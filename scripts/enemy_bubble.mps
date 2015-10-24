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

/* */
new Fixed:TakeMagicCount = 0.00;
new TakeMagic = true;
new  Directions:last =  Directions:-1;

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

	//Defaults
	qDirection = SOUTHEAST;
	qMovementAngle = Dir2Angle(SOUTHEAST);
	qObject = EntityGetObject();
	ObjectReplace(qObject, "enemy11.png:1", SPRITE);

}

public Close()
{
	CollisionSet(SELF, -1, 0);
}



main()
{
	if ( qState == DEAD ||  GameState() != GS_ALL )
		return;

	if ( !EntityMove( MASK_ENEMYSOLID2, false ))
	{
		new Directions:next = qDirection+( !qHitMaskCheck[1]  ?  EAST: -EAST);

		qDirection = (next)%DIRECTIONS_COUNT;
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
		new string{128};
		StringFormat(string, _, "Angle %d, ", angle);
		GraphicsDraw(string, TEXT, x,y,6.0,0,0)

		new Fixed:w = -fsin(fixed(angle))*100;
		new Fixed:q =fcos (fixed(angle))*100;

		GraphicsDraw(string, LINE, 320,240,6.0, 320+fround(w), 240+fround(q))


		CallEntityHurt( attacker, AMAGIC, 50, angle);
		//SystemCommand(4,1);
		if ( TakeMagic )
		{
			CallEntityChangeCounter(attacker, ITEM_MAGIC, -5);
			AudioPlaySound("magic_increase", qDisplayArea.x, qDisplayArea.y);	
			TakeMagic = true;
			TakeMagicCount = 0.00;
		}
		else
		{
			TakeMagicCount += 10.0 * GameFrameSeconds();
			if (TakeMagicCount > 30.0)
				TakeMagic = true;
		}
	}

}
