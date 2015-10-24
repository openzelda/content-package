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
 *     2010/01/11 [luke]: new file. 
 ***********************************************/ 
#include <weapon> 
#include <public_events> 
#include <movement> 
 
 
new timer = 0; 
new sheet{} = "weapon_sword01.png"; 
new player_sheet{} = "p01swing.png"; 
new anim[4]{11} = [ "swing-front", "swing-side", "swing-back", "swing-side" ]; 
new swordSprite{64}, playerSprite{64}; 
new swordangle = 0; 
 
new result = 0; 
 
public Init(...) 
{ 
	qDisplayOffset.y += 32; 
	qDisplayOffset.x += 12; 
} 
 
public Close() 
{ 
	ObjectDelete(qObject); 
} 
 
main() { } //So Engine doesn't complain 
 
weapon_begin(  object:playerObject, dir ) 
{ 
	if ( timer || qObject != OBJECT_NONE ) 
		return 0; 
	 
	timer = AnimationGetLength(sheet, anim[dir]); 
	timer = timer ? timer : 200; // In case of missing sprite

	StringFormat( swordSprite, _, "%s:%s", sheet, anim[dir] ); 
	StringFormat( playerSprite, _, "%s:%s", player_sheet, anim[dir] ); 
 
	if (dir == 2) 
		qObject = ObjectCreate( swordSprite, SPRITE, qDisplayArea.x, qDisplayArea.y, qPosition.z - 4, 0, 0); 
	else if (dir == 0) 
		qObject = ObjectCreate( swordSprite, SPRITE, qDisplayArea.x + qDisplayOffset.x, qDisplayArea.y + qDisplayOffset.y, qPosition.z + 1, 0, 0 ); 
	else  if (dir == 3) 
		qObject = ObjectCreate( swordSprite, SPRITE, qDisplayArea.x + 4, qDisplayArea.y, qPosition.z + 1, 0, 0 ); 
	else 
		qObject = ObjectCreate( swordSprite, SPRITE, qDisplayArea.x, qDisplayArea.y, qPosition.z + 1, 0, 0 ); 
 
 
	ObjectFlag( qObject, FLAG_SPEED, 1 ); 
	ObjectFlag( qObject, FLAG_ANIMLOOP, 0 ); 
	ObjectEffect( qObject, WHITE, _, _, _, (dir == 3 ? 16 : 0), _, _ ); 
 
	ObjectInfo( qObject, qDisplayArea.w, qDisplayArea.h, qDisplayArea.x, qDisplayArea.y); 
 
	result = ObjectReplace( playerObject, playerSprite, SPRITE ); // Replace player sprite with swinging sprite 

	return result;
} 
 
weapon_collision( ) 
{ 
	new hx, hy, hw, hh, hitCenterX, hitCenterY; 
 
	CollisionFromObject( qObject, TYPE_WEAPON); 
	CollisionGet(SELF, 0, hx, hy, hw, hh); 
 
	hitCenterX = hx+(hw/2); 
	hitCenterY = hy+(hh/2); 
 
	swordangle = D2A(qDisplayDirection); 
 
	if ( CollisionCalculate() ) 
	{ 
		new entity:current; 
		new angle; 
		new dist; 
		new rect; 
		new type; 
 
		while ( CollisionGetCurrent(SELF, current, angle, dist, rect, type) ) 
		{ 
			if ( type == _:TYPE_ENEMY || type == _:TYPE_AWAKING ) 
			{ 
				CallEntityHit(current, ownerid, swordangle, dist, ASWORD, 50, hitCenterX, hitCenterY, rect); 
			} 
		} 
	} 
} 
 
weapon_ended( object:player ) 
{ 
	if ( TimerCountdownWithReset(timer, 0) ) 
	{ 
		ObjectDelete(qObject); 
		CollisionSet(SELF, -1, 0); 
		qObject = OBJECT_NONE; 
		return 0; 
	} 
	return 1; 
} 
 
public End( object:player, dir ) 
{ 
	timer = 0; 
	weapon_ended( player ); 
} 
 
public Use( object:player, dir ) 
{ 
	new object:playerObject = player; 
	qDisplayDirection = NumberClamp((dir/2), 0, 3); 
	 
	EntityPublicFunction(ownerid, "UsingCustomAnimation"); 
 
	GetEntityPosition(qPosition.x, qPosition.y, qPosition.z, qDisplayArea.x, qDisplayArea.y); 
 
	weapon_begin( playerObject, qDisplayDirection ); 
 
	weapon_collision( ); 
	 
	return weapon_ended( playerObject ); 
} 
