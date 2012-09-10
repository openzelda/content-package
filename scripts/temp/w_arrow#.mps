/***********************************************
 * Copyright (c) 2004-2006 Editors
 * Changes:  
 *	19/08/02 [lukex]: New file.
 *	01/12/02 [Satanman]: Added Different types of Arrows
 *	26/04/05 [lukex]: minor changes.
 ***********************************************/
#include <foreign/journey>
#include <float>
#include <core>


new float: arrowCount = 0.00;
new float: timeActive = 0.00;
new param;
new colours[3] = {255, 255, 255};
new parent[20];

main()
{
	if (FirstRun())
	{	
		GetParent("this", parent);
		SetSpeed("this", 180);
		SetDamage("this", 100);
		SetActiveDist("this", -2);
		SetDirection("this", GetDirection("player1"));
		param = GetParam("this");
		if (param == 'f')
		{
			colours = {255, 0, 0};
			SetSpeed("this", 150);
			SetDamage("this", 150);
		}
		else if (param == 'i')
		{
			colours = {0, 255, 255};
			SetSpeed("this", 220);
			SetDamage("this", 200);
		}
		else if (param == 'l')
		{
			colours = {255, 255, 0};
			SetSpeed("this", 500);
			SetDamage("this", 400);
		}
		else if (param == 'b')
		{
			colours = {255, 0, 0};
			SetSpeed("this", 120);
			SetDamage("this", 300);
		}
		else if (param == 's')
		{
			colours = {128, 128, 128};
			SetSpeed("this", 200);
			SetDamage("this", 200);
		}
		SetValue(parent, 1, 1);
		
	}
	
	// Advance the misc. counter 
	if (param == 'b')
		arrowCount += 256 * GetTimeDelta();
	else
		arrowCount += GetTimeDelta();
		
	// Dont allow this entity to live for too long if it doesnt hit anything
	timeActive += GetTimeDelta();
	if ( timeActive > 5)
	{
		DeleteEntity("this");
	}
	if ( timeActive > 2)
	{
		SetValue(parent, 1, 0);
	}
	MoveArrow();
}

//----------------------------------------
// Name: MoveArrow()
//----------------------------------------
MoveArrow()
{
	// Move the arrow
	new dir = GetDirection("this");
	new rot;
	if ( dir == north )
	{
		SetMoveAngle("this", 90);
		rot = 0;
	}
	else if ( dir == east )
	{
		SetMoveAngle("this", 180);
		rot = 90;
	}
	else if ( dir == south )
	{
		SetMoveAngle("this", 270);
		rot = 180;
	}
	else if ( dir == west )
	{
		SetMoveAngle("this", 0);
		rot = 270;

	}
	AngleMove("this");
	
	// Draw the Arrow
	new x = GetX("this");
	new y = GetY("this");

	if ( isVisible("this") )
	{
		PutSprite("w_arrow", x , y , y + 8, 0, colours[0], colours[1], colours[2], 255, rot);
		if (param == 'l')
		{
			if ( dir == north )
			{
				PutSprite("w_arrow", x , y + 16, y + 8, 0, colours[0], colours[1], colours[2], 150, rot);
				PutSprite("w_arrow", x , y + 32 , y + 8, 0, colours[0], colours[1], colours[2], 50, rot);
			}
			else if ( dir == east )
			{
				PutSprite("w_arrow", x - 16 , y , y + 8, 0, colours[0], colours[1], colours[2], 150, rot);
				PutSprite("w_arrow", x - 32 , y , y + 8, 0, colours[0], colours[1], colours[2], 50, rot);
			}
			else if ( dir == south )
			{
				PutSprite("w_arrow", x , y - 16, y + 8, 0, colours[0], colours[1], colours[2], 150, rot);
				PutSprite("w_arrow", x , y - 32 , y + 8, 0, colours[0], colours[1], colours[2], 50, rot);
			}
			else if ( dir == west )
			{
				PutSprite("w_arrow", x + 16 , y , y + 8, 0, colours[0], colours[1], colours[2], 150, rot);
				PutSprite("w_arrow", x + 32 , y , y + 8, 0, colours[0], colours[1], colours[2], 50, rot);
			}
		} 
		else if (param == 'f')
		{
			if (arrowCount >= 0.2)
			{
				CreateEntity("_fire1a", x - 8, y - 8, "arrowflame");
				arrowCount = 0.00;
			}
		} 
		else if (param == 'i')
		{	
			if (arrowCount >= 0.1)
			{
				CreateEntity("_sparkle1", x - 6 + random(12), y - 6 + random(12), "arrowice");
				arrowCount = 0.00;
			}
		} 
		else if (param == 'b')
		{	
			if (arrowCount >= 255.00)
				arrowCount = 0.00;
			colours[0] = floatround(arrowCount);
		} 
		else if (param == 's')
		{	
			if (arrowCount >= 0.05)
			{
				CreateEntity("_sparkle1", x - 6 + random(8), y - 6 + random(8), "arrowsparkle");
				arrowCount = 0.00;
			}
		}
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
	{
		SetValue(parent, 0, 0);
		DeleteEntity("this");
	}
	// Test for a collision on the mask layer
	if (AngleCollide("this", 2, 50, 50, 0, 2, 2))
	{
		SetValue(parent, 0, 0);
		// Create an arrow hit / explosion entity
		if (param == 'b')
			CreateEntity("_explosion1", GetX("this"), GetY("this"), "arrowexplode");
		else
			CreateEntity("w_arrowhit", GetX("this"), GetY("this"), "arrowhit");
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
				SetValue(parent, 0, 0);
				// hit it!!! burn-kill-destroy! mwahahaha!!!
				if (param == 'n')
					CallFunction( temp, false, "HitByWeapon", "snnn", "arrow", 100, x - 3, y - 3);
				else if (param == 'f')
					CallFunction( temp, false, "HitByWeapon", "snnn", "fire", 150, x - 3, y - 3);
				else if (param == 'i')
					CallFunction( temp, false, "HitByWeapon", "snnn", "ice", 200, x - 3, y - 3);
				else if (param == 'l')
					CallFunction( temp, false, "HitByWeapon", "snnn", "light", 400, x - 3, y - 3);
				else if (param == 'b')
					CreateEntity("_explosion1", x - 6, y - 6, "arrowexplode");
				else if (param == 's')
					CallFunction( temp, false, "HitByWeapon", "snnn", "silver", 200, x - 3, y - 3);
				return true;
			}
		}
	}while( NextEntity() )
	return false;
}
