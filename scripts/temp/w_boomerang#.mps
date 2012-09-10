/***********************************************
 * Copyright (c) 2002-2005 Editors
 * Changes:  
 *	02/07/02 [GD]: New file.
  *	06/06/05 [lukex]: Updated boomerang names.
 ***********************************************/

#include <animation>
#include <foreign/journey>
#include <counter>

new MagicNeeded = 0;	// Magic needed to fire the weapon
new param;

// Create 4 strings to store the Identifiers of the Player animations for each direction
new Anim[4][20];
new wimage[20];					// holds the boomerang image
new CreatedWeapon = false;
new PlayerSuit = 1; 			// Player suit (Mar. 03)
new LastPlayerSuit = 1;
main()
{
	if (FirstRun())
	{
		new n;
		
		// Set this entity's basic type
		SetType("this", weaponType);
			
		// Get the scripts parameter
		param = GetParam("this");
		
		// Create 2 string for the weapons descriptions
		AllocateStrings("this", 2, 256);
		
		if (param == 'r')  // Red Boomerang
		{
			SetString("this", 0,  "You got the boomerang! Give it a try!");		// For Chests
			SetString("this", 1,  "Boomerang");								// For menu
			SetImage("this", "_rboom1");				
			wimage = "_rboom1";
		}
		if (param == 'g')  // Gold Boomerang
		{
			SetString("this", 0,  "You got the Magic Boomerang!`You can throw this faster and farther than your old one!");		// For Chests
			SetString("this", 1,  "Magic Boomerang");						
			SetImage("this", "_gboom1");	
			wimage = "_gboom1";
		}
		if (param == 'b')  // Blue/ice Boomerang
		{
			SetString("this", 0,  "You got the Ice Boomerang!`This magical weapon will freeze solid any enemies it touches! But watch your Magic Meter it uses a lot of magic!");		// For Chests
			SetString("this", 1,  "Ice Boomerang");						
			SetImage("this", "_bboom1");	
			wimage = "_bboom1";
			MagicNeeded = 14;	// Need magic to do this
		}
		
			
		// Create the Animations
		for ( n = 0; n < 4; n++ )
		{
			CreateAnim(24, Anim[n]);
			SetAnimLoop(Anim[n], false);
		}
		SetPlayerSuit(PlayerSuit);
		SetOwnedFlag("this", 1);
	}

	SetActiveDist("this", -1); 
}

//----------------------------------------
// Name: Init()
//----------------------------------------
public Init()
{
	new n;
	/* This function should be called by the Player script every
      time just before the weapon is used, it resets all animations
      and makes sure everything is ready to go */
      
    // if this entities first value is on 1 then we have launched a boomerang
    // before and it hasnt come back yet   
	if ( GetValue("this", 5) == 1)
	{
		
		return -1;
	}
    
	if (MagicNeeded > 0)
    {
	    // Make sure we have enough magic to do this
	    if ( GetCounterValue( "magic" ) < MagicNeeded )
	    {
	    	// Player does have enough magic
	    	PlaySound("_error.wav", 240);
	    	SetState("player1", standing);
	    	return -1;	
	    }
	    else
	    {
	    	// Decrease magic level
	    	IncCounterTarget("magic", -MagicNeeded);	
	    }
    }
	   
	// Reset all animations
	for ( n = 0; n < 4; n++ )
    	SetAnimCount(Anim[n], 0);
		
    // Set the Position and Direction of this entity to match the player's
    SetX("this", GetX("player1"));
    SetY("this", GetY("player1"));
    SetDirection("this", GetDirection("player1"));
    CreatedWeapon = false;
   
}


//----------------------------------------
// Name: CreateBoomerang()
//----------------------------------------
CreateBoomerang()
{
	// Create the actual boomerang entity
	new entity[20];
	new x = GetX("player1");
	new y = GetY("player1");
	new dir = GetDirection("player1");
	new angle;
	new angleAdj = 30;
	
	if ( dir == north )
	{
		x = GetX("player1") - 2;
		y = GetY("player1") - 8;
		angle = 90;
		
		if ( LeftKey())
			angle -= angleAdj;
		if ( RightKey())
			angle += angleAdj;
		
	}
	else if ( dir == east )
	{
		x = GetX("player1") + 8;
		angle = 180;
		
		if ( UpKey())
			angle -= angleAdj;
		if ( DownKey())
			angle += angleAdj;
	}
	else if ( dir == south )
	{
		x = GetX("player1") + 10;
		y = GetY("player1") + 8;
		angle = 270;
		
		if ( LeftKey())
			angle += angleAdj;
		if ( RightKey())
			angle -= angleAdj;
	}
	else if ( dir == west )
	{
		x = GetX("player1") - 8;
		angle = 0;
		
		if ( UpKey())
			angle += angleAdj;
		if ( DownKey())
			angle -= angleAdj;
	}
	
	// Create a boomerang entity
	if (param == 'r')
    	CreateEntity("_boomr", x, y, entity);
    else if (param == 'g')
    	CreateEntity("_boomg", x, y, entity);
    else
    	CreateEntity("_boomb", x, y, entity);
    
    SetDirection(entity, dir);
    SetMoveAngle(entity, angle);
}


//----------------------------------------
// Name: DrawWeapon()
//----------------------------------------
public DrawWeapon()
{
	// Get the Correct Animation
	new dir = GetDirection("this");
	new width  = GetAnimWidth(Anim[dir]);
    new height = GetAnimHeight(Anim[dir]);
    new x = GetX("this");
    new y = GetY("this");
    new xoff;
    new yoff;
    new AnimCount;	
    new sx;
    new sy;
    new rotation;		// Amount to rotate the weapon sprite
       
    if ( dir == north)
    {
      	xoff = -8;
      	yoff = -6;
    }
    else if ( dir == east)
    {
      	xoff = -7;
      	yoff = 0;  
    }
    else if ( dir == south)
    {
    	xoff = 13;
      	yoff = 1;
      	rotation = 270;
    }
    else if ( dir == west)
    {
       	xoff = 10;
      	yoff = 0; 
      	rotation = 270; 
    }

	// Draw the Player animation
	if (isVisible("player1"))
    {
       // Draw the Player
       DrawAnim(Anim[dir], x, y, y + height);
       AnimCount = GetAnimCount(Anim[dir]);

		if ( AnimCount <= 4)
		{
	       	// Draw the image of the weapon
	       	sx = x + xoff;
	       	sy = y + yoff - 9;
	       	PutSprite(wimage, sx, sy, y + height, 0, 255, 255, 255, 255, rotation, 100);
		}
		else
		{
			if (!CreatedWeapon)
			{
				// Make the boomerang weapon
				CreatedWeapon = true;	
				CreateBoomerang();
			}
		}

       	// Draw the Player's shadow
       	PutSprite("shadow1", x, y, 2);
	}
    else
       IncrementAnim(Anim[dir]);
       
       
    // Check if the weapon animation is over
    if (FinishedAnim(Anim[dir]))
    {
       // Return control back to player entity
       SetState("player1", standing);
    }
}
//-----------------------------------------------------
// Name: SetPlayerSuit()
// Desc: Changes the players Animation
//-----------------------------------------------------
public ChangePlayerSuit(ChangeTo) {
	PlayerSuit = ChangeTo;
}


SetPlayerSuit(NewPlayerSuit)
{
	LastPlayerSuit = NewPlayerSuit;
	for (new n = 0; n < 4; n++ )
	{
		DeleteAnim(Anim[n]);
		CreateAnim(24, Anim[n]);
	}
		
	if (NewPlayerSuit == 1)
	{
		// Add Frames to player Animations
		AddAnimframe(Anim[0], 0, -9, "__swdn6");
		AddAnimframe(Anim[0], 0, -9, "__swdn6");
		AddAnimframe(Anim[0], 0, -9, "__swdn6");
		AddAnimframe(Anim[0], 0, -9, "__swdn6");
		AddAnimframe(Anim[0], 0, -9, "__swdn7");
		AddAnimframe(Anim[0], 0, -9, "__swdn7");
		AddAnimframe(Anim[0], 0, -9, "__swdn7");
		
		AddAnimframe(Anim[1], 0, -9, "__swde7");
		AddAnimframe(Anim[1], 0, -9, "__swde7");
		AddAnimframe(Anim[1], 0, -9, "__swde7");
		AddAnimframe(Anim[1], 0, -9, "__swde7");
		AddAnimframe(Anim[1], 1, -9, "__swde3");
		AddAnimframe(Anim[1], 1, -9, "__swde3");
		AddAnimframe(Anim[1], 1, -9, "__swde3");

		AddAnimframe(Anim[2], 0, -9, "__swds6");
		AddAnimframe(Anim[2], 0, -9, "__swds6");
		AddAnimframe(Anim[2], 0, -9, "__swds6");
		AddAnimframe(Anim[2], 0, -9, "__swds6");
		AddAnimframe(Anim[2], 0, -8, "__swds3");
		AddAnimframe(Anim[2], 0, -8, "__swds3");
		AddAnimframe(Anim[2], 0, -8, "__swds3");
	    
		AddAnimframe(Anim[3], 0, -9,  "__swdw7");
		AddAnimframe(Anim[3], 0, -9,  "__swdw7");
		AddAnimframe(Anim[3], 0, -9,  "__swdw7");
		AddAnimframe(Anim[3], 0, -9,  "__swdw7");
		AddAnimframe(Anim[3], -1, -9, "__swdw3");
		AddAnimframe(Anim[3], -1, -9, "__swdw3");
		AddAnimframe(Anim[3], -1, -9, "__swdw3");	
	}
	else if (NewPlayerSuit == 2)
	{
			// Add Frames to player Animations
		AddAnimframe(Anim[0], 0, -9, "__twdn6");
		AddAnimframe(Anim[0], 0, -9, "__twdn6");
		AddAnimframe(Anim[0], 0, -9, "__twdn6");
		AddAnimframe(Anim[0], 0, -9, "__twdn6");
		AddAnimframe(Anim[0], 0, -9, "__twdn7");
		AddAnimframe(Anim[0], 0, -9, "__twdn7");
		AddAnimframe(Anim[0], 0, -9, "__twdn7");
		
		AddAnimframe(Anim[1], 0, -9, "__twde7");
		AddAnimframe(Anim[1], 0, -9, "__twde7");
		AddAnimframe(Anim[1], 0, -9, "__twde7");
		AddAnimframe(Anim[1], 0, -9, "__twde7");
		AddAnimframe(Anim[1], 1, -9, "__twde3");
		AddAnimframe(Anim[1], 1, -9, "__twde3");
		AddAnimframe(Anim[1], 1, -9, "__twde3");

		AddAnimframe(Anim[2], 0, -9, "__twds6");
		AddAnimframe(Anim[2], 0, -9, "__twds6");
		AddAnimframe(Anim[2], 0, -9, "__twds6");
		AddAnimframe(Anim[2], 0, -9, "__twds6");
		AddAnimframe(Anim[2], 0, -8, "__twds3");
		AddAnimframe(Anim[2], 0, -8, "__twds3");
		AddAnimframe(Anim[2], 0, -8, "__twds3");
	    
		AddAnimframe(Anim[3], 0, -9,  "__twdw7");
		AddAnimframe(Anim[3], 0, -9,  "__twdw7");
		AddAnimframe(Anim[3], 0, -9,  "__twdw7");
		AddAnimframe(Anim[3], 0, -9,  "__twdw7");
		AddAnimframe(Anim[3], -1, -9, "__twdw3");
		AddAnimframe(Anim[3], -1, -9, "__twdw3");
		AddAnimframe(Anim[3], -1, -9, "__twdw3");

	}
	else if (NewPlayerSuit == 3)
	{
		// Add Frames to player Animations
		AddAnimframe(Anim[0], 0, -9, "__uwdn6");
		AddAnimframe(Anim[0], 0, -9, "__uwdn6");
		AddAnimframe(Anim[0], 0, -9, "__uwdn6");
		AddAnimframe(Anim[0], 0, -9, "__uwdn6");
		AddAnimframe(Anim[0], 0, -9, "__uwdn7");
		AddAnimframe(Anim[0], 0, -9, "__uwdn7");
		AddAnimframe(Anim[0], 0, -9, "__uwdn7");
		
		AddAnimframe(Anim[1], 0, -9, "__uwde7");
		AddAnimframe(Anim[1], 0, -9, "__uwde7");
		AddAnimframe(Anim[1], 0, -9, "__uwde7");
		AddAnimframe(Anim[1], 0, -9, "__uwde7");
		AddAnimframe(Anim[1], 1, -9, "__uwde3");
		AddAnimframe(Anim[1], 1, -9, "__uwde3");
		AddAnimframe(Anim[1], 1, -9, "__uwde3");

		AddAnimframe(Anim[2], 0, -9, "__uwds6");
		AddAnimframe(Anim[2], 0, -9, "__uwds6");
		AddAnimframe(Anim[2], 0, -9, "__uwds6");
		AddAnimframe(Anim[2], 0, -9, "__uwds6");
		AddAnimframe(Anim[2], 0, -8, "__uwds3");
		AddAnimframe(Anim[2], 0, -8, "__uwds3");
		AddAnimframe(Anim[2], 0, -8, "__uwds3");
	    
		AddAnimframe(Anim[3], 0, -9,  "__uwdw7");
		AddAnimframe(Anim[3], 0, -9,  "__uwdw7");
		AddAnimframe(Anim[3], 0, -9,  "__uwdw7");
		AddAnimframe(Anim[3], 0, -9,  "__uwdw7");
		AddAnimframe(Anim[3], -1, -9, "__uwdw3");
		AddAnimframe(Anim[3], -1, -9, "__uwdw3");
		AddAnimframe(Anim[3], -1, -9, "__uwdw3");
	}
}
