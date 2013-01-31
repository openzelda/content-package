#include <open_zelda>
#include <string>

new doorOpen[64];
new doorClose[64];
new doorArch[64];
new doorAnim[64];

new width = 64;
new height = 48;

new offset = 4;
new xoffset = 12;
new yoffset = 8;
new bool:open = false;

new locked = 0;
new bool:opened = 0;
new obj =-1, arch = -1;

/* Door Target */
new section[64];
new target_entity[64];
new target_grid = -1;

forward public OpenDoor();
forward public CloseDoor();
forward public MovePlayer(player[], d);
forward public UpdatePlayer(player[]);
forward public Hit( attacker[], angle, dist, attack, damage, x, y, rect );

public Init(...)
{
	new flip;
	_type_ = TYPE_DOOR;

	/* Get Settings */
	EntityGetSetting("object-image", doorOpen);
	EntityGetSetting("section", section);
	EntityGetSetting("target", target_entity);
	target_grid = EntityGetNumber("target_map");
	open = opened = bool:EntityGetNumber("opened");
	locked = EntityGetNumber("locktype");
	obj = EntityGetNumber("object-id");
	flip = EntityGetNumber("object-flipmode");
	
	_dir_ = (flip > 15 ? flip - 16 : flip) * 2;

	if ( _dir_ == NORTH )
		_dir_ = SOUTH;
	else if ( _dir_ == SOUTH )
		_dir_ = NORTH;

	if ( _dir_ == EAST || _dir_ == WEST )
	{
		xoffset = 8;
		yoffset = 12;
	}

	strformat(doorClose, _, _, "%s-%s", doorOpen, (locked ? "locked" : "closed"));
	strformat(doorArch, _, _, "%s-arch", doorOpen);

	EntityGetPosition(_x_,_y_,_z_);
	UpdateDisplayPosition();
	
	MaskFill(dx , dy, width, height, MASK_WALK );
	if ( _dir_ == EAST || _dir_ == WEST )
	{
		width = MiscGetHeight(doorOpen);
		height = MiscGetWidth(doorOpen);
		if ( target_grid == -1 )
			MaskFill(dx + (_dir_ == EAST ? width : -8) , dy, 8, height, MASK_AUTOWALK);
		else
			MaskFill(dx + (_dir_ == EAST ? width : -8) , dy, 8, height, MASK_PLAYERSOLID);
	}
	else
	{
		width = MiscGetWidth(doorOpen);
		height = MiscGetHeight(doorOpen);
		if ( target_grid == -1 )
			MaskFill(dx , dy + (_dir_ == SOUTH ? height : -8), width, 8, MASK_AUTOWALK);
		else
			MaskFill(dx , dy + (_dir_ == SOUTH ? height : -8), width, 8, MASK_PLAYERSOLID);
	}
	if ( _dir_ == EAST || _dir_ == WEST )
		MaskFill(dx, dy + yoffset, width, height - (yoffset*2), MASK_WALK);
	else
		MaskFill(dx + xoffset, dy, width - (xoffset*2), height, MASK_WALK);
	if ( MiscGetHeight(doorArch) )
	{
		arch = ObjectCreate(doorArch, SPRITE, dx + (_dir_ == EAST ? height-32 : 0) , dy+ (_dir_ == SOUTH ? width-32 : 0), 5000, 0, 0);
		ObjectEffect(object:arch, 0xffffffff, _, _, _, flip, _, _);
	}

	CloseDoor();
	if ( opened == true )
		OpenDoor();
}


public OpenDoor()
{
	open = true;
	opened = false;
	if ( _dir_ == EAST || _dir_ == WEST )
		MaskFill(dx, dy + yoffset, width, height - (yoffset*2), MASK_WALK);
	else
		MaskFill(dx + xoffset, dy, width - (xoffset*2), height, MASK_WALK);

	CollisionSet(SELF, 0, 0);
	CollisionSet(SELF, 1, TYPE_TRANSPORT, dx+xoffset, dy+yoffset, width-(xoffset*2), height-(yoffset*2));
	
	ObjectReplace(object:obj, doorOpen, SPRITE); 
	ObjectFlag(object:obj, FLAG_ANIMLOOP, false);
	ObjectFlag(object:obj, FLAG_ANIMRESET, false);
}

main()
{
	DebugText("'%s' '%s' '%d'", section, target_entity, target_grid);
	DebugText("'%d'", opened);
	/* Temporary code until engine handle screens better */

	if ( open )
	{
		if ( _dir_ == EAST || _dir_ == WEST )
			MaskFill(dx, dy + yoffset, width, height - (yoffset*2), MASK_WALK);
		else
			MaskFill(dx + xoffset, dy, width - (xoffset*2), height, MASK_WALK);
	}
	else
	{
		MaskFill(dx, dy, width, height, MASK_SOLID);
	}


}

public CloseDoor()
{
	open = false;
	MaskFill(dx, dy, width, height, MASK_SOLID);
	CollisionSet(SELF, 0, _type_, dx, dy, width, height);
	CollisionSet(SELF, 1, 0);

	ObjectReplace(object:obj, doorClose, SPRITE); 
	ObjectFlag(object:obj, FLAG_ANIMLOOP, false);
	ObjectFlag(object:obj, FLAG_ANIMREVERSE, true);
	ObjectFlag(object:obj, FLAG_ANIMRESET, true);
}

// Hit( attacker[], angle, dist, attack, damage, x, y )
public Hit( attacker[], angle, dist, attack, damage, x, y, rect )
{
	if ( attack&APLAYER == APLAYER )
	{
		/* Take Key from player */
		if ( !opened && locked )
			OpenDoor();
	}
}

public UpdatePlayer(player[])
{
	new nplayer[64];
	StringCopy(nplayer, player);
	EntitySetPosition(_x_ + fixed(xoffset), _y_+fixed(yoffset), _, nplayer);
	EntityPublicFunction(nplayer, "SetDir", "n", _dir_ + 4);
	EntityPublicFunction(nplayer, "UpdatePosition");
}

public MovePlayer(player[], d)
{
	if ( target_grid < 0 )
		return false;
	if ( _dir_ != d )
		return false;

	new x, y;
	new nplayer[64];
	
	x = (target_grid % 64);
	y = (target_grid / 64);

	strcopy(nplayer, player);

	return TransitionPlayer( nplayer, target_entity, _, section, x, y );
}

