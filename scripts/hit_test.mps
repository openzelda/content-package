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

#include <public_events>

/* Public Function */
forward PUBLIC_EVENT_HIT;

new ang = 0;



public Init( ... )
{
	GetEntityPosition( mqEntityPosition.x, mqEntityPosition.y, mqDisplayZIndex, mqDisplayArea.x, mqDisplayArea.y, mqDisplayZIndex, mqDisplayLayer);

}

main()
{
	CollisionSet(SELF, 1, TYPE_ENEMY, mqDisplayArea.x, mqDisplayArea.y, 32, 32 );
	DebugText("Last Angle: %d", ang);

	GraphicsDraw("", RECTANGLE, mqDisplayArea.x+fround(fsin(ang, degrees)*64), mqDisplayArea.y+fround(fcos(ang, degrees)*64), 4, 32,32, BLACK);


}

PUBLIC_EVENT_HIT
{
	//Hit( attacker[], angle, dist, attack, damage, x, y, rect )
	ang = angle;



}
