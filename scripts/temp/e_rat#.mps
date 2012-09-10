/* This file is Public Domain */
/*************************************************************************
 * _ratenemy1 Entity Script
 * 
 * Author: Satanman
 * Date:   18/02/02
 *
 * Desc:   An Enemy Script for a rat enemy. 
 *
 *         NOTE: This Script REQUIRES the enemy library entity: _enemylib
 *         to be included in the project.
 *
 * Usage:  
 *
 * Sprites: _EnemySheet1.spt
 *         
 * Sounds: rat.wav
 ************************************************************************/
#include <foreign/journey>
#include <animation>
#include <float>
#include <counter>
#include <core>

//==================================
//   Global Data
//==================================
new walkn[20];
new walke[20];
new walks[20];
new walkw[20];
new standn[20];
new stande[20];
new stands[20];
new standw[20];
new DeadAnim[20];	     // String holds animation identifier of death animation
new FallAnim[20];	     // String holds animation identifier of falling animation
new LastImage[20];           // holds sprite code of the last drawn image
new float: StandTimer;
new float: StunCount;
new float: HitCount;	     // Counter used when the enemy has been hit
new adj = 3;		     // Collision rectangle adjustment value
new width;
new height;
new x;
new y;
new Dir;

//----------------------------------------
// Name: main()
//----------------------------------------
main()
{
	if (FirstRun())
	{
		// Create the animations
		CreateAnim(6, walkn);    // Walking animations
		CreateAnim(6, walke);
		CreateAnim(6, walks);
		CreateAnim(6, walkw);

		CreateAnim(6, standn);    // Standing animations
		CreateAnim(6, stande);
		CreateAnim(6, stands);
		CreateAnim(6, standw);

		// Add Frames to the walking animations
		AddAnimframe(walkn, 0, 0, "_ratn1");  // walking north
		AddAnimframe(walkn, 0, 0, "_ratn2");
		AddAnimframe(walke, 0, 0, "_rate1");  // walking east
		AddAnimframe(walke, 0, 0, "_rate2");
		AddAnimframe(walks, 0, 0, "_rats1");  // walking south
		AddAnimframe(walks, 0, 0, "_rats2");
		AddAnimframe(walkw, 0, 0, "_ratw1");  // walking west
		AddAnimframe(walkw, 0, 0, "_ratw2");

		// Add Frames to the standing animations
		AddAnimframe(standn, 0, 0, "_ratstandn1");  // facing north
		AddAnimframe(standn, 0, 0, "_ratstandn2");
		AddAnimframe(stande, 0, 0, "_ratstande1");  // facing east
		AddAnimframe(stande, 0, 0, "_ratstande2");
		AddAnimframe(stands, 0, 0, "_ratstands1");  // facing south
		AddAnimframe(stands, 0, 0, "_ratstands2");
		AddAnimframe(standw, 0, 0, "_ratstandw1");  // facing west
		AddAnimframe(standw, 0, 0, "_ratstandw2");
		LastImage = "_ratenemy1";

		// Create the Death Animation using the enemy library - nmelib
		CreateAnim(8, DeadAnim);
		CallFunction("_enemylib", true, "CreateDeathAnim", "s", DeadAnim );

		// Create the Falling Animation using the enemy library
		CreateAnim(8, FallAnim); 
		CallFunction("_enemylib", true, "CreateFallAnim", "s", FallAnim );

		// Set some general parameters
		SetActiveDist("this", 320);
		SetType("this", enemyType);
		SetSpeed( "this", 90 );   //these buggers are pretty fast
		SetDamage("this", 50);
		SetHealth("this", 50);
		Dir = GetDirection("this");
		if (Dir == north)
		{
			width  = GetAnimWidth(walkn);
			height = GetAnimHeight(walkn);
			LastImage = "_ratn1";
		} else if (Dir == east)
		{
			width  = GetAnimWidth(walke);
			height = GetAnimHeight(walke);
			LastImage = "_rate1";
		} else if (Dir == south)
		{
			width  = GetAnimWidth(walks);
			height = GetAnimHeight(walks);
			LastImage = "_rats1";
		} else if (Dir == west)
		{
			width  = GetAnimWidth(walkw);
			height = GetAnimHeight(walkw);
			LastImage = "_ratw1";
		}
	}

	if (!isActive("this") || isDead("this"))
		return;

	// Check for a collision with the player
	CallFunction("_enemylib", true, "CheckForPlayer", "NULL");


	// Call a function for the enemy depending on its state
	switch( GetState("this") )
	{
		case standing:
			Sit();
		case walking:
			Walk();
		case hit:
			Hit();
		case dying:
			Die();
		case falling:
			CallFunction("_enemylib", true, "Fall", "snn", FallAnim, width, height);
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

	// Move the enemy if the game is unpaused
	if (GetPauseLevel() == 0)
	{
		// Sometimes randomly change direction
		if (random(150) == 1)
		{
			ChangeDirection("this");
			SetAngleFromDir("this");
			Dir = GetDirection("this");
			if (Dir == north)
			{
				width  = GetAnimWidth(walkn);
				height = GetAnimHeight(walkn);
				LastImage = "_ratn1";
			} else if (Dir == east)
			{
				width  = GetAnimWidth(walke);
				height = GetAnimHeight(walke);
				LastImage = "_rate1";
			} else if (Dir == south)
			{
				width  = GetAnimWidth(walks);
				height = GetAnimHeight(walks);
				LastImage = "_rats1";
			} else if (Dir == west)
			{
				width  = GetAnimWidth(walkw);
				height = GetAnimHeight(walkw);
				LastImage = "_ratw1";
			}
		} else if (random(300) == 1)
		{
			SetState("this", standing);
			PlaySound("rat.wav", 240);
		}
  
		// Check for Collisions
		if (AngleCollide("this", 5, 5, 240, true, width / 2, height / 2))
		{
			// Pick a new Random direction
			ChangeDirection("this");
			SetAngleFromDir("this");
			Dir = GetDirection("this");
			if (Dir == north)
			{
				width  = GetAnimWidth(walkn);
				height = GetAnimHeight(walkn);
				LastImage = "_ratn1";
			} else if (Dir == east)
			{
				width  = GetAnimWidth(walke);
				height = GetAnimHeight(walke);
				LastImage = "_rate1";
			} else if (Dir == south)
			{
				width  = GetAnimWidth(walks);
				height = GetAnimHeight(walks);
				LastImage = "_rats1";
			} else if (Dir == west)
			{
				width  = GetAnimWidth(walkw);
				height = GetAnimHeight(walkw);
				LastImage = "_ratw1";
			}
		}
 
		// Move the enemy
		AngleMove("this");
	}

	x = GetX("this");
	y = GetY("this");

	// Draw the enemy and its shadow
	if (isVisible("this"))
	{
		if (Dir == north)
			DrawAnim(walkn, x, y, y + height);
		else if (Dir == east)
			DrawAnim(walke, x, y, y + height);
		else if (Dir == south)
			DrawAnim(walks, x, y, y + height);
		else if (Dir == west)
			DrawAnim(walkw, x, y, y + height);
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
	Dir = GetDirection("this");
	if (Dir == north)
	{
		width  = GetAnimWidth(walkn);
		height = GetAnimHeight(walkn);
		LastImage = "_ratn1";
	} else if (Dir == east)
	{
		width  = GetAnimWidth(walke);
		height = GetAnimHeight(walke);
		LastImage = "_rate1";
	} else if (Dir == south)
	{
		width  = GetAnimWidth(walks);
		height = GetAnimHeight(walks);
		LastImage = "_rats1";
	} else if (Dir == west)
	{
		width  = GetAnimWidth(walkw);
		height = GetAnimHeight(walkw);
		LastImage = "_ratw1";
	}
	
	x = GetX("this");
	y = GetY("this");

	// Draw the enemy and its shadow
	if (isVisible("this"))
	{
		if (justDraw)
		{
			if (Dir == north)
				DrawAnimNoInc(walkn, x, y, y + height);
			else if (Dir == east)
				DrawAnimNoInc(walke, x, y, y + height);
			else if (Dir == south)
				DrawAnimNoInc(walks, x, y, y + height);
			else if (Dir == west)
				DrawAnimNoInc(walkw, x, y, y + height);
		} else {
			if (Dir == north)
				DrawAnim(walkn, x, y, y + height);
			else if (Dir == east)
				DrawAnim(walke, x, y, y + height);
			else if (Dir == south)
				DrawAnim(walks, x, y, y + height);
			else if (Dir == west)
				DrawAnim(walkw, x, y, y + height);
		}
		PutSprite("shadow1", (x + width / 2) - 8, y + height - 15, 2);
	}
  
	// Set a collision rectangle around the Enemy
	SetCollisionRect("this", 0, false, x + adj, y + adj, x + width - adj, y + height - adj);
}

//----------------------------------------
// Name: Shit()
//----------------------------------------
Sit()
{
	SetState("this", standing);
	x = GetX("this");
	y = GetY("this");
	
	// Draw the enemy and its shadow
	if (isVisible("this"))
	{
		if (Dir == north)
		{
			DrawAnim(standn, x, y, y + height);
			LastImage = "_ratstandn1";
		} else if (Dir == east)
		{
			DrawAnim(stande, x, y, y + height);
			LastImage = "_ratstande1";
		} else if (Dir == south)
		{
			DrawAnim(stands, x, y, y + height);
			LastImage = "_ratstands1";
		} else if (Dir == west)
		{
			DrawAnim(standw, x, y, y + height);
			LastImage = "_ratstandw1";
		}
		PutSprite("shadow1", (x + width / 2) - 8, y + height - 15, 2);
	}
	// Set a collision rectangle around the Enemy
	SetCollisionRect("this", 0, true, x + adj, y + adj, x + width - adj, y + height - adj);
	StandTimer += GetTimeDelta();
	if (StandTimer >= 1.00)
	{
		SetState("this", walking);
		StandTimer = 0.00;
	}
}

//----------------------------------------
// Name: HitByWeapon(wtype[], damage, x, y)
//----------------------------------------
public HitByWeapon(wtype[], damage, x, y)
{	
	Dir = GetDirection("this");
	if (Dir == north)
	{
		width  = GetAnimWidth(walkn);
		height = GetAnimHeight(walkn);
		LastImage = "_ratn1";
	} else if (Dir == east)
	{
		width  = GetAnimWidth(walke);
		height = GetAnimHeight(walke);
		LastImage = "_rate1";
	} else if (Dir == south)
	{
		width  = GetAnimWidth(walks);
		height = GetAnimHeight(walks);
		LastImage = "_rats1";
	} else if (Dir == west)
	{
		width  = GetAnimWidth(walkw);
		height = GetAnimHeight(walkw);
		LastImage = "_ratw1";
	}
	
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
	CallFunction("_enemylib", true, "BeginHit", "nnn", damage, x, y );

}


//----------------------------------------
// Name: Hit()
//----------------------------------------
Hit()
{
	new colors[5][3] = { {19,125,19}, {253,211,65}, {225,88,5}, {32,211,238}, {238,32,32} };
	// Move the enemy if the game is completely unpaused
	if (GetPauseLevel() == 0)
	{
		AngleMove("this");
		AngleCollide("this", 5, 5, 126, 0, width / 2, height / 2);
	}

	x = GetX("this");
	y = GetY("this");

	// Draw the enemy
	if (isVisible("this"))
	{
		if (Dir == north)
		{
			DrawAnim(walkn, x, y, y + height, 0, colors[ floatround(HitCount * 20.0) % 5 ][0], \
				colors[ floatround(HitCount * 20.0) % 5 ][1], \
				colors[ floatround(HitCount * 20.0) % 5 ][2], 255, 0, 100);
		} else if (Dir == east)
		{
			DrawAnim(walke, x, y, y + height, 0, colors[ floatround(HitCount * 20.0) % 5 ][0], \
				colors[ floatround(HitCount * 20.0) % 5 ][1], \
				colors[ floatround(HitCount * 20.0) % 5 ][2], 255, 0, 100);
		} else if (Dir == south)
		{
			DrawAnim(walks, x, y, y + height, 0, colors[ floatround(HitCount * 20.0) % 5 ][0], \
				colors[ floatround(HitCount * 20.0) % 5 ][1], \
				colors[ floatround(HitCount * 20.0) % 5 ][2], 255, 0, 100);
		} else if (Dir == west)
		{
			DrawAnim(walkw, x, y, y + height, 0, colors[ floatround(HitCount * 20.0) % 5 ][0], \
				colors[ floatround(HitCount * 20.0) % 5 ][1], \
				colors[ floatround(HitCount * 20.0) % 5 ][2], 255, 0, 100);
		}
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
	x = GetX("this");
	y = GetY("this");
	//new Dir = GetDirection("this");

	if (isVisible("this"))
	{
		
		PutSprite(LastImage, x, y, y + height, 0, 100, 100, 255);
		PutSprite("shadow1", (x + width / 2) - 8, y + height - 15, 2);
	}
}
