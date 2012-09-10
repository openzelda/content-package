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
/* Mokoi Quest 
 *  Routines that are part of most entities
 */

#include <quest_types>
#include <helper>

/* Variables */
stock Fixed:_angle_ = 0.0;
stock Fixed:_speed_ = 0.0;
stock Fixed:_x_, Fixed:_y_, Fixed:_z_;
stock dx, dy, dz, dl;
stock dw = 16, dh = 16;
stock ox = 0, oy = 0;
stock locations[6][4];
stock _hit[2];
stock bool:_flipy_ = false;
stock bool:_flipx_ = false;
stock bool:_allow_offscreen = false 

/* South, west, north, east */
stock round_method:move_round[4][2] = { {round_floor, round_ceil}, {round_ceil, round_ceil}, {round_ceil, round_floor}, {round_floor, round_floor} };


stock ReplaceEntityGraphics( display_object[EntityGraphic], image[], bool:flip, bool:force = false )
{
	//if ( update || force )
	//{
		ObjectReplace( display_object[egOBJ], image, SPRITE );
		ObjectEffect( display_object[egOBJ], .mirror = (flip ? 16 : 0) );
	//}
}

stock UpdateEntityGraphics( display_object[EntityGraphic] )
{
	ObjectPosition( display_object[egOBJ], dx+display_object[egOFFX], dy+display_object[egOFFY], dz+display_object[egOFFZ], 0, 0);
}
stock ColourEntityGraphics( display_object[EntityGraphic], colour )
{
	ObjectEffect( display_object[egOBJ], colour);
}


stock fixed:MovementAngle(Fixed:x_movement, Fixed:y_movement)
{
	return fatan2( x_movement, -y_movement, degrees)+ 90.0 ;
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
		locations[i][0] = locations[i-1][0];
		locations[i][1] = locations[i-1][1];
		locations[i][2] = locations[i-1][2];
		locations[i][3] = locations[i-1][3];
	}
	locations[0][0] = dx;
	locations[0][1] = dy;
	locations[0][2] = dz;
	locations[0][3] = _dir_;
}

stock UpdateDisplayPosition()
{
	dx = fround(_x_, round_unbiased);
	dy = fround(_y_, round_unbiased);
	dl = fround(_z_, round_floor);
	dz = (dl ? dl*1000 : 20 ) + ( dy > -10 ? (dy/8) : -9);
}


stock EntityMove( maxmask, push_off = true)
{
	new Fixed:speed =  _speed_ * GameFrame2();
	new results = 0;
	
	if (speed > 1.0)
	{
		while ( speed > 1.0 )
		{
			results += EntityMoveCode(maxmask,1.0, push_off);
			speed -= 1.0;
		}
	}
	results += EntityMoveCode(maxmask,speed, push_off);
	StorePosition();
	return results;
}

stock EntityMoveCode( maxmask, Fixed:speed, push_off = true )
{
	if (!speed)
		return false;

	new Fixed:movex = ( _flipx_ ? -fsin(_angle_, degrees) : fsin(_angle_, degrees) ) * speed;
	new Fixed:movey = ( _flipy_ ? -fcos(_angle_, degrees) : fcos(_angle_, degrees) ) * speed;
	new na = 0; // new angle
	new r = false;

	if ( MoveCheck(na, _angle_, maxmask, movex, movey) )
	{
		_x_ += movex;
		_y_ += movey;
		r = true;
	}
	else if ( push_off )
	{
		if ( na )
		{
			_angle_ += fixed(na);
			movex = fsin(_angle_, degrees);
			movey = fcos(_angle_, degrees);
			_x_ += movex/4.0;
			_y_ += movey/4.0;
			r = true;
		}
		else
		{
			_x_ = fixed( fround(_x_, move_round[_animdir_][0]) );
			_y_ = fixed( fround(_y_, move_round[_animdir_][1]) );
		}
	}
	else
	{
		_x_ = fixed( fround(_x_, move_round[_animdir_][0]) );
		_y_ = fixed( fround(_y_, move_round[_animdir_][1]) );
	}
	EntitySetPosition(_x_, _y_, _);
	UpdateDisplayPosition();
	
	if ( _angle_ < 0.0 )
		_angle_ += 360.0;
	else if ( _angle_ >= 360.0 )
		_angle_ -= 360.0;
	return r;
}


stock MoveCheck(&a, Fixed:angle, maxmask, Fixed:movex, Fixed:movey)
{
	_dir_ = Angle2Dir(angle, 22.5);
	
	_animdir_ = NumberClamp((_dir_/2), 0, 3);

	new checks[8][3];

	UpdatePoints( checks, fround(movex, move_round[_animdir_][0]), fround(movey, move_round[_animdir_][1]) );
	DisplayUpdatePoints( checks);

	new l,r,q = _dir_;
	l = (_dir_ >= 7 ? 0 : _dir_ + 1);
	r = (_dir_ == 0 ? 7 : _dir_ - 1);

	new maskv = MaskGetValue( checks[q][0], checks[q][1]);
	_hit[0] = MaskGetValue( checks[l][0], checks[l][1]);
	_hit[1] = MaskGetValue( checks[r][0], checks[r][1]);

	if( maskv > 255 )
	{
		return !a;
	}
	else if ( !_allow_offscreen && maskv < 0 )
	{
		return false;
	}
	else if ( maskv > maxmask )
	{
		if ( MaskGetValue( checks[q][0], checks[q][1]) > maxmask )
		{
			a = 0;
			return false;
		}
		return false;
	}
	else
	{
		if ( _hit[0] > maxmask )
			a -= 30;
		else
			_hit[0] = 0;
		if ( _hit[1] > maxmask )
			a += 30;
		else
			_hit[1] = 0;
	}
	
	return !a;

}

stock DisplayUpdatePoints( _points_[8][3] )
{
	new l,r,q = _dir_;
	l = (_dir_ >= 7 ? 0 : _dir_ + 1);
	r = (_dir_ == 0 ? 7 : _dir_ - 1);

	for ( new c = 0; c < 8; c++ )
	{
		GraphicsDraw("", RECTANGLE, _points_[c][XAXIS], _points_[c][YAXIS], 5, 2,2, 0xFF00FFAA);
	}
	GraphicsDraw("", RECTANGLE, _points_[l][XAXIS], _points_[r][YAXIS], 5, 2,2, 0x0000FFAA);
	GraphicsDraw("", RECTANGLE, _points_[r][XAXIS], _points_[l][YAXIS], 5, 2,2, 0x0000FFAA);
	GraphicsDraw("", RECTANGLE, _points_[q][XAXIS], _points_[q][YAXIS], 5, 2,2, 0x0000FFAA);
}

stock UpdatePoints( _points_[8][3], bx, by )
{
	_points_[SOUTH][XAXIS] = dx + (dw/2) + ox + bx;
	_points_[SOUTH][YAXIS] = dy + (dh) + oy + by;

	_points_[SOUTHEAST][XAXIS] = dx + (dw) + ox + bx;
	_points_[SOUTHEAST][YAXIS] = dy + (dh) + oy + by;

	_points_[EAST][XAXIS] = dx + (dw) + ox + bx;
	_points_[EAST][YAXIS] = dy + (dh/2) + oy + by;

	_points_[NORTHEAST][XAXIS] = dx + (dw) + ox + bx;
	_points_[NORTHEAST][YAXIS] = dy + oy + by;

	_points_[NORTH][XAXIS] = dx + (dw/2) + ox + bx;
	_points_[NORTH][YAXIS] = dy + oy + by;

	_points_[NORTHWEST][XAXIS] = dx + ox + bx +1;
	_points_[NORTHWEST][YAXIS] = dy + oy + by +1;

	_points_[WEST][XAXIS] = dx + ox + bx;
	_points_[WEST][YAXIS] = dy + (dh/2) + oy + by;

	_points_[SOUTHWEST][XAXIS] = dx + ox + bx;
	_points_[SOUTHWEST][YAXIS] = dy + (dh) + oy + by ;

}
