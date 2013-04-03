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
#include <weapon>
#include <public_events>
#include <movement>


new timer = 0;
new sheet{} = "sword01.png";
new player_sheet{} = "p01swing.png";
new anim[4]{11} = [ "swing-front", "swing-side", "swing-back", "swing-side" ];
new swordSprite{64}, playerSprite{64};
new swordangle = 0;

public Init(...)
{
	mqDisplayOffset.y += 32;
	mqDisplayOffset.x += 12;
	mqEntityId = entityId:EntityGetSettingHash("id");
}

public Close()
{
	ObjectDelete(mqDisplayObject);
}

main() { 
	DebugText("Sword running %d  %d ", timer, mqDisplayDirection );
	DebugText("swordSprite '%s'", swordSprite );
	DebugText("playerSprite '%s'", playerSprite );
	DebugText("mqDisplayZIndex: %d, mqDisplayLayer: %d", mqDisplayZIndex, mqDisplayLayer );

} //So Engine doesn't complain

weapon_begin(  object:player, dir )
{
	if ( timer || mqDisplayObject != OBJECT_NONE )
		return;


	
	timer = AnimationGetLength(sheet, anim[dir]);
	strformat( swordSprite, _, true, "%s:%s", sheet, anim[dir] );
	strformat( playerSprite, _, true, "%s:%s", player_sheet, anim[dir] );

	if (dir == 2)
		mqDisplayObject = ObjectCreate( swordSprite, SPRITE, mqDisplayArea.x, mqDisplayArea.y, mqDisplayZIndex - 4, 0, 0);
	else if (dir == 0)
		mqDisplayObject = ObjectCreate( swordSprite, SPRITE, mqDisplayArea.x + mqDisplayOffset.x, mqDisplayArea.y + mqDisplayOffset.y, mqDisplayZIndex +1 , 0, 0);
	else  if (dir == 3)
		mqDisplayObject = ObjectCreate( swordSprite, SPRITE, mqDisplayArea.x + 4, mqDisplayArea.y, mqDisplayZIndex + 1, 0, 0);
	else
		mqDisplayObject = ObjectCreate( swordSprite, SPRITE, mqDisplayArea.x, mqDisplayArea.y, mqDisplayZIndex + 1, 0, 0);

	ObjectFlag( mqDisplayObject, FLAG_SPEED, 1);
	ObjectFlag( mqDisplayObject, FLAG_ANIMLOOP, 0);
	ObjectEffect( mqDisplayObject, WHITE, _, _, _, (dir == 3 ? 16 : 0), _, _ );

	ObjectInfo( mqDisplayObject, mqDisplayArea.w, mqDisplayArea.h);

	ObjectReplace( player, playerSprite, SPRITE ); // Replace player sprite with swinging sprite
}

weapon_collision( )
{
	new hx, hy, hw, hh, hitCenterX, hitCenterY;

	CollisionFromObject( mqDisplayObject, TYPE_WEAPON);
	CollisionGet(SELF, 0, hx, hy, hw, hh);

	hitCenterX = hx+(hw/2);
	hitCenterY = hy+(hh/2);

	swordangle = D2A(mqDisplayDirection);

	if ( CollisionCalculate() )
	{
		new entityId:current;
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
	if ( CountTimer(timer, 0) )
	{
		ObjectDelete(mqDisplayObject);
		CollisionSet(SELF, -1, 0);
		mqDisplayObject =  OBJECT_NONE;
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
	mqDisplayDirection = NumberClamp((dir/2), 0, 3);
	
	
	
	GetEntityPosition(mqEntityPosition.x, mqEntityPosition.y, mqEntityPosition.z, mqDisplayArea.x, mqDisplayArea.y, mqDisplayZIndex, mqDisplayLayer);

	weapon_begin( player, mqDisplayDirection );

	weapon_collision( );

	
	return weapon_ended( player );
}