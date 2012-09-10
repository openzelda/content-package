/* This file is Public Domain */
/************************************************************************
* level7_pipe# Entity Script
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
*		  must be in the same group, and link cannot move more than
*		  1000 pixels away from the launcher during transit.
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
new LinkSpeed = 0;
new thismove = false;

//----------------------------------------
// Name: main()
//----------------------------------------
main()
{
	if (FirstRun())
	{
		// Get the parameter passed to this script from the sprite code
		param = GetParam("this");

		if ( param == 'n' )       // North
		{
			SetDirection("this", south);
			ImgStr = "_level7_pipen";
		}else if ( param == 'e' )  // East
		{
			SetDirection("this", west);
			ImgStr = "_level7_pipee";
		}else if ( param == 's' )  // South
		{
			SetDirection("this", north);
			ImgStr = "_level7_pipes";
		}else if ( param == 'w' )  // West
		{
			SetDirection("this", east)
			ImgStr = "_level7_pipew";
		}
		// Set the active distance for this entity
		SetActiveDist("this", 1000);
		
		// Set this entity's basic type
		SetType("this", doorType);   //sort of
		
		// Record the width and height of the main sprite for later use
		width  = GetWidth(ImgStr);
		height = GetHeight(ImgStr);
		x = GetX("this");
        y = GetY("this");
        
		SetInteractingFlag("this", false);
		LinkSpeed = GetSpeed("player1");
	}
    PutSprite(ImgStr, x , y, y);

	//create a collision rectangle around this pipe
	SetCollisionRect("this", 0, false, x + adj, y + adj, x + width - adj, y + height - adj);
		
		// Check if the Player is standing in the doorway
		if ( CollideAll("this", "player1") )
			SetInteractingFlag("this", true);     // Set the Interacting Flag to true
		else
			SetInteractingFlag("this", false);
			
	if (isInteracting("this"))
	{
		
		if (GetDirection("this") == GetDirection("player1"))
		{
			SetPauseLevel(2);
			SetVisibleFlag("player1", false);
			//if (thismove == false)
				//LinkSpeed = GetSpeed("player1");
			thismove = true
			SetSpeed("player1", 120);
			SetDirection("player1", GetDirection("this"));
			
		}else{
			SetVisibleFlag("player1", true);
			SetSpeed("player1", LinkSpeed);
			SetPauseLevel(0);
		}
	}
	if (LinkSpeed == GetSpeed("player1"))
		thismove = false;
	if (GetPauseLevel() == 2 && thismove == true)
	{
		AngleMove("player1");
		if (!isActive("this") || WKey() == true)
		{
			SetPauseLevel(0);
			SetVisibleFlag("player1", true);
			SetPosition("player1", x, y); // emergancy restoration of position
		}
	}
}