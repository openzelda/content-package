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
#include <time>
#include <network>
#include <player>


forward public Entered();
forward public Exited();
forward public Finished();


new name{32} = "Unknown Dungeon";

new startTime = 0;
new finishTime = 0;
new Fixed:timer = 0.00;
new active = 0;

new Fixed:fade = 0.00;

new justEntered = 0;

public Init(...)
{
	if ( !startTime ) 
	{
		EntityGetSetting( "name", name, ENTITY_MAP );
		startTime = TimestampCurrent();
	}
	justEntered = 1;
}

public UpdatePosition() { }
public Close() { }

main()
{
	if ( finishTime && active )
	{
		new mes{32};
		StringFormat(mes, _, true, "Finished dungeon in %.2q seconds", finishTime - startTime);
		EntityPublicFunction(ENTITY_MAIN, "CustomText", ''snnnnnn'', mes, -1, -1, 6000, 19, 2, 255 );
	}

	if ( !GameState() )
		return;

	if ( justEntered )
	{
		timer += GameFrame2();
	
		if ( timer < 5.00 )
		{
			if ( timer > 2.50 )
				fade = fdiv(timer, 0.02);
			//forward public CustomText(message{}, x, y, z, width, height, alpha)
			EntityPublicFunction( ENTITY_MAIN, "CustomText", ''snnnnnn'', name, -1, -1, 6000, 40, 1, 255 - fround(fade) );
		}
		else
		{
			timer = 0.00;
			justEntered = 0;
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
	finishTime = TimestampCurrent();
	GameState(2);

	new name[16];
	PlayerGetName(0, name);


}
