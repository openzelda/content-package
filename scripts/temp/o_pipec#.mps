/* This file is Public Domain */
/************************************************************************
* level7_pipec# Entity Script
* 
* Author: Satanman
* Date:   21 July 2002
*
* Desc:     A really cool pipe thingy. it simply flings link down
*           a network of pipes, with the help of corners and things,
*	 		there are a few in turtles rock
*
* Usage:  it's a self-sufficient script, simply place it in a level,
* 		  and if everythings lined up correctly, he should go flying
*         the pipes to his destination. Just remember - all paths
*		  must be in the same group, and these and the end must all be within
*		  1000 pixels of the start.
*
***********************************************************************/
#include <foreign/journey>
//#include <counter>
//#include <core>

new ImgStr[20];		//used to store the image of the pipe entrance
new width;		    // Used to store the width and height of the pipe
new height;
new param;			// Will hold the parameter passed to this script
new x;
new y;
new adj = 5; //dont ask

//----------------------------------------
// Name: main()
//----------------------------------------
main()
{
	if (FirstRun())
	{
		// Get the parameter passed to this script from the sprite code
		param = GetParam("this");

		if ( param == '1' )       // V>
		{
			//SetDirection("this", south);
			ImgStr = "_level7_pipec1";
		}else if ( param == '2' )  // <V
		{
			//SetDirection("this", west);
			ImgStr = "_level7_pipec2";
		}else if ( param == '3' )  // <^
		{
			//SetDirection("this", north);
			ImgStr = "_level7_pipec3";
		}else if ( param == '4' )  // ^>
		{
			//SetDirection("this", east);
			ImgStr = "_level7_pipec4";
		}
		// Set the active distance for this entity
		SetActiveDist("this", 190);
		
		// Set this entity's basic type
		SetType("this", doorType);   //sort of
		
		// Record the width and height of the main sprite for later use
		width  = GetWidth(ImgStr);
		height = GetHeight(ImgStr);
		x = GetX("this");
        y = GetY("this");
        
		SetInteractingFlag("this", false);
	}
    PutSprite(ImgStr, x , y, 99999);
	
		if ( param == '1' )       // V>
		{
			//create a collision rectangle around this pipe
			SetCollisionRect("this", 0, false, x, y, x + adj, y + height); // left
			SetCollisionRect("this", 1, false, x, y, x + width, y + adj); // top
		}else if ( param == '2' )  // <V
		{
			//create a collision rectangle around this pipe
			SetCollisionRect("this", 0, false, x, y, x + width, y + adj); // top
			SetCollisionRect("this", 1, false, x + width, y, x + width - adj, y + height); // right
		}else if ( param == '3' )  // <^
		{
			//create a collision rectangle around this pipe
			SetCollisionRect("this", 0, false, x, y + height, x + width, y + height - adj); // bottom
			SetCollisionRect("this", 1, false, x + width, y, x + width - adj, y + height); // right
		}else if ( param == '4' )  // ^>
		{
			//create a collision rectangle around this pipe
			SetCollisionRect("this", 0, false, x, y, x + adj, y + height); // left
			SetCollisionRect("this", 1, false, x, y + height, x + width, y + height - adj); // bottom
		}
		
	// Check if the Player is standing in the node
	if ( CollideAll("this", "player1") )
		SetInteractingFlag("this", true);     // Set the Interacting Flag to true
	else
		SetInteractingFlag("this", false);
			
	if (isInteracting("this") && GetPauseLevel() == 2)
	{
		PlaySound("_bombplaced.wav", 240);
		if ( param == '1' )       // V>
		{
			if (GetDirection("player1") == north)
			{
				SetMoveAngle("player1", 180); // east
				SetDirection("player1", east);
			}else if (GetDirection("player1") == west)
			{
				SetMoveAngle("player1", 270); // south
				SetDirection("player1", south);
			}
		}else if ( param == '2' )  // <V
		{
			if (GetDirection("player1") == north)
			{
				SetMoveAngle("player1", 0); // west
				SetDirection("player1", west);
			}else if (GetDirection("player1") == east)
			{
				SetMoveAngle("player1", 270); // south
				SetDirection("player1", south);
			}
		}else if ( param == '3' )  // <^
		{
			if (GetDirection("player1") == south)
			{
				//DrawText("hidly-ho!", 100, 200);
				SetMoveAngle("player1", 0); // west
				SetDirection("player1", west);
			}else if (GetDirection("player1") == east)
			{
				SetMoveAngle("player1", 90); // north
				SetDirection("player1", north);
			}
		}else if ( param == '4' )  // ^>
		{
			if (GetDirection("player1") == south)
			{
				SetMoveAngle("player1", 180); // east
				SetDirection("player1", east);
			}else if (GetDirection("player1") == west)
			{
				SetMoveAngle("player1", 90); // north
				SetDirection("player1", north);
			}
		}else{
			SetPauseLevel(0);
			SetVisibleFlag("player1", true);
		}
	}
	

}