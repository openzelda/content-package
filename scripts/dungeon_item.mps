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
 
#include <item> 
 
new Fixed:count = 0.0; 
new obj; 
 
new dungeon{32} = "dungeon-d"; 
new dungeonid = 0; 
new entity:dungeonEntity; 
 
public Init( ... ) 
{ 
	GetEntityPosition(qPosition.x, qPosition.y, qPosition.z, qDisplayArea.x, qDisplayArea.y); 
 
	obj = EntityGetObject(); 
 
	dungeonid = EntityGetNumber("dungeon-id"); 
	StringFormat(dungeon, _, "dungeon-%d", dungeonid); 
	dungeonEntity = entity:EntityHash(dungeon); 
 
 
	CollisionFromObject(obj, TYPE_ITEM); 
} 
 
main() 
{ 
	HandleLift(); 
} 
 
public Pickup( player ) 
{ 
	if ( qState != LIFTING ) 
	{ 
		EntityPublicFunction(dungeonEntity, "Finished"); 
		EntityGetPosition(qPosition.x, qPosition.y,  qPosition.z, player ); 
		qPosition.z++; 
	} 
	qState = LIFTING; 
	return true; 
} 
 
HandleLift() 
{ 
	if ( qState == LIFTING ) 
	{ 
		count += GameFrameSeconds();  
		if ( count < 4.00 ) 
		{ 
			qPosition.y -= GameFrameSeconds()*8.0; 
			UpdateDisplayPosition(); 
			ObjectPosition(object:obj, qDisplayArea.x, qDisplayArea.y, 4, 0, 0); 
		} 
		else 
		{ 
			EntityPublicFunction(dungeonEntity, "Exited"); 
 
			EntityDelete(); 
		} 
 
	} 
} 
