#include <open_zelda>
#include <string>
#include <item>

new Fixed:count = 0.0;
new obj = -1;
new p[64];
new dungeon[32] = "dungeon-d";
new dungeonid = 0;

public Init( ... )
{
	EntityGetPosition(mqEntityPosition.x,mqEntityPosition.y, mqDisplayZIndex);
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
	if ( mqState != LIFTING )
	{
		strcopy(p, player);
		EntityPublicFunction(dungeon, "Finished");
		EntityGetPosition(mqEntityPosition.x,mqEntityPosition.y,  mqDisplayZIndex, p);
		mqDisplayZIndex++;
	}
	mqState = LIFTING;
	return true;
}

HandleLift()
{
	if ( mqState == LIFTING )
	{
		count += GameFrame2(); 
		if ( count < 4.00 )
		{
			mqEntityPosition.y -= GameFrame2()*8.0;
			UpdateDisplayPosition();
			ObjectPosition(object:obj, mqDisplayArea.x, mqDisplayArea.y, 4, 0, 0);
		}
		else
		{
			EntityDelete(p);
			EntityPublicFunction(dungeon, "Exited");
			MapChange(MapCurrent("Exit"));
		}

	}
}
