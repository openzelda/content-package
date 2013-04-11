/***********************************************
 * Copyright © Luke Salisbury
 *
 * You are free to share, to copy, distribute and transmit this work
 * You are free to adapt this work
 * Under the following conditions:
 *  You must attribute the work in the manner specified by the author or licensor (but not in any way that suggests that they endorse you or your use of the work). 
 *  You may not use this work for commercial purposes.
 * Full terms of use: http://creativecommons.org/licenses/by-nc/3.0/
 * Changes:
 *     2010/01/11 [luke]: new file.
 *     2011/07/01 [luke]: added knockback
 * Todo:
 ***********************************************/

//#include <network>
#include <movement>
#include <player_function>


/* Main Code */
public Init(...)
{
	mqAllowOffscreenMovement = true;
	mqEntityId = entityId:EntityGetSettingHash("id");

	GetEntityPosition(mqEntityPosition.x, mqEntityPosition.y, mqEntityPosition.z, mqDisplayArea.x, mqDisplayArea.y, mqDisplayZIndex, mqDisplayLayer);
	SetEntityDimension(30, 24, 2, 24);
	SetPlayerSprites("p01n.png", "p01push.png", "p01pull.png", "p01swim.png", "p01swing.png");
	SetState(STANDING);
	SetType(TYPE_PLAYER);
	SetDir(SOUTH);

	mqDisplayObject = ObjectCreate(animation[mqState][0], SPRITE, mqDisplayArea.x, mqDisplayArea.y, mqDisplayZIndex, 0, 0, WHITE);


	mqHudEntity = EntityCreate( "hud", HUD_ENTITY_ID, 0, 0, 6, GLOBAL_MAP, [ARG_RETURN_NUMBER, ARG_END], mqEntityId  );
	mqMenuEntity = EntityCreate( "menu", MENU_ENTITY_ID, 0, 0, 6, GLOBAL_MAP, [ARG_RETURN_NUMBER, ARG_END], mqEntityId );
	
	EntityCreate( "transition", "transition", 0, 0, 0, GLOBAL_MAP, [ARG_RETURN_NUMBER, ARG_END], mqEntityId );
	EntityCreate( "tester-transition", "", 0,0,6, GLOBAL_MAP);

	//SetRestartPosition(0, mqDisplayArea.x, mqDisplayArea.y, MapCurrent(), "Start");


	GiveWeapon("weapon_sword");
}

/* UpdatePosition is called when a global entity has changed maps */
public UpdatePosition()
{
	GetEntityPosition(mqEntityPosition.x, mqEntityPosition.y, mqEntityPosition.z, mqDisplayArea.x, mqDisplayArea.y, mqDisplayZIndex, mqDisplayLayer);
	MapSetOffset(mqEntityPosition.x,mqEntityPosition.y);
	DisplayPlayer();
}

/* Called each frame */
main()
{
	DebugText("mqDisplayZIndex: %d, mqDisplayLayer: %d", mqDisplayZIndex, mqDisplayLayer );
	DebugText("mqSelectedWeapons: %d", mqSelectedWeapons[0] );
	DebugText("mqDisplayObject: %d", mqDisplayObject );

	new sx, sy;
	ObjectInfo(mqDisplayObject, sx, sy);
	if ( mqState == GONE || GameState() != 1 )
		return;

	if ( mqHealth <= 0 && mqState < DYING )
	{
		hit = 1000;
		mqState = DYING;
	}

	if ( mqState >= DYING )
	{
		HandleDeath();
		return;
	}

	GetEntityPosition(mqEntityPosition.x, mqEntityPosition.y, mqEntityPosition.z, mqDisplayArea.x, mqDisplayArea.y, mqDisplayZIndex, mqDisplayLayer);

	CheckForKeys();
	MovePlayer();
	CheckEnvironment();
	DisplayPlayer();

	CheckCollisions();
	if ( Countdown(hit) )
	{
		mqState = (mqState == KNOCKED) ? STANDING : mqState;
	}
	UpdateState();
}

public Close()
{
	CollisionSet(SELF, -1);
	ObjectDelete(mqDisplayObject);
}

/* */

CheckCollisions()
{

	if ( CollisionCalculate() )
	{
		new entityId:current;
		new angle;
		new dist;
		new rect;
		new type;
		while ( CollisionGetCurrent(SELF, current, angle, dist, rect, type) )
		{
			if ( type == TYPE_AWAKING )
			{
				CallEntityAwaking( current, mqEntityId, rect);
			}
			else if ( type == TYPE_ENEMY || type == TYPE_DOOR )
			{
				CallEntityHit( current, mqEntityId, D2A(mqDirection), dist, APLAYER, 0, mqDisplayArea.x,mqDisplayArea.y, rect );
			}
			else if ( type == TYPE_TRANSPORT )
			{
				//MovePlayer(player, dir)
				if ( EntityPublicFunction(current, "MovePlayer", ''nn'', mqEntityId, mqDirection) == 1 )
				{
					 mqState = STANDING;
				}
			}
			else if ( type == TYPE_PUSHABLE && mqState == PUSHING )
			{
				// public Push(attacker[], rect, angle)
				CallEntityPush(current, mqEntityId, rect, angle);
			}
			else if ( type == TYPE_SWITCH )
			{
				// public Pressed(attacker[])
				CallEntityPressed(current, mqEntityId, rect, angle);
			}
			else if ( type == TYPE_ITEM )
			{
				// public Pickup(attacker[])
				if ( CallEntityPickup(current,  mqEntityId) )
				{
					mqState = LIFTING;
				}
			}
		}
	}
}

public Hurt(type, damage, angle)
{
	if (mqState >= KNOCKED)
		return;
	if ( Countdown(hit) )
	{
		if ( mqState == USING )
			EntityPublicFunction(mqSelectedWeapons[mqUsingWeapon], "End", ''nn'', mqDisplayObject, mqDirection);
		SetState(KNOCKED);
		mqHealth -= damage;
		mqMovementAngle = angle%360;
		EntityPublicFunction(mqHudEntity, "Refresh", "");
		hit = 1000;
	}
}

MovePlayer()
{
	mqFlipXMovement = false;
	if ( mqState == USING || mqState == LIFTING )
		return;
	else if ( mqState == STANDING )
		mqMovementSpeed = 0;
	else if ( mqState == PUSHING )
		mqMovementSpeed = 20.00;
	else if ( mqState == KNOCKED )
	{
		mqFlipXMovement = true;
		mqMovementSpeed = -40.00;
	}
	else
		mqMovementSpeed = 80.00;
	if ( EntityMove(MASK_PLAYERSOLID2) )
		EntityPublicFunction( EntityHash("__map__"), "SetPlayerPosition", ''nnn'', _:mqEntityPosition.x, _:mqEntityPosition.y, _:mqDisplayZIndex);
	MapSetOffset(mqEntityPosition.x,mqEntityPosition.y);
	CollisionSet(SELF,0,TYPE_PLAYER,mqDisplayArea.x+mqDisplayOffset.x,mqDisplayArea.y+mqDisplayOffset.y,mqDisplayArea.w,mqDisplayArea.h);
}

CheckEnvironment()
{
	new maskv = MaskGetValue( mqDisplayArea.x+8, mqDisplayArea.y+8 );
	if ( maskv == MASK_PUDDLE )
	{
	}
	else if ( maskv == MASK_WATER )
	{
	}

}

PushCheck( qdir )
{
	if ( qdir != mqDirection )
		push_delay = 0.00;
	else if ( mqState == PUSHING )
		return true;

	if ( mqLocations[2][0] == mqDisplayArea.x && mqLocations[2][1] == mqDisplayArea.y && mqLocations[2][3] == qdir )
		push_delay += GameFrame2();
	else
		push_delay = 0.00;

	if ( push_delay > 0.1 )
	{
		return true;
	}
	return false;
}


CheckForKeys()
{
	new x_movement = 0;
	new y_movement = 0;

	if ( GameState() == 3 )
		return;

	if ( GameState() == 1 )
	{
		weapon_action[0] = InputButton(BUTTON_ACTION1, controller);
		weapon_action[1] = InputButton(BUTTON_ACTION2, controller);
		weapon_action[2] = InputButton(BUTTON_ACTION3, controller);
	}

	if ( InputButton(BUTTON_MENU, controller) == 1 )
	{
		EntityPublicFunction(mqMenuEntity, "Show", ''nnnn'', mqEntityId, mqSelectedWeapons[0], mqSelectedWeapons[1], mqSelectedWeapons[2] );
		return;
	}

	if ( mqState == USING )
	{
		if ( mqUsingWeapon != -1 )
		{
			EntitySetPosition(mqEntityPosition.x, mqEntityPosition.y, mqEntityPosition.z, mqSelectedWeapons[mqUsingWeapon]);
			if ( EntityPublicFunction( mqSelectedWeapons[mqUsingWeapon], "Use", ''nn'', mqDisplayObject, mqDirection) > 0 )
				return;
			else
				SetState(STANDING);
		}
		else
			SetState(STANDING);
	}
	else if ( mqState == KNOCKED )
	{
		return;
	}
	else if ( mqState != LIFTING && GameState() == 1 )
	{
		x_movement = InputAxis(0);
		y_movement = InputAxis(1);
	}
	
	mqMovementAngle = 0.0;
	
	if ( x_movement || y_movement )
	{
		mqMovementAngle = MovementAngle( Fixed:x_movement, Fixed:y_movement);
		
		new a = Angle2Dir(mqMovementAngle, 0);
		
		mqState = PushCheck( a ) ? PUSHING : MOVING;
		mqDirection = a
		mqDisplayDirection = NumberClamp((mqDirection/2), 0, 3);
		mqUpdate = true;
	}
	else
	{
		push_delay = 0.00;
		mqState = (mqState == LIFTING ? LIFTING : STANDING );
	}
	
	UpdateState();

	if ( weapon_action[0] == 1 && mqSelectedWeapons[0])
	{
		animationUsingCustom = false;
		EntitySetPosition(mqEntityPosition.x, mqEntityPosition.y, mqEntityPosition.z, mqSelectedWeapons[0]);
		if ( CallEntityUse(mqSelectedWeapons[0], mqDisplayObject, mqDirection ) == 1 )
		{
			mqState = USING;
			mqUsingWeapon = 0;
		}
	}
	else if ( weapon_action[1] == 1  && mqSelectedWeapons[1])
	{
		animationUsingCustom = false;
		EntitySetPosition(mqEntityPosition.x, mqEntityPosition.y, mqEntityPosition.z, mqSelectedWeapons[1]);
		if ( CallEntityUse(mqSelectedWeapons[1], mqDisplayObject, mqDirection) == 1 )
		{
			mqState = USING;
			mqUsingWeapon = 1;
		}
	}
	else if ( weapon_action[2] == 1  && mqSelectedWeapons[2])
	{
		animationUsingCustom = false;
		EntitySetPosition(mqEntityPosition.x, mqEntityPosition.y, mqEntityPosition.z, mqSelectedWeapons[2]);
		if ( CallEntityUse(mqSelectedWeapons[2], mqDisplayObject, mqDirection) == 1 )
		{
			mqState = USING;
			mqUsingWeapon = 2;
		}
	}
	else
	{
		mqUsingWeapon = -1;
	}
}


DisplayPlayer()
{
	if ( HasStateChanged() )
	{
		if ( !(mqState == USING && animationUsingCustom) )
			ObjectReplace(mqDisplayObject, STATE_GRAPHIC, SPRITE );
		ObjectEffect(mqDisplayObject, WHITE, _, _, _, STATE_FLIP, _, _);
	}
	ObjectPosition(mqDisplayObject, mqDisplayArea.x, mqDisplayArea.y, mqDisplayZIndex, 0, 0);
	if ( hit > 0 )
		hidden = !hidden;
	else
		hidden = 1;
	ObjectToggle(mqDisplayObject, hidden);
}


UpdateState()
{
	/* Disabled Network Code */
	/*
	new message[1];
	message[0] = ( animdir << 24 | mqState << 16 | fround(mqMovementAngle) );
	NetworkMessage(false, 2, message, 1 );
	*/
}

