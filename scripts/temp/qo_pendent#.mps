/***********************************************
 * Copyright (c) 2005-2006 lukex
 * Changes:  
 *	07/09/05 [lukex]: New file.
 ***********************************************/
/* TODO 
 - 
 - 
*/

#include <foreign/journey>
#include <core>
#include <float>


//==================================
//	Global Data
//==================================
// Create Strings to hold the sprite codes
new sprite[20] =  "qo_pendent1";

new width;
new height;
new param;
new x;
new y;
// Create a flag to idicate if the chest was just opened
new JustTaken = false;
new float: OpenCount = 0.00;

// Create another flag for fading the music back in
new MusicFadeIn = false;
new float: MusicFade = 50.00;

//----------------------------------------
// Name: main()
//----------------------------------------
main()
{
	if (FirstRun())
	{
		AllocateStrings("this", 1, 32);
		param = GetParam("this");
		//sprite[11] = param;

		// Set this entity's basic type
		SetType("this", otherType);
		width  = GetWidth(sprite);
		height = GetHeight(sprite);
		x = GetX("this");
		y = GetY("this");
		SetTakenFlag("this", 0);
	}



	if (MusicFadeIn)
	{
		MusicFade += 100 * GetTimeDelta();
		if (MusicFade > 200)
			MusicFade = 200.00;
		SetMusicVolume( floatround(MusicFade) );
		if (MusicFade == 200)
			MusicFadeIn = false;
	}
	
	if (isActive("this"))
	{
		if (!isTaken("this"))
		{

			PutSprite(sprite, x, y, 1);
			SetCollisionRect("this", 0, true, x, y, x + width, y + height);
			SetCollisionRect("this", 0, true, x + (width / 2) - 4, y + height, x + (width / 2) + 4, y + height +1);

 
			if ( CollideAll("this", "player1") )
			{
				// Check if the player is facing north
				if ( GetDirection("player1") == north )
				{
					TakeItem();
				}
			}
		}
		else
		{
			if (JustTaken)
				JustOpen();
		}
	}
}


//----------------------------------------
// Name: OpenChest()
//----------------------------------------
TakeItem()
{ 

	SetTakenFlag("this", true);

	// Set the IsOpen flag to true
	JustTaken = true;
	OpenCount = 0.00;

	// Pause the Game
	SetPauseLevel(1);

	// Set music volume a little lower
	SetMusicVolume(125);

}


//----------------------------------------
// Name: JustOpen()
//----------------------------------------
JustOpen()
{


	// Play sound only once
	if (OpenCount == 0.00)
	{
		SetMusicVolume(50);  // Set music volume even lower
		PlaySound("_chestitem.wav", 240);
	}

	// Increment the Counter
	OpenCount += 1 * GetTimeDelta();

	// Show the Item floating above the Chest
	PutSprite(sprite, x ,  y - (floatround(OpenCount * 30)),  y);

	// if 1 second hasnt passed then return
	if (OpenCount < 1)
	{
		SetVisibleFlag("player1", 0);
		PutSprite("__plls1", GetX("player1"), GetY("player1"), 1);
		PutSprite("__plhs3", GetX("player1"), GetY("player1")- 8 , 10);//
		return;
	}
	SetVisibleFlag("player1", 1);
	SetPauseLevel(0);

	// Set the music to fade back in
	MusicFadeIn = true;

	new targetDoor[32];
	GetString("this", 0, targetDoor);
	CallFunction("_doorlib", false, "StartDoorTrans", "sn", targetDoor, 5 );

}






