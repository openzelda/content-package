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
#include <counters>

forward public Show();
forward public Refresh();
forward public Hide();

/* Hearts */
#define HEARTS_X 320
#define HEARTS_Y 24

new active = 0;
new count = 0;
new used = 0;
new object:hud = object:-1;
new owner = 0;

DrawCharacter(number, px, py, pz, colour, alpha)
{
	new gfx[20];
	strformat(gfx, _, _, "alpha01.png:%d", number+48);
	GraphicsDraw(gfx, SPRITE, px, py, pz, 0, 0);
	return MiscGetWidth(gfx);
}


public Show() 
{
	active = true;
	ObjectToggle(hud, 1);
}

public Refresh()
{
	
	count = EntityPublicVariable(owner, "mqMaxHealth");
	used = EntityPublicVariable(owner, "mqHealth");

	if (count > 0)
	{
		new q = NumberClamp(count/50, 0, 39);
		new u = used/50;
		DebugText("%d, %d", q, u);
		for ( new c = 0; c < q; c += 2 )
		{
			if ( c+1 == u )
				GraphicsDraw("hud.png:heart_h", SPRITE,  HEARTS_X + ((c%20)*8), HEARTS_Y+((c/20)*8), 6000, 0, 0);
			else if ( c < u )
				GraphicsDraw("hud.png:heart_f", SPRITE,  HEARTS_X + ((c%20)*8), HEARTS_Y+((c/20)*8), 6000, 0, 0);
			else 
				GraphicsDraw("hud.png:heart_e", SPRITE,  HEARTS_X + ((c%20)*8), HEARTS_Y+((c/20)*8), 6000, 0, 0);
		}
	}

	new v = 0;
	new px;
	for ( new c = 0; c < 3; c++ )
	{
		v = EntityPublicVariable(counters[c].entityID, "v");
		px = counters[c].screenX;
		if(v > 100)
		{
			px += DrawCharacter(v/100, px, counters[c].screenY, 6000, 0xFFFFFF00, 0xFF)
			v %= 100;
		}	
		if(v > 10)
		{
			px += DrawCharacter(v/10, px, counters[c].screenY, 6000, 0xFFFFFF00, 0xFF)
			v %= 10;
		}
		if(v >= 0)
		{
			px += DrawCharacter(v, px, counters[c].screenY, 6000, 0xFFFFFF00, 0xFF)
		}	
		
	}

}

public Hide() 
{
	ObjectToggle(hud, 0);
	active = false;
}

public Init(...)
{
	active = true;
	SheetReference("hud.png", 1);

	hud = ObjectCreate("hud", CANVAS, 0, 0, 6000, 0, 0, .pos = GLOBAL_MAP); 
	

	if ( numargs() )
	{
		owner = getarg(0, 0);
	}

	CreateCounters();

	Refresh();

}

public Close()
{
	SheetReference("hud.png", -1);
	ObjectDelete(hud);
}

main()
{
	if ( active )
		Refresh();
}


