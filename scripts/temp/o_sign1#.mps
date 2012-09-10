/***********************************************
 * Copyright (c) 2004-2006 Editors
 * Changes:  
 *	04/09/02 [The Chemist]: New file.
 ***********************************************/

#include <foreign/journey>
#include <animation>


//==================================
//   Global Data
//==================================

new MainImage[20];
new width;    // The Width and Height of the main sprite
new height;
new param;

//----------------------------------------
// Name: main()
//----------------------------------------
main()
{
	if (FirstRun())
  	{
    		param = GetParam("this");
	    	AllocateStrings("this", 1, 900);
		// Setup some general parameters
		SetType("this", otherType);
    		SetString("this", 0, "There are some strange carvings on this post");
	    	SetActiveInGroups("this", true);
    	
		if ( param == '1' )
		{
			MainImage = "_sign11";
			SetImage("this", "_sign11");
		}
		if ( param == '2' )
		{
			MainImage = "_sign12";
			SetImage("this", "_sign12");
		}

		// Record the width and height of the main sprite for later use
		width  = GetWidth(MainImage);
		height = GetHeight(MainImage);
  	}

	new yDepth = 2;
	new x = GetX("this");
	new y = GetY("this");
  
	// Draw The main Sprite
	PutSprite(MainImage, x, y, height);
  
	if (isVisible("this"))
	{ 
		if (isActive("this"))
		{
			// Set a solid collision rectangle
			SetCollisionRect("this", 0, true, x, y, x + width, y + height);
         
			// Check if the Player wants to read the sign
			CheckForRead();
		}
	}
}

//----------------------------------------
// Name: CheckForRead()
//----------------------------------------
CheckForRead()
{   
	// Check the player is facing north
	if (GetDirection("player1") == north && (GetY("player1") >= (GetY("this") + 16)))
	{
		// Check if the player is pressing the read key
		if ( QKey() && GetPauseLevel() == 0)
		{
			// Check the player is near the post
			if (Collide("this", "player1"))
			{
				CallFunction("_misclib", true, "ShowTextBox", "sn", "this", 0);   
			}
		}  		
	}
} 