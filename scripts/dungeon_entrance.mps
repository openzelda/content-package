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

new doorArch{64};
new doorOpen{64};

new width = 64;
new height = 48;

new xoffset = 14;
new yoffset = 8;

new dungeon{32} = "dungeon-d";
new dungeonid = 0;
new entityId:dungeonEntity;

new dir = -1;
new object:arch = OBJECT_NONE;

new section{64};
new entityId:target_entity;
new target_grid = -1;

forward public MovePlayer( p, d );
forward public UpdatePlayer( p );

public Init(...)
{
	mqType = TYPE_DOOR;

	/* Get Settings */
	EntityGetSetting("object-image", doorOpen);
	EntityGetSetting("section", section);
	target_entity = entityId:EntityGetSettingHash("target");
	target_grid = EntityGetNumber("target_map");

	dungeonid = EntityGetNumber("dungeon-id");
	StringFormat(dungeon, _, true, "dungeon-%d", dungeonid);


	GetEntityPosition(mqEntityPosition.x, mqEntityPosition.y, mqEntityPosition.z, mqDisplayArea.x, mqDisplayArea.y, mqDisplayZIndex, mqDisplayLayer);
	

	StringFormat(doorArch, _, true, "%s-arch", doorOpen);
	if ( MiscGetHeight(doorArch) )
	{
		arch = ObjectCreate(doorArch, SPRITE, mqDisplayArea.x, mqDisplayArea.y + height-16, mqDisplayZIndex+1000, 0, 0,0xffffffff);
	}

	dungeonEntity = EntityCreate("dungeon", dungeon, 1.0, 1.0, 6.0, GLOBAL_MAP);

	MaskFill(mqDisplayArea.x + xoffset, mqDisplayArea.y, width - (xoffset*2), height - 4, MASK_PLAYERSOLID);
	CollisionSet(SELF, 1, TYPE_TRANSPORT, mqDisplayArea.x+xoffset, mqDisplayArea.y+yoffset, width-(xoffset*2), height-(yoffset*2)-8);

}

public Close()
{
	CollisionSet(SELF, 1, 0);
	ObjectDelete(object:arch);
}

main()
{

}

public UpdatePlayer( p )
{
	new player = p;


	EntitySetPosition(mqEntityPosition.x + fixed(xoffset), mqEntityPosition.y+fixed(yoffset), _, player);

	EntityPublicFunction(player, "SetDir", ''n'', mqDirection + 4);
	EntityPublicFunction(player, "UpdatePosition");

	EntityPublicFunction(dungeonid, "Entered");
	EntityPublicFunction(ENTITY_MAIN, "SetDay", ''n'', 0);

	// SetRestartPosition( point, ndescription{}, nx, ny, nmapid );
	EntityPublicFunction(player, "SetRestartPosition", ''nsnnn'', 0, "Dungeon", mqDisplayArea.x + xoffset, mqDisplayArea.y  +yoffset , -1 );

	
}

public MovePlayer(p, d)
{
	new player = p;

	if ( target_grid < 0 )
		return false;
	if ( mqDirection != d )
		return false;

	if ( target_grid >= 0)
	{
		new x = (target_grid % 64); 
		new y = (target_grid / 64);
	
		if ( SectionValid(section,x, y) )
		{
			TransitionPlayer( player, target_entity, 0, section, x, y );
			EntityPublicFunction( dungeonid, "Exited");
			EntityPublicFunction( ENTITY_MAIN, "SetDay", "n", 1);
			return true;
		}
	}
	return false;
}

