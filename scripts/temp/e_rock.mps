/***********************************************
 * Copyright (c) 2004-2006 Editors
 * Changes:  
 *	19/02/02 [lukex]: New file.
 ***********************************************/
#include <foreign/journey>
#include <float>
#include <core>

new param;
new parent[20];
new dir;
new broke = false;

new float: FadeCount = 0.00;
new float: MoveCount = 0.00;
new x;
new y;
new justcollide = false;
new soundplay = false;
main()
{
	if (FirstRun())
	{	
		GetParent("this", parent);
		SetSpeed("this", 180);
		SetDamage("this", 50);
		SetActiveDist("this", -2);
		SetDirection("this", GetDirection(parent));
		SetSpeed("this", 150);
		SetValue(parent, 0, 1);
		SetType("this", enemyType);
	}
	

	if ( CallFunction("_enemylib", true, "CheckForPlayer", "NULL")) 
		broke = true;
	
	if (broke == true)
	{
		Collision();
		if(soundplay == false)
		{
			PlaySound("_potdestroy.wav",240);
			soundplay = true;
		}
	}
	else
		MoveRock();
}

//----------------------------------------
// Name: MoveArrow()
//----------------------------------------
MoveRock()
{
	if ( !GetPauseLevel() )
	{
		// Move the arrow
		new dir = GetDirection("this");
		
		if ( dir == north )
			SetMoveAngle("this", 90);
		else if ( dir == east )
			SetMoveAngle("this", 180);
		else if ( dir == south )
			SetMoveAngle("this", 270);
		else if ( dir == west )
			SetMoveAngle("this", 0);

		AngleMove("this");
	}
	// Draw the Rock
	new x = GetX("this");
	new y = GetY("this");

	if ( isVisible("this") )
	{
		PutSprite("e_rock", x , y , y + 8, 0);
		SetCollisionRect("this", 0, false, x, y, x + 8, y + 8);
	}
	if(!justcollide)
	{
		// Check if it hits a wall or somthing else
		CollisionTest();
		justcollide = true;
	}
}


//----------------------------------------
// Name: CollisionTest()
//----------------------------------------
CollisionTest()
{
	// Test for a collision on the mask layer
	if (AngleCollide("this", 8, 8, 240, true, GetWidth("this") / 2, GetHeight("this") / 2)&& GetType("this",!enemyType))
		broke = true;
}
//----------------------------------------
// Name: Collision()
//----------------------------------------
Collision()
{

	new x = GetX("this");
	new y = GetY("this");
	
	FadeCount += 500.00 * GetTimeDelta();
	MoveCount += 10.00 * GetTimeDelta();
	ClearCollisionRect("this", 0);

	PutSprite("e_rockbreak", x - floatround(MoveCount), y - floatround(MoveCount), y + 8, 0, 255, 255, 255, 255 - floatround(FadeCount), 180, 100); // n
	PutSprite("e_rockbreak", x + floatround(MoveCount), y - floatround(MoveCount), y + 8, 0, 255, 255, 255, 255 - floatround(FadeCount), 270, 100); // e
	PutSprite("e_rockbreak", x + floatround(MoveCount), y + floatround(MoveCount), y + 8, 0, 255, 255, 255, 255 - floatround(FadeCount), 0, 100); // s
	PutSprite("e_rockbreak", x - floatround(MoveCount), y + floatround(MoveCount), y + 8, 0, 255, 255, 255, 255 - floatround(FadeCount), 90, 100); // w
	
    
    
	if ( FadeCount > 240.00)
	{
		SetValue(parent, 0, 0);
		DeleteEntity("this");
	}
}


//----------------------------------------
// Name: HitByWeapon(wtype[], damage, x, y)
//----------------------------------------
public HitByWeapon(wtype[], damage, x, y)
{
	if ( !strcmp( wtype, "shield" ) )
	{
		broke = true;
	}
}