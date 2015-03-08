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
 
 
new object:obj; 
 
 
public Init(...) 
{ 
	SetupEntity( ALIVE, 0, obj, 112, 32 ); 
} 
 
main() 
{ 
	ObjectEffect(obj, WHITE); 
	if ( qDisplayArea.x < InputPointer(0) < (qDisplayArea.x+qDisplayArea.w) ) 
	{ 
		if ( qDisplayArea.y < InputPointer(1) < (qDisplayArea.y+qDisplayArea.h) ) 
		{ 
			ObjectEffect(obj, 0xFF0000FF); 
			if ( InputButton(11) == 1 ) 
			{ 
				EntityPublicFunction(MAP_ENTITY, "submitted"); 
			} 
		} 
	} 
} 
