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

#if !defined DEATHLENGTH
	#define DEATHLENGTH 1000
#endif

#include <movement>
#include <public_events>
#include <entity_health>
#include <entity> 
forward public Reset();

new qDamageDealt = 50;
new qInitialPosition[VECTOR3] = [ -99.0 , -99.0  , -99.0 ];
new bool:qIsABoss = false;
stock bool:qEntityResetable = false;
new entity:qAttacker;
new qItemDrop{64};
new qSprite{64};
new qSheet{64};
new qDeathTimer = 4200;
new object:qDeathObject;

new EffectState:qCurrentEffect = NOEFFECT;
new qEffectTimer = 0;

new qHitColours[5] = [ 0x138813FF, 0xFDD341FF, 0xE15805FF, 0x20D3EEFF, 0xEE2020FF ];

/**
* Enemy Init
*
*/
EnemyInit()
{
	qDirection = SOUTH;
	qDisplayDirection = 0;

	if ( qInitialPosition.x == -99.0 )
	{
		GetEntityPosition( qPosition.x, qPosition.y, qPosition.z, qDisplayArea.x, qDisplayArea.y );

		qState = STANDING
		qType = TYPE_ENEMY;
		
		qInitialPosition.x = qPosition.x;
		qInitialPosition.y = qPosition.y;
		qInitialPosition.z = qPosition.z;
		
		EntityGetSetting("object-image", qSprite);
		EntityGetSetting("item", qItemDrop);

		for ( new n = 0; qSprite{n} && qSprite{n} != ':' ; n++ )
		{
			qSheet{n} = qSprite{n};
		}
	}
	else
	{
		Reset();
	}
}

public Reset()
{
	qPosition.x = qInitialPosition.x;
	qPosition.y = qInitialPosition.y;
	qState = STANDING;
	qHealth = qMaxHealth;
	UpdateDisplayPosition();
	UpdateObject();
}

stock HandleDying()
{
	if ( TimerCountdown(qDeathTimer) )
	{
		qState = DEAD;
		ObjectDelete(qDeathObject);
		qDeathObject = OBJECT_NONE;
		DeathEvent();
		qDeathTimer = 0;
	}
}

stock CheckHealth()
{
	if ( qHealth <= 0 )
		Kill();
}

stock RandomizeMovement()
{
	new new_dir;
	do {
		new_dir = random(8);
	}while ( qDirection != new_dir )

	SetDir(new_dir);
	qMovementAngle = Dir2Angle(qDirection);
}


stock Kill( )
{
	qHealth = 0;
	qState = DYING;
	AudioPlaySound( ( qIsABoss ? "boss_killed.wav" : "enemy_killed.wav"), qDisplayArea.x, qDisplayArea.y);
	
	if ( !qDeathObject )
		qDeathObject = ObjectCreate("effects_death01.png:anim", SPRITE, qDisplayArea.x, qDisplayArea.y, qPosition.z + 100, 0, 0,WHITE);
	qDeathTimer = AnimationGetLength("effects_death01.png","anim") ;
	ObjectFlag(qDeathObject, FLAG_ANIMLOOP, false);
}

stock DeathEvent()
{
	FunctionCall( FunctionIdent("EnemyClose") );
	if ( qAttacker )
		EntityPublicFunction(qAttacker, "AddKill", ['n', '0'], _,  qMaxHealth );

	if ( qIsABoss )
	{
		new entityId, function{24};
		entityId = EntityGetHash( "on-death-entity" );
		EntityGetSetting( "on-death-function", function );
		if ( entityId && function{0} )
			EntityPublicFunction( entityId, function );
	}
	else
	{
		EntityPublicFunction(MAP_ENTITY, "KilledEnemy");
		EntityPublicFunction(EntityHash("itemlib"), "CreateItem", ''nns'', _, qDisplayArea.x + (qDisplayArea.w / 2), qDisplayArea.y + (qDisplayArea.y / 2), qItemDrop);
	}
}

stock CheckForHoles( )
{
	if (qState == HIT || qState == FALLING || qState == DYING )
		return false;

	// Check if the enemy is over a hole
	if ( MaskGetValue(qDisplayArea.x, qDisplayArea.y) == MASK_HOLE1 )
	{
		qState = FALLING; // Set the enemies state to falling
		AudioPlaySound("dropping.wav", qDisplayArea.x, qDisplayArea.y);
		return true;
	}
	return false;
}

stock Fall( img, width, height )
{
	new HoleType = MaskGetValue(qDisplayArea.x, qDisplayArea.y); // Check what type of hole we are in
	new length = AnimationGetLength(img);

	if ( !length )
	{
		if ( HoleType == MASK_HOLE1 ) // Check for a normal hole
		{
			Kill(); // Kill The enemy
		}
		else  // The enemy falls to another floor
		{
			// Work out the new world coordinates for the enemy
			/*
			new gridx = -1;
			new gridy = -1;
			MapGetGrid(gridx, gridy);
			
			SetX("this", (GetLowerLevelX() * 320) + (x - (screenx * 320)));
			SetY("this", (GetLowerLevelY() * 240) + (y - (screeny * 240)));
			if (screenx == GetLowerLevelX() && screeny == GetLowerLevelY())
			{
				Kill(""); // Kill The enemy
			}
			*/

			qState = STANDING;
			ClearCollisionSet(SELF, 0, 0);
		}
	}
}

stock StunnedEffect( count )
{
	static ShakeCount = 0;

	new ShakeOffset[5] = [ -2, -2, 0, 2, 2 ];

	if ( count <= 100)
	{
		qPosition.x += ShakeOffset[ ShakeCount ];
		ShakeCount++;
		if ( ShakeCount >= 5 )
			ShakeCount = 0;
	}

	if ( count <= 0)
		qState = STANDING;
}


stock StockHit( attacker[], angle, dist, attack, damage, x, y, rect )
{
	if ( damage == 0 && attack&APLAYER != APLAYER )
		return;

	if ( qState == HIT || qState == DYING || qState == GONE )
		return;

	qState = HIT;

	strcopy( qAttacker, attacker );
	new child = "*";

	qAngle = fixed(360 - angle);

	if ( attack&AFIRE == AFIRE )
	{
		qState = BURNING;
		// Create a Burning fire entity on this enemy
		EntityCreate( "effect_fire", "", qDisplayArea.x, qDisplayArea.y, qPosition.z, CURRENT_MAP );
		StunCount = 3200;
	}
	else if ( attack&AICE == AICE )
	{
		// Create a frozen effect around the enemy
		child = EntityCreate( "effect_freeze", "", qDisplayArea.x, qDisplayArea.y, qPosition.z, CURRENT_MAP, ''dddd'', qDisplayArea.x, qDisplayArea.y, qDisplayArea.w, qDisplayArea.h );
		ObjectEffect( obj, 0xFF0000FF );
		StunCount = 3200;
		qState = STUNNED;
	}
	else if ( attack&ASTUN == ASTUN )
	{
		qState = STUNNED;
		StunCount = damage * 10;
	}
	else if ( attack&APLAYER == APLAYER )
	{
		CallEntityHurt( qAttacker, AENEMY, qDamageDealt, angle)
	}
	else
	{
		qHealth -= damage;
		HitCount = 1800;
		AudioPlaySound( "enemy_hurt.wav", qDisplayArea.x, qDisplayArea.y );
		BeenHit();
	}
	CheckHealth();
}







stock CreateEntityShadow( display_object[EntityGraphic] )
{
	display_object.obj = ObjectCreate( "", CIRCLE, qDisplayArea.x + display_object.x, qDisplayArea.y + display_object.y, qPosition.z + display_object.z, display_object.width, display_object.height, 0x000000AA);
}