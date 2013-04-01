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

/* Public Function */
forward PUBLIC_EVENT_HIT;

/* Local variable */
new HitCount;
new LeapCount = 1000;
new StandCount = 600;
new HeadDirection = 0;

/* Display Object */
new body[EntityGraphic] = { OBJECT_NONE, 0, 24, 0 };	// Display Object, Offset x, Offset y, Offset z
new head[EntityGraphic] = { OBJECT_NONE, 0, 0, 1 };	// Display Object, Offset x, Offset y, Offset z
new object:shadow = OBJECT_NONE;

/* Collisions Settings */
new hitzone[3][RECT] = { 
	{ 4, 28, 24, 24 }, // Body 
	{ -16, 16, 64, 56 }, // Attack Alert
	{ 4, 28, 24, 16 }, // jumping body
};


/* Function */
public Init(...)
{
	mqMovementSpeed = 50;
	mqDamageDealt = 50;
	mqHealth = mqMaxHealth = 100;

	mqDisplayArea.w = mqDisplayArea.h =  24;
	mqDisplayOffset.x = 2;
	mqDisplayOffset.y = 28;

	SetStateGraphic( STANDING, "enemy_bones01.png", "front_0", "side_0", "back_0", "side_0" );
	SetStateGraphic( MOVING, "enemy_bones01.png", "front", "side", "back", "side" );
	SetStateGraphic( LEAPING, "enemy_bones01.png", "stomp", "stomp", "stomp", "stomp" );
	SetStateGraphic( DYING, "enemy_bones01.png", "front_0", "side_0", "back_0", "side_0" );

	EnemyInit();

	/* Retrive Display Objects */
	body[egOBJ] = object:EntityGetNumber("object-id");
	head[egOBJ] = ObjectCreate( "enemy_bones01.png:head_front", SPRITE, mqDisplayArea.x, mqDisplayArea.y, mqDisplayZIndex+1, 0, 0, WHITE );
	shadow = ObjectCreate( "", CIRCLE, mqDisplayArea.x, mqDisplayArea.y+32, mqDisplayZIndex-1, 16, 8,  0x000000AA);
	ShowObjects( head[egOBJ], body[egOBJ], shadow );
}

public Close()
{
	CollisionSet(SELF, -1, 0);
	ObjectDelete(shadow);
	ObjectDelete(head[egOBJ]);
}

main()
{
	if ( mqState == GONE || GameState() != 1 )
	{
		return;
	}

	//StringFormat(error_message,_,_,"x: %d y: %d z: %d l: %d", mqDisplayArea.x, mqDisplayArea.y,mqDisplayZIndex, mqDisplayLayer)
	//GraphicsDraw(error_message, TEXT, mqDisplayArea.x, mqDisplayArea.y, 5, 0 ,0, 0xFF0000FF );

	if ( HasStateChanged() )
	{
		ResetObjects( head[egOBJ], body[egOBJ] );
	}

	if ( InputButton(1) )
	{
		//Hit( "temp", 90, 5, ASWORD, 0, mqDisplayArea.x, mqDisplayArea.y, 1 );
		Kill();
	}


	new q = (mqState == LEAPING ? 2 : 0); // Use which hit zone to use
	CollisionSet(SELF, 0, TYPE_ENEMY, mqDisplayArea.x + hitzone[q][rX], mqDisplayArea.y + hitzone[q][rY], hitzone[q][rW], hitzone[q][rH] );
	CollisionSet(SELF, 1, TYPE_AWAKING, mqDisplayArea.x + hitzone[1][rX], mqDisplayArea.y + hitzone[1][rY], hitzone[1][rW], hitzone[1][rH] );

	switch( mqState )
	{
		case STANDING:
			Stand();
		case MOVING:
			Move();
		case LEAPING:
			Leap();
		case HIT:
			Hurt();
		case DYING:
		{
			ReplaceEntityGraphics( body, STATE_GRAPHIC, STATE_FLIP );
			ColourEntityGraphics( body, 0xDD0000FF);
			ColourEntityGraphics( head, 0xDD0000FF);
			HandleDying();
		}
		case SPECIALSTATE:
			Special();
		case DEAD:
		{
			ObjectToggle( body[egOBJ], false  );
			ObjectDelete(head[egOBJ]);
			ObjectDelete(shadow);
			CollisionSet(SELF, -1, 0);
			SetState(GONE);
			return;
		}
	}
	UpdateEntityGraphics( head );
	UpdateEntityGraphics( body );
	if ( mqState == LEAPING )
	{
		ObjectPosition( body[egOBJ], mqDisplayArea.x+body[egOFFX], mqDisplayArea.y+body[egOFFY]-4, mqDisplayZIndex+body[egOFFZ], 0, 0);
	}
	ObjectPosition( shadow, mqDisplayArea.x+4, mqDisplayArea.y+48, mqDisplayZIndex-1, 24, 8);
}

/* Local Function */
SetHeadDir(head_direction)
{
	head_direction %= 8;
	switch ( head_direction/2 ) 
	{
		case 1:
			ReplaceEntityGraphics( head, "enemy_bones01.png:head_side", false );
		case 2:
			ReplaceEntityGraphics( head, "enemy_bones01.png:head_front", false );
		case 3:
			ReplaceEntityGraphics( head, "enemy_bones01.png:head_side", true );
		default:
			ReplaceEntityGraphics( head, "enemy_bones01.png:head_front", false );
	}
}

ChangeHeadDir()
{
		HeadDirection = mqDirection;
		if ( random(2) )
			HeadDirection+=2;
		else
			HeadDirection=2;
		StandCount = 1000;
		SetState(STANDING);
}


/* States */
STATEFUNCTION Move()
{
	ReplaceEntityGraphics( body, STATE_GRAPHIC, STATE_FLIP );
	SetHeadDir(mqDirection);
	
	if ( !random(500) ) // Change Direction
	{
		ChangeHeadDir();
	}
	else
	{
		if ( EntityMove( MASK_ENEMYSOLID2, true ) > 1 )
		{
			ChangeHeadDir();
		}
	}
}


STATEFUNCTION Leap()
{
	ReplaceEntityGraphics( body, STATE_GRAPHIC, STATE_FLIP );
	ReplaceEntityGraphics( head, "enemy_bones01.png:head_front", false );
	EntityMove( MASK_ENEMYSOLID2, true );

	if ( Countdown(LeapCount) ) // Check the hit counter
	{
		SetState(STANDING);
		RandomizeMovement();
		CheckHealth();
	}
	
}

STATEFUNCTION Stand()
{
	ReplaceEntityGraphics( body, STATE_GRAPHIC, STATE_FLIP );
	SetHeadDir(HeadDirection);

	if ( Countdown(StandCount) ) // Start Moving Again
	{
		mqMovementAngle = Dir2Angle(HeadDirection);
		SetDir(HeadDirection);
		SetState(MOVING);
	}
}



STATEFUNCTION Hurt()
{
	CollisionSet(SELF, -1, 0);
	EntityMove(MASK_ENEMYSOLID2);

	new q = (HitCount % 100) / 20;
	ColourEntityGraphics(body, mqHitColours[q]);
	ColourEntityGraphics(head, mqHitColours[q]);

	EntityMove( MASK_ENEMYSOLID2 );

	if ( Countdown(HitCount) ) // Check the hit counter
	{
		SetState(MOVING);
		RandomizeMovement();
		CheckHealth();
	}
}

STATEFUNCTION Special()
{

	switch ( mqCurrentEffect )
	{
		case STUNNED:
		{
			StunnedEffect( mqEffectTimer );
			ReplaceEntityGraphics( body, "enemy_bones01.png:front_0", false );
		}
		case FROZEN:
		{
			ReplaceEntityGraphics( body, "enemy_bones01.png:front_0", false );
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

	if ( Countdown(mqEffectTimer) ) //Reset State
	{
		SetState(STANDING);
	}

}



/* Public Functions */
PUBLIC_EVENT_HIT
{
	if ( mqState == HIT || mqState == DYING || mqState == GONE )
		return;

	strcopy( mqAttacker, attacker );

	if ( attack&APLAYER == APLAYER )
	{
		EntityPublicFunction( mqAttacker, "Hurt", "nnn", ASWORD, mqDamageDealt, angle );
	}
	else if ( mqState != HIT)
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
			Hurt();
		}
	}
	CheckHealth();
}