/* This entity has been release under public domain */
/***********************************************************************
 * HookShot Entity Script
 * 
 * Author: Satanman
 * Date:   22nd May 2003
 *
 * Desc:   It Expands! it retracts! what a cool invention!
 *
 * Usage:  This script will be called by the player entity when it wants
 *         to use this weapon, before it calls this script it will enter
 *         the 'using' state and stay there until this script tells it
 *         to finish 
 *
 *         
 ***********************************************************************/
#include <foreign/journey>
#include <core>
#include <float>
#include <animation>

//==================================
//   Global Data
//==================================
new rotation = 0;
new float: stretching = 0.00;
new float: Stretchsound = 0.00;
new expanding = false;
new latched = 0;
new pullitem[20];
new headx = 0;
new heady = 0;
new lastheadx = 0;
new lastheady = 0;

//----------------------------------------
// Name: main()
//----------------------------------------
main()
{
	if (FirstRun())
	{
		// Set this entity's basic type
		SetType("this", weaponType);
		SetOwnedFlag("this", true);		// this hookshot is always avaiable on the menu
      
		// Create 2 string for the weapons descriptions
		AllocateStrings("this", 2, 80);	
		SetDamage("this", 50);
		SetImage("this", "w_hookshot1");
		SetString("this", 0, "You got the hookshot!`It Expands! it retracts! `what a cool invention!"); 	// For Chests
		SetString("this", 1, "Hookshot"); 				// For menu
		SetActiveInGroups("this", true);
		printf("Hookshot Created");
	}
}


//----------------------------------------
// Name: Init()
//----------------------------------------
public Init()
{
	// This function should be called by the Player script every
	//	time just before the weapon is used, it resets all animations
	//	and makes sure everything is ready to go 
	// Reset all animations
	
	// Set the Position and Direction of this entity to match the player's
	SetX("this", GetX("player1"));
	SetY("this", GetY("player1"));
	SetDirection("this", GetDirection("player1"));
	expanding = true;
	stretching = 0.02;
	headx = 0;
	heady = 0;
	lastheadx = 0;
	lastheady = 0;
	latched = 0;
	pullitem = "";
}


//----------------------------------------
// Name: DrawWeapon()
//----------------------------------------
public DrawWeapon()
{
	new x = GetX("this");
	new y = GetY("this");
	new dir = GetDirection("this");
	new playerImg[10];

	// ====================================================
	// Setup the player animation and the hammer image based
	//	on the direction this entity is facing
	// ====================================================
	/* TODO support tunics */
	if ( dir == north)
		playerImg = "__swdn3";
	else if ( dir == east)
		playerImg = "__swde3";
	else if ( dir == south)
		playerImg = "__swds3";
	else if ( dir == west)
		playerImg = "__swdw3";

	// Get the width and height of the Animation
	new width  = GetWidth(playerImg);
	new height = GetHeight(playerImg);
	new sx;
	new sy;
   
	// ========================================================
	// Draw the Player and the Hookshot image seperately
	// ========================================================
	if (isVisible("player1"))
	{
		// Draw the Player
		PutSprite(playerImg, x, y, y + height);

		DrawHookshot(x, y);
		
		// Draw the Player's shadow
		PutSprite("shadow1", x, y, 2);
	}
	// ========================================================================
	// Set the Collision Rectangle for the hookshot.
	// ========================================================================
	SetCollisionRect("this", 0, false, headx + 2, heady + 2, headx + 10, heady + 10);
	


	// Check to see if the head hits anything
	if (latched == 0)
		CheckForHit();
   

	if (stretching <= GetTimeDelta() * 200)
	{
		// Return control back to player entity
		SetState("player1", standing);
	}
}

HandleStretching()
{
	if (latched == 0)
	{
		if (expanding == true)
		{
			if (stretching > 100.00)
				expanding = false;
			else if (CheckMask(headx + 8, heady + 8) <= 16)
			{
				CreateEntity("_explosion2", headx, heady, "_explosion2");
				expanding = false;
			}
			stretching += GetTimeDelta() * 200;
		} else
			stretching -= GetTimeDelta() * 200;
	} else if (latched == 1)
	{
		stretching -= GetTimeDelta() * 200;
		SetPosition(pullitem, headx, heady);
	} else if (latched == 2)
	{
		new x = GetX("this");
		new y = GetY("this");
		new dir = GetDirection("this");
		new poschange = floatround(stretching);
		stretching -= GetTimeDelta() * 200;
		
		if (dir == north)
			SetY("this", lastheady + poschange);
		else if (dir == east)
			SetX("this", lastheadx - 8 - poschange);
		else if (dir == west)
			SetX("this", lastheadx + 2 + poschange);
		else if (dir == south)
			SetY("this", lastheady - 10 - poschange);
	}
	if (Stretchsound >= 1.20)
	{
		PlaySound("w_hookshot.wav", 240);
		Stretchsound = 0.00;
	}
}

DrawHookshot(hx, hy)
{
	new dir = GetDirection("this");
	new linklength = floatround(stretching);
	
	if (dir == north)
	{
		PutSprite("w_HookShotHandle", hx + 2, hy, hy + 8);
		for (new p; p < 7; p++)
			PutSprite("w_HookShotLink", hx + 4, hy - ((linklength* p) / 7), hy);
		PutSprite("w_HookShotHead", hx, hy - linklength, hy);
		headx = hx;
		heady = hy - linklength;
	} else if (dir == west)
	{
		PutSprite("w_HookShotHandle", hx - 2, hy + 12, hy + 12, 0, 255, 255, 255, 255, 270);
		for (new p; p < 7; p++)
			PutSprite("w_HookShotLink", hx - 2 - ((linklength* p) / 7), hy + 12, hy, 0, 255, 255, 255, 255, 270);
		PutSprite("w_HookShotHead", hx -2 - linklength, hy + 12, hy, 0, 255, 255, 255, 255, 270);
		headx = hx -2 - linklength;
		heady = hy + 12;
	} else if (dir == east)
	{
		PutSprite("w_HookShotHandle", hx + 12, hy + 12, hy + 12, 0, 255, 255, 255, 255, 90);
		for (new p; p < 7; p++)
			PutSprite("w_HookShotLink", hx + 12 + ((linklength* p) / 7), hy + 12, hy, 0, 255, 255, 255, 255, 90);
		PutSprite("w_HookShotHead", hx + 12 + linklength, hy + 12, hy, 0, 255, 255, 255, 255, 90);
		headx = hx + 12 + linklength;
		heady = hy + 12;
	} else if (dir == south)
	{
		PutSprite("w_HookShotHandle", hx + 6, hy + 20, hy + 20, 0, 255, 255, 255, 255, 180);
		for (new p; p < 7; p++)
			PutSprite("w_HookShotLink", hx + 6, hy + 30 + ((linklength* p) / 7), hy, 0, 255, 255, 255, 255, 180);
		PutSprite("w_HookShotHead", hx + 6, hy + 30 + linklength, hy, 0, 255, 255, 255, 255, 180);
		headx = hx + 6;
		heady = hy + 30 + linklength, hy;
	}
	HandleStretching()
}


//----------------------------------------
// Name: CheckForHit()
//----------------------------------------
CheckForHit()
{
	new temp[20];

	// Go to the start of the Entity List
	StartEntity(80, headx, heady);
   
	// Loop through all the entities within a certain distance
	do
	{
		ToString(GetCurrentEntity(), temp);

		if (isActive(temp) && GetType(temp) != playerType )
		{
			// Check if the hookshot collides with the current entity
			if (Collide("this", temp))
			{
				if (GetType(temp) == enemyType)
				{
					CallFunction(temp, false, "HitByWeapon", "snnn", \
						"hookshot", GetDamage("this"), GetX("this"), GetY("this"));
				} else if (GetWeight(temp) == 0)
					latched = 1;
				else if (GetWeight(temp) == 10)
				{
					new dir = GetDirection("this");
					lastheadx = headx;
					lastheady = heady;
					if (dir == north)
						SetY("player1", lastheady);
					else if (dir == east)
						SetX("player1", lastheadx - 8);
					else if (dir == west)
						SetX("player1", lastheadx + 2);
					else if (dir == south)
						SetY("player1", heady - 10);
					latched = 2;
				} else if (GetType(temp) != weaponType)
				{
					expanding = false;
					return;
				}
				pullitem = temp;
				return;
			}
		}
	}while( NextEntity() )
}