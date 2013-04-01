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
#include <network>

forward public NetMessage(player, array[], array_size);


new animation[2][4]{32} = [
	["p02n.png:front_0", "p02n.png:side_0", "p02n.png:back_0", "p02n.png:side_0"], //STANDING,
	["p02n.png:front", "p02n.png:side", "p02n.png:back", "p02n.png:side"] //MOVING,
];

new object:nameObject = OBJECT_NONE;
new active = true;
new modechanged;
new str[128];
new name[12];


public NetMessage(player, array[], array_size)
{
	if ( array_size == 1 )
	{
		new d = array[0] >> 24;
		new s = (array[0] >> 16) & 0x000000FF;

		if ( s != STANDING)
			mqState = MOVING;
		else
			mqState = STANDING;

		d = clamp(d, 0, 3);
		if ( mqState != mqStatePrev )
		{
			modechanged = true;
			mqStatePrev = mqState;
		}
		if ( d != mqDirection )
		{
			modechanged = true;
			mqDirection = d;
		}
	}
}


public Init(...)
{

	SetupEntity( STANDING, 0, mqDisplayObject, 32, 24, 0, 24 );
	EntityGetSetting("client-name", name);


	new test[16];
	new base[32];
	StringFormat( test, _, true, "p%sn.png:front_0", name );
	if ( MiscGetWidth(test) > 0)
		StringCopy(base, name);
	else
		StringCopy(base, "02");
	
	
	StringFormat( animation[0][0], _, true, "p%sn.png:%s", base, "front_0" );
	StringFormat( animation[0][1], _, true, "p%sn.png:%s", base, "side_0" );
	StringFormat( animation[0][2], _, true, "p%sn.png:%s", base, "back_0" );
	StringFormat( animation[0][3], _, true, "p%sn.png:%s", base, "side_0" );

	StringFormat( animation[1][0], _, true, "p%sn.png:%s", base, "front" );
	StringFormat( animation[1][1], _, true, "p%sn.png:%s", base, "side" );
	StringFormat( animation[1][2], _, true, "p%sn.png:%s", base, "back" );
	StringFormat( animation[1][3], _, true, "p%sn.png:%s", base, "side" );

	mqDisplayObject = ObjectCreate( animation[0][0], SPRITE, mqDisplayArea.x, mqDisplayArea.y, mqDisplayZIndex, 0, 0);
	nameObject = ObjectCreate( name, TEXT, mqDisplayArea.x, mqDisplayArea.y+44, mqDisplayZIndex+1.000, 0, 0);
	CheckActive();

}

public Close()
{
	ObjectDelete( mqDisplayObject );
	ObjectDelete( nameObject );
}

CheckActive()
{

	active = !!EntityActive();
	ObjectToggle( mqDisplayObject, active );
	ObjectToggle( nameObject, active );

}

public UpdatePosition()
{
	
}

main()
{

	CheckActive();
	if ( active )
	{
		GetEntityPosition( mqEntityPosition.x, mqEntityPosition.y, mqEntityPosition.z, mqDisplayArea.x, mqDisplayArea.y, mqDisplayZIndex, mqDisplayLayer );

		CollisionSet(SELF, 0, 0, mqDisplayArea.x+mqDisplayOffset.x, mqDisplayArea.y+mqDisplayOffset.y, mqDisplayArea.w, mqDisplayArea.h);
		if ( CollisionCalculate() )
		{
			new current;
			new angle;
			new dist;
			new rect;
			new _STATE:type;
			while ( CollisionGetCurrent(SELF, current, angle, dist, rect, type) )
			{
				if ( type == TYPE_SWITCH )
				{
					CallEntityPressed(current, mqEntityId, rect, angle);
				}
			}
		}
		ObjectPosition(mqDisplayObject, mqDisplayArea.x, mqDisplayArea.y, 3, 0, 0);
		ObjectPosition(nameObject, mqDisplayArea.x, mqDisplayArea.y+44, 4, 0, 0);
		if ( modechanged )
		{
			if ( mqState == STANDING )
				ObjectReplace(mqDisplayObject, animation[0][mqDirection], 's' );
			else
				ObjectReplace(mqDisplayObject, animation[1][mqDirection], 'a' );
		}
	}
	modechanged = false;


}



