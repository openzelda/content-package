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
 
public Init(...) 
{ 
	qDirection = EntityGetNumber("dir"); 
	qObject = EntityGetObject(); 
 
	GetEntityPosition(qPosition.x, qPosition.y, qPosition.z, qDisplayArea.x, qDisplayArea.y); 
 
} 
 
main() 
{ 
	ObjectEffect(qObject, WHITE); 
	if ( qDisplayArea.x < InputPointer(0,1) < (qDisplayArea.x+16) ) 
	{ 
		if ( qDisplayArea.y < InputPointer(1,1) < (qDisplayArea.y+32) ) 
		{ 
			ObjectEffect(qObject, 0xFF0000FF); 
			if ( InputButton(11,1) == 1) 
			{ 
				EntityPublicFunction(MAP_ENTITY, "MenuPush", ''n'', _, qDirection ); 
			} 
		} 
	} 
} 
