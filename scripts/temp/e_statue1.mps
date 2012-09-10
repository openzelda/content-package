/***********************************************
 * Copyright (c) 2002-2005 Editors
 * Changes:  
 *	01/07/2002 [lukex]: New file.
 ***********************************************/

/*************************************************************************
 * e_statue1.zes Entity Script
 * 
 * Author: GD
 * License: GPL
 * Date:   1 July 2002
 *
 * Desc:   An Enemy Script for  a statue which comes to life
 *		   when you get near it and hops around after you.
 *
 *         NOTE: This Script REQUIRES the enemy library entity: _enemylib
 *         to be included in the project.
 *
 * Usage:  The Armos' active flag is set to true whenever the player gets close
 *			to them and makes then wake up.
 *
 * Sprites: _EnemySheet1.spt
 *         
 ************************************************************************/
#include <foreign/journey>
#include <animation>
#include <float>
#include <core>

//   Global Data
new MainImage[20] = "e_statue1";  // Main Sprite for the enemy
new DeadAnim[20];	     		// String holds animation identifier of death animation
new FallAnim[20];	     		// String holds animation identifier of falling animation
new LastImage[20];       		// holds sprite code of the last drawn image
new float: StunCount;
new float: HitCount;	 		// Counter used when the enemy has been hit
new adj = 4;		     		// Collision rectangle adjustment value

// Variables used for bouncing
new float: BounceVelocity = 80.00;
new float: BounceAmount   = 1.00;
new float: gravity = 700.00;
new float: AwakenCount = 0.00;
new Awakened = false;

//----------------------------------------
// Name: main()
//----------------------------------------
main()
{
	if (FirstRun())
	{
		LastImage = MainImage;
		
		// Create the Death Animation using the enemy library - nmelib
		CreateAnim(8, DeadAnim);
		CallFunction("_enemylib", true, "CreateDeathAnim", "s", DeadAnim );
		
		// Create the Falling Animation using the enemy library
		CreateAnim(8, FallAnim); 
		CallFunction("_enemylib", true, "CreateFallAnim", "s", FallAnim );
		
		// Set some general parameters
		SetActiveDist("this", 320);
		SetType("this", enemyType);
		SetSpeed( "this", 45 );   
		SetDamage("this", 50);
		SetHealth("this", 200);
		SetMaxHealth("this", 200);
		SetActiveFlag("this", false);
	}
	
	if (isDead("this"))
		return;
	
	// Check for a collision with the player
	CallFunction("_enemylib", true, "CheckForPlayer", "NULL");
	
	// Call a function for the enemy depending on its state
	switch( GetState("this") )
	{
		case standing:
			Walk();
		case walking:
			Walk();
		case hit:
			Hit();
		case dying:
			Die();
		case falling:
			CallFunction("_enemylib", true, "Fall", "snn", FallAnim, GetWidth("_tentacle1"), GetHeight("_tentacle1"));
		case stunned:
			Stunned();
		case frozen:
			Freeze();
	}
		
	// Check for holes in the ground
	CallFunction("_enemylib", true, "CheckForHoles", "s", FallAnim);
}

//----------------------------------------
// Name: Walk()
//----------------------------------------
Walk()
{	
	// If the enemy has not yet been awakened then just wait for the player
	if (!Awakened)
	{
		WaitForPlayer();
		return;
	}
		
	// Get the width and height of the Current animation
	new width  = GetWidth(MainImage);
	new height = GetHeight(MainImage);
	SetState("this", walking);
	
	// Move the Enemy
	if (GetPauseLevel() == 0)
	{	
		// Decrease the bounce velocity
		BounceVelocity -= (gravity * GetTimeDelta());
		BounceAmount += (BounceVelocity * GetTimeDelta());
		
		// Check if the enemy hits the floor yet after bouncing
		if ( BounceAmount <= 0 )
		{
			// Start a new bounce
			BounceAmount = 1.00;
			BounceVelocity = 80.00;
		}
		
		// We wanna walk towards the player
		SetMoveAngle("this", CalculateAngle(GetX("this"), GetY("this"), GetX("player1"), GetY("player1") ));

		// Check for Collisions - if there are none then move the enemy
		if (!AngleCollide("this", 6, 5, 240, true, width / 2, 24))
			AngleMove("this");
	}
	
	// Draw the enemy
	new x = GetX("this");
	new y = GetY("this");
	if (isVisible("this"))
	{
		PutSprite(MainImage, x, y - floatround(BounceAmount), y + height, 0, 255, 160, 160);
		PutSprite("shadow1", (x + width / 2) - 8, y + height - 15, 2);
	}
	
	// Set a collision rectangle around the Enemy
	SetCollisionRect("this", 0, false, x + adj, y + 8 + adj, x + width - adj, y + height - adj);
}

//----------------------------------------
// Name: Stand()
//----------------------------------------
Stand( justDraw )
{
	// Get the width and height of the Current animation
	new width  = GetWidth(MainImage);
	new height = GetHeight(MainImage);
	new x = GetX("this");
	new y = GetY("this");
	
	// Draw the enemy and its shadow
	if (isVisible("this"))
	{
		PutSprite(MainImage, x, y - floatround(BounceAmount), y + height);
		PutSprite("shadow1", (x + width / 2) - 8, y + height - 16, 2);
	}
	
	// Set a collision rectangle around the Enemy
	SetCollisionRect("this", 0, false, x + adj, y + 8 + adj, x + width - adj, y + height - adj);
}

//----------------------------------------
// Name: WaitForPlayer()
//----------------------------------------
WaitForPlayer()
{
	// Check if the enemy is waking up
	if ( AwakenCount != 0.00)
	{
		Awaken();
		return;
	}
		
	// Just stand and wait
	BounceAmount = 1.00;
	Stand( 1 );
	
	// Check if the player is a certain distance away
	new px = GetX("player1");
	new py = GetY("player1");
	new x  = GetX("this") + 8;
	new y  = GetY("this") + 8;
	new detect = 35;
		
	// Check the player is Near enough
	if ( px >= x - detect && px <= x + detect)
	{
		if ( py >= y - detect && py <= y + detect)
		{
			// The player is close enough - start moving
			AwakenCount = 1.00;
			SetActiveFlag("this", true);
		}
	}
}

//----------------------------------------
// Name: Awaken()
//----------------------------------------
Awaken()
{
	new colors[5][3] = { {19,125,19}, {253,211,65}, {225,88,5}, {32,211,238}, {238,32,32} };
	
	// If the awaken count gets too high then start moving around
	AwakenCount += 1 * GetTimeDelta();
	if ( AwakenCount > 2 )
	{
		AwakenCount = 0.00;
		Awakened = true;
	}
	
	// Draw the enemy in a standing position, draw it different colours
	new x = GetX("this");
	new y = GetY("this");
	new width  = GetWidth(MainImage);
	new height = GetHeight(MainImage);
	
	if (isVisible("this"))
	{
		PutSprite(MainImage, x, y, y + height, 0, colors[ floatround(AwakenCount * 20.0) % 5 ][0], \
		                           			 	  colors[ floatround(AwakenCount * 20.0) % 5 ][1], \
		                           			 	  colors[ floatround(AwakenCount * 20.0) % 5 ][2], 255, 0, 100);
		PutSprite("shadow1", (x + width / 2) - 8, y + height - 16, 2);
	}
}

//----------------------------------------
// Name: HitByWeapon(wtype[], damage, x, y)
//----------------------------------------
public HitByWeapon(wtype[], damage, x, y)
{
	if (!Awakened)
		return;
		
	new state = GetState("this");
	if (state == hit || state == dying || state == burning)
		return;
		
	// Check if this enemy was hit by a weapon that can stun
	if ( !strcmp( wtype, "stun" ) && state != stunned && state != frozen)
	{
		StunCount = float(damage);
		SetState("this", stunned);
		return;
	}
	
	// Check if this enemy was hit by a fire weapon
	if ( !strcmp( wtype, "fire" ) )
	{
		// fire attacks harm armos a lot - crank up the damage
		// but go into a hit state instead of a burning state
		damage = 200;
	}
	
	// Check if this enemy was hit by an ice weapon
	if ( !strcmp( wtype, "ice" ) )
	{
		// Put this enemy on ice
		CallFunction("_enemylib", true, "BeginFreeze", "s", LastImage);
		return;
	}
	
	HitCount = 0.00;
	CallFunction("_enemylib", true, "BeginHit", "nnn", damage, x, y );
}

//----------------------------------------
// Name: Hit()
//----------------------------------------
Hit()
{
	new colors[5][3] = { {19,125,19}, {253,211,65}, {225,88,5}, {32,211,238}, {238,32,32} };
	new width  = GetWidth(MainImage);
	new height = GetHeight(MainImage);
	
	// Move the enemy if the game is completely unpaused
	if (GetPauseLevel() == 0)
	{
		AngleMove("this");
		AngleCollide("this", 5, 5, 126, 0, width / 2, height / 2);
	}
	new x = GetX("this");
	new y = GetY("this");
	
	// Draw the enemy with different shades of colour becuase they have been hit
	if (isVisible("this"))
	{
		PutSprite(MainImage, x, y - floatround(BounceAmount), y + height, 0, \
		                                          colors[ floatround(HitCount * 20.0) % 5 ][0], \
		                           			 	  colors[ floatround(HitCount * 20.0) % 5 ][1], \
		                           			 	  colors[ floatround(HitCount * 20.0) % 5 ][2], 255, 0, 100);
		
		PutSprite("shadow1", (x + width / 2) - 8, y + height - 15, 2);
	}
	
	// Check the hit counter, if it goes high enough then end this hit state
	HitCount += GetTimeDelta();
	if (HitCount >= 0.23)
	{
		// Leave the Hit state
		SetState("this", walking); 
		SetSpeedMod("this", 0);
	}
}

//----------------------------------------
// Name: Die()
//----------------------------------------
Die()
{		
	// Draw the enemy standing still
	if (GetAnimCount(DeadAnim) < 5)
		Stand( true );   	
	
	// Overlay the death animation over the enemy
	CallFunction("_enemylib", true, "HandleDying", "ss", DeadAnim, LastImage);   
	SetHealth("this", 0);
	Awakened = false;	// Put the enemy back to sleep
	AwakenCount = 0.00;
	SetActiveFlag("this", false);
}

//----------------------------------------
// Name: Stunned()
//----------------------------------------
Stunned()
{
	// Display the enemy stood still
	Stand( true );
	
	// decrement the Stun counter
	StunCount -= 10 * GetTimeDelta();
	CallFunction("_enemylib", true, "Stunned", "n", floatround(StunCount));
}

//----------------------------------------
// Name: Freeze()
//----------------------------------------
Freeze()
{
	// Draw the enemy in a standing position, but draw them blue
	new x = GetX("this");
	new y = GetY("this");
	new width  = GetWidth(MainImage);
	new height = GetHeight(MainImage);
	BounceAmount = 1.00;
	
	if (isVisible("this"))
	{
		PutSprite(MainImage, x, y, y + height, 0, 100, 100, 255);
		PutSprite("shadow1", (x + width / 2) - 8, y + height - 15, 2);
	}
}