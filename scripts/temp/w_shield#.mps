/***********************************************
 * Copyright (c) 2004-2001 lukex
 * Changes:  
 *	21/05/2004 [lukex]: New file.
 *	26/04/2005 [lukex]: added param support.
 *	21/08/2007 [lukex]: Allow walking while non-autoblock.
 ***********************************************/
#include <animation>
#include <foreign/journey>
#include <float>

new param;
new shield = 0;
new autoblock = false; // true = Z3 Style Shield - false = Z4 Style Shield
new active = false;

main()
{
	if (FirstRun())
	{
		SetType("this", itemType);
		param = GetParam("this");
		
		SetOwnedFlag("this", true);
		if ( !autoblock )
			SetImage("this", "w_shield1");
		// Create 2 string for the weapons descriptions
		AllocateStrings("this", 2, 64);	
		if (param == '1')
		{
			SetString("this", 0, "You got the level 1 Shield!"); 	// For Chests
			if ( !autoblock )
				SetImage("this", "w_shield1");
			SetString("this", 1, "Shield lv1"); 				// For menu	
		}
		else if (param == '2')
		{
			SetString("this", 0, "You got the level 2 Shield!"); 	// For Chests
			if ( !autoblock )
				SetImage("this", "w_shield2");
			SetString("this", 1, "Shield lv2"); 				// For menu	
		}
		SetActiveDist("this", -2);
		SetActiveInGroups("this", true);
		printf("Shield Created");		

	}
	new x = GetX("player1");
	new y = GetY("player1");
	SetPosition("this", x, y);
		
	if ( isVisible("player1") ) 
	{
		new playerstate = GetState("player1");
		
		if ( playerstate == walking || playerstate == standing )
		{
			if ( autoblock )
			{
				DrawShield(x, y, GetDirection("player1"));
			}
			else if ( active )
			{
				DrawInactiveShield(x, y, GetDirection("player1"));
			}
		}
	}
}

//----------------------------------------
// Name: Init()
//----------------------------------------
public Init()
{

}

public MenuSelected()
{
	active = true;
	return -1;
}
public MenuUnselected()
{
	active = false;
	return -1;
}
//----------------------------------------
// Name: DrawWeapon()
//----------------------------------------
public DrawWeapon( keyHeld )
{
	new x = GetX("player1");
	new y = GetY("player1");
	new dir = GetDirection("player1");

	new moving = true;

	SetDirection("player1", dir);
	SetSpeedMod("player1", -40);

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
		DrawShield(x, y, dir);// Draw the Shield
		if ( moving )
			CallFunction("player1", false, "Walk", "nnnn", x, y, 0, 1);
		else 
			CallFunction("player1", false, "Stand", "nn", x, y);
	}

	if ( keyHeld )
		SetState("player1", using);
	else
		SetState("player1", standing);
}

//----------------------------------------
// Name: DrawWeapon()
//----------------------------------------
public DrawShield(x, y, dir )
{
	new rot;
	new depth = y + 16;
	new shield_image[11]= "w_shieldpX";
	shield_image[8] = param;
	shield_image[10] = 0;
	
	if ( dir == north)
	{
		shield_image[9] = 'a';
		x += 9;
		depth = y;
	}
	else if ( dir == east)
	{
		shield_image[9] = 'c';
		x += 16;
		y += 2;
	}
	else if ( dir == south)
	{
		shield_image[9] = 0;
		y += 4;
	}
	else if ( dir == west)
	{
		shield_image[9] = 'b';
		x -= 2;
		y += 2;   
	}
	SetCollisionRect("this", 0, false, x - 1, y - 1, x + GetWidth(shield_image) + 1, y + GetHeight(shield_image) + 1 );
	PutSprite(shield_image, x, y, depth, 0, 255, 255, 255, 255, rot );
	CheckForEnemies(x, y);
}
//----------------------------------------
// Name: DrawWeapon()
//----------------------------------------
public DrawInactiveShield(x, y, dir )
{
	
	new xoff;
	new yoff;
	new rot;
	new depth = y + 16;
	new shield_image[11]= "w_shieldpX";
	shield_image[8] = param;
	shield_image[10] = 0;
	if ( !autoblock )
		dir += 1;
		
	if ( dir == north)
	{
		shield_image[9] = 'a';
		x += 9;
		depth = y;
	}
	else if ( dir == east)
	{
		shield_image[9] = 'c';
		x += 16;
		y += 2;
	}
	else if ( dir == south)
	{
		shield_image[9] = 0;
		y += 4;
	}
	else if ( dir == west)
	{
		shield_image[9] = 'b';
		x -= 2;
		y += 2;   
	}

	PutSprite(shield_image, x, y, depth, 0 );
}

CheckForEnemies(x, y)
{
	new temp[20];
	
	// Go to the start of the Entity List
	StartEntity(64, x + 8, y + 8);
	
	// Loop through all the entities within a certain distance
	do
	{
		ToString(GetCurrentEntity(), temp);
		
		// Check this entity is an enemy
		if ( GetType( temp ) == enemyType && !isDead( temp ) && isActive( temp ))
		{
			
			// Check this entity is near the arrow
			if ( Collide("this", temp) )
			{
				CallFunction( temp, false, "HitByWeapon", "snnn", "shield", 200, x - 3, y - 3);
			}
		}
	}while( NextEntity() )
}