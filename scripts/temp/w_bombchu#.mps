 /***********************************************
 * bombchuweapon  - Bombchu script
 * 
 * Author: Kouruu - based on _bombweapon1 script
 * Date:   January 1, 2005
 *
 * Desc:   A bombchu script, the fuse counts down while
 *         it runs in random directions 'sweet' and
 *		   then creates an explosion entity. Make sure
 *         you have the explosion script included-
 *         _explosion1.zes
 *
 * Usage:
 *
 * Sprites: bombchu.spt
 *         
 ***********************************************/
#include <animation>
#include <foreign/journey>
#include <float>
#include <core>

new Image[20];						// String holds animation identifier of the bombchu
new FallAnim[20];	     			// String holds animation identifier of falling animation
new float: fuse = 0.00;
new float: TintCount = 0.00;
const FUSE_LENGTH = 40;
const MaxColors = 5;
new colors[MaxColors][3] = { {180,150,0}, {0,0,0}, {115,100,49}, {255,200,200}, {238,0,0} };
new width;
new height;
new isFalling = false;
new x;
new y;
new direct;
new float:soundFXCount = 5.00;

//----------------------------------------
// Name: main()
//----------------------------------------
main()
{
	if (FirstRun())
	{
		SetDirection("this", GetDirection("player1"));
		new dir = GetDirection("this");
		CreateAnim(8, Image);
		if( dir == north)
		{
			AddAnimframe(Image, 0, 0, "bombchun");
			AddAnimframe(Image, 0, 0, "bombchuna");
			width = GetWidth(  "bombchun" );
			height= GetHeight( "bombchun" );
	        SetImage("this", "bombchun");
		}
		else if( dir == south)
		{
			AddAnimframe(Image, 0, 0, "bombchus");
			AddAnimframe(Image, 0, 0, "bombchusa");
			width = GetWidth(  "bombchus" );
			height= GetHeight( "bombchus" );
	        SetImage("this", "bombchus");
		}
		else if( dir == east)
		{
			AddAnimframe(Image, 0, 0, "bombchue");
			AddAnimframe(Image, 0, 0, "bombchuea");
			width = GetWidth(  "bombchue" );
			height= GetHeight( "bombchue" );
	        SetImage("this", "bombchue");
		}
		else if( dir == west)
		{
			AddAnimframe(Image, 0, 0, "bombchuw");
			AddAnimframe(Image, 0, 0, "bombchuwa");
			width = GetWidth(  "bombchuw" );
			height= GetHeight( "bombchuw" );
	        SetImage("this", "bombchuw");
		}
		direct = dir;
		SetLiftLevel("this", 1);
        SetWeight("this", 90);
        SetBounceValue("this", 15);
        SetSpeed("this", 200);
        
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
		
	// Draw the Bombchu
	if (isVisible("this") && !isFalling)
		DrawBomb( CurrentFrame );
						
	// See if the bombchu needs to explode
	if (CurrentFrame >= FUSE_LENGTH )
		GoBOOM();
				
	// Increment the fuse counter
	fuse += 8 * GetTimeDelta();
	
	// If we are falling then play the falling animation
	if (isFalling)
		Fall();
	else
	{
		// Check for any holes the bombchu might be in
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
	new wid = GetAnimWidth(  Image ) / 2;
	new hei = GetAnimHeight( Image ) / 2;
	
	// If the bombchu is being held by the player then tell the player
	if (isTaken("this"))
		CallFunction("player1", false, "EndThrow","NULL");
		
	// Create an explosion entity
	CreateEntity("_explosion1", GetX("this") + wid, GetY("this") + hei, Ent);
	
	// Delete the bombchu and falling animation
	DeleteAnim(FallAnim);
	DeleteAnim(Image);	
	DeleteEntity("this");	
}

//----------------------------------------
// Name: DrawBomb()
//----------------------------------------
DrawBomb( CurrentFrame )
{   
    new yDepth = 0;
	new rTint = 255;
	new gTint = 255;
	new bTint = 255;
	new AnimWidth = GetAnimWidth( Image );
	new AnimHeight = GetAnimHeight( Image );
	
	// If the bombchu is about to explode then start making it different colours
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
	
		if (GetPauseLevel() == 0)
	{
		// Check for Collisions
		CheckForEnemies();
		if (AngleCollide("this", 5, 5, 240, true, width / 2, height / 2))
		{
			GoBOOM();
		}
		new rnd = random(3) + 1;
		if (direct == north)
		{
			if (rnd == 1)
				SetDirection("this", northwest);
			else if (rnd == 2)
				SetDirection("this", north);
			else if (rnd == 3)
				SetDirection("this", northeast);
		}
		else if (direct == south)
		{
			if (rnd == 1)
				SetDirection("this", southwest);
			else if (rnd == 2)
				SetDirection("this", south);
			else if (rnd == 3)
				SetDirection("this", southeast);
		}
		else if (direct == east)
		{
			if (rnd == 1)
				SetDirection("this", northeast);
			else if (rnd == 2)
				SetDirection("this", east);
			else if (rnd == 3)
				SetDirection("this", southeast);
		}
		else if (direct == west)
		{
			if (rnd == 1)
				SetDirection("this", northwest);
			else if (rnd == 2)
				SetDirection("this", west);
			else if (rnd == 3)
				SetDirection("this", southwest);
		}

		// Move the bombchu
		SetAngleFromDir("this");
		AngleMove("this");
		// Check the sound effects counter
		soundFXCount += 100 * GetTimeDelta();
		if ( soundFXCount > 4)
		{
			// We cant play the sound each loop becuase that would sound bad and probably
			// grind everything to a halt, so just play it every so often
			PlaySound("bombchu.wav", 240);
			soundFXCount = 0.00;
		}

	}
	new x = GetX("this");
	new y = GetY("this");

// Draw shadow if this has not been picked up
	if (!isTaken("this"))
		PutSprite("shadow1", x, y, 2);
	else
	    // Adjust the depth the sprite is drawn at so it appears above the player sprite
		yDepth = 48;
	
	// Draw the bombchu
	if (isVisible("this"))
	{
		DrawAnim( Image, x + (width / 2) - AnimWidth / 2,
	                  y + (height / 2) - AnimHeight / 2, y + yDepth, 0, rTint, gTint, bTint );
	}
	else
	    IncrementAnim( Image );

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
   	// Check if the bombchu is in a hole based on its collision rectangle
   	new HoleType = CheckForHole("this");
   	
	if (HoleType != -1)
	{
		// If the bombchu is being held by the player then tell the player to stop
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
		// Delete the bombchu and falling animation
		DeleteAnim(FallAnim);
		DeleteAnim(Image);
		DeleteEntity("this");	
	}
}
//----------------------------------------
// Name: CheckForEnemies()
//----------------------------------------
CheckForEnemies()
{
	new x = GetX("this");
	new y = GetY("this");
	new temp[20];
	
	// Go to the start of the Entity List
	StartEntity(40, x, y);
	do
	{
		ToString(GetCurrentEntity(), temp);
		
		// Check this entity is an enemy
		if ( GetType( temp ) == enemyType && !isDead( temp ) )
		{
			// Check this entity is near the fireball
			if (Collide("this", temp))
			{
				GoBOOM();
			}
		}
		
		
	}while( NextEntity() )
}
