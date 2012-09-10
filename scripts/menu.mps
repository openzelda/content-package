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
 *     2011/06/17 [luke]: new file.
 ***********************************************/

/* Setting */
#define ICON_MENU_X 48
#define ICON_MENU_Y 32
#define ICON_SPACING_X 48
#define ICON_SPACING_Y 48
#define ICON_OFFSET_X 4
#define ICON_OFFSET_Y 4
#define ICON_MENU_LINECOUNT 6


#define SLIDEVAR 384
forward public Show( selfid[], weapons1[], weapons2[], weapons3[] );
forward public Refresh();
forward public Hide();
forward public AddWeapon( w[64]);


enum ListItem {
	ID[64],
	ICON[64],
	ACTIVE,
}

enum local {
	disabled,
	entering,
	exiting
}

new slide = 0;
new local:mode = disabled;
new object:menu = object:-1;
new owner[64]="";
new controller = 0;
new weapon[30][ListItem];

new action[4] = {0, -1,-1,-1};

public Show( selfid[], weapons1[], weapons2[], weapons3[] )
{
	slide = SLIDEVAR;
	mode = entering;
	EntityPublicFunction("hudent", "Hide", "");
	menu = ObjectCreate("menu", CANVAS, 0, -slide,6, 512, 512, 0xFF0000AA, GLOBAL_MAP); 

	GameState(3);

	strcopy(owner, selfid);

	for (new n = 0; n < 30; n++)
	{
		if ( StringEqual(weapon[n][ID], weapons1) )
		{
			action[1] = n;
		}
		else if ( StringEqual(weapon[n][ID], weapons2) )
		{
			action[2] = n;
		}
		else if ( StringEqual(weapon[n][ID], weapons3) )
		{
			action[3] = n;
		}
	}
}

public Refresh()
{
	ObjectPosition( menu, 0, -slide, 6, 512, 512, GLOBAL_MAP);

	if ( action[1] >= 0 )
		GraphicsDraw("", CIRCLE, ICON_MENU_X +((action[1]%ICON_MENU_LINECOUNT)*ICON_SPACING_X), ICON_MENU_Y + ((action[1]/ICON_MENU_LINECOUNT)*ICON_SPACING_Y) - slide, 6, 40, 40, 0xFF000077);
	if ( action[2] >= 0 )
		GraphicsDraw("", CIRCLE, ICON_MENU_X +((action[2]%ICON_MENU_LINECOUNT)*ICON_SPACING_X), ICON_MENU_Y + ((action[2]/ICON_MENU_LINECOUNT)*ICON_SPACING_Y) - slide, 6, 40, 40, 0xFFFF0077);
	if ( action[3] >= 0 )
		GraphicsDraw("", CIRCLE, ICON_MENU_X +((action[3]%ICON_MENU_LINECOUNT)*ICON_SPACING_X), ICON_MENU_Y + ((action[3]/ICON_MENU_LINECOUNT)*ICON_SPACING_Y) - slide, 6, 40, 40, 0xFF00FF77);

	GraphicsDraw("", CIRCLE, ICON_MENU_X +((action[0]%ICON_MENU_LINECOUNT)*ICON_SPACING_X), 32 + ((action[0]/ICON_MENU_LINECOUNT)*ICON_SPACING_Y) - slide, 6, 40, 40, 0xFFFFFF77);


	new n = 0, x, y;
	while (n < 30)
	{
		x = ((n%ICON_MENU_LINECOUNT)*ICON_SPACING_X);
		y = ((n/ICON_MENU_LINECOUNT)*ICON_SPACING_Y);

		if ( weapon[n][ACTIVE] )
		{
			GraphicsDraw(weapon[n][ICON], SPRITE, ICON_MENU_X + ICON_OFFSET_X + x, ICON_MENU_Y + ICON_OFFSET_Y + (y - slide), 6, 0, 0);
		}
		else
		{
			GraphicsDraw("menuicon.png:1", SPRITE, ICON_MENU_X + ICON_OFFSET_X + x, ICON_MENU_Y + ICON_OFFSET_Y + (y - slide), 6, 0, 0, 0x111111FF);
		}
		
		n++;
	}

}

public Hide()
{
	mode = exiting;
}

public Init(...)
{

}

public Close()
{
	
}

main()
{
	switch ( mode )
	{
		case entering:
		{
			if ( slide > 0 )
			{
				slide -= GameFrame();
			}
			else
			{
				if ( InputButton(6,controller)  == 1 )
					Hide();

				action[0] += (InputAxis(0,controller)/255);
				action[0] += (InputAxis(1,controller)/255)* 6;
				action[0] = NumberClamp(action[0], 0, 29);
				
				if ( action[0] >= 0 && action[0] < 29 )
				{
					if ( InputButton(0,controller)  == 1 )
					{
						EntityPublicFunction(owner, "SetWeapon", "sn", weapon[action[0]][ID], 0);
						action[1] = action[0];
					}
					if ( InputButton(1,controller)  == 1 )
					{
						EntityPublicFunction(owner, "SetWeapon", "sn", weapon[action[0]][ID], 1);
						action[2] = action[0];
					}
					if ( InputButton(2,controller)  == 1 )
					{
						EntityPublicFunction(owner, "SetWeapon", "sn", weapon[action[0]][ID], 2);
						action[3] = action[0];
					}
				}
			}
			Refresh();

		}
		case exiting:
		{
			if ( slide < SLIDEVAR )
			{
				slide += GameFrame();
			}
			else
			{
				EntityPublicFunction("hudent", "Show", "");
				ObjectDelete(menu);
				menu = object:-1;
				GameState(1);
			}
			Refresh();
		}

		default:
		{
		}

	}

}

public AddWeapon( w[64] )
{
	new n = 0;
	while (n < 32)
	{
		if ( !weapon[n][ACTIVE]  )
			break;
		n++;
	}		

	strcopy(weapon[n][ID], w);
	strformat(weapon[n][ICON], _, true, "menuicon.png:%s", w);
	weapon[n][ACTIVE] = true;
}

