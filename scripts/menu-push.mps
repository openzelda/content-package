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

public Init(...)
{
	mqDirection = EntityGetNumber("dir");
	mqDisplayObject = EntityGetNumber("object-id");

	GetEntityPosition(mqEntityPosition.x, mqEntityPosition.y, mqEntityPosition.z, mqDisplayArea.x, mqDisplayArea.y, mqDisplayZIndex, mqDisplayLayer);

}

main()
{
	ObjectEffect(mqDisplayObject, WHITE);
	if ( mqDisplayArea.x < InputPointer(0,1) < (mqDisplayArea.x+16) )
	{
		if ( mqDisplayArea.y < InputPointer(1,1) < (mqDisplayArea.y+32) )
		{
			ObjectEffect(mqDisplayObject, 0xFF0000FF);
			if ( InputButton(11,1) == 1)
			{
				EntityPublicFunction(__MAP__, "MenuPush", "n", mqDirection );
			}
		}
	}
}
