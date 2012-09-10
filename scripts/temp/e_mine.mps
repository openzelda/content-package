/***********************************************
 * Copyright (c) 2002-2005 Editors, The Chemist
 * Changes:  
 *	04/09/2003 [The Chemist]: New file.
 ***********************************************/

#include <animation>
#include <foreign/journey>

new MainImage[20] = "e_mine"; // Name of the sprite
new adj = 2;	//Collision rectangle adjustment value

main()
{
	if (FirstRun())
   	{
    	SetActiveDist("this", 220);
    	SetType("this", otherType);
    }
   
   	new width  = GetWidth(MainImage);
	new height = GetHeight(MainImage);
	
	new x = GetX("this");
	new y = GetY("this");
	
	
		
	// Set a collision rectangle around the mine
	SetCollisionRect("this", 0, false, x + adj, y + adj, x + width - adj, y + 2 + adj);
   
	if (!isActive("this"))
		return;
	else
	{
		if (isVisible("this"))
		{
			PutSprite(MainImage, x, y, 0);
			new Ent[20];
			// Check the player is near the post
			if (Collide("this", "player1"))
			{
				CreateEntity("_explosion1", x + 8, y + 4, Ent);
				SetActiveFlag("this", false);
			}
		}
	}	
}

