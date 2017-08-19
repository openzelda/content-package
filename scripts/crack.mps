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
#define XOFFSET 12
#define YOFFSET 8

#include <door>


/* */



/* Arch */
new object:archObject; 
 
public Init(...) 
{ 
	archObject = object:DoorInit();
} 
 
main() 
{ 
} 

public Close()
{
	ObjectDelete( archObject);
}
 


public OpenDoor() 
{ 
	isOpen = true; 
	MaskFill(collision.x , collision.y, collision.w, collision.h, MASK_ENEMYSOLID1); 
	CollisionSet(SELF, 0); 

	ObjectReplace(qObject, openSprite, SPRITE);  
	ObjectFlag(qObject, FLAG_ANIMLOOP, false); 
	ObjectFlag(qObject, FLAG_ANIMRESET, false); 

	return isOpen; 
} 
 
public CloseDoor() 
{ 
	isOpen = false; 
	MaskFill(collision.x , collision.y, collision.w, collision.h, MASK_SOLID); 
	CollisionSet(SELF, 0, qType, collision.x , collision.y, collision.w, collision.h); 

	ObjectReplace(qObject, closeSprite, SPRITE);
	ObjectFlag(qObject, FLAG_ANIMLOOP, false); 

	return isOpen; 
} 
 
 

PUBLIC_EVENT_HIT
{ 
	// Check if an explosion hit the wall 
	if ( attack&AEXPLOSION == AEXPLOSION ) 
		OpenDoor(); 
	else if ( attack&ASWORD == ASWORD ) 
		AudioPlaySound("swordclink.wav", x, y); 
} 
 
 
 
