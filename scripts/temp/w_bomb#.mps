/***********************************************
 * Copyright (c) 2002-2005 Editors
 * Changes:  
 *	12/06/02 [GD]: New file.
 ***********************************************/
#include <animation>
#include <foreign/journey>
#include <float>

new Image[20] = "_bombweapon1";		// String holds the main image for the bomb
new FallAnim[20];	     			// String holds animation identifier of falling animation
new float: fuse = 0.00;
new float: TintCount = 0.00;
const FUSE_LENGTH = 30;
const MaxColors = 5;
new colors[MaxColors][3] = { {180,150,0}, {0,0,0}, {115,100,49}, {255,200,200}, {238,0,0} };
new width;
new height;
new isFalling = false;
new x;
new y;
new parent[20];

//----------------------------------------
// Name: main()
//----------------------------------------
main()
{
	if (FirstRun())
	{
		width = GetWidth(  Image );
		height= GetHeight( Image );
		SetLiftLevel("this", 1);
		SetImage("this", Image);
		SetWeight("this", 90);
		SetBounceValue("this", 15);
		GetParent("this", parent);
		// Create the falling animation - using the standard falling sprites (_MiscSheet.spt)
		CreateAnim(8, FallAnim);
		AddAnimframe(FallAnim, 0, 0, "_efall1");
		AddAnimframe(FallAnim, 0, 0, "_efall2");
		AddAnimframe(FallAnim, 0, 0, "_efall3");
		AddAnimframe(FallAnim, 0, 0, "_efall4");
		AddAnimframe(FallAnim, 0, 0, "_efall5");
		AddAnimframe(FallAnim, 0, 0, "_efall6");
		SetAnimLoop(FallAnim, false);
		SetActiveDist("this", -2);
	   	SetActiveInGroups("this", true);

	}
	
	x = GetX("this");
	y = GetY("this");
	
	new CurrentFrame = floatround(fuse);
	
	// Draw the Bomb
	if (isVisible("this") && !isFalling)
		DrawBomb( CurrentFrame );
						
	// See if the bomb needs to explode
	if (CurrentFrame >= FUSE_LENGTH )
		GoBOOM();
				
	// Increment the fuse counter
	if ( !GetPauseLevel() )
		fuse += 8 * GetTimeDelta();

	// If we are falling then play the falling animation
	if (isFalling)
		Fall();
	else
	{
		// Check for any holes the bomb might be in
		CheckForHoles();
	}
	
	SetCollisionRect("this", 0, false, x, y, x + width, y + height );
}

//----------------------------------------
// Name: GoBOOM()
//----------------------------------------
GoBOOM()
{
	new Ent[20];
	new wid = GetWidth(  Image ) / 2;
	new hei = GetHeight( Image ) / 2;
	
	// If the bomb is being held by the player then tell the player
	if (isTaken("this"))
		CallFunction("player1", false, "EndThrow","NULL");
		
	// Create an explosion entity
	CreateEntity("_explosion1", GetX("this") + wid, GetY("this") + hei, Ent);
	
	// Delete the bomb and falling animation
	DeleteAnim(FallAnim);	
	DeleteEntity("this");	
}

//----------------------------------------
// Name: DrawBomb()
//----------------------------------------
DrawBomb( CurrentFrame )
{   
    new yDepth = 0;
	new x = GetX("this");
	new y = GetY("this");
	new rTint = 255;
	new gTint = 255;
	new bTint = 255;
	new height = GetHeight( Image );
	
	// If the bomb is about to explode then start making it different colours
	if ( fuse > FUSE_LENGTH / 2 )
	{
		new CurrentFrame = floatround( TintCount );
		rTint = colors[CurrentFrame][0];
		gTint = colors[CurrentFrame][1];
		bTint = colors[CurrentFrame][2];
		
		// Check the animation hasnt finished
		if (CurrentFrame >=  MaxColors)
			TintCount = 0.00;
			
		TintCount += 12 * GetTimeDelta();	
	}
	
	// Draw shadow if this has not been picked up
	if (!isTaken("this"))
		PutSprite("shadow1", x, y, 2);
	else
	    // Adjust the depth the sprite is drawn at so it appears above the player sprite
		yDepth = 48;
	
	// Draw the bomb
	PutSprite( Image, x, y, y + height + yDepth, 0, rTint, gTint, bTint );
}

//----------------------------------------
// Name: Thrown()
//----------------------------------------
public Thrown()
{
	// Called when its being thrown	
	return 1;
}

//----------------------------------------
// Name: CheckForHoles()
//----------------------------------------
CheckForHoles()
{
   	// Check if the bomb is in a hole based on its collision rectangle
   	new HoleType = CheckForHole("this");
   	
	if (HoleType != -1)
	{
		// If the bomb is being held by the player then tell the player to stop
		if (isTaken("this"))
			CallFunction("player1", false, "EndThrow","NULL");
		
		fuse = 0.00;		// Make sure it doesnt explode while falling
		isFalling = true;
		PlaySound("_dropping.wav", 240);
	    return true;
	}
}

//----------------------------------------
// Name: Fall()
//----------------------------------------
Fall()
{
	new AnimWidth = GetAnimWidth( FallAnim );
    new AnimHeight= GetAnimHeight( FallAnim );
	
	//  play a falling animation
	if (isVisible("this"))
	{
		DrawAnim( FallAnim, x + (width / 2) - AnimWidth / 2,
	                  y + (height / 2) - AnimHeight / 2, y );
	}
	else
	    IncrementAnim( FallAnim );
	        
	// Check if the falling animation has done
   	if (FinishedAnim( FallAnim ))
   	{
		// Delete the bomb and falling animation
		DeleteAnim(FallAnim);
		DeleteEntity("this");	
	}
}