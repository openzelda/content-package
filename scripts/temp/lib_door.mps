/***********************************************
*
***********************************************/

#include <foreign/journey>
#include <core>
#include <float>


new fading;
new Door[20];
new float: timer = 0.00;
new wipex = 0;
new wipey = 0;
new displaypos[2];
new transition;

/* for main.zes Door Handling */
new usingHandle = false; 
new doorNames[2][32];
new doorPositions[2][2];


RunDoorTrans(mode, whichone)
{
	switch(whichone)
	{
		case 0:	
			return FadeToColour(0, 0, 0, 160, mode);
		case 1:	
			return FadeToColour(255, 255, 255, 160, mode);
		case 4:	
			return DoorWipe( mode );
		case 5:
			return IrisOut(mode, 2);
	}

	/*
		case 2:	
			return Steps( fading, true );
		case 3:	
			return Steps( fading, false );
		
	*/
}


public Handle()
{
	usingHandle = true;
	if (!fading)
	{
		return;	
	}
	else if (fading == 1)
	{
		GameState(2);
		if ( RunDoorTrans(1, transition) )
		{
			fading = 2;
			GetNewPosition( doorNames[1] );
			RunDoorTrans(0, transition);
		}

	}
	else if (fading == 2) 
	{
		if ( RunDoorTrans(0, transition) )
		{
			GameState(1);
			transition = 0;
			fading = 0;
			doorNames[0] = "";
			doorNames[1] = "";
		}
	}
}

public StartDoorTrans(target[32], wantedTrans)
{
	if (usingHandle)
	{
		if (strlen(target) < 2)
			return;
		doorNames[1] = target;
		transition = wantedTrans;
		EntityGetPostion(doorPositions[0][0], doorPositions[0][1], doorNames[0]);
		EntityGetPostion(doorPositions[1][0], doorPositions[1][1], doorNames[1]);
		fading = 1;
	}

}

//----------------------------------------
// Name: MoveToOtherDoor()
//----------------------------------------
public MoveToOtherDoor()
{
	fading = true;

	// Check if the first string is blank
	if ( strlen(Door) > 1 )
	{
		GameState(2);
		EntityCallFunction(Door, "opendoor");
		if ( RunDoorTrans(fading, transition) )
		{
			SetInteractingFlag(Door, true);
			GetNewPosition( Door );
		}
	}
}

//----------------------------------------
// Name: FinishDoorTrans()
//----------------------------------------
public FinishDoorTrans()
{
	fading = false;
	if ( RunDoorTrans(fading, transition) )
	{
		GameState(1);
		transition = 0;
	}	
}

//----------------------------------------
// Name: GetNewPosition()
//----------------------------------------
public GetNewPosition( TargetDoor[] )
{
	new width, height = -1;
	new Float:x, Float:y;
	new dir = 0;
	
	EntityGetPosition(x, y, _z_, TargetDoor);
	dir = EntityCallFunction(TargetDoor, "dir");
		
	// Work out the Width and Height of the target door from it's sprite
	new width = MiscGetWidth(DoorSprite);
	new height = MiscGetHeight(DoorSprite);
	

	// If the entity doesnt exist then the x and y will be set to -999 each
	if ( x == -999 || height == -1 )
	{
		return;
	}
		
	// Adjust the position the player should be placed according to the direction
	// The new door is facing
	if ( dir == north )
	{
		x += width / 2 - 8;
		y += 16;
		EntityCallFunction(player, "SetDir", south);
		SetDirection("player1", south);
	}
	if ( dir == east )
	{
		x -= 4;
		y += height / 2 - 8;
		EntityCallFunction(player, "SetDir", west);
	}
	if ( dir == south )
	{
		x += width / 2 - 8;
		y -= 6;
		EntityCallFunction(player, "SetDir", north);
	}
	if ( dir == west )
	{
		x += 10;
		y += height / 2 - 8;
		EntityCallFunction(player, "SetDir", east);
	}
	
	EntitySetPosition(x, y, player);
}
/*
public Steps( fadeout, GoingUp )
{
	timer += GetTimeDelta();
	if ( timer > 3.00 ) {
		SetMoveAngle("player1", 180);
	} else {
		SetMoveAngle("player1", 90);
	}
		AngleMove("player1"); 
}
*/
/*
public DoorWipe( fadeout )
{
	static wiped;
	if ( fadeout )
	{
		if ( !wiped )
		{
			Wipe(dir, 200)
			wiped = true;
			if ( dir == north )
			{
				wipex = GetX("player1");
				wipey = doorPositions[1][1];
			}
			else if ( dir == east )
			{
				wipex = doorPositions[1][0] - GetWidth(doorNames[1]);
				wipey = GetY("player1");
			}
			else if ( dir == south )
			{
				wipex = GetX("player1");
				wipey = doorPositions[1][1] - GetHeight(doorNames[1]);
			}
			else if ( dir == west )
			{
				wipex = doorPositions[1][0];
				wipey = GetY("player1");
			}
			displaypos[0] = GetX("player1");
			displaypos[1] = GetY("player1");
		}
		else
		{
			//ConsoleNumber("x ", wipex);
			//ConsoleNumber("y ", wipey);
	
			if ( displaypos[0] == wipex && displaypos[1] == wipey )
			{
				wipex = 0;
				wipey = 0;
				wiped = false;
				fadeout = false;
				return 1;
			}
			SetVisibleFlag("player1", false);
			CallFunction("player1", false, "Walk", "nnn", displaypos[0],displaypos[1], true);
			new float: MoveAmt  
			new MoveAngle; 
			MoveAmt = 0.60; 
			MoveAngle = CalculateAngle(displaypos[0],displaypos[1],wipex,wipey); 
			
			displaypos[0] = displaypos[0] - floatround(MoveAmt * Cos(MoveAngle));
			displaypos[1] = displaypos[1] - floatround(MoveAmt * Sin(MoveAngle));
		}
		return 0;
	}
	else
	{
		SetVisibleFlag("player1", true);
		return 1;
	}

}
*/



public FadeToColour(R, G, B, speed, fadeout)
{
	new alpha;
	timer += GetTimeDelta() * speed;	
	if (fadeout)
		alpha = 0 + (floatround(timer));
	else 
		alpha = 255 - (floatround(timer));

	DrawRectangle(0, 0, 640, 480, R, G, B, alpha);

	if (fadeout && alpha >= 255)
	{
		timer = 0.00;
		return true;
	}
	else if (!fadeout && alpha <= 0)
	{
		timer = 0.00;
		return true;
	}
	else 
		return false;

}

public IrisOut(fadeout, speed)
{
	// Scripted By Satanman
	// closes an iris around the player; isout is whether it's closing or opening,
	// speed is the time, in seconds, it takes to close the iris
	// a variable called 'timer' must be initialised at the top of the script, and must be set to 440.00
	// if it's an exit iris, or 0.00 if it's an opening one.
	
	new outerxy[2]; //x and y values for the outer ring
	new innerxy[2]; //x and y values for the iris
	new float: iristimer = 0.00;
	
	timer += GameFrame() * speed;
	
	if ( fadeout )
		iristimer = 440.00 - (timer * 440 / 2); // close the iris -thinks of stargate SG-1
	else
		iristimer = 0 + (timer * 440 / 2); //open the iris -ditto
	
	
	for (new line = 0; line < 360 ; line += 2)
	{
		outerxy[0] = 320 + floatround(440 * Cos(line)); //get the x and y of this bit of the outer ring
		outerxy[1] = 240 + floatround(440 * Sin(line));
		
		innerxy[0] = 320 + floatround(iristimer * Cos(line)); //get the x and y of this bit of the iris
		innerxy[1] = 240 + floatround(iristimer * Sin(line));

		DrawLine(outerxy[0], outerxy[1], innerxy[0], innerxy[1], 20, 0, 0, 0); //draw this segment of the iris
	}

	if (!fadeout && iristimer >= 440)
	{
		timer = 0.00;
		return true;
	}
	else if (fadeout && iristimer <= 0)
	{
		timer = 0.00;
		return true;
	}
	else 
		return false;
}
