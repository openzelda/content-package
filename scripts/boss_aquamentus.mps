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

#define NOTNETWORKED 1

#define DEATHLENGTH 1000
#define SHOTLENGTH 200
native EntityHash(name[]);

#include <enemy>
#include <network>


/* Public Function */
forward PUBLICFUNCTIONHIT;




forward public Wake();

new Fixed:a = 200.0;
new timer;
new shot_timer = SHOTLENGTH;
new walk_timer = DEATHLENGTH;
new HitCount;
new object:obj = NULLOBJECT;

/* Custom States
1 - STANDING
2 - USING
3 - SPECIALSTATE/SLEEP
4 - HIT
5 - DYING
*/




public Init(...)
{
	_speed_ = 30;
	_damage_ = 200;
	_health_ = 1000;
	dw = dh = 128;
	_boss_ = true;
	EnemyInit();

	obj = EntityGetNumber("object-id");
	_state_ = MOVING

	ObjectEffect(object:obj, 0x999999FF );
	CollisionFromObject(obj, TYPE_ENEMY);
}

main()
{
	if ( _state_ == GONE || GameState() != 1 )
		return;

#if defined NOTNETWORKED
#else
	if ( last_state != SPECIALSTATE)
		EndKnockedOut();
#endif
	switch( _state_ )
	{
		case SPECIALSTATE:
			KnockedOut();
		case USING:
			Shoot();
		case HIT:
			Hurting();
		case DYING:
			HandleDying();
		case DEAD:
			EntityDelete();
		default:
			Move();
	}
}

public Close()
{
	CollisionSet(SELF, -1, 0);
	ObjectDelete(object:obj);
}

/* States */
STATEFUNCTION Shoot()
{
	if ( HasStateChanged() )
	{
		ObjectReplace(object:obj, "aquamentus.png:3", SPRITE);
		ObjectEffect(object:obj, 0x999999FF );
		a = 220.0;
	}

	if ( CountTimer(shot_timer, SHOTLENGTH) )
	{
		EntityCreate("attack_flamethrower1", "*", _x_, _y_+32.0, 4, CURRENT_MAP, _, "d", a );
		a += 10.0;
		if ( a > 340.0 ) 
			_state_ = MOVING;
	}
}

STATEFUNCTION Move()
{
	if ( HasStateChanged() )
	{
		ObjectReplace(obj, "aquamentus.png:0", SPRITE);
		ObjectEffect(obj, 0x999999FF );
	}

	#if defined NOTNETWORKED
		if ( CountTimer(walk_timer, DEATHLENGTH) )
		{
			_state_ = USING;
		}
	#endif
}

STATEFUNCTION Stand()
{
	if ( HasStateChanged() )
	{
		ObjectReplace(obj, "aquamentus.png:1", SPRITE);
	}
}

STATEFUNCTION Hurting()
{
	CollisionSet(SELF, -1, 0);
	new q = (HitCount % 100) / 20;

	ObjectEffect(obj, hit_colours[q]);
	#if defined NOTNETWORKED
		if ( Countdown(HitCount) )
		{
			_state_ = USING;
			HitCount = 0;
		}
	#else
		HitCount += GameFrame();
		if ( HitCount > 400 )
			HitCount -= 400;
	#endif
}

new knockedout_obj = -1;
KnockedOut()
{
	if ( HasStateChanged() )
	{
		ObjectReplace(obj, "aquamentus.png:1", SPRITE);
		AudioPlaySound( "enemy_laser.wav", dx, dy );
	}

	if ( knockedout_obj == -1 )
	{
		knockedout_obj = ObjectCreate("misc.png:knockedout", SPRITE, dx+16, dy+8, 5, 0, 0);
	}
	#if defined NOTNETWORKED
		if ( Countdown(timer) )
		{
			_state_ = STANDING;
			EndKnockedOut();
		}
	#endif
}

EndKnockedOut()
{
	if ( knockedout_obj == -1 )
		return;
	timer = 0;
	AudioPlaySound( "effect_roar1.wav", dx, dy );
	ObjectDelete(knockedout_obj);
	knockedout_obj = NULLOBJECT;
	ObjectReplace(obj, "aquamentus.png:3", SPRITE);
	ObjectEffect(obj, 0x999999FF );
}

/* /states */

/* Events */
public Wake()
{
	#if defined NOTNETWORKED
		_state_ = SPECIALSTATE;
		timer = 3000;
		ObjectEffect(obj, 0xFFFFFFFF );
	#else
		new message[1];
		SetBits( message[0], 3, 0, 4 );
		NetworkMessage(1, 1, message, 1);
		EntityCreate("attack_flamethrower1", "*",10.0, 10.0, 4, CURRENT_MAP, _, "dd", a, 200 );
	#endif
}

PUBLICFUNCTIONHIT
{
	if ( _state_ == HIT || _state_ == DYING || _state_ == GONE )
		return;

	strcopy( _attacker_, attacker );

	if ( attack&ASWORD == ASWORD )
	{
		AudioPlaySound( "enemy_hurt.wav", dx, dy );
		if ( _state_ != USING )
		{
			_state_ = HIT;
			#if defined NOTNETWORKED
			_health_ -= 50;
			HitCount = 1000;
			Hurting();
			#else
			new message[1];
			SetBits( message[0], 4, 0, 4 );
			NetworkMessage(1, 1, message, 1);
			#endif
		}
	}
	else if ( attack&APLAYER == APLAYER )
	{
		EntityPublicFunction( _attacker_, "Hurt", "n", _damage_ );
	}
	#if defined NOTNETWORKED
	CheckHealth();
	#endif
}
/* /Events */

/*
	if ( _initialx_ < _x_ + 200.0 )
	{
		_x_ -= (_speed_ * GameFrame2());
		dx = fround(_x_, round_unbiased);
	}
	else
	{
		_state_ = STANDING;
	}

	ObjectPosition( obj, dx, dy, 4, 0, 0);

//	if ( CountTimer(walk_timer, DEATHLENGTH) )
//	{
//		_state_ = WAITING;
//	}
*/
#if defined NOTNETWORKED

#else

forward public NetMessage( player, array[], size );

public NetMessage( player, array[], size )
{
	if ( size > 0 )
	{
		new a = GetBits( array[0], 0, 4 );
		if ( a == 2 )
		{
			_state_ = USING;
		}
		else if ( a == 3 )
		{
			_state_ = SPECIALSTATE;
		}
		else if ( a == 4 )
		{
			_state_ = HIT;
		}
		else if ( a == 5 )
		{
			Kill();
			ObjectEffect(object:death_obj, .scale_w = 2000,.scale_h = 2000);
		}
	}
}

#endif

