/***********************************************
 * Copyright (c) 2005-2006 lukex
 * Changes:  
 *	12/09/05 [lukex]: New file.
 ***********************************************/

#define nodebug
#include <foreign/journey>
#include <animation>
#include <float>
#include <core>

enum _personalstates 
{
	ppose,
	phiding,
	pmove1 = 4,
}
//==================================
//	Global Data
//==================================
new posing[20];
new hitasnim[20];
new LastImage[10] = "_boss4a";
new DeadAnim[20];

new float: HitCount;
new float:timer = 0.00;
new float:changeDir = 2.00;
new adj = 2;
new bool:explosion;

new alpha = 255;
new bool:alphadir = false;

new isfrozen = false;

new enemyx;
new enemyy;
new width;
new height

//----------------------------------------
// Name: main()
//----------------------------------------
main()
{
	if (FirstRun())
	{
		// Create the animations
      	CreateAnim( 8, posing );
      	CreateAnim( 8, hitasnim );

	    AddAnimframe(posing, 0, 0, "_boss4a" );
		AddAnimframe(posing, 0, 0, "_boss4b" );
		AddAnimframe(posing, 0, 0, "_boss4c" );
		
	    AddAnimframe(posing, 0, 0, "_boss4d" );
		AddAnimframe(posing, 0, 0, "_boss4e" );
		AddAnimframe(posing, 0, 0, "_boss4f" );		

	    AddAnimframe(hitasnim, 0, 0, "_boss4g" );
		AddAnimframe(hitasnim, 0, 0, "_boss4h" );
		AddAnimframe(hitasnim, 0, 0, "_boss4i" );
		
		// Create the Death Animation using the enemy library - nmelib
		CreateAnim(8, DeadAnim);
		CallFunction("_enemylib", true, "CreateDeathAnim", "s", DeadAnim );
		
		SetType("this", enemyType);
		SetSpeed( "this", 25 );
		SetDamage("this", 75);
		SetMaxHealth("this", 300);
		SetHealth("this", 300);
		SetState("this", ppose);
		SetMoveAngle("this", 270);
		SetDirection("this", south);
		
		width = GetWidth("_boss4a");
		height = GetHeight("_boss4a");
	}
	
	if (isDead("this")|| !isActive("this"))
		return;

	enemyx = GetX("this");
	enemyy = GetY("this");
	
	if ( !GetPauseLevel() )
		timer += 4*GetTimeDelta();

	switch( GetState("this") )
	{
		case ppose:
		{
			ClearCollisionRect("this", 0);
			if ( timer > 7.00 )
			{
				alpha = 255;
				timer = 0.00;
				SetState("this", phiding);
			}
			else if ( timer > 5.00 )
			{
				isfrozen = false;
				if (12 < alpha)
				{
					alphadir = true;
				}
				else if (242 > alpha)
				{
					alphadir = false;
				}
				
				if (alphadir)
					alpha += floatround(timer * 512);
				else
					alpha -= floatround(timer * 512);

				
				PutSprite("_boss4a", enemyx, enemyy, enemyy, .a = alpha);
			}
			else
			{
				SetCollisionRect("this", 0, false, enemyx, enemyy, enemyx + width, enemyy + height);
				if ( isfrozen )
				{
					PutSprite("_boss4a", enemyx, enemyy, enemyy, 0, 100, 100, 255);
					if ( !GetPauseLevel() )
						timer -= 2*GetTimeDelta();
				}
				else
				{
					PutSprite("_boss4a", enemyx, enemyy, enemyy);
				}
			}

		}
		case pmove1:
		{
			DrawAnim(posing, enemyx, enemyy, enemyy);
			SetCollisionRect("this", 0, false, enemyx, enemyy, enemyx + width, enemyy + height);
			if ( FinishedAnim(posing) )
			{
				SetState("this", ppose);
				timer = 0.00;
			}
		}
		case hit:
			Hit();
		case dying:
			Die();
		case phiding:
		{
			ClearCollisionRect("this", 0);
			if ( timer > 3.00 )
			{
				SetState("this", pmove1);
			}
		}
	}

}

//----------------------------------------
// Name: HitByWeapon(wtype[], damage, x, y)
//----------------------------------------
public HitByWeapon(wtype[], damage, x, y)
{
	if ( !strcmp( wtype, "arrow" ) )
	{
		isfrozen = true;
		SetState("this", ppose);
	}		
	if ( !strcmp( wtype, "sword" ) )
	{
		HitCount = 0.00;
		CallFunction("_enemylib", true, "BeginHit", "nnnn", damage, x, y, 1 );
	}
}

//----------------------------------------
// Name: Hit()
//----------------------------------------
Hit()
{
	new colors[5][3] = { {19,125,19}, {253,211,65}, {225,88,5}, {32,211,238}, {238,32,32} };
	
	if (GetPauseLevel() == 0)
	{
	
		ClearCollisionRect("this", 0);
		if (isVisible("this"))
		{
			PutSprite(LastImage,  enemyx, enemyy, enemyy + height, 0, colors[ floatround(HitCount * 20.0) % 5 ][0], colors[ floatround(HitCount * 20.0) % 5 ][1], colors[ floatround(HitCount * 20.0) % 5 ][2]);
		}



		// Check the hit counter, if it goes high enough then end this hit state
		HitCount += GetTimeDelta();
		if (HitCount >= 3.00)
		{
			HitCount = 0.00;
			// Leave the Hit state
			SetState("this", walking); 
			SetHealth("this", GetHealth("this") - 100);
			if ( GetHealth("this") <= 0)
			{
				SetState("this", dying);
			}
		}
	}
}

//----------------------------------------
// Name: Die()
//----------------------------------------
Die()
{	
		
	// Draw the enemy standing still
	if (GetAnimCount(DeadAnim) < 5)
		PutSprite(LastImage, enemyx, enemyy, enemyy);  	
	
	// Overlay the death animation over the enemy
	CallFunction("_enemylib", true, "HandleDying", "ss", DeadAnim, LastImage);   
	SetHealth("this", 0);
	ClearCollisionRect("this", 0);
}


ShootRocks()
{
/*
	CreateEntity("e_rock", x + 4, y + 10, entity);
	CreateEntity("e_rock", x + 4, y + 10, entity);
	CreateEntity("e_rock", x + 4, y + 10, entity);
	CreateEntity("e_rock", x + 4, y + 10, entity);
	CreateEntity("e_rock", x + 4, y + 10, entity);
	CreateEntity("e_rock", x + 4, y + 10, entity);
	CreateEntity("e_rock", x + 4, y + 10, entity);
	*/
}
SpawnOrbs()
{
/*
	CreateEntity("orbenemy#", x + 4, y + 10, entity);
	CreateEntity("orbenemy#", x + 4, y + 10, entity);
	CreateEntity("orbenemyr", x + 4, y + 10, entity);
*/
}