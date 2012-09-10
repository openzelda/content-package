/***********************************************
 * Copyright (c) 2004-2006 Editors
 * Changes:  
 *	19/12/01 [GD]: New file.
 *	16/03/03 [lukex]: Tunic Support added.
 *	14/06/03 [lukex]: Weapons Charging, Sword spin started
 *	10/01/04 [lukex]: Added CheckForTap()
 *	06/06/05 [lukex]: Fix first part of Ice Slidding
 *	27/01/07 [lukex]: Sword spin animation (as good as I'm doing it)
 ***********************************************/

#include <foreign/journey>
#include <core>
#include <float>
#include <animation>

//==================================
//	Global Data
//==================================
new playerAnimation[4][20];

new swordImage[22][] = { "__swd01", "__swd02", "__swd03", "__swd04", "__swd05", "__swd06", "__swd07", \
			"__swd08", "__swd09", "__swd10", "__swd11", "__swd12", "__swd13", "__swd14", \
			"__swd15", "__swd16", "__swd17", "__swd18","__swd19","__swd20","__swd21","__swd22" };

/* Each direction uses 8 frames, if you wish to increase frames make sure you change the next 6 array equally */
new playerSpinImage[32][] = { \
	"__swdn7", "__swdn7", "__swdn2", "__swdn2", "__swde1", "__swde2", "__swde3", "__swde4", \
	"__swds4", "__swds3", "__swds2", "__swds1", "__swdw1", "__swdw2", "__swdw3", "__swdw4", \
	"__swds4", "__swds3", "__swds2", "__swds1", "__swdw1", "__swdw2", "__swdw3", "__swdw4", \
	"__swds4", "__swds3", "__swds2", "__swds1", "__swds4", "__swds3", "__swds2", "__swds1" \
};
new playerSpinXOff[32] = {0, 0, 0, -1, 0, 1, 0, -4, -1, -1, 0, 1, 1, 0, -1, 0,1,0,0,1,0,-1,0,1,1,1,0,0,-1,0,1};
new playerSpinYOff[32] = {-7, -8, -9, -9, -9, -9, -8, -8, -8, -8, -9, -8, -8, -9, -9, -8, -9, -9, -9, -9, -9, -9, -9, -9, -9, -9, -9, -9};

new swordSpinImage[32] = {14,19,17,6,18,14,19,0, \
	6,18,19,17,0,6,14,14, \
	20,17,0,21,14,19,17,17, \
	21,18,14,20,0,6,18,18 \
};
new swordSpinXOff[32] = {-2,-5,-12,7,16,4,-5,-7, \
	10,15,8,-5,1,11,10,8, \
	-10,-9,-1,16,5,0,-12,-9, \
	13,11,6,-11,-4,6,14,12 \
};
new swordSpinYOff[32] = {8,7,3,-12,3,9,6,-5, \
	-11,6,9,5,-13,-8,5,10, \
	4,-3,-10,3,12,11,3,-3, \
	1,4,11,7,-7,-7,5,6 \
};

new float: swordSpin = 0.00;
new float: swordSpinSpeed = 2.00;

new swordStab[4][] = { "__swd13", "__swd10", "__swd17", "__swd04" };

new swordCollision[22][8] = { \
	{2,2,6,8, 6,4,10,12}, {0,0,6,6, 2,6,8,12}, {2,0,6,12, -999,-999,-999,-999}, {2,0,8,6, 0,6,6,12}, \
	{2,2,6,8, 6,4,10,12}, {0,0,6,6, 2,6,8,12}, {2,0,6,12, -999,-999,-999,-999}, {2,0,8,6, 0,6,6,12}, \
	{2,2,6,8, 6,4,10,12}, {0,0,6,6, 2,6,8,12}, {2,0,6,12, -999,-999,-999,-999}, {2,0,8,6, 0,6,6,12}, \
	{2,2,6,8, 6,4,10,12}, {0,0,6,6, 2,6,8,12}, {2,0,6,12, -999,-999,-999,-999}, {2,0,8,6, 0,6,6,12}, \
	{2,2,6,8, 6,4,10,12}, {0,0,6,6, 2,6,8,12}, {2,0,6,12, -999,-999,-999,-999}, {2,0,8,6, 0,6,6,12}, \
	{2,0,6,12, -999,-999,-999,-999}, {2,0,8,6, 0,6,6,12} \
};





new PlayerSuit = 1;		// Player suit (Mar. 03)
new LastPlayerSuit = 1;		// Stored Last Player suit (Mar. 03)
new param;	
new mode = 0;

new float: keyHeldCount = 0.00;	

new width;
new height;
new sx;
new sy;

main()
{
	if (FirstRun())
	{
		SetType("this", weaponType); // Set this entity's basic type
		SetOwnedFlag("this", true);		// this sword is always avaiable on the menu
		AllocateStrings("this", 2, 64);	// Create 2 string for the weapons descriptions
		
		param = GetParam("this");
	
		if (param == '1')
		{
			SetString("this", 0, "You got the Normal Sword!"); 	// For Chests
			SetString("this", 1, "Normal Sword"); 				// For menu
			SetDamage("this", 50);
			SetImage("this", "_swordicon1");
		}
		else if (param == '2')
		{
			SetString("this", 0, "You got the level 2 Sword!"); 	// For Chests
			SetString("this", 1, "Sword lv2"); 				// For menu
			SetDamage("this", 75);
			SetImage("this", "_swordicon2");
		}
		else if (param == '3')
		{
			SetString("this", 0, "You got the level 3 Sword!"); 	// For Chests
			SetString("this", 1, "Sword lv3"); 				// For menu
			SetDamage("this", 100);
			SetImage("this", "_swordicon3");
		}
		else if (param == '4')
		{
			SetString("this", 0, "You got the level 4 Sword!"); 	// For Chests
			SetString("this", 1, "Sword lv4"); 				// For menu
			SetDamage("this", 125);
			SetImage("this", "_swordicon4");
		}
		SetPlayerSuit(PlayerSuit); // Create the Animations
	}

}


//----------------------------------------
// Name: Init()
//----------------------------------------
public Init()
{
	if ( LastPlayerSuit != PlayerSuit )
		SetPlayerSuit(PlayerSuit);
	
	SetAnimCount(playerAnimation[0], 0);
	SetAnimCount(playerAnimation[1], 0);
	SetAnimCount(playerAnimation[2], 0);
	SetAnimCount(playerAnimation[3], 0);
	
	swordSpin = 0.00;
	keyHeldCount = 0.00;
	mode = 0

	// Set the Position and Direction of this entity to match the player's
	SetDirection("this", GetDirection("player1"));
	PlaySound("w_sword1.wav");
	return 1;
}


//----------------------------------------
// Name: DrawWeapon()
//----------------------------------------
public DrawWeapon( keyHeld )
{
	new x = GetX("player1");
	new y = GetY("player1");
	new dir = GetDirection("this");

	if (mode == 0)
	{
		if ( !keyHeld )
			mode = 1;
		DrawSwipeImage( x, y, dir );
		
	}
	else if (mode == 1)
	{
		DrawSwipeImage( x, y, dir );
	}	
	else if (mode == 2)
	{
		if ( !keyHeld )
		{
			if ( keyHeldCount > 6 )
			{
				mode = 3;
			}
			else
			{
				SetState("player1", standing);
				return; // Return control back to player entity
			}
		}
		keyHeldCount += GetTimeDelta()* 4;
		
		//Stab
		new moving = true;

		SetDirection("player1", dir);
		SetSpeedMod("player1", -20);

		if (UpKey() && !DownKey() && !LeftKey() && !RightKey())
			SetMoveAngle("player1", 90);
		else if (!UpKey() && DownKey() && !LeftKey() && !RightKey())
			SetMoveAngle("player1", 270);
		else if (!UpKey() && !DownKey() && LeftKey() && !RightKey())
			SetMoveAngle("player1", 0);
		else if (!UpKey() && !DownKey() && !LeftKey() && RightKey())
			SetMoveAngle("player1", 180);
		else if (UpKey() && !DownKey() && !LeftKey() && RightKey())
			SetMoveAngle("player1", 135);
		else if (UpKey() && !DownKey() && LeftKey() && !RightKey())
			SetMoveAngle("player1", 45);
		else if (!UpKey() && DownKey() && LeftKey() && !RightKey())
			SetMoveAngle("player1", 315);
		else if (!UpKey() && DownKey() && !LeftKey() && RightKey())
			SetMoveAngle("player1", 225);
		else
			moving = false;
			
		if (isVisible("player1"))
		{
			DrawStabImage( x, y, dir );
			if ( moving )
				CallFunction("player1", false, "Walk", "nnnn", x, y, 0, 1);
			else 
				CallFunction("player1", false, "Stand", "nn", x, y);
			
		}
		SetState("player1", using);
	}
	else if (mode == 3)
	{
		DrawSwordSpin(x,y,dir);
	}
	SetPosition("this", GetX("player1"), GetY("player1"));
}

DrawSwipeImage( x, y, dir )
{
	new AnimCount;
	new swordimages[6];
	new xoff[6];
	new yoff[6];
	if ( dir == north)
	{
		swordimages = {10,14,13,2,3,3};
		xoff = {14, 11, -2, -9, -12, -12};
		yoff = {8, -9, -8, -3, -1, -1};
	}
	else if ( dir == east)
	{
		swordimages = {7,8,9,10,11,11};
		xoff = {11, 9, 15,17, 9, 9};
		yoff = {0, -2, 2, 11, 13, 13};
	}
	else if ( dir == south)
	{
		swordimages = {4,5,6,17,16,16};
		xoff = {-9, -7, -6, 7, 15, 15};
		yoff = {9, 11, 17, 19, 11, 11};
	}
	else if ( dir == west)
	{
		swordimages = {1,2,3,4,5,5};
		xoff = {-6, -9, -10, -10, -9, -9}; 
		yoff = {0, -2, 2, 11, 13, 13};
	}
	
	width  = GetAnimWidth(playerAnimation[dir]);
	height = GetAnimHeight(playerAnimation[dir]);

	new temp = 0 ; 
	if (isVisible("player1"))
	{
		DrawAnim(playerAnimation[dir], x, y, y + height);
		AnimCount = GetAnimCount(playerAnimation[dir]);
		temp = swordimages[AnimCount] -1;
		// Draw the image of the sword
		
		sx = x + xoff[AnimCount];
		sy = y + yoff[AnimCount] - 9;
		
		PutSprite(swordImage[temp], sx, sy, y + height);

		// Draw the Player's shadow
		PutSprite("shadow1", x, y, 2);
	}
	else
		IncrementAnim(playerAnimation[dir]);

	SetCollisionRect("this", 0, false, sx + swordCollision[temp][0], \
			sy + swordCollision[temp][1], \
			sx + swordCollision[temp][2], \ 
			sy + swordCollision[temp][3]);

	if ( swordCollision[temp][4] != -999 )
	{
		SetCollisionRect("this", 1, false, sx + swordCollision[temp][4], \
			sy + swordCollision[temp][5], \
			sx + swordCollision[temp][6], \ 
			sy + swordCollision[temp][7]);
	}
	
	// Check to see if the sword hits anything
	CheckForHit();

	// Check if the weapon animation is over
	if (FinishedAnim(playerAnimation[dir]))
	{
		if (mode == 0)
		{
			SetState("player1", using);
			mode = 2;
		}
		else
			SetState("player1", standing); // Return control back to player entity
	}
}

DrawStabImage( x, y, dir )
{
	height = GetHeight(swordStab[dir]);
	width = GetWidth(swordStab[dir]);
	new point;	
	if ( dir == north)
	{
		x -= 2;
		y -= 6;
		point = CheckMask(x+(width/2), y, 1);
	}
	else if ( dir == east)
	{
		x += 10;
		y += 6;
		point = CheckMask(x+width, y+(height/2), 1);
	}
	else if ( dir == south)
	{
		x += 10;
		y += 8;
		point = CheckMask(x+(width/2), y+height, 1);
	}
	else if ( dir == west)
	{
		x -= 8;
		y += 6;
		point = CheckMask(x, y+(height/2), 1);
	}
	SetCollisionRect("this", 0, false, x, y, x + width, y + height);
	#if defined _journey_included
		DrawColourSprite(swordStab[dir], x, y, y + 16, ( keyHeldCount > 6 ? Red : White) );
	#else
		PutSprite(swordStab[dir], x, y, y + 16);
	#endif
	
	if ( point < 128 )
	{
		CheckForHit();
	}
}

DrawSwordSpin( x, y, dir )
{
	new lastSpin = sizeof(swordSpinImage) / 4;
	new spinCount = floatround(swordSpin, floatround_floor);
	new spinOffset = (dir * lastSpin) + spinCount;
	new image = swordSpinImage[spinOffset];

	width  = GetWidth(swordImage[image]);
	height = GetHeight(swordImage[image]);

	sx = x + swordSpinXOff[spinOffset];
	sy = y + swordSpinYOff[spinOffset];
	
	if (isVisible("player1"))
	{
		PutSprite(playerSpinImage[spinOffset], x + playerSpinXOff[spinOffset], y + playerSpinYOff[spinOffset], y + height);
		PutSprite(swordImage[image], sx, sy, sy + height);
	}
	swordSpin += swordSpinSpeed * GetTimeDelta();
	spinCount = floatround(swordSpin, floatround_floor);

	if ( spinCount >= lastSpin ) // Check if spin is finished
	{
		SetState("player1", standing);	// Return control back to player entity
		return;
	}

	SetCollisionRect("this", 0, false, sx + swordCollision[image][0], \
			sy + swordCollision[image][1], \
			sx + swordCollision[image][2], \ 
			sy + swordCollision[image][3]);
	
	if ( swordCollision[image][4] != -999 )
	{
		SetCollisionRect("this", 1, false, sx + swordCollision[image][4], \
			sy + swordCollision[image][5], \
			sx + swordCollision[image][6], \ 
			sy + swordCollision[image][7]);
	}
	
	CheckForHit(); // Check to see if the sword hits anything

}

//----------------------------------------
// Name: CheckForHit()
//----------------------------------------
CheckForHit()
{
	new temp[20];

	// Go to the start of the Entity List
	StartEntity(40);

	// Loop through all the entities within a certain distance
	do
	{
		ToString(GetCurrentEntity(), temp);
		 
		if (isActive(temp) && GetType(temp) != playerType )
		{
			if (Collide("this", temp))
			{
				if ( GetState(temp) != hit )
					CallFunction(temp, false, "HitByWeapon", "snnn", "sword", GetDamage("this"), GetX("this"), GetY("this"));
			}
		}
	} while ( NextEntity() )
}

public ChangePlayerSuit(ChangeTo)
{
	PlayerSuit = ChangeTo;
	SetPlayerSuit(ChangeTo);
}

SetPlayerSuit(NewPlayerSuit)
{
	LastPlayerSuit = NewPlayerSuit;
	DeleteAnim( playerAnimation[0] );
	DeleteAnim( playerAnimation[1] );
	DeleteAnim( playerAnimation[2] );
	DeleteAnim( playerAnimation[3] );
	CreateAnim(24, playerAnimation[0]);
	CreateAnim(24, playerAnimation[1]);
	CreateAnim(24, playerAnimation[2]); 
	CreateAnim(24, playerAnimation[3]);
		
	// Add Frames to all Animations
	if (NewPlayerSuit == 1) {	
		AddAnimframe(playerAnimation[0], 0, -9, "__swdn1");
		AddAnimframe(playerAnimation[0], 0, -9, "__swdn2");
		AddAnimframe(playerAnimation[0], 0, -13, "__swdn3");
		AddAnimframe(playerAnimation[0], 0, -9, "__swdn4");
		AddAnimframe(playerAnimation[0], 0, -9, "__swdn4");

		AddAnimframe(playerAnimation[1], 0, -9, "__swde1");
		AddAnimframe(playerAnimation[1], 0, -9, "__swde2");
		AddAnimframe(playerAnimation[1], 0, -9, "__swde3");
		AddAnimframe(playerAnimation[1], 0, -9, "__swde4");
		AddAnimframe(playerAnimation[1], 0, -9, "__swde5"); 

		AddAnimframe(playerAnimation[2], 0, -9, "__swds1");
		AddAnimframe(playerAnimation[2], 0, -9, "__swds2");
		AddAnimframe(playerAnimation[2], 0, -9, "__swds2");
		AddAnimframe(playerAnimation[2], 0, -9, "__swds3");
		AddAnimframe(playerAnimation[2], 0, -9, "__swds4");

		AddAnimframe(playerAnimation[3], 0, -9, "__swdw1");
		AddAnimframe(playerAnimation[3], 0, -9, "__swdw2");
		AddAnimframe(playerAnimation[3], 0, -9, "__swdw3");
		AddAnimframe(playerAnimation[3], -4, -9, "__swdw4");
		AddAnimframe(playerAnimation[3], 0, -9, "__swdw5");
	} 
	else if (NewPlayerSuit == 2) 
	{	
		AddAnimframe(playerAnimation[0], 0, -9, "__twdn1");
		AddAnimframe(playerAnimation[0], 0, -9, "__twdn2");
		AddAnimframe(playerAnimation[0], 0, -13, "__twdn3");
		AddAnimframe(playerAnimation[0], 0, -9, "__twdn4");
		AddAnimframe(playerAnimation[0], 0, -9, "__twdn4");

		AddAnimframe(playerAnimation[1], 0, -9, "__twde1");
		AddAnimframe(playerAnimation[1], 0, -9, "__twde2");
		AddAnimframe(playerAnimation[1], 0, -9, "__twde3");
		AddAnimframe(playerAnimation[1], 0, -9, "__twde4");
		AddAnimframe(playerAnimation[1], 0, -9, "__twde5"); 

		AddAnimframe(playerAnimation[2], 0, -9, "__twds1");
		AddAnimframe(playerAnimation[2], 0, -9, "__twds2");
		AddAnimframe(playerAnimation[2], 0, -9, "__twds2");
		AddAnimframe(playerAnimation[2], 0, -9, "__twds3");
		AddAnimframe(playerAnimation[2], 0, -9, "__twds4");

		AddAnimframe(playerAnimation[3], 0, -9, "__twdw1");
		AddAnimframe(playerAnimation[3], 0, -9, "__twdw2");
		AddAnimframe(playerAnimation[3], 0, -9, "__twdw3");
		AddAnimframe(playerAnimation[3], -4, -9, "__twdw4");
		AddAnimframe(playerAnimation[3], 0, -9, "__twdw5");
	}
	else if (NewPlayerSuit == 3) 
	{	
		AddAnimframe(playerAnimation[0], 0, -9, "__uwdn1");
		AddAnimframe(playerAnimation[0], 0, -9, "__uwdn2");
		AddAnimframe(playerAnimation[0], 0, -13, "__uwdn3");
		AddAnimframe(playerAnimation[0], 0, -9, "__uwdn4");
		AddAnimframe(playerAnimation[0], 0, -9, "__uwdn4");

		AddAnimframe(playerAnimation[1], 0, -9, "__uwde1");
		AddAnimframe(playerAnimation[1], 0, -9, "__uwde2");
		AddAnimframe(playerAnimation[1], 0, -9, "__uwde3");
		AddAnimframe(playerAnimation[1], 0, -9, "__uwde4");
		AddAnimframe(playerAnimation[1], 0, -9, "__uwde5"); 

		AddAnimframe(playerAnimation[2], 0, -9, "__uwds1");
		AddAnimframe(playerAnimation[2], 0, -9, "__uwds2");
		AddAnimframe(playerAnimation[2], 0, -9, "__uwds2");
		AddAnimframe(playerAnimation[2], 0, -9, "__uwds3");
		AddAnimframe(playerAnimation[2], 0, -9, "__uwds4");

		AddAnimframe(playerAnimation[3], 0, -9, "__uwdw1");
		AddAnimframe(playerAnimation[3], 0, -9, "__uwdw2");
		AddAnimframe(playerAnimation[3], 0, -9, "__uwdw3");
		AddAnimframe(playerAnimation[3], -4, -9, "__uwdw4");
		AddAnimframe(playerAnimation[3], 0, -9, "__uwdw5");
	}
		SetAnimLoop(playerAnimation[0], false);
		SetAnimLoop(playerAnimation[1], false);
		SetAnimLoop(playerAnimation[2], false);
		SetAnimLoop(playerAnimation[3], false);
}