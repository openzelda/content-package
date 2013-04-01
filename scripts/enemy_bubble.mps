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
#include <public_events>

new Fixed:TakeMagicCount = 0.00;
new TakeMagic = true;
new last = -1;

public Init( ... )
{
	mqMovementSpeed = 100;   
	mqDamageDealt = 50;
	mqHealth = 50;
	mqState = MOVING;
	mqDisplayArea.h = mqDisplayArea.w = 38;
	mqDisplayOffset.x = mqDisplayOffset.y = 1;
	EnemyInit();

	mqDirection = 1;
	mqMovementAngle= Dir2Angle(mqDirection);
	mqDisplayObject = EntityGetObject();
}

public Close()
{
	CollisionSet(SELF, -1, 0);
}



main()
{
	if ( mqState == DEAD || GameState() != 1 )
		return;

	if ( !EntityMove( MASK_ENEMYSOLID2, false ) )
	{
		mqDirection += ( !mqHitMaskCheck[0] ? 2 : -2);
		last = ( !mqHitMaskCheck[0] ? 2 : -2);
		mqMovementAngle = Dir2Angle(mqDirection);
	}
	CollisionSet(SELF, 1, TYPE_ENEMY, mqDisplayArea.x+3, mqDisplayArea.y+3, 34, 34 );
	ObjectPosition( mqDisplayObject, mqDisplayArea.x, mqDisplayArea.y, 3, 0, 0 );
}

PUBLIC_EVENT_HIT
{
	if ( mqState == HIT || mqState == DYING || mqState == GONE )
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
