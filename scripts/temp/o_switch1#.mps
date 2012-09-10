/***********************************************
 * Copyright (c) 2004-2006 Editors
 * Changes:  
 *	07/07/02 [GD + Switch contest entries]: New file.
 ***********************************************/

#include <foreign/journey>
#include <core>

//==================================
//   Global Data
//==================================
// Create Strings to hold the sprite codes
new UpSpr[20];
new DnSpr[20];
new width;
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
		
		if ( param == 'a' ) // Normal switch
		{
			UpSpr = "_switch1a";
			DnSpr = "_switch1aa";
		}
		else if ( param == 'b' ) // Green Dungeon switch
		{
			UpSpr = "_switch1b";
			DnSpr = "_nullsprite";	// No sprite
		}
		
		// Record the width and height of the main sprite for later use
		width  = GetWidth(UpSpr);
		height = GetHeight(UpSpr);
		SetImage("this", UpSpr);
		SetType("this", switchType);
	}
	
	if (isActive("this"))
	{
		new x = GetX("this");
		new y = GetY("this");
		SetCollisionRect("this", 0, false, x + 4, y + 4, x + 12, y + 12);
		// ==============================================
		// Check if the Player is standing on the switch
		// ==============================================
		// You could also use the Collide() fuction for this.
		if (NearPoint(x, y - (height / 3), GetX("player1"), GetY("player1"), width / 3) \
			|| GetValue("this", 0) == 1 )
		SetPushedFlag("this", true);
		else
		SetPushedFlag("this", false);
		
		// ==============================================
		// Draw the switch in its current state
		// ==============================================
		if (!isPushed("this"))
		{
		// Draw the Switch if visible
		if (isVisible("this"))
		PutSprite(UpSpr, x, y, 1);
		}
		else
		{
		// Draw the pushed Switch if visible
		if (isVisible("this"))
		PutSprite(DnSpr, x, y, 1);
		}
	}
}





