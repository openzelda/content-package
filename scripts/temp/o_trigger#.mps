/***********************************************
 * Copyright (c) 2002-2005 Editors, lukex
 * Changes:  
 *	21/09/2002 [lukex]: New file.
 ***********************************************/

#include <foreign/journey>

new width;
new height;
new image[20];
main()
{
	if (FirstRun())
	{
		new param;
		param = GetParam("this");
		if (param == 'a')
			image = "o_triggera";
		if (param == 'b')
			image = "o_triggerb";
		if (param == 'c')
			image = "o_triggerc";
			
		width = GetWidth(image);
		height = GetHeight(image);
	}
	
	if (isActive("this"))
	{
		new x = GetX("this");
		new y = GetY("this");
		SetCollisionRect("this", 0, false, x - 2, y- 2, x + height - 2, y + width - 2);
		if (Collide("player1", "this")) {
			SetPushedFlag("this", true);
		} else {
			SetPushedFlag("this", false);
		}
	}
}
