/***********************************************
 * Copyright © Luke Salisbury
 *
 * You are free to share, to copy, distribute and transmit this work
 * You are free to adapt this work
 * Under the following conditions:
 *  You must attribute the work in the manner specified by the author or licensor (but
 *    not in any way that suggests that they endorse you or your use of the work). 
 *  You may not use this work for commercial purposes.
 * Full terms of use: http://creativecommons.org/licenses/by-nc/3.0/
 * Changes:
 *     2010/02/09 [luke]: new file.
 ***********************************************/
#define DEATHLENGTH 480
#include <enemy>
#include <entity_graphics>


/* Public Function */

forward PUBLIC_EVENT_HIT;

new Fixed:TakeMagicCount = 0.00;
new TakeMagic = true;
new last = -1;
new prev[.x, .y] = { 0, 0 };


public Init( ... )
{
	qMovementSpeed = 100;   
	qDamageDealt = 50;
	qHealth = 50;

	qState = MOVING;


	/* These are used more for collision through EntityMove then for Display.*/
	qDisplayArea.h = qDisplayArea.w = 38;
	qDisplayOffset.x = qDisplayOffset.y = 0;


	EnemyInit();

	qDirection = SOUTHWEST;
	qMovementAngle= Dir2Angle(qDirection);
	qObject = EntityGetObject();
}

public Close()
{
	CollisionSet(SELF, -1, 0);
}



main()
{
	if ( qState == DEAD || GameState() != 1 )
		return;

	if ( !EntityMove( MASK_ENEMYSOLID2, false ))
	{
		new next = ( !qHitMaskCheck[1]  ? 2 : -2);

		qDirection += next;
		last = next;
		qMovementAngle = Dir2Angle(qDirection);
	}

	CollisionSet(SELF, 1, TYPE_ENEMY, qDisplayArea.x + 3, qDisplayArea.y+3, 34, 34 );
	ObjectPosition( qObject, qDisplayArea.x, qDisplayArea.y, qPosition.z, 0, 0 );
}



/* Public Functions */

PUBLIC_EVENT_HIT
{
	if ( qState == HIT || qState == DYING || qState == GONE )
		return;

	if ( attack&APLAYER == APLAYER )
	{
		EntityPublicFunction( attacker, "Hurt", ''nnn'', AMAGIC, 50, angle );

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
			TakeMagicCount += 10.0 * GameFrameSeconds();
			if (TakeMagicCount > 30.0)
				TakeMagic = true;
		}
	}

}
