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

#include <item>

new Fixed:count = 0.0;
new obj = -1;
new p[64];
new dungeon{32} = "dungeon-d";
new dungeonid = 0;

public Init( ... )
{
	EntityGetPosition(mqEntityPosition.x,mqEntityPosition.y, mqDisplayZIndex);
	UpdateDisplayPosition();

	obj = EntityGetNumber("object-id");

	dungeonid = EntityGetNumber("dungeon-id");
	strformat(dungeon, _, _, "dungeon-%d", dungeonid);

	CollisionFromObject(obj, TYPE_ITEM);
}

main()
{
	HandleLift();
}

public Pickup( player )
{
	if ( mqState != LIFTING )
	{
		EntityPublicFunction(dungeonid, "Finished");
		EntityGetPosition(mqEntityPosition.x, mqEntityPosition.y,  mqDisplayZIndex, player );
		mqDisplayZIndex++;
	}
	mqState = LIFTING;
	return true;
}

HandleLift()
{
	if ( mqState == LIFTING )
	{
		count += GameFrame2(); 
		if ( count < 4.00 )
		{
			mqEntityPosition.y -= GameFrame2()*8.0;
			UpdateDisplayPosition();
			ObjectPosition(object:obj, mqDisplayArea.x, mqDisplayArea.y, 4, 0, 0);
		}
		else
		{
			EntityDelete();
			//EntityPublicFunction(dungeonid, "Exited");
			//MapChange(MapCurrent("Exit"));
		}

	}
}
