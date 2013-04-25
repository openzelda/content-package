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

#if NETWORKED
	#include <network>
#endif


/* Public Function */
forward PUBLIC_EVENT_HIT;
forward public Wake();



new Fixed:a = 200.0;
new timer;
new shotTimer = SHOTLENGTH;
new walkTimer = DEATHLENGTH;
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
	mqHealth = 500;
	mqDisplayArea.w = mqDisplayArea.h = 128;
	mqIsABoss = true;

	EnemyInit();

	mqDisplayObject = EntityGetObject();
	mqState = MOVING;

	ObjectEffect( mqDisplayObject, 0x999999FF );
	

}

main()
{
	if ( mqState == GONE || GameState() != 1 )
		return;


#if NETWORKED
	if ( mqStatePrev != SPECIALSTATE )
		EndKnockedOut();
#endif

	DebugText("%d", mqHealth);
	CollisionFromObject( mqDisplayObject, TYPE_ENEMY );
	switch( mqState )
	{
		case SPECIALSTATE:
			KnockedOut();
		case USING:
			Shoot();
		case STANDING:
			Stand();
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
Shoot()
{
	

	if ( HasStateChanged() )
	{
		ObjectReplace(mqDisplayObject, "aquamentus.png:3", SPRITE);
		ObjectEffect(mqDisplayObject, 0x999999FF );
		a = 220.0;
	}
	
	
	if ( TimerCountdownWithReset(shotTimer, SHOTLENGTH) )
	{
		new Fixed:angle = a;
		EntityCreate("attack_flamethrower1", "", mqEntityPosition.x, mqEntityPosition.y + 32.0, mqEntityPosition.z, CURRENT_MAP, ''d'', angle );
		a += 20.0;
		if ( a > 340.0 ) 
			mqState = MOVING;
	}
}

Move()
{
	if ( HasStateChanged() )
	{
		ObjectReplace( mqDisplayObject, "aquamentus.png:0", SPRITE);
		ObjectEffect( mqDisplayObject, 0x999999FF );
	}
	#if !NETWORKED
	if ( TimerCountdownWithReset(walkTimer, DEATHLENGTH) )
	{
		mqState = USING;
	}
	#endif
}

Stand()
{
	if ( HasStateChanged() )
	{
		ObjectReplace(mqDisplayObject, "aquamentus.png:1", SPRITE);
	}
}

Hurting()
{
	CollisionSet(SELF, -1, 0);
	new q = (HitCount % 100) / 20;

	ObjectEffect(mqDisplayObject, mqHitColours[q]);

	#if NETWORKED
	HitCount += GameFrame();
	if ( HitCount > 400 )
		HitCount -= 400;

	#else
	if ( TimerCountdown(HitCount) )
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

	#if !NETWORKED
	if ( TimerCountdown(timer) )
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
	ObjectDelete(object:knockedout_obj);

	knockedout_obj = OBJECT_NONE;
	ObjectReplace( mqDisplayObject, "aquamentus.png:3", SPRITE);
	ObjectEffect( mqDisplayObject, 0x999999FF );
}

/* /states */

/* Events */
public Wake()
{
	#if NETWORKED
	new message[1];
	SetBits( message[0], 3, 0, 4 );
	NetworkMessage(1, 1, message, 1);
	EntityCreate("attack_flamethrower1", "*",10.0, 10.0, 4.000, CURRENT_MAP, _,  [ ARG_RETURN_NUMBER, ARG_NUMBER, ARG_END ], a, 200 );
	#else
	mqState = USING;
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
		
		//if ( mqState != USING )
		//{
			AudioPlaySound( "enemy_hurt.wav", mqDisplayArea.x, mqDisplayArea.y );
			mqState = HIT;
			#if NETWORKED
			new message[1];
			SetBits( message[0], 4, 0, 4 );
			NetworkMessage(1, 1, message, 1);
			#else
			mqHealth -= 50;
			HitCount = 1000;
			Hurting();
			#endif
		//}
	}
	else if ( attack&APLAYER == APLAYER )
	{
		CallEntityHurt( mqAttacker, ASWORD, mqDamageDealt, angle);
	}

	#if !NETWORKED
	CheckHealth();
	#endif
}
/* /Events */

#if NETWORKED

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

