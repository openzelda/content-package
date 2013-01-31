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

	obj = ObjectCreate(animation[_state_][0], SPRITE, dx, dy, dz, 0, 0, WHITE);

	self_hash_id = EntityGetSettingHash( "id" );

	//EntityCreate( "hud", HUD_ENTITY_ID, 0, 0, 6, GLOBAL_MAP, _, "s", self_hash_id );
	menu_hash_id = EntityCreate( "menu", MENU_ENTITY_ID, 0, 0, 6, GLOBAL_MAP, _, "n", self_hash_id );
	GiveWeapon("weapon_sword");

	//SetRestartPosition(0, dx, dy, MapCurrent(), "Start");

}

/* UpdatePosition is called when a global entity has changed maps */
public UpdatePosition()
{
	GetEntityPosition(_x_, _y_, _z_, dx, dy, dz, dl);
	MapSetOffset(_x_,_y_);
	DisplayPlayer();
}

/* Called each frame */
main()
{
	new sx, sy;
	ObjectInfo(obj, sx, sy);
	if ( _state_ == GONE || GameState() != 1 )
		return;

	if ( _health_ <= 0 && _state_ < DYING )
	{
		hit = 1000;
		_state_ = DYING;
	}

	if ( _state_ >= DYING )
	{
		HandleDeath();
		return;
	}

	GetEntityPosition(_x_, _y_, _z_, dx, dy, dz, dl);

	CheckForKeys();
	MovePlayer();
	CheckEnvironment();
	DisplayPlayer();

	CheckCollisions();
	if ( Countdown(hit) )
	{
		_state_ = (_state_ == KNOCKED) ? STANDING : _state_;
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
				EntityPublicFunction(current, "Hit", "snnnnnn", selfid, D2A(_dir_), dist, APLAYER, 0, dx,dy, rect);
			}
			else if ( type == TYPE_TRANSPORT )
			{
				//MovePlayer(player, dir)
				if ( EntityPublicFunction(current, "MovePlayer", "sn", selfid, _dir_) == 1 )
				{
					 _state_ = STANDING;
				}
			}
			else if ( type == TYPE_PUSHABLE && _state_ == PUSHING )
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
					_state_ = LIFTING;
				}
			}
		}
	}
}

public Hurt(type, damage, angle)
{
	if (_state_ >= KNOCKED)
		return;
	if ( Countdown(hit) )
	{
		if ( _state_ == USING )
			EntityPublicFunction(weapons[0], "End", "nn", obj, _dir_);
		SetState(KNOCKED);
		_health_ -= damage;
		_angle_ = angle%360;
		EntityPublicFunction(hud_hash_id, "Refresh", "");
		hit = 1000;
	}
}

MovePlayer()
{
	_flipx_ = false;
	if ( _state_ == USING || _state_ == LIFTING )
		return;
	else if ( _state_ == STANDING )
		_speed_ = 0;
	else if ( _state_ == PUSHING )
		_speed_ = 20.00;
	else if ( _state_ == KNOCKED )
	{
		_flipx_ = true;
		_speed_ = -40.00;
	}
	else
		_speed_ = 80.00;
	if ( EntityMove(MASK_PLAYERSOLID2) )
		EntityPublicFunction(__MAP__, "SetPlayerPosition", "nnn", _:_x_, _:_y_, _:_z_);
	MapSetOffset(_x_,_y_);
	CollisionSet(SELF,0,TYPE_PLAYER,dx+ox,dy+oy,dw,dh);
}

CheckEnvironment()
{
	new maskv = MaskGetValue( dx+8, dy+8 );
	if ( maskv == MASK_PUDDLE )
	{
	}
	else if ( maskv == MASK_WATER )
	{
	}

}

PushCheck( qdir )
{
	if ( qdir != _dir_ )
		push_delay = 0.00;
	else if ( _state_ == PUSHING )
		return true;

	if ( locations[2][0] == dx && locations[2][1] == dy && locations[2][3] == qdir )
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

	if ( _state_ == USING )
	{
		if ( weapon_active != -1 )
		{
			EntitySetPosition(_x_, _y_, _z_, weapons[weapon_active]);
			if ( EntityPublicFunction( weapons[weapon_active], "Use", "nn", obj, _dir_) > 0 )
				return;
			else
				SetState(STANDING);
		}
		else
			SetState(STANDING);
	}
	else if ( _state_ == KNOCKED )
	{
		return;
	}
	else if ( _state_ != LIFTING && GameState() == 1 )
	{
		x_movement = InputAxis(0,controller);
		y_movement = InputAxis(1,controller);
	}
	
	_angle_ = 0.0;
	
	if ( x_movement || y_movement )
	{
		_angle_ = MovementAngle( Fixed:x_movement, Fixed:y_movement);
		
		new a = Angle2Dir(_angle_, 0);
		
		_state_ = PushCheck( a ) ? PUSHING : MOVING;
		_dir_ = a
		_animdir_ = NumberClamp((_dir_/2), 0, 3);
		update = true;
	}
	else
	{
		push_delay = 0.00;
		_state_ = (_state_ == LIFTING ? LIFTING : STANDING );
	}
	
	UpdateState();

	if ( weapon_action[0] == 1 && weapons[0])
	{
		EntitySetPosition(_x_, _y_, _z_, weapons[0]);
		if ( EntityPublicFunction(weapons[0], "Use", "nn", obj, _dir_) == 1 )
		{
			_state_ = USING;
			weapon_active = 0;
		}
	}
	else if ( weapon_action[1] == 1  && weapons[1])
	{
		EntitySetPosition(_x_, _y_, _z_, weapons[1]);
		if ( EntityPublicFunction(weapons[1], "Use", "nn", obj, _dir_) == 1 )
		{
			_state_ = USING;
			weapon_active = 1;
		}
	}
	else if ( weapon_action[2] == 1  && weapons[2])
	{
		EntitySetPosition(_x_, _y_, _z_, weapons[2]);
		if ( EntityPublicFunction(weapons[2], "Use", "nn", obj, _dir_) == 1 )
		{
			_state_ = USING;
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
	ObjectPosition(obj, dx, dy, dz, 0, 0);
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
	message[0] = ( animdir << 24 | _state_ << 16 | fround(_angle_) );
	NetworkMessage(false, 2, message, 1 );
	*/
}

