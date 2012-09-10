/***********************************************
 * Copyright (c) 2004-2006 Editors
 * Changes:  
 *	19/02/03 [lukex]: New file.
 *	01/04/03 [KingOfHeart]:
 *	19/02/05 [lukex]: Code Cleanup
 ***********************************************/

#include <foreign/journey>
#include <animation>
#include <float>
#include <counter>
#include <core>

//==================================
//	Global Data
//==================================
new walks[4][20];
new shoot[4][20];
new DeadAnim[20];			  // String holds animation identifier of death animation
new FallAnim[20];			  // String holds animation identifier of falling animation
new LastImage[4][20];			  // holds sprite code of the last drawn image

new float: StunCount;
new float: HitCount;			  // Counter used when the enemy has been hit
new adj = 3;					  // Collision rectangle adjustment value
new shooting = false;
new float: ShootAnim;
new float: standtimer = 0.00;
new alldirections = false;
new float: firing = 0;
//----------------------------------------
// Name: main()
//----------------------------------------
main()
{
	if (FirstRun())
	{
		// Create the animations
		CreateAnim(6, walks[north]);	 // Walking animations
		CreateAnim(6, walks[east]);	 // Walking animations
		CreateAnim(6, walks[south]);	 // Walking animations
		CreateAnim(6, walks[west]);	 // Walking animations
		CreateAnim(1, shoot[north]);	 // Walking animations
		CreateAnim(1, shoot[east]);	 // Walking animations
		CreateAnim(1, shoot[south]);	 // Walking animations
		CreateAnim(1, shoot[west]);	 // Walking animations
		// Add Frames to the walking animations
		AddAnimframe(walks[south], 0, 0, "e_octo_rw1");  // walking north
		AddAnimframe(walks[south], 0, 0, "e_octo_rw2");
		AddAnimframe(shoot[south], 0, 0, "e_octo_rs1");  // walking north
		AddAnimframe(shoot[south], 0, 0, "e_octo_rs2");
		LastImage[south] = "e_octo_rw1";
		AddAnimframe(walks[east], 0, 0, "e_octo_rw7");  // walking north
		AddAnimframe(walks[east], 0, 0, "e_octo_rw8");
		AddAnimframe(shoot[east], 0, 0, "e_octo_rs7");  // walking north
		AddAnimframe(shoot[east], 0, 0, "e_octo_rs8");
		LastImage[east] = "e_octo_rw7";
		AddAnimframe(walks[north], 0, 0, "e_octo_rw5");  // walking north
		AddAnimframe(walks[north], 0, 0, "e_octo_rw6");
		AddAnimframe(shoot[north], 0, 0, "e_octo_rw5");  // walking north
		AddAnimframe(shoot[north], 0, 0, "e_octo_rw6");
		LastImage[north] = "e_octo_rw5";
		AddAnimframe(walks[west], 0, 0, "e_octo_rw3");  // walking north
		AddAnimframe(walks[west], 0, 0, "e_octo_rw4");
		AddAnimframe(shoot[west], 0, 0, "e_octo_rs3");  // walking north
		AddAnimframe(shoot[west], 0, 0, "e_octo_rs4");
		LastImage[west] = "e_octo_rw3";
		// Create the Death Animation using the enemy library - nmelib
		CreateAnim(8, DeadAnim);
		CallFunction("_enemylib", true, "CreateDeathAnim", "s", DeadAnim );

		// Create the Falling Animation using the enemy library
		CreateAnim(8, FallAnim); 
		CallFunction("_enemylib", true, "CreateFallAnim", "s", FallAnim );
		
		// Set some general parameters
		SetActiveDist("this", 320);
		SetType("this", enemyType);
		SetSpeed( "this", 90 );
		SetDamage("this", 40);
		SetDirection("this", south);
		SetState("this", walking);
	}

	if (!isActive("this") || isDead("this"))
		return;

	// Check for a collision with the player
	CallFunction("_enemylib", true, "CheckForPlayer", "NULL");

	// Call a function for the enemy depending on its state
	switch( GetState("this") )
	{
		case standing:
			Stand();
		case walking:
			Walk();
		case hit:
			Hit();
		case dying:
			Die();
		case falling:
			CallFunction("_enemylib", true, "Fall", "snn", FallAnim, GetWidth("e_octo_rw1"), GetHeight("e_octo_rw1"));
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
	SetState("this", walking);
	standtimer += GetTimeDelta();
	// Get the width and height of the Current animation
	new width = GetWidth("e_octo_rw1");
	new height = GetHeight("e_octo_rw1");
 
	// Move the enemy if the game is unpaused
	if (!GetPauseLevel())
	{
		// Sometimes randomly change direction
		if (random(200) == 1)
		{
			ChangeDirection("this");
			SetAngleFromDir("this");
		}
		// Check for Collisions - the next part is specific to the octorock enemy
		if (AngleCollide("this", 5, 5, 240, true, width / 2, height / 2))
		{
			// Pick a new Random direction
			ChangeDirection("this");
			SetAngleFromDir("this");
		}
 
		// Move the enemy
		AngleMove("this");
	}
	if( standtimer >= 2 )
	{
		SetState("this",standing);
		standtimer = 0.00;
	}
	
	new Dir = GetDirection("this");
	new x = GetX("this");
	new y = GetY("this");

	// Draw the enemy and its shadow
	if (isVisible("this"))
	{
		DrawAnim(walks[ Dir ], x, y, y + height);
		PutSprite("shadow1", (x + width / 2) - 8, y + height - 15, 2);
	}

	// Set a collision rectangle around the Enemy
	SetCollisionRect("this", 0, false, x + adj, y + adj, x + width - adj, y + height - adj);
}

//----------------------------------------
// Name: ShootRock()
//----------------------------------------
ShootRock()
{
	new x = GetX("this");
	new y = GetY("this");
	new Dir = GetDirection("this");
	new width  = GetWidth("e_octo_rw1");
	new height = GetHeight("e_octo_rw1");
	new entity[20];
 
	DrawAnim(shoot[ Dir ], x, y, y + 16);
	PutSprite("shadow1", (x + width / 2) - 8, y + height - 15, 2);
		
	if(alldirections && firing == 4)
	{
		firing = 0;
		SetState("this",walking);
	}
	if (ShootAnim > 0.5)
	{
		ShootAnim = 0.00;
		if(!alldirections)
			SetState("this", walking);
  		if ( Dir == north )
			CreateEntity("e_rock", x + 4, y, entity);
		else if ( Dir == east )
			CreateEntity("e_rock", x + 12, y + 5, entity);
		else if ( Dir == south )
			CreateEntity("e_rock", x + 4, y + 10, entity);
		else if ( Dir == west )
			CreateEntity("e_rock", x - 6, y + 5, entity);
		Newdirection();	
	} 
	else 
	{
		ShootAnim += GetTimeDelta();
	}

}
//----------------------------------------
//Name: Newdirection
//----------------------------------------
Newdirection()
{
	if( !alldirections )
		return;
	new Dir = GetDirection("this");
	if ( Dir == 3 ) 
		SetDirection("this",0);
	else
		SetDirection("this",Dir+1);
	firing++;
}
//----------------------------------------
//Name: AllDirections
//----------------------------------------
public AllDirections()
{
	alldirections = true;
}
//----------------------------------------
// Name: Stand()
//----------------------------------------
Stand()
{
	
	// Get the width and height of the Current animation
	new width  = GetWidth("e_octo_rw1");
	new height = GetHeight("e_octo_rw1");
	new x = GetX("this");
	new y = GetY("this");
	new Dir = GetDirection("this");
	// Draw the enemy and its shadow
  		
	if (isVisible("this"))
	{
		ShootRock();
		DrawAnimNoInc(walks[ Dir ], x, y, y + height);
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
	new Dir = GetDirection("this");
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
	 		// Set the enemy on fire - watch them burn muhahahaha
	 		if (CallFunction("_enemylib", true, "SetOnFire", "s", LastImage[ Dir ]))
	 				StunCount = 32.00;  // function succeded, make the enemy stunned for a while then kill them
	 		return;
	}
	
	// Check if this enemy was hit by an ice weapon
	if ( !strcmp( wtype, "ice" ) )
	{
	 		// Put this enemy on ice
	 		CallFunction("_enemylib", true, "BeginFreeze", "s", LastImage[ Dir ]);
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
	new width  = GetWidth("e_octo_rw1");
	new height = GetHeight("e_octo_rw1");



	// Move the enemy if the game is completely unpaused
	if (GetPauseLevel() == 0)
	{
		AngleMove("this");
		AngleCollide("this", 5, 5, 126, 0, width / 2, height / 2);
	}

	new x = GetX("this");
	new y = GetY("this");
	new Dir = GetDirection("this");
	// Draw the enemy
	if (isVisible("this"))
	{
		DrawAnim(walks[ Dir ], x, y, y + height, 0, colors[ floatround(HitCount * 20.0) % 5 ][0], \
														 colors[ floatround(HitCount * 20.0) % 5 ][1], \
														 colors[ floatround(HitCount * 20.0) % 5 ][2], 255, 0, 100);

		PutSprite("shadow1", (x + width / 2) - 8, y + height - 15, 2);
	}

	// Check the hit counter
	HitCount += GetTimeDelta();

	if (HitCount >= 0.23)
	{
		// Leave the Hit state
		SetState("this", walking); 
		SetSpeedMod("this", 0);
		ChangeDirection("this");  // Pick a new Random direction
		SetAngleFromDir("this");
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
	new Dir = GetDirection("this");
	// Overlay the death animation over the enemy
	CallFunction("_enemylib", true, "HandleDying", "ss", DeadAnim, LastImage[ Dir ]);	
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
	new width  = GetWidth("e_octo_rw1");
	new height = GetHeight("e_octo_rw1");
	new x = GetX("this");
	new y = GetY("this");
	new Dir = GetDirection("this");
		
	if (isVisible("this"))
	{
		DrawAnimNoInc(walks[ Dir ], x, y, y + height, 0, 100, 100, 255);
		PutSprite("shadow1", (x + width / 2) - 8, y + height - 15, 2);
	}
}
