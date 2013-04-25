/***********************************************
 * Copyright © Luke Salisbury
 *
 * You are free to share, to copy, distribute and transmit this work
 * You are free to adapt this work
 * Under the following conditions:
 *  You must attribute the work in the manner specified by the author or licensor (but not in any way that suggests that they endorse you or your use of the work). 
 *  You may not use this work for commercial purposes.
 * Full terms of use: http://creativecommons.org/licenses/by-nc/3.0/
 * Changes:
 *     2010/01/11 [luke]: new file.
 ***********************************************/

#include <movement>

new count = 0;
new active = 0;
new speed = 220;
new obj1, obj2, obj3;

public Init( ...)
{
/*
	PutSprite("_firerod10", x + xpos[2], y + ypos[2], y + 8);	
	PutSprite("_firerod11", x + xpos[1], y + ypos[1], y + 8);	
	PutSprite("_firerod12", x + xpos[0], y + ypos[0], y + 8);	
*/
	GetEntityPosition(mqEntityPosition.x, mqEntityPosition.y, mqEntityPosition.z, mqDisplayArea.x, mqDisplayArea.y, mqDisplayZIndex, mqDisplayLayer);
	obj1 = ObjectCreate("fire1.png:1", SPRITE, mqDisplayArea.x, mqDisplayArea.y, mqDisplayZIndex, 0, 0);
	obj2 = ObjectCreate("fire1.png:1", SPRITE, mqDisplayArea.x, mqDisplayArea.y, mqDisplayZIndex, 0, 0);
	obj3 = ObjectCreate("fire1.png:1", SPRITE, mqDisplayArea.x, mqDisplayArea.y, mqDisplayZIndex, 0, 0);
}

public Close()
{
	ObjectDelete(obj1);
	ObjectDelete(obj2);
	ObjectDelete(obj3);

	EntityCreate("effect_fire1", "", mqDisplayArea.x, mqDisplayArea.y, mqDisplayZIndex, CURRENT_MAP);
}

main()
{
	// Advance the counter
	count += 12 * GameFrame();
	if ( count >= 4000 )
		count = 0;
	
	active += GameFrame(); // Dont allow this entity to live for too long if it doesnt hit anything
	if ( active > 5000 )
		EntityDelete();
		
	MoveFireball();
}

//----------------------------------------
// Name: MoveFireball()
//----------------------------------------
MoveFireball()
{
	mqMovementAngle = Dir2Angle(mqDirection);
	
	// Draw the fireball
	new xpos[3];
	new ypos[3];
	
	// Set the positions of the 3 sprites according to the counter
	if (count < 100)
	{
		xpos = [ 0, 8, 0 ];
		ypos = [ 0, 5, 10 ];
	}
	else if (count < 200)
	{
		xpos = [ 5, 0, 9 ];
		ypos = [ 0, 5, 10 ];
	}
	else if (count < 300)
	{
		xpos = [ 5, 0, 9 ];
		ypos = [ 6, 4, 0 ];
	}
	else
	{
		xpos = [ 0, 8, 0 ];
		ypos = [ 6, 4, 0 ];
	}
	
	ObjectPosition(obj1, mqDisplayArea.x + xpos[0], mqDisplayArea.y + ypos[0], 4, 0, 0);
	ObjectPosition(obj2, mqDisplayArea.x + xpos[1], mqDisplayArea.y + ypos[1], 4, 0, 0);
	ObjectPosition(obj3, mqDisplayArea.x + xpos[2], mqDisplayArea.y + ypos[2], 4, 0, 0);
	
	CollisionTest();// Check if it hits a wall or somthing else
}


//----------------------------------------
// Name: CollisionTest()
//----------------------------------------
CollisionTest()
{
	// Check if this has hit an enemy, if it has then set the enemy on fire.
	//if ( CheckForEnemies() )
	//	EntityDelete();
			
	// Test for a collision on the mask layer
	/*
	if (AngleCollide("this", 3, 3, 126, 0, 8, 8))
	{
		fireball = true;
		EntityDelete();
	}
	*/
}


