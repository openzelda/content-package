/***********************************************
 * Copyright © Luke Salisbury
 *
 * You are free to share, to copy, distribute and transmit this work
 * You are free to adapt this work
 * Under the following conditions:
 *  You must attribute the work in the manner specified by the author or licensor (but
 *    not in any way that suggests that they endorse you or your use of the work). 
 *  You may not use this work for commercial purposes.
 * Full terms of use: http://creativecommons.org/licenses/by-nc/3.0/
 * Changes:
 *     2010/01/11 [luke]: new file.
 ***********************************************/
#include <counters>

forward public Show();
forward public Refresh();
forward public Hide();

forward public ShowMenu( entity:new_owner, entity:weapons1, entity:weapons2, entity:weapons3 );
forward public HideMenu();
forward public AddWeapon( weaponName{64}, entity:weaponId, entity:ownerId );

/* Setting */
#define ICON_MENU_X 48
#define ICON_MENU_Y 32
#define ICON_SPACING_X 48
#define ICON_SPACING_Y 48
#define ICON_OFFSET_X 4
#define ICON_OFFSET_Y 4
#define ICON_MENU_LINECOUNT 6
#define FONT_WIDTH 16
#define SLIDEVAR 384

const local: {
	hideall = 0,
	hudonly,
	entering,
	menuonly,
	exiting,
}

/* Counters */ 
#define CounterItem[entity:.entityID, .width]

new counters[6][CounterItem] = [ 
	[ entity:0, 3 ], //HEART
	[ entity:0, 2 ], //BOMBS
	[ entity:0, 2 ], //ARROW
	[ entity:0, 3 ], //RUPEE
	[ entity:0, 1 ], //KEY
	[ entity:0, 1 ] //MAGIC
] 

/* Hearts */
new heartsLocation[RECT];
new magicLocation[RECT];
new rupeesLocation[RECT];
new bombsLocation[RECT];
new arrowsLocation[RECT];
new keysLocation[RECT];


new object:menuObject;
new object:hudObject;
new slide[POINT] = [ 0, 0 ];
new offset[POINT] = [ 0, -SLIDEVAR ];
new local:mode = hudonly;
new entity:owner;

new weapon[30][entity:.id, .icon{64}, .active];

new selectedItems[3] = [ -1, -1, -1 ];
new Fixed:inputAction[3] = [ 0.0, 0.0, 0.0 ];
new menuPosition;

new heartsCount = 0;
new heartsUsed = 0;

public Show() 
{
	mode = hudonly
	ObjectFlag(hudObject, FLAG_HIDDEN, 0);
}

public ShowMenu( entity:new_owner, entity:weapons1, entity:weapons2, entity:weapons3 )
{
	mode = entering;
	
	GameState(3);

	for (new n = 0; n < 30; n++)
	{
		if ( weapon[n].id == weapons1 )
		{
			selectedItems[0] = n;
		}
		else if ( weapon[n].id == weapons2 )
		{
			selectedItems[1] = n;
		}
		else if ( weapon[n].id == weapons3 )
		{
			selectedItems[2] = n;
		}
	}
}

public HideMenu()
{
	mode = exiting;
}

public AddWeapon( weaponName{64}, entity:weaponId, entity:ownerId )
{
	new n = 0;
	while (n < 30)
	{
		if ( !weapon[n].active  )
			break;
		n++;
	}

	weapon[n].id = weaponId;
	weapon[n].active = true;
	StringFormat(weapon[n].icon, _, "menuicon.png:%s", weaponName);
}


public Refresh()
{

}

public Hide()
{
	ObjectFlag(hudObject, FLAG_HIDDEN, 1);
	mode = hideall;
}

public Init(...)
{
	SheetReference("hud.png", 1);
	SheetReference("menuicon.png", 1);

	hudObject = ObjectCreate("hud", CANVAS, 0 + slide.x, 0 + slide.y, 6.000, 0, 0, WHITE, 1);
	menuObject = ObjectCreate("menu", CANVAS, 0 + slide.x + offset.x, 0 + slide.y + offset.y, 6.0, 512, 512, WHITE, 1);

	//ObjectFlag(menuObject, FLAG_HIDDEN, 1);

	if ( numargs() )
	{
		owner = entity:getarg(0, 0);
	}

	RetrieveCounters(owner);


	PlaceholderInfo( hudObject, heartsLocation, "hearts", true);
	PlaceholderInfo( hudObject, magicLocation, "magic", false);
	PlaceholderInfo( hudObject, rupeesLocation, "rupees", true);
	PlaceholderInfo( hudObject, bombsLocation, "bombs", true);
	PlaceholderInfo( hudObject, arrowsLocation, "arrows", true);
	PlaceholderInfo( hudObject, keysLocation, "keys", true);


}

public Close()
{
	SheetReference("hud.png", -1);
	SheetReference("menuicon.png", -1);

	ObjectDelete(hudObject);
	ObjectDelete(menuObject);
}

main()
{
	ConsoleOutput("Parent ID %d", owner);

	switch ( mode )
	{
		case hudonly:
		{
			RefreshHUD();
		}

		case menuonly:
		{
			inputAction[0] += (InputAxis(0) * GameFrameSeconds()*8) / 255;
			inputAction[1] += (InputAxis(1) * GameFrameSeconds()*8) / 255;

			inputAction[0] = RealClamp(inputAction[0], 0, 5);
			inputAction[1] = RealClamp(inputAction[1], 0, 4);

			menuPosition = RealRound(inputAction[0]) + ( RealRound(inputAction[1]) * 6);
			menuPosition = NumberClamp(menuPosition, 0, 29);

			if ( menuPosition >= 0 && menuPosition < 29 )
			{
				if ( InputButton(0) == 1 )
				{
					if ( menuPosition != selectedItems[1]  && menuPosition  != selectedItems[2] )
					{ 
						EntityPublicFunction(owner, "SetWeapon", ''nn'', _, weapon[menuPosition].id, 0);
						selectedItems[0] = menuPosition
					}
				}
				if ( InputButton(1) == 1 )
				{
					if ( menuPosition != selectedItems[0]  && menuPosition != selectedItems[2] )
					{
						EntityPublicFunction(owner, "SetWeapon", ''nn'', _, weapon[menuPosition].id, 1);
						selectedItems[1] = menuPosition
					}
				}
				if ( InputButton(2)  == 1 )
				{
					if ( menuPosition != selectedItems[1]  && menuPosition != selectedItems[0] )
					{ 
						EntityPublicFunction(owner, "SetWeapon", ''nn'', _, weapon[menuPosition].id, 2);
						selectedItems[2] = menuPosition
					}
				}
			}
			RefreshMenu();
		}
		case entering:
		{
			ObjectFlag(menuObject, FLAG_HIDDEN, 0);

			slide.y += GameFrame();

			if ( slide.y > SLIDEVAR )
			{
				slide.y =SLIDEVAR
				mode = menuonly;
				inputAction[0] =inputAction[1]  = 0.0;
			}

			RefreshHUD();
			RefreshMenu();
		}
		case exiting:
		{
			slide.y -= GameFrame();
			if ( slide.y <= 0 )
			{
				mode = hudonly;
				slide.y = 0;
				ObjectFlag(menuObject, FLAG_HIDDEN, 0);
				GameState(1);
			}
			RefreshMenu();
			RefreshHUD();
		}
		default:
		{

		}
	}
	
}

PlaceholderInfo( object:parent, info[RECT], name{}, hide )
{
	new object:placeholder = CanvasChildInfo( parent, name, info.x, info.y, info.w, info.h);
	if ( hide )
		CanvasChildSetEffect(parent, placeholder, 0x00000000);
}

ipow(base, exp)
{
	new result = 1;
	while (exp)
	{
		if (exp & 1)
			result *= base;
		exp >>= 1;
		base *= base;
	}

	return result;
}

RetrieveCounters( owner ) 
{ 
	for ( new q = 0; q < 6; q++ ) 
	{
		counters[q].entityID = EntityPublicFunction(owner, "GetItemCounter", [ARG_NUMBER, ARG_END], _, q );
	}
}

DrawCharacter(number, px, py, Fixed:pz, colour)
{
	new gfx{20};
	StringFormat(gfx, _, "alpha01.png:%d", number+48);
	GraphicsDraw(gfx, SPRITE, px, py, pz, 0, 0, colour);
	return 8;
}

DrawCounter( counter[CounterItem], info[RECT])
{
	new value = 0;
	new v,d;

	value = EntityPublicVariable(counter.entityID, "v");

	for ( new c = 0; c < counter.width; c++ )
	{
		d = ipow(10, counter.width - 1 - c );
		v = value/d
		DrawCharacter(v, info.x + slide.x + (c * FONT_WIDTH), info.y + slide.y, 6.0, 0xFFFFFFFF);
		value %= d;
	}
}


RefreshHUD()
{
	ObjectPosition( hudObject, 0 + slide.x, 0 + slide.y, 6.000, 512, 512);

	heartsCount = EntityPublicVariable(owner, "qMaxHealth");
	heartsUsed = EntityPublicVariable(owner, "qHealth");

	ConsoleOutput( "heartsUsed %d %d", heartsUsed, heartsCount );

	if ( heartsCount > 0)
	{
		new q = NumberClamp(heartsCount/50, 0, 39);
		new u = heartsUsed/50;
		for ( new c = 0; c < q; c += 2 )
		{
			if ( c+1 == u )
				GraphicsDraw("hud.png:heart_h", SPRITE, heartsLocation.x + ((c%20)*8) + slide.x, heartsLocation.y + ((c/20)*8) + slide.y, 6.000, 0, 0);
			else if ( c < u )
				GraphicsDraw("hud.png:heart_f", SPRITE, heartsLocation.x + ((c%20)*8) + slide.x, heartsLocation.y + ((c/20)*8) + slide.y, 6.000, 0, 0);
			else 
				GraphicsDraw("hud.png:heart_e", SPRITE, heartsLocation.x + ((c%20)*8) + slide.x, heartsLocation.y + ((c/20)*8) + slide.y, 6.000, 0, 0);
		}
	}
	DrawCounter(counters[ITEM_RUPEE], rupeesLocation);
	DrawCounter(counters[ITEM_ARROW], arrowsLocation);
	DrawCounter(counters[ITEM_BOMBS], bombsLocation);
	DrawCounter(counters[ITEM_KEY], keysLocation);

}

RefreshMenu()
{
	ObjectPosition( menuObject, 0 + slide.x + offset.x, 0 + slide.y + offset.y, 6.000, 512, 512);


//	hudObject = ObjectCreate("hud", CANVAS, 0 + slide.x, 0 + slide.y, 6.000, 0, 0);
//	menuObject = ObjectCreate("menu", CANVAS, 0 + slide.x + offset.x, 0 + slide.y + offset.y, 6.0, 512, 512);


	if ( selectedItems[0] >= 0 )
	{
		//❶ ❷ ❸
		GraphicsDraw("", CIRCLE, ICON_MENU_X +((selectedItems[0]%ICON_MENU_LINECOUNT)*ICON_SPACING_X) + slide.x + offset.x, ICON_MENU_Y + ((selectedItems[0]/ICON_MENU_LINECOUNT)*ICON_SPACING_Y) + slide.y + offset.y, 6.000, 40, 40, 0xFF000077);
		GraphicsDraw("❶", TEXT, ICON_MENU_X +((selectedItems[0]%ICON_MENU_LINECOUNT)*ICON_SPACING_X) + slide.x + offset.x, ICON_MENU_Y + ((selectedItems[0]/ICON_MENU_LINECOUNT)*ICON_SPACING_Y) + slide.y + offset.y, 6.000, 0, 0, 0xFFFFFFFF);
	}
	if ( selectedItems[1] >= 0 )
	{
		GraphicsDraw("", CIRCLE, ICON_MENU_X +((selectedItems[1]%ICON_MENU_LINECOUNT)*ICON_SPACING_X) + slide.x + offset.x, ICON_MENU_Y + ((selectedItems[1]/ICON_MENU_LINECOUNT)*ICON_SPACING_Y) + slide.y + offset.y, 6.000, 40, 40, 0xFFFF0077);
		GraphicsDraw("❷", TEXT, ICON_MENU_X +((selectedItems[1]%ICON_MENU_LINECOUNT)*ICON_SPACING_X) + slide.x + offset.x, ICON_MENU_Y + ((selectedItems[1]/ICON_MENU_LINECOUNT)*ICON_SPACING_Y) + slide.y + offset.y, 6.000, 0, 0, 0xFFFFFFFF);
	}
	if ( selectedItems[2] >= 0 )
	{
		GraphicsDraw("", CIRCLE, ICON_MENU_X +((selectedItems[2]%ICON_MENU_LINECOUNT)*ICON_SPACING_X) + slide.x + offset.x, ICON_MENU_Y + ((selectedItems[2]/ICON_MENU_LINECOUNT)*ICON_SPACING_Y) + slide.y + offset.y, 6.000, 40, 40, 0xFF00FF77);
		GraphicsDraw("❸", TEXT, ICON_MENU_X +((selectedItems[2]%ICON_MENU_LINECOUNT)*ICON_SPACING_X) + slide.x + offset.x, ICON_MENU_Y + ((selectedItems[2]/ICON_MENU_LINECOUNT)*ICON_SPACING_Y) + slide.y + offset.y, 6.000, 0, 0, 0xFFFFFFFF);
	}

	GraphicsDraw("", CIRCLE, ICON_MENU_X +((menuPosition%ICON_MENU_LINECOUNT)*ICON_SPACING_X) + slide.x + offset.x, ICON_MENU_Y + ((menuPosition/ICON_MENU_LINECOUNT)*ICON_SPACING_Y) + slide.y + offset.y, 6.000, 40, 40, 0xFFFFFF77);

	new n = 0, x, y;
	while (n < 30)
	{
		x = ((n%ICON_MENU_LINECOUNT)*ICON_SPACING_X) + slide.x + offset.x;
		y = ((n/ICON_MENU_LINECOUNT)*ICON_SPACING_Y) + slide.y + offset.y;

		if ( weapon[n].active )
		{
			GraphicsDraw(weapon[n].icon, SPRITE, ICON_MENU_X + ICON_OFFSET_X + x , ICON_MENU_Y + ICON_OFFSET_Y + y , 6.000, 0, 0);
		}
		else
		{
			GraphicsDraw("menuicon.png:1", SPRITE, ICON_MENU_X + ICON_OFFSET_X + x, ICON_MENU_Y + ICON_OFFSET_Y + y , 6.000, 0, 0, 0x111111FF);
		}
		
		
		n++;
	}

}
