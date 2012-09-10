/***********************************************
 * Copyright (c) 2002-2005 Editors
 * Changes:  
 *	12/06/02 [GD]: New file.
 *	02/04/03 [lukex]: 
 *		Suit listing Added
 *		Day/ Hour / Minute shown [Lukex]
 *		Added support for Dungeon items (updated _maplib needed) [Lukex]
 *		New Public Function: ableMenu(able) - Disable the menu also disable the HUD. [Lukex]
 *		Time is now paused when menu is open. [Lukex]
 *	05/06/04 [lukex]: 
 *		Added (un)Selecting callfunction, useful if you want the item do somthing when selected.
 *		Add "Run Submenu" feature, the sub menu is controlled by the weapon entity.
 *	14/06/04 [lukex]: menu shouldn't become inactive after selecting. 
 *	05/02/05 [lukex]: Displays Player Level/EXP  
 *	02/05/05 [lukex]: Added Arrows & bomb display
 *	12/05/05 [lukex]: Design change. 
 ***********************************************/
#include <animation>
#include <foreign/journey>
#include <counter>
#include <float>
#include <core>

// Menu item variables
const MAX_ITEMS = 64;			// Max items the menu can hold
new NumItems 	= 0;
new ItemCodes[MAX_ITEMS][20];	// Array to hold the IDs of all entities in the menu
new ItemSprites[MAX_ITEMS][20];	// Array to hold the sprites of all entities in the menu
new ItemX[MAX_ITEMS];
new ItemY[MAX_ITEMS];
new ItemUnits[MAX_ITEMS];
new dname[64];

// Menu Status Variables
new MenuDown 	  = false;
new MenuGoingDown = false;
new MenuGoingUp   = false;
new float: MenuCount = 0.00;
new ypos = 0;
new MaxYPos = 480;
new Selected = 0;

// Menu Item placement
new ItemStartX 		= 45;
new ItemStartY 		= 132;
new ItemBoxWidth 	= 370;
new ItemBoxHeight 	= 432;
new ItemsPerRow		= 8;

new MenuActive 	  = 1;
new SubMenuActive[20] = "";
new Menu 	  = 0;
//----------------------------------------
// Name: Init()
//----------------------------------------
public Init()
{
	AllocateStrings("this", 5, 32);	
}

public ableMenu(able)
{
	MenuActive = able;
}

//----------------------------------------
// Name: HandleMenu()
//----------------------------------------
public HandleMenu()
{
	if (!MenuActive || (GetPauseLevel() == 3) )
		return 1;	
	// Return a result based on the menu state
	new res = 0;
	
	// If the menu is active then draw it
	if ( MenuGoingDown || MenuGoingUp || MenuDown )
	{
		if (GetPauseLevel() == 1)
			SetMinuteCount(GetMinuteCount());
		DrawMenu();
		res = 1;
  	
	}
	if (ZKey())
		Save();	
	// Check if the user is pressing the enter key
	if (EnterKey())
	{
		SetEnterKey(false);
		
		if ( MenuGoingDown || MenuGoingUp )
			return 1;
		
		if (MenuDown)		
			EndMenu();
		else
			StartMenu();
				    
		MenuCount = 0.00;
		res = 1;
	}
	return res;
}

//----------------------------------------
// Name: StartMenu()
// Called when the menu goes down
//----------------------------------------
StartMenu()
{
	new Selected[2][20];
	
	// Start the Menu going down
	SetPauseLevel(1);

	RebuildMenuList();
	MenuGoingDown = true;
	PlaySound("_menuopen.wav", 245);
	
	// Get the Selected menu items from the Player
	GetString("player1", 0, Selected[0]);
	GetString("player1", 1, Selected[1]);
	SetString("this", 0, Selected[0]);
	SetString("this", 1, Selected[1]);
	GetString("_maplib", 1, dname);
}

//----------------------------------------
// Name: EndMenu()
// Called when the menu goes back up
//----------------------------------------
EndMenu()
{
	new Selected[2][20];
	
	MenuGoingUp = true;
	PlaySound("_menuclose.wav", 245);
	SubMenuActive = "";
	
	// Save the selected items in the player's strings
	GetString("this", 0, Selected[0]);
	GetString("this", 1, Selected[1]);
	SetString("player1", 0, Selected[0]);
	SetString("player1", 1, Selected[1]);
}


//----------------------------------------
// Name: MoveMenu()
//----------------------------------------
MoveMenu()
{
	new TempY;
	MenuCount += 500 * GetTimeDelta();
	TempY = floatround( MenuCount );
	
	// Deciede if we are going up or down
	if ( MenuGoingDown )
		ypos = TempY;
	else
		ypos = MaxYPos - TempY;
	
	// Check if the menu has reached ts limit
	if ( TempY >= MaxYPos)
	{
		if ( MenuGoingDown )
		{
			MenuDown = true;
		}
		else
		{
			// Menu has gone completely up
			MenuDown = false;
			SetPauseLevel(0);
		}
		
		MenuGoingDown = false;
		MenuGoingUp = false;
	}
}

//----------------------------------------
// Name: DrawMenu()
//----------------------------------------
DrawMenu()
{
	new itemx;
	new itemy;
	new n;
	new Adj = ypos - MaxYPos;
	new suit[4][20] = { "NULL", "playersuit1", "playersuit2", "playersuit3"  };
	new glove[4][20] = { "NULL", "_powerglove1", "_lunarglove1", "_titanmitt1"  };
	new suit_num;
	new string[16];
	new hour = GetHourCount();
	new minute = GetMinuteCount();
	new day = GetDayCount();
	new Dungeon = GetValue("_maplib", 0);
	
	DrawRectangle(0, 0, 640, 480, 0, 0, 0, 128);
	
	if ( MenuGoingDown || MenuGoingUp )
		MoveMenu();
	else
	{

	}
	//DrawBorder( x, y, width, height, color )
	// color 0 green; color 8 red; color 16 yellow;
	DrawBorder( 10, 10 + Adj, 200, 80, 0 );
	DrawBorder( 220, 10 + Adj, 200, 80, 0 );
	DrawBorder( 430, 10 + Adj, 200, 100, 0 );
	
	DrawBorder( 10, 100 + Adj, 408, 260, 8 );
	DrawBorder( 10, 370 + Adj, 408, 80, 8 );
	
	DrawBorder( 430, 120 + Adj, 200, 146, 16 );
	DrawBorder( 430, 276 + Adj, 200, 175, 16 );
	
	DrawBitmapText("Primary Weapon", 18, 18 + Adj, 2, COLOURS[White][0], COLOURS[White][1], COLOURS[White][2], _, 100 );
	DrawBitmapText("Secondary Weapon", 230, 18 + Adj, 2, COLOURS[White][0], COLOURS[White][1], COLOURS[White][2], _, 100 );

	// Go through each item in the menu and draw them
	for (n = 0; n < NumItems; n++)
	{
		DrawImage( ItemSprites[n], ItemX[n], ItemY[n] + Adj, 255, 255, 255, 255, 0, 200 );	
		if ( ItemUnits[n] != -1 )
			DrawNumber( ItemUnits[n], ItemX[n] + 16, ItemY[n] + Adj + 16, 196, 0 );
	}
	
	DrawSelectedItems();	
	HandleSelection();
	
	
	suit_num = CallFunction("player1", true, "GetPlayerSuit", "NULL");
	DrawImage("_menuequip", 460, 300 + Adj, 255, 255, 255, 255, 0, 200);
	DrawImage(suit[suit_num], 460, 330 + Adj, 255, 255, 255, 255, 0, 200);
	DrawImage(glove[GetLiftLevel("player1")], 496, 330 + Adj, 255, 255, 255, 255, 0, 200);
	if ( GetCounterMax("arrows") != -1 )
		DrawImage("i_quiver", 528, 330 + Adj, 255, 255, 255, 255, 0, 200);
	if ( GetCounterMax("bombs") != -1 )
		DrawImage("i_bombbag", 564, 330 + Adj, 255, 255, 255, 255, 0, 200);


	if ( Dungeon > 0) {
		new DungeonValue = GetValue("_maplib", Dungeon);
		if ( DungeonValue > 3 )
		{
			DungeonValue -= 4;
			DrawImage("_bosskey", 480, 400 + Adj, 255, 255, 255, 255, 0, 200 );
		}
		if ( DungeonValue > 1 )
		{
			DungeonValue -= 2;
			DrawImage("_compassitem", 560, 400 + Adj, 255, 255, 255, 255, 0, 200 );
			
		}
		if (DungeonValue > 0)
		{
			DrawImage("_mapitem", 520, 400 + Adj, 255, 255, 255, 255, 0, 200 );
		}
		DrawImage("_menudungeon", 480, 370 + Adj, 255, 255, 255, 255, 0, 200);

	} else {
		/*
		if (GetCounterValue("HeartPieces") == 1)
			DrawImage("_heart14", 520, 400 + Adj, 255, 255, 255, 255, 0, 200 );
		else if (GetCounterValue("HeartPieces") == 2)
			DrawImage("_heart24", 520, 400 + Adj, 255, 255, 255, 255, 0, 200 );
		else if (GetCounterValue("HeartPieces") == 3)
			DrawImage("_heart34", 520, 400 + Adj, 255, 255, 255, 255, 0, 200 );
		else
			DrawImage("_heart04", 520, 400 + Adj, 255, 255, 255, 255, 0, 200 );
		*/
	}
	
	new time_string[6] = "00:00";
	ToString(hour, string);
    if (hour < 10) 
    { 
        time_string[0] = '0'; 
        time_string[1] = string[0]; 
    } 
    else 
    { 
        time_string[0] = string[0];
        time_string[1] = string[1]; 
    }  
    ToString(minute, string); 
    if (minute < 10) 
    { 
        time_string[3] = '0';
        time_string[4] = string[0];  
    } 
    else 
    { 
        time_string[3] = string[0];
        time_string[4] = string[1]; 
    } 
	
	DrawBitmapText(time_string, 450, 30 + Adj, 2, COLOURS[White][0], COLOURS[White][1], COLOURS[White][2], _, 100 );
	
	ToString(day+1, string);
	DrawBitmapText("Day: ", 450, 50 + Adj, 2, COLOURS[Red][0], COLOURS[Red][1], COLOURS[Red][2], _, 100);
	DrawBitmapText(string, 506, 50 + Adj, 2, COLOURS[White][0], COLOURS[White][1], COLOURS[White][2], _, 100 );



	DrawBitmapText(dname, 450, 70 + Adj, 2, COLOURS[Lime][0], COLOURS[Lime][1], COLOURS[Lime][2], _, 100);

	CallFunction("player1", true, "DisplayLevelStats", "nn", 450, 200 + Adj);
}

//----------------------------------------
// Name: DrawSelectedItems()
//----------------------------------------
DrawSelectedItems()
{
	new n;
	new Entity[20];
	new Buffer[20];
	new Adj = ypos - MaxYPos;
	SetTextSize(12);
	
	for (n = 0; n < 2; n++)
	{
		GetString("this", n, Entity);
		GetImage(Entity, Buffer);
		DrawImage(Buffer, (n * 210) + 40, 38 + Adj, 255, 255, 255, 255, 0, 200);
		
		// Write a description of the item
		if (GetString(Entity, 1, Buffer) == 0)      // Description should be stored as string 0
		{
			if (strlen(Buffer) > 2)
			{
				DrawText(Buffer, (n * 210) + 70, 38 + Adj, 255, 255, 255, 255);
			}
		}
	}
}

//----------------------------------------
// Name: HandleSelection()
//----------------------------------------
HandleSelection()
{

	if ( strlen(SubMenuActive) > 1 )
	{	
		if ( CallFunction(SubMenuActive, false, "SubMenu", "NULL") == 1 )
			return;
		else
			SubMenuActive = "";
		
	}

	static float: FlashCount = 0.00;
	new Adj = ypos - MaxYPos;
	
	// Dont do this part if the menu is moving up or down
	if (MenuGoingDown || MenuGoingUp || ItemX[Selected] == 0)
		return;
	
	// Create a little counter to make the cursor flash
	FlashCount += 6 * GetTimeDelta();
	if (FlashCount >= 2)
		FlashCount = 0.00;
	
	// Draw the selection cursor
	if (FlashCount >= 1)
		DrawImage("_menu9", ItemX[Selected] - 8, ItemY[Selected] + Adj - 8, 255, 255, 255, 128, 0, 200);
	
	// Check for Key entry
	if (UpKey())
	{
		SetUpKey(false);
		MoveSelection( ItemsPerRow, false );
	}
	else if (DownKey())
	{
		SetDownKey(false);
		MoveSelection( ItemsPerRow, true );
	}
	else if (LeftKey())
	{
		SetLeftKey(false);
		MoveSelection( 1, false );
	}
	else if (RightKey())
	{
		SetRightKey(false);
		MoveSelection( 1, true );
	}
	
	// Check for the user setting a new item
	new tempstring[32];
	if (AKey())
	{
		SetAKey(false);
		GetString("this", 1, tempstring);
		if ( !strcmp(ItemCodes[Selected], tempstring ) )
		{
			PlaySound("_error.wav", 245);
		} 
		else
		{
			tempstring = "";
			GetString("this", 0, tempstring);
			if ( strlen(tempstring) > 1  )
			{
				CallFunction(tempstring, true, "MenuUnselected", "NULL");
				tempstring = "";
			}
			SetString( "this", 0, ItemCodes[Selected]);
			if ( CallFunction(ItemCodes[Selected], true, "MenuSelected", "NULL") == 2 )
				SubMenuActive = ItemCodes[Selected];
			else
				SubMenuActive = "";
			PlaySound("_menuselect.wav", 245);
		}
	}
		
	if (SKey())
	{
		SetSKey(false);
		GetString("this", 0, tempstring);
		if ( !strcmp(ItemCodes[Selected], tempstring ) )
		{
			PlaySound("_error.wav", 245);
		} 
		else
		{
			tempstring = "";
			GetString("this", 1, tempstring);
			if ( strlen(tempstring) > 1  )
			{
				CallFunction(tempstring, true, "MenuUnselected", "NULL");
				tempstring = "";
			}
			SetString( "this", 1, ItemCodes[Selected]);
			if ( CallFunction(ItemCodes[Selected], true, "MenuSelected", "NULL") == 2)
				SubMenuActive = ItemCodes[Selected];
			else
				SubMenuActive = "";
			PlaySound("_menuselect.wav", 245);
		}
	}
}

//----------------------------------------
// Name: MoveSelection()
//----------------------------------------
MoveSelection( Amount, foward )
{
	if (foward)
	{
		if ( Selected + Amount < NumItems )
		{
			Selected += Amount;	
			PlaySound("_menuselect.wav", 245);
		}
	}
	else
	{
		if ( Selected - Amount >= 0)
		{
			Selected -= Amount;
			PlaySound("_menuselect.wav", 245);
		}
	}
}

//----------------------------------------
// Name: RebuildMenuList()
//----------------------------------------
RebuildMenuList()
{
	new ImageBuffer[20];
	new temp[20];
	NumItems = 0;
	new x = ItemStartX;
	new y = ItemStartY;
	Selected = 0;
	new ItemUnit;
	StartEntity(-1); 
	do  
	{
		ToString(GetCurrentEntity(), temp);
		
		// Check weapon and item entities only
		if (GetType(temp) == weaponType || GetType(temp) == itemType)  
		{
			// Get the image of the current item
			GetImage( temp, ImageBuffer );
								
			// Only add this item if it has an image and its owned by the player
			if ( strlen( ImageBuffer ) > 2 && isOwned(temp))
			{	
				ItemX[NumItems] = x;	
				ItemY[NumItems] = y;
				ItemUnit = GetValue(temp, 2);
				if ( ItemUnit == 4 )
					ItemUnits[NumItems] = GetCounterValue("arrows");
				else if ( ItemUnit == 3 )
					ItemUnits[NumItems] = GetCounterValue("bombs");
				else
					ItemUnits[NumItems] = -1;
				// Copy this items code to the array
				strcpy(ItemCodes[NumItems], temp);
				strcpy(ItemSprites[NumItems], ImageBuffer);
				
				NumItems++;
						
				// Get a position on the menu for this item
				x += 45;
				
				if (x > ItemBoxWidth)
				{
					x = ItemStartX;
					y += 45;
					
					if ( y > ItemBoxHeight )
						break;
				}
				
				// Dont put more than we allocated for
				if ( NumItems >= MAX_ITEMS )
					break; 
			}
		}
	}while( NextEntity() )  

}

public DrawBorder( x, y, width, height, color )
{
	// Create an array with sprite names in
	new sprites[24][20] = { "_menu1", "_menu2", "_menu3", "_menu4", "_menu5", "_menu6", \
									"_menu7", "_menu8", "_menu10", "_menu11", "_menu12", "_menu13", \
									"_menu14", "_menu15", "_menu16", "_menu17", "_menu18", "_menu19", \
									"_menu20", "_menu21", "_menu22", "_menu23", "_menu24", "_menu25" };
							
	// Draws a rectangle of sprites
	new wid = 16;
	new hei = 16;
	new n;
	new i = color;

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

	// Draw 4 corners
	DrawImage(sprites[0 + i], x, y, 255, 255, 255, 255, 0, 200);
	DrawImage(sprites[1 + i], x + width - wid, y, 255, 255, 255, 255, 0, 200);
	DrawImage(sprites[2 + i], x, y + height - hei, 255, 255, 255, 255, 0, 200);
	DrawImage(sprites[3 + i], x + width - wid, y + height - hei, 255, 255, 255, 255, 0, 200 );
	

	
	DrawRectangle( x, y, x + width - wid, y + height - hei, 0,0,0);
	

}

DrawNumber( num, x, y, alpha, maxed )
{
	new maxcolor = (maxed ? 0 : 255 );
	new tempString[10];
	ToString(num, tempString); 
	new tempImage[7] = "_itemX";

	for ( new n = strlen(tempString); n >= 0; n--)
	{
		x -= GetWidth(tempImage) - 2;
		tempImage[5] = tempString[n];
		DrawImage(tempImage, x, y, maxcolor, 255, maxcolor, alpha);
	}
}