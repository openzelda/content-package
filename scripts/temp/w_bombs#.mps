/***********************************************
 * Copyright (c) 2004-2006 Editors
 * Changes:  
 *	29/06/02 [GD]: New file.
 ***********************************************/
#include <foreign/journey>
#include <counter>

main()
{
	if (FirstRun())
	{
		// Set the image which appears in the start menu
		SetImage("this", "_bombweapon1");
		if ( GetCounterMax("bombs") == -1 )
		{
			CreateCounterWithID(0, 20, "bombs");		// Create a bomb counter
			SetCounterTarget("bombs", 20);
			CallFunction("_itemlib", false, "AddItem", "sn", "_itembomb1", 65);  // 1 arrow
			CallFunction("_itemlib", false, "AddItem", "sn", "_itembomb2", 20);  // 5 arrows
			CallFunction("_itemlib", false, "AddItem", "sn", "_itembomb3", 7);   // 10 arrows
		}
		// Set this entity's basic type
		SetType("this", weaponType);
		SetValue("this", 2, 3);
		// Create 2 string for the weapons descriptions
		AllocateStrings("this", 2, 64);	
		SetString("this", 0, "You Got Bombs!");
		SetString("this", 1, "Bombs");
		SetOwnedFlag("this", true);		// Bombs are always avaiable on the menu
	}

}


//----------------------------------------
// Name: Init()
//----------------------------------------
public Init()
{
     
	// Check the player actually has some bombs
	if (GetCounterValue("bombs") < 1)
	{
		// no bombs
		PlaySound("_error.wav", 240);
		// Return control back to player entity
	    	SetState("player1", standing);
		return -1;
	}
	else
	{
		// Decrease bomb amount by 1
		IncCounterValue("bombs", -1);
	}

	// Play the sound of a bomb being laid
	PlaySound("_bombplaced.wav", 240);
   
	new EntName[20];
	new x = GetX("player1");
	new y = GetY("player1");
	new dir = GetDirection("player1");
	
	// Adjust the bombs position based on the player's direction
	if ( dir == north )
		y -= 12;
	else if ( dir == east )
		x += 12;
	else if ( dir == south )
		y += 12;
	else if ( dir == west )
		x -= 12;
			
	// We dont have to do much here - just create a bomb entity
	// in front of the player.
	CreateEntity("w_bomb1", x, y, EntName);
}
public DrawWeapon( keyHeld )
{
	new x = GetX("player1");
	new y = GetY("player1");
	// Draw the Player animation
	if (isVisible("player1"))
	{
		CallFunction("player1", false, "Stand", "nn", x, y);	
	}


	
	if ( !keyHeld )
	{
		SetState("player1", standing); // Return control back to player entity
	}
}
