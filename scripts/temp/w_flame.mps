/***********************************************
 * Copyright (c) 2002-2005 Editors
 * Changes:  
 *	23/06/03 [Lukex]: New file.
 ***********************************************/

#include <animation>
#include <foreign/journey>

new flame[20];
new y
new x
main()
{
	if (FirstRun())
	{	
		SetActiveDist("this", -2);
		CreateAnim(20, flame );
		AddAnimframe(flame, 0, 0, "w_flame1");
		AddAnimframe(flame, 0, 0, "w_flame2");
		AddAnimframe(flame, 0, 0, "w_flame3");
		PlaySound("_fire1.wav", 240);
		x = GetX("this");
		y = GetY("this");
	}
		


	if ( isVisible("this") )
		DrawAnim(flame, x, y, y + 16);
	
	// Check if it hits a wall or somthing else
	if (CheckForEnemies())
		DeleteEntity("this");
	
	if (FinishedAnim(flame))
		DeleteEntity("this");
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
			// Check this entity is near the fireball
			if (CollidePoint(temp, x, y))
			{
				// Set this enemy on fire!
				CallFunction( temp, false, "HitByWeapon", "snnn", "fire", 150, x - 6, y - 6);
				return true;
			}
		}
	}while( NextEntity() )
	return false;
}