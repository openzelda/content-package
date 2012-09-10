/* This file is Public Domain */
/************************************************************************
* level7_pipend# Entity Script
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
*		  must be in the same group, however, these allow inter-group travel,
*		  so long as you DONT link together 2 facing the same way, and they MUST
*		  be in different groups. use them as you do a door.
*
***********************************************************************/
#include <foreign/journey>
//#include <counter>
#include <core>

new ImgStr[20];		//used to store the image of the pipe entrance
new width;		    // Used to store the width and height of the pipe
new height;
new param;			// Will hold the parameter passed to this script
new x;
new y;
new adj = 5; //dont ask
new thismove = false;
new otherpipe[20];
new LinkSpeed = 0;

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
			SetDirection("this", north);
			ImgStr = "_level7_pipendn";
		}else if ( param == 'e' )  // East
		{
			SetDirection("this", east);
			ImgStr = "_level7_pipende";
		}else if ( param == 's' )  // South
		{
			SetDirection("this", south);
			ImgStr = "_level7_pipends";
		}else if ( param == 'w' )  // West
		{
			SetDirection("this", west)
			ImgStr = "_level7_pipendw";
		}
		// Set the active distance for this entity
		SetActiveDist("this", 1000);
		
		// Set this entity's basic type
		SetType("this", doorType);   //sort of
		
		AllocateStrings("this", 1, 20);
		
		// Record the width and height of the main sprite for later use
		width  = GetWidth(ImgStr);
		height = GetHeight(ImgStr);
		x = GetX("this");
        y = GetY("this");
        
		SetInteractingFlag("this", false);
		LinkSpeed = GetSpeed("player1");
	}

    PutSprite(ImgStr, x , y, 99999);

	//create a collision rectangle around this pipe
	SetCollisionRect("this", 0, true, x + adj, y + adj, x + width - adj, y + height - adj);
	GetString("this", 0, otherpipe);
		
		// Check if the Player is standing in the doorway
		if ( CollideAll("this", "player1") )
			SetInteractingFlag("this", true);     // Set the Interacting Flag to true
		else
			SetInteractingFlag("this", false);
			
	if (isInteracting("this") && GetPauseLevel() == 2)
	{
		thismove = true;
		if (GetDirection("this") == GetDirection("player1"))
		{
			//SetPauseLevel(0);
			//CallFunction("_doorlib", true, "MoveToOtherDoor", "NULL");	// Maybe move to another door
			if (strlen(otherpipe) >= 2)
			{
				SetPosition("player1", GetX(otherpipe), GetY(otherpipe));
			}
			else
			{
				SetVisibleFlag("player1", true);
				SetPauseLevel(0);
			}
		}
		else
		{
			//SetPauseLevel(2);
			if (param == 'n')
			{
				SetDirection("player1", south);
				SetMoveAngle("player1", 270);
			}else if (param == 'e')
			{
				SetDirection("player1", west);
				SetMoveAngle("player1", 0);
			}else if (param == 's')
			{
				SetDirection("player1", north);
				SetMoveAngle("player1", 90);
			}else if (param == 'w')
			{
				SetDirection("player1", east);
				SetMoveAngle("player1", 180);
			}
		}
	}
	if (GetPauseLevel() == 2 && thismove == true)
	{
		AngleMove("player1");
		if (!isActive("this"))
		{
			SetPauseLevel(0);
			SetVisibleFlag("player1", true);
		}
	}
	if (LinkSpeed == GetSpeed("player1"))
		thismove = false;
}