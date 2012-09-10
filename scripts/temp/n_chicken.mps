/* This file is Public Domain */
/*************************************************************************
 * _chicken Entity Script
 * 
 * Author: Satanman
 * Date:   30/06/02
 *
 * Desc:   A Script for a not-simple chicken. done: all basic chicken abilities except throwing
 *
 *         NOTE: This Script REQUIRES the enemy library entity: _enemylib
 *         to be included in the project.
 *
 * Usage:  fun, really :)
 *
 * Sprites: _ChickenSheet.spt
 *         
 ************************************************************************/
#include <foreign/journey>
#include <animation>
#include <float>
#include <counter>
#include <core>

//==================================
//   Global Data
//==================================
new DeadAnim[20];	     // String holds animation identifier of death animation
new FallAnim[20];	     // String holds animation identifier of falling animation

new LastImage[20]; //beh
new float: HitCount;	     // Counter used when the chicken has been hit
new float: timer;
new status = 0;			//how's the little guy doing?
new chickanim[20]; 
new chicksprite[20];
new chicken_number;
new max_chicken_number = 20;
new float: chicken_wait;
new float: StunCount;
new walke[20];
new walkw[20];
new height;
new width;
new run;
new float: movetime = 0.00;

//----------------------------------------
// Name: main()
//----------------------------------------
main()
{
	if (FirstRun())
	{
		// Create the animations
		CreateAnim(3, walkw);    // Walking animations
		CreateAnim(3, walke);    //walke, hehe

		// Add Frames to the wanking animations
		AddAnimframe(walkw, 0, 0, "_chickenwest1");  // walking west
		AddAnimframe(walkw, 0, 0, "_chickenwest2");

		AddAnimframe(walke, 0, 0, "_chickeneast1");  // walking east
		AddAnimframe(walke, 0, 0, "_chickeneast2");
		LastImage = "_chickeneast1";

		// Create the Death Animation using the enemy library - nmelib
		CreateAnim(8, DeadAnim);
		CallFunction("_enemylib", true, "CreateDeathAnim", "s", DeadAnim );

		// Create the Falling Animation using the enemy library
		CreateAnim(8, FallAnim); 
		CallFunction("_enemylib", true, "CreateFallAnim", "s", FallAnim );

		// Set some general parameters
		SetActiveDist("this", 320);
		SetType("this", otherType); //any other suggestions for its type?
		SetSpeed( "this", 0 );   // initially...
		SetCuttableFlag("this", true);   //hehe ;)
		Respawn("this", 50);
		SetDamage("this", 20);   //throw the little bugger at an enemy :)
		SetImage("this", "_chickeneast1");
		SetMaxHealth("this", 512);
		SetHealth("this", 512);
		SetLiftLevel("this", 1);
		SetWeight("this", 100);
	}

	if (!isActive("this") || isDead("this"))
		return;

	// Call a function for the enemy depending on its state
	switch( GetState("this") )
	{
		case standing:
			Walk();
		case walking:
			Walk();
		case chasing:
			Chase();
		case hit:
			Hit();
		case dying:
			Die();
		case falling:
			CallFunction("_enemylib", true, "Fall", "snn", FallAnim, GetWidth("_chickeneast1"), GetHeight("_chickeneast1"));
		case burning:
			Burn();
		case stunned:
			Stunned();
		case frozen:
			Freeze();
	}

	// Check for holes in the ground if not dead
	if ( !isDead("this") )
		CallFunction("_enemylib", true, "CheckForHoles", "s", FallAnim);

	if (chicken_number > 0 && chicken_wait >= 0.75)
		Chickens_Attack();
	else if (chicken_number > 0)
		chicken_wait += GetTimeDelta();

	if (GetMoveAngle("this") > 90 && GetMoveAngle("this") < 270)
	{
		chickanim = "walke";
		SetDirection("this", east);
		LastImage = "_chickeneast";
	}else{
		chickanim = "walkw";
		SetDirection("this", west);
		LastImage = "_chickenwest";
	}
}

//----------------------------------------
// Name: Walk()
//----------------------------------------
Walk()
{
	if (timer > movetime && status == 0)
	{
		SetState("this", walking);
		timer = 0.00;
		movetime = 0.50 + random(250) / 100;
	}
	else if (timer > movetime && status == 1)
	{
		SetState("this", standing);
		timer = 0.00;
		movetime = 1.00;
	}
	// Get the width and height of the Current animation
	width  = GetAnimWidth(walke);
	height = GetAnimHeight(walke);


	// Move the enemy if the game is unpaused
	if (GetPauseLevel() == 0)
	{
		if(GetState("this") == walking && status == 0)
		{
			status = 1;
			SetMoveAngle("this", random(360));
			SetSpeed("this", 30);
		}else if (GetState("this") == standing && status == 1)
		{
			status = 0;
			SetSpeed("this", 0);
		}

		if (AngleCollide("this", 5, 5, 126, true, width / 2, height / 2))
		{
			SetMoveAngle("this", random(360));
			if (GetMoveAngle("this") > 90 && GetMoveAngle("this") < 270)
			{
				chickanim = "walkw";
				SetDirection("this", west);
			}else{
				chickanim = "walke";
				SetDirection("this", east);
			}
		}

		// Move the chicken
		AngleMove("this");
		if (status != 2)
			timer += GetTimeDelta();
	}

	new x = GetX("this");
	new y = GetY("this");

	// Draw the chicken and its shadow
	if (isVisible("this"))
	{
		if (GetDirection("this") == west)
			DrawAnim(walkw, x, y, y + height);
		else
			DrawAnim(walke, x, y, y + height);
		PutSprite("shadow1", (x + width / 2) - 8, y + height - 15, 2);
	}

	// Set a collision rectangle around the chicken
	SetCollisionRect("this", 0, false, x, y, x + width, y + height);
}


//----------------------------------------
// Name: Stand( JustDraw )
//----------------------------------------
Stand( justDraw )
{
	// Get the width and height of the Current animation
	new width  = GetAnimWidth(walke);
	new height = GetAnimHeight(walke);
	new x = GetX("this");
	new y = GetY("this");

	// Draw the enemy and its shadow
	if (isVisible("this"))
	{
		if (justDraw)
			DrawAnimNoInc(walke, x, y, y + height);
		else  
			DrawAnim(walke, x, y, y + height);

		PutSprite("shadow1", (x + width / 2) - 8, y + height - 15, 2);
	}

	// Set a collision rectangle around the Enemy
	SetCollisionRect("this", 0, false, x, y, x + width, y + height);
}

//----------------------------------------
// Name: HitByWeapon(wtype[], damage, x, y)
//----------------------------------------
public HitByWeapon(wtype[], damage, x, y)
{

	new state = GetState("this");
	if (state == burning && !strcmp(wtype, "ice"))
	{
		SetState("this", walking);
		return;
	}
	if (state == frozen && !strcmp(wtype, "fire"))
	{
		SetState("this", walking);
		return;
	}
	if (state == hit || state == dying || state == burning)
		return;

	// Work out a new move angle to move the chicken away from the thing that hit him
	new Angle = CalculateAngle( x, y,  GetX("this"), GetY("this"));

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
		// Set the enemy on fire - watch them burn muhahahaha   <-- I never knew GD was this sadistic :/
		if (CallFunction("_enemylib", true, "SetOnFire", "s", LastImage))
			StunCount = 32.00;
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
	SetMoveAngle("this", Angle);
	SetSpeedMod("this", 100);
	ClearCollisionRect("this", 0); 
	PlaySound("gluck.wav", 240);

	// Set the chicken state to hit
	SetState("this", hit);
 
	// Handle damage to the chicken
	SetHealth("this",  GetHealth("this") - damage);
	if (GetHealth("this") <= 0)
	{
		Chickens_Attack();
	}
}

//----------------------------------------
// Name: Hit()
//----------------------------------------
Hit()
{
	new colours[5][3] = { {19,125,19}, {253,211,65}, {225,88,5}, {32,211,238}, {238,32,32} };
	new width  = GetAnimWidth(walkw);
	new height = GetAnimHeight(walkw);

	// Move the chicken if the game is completely unpaused
	if (GetPauseLevel() == 0)
	{
		AngleMove("this");
		AngleCollide("this", 5, 5, 126, 0, width / 2, height / 2);
	}

	new x = GetX("this");
	new y = GetY("this");

	// Draw the chicken
	if (isVisible("this"))
	{
		DrawAnim(walkw, x, y, y + height, 0, colours[ floatround(HitCount * 20.0) % 5 ][0], \
			colours[ floatround(HitCount * 20.0) % 5 ][1], \
			colours[ floatround(HitCount * 20.0) % 5 ][2], 255, 0, 100);

		PutSprite("shadow1", (x + width / 2) - 8, y + height - 15, 2);
	}

	// Check the hit counter
	HitCount += GetTimeDelta();

	if (HitCount >= 0.23)
	{
		// Leave the Hit state
		SetState("this", chasing);
		status = 2; //you scared him :(
		SetSpeedMod("this", 0);
		if (GetHealth("this") <= 0)
		SetHealth("this", 512);
	}
}

//----------------------------------------
// Name: Die() [this will hardly ever happen]
//----------------------------------------
Die()
{	
	// Draw the chicken standing still.. or not :)
	if (GetAnimCount(DeadAnim) < 5)
		Walk();

	// Overlay the death animation over the chicken
	CallFunction("_enemylib", true, "HandleDying", "ss", DeadAnim, LastImage);   
	SetHealth("this", 0);
}

//----------------------------------------
// Name: chickens_attack()
//----------------------------------------
Chickens_Attack()
{
	new attack_dir = random(4); //get a random direction for the chicken to attack from
	if (chicken_number < max_chicken_number)
	{
		if (attack_dir == 1)
			CreateEntity("n_Achicken", GetX("player1") - 160, GetY("player1") - 120 + random(240), "attackchick");
		else if (attack_dir == 2)
			CreateEntity("n_Achicken", GetX("player1") + 160, GetY("Player1") - 120 + random(240), "attackchick");
		else if (attack_dir == 3)
			CreateEntity("n_Achicken", GetX("player1") - 160 + random(320), GetY("player1") - 120, "attackchick");
		else if (attack_dir == 4)
			CreateEntity("n_Achicken", GetX("player1") - 160 + random(320), GetY("player1") + 120, "attackchick");
		PlaySound("gluck.wav", 240);
		chicken_number += 1;
		chicken_wait = 0.00;
	}else{
		chicken_number = 0;
	}
}

//----------------------------------------
// Name: Chase()
//----------------------------------------
Chase()
{
	new x = GetX("this");
	new y = GetY("this");
	run = CalculateAngle(GetX("player1"),GetY("player1"),GetX("this"),GetY("this"));
	SetMoveAngle("this", run);
	SetSpeed("this", 60);
	Walk();   
}

//--------------------------------------------------------
// Name: Thrown()
// Desc: Called when this entity is being thrown to check
//       for collision with enemies etc..
//--------------------------------------------------------
public Thrown()
{
	new temp[20];
	// Check if we hit any enemies - and damage them.
	StartEntity(); // Go to the start of the Entity List.

	// Loop through all the entities within a certain distance
	do
	{
		ToString(GetCurrentEntity(), temp);

		// Check for collision with enemies only
		if (GetType(temp) == enemyType && isActive(temp))  
		{
			if (Collide("this", temp))
			{
				CallFunction(temp, false, "HitByWeapon", "snnn", \
					"throwobj", GetDamage("this") , GetX("this"), GetY("this"));
				return false;
			}
		}
	}while( NextEntity(80) )  // check all enemies within 80 pixels of the object
	return true;
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
	// This function should be called when the chicken is in the burning state
	//Use the stunned state to make the enemy stand still while they burn
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
	// Draw the chicken in a standing position, but draw them blue
	new x = GetX("this");
	new y = GetY("this");
	new width  = GetAnimWidth(walke);
	new height = GetAnimHeight(walke);

	if (isVisible("this"))
	{
		DrawAnimNoInc(walke, x, y, y + height, 0, 100, 100, 255);
		PutSprite("shadow1", (x + width / 2) - 8, y + height - 15, 2);
	}
}