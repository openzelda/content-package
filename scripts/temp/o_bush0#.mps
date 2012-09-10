/***********************************************
 * Copyright (c) 2001-2005 Editors
 * Changes:  
 *	19/12/01 [GD]: New file.
 ***********************************************/
#include <foreign/journey>
#include <float>

//   Global Data
new mainSpr[20] = "o_bush01";
new underSpr[20]= "o_bush02";
new justDestroyed = false;
new float: DestroyCount;
new width;    // The Width and Height of the main sprite
new height;

new x,y;

//----------------------------------------
// Name: main()
//----------------------------------------
main()
{
	if (FirstRun())
	{
		// Set this entity's basic type
		SetType("this", otherType);

		// Setup some general parameters
		SetLiftLevel("this", 1);
		SetImage("this", mainSpr);
		SetWeight("this", 80);
		SetItem("this", " ");
		SetDamage("this", 50);
		SetActiveInGroups("this", true);

		// Record the width and height of the main sprite for later use
		width  = GetWidth(mainSpr);
		height = GetHeight(mainSpr);
		x = GetX("this");
		y = GetY("this");
	}

	new yDepth = 2;

  
	if (isVisible("this"))
	{ 
		// Is this entity has been picked up then draw the sprite underneath
		if (isTaken("this"))
		{
			x = GetX("this");
			y = GetY("this");
			// The yDepth should be the height of the player - so the bush can be drawn above the player
			yDepth = y + 50 + height;	
			PutSprite(underSpr, GetInitialX("this"), GetInitialY("this"), 1);
			if (isActive("this"))
			{
				PutSprite(mainSpr, x, y, yDepth );
				SetCollisionRect("this", 0, false, x, y, x + width, y + height);
			}
			
		}
		else
		{

			if (isActive("this"))
			{
				SetCollisionRect("this", 0, true, x, y, x + width, y + height);
				PutSprite(mainSpr, x, y, yDepth );
			}
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
	// We should see what kind of weapon is hitting this entity
	// from the wtype param and make a decision based on that.
	
   BeginDestroy();
}

//--------------------------------------------------------
// Name: Thrown()
// Desc: Called when this entity is being thrown to check
//	 for collision with enemies etc..
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
				 "throwobj", GetDamage("this") ,x, y);
				 BeginDestroy();
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
   PlaySound("_bushdestroy.wav", 240);
   // Get the item string if there is one, we need to pass it to GetRandomItem()
   new item[20];
   GetItem("this", item);

   // Make a random Item Appear beneath the bush
   CallFunction("_itemlib", false, "GetRandomItem", "nns", \
		    GetX("this") + width / 2, GetY("this") + height / 2, item);

}

//----------------------------------------
// Name: Destroy()
//----------------------------------------
public Destroy() 
{
   new n;
   new x = GetX("this") + 8;
   new y = GetY("this");

   const MaxFrames = 7;
   new DestroyImages[2][] = { "_bush03", "_bush04" };

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
	SetX("this", GetInitialX("this"));
	SetY("this", GetInitialY("this"));
	Respawn("this", 20);
	justDestroyed = false;
   }  
}








