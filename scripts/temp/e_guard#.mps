/***********************************************
* Changes:  
 *	04/07/02 [GD]: New file.
 *	01/09/06 [lukex]: Added RedTeam316's CheckForLineOfSight function
 ***********************************************/
#include <foreign/journey>
#include <animation>
#include <float>
#include <counter>
#include <core>

//==================================
//   Global Data
//==================================
new walk[4][20];			// 4 Strings to hold the walking animation identifiers
new head[4][20];			// Set of 4 strings to hold each head sprite
new stand[4][20];			// Set of 4 strings to hold each standing sprite
new weapon[20];				// String to hold the identifier of the Guards weapon entity
new DeadAnim[20];	    	// String holds animation identifier of death animation
new FallAnim[20];	     	// String holds animation identifier of falling animation
new headDist = 9;
new headDir  = 2;
new AlreadySetWeapon = 0;	 // Variable to make sure the weapon is only set once

new float: HitCount;	     // Counter used when the enemy has been hit
new float: KnockCount;
new float: StunCount;

new LastImage[20];
new firstStand = false;
new CurrentState;
new adj = 2;
new DetectRadius = 100;		// How far away the player is before the chase begins
new param;					// The parameter passed to this script


//----------------------------------------
// Name: main()
//----------------------------------------
main()
{
	if (FirstRun())
	{
		new n;
		param = GetParam("this");
		
		// Allocate 1 string for storing the weapon's Identifier, we cant just put it
		// in the weapon[] buffer as it would be lost when the user saves and loads the
		// game, we need to perminantly store it
		AllocateStrings("this", 1, 20);
		
		// Create a weapon for the guard by default
		CreateEntity("e_guardsword", 0, 0, weapon);
		SetString("this", 0, weapon);
		SetSpeed( "this", 25 );
		
		// Create the animations
		for (n = 0; n < 4; n++)
	      	CreateAnim( 8, walk[n] );
	      
	    // Create the Falling Animation
		CreateAnim(8, FallAnim); 
	      	
	    // Use different sprites depending on the parameter
	   	if ( param == 'g' )		// GREEN GUARD
	   	{
			// Add Frames to the walking animations
			AddAnimframe(walk[0], 0, 0, "_gguardwalkn1");  // walking north
			AddAnimframe(walk[0], 0, 0, "_gguardwalkn2");
			AddAnimframe(walk[0], 0, 0, "_gguardwalkn3");
			AddAnimframe(walk[0], 0, 0, "_gguardwalkn4");
			stand[north] = "_gguardwalkn1";
			head[north] = "_gguardheadn1";
			AddAnimframe(walk[1], 0, 0, "_gguardwalke1");  // walking east
			AddAnimframe(walk[1], 0, 0, "_gguardwalke2");
			AddAnimframe(walk[1], 0, 0, "_gguardwalke3");
			AddAnimframe(walk[1], 0, 0, "_gguardwalke2");
			stand[east] = "_gguardwalke1";
			head[east] = "_gguardheade1";
			AddAnimframe(walk[2], 0, 0, "_gguardwalks1");  // walking south
			AddAnimframe(walk[2], 0, 0, "_gguardwalks2");
			AddAnimframe(walk[2], 0, 0, "_gguardwalks3");
			AddAnimframe(walk[2], 0, 0, "_gguardwalks4");
			stand[south] = "_gguardwalks1";
			head[south] = "_gguardheads1";
			AddAnimframe(walk[3], 0, 0, "_gguardwalkw1");  // walking west
			AddAnimframe(walk[3], 0, 0, "_gguardwalkw2");
			AddAnimframe(walk[3], 0, 0, "_gguardwalkw3");
			AddAnimframe(walk[3], 0, 0, "_gguardwalkw2");
			stand[west] = "_gguardwalkw1";
			head[west] = "_gguardheadw1";
			AddAnimframe(FallAnim, 0, 0, "_gguardfall1");  // Falling
			AddAnimframe(FallAnim, 0, 0, "_gguardfall2");
			AddAnimframe(FallAnim, 0, 0, "_gguardfall3");
			AddAnimframe(FallAnim, 0, 0, "_gguardfall4");
			AddAnimframe(FallAnim, 0, 0, "_gguardfall5");
	   	}
	   	if ( param == 'b' )		// BLUE GUARD
	   	{
			// Add Frames to the walking animations
			AddAnimframe(walk[0], 0, 0, "_bguardwalkn1");  // walking north
			AddAnimframe(walk[0], 0, 0, "_bguardwalkn2");
			AddAnimframe(walk[0], 0, 0, "_bguardwalkn3");
			AddAnimframe(walk[0], 0, 0, "_bguardwalkn4");
			stand[north] = "_bguardwalkn1";
			head[north] = "_bguardheadn1";
			AddAnimframe(walk[1], 0, 0, "_bguardwalke1");  // walking east
			AddAnimframe(walk[1], 0, 0, "_bguardwalke2");
			AddAnimframe(walk[1], 0, 0, "_bguardwalke3");
			AddAnimframe(walk[1], 0, 0, "_bguardwalke2");
			stand[east] = "_bguardwalke1";
			head[east] = "_bguardheade1";
			AddAnimframe(walk[2], 0, 0, "_bguardwalks1");  // walking south
			AddAnimframe(walk[2], 0, 0, "_bguardwalks2");
			AddAnimframe(walk[2], 0, 0, "_bguardwalks3");
			AddAnimframe(walk[2], 0, 0, "_bguardwalks4");
			stand[south] = "_bguardwalks1";
			head[south] = "_bguardheads1";
			AddAnimframe(walk[3], 0, 0, "_bguardwalkw1");  // walking west
			AddAnimframe(walk[3], 0, 0, "_bguardwalkw2");
			AddAnimframe(walk[3], 0, 0, "_bguardwalkw3");
			AddAnimframe(walk[3], 0, 0, "_bguardwalkw2");
			stand[west] = "_bguardwalkw1";
			head[west] = "_bguardheadw1";
			AddAnimframe(FallAnim, 0, 0, "_bguardfall1");  // Falling
			AddAnimframe(FallAnim, 0, 0, "_bguardfall2");
			AddAnimframe(FallAnim, 0, 0, "_bguardfall3");
			AddAnimframe(FallAnim, 0, 0, "_bguardfall4");
			AddAnimframe(FallAnim, 0, 0, "_bguardfall5");
			DetectRadius = 120;
			SetMaxHealth("this", 150);
	   	}
	   	
	   	if ( param == 'r' )		// RED GUARD
	   	{
			// Add Frames to the walking animations
			AddAnimframe(walk[0], 0, 0, "_rguardwalkn1");  // walking north
			AddAnimframe(walk[0], 0, 0, "_rguardwalkn2");
			AddAnimframe(walk[0], 0, 0, "_rguardwalkn3");
			AddAnimframe(walk[0], 0, 0, "_rguardwalkn4");
			stand[north] = "_rguardwalkn1";
			head[north] = "_rguardheadn1";
			AddAnimframe(walk[1], 0, 0, "_rguardwalke1");  // walking east
			AddAnimframe(walk[1], 0, 0, "_rguardwalke2");
			AddAnimframe(walk[1], 0, 0, "_rguardwalke3");
			AddAnimframe(walk[1], 0, 0, "_rguardwalke2");
			stand[east] = "_rguardwalke1";
			head[east] = "_rguardheade1";
			AddAnimframe(walk[2], 0, 0, "_rguardwalks1");  // walking south
			AddAnimframe(walk[2], 0, 0, "_rguardwalks2");
			AddAnimframe(walk[2], 0, 0, "_rguardwalks3");
			AddAnimframe(walk[2], 0, 0, "_rguardwalks4");
			stand[south] = "_rguardwalks1";
			head[south] = "_rguardheads1";
			AddAnimframe(walk[3], 0, 0, "_rguardwalkw1");  // walking west
			AddAnimframe(walk[3], 0, 0, "_rguardwalkw2");
			AddAnimframe(walk[3], 0, 0, "_rguardwalkw3");
			AddAnimframe(walk[3], 0, 0, "_rguardwalkw2");
			stand[west] = "_rguardwalkw1";
			head[west] = "_rguardheadw1";
			AddAnimframe(FallAnim, 0, 0, "_rguardfall1");  // Falling
			AddAnimframe(FallAnim, 0, 0, "_rguardfall2");
			AddAnimframe(FallAnim, 0, 0, "_rguardfall3");
			AddAnimframe(FallAnim, 0, 0, "_rguardfall4");
			AddAnimframe(FallAnim, 0, 0, "_rguardfall5");
			DetectRadius = 130;
			SetMaxHealth("this", 200);
			SetSpeed( "this", 27 );
	   	}
		
		// Create the Death Animation using the enemy library - nmelib
		CreateAnim(8, DeadAnim);
		CallFunction("_enemylib", true, "CreateDeathAnim", "s", DeadAnim );
		
		// Set some general parameters
		SetHealth("this", GetMaxHealth("this"));
		SetActiveDist("this", 320);
		SetType("this", enemyType);
		SetDamage("this", 50);
		SetState("this", standing);
		SetAnimLoop(FallAnim, false);
	}

	if (!isActive("this") || isDead("this"))
		return;
		
	// Record the current state globally
	CurrentState = GetState("this");

	// Check for a collision with the player
	CallFunction("_enemylib", true, "CheckForPlayer", "NULL");
	
	// Load the weapons identifier into the weapon buffer
	GetString("this", 0, weapon);
	
	// Call a function for the enemy depending on its state
	switch( CurrentState )
	{
		case chasing:
			Chase();
		case standing:
			Stand( false );
		case walking:
			Walk( false );
		case hit:
			Hit();
		case dying:
			Die();
		case knocked:
			KnockBack();
		case falling:
			CallFunction("_enemylib", true, "Fall", "snn", FallAnim, GetWidth("_crabenemy"), GetHeight("_crabenemy"));
		case stunned:
			Stunned();
		case burning:
			Burn();
		case frozen:
			Freeze();
	}

	// Check for holes in the ground
	if ( CurrentState != falling ) 
		CallFunction("_enemylib", true, "CheckForHoles", "s", FallAnim);
}

//----------------------------------------
// Name: Chase()
//----------------------------------------
Chase()
{
	new dir = GetDirection("this");
	new width = GetAnimWidth(walk[ dir ]);		// Get the width of the current frame
	new x = GetX("this");
	new y = GetY("this");
	
	SetAnimSpeed(walk[ dir ], 12);
	SetSpeedMod("this", 20);
	
	// We wanna walk towards the player
	SetMoveAngle("this", CalculateAngle(x ,y, GetX("player1"), GetY("player1") ));
	
	// Move the enemy if the game is unpaused
	if (GetPauseLevel() == 0)
	{   
		// Check for Collisions
		if (!AngleCollide("this", 8, 5, 240, true, width / 2, 8))
			AngleMove("this");
			
		SetDirFromAngle("this");
	}

	Walk( true );
	
	// If the player is gone then stop chasing
	if ( !CallFunction("_enemylib", true, "CheckForChase", "nnnn", dir, x, y, DetectRadius ))
    {
    	new n;
    	for (n = 0; n < 4; n++)				// Reset the speeds of the animations
    		SetAnimSpeed(walk[ n ], 8);	
    	
    	SetState("this", standing);
    	SetSpeedMod("this", 0);				// Make the enemy walk at normal speed
    }
}

//----------------------------------------
// Name: Walk()
//----------------------------------------
Walk( justDraw )
{
	new dir = GetDirection("this");
	new width = GetAnimWidth(walk[ dir ]);		// Get the width of the current frame
	new x = GetX("this");
	new y = GetY("this");
	new CurrentFrame = GetAnimCount(walk[ dir ]);
		
	if ( !justDraw )
	{	
		// Move the enemy if the game is unpaused
		if (GetPauseLevel() == 0)
		{   
			// Sometimes randomly change direction
			if (random(600) == 1)
				SetState("this", standing);
			
			// Check for Collisions
			if (AngleCollide("this", 8, 5, 240, true, width / 2, 8))
				SetState("this", standing);
			else
				firstStand = false;
			
			// Move the enemy
			AngleMove("this");
		}
		
	    // Check to see if the player is around
	    if ( CallFunction("_enemylib", true, "CheckForChase", "nnnn", dir, x, y, DetectRadius ))
	    {
	    	SetState("this", chasing);
	    }
	}
	
    // Draw the guard walking
	if (isVisible("this"))
	{
		// Draw the Guards sword
		CallFunction( weapon, false, "Draw", "nnnnn", x, y, y + 16, dir, CurrentFrame);
		                                             
		// Draw the Guards body
		DrawAnim( walk[ dir ], x, y, y + 16);
				
		// Draw the Guards Head
		PutSprite( head[ dir ], x + (width / 2) - 8, y - headDist, y + 17);
		
		// Draw the Guards shadow
		PutSprite("shadow1", x + (width / 2) - 8, y + 2, 2);
	}
	
	// Set a collision rectangle around the Guards body
    SetCollisionRect("this", 0, false, x + adj, y + adj, x + width - adj, y + 16 - adj);
    
    // Record the current sprite in the walking anim as the last image
    GetAnimImage( walk[ dir ], LastImage );
}

//----------------------------------------
// Name: Stand()
//----------------------------------------
Stand( justDraw )
{
	static float: HeadCount = 0.00;		// Counter for turning the guards head
	new width;
	new x = GetX("this");
	new y = GetY("this");
	new dir = GetDirection("this");
	
	if (!justDraw && GetPauseLevel() == 0)
	{
		// Turn the guards head
		HeadCount += 300 * GetTimeDelta();
		
		// Pick a new head direction
		if ( HeadCount < 100 )
			headDir = dir - 1;
		else if ( HeadCount < 200 )
			headDir = dir;
		else if ( HeadCount < 300 )
			headDir = dir + 1;
		else
			headDir = dir;
		
		// Check the head direction is valid
		if ( headDir < 0 )
			headDir = 3;
		if ( headDir > 3 )
			headDir = 0;
			
		if ( CurrentState != dying )
		{
			// Make sure headcount isnt too large
			if ( HeadCount > 400 || firstStand )
			{
				HeadCount = 0.00;
				
				// Pick a new Random direction
				ChangeDirection("this");
				SetAngleFromDir("this");
				SetState("this", walking);
				firstStand = true;
			}
			
			// Check to see if the player is around
			if ( CheckForLineOfSight( x, y, DetectRadius ) )
			   	SetState("this", chasing); 	
		}
	}
	
	// Draw the guard standing
	if (isVisible("this"))
	{
		// Draw the Guards sword
		CallFunction( weapon, false, "Draw", "nnnnn", x, y, y + 16, dir, 0);
		
		// Draw the Guards body
		PutSprite( stand[ dir ], x, y, y + 16);
		
		width = GetWidth( stand[ dir ] );
		
		// Draw the Guards Head
		PutSprite( head[ headDir ], x + (width / 2) - 8, y - headDist, y + 16);
		
		// Draw the Guards shadow
		PutSprite("shadow1", x + (width / 2) - 8, y + 2, 2);
	}
	
	// Set a collision rectangle around the Guards body
    SetCollisionRect("this", 0, false, x + adj, y + adj, x + width - adj, y + 16 - adj);
    LastImage = stand[ dir ];
}

//----------------------------------------
// Name: HitByWeapon(wtype[], damage, x, y)
//----------------------------------------
public HitByWeapon(wtype[], damage, x, y)
{
	new state = GetState("this");
   	if (state == hit || state == dying || state == burning )
      	return;
      	
    // Check if this enemy was hit by a weapon that can stun
	if ( !strcmp( wtype, "stun" ) )
	{
		if (state != stunned && state != frozen)
		{
			StunCount = float(damage);
			SetState("this", stunned);
		}
		return;
	}
      
    // Check if this enemy was hit by a fire weapon
    if ( !strcmp( wtype, "fire" ) )
    {
    	// Set the enemy on fire - watch them burn muhahahaha
    	if (CallFunction("_enemylib", true, "SetOnFire", "s", LastImage))
    		StunCount = 32.00;  // function succeded, make the enemy stunned for a while then kill them
    	return;
    }
    
    // Check if this enemy was hit by an ice weapon
    if ( !strcmp( wtype, "ice" ) )
    {
    	// Put this enemy on ice
    	CallFunction("_enemylib", true, "BeginFreeze", "s", LastImage);
    	return;
    }

   	HitCount = 0.00;
	CallFunction("_enemylib", true, "BeginHit", "nnn", damage, x, y );
}

//----------------------------------------
// Name: Hit()
//----------------------------------------
Hit()
{
	const MaxColors = 5;
   	new colors[MaxColors][3] = { {19,125,19}, {253,211,65}, {225,88,5}, {32,211,238}, {238,32,32} };
   	new dir = GetDirection("this");
	new width = GetAnimWidth(walk[ dir ]);		// Get the width of the current frame
	new x = GetX("this");
	new y = GetY("this");
	new CurrentFrame = GetAnimCount(walk[ dir ]);
	new r = colors[ floatround(HitCount * 20.0) % MaxColors ][0];
	new g = colors[ floatround(HitCount * 20.0) % MaxColors ][1];
	new b = colors[ floatround(HitCount * 20.0) % MaxColors ][2];
	
	// Move the enemy if the game is completely unpaused
   	if (GetPauseLevel() == 0)
   	{
      	AngleMove("this");
      	AngleCollide("this", 5, 5, 240, 0, width / 2, 8);
   	}
   	
   	// Draw the Guard being hit
	if (isVisible("this"))
	{
		// Draw the Guards sword
		CallFunction( weapon, false, "Draw", "nnnnn", x, y, y + 16, dir, CurrentFrame);
		                                             
		// Draw the Guards body
		DrawAnim( walk[ dir ], x, y, y + 16, 0, r, g, b);
				
		// Draw the Guards Head
		PutSprite( head[ dir ], x + (width / 2) - 8, y - headDist, y + 17, 0, r, g, b);
		
		// Draw the Guards shadow
		PutSprite("shadow1", x + (width / 2) - 8, y + 2, 2);
	}
	
	// Record the current sprite in the walking anim as the last image
    GetAnimImage( walk[ dir ], LastImage );
   	
   	// increment and check the hit counter
   	HitCount += GetTimeDelta();

   	if (HitCount >= 0.23)
   	{
      	// Leave the Hit state
      	SetState("this", standing); 
      	SetSpeedMod("this", 0);
   	}
}

//----------------------------------------
// Name: Die()
//----------------------------------------
Die()
{		
    // Draw the enemy standing still
    if (GetAnimCount(DeadAnim) < 5)
        Stand( true );   
                
    // Overlay the death animation over the enemy
    CallFunction("_enemylib", true, "HandleDying", "ss", DeadAnim, LastImage);   
}

//--------------------------------------------------------------
// Name: BeginKnockBack()
// Desc: Knocks the enemy back without damaging it
//--------------------------------------------------------------
public BeginKnockBack(x, y )
{
	new state = GetState("this");
	if (state == dying || state == falling || state == knocked || state == hit || isDead("this"))
		return;
	
	PlaySound("_swordclash.wav", 240);
			
	// Work out a new move angle to move
	new Angle = CalculateAngle( x, y,  GetX("this"), GetY("this"));
	KnockCount = 0.00;
	
	ClearCollisionRect("this", 0); 
	SetMoveAngle("this", Angle );
	SetSpeedMod("this", 50 );			
	SetState("this", knocked );
}

//----------------------------------------
// Name: KnockBack()
//----------------------------------------
KnockBack()
{
	new dir = GetDirection("this");
	new width = GetAnimWidth(walk[ dir ]);		// Get the width of the current frame
	
	// Move the player if the game is completely unpaused
	if (GetPauseLevel() == 0)
	{
		AngleMove("this");
		AngleCollide("this", 5, 5, 240, 0, width / 2, 8);
	}
	
	Walk( true );
	
	// Check the Knock counter
	KnockCount += 100 * GetTimeDelta();
	
	if (KnockCount >= 20)
	{
		// Leave the Knocked state
		SetState("this", standing); 
		SetSpeedMod("this", 0);
	}
}

//----------------------------------------
// Name: Stunned()
//----------------------------------------
Stunned()
{
	// Display the enemy stood still
	headDir = GetDirection("this");
	Stand( true );
	
	// decrement the Stun counter
	StunCount -= 10 * GetTimeDelta();
	CallFunction("_enemylib", true, "Stunned", "n", floatround(StunCount));
}

//----------------------------------------
// Name: Burn()
//----------------------------------------
Burn()
{
	// This function should be called when the enemy is the the burning state
	// Use the stunned state to make the enemy stand still while they burn
	Stunned();	
	
	// if the stun count gets below a certain level then kill then enemy
	if (StunCount <= 12)
		CallFunction("_enemylib", true, "KillEnemy", "NULL");
}

//----------------------------------------
// Name: Freeze()
//----------------------------------------
Freeze()
{
	// Draw the enemy in a standing position, but draw them blue
	new x = GetX("this");
	new y = GetY("this");
	new dir = GetDirection("this");
	new width = GetWidth( stand[ dir ] );
	headDir = dir;
	
	// Draw the enemy standing
	if (isVisible("this"))
	{
		CallFunction( weapon, false, "Draw", "nnnnn", x, y, y + 16, dir, 0);
		PutSprite( stand[ dir ], x, y, y + 16, 0, 100, 100, 255);
		PutSprite( head[ headDir ], x + (width / 2) - 8, y - headDist, y + 16, 0, 100, 100, 255);
		PutSprite("shadow1", x + (width / 2) - 8, y + 2, 2);
	}
}

//----------------------------------------
// Name: SetHead()
//----------------------------------------
public SetHead( HeadNum )
{
	// Call this function from a screen script, and call it only once, at the moment
	// there are 3 heads to choose from 0,1,2
	new n;
	// Just modifies the sprite name for each head sprite to change the number at the end...
	for (n = 0; n < 4; n ++)
		head[n][ strlen( head[n] ) - 1] = HeadNum + 49;
}

//----------------------------------------
// Name: SetWeapon()
//----------------------------------------
public SetWeapon( Weapon[] )
{
	// Only allow 1 weapon change, otherwise people might try and call this function
	// every frame or somthing stupid like that.
	if (AlreadySetWeapon)
		return;
		
	// Call this function from a screen script, and call it only once
	// Delete the existing weapon
	GetString("this", 0, weapon);
	DeleteEntity(weapon);
	
	// Make a new one
	CreateEntity(Weapon, GetX("this"), GetY("this"), weapon);
	
	// Save this in string 0
	SetString("this", 0, weapon);
	AlreadySetWeapon = 1;
}

//-------------------------------------------------------------------------
// Name: CheckForLineOfSight()
// Desc: Checks if the player is in the enemy's line-of-sight.  
//-------------------------------------------------------------------------
public CheckForLineOfSight(ex,ey, detect)
{	
	new maskval;
	new maskmin = 0;
	new maskmax = 128;
	new x,y,fx,fy, rad = 0;
	new px = GetX("player1")+8;
	new py = GetY("player1")+8;
	new angle = CalculateAngle(ex,ey,px,py);	

	//this section is most likely wrong
	new view_angle = headDir * 90; 
	if ((view_angle - 33) < angle < (view_angle + 33))
		detect = 0;

	#if defined debug
		DrawLine(WorldToScreenX(ex), WorldToScreenY(ey), WorldToScreenX(px), WorldToScreenY(py), 1,24, 255, 26, 180);
	#endif
	while(rad < detect)
	{
		fx = floatround(rad*Cos(angle));
		fy = floatround(rad*Sin(angle));
		
		maskval = CheckMask(ex-fx, ey-fy);
		if (maskmin <= maskval <= maskmax)
			return 0;
		else if(NearPoint(ex-fx, ey-fy, px, py, 1))
			return 1; //The player is in the enemy's line-of-sight
		
		#if defined debug
		DrawRectangle(WorldToScreenX(ex-fx), WorldToScreenY(ey-fy), WorldToScreenX(ex-fx+1), WorldToScreenY(ey-fy+1), 255, 0, 0, 255, 0);
		#endif
		rad += 2;
	}
	return 0; // Enemy has poor eye sight & can't see player.	
}