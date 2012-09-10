/***********************************************
 * Copyright (c) 2004-2006 Editors
 * Changes:  
 *	29/06/02 [GD / Satanman]: New file.
 ***********************************************/

#include <core>
#include <foreign/journey>
#include <animation>
#include <float>


//==================================
//   Global Data
//==================================
// Images for the Sign, change these to change how the sign looks
new mainSpr[20]   = "_sign01";
new underSpr[20]  = "_sign01a";
new ShadowSpr[20] = "_sign01b";

new justDestroyed = false;
new float: DestroyCount;
new width;    // The Width and Height of the main sprite
new height;
new draw_image = false;

//----------------------------------------
// Name: main()
//----------------------------------------
main()
{
  if (FirstRun())
  {
    AllocateStrings("this", 2, 900);
	new param;
	param = GetParam("this");
	mainSpr[6] = param;
	underSpr[6] = param;
	ShadowSpr[6] = param;
    // Setup some general parameters
    SetImage("this", mainSpr);
    SetWeight("this", 70);
    SetType("this", otherType);
    SetDamage("this", 50);
    SetActiveInGroups("this", true);

    // Record the width and height of the main sprite for later use
    width  = GetWidth(mainSpr);
    height = GetHeight(mainSpr);
  }

  new yDepth = 2;
  new x = GetX("this");
  new y = GetY("this");
  
  if (isVisible("this"))
  { 
     // Is this entity has been picked up then draw the sprite underneath
     if (isTaken("this"))
     {
     	// The yDepth should be the height of the player - so the bush can be drawn above the player
      	yDepth = y + 50 + height;	
        PutSprite(underSpr, GetInitialX("this"), GetInitialY("this"), 1);
        SetCollisionRect("this", 0, false, x, y, x + width, y + height);
     }
     else
     {
        // If it hasnt been picked up and is still active set a solid collision rect
        if (isActive("this"))
        {
           // Set a solid collision rectangle
           SetCollisionRect("this", 0, true, x, y, x + width, y + height);
         
           // Check if the Player wants to read the sign
           CheckForRead();
           if (FinishedReading())
				draw_image = false;    

           if (draw_image) {
	            new messageimage[20];    
	            GetString("this", 1, messageimage);
	            if (strlen(messageimage) >= 1) {
	            	DrawImage(messageimage, 160, 120, 255, 255, 255, 255, 0, 400);
	            }
           }
        }
      }
       
      if (isActive("this"))
      {
           // Draw The main Sprite & shadow
           PutSprite(mainSpr, GetX("this"), GetY("this"), yDepth);
           PutSprite(ShadowSpr, GetX("this"), GetY("this") + height, 1);
      }
    }

  if (justDestroyed)
    Destroy();
}

//----------------------------------------
// Name: CheckForRead()
//----------------------------------------
CheckForRead()
{   
   // Check the player is facing north
   if (GetDirection("player1") == north)
   {
      // Check if the player is pressing the read key
      if ( QKey() && GetPauseLevel() == 0)
      {
         // Check the player is near the sign
         if (Collide("this", "player1"))
         {
				CallFunction("_misclib", true, "ShowTextBox", "sn", "this", 0); 
				draw_image = true;
				SetState("player1", standing);
         }
      } 
      // Make it so that the sign cant be lifted from below
      SetLiftLevel("this", -1); 
   }
   else 
      SetLiftLevel("this", 1);
}

//--------------------------------------------------------
// Name: Thrown()
// Desc: Called when this entity is being thrown to check
//       for collision with enemies etc..
//--------------------------------------------------------
public Thrown()
{
   new temp[20];
   new x = GetX("this");
   new y = GetY("this");

   // Check if we hit any enemies - and damage them.
   // check all enemies within 60 pixels of the object
   StartEntity(60, x, y);

   // Loop through all the entities within a certain distance
   do
   {
      ToString(GetCurrentEntity(), temp);

      // Check for collision with enemies only
      if (GetType(temp) == enemyType && isActive(temp))  
      {
         if (Collide("this", temp))
         {
            CallFunction(temp, false, "HitByWeapon", "snnn", \
                         "throwobj", GetDamage("this"), x, y);
            return false;
         }
      }
   }while( NextEntity() )
   return true;
}

//----------------------------------------
// Name: BeginDestroy()
//----------------------------------------
public BeginDestroy()
{
   SetTakenFlag("this", true);
   SetActiveFlag("this", false);
   ClearCollisionRect("this", 0);
   justDestroyed = true;
   DestroyCount = 0.00;
   PlaySound("_potdestroy.wav", 240);
}

//----------------------------------------
// Name: Destroy()
//----------------------------------------
public Destroy()
{
   new n;
   new x = GetX("this") + 8;
   new y = GetY("this") + 6;

   const MaxFrames = 8;
   new DestroyImages[5][] = { "_sin01c", "_sin01d", "_sin01e", "_sin01f", "___none" };

   // 4 fragments over MaxFrames frames of animation
   new xpos[4][MaxFrames]  = { {-8,-10,-12,-14,-15,-17,0,0}, {0,1,1,1,1,1,1,1}, {0,1,2,4,5,6,7,0}, {-8,-9,-9,-9,-10,-11,-12,-11} };
   new ypos[4][MaxFrames]  = { {-7,-7,-6,-6,-6,-4,0,0}, {-7,-7,-10,-10,-11,-10,-11,-7}, {2,3,0,2,2,4,4,0}, {1,3,5,5,7,9,7,10} };
   new frame[4][MaxFrames] = { {0,0,1,0,0,1,4,4}, {1,2,3,2,3,1,0,1}, {2,1,0,1,0,1,0,4}, {0,0,1,0,1,0,0,1} };

   // Advance our animation counter
   DestroyCount += 17.0 * GetTimeDelta();

   // Draw the image of each fragment
   for( n = 0; n < 4; n++ )
   {
      PutSprite( DestroyImages[ frame[n][floatround(DestroyCount)] ], x + xpos[n][ floatround(DestroyCount) ], y + ypos[n][ floatround(DestroyCount) ], y + ypos[n][ floatround(DestroyCount) ]);
   }
    
   // if our animation counter goes too high then end the animation         
   if ( DestroyCount >= MaxFrames - 1)
   {
      // Set the coordinates of the entity back to the initial coordinates
      SetX("this", GetInitialX("this"));
      SetY("this", GetInitialY("this"));
      Respawn("this", 20);               // Respawn this entity after a period of time
      justDestroyed = false;
   }  
}
