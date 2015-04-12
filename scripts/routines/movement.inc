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
 *     2013/04/01 [luke]: new file.
 ***********************************************/
#include <collision>

#define STOREDPOSITION[.x, .y, Fixed:.z, .dir]

stock Fixed:qMovementAngle = 0.0;
stock Fixed:qMovementSpeed = 0.0;
stock qLocations[6][STOREDPOSITION];
stock qHitMaskCheck[3];
stock bool:qFlipYMovement = false;
stock bool:qFlipXMovement = false;
stock bool:qAllowOffscreenMovement = false

stock round_method:qMovementRounding[4][2] = [ [round_floor, round_ceil], [round_ceil, round_ceil], [round_ceil, round_floor], [round_floor, round_floor] ]; /* South, west, north, east */

stock Fixed:MovementAngle(Fixed:x_movement, Fixed:y_movement)
{
	return fatan2( y_movement, x_movement, degrees);
}

stock Fixed:Dir2Angle(d)
{
	d %= 8;
	return fixed(d*45);
}

stock D2A(d)
{
	d %= 8;
	return d*45;
}

stock Angle2Dir(Fixed:a, Fixed:offset = 0.0)
{
	a += offset;
	if ( a < 0.0 )
		a += 360.0;
	else if ( a >= 360.0 )
		a -= 360.0;
	return NumberClamp(fround(a) / 45, 0, 7);
}


stock StorePosition()
{
	for ( new i = 5; i > 0; i-- )
	{
		qLocations[i] = qLocations[i-1];
	}
	qLocations[0].x = qDisplayArea.x;
	qLocations[0].y = qDisplayArea.y;
	qLocations[0].z = qPosition.z;
	qLocations[0].dir = qDirection;
}


stock EntityMove( maxmask, push_off = true )
{
	new Fixed:speed =  qMovementSpeed * GameFrameSeconds();
	new results = 0;

	if (speed > 1.0)
	{
		while ( speed > 1.0 )
		{
			results += EntityMoveCode(maxmask,1.0, push_off);
			speed -= 1.0;
		}
	}
	results += EntityMoveCode(maxmask, speed, push_off);
	StorePosition();
	return results;
}

stock EntityMoveCode( maxmask, Fixed:speed, push_off = true )
{
	if (!speed)
		return false;

	new Fixed:movex = ( qFlipXMovement ? -fsin(qMovementAngle, degrees) : fsin(qMovementAngle, degrees) ) * speed;
	new Fixed:movey = ( qFlipYMovement ? -fcos(qMovementAngle, degrees) : fcos(qMovementAngle, degrees) ) * speed;
	new na = 0; // new angle
	new r = false;

	if ( MoveCheck(na, qMovementAngle, maxmask, movex, movey) )
	{
		qPosition.x += movex;
		qPosition.y += movey;
		r = true;
	}
	else if ( push_off )
	{
		if ( na )
		{
			qMovementAngle += fixed(na);
			movex = fsin(qMovementAngle, degrees);
			movey = fcos(qMovementAngle, degrees);
			qPosition.x += movex/4.0;
			qPosition.y += movey/4.0;
			r = true;
		}
		else
		{
			qPosition.x = fixed( fround(qPosition.x, qMovementRounding[qDisplayDirection][0]) );
			qPosition.y = fixed( fround(qPosition.y, qMovementRounding[qDisplayDirection][1]) );
		}
	}
	else
	{
		qPosition.x = fixed( fround(qPosition.x, qMovementRounding[qDisplayDirection][0]) );
		qPosition.y = fixed( fround(qPosition.y, qMovementRounding[qDisplayDirection][1]) );
	}
	EntitySetPosition(qPosition.x, qPosition.y, qPosition.z );
	UpdateDisplayPosition();

	qMovementAngle %= 360.0;

	return r;

}


stock MoveCheck(&a, Fixed:angle, maximum_mask_value, Fixed:movex, Fixed:movey)
{
	new checks[8][POSITION];

	qDirection = Angle2Dir(angle, 22.5);
	qDisplayDirection = NumberClamp((qDirection/2), 0, 3);

	UpdateCollisionPoints( checks, fround(movex, qMovementRounding[qDisplayDirection][0]), fround(movey, qMovementRounding[qDisplayDirection][1]) );
	DisplayCollisionPoints( checks );

	new l,r,q = qDirection;
	l = (qDirection >= 7 ? 0 : qDirection + 1);
	r = (qDirection == 0 ? 7 : qDirection - 1);

	qHitMaskCheck[0] = MaskGetValue( checks[q].x, checks[q].y);
	qHitMaskCheck[1] = MaskGetValue( checks[l].x, checks[l].y);
	qHitMaskCheck[2] = MaskGetValue( checks[r].x, checks[r].y);

	ConsoleOutput("qHitMaskCheck[0] %d %d x%d ", qHitMaskCheck[0], checks[q].x, checks[q].y );
	ConsoleOutput("qHitMaskCheck[1] %d", qHitMaskCheck[1] );
	ConsoleOutput("qHitMaskCheck[2] %d", qHitMaskCheck[2] );

	if( qHitMaskCheck[0] > 255 )
	{
		if ( qAllowOffscreenMovement )
		{
			return true;
		}
		else
		{
			return false;
		}
	}
	else if ( qHitMaskCheck[0] > maximum_mask_value )
	{
		if ( MaskGetValue( checks[q].x, checks[q].y) > maximum_mask_value )
		{
			a = 0;
			return false;
		}
		return false;
	}
	else
	{
		if ( qHitMaskCheck[1] > maximum_mask_value )
			a -= 30;
		else
			qHitMaskCheck[1]  = 0;


		if ( qHitMaskCheck[2] > maximum_mask_value )
			a += 30;
		else
			qHitMaskCheck[2] = 0;
	}

	return !a;

}

