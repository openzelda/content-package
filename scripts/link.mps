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

new sprite_colour = 0xFFFFFF00;

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
	switch (game_state)
	{
		case GS_PAUSE:
			main_pause();
		case GS_MENU:
			main_menu();
		default:
			main_player();
	}
}

public Close()
{
	CollisionSet(SELF, -1);
	ObjectDelete(qObject);
}

/* */
main_pause()
{

}

main_player() {
	// Menu 


	if ( qState == GONE || GameState() == GS_PAUSE )
		return;

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

	if (  GameState() == GS_ALL )
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
/*
	new x = qDisplayArea.x;
	new y = qDisplayArea.y;
	new s[8]{20} = [ "SOUTH", "SOUTHEAST","EAST","NORTHEAST","NORTH","NORTHWEST","WEST","SOUTHWEST"];

	//GraphicsDraw( s[qDirection], TEXT, x, y, 6.0, 0, 0, RED);
*/


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

	/* Disabled Network Code */
	/*
	new message[1];
	message[0] = ( animdir << 24 | qState << 16 | fround(qMovementAngle) );
	NetworkMessage(false, 2, message, 1 );
	*/
}
