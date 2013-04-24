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

new doorOpen{64};
new doorClose{64};
new doorArch{64};
new doorAnim{64};

new width = 64;
new height = 48;

new offset = 4;
new xoffset = 12;
new yoffset = 8;

new object:archObject = OBJECT_NONE;
new bool:animating = false;



new keyType = 0;
new closedDoor = 0;
new shutDoor = 0;

/* Door Target */
new section{64};
new entityId:target_entity;
new target_grid = -1;

forward public OpenDoor();
forward public CloseDoor();
forward public MovePlayer(p, d);
forward public UpdatePlayer(player);
forward PUBLIC_EVENT_HIT;



public Init(...)
{
	new flip;

	mqType = TYPE_DOOR;

	/* Get Settings */
	EntityGetSetting("object-image", doorOpen);
	EntityGetSetting("section", section);
	target_entity = entityId:EntityGetSettingHash("target");
	target_grid = EntityGetNumber("target_map");

	closedDoor = EntityGetNumber("closed");
	shutDoor = EntityGetNumber("shut");
	keyType = EntityGetNumber("key");

	mqDisplayObject = EntityGetObject();
	flip = EntityGetNumber("object-flip");
	
	mqDirection = (flip > 15 ? flip - 16 : flip) * 2;

	if ( mqDirection == _:NORTH )
		mqDirection = SOUTH;
	else if ( mqDirection == _:SOUTH )
		mqDirection = NORTH;

	if ( mqDirection == _:EAST || mqDirection == _:WEST )
	{
		xoffset = 8;
		yoffset = 12;
	}

	StringFormat(doorClose, _, true, "%s-%s", doorOpen, ( keyType ? "locked" : "closed"));
	StringFormat(doorArch, _, true, "%s-arch", doorOpen);

	GetEntityPosition(mqEntityPosition.x, mqEntityPosition.y, mqEntityPosition.z, mqDisplayArea.x, mqDisplayArea.y, mqDisplayZIndex, mqDisplayLayer);
	
	MaskFill(mqDisplayArea.x , mqDisplayArea.y, width, height, MASK_WALK );
	if ( mqDirection == _:EAST || mqDirection == _:WEST )
	{
		width = MiscGetHeight(doorOpen);
		height = MiscGetWidth(doorOpen);
		if ( target_grid == -1 )
			MaskFill(mqDisplayArea.x + (mqDirection == _:EAST ? width : -8) , mqDisplayArea.y, 8, height, MASK_AUTOWALK);
		else
			MaskFill(mqDisplayArea.x + (mqDirection == _:EAST ? width : -8) , mqDisplayArea.y, 8, height, MASK_PLAYERSOLID);
	}
	else
	{
		width = MiscGetWidth(doorOpen);
		height = MiscGetHeight(doorOpen);
		if ( target_grid == -1 )
			MaskFill(mqDisplayArea.x , mqDisplayArea.y + (mqDirection == _:SOUTH ? height : -8), width, 8, MASK_AUTOWALK);
		else
			MaskFill(mqDisplayArea.x , mqDisplayArea.y + (mqDirection == _:SOUTH ? height : -8), width, 8, MASK_PLAYERSOLID);
	}

	if ( mqDirection == _:EAST || mqDirection == _:WEST )
		MaskFill(mqDisplayArea.x, mqDisplayArea.y + yoffset, width, height - (yoffset*2), MASK_WALK);
	else
		MaskFill(mqDisplayArea.x + xoffset, mqDisplayArea.y, width - (xoffset*2), height, MASK_WALK);


	if ( MiscGetHeight(doorArch) )
	{
		archObject = ObjectCreate(doorArch, SPRITE, mqDisplayArea.x + (mqDirection == _:EAST ? height-32 : 0) , mqDisplayArea.y+ (mqDirection == _:SOUTH ? width-32 : 0), mqDisplayZIndex+1000, 0, 0);
		ObjectEffect(archObject, 0xffffffff, _, _, _, flip, _, _);
	}

	
	if ( closedDoor == 0 )
		OpenDoor();
	else
		CloseDoor();
}

public Close()
{
	ObjectDelete(archObject);
}


main()
{
	/* Temporary code until engine handle screens better */
	if ( !closedDoor )
	{
		if ( mqDirection == _:EAST || mqDirection == _:WEST )
			MaskFill(mqDisplayArea.x, mqDisplayArea.y + yoffset, width, height - (yoffset*2), MASK_WALK);
		else
			MaskFill(mqDisplayArea.x + xoffset, mqDisplayArea.y, width - (xoffset*2), height, MASK_WALK);
	}
	else
	{
		MaskFill(mqDisplayArea.x, mqDisplayArea.y, width, height, MASK_SOLID);
	}

}



public OpenDoor()
{
	closedDoor = 0;
	if ( mqDirection == _:EAST || mqDirection == _:WEST )
		MaskFill(mqDisplayArea.x, mqDisplayArea.y + yoffset, width, height - (yoffset*2), MASK_WALK);
	else
		MaskFill(mqDisplayArea.x + xoffset, mqDisplayArea.y, width - (xoffset*2), height, MASK_WALK);

	CollisionSet(SELF, 0, 0);
	CollisionSet(SELF, 1, TYPE_TRANSPORT, mqDisplayArea.x+xoffset, mqDisplayArea.y+yoffset, width-(xoffset*2), height-(yoffset*2));
	
	ObjectReplace(mqDisplayObject, doorOpen, SPRITE); 
	ObjectFlag(mqDisplayObject, FLAG_ANIMLOOP, false);
	ObjectFlag(mqDisplayObject, FLAG_ANIMRESET, false);

	return closedDoor;
}

public CloseDoor()
{
	closedDoor = 1;
	MaskFill(mqDisplayArea.x, mqDisplayArea.y, width, height, MASK_SOLID);
	CollisionSet(SELF, 0, mqType, mqDisplayArea.x, mqDisplayArea.y, width, height);
	CollisionSet(SELF, 1, 0);

	ObjectReplace(mqDisplayObject, doorClose, SPRITE); 
	ObjectFlag(mqDisplayObject, FLAG_ANIMLOOP, false);
	ObjectFlag(mqDisplayObject, FLAG_ANIMREVERSE, true);
	ObjectFlag(mqDisplayObject, FLAG_ANIMRESET, true);

	return closedDoor;
}

// Hit( attacker[], angle, dist, attack, damage, x, y )
PUBLIC_EVENT_HIT
{
	if ( attack&APLAYER == APLAYER )
	{
		if ( closedDoor )
		{
			if ( keyType )
			{
				if ( true )  //TODO  Take Key from player
				{
					OpenDoor();
				}
			}
			else if ( !shutDoor )
			{
				OpenDoor();
			}
		}
	}
}

public UpdatePlayer(player)
{
	EntitySetPosition(mqEntityPosition.x + fixed(xoffset), mqEntityPosition.y+fixed(yoffset), _, player);

	EntityPublicFunction(player, "SetDir", ''n'', mqDirection + 4);
	EntityPublicFunction(player, "UpdatePosition");
}

public MovePlayer(p, d)
{
	new player = p;
	if ( target_grid < 0 )
		return false;

	if ( mqDirection != d )
		return false;

	new x, y;
	
	x = (target_grid % 64);
	y = (target_grid / 64);




	return TransitionPlayer( player, target_entity, 0, section, x, y );
}

