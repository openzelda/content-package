/***********************************************
 * Copyright (c) 2004-2006 Editors
 * Changes:  
 *	19/08/03 [lukex]: New file.
 *	17/04/05 [lukex]: basic working system up & running
 ***********************************************/

/* TODO */
/*
	1. Finished animation & pretting up.

*/
/* Known Bug */
/*
	1. Do not Create via main.zes firstrun

*/

#include <animation>
#include <foreign/journey>
#include <core>
#include <float>



const DEBUGSCRIPT = 0;
new author[3] = {1819634533,2013265920, 0 };

new groupx = -1;
new groupy = -1;
new groupx_offset, groupy_offset;
const DIG_X = 40;
const DIG_Y = 30;
new dig_area[DIG_X][DIG_Y];

main()
{
	if (FirstRun())
	{
		// Set this entity's basic type
		SetType("this", itemType);
		SetImage("this", "i_shovel");
		SetOwnedFlag("this", true);		// this sword is always avaiable on the menu
		// Create 2 string for the weapons descriptions
		AllocateStrings("this", 2, 64);	
		SetString("this", 0, ""); 	// For Chests
		SetString("this", 1, "Shovel"); 				// For menu
		SetActiveDist("this", -2);
		SetActiveInGroups("this", 1);
		GridGroup();
	}
	
	SetPosition("this", GetX("player1"), GetY("player1"));
	
	new currentGroupX = GetGroupMinX() / 320;
	new currentGroupY = GetGroupMinY() / 240;

	if (groupx != currentGroupX || groupy != currentGroupY)
	{
		groupx = currentGroupX;
		groupy = currentGroupY;
		GridGroup();
	}


	if (DEBUGSCRIPT)
	{
		new px = GetAnglePointX("this", 9, 8);
	new py = GetAnglePointY("this", 9, 8);
	new nx, ny;
	nx = ((px - GetGroupMinX()) / 16);
	ny = ((py - GetGroupMinY()) / 16);
		ConsoleNumber("ny", ny);
		ConsoleNumber("nx", nx);
		ConsoleNumber("py", py);
		ConsoleNumber("px", px);
		ConsoleNumber("dig_area[nx][ny]", dig_area[nx][ny]);
	}
	DisplayHoles();
}


public Init()
{
	SetDirection("this", GetDirection("player1"));
	SetMoveAngle("this", GetMoveAngle("player1"));
}

public DrawWeapon( keyHeld )
{
	//DrawAnim()
	new diggable = 0;
	diggable = IsDiggable(true);
	if (diggable == 2)
	{
		//Already dug
		PlaySound("_error.wav");
	}
	else if (diggable == 1)
	{
		//digging
		new item[20];
		CallFunction("_itemlib", false, "GetRandomItem", "nns", GetX("this") + 8, GetY("this") + 8, item);

	}
	else
	{
		//Can't digg
		PlaySound("_error.wav");
	}
	SetState("player1", standing);
	return -1;
}	


public IsDiggable(dig)
{
	new px = GetAnglePointX("this", 9, 8);
	new py = GetAnglePointY("this", 9, 8);
	new nx, ny;
	nx = ((px - GetGroupMinX()) / 16);
	ny = ((py - GetGroupMinY()) / 16);
	new temp = dig_area[nx][ny];
	if (dig_area[nx][ny] == 1 && dig )
		dig_area[nx][ny] = 2;

	return temp;
}

GridGroup()
{
	new startX = GetGroupMinX();
	new startY = GetGroupMinY();
	new x = 0;
	new y = 0;
	new point = 0;

	for (new nx = 0; nx < DIG_X; nx++)
	{
		x = (startX + (nx * 16));
		for (new ny = 0; ny < DIG_Y; ny++)
		{
			y = (startY + (ny * 16));
			point = CheckMask(x + 8, y + 8, true);
			dig_area[nx][ny] = ( point == 248 ? 1 : 0);
			
		}
	}
}
DisplayHoles()
{
	new startX = GetGroupMinX();
	new startY = GetGroupMinY();
	new x = 0;
	new y = 0;

	for (new nx = 0; nx < DIG_X; nx++)
	{
		
		x = (startX + (nx * 16));
		if ( GetWorldX() <= x <= (GetWorldX() + 320) )
		{
			for (new ny = 0; ny < DIG_Y; ny++)
			{
				y = (startY + (ny * 16));
				if ( dig_area[nx][ny] == 2 )
					PutSprite("shoveltest", x, y, 0);
				
			}
		}
	}
}