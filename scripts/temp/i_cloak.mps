/***********************************************
 * Copyright (c) 2004-2006 Editors
 * Changes:  
 *	18/04/05 [lukex]: New File base on my comment made to Kouruu's Cloak script
 ***********************************************/

#include <foreign/journey>
#include <counter>
#include <float>

new keyReleased = false;
new float: magic_count;
main()
{
	if (FirstRun())
	{
		// Set this entity's basic type
     		SetType("this", itemType);
     	
      		AllocateStrings("this", 2, 128);	
	      	SetString("this", 0,  "You got the Invisibility Cloak!`Now your enemies can't see you! But watch your Magic Meter!");
      		SetString("this", 1,  "Magic Cloak");
      		SetImage("this", "i_cloak");
	}
}

public Init()
{
	magic_count = 0.00;
	SetVisibleFlag("player1", false); // Stop Player Script from drawing the player
	keyReleased = false;
}

public DrawWeapon(keyHeld)
{

	if (keyHeld && keyReleased)
	{
		SetVisibleFlag("player1", true);
		
		return -1; //Returning -1 means this script is finished.
	}
	if (keyHeld == 0) // when keyHeld eq. 0 means the player has released the key
	{
		keyReleased = true;
	}
	
	/* Should Use player1.zes CheckForMovement() instead of using it own movement code */
	new moving = true;
	if (UpKey() && !DownKey() && !LeftKey() && !RightKey())
		SetMoveAngle("player1", 90);
	else if (!UpKey() && DownKey() && !LeftKey() && !RightKey())
		SetMoveAngle("player1", 270);
	else if (!UpKey() && !DownKey() && LeftKey() && !RightKey())
		SetMoveAngle("player1", 0);
	else if (!UpKey() && !DownKey() && !LeftKey() && RightKey())
		SetMoveAngle("player1", 180);
	else if (UpKey() && !DownKey() && !LeftKey() && RightKey())
		SetMoveAngle("player1", 135);
	else if (UpKey() && !DownKey() && LeftKey() && !RightKey())
		SetMoveAngle("player1", 45);
	else if (!UpKey() && DownKey() && LeftKey() && !RightKey())
		SetMoveAngle("player1", 315);
	else if (!UpKey() && DownKey() && !LeftKey() && RightKey())
		SetMoveAngle("player1", 225);
	else
		moving = false;
	new x = GetX("player1");
	new y = GetY("player1");
	SetX("this", x);
	SetY("this", y);

	if ( moving )
		CallFunction("player1", false, "Walk", "nnn", x, y, 1);
	else 
		CallFunction("player1", false, "Stand", "nn", x, y);

	PutSprite("shadow1", x, y, 2);
}


