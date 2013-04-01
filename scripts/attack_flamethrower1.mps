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
#include <movement>
#include <public_events>


forward PUBLIC_EVENT_HIT;

new Fixed:active_timer = 0.0;

public Init( ... )
{
	GetEntityPosition(mqEntityPosition.x, mqEntityPosition.y, mqEntityPosition.z, mqDisplayArea.x, mqDisplayArea.y, mqDisplayZIndex, mqDisplayLayer);

	mqDisplayObject = ObjectCreate("aquamentus.png:flame", SPRITE, mqDisplayArea.x, mqDisplayArea.y, mqDisplayZIndex, 32, 32);
	ObjectEffect(mqDisplayObject, _, _, 2000,2000);
	AudioPlaySound( "effect_fire1.wav", mqDisplayArea.x, mqDisplayArea.y );

	if ( numargs() )
		mqMovementAngle = Fixed:getarg(0);
}

public Close()
{
	ObjectDelete( mqDisplayObject );
}

main()
{
	active_timer += GameFrame2();
	if ( active_timer > 7.000 )
	{
		EntityDelete();
		return;
	}

	new Fixed:speed = mqMovementSpeed * GameFrame2(); // Movement fot the frame
	new Fixed:movex = fsin(mqMovementAngle, degrees) * speed;
	new Fixed:movey = fcos(mqMovementAngle, degrees) * speed;

	mqEntityPosition.x += movex;
	mqEntityPosition.y += movey;

	mqDisplayArea.x = fround(mqEntityPosition.x, round_unbiased)+16;
	mqDisplayArea.y = fround(mqEntityPosition.y, round_unbiased)+16;

	if ( MaskGetValue(mqDisplayArea.x, mqDisplayArea.y) > 200 )
		EntityDelete();

	ObjectPosition(mqDisplayObject, mqDisplayArea.x-16, mqDisplayArea.y-16, mqDisplayZIndex, 0, 0);
	CollisionFromObject(mqDisplayObject, TYPE_ENEMY);
}

PUBLIC_EVENT_HIT
{
	if ( attack&APLAYER == APLAYER )
	{
		EntityPublicFunction( attacker, "Hurt", "nn", AFIRE, 50 );
		EntityDelete();
	}
	else if ( attack&ASHIELD == ASHIELD )
	{
		EntityDelete();
	}

}

