#include <mokoi_quest>
#include <string>
#include <item>

new Fixed:count = 0.0;
new obj = -1;
new p[64];
new dungeon[32] = "dungeon-d";
new dungeonid = 0;

public Init( ... )
{
	EntityGetPosition(_x_,_y_, _z_);
	UpdateDisplayPosition();

	obj = EntityGetNumber("object-id");

	dungeonid = EntityGetNumber("dungeon-id");
	strformat(dungeon, _, _, "dungeon-%d", dungeonid);

	CollisionFromObject(obj, TYPE_ITEM);
}

main()
{
	HandleLift();
}

public Pickup( player[] )
{
	if ( _state_ != LIFTING )
	{
		strcopy(p, player);
		EntityPublicFunction(dungeon, "Finished");
		EntityGetPosition(_x_,_y_,  _z_, p);
		_z_++;
	}
	_state_ = LIFTING;
	return true;
}

HandleLift()
{
	if ( _state_ == LIFTING )
	{
		count += GameFrame2(); 
		if ( count < 4.00 )
		{
			_y_ -= GameFrame2()*8.0;
			UpdateDisplayPosition();
			ObjectPosition(object:obj, dx, dy, 4, 0, 0);
		}
		else
		{
			EntityDelete(p);
			EntityPublicFunction(dungeon, "Exited");
			MapChange(MapCurrent("Exit"));
		}

	}
}
