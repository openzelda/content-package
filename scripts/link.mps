/***********************************************
 * Copyright © Luke Salisbury
 *
 * You are free to share, to copy, distribute and transmit this work
 * You are free to adapt this work
 * Under the following conditions:
 *  You must attribute the work in the manner specified by the author or licensor (but 
 *    not in any way that suggests that they endorse you or your use of the work). 
 *  You may not use this work for commercial purposes.
 * Full terms of use: http://creativecommons.org/licenses/by-nc/3.0/
 * Changes:
 *     2010/01/11 [luke]: new file.
 *     2011/07/01 [luke]: added knockback
 * Todo:
 ***********************************************/
#define HITLENGTH 500
#define INVLENGTH 1000

#include <movement>
#include <player_function>

/* Variable */
new sprite_colour = 0xFFFFFF00;
new Fixed:pushDelay;
new entity:hudEntity;
new controller;

new hitTimer[SIMPLETIMER] = [0, 0];
new invTimer[SIMPLETIMER] = [0, 0];


new entity:qCounters[16];
new countersSize[6] = [ 300, 20, 20, 500, 9, 300];
new _restart[3][RestartPoint];
new __timerSelectorAnim = 0;
new __RestartMenuPosition = 0;
new DeathCount = 0;
new __DeathMenuPosition = 0;
new __SaveDetail[64] ={};
new weapon_action[3] = [0,0,0];
new qSelectedWeapons[4];
new qUsingWeapon = -1;

stock animationUsingCustom = false;

public internal_screen_width;
public internal_screen_height;

/* Public Functions */
forward public UpdatePosition();
forward public GiveWeapon( weapon{} );
forward public SetWeapon( weapon_id, slot );
forward public SetPlayerSprites( normal{32}, push{32}, pull{32}, swim{32}, using{32} );
forward public SetRestartPosition( point, ndescription{}, nx, ny, nmapid );
forward public UsingCustomAnimation()

forward public GetItemCounter( type );
forward public IncreaseItemCount( type, worth );


/* Main Code */
public Init(...)
{
	SetAllowOffscreenMovement();
	GetEntityPosition(qPosition.x, qPosition.y, qPosition.z, qDisplayArea.x, qDisplayArea.y );
	SetEntityDimension(30, 24, 2, 24);
	SetPlayerSprites("p01.png", "p01push.png", "p01pull.png", "p01swim.png", "p01swing.png");

	SetState(STANDING);
	SetType(TYPE_PLAYER);
	SetDir(SOUTH);

	SetObject(StateGraphics[qState][0], qDisplayArea.x, qDisplayArea.y, qPosition.z)

	/* */
	CreateItemCounters()

	hudEntity = EntityCreate( "hud", "", 0, 0, 6.0, GLOBAL_MAP, [ARG_RETURN_NUMBER, ARG_END], _, internal_ident  );

	EntityCreate( "transition", "transition", 0, 0, 0, GLOBAL_MAP, [ARG_RETURN_NUMBER, ARG_END], _, internal_ident );

	SetRestartPosition(0, "Start", qDisplayArea.x, qDisplayArea.y, MapCurrentIdent() );

	GiveWeapon("weapon_sword");

	GameState(GS_ALL);

	qHealth = 50
}

/* UpdatePosition is called when a global entity has changed maps */
public UpdatePosition()
{
	GetEntityPosition(qPosition.x, qPosition.y, qPosition.z, qDisplayArea.x, qDisplayArea.y );
	MapOffsetSet(qPosition.x,qPosition.y);
	DisplayPlayer();
}

/* Called each frame */
main()
{
	new game_state = GameState();
	ConsoleOutput("State: %d - %x", game_state, qObject & 0x80000000);

	switch (game_state)
	{
		case GS_PAUSE:
			main_pause();
		case GS_MENU:
			main_menu();
		case GS_RESTART:
			main_restart_menu();
		default:
			main_player();
	}
}

public Close()
{
	CollisionSet(SELF, -1);
	ObjectDelete(qObject);
}

/*   */
main_pause()
{

}

main_restart_menu()
{
	EntityPublicFunction(hudEntity, "Hide", [ARG_END] );
	HandleRestartMenu()
}

main_player()
{
	if ( qState == GONE || GameState() == GS_PAUSE )
		return;

	if ( GameState() == GS_RESTART )
	{
		//SystemCommand(4,1);
		return;
	}
	if ( qHealth <= 0 && qState < DYING )
	{
		TimerSimpleStart(hitTimer, HITLENGTH);
		qState = DYING;
	}

	if ( qState >= DYING )
	{
		HandleDeath();
		return;
	}

	if ( InputButton(BUTTON_MENU) == 1 )
	{
		EntityPublicFunction(hudEntity, "ShowMenu", ''nnnn'', _, internal_ident, qSelectedWeapons[0], qSelectedWeapons[1], qSelectedWeapons[2] );
	}

	GetEntityPosition(qPosition.x, qPosition.y, qPosition.z, qDisplayArea.x, qDisplayArea.y );

	CheckForKeys();
	MovePlayer();
	CheckEnvironment();
	DisplayPlayer();

	CheckCollisions();

	UpdateState();

	if ( InputButton(4)  == 1)
	{
		qHealth -= 50;
	}
	if ( InputButton(5)  == 1)
	{
		qHealth += 50;
	}
	ConsoleOutput("Restart: %dx%d on %d", _restart[0].x, _restart[0].y, _restart[0].mapid );
}

main_menu()
{
	if ( InputButton(BUTTON_MENU) == 1 )
	{
		EntityPublicFunction(hudEntity, "HideMenu");
	}
}

CheckCollisions()
{
	if ( CollisionCalculate() )
	{
		new entity:current;
		new angle;
		new dist;
		new rect;
		new type;
		while ( CollisionGetCurrent(SELF, current, angle, dist, rect, type) )
		{
			ConsoleOutput("Player Collision: %d", type );
			if ( type == TYPE_AWAKING )
			{
				CallEntityAwaking( current, internal_ident, rect);
			}
			else if ( type == TYPE_ENEMY  )
			{
				CallEntityHit( current, internal_ident, angle, dist, APLAYER, 0, qDisplayArea.x + qDisplayArea.w/2, qDisplayArea.y + qDisplayArea.h/2, rect );
			}
			else if ( type == TYPE_DOOR || type == TYPE_DROPITEM )
			{
				CallEntityHit( current, internal_ident, angle, dist, APLAYER, 0, qDisplayArea.x + qDisplayArea.w/2, qDisplayArea.y + qDisplayArea.h/2, rect );
			}
			else if ( type == TYPE_TRANSPORT )
			{
				if ( CallEntityMovePlayer(current, internal_ident, qDirection) == 1 )
				{
					 qState = STANDING;
				}
			}
			else if ( type == TYPE_PUSHABLE && qState == PUSHING )
			{
				// public Push(attacker[], rect, angle)
				CallEntityPush(current, internal_ident, rect, angle);
			}
			else if ( type == TYPE_SWITCH )
			{
				// public Pressed(attacker[])
				CallEntityPressed(current, internal_ident, rect, angle);
			}
			else if ( type == TYPE_ITEM )
			{
				// public Pickup(attacker[])
				if ( CallEntityPickup(current,  internal_ident) )
				{
					qState = LIFTING;
				}
			}
		}
	}
}

PUBLIC_EVENT_HURT
{
	//SystemCommand(4,1);
	if (qState >= KNOCKED)
		return;

	if ( invTimer.active == 0 && hitTimer.active == 0)
	{
		if ( qState == USING )
			EntityPublicFunction(qSelectedWeapons[qUsingWeapon], "End", ''nn'', qObject, qDirection);
		
		SetState(KNOCKED);
		qHealth -= damage;
		qMovementAngle = angle

		TimerSimpleStart(hitTimer, HITLENGTH);
		TimerSimpleStart(invTimer, INVLENGTH);
	}
}

MovePlayer()
{
	if ( qState == USING || qState == LIFTING )
		return;
	else if ( qState == STANDING )
		qMovementSpeed = 0;
	else if ( qState == PUSHING )
		qMovementSpeed = 20.00;
	else if ( qState == KNOCKED )
	{
		qMovementSpeed = -80.00;
		qFlipXMovement = true;
	}
	else
		qMovementSpeed = 80.00;

	if ( EntityMove(MASK_PLAYERSOLID) )
	{
		EntityPublicFunction( MAP_ENTITY, "SetPlayerPosition", ''nnn'', _, qPosition.x, qPosition.y, qPosition.z);
	}
	MapOffsetSet(qPosition.x,qPosition.y);

	CollisionSet(SELF,0,TYPE_PLAYER,qDisplayArea.x+qDisplayOffset.x,qDisplayArea.y+qDisplayOffset.y,qDisplayArea.w,qDisplayArea.h);

	qFlipYMovement = qFlipXMovement = false;
}

CheckEnvironment()
{
	new maskv = MaskGetValue( qDisplayArea.x+8, qDisplayArea.y+8 );
	if ( maskv == MASK_PUDDLE )
	{
	}
	else if ( maskv == MASK_WATER )
	{
	}

}

PushCheck( direction )
{
	if ( direction != qDirection )
		pushDelay = 0.00;
	else if ( qState == PUSHING )
		return true;

	if ( qLocations[2].x == qDisplayArea.x && qLocations[2].y == qDisplayArea.y && qLocations[2].dir == direction )
		pushDelay += GameFrameSeconds();
	else
		pushDelay = 0.00;

	if ( pushDelay > 0.1 )
	{
		return true;
	}
	return false;
}


CheckForKeys()
{
	new x_movement = 0;
	new y_movement = 0;

	if ( GameState() == GS_MENU )
	{
		return;
	}

	if ( GameState() == GS_ALL )
	{
		weapon_action[0] = InputButton(BUTTON_ACTION1, controller);
		weapon_action[1] = InputButton(BUTTON_ACTION2, controller);
		weapon_action[2] = InputButton(BUTTON_ACTION3, controller);
	}

	if ( qState == USING )
	{
		if ( qUsingWeapon != -1 )
		{
			EntitySetPosition(qPosition.x, qPosition.y, qPosition.z, qSelectedWeapons[qUsingWeapon]);
			if ( EntityPublicFunction( qSelectedWeapons[qUsingWeapon], "Use", [ARG_NUMBER, ARG_NUMBER,ARG_END], _, qObject, qDirection) > 0 )
				return;
			else
				SetState(STANDING);
		}
		else
			SetState(STANDING);
	}
	else if ( qState == KNOCKED )
	{
		return;
	}
	else if ( qState != LIFTING &&  GameState() == GS_ALL )
	{
		x_movement = InputAxis(0);
		y_movement = InputAxis(1);
	}
	
	qMovementAngle = 0.0;

	if ( x_movement || y_movement )
	{
		qMovementAngle = MovementAngle( Fixed:x_movement, Fixed:y_movement);
		
		new a = Angle2Dir(qMovementAngle, 0);
		
		qState = PushCheck( a ) ? PUSHING : MOVING;
		SetDir(a);
		qUpdate = true;
	}
	else
	{
		pushDelay = 0.00;
		qState = (qState == LIFTING ? LIFTING : STANDING );
	}
	
	UpdateState();

	if ( weapon_action[0] == 1 && qSelectedWeapons[0])
	{
		animationUsingCustom = false;
		EntitySetPosition(qPosition.x, qPosition.y, qPosition.z, qSelectedWeapons[0]);
		if ( CallEntityUse(qSelectedWeapons[0], qObject, qDirection ) == 1 )
		{
			qState = USING;
			qUsingWeapon = 0;
		}
	}
	else if ( weapon_action[1] == 1  && qSelectedWeapons[1])
	{
		animationUsingCustom = false;
		EntitySetPosition(qPosition.x, qPosition.y, qPosition.z, qSelectedWeapons[1]);
		if ( CallEntityUse(qSelectedWeapons[1], qObject, qDirection) == 1 )
		{
			qState = USING;
			qUsingWeapon = 1;
		}
	}
	else if ( weapon_action[2] == 1  && qSelectedWeapons[2])
	{
		animationUsingCustom = false;
		EntitySetPosition(qPosition.x, qPosition.y, qPosition.z, qSelectedWeapons[2]);
		if ( CallEntityUse(qSelectedWeapons[2], qObject, qDirection) == 1 )
		{
			qState = USING;
			qUsingWeapon = 2;
		}
	}
	else
	{
		qUsingWeapon = -1;
	}
}

DisplayPlayer()
{
	if ( HasStateChanged() )
	{
		if ( !(qState == USING && animationUsingCustom) )
			ObjectReplace(qObject, STATE_GRAPHIC, SPRITE );
		ObjectEffect(qObject, sprite_colour, _, _, _, STATE_FLIP, _, _);
	}
	ObjectPosition(qObject, qDisplayArea.x, qDisplayArea.y, qPosition.z, 0, 0);
	ObjectEffect(qObject, sprite_colour, _, _, _, STATE_FLIP, _, _);
}

CycleAlpha(value, repeat)
{
	new r = value % repeat;
	new d = value / repeat;
	return (d % 2 ==1 ? 0 + r : 255 -r);
}

UpdateState()
{
	if ( TimerSimpleCountdown(hitTimer) )
	{
		qState = (qState == KNOCKED) ? STANDING : qState;
	}
	
	TimerSimpleCountdown(invTimer);
	if ( invTimer.active )
		sprite_colour = 0xFFFFFF00 + CycleAlpha(invTimer.timer, INVLENGTH/4)
	else
		sprite_colour = 0xFFFFFFFF;
}

/* Animation Code */ 
public UsingCustomAnimation()
{
	animationUsingCustom = true;
}

public SetPlayerSprites( normal{32}, push{32}, pull{32}, swim{32}, using{32} )
{
	SheetReference(normal);
	SheetReference(push);
	SheetReference(pull);
	SheetReference(swim);
	SheetReference(using);

	SetStateGraphic( STANDING, normal, "front_0", "side_0", "back_0", "side_0" );
	SetStateGraphic( MOVING, normal, "front", "side", "back", "side" );
	SetStateGraphic( USING, using, "front", "side", "back", "side" );
	SetStateGraphic( KNOCKED, normal, "front_knock", "side_knock", "back_knock", "side_knock" );
	SetStateGraphic( PUSHING, push, "front", "side", "back", "side" );
	SetStateGraphic( PULLING, pull, "front", "side", "back", "side" );
	SetStateGraphic( DYING, normal, "death", "death", "death", "death" );
	SetStateGraphic( DEAD, normal, "death_1", "death_1", "death_1", "death_1" );

}

/* Restart Point Code */
public SetRestartPosition( point, ndescription{}, nx, ny, nmapid )
{
	point %= 3;
	StringCopy(_restart[point].description, ndescription);

	if ( nx == -1 )
		_restart[point].x = _:qPosition.x;
	else
		_restart[point].x = nx;

	if ( ny == -1 )
		_restart[point].y = _:qPosition.y;
	else
		_restart[point].y = ny;

	_restart[point].mapid = nmapid;
	_restart[point].active = 1;

}

HandleRestartMenu()
{
	GameState(GS_RESTART);
	new x = 64;
	new y = internal_screen_height/2 - 96;

	GraphicsDraw("menu_border01.png:1", SPRITE, x, y, 6.0, internal_screen_width- (x*2), 96);
	AnimationDraw("alpha03.png:selector", __timerSelectorAnim, x , y + (__RestartMenuPosition*32), 6.0, 0, 0)
	for( new i = 0; i < 3; i++ )
	{
		CustomText(_restart[i].description, -1, x+32, y + (i*32), .box_width = 320)
	}

	__RestartMenuPosition += InputAxisAsButton(YAXIS);
	__RestartMenuPosition %= 3;

	if ( InputButton( BUTTON_ACTION1 ) == BUTTON_PRESSED)
	{
		HandleRestart();
	}
}

HandleRestart()
{
	LayerColour(-1, 0xFFFFFFFF);

	qHealth = qMaxHealth;
	qState = STANDING;

	ObjectReplace(qObject, StateGraphics[STANDING][0], SPRITE);

	EntityPublicFunction( hudEntity, "Show", [ARG_END] );

	TransitionPlayerReset( internal_ident, _restart[__RestartMenuPosition].mapid );
	EntitySetPosition( _restart[__RestartMenuPosition].x, _restart[__RestartMenuPosition].y, _ );
}

/* Hurting and Death */
HandleDeathMenu()
{
	EntityPublicFunction( hudEntity, "Hide", [ARG_END] );
	new x = 64;
	new y = internal_screen_height/2 - 96;
	GraphicsDraw("menu_border01.png:1", SPRITE, x, y, 6.0, internal_screen_width- (x*2), 96);
	AnimationDraw("alpha03.png:selector", __timerSelectorAnim, x , y +  (__DeathMenuPosition*32), 6.0, 0, 0) ;

	CustomText("Game Over", -1, -1, y-64, .box_width = internal_screen_width)
	CustomText("Save and Continue", -1, x+32, y, .box_width = internal_screen_width);
	CustomText("Continue", -1, x+32, y+32, .box_width = internal_screen_width);
	CustomText("Exit", -1, x+32, y+64, .box_width = internal_screen_width);

	__DeathMenuPosition += InputAxisAsButton(YAXIS);
	__DeathMenuPosition = clamp(__DeathMenuPosition, 0, 2);
	
	if ( InputButton( BUTTON_ACTION1 ) )
	{
		if ( __DeathMenuPosition == 0 )
		{
			GameSave(0, __SaveDetail);
			GameState(GS_RESTART);
			Transition("respawn");
		}
		else if ( __DeathMenuPosition == 1 )
		{
			GameState(GS_RESTART);
			Transition("respawn");
		}
		else
		{
			SystemCommand(COMMAND_EXIT);
		}
	}
}

HandleDeath()
{
	GameState(GS_PLAYER);
	ObjectPosition(qObject, qDisplayArea.x, qDisplayArea.y, qPosition.z, 0, 0);
	if ( qState == DEAD )
	{
		DeathCount = 0;
		ObjectReplace(qObject, StateGraphics[DEAD][0], SPRITE);
		HandleDeathMenu();

	}
	else if ( qState == DYING ) 
	{
		LayerColour(0, 0xFF0000FF);
		LayerColour(1, 0xFF0000FF);
		LayerColour(2, 0xFF0000FF);
		LayerColour(3, 0xFF0000FF);
		LayerColour(4, 0xFF0000FF);
		LayerColour(5, 0xFF0000FF);
		
		if ( DeathCount == 0 )
		{
			DeathCount = AnimationGetLength( "p01.png", "death" );
			ObjectReplace(qObject, StateGraphics[DYING][0], SPRITE);
		}
		if ( TimerCountdown(DeathCount) )
			qState = DEAD;
	}
}

/* Weapon */

public GiveWeapon( weapon{} )
{
	new entity:hash;
	new entityName{64};
	StringCopy(entityName, weapon);

	hash = EntityCreate( entityName, "", 0, 0, qPosition.z, GLOBAL_MAP );

	EntityPublicFunction( hash, "SetOwner", [ ARG_NUMBER, ARG_END ], _, internal_ident );
	EntityPublicFunction( hudEntity, "AddWeapon", [ ARG_STRING, ARG_NUMBER, ARG_NUMBER, ARG_END ], _, entityName, hash, internal_ident );

	SetWeapon( hash, BUTTON_ACTION1 );
}

public SetWeapon( weapon_id, slot )
{
	if ( slot >= 0 && slot < 4 ) 
	{
		qSelectedWeapons[slot] = weapon_id;
	}
}

/* Items */



static ipow(base, exp)
{
	new result = 1;
	while (exp)
	{
		if (exp & 1)
			result *= base;
		exp >>= 1;
		base *= base;
	}

	return result;
}

public GetItemCounter( type )
{
	if ( type < 16 && type >= 0)
	{
		return qCounters[type];
	}
	return 0;

}

CreateItemCounters()
{
	for ( new q = 0; q < 6; q++ ) 
	{
		qCounters[q] = EntityCreate("counter", "", 0, 0, 1, GLOBAL_MAP, [ARG_RETURN_NUMBER, ARG_RETURN_NUMBER, ARG_END], _, 0, countersSize[q] ); 
	}
}

public IncreaseItemCount( type, worth )
{
	if ( type < 16 && type >= 0)
	{	
		if ( qCounters[type] )
		{
			EntityPublicFunction( qCounters[type], "@IncreaseTarget", [ARG_NUMBER, ARG_END], _, worth );
		}
	}
}
