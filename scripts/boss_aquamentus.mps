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

#define NETWORKED 0

#define DEATHLENGTH 1000
#define SHOTLENGTH 200

#include <enemy>

#if defined NETWORKED
	#include <network>
#endif


/* Public Function */
forward PUBLIC_EVENT_HIT;
forward public Wake();



new Fixed:a = 200.0;
new timer;
new shot_timer = SHOTLENGTH;
new walk_timer = DEATHLENGTH;
new HitCount;

/* Custom States
1 - STANDING
2 - USING
3 - SPECIALSTATE/SLEEP
4 - HIT
5 - DYING
*/




public Init(...)
{
	mqMovementSpeed = 30;
	mqDamageDealt = 200;
	mqHealth = 1000;
	mqDisplayArea.w = mqDisplayArea.h = 128;
	mqIsABoss = true;

	EnemyInit();

	mqDisplayObject = EntityGetObject();
	mqState = MOVING;

	ObjectEffect( mqDisplayObject, 0x999999FF );
	CollisionFromObject( mqDisplayObject, TYPE_ENEMY );
}

main()
{
	if ( mqState == GONE || GameState() != 1 )
		return;



#if defined NETWORKED
	if ( mqStatePrev != SPECIALSTATE )
		EndKnockedOut();
#endif
	switch( mqState )
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
	ObjectDelete(mqDisplayObject);
}

/* States */
STATEFUNCTION Shoot()
{
	if ( HasStateChanged() )
	{
		ObjectReplace(mqDisplayObject, "aquamentus.png:3", SPRITE);
		ObjectEffect(mqDisplayObject, 0x999999FF );
		a = 220.0;
	}

	if ( CountTimer(shot_timer, SHOTLENGTH) )
	{
		EntityCreate("attack_flamethrower1", "*", mqEntityPosition.x, mqEntityPosition.y + 32.0, mqEntityPosition.z, CURRENT_MAP, _, [ ARG_RETURN_NUMBER, ARG_END ], a );
		a += 10.0;
		if ( a > 340.0 ) 
			mqState = MOVING;
	}
}

STATEFUNCTION Move()
{
	if ( HasStateChanged() )
	{
		ObjectReplace( mqDisplayObject, "aquamentus.png:0", SPRITE);
		ObjectEffect( mqDisplayObject, 0x999999FF );
	}

	#if !defined NETWORKED
	if ( CountTimer(walk_timer, DEATHLENGTH) )
	{
		mqState = USING;
	}
	#endif
}

STATEFUNCTION Stand()
{
	if ( HasStateChanged() )
	{
		ObjectReplace(mqDisplayObject, "aquamentus.png:1", SPRITE);
	}
}

STATEFUNCTION Hurting()
{
	CollisionSet(SELF, -1, 0);
	new q = (HitCount % 100) / 20;

	ObjectEffect(mqDisplayObject, mqHitColours[q]);

	#if defined NETWORKED
	HitCount += GameFrame();
	if ( HitCount > 400 )
		HitCount -= 400;

	#else
	if ( Countdown(HitCount) )
	{
		mqState = USING;
		HitCount = 0;
	}
	#endif
}

new knockedout_obj = -1;
KnockedOut()
{
	if ( HasStateChanged() )
	{
		ObjectReplace( mqDisplayObject, "aquamentus.png:1", SPRITE );
		AudioPlaySound( "enemy_laser.wav", mqDisplayArea.x, mqDisplayArea.y );
	}

	if ( knockedout_obj == -1 )
	{
		knockedout_obj = ObjectCreate("misc.png:knockedout", SPRITE, mqDisplayArea.x+16, mqDisplayArea.y+8, 5, 0, 0);
	}

	#if !defined NETWORKED
	if ( Countdown(timer) )
	{
		mqState = STANDING;
		EndKnockedOut();
	}
	#endif
}

EndKnockedOut()
{
	if ( knockedout_obj == -1 )
		return;

	timer = 0;
	AudioPlaySound( "effect_roar1.wav", mqDisplayArea.x, mqDisplayArea.y );
	ObjectDelete(knockedout_obj);

	knockedout_obj = OBJECT_NONE;
	ObjectReplace( mqDisplayObject, "aquamentus.png:3", SPRITE);
	ObjectEffect( mqDisplayObject, 0x999999FF );
}

/* /states */

/* Events */
public Wake()
{
	#if defined NOTNETWORKED
	new message[1];
	SetBits( message[0], 3, 0, 4 );
	NetworkMessage(1, 1, message, 1);
	EntityCreate("attack_flamethrower1", "*",10.0, 10.0, 4, CURRENT_MAP, _,  [ ARG_RETURN_NUMBER, ARG_NUMBER, ARG_END ], a, 200 );

	#else
	mqState = SPECIALSTATE;
	timer = 3000;
	ObjectEffect( mqDisplayObject, 0xFFFFFFFF );
	#endif
}

PUBLIC_EVENT_HIT
{
	if ( mqState == HIT || mqState == DYING || mqState == GONE )
		return;

	mqAttacker = attacker;

	if ( attack&ASWORD == ASWORD )
	{
		AudioPlaySound( "enemy_hurt.wav", mqDisplayArea.x, mqDisplayArea.y );
		if ( mqState != USING )
		{
			mqState = HIT;
			#if defined NETWORKED
			new message[1];
			SetBits( message[0], 4, 0, 4 );
			NetworkMessage(1, 1, message, 1);
			
			#else
			mqHealth -= 50;
			HitCount = 1000;
			Hurting();
			#endif
		}
	}
	else if ( attack&APLAYER == APLAYER )
	{
		EntityPublicFunction( mqAttacker, "Hurt", "n", mqDamageDealt );
	}

	#if !defined NETWORKED
	CheckHealth();
	#endif
}
/* /Events */

#if defined NETWORKED

forward public NetMessage( player, array[], size );

public NetMessage( player, array[], size )
{
	if ( size > 0 )
	{
		new a = GetBits( array[0], 0, 4 );
		if ( a == 2 )
		{
			mqState = USING;
		}
		else if ( a == 3 )
		{
			mqState = SPECIALSTATE;
		}
		else if ( a == 4 )
		{
			mqState = HIT;
		}
		else if ( a == 5 )
		{
			Kill();
			ObjectEffect(object:mqDeathObject, .scale_w = 2000,.scale_h = 2000);
		}
	}
}

#endif

