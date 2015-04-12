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
#include <mokoi_quest>

new qCollisionBuffer = 2;
stock DisplayCollisionPoints( points[8][POSITION] )
{
	new Direction:l,Direction:r,Direction:q = qDirection;
	l = (qDirection >= SOUTHWEST ? SOUTH : qDirection + 1);
	r = (qDirection == SOUTH ? SOUTHWEST : qDirection - 1);

	for ( new c = 0; c < 8; c++ )
	{
		GraphicsDraw("", RECTANGLE, points[Direction:c].x, points[Direction:c].y, 5.1, 4, 4, 0xFF00FFAA);
	}

	GraphicsDraw("", RECTANGLE, points[Direction:r].x, points[Direction:r].y, 5.0, 5, 5, 0x0000FFAA);
	GraphicsDraw("", RECTANGLE, points[Direction:l].x, points[Direction:l].y, 5.0, 5, 5, 0x00FFFFAA);
	GraphicsDraw("", RECTANGLE, points[Direction:q].x, points[Direction:q].y, 5.0, 5, 5, 0x00FF00AA);
}

stock UpdateCollisionPoints( points[8][POSITION], bx, by )
{
	points[SOUTH].x = qDisplayArea.x + (qDisplayArea.w/2) + qDisplayOffset.x + bx;
	points[SOUTH].y = qDisplayArea.y + (qDisplayArea.h) + qDisplayOffset.y + by;

	points[SOUTHEAST].x = qDisplayArea.x + (qDisplayArea.w) + qDisplayOffset.x + bx - qCollisionBuffer;
	points[SOUTHEAST].y = qDisplayArea.y + (qDisplayArea.h) + qDisplayOffset.y + by - qCollisionBuffer;

	points[EAST].x = qDisplayArea.x + (qDisplayArea.w) + qDisplayOffset.x + bx;
	points[EAST].y = qDisplayArea.y + (qDisplayArea.h/2) + qDisplayOffset.y + by;

	points[NORTHEAST].x = qDisplayArea.x + (qDisplayArea.w) + qDisplayOffset.x + bx - qCollisionBuffer;
	points[NORTHEAST].y = qDisplayArea.y + qDisplayOffset.y + by + qCollisionBuffer;

	points[NORTH].x = qDisplayArea.x + (qDisplayArea.w/2) + qDisplayOffset.x + bx;
	points[NORTH].y = qDisplayArea.y + qDisplayOffset.y + by;

	points[NORTHWEST].x = qDisplayArea.x + qDisplayOffset.x + bx + qCollisionBuffer;
	points[NORTHWEST].y = qDisplayArea.y + qDisplayOffset.y + by + qCollisionBuffer;

	points[WEST].x = qDisplayArea.x + qDisplayOffset.x + bx;
	points[WEST].y = qDisplayArea.y + (qDisplayArea.h/2) + qDisplayOffset.y + by;

	points[SOUTHWEST].x = qDisplayArea.x + qDisplayOffset.x + bx + qCollisionBuffer;
	points[SOUTHWEST].y = qDisplayArea.y + (qDisplayArea.h) + qDisplayOffset.y + by - qCollisionBuffer;

}
