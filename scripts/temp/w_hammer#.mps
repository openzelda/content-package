/* This file is Public Domain */
/***********************************************************************
 * _hammer# Entity Script
 * 
 * Author: Satanman
 * Date:   30th July 2002
 *
 * Desc:   An oversized mallet, reminiscent of MrZ (AGN forums)
 *
 * Usage:  This script will be called by the player entity when it wants
 *         to use this weapon, before it calls this script it will enter
 *         the 'using' state and stay there until this script tells it
 *         to finish 
 *
 * Sprites: _WeaponSheet1.spt
 *         
 ***********************************************************************/
#include <foreign/journey>
#include <core>
#include <float>
#include <animation>

//==================================
//   Global Data
//==================================
// Create strings to store the Idents of each animation
new hammern[20];
new hammere[20];
new hammers[20];
new hammerw[20];
new swordn[20];
new sworde[20];
new swords[20];
new swordw[20];
new hitfloor;
new param;
new starxy[4];
new float: startimer = 0.00;
new float: alpharot = 0.00;
new alpharound = 0;
new PlayerSuit = 1; 			// Player suit (Mar. 03)
new LastPlayerSuit = 1;




//----------------------------------------
// Name: main()
//----------------------------------------
main()
{
	if (FirstRun())
	{
		param = GetParam("this");
		// Set this entity's basic type
		SetType("this", weaponType);
		SetOwnedFlag("this", true);		// this hammer is always avaiable on the menu
      
		// Create 2 string for the weapons descriptions
		AllocateStrings("this", 2, 64);	
		if (param == '1')
		{
			SetDamage("this", 100);
			SetImage("this", "w_hammer1");
			SetString("this", 0, "You got the magic hammer!"); 	// For Chests
			SetString("this", 1, "Magic Hammer"); 				// For menu
		}
		// Create the Animations
		CreateAnim(8, hammern);
		CreateAnim(8, hammere);
		CreateAnim(8, hammers); 
		CreateAnim(8, hammerw);
		CreateAnim(12, swordn);
		CreateAnim(12, sworde);
		CreateAnim(12, swords); 
		CreateAnim(12, swordw);

		// make sure the animations dont loop back to the start, we only want
		// the swiping animation once.
		SetAnimLoop(hammern, false);
		SetAnimLoop(hammere, false);
		SetAnimLoop(hammers, false);
		SetAnimLoop(hammerw, false);
		SetAnimLoop(swordn, false);
		SetAnimLoop(sworde, false);
		SetAnimLoop(swords, false);
		SetAnimLoop(swordw, false);
		
		if (param == '1')
		{
			// Add Frames to all Animations
			AddAnimframe(hammern, 2, -10, "w_hammernorth1");
			AddAnimframe(hammern, 2, -8, "w_hammernorth2");
			AddAnimframe(hammern, 2, -8, "w_hammernorth2");
			AddAnimframe(hammern, 2, -8, "w_hammernorth2");
	
			AddAnimframe(hammere, 8, -8, "w_hammereast1");
			AddAnimframe(hammere, 10, -6, "w_hammereast2");
			AddAnimframe(hammere, 12, 4, "w_hammereast3");
			AddAnimframe(hammere, 12, 4, "w_hammereast3");

			AddAnimframe(hammers, 8, -4, "w_hammernorth1");
			AddAnimframe(hammers, 8, 0, "w_hammersouth2");
			AddAnimframe(hammers, 8, 4, "w_hammersouth3");
			AddAnimframe(hammers, 8, 4, "w_hammersouth3");
	
			AddAnimframe(hammerw, 4, -8, "w_hammereast1");
			AddAnimframe(hammerw, -10, -6, "w_hammerwest2");
			AddAnimframe(hammerw, -12, 4, "w_hammerwest3");
			AddAnimframe(hammerw, -12, 4, "w_hammerwest3");
		}
		SetPlayerSuit(PlayerSuit);
		printf("Hammer Created");
	}	
}


//----------------------------------------
// Name: Init()
//----------------------------------------
public Init()
{
	/* This function should be called by the Player script every
		time just before the weapon is used, it resets all animations
		and makes sure everything is ready to go */

	// Reset all animations
	starxy = { 0, 0, 0, 0};
	SetAnimCount(hammern, 0);
	SetAnimCount(hammere, 0);
	SetAnimCount(hammers, 0);
	SetAnimCount(hammerw, 0);
	SetAnimCount(swordn, 0);
	SetAnimCount(sworde, 0);
	SetAnimCount(swords, 0);
	SetAnimCount(swordw, 0);
	hitfloor = false;
	startimer = 0.00;
	alpharot = 0.00;
	
	// Set the Position and Direction of this entity to match the player's
	SetX("this", GetX("player1"));
	SetY("this", GetY("player1"));
	SetDirection("this", GetDirection("player1"));
	PlaySound("w_hammer.wav",240);
	
	if ( LastPlayerSuit != PlayerSuit )
 		SetPlayerSuit(PlayerSuit);
}


//----------------------------------------
// Name: DrawWeapon()
//----------------------------------------
public DrawWeapon()
{
	new playeranim[20];
	new anim[20];
	new currentimg[20];
	new swordimages[6];	
	new AnimCount;
	new x = GetX("this");
	new y = GetY("this");
	new dir = GetDirection("this");

	// ====================================================
	/* Setup the player animation and the hammer image based
		on the direction this entity is facing */
	// ====================================================
	if ( dir == north)
	{
		playeranim = swordn;
		anim = hammern;
	}else if ( dir == east)
	{
		playeranim = sworde;
		anim = hammere;
	}else if ( dir == south)
	{
		playeranim = swords;
		anim = hammers;
	}else if ( dir == west)
	{
		playeranim = swordw;
		anim = hammerw;
	}
	// Get the width and height of the Animation
	new width  = GetAnimWidth(playeranim);
	new height = GetAnimHeight(playeranim);
	new sx;
	new sy;
   
	// ========================================================
	// Draw the Player Animation and the hammer image seperately
	// ========================================================
	if (isVisible("player1"))
	{
		// Draw the Player
		DrawAnim(playeranim, x, y, y + height);
		AnimCount = GetAnimCount(playeranim);

		// Draw the image of the hammer
		//sx = x + xoff[AnimCount];
		//sy = y + yoff[AnimCount] - 9;
		//PutSprite(simage[swordimages[AnimCount]-1], 
		//                                   sx, sy, y + height);
		if (dir != north)
			DrawAnim(anim, x, y, y + height);
		else
			DrawAnim(anim, x, y, y);
			
		// Draw the Player's shadow
		PutSprite("shadow1", x, y, 2);
		
		if (AnimCount == 3)
			HitGround(dir);
	}
	else
		IncrementAnim(playeranim);

	// ========================================================================
	/* Set the Collision Rectangle for the hammer. I'm pretty lazy, so 
		it's just a square in front of the player */
	// ========================================================================
	if (dir == north)
		SetCollisionRect("this", 0, false, x + 4, y, x + 8, y - 8);
	else if (dir == east)
		SetCollisionRect("this", 0, false, x + width, y + 8, x + width + 8, y + 12);
	else if (dir == south)
		SetCollisionRect("this", 0, false, x + 4, y + height, x + 8, y + height + 8);
	else if (dir == west)
		SetCollisionRect("this", 0, false, x - 8, y + 8, x, y + 12);


	// Check to see if the hammer hits anything
	CheckForHit();
   
	// Check if the weapon animation is over
	if (FinishedAnim(anim))
	{
		// Return control back to player entity
		SetState("player1", standing);
	}
}


//----------------------------------------
// Name: CheckForHit()
//----------------------------------------
CheckForHit()
{
	new temp[20];

	// Go to the start of the Entity List
	StartEntity(80);
   
	// Loop through all the entities within a certain distance
	do
	{
		ToString(GetCurrentEntity(), temp);

		if (isActive(temp) && GetType(temp) != playerType )
		{
			// Check if the hammer collides with the current entity
			if (Collide("this", temp))
			{
				CallFunction(temp, false, "HitByWeapon", "snnn", \
					"hammer", GetDamage("this"), GetX("this"), GetY("this"));
			}
		}
	}while( NextEntity() )
}

//----------------------------------------
// Name: HitGround(thisdir)
//----------------------------------------
HitGround(thisdir)
{
	if (alpharot < 255.00)
	{
		new x = GetX("this");
		new y = GetY("this");
		if (hitfloor == false)
		{
			PlaySound("_bombplaced.wav", 240); //the sound of a thousand uses!
			hitfloor = true;
			if (thisdir == north)
				starxy = {6, 0, 6, 0};
			else if (thisdir == east)
				starxy = {20, 8, 20, 8};
			else if (thisdir == south)
				starxy = {12, 18, 12, 18};
			else if (thisdir == west)
				starxy = {-12, 8, -12, 8};
		}
		
		if (startimer >= 0.02)
		{
			starxy[0] -= 1;
			starxy[1] -= 1;
			starxy[2] += 1;
			starxy[3] -= 1;
			startimer = 0.00;
		}
		
		startimer +=  GetTimeDelta();
			alpharot += 512 * GetTimeDelta();
		
		alpharound = floatround(alpharot);
		
		PutSprite("star1", x + starxy[0], y + starxy[1], 999999, 0, 255, 255, 255, 255 - alpharound, alpharound);
		PutSprite("star1", x + starxy[2], y + starxy[3], 999999, 0, 255, 255, 255, 255 - alpharound, alpharound);
	}
}
//-----------------------------------------------------
// Name: SetPlayerSuit()
// Desc: Changes the players Animation
//-----------------------------------------------------
public ChangePlayerSuit(ChangeTo) {
	PlayerSuit = ChangeTo;
}

public GetPlayerSuit() {
	return PlayerSuit;
}

SetPlayerSuit(NewPlayerSuit)
{
	LastPlayerSuit = NewPlayerSuit;
	DeleteAnim(swordn);
	DeleteAnim(sworde);
	DeleteAnim(swords); 
	DeleteAnim(swordw);
		
	CreateAnim(12, swordn);
	CreateAnim(12, sworde);
	CreateAnim(12, swords); 
	CreateAnim(12, swordw);
		
	if (NewPlayerSuit == 1)
	{
		AddAnimframe(swordn, 0, -9, "__swdn1");
		AddAnimframe(swordn, 0, -9, "__swdn2");
		AddAnimframe(swordn, 0, -13, "__swdn3");
		AddAnimframe(swordn, 0, -9, "__swdn4");

		AddAnimframe(sworde, 0, -9, "__swde1");
		AddAnimframe(sworde, 0, -9, "__swde2");
		AddAnimframe(sworde, 0, -9, "__swde3");
		AddAnimframe(sworde, 0, -9, "__swde4");

		AddAnimframe(swords, 0, -9, "__swds1");
		AddAnimframe(swords, 0, -9, "__swds2");
		AddAnimframe(swords, 0, -9, "__swds2");
		AddAnimframe(swords, 0, -9, "__swds3");

		AddAnimframe(swordw, 0, -9, "__swdw1");
		AddAnimframe(swordw, 0, -9, "__swdw2");
		AddAnimframe(swordw, 0, -9, "__swdw3");
		AddAnimframe(swordw, -4, -9, "__swdw4");	
	}
	else if (NewPlayerSuit == 2)
	{
		AddAnimframe(swordn, 0, -9, "__twdn1");
		AddAnimframe(swordn, 0, -9, "__twdn2");
		AddAnimframe(swordn, 0, -13, "__twdn3");
		AddAnimframe(swordn, 0, -9, "__twdn4");

		AddAnimframe(sworde, 0, -9, "__twde1");
		AddAnimframe(sworde, 0, -9, "__twde2");
		AddAnimframe(sworde, 0, -9, "__twde3");
		AddAnimframe(sworde, 0, -9, "__twde4");

		AddAnimframe(swords, 0, -9, "__twds1");
		AddAnimframe(swords, 0, -9, "__twds2");
		AddAnimframe(swords, 0, -9, "__twds2");
		AddAnimframe(swords, 0, -9, "__twds3");

		AddAnimframe(swordw, 0, -9, "__twdw1");
		AddAnimframe(swordw, 0, -9, "__twdw2");
		AddAnimframe(swordw, 0, -9, "__twdw3");
		AddAnimframe(swordw, -4, -9, "__twdw4");	
	}
		else if (NewPlayerSuit == 3)
	{
		AddAnimframe(swordn, 0, -9, "__uwdn1");
		AddAnimframe(swordn, 0, -9, "__uwdn2");
		AddAnimframe(swordn, 0, -13, "__uwdn3");
		AddAnimframe(swordn, 0, -9, "__uwdn4");

		AddAnimframe(sworde, 0, -9, "__uwde1");
		AddAnimframe(sworde, 0, -9, "__uwde2");
		AddAnimframe(sworde, 0, -9, "__uwde3");
		AddAnimframe(sworde, 0, -9, "__uwde4");

		AddAnimframe(swords, 0, -9, "__uwds1");
		AddAnimframe(swords, 0, -9, "__uwds2");
		AddAnimframe(swords, 0, -9, "__uwds2");
		AddAnimframe(swords, 0, -9, "__uwds3");

		AddAnimframe(swordw, 0, -9, "__uwdw1");
		AddAnimframe(swordw, 0, -9, "__uwdw2");
		AddAnimframe(swordw, 0, -9, "__uwdw3");
		AddAnimframe(swordw, -4, -9, "__uwdw4");	
	}
}
