/*********************************************** 
 * Copyright © Luke Salisbury 
 * 
 * You are free to share, to copy, distribute and transmit this work 
 * You are free to adapt this work 
 * Under the following conditions: 
 *  You must attribute the work in the manner specified by the author 
 *  or licensor (but not in any way that suggests that they endorse you
 *  or your use of the work).  
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
	qMovementSpeed = 30; 
	qDamageDealt = 200; 
	qHealth = 500; 
	qDisplayArea.w = qDisplayArea.h = 128; 
	qIsABoss = true; 
 
	EnemyInit(); 
 
	qObject = EntityGetObject(); 
	qState = MOVING; 
 
	ObjectEffect( qObject, 0x999999FF ); 
	 
 
} 
 
main() 
{ 
	if ( qState == GONE ||  GameState() != GS_ALL ) 
		return; 
 
 
#if NETWORKED 
	if ( qStatePrev != SPECIALSTATE ) 
		EndKnockedOut(); 
#endif 
 
	ConsoleOutput("%d", qHealth); 
	CollisionFromObject( qObject, TYPE_ENEMY ); 
	switch( qState ) 
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
	ObjectDelete(qObject); 
} 

UpdateObject()
{
}


/* States */ 
Shoot() 
{ 
	 
 
	if ( HasStateChanged() ) 
	{ 
		ObjectReplace(qObject, "aquamentus.png:3", SPRITE); 
		ObjectEffect(qObject, 0x999999FF ); 
		a = 220.0; 
	} 
	 
	 
	if ( TimerCountdownWithReset(shotTimer, SHOTLENGTH) ) 
	{ 
		new Fixed:angle = a; 
		EntityCreate("attack_flamethrower1", "", qPosition.x, qPosition.y + 32.0, qPosition.z, CURRENT_MAP, ''d'', _, angle ); 
		a += 20.0; 
		if ( a > 340.0 )  
			qState = MOVING; 
	} 
} 
 
Move() 
{ 
	if ( HasStateChanged() ) 
	{ 
		ObjectReplace( qObject, "aquamentus.png:0", SPRITE); 
		ObjectEffect( qObject, 0x999999FF ); 
	} 
	#if !NETWORKED 
	if ( TimerCountdownWithReset(walkTimer, DEATHLENGTH) ) 
	{ 
		qState = USING; 
	} 
	#endif 
} 
 
Stand() 
{ 
	if ( HasStateChanged() ) 
	{ 
		ObjectReplace(qObject, "aquamentus.png:1", SPRITE); 
	} 
} 
 
Hurting() 
{ 
	CollisionSet(SELF, -1, 0); 
	new q = (HitCount % 100) / 20; 
 
	ObjectEffect(qObject, qHitColours[q]); 
 
	#if NETWORKED 
	HitCount += GameFrame(); 
	if ( HitCount > 400 ) 
		HitCount -= 400; 
 
	#else 
	if ( TimerCountdown(HitCount) ) 
	{ 
		qState = USING; 
		HitCount = 0; 
	} 
	#endif 
} 
 
new knockedout_obj = -1; 
KnockedOut() 
{ 
	if ( HasStateChanged() ) 
	{ 
		ObjectReplace( qObject, "aquamentus.png:1", SPRITE ); 
		AudioPlaySound( "enemy_laser.wav", qDisplayArea.x, qDisplayArea.y ); 
	} 
 
	if ( knockedout_obj == -1 ) 
	{ 
		knockedout_obj = ObjectCreate("misc.png:knockedout", SPRITE, qDisplayArea.x+16, qDisplayArea.y+8, 5, 0, 0); 
	} 
 
	#if !NETWORKED 
	if ( TimerCountdown(timer) ) 
	{ 
		qState = STANDING; 
		EndKnockedOut(); 
	} 
	#endif 
} 
 
EndKnockedOut() 
{ 
	if ( knockedout_obj == -1 ) 
		return; 
 
	timer = 0; 
	AudioPlaySound( "effect_roar1.wav", qDisplayArea.x, qDisplayArea.y ); 
	ObjectDelete(object:knockedout_obj); 
 
	knockedout_obj = OBJECT_NONE; 
	ObjectReplace( qObject, "aquamentus.png:3", SPRITE); 
	ObjectEffect( qObject, 0x999999FF ); 
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
	qState = USING; 
	timer = 3000; 
	ObjectEffect( qObject, 0xFFFFFFFF ); 
	#endif 
} 
 
PUBLIC_EVENT_HIT 
{ 
	if ( qState == HIT || qState == DYING || qState == GONE ) 
		return; 
 
	qAttacker = attacker; 
 
	if ( attack&ASWORD == ASWORD ) 
	{ 
		 
		//if ( qState != USING ) 
		//{ 
			AudioPlaySound( "enemy_hurt.wav", qDisplayArea.x, qDisplayArea.y ); 
			qState = HIT; 
			#if NETWORKED 
			new message[1]; 
			SetBits( message[0], 4, 0, 4 ); 
			NetworkMessage(1, 1, message, 1); 
			#else 
			qHealth -= 50; 
			HitCount = 1000; 
			Hurting(); 
			#endif 
		//} 
	} 
	else if ( attack&APLAYER == APLAYER ) 
	{ 
		CallEntityHurt( qAttacker, ASWORD, qDamageDealt, angle); 
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
			qState = USING; 
		} 
		else if ( a == 3 ) 
		{ 
			qState = SPECIALSTATE; 
		} 
		else if ( a == 4 ) 
		{ 
			qState = HIT; 
		} 
		else if ( a == 5 ) 
		{ 
			Kill(); 
			ObjectEffect(object:qDeathObject, .scale_w = 2000,.scale_h = 2000); 
		} 
	} 
} 
 
#endif 
 
