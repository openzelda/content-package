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

new timeout = 0, animationLength;

public Init(...)
{
	GetEntityPosition(mqEntityPosition.x, mqEntityPosition.y, mqEntityPosition.z, mqDisplayArea.x, mqDisplayArea.y, mqDisplayZIndex, mqDisplayLayer);
	
	mqDisplayObject = ObjectCreate("icerod.png:1", SPRITE, mqDisplayArea.x, mqDisplayArea.y, mqDisplayZIndex, 0, 0);

	ObjectFlag(mqDisplayObject, FLAG_ANIMLOOP, false);

	animationLength = AnimationGetLength("icerod1.png", "1");
	timeout = animationLength;
}

public Close()
{
	ObjectDelete(mqDisplayObject);
}

main()
{
	// Check if the animation is finsihed
	if ( TimerCountdown(timeout) )
	{
		timeout = animationLength;
		GetRandomSpot();	
	}
}


//----------------------------------------
// Name: SetArea()
//----------------------------------------
public SetArea( nx, ny, wid, hei )
{
	mqDisplayArea.x = nx;
	mqDisplayArea.y = ny;
	mqDisplayArea.w = wid;
	mqDisplayArea.h = hei;

	EntitySetPosition( mqDisplayArea.x, mqDisplayArea.y );

	GetRandomSpot();
}

//----------------------------------------
// Name: GetRandomSpot()
//----------------------------------------
GetRandomSpot()
{
	new border = 2;
	
	// Get a new random position for the sparkle
	mqEntityPosition.x += random(mqDisplayArea.w - border*2);
	mqEntityPosition.y += random(mqDisplayArea.h - border*2);
	
	mqEntityPosition.x += border;
	mqEntityPosition.y += border;
}
