/***********************************************
 * Copyright (c) 2004-2006 Editors
 * Changes:  
 *	01/08/02 [The Chemist]: New file.
 ***********************************************/

#include <foreign/journey>
#include <animation>
#include <float>
#include <core>

//   Global Data
new MainImage[20] = "e_treesnout";  // Main Sprite for snout
new EyeImage[20] = "e_treesnouti"; // The simple sprite for each eye
new AwakeAnim[20];	    // String holds identifier for the 'twitching' animation

new adj = 1;		    // Collision rectangle adjustment value
new WobbleLength = 1	// Length of time (in seconds) the snout wobbles when awakened
new AwakeLength = 60	// Length of time (in seconds) the tree is 'awake'

new x;					// Variables used for coordinates
new y;					//
new height;				//
new width;				//

new float: AwakeCount = 0.00; // Used to count the time of being 'awake'
new float: WobbleCount = 0.00;// Used to count the time of being 'awake'

new Awakened = false;	// Boolean flag for the tree being active or 'awakened'
new Talking = false		// Boolean flag used for NPC talking

//----------------------------------------
// Name: main()
//----------------------------------------
main()
{
	if (FirstRun())
	{
		// Create the Animation used when awakening and thereafter
		CreateAnim(10, AwakeAnim);
		AddAnimframe(AwakeAnim, 0, 0, "_doutside_snout");
		AddAnimframe(AwakeAnim, 0, 0, "_doutside_snouta");
		AddAnimframe(AwakeAnim, 0, 0, "_doutside_snout");
		AddAnimframe(AwakeAnim, 0, 0, "_doutside_snoutb");
		
		// Set some general parameters
		SetActiveDist("this", 320);
		SetType("this", npcType);
		AllocateStrings("this", 10, 640 );   
		SetActiveFlag("this", false);
		SetString("this", 0, "Quit bothering me! And watch where you're going when you dash around!");	
		
		// Set values to the global variables
		x = GetX("this");
		y = GetY("this");
		width  = GetWidth(MainImage);
		height = GetHeight(MainImage);
	}
	
	// Set a collision rectangle around the Enemy
	SetCollisionRect("this", 0, true, x + adj, y + adj, x + width - adj, y + height - adj);
	
	// Draw the eyes on the tree
	Stare();
	
	if (!Awakened)
	{
		// Nullsprite is used for when it returns to rest again in Deactivate()
		PutSprite("_nullsprite", x, y, 0);
		AwakeCount = 0.00;
		if (Collide("this", "player1") && GetState("player1") != knocked )
		{
			new EntName[20];
			SetActiveFlag("this", true);
			CallFunction("player1", false, "BeginKnockBack", "nnnn", GetX("this") + 8, GetY("this") + 12, 60, 50);
			CreateEntity("w_bomb1", x, y + height + 1, EntName);
			SoundFX();
		}
	}
	
	if (isActive("this"))
	{
		if (Awakened)
		{
			WobbleCount = 0.00
			SetAnimSpeed(AwakeAnim, 3);
			DrawAnim(AwakeAnim, x, y, height);
			
			// Check if the Player wants to talk to the tree
           	CheckForTalk();
           	
           	// Count the time until it returns to normal
           	Deactivate();
		}
		else
			Wobble();
	}
}


//----------------------------------------
// Name: Stare()
//----------------------------------------
Stare()
{
	// This Procedure draws the eyes which follow the player
	
	// Declare new vairables
	new px = GetX("player1");
	new py = GetY("player1");
	new leye = x - 5
	new reye = x + width - 3
	new yeye = y - 9;	
	
	if ( py < (yeye - 60))
	{
		PutSprite(EyeImage, leye, yeye, 999999);
		PutSprite(EyeImage, reye, yeye, 999999);
	}
	else
	{
		if ( py >= (yeye - 60) && py < (yeye + 10) && px < leye)
		{
			PutSprite(EyeImage, leye - 2, yeye - 1, 999999);
			PutSprite(EyeImage, reye - 2, yeye - 1, 999999);
		}
		else
		{	
			if ( py >= (yeye - 80) && py < (yeye + 10) && px > (reye + 8))
			{
				PutSprite(EyeImage, leye + 2, yeye - 1, 999999);
				PutSprite(EyeImage, reye + 2, yeye - 1, 999999);
			}
			else
			{					
				if ( px < (leye - 40))
				{
					PutSprite(EyeImage, leye - 2, yeye, 999999);
					PutSprite(EyeImage, reye - 2, yeye, 999999);
				}
				if ( px >= (leye - 40) && px < (leye - 10))
				{
					PutSprite(EyeImage, leye - 1, yeye, 999999);
					PutSprite(EyeImage, reye - 1, yeye, 999999);
				}
				if ( px >= (leye - 10) && px <= (reye + 18))
				{
					PutSprite(EyeImage, leye, yeye, 999999);
					PutSprite(EyeImage, reye, yeye, 999999);
				}
				if ( px > (reye + 18) && px <= (reye + 48))
				{
					PutSprite(EyeImage, leye + 1, yeye, 999999);
					PutSprite(EyeImage, reye + 1, yeye, 999999);
				}
				if ( px > (reye + 48))
				{
					PutSprite(EyeImage, leye + 2, yeye, 999999);
					PutSprite(EyeImage, reye + 2, yeye, 999999);
				}
			}
		}
	}
}


//----------------------------------------
// Name: HitByWeapon(wtype[], damage, x, y)
//----------------------------------------
public HitByWeapon(wtype[], damage, x, y)
{
	// Check if this enemy was hit by a weapon that can stun
	if ( !strcmp( wtype, "sword" ))
	{
		// Knock the player back a lot
		SetActiveFlag("this", true);
		CallFunction("player1", false, "BeginKnockBack", "nnnn", GetX("this") + 8, GetY("this") + 12, 60, 30);
		SoundFX();
	}
}


//----------------------------------------
// Name: Wobble()
//----------------------------------------
Wobble()
{
	WobbleCount += 10 * GetTimeDelta();
	if (WobbleCount > (10 * WobbleLength) && GetPauseLevel() == 0)
		Awakened = true;
	DrawAnim(AwakeAnim, x, y, height);
	SetAnimSpeed(AwakeAnim, 10);
}


//----------------------------------------
// Name: Deactivate()
//----------------------------------------
Deactivate()
{
	AwakeCount += 10 * GetTimeDelta();
	if (AwakeCount > (10 * AwakeLength))
	{
		Awakened = false;
		SetActiveFlag("this", false);
	}
}


//----------------------------------------
// Name: CheckForTalk()
//----------------------------------------
CheckForTalk()
{   
   	// Check if the Player wants to talk to this NPC
	if ( CallFunction("_npclib", true, "CheckForTalk", "NULL") )
		Talking = true;
		
	// Check if the player has just finished talking to an NPC
	if (Talking && FinishedReading())
	{
		CallFunction("_npclib", true, "AfterTalk", "NULL");
		Talking = false;
	}
}


//----------------------------------------
// Name: SoundFX
//----------------------------------------
SoundFX()
{
	// Be sure to change the .wav file name if you have a different one
	PlaySound("_bounceoff.wav", 240);
}
	