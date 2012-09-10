#include <public_events>

//#define MOUSE_PRESS(%1,  ( evKill[rX] < x < evKill[rX] + evKill[rW] ) && ( evKill[rY] < y < evKill[rY] + evKill[rH] ) && InputButton(11,0)

new entities[128][64 char]
new entities_count = 0;
new entitiylist[RECT] = {0, 0, 96,20 }


new evError[64];
new evHit[RECT] = {200, 20, 20,8 };
new evKill[RECT] = {230, 20, 20,8 };
new evActivate[RECT] = {260, 20, 20,8 };
new evInfo[RECT] = {290, 20, 20,8 };
new evNext[RECT] = {300, 8, 20,8 };
new evPrev[RECT] = {200, 8, 20,8 };
new evTitle[RECT] = {220, 8, 60,8 };
new evEntity = 0;

native DebugWatch();
public Init( ... )
{
	//DebugWatch();
}
main()
{
	GenerateEntityList();
	new x = InputPointer(0,0);
	new y = InputPointer(1,0);

	if ( ( entitiylist[rX] < x < entitiylist[rX] + entitiylist[rW] ) && ( entitiylist[rY] < y < entitiylist[rY] + entitiylist[rH] ) )
		DisplayEntityList(entitiylist, true );
	else
		DisplayEntityList(entitiylist, false  );

	//Next Button
	GraphicsDraw("", RECTANGLE, evNext[rX], evNext[rY], 6, evNext[rW], evNext[rH], 0xFFFFDDAA);
	if ( ( evNext[rX] < x < evNext[rX] + evNext[rW] ) && ( evNext[rY] < y < evNext[rY] + evNext[rH] ) && InputButton(11,0)== 1  )
		evEntity = (evEntity >= 127 ? 0 : evEntity + 1);

	// Title
	new str[64];
	StringFormat(str,_,_,"%d: %s", evEntity, entities[evEntity]);
	GraphicsDraw(str, TEXT, evTitle[rX], evTitle[rY], 6, evTitle[rW], evTitle[rH], 0x000000AA);
	GraphicsDraw(evError, TEXT, evHit[rX], evHit[rY]+10, 6, evTitle[rW], evTitle[rH], 0xFF0000AA);


	//Prev Button
	GraphicsDraw("", RECTANGLE, evPrev[rX], evPrev[rY], 6, evPrev[rW], evPrev[rH], 0xFFDDDDAA);
	if ( ( evPrev[rX] < x < evPrev[rX] + evPrev[rW] ) && ( evPrev[rY] < y < evPrev[rY] + evPrev[rH] ) && InputButton(11,0)== 1  )
		evEntity = (evEntity < 1 ? 127 : evEntity - 1);

	//Hit Button
	GraphicsDraw("", RECTANGLE, evHit[rX], evHit[rY], 6, evHit[rW], evHit[rH], 0xDDFFDDAA);
	GraphicsDraw("Hit", TEXT, evHit[rX], evHit[rY], 6, evHit[rW], evHit[rH], 0x000000FF);
	if ( ( evHit[rX] < x < evHit[rX] + evHit[rW] ) && ( evHit[rY] < y < evHit[rY] + evHit[rH] ) && InputButton(11,0) == 1 )
	{
		 //CallEntityHit( entities[evEntity], "tester", angle, dist, attack, damage, x, y, rect );
	}
	//Info Button
	GraphicsDraw("", RECTANGLE, evInfo[rX], evInfo[rY], 6, evInfo[rW], evInfo[rH], 0xDDFFFFAA);
	GraphicsDraw("Info", TEXT, evInfo[rX], evInfo[rY], 6, evInfo[rW], evInfo[rH], 0x000000FF);
	if ( ( evInfo[rX] < x < evInfo[rX] + evInfo[rW] ) && ( evInfo[rY] < y < evInfo[rY] + evInfo[rH] ) && InputButton(11,0)== 1  )
	{
		new Fixed:qx, Fixed:qy , Fixed:qz
		EntityGetPosition(qx, qy, qz,entities[evEntity]);
		new qtype = EntityPublicVariable(entities[evEntity], "_type_")
		StringFormat(evError,_,_,"%qx%q type:%d", qx, qy, qtype);
		 //CallEntityHit( entities[evEntity], "tester", angle, dist, attack, damage, x, y, rect );
	}

	//Awaking Button
	GraphicsDraw("", RECTANGLE, evActivate[rX], evActivate[rY], 6, evActivate[rW], evActivate[rH], 0xFF00DDAA);
	if ( ( evActivate[rX] < x < evActivate[rX] + evActivate[rW] ) && ( evActivate[rY] < y < evActivate[rY] + evActivate[rH] ) && InputButton(11,0)== 1  )
	{
		 //CallEntityHit( entities[evEntity], "tester", angle, dist, attack, damage, x, y, rect );
	}

	//Awaking Button
	GraphicsDraw("", RECTANGLE, evKill[rX], evKill[rY], 6, evKill[rW], evKill[rH], 0xDD00FFAA);
	if ( ( evKill[rX] < x < evKill[rX] + evKill[rW] ) && ( evKill[rY] < y < evKill[rY] + evKill[rH] ) && InputButton(11,0) )
	{
		 //CallEntityHit( entities[evEntity], "tester", angle, dist, attack, damage, x, y, rect );
	}
}

GenerateEntityList()
{
	for( new z = 0; z < 128; z++ )
	{
		entities[z] = "";
	}
	new c = 0;
	if ( EntitiesList(0) )
	{
		while ( EntitiesNext( entities[c], 0) )
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
				position[rX], 
				position[rY], 
				6, 
				position[rW], 
				position[rH],
				WHITE);

	new x = position[rX];
	new y = position[rY] + position[rH];

	new global = EntitiesList(0);
	new local = EntitiesList(CURRENT_MAP);
	entities_count = global+local;

	new str[42];
	StringFormat(str, _,_, "Global: %d\nLocal: %d", global, local);
	GraphicsDraw(str, TEXT, position[rX], position[rY], 6, 0,0, BLACK);
	if ( display_list  )
	{
		GraphicsDraw("", RECTANGLE, 
				x, 
				y, 
				6, 
				position[rW], 
				10*entities_count,
				0xDDDDDDDD);
		
			
		for( new c = 0; c < entities_count; c++ )
		{
			StringFormat(str,_,_,"%d: %s", EntityPublicVariable(entities[c], "_type_"), entities[c]  );
			GraphicsDraw(str, TEXT, x, y, 6, 0,0, BLACK);
			y+=10;
		}

	}


}