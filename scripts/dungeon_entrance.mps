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
new target[64];
new target_grid = -1;

forward public MovePlayer(player[], d);
forward public UpdatePlayer(player[]);

public Init(...)
{
	_type_ = TYPE_DOOR;
	EntityGetSetting("object-image", doorOpen);
	EntityGetSetting("target", target);
	EntityGetSetting("section", section);
	if ( target[0] )
		target_grid = EntityGetNumber("grid");

	dungeonid = EntityGetNumber("dungeon-id");
	strformat(dungeon, _, _, "dungeon-%d", dungeonid);


	EntityGetPosition(_x_,_y_,_z_);
	UpdateDisplayPosition();

	strformat(doorArch, _, _, "%s-arch", doorOpen);
	if ( MiscGetHeight(doorArch) )
	{
		arch = ObjectCreate(doorArch, SPRITE, dx, dy + height-16, 5, 0, 0,0xffffffff);
	}

	EntityCreate("dungeon", dungeon, 1, 1, 6, GLOBAL_MAP);

	//MaskFill(dx, dy, width, height, MASK_SOLID);
	MaskFill(dx + xoffset, dy, width - (xoffset*2), height - 4, MASK_PLAYERSOLID);
	CollisionSet(SELF, 1, TYPE_TRANSPORT, dx+xoffset, dy+yoffset, width-(xoffset*2), height-(yoffset*2)-8);

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

public UpdatePlayer(player[])
{
	new nplayer[64];
	strcopy(nplayer, player);
	EntitySetPosition(_x_ + fixed(xoffset), _y_+8.00, _, nplayer);
	EntityPublicFunction(nplayer, "SetDir", "n", NORTH);
	EntityPublicFunction(nplayer, "UpdatePosition");

	EntityPublicFunction(dungeon, "Entered");
	EntityPublicFunction("main", "SetDay", "n", 0);

	//SetRestartPosition(point, nx, ny, ngrid, nname[])
	//EntityPublicFunction(player, "SetRestartPosition", "nnnns", 0, -1, -1, -1, "Dungeon");
	
}

public MovePlayer(player[], d)
{
	if ( target_grid < 0 )
		return false;
	if ( _dir_ != d )
		return false;

	if ( target_grid >= 0)
	{
		new x = (target_grid % 64); 
		new y = (target_grid / 64);
	
		if ( SectionValid(section,x, y) )
		{
			new nplayer[64];
			strcopy(nplayer, player);
			//SetTarget(ntarget[], nx, ny)
			TransitionPlayer( nplayer, target, 0, _, x, y );
			EntityPublicFunction(dungeon, "Exited");
			EntityPublicFunction("main", "SetDay", "n", 1);
			return true;
		}
	}
	return false;
}

