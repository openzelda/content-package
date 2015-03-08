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

new obj = -1;
new timeout = 0;

public Init(...)
{
	EntityGetPosition(qPosition.x,qPosition.y, qPosition.z);
	UpdateDisplayPosition();
	obj = ObjectCreate("explosion.png:2", qDisplayArea.x, qDisplayArea.y, 4, 0, 0);
	ObjectFlag(obj, FLAG_ANIMLOOP, 0);
	timeout = AnimationGetLength("explosion.png:2");
}

public Close()
{
	ObjectDelete(obj);
}


main()

{

	if ( TimerCountdown(timeout) )
		EntityDelete();

}

