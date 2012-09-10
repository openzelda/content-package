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
#include <weapon>

new object:obj = NULLOBJECT;
new timer = 0;
new sheet[] = "sword01.png";
new player_sheet[] = "p01swing.png";
new anim[4][11 char] = { !"swing-front", !"swing-side", !"swing-back", !"swing-side" };
new _px_, _py_;

public Init(...)
{
	oy += 32;
	ox += 12;
}

public Close()
{
	ObjectDelete(obj);
}

main() { } //So Engine doesn't complain

weapon_begin( xobj, dir )
{
	if ( timer || obj != NULLOBJECT )
		return;

	new image[64], ximage[64];
	
	timer = AnimationGetLength(sheet, anim[dir]);
	strformat( image, _, true, "%s:%s", sheet, anim[dir] );
	strformat( ximage, _, true, "%s:%s", player_sheet, anim[dir] );

	if (dir == 2)
		obj = object:ObjectCreate( image, SPRITE, dx, dy, 3, 0, 0);
	else if (dir == 0)
		obj = object:ObjectCreate( image, SPRITE, dx + ox, dy + oy, 3, 0, 0);
	else  if (dir == 3)
		obj = object:ObjectCreate( image, SPRITE, dx + 4, dy, 3, 0, 0);
	else
		obj = object:ObjectCreate( image, SPRITE, dx, dy, 3, 0, 0);

	ObjectFlag(obj, FLAG_SPEED, 1);
	ObjectFlag(obj, FLAG_ANIMLOOP, 0);
	ObjectEffect( obj, WHITE, _, _, _, (dir == 3 ? 16 : 0), _, _ );
	ObjectReplace( object:xobj, ximage, SPRITE ); // Replace player sprite with swinging sprite
}

weapon_ended( xobj )
{
	if ( CountTimer(timer, 0) )
	{
		ObjectDelete(obj);
		CollisionSet(SELF, -1, 0);
		obj = NULLOBJECT;
		return 0;
	}
	return 1;
}

public End( xobj, dir )
{
	timer = 0;
	weapon_ended( xobj );
}

public Use( xobj, dir )
{
	new swordangle = D2A(dir);
	dir = NumberClamp((dir/2), 0, 3);

	EntityGetPosition(_x_, _y_, _z_);
	UpdateDisplayPosition();
	//ObjectInfo(obj, _px_, _py_);

	

	weapon_begin( xobj, dir );
	CollisionFromObject(obj, TYPE_WEAPON);

	new hx, hy, hw, hh;
	CollisionGet(SELF, 0,hx,hy,hw,hh);
	if ( CollisionCalculate() )
	{
		new current[64];
		new angle;
		new dist;
		new rect;
		new type;

		while ( CollisionGetCurrent(SELF, current, angle, dist, rect, type) )
		{
			if ( type == _:TYPE_ENEMY || type == _:TYPE_AWAKING )
			{
				//// forward public Hit( attacker[], angle, dist, attack, damage, x, y, rect );
				EntityPublicFunction(current, "Hit", "snnnnnnn", ownerid, swordangle, dist, ASWORD, 50, hx-(hw/2), hy-(hh/2), rect);
			}
		}
	}
	
	return weapon_ended( xobj );
}