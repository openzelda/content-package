/***********************************************
 * Copyright © Luke Salisbury
 *
 * You are free to share, to copy, distribute and transmit this work
 * You are free to adapt this work
 * Under the following conditions:
 *  You must attribute the work in the manner specified by the author or licensor (but
 *    not in any way that suggests that they endorse you or your use of the work). 
 *  You may not use this work for commercial purposes.
 * Full terms of use: http://creativecommons.org/licenses/by-nc/3.0/
 * Changes:
 *     2010/01/11 [luke]: new file.
 ***********************************************/

new timeout = 0, animationLength;

public Init(...)
{
	GetEntityPosition(qPosition.x, qPosition.y, qPosition.z, qDisplayArea.x, qDisplayArea.y);
	
	qObject = ObjectCreate("icerod.png:1", SPRITE, qDisplayArea.x, qDisplayArea.y, qPosition.z, 0, 0);

	ObjectFlag(qObject, FLAG_ANIMLOOP, false);

	animationLength = AnimationGetLength("icerod1.png", "1");
	timeout = animationLength;
}

public Close()
{
	ObjectDelete(qObject);
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
	qDisplayArea.x = nx;
	qDisplayArea.y = ny;
	qDisplayArea.w = wid;
	qDisplayArea.h = hei;

	EntitySetPosition( qDisplayArea.x, qDisplayArea.y );

	GetRandomSpot();
}

//----------------------------------------
// Name: GetRandomSpot()
//----------------------------------------
GetRandomSpot()
{
	new border = 2;
	
	// Get a new random position for the sparkle
	qPosition.x += random(qDisplayArea.w - border*2);
	qPosition.y += random(qDisplayArea.h - border*2);
	
	qPosition.x += border;
	qPosition.y += border;
}
