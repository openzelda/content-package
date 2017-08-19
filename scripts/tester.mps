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
 *     2012/01/11 [luke]: new file. 
 ***********************************************/ 
#include <public_events> 
 
//#define MOUSE_PRESS(%1,  ( evKill.x < x < evKill.x + evKill.w ) && ( evKill.y < y < evKill.y + evKill.h ) && InputButton(11,0) 
 
new entities[128]; 
new entities_name[128]{64}; 
new entities_count = 0; 
new entitiylist[RECT] = [0, 0, 96, 20]; 
 
 
new evError[64]; 
new evHit[RECT] = [200, 20, 20, 8]; 
new evKill[RECT] = [230, 20, 20, 8]; 
new evActivate[RECT] = [260, 20, 20, 8]; 
new evInfo[RECT] = [290, 20, 20, 8]; 
new evNext[RECT] = [300, 8, 20, 8]; 
new evPrev[RECT] = [200, 8, 20, 8]; 
new evTitle[RECT] = [220, 8, 60, 8]; 
new evEntity = 0; 
 
native DebugWatch(); 
public Init( ... ) 
{ 
	//DebugWatch(); 
} 
main() 
{ 
	TextSprites( 0, "" ); 
	GenerateEntityList(); 
	new x = InputPointer(0,0); 
	new y = InputPointer(1,0); 
 
	if ( ( entitiylist.x < x < entitiylist.x + entitiylist.w ) && ( entitiylist.y < y < entitiylist.y + entitiylist.h ) ) 
		DisplayEntityList(entitiylist, true ); 
	else 
		DisplayEntityList(entitiylist, false  ); 
 
	//Next Button 
	GraphicsDraw("", RECTANGLE, evNext.x, evNext.y, 6, evNext.w, evNext.h, 0xFFFFDDAA); 
	if ( ( evNext.x < x < evNext.x + evNext.w ) && ( evNext.y < y < evNext.y + evNext.h ) && InputButton(11,0)== 1  ) 
		evEntity = (evEntity >= 127 ? 0 : evEntity + 1); 
 
	// Title 
	new str[64]; 
	StringFormat(str,_,"%d: #%d", evEntity, entities[evEntity]); 
	GraphicsDraw(str, TEXT, evTitle.x, evTitle.y, 6, evTitle.w, evTitle.h, 0x000000AA); 
	GraphicsDraw(evError, TEXT, evHit.x, evHit.y+10, 6, evTitle.w, evTitle.h, 0xFF0000AA); 
 
 
	//Prev Button 
	GraphicsDraw("", RECTANGLE, evPrev.x, evPrev.y, 6, evPrev.w, evPrev.h, 0xFFDDDDAA); 
	if ( ( evPrev.x < x < evPrev.x + evPrev.w ) && ( evPrev.y < y < evPrev.y + evPrev.h ) && InputButton(11,0)== 1  ) 
		evEntity = (evEntity < 1 ? 127 : evEntity - 1); 
 
	//Hit Button 
	GraphicsDraw("", RECTANGLE, evHit.x, evHit.y, 6, evHit.w, evHit.h, 0xDDFFDDAA); 
	GraphicsDraw("Hit", TEXT, evHit.x, evHit.y, 6, evHit.w, evHit.h, 0x000000FF); 
	if ( ( evHit.x < x < evHit.x + evHit.w ) && ( evHit.y < y < evHit.y + evHit.h ) && InputButton(11,0) == 1 ) 
	{ 
		 //CallEntityHit( entities[evEntity], "tester", angle, dist, attack, damage, x, y, rect ); 
	} 
	//Info Button 
	GraphicsDraw("", RECTANGLE, evInfo.x, evInfo.y, 6, evInfo.w, evInfo.h, 0xDDFFFFAA); 
	GraphicsDraw("Info", TEXT, evInfo.x, evInfo.y, 6, evInfo.w, evInfo.h, 0x000000FF); 
	if ( ( evInfo.x < x < evInfo.x + evInfo.w ) && ( evInfo.y < y < evInfo.y + evInfo.h ) && InputButton(11,0)== 1  ) 
	{ 
		new Fixed:qx, Fixed:qy , Fixed:qz 
		EntityGetPosition(qx, qy, qz, entities[evEntity]); 
		new qtype = EntityPublicVariable(entities[evEntity], "qType") 
		StringFormat(evError,_,"%qx%q type:%d", qx, qy, qtype); 
		//CallEntityHit( entities[evEntity], "tester", angle, dist, attack, damage, x, y, rect ); 
	} 
 
	//Awaking Button 
	GraphicsDraw("", RECTANGLE, evActivate.x, evActivate.y, 6, evActivate.w, evActivate.h, 0xFF00DDAA); 
	if ( ( evActivate.x < x < evActivate.x + evActivate.w ) && ( evActivate.y < y < evActivate.y + evActivate.h ) && InputButton(11,0)== 1  ) 
	{ 
		 //CallEntityHit( entities[evEntity], "tester", angle, dist, attack, damage, x, y, rect ); 
	} 
 
	//Awaking Button 
	GraphicsDraw("", RECTANGLE, evKill.x, evKill.y, 6, evKill.w, evKill.h, 0xDD00FFAA); 
	if ( ( evKill.x < x < evKill.x + evKill.w ) && ( evKill.y < y < evKill.y + evKill.h ) && InputButton(11,0) ) 
	{ 
		 //CallEntityHit( entities[evEntity], "tester", angle, dist, attack, damage, x, y, rect ); 
	} 
} 
 
GenerateEntityList() 
{ 
	for( new z = 0; z < 128; z++ ) 
	{ 
		entities[z] = 0; 
	} 
	new c = 0; 
	if ( EntitiesList(0) ) 
	{ 
		while ( EntitiesNext( entities[c], 0, entities_name[c]) ) 
		{ 
			c++; 
		} 
 
	} 
	 
	new map = CURRENT_MAP; 
	if ( EntitiesList(map) ) 
	{ 
		while ( EntitiesNext( entities[c], map) ) 
		{ 
			c++; 
		} 
 
	} 
 
} 
 
 
 
DisplayEntityList( position[RECT], display_list ) 
{ 
	GraphicsDraw("", RECTANGLE,  
				position.x,  
				position.y,  
				6,  
				position.w,  
				position.h, 
				WHITE); 
 
	new x = position.x; 
	new y = position.y + position.h; 
 
	new global = EntitiesList(0); 
	new local = EntitiesList(CURRENT_MAP); 
	entities_count = global+local; 
 
	new str[42]; 
	StringFormat(str, _,"Global: %d\nLocal: %d", global, local); 
	GraphicsDraw(str, TEXT, position.x, position.y, 6, 0,0, BLACK); 
	if ( display_list  ) 
	{ 
		GraphicsDraw("", RECTANGLE,  
				x,  
				y,  
				6,  
				position.w,  
				10*entities_count, 
				0xDDDDDDDD); 
		 
			 
		for( new c = 0; c < entities_count; c++ ) 
		{ 
			StringFormat(str,_,"%d: %s", EntityPublicVariable(entities[c], "qType"), entities[c]  ); 
			GraphicsDraw(str, TEXT, x, y, 6, 0,0, BLACK); 
			y+=10; 
		} 
 
	} 
 
 
}