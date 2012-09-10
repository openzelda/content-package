/***********************************************
 * Copyright (c) 2004-2006 Editors
 * Changes:  
 *	29/06/02 [GD]: New file.
 ***********************************************/
#include <foreign/journey>
#include <float>

//   Global Data
new mainSpr[20];			// The Main Sprite
new underSpr[20];			// The sprite under the main sprite
new justDestroyed = false;
new float: DestroyCount;
new width;    				// The Width and Height of the main sprite
new height;

//----------------------------------------
// Name: main()
//----------------------------------------
main()
{
	if (FirstRun())
   	{
      	// Setup some general parameters
      	SetType("this", otherType);
      	SetLiftLevel("this", 1);
      	SetWeight("this", 80);
      	SetDamage("this", 50);
      	SetActiveInGroups("this", true);	// Becuase the player might carry it to other groups
      	mainSpr = "_pot1a";
      	underSpr= "_pot1b";
      	SetImage("this", mainSpr);
      	// Record the width and height of the main sprite for later use
     	width  = GetWidth(mainSpr);
      	height = GetHeight(mainSpr);
    }

   new zDepth = 2;
   new x = GetX("this");
   new y = GetY("this");
  
   if (isVisible("this"))
   { 
      // draw the sprite underneath
      PutSprite(underSpr, GetInitialX("this"), GetInitialY("this"), 1);
      
      if (isTaken("this"))
      {
      	 // The zDepth should be the height of the player - so the bush can be drawn above the player
      	 zDepth = y + 50 + height;	
         SetCollisionRect("this", 0, false, x, y, x + width, y + height);
      }
      else
      {
         // If it hasnt been picked up and is still active set a solid collision rect
         if (isActive("this"))
            SetCollisionRect("this", 0, true, x, y, x + width, y + height);
      }
      
      // Draw The main Sprite
      if (isActive("this"))
         PutSprite(mainSpr, x, y, zDepth );
   }

   if (justDestroyed)
      Destroy();
}

//----------------------------------------
// Name: HitByWeapon(wtype[], damage)
//----------------------------------------
public HitByWeapon(wtype[], damage)
{
	// We should see what kind of weapon is hitting this entity
	// from the wtype param and make a decision based on that.
	
   	// Get the item string if there is one, we need to pass it to GetRandomItem()
   	new item[20];
   	GetItem("this", item);

   	// Make a random Item Appear beneath the entity
   	CallFunction("_itemlib", false, "GetRandomItem", "nns", \
                 GetX("this") + width / 2, GetY("this") + height / 2, item);

   	BeginDestroy();
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
				// Tell any other scripts that they have been hit by a throwable object
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
	new x 					= GetX("this") + width / 2;
	new y 					= GetY("this") + height / 2;
	const MaxFrames 		= 8;
	new DestroyImages[5][] 	= { "_stone01", "_stone02", "_stone03", "_stone04", "___none" };
	
	// 4 fragments over MaxFrames frames of animation
	new xpos[4][MaxFrames]  = { {-8,-10,-12,-14,-15,-17,0,0}, {0,1,1,1,1,1,1,1}, {0,1,2,4,5,6,7,0}, {-8,-9,-9,-9,-10,-11,-12,-11} };
	new ypos[4][MaxFrames]  = { {-7,-7,-6,-6,-6,-4,0,0}, {-7,-7,-10,-10,-11,-10,-11,-7}, {2,3,0,2,2,4,4,0}, {1,3,5,5,7,9,7,10} };
	new frame[4][MaxFrames] = { {0,0,1,0,0,1,4,4}, {1,2,3,2,3,1,0,1}, {2,1,0,1,0,1,0,4}, {0,0,1,0,1,0,0,1} };
	
	// Advance our animation counter
	DestroyCount += 17.0 * GetTimeDelta();
	
	// Draw the image of each fragment
	for( n = 0; n < 4; n++ )
	{
		new dCount = floatround(DestroyCount);
		PutSprite( DestroyImages[ frame[n][dCount] ], x + xpos[n][dCount], y + ypos[n][dCount], y + ypos[n][dCount]);
	}
    
	// if our animation counter goes too high then end the animation         
	if ( DestroyCount >= MaxFrames - 1)
	{
		// Set the coordinates of the entity back to the initial coordinates
		SetX("this", GetInitialX("this"));
		SetY("this", GetInitialY("this"));
		Respawn("this", 30);               // Respawn this entity after a period of time
		justDestroyed = false;
	}  
}
