/***********************************************
 * Copyright (c) 2002-2005 Editors, The Chemist
 * Changes:  
 *	04/09/2003 [The Chemist]: New file.
 ***********************************************/
#include <animation>
#include <foreign/journey>
#include <float>

new MainImage[20] = "_Desert_cactus";

main()
{
   if (FirstRun())
   {
      // Set some general parameters
      SetActiveDist("this", 220);
      SetType("this", enemyType);
      SetDamage("this", 50);
   }
   else
   {
	   if (!isActive("this"))
	      return;
	
	   // Check for a collision with the player
	   CallFunction("_enemylib", true, "CheckForPlayer", "NULL");
   }
   
   	new width  = GetWidth(MainImage);
	new height = GetHeight(MainImage);
	
	new x = GetX("this");
	new y = GetY("this");
	
	if (isVisible("this"))
		PutSprite(MainImage, x, y, height);
		
	// Set a collision rectangle around the Enemy
	SetCollisionRect("this", 0, true, x, y, x + width, y + height);
}