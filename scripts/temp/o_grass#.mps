/***********************************************
 * Copyright (c) 2002-2006 lukex
 * Changes:  
 *	03/08/02 [lukex]: New file.
 ***********************************************/
#include <foreign/journey>
#include <float>
#include <animation>
#include <core>

//   Global Data
new mainSpr[20]  = "o_grass#";
new overplayer1[20] = "o_grass#anim1";
new overplayer2[20] = "o_grass#anim2";
new overplayerAnim[20];

new bool: justDestroyed = false;

new float: DestroyCount;
new float: SoundCount;
new width = 16;
new height = 16;
new param;

new x,y,playx,playy;


//----------------------------------------
// Name: main()
//----------------------------------------
main()
{
	if (FirstRun())
	{
		// Set this entity's basic type
		SetType("this", otherType);
		param = GetParam("this");
		mainSpr[7]  = param;
		overplayer1[7] = param;
		overplayer2[7] = param;
		CreateAnim(7, overplayerAnim);
		AddAnimframe(overplayerAnim, 0,0, overplayer1); 
		AddAnimframe(overplayerAnim, 0,0, overplayer2);
		SetAnimLoop(overplayerAnim, true);
		SetItem("this", "nothing");
		x = GetX("this");
		y = GetY("this");
	}

	if (isActive("this")) 
	{
		new playx = GetX("player1");
		new playy = GetY("player1");
		if ( NearPoint(x, y, playx,playy, 32) )
		{
			SetInteractingFlag("this", true);
		}
		else
		{
			SetInteractingFlag("this", false);
		}

		if ( isVisible("this") )
			PutSprite(mainSpr, x, y, 2 );

		if (isInteracting("this"))
		{ 
			
			SetCollisionRect("this", 0, false, x, y, x + width, y + height); 
			if ( Collide("this", "player1") ) 
			{
				
				SetSpeedMod("player1", -30);
				if ( GetState("player1") == walking || GetState("player1") == walkLift )
				{
					DrawAnim(overplayerAnim, playx, playy+16, 9999 );
					SoundCount += GetTimeDelta();
					if (SoundCount >= 0.3)
					{
						PlaySound("p_walkingrass.wav", 240);
						SoundCount = 0.00;
					}
				}
				else
					DrawAnimNoInc(overplayerAnim, playx, playy+16, 9999 );
			}
			else
			{
				SetSpeedMod("player1", 0);
			}	
		}
		else
		{
			ClearCollisionRect("this", 0);
		}
	}

	if (justDestroyed)
		Destroy();
}

//----------------------------------------
// Name: HitByWeapon(wtype[], damage)
//----------------------------------------
public HitByWeapon(wtype[], damage)
{
	if ( !strcmp(wtype, "sword") )
		BeginDestroy();
}

//----------------------------------------
// Name: BeginDestroy()
//----------------------------------------
public BeginDestroy()
{
   new item[20];
   GetItem("this", item);

   // Make a random Item Appear beneath the grass
   CallFunction("_itemlib", false, "GetRandomItem", "nns", \
                GetX("this") + width / 2, GetY("this") + height / 2, item);
   //cut = true;
   SetActiveFlag("this", false);
   ClearCollisionRect("this", 0);
   justDestroyed = true;
   DestroyCount = 0.00;
   PlaySound("_bushdestroy.wav", 240);  //NEED'S SOUND
}

//----------------------------------------
// Name: Destroy()
//----------------------------------------
public Destroy() 
{
   new n;

   const MaxFrames = 7;
   new DestroyImages[2][] = { "o_grassg0", "o_grassg1" };

   // 4 leaves over MaxFrames frames of animation
   new xpos[4][MaxFrames]  = { {-4,-3,-5,-6,-8,-8,-11}, {2,0,-3,-6,-10,-14,-17}, {-2,-2,0,0,1,3,-4}, {-12,-7,-7,-2,0,2,-2} };
   new ypos[4][MaxFrames]  = { {-9,-10,-11,-12,-13,-16,-20}, {-3,-1,2,1,1,0,-2}, {1,5,7,9,11,11,15}, {-2,0,1,1,5,4,12} };
   new frame[4][MaxFrames] = { {0,0,0,0,0,0,0}, {1,1,1,1,1,0,1}, {0,0,1,0,0,0,1}, {0,0,0,0,0,0,1} };

   // Advance our animation counter
   DestroyCount += 12.0 * GetTimeDelta();

   // Draw the image of each leaf
   for( n = 0; n < 4; n++ )
   {
      PutSprite( DestroyImages[ frame[n][floatround(DestroyCount)] ], 
                 x + xpos[n][ floatround(DestroyCount) ],   
                 y + ypos[n][ floatround(DestroyCount) ], 
                 y + ypos[n][ floatround(DestroyCount) ]);
   }
    
   // if our animation counter goes too high then end the animation         
   if (DestroyCount >= MaxFrames -1)
   {
      // Set the coordinates of the entity back to the initial coordinates
      Respawn("this", 30);
      justDestroyed = false;
   }  
}








