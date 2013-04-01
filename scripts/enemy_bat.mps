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
forward PUBLIC_EVENT_AWAKING
forward PUBLIC_EVENT_HIT

/* Local variable */
new HitCount;
new timer;
new adj = 3;
new listen_rad = 50;

/* Display Object */
new body[EntityGraphic] = [ OBJECT_NONE, 0, 0, 0 ];	// Display Object, Offset x, Offset y, Offset z
new object:shadow = OBJECT_NONE;

/* Collisions Settings */

/* Function */

public Init(...)
{
	mqMovementSpeed = 50;
	mqDamageDealt = 50;
	mqHealth = mqMaxHealth = 50;

	mqDisplayArea.w = mqDisplayArea.h = 32;

	EnemyInit();

	/* Set up Objects */
	SetStateGraphic( STANDING, "bat01.png", "bat_1", "bat_1", "bat_1", "bat_1" );
	SetStateGraphic( MOVING, "bat01.png", "bat", "bat", "bat", "bat" );

	/* */
	body.obj = object:EntityGetNumber("object-id");
	shadow = ObjectCreate( "", CIRCLE, mqDisplayArea.x+8, mqDisplayArea.y+32, 2, 16, 8, 0x000000DD );
	ShowObjects( body.obj, shadow );
}


main()
{
	if ( mqState == GONE || GameState() != 1 )
		return;

	if ( HasStateChanged() )
	{
		ResetObjects( body.obj );
	}

	if ( mqState <= MOVING )
		CollisionSet(SELF, 0, TYPE_ENEMY, mqDisplayArea.x + adj, mqDisplayArea.y + adj, mqDisplayArea.w - (adj*2), mqDisplayArea.h - (adj*2) );
	else
		CollisionSet(SELF, 0 );

	switch( mqState )
	{
		case STANDING:
			Stand();
		case MOVING:
			Move();
		case HIT:
			Hurt();
		case DYING:
			HandleDying();
		case SPECIALSTATE:
			Special();
		case DEAD:
		{
			HideObjects( body.obj, shadow );
			CollisionSet(SELF, -1, 0);
			SetState(GONE);
			return;
		}
	}
	UpdateEntityGraphics( body );
	ObjectPosition( shadow, mqDisplayArea.x+8, mqDisplayArea.y+32, 2, 16, 8);
}


public Close()
{
	CollisionSet(SELF, 0, 0);
	CollisionSet(SELF, 1, 0);
	ObjectDelete(shadow);
}

/* Local Functions */

/* State */ 
STATEFUNCTION Move()
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

STATEFUNCTION Stand()
{
	ReplaceEntityGraphics( body, STATE_GRAPHIC, STATE_FLIP );
	CollisionSet(SELF, 1, TYPE_AWAKING, mqDisplayArea.x - listen_rad, mqDisplayArea.y - listen_rad, mqDisplayArea.w + (listen_rad*2), mqDisplayArea.h + (listen_rad*2) );
}


STATEFUNCTION Hurt()
{
	EntityMove(MASK_ENEMYSOLID1);

	new q = (HitCount % 100) / 20;
	ColourEntityGraphics(body, mqHitColours[q]);

	if ( Countdown(HitCount) )
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

	if ( Countdown(mqEffectTimer) ) //Reset State
	{
		SetState(STANDING);
	}

}
/* Public Functions */

PUBLIC_EVENT_AWAKING
{
	SetState(MOVING);
	timer = 0;
	AudioPlaySound("enemy_bat2.wav", mqDisplayArea.x, mqDisplayArea.y);
	CollisionSet(SELF, 1, 0);
}

PUBLIC_EVENT_HIT
{
	if ( !damage && attack&APLAYER != APLAYER )
		return;
	if ( mqState == HIT || mqState == DYING || mqState == GONE )
		return;

	mqAttacker = attacker;
	new child;

	mqMovementAngle = fixed(360 - angle);

	if ( attack&AFIRE == AFIRE )
	{
		mqState = SPECIALSTATE;
		// Create a Burning fire entity on this enemy
		//EntityCreate( "effect_fire", "*", mqDisplayArea.x, mqDisplayArea.y, 5, CURRENT_MAP );
		//StunCount = 3200;
	}
	else if ( attack&AICE == AICE )
	{
		// Create a frozen effect around the enemy
		//EntityCreate( "effect_freeze", child, mqDisplayArea.x, mqDisplayArea.y, 5, CURRENT_MAP );
		EntityPublicFunction( child, "SetArea", ''nnnn'', mqDisplayArea.x, mqDisplayArea.y, mqDisplayArea.w, mqDisplayArea.h);
		//ObjectEffect( obj, 0x0000FFFF );
		//StunCount = 3200;
		mqState = SPECIALSTATE;
	}
	else if ( attack&ASTUN == ASTUN )
	{
		mqState = SPECIALSTATE;
		//StunCount = damage * 10;
	}
	else if ( attack&APLAYER == APLAYER )
	{
		CallEntityHit( attacker, 0, angle, 5, ASWORD,  mqDamageDealt, x, y, rect );
		//EntityPublicFunction( attacker, "Hurt", ''nnn'' ASWORD, mqDamageDealt, angle );
		return;
	}
	else
	{
		AudioPlaySound( "enemy_hurt.wav", mqDisplayArea.x, mqDisplayArea.y );
		mqState = HIT;
		mqHealth -= damage;
		HitCount = 1000;
		Hurt();
	}
	CheckHealth();
}



