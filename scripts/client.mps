#include <open_zelda>
#include <string>
#include <core>
#include <network>

forward public NetMessage(player, array[], array_size);

new _STATE:player_state = STANDING;

new animation[2][4][32] = {
	{!"p02n.png:front_0", !"p02n.png:side_0", !"p02n.png:back_0", !"p02n.png:side_0"},//STANDING,
	{!"p02n.png:front", !"p02n.png:side", !"p02n.png:back", !"p02n.png:side"},//MOVING,
};

new obj = -1;
new name_obj = -1;
new active = true;
new modechanged;
new str[128];
new name[12];
new selfid[64];

public NetMessage(player, array[], array_size)
{
	if (array_size == 1)
	{
		new d = array[0] >> 24;
		new s = (array[0] >> 16) & 0x000000FF;

		if ( s != STANDING)
			player_state = MOVING;
		else
			player_state = STANDING;

		d = clamp(d, 0, 3);
		if ( player_state != last_state )
		{
			modechanged = true;
			last_state = player_state;
		}
		if ( d != _dir_ )
		{
			modechanged = true;
			_dir_ = d;
		}
	}
}

public Init(...)
{
	_dir_ = 0;
	EntityGetSetting("client-name", name);
	EntityGetSetting("id", selfid, SELF);
	EntityGetPosition( _x_, _y_, _z_);
	UpdateDisplayPosition();
	
	dw = 32;
	dh = 24;
	dz = 3
	ox = 0;
	oy = 24;
	
	new test[16];
	new base[32];
	strformat( test, _, true, "p%sn.png:front_0", name );
	if ( MiscGetWidth(test) > 0)
		strcopy(base, name);
	else
		strcopy(base, "02");
	
	
	strformat( animation[0][0], _, true, "p%sn.png:%s", base, "front_0" );
	strformat( animation[0][1], _, true, "p%sn.png:%s", base, "side_0" );
	strformat( animation[0][2], _, true, "p%sn.png:%s", base, "back_0" );
	strformat( animation[0][3], _, true, "p%sn.png:%s", base, "side_0" );

	strformat( animation[1][0], _, true, "p%sn.png:%s", base, "front" );
	strformat( animation[1][1], _, true, "p%sn.png:%s", base, "side" );
	strformat( animation[1][2], _, true, "p%sn.png:%s", base, "back" );
	strformat( animation[1][3], _, true, "p%sn.png:%s", base, "side" );

	obj = ObjectCreate(animation[0][0], 's', dx, dy, 3, 0, 0);
	name_obj = ObjectCreate(name, 't', dx, dy+44, 4, 0, 0);
	Toggle();

}

Toggle()
{
	if ( EntityActive() == 1 )
		active = 1;
	else
		active = 0;
	ObjectToggle(obj, active);
	ObjectToggle(name_obj, active);
}

public UpdatePosition()
{
	
}

main()
{
	Toggle();
	if ( EntityActive(SELF) == 1 )
	{
		EntityGetPosition( _x_, _y_, _z_);
		UpdateDisplayPosition();
		CollisionSet(SELF,0,0,dx+ox,dy+oy,dw,dh);
		if ( CollisionCalculate() )
		{
			new current[64];
			new angle;
			new dist;
			new rect;
			new _STATE:type;
			while ( CollisionGetCurrent(SELF, current, angle, dist, rect, type) )
			{
				if ( type == TYPE_SWITCH )
				{
					// public Pressed(attacker[], rect, angle)
					EntityPublicFunction(current, "Pressed", "snn", selfid, rect, angle);
				}
			}
		}
		ObjectPosition(obj, dx, dy, 3, 0, 0);
		ObjectPosition(name_obj, dx, dy+44, 4, 0, 0);
		if ( modechanged )
		{
			if ( player_state == STANDING )
				ObjectReplace(obj, animation[0][_dir_], 's' );
			else
				ObjectReplace(obj, animation[1][_dir_], 'a' );
		}
	}
	modechanged = false;
}



