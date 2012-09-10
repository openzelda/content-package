/***********************************************
 * Copyright (c) 2002-2005 Editors
 * Changes:  
 *	23/06/02 [GD]: New file.
 *	27/08/04 [Luke]: Merged Ice & Fire Rods into one entity
 ***********************************************/
#include <animation>
#include <foreign/journey>
#include <counter>
#include <core>

new MagicNeeded = 5;	// Magic needed to fire the rod
new PlayerSuit = 1; 
new LastPlayerSuit = 1;
new param;
new paramNumber;
new createdentity[2][] = {"_fireball1","_iceblast1"};
new createdsounds[2][] = {"_fireball.wav","_iceball.wav"};
new wimageprefix[2][] = {"_firerod","_icerod"};
// Create 4 strings to store the Identifiers of the Player animations for each direction
new Anim[4][20];

// Create an array of strings to hold the names of all the rod sprites
new wimage[8][] = {"_firerod1", "_firerod2", "_firerod3", "_firerod4", "_firerod5", "_firerod6", 
                   "_firerod7", "_firerod8" };
                 

main()
{
	if (FirstRun())
	{
		new n;
		
		// Set this entity's basic type
     	SetType("this", weaponType);
     	param = GetParam("this");
		// Create 2 string for the weapons descriptions
      AllocateStrings("this", 2, 128);	
      	
      if (param == 'f')
      {	
      	SetString("this", 0,  "You got the Fire Rod!`This rod commands the red fire! But watch your Magic Meter!");		// For Chests
      	SetString("this", 1,  "Fire Rod");					// For Menu
      	SetImage("this", "_firerodicon");
      	paramNumber = 0;
	printf("Fire rod Created");
      } 
      else if (param == 'i')
      {
      	SetString("this", 0,  "You got the Ice Rod!`Its chill magic blasts the air! But watch your Magic Meter!");		// For Chests
      	SetString("this", 1,  "Ice Rod");					// For Menu
      	SetImage("this", "_icerodicon");
      	paramNumber = 1;
	printf("Ice rod Created");
      }
      	
      SetOwnedFlag("this", 1);
      // Create the Animations
      for ( n = 0; n < 4; n++ )
      {
      	CreateAnim(24, Anim[n]);
      	SetAnimLoop(Anim[n], false);
      }
		SetPlayerSuit(PlayerSuit);

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
	   
	// Reset all animations
	for ( n = 0; n < 4; n++ )
    	SetAnimCount(Anim[n], 0);
		
    // Set the Position and Direction of this entity to match the player's
    SetX("this", GetX("player1"));
    SetY("this", GetY("player1"));
    SetDirection("this", GetDirection("player1"));
    PlaySound(createdsounds[paramNumber]);
  
    CreateSubentity();
}

//----------------------------------------
// Name: CreateSubentity()
//----------------------------------------
CreateSubentity()
{
	new entity[20];
	new x = GetX("player1");
	new y = GetY("player1");
	new dir = GetDirection("player1");
	
	if ( dir == north )
	{
		x = GetX("player1") - 2;
		y = GetY("player1") - 8;
	}
	else if ( dir == east )
	{
		x = GetX("player1") + 8;
	}
	else if ( dir == south )
	{
		x = GetX("player1") + 10;
		y = GetY("player1") + 8;
	}
	else if ( dir == west )
	{
		x = GetX("player1") - 8;
	}
	
	// Create a Firball entity to fly from this rod
    CreateEntity(createdentity[paramNumber], x, y, entity);
    SetDirection(entity, dir);
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
    new rodImages[6];
    new xoff[6];            // X and Y offsets for the rods images
    new yoff[6];	
    new sx;
    new sy;
    new AnimCount;
    new depth = y + height;
    
    if ( dir == north)
    {
      	rodImages = {6,0,0,0,0,0};
      	xoff = {-2, -2, -2, -2, -2, -2};
      	yoff = {-7, -3, -3,  2,  2,  2};
      	depth = y;
    }
    else if ( dir == east)
    {
      	rodImages = {0,1,1,3,3,3};
      	xoff = { 8,  13, 13, 14, 14, 14};
      	yoff = {-3,   2,  2, 12, 12, 12};    
    }
    else if ( dir == south)
    {
    	rodImages = {0,7, 7, 2, 2,2};
      	xoff = { 10,  10,  10,  8,  8,  8};
      	yoff = { -5,  14,  14, 16, 16, 16};    
      
    }
    else if ( dir == west)
    {
       	rodImages = {0,5, 5,4,4,4};
      	xoff = { 0,  -13, -13, -14, -14, -14};
      	yoff = {-3,    2,   2,  12,  12,  12};    
    }

	// Draw the Player animation
	if (isVisible("player1"))
    {
       // Draw the Player
       DrawAnim(Anim[dir], x, y, y + height);
       AnimCount = GetAnimCount(Anim[dir]);

       // Draw the image of the weapon
       sx = x + xoff[AnimCount];
       sy = y + yoff[AnimCount] - 9;
		
		new temp1[20];
		new temp2[20];
		
		ToString((rodImages[AnimCount] + 1), temp2);
		strcpy(temp1, wimageprefix[paramNumber]);
		strcat( temp1, temp2);
		PutSprite(wimage[rodImages[AnimCount]], sx, sy, depth);

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
		SetAnimLoop(Anim[n], false);
	}
		
	if (NewPlayerSuit == 1)
	{
      	// Add Frames to player Animations
      	AddAnimframe(Anim[0], 0, -9, "__swdn6");
      	AddAnimframe(Anim[0], 0, -9, "__swdn7");
      	AddAnimframe(Anim[0], 0, -9, "__swdn7");
      	AddAnimframe(Anim[0], 0, -9, "__swdn7");
      	AddAnimframe(Anim[0], 0, -9, "__swdn7");
      	AddAnimframe(Anim[0], 0, -9, "__swdn7");
      	
      	AddAnimframe(Anim[1], 0, -9, "__swde6");
      	AddAnimframe(Anim[1], 2, -9, "__swde3");
      	AddAnimframe(Anim[1], 2, -9, "__swde3");
      	AddAnimframe(Anim[1], 1, -9, "__swde3");
      	AddAnimframe(Anim[1], 1, -9, "__swde3");
      	AddAnimframe(Anim[1], 1, -9, "__swde3");

      	AddAnimframe(Anim[2], 0, -9, "__swds6");
      	AddAnimframe(Anim[2], 0, -9, "__swds3");
      	AddAnimframe(Anim[2], 0, -9, "__swds3");
      	AddAnimframe(Anim[2], 0, -9, "__swds3");
      	AddAnimframe(Anim[2], 0, -9, "__swds3");
      	AddAnimframe(Anim[2], 0, -9, "__swds3");
    
      	AddAnimframe(Anim[3], 0, -9, "__swdw6");
      	AddAnimframe(Anim[3], -2, -9, "__swdw3");
      	AddAnimframe(Anim[3], -2, -9, "__swdw3");
      	AddAnimframe(Anim[3], -1, -9, "__swdw3");
      	AddAnimframe(Anim[3], -1, -9, "__swdw3");
      	AddAnimframe(Anim[3], -1, -9, "__swdw3");
	}
	else if (NewPlayerSuit == 2)
	{
      	// Add Frames to player Animations
      	AddAnimframe(Anim[0], 0, -9, "__twdn6");
      	AddAnimframe(Anim[0], 0, -9, "__twdn7");
      	AddAnimframe(Anim[0], 0, -9, "__twdn7");
      	AddAnimframe(Anim[0], 0, -9, "__twdn7");
      	AddAnimframe(Anim[0], 0, -9, "__twdn7");
      	AddAnimframe(Anim[0], 0, -9, "__twdn7");
      	
      	AddAnimframe(Anim[1], 0, -9, "__twde6");
      	AddAnimframe(Anim[1], 2, -9, "__twde3");
      	AddAnimframe(Anim[1], 2, -9, "__twde3");
      	AddAnimframe(Anim[1], 1, -9, "__twde3");
      	AddAnimframe(Anim[1], 1, -9, "__twde3");
      	AddAnimframe(Anim[1], 1, -9, "__twde3");

      	AddAnimframe(Anim[2], 0, -9, "__twds6");
      	AddAnimframe(Anim[2], 0, -9, "__twds3");
      	AddAnimframe(Anim[2], 0, -9, "__twds3");
      	AddAnimframe(Anim[2], 0, -9, "__twds3");
      	AddAnimframe(Anim[2], 0, -9, "__twds3");
      	AddAnimframe(Anim[2], 0, -9, "__twds3");
    
      	AddAnimframe(Anim[3], 0, -9, "__twdw6");
      	AddAnimframe(Anim[3], -2, -9, "__twdw3");
      	AddAnimframe(Anim[3], -2, -9, "__twdw3");
      	AddAnimframe(Anim[3], -1, -9, "__twdw3");
      	AddAnimframe(Anim[3], -1, -9, "__twdw3");
      	AddAnimframe(Anim[3], -1, -9, "__twdw3");

	}
	else if (NewPlayerSuit == 3)
	{
      	// Add Frames to player Animations
      	AddAnimframe(Anim[0], 0, -9, "__uwdn6");
      	AddAnimframe(Anim[0], 0, -9, "__uwdn7");
      	AddAnimframe(Anim[0], 0, -9, "__uwdn7");
      	AddAnimframe(Anim[0], 0, -9, "__uwdn7");
      	AddAnimframe(Anim[0], 0, -9, "__uwdn7");
      	AddAnimframe(Anim[0], 0, -9, "__uwdn7");
      	
      	AddAnimframe(Anim[1], 0, -9, "__uwde6");
      	AddAnimframe(Anim[1], 2, -9, "__uwde3");
      	AddAnimframe(Anim[1], 2, -9, "__uwde3");
      	AddAnimframe(Anim[1], 1, -9, "__uwde3");
      	AddAnimframe(Anim[1], 1, -9, "__uwde3");
      	AddAnimframe(Anim[1], 1, -9, "__uwde3");

      	AddAnimframe(Anim[2], 0, -9, "__uwds6");
      	AddAnimframe(Anim[2], 0, -9, "__uwds3");
      	AddAnimframe(Anim[2], 0, -9, "__uwds3");
      	AddAnimframe(Anim[2], 0, -9, "__uwds3");
      	AddAnimframe(Anim[2], 0, -9, "__uwds3");
      	AddAnimframe(Anim[2], 0, -9, "__uwds3");
    
      	AddAnimframe(Anim[3], 0, -9, "__uwdw6");
      	AddAnimframe(Anim[3], -2, -9, "__uwdw3");
      	AddAnimframe(Anim[3], -2, -9, "__uwdw3");
      	AddAnimframe(Anim[3], -1, -9, "__uwdw3");
      	AddAnimframe(Anim[3], -1, -9, "__uwdw3");
      	AddAnimframe(Anim[3], -1, -9, "__uwdw3");
	}
}