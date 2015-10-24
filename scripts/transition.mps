/***********************************************
 * Copyright © Luke Salisbury
 *
 * You are free to share, to copy, distribute and transmit this work
 * You are free to adapt this work
 * Under the following conditions:
 *  You must attribute the work in the manner specified by the author or licensor (but not in any way that suggests that they endorse you or your use of the work). 
 *  You may not use this work for commercial purposes.
 * Full terms of use: http://creativecommons.org/licenses/by-nc/3.0/
 * Changes:
 *     2010/01/11 [luke]: new file.
 ***********************************************/

#define FADEIN	1
#define FADEOUT	2
#define FADEEND	3

forward public SetTarget(entity:nplayer_id, entity:ntarget_id, nmapid);


/* Target Varibles */
new entity:target_entity;
new map_id = 0;
new entity:player_entity;

new transtition_state, transtition_mode;

new layer_colour = 0xFFFFFFFF;
new Fixed:seconds;

public Init(...) {}
public Close() {}

main()
{
	if ( transtition_state )
	{
		if ( transtition_state == FADEEND )
		{
			transtition_state = 0;
			LayerColour(0, 0xffffffff);
			LayerColour(1, 0xffffffff);
			LayerColour(2, 0xffffffff);
			LayerColour(3, 0xffffffff);
			LayerColour(4, 0xffffffff);
			LayerColour(5, 0xffffffff);
			GameState(GS_ALL);
		}
		else if ( transtition_state == FADEOUT )
		{
			if ( target_entity && player_entity )
			{
				EntityPublicFunction(target_entity, "UpdatePlayer", ''nnn'', _, player_entity, 32.0, 48.0);
				target_entity = entity:0;
				player_entity = entity:0;
			}
			Fade();
		}
		else if ( transtition_state == FADEIN )
		{
			Fade();
		}
	}
}

public SetTarget(entity:nplayer_id, entity:ntarget_id, nmapid)
{
	target_entity = ntarget_id;
	player_entity = nplayer_id;

	if ( nmapid )
	{
		map_id = nmapid;
		GameState(GS_PAUSE);
		transtition_state = FADEIN;
		return true;
	}
	return false;
}

MoveToTarget()
{
	if ( map_id != 0 )
	{
		MapSet(map_id, 0, 0);
		map_id = 0; 
		return true;
	}

	return false;
}

Fade()
{
	new alpha;

	seconds += GameFrameSeconds() * 400.0;
	
	if ( transtition_state == FADEOUT )
		alpha = 0 + fround(seconds);
	else
		alpha = 255 - fround(seconds);

	if ( seconds >= 255.0 )
	{
		if ( transtition_state == FADEIN )
		{
			MoveToTarget();
		}

		transtition_state++;
		seconds = 0.0;
	}
	else
	{
		layer_colour = (alpha << 24 | alpha << 16 | alpha << 8 | 255);

		LayerColour(0, layer_colour);
		LayerColour(1, layer_colour);
		LayerColour(2, layer_colour);
		LayerColour(3, layer_colour);
		LayerColour(4, layer_colour);
		LayerColour(5, layer_colour);
	}

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
*/
