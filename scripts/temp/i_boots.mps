/***********************************************
 * Copyright (c) 2002-2005 Editors, lukex
 * Changes:  
 *	21/09/2003 [lukex]: New file.
 ***********************************************/
#include <foreign/journey>
#include <float>
#include <core>

const DEBUGSCRIPT = 0;
new running = false;
new float: keyHeldCount = 0.00;	

main()
{
	if (FirstRun())
	{
		SetType("this", itemType);
		AllocateStrings("this", 2, 100);
		SetString("this", 0,  "You found the Pegasus Boots! Run Link Run!");		// For Chests
		SetString("this", 1,  "Pegasus Boots");	// For menu      
		SetImage("this", "i_boots");
		SetOwnedFlag("this", true);
	}
	SetActiveDist("this", -1);
}

public Init()
{
	running = false;
	keyHeldCount = 0.00; //
	SetX("this", GetX("player1"));
	SetY("this", GetY("player1"));
	
}

//----------------------------------------
// Name: DrawWeapon()
//----------------------------------------
public DrawWeapon( keyHeld )
{
	new dir = GetDirection("player1");
	new x = GetX("this");
	new y = GetY("this");

	
	/* Debug Feature */
	if ( DEBUGSCRIPT )
	{
		CallFunction("console", true, "PrintNumber", "snn", "keyHeld", keyHeld, 255 );
		CallFunction("console", true, "PrintNumber", "snn", "running", running, 255 );
		CallFunction("console", true, "PrintNumber", "snnn", "keyHeldCount", floatround(keyHeldCount * 100), 0, 255 );
	}

	if ( running )
	{
		x = GetX("player1");
		y = GetY("player1");
  		SetX("this", x);
		SetY("this", y);
		if ( ( dir == north && DownKey() ) || ( dir == south && UpKey() ) )
			return -1;
		else if ( ( dir == east && LeftKey() ) || ( dir == west && RightKey() ) )
			return -1;
		SetState("player1", using);
		SetSpeedMod("player1", 161 );

		if ( isVisible("player1") )
		{
			CallFunction("player1", false, "Walk", "nnn", x, y, 1);
			
			new entity[20];
			new entityName[20];
			GetString("player1", 0, entity);
			GetString(entity, 1, entityName);	
			if ( strcmp(entityName, "Sword") > 0 )
			{
		   		CallFunction(entity,	false, "DrawStabImage", "nnn", x, y, dir);
	   		}
	   		else
	   		{
				GetString("player1", 1, entity);
				GetString(entity, 1, entityName);	
				if ( strcmp(entityName, "Sword") > 0 )
				{
			   		CallFunction(entity,	false, "DrawStabImage", "nnn", x, y, dir);
		   		}
			}
		}
	}
	else 
	{
		if ( isVisible("player1") )
		{
			if( !keyHeld )
			{
				 CallFunction("player1", false, "Stand", "nn", x, y);
				 SetState("player1", standing);
				 return -1;
			}		
			/* Charging up*/
			SetSpeedMod( "player1", -GetSpeed("player1") );

			//DrawAnim() 
			CallFunction("player1",	false, "Walk", "nnn", x, y, 0);
			keyHeldCount += GetTimeDelta() * 2;
			if ( keyHeldCount > 1.00 ) //FinishedAnim()
			{
				running = true;
			}
		}
	}
}