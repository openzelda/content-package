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
 *     2012/01/30 [luke]: cleanned up
 ***********************************************/
#define DEATHLENGTH 480
#include <enemy>
#include <entity_graphics>

/* Public Function */
forward PUBLIC_EVENT_AWAKING;
forward PUBLIC_EVENT_HIT;

/* Local variable */
new HitCount;
new timer;
new adj = 3;
new listen_rad = 50;

/* Display Object */
new body[EntityGraphic] = [ OBJECT_NONE, 0, 0, 0, 0, 0 ];	// Display Object, Offset x, Offset y, Offset z, width, height
new shadow[EntityGraphic] = [ OBJECT_NONE, 8, 32, -1, 16, 8 ];	// Display Object, Offset x, Offset y, Offset z, width, height

/* Collisions Settings */

/* Function */

public Init(...)
{
	mqMovementSpeed = 50;
	mqDamageDealt = 50;
	mqHealth = mqMaxHealth = 50;

	/* These are used more for collision through EntityMove then for Display.*/
	mqDisplayArea.w = mqDisplayArea.h = 32;

	EnemyInit();

	/* Set up Objects */
	SetStateGraphic( STANDING, mqSheet, "bat_1", "bat_1", "bat_1", "bat_1" );
	SetStateGraphic( MOVING, mqSheet, "bat", "bat", "bat", "bat" );

	/* Retrieve Display Objects */
	body.obj = object:EntityGetNumber("object-id");
	CreateEntityShadow( shadow );

}

public Close()
{
	CollisionSet(SELF, -1, 0);
	DeleteEntityGraphics(shadow);
	ObjectToggle( body.obj, false );
}

main()
{
	StringFormat(error_message, _, true, "Health: %d\nmqDeathTimer: %d\nHitCount: %d", mqHealth, mqDeathTimer, HitCount);
	GraphicsDraw(error_message, TEXT, mqDisplayArea.x-20, mqDisplayArea.y-20, 5000, 0, 0, 0x000000FF );
	GraphicsDraw(error_message, TEXT, mqDisplayArea.x-21, mqDisplayArea.y-21, 5001, 0, 0, 0xffffffff );


	if ( mqState == GONE || GameState() != 1 )
		return;

	if ( HasStateChanged() )
	{
		ResetObjects( body.obj );
	}

	if ( mqState <= MOVING )
		CollisionSet(SELF, 0, TYPE_ENEMY, mqDisplayArea.x + adj, mqDisplayArea.y + adj, mqDisplayArea.w - (adj*2), mqDisplayArea.h - (adj*2) );

	switch( mqState )
	{
		case STANDING:
			State_Stand();
		case MOVING:
			State_Move();
		case HIT:
			State_Hurt();
		case DYING:
			State_Dying();
		case SPECIALSTATE:
			State_Special();
		case DEAD:
		{
			ObjectToggle( body.obj, false );
			DeleteEntityGraphics( shadow );
			CollisionSet(SELF, -1, 0);
			SetState(GONE);
			return;
		}
	}

	UpdateEntityGraphics( body );
	UpdateEntityGraphics( shadow );
}





/* States */ 
State_Move()
{
	ReplaceEntityGraphics( body, STATE_GRAPHIC, STATE_FLIP );

	// randomly change direction
	if ( !random(30) )
		mqMovementAngle = fixed(random(8) * 45);

	// Move the enemy
	EntityMove( MASK_ENEMYSOLID1 );

	timer += GameFrame();
	if ( timer >= 2000 )
		mqState = STANDING;
}

State_Stand()
{
	ReplaceEntityGraphics( body, STATE_GRAPHIC, STATE_FLIP );
	CollisionSet(SELF, 1, TYPE_AWAKING, mqDisplayArea.x - listen_rad, mqDisplayArea.y - listen_rad, mqDisplayArea.w + (listen_rad*2), mqDisplayArea.h + (listen_rad*2) );
}

State_Dying()
{
	ColourEntityGraphics( body, 0xDD0000FF);
	HandleDying();
}


State_Hurt()
{
	CollisionSet(SELF, -1, 0);
	EntityMove(MASK_ENEMYSOLID1);


	new q = (HitCount % 100) / 20;
	ColourEntityGraphics(body, mqHitColours[q]);

	EntityMove(MASK_ENEMYSOLID1);

	if ( TimerCountdown(HitCount) ) // Check the hit counter
	{
		SetState(STANDING);
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
			ReplaceEntityGraphics( body, STATE_GRAPHIC, STATE_FLIP );
		}
		case FROZEN:
		{
			ReplaceEntityGraphics( body, STATE_GRAPHIC, STATE_FLIP );
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
PUBLIC_EVENT_AWAKING
{
	if ( mqState == STANDING )
	{
		timer = 0;
	
		SetState(MOVING);
		AudioPlaySound("enemy_bat2.wav", mqDisplayArea.x, mqDisplayArea.y);

		CollisionSet(SELF, 1, 0);
	}
}

PUBLIC_EVENT_HIT
{
	if ( mqState == HIT || mqState == DYING || mqState == GONE )
		return;

	mqAttacker = attacker;
	mqMovementAngle = fixed(angle);

	if ( attack&AFIRE == AFIRE )
	{
		mqState = SPECIALSTATE;
	}
	else if ( attack&AICE == AICE )
	{
		mqState = SPECIALSTATE;
	}
	else if ( attack&ASTUN == ASTUN )
	{
		mqState = SPECIALSTATE;
	}
	else if ( attack&APLAYER == APLAYER )
	{
		CallEntityHurt( mqAttacker, ASWORD, mqDamageDealt, angle );
	}
	else if ( mqState != HIT )
	{
		AudioPlaySound( "enemy_hurt.wav", mqDisplayArea.x, mqDisplayArea.y );
		mqState = HIT;
		mqHealth -= damage;
		HitCount = 800;
		State_Hurt();
	}
	CheckHealth();
}



