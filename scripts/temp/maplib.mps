/* This file is Public Domain */
/***********************************************
 * _maplib
 * 
 * Author:	Satanman
 * Date:	13th august 2002
 *
 * Desc:	A dungeon map library
 *
 * Usage:	called by the main script, also uses map files
 *			to get the layout of multiple dungeons
 *			This script raises the question of 'why is link
 *			carrying a state-of-the-art digital map?'
 *
 * Changes: 02/04/2003 by lukex -  
 *	    Added Basic World map
 *	    Made changes to support updated Compass & map items 
 * 	07-08/2005 by lukex -  
 *	    OO-style map data, Groups Naming
 ***********************************************/
#include <animation>
#include <foreign/journey>
#include <float>
#include <core>




const NumberOfDungeons = 17;


new LevelNow = 0;
new float: MapCount;
new MapGoingDown;
new MapGoingUp;
new MapDown;
new ypos = 0;
new MaxYPos = 640;

/*
boss key = 4
compass = 2
map = 1
*/

new DungeonsId[NumberOfDungeons][64];

//----------------------------------------
// Name: Init()
//----------------------------------------
public Init()
{
	AllocateStrings("this", 1, 64);
	printf("_maplib.zes Loaded");
	SetValue("this", 0, 0);
}

//----------------------------------------
// Name: Init()
//----------------------------------------
public AddMap(map[], level)
{
	strcpy(DungeonsId[level], map);
}

//----------------------------------------
// Name: HandleMap()
//----------------------------------------
public HandleMap()
{
	// Return a result based on the map state
	new res = 0;
	
	// If the map is active then draw it
	if ( MapGoingDown || MapGoingUp || MapDown )
	{
		DisplayMap();
		res = 1;

	}
	// Check if the user is pressing the W key
	if ( WKey() )
	{
		SetWKey(false);
		if ( MapGoingDown || MapGoingUp )
			return 1;

		if (MapDown)
			EndMap();
		else
			StartMap();

		MapCount = 0.00;
		res = 1;
	}
	
	LevelNow = GetValue("this", 0);
	ConsoleNumber("LevelNow",LevelNow);
	if ( !res && !LevelNow)
	{
		for (new n = 1; n < NumberOfDungeons; n++)
		{
			if ( strlen(DungeonsId[n]) > 1 )
			{
				new dungeon_exit[64];
				GetString(DungeonsId[n], 1, dungeon_exit);

				if ( strlen(dungeon_exit) > 1 )
				{
					
					if ( isInteracting(dungeon_exit) )
					{
						LevelNow = n;
						SetValue("this", 0, n);
						SetRestartPoint(GetX(dungeon_exit) + 8,GetY(dungeon_exit));
						new dname[64];
						GetString(DungeonsId[LevelNow], 0, dname);
						SetString("this", 0, dname);
					}
				}
			}
		}
	}

	return res;
}

//----------------------------------------
// Name: StartMap()
// Called when the map goes down
//----------------------------------------
StartMap()
{
	// Start the Map going down
	SetPauseLevel(1);
	MapGoingDown = true;
	PlaySound("_menuopen.wav", 245);
}

//----------------------------------------
// Name: EndMap()
// Called when the map goes back up
//----------------------------------------
EndMap()
{
	MapGoingUp = true;
	PlaySound("_menuclose.wav", 245);
}


//----------------------------------------
// Name: MoveMap()
//----------------------------------------
MoveMap()
{
	new TempY;
	MapCount += 850 * GetTimeDelta();
	TempY = floatround( MapCount );
	
	// Decide if we are going up or down
	if ( MapGoingDown )
		ypos = TempY;
	else
		ypos = MaxYPos - TempY;
	
	// Check if the map has reached ts limit
	if ( TempY >= MaxYPos)
	{
		if ( MapGoingDown )
		{
			MapDown = true;
			//fix a 'going too far' bug
			ypos = MaxYPos;
		}
		else
		{
			// Map has gone completely up
			MapDown = false;
			SetPauseLevel(0);
		}
		
		MapGoingDown = false;
		MapGoingUp = false;
	}
}




//----------------------------------------------
// name: DisplayMap()
//----------------------------------------------
public DisplayMap()
{
	if ( MapGoingDown || MapGoingUp )
		MoveMap();
		
	new Adj = ypos - MaxYPos;

	DrawRectangle(0, 0, 640, 480, 0, 0, 0, 127);
	if ( !LevelNow )
	{
		DrawBorder(10, 10 - Adj, 620, 460, 0);
		CallFunction(DungeonsId[LevelNow], false, "DrawMap", "n", Adj);
	} 
	else 
	{
		DrawBorder(70, 40 - Adj, 500, 400, 0);
		CallFunction(DungeonsId[LevelNow], false, "DrawMap", "n", Adj);
	}
}

//----------------------------------------
// Name: DrawBorder() (from GD's _menulib)
//----------------------------------------
public DrawBorder( x, y, width, height, type)
{
	// Create an array with sprite names in
	new sprites[16][] = { "map_border1", "map_border2", "map_border3", "map_border4", "map_border5", "map_border5", "map_border6", "map_border6", "map_border11", "map_border12", "map_border13", "map_border14", "map_border15", "map_border16", "map_border17", "map_border18"};
							
	// Draws a rectangle of sprites
	new wid = 16;
	new hei = 16;
	new n;
	new i = type;
	
	// Draw 4 corners
	DrawImage(sprites[0 + i], x, y, 255, 255, 255, 255, 0, 200);
	DrawImage(sprites[1 + i], x + width - wid, y, 255, 255, 255, 255, 0, 200);
	DrawImage(sprites[2 + i], x, y + height - hei, 255, 255, 255, 255, 0, 200);
	DrawImage(sprites[3 + i], x + width - wid, y + height - hei, 255, 255, 255, 255, 0, 200 );
	
	// Draw 4 sides
	for ( n = x + wid; n < x + width - wid; n+= wid)
	{
		DrawImage(sprites[4 + i], n, y, 255, 255, 255, 255, 0, 200);
		DrawImage(sprites[5 + i], n, y + height - hei, 255, 255, 255, 255, 0, 200 );
	}
		
	for ( n = y + hei; n < y + height - hei; n+= hei)
	{
		DrawImage(sprites[6 + i], x, n, 255, 255, 255, 255, 0, 200);
		DrawImage(sprites[7 + i], x + width - wid, n, 255, 255, 255, 255, 0, 200);
	}
	if (i == 0)
		DrawRectangle( x, y, x + width - wid, y + height - hei, 0,0,0);
}

public SetPlayerPosition(x, y, z)
{
	LevelNow = GetValue("this", 0);
	CallFunction(DungeonsId[LevelNow], false, "SetPlayerPosition", "nnn", x, y, z);
}

public UpdatePlayerPos(axis, value)
{
	LevelNow = GetValue("this", 0);
	CallFunction(DungeonsId[LevelNow], false, "UpdatePlayerPos", "nn", axis, value);
}

//CallFunction("_maplib", false, "UpdatePlayerPos", "nn", axis, value);