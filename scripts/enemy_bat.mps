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
 *     2010/02/04 [luke]: new file.
 *     2012/01/30 [luke]: cleanned up
 ***********************************************/
#define DEATHLENGTH 480
#include <enemy>

/* Public Function */
forward PUBLICFUNCTIONAWAKING
forward PUBLICFUNCTIONHIT

/* Local variable */
new HitCount;
new timer;
new adj = 3;
new listen_rad = 50;

/* Display Object */
new body[EntityGraphic] = [ OBJECT_NONE, 0, 0, 0 ];	// Display Object, Offset x, Offset y, Offset z
new object:shadow = OBJECT_NONE;

/* Collisions Settings */

/* Function */

public Init(...)
{
	_speed_ = 50;
	_damage_ = 50;
	_health_ = _maxhealth_ = 50;

	dw = dh = 32;

	EnemyInit();

	/* Set up Objects */
	SetStateGraphic( STANDING, "bat01.png", "bat_1", "bat_1", "bat_1", "bat_1" );
	SetStateGraphic( MOVING, "bat01.png", "bat", "bat", "bat", "bat" );

	/* */
	body.obj= object:EntityGetNumber("object-id");
	shadow = ObjectCreate( "", CIRCLE, dx+8, dy+32, 2, 16, 8, 0x000000DD );
	ShowObjects( body.obj, shadow );
}


main()
{
	if ( _state_ == GONE || GameState() != 1 )
		return;

	if ( HasStateChanged() )
	{
		ResetObjects( body.obj );
	}

	if ( _state_ <= MOVING )
		CollisionSet(SELF, 0, TYPE_ENEMY, dx + adj, dy + adj, dw - (adj*2), dh - (adj*2) );
	else
		CollisionSet(SELF, 0 );

	switch( _state_ )
	{
		case STANDING:
			Stand();
		case MOVING:
			Move();
		case HIT:
			Hurt();
		case DYING:
			HandleDying();
		case SPECIALSTATE:
			Special();
		case DEAD:
		{
			HideObjects( body.obj, shadow );
			CollisionSet(SELF, -1, 0);
			SetState(GONE);
			return;
		}
	}
	UpdateEntityGraphics( body );
	ObjectPosition( shadow, dx+8, dy+32, 2, 16, 8);
}


public Close()
{
	CollisionSet(SELF, 0, 0);
	CollisionSet(SELF, 1, 0);
	ObjectDelete(shadow);
}

/* Local Functions */

/* State */ 
STATEFUNCTION Move()
{
	ReplaceEntityGraphics( body, STATE_GRAPHIC, STATE_FLIP );

	// randomly change direction
	if ( !random(30) )
		_angle_ = fixed(random(8) * 45);

	// Move the enemy
	EntityMove( MASK_ENEMYSOLID1 );

	timer += GameFrame();
	if ( timer >= 2000 )
		_state_ = STANDING;
}

STATEFUNCTION Stand()
{
	ReplaceEntityGraphics( body, STATE_GRAPHIC, STATE_FLIP );
	CollisionSet(SELF, 1, TYPE_AWAKING, dx - listen_rad, dy - listen_rad, dw + (listen_rad*2), dh + (listen_rad*2) );
}


STATEFUNCTION Hurt()
{
	EntityMove(MASK_ENEMYSOLID1);

	new q = (HitCount % 100) / 20;
	ColourEntityGraphics(body, hit_colours[q]);

	if ( Countdown(HitCount) )
	{
		SetState(MOVING);
		RandomizeMovement();
		CheckHealth();
	}
}

STATEFUNCTION Special()
{

	switch ( current_effect )
	{
		case STUNNED:
		{
			StunnedEffect( effect_count );
			ReplaceEntityGraphics( body, STATE_GRAPHIC, STATE_FLIP );
		}
		case FROZEN:
		{
			ReplaceEntityGraphics( body, STATE_GRAPHIC, STATE_FLIP );
			ColourEntityGraphics( body, 0x0000FFFF);
		}
		case SHOCKED:
		{
		}
		case BURNING:
		{
		}
		default:
		{
			SetState(STANDING);
			return;
		}
	}

	if ( Countdown(effect_count) ) //Reset State
	{
		SetState(STANDING);
	}

}
/* Public Functions */

PUBLICFUNCTIONAWAKING
{
	SetState(MOVING);
	timer = 0;
	AudioPlaySound("enemy_bat2.wav", dx, dy);
	CollisionSet(SELF, 1, 0);
}

PUBLICFUNCTIONHIT
{
	if ( !damage && attack&APLAYER != APLAYER )
		return;
	if ( _state_ == HIT || _state_ == DYING || _state_ == GONE )
		return;

	_attacker_ = attacker;
	new child;

	_angle_ = fixed(360 - angle);

	if ( attack&AFIRE == AFIRE )
	{
		_state_ = SPECIALSTATE;
		// Create a Burning fire entity on this enemy
		//EntityCreate( "effect_fire", "*", dx, dy, 5, CURRENT_MAP );
		//StunCount = 3200;
	}
	else if ( attack&AICE == AICE )
	{
		// Create a frozen effect around the enemy
		//EntityCreate( "effect_freeze", child, dx, dy, 5, CURRENT_MAP );
		EntityPublicFunction( child, "SetArea", ''nnnn'', dx, dy, dw, dh);
		//ObjectEffect( obj, 0x0000FFFF );
		//StunCount = 3200;
		_state_ = SPECIALSTATE;
	}
	else if ( attack&ASTUN == ASTUN )
	{
		_state_ = SPECIALSTATE;
		//StunCount = damage * 10;
	}
	else if ( attack&APLAYER == APLAYER )
	{
		CallEntityHit( attacker, 0, angle, 5, ASWORD,  _damage_, x, y, rect );
		//EntityPublicFunction( attacker, "Hurt", ''nnn'' ASWORD, _damage_, angle );
		return;
	}
	else
	{
		AudioPlaySound( "enemy_hurt.wav", dx, dy );
		_state_ = HIT;
		_health_ -= damage;
		HitCount = 1000;
		Hurt();
	}
	CheckHealth();
}



