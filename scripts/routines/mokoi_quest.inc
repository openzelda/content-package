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
#if defined _mokoi_quest_included
  #endinput
#endif
#define _mokoi_quest_included

/* Mokoi Quest
 *  Routines that are part of most entities
 */

#include <quest_types>
#include <private_language>
#include <helper>
#include <enums>
#include <core>
#include <system>

/* public functions */

forward public SetState(q);
forward public GetState();
forward public GetType();
forward public SetType(q);
forward public GetDir();
forward public SetDir(q);


/* Public Variables */
public EntityState:qState = ALIVE;
public qType = 0;
public Directions:qDirection = SOUTH;
public object:qObject;


/* Local Variables */
stock entity:qId;
stock qPosition[VECTOR3];
stock qDisplayArea[RECT] = [ 0, 0, 16, 16];
stock qDisplayOffset[POINT];
stock qDisplayDirection = 0;
stock qUpdate = false;
new Directions:qDirectionPrev = Directions:-1;
new EntityState:qStatePrev = UNSETSTATE;


/**/
forward @AutoPreInit();
@AutoPreInit()
{
	qId = entity:EntityGetNumber("id");
}


/* Functions */
stock SetupEntity( EntityState:init_state, type, &object:display_object, width, height, offset_x = 0, offset_y = 0 )
{
	qState = init_state;
	qType = type;
	qDisplayArea.h = height;
	qDisplayArea.w = width;
	qDisplayOffset.x = offset_x
	qDisplayOffset.y = offset_y;
	qObject = EntityGetObject();
	qId = entity:EntityGetNumber("id");
	GetEntityPosition( qPosition.x, qPosition.y, qPosition.z, qDisplayArea.x, qDisplayArea.y );

}

stock SetEntityDimension( width, height, offset_x = 0, offset_y = 0 )
{
	qDisplayArea.h = height;
	qDisplayArea.w = width;
	qDisplayOffset.x = offset_x
	qDisplayOffset.y = offset_y;

	GetEntityPosition( qPosition.x, qPosition.y, qPosition.z, qDisplayArea.x, qDisplayArea.y );
}

stock GetEntityPosition( &Fixed:fx, &Fixed:fy, &Fixed:fz, &ix, &iy )
{
	EntityGetPosition(fx, fy, fz); // Fixed Position
	ix = fround(fx, round_unbiased); // Display Positions
	iy = fround(fy, round_unbiased);
}

stock UpdateDisplayPosition()
{
	qDisplayArea.x = fround(qPosition.x, round_unbiased);
	qDisplayArea.y = fround(qPosition.y, round_unbiased);
}

stock HasStateChanged()
{
	new changed = false;
	if ( qState != qStatePrev || qDirection != qDirectionPrev )
		changed = qUpdate = true;
	else
		qUpdate = false;
	qStatePrev = qState;
	qDirectionPrev = qDirection;
	return changed;
}

/* public functions */
public GetDir()
{
	return _:qDirection;
}

public SetDir(q)
{
	q %= 8; // Make sure q is between 0-7.
	qDirection = Directions:q;
	qDisplayDirection = _:q/2;
	return _:qDirection;
}

public GetState()
{
	return _:qState;
}

public SetState(q)
{
	qState = EntityState:q;
	return _:qState;
}

public GetType()
{
	return qType;
}

public SetType(q)
{
	qType = q;
	return qType;
}
