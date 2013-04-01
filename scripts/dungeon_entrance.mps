#include <open_zelda>
#include <string>

new doorArch[64];
new doorOpen[64];

new width = 64;
new height = 48;

new xoffset = 14;
new yoffset = 8;

new dungeon[32] = "dungeon-d";
new dungeonid = 0;
new dir = -1;
new arch = -1;

new section[64];
new target;
new target_grid = -1;

forward public MovePlayer(player, d);
forward public UpdatePlayer(player );

public Init(...)
{
	mqType = TYPE_DOOR;
	EntityGetSetting("object-image", doorOpen);
	target = EntityGetSettingHash("target");
	EntityGetSetting("section", section);
	if ( target )
		target_grid = EntityGetNumber("grid");

	dungeonid = EntityGetNumber("dungeon-id");
	strformat(dungeon, _, _, "dungeon-%d", dungeonid);


	EntityGetPosition(mqEntityPosition.x,mqEntityPosition.y,mqDisplayZIndex);
	UpdateDisplayPosition();

	strformat(doorArch, _, _, "%s-arch", doorOpen);
	if ( MiscGetHeight(doorArch) )
	{
		arch = ObjectCreate(doorArch, SPRITE, mqDisplayArea.x, mqDisplayArea.y + height-16, 5, 0, 0,0xffffffff);
	}

	EntityCreate("dungeon", dungeon, 1, 1, 6, GLOBAL_MAP);

	//MaskFill(mqDisplayArea.x, mqDisplayArea.y, width, height, MASK_SOLID);
	MaskFill(mqDisplayArea.x + xoffset, mqDisplayArea.y, width - (xoffset*2), height - 4, MASK_PLAYERSOLID);
	CollisionSet(SELF, 1, TYPE_TRANSPORT, mqDisplayArea.x+xoffset, mqDisplayArea.y+yoffset, width-(xoffset*2), height-(yoffset*2)-8);

}

public Close()
{
	CollisionSet(SELF, 1, 0);
	if ( arch != -1) 
		ObjectDelete(object:arch);
}

main()
{

}

public UpdatePlayer(player)
{
	EntitySetPosition(mqEntityPosition.x + fixed(xoffset), mqEntityPosition.y+8.00, _, player);
	EntityPublicFunction(player, "SetDir", ''n'', NORTH);
	EntityPublicFunction(player, "UpdatePosition");

	EntityPublicFunction(dungeonid, "Entered", '''');
	EntityPublicFunction(EntityHash("main"), "SetDay", ''n'', 0);

	//SetRestartPosition(point, nx, ny, ngrid, nname[])
	//EntityPublicFunction(player, "SetRestartPosition", "nnnns", 0, -1, -1, -1, "Dungeon");
	
}

public MovePlayer(player, d)
{
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
			TransitionPlayer( player, target, 0, _, x, y );
			EntityPublicFunction( dungeonid, "Exited");
			EntityPublicFunction( EntityHash("main"), "SetDay", "n", 1);
			return true;
		}
	}
	return false;
}

