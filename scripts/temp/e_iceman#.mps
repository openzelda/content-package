/***********************************************
 * Copyright (c) 2004-2006 Editors
 * Changes:  
 *	19/08/02 [lukex]: New file.
 ***********************************************/
#include <foreign/journey>
#include <animation>
#include <float>
#include <core>

//   Global Data
new walks[20];
new MainImage[20];  			// Main Sprite for the enemy
new DeadAnim[20];	     		// String holds animation identifier of death animation
new FallAnim[20];	     		// String holds animation identifier of falling animation
new LastImage[20];       		// holds sprite code of the last drawn image
new float: StunCount;
new float: HitCount;	 		// Counter used when the enemy has been hit
new param;
new sparkleAmount = 200;
new sparklecount = 0;
// Variables used for bouncing
new float: AwakenCount = 0.00;
new Awakened = false;

//----------------------------------------
// Name: main()
//----------------------------------------
main()
{
	if (FirstRun())
	{
		//LastImage = MainImage;
		CreateAnim(16, walks);
		AddAnimframe(walks, 0, 0, "e_icemanW1");  
		AddAnimframe(walks, 0, 0, "e_icemanW2");
		AddAnimframe(walks, 0, 0, "e_icemanW3");
		// Create the Death Animation 
		CreateAnim(8, DeadAnim);
		AddAnimframe(DeadAnim, 0, 0, "e_icemanD1");  
		AddAnimframe(DeadAnim, 0, 0, "e_icemanD2");
		AddAnimframe(DeadAnim, 0, 0, "e_icemanD3");
		AddAnimframe(DeadAnim, 0, 0, "e_icemanD4");
				
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

		MainImage = "e_icemanN";
		LastImage = "e_icemanW2";
		
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
			CallFunction("_enemylib", true, "Fall", "snn", FallAnim, GetWidth(walks), GetHeight(walks));
		case frozen:
			Walk();
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
	// If the enemy has not yet been awakened then just wait for the player
	if (!Awakened)
	{
		WaitForPlayer();
		return;
	}
		
	// Get the width and height of the Current animation
	new width  = GetAnimWidth(walks);
	new height = GetAnimHeight(walks);
	SetState("this", walking);
	
	// Move the Enemy
	if (GetPauseLevel() == 0)
	{	
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
		DrawAnim(walks, x, y, y + height);
		PutSprite("shadow1", (x + width / 2) - 8, y + height - 15, 2);
	}
	
	// Set a collision rectangle around the Enemy
	SetCollisionRect("this", 0, false, x, y + 4 , x + width, y + height + 2);
}

//----------------------------------------
// Name: Stand()
//----------------------------------------
Standinwall( justDraw )
{
	// Get the width and height of the Current animation
	new width  = GetWidth(MainImage);
	new height = GetHeight(MainImage);
	new x = GetX("this");
	new y = GetY("this");
	
	// Draw the enemy and its shadow
	if (isVisible("this"))
	{
		PutSprite(MainImage, x, y , y + height);
	}
}
//----------------------------------------
// Name: Stand()
//----------------------------------------
Stand( justDraw )
{
	// Get the width and height of the Current animation
	new width  = GetWidth(LastImage);
	new height = GetHeight(LastImage);
	new x = GetX("this");
	new y = GetY("this");
	
	// Draw the enemy and its shadow
	if (isVisible("this"))
	{
		PutSprite(LastImage, x, y , y + height);
		PutSprite("shadow1", (x + width / 2) - 8, y + height - 16, 2);
	}
	
	// Set a collision rectangle around the Enemy
	SetCollisionRect("this", 0, false, x , y + 8, x + width, y + height);
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
	Standinwall( 1 );
	
	// Check if the player is a certain distance away
	new px = GetX("player1");
	new x  = GetX("this");

	// Check the player is Near enough
	if ( px >= x && px <= x + 32)
	{
		AwakenCount = 1.00;
		SetActiveFlag("this", true);
	}
}

//----------------------------------------
// Name: Awaken()
//----------------------------------------
Awaken()
{
	
	AwakenCount += 1 * GetTimeDelta();
	if ( AwakenCount > 1.5 )
	{
		AwakenCount = 0.00;
		Awakened = true;
	}
	
	// Draw the enemy in a standing position, draw it different colours
	new x = GetX("this");
	new y = GetY("this");
	new width  = GetWidth(MainImage);
	new height = GetHeight(MainImage);
	const WAKEUP_SHAKE = 8;
	static ShakeCount = 0;
	new ShakeOffset[WAKEUP_SHAKE] = { -2, 0, 2, 0, 2, 0, -2, 0 }; 
	// Move the enemy slightly to shake them
	SetX("this", GetX("this") + ShakeOffset[ ShakeCount ] );
		
	// Increment the shaking counter
	ShakeCount++;
	if ( ShakeCount >= WAKEUP_SHAKE )
		ShakeCount = 0;
	
		
	if (isVisible("this"))
	{
		PutSprite(MainImage, x, y , y + height, 0, 255, 255, 255, 255, 0, 100);
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
		
	if ( !strcmp( wtype, "fire" ) )
	{
		if (CallFunction("_enemylib", true, "SetOnFire", "s", LastImage))
		return;
	}
	
	HitCount = 0.00;
	BeginHit2( x, y );
}
BeginHit2( x, y ) {
	// Work out a new move angle to move the enemy away from the thing that hit him
	new Angle = CalculateAngle( x, y,  GetX("this"), GetY("this"));
	
	SetMoveAngle("this", Angle);
	SetSpeedMod("this", 100);
	ClearCollisionRect("this", 0); 
	PlaySound("e_hurt.wav", 240);
	SetState("this", hit);
		
}

//----------------------------------------
// Name: Hit()
//----------------------------------------
Hit()
{
	new width  = GetWidth(LastImage);
	new height = GetHeight(LastImage);
	
	// Move the enemy if the game is completely unpaused
	if (GetPauseLevel() == 0)
	{
		AngleMove("this");
		AngleCollide("this", 5, 5, 126, 0, width / 2, height / 2);
	}
	new x = GetX("this");
	new y = GetY("this");
	if (isVisible("this"))
	{
		DrawAnim(walks, x, y, y + height);
		
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

	// Overlay the death animation over the enemy
	CallFunction("_enemylib", true, "HandleDying", "ss", DeadAnim, "32x16x0");   
	SetHealth("this", 0);
	Awakened = false;	// Put the enemy back to sleep
	AwakenCount = 0.00;
	SetActiveFlag("this", false);
}

//----------------------------------------
// Name: Burn()
//----------------------------------------
Burn()
{
	CallFunction("_enemylib", true, "KillEnemy", "NULL");
}
