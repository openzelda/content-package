/*********************************************** 
 * Copyright © Luke Salisbury 
 * 
 * You are free to share, to copy, distribute and transmit this work 
 * You are free to adapt this work 
 * Under the following conditions: 
 *  You must attribute the work in the manner specified by the author 
 *  or licensor (but not in any way that suggests that they endorse you
 *  or your use of the work).  
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
	qMovementSpeed = 50; 
	qDamageDealt = 50; 
	qHealth = qMaxHealth = 50; 
 
	/* These are used more for collision through EntityMove then for Display.*/ 
	qDisplayArea.w = qDisplayArea.h = 32; 
 
	EnemyInit(); 
 
	/* Set up Objects */ 
	SetStateGraphic( STANDING, qSheet, "bat_1", "bat_1", "bat_1", "bat_1" ); 
	SetStateGraphic( MOVING, qSheet, "bat", "bat", "bat", "bat" ); 
 
	/* Retrieve Display Objects */ 
	body.obj = object:EntityGetNumber("object-id"); 
	CreateEntityShadow( shadow ); 
 
} 
 
public Close() 
{ 
	CollisionSet(SELF, -1, 0); 
	DeleteEntityGraphics(shadow); 
	ObjectFlag( body.obj, FLAG_HIDDEN, false ); 
} 
 
main() 
{ 
	if ( qState == GONE ||  GameState() != GS_ALL ) 
		return; 
 
	if ( HasStateChanged() ) 
	{ 
		ObjectsReset( body.obj ); 
	} 
 
	if ( qState <= MOVING ) 
		CollisionSet(SELF, 0, TYPE_ENEMY, qDisplayArea.x + adj, qDisplayArea.y + adj, qDisplayArea.w - (adj*2), qDisplayArea.h - (adj*2) ); 
 
	switch( qState ) 
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
			ObjectFlag( body.obj, FLAG_HIDDEN, false ); 
			DeleteEntityGraphics( shadow ); 
			CollisionSet(SELF, -1, 0); 
			SetState(GONE); 
			return; 
		} 
	} 
 
	UpdateObject();
} 
 
UpdateObject()
{
	UpdateEntityGraphics( body ); 
	UpdateEntityGraphics( shadow ); 
}
 
 
 
/* States */  
State_Move() 
{ 
	ReplaceEntityGraphics( body, STATE_GRAPHIC, STATE_FLIP ); 
 
	// randomly change direction 
	if ( !random(30) ) 
		qMovementAngle = fixed(random(8) * 45); 
 
	// Move the enemy 
	EntityMove( MASK_ENEMYSOLID1 ); 
 
	timer += GameFrame(); 
	if ( timer >= 2000 ) 
		qState = STANDING; 
} 
 
State_Stand() 
{ 
	ReplaceEntityGraphics( body, STATE_GRAPHIC, STATE_FLIP ); 
	CollisionSet(SELF, 1, TYPE_AWAKING, qDisplayArea.x - listen_rad, qDisplayArea.y - listen_rad, qDisplayArea.w + (listen_rad*2), qDisplayArea.h + (listen_rad*2) ); 
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
	ColourEntityGraphics(body, qHitColours[q]); 
 
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
 
	switch ( qCurrentEffect ) 
	{ 
		case STUNNED: 
		{ 
			StunnedEffect( qEffectTimer ); 
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
 
	if ( TimerCountdown(qEffectTimer) ) //Reset State 
	{ 
		SetState(STANDING); 
	} 
 
} 
 
 
 
/* Public Functions */ 
PUBLIC_EVENT_AWAKING 
{ 
	if ( qState == STANDING ) 
	{ 
		timer = 0; 
	 
		SetState(MOVING); 
		AudioPlaySound("enemy_bat2.wav", qDisplayArea.x, qDisplayArea.y); 
 
		CollisionSet(SELF, 1, 0); 
	} 
} 
 
PUBLIC_EVENT_HIT 
{ 
	if ( qState == HIT || qState == DYING || qState == GONE ) 
		return; 
	if ( rect == 1) 
		return; 
	qAttacker = attacker; 
	qMovementAngle = fixed(angle); 
 
	if ( attack&AFIRE == AFIRE ) 
	{ 
		qState = SPECIALSTATE; 
	} 
	else if ( attack&AICE == AICE ) 
	{ 
		qState = SPECIALSTATE; 
	} 
	else if ( attack&ASTUN == ASTUN ) 
	{ 
		qState = SPECIALSTATE; 
	} 
	else if ( attack&APLAYER == APLAYER ) 
	{ 
		CallEntityHurt( qAttacker, ASWORD, qDamageDealt, angle ); 
	} 
	else if ( qState != HIT ) 
	{ 
		AudioPlaySound( "enemy_hurt.wav", qDisplayArea.x, qDisplayArea.y ); 
		qState = HIT; 
		qHealth -= damage; 
		HitCount = 800; 
		State_Hurt(); 
	} 
	CheckHealth(); 
} 
 
 
 
