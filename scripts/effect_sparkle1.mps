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
#include <mokoi_quest>

new length = 0;
new object:obj = NULLOBJECT;
public Init(...)
{
	EntityGetPosition(_x_, _y_, _z_);
	UpdateDisplayPosition();
	obj = ObjectCreate("icerod.png:sparkle", 'a', dx, dx, 4, 0, 0);
	length = AnimationGetLength("icerod.png:sparkle");
}

main()
{
	if ( Countdown( length ) )
	{
		EntityDelete();
	}
}
