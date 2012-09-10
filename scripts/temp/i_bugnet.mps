/***********************************************
 * _bugnet.zes
 * 
 * Author: Raichu19192
 * Date:   
 *
 * Desc: Used to catch fairies and bees but you can easly add more things to catch 
 *
 * bugnet[1].spt
 *         
 ***********************************************/
#include <animation>
#include <foreign/journey>

new swordn[20];
new sworde[20];
new swordw[20];
new swords[20];
new CollectItem = false;
//I hope this works for the net
new simage[8][20] = {"net1", "net2", "net3", "net4", "net5", "net6", "net7", "net8"};
new scol[8][8] = {{1,1,11,7,0,8,15,14},{2,0,14,9,10,9,12,14},{1,0,13,5,2,5,14,15},\
				  {0,10,5,12,5,3,15,14},{0,10,15,7,4,7,14,14},{4,0,13,6,2,6,14,15},\
				  {5,0,13,4,1,4,14,15},{0,2,15,6,0,6,11,14}};                   
                    

/* Create an array to hold the x,y points for the collision rectangles for each sword sprite
   17 sword frames * 8 points (2 Rectangles) */


main()
{
	if (FirstRun())
   {
      // Set this entity's basic type
      SetType("this", weaponType);//Sorta
      SetDamage("this", 0);
      SetImage("this", "_bugneticon1");
      SetOwnedFlag("this", true);		// this sword is always avaiable on the menu
      
      // Create 2 string for the weapons descriptions
      AllocateStrings("this", 2, 64);	
      SetString("this", 0, "You got a bug net. Now do you have a bottle?"); 	// For Chests
      SetString("this", 1, "Bug Net"); 				// For menu

      // Create the Animations
      CreateAnim(24, swordn);
      CreateAnim(24, sworde);
      CreateAnim(24, swords); 
      CreateAnim(24, swordw);

      // make sure the animations dont loop back to the start, we only want
      // the swiping animation once.
      SetAnimLoop(swordn, false);
      SetAnimLoop(sworde, false);
      SetAnimLoop(swords, false);
      SetAnimLoop(swordw, false);

      // Add Frames to all Animations
      AddAnimframe(swordn, 0, -9, "__swdn4");
      AddAnimframe(swordn, 0, -9, "__swdn2");
      AddAnimframe(swordn, 0, -9, "__swdn1");
      

      AddAnimframe(sworde, 0, -9, "__swde2");
      AddAnimframe(sworde, 0, -9, "__swde3");
      AddAnimframe(sworde, 0, -9, "__swde5");
      

      AddAnimframe(swords, 0, -9, "__swds4");
      AddAnimframe(swords, 0, -9, "__swds2");
      AddAnimframe(swords, 0, -9, "__swds1");
      

      AddAnimframe(swordw, 0, -9, "__swdw5");
      AddAnimframe(swordw, 0, -9, "__swdw3");
      AddAnimframe(swordw, 0, -9, "__swdw2");
      
   }
   
   SetActiveDist("this", -1); 
}


//----------------------------------------
// Name: Init()
//----------------------------------------
public Init()
{
   /* This function should be called by the Player script every
      time just before the weapon is used, it resets all animations
      and makes sure everything is ready to go */

   // Reset all animations
   SetAnimCount(swordn, 0);
   SetAnimCount(sworde, 0);
   SetAnimCount(swords, 0);
   SetAnimCount(swordw, 0);
   CollectItem = false;

   // Set the Position and Direction of this entity to match the player's
   SetX("this", GetX("player1"));
   SetY("this", GetY("player1"));
   SetDirection("this", GetDirection("player1"));
   
}


//----------------------------------------
// Name: DrawWeapon()
//----------------------------------------
public DrawWeapon()
{
   new anim[20];
   new currentimg[20];
   new swordimages[3];	
   new xoff[3];            // X and Y offsets for the sword images
   new yoff[3];	
   new AnimCount;
   new x = GetX("this");
   new y = GetY("this");
   new dir = GetDirection("this");

   // ====================================================
   /* Setup the player animation and the sword image based
      on the direction this entity is facing */
   // ====================================================
   if ( dir == north)
   {
      anim = swordn;
      swordimages = {0,1,2};
      xoff = {-15, -8, 11};
      yoff = {-1, -6, -4};
   }
   else if ( dir == east)
   {
      anim = sworde;
      swordimages = {2,3,4};
      xoff = {13, 5, 10};
      yoff = {-2, 14, 18};
   }
   else if ( dir == south)
   {
      anim = swords;
      swordimages = {4,5,6};
      xoff = {15, 3, -10};
      yoff = {12, 17, 14};
   }
   else if ( dir == west)
   {
      anim = swordw;
      swordimages = {6,7,0};
      xoff = {-8, -15, -14}; 
      yoff = {19, 10, 0};
   }

   // Get the width and height of the Animation
   new width  = GetAnimWidth(anim);
   new height = GetAnimHeight(anim);
   new sx;
   new sy;
   
   // ========================================================
   // Draw the Player Animation and the sword image seperately
   // ========================================================
   if (isVisible("player1"))
   {
      AnimCount = GetAnimCount(anim);
      // Draw the image of the sword
      sx = x + xoff[AnimCount];
      sy = y + yoff[AnimCount] - 9;
      if(dir == north)
      {
      	     PutSprite(simage[swordimages[AnimCount]], \
                                         sx, sy, y + height);
      }
      
      // Draw the Player
      DrawAnim(anim, x, y, y + height);
 
      if(dir != north)
      {
      	PutSprite(simage[swordimages[AnimCount]], \
                                         sx, sy, y + height);
      }

      // Draw the Player's shadow
      PutSprite("shadow1", x, y, 2);
   }
   else
      IncrementAnim(anim);

   // ========================================================================
   /* Set the Collision Rectangles for the sword, this entity uses 2 collision
      rectangles along the blade of the sword for good collision detection. */
   // ========================================================================
   SetCollisionRect("this", 0, false, sx + scol[swordimages[AnimCount]][0], 
                                      sy + scol[swordimages[AnimCount]][1], 
                                      sx + scol[swordimages[AnimCount]][2],  
                                      sy + scol[swordimages[AnimCount]][3]);

   SetCollisionRect("this", 1, false, sx + scol[swordimages[AnimCount]][4], 
                                      sy + scol[swordimages[AnimCount]][5], 
                                      sx + scol[swordimages[AnimCount]][6],  
                                      sy + scol[swordimages[AnimCount]][7]);

   // Check to see if the sword hits anything
   CheckForHit();
   
   // Check if the weapon animation is over
   if (FinishedAnim(anim))
   {
      // Return control back to player entity
      SetState("player1", standing);
      return -1;
   }
}


//----------------------------------------
// Name: CheckForHit()
//----------------------------------------
CheckForHit()
{
   // No need to check for collisions when we already have caught something
   if(CollectItem)
   	return;
   new temp[20];
  
   // Go to the start of the Entity List
   StartEntity(80);
   
   // Loop through all the entities within a certain distance
   do
   {
      ToString(GetCurrentEntity(), temp);
       
      if (isActive(temp) && GetType(temp) != playerType )
      {
         // Check if the sword collides with the current entity
         if (Collide("this", temp))
         {
    		if(CallFunction(temp, false, "HitByWeapon", "snnn", \
               "Bugnet", GetDamage("this"), GetX("this"), GetY("this")))
            	CollectItem = true;   
            return;   
        }
     }
   }while( NextEntity() )
  

}

