/***********************************************
 * Copyright (c) 2004-2006 Editors
 * Changes:  
 *	29/06/02 [GD]: New file.
 ***********************************************/
#include <foreign/journey>
#include <animation>
#include <float>
#include <core>

//   Global Data
new walks[20];
new DeadAnim[20];	     		// String holds animation identifier of death animation
new FallAnim[20];	     		// String holds animation identifier of falling animation
new LastImage[20];       		// holds sprite code of the last drawn image
new float: StunCount;
new float: HitCount;	 		// Counter used when the enemy has been hit
new adj = 3;		     		// Collision rectangle adjustment value
new param;

//----------------------------------------
// Name: main()
//----------------------------------------
main()
{
	if (FirstRun())
	{
		param = GetParam("this");
				
		// Create the animations
		CreateAnim(16, walks);
		
		// Add Frames to the walking animations
		if (param == 'b')
		{
			AddAnimframe(walks, 0, 0, "_orbenemyb");  
			AddAnimframe(walks, 0, 0, "_orbenemyba");
			LastImage = "_orbenemyb";
			SetSpeed( "this", 50 );  
			SetMaxHealth("this", 100);
		}
		else if (param == 'r')
		{
			AddAnimframe(walks, 0, 0, "_orbenemyr");  
			AddAnimframe(walks, 0, 0, "_orbenemyra");
			LastImage = "_orbenemyr";
			SetSpeed( "this", 55 ); 
			SetMaxHealth("this", 150); 
		}
		
		// Create the Death Animation using the enemy library - nmelib
		CreateAnim(8, DeadAnim);
		CallFunction("_enemylib", true, "CreateDeathAnim", "s", DeadAnim );
		
		// Create the Falling Animation using the enemy library
		CreateAnim(8, FallAnim); 
		CallFunction("_enemylib", true, "CreateFallAnim", "s", FallAnim );
		
		// Set some general parameters
		SetActiveDist("this", 320);
		SetType("this", enemyType);
		SetDamage("this", 50);
		SetHealth("this", GetMaxHealth("this"));
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
			CallFunction("_enemylib", true, "Fall", "snn", FallAnim, GetWidth("_orbenemyb"), GetHeight("_orbenemyb"));
		case stunned:
			Stunned();
		case frozen:
			Freeze();
		case burning:
			Burn();
	}
		
	// Check for holes in the ground
	CallFunction("_enemylib", true, "CheckForHoles", "s", FallAnim);
}

//----------------------------------------
// Name: Walk()
//----------------------------------------
Walk()
{	
	// Get the width and height of the Current animation
	new width  = GetAnimWidth(walks);
	new height = GetAnimHeight(walks);
	SetState("this", walking);
	
	// Move the Enemy
	if (GetPauseLevel() == 0)
	{		
		// We wanna walk towards the player
		SetMoveAngle("this",  CalculateAngle(GetX("this"), GetY("this"), GetX("player1"), GetY("player1")));

		// Check for Collisions - if there are none then move the enemy
		if (!AngleCollide("this", 6, 5, 240, true, width / 2, (height / 2) + 8 ))
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
	SetCollisionRect("this", 0, false, x + adj, y + 8 + adj, x + width - adj, y + height - adj);
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
	SetCollisionRect("this", 0, false, x + adj, y + 8 + adj, x + width - adj, y + height - adj);
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
	CallFunction("player1", false, "BeginKnockBack", "nnnn", GetX("this") + 8, GetY("this") + 12, 60, 30);
	if ( !strcmp( wtype, "sword" ) )
	{
		// Knock the player back a lot
		CallFunction("player1", false, "BeginKnockBack", "nnnn", GetX("this") + 8, GetY("this") + 12, 60, 30);
	}
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
		DrawAnim(walks, x, y, y + height, 0,      colors[ floatround(HitCount * 20.0) % 5 ][0], \
		                           			 	  colors[ floatround(HitCount * 20.0) % 5 ][1], \
		                           			 	  colors[ floatround(HitCount * 20.0) % 5 ][2], 255, 0, 100);
		
		PutSprite("shadow1", (x + width / 2) - 8, y + height - 15, 2);
	}
	
	// Check the hit counter, if it goes high enough then end this hit state
	HitCount += GetTimeDelta();
	if (HitCount >= 0.25)
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