/***********************************************
 *
 ***********************************************/
#define DAMAGE 150
#include <mokoi_quest>

new BlastRadius = 0;
new obj = -1;


public Init(...)
{
	EntityGetPosition(_x_,_y_, _z_);
	UpdateDisplayPosition();
	obj = ObjectCreate("explosion.png:1", dx, dy, 4, 0, 0);
	AudioPlaySound("bigexplosion.wav");	

}

main()
{
	if ( !HandleExplosion() )
	{
		EntityDelete();
	}
}

//----------------------------------------
// Name: HandleExplosion()
//----------------------------------------
HandleExplosion(  )
{
	new xpos[12];
	new ypos[12];
	new sprite[12];
	new NumItems = 0;
	new n;
	/*
	// Each frame is made up from several smaller sprites, each sprite needs an x and y
	// coordinate and a sprite code, which is what the bit below does. 
	if ( CurrentFrame == 0 )
	{
		xpos = { -8,   -1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1 };
		ypos = { -8,   -1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1 };
		sprite = { 15, -1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1};		                           
	    NumItems = 1;
	    BlastRadius = 8;
	}
	else if ( CurrentFrame == 1 )
	{
		xpos = { -16, 0, -16, 0,  -1,-1,-1,-1,-1,-1,-1,-1 };
		ypos = { -16, -16, 0, 0,  -1,-1,-1,-1,-1,-1,-1,-1 };
		sprite = { 0, 1, 2, 3,  -1,-1,-1,-1,-1,-1,-1,-1};		                           
	    NumItems = 4;
	    BlastRadius = 16;
	}
	else if ( CurrentFrame == 2 )
	{
		xpos = { -16, 0, -16, 0,  -1,-1,-1,-1,-1,-1,-1,-1 };
		ypos = { -16, -16, 0, 0,  -1,-1,-1,-1,-1,-1,-1,-1 };
		sprite = { 4, 5, 6, 7,  -1,-1,-1,-1,-1,-1,-1,-1};		                           
	    NumItems = 4;
	    BlastRadius = 16;
	}
	else if ( CurrentFrame == 3 )
	{
		xpos = { -16, 0, -16, 0,  -1,-1,-1,-1,-1,-1,-1,-1 };
		ypos = { -16, -16, 0, 0,  -1,-1,-1,-1,-1,-1,-1,-1 };
		sprite = { 0, 1, 2, 3,  -1,-1,-1,-1,-1,-1,-1,-1};		                           
	    NumItems = 4;
	    BlastRadius = 16;
	}
	else if ( CurrentFrame == 4 )
	{
		xpos = { -20, 4, -20, 4, -8, -1,-1,-1,-1,-1,-1,-1 };
		ypos = { -20, -20, 4, 4, -8, -1,-1,-1,-1,-1,-1,-1 };
		sprite = { 4, 5, 6, 7, 8,     -1,-1,-1,-1,-1,-1,-1};		                           
	    NumItems = 5;
	    BlastRadius = 20;
	}
	else if ( CurrentFrame == 5 )
	{
		xpos = { -8, -13, -7, 0,  -5, -12, -1,-1,-1,-1,-1,-1 };
		ypos = { -6, -8, -13, -8, 0, -3,   -1,-1,-1,-1,-1,-1 };
		sprite = { 8, 8, 8, 8, 8, 8,       -1,-1,-1,-1,-1,-1};		                           
	    NumItems = 6;
	    BlastRadius = 20;
	}
	else if ( CurrentFrame == 6 )
	{
	    xpos = { -10, -20, -8, 6,  -4, -18, -1,-1,-1,-1,-1,-1 };
		ypos = { -6, -10, -20, -10, 5, 0,  -1,-1,-1,-1,-1,-1 };
		sprite = { 8, 8, 8, 8, 8, 8,       -1,-1,-1,-1,-1,-1};		                           
	    NumItems = 6;
	    BlastRadius = 20;
	}
	else if ( CurrentFrame == 7 )
	{
		xpos = { -6,  2,  -5, 4,  -13, -20, -19, -8, -18, 9, 4,   12};
		ypos = { -20, -11,-4, 10, -6,  -13, -8,  0,   16, 4, -18, -10};
		sprite = { 9, 11, 13, 12, 11,  14,  9,   10,  11, 14, 13,  14};		                           
	    NumItems = 12;
	    BlastRadius = 0;
	}
	else if ( CurrentFrame == 8 )
	{
		xpos = { -20, -6, 1,  11,  -13, 4, -12, -1, -1, -1, -1, -1};
		ypos = { -12, -6, -21,-10, -6,  10, 2,  -1, -1, -1, -1, -1};
		sprite = { 9, 10, 11, 12,  11,  9,  11, -1, -1, -1, -1, -1};		                           
	    NumItems = 7;
	    BlastRadius = 0;
	}
	else
	{
		return true;
	}	
	*/
	return false;          
}

//----------------------------------------
// Name: GetCollisionRect()
//----------------------------------------
GetCollisionRect()
{
	if ( BlastRadius > 0)
	{
		// Set up a collision rectangle based on the Blast Radius
		CollisionSet(SELF, 0, 0, x - BlastRadius, y - BlastRadius, x + BlastRadius, y + BlastRadius);
		CheckForCollisions();
	}
	else
		CollisionRect();
		
	
}

//----------------------------------------
// Name: CheckForCollisions()
//----------------------------------------
CheckForCollisions()
{
	// Go through every entity and see if this blast affects them
	new current[64];
	new angle;
	new dist;
	new rect;
	
	CollisionCalculate();
	while ( CollisionGetCurrent(_, current, angle, dist, rect )
	{
		//Hit( attacker[], angle, dist, attack, damage, x, y, rect )
		EntityCallFunction( current, "Hit", "sddddd", owner, angle, AEXPLOSION, DAMAGE, _x_, _y_, rect);
	}
}
