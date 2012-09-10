/***********************************************
 * Open Legends Media License
 * Copyright (c) 2003-2005 Open Legends Project, lukex
 * Changes:  
 *	21/04/2003 [lukex]: New file.
 ***********************************************/
#include <foreign/journey>
	
main()
{
	if (FirstRun())
	{
		new param = GetParam("this");
		AllocateStrings("this", 1, 100);
		if (param == '1')
		{
			SetString("this", 0,  "You got the Level 1 Tunic!");		// For Chests
			SetImage("this", "playersuit1");
			CallFunction("player1", false, "ChangePlayerSuit", "n", 1)
		} 
		else if (param == '2')
		{
			SetString("this", 0,  "You got the Level 2 Tunic! YEAH");		// For Chests
			SetImage("this", "playersuit2");
			CallFunction("player1", false, "ChangePlayerSuit", "n", 2)
		}
		else if (param == '3')
		{
			SetString("this", 0,  "You got the Level 3 Tunic! YEAH");		// For Chests
			SetImage("this", "playersuit3");
			CallFunction("player1", false, "ChangePlayerSuit", "n", 3)
		}
	}
}