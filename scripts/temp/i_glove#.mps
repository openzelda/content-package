/***********************************************
 * Copyright (c) 2004-2006 Editors
 * Changes:  
 *	04/07/02 [GD]: New file.
 ***********************************************/
#include <foreign/journey>

new Param;

main()
{
	if (FirstRun())
	{
		Param = GetParam("this");
		
		// Create a string for the description of the glove
      	AllocateStrings("this", 1, 128);	
      	
      	// Level 1 glove - the POWER GLOVE
      	// For lifting normal stones
      	if ( Param == '1' )
      	{	
      		SetString("this", 0, "You got the Power Glove!`You can feel strength in both hands! You can pick up and carry stones now!");	
      		SetLiftLevel("player1", 2);
      		SetImage("this", "_powerglove1");
      	}
      	// Level 2 glove - the Lunar Glove
      	// For picking up the dark stones
      	if ( Param == '2' )
      	{	
      		SetString("this", 0, "You got the Lunar Glove!`This mysterious green glove grants you more strength than the power glove!");	
      		SetLiftLevel("player1", 3);
      		SetImage("this", "_lunarglove1");
      	}
      	// Level 3 glove - the Titan's Mitt
      	// For lifting those huge stones
      	if ( Param == '3' )
      	{	
      		SetString("this", 0, "You got the Titan's Mitt!`Now you can lift the heaviest stones that were once impossible to budge.");	
      		SetLiftLevel("player1", 4);
      		SetImage("this", "_titanmitt1");
      	}
	}
	
	SetActiveDist("this", -1); 
}
