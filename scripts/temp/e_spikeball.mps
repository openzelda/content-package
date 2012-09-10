/***********************************************
 * Copyright (c) 2004-2006 Editors
 * Changes:  
 *	29/06/02 [GD]: New file.
 ***********************************************/

#include <foreign/journey>
#include <float>
#include <core>

new MainImage[20] = "_spikeball";
new adj = 2;
new float: hbw = 0.00; 

//----------------------------------------
// Name: main()
//----------------------------------------
main()
{
   if (FirstRun())
   {
      // Set some general parameters
      SetActiveDist("this", 220);
      SetType("this", enemyType);
      SetSpeed( "this", 160 );   
      SetDamage("this", 50);
      SetDirection("this", east);
   }
   else
   {
	   if (!isActive("this"))
	      return;
	
	   // Check for a collision with the player
	   CallFunction("_enemylib", true, "CheckForPlayer", "NULL");
	   
	   MoveBall();
   }
}

//----------------------------------------
// Name: MoveBall()
//----------------------------------------
MoveBall()
{
	new width  = GetWidth(MainImage);
	new height = GetHeight(MainImage);

	// Move the enemy if the game is unpaused
	if (GetPauseLevel() == 0)
	{
		// Check for Collisions
		if (AngleCollide("this", 5, 5, 240, true, width / 2, height / 2))
		{
			new Dir = GetDirection("this");
			SoundPlayer();
			
			// has collided with somthing, move now in opposite direction
			if ( Dir == north)
				SetDirection("this", south );
			else if ( Dir == east )
				SetDirection("this", west );
			else if ( Dir == south )
				SetDirection("this", north );
			else if ( Dir == west )
				SetDirection("this", east );
		}
		
		// Move the enemy
		SetAngleFromDir("this");
		AngleMove("this");
	}

	new x = GetX("this");
	new y = GetY("this");

	// Draw the enemy 
	if (isVisible("this"))
		PutSprite(MainImage, x, y, y + height);

	// Set a collision rectangle around the Enemy
	SetCollisionRect("this", 0, false, x + adj, y + adj, x + width - adj, y + height - adj);
	if(hbw != 0)
		DelayHit();
}

//----------------------------------------
// Name: HitByWeapon(wtype[], damage, x, y)
//----------------------------------------
public HitByWeapon(wtype[], damage, x, y)
{    
	new Buffer[20];
	if(hbw != 0)
		return;
	hbw += GetTimeDelta();
	SetActiveDist("this",-2);
	// Check if this enemy was hit by the players sword
	if ( !strcmp( wtype, "sword" ) )
	{
		// Knock the player back
		CallFunction("player1", false, "BeginKnockBack", "nnnn", GetX("this") + 8, GetY("this") + 8, 40, 20);
		
		new px = (GetWidth(MainImage) / 2) + GetX("this");
		new py = (GetHeight(MainImage) / 2) + GetY("this");
		PlaySound("_swordclash.wav", 244);
		
		// Make a small explosion effect
		//CreateEntity("_explosion2", px, py, Buffer);
		return;
	}
   
}

SoundPlayer()
{
	if(hbw != 0)
		return;
	hbw +=GetTimeDelta();
	SetActiveDist("this",-2);
	PlaySound("_swordclash.wav", 244);
}

//---------------------------------------
// Name: DelayHit()
//---------------------------------------
DelayHit()
{
	hbw += GetTimeDelta();
	if(hbw >= 0.25)
	{
		hbw = 0.00;
		SetActiveDist("this", 220)
	}
}