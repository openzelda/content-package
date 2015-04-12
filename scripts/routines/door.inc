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
 *     2015/01/30  [luke]: new file.
 ***********************************************/
#include <public_events>
#include <quest_types>

/* Public Function */
forward public OpenDoor();
forward public CloseDoor();
forward public MovePlayer(entity:p, Directions:d);
forward public UpdatePlayer( entity:playerId, Fixed:playerWidth, Fixed:playerHeight )
forward PUBLIC_EVENT_HIT;

/* Door Target */
public hasTarget = false;
new targetWorld{64}
new entity:targetEntity;
new targetGrid = -1;

/* State */
public isOpen = 0;

/* */
new collision[RECT];
new transport[RECT];

/* Sprites */
new openSprite{64};
new closeSprite{64};
new archSprite{64};

new arch[DIMENSION];
new door[DIMENSION];


DoorInit( direction )
{
	new object:obj;

	qType = TYPE_DOOR;

	/* Get Settings */
	EntityGetSetting("object-content", openSprite);
	new rotation = EntityGetNumber("object-flip");
	if ( direction >= 0 )
		qDirection = Direction:direction;
	else
		qDirection = FlipDirections( rotation % 16 );

	/* Target */
	targetEntity = entity:EntityGetSettingHash("target.entity");
	targetGrid = EntityGetNumber("target.grid");
	EntityGetSetting("target.world", targetWorld);

	hasTarget = targetWorld{0} ? true : false;

	/* Settings */


	/* Object */
	qObject = EntityGetObject();
	if ( qDirection == EAST || qDirection == WEST )
		ObjectDimensions( qObject, door.h, door.w );
	else
	{
		// Flip North/South
		qDirection = (qDirection + 4) % 8;
		ObjectDimensions( qObject, door.w, door.h );
	}
	
	StringFormat(closeSprite, _, "%s-closed", openSprite);
	StringFormat(archSprite, _, "%s-arch", openSprite);

	/* Position */
	EntityGetPosition(qPosition.x, qPosition.y, qPosition.z);
	UpdateDisplayPosition();

	/* */
	if ( qDirection == NORTH )
	{
		transport.x = qDisplayArea.x + XOFFSET;
		transport.y = qDisplayArea.y;
		transport.w = door.w - XOFFSET - XOFFSET;
		transport.h = YOFFSET;

		collision.x = qDisplayArea.x + XOFFSET;
		collision.y = qDisplayArea.y + YOFFSET;
		collision.w = door.w - XOFFSET - XOFFSET;
		collision.h = door.h - YOFFSET;
	}
	else if ( qDirection == SOUTH )
	{
		transport.x = qDisplayArea.x + XOFFSET;
		transport.y = qDisplayArea.y + door.h - YOFFSET;
		transport.w = door.w - XOFFSET - XOFFSET;
		transport.h = YOFFSET;

		collision.x = qDisplayArea.x + XOFFSET;
		collision.y = qDisplayArea.y;
		collision.w = door.w - XOFFSET - XOFFSET;
		collision.h = door.h - YOFFSET;
	}
	else if ( qDirection == EAST )
	{
		transport.x = qDisplayArea.x + door.w - XOFFSET;
		transport.y = qDisplayArea.y + YOFFSET;
		transport.w = XOFFSET;
		transport.h = door.h - YOFFSET - YOFFSET;

		collision.x = qDisplayArea.x;
		collision.y = qDisplayArea.y + YOFFSET;
		collision.w = door.w - XOFFSET;
		collision.h = door.h - YOFFSET - YOFFSET;
	}
	else
	{
		transport.x = qDisplayArea.x;
		transport.y = qDisplayArea.y + YOFFSET;
		transport.w = XOFFSET;
		transport.h = door.h - YOFFSET - YOFFSET;

		collision.x = qDisplayArea.x + XOFFSET;
		collision.y = qDisplayArea.y + YOFFSET;
		collision.w = door.w - XOFFSET;
		collision.h = door.h - YOFFSET - YOFFSET;
	}

	MaskFill(qDisplayArea.x, qDisplayArea.y, door.w, door.h, MASK_PLAYERSOLID);

	if ( SheetSpriteDimension(archSprite, arch.w, arch.h) )
	{
		if ( qDirection == SOUTH )
		{
			obj = ObjectCreate(archSprite, SPRITE, qDisplayArea.x, qDisplayArea.y + door.h - arch.h, qPosition.z + 1.0, 0, 0);
		}
		else if ( qDirection == EAST )
		{
			obj = ObjectCreate(archSprite, SPRITE, qDisplayArea.x + door.h - arch.h- arch.h, qDisplayArea.y, qPosition.z + 1.0, 0, 0);
		}
		else
		{
			obj = ObjectCreate(archSprite, SPRITE, qDisplayArea.x, qDisplayArea.y, qPosition.z + 1.0, 0, 0);
		}
		ObjectEffect( obj, 0xFFFFFFFF, .mirror = rotation );
	}

	if ( EntityGetNumber("closed") )
	{
		CloseDoor();
	}
	else
	{
		OpenDoor();
	}

	return obj
}

FillMask()
{
	MaskFill(qDisplayArea.x, qDisplayArea.y, door.w, door.h, MASK_SOLID);
	MaskFill(transport.x, transport.y, transport.w, transport.h, (targetGrid == -1 ? MASK_PLAYERSOLID2 : MASK_AUTOWALK) ); 
	MaskFill(collision.x, collision.y, collision.w, collision.h, (isOpen  ? MASK_CLEAR : MASK_PLAYERSOLID2)); 
}

public UpdatePlayer( entity:playerId, Fixed:playerWidth, Fixed:playerHeight )
{

	ConsoleLog("Player Z: %q", qPosition.z + 0.1);
	ConsoleLog("Door Z: %q", qPosition.z);
	switch ( qDirection)
	{
		case NORTH:
			EntitySetPosition( qPosition.x + XOFFSET, qPosition.y, qPosition.z +  0.005, playerId);
		case SOUTH:
			EntitySetPosition( qPosition.x + XOFFSET, qPosition.y, qPosition.z +  0.005, playerId);
		case WEST:
			EntitySetPosition( qPosition.x, qPosition.y + YOFFSET, qPosition.z +  0.005, playerId);
		case EAST:
			EntitySetPosition( qPosition.x, qPosition.y + YOFFSET, qPosition.z + 0.005, playerId);
		default:
			EntitySetPosition( qPosition.x, qPosition.y, qPosition.z +  0.005, playerId);
	}

	EntityPublicFunction(playerId, "SetDir", [ARG_NUMBER, ARG_END], _, qDirection + 4);
	EntityPublicFunction(playerId, "UpdatePosition");
}

public MovePlayer(entity:p, Directions:d)
{
	new x, y;
	new entity:player = p;
	new targetMap,worldId;

	if ( hasTarget != true )
		return false;

	if ( targetGrid < 0 )
		return false;

	if ( qDirection != d )
		return false;

	x = (targetGrid % 64);
	y = (targetGrid / 64);


	worldId = WorldLoad(targetWorld);
	targetMap = WorldGetIdent( worldId, x, y  );


	return TransitionPlayer( player, targetEntity, targetMap );
}
