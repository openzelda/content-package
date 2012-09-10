/***********************************************
 * Copyright (c) 2004-2006 Editors
 * Changes:  
 *	08/03/05 [lukex]: New file. based on w_bow#.
 ***********************************************/

#include <animation>
#include <foreign/journey>
#include <counter>
#include <core>


new Anim[4][20];
new PlayerSuit = 1; 
new LastPlayerSuit = 1;
new x;
new y;
main()
{
	if (FirstRun())
	{
		for (new n = 0; n < 4; n++ )
		{
			CreateAnim(24, Anim[n]);
			SetAnimLoop(Anim[n], false);
		}
		SetType("this", weaponType);
		AllocateStrings("this", 2, 100);
		SetString("this", 0, "You can use Throwing Stars now");
		SetString("this", 1, "Throwing Stars");
		SetOwnedFlag("this", 1);
		CreateCounterWithID(0, 100, "tstars");
		// CallFunction("_itemlib", false, "AddItem", "sn", "_itemtstars",  20); 
		IncCounterTarget("tstars", 100);
		SetPlayerSuit(PlayerSuit);
		SetActiveDist("this", -1);
		SetImage("this", "w_tstars");
		printf("Throwing Stars Created");
	}
	SetActiveDist("this", -1);
	if( PlayerSuit != LastPlayerSuit )
		SetPlayerSuit(PlayerSuit);
}

//----------------------------------------
// Name: Init()
//----------------------------------------
public Init()
{
	if ( !GetCounterValue("tstars") )
	{
		PlaySound("_error.wav", 240);
		SetState("player1", standing);
		return -1;	
	}
	else
	{
		IncCounterTarget("tstars", -1);
	}


	// Reset all animations
	for ( new n = 0; n < 4; n++ )
		SetAnimCount(Anim[n], 0);

	// Set the Position and Direction of this entity to match the player's
	x = GetX("player1");
	y = GetY("player1");
	SetX("this", x);
	SetY("this", y);
	SetDirection("this", GetDirection("player1"));
	CreateEntity("w_tstar", x + 4, y, "w_tstar");
	
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
	new xoff[2];            // X and Y offsets for the bow images
	new yoff[2];	
	new sx;
	new sy;
	new AnimCount;

	// Draw the Player animation
	if (isVisible("player1"))
	{
		// Draw the Player
		DrawAnim(Anim[dir], x, y, y + height);
		AnimCount = GetAnimCount(Anim[dir]);



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
