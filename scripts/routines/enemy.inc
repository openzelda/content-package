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
 ***********************************************/

#if !defined DEATHLENGTH
	#define DEATHLENGTH 1000
#endif

#include <quest_types>
#include <open_zelda>
#include <public_events>

public _maxhealth_;
public _health_;

new _damage_ = 50;
new Fixed:_initialx_ = -99.0;
new Fixed:_initialy_;
new bool:_boss_ = false;
stock bool:_resetable_ = false;
new _attacker_;
new _item_[64];
new _sprite_[64];
new death_count = 4200;
new object:death_obj = OBJECT_NONE;

new _STATEEFFECTS:current_effect = NOEFFECT;
new effect_count = 0;

new hit_colours[5] = [ 0x138813FF, 0xFDD341FF, 0xE15805FF, 0x20D3EEFF, 0xEE2020FF ];


static error_message[43];

/* States */
#define STATE_FLIP ((_dir_/2) == 3 ? true : false)
#define STATE_GRAPHIC StateGraphics[_state_][((_dir_ % 8)/2)]
stock StateGraphics[STATE_COUNT][4]{32};

stock SetStateGraphic( _STATE:s, parent[], south_graphic[], west_graphic[], north_graphic[], east_graphic[] )
{
	s =  _STATE:NumberClamp( _:s, _:ALIVE, _:DEAD );
	strformat( StateGraphics[s][0], _, true, "%s:%s", parent, south_graphic);
	strformat( StateGraphics[s][1], _, true, "%s:%s", parent, west_graphic);
	strformat( StateGraphics[s][2], _, true, "%s:%s", parent, north_graphic);
	strformat( StateGraphics[s][3], _, true, "%s:%s", parent, east_graphic);
}

/**
* Enemy Init
*
*/
EnemyInit()
{
	if ( _initialx_ == -99.0 )
	{
		GetEntityPosition( _x_, _y_, _z_, dx, dy, dz, dl);


		_type_ = TYPE_ENEMY;
		_initialx_ = _x_;
		_initialy_ = _y_;
		_state_ = STANDING
		EntityGetSetting("object-sprite", _sprite_);
		EntityGetSetting("item", _item_);
	}
	else
	{
		Reset();
	}
}

public Reset()
{
	_x_ = _initialx_;
	_y_ = _initialy_;
	_state_ = STANDING;
	_health_ = _maxhealth_;
	UpdateDisplayPosition();
}

stock HandleDying()
{
	if ( Countdown(death_count) )
	{
		_state_ = DEAD;
		ObjectDelete(death_obj);
		death_obj = OBJECT_NONE;
		DeathEvent();
	}
}

stock CheckHealth()
{
	if ( _health_ <= 0 )
		Kill();
}

stock RandomizeMovement()
{
	new new_dir;
	do {
		new_dir = random(8);
	}while ( _dir_ != new_dir )

	_dir_ = new_dir;
	_angle_ = Dir2Angle(_dir_);
}


stock Kill( )
{
	_health_ = 0;
	_state_ = DYING;
	AudioPlaySound( ( _boss_ ? "boss_killed.wav" : "enemy_killed.wav"), dx, dy);
	
	if (death_obj == OBJECT_NONE )
		death_obj = ObjectCreate("deathanim01.png:anim", SPRITE, dx, dy, dz+100, 0, 0,WHITE);
	death_count = AnimationGetLength("deathanim01.png","anim") ;
	ObjectFlag(death_obj, FLAG_ANIMLOOP, false);
}

stock DeathEvent()
{
	FunctionCall(FunctionID("EnemyClose"));
	if ( _attacker_ )
		EntityPublicFunction(_attacker_, "AddKill", ['n', '0'], _maxhealth_ );

	if ( _boss_ )
	{
		new entityId, function[24];
		entityId = EntityGetNumber("death-entity" );
		EntityGetSetting("death-function", function );
		if ( entityId && function[0] )
			EntityPublicFunction( entityId, function );
	}
	else
	{
		EntityPublicFunction(__MAP__, "EnemyKilled");
		//EntityPublicFunction("itemlib", "CreateItem", "nns", dx + (dw / 2), dy + (dy / 2), _item_);
	}
}

stock CheckForHoles( )
{
	if (_state_ == HIT || _state_ == FALLING || _state_ == DYING )
		return false;

	// Check if the enemy is over a hole
	if ( MaskGetValue(dx, dy) == MASK_HOLE1 )
	{
		_state_ = FALLING; // Set the enemies state to falling
		AudioPlaySound("dropping.wav", dx, dy);
		return true;
	}
	return false;
}

stock Fall( img, width, height )
{
	new HoleType = MaskGetValue(dx, dy); // Check what type of hole we are in
	new length = AnimationGetLength(img);

	if ( !length )
	{
		if ( HoleType == MASK_HOLE1 ) // Check for a normal hole
		{
			Kill(); // Kill The enemy
		}
		else  // The enemy falls to another floor
		{
			// Work out the new world coordinates for the enemy
			/*
			new gridx = -1;
			new gridy = -1;
			MapGetGrid(gridx, gridy);
			
			SetX("this", (GetLowerLevelX() * 320) + (x - (screenx * 320)));
			SetY("this", (GetLowerLevelY() * 240) + (y - (screeny * 240)));
			if (screenx == GetLowerLevelX() && screeny == GetLowerLevelY())
			{
				Kill(""); // Kill The enemy
			}
			*/

			_state_ = STANDING;
			ClearCollisionSet(SELF, 0, 0);
		} 
	}
}

stock StunnedEffect( count )
{
	static ShakeCount = 0;

	new ShakeOffset[5] = [ -2, -2, 0, 2, 2 ]; 

	if ( count <= 100)
	{
		_x_ += ShakeOffset[ ShakeCount ];
		ShakeCount++;
		if ( ShakeCount >= 5 )
			ShakeCount = 0;
	}

	if ( count <= 0)
		_state_ = STANDING;
}


stock StockHit( attacker[], angle, dist, attack, damage, x, y, rect )
{
	if ( damage == 0 && attack&APLAYER != APLAYER )
		return;

	if ( _state_ == HIT || _state_ == DYING || _state_ == GONE )
		return;

	_state_ = HIT;

	strcopy( _attacker_, attacker );
	new child[64] = "*";

	_angle_ = fixed(360 - angle);

	if ( attack&AFIRE == AFIRE )
	{
		_state_ = BURNING;
		// Create a Burning fire entity on this enemy
		EntityCreate( "effect_fire", "*", dx, dy, dz, CURRENT_MAP );
		StunCount = 3200;
	}
	else if ( attack&AICE == AICE )
	{
		// Create a frozen effect around the enemy
		EntityCreate( "effect_freeze", child, dx, dy, dz, CURRENT_MAP, _, "nnnn", dx, dy, dw, dh );
		ObjectEffect( obj, 0xFF0000FF );
		StunCount = 3200;
		_state_ = STUNNED;
	}
	else if ( attack&ASTUN == ASTUN )
	{
		_state_ = STUNNED;
		StunCount = damage * 10;
	}
	else if ( attack&APLAYER == APLAYER )
	{
		EntityPublicFunction( _attacker_, "Hurt", "n", _damage_ );
	}
	else
	{
		_health_ -= damage;
		HitCount = 1000;
		AudioPlaySound( "enemy_hurt.wav", dx, dy );
		BeenHit();
	}
	CheckHealth();
}
