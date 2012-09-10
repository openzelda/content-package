/***********************************************
 * Copyright (c) 2002-2005 Editors, The Chemist
 * Changes:  
 *	04/09/2003 [The Chemist]: New file.
 ***********************************************/
#include <foreign/journey>
#include <animation>
#include <counter>
new doorAnim[20];	// String to store the Identifier of the door animation
new doorArch[20];   // String to hold the sprite of the Door's Arch
new doorSprite[20];
new width;		    // Used to store the widht and height of the door
new height;
new Animating = false;
new ClosedDoor = false;
new xoffset = 0;
new yoffset = 0;
new param;			// Will hold the parameter passed to this script
new x;
new y;

//----------------------------------------
// Name: main()
//----------------------------------------
main()
{
	if (FirstRun())
	{
		// Get the parameter passed to this script from the sprite code
		param = GetParam("this");
		AllocateStrings("this", 1, 20);
				
		// Create the Main Door Animation
		CreateAnim(8, doorAnim);
				
		SetDirection("this", north);
		
		// Add Frames to Animation depending on what the parameter is
        if ( param == 'g' )       // green
     	{
	 		 AddAnimframe(doorAnim, 0, 0, "_castledoorg");
	 		 ClosedDoor = true;
        }
     	else if ( param == 'b' )  // blue
     	{
       	  	 AddAnimframe(doorAnim, 0, 0, "_castledoorb");
       	  	 ClosedDoor = true;
        }
        else if ( param == 'r' )  // red
        {
        	 AddAnimframe(doorAnim, 0, 0, "_castledoorr");
        	 ClosedDoor = true;
        }
        else if ( param == 'p' )  // purple
        {
	         AddAnimframe(doorAnim, 0, 0, "_castledoorp");
	         ClosedDoor = true;
        }
		else if ( param == 'o' )  // open
		{
			doorSprite = "_castledooro";
			doorArch = "_castledoora";
			SetImage("this", "_castledooro");
		}
		else if ( param == 's' )  // steps
		{
			doorSprite = "_castledoors";
			doorArch = "_castledoor2a";
		}
		else if ( param == 'c' )  // Castle Gate
		{
			AddAnimframe(doorAnim, 0, 0, "_castledoorc");
        	AddAnimframe(doorAnim, 0, 0, "_castlegateopen1");
       	 	AddAnimframe(doorAnim, 0, 0, "_castlegateopen2");
       	 	AddAnimframe(doorAnim, 0, 0, "_castlegateopen3");
        	AddAnimframe(doorAnim, 0, 0, "_nullsprite");
        	doorArch = "_nullsprite";
        }
		
		// Add these frames + data for the coloured doors and others for other doors
		if (ClosedDoor)
		{
			AddAnimframe(doorAnim, 0, 8, "_castledooro1");
        	AddAnimframe(doorAnim, 0, 0, "_castledooro");
        	doorArch = "_castledoora";
        	width  = GetAnimWidth(doorAnim);
			height = GetAnimHeight(doorAnim);
        	SetOpenFlag("this", false);
        	SetImage("this", "_castledooro");
		}
		else if ( param == 'o' || param == 's')
		{
			DeleteAnim(doorAnim);
			SetOpenFlag("this", true);
			width  = GetWidth(doorSprite);
			height = GetHeight(doorSprite);
		}
		else
		{
			width  = GetAnimWidth(doorAnim);
			height = GetAnimHeight(doorAnim);
        	SetOpenFlag("this", false);
		}
		
		
		// Set the active distance for this entity
		SetActiveDist("this", 190);
		
		// Set this entity's basic type
		SetType("this", doorType);
		
		// Record x and y values
		x = GetX("this");
        y = GetY("this");
      		
		SetInteractingFlag("this", false);
	}
	
	// Draw the Arch of the door above everything else
    PutSprite(doorArch, x + xoffset, y + yoffset, 999999);
	
	// Draw the door animation or sprite
	if (ClosedDoor || param == 'c' )
		DrawAnimNoInc(doorAnim, x, y, 1);
	else
		PutSprite(doorSprite, x, y, 1);
		
	if (isOpen("this") && param != 'c' )
	{
		// Create a collsion rectangle around the whole door
		SetCollisionRect("this", 0, false, x + 2, y + 2, x + width - 2, y + height - 2);
		
	    /* Create another collision rectangle inside the door for checking if the 
        player is standing in the doorway */
        SetCollisionRect("this", 1, false, x + xoffset + 3, y + yoffset + 3, \
                         x + xoffset + GetWidth(doorArch) - 3, y + yoffset + GetHeight(doorArch) - 3);
		
		// Check if the Player is standing in the doorway
		if ( CollideAll("this", "player1"))
		{
			SetInteractingFlag("this", true);     // Set the Interacting Flag to true
			CallFunction("_doorlib", true, "MoveToOtherDoor", "NULL");	// Maybe move to another door
		}
		else
			SetInteractingFlag("this", false); 
	}
	else
	{
		if (ClosedDoor)
		{
			// Create a solid collsion rectangle around the whole door
			SetCollisionRect("this", 0, true, x + 2, y + 2, x + width - 2, y + height - 2);
			ClearCollisionRect("this", 1);
		
			// Check if the Player wants to open the door
			if ( CollideAll("this", "player1") )
				CheckForOpen();
		}
	}
	
	// Deal with the gate separately
	if ( param == 'c' )
		Gate();
	
	if (Animating && ( ClosedDoor || param == 'c' ))
		Animate();    // Move between closed and open states
	
}

//----------------------------------------
// Name: CheckForOpen()
//----------------------------------------
CheckForOpen()
{
	// Check the player is facing the door
	if (GetDirection("player1") == GetDirection("this"))
	{
		Open();
	}
}

//----------------------------------------
// Name: Open()
//----------------------------------------
public Open()
{
	if (!isOpen("this"))		// You cant open a door which is already open
		Animating = true;
}

//----------------------------------------
// Name: Close()
//----------------------------------------
public Close()
{	
	if (isOpen("this"))         // You cant close a door which is already closed
	{
		Animating = true;
	}
}

//----------------------------------------
// Name: Animate()
//----------------------------------------
Animate()
{
	// Makes the Door open or close
	if (!isOpen("this"))
	{
		SetAnimDirection(doorAnim, 1);     // Make the door animation go fowards
		IncrementAnim(doorAnim);  
		if (GetAnimCount(doorAnim) >= GetMaxAnim(doorAnim))
		{    
			SetOpenFlag("this", true);      // Open the door
			Animating = false;
			PlaySound("_dooropen.wav");
		}
	}
	else
	{
		SetAnimDirection(doorAnim, 0);     // Make the door animation go backwards
		IncrementAnim(doorAnim);  
		if (GetAnimCount(doorAnim) <= 0)
		{
			SetOpenFlag("this", false);      // Close the door
			Animating = false;
			PlaySound("_doorclose.wav");
		}        
	}
}


//----------------------------------------
// Name: Gate()
//----------------------------------------
Gate()
{
	PutSprite("_castlegateshade", x, y, 1, 0, 255, 255, 255, 100);
	if (isOpen("this"))
	{
		// Create a collsion rectangle around the whole door
		ClearCollisionRect("this", 0);
		SetInteractingFlag("this", false);
	}
	else
	{
		// Create a solid collsion rectangle around the whole door
		SetCollisionRect("this", 0, true, x, y, x + width, y + height);
		ClearCollisionRect("this", 1);
	}
}
	
	