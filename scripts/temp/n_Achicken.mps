/* This file is Public Domain */
/*************************************************************************
 * _Achicken Entity Script
 * 
 * Author: Satanman
 * Date:   30/06/02
 *
 * Desc:   A Script for a simple attack chicken. 
 *
 *         this is just an add-on to the big chicken
 *         
 *
 * Usage:  called by the main chicken. it's in a seperate script because
 *		   there are several on screen at once, so it must be small
 *         there's a 1 in 50 chance of getting a special chicken
 *
 * Sprites: _Chickensheet.spt
 *         
 ************************************************************************/
#include <foreign/journey>
#include <animation>
#include <float>
#include <core>

//==================================
//   Global Data
//==================================

new float: timer;
new adj = 5;		     // Collision rectangle adjustment value
new chickenanim[32];
new width;
new height;
new walkw[20];
new walke[20];
new Bcolour = 255;  //blue
new Rcolour = 255;  //red

//----------------------------------------
// Name: main()
//----------------------------------------
main()
{
   if (FirstRun())
   {
      // Create the animations
      CreateAnim(6, walkw);    // Walking animations
      CreateAnim(6, walke);    //walke, hehe
      
      // Add Frames to the wanking animations
      AddAnimframe(walkw, 0, 0, "_chickenwest1");  // walking west
      AddAnimframe(walkw, 0, 0, "_chickenwest2");

      AddAnimframe(walke, 0, 0, "_chickeneast1");  // walking east
      AddAnimframe(walke, 0, 0, "_chickeneast2");
      
      if (random(100) == 1)
      {
      	Bcolour = 0;
      	SetSpeed("this", 128 );
      	SetDamage("this", 500);   //Golden Chicken of justice!
      } else if (random(100) == 1)
      {
      	Rcolour = 0;
      	SetSpeed("this", 40 );
      	SetDamage("this", -500);   //Perspex Chicken of healing!
      } else {
      	SetSpeed("this", 60 );
      	SetDamage("this", 100);   //they take off 1 heart in lttp... I think
      }
      
      new fly = CalculateAngle(GetX("this"),GetY("this"),GetX("player1"),GetY("player1"));
      SetMoveAngle("this", fly);
      
      if (GetMoveAngle("this") > 90 && GetMoveAngle("this") < 270)
      	{
      		SetDirection("this", east);
      	} else
      	{
      		SetDirection("this", west);
      	}

      // Set some general parameters
      SetActiveDist("this", 320);
      SetType("this", enemyType); //any other suggestions for its type?
      
      SetCuttableFlag("this", false);   //immortal
      

   }

   if (!isActive("this"))
      DeleteEntity("this");

   // Check for a collision with the player, later.
   CallFunction("_enemylib", true, "CheckForPlayer", "NULL");
   

   width  = GetAnimWidth(walke);
   height = GetAnimHeight(walke);
   
   
 
   // Move the chicken if the game is unpaused
   if (GetPauseLevel() == 0)
   {

      // Move the chicken
      AngleMove("this");
   }

   new x = GetX("this");
   new y = GetY("this");
   
   // Draw the chicken and its shadow
   if (isVisible("this"))
   {
      if (GetDirection("this")==west)
         DrawAnim(walkw, x, y - 16, y + height, 0, Rcolour, 255, Bcolour);
      else
         DrawAnim(walke, x, y - 16, y + height, 0, Rcolour, 255, Bcolour);
      PutSprite("shadow1", (x + width / 2) - 8, y + height - 15, 2);
   }

   // Set a collision rectangle around the chicken
   SetCollisionRect("this", 0, false, x + adj, y + adj, x + width - adj, y + height - adj);
}