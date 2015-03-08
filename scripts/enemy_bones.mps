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
	qMovementSpeed = 50; 
	qDamageDealt = 50; 
	qHealth = qMaxHealth = 100; 
 
	HeadDirection = SOUTH; 
 
	/* These are used more for collision through EntityMove then for Display.*/ 
	qDisplayArea.w = qDisplayArea.h =  24; 
	qDisplayOffset.x = 4; 
	qDisplayOffset.y = 28; 
 
	EnemyInit(); 
 
	SetStateGraphic( STANDING, qSheet, "front_0", "side_0", "back_0", "side_0" ); 
	SetStateGraphic( MOVING, qSheet, "front", "side", "back", "side" ); 
	SetStateGraphic( LEAPING, qSheet, "stomp", "stomp", "stomp", "stomp" ); 
	SetStateGraphic( DYING, qSheet, "front_0", "side_0", "back_0", "side_0" ); 
 
	StringFormat( graphicHead[0], _, "%s:head_front", qSheet); 
	StringFormat( graphicHead[1], _, "%s:head_side", qSheet); 
	StringFormat( graphicHead[2], _, "%s:head_back", qSheet); 
	StringFormat( graphicHead[3], _, "%s:head_side", qSheet); 
 
	//textColor = (NumberRandom(0xffffff) << 8) + 0xff; 
 
	/* Retrieve Display Objects */ 
	ObjectFlag( EntityGetObject(), FLAG_HIDDEN, false  ); // We don't the map placeholder object, we will use our own. 
 
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
	if ( qState == GONE || GameState() != 1 ) 
	{ 
		return; 
	} 
 
	if ( HasStateChanged() ) 
	{ 
		ObjectsReset( head.obj, body.obj ); 
	} 
 
	/* Collisions Settings */ 
	new q = (qState == LEAPING ? 2 : 0); // Use which hit zone to use 
	CollisionSet(SELF, 0, TYPE_ENEMY, qDisplayArea.x + hitzone[q].x, qDisplayArea.y + hitzone[q].y, hitzone[q].w, hitzone[q].h ); 
	CollisionSet(SELF, 1, TYPE_AWAKING, qDisplayArea.x + hitzone[1].x, qDisplayArea.y + hitzone[1].y, hitzone[1].w, hitzone[1].h ); 
 
	switch( qState ) 
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
	if ( qState == LEAPING ) 
	{ 
		ObjectPosition( body.obj, qDisplayArea.x+body.x, qDisplayArea.y+body.y-6, qPosition.z+body.z, 0, 0); 
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
		qMovementAngle = Dir2Angle(qDirection); 
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
	ColourEntityGraphics(body, qHitColours[q]); 
	ColourEntityGraphics(head, qHitColours[q]); 
 
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
 
	switch ( qCurrentEffect ) 
	{ 
		case STUNNED: 
		{ 
			StunnedEffect( qEffectTimer ); 
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
 
	if ( TimerCountdown(qEffectTimer) ) //Reset State 
	{ 
		SetState(STANDING); 
	} 
 
} 
 
 
 
/* Public Functions */ 
//public Hit( entityId:attacker, angle, dist, attack, damage, x, y, rect ) 
PUBLIC_EVENT_HIT 
{ 
	if ( qState == HIT || qState == DYING || qState == GONE ) 
		return; 
 
	new a = angle; 
	qAttacker = attacker; 
 
	if ( attack&APLAYER == APLAYER ) 
	{ 
		CallEntityHurt( qAttacker, ASWORD, qDamageDealt, a ); 
	} 
	else if ( qState != HIT ) 
	{ 
		qMovementAngle = fixed(angle); 
		if ( rect == 1 ) 
		{ 
			if ( attack&ASWORD == ASWORD ) 
			{ 
				SetState(LEAPING); 
				LeapCount = 800; 
			} 
		} 
		else 
		{ 
			AudioPlaySound( "enemy_hurt.wav", qDisplayArea.x, qDisplayArea.y ); 
			qState = HIT; 
			qHealth -= damage; 
			HitCount = 800; 
			State_Hurt(); 
		} 
	} 
	CheckHealth(); 
}