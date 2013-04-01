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

/*
Disabled Networking Code
forward public NetMessage( player, array[], size );
native EntityNetworkSync();
native NetworkMessage(reliable, server, message[], length, reallength = sizeof(message));

*/

forward public UpdatePosition();
forward public Push(attacker, rect, angle);

new playingAudio = false;

/*
public NetMessage(player, array[], size)
{
	if ( size )
	{
		MaskFill(mqDisplayArea.x, mqDisplayArea.y, mqDisplayArea.w, mqDisplayArea.h, 0);
		mqDisplayArea.x = GetBits( array[0], mqDisplayArea.x, 0, 16 );
		mqDisplayArea.y = GetBits( array[0], mqDisplayArea.y, 16, 16 );
		ObjectPosition(obj, mqDisplayArea.x, mqDisplayArea.y, mqDisplayZIndex, 0, 0);
		MaskFill(mqDisplayArea.x, mqDisplayArea.y, mqDisplayArea.w, mqDisplayArea.h, 255);
		CollisionSet(SELF, 0, TYPE_PUSHABLE, mqDisplayArea.x-1, mqDisplayArea.y-1, mqDisplayArea.w+2, mqDisplayArea.h+2);
		EntitySetPosition(mqEntityPosition.x,mqEntityPosition.y, mqEntityPosition.z);
		UpdateDisplayPosition();
	}
}
*/

public Init(...)
{
	mqMovementSpeed = 40.0;

	SetupEntity( ALIVE, TYPE_PUSHABLE, mqDisplayObject, 32, 32, 0, 0 );
	ObjectInfo( mqDisplayObject, mqDisplayArea.w, mqDisplayArea.h );

	StorePosition();
}

public UpdatePosition()
{
	MaskFill( mqDisplayArea.x, mqDisplayArea.y, mqDisplayArea.w, mqDisplayArea.h, MASK_CLEAR );
	EntityGetPosition( mqEntityPosition.x, mqEntityPosition.y, mqEntityPosition.z);

	UpdateDisplayPosition();
	StorePosition();

	ObjectPosition(mqDisplayObject, mqDisplayArea.x, mqDisplayArea.y, mqDisplayZIndex, 0, 0);
	MaskFill(mqDisplayArea.x, mqDisplayArea.y, mqDisplayArea.w, mqDisplayArea.h, MASK_BLOCK );
	CollisionSet(SELF, 0, TYPE_PUSHABLE, mqDisplayArea.x-1, mqDisplayArea.y-1, mqDisplayArea.w+2, mqDisplayArea.h+2);
}

public Close()
{
	MaskFill(mqDisplayArea.x, mqDisplayArea.y, mqDisplayArea.w, mqDisplayArea.h, MASK_CLEAR);
	CollisionSet(SELF, 0, 0);
}

public Push(attacker, rect, angle)
{
	if ( mqState != MOVING )
	{
		angle = (angle/45)*45;
		if ( !(angle % 90) ) // Angle Must be multiple of 90
		{
			mqMovementAngle = fixed(angle);
			SoundPlayOnce(playingAudio, "object_push.wav");
			mqState = MOVING;
			if ( mqMovementAngle < 0 )
				mqMovementAngle += 360.0;
			mqMovementAngle = 360.0 - mqMovementAngle;
		}
	}
}

/*
NetworkUpdate()
{
	new message[1];
	SetBits( message[0], mqDisplayArea.x, 0, 16 );
	SetBits( message[0], mqDisplayArea.y, 16, 16 );
	NetworkMessage(1, 0, message, 1);
	EntityNetworkSync();
}
*/

Update()
{
	CollisionSet(SELF, 0, TYPE_PUSHABLE, mqDisplayArea.x-1, mqDisplayArea.y-1, mqDisplayArea.w+2, mqDisplayArea.h+2);
}

main()
{
	if ( mqState == MOVING )
	{
		mqState = STANDING;
		MaskFill(mqDisplayArea.x, mqDisplayArea.y, mqDisplayArea.w, mqDisplayArea.h, MASK_CLEAR);
		if ( EntityMove( MASK_NORMALGROUND ) )
		{
			ObjectPosition(mqDisplayObject, mqDisplayArea.x, mqDisplayArea.y, mqDisplayZIndex, 0, 0);
			Update();
		}
		MaskFill(mqDisplayArea.x, mqDisplayArea.y, mqDisplayArea.w, mqDisplayArea.h, MASK_BLOCK);
	}

}
