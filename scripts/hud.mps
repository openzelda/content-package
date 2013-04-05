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
new object:obj[20] = [ object:-1, ...];
new object:hud = object:-1;
new owner;

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
	for ( new c = 0; c < 20; c++ )
	{
		ObjectToggle(obj[c], 1);
	}
}

public Refresh()
{
	count = EntityPublicVariable(owner, "mqMaxHealth");
	used = EntityPublicVariable(owner, "mqHealth");

	if (count > 0)
	{
		new q = NumberClamp(count/100, 0, 19);
		new u = used/50;
		
		for ( new c = 0; c < q; c++ )
		{
			if ( obj[c] == object:-1 )
				obj[c] = ObjectCreate("hud.png:heart_f", SPRITE,  HEARTS_X + ((c%10)*16), HEARTS_Y+((c/10)*16), 6, 0, 0);
			if (  u >= (c*2)+2  )
				ObjectReplace(obj[c], "hud.png:heart_f", SPRITE);
			else if (  u >= (c*2)+1 )
				ObjectReplace(obj[c], "hud.png:heart_h", SPRITE);
			else
				ObjectReplace(obj[c], "hud.png:heart_e", SPRITE);
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
	for ( new c = 0; c < 20; c++ )
	{
		ObjectToggle(obj[c], 0);
	}

	active = false;

}

public Init(...)
{
	active = true;
	hud = ObjectCreate("hud", CANVAS, 0, 0, 6000, 0, 0, .pos = GLOBAL_MAP); 
	new c = 0;
	if ( numargs() >=1 )
	{
		new i = 0;
		do 
		{
			c = getarg(0, i++);
		} while(c && i<64);
	}

	CreateCounters();
	count = EntityPublicVariable(owner, "mqMaxHealth");
	used = EntityPublicVariable(owner, "mqHealth");
	if (count > 0)
	{
		Refresh();
	}
}

public Close()
{
	ObjectDelete(hud);
}

main()
{
	if ( active )
		Refresh();
}


