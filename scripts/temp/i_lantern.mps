/***********************************************
 * Copyright (c) 2004-2006 Editors
 * Changes:  
 *	04/07/03 [lukex]: New file.
 ***********************************************/
#include <foreign/journey>
#include <counter>

new magicNeeded = 0;		// magic needed to fire the weapon
new entity[20];	

main()
{
	if (FirstRun())
	{
		// Set this entity's basic type
		SetType("this", weaponType);
		// Create 2 string for the item descriptions
		AllocateStrings("this", 2, 100);
		SetString("this", 0,  "You got the lantern! Now you can see in the dark");		// For Chests
		SetString("this", 1,  "Lantern");	// For menu
		SetImage("this", "i_lantern");
		SetOwnedFlag("this", true);
		magicNeeded = 1;
		CallFunction("_weatherlib", false, "AbleLantern", "n", true);
	}
		
}

//----------------------------------------
// Name: Init()
//----------------------------------------
public Init()
{
	if (magicNeeded > 0)
	{
		// Make sure we have enough magic to do this
		if ( GetCounterValue( "magic" ) < magicNeeded )
		{
			// Player does have enough magic
			PlaySound("_error.wav", 240);
		    	SetState("player1", standing);
		    	return -1;	
		}
		else
		{
			// Decrease magic level
			IncCounterTarget("magic", -magicNeeded);	
		}
	}
	   
		
	// Set the Position and Direction of this entity to match the player's
	SetX("this", GetX("player1"));
	SetY("this", GetY("player1"));
	SetDirection("this", GetDirection("player1"));

	CreateFlame();
}

CreateFlame()
{
	
	new x = GetX("player1");
	new y = GetY("player1");
	new dir = GetDirection("player1");
	
	if ( dir == north )
	{
		y -= 18;
	}
	else if ( dir == east )
	{
		x += 18;
	}
	else if ( dir == south )
	{
		y += 18;
	}
	else if ( dir == west )
	{
		x -= 18;
	}
	
	// Create a flame entity
	CreateEntity("w_flame", x, y, entity);
	SetDirection(entity, dir);
}

//----------------------------------------
// Name: DrawWeapon()
//----------------------------------------
public DrawWeapon(keyHeld)
{
	CallFunction("player1", false, "Stand", "nn", GetX("player1"), GetY("player1"));
	if ( !keyHeld )
	{
		return -1;
	}
}

