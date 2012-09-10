/* This file is Public Domain */
/***********************************************
 * _mapitem.zes
 * 
 * Author: Satanman
 * Date:   16th august 2002
 *
 * Desc:  a map item;
 *
 * Usage: place it in chests
 * 
 * Changes: 02/04/2003 by lukex -  
 *	    removes the need for param, but now 
 *	    relies on _maplib
 *         
 ***********************************************/
#include <foreign/journey>
#include <counter>
#include <float>

new MainImage[20];   	
new ImageAlpha = 255;		
new width;
new height;


//----------------------------------------
// Name: main()
//----------------------------------------
main()
{
	if (FirstRun())
	{  	      	
		// Save the parameter passed
		AllocateStrings("this", 1, 300);
		SetImage("this", "_mapitem");
		MainImage = "_mapitem";
		SetString("this", 0, "You Found the map! "); 
	
		// Get the width and Height of the anim for future use
		width  = GetWidth(MainImage);
		height = GetHeight(MainImage);
	}	
	
	if ( !isTaken("this"))
	{
		if ( Collide("this", "player1") && isPickable("this") )
			ItemTake();
		
		new x = GetX("this");
		new y = GetY("this");
		
		// Set up 1 collision rectangle for the item
		SetCollisionRect("this", 0, false, x, y, x + width, y + height);
		
		// If the Item is visible then draw it
		if (isVisible("this") && !FirstRun("this"))
		{
			PutSprite(MainImage, x, y, y + height, 0, 255, 255, 255, ImageAlpha, 0, 100);
			PutSprite("shadow3", x, y + height - 7, 2, 0, 255, 255, 255, ImageAlpha);
		}
		
	}
}

//----------------------------------------
// Name: ItemTake()
//----------------------------------------
ItemTake()
{
	// Make the Item disappear when taken
	SetVisibleFlag("this", false);
	SetTakenFlag("this", true);
	
	new Dungeon = GetValue("_maplib", 0);
	SetValue("_maplib", Dungeon, GetValue("_maplib", Dungeon) + 1 );
	
	// Delete this entity if its been taken
	DeleteEntity("this");
}