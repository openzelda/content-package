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
new Fixed:x, Fixed:y, Fixed:z;
new dx, dy;
new obj = -1;
new w = 112;
new h = 32;

public Init(...)
{
	obj = EntityGetNumber("object-id");
	EntityGetPosition(x,y,z);
	dx = fround(x);
	dy = fround(y);
}

main()
{
	ObjectEffect(obj, WHITE);
	if ( dx < InputPointer(0) < (dx+w) )
	{
		if ( dy < InputPointer(1) < (dy+h) )
		{
			ObjectEffect(obj, 0xFF0000FF);
			if ( InputButton(11) == 1 )
			{
				EntityPublicFunction("__map__", "submitted");
			}
		}
	}
}
