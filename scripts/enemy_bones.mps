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
 *     2010/02/04 [luke]: new file.
 *     2012/01/15 [luke]: 
 * Todo:
 *     Fix stomp graphics, sprite alignment.
 *     Make sure entity save correctly
 ***********************************************/
#define DEATHLENGTH 480
#include <enemy>
#include <entity_graphics>

/* Public Function */
forward PUBLIC_EVENT_HIT;

/* Local variable */
new HitCount;
new LeapCount = 1000;
new StandCount = 600;
new HeadDirection = 0;

/* Graphics */
new graphicHead[4]{32} ;

/* Display Object */
new body[EntityGraphic] = [ OBJECT_NONE, 0, 24, 0, 0, 0 ];	// Display Object, Offset x, Offset y, Offset z, width, height
new head[EntityGraphic] = [ OBJECT_NONE, 0, 0, 1, 0, 0 ];		// Display Object, Offset x, Offset y, Offset z, width, height
new shadow[EntityGraphic] = [ OBJECT_NONE, 4, 48, - 1, 24, 16 ];	// Display Object, Offset x, Offset y, Offset z, width, height

/* Collisions Settings */
new hitzone[3][RECT] = [ 
	[ 4, 28, 24, 24 ], // Body 
	[ -16, 16, 64, 56 ], // Attack Alert
	[ 4, 28, 24, 16 ] // jumping body
];

//new textColor = 0x000000FF;

/* Function */
public Init(...)
{
	mqMovementSpeed = 50;
	mqDamageDealt = 50;
	mqHealth = mqMaxHealth = 100;

	HeadDirection = SOUTH;

	/* These are used more for collision through EntityMove then for Display.*/
	mqDisplayArea.w = mqDisplayArea.h =  24;
	mqDisplayOffset.x = 4;
	mqDisplayOffset.y = 28;

	EnemyInit();

	SetStateGraphic( STANDING, mqSheet, "front_0", "side_0", "back_0", "side_0" );
	SetStateGraphic( MOVING, mqSheet, "front", "side", "back", "side" );
	SetStateGraphic( LEAPING, mqSheet, "stomp", "stomp", "stomp", "stomp" );
	SetStateGraphic( DYING, mqSheet, "front_0", "side_0", "back_0", "side_0" );

	StringFormat( graphicHead[0], _, true, "%s:head_front", mqSheet);
	StringFormat( graphicHead[1], _, true, "%s:head_side", mqSheet);
	StringFormat( graphicHead[2], _, true, "%s:head_back", mqSheet);
	StringFormat( graphicHead[3], _, true, "%s:head_side", mqSheet);

	//textColor = (NumberRandom(0xffffff) << 8) + 0xff;

	/* Retrieve Display Objects */
	ObjectToggle( object:EntityGetObject(), false  ); // We don't the map placeholder object, we will use our own.

	CreateEntityGraphics( body, STATE_GRAPHIC );
	CreateEntityGraphics( head, graphicHead[0] );
	CreateEntityShadow( shadow );

}

public Close()
{
	CollisionSet(SELF, -1, 0);
	DeleteEntityGraphics(shadow);
	DeleteEntityGraphics( body );
	DeleteEntityGraphics( head );
}

main()
{
	if ( mqState == GONE || GameState() != 1 )
	{
		return;
	}
/*
	StringFormat(error_message, _, true, "Head: %d\nID: %d", body.obj, head.obj );
	GraphicsDraw(error_message, TEXT, mqDisplayArea.x-20, mqDisplayArea.y-20, 5000, 0, 0, 0x000000FF );
	GraphicsDraw(error_message, TEXT, mqDisplayArea.x-21, mqDisplayArea.y-21, 5001, 0, 0, textColor );
*/
	StringFormat(error_message, _, true, "Health: %d\nmqDeathTimer: %d\nHitCount: %d", mqHealth, mqDeathTimer, HitCount);
	GraphicsDraw(error_message, TEXT, mqDisplayArea.x-20, mqDisplayArea.y-20, 5000, 0, 0, 0x000000FF );
	GraphicsDraw(error_message, TEXT, mqDisplayArea.x-21, mqDisplayArea.y-21, 5001, 0, 0, 0xffffffff );

	if ( HasStateChanged() )
	{
		ResetObjects( head.obj, body.obj );
	}

	/* Collisions Settings */
	new q = (mqState == LEAPING ? 2 : 0); // Use which hit zone to use
	CollisionSet(SELF, 0, TYPE_ENEMY, mqDisplayArea.x + hitzone[q].x, mqDisplayArea.y + hitzone[q].y, hitzone[q].w, hitzone[q].h );
	CollisionSet(SELF, 1, TYPE_AWAKING, mqDisplayArea.x + hitzone[1].x, mqDisplayArea.y + hitzone[1].y, hitzone[1].w, hitzone[1].h );

	switch( mqState )
	{
		case STANDING:
			State_Stand();
		case MOVING:
			State_Move();
		case LEAPING:
			State_Leap();
		case HIT:
			State_Hurt();
		case DYING:
			State_Dying();
		case SPECIALSTATE:
			State_Special();
		case DEAD:
		{
			DeleteEntityGraphics(shadow);
			DeleteEntityGraphics( body );
			DeleteEntityGraphics( head );
			CollisionSet(SELF, -1, 0);
			SetState(GONE); 
			return;
		}
	}

	SetHeadDir();
	UpdateEntityGraphics( head );
	UpdateEntityGraphics( body );
	UpdateEntityGraphics( shadow );

	// Leaping Graphics have a special position code
	if ( mqState == LEAPING )
	{
		ObjectPosition( body.obj, mqDisplayArea.x+body.x, mqDisplayArea.y+body.y-6, mqDisplayZIndex+body.z, 0, 0);
	}
	
}

/* Local Function */

SetHeadDir()
{
	new n = (HeadDirection/2)%4;

	ReplaceEntityGraphics( head, graphicHead[n], (n == 3 ? true : false) );

}

ChangeHeadDir()
{
	new new_dir;
	new_dir = HeadDirection;
	do {
		new_dir = random(4)*2;
	} while ( HeadDirection == new_dir );

	HeadDirection = new_dir;
	
}


/* States */
State_Dying()
{
	ReplaceEntityGraphics( body, STATE_GRAPHIC, STATE_FLIP );
	ColourEntityGraphics( body, 0xDD0000FF);
	ColourEntityGraphics( head, 0xDD0000FF);
	HandleDying();
}

State_Move()
{
	ReplaceEntityGraphics( body, STATE_GRAPHIC, STATE_FLIP );
	
	
	if ( !random(50) ) // Change Direction
	{
		ChangeHeadDir();
		StandCount = 1000;
		SetState(STANDING);
	}
	else
	{
		mqMovementAngle = Dir2Angle(mqDirection);
		if ( !EntityMove( MASK_ENEMYSOLID2, false )  )
		{
			StandCount = 1000;
			SetState(STANDING);
			
		}
	}
}


State_Leap()
{
	ReplaceEntityGraphics( body, STATE_GRAPHIC, STATE_FLIP );
	ReplaceEntityGraphics( head, graphicHead[0], false ); //Always look south

	EntityMove( MASK_ENEMYSOLID2, true );

	if ( TimerCountdown(LeapCount) ) // Check the hit counter
	{
		SetState(STANDING);
		RandomizeMovement();
		CheckHealth();
	}
	
}

State_Stand()
{
	ReplaceEntityGraphics( body, STATE_GRAPHIC, STATE_FLIP );

	if ( !random(500) ) // Change Head Direction
	{
		ChangeHeadDir();
	}

	if ( TimerCountdown(StandCount) ) // Start Moving Again
	{
		SetDir(HeadDirection);
		SetState(MOVING);
	}
}



State_Hurt()
{
	CollisionSet(SELF, -1, 0);
	EntityMove(MASK_ENEMYSOLID2);

	new q = (HitCount % 100) / 20;
	ColourEntityGraphics(body, mqHitColours[q]);
	ColourEntityGraphics(head, mqHitColours[q]);

	EntityMove( MASK_ENEMYSOLID2 );

	if ( TimerCountdown(HitCount) ) // Check the hit counter
	{
		SetState(MOVING);
		RandomizeMovement();
		CheckHealth();
	}
}

State_Special()
{

	switch ( mqCurrentEffect )
	{
		case STUNNED:
		{
			StunnedEffect( mqEffectTimer );
			ReplaceEntityGraphics( body, STATE_GRAPHIC, false );
		}
		case FROZEN:
		{
			ReplaceEntityGraphics( body, STATE_GRAPHIC, false );
			ColourEntityGraphics( body, 0x0000FFFF);
		}
		case SHOCKED:
		{
		}
		case BURNING:
		{
		}
		default:
		{
			SetState(STANDING);
			return;
		}
	}

	if ( TimerCountdown(mqEffectTimer) ) //Reset State
	{
		SetState(STANDING);
	}

}



/* Public Functions */
//public Hit( entityId:attacker, angle, dist, attack, damage, x, y, rect )
PUBLIC_EVENT_HIT
{
	if ( mqState == HIT || mqState == DYING || mqState == GONE )
		return;

	mqAttacker = attacker;

	if ( mqAttacker&APLAYER == APLAYER )
	{
		CallEntityHurt( mqAttacker, ASWORD, mqDamageDealt, angle );
	}
	else if ( mqState != HIT )
	{
		mqMovementAngle = fixed(angle);
		if ( rect == 1 )
		{
			SetState(LEAPING);
			LeapCount = 800;
		}
		else
		{
			AudioPlaySound( "enemy_hurt.wav", mqDisplayArea.x, mqDisplayArea.y );
			mqState = HIT;
			mqHealth -= damage;
			HitCount = 800;
			State_Hurt();
		}
	}
	CheckHealth();
}