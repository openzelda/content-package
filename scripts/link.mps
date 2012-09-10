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
#include <mokoi_quest>
#include <network>
#include <player>

/* Public Functions */
forward public UpdatePosition();
forward public Hurt(type, damage, angle);
forward public GiveWeapon( weapon[] );
forward public SetWeapon( weapon[], n );
forward public SetPlayerSprites();
forward public SetRestartPosition( point, ndescription[], nx, ny, nmapid );

/* Variable */
public _maxhealth_ = 300;
public _health_ = 300;

new selfid[64];
new hudid[32] = "hudent";
new menuid[32] = "menuent";
new controller = 0;

new Fixed:push_delay = 0.00;

/* Animation Code */ 
#define STATE_FLIP (_animdir_ == 3 ? 16 : 0)
#define STATE_GRAPHIC animation[_state_][_animdir_]
new object:obj = NULLOBJECT;
stock animation[_STATE][4][32 char] = {
	//SOUTH, WEST, NORTH, EAST, 
	/* ALIVE */		{"", "", "", ""},
	/* STANDING */		{"", "", "", ""},
	/* MOVING */		{"", "", "", ""},
	/* HIT */		{"", "", "", ""},
	/* KNOCKED */		{"", "", "", ""},
	/* JUMPING */		{"", "", "", ""},
	/* SWIMMING */		{"", "", "", ""},
	/* FLOATING */		{"", "", "", ""},
	/* CHASING */		{"", "", "", ""},
	/* USING */		{"", "", "", ""},
	/* LIFTING */		{"", "", "", ""},
	/* STANDLIFT */		{"", "", "", ""},
	/* WALKLIFT */		{"", "", "", ""},
	/* SPECIALSTATE */	{"", "", "", ""},
	/* FALLING */		{"", "", "", ""},
	/* WAITING */		{"", "", "", ""},
	/* LEAPING */		{"", "", "", ""},
	/* PUSHING */		{"", "", "", ""},
	/* PULLING */		{"", "", "", ""},
	/* DYING */		{"", "", "", ""},
	/* DEAD */		{"", "", "", ""},
	/* GONE */		{"", "", "", ""}
};

SetStateGraphic( _STATE:s, parent[], south_graphic[], west_graphic[], north_graphic[], east_graphic[] )
{
	s =  _STATE:NumberClamp( _:s, _:ALIVE, _:DEAD );
	strformat( animation[s][0], _, true, "%s:%s", parent, south_graphic);
	strformat( animation[s][1], _, true, "%s:%s", parent, west_graphic);
	strformat( animation[s][2], _, true, "%s:%s", parent, north_graphic);
	strformat( animation[s][3], _, true, "%s:%s", parent, east_graphic);
}

public SetPlayerSprites()
{
	SheetReference("p01push.png");
	SheetReference("p01pull.png");
	SheetReference("p01n.png");

	SetStateGraphic( STANDING, "p01n.png", "front_0", "side_0", "back_0", "side_0" );
	SetStateGraphic( MOVING, "p01n.png", "front", "side", "back", "side" );
	SetStateGraphic( KNOCKED, "p01n.png", "front_knock", "side_knock", "back_knock", "side_knock" );
	SetStateGraphic( PUSHING, "p01push.png", "front", "side", "back", "side" );
	SetStateGraphic( PULLING, "p01pull.png", "front", "side", "back", "side" );
	SetStateGraphic( DYING, "p01n.png", "death", "death", "death", "death" );
	SetStateGraphic( DEAD, "p01n.png", "death_1", "death_1", "death_1", "death_1" );

}

/* Restart Point Code */
enum RestartPoint {
	description[32],
	section[64],
	x,
	y,
	dir,
	mapid,
	active
}
new _restart[3][RestartPoint];

public SetRestartPosition( point, ndescription[], nx, ny, nmapid )
{
	point %= 3;
	strcopy(_restart[point][description], ndescription);

	if ( nx == -1 )
		_restart[point][x] = _:_x_;
	else
		_restart[point][x] = nx;

	if ( ny == -1 )
		_restart[point][y] = _:_y_;
	else
		_restart[point][y] = ny;

	
	if ( nmapid == -1 )
	{
	
		_restart[point][mapid] = MapCurrent();
	}
	else
		_restart[point][mapid] = nmapid;
	_restart[point][active] = 1;
}

/* Hurting and Death */
new hit = 0;
new hidden = 1;
new DeathCount = 0;
HandleDeath()
{
	ObjectPosition(obj, dx, dy, dz, 0, 0);
	if ( _state_ == DEAD ) 
	{
		DeathCount = 0;
		ObjectReplace(obj, animation[DEAD][0], SPRITE);
		EntityPublicFunction("main", "CustomText", "snnnnnn", !"Press Enter to continue", -1, -1, 6, 11, 2, 255 );
		if ( InputButton( 6 ) )
		{
			_health_ = _maxhealth_;
			_state_ = STANDING;
			LayerColour(0, 0xFFFFFFFF);
			LayerColour(1, 0xFFFFFFFF);
			LayerColour(2, 0xFFFFFFFF);
			LayerColour(3, 0xFFFFFFFF);
			LayerColour(4, 0xFFFFFFFF);
			LayerColour(5, 0xFFFFFFFF);
		
			TransitionPlayer( selfid, "", _restart[0][mapid], SELF);
			EntitySetPosition( _restart[0][x], _restart[0][y], _ );
		}
	}
	else if ( _state_ == DYING ) 
	{
		LayerColour(0, 0xFF0000FF);
		LayerColour(1, 0xFF0000FF);
		LayerColour(2, 0xFF0000FF);
		LayerColour(3, 0xFF0000FF);
		LayerColour(4, 0xFF0000FF);
		LayerColour(5, 0xFF0000FF);
		
		if ( DeathCount == 0 )
		{
			DeathCount = AnimationGetLength( "p01n.png", "death" );
			ObjectReplace(obj, animation[DYING][0], SPRITE);
		}
		if ( Countdown(DeathCount) )
			_state_ = DEAD;
	}
}

/* Weapon */
new action[3] = {0,0,0};
new weapons[4][64 char];
new weapon_active = -1;
public GiveWeapon( weapon[] )
{
	new weaponid[64];
	strcopy(weaponid, weapon);
	EntityCreate( weapon, weaponid, 0, 0, 1, GLOBAL_MAP );
	EntityPublicFunction( weaponid, "SetOwner", "s", selfid );
	EntityPublicFunction( menuid, "AddWeapon", "s", weaponid );
	SetWeapon(weaponid, 0);
}

public SetWeapon( weapon[], n )
{
	if ( n >= 0 && n < 4 ) 
		strcopy(weapons[n], weapon);
}


/* Main Code */

public Init(...)
{
	GetEntityPosition(_x_, _y_, _z_, dx, dy, dz, dl);

	//SetRestartPosition(0, dx, dy, MapCurrent(), "Start");

	_dir_ = 0;
	dw = 30;
	dh = 24;
	ox = 2;
	oy = 24;
	_allow_offscreen = true;

	SetPlayerSprites();
	SetState(STANDING);
	_type_ = TYPE_PLAYER;
	

	obj = ObjectCreate(animation[_state_][0], SPRITE, dx, dy, dz, 0, 0, WHITE);

	EntityGetSetting( "id", selfid, SELF );

	//EntityCreate( "hud", hudid, 0, 0, 6, GLOBAL_MAP, _, "s", selfid );
	EntityCreate( "menu", menuid, 0, 0, 6, GLOBAL_MAP, _, "s", selfid );
	GiveWeapon("weapon_sword");

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
		new current[64];
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
		EntityPublicFunction(hudid, "Refresh", "");
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
		EntityPublicFunction("__map__", "SetPlayerPosition", "nnn", _:_x_, _:_y_, _:_z_);
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
		action[0] = InputButton(0, controller);
		action[1] = InputButton(1, controller);
		action[2] = InputButton(2, controller);
	}

	if ( InputButton(6, controller) == 1 )
	{
		EntityPublicFunction(menuid, "Show", "ssss", selfid, weapons[0], weapons[1], weapons[2] );
		return;
	}

	if ( _state_ == USING )
	{
		if ( weapon_active != -1 )
		{
			EntitySetPosition(_x_, _y_, _z_, weapons[weapon_active]);
			if ( EntityPublicFunction(weapons[weapon_active], "Use", "nn", obj, _dir_) > 0 )
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

	if ( action[0] == 1 && weapons[0][0])
	{
		EntitySetPosition(_x_, _y_, _z_, weapons[0]);
		if ( EntityPublicFunction(weapons[0], "Use", "nn", obj, _dir_) == 1 )
		{
			_state_ = USING;
			weapon_active = 0;
		}
	}
	else if ( action[1] == 1  && weapons[1][0])
	{
		EntitySetPosition(_x_, _y_, _z_, weapons[1]);
		if ( EntityPublicFunction(weapons[1], "Use", "nn", obj, _dir_) == 1 )
		{
			_state_ = USING;
			weapon_active = 1;
		}
	}
	else if ( action[2] == 1  && weapons[2][0])
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

