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
#include <open_zelda>

new timeout = 1;
new object:obj = OBJECT_NONE;

public Init( ... )
{
	new length = 1;
	EntityGetPosition(mqEntityPosition.x,mqEntityPosition.y, mqDisplayZIndex);
	UpdateDisplayPosition();
	obj = ObjectCreate("fire1.png:1", SPRITE, mqDisplayArea.x, mqDisplayArea.y, 4, 0, 0);
	timeout = AnimationGetLength("fire1.png:1") * length;
	AudioPlaySound("fire1.wav", mqDisplayArea.x, mqDisplayArea.y);
}

public Close()
{
	ObjectDelete(obj);
}


main()
{
	if ( mqState == DYING )
	{
		if ( TimerCountdown(timeout) )
			EntityDelete();
	}
	else
	{
		if ( TimerCountdown(timeout) )
		{
			ObjectReplace(obj, "fire1.png:2", SPRITE );
			ObjectFlag(obj, FLAG_ANIMLOOP, 0);
			timeout = AnimationGetLength("fire1.png:2");
		}
	}
}

