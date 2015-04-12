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
 *     2013/04/11 [luke]: updated to work with latest version
 ***********************************************/

#define XOFFSET 12
#define YOFFSET 8

#include <door>

new dungeon{32} = "dungeon-d";
new dungeonid = 0;
new entity:dungeonEntity;

/* Arch */
new object:archObject;

public Init(...)
{
	isOpen= true;
	archObject = object:DoorInit( -1 );

	/* Get Settings */
	dungeonid = EntityGetNumber("dungeon-id");
	StringFormat(dungeon, _, "dungeon-%d", dungeonid);

	dungeonEntity = EntityCreate("dungeon", dungeon, 1.0, 1.0, 6.0, GLOBAL_MAP);

}

public Close()
{
	CollisionSet(SELF, 1, 0);
	ObjectDelete(archObject);
}

main()
{
	/* Temporary code until engine handle screens better */
	FillMask();
}


public OpenDoor()
{
	return true;
}

public CloseDoor()
{
	return true;
} 


