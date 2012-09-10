/* This file is Public Domain */
/***********************************************
 * e_laser1 entity script
 * 
 * Author: Satanman
 * Date:   23 July 2002
 *
 * Desc:   A laser entity designed for release by laser_eye#
 *		   it has been fine-tuned to appear as 1 long line.	   
 *
 * Usage:  Used by laser_eye#, avoid direct exposure to eyes
 *
 * Sprites: level7_dungeon.spt
 *         
 ***********************************************/
#include <foreign/journey>
#include <float>

//new float: fireCount = 0.00;
new float: timeActive = 0.00;
new parent[20];
new dir;
new angle;
new x;
new y;

main()
{
	if (FirstRun())
	{	
		GetParent("this",parent);
		SetSpeed("this", 400);
		SetActiveDist("this", 150);
		dir = GetDirection(parent);
		if (dir == north)
			dir = south;
		else if (dir == east)
			dir = west;
		else if (dir == south)
			dir = north;
		else if (dir == west)
			dir = east;
		SetDirection("this", dir);
		SetAngleFromDir("this");
		angle = GetMoveAngle("this");
	}
		
	// Dont allow this entity to live for too long if it doesnt hit anything
	timeActive += GetTimeDelta();
	if ( timeActive > 5)
		DeleteEntity("this");
		
	MoveLaser();
}

//----------------------------------------
// Name: MoveLaser()
//----------------------------------------
MoveLaser()
{
	// Move the laser
	AngleMove("this");
	
	// Draw the Laser
	x = GetX("this");
	y = GetY("this");
	
	if ( isVisible("this") )
	{
		PutSprite("e_laser1", x, y, y, 0, 255, 255, 255, 130, angle);		
	}
	
	// Check if it hits a wall or somthing else
	if (timeActive > 0.1)
		CollisionTest();
}


//----------------------------------------
// Name: CollisionTest()
//----------------------------------------
CollisionTest()
{
	new entity[20];
	
	// Check if this has hit an enemy or the player
	if (CheckForEnemies())
		DeleteEntity("this");
			
	// Test for a collision on the mask layer
	if (AngleCollide("this", 3, 3, 126, 0, 8, 8))
	{
		CreateEntity("_explosion2", x, y, "_explosion2");
		DeleteEntity("this");
	}
}

//----------------------------------------
// Name: CheckForEnemies()
//----------------------------------------
CheckForEnemies()
{
	x = GetX("this") + 6;
	y = GetY("this") + 6;
	new temp[20];
	
	// Go to the start of the Entity List
	StartEntity();
	
	// Loop through all the entities within a certain distance
	do
	{
		ToString(GetCurrentEntity(), temp);
		
		// Check this entity is an enemy
		if (GetType( temp ) == enemyType || GetType( temp ) == playerType)
		{
			if( !isDead( temp ) && isActive( temp ))
			{
				// Check this entity is near the laser
				if (CollidePoint(temp, x, y))
				{
					// lase the enemy :) (I'm aware lase isnt a word)
					CallFunction( temp, false, "HitByWeapon", "snnn", "laser", 100, x - 6, y - 6);
					return true;
				}
			}
		}
	}while( NextEntity(40, x, y) )
	return false;
}