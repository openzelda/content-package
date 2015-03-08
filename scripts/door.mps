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
#define XOFFSET 12
#define YOFFSET 8

#include <door>

new lockedSprite{64}; 
 
new takesKey = 0; 
new touchOpen = 1; 
 
/* Arch */
new object:archObject; 
 
public Init(...) 
{ 
	archObject = object:DoorInit();

	touchOpen = !EntityGetNumber("touchopen"); 
	takesKey = EntityGetNumber("usekey"); 

	StringFormat(lockedSprite, _, "%s-%s", openSprite, "locked" ); 

} 
 
public Close() 
{ 
	ObjectDelete(archObject); 
} 
 
 
main() 
{
	ConsoleOutput("door target: %s %d %d", targetWorld,targetGrid,targetEntity);

	/* Temporary code until engine handle screens better */ 
	FillMask();
} 
 
 
 
public OpenDoor() 
{ 
	isOpen = true;  
 
	CollisionSet(SELF, 0, 0); 
	CollisionSet(SELF, 1, TYPE_TRANSPORT,  transport.x, transport.y, transport.w, transport.h); 
	 
	ObjectReplace(qObject, openSprite, SPRITE);  
	ObjectFlag(qObject, FLAG_ANIMLOOP, false); 
	ObjectFlag(qObject, FLAG_ANIMRESET, false); 
 
	return isOpen; 
} 
 
public CloseDoor() 
{ 
	isOpen = false; 

	CollisionSet(SELF, 0, qType, collision.x - 2, collision.y - 2, collision.w + 4, collision.h + 4); 
	CollisionSet(SELF, 1, 0); 
 
	ObjectReplace(qObject, closeSprite, SPRITE);  
	ObjectFlag(qObject, FLAG_ANIMLOOP, false); 
	ObjectFlag(qObject, FLAG_ANIMREVERSE, true); 
	ObjectFlag(qObject, FLAG_ANIMRESET, true); 
 
	return isOpen; 
} 
 
// Hit( attacker[], angle, dist, attack, damage, x, y ) 
PUBLIC_EVENT_HIT 
{ 
	if ( attack&APLAYER == APLAYER ) 
	{ 
		if ( !isOpen ) 
		{ 
			if ( takesKey ) 
			{ 
				if ( true )  //TODO  Take Key from player 
				{ 
					OpenDoor(); 
				} 
				takesKey = 0;
			} 
			else if ( touchOpen )
			{ 
				OpenDoor(); 
			} 
		} 
	} 
} 
 
 
