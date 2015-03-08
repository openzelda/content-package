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
 
/* 
Disabled Networking Code 
forward public NetMessage( player, array[], size ); 
native EntityNetworkSync(); 
native NetworkMessage(reliable, server, message[], length, reallength = sizeof(message)); 
 
*/ 
 
forward public UpdatePosition(); 
forward public Push(attacker, rect, angle); 
 
new playingAudio = 0; 
 
/* 
public NetMessage(player, array[], size) 
{ 
	if ( size ) 
	{ 
		MaskFill(qDisplayArea.x, qDisplayArea.y, qDisplayArea.w, qDisplayArea.h, 0); 
		qDisplayArea.x = GetBits( array[0], qDisplayArea.x, 0, 16 ); 
		qDisplayArea.y = GetBits( array[0], qDisplayArea.y, 16, 16 ); 
		ObjectPosition(obj, qDisplayArea.x, qDisplayArea.y, qPosition.z, 0, 0); 
		MaskFill(qDisplayArea.x, qDisplayArea.y, qDisplayArea.w, qDisplayArea.h, 255); 
		CollisionSet(SELF, 0, TYPE_PUSHABLE, qDisplayArea.x-1, qDisplayArea.y-1, qDisplayArea.w+2, qDisplayArea.h+2); 
		EntitySetPosition(qPosition.x,qPosition.y, qPosition.z); 
		UpdateDisplayPosition(); 
	} 
} 
*/ 
 
public Init(...) 
{ 
	qMovementSpeed = 40.0; 
 
	SetupEntity( ALIVE, TYPE_PUSHABLE, qObject, 32, 32, 0, 0 ); 
	ObjectInfo( qObject, qDisplayArea.w, qDisplayArea.h ); 
 
	StorePosition(); 
 
	Update(); 
} 
 
public UpdatePosition() 
{ 
	MaskFill( qDisplayArea.x, qDisplayArea.y, qDisplayArea.w, qDisplayArea.h, MASK_CLEAR ); 
	EntityGetPosition( qPosition.x, qPosition.y, qPosition.z); 
 
	UpdateDisplayPosition(); 
	StorePosition(); 
 
	ObjectPosition(qObject, qDisplayArea.x, qDisplayArea.y, qPosition.z, 0, 0); 
	MaskFill(qDisplayArea.x, qDisplayArea.y, qDisplayArea.w, qDisplayArea.h, MASK_BLOCK ); 
	CollisionSet(SELF, 0, TYPE_PUSHABLE, qDisplayArea.x-1, qDisplayArea.y-1, qDisplayArea.w+2, qDisplayArea.h+2); 
} 
 
public Close() 
{ 
	MaskFill(qDisplayArea.x, qDisplayArea.y, qDisplayArea.w, qDisplayArea.h, MASK_CLEAR); 
	CollisionSet(SELF, 0, 0); 
} 
 
public Push(attacker, rect, angle) 
{ 
	if ( qState != MOVING ) 
	{ 
		angle = (angle/45)*45; 
		if ( !(angle % 90) ) // Angle Must be multiple of 90 
		{ 
		//Reset Audio playback 
		//playingAudio = false; 
			qMovementAngle = fixed(angle); 
			SoundPlayOnce(playingAudio, "object_push.wav"); 
			qState = MOVING; 
			qMovementAngle %= 360.0; 
			qMovementAngle = 360.0 - qMovementAngle; 
		} 
	} 
} 
 
/* 
NetworkUpdate() 
{ 
	new message[1]; 
	SetBits( message[0], qDisplayArea.x, 0, 16 ); 
	SetBits( message[0], qDisplayArea.y, 16, 16 ); 
	NetworkMessage(1, 0, message, 1); 
	EntityNetworkSync(); 
} 
*/ 
 
Update() 
{ 
	CollisionSet(SELF, 0, TYPE_PUSHABLE, qDisplayArea.x-1, qDisplayArea.y-1, qDisplayArea.w+2, qDisplayArea.h+2); 
} 
 
main() 
{ 
	if ( qState == MOVING ) 
	{ 
		qState = STANDING; 
		MaskFill(qDisplayArea.x, qDisplayArea.y, qDisplayArea.w, qDisplayArea.h, MASK_CLEAR); 
		if ( EntityMove( MASK_NORMALGROUND ) ) 
		{ 
			ObjectPosition(qObject, qDisplayArea.x, qDisplayArea.y, qPosition.z, 0, 0); 
			Update(); 
		} 
		MaskFill(qDisplayArea.x, qDisplayArea.y, qDisplayArea.w, qDisplayArea.h, MASK_BLOCK); 
	} 
	else 
	{ 
 
	} 
 
} 
