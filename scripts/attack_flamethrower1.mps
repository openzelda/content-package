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
#include <movement> 
#include <public_events> 
 
 
forward PUBLIC_EVENT_HIT; 
new qAttacker; 
new Fixed:active_timer = 0.0; 
 
public Init( ... ) 
{ 
	qMovementSpeed = 60; 
 
	GetEntityPosition(qPosition.x, qPosition.y, qPosition.z, qDisplayArea.x, qDisplayArea.y); 
 
	qObject = ObjectCreate("aquamentus.png:flame", SPRITE, qDisplayArea.x, qDisplayArea.y, qPosition.z, 0, 0); 
	ObjectEffect(qObject, _, _, 2000,2000); 
	AudioPlaySound( "effect_fire1.wav", qDisplayArea.x, qDisplayArea.y ); 
 
	if ( numargs() ) 
		qMovementAngle = Fixed:getarg(0); 
} 
 
public Close() 
{ 
	ObjectDelete( qObject ); 
} 
 
main() 
{ 
	active_timer += GameFrameSeconds(); 
	if ( active_timer > 7000 ) 
	{ 
		EntityDelete(); 
		return; 
	} 
 
	new Fixed:speed = qMovementSpeed * GameFrameSeconds(); // Movement for the frame 
	new Fixed:movex = fsin(qMovementAngle, degrees) * speed; 
	new Fixed:movey = fcos(qMovementAngle, degrees) * speed; 
 
	qPosition.x += movex; 
	qPosition.y += movey; 
 
	qDisplayArea.x = fround(qPosition.x, round_unbiased)+16; 
	qDisplayArea.y = fround(qPosition.y, round_unbiased)+16; 
 
	if ( MaskGetValue(qDisplayArea.x, qDisplayArea.y) > 200 ) 
	{ 
		EntityDelete(); 
		return; 
	} 
 
	EntitySetPosition(qPosition.x, qPosition.y, qPosition.z); 
	ObjectPosition(qObject, qDisplayArea.x-16, qDisplayArea.y-16, qPosition.z, 0, 0); 
	CollisionSet(SELF, 0, TYPE_ENEMY, qDisplayArea.x-16, qDisplayArea.y-16, 22, 22); 
} 
 
PUBLIC_EVENT_HIT 
{ 
	qAttacker = attacker; 
	if ( attack&APLAYER == APLAYER ) 
	{ 
		CallEntityHurt( qAttacker, AFIRE, 50, qMovementAngle); 
		//EntityDelete(); 
		active_timer = 9999; 
	} 
	else if ( attack&ASHIELD == ASHIELD ) 
	{ 
		//EntityDelete(); 
		active_timer = 9999; 
	} 
 
} 
 
