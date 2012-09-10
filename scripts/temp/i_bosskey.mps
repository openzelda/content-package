/***********************************************
 * Copyright (c) 2002-2005 Editors
 * Changes:  
 *	16/06/02 [GD]: New file.
 *	02/04/03 [lukex]: Split it from _itemkey#
 *			  Uses maplib to set 1 key per dungeons
 ***********************************************/
#include <foreign/journey>
#include <counter>
#include <float>


new MainImage[20];		// String holds the main image for the entity
new bouncing = false;
new initialBounce;
new TempBounce;    		
new float: bounceVelocity = 0.00;
new float: bounceY;
new width;
new height;

//----------------------------------------
// Name: main()
//----------------------------------------
main()
{
	if (FirstRun())
	{
		// Allocate 1 text string, 300 characters long 
		AllocateStrings("this", 1, 300);
		SetActiveDist("this", 190);
		
		// Save the parameter passed
		MainImage = "_bosskey";
		SetString("this", 0, "You got the Master key! this key can unlock special doors and chests.");
					
		SetImage("this", MainImage);
		width = GetWidth(MainImage);
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
			PutSprite(MainImage, x, y - floatround(bounceY), y + height);
			PutSprite("shadow3", x + (width / 2) - 4, y + height - 6, 2);
		}
	}
	
	if (bouncing)
		Bounce();
}

//----------------------------------------
// Name: ItemTake()
//----------------------------------------
ItemTake()
{
	// Make the Item disappear when taken
	SetVisibleFlag("this", false);
	SetTakenFlag("this", true);
	
	// This is a key - so update the correct counter
	new Dungeon = GetValue("_maplib", 0);
	SetValue("_maplib", Dungeon, GetValue("_maplib", Dungeon) + 4 );
	
	// Other scripts can disable the sound effect on items by setting their first value to 1
	if ( GetValue("this", 0) == 0 )
		PlaySound("_getkey.wav", 240);
	
	// Delete this entity if its been taken
	DeleteEntity("this");
}

//----------------------------------------
// Name: StartBounce()
//----------------------------------------
public StartBounce()
{
	/* StartBounce is called from another script using CallFunction, it should be
	called just after the item is created to make it "bounce" a bit. */
	
	// While this is bouncing it can't be picked up by the player
	SetPickableFlag("this", false);
	
	bouncing = true;
	bounceVelocity = 160.00;
	bounceY = 0.00;
	TempBounce = 120;
	
	// Record the position of the item before it bounces
	initialBounce = GetY("this");
}


//----------------------------------------
// Name: Bounce()
//----------------------------------------
Bounce()
{
	bounceVelocity -= (700 * GetTimeDelta());
	bounceY += (bounceVelocity * GetTimeDelta());
	
	// Check if the item has finished bouncing
	if (initialBounce - floatround(bounceY) > initialBounce)
	{
		// Check if the item has more bounce left in it
		if (TempBounce < 20)
		{
			bouncing = false;
			SetPickableFlag("this", true);
		}   
		else
		{ 
			bounceVelocity = float(TempBounce);
			TempBounce = TempBounce / 2;
			bounceY = 0.00;
		} 
	}
}