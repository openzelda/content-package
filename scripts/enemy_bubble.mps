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
 *     2010/02/09 [luke]: new file.
 ***********************************************/

#define DEATHLENGTH 2500
#include <enemy>

new obj = -1;
new Fixed:TakeMagicCount = 0.00;
new TakeMagic = true;

public Init( ... )
{
	_speed_ = 100;   
	_damage_ = 50;
	_health_ = 50;
	_state_ = MOVING;
	dh = dw = 38;
	ox = oy = 1;
	EnemyInit();

	_dir_ = 1;
	_angle_= Dir2Angle(_dir_);
	obj = EntityGetNumber("object-id");
}

public Close()
{
	CollisionSet(SELF, -1, 0);
}


new last = -1;
main()
{
	if ( _state_ == DEAD || GameState() != 1 )
		return;

	if ( !EntityMove( MASK_ENEMYSOLID2, false ) )
	{
		_dir_ += ( !_hit[0] ? 2 : -2);
		last = ( !_hit[0] ? 2 : -2);
		_angle_ = Dir2Angle(_dir_);
	}
	CollisionSet(SELF, 1, TYPE_ENEMY, dx+3, dy+3, 34, 34 );
	ObjectPosition( obj, dx, dy, 3, 0, 0 );
}

public Hit( attacker[], angle, dist, attack, damage, x, y, rect )
{
	if ( _state_ == HIT || _state_ == DYING || _state_ == GONE )
		return;

	if ( attack&APLAYER == APLAYER )
	{
		EntityPublicFunction( attacker, "Hurt", "nnn", AMAGIC, 50, angle );

		if ( TakeMagic )
		{
		/*
			if (GetCounterValue("magic") > 0)
			{
				IncCounterTarget("magic", -5);
				PlaySound("_magicincrease.wav", 240);	
				TakeMagic = false;
				TakeMagicCount = 0.00;
			}
		*/
		}
		else
		{
			TakeMagicCount += 10.0 * GameFrame2();
			if (TakeMagicCount > 30.0)
				TakeMagic = true;
		}
	}

}
