/***********************************************
 * Copyright (c) 2004-2006 Editors
 * Changes:  
 *	08/03/05 [lukex]: New file.  based on w_arrows#.
 ***********************************************/
#include <foreign/journey>
#include <float>
#include <core>
#include <animation>
new float: timeActive = 0.00;
new param;
new colours[3] = {255, 255, 255};
new parent[20];
new anim[20];
main()
{
	if (FirstRun())
	{	
		GetParent("this", parent);
		SetSpeed("this", 180);
		SetDamage("this", 100);
		SetActiveDist("this", -2);
		SetDirection("this", GetDirection("player1"));
		SetValue(parent, 0, GetValue(parent, 0) + 1);
		CreateAnim(4, anim);
		SetAnimLoop(anim, true);
		AddAnimframe(anim, 0, 0, "w_tstars");
		AddAnimframe(anim, 0, 0, "w_tstars1");
	}
	
	timeActive += GetTimeDelta();
	if ( timeActive > 5)
	{
		SetValue(parent, 0, GetValue(parent, 0) - 1);
		DeleteEntity("this");
	}
	if (timeActive >= 0.5)
		MoveWeapon();
}

//----------------------------------------
// Name: MoveArrow()
//----------------------------------------
MoveWeapon()
{
	// Move the arrow
	new dir = GetDirection("this");
	new rot;
	SetMoveAngle("this", 90 + (dir*90));
	AngleMove("this");
	
	// Draw the Arrow
	new x = GetX("this");
	new y = GetY("this");

	if ( isVisible("this") )
	{
		DrawAnim(anim, x , y , y + 8, 0, colours[0], colours[1], colours[2], 255);
	}
	
	// Check if it hits a wall or somthing else
	CollisionTest();
}


//----------------------------------------
// Name: CollisionTest()
//----------------------------------------
CollisionTest()
{
	//new entity[20];
	
	// Check if this has hit an enemy, if it has then hit it and delete
	if (CheckForEnemies())
		DeleteEntity("this");
			
	// Test for a collision on the mask layer
	if (AngleCollide("this", 2, 50, 50, 0, 2, 2))
	{
		SetValue(parent, 0, GetValue(parent, 0) - 1);
		DeleteEntity("this");
	}
}

//----------------------------------------
// Name: CheckForEnemies()
//----------------------------------------
CheckForEnemies()
{
	new x = GetX("this") + 6;
	new y = GetY("this") + 6;
	new temp[20];
	
	// Go to the start of the Entity List
	StartEntity(40, x, y);
	
	// Loop through all the entities within a certain distance
	do
	{
		ToString(GetCurrentEntity(), temp);
		
		// Check this entity is an enemy
		if ( GetType( temp ) == enemyType && !isDead( temp ) && isActive( temp ))
		{
			// Check this entity is near the arrow
			if (CollidePoint(temp, x, y))
			{
				SetValue(parent, 0, GetValue(parent, 0) - 1);
				CallFunction( temp, false, "HitByWeapon", "snnn", "tstar", 200, x - 3, y - 3);
				return true;
			}
		}
	}while( NextEntity() )
	return false;
}
