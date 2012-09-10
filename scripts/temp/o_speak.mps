/***********************************************
 * Copyright (c) 2002-2005 Editors, lukex
 * Changes:  
 *	21/09/2002 [lukex]: New file.
 ***********************************************/

#define nodebug
#include <foreign/journey>


new x;
new y;
new dir;
new Talking = false;   
main()
{
	if (FirstRun())
  	{
	   AllocateStrings("this", 10, 640 );  
	
	   // Setup some general parameters
	   SetType("this", otherType);
	   SetImage("this", "_nullsprite");
	   SetActiveDist("this", 300)
	   x = GetX("this");
	   y = GetY("this");
	   SetDirection("this", south);
	   dir = GetDirection("this");
	}

	if (isActive("this"))
 	{
		if ( dir == south )
			SetCollisionRect("this", 0, false, x + 4, y + 14, x + 12, y + 20);
		else if ( dir == west )
			SetCollisionRect("this", 0, false, x, y, x + 16, y + 16);
		else if ( dir == north )
			SetCollisionRect("this", 0, false, x + 4, y - 4, x + 12, y + 4);
		else if ( dir == east )
			SetCollisionRect("this", 0, false, x, y, x + 16, y + 16);
			
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
}


