/***********************************************
 * Copyright (c) 2002-2005 Editors
 * Changes:  
 *	01/06/02 [GD]: New file.
 ***********************************************/
#include <foreign/journey>
#include <animation>
#include <float>
#include <core>

//   Global Data
new walks[20];
new DeadAnim[20];	     // String holds animation identifier of death animation
new FallAnim[20];	     // String holds animation identifier of falling animation
new LastImage[20];       // holds sprite code of the last drawn image
new float: StunCount;
new float: HitCount;	 // Counter used when the enemy has been hit
new adj = 2;		     // Collision rectangle adjustment value


//----------------------------------------
// Name: main()
//----------------------------------------
main()
{
	if (FirstRun())
	{
		// Create the animations
		CreateAnim(6, walks);
		
		// Add Frames to the walking animations
		AddAnimframe(walks, 0, 0, "_tentacle1");  // walking south
		AddAnimframe(walks, 0, 0, "_tentacle1a");
		AddAnimframe(walks, 0, 0, "_tentacle1b");
		LastImage = "_tentacle1";
		
		// Create the Death Animation using the enemy library - nmelib
		CreateAnim(8, DeadAnim);
		CallFunction("_enemylib", true, "CreateDeathAnim", "s", DeadAnim );
		
		// Create the Falling Animation using the enemy library
		CreateAnim(8, FallAnim); 
		CallFunction("_enemylib", true, "CreateFallAnim", "s", FallAnim );
		
		// Set some general parameters
		SetActiveDist("this", 320);
		SetType("this", enemyType);
		SetSpeed( "this", 10 );   
		SetDamage("this", 50);
		SetHealth("this", 1);
		SetMaxHealth("this", 100);
	}
	
	if (!isActive("this") || isDead("this"))
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
		case burning:
			Burn();
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
	static float: moveCount = 0.00;
	static moveTarg = 20;
	SetState("this", walking);
	
	// Get the width and height of the Current animation
	new width  = GetAnimWidth(walks);
	new height = GetAnimHeight(walks);
	
	// Move the Enemy
	if (GetPauseLevel() == 0)
	{	
		// The move count will tell us when its time to pick another direction
		moveCount += 10 * GetTimeDelta();
		if (moveCount > moveTarg)
		{
			// Set a random direction to move in
			moveCount = 0.00;
			moveTarg = random(20) + 10;
			SetMoveAngle("this", random(360));
			SetAnimSpeed(walks, random(10) + 5);
		}
		
		// Move at a random Speed
		SetSpeed( "this", random(16) - 2 );
		
		// Check for Collisions
		if (!AngleCollide("this", 5, 5, 240, true, width / 2, height / 2))
			AngleMove("this");
	}
	
	// Draw the enemy
	new x = GetX("this");
	new y = GetY("this");
	
	if (isVisible("this"))
	{
		DrawAnim(walks, x, y, y + height);
		PutSprite("shadow1", (x + width / 2) - 8, y + height - 15, 2);
	}
	
	// Set a collision rectangle around the Enemy
	SetCollisionRect("this", 0, false, x + adj, y + adj, x + width - adj, y + height - adj);
}

//----------------------------------------
// Name: Stand()
//----------------------------------------
Stand( justDraw )
{
	// Get the width and height of the Current animation
	new width  = GetAnimWidth(walks);
	new height = GetAnimHeight(walks);
	new x = GetX("this");
	new y = GetY("this");
	
	// Draw the enemy and its shadow
	if (isVisible("this"))
	{
		if (justDraw)
			DrawAnimNoInc(walks, x, y, y + height);
		else  
			DrawAnim(walks, x, y, y + height);
		
		PutSprite("shadow1", (x + width / 2) - 8, y + height - 15, 2);
	}
	
	// Set a collision rectangle around the Enemy
	SetCollisionRect("this", 0, false, x + adj, y + adj, x + width - adj, y + height - adj);
}

//----------------------------------------
// Name: HitByWeapon(wtype[], damage, x, y)
//----------------------------------------
public HitByWeapon(wtype[], damage, x, y)
{
	new state = GetState("this");
	if (state == hit || state == dying || state == burning )
		return;
	
	// Check if this enemy was hit by a weapon that can stun
	if ( !strcmp( wtype, "stun" ) && state != stunned && state != frozen )
	{
		StunCount = float(damage);
		SetState("this", stunned);
		return;
	}
	
	// Check if this enemy was hit by a fire weapon
	if ( !strcmp( wtype, "fire" ) )
	{
		// Set the enemy on fire - watch them burn muhahahaha
		if (CallFunction("_enemylib", true, "SetOnFire", "s", LastImage))
		StunCount = 32.00;  // function succeded, make the enemy stunned for a while then kill them
		return;
	}
	
	// Check if this enemy was hit by an ice weapon
	if ( !strcmp( wtype, "ice" ) )
	{
		// Put this enemy on ice
		CallFunction("_enemylib", true, "BeginFreeze", "s", LastImage);
		return;
	}
	
	HitCount = 0.00;
	CallFunction("_enemylib", true, "BeginHit", "nnnn", damage, x, y, 0 );
}

//----------------------------------------
// Name: Hit()
//----------------------------------------
Hit()
{
	new colors[5][3] = { {19,125,19}, {253,211,65}, {225,88,5}, {32,211,238}, {238,32,32} };
	new width  = GetAnimWidth(walks);
	new height = GetAnimHeight(walks);
	
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
		DrawAnim(walks, x, y, y + height, 0, colors[ floatround(HitCount * 20.0) % 5 ][0], \
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
// Name: Burn()
//----------------------------------------
Burn()
{
	// This function should be called when the enemy is the the burning state
	// Use the stunned state to make the enemy stand still while they burn
	Stunned();	
	
	// if the stun count gets below a certain level then kill then enemy
	if (StunCount <= 12)
		CallFunction("_enemylib", true, "KillEnemy", "NULL");
}

//----------------------------------------
// Name: Freeze()
//----------------------------------------
Freeze()
{
	// Draw the enemy in a standing position, but draw them blue
	new x = GetX("this");
	new y = GetY("this");
	new width  = GetAnimWidth(walks);
    new height = GetAnimHeight(walks);
	
	if (isVisible("this"))
	{
		DrawAnimNoInc(walks, x, y, y + height, 0, 100, 100, 255);
		PutSprite("shadow1", (x + width / 2) - 8, y + height - 15, 2);
	}
}