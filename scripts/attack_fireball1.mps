/***********************************************
 *
 ***********************************************/
#include <mokoi_quest>

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
	EntityGetPosition(_x_, _y_, _z_);
	UpdateDisplayPosition()
	obj1 = ObjectCreate("fire1.png:1", SPRITE, dx, dy, 4, 0, 0);
	obj2 = ObjectCreate("fire1.png:1", SPRITE, dx, dy, 4, 0, 0);
	obj3 = ObjectCreate("fire1.png:1", SPRITE, dx, dy, 4, 0, 0);
}

public Close()
{
	ObjectDelete(obj1);
	ObjectDelete(obj2);
	ObjectDelete(obj3);
	EntityCreate("effect_fire1", "*", dx, dy, 5, CURRENT_MAP);
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
	_angle_ = fixed(_dir_ * 45);
	
	// Draw the fireball
	new xpos[3];
	new ypos[3];
	
	// Set the positions of the 3 sprites according to the counter
	if (count < 100)
	{
		xpos = { 0, 8, 0 };
		ypos = { 0, 5, 10 };
	}
	else if (count < 200)
	{
		xpos = { 5, 0, 9 };
		ypos = { 0, 5, 10 };
	}
	else if (count < 300)
	{
		xpos = { 5, 0, 9 };
		ypos = { 6, 4, 0 };
	}
	else
	{
		xpos = { 0, 8, 0 };
		ypos = { 6, 4, 0 };
	}
	
	ObjectPosition(obj1, dx + xpos[0], dy + ypos[0], 4, 0, 0);
	ObjectPosition(obj2, dx + xpos[1], dy + ypos[1], 4, 0, 0);
	ObjectPosition(obj3, dx + xpos[2], dy + ypos[2], 4, 0, 0);
	
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


