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
new target_entity;
new target_grid = -1;

forward public OpenDoor();
forward public CloseDoor();
forward public MovePlayer(player, d);
forward public UpdatePlayer(player);
forward public Hit( attacker, angle, dist, attack, damage, x, y, rect );

public Init(...)
{
	new flip;
	mqType = TYPE_DOOR;

	/* Get Settings */
	EntityGetSetting("object-image", doorOpen);
	EntityGetSetting("section", section);
	target_entity = EntityGetSettingHash("target");
	target_grid = EntityGetNumber("target_map");
	open = opened = bool:EntityGetNumber("opened");
	locked = EntityGetNumber("locktype");
	obj = EntityGetNumber("object-id");
	flip = EntityGetNumber("object-flipmode");
	
	mqDirection = (flip > 15 ? flip - 16 : flip) * 2;

	if ( mqDirection == NORTH )
		mqDirection = SOUTH;
	else if ( mqDirection == SOUTH )
		mqDirection = NORTH;

	if ( mqDirection == EAST || mqDirection == WEST )
	{
		xoffset = 8;
		yoffset = 12;
	}

	strformat(doorClose, _, _, "%s-%s", doorOpen, (locked ? "locked" : "closed"));
	strformat(doorArch, _, _, "%s-arch", doorOpen);

	EntityGetPosition(mqEntityPosition.x,mqEntityPosition.y,mqDisplayZIndex);
	UpdateDisplayPosition();
	
	MaskFill(mqDisplayArea.x , mqDisplayArea.y, width, height, MASK_WALK );
	if ( mqDirection == EAST || mqDirection == WEST )
	{
		width = MiscGetHeight(doorOpen);
		height = MiscGetWidth(doorOpen);
		if ( target_grid == -1 )
			MaskFill(mqDisplayArea.x + (mqDirection == EAST ? width : -8) , mqDisplayArea.y, 8, height, MASK_AUTOWALK);
		else
			MaskFill(mqDisplayArea.x + (mqDirection == EAST ? width : -8) , mqDisplayArea.y, 8, height, MASK_PLAYERSOLID);
	}
	else
	{
		width = MiscGetWidth(doorOpen);
		height = MiscGetHeight(doorOpen);
		if ( target_grid == -1 )
			MaskFill(mqDisplayArea.x , mqDisplayArea.y + (mqDirection == SOUTH ? height : -8), width, 8, MASK_AUTOWALK);
		else
			MaskFill(mqDisplayArea.x , mqDisplayArea.y + (mqDirection == SOUTH ? height : -8), width, 8, MASK_PLAYERSOLID);
	}
	if ( mqDirection == EAST || mqDirection == WEST )
		MaskFill(mqDisplayArea.x, mqDisplayArea.y + yoffset, width, height - (yoffset*2), MASK_WALK);
	else
		MaskFill(mqDisplayArea.x + xoffset, mqDisplayArea.y, width - (xoffset*2), height, MASK_WALK);
	if ( MiscGetHeight(doorArch) )
	{
		arch = ObjectCreate(doorArch, SPRITE, mqDisplayArea.x + (mqDirection == EAST ? height-32 : 0) , mqDisplayArea.y+ (mqDirection == SOUTH ? width-32 : 0), 5000, 0, 0);
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
	if ( mqDirection == EAST || mqDirection == WEST )
		MaskFill(mqDisplayArea.x, mqDisplayArea.y + yoffset, width, height - (yoffset*2), MASK_WALK);
	else
		MaskFill(mqDisplayArea.x + xoffset, mqDisplayArea.y, width - (xoffset*2), height, MASK_WALK);

	CollisionSet(SELF, 0, 0);
	CollisionSet(SELF, 1, TYPE_TRANSPORT, mqDisplayArea.x+xoffset, mqDisplayArea.y+yoffset, width-(xoffset*2), height-(yoffset*2));
	
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
		if ( mqDirection == EAST || mqDirection == WEST )
			MaskFill(mqDisplayArea.x, mqDisplayArea.y + yoffset, width, height - (yoffset*2), MASK_WALK);
		else
			MaskFill(mqDisplayArea.x + xoffset, mqDisplayArea.y, width - (xoffset*2), height, MASK_WALK);
	}
	else
	{
		MaskFill(mqDisplayArea.x, mqDisplayArea.y, width, height, MASK_SOLID);
	}


}

public CloseDoor()
{
	open = false;
	MaskFill(mqDisplayArea.x, mqDisplayArea.y, width, height, MASK_SOLID);
	CollisionSet(SELF, 0, mqType, mqDisplayArea.x, mqDisplayArea.y, width, height);
	CollisionSet(SELF, 1, 0);

	ObjectReplace(object:obj, doorClose, SPRITE); 
	ObjectFlag(object:obj, FLAG_ANIMLOOP, false);
	ObjectFlag(object:obj, FLAG_ANIMREVERSE, true);
	ObjectFlag(object:obj, FLAG_ANIMRESET, true);
}

// Hit( attacker[], angle, dist, attack, damage, x, y )
public Hit( attacker, angle, dist, attack, damage, x, y, rect )
{
	if ( attack&APLAYER == APLAYER )
	{
		/* Take Key from player */
		if ( !opened && locked )
			OpenDoor();
	}
}

public UpdatePlayer(player)
{
	EntitySetPosition(mqEntityPosition.x + fixed(xoffset), mqEntityPosition.y+fixed(yoffset), _, player);
	EntityPublicFunction(player, "SetDir", ''n'', mqDirection + 4);
	EntityPublicFunction(player, "UpdatePosition");
}

public MovePlayer(player, d)
{
	if ( target_grid < 0 )
		return false;
	if ( mqDirection != d )
		return false;

	new x, y;
	
	x = (target_grid % 64);
	y = (target_grid / 64);



	return TransitionPlayer( player, target_entity, _, section, x, y );
}

