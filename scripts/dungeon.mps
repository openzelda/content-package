#include <core>
#include <time>
#include <entities>
#include <network>
#include <string>
#include <player>


forward public Entered();
forward public Exited();
forward public Finished();

new start = 0;
new Fixed:timer = 0.00;
new active = 0;
new name[32] = !"Unknown Dungeon";
new text[12];
new obj = -1;
new fade = 0;
new finished = 0;
new justent = 0;

public Init(...)
{
	if ( !start ) 
	{
		EntityGetSetting( "name", name, "__map__" );
		start = TimestampCurrent();
	}
	justent = 1;
}

public UpdatePosition() { }
public Close() { }

main()
{
	
	if ( finished && active )
	{
		new mes[32];
		strformat(mes, _, true, "Finished dungeon in %.2q seconds", finished - start);
		EntityPublicFunction("main", "CustomText", "snnnnnn", mes, -1, -1, 6, 19, 2, 255 );
	}

	if ( !GameState() )
		return;

	if ( justent )
	{
		timer += GameFrame2();
	
		if ( timer < 5.00 )
		{
			if ( timer > 2.50 )
				fade = fdiv(timer, 0.02);
			//DebugText("%d %d %q %d", timer, fade, fade, fround(Fixed:fade));
			EntityPublicFunction("main", "CustomText", "snnnnnn", name, -1, -1, 6, 40, 1, 255 - fround(Fixed:fade) );
		}
		else
		{
			timer = 0.00;
			justent = 0;
		}
	}
}

public Entered()
{
	active = 1;
}

public Exited()
{
	active = 0;
}

public Finished()
{
	finished = TimestampCurrent();
	GameState(2);
	new mes[128];
	new name[16];
	PlayerGetName(0, name);

	//strformat(mes, _, true, "hyruleanadventures.thegaminguniverse.com/heroes/submit/?t=%d&u=%s&d=1", finished - start, name);
	//OnlineData(_, mes);
}
