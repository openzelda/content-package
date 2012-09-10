/***********************************************
 * Copyright (c) 2004-2006 Editors
 * Changes:  
 *	04/07/02 [GD]: New file.
 ***********************************************/
#include <foreign/journey>
#include <core>

// Create an array of offsets for the weapon for each frame
new WoffsetX[4][4] = { {  1,   1,   1,   2}, {  9,  9,  14,  9}, { 2,  3,  3,  2}, { -9, -9, -14, -9}};
new WoffsetY[4][4] = { {-10,  -9,  -9, -14}, {  8,  8,  6,   8}, {10, 12, 12, 14}, {  8,  8,   6,  8}};

new Sprites[4][20];	// 4 Strings to hold the sprites for each direction
new Parent[20];		// The guard entitiy who owns this sword
new adj = 2;

//----------------------------------------
// Name: main()
//----------------------------------------
main()
{
	if (FirstRun())
	{
		Sprites[north] = "_guardswordn";
		Sprites[east]  = "_guardsworde";
		Sprites[south] = "_guardswords";
		Sprites[west]  = "_guardswordw";
		
		// Get the entity who created this
		GetParent("this", Parent);
		SetDamage("this", 50);
	}
	SetActiveDist("this", -1);
}

//----------------------------------------
// Name: Draw()
//----------------------------------------
public Draw( x, y, depth, direction, frame )
{
	// Offset the weapons coordinates
	x += WoffsetX[direction][frame];
	y += WoffsetY[direction][frame];
	 
	new width  = GetWidth(  Sprites[ direction ] );
	new height = GetHeight( Sprites[ direction ] );
	
	if (direction == north)
		depth -= 4;
					
	// Draw the weapon
	if ( GetState(Parent) == frozen )  // If the guard is frozen then draw the sword blue-ish
		PutSprite( Sprites[ direction ], x, y, depth, 0, 100, 100, 255);
	else
		PutSprite( Sprites[ direction ], x, y, depth);
	
	// Set the direction of the sword to the same as the guard
	SetDirection("this", direction);
	
	// Set a collision rectangle around the weapon
    SetCollisionRect("this", 0, false, x + adj, y + adj, x + width - adj, y + height - adj);
    SetX("this", x);
    SetY("this", y);
    
    // Check for a collision with the player
	CallFunction("_enemylib", true, "CheckForPlayer", "NULL");
}

//----------------------------------------
// Name: HitByWeapon(wtype[], damage, x, y)
//----------------------------------------
public HitByWeapon(wtype[], damage, x, y)
{
	new ParentState = GetState(Parent);
	new Buffer[20];
	new dir = GetDirection("this");
	new px1;
	new py1;
		
	// if we were hit by the players sword then make this guard jump back and also the player
	if ( !strcmp(wtype, "sword") && !isDead(Parent))
	{
		// Dont go any further if the player is in certain states
		if ( ParentState != knocked && ParentState != hit && ParentState != dying && \
		     ParentState != burning && ParentState != frozen && ParentState != stunned)
		{
			CallFunction("player1", false, "BeginKnockBack", "nnnn", GetX("this"), GetY("this"), 40, 20);
			CallFunction(Parent, false, "BeginKnockBack", "nn", x, y);
			
			// We have to work out where the small explosion should appear
			new width  = GetWidth(   Sprites[ dir ] );
			new height = GetHeight(  Sprites[ dir ] );
			px1 = GetX("this") + width / 2;
			py1 = GetY("this") + height / 2;
			
			CreateEntity("_explosion2", px1, py1, Buffer);
		}
	}
}
