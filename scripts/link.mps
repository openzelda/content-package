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
#include <open_zelda>
#include <network>

#include <player>

#include <player_function>







/* Main Code */
public Init(...)
{
	_allow_offscreen = true;


	
	SetEntityDimension(30, 24, 2, 24);
	SetPlayerSprites("p01n.png", "p01push.png", "p01pull.png", "p01swim.png");
	SetState(STANDING);
	SetType(TYPE_PLAYER);
	SetDir(SOUTH);

	obj = ObjectCreate(animation[mqState][0], SPRITE, mqDisplayArea.x, mqDisplayArea.y, mqDisplayZIndex, 0, 0, WHITE);

	self_hash_id = EntityGetSettingHash( "id" );

	//EntityCreate( "hud", HUD_ENTITY_ID, 0, 0, 6, GLOBAL_MAP, _, "s", self_hash_id );
	menu_hash_id = EntityCreate( "menu", MENU_ENTITY_ID, 0, 0, 6, GLOBAL_MAP, _, "n", self_hash_id );
	GiveWeapon("weapon_sword");

	//SetRestartPosition(0, mqDisplayArea.x, mqDisplayArea.y, MapCurrent(), "Start");

}

/* UpdatePosition is called when a global entity has changed maps */
public UpdatePosition()
{
	GetEntityPosition(mqEntityPosition.x, mqEntityPosition.y, mqDisplayZIndex, mqDisplayArea.x, mqDisplayArea.y, mqDisplayZIndex, mqDisplayLayer);
	MapSetOffset(mqEntityPosition.x,mqEntityPosition.y);
	DisplayPlayer();
}

/* Called each frame */
main()
{
	new sx, sy;
	ObjectInfo(obj, sx, sy);
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

	GetEntityPosition(mqEntityPosition.x, mqEntityPosition.y, mqDisplayZIndex, mqDisplayArea.x, mqDisplayArea.y, mqDisplayZIndex, mqDisplayLayer);

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
	ObjectDelete(obj);
}

/* */

CheckCollisions()
{
	return;
	if ( CollisionCalculate() )
	{
		new current;
		new angle;
		new dist;
		new rect;
		new type;
		while ( CollisionGetCurrent(SELF, current, angle, dist, rect, type) )
		{
			if ( type == TYPE_AWAKING )
			{
				EntityPublicFunction(current, "Awaking", "sn", selfid, rect);
			}
			else if ( type == TYPE_ENEMY || type == TYPE_DOOR )
			{
				// public Hit( attacker[], angle, dist, attack, damage, x, y, rect )
				EntityPublicFunction(current, "Hit", "snnnnnn", selfid, D2A(mqDirection), dist, APLAYER, 0, mqDisplayArea.x,mqDisplayArea.y, rect);
			}
			else if ( type == TYPE_TRANSPORT )
			{
				//MovePlayer(player, dir)
				if ( EntityPublicFunction(current, "MovePlayer", "sn", selfid, mqDirection) == 1 )
				{
					 mqState = STANDING;
				}
			}
			else if ( type == TYPE_PUSHABLE && mqState == PUSHING )
			{
				// public Push(attacker[], rect, angle)
				EntityPublicFunction(current, "Push", "snn", selfid, rect, angle);
			}
			else if ( type == TYPE_SWITCH )
			{
				// public Pressed(attacker[])
				EntityPublicFunction(current, "Pressed", "s", selfid);
			}
			else if ( type == TYPE_ITEM )
			{
				// public Pickup(attacker[])
				if ( EntityPublicFunction(current, "Pickup", "s", selfid) )
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
			EntityPublicFunction(weapons[0], "End", "nn", obj, mqDirection);
		SetState(KNOCKED);
		mqHealth -= damage;
		mqMovementAngle = angle%360;
		EntityPublicFunction(hud_hash_id, "Refresh", "");
		hit = 1000;
	}
}

MovePlayer()
{
	_flipx_ = false;
	if ( mqState == USING || mqState == LIFTING )
		return;
	else if ( mqState == STANDING )
		mqMovementSpeed = 0;
	else if ( mqState == PUSHING )
		mqMovementSpeed = 20.00;
	else if ( mqState == KNOCKED )
	{
		_flipx_ = true;
		mqMovementSpeed = -40.00;
	}
	else
		mqMovementSpeed = 80.00;
	if ( EntityMove(MASK_PLAYERSOLID2) )
		EntityPublicFunction( EntityHash("__map__"), "SetPlayerPosition", "nnn", _:mqEntityPosition.x, _:mqEntityPosition.y, _:mqDisplayZIndex);
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

	if ( locations[2][0] == mqDisplayArea.x && locations[2][1] == mqDisplayArea.y && locations[2][3] == qdir )
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
		EntityPublicFunction(menu_hash_id, "Show", "ssss", selfid, weapons[0], weapons[1], weapons[2] );
		return;
	}

	if ( mqState == USING )
	{
		if ( weapon_active != -1 )
		{
			EntitySetPosition(mqEntityPosition.x, mqEntityPosition.y, mqDisplayZIndex, weapons[weapon_active]);
			if ( EntityPublicFunction( weapons[weapon_active], "Use", "nn", obj, mqDirection) > 0 )
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
		x_movement = InputAxis(0,controller);
		y_movement = InputAxis(1,controller);
	}
	
	mqMovementAngle = 0.0;
	
	if ( x_movement || y_movement )
	{
		mqMovementAngle = MovementAngle( Fixed:x_movement, Fixed:y_movement);
		
		new a = Angle2Dir(mqMovementAngle, 0);
		
		mqState = PushCheck( a ) ? PUSHING : MOVING;
		mqDirection = a
		_animdir_ = NumberClamp((mqDirection/2), 0, 3);
		update = true;
	}
	else
	{
		push_delay = 0.00;
		mqState = (mqState == LIFTING ? LIFTING : STANDING );
	}
	
	UpdateState();

	if ( weapon_action[0] == 1 && weapons[0])
	{
		EntitySetPosition(mqEntityPosition.x, mqEntityPosition.y, mqDisplayZIndex, weapons[0]);
		if ( EntityPublicFunction(weapons[0], "Use", "nn", obj, mqDirection) == 1 )
		{
			mqState = USING;
			weapon_active = 0;
		}
	}
	else if ( weapon_action[1] == 1  && weapons[1])
	{
		EntitySetPosition(mqEntityPosition.x, mqEntityPosition.y, mqDisplayZIndex, weapons[1]);
		if ( EntityPublicFunction(weapons[1], "Use", "nn", obj, mqDirection) == 1 )
		{
			mqState = USING;
			weapon_active = 1;
		}
	}
	else if ( weapon_action[2] == 1  && weapons[2])
	{
		EntitySetPosition(mqEntityPosition.x, mqEntityPosition.y, mqDisplayZIndex, weapons[2]);
		if ( EntityPublicFunction(weapons[2], "Use", "nn", obj, mqDirection) == 1 )
		{
			mqState = USING;
			weapon_active = 2;
		}
	}
	else
	{
		weapon_active = -1;
	}
}


DisplayPlayer()
{
	if ( HasStateChanged() )
	{
		ObjectReplace(obj, STATE_GRAPHIC, SPRITE );
		ObjectEffect(obj, WHITE, _, _, _, STATE_FLIP, _, _);
	}
	ObjectPosition(obj, mqDisplayArea.x, mqDisplayArea.y, mqDisplayZIndex, 0, 0);
	if ( hit > 0 )
		hidden = !hidden;
	else
		hidden = 1;
	ObjectToggle(obj, hidden);
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

