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


#define SLIDEVAR 512

forward public Show( new_owner, weapons1, weapons2, weapons3 );
forward public Refresh();
forward public Hide();
forward public AddWeapon( weaponName{64}, weaponId, ownerId );


const local: {
	disabled = 0,
	entering,
	exiting
}

new slide = 0;
new local:mode = disabled;
new owner=0;

new weapon[30][.id, .icon{64}, .active];

new selectedItems[3] = [ -1, -1, -1 ];
new inputAction[3] = [ 0, -1, 0 ];

public Show( new_owner, weapons1, weapons2, weapons3 )
{
	slide = SLIDEVAR;
	mode = entering;
	EntityPublicFunction( EntityHash(HUD_ENTITY_ID), "Hide", "");
	mqDisplayObject = ObjectCreate("menu", CANVAS, 0, 0-slide, 6, 512, 512, 0xFFFFFFFF); 

	GameState(3);

	owner = new_owner;

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

	SheetReference("menuicon.png", 1);
}

public Refresh()
{
	ObjectPosition( mqDisplayObject, 0, 0-slide, 6000, 512, 512, GLOBAL_MAP);

	if ( selectedItems[0] >= 0 )
	{
		//❶ ❷ ❸
		GraphicsDraw("", CIRCLE, ICON_MENU_X +((selectedItems[0]%ICON_MENU_LINECOUNT)*ICON_SPACING_X), ICON_MENU_Y + ((selectedItems[0]/ICON_MENU_LINECOUNT)*ICON_SPACING_Y) - slide, 6000, 40, 40, 0xFF000077);
		GraphicsDraw("❶", TEXT, ICON_MENU_X +((selectedItems[0]%ICON_MENU_LINECOUNT)*ICON_SPACING_X), ICON_MENU_Y + ((selectedItems[0]/ICON_MENU_LINECOUNT)*ICON_SPACING_Y) - slide, 6000, 0, 0, 0xFFFFFFFF);
	}	
	if ( selectedItems[1] >= 0 )
	{
		GraphicsDraw("", CIRCLE, ICON_MENU_X +((selectedItems[1]%ICON_MENU_LINECOUNT)*ICON_SPACING_X), ICON_MENU_Y + ((selectedItems[1]/ICON_MENU_LINECOUNT)*ICON_SPACING_Y) - slide, 6000, 40, 40, 0xFFFF0077);
		GraphicsDraw("❷", TEXT, ICON_MENU_X +((selectedItems[1]%ICON_MENU_LINECOUNT)*ICON_SPACING_X), ICON_MENU_Y + ((selectedItems[1]/ICON_MENU_LINECOUNT)*ICON_SPACING_Y) - slide, 6000, 0, 0, 0xFFFFFFFF);
	}	
	if ( selectedItems[2] >= 0 )
	{	
		GraphicsDraw("", CIRCLE, ICON_MENU_X +((selectedItems[2]%ICON_MENU_LINECOUNT)*ICON_SPACING_X), ICON_MENU_Y + ((selectedItems[2]/ICON_MENU_LINECOUNT)*ICON_SPACING_Y) - slide, 6000, 40, 40, 0xFF00FF77);
		GraphicsDraw("❸", TEXT, ICON_MENU_X +((selectedItems[2]%ICON_MENU_LINECOUNT)*ICON_SPACING_X), ICON_MENU_Y + ((selectedItems[2]/ICON_MENU_LINECOUNT)*ICON_SPACING_Y) - slide, 6000, 0, 0, 0xFFFFFFFF);

	}
	GraphicsDraw("", CIRCLE, ICON_MENU_X +((inputAction[0]%ICON_MENU_LINECOUNT)*ICON_SPACING_X), ICON_MENU_Y + ((inputAction[0]/ICON_MENU_LINECOUNT)*ICON_SPACING_Y) - slide, 6000, 40, 40, 0xFFFFFF77);
	

	new n = 0, x, y;
	while (n < 30)
	{
		x = ((n%ICON_MENU_LINECOUNT)*ICON_SPACING_X);
		y = ((n/ICON_MENU_LINECOUNT)*ICON_SPACING_Y);

		if ( weapon[n].active )
		{
			GraphicsDraw(weapon[n].icon, SPRITE, ICON_MENU_X + ICON_OFFSET_X + x, ICON_MENU_Y + ICON_OFFSET_Y + (y - slide), 6000, 0, 0);
		}
		else
		{
			GraphicsDraw("menuicon.png:1", SPRITE, ICON_MENU_X + ICON_OFFSET_X + x, ICON_MENU_Y + ICON_OFFSET_Y + (y - slide), 6000, 0, 0, 0x111111FF);
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
				slide = -1;
				if ( InputButton(6)  == 1 )
					Hide();

				inputAction[1] = (InputAxis(0)/255) + ((InputAxis(1)/255)* 6);


				if ( inputAction[2] != inputAction[1] )
				{
					inputAction[2] = inputAction[1];
				}
				else
				{
					inputAction[2] = 0;
				}

				inputAction[0] += inputAction[2];
				inputAction[0] = NumberClamp(inputAction[0], 0, 29);


				if ( inputAction[0] >= 0 && inputAction[0] < 29 )
				{
					if ( InputButton(0)  == 1 )
					{
						if ( inputAction[0]  != selectedItems[1]  && inputAction[0]  != selectedItems[2] )
						{ 
							EntityPublicFunction(owner, "SetWeapon", ''nn'', weapon[inputAction[0]].id, 0);
							selectedItems[0] = inputAction[0];
						}
					}
					if ( InputButton(1)  == 1 )
					{
						if ( inputAction[0]  != selectedItems[0]  && inputAction[0]  != selectedItems[2] )
						{ 
							EntityPublicFunction(owner, "SetWeapon", ''nn'', weapon[inputAction[0]].id, 1);
							selectedItems[1] = inputAction[0];
						}					
					}
					if ( InputButton(2)  == 1 )
					{
						if ( inputAction[0]  != selectedItems[1]  && inputAction[0]  != selectedItems[0] )
						{ 
							EntityPublicFunction(owner, "SetWeapon", ''nn'', weapon[inputAction[0]].id, 2);
							selectedItems[2] = inputAction[0];
						}
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
				EntityPublicFunction( EntityHash(HUD_ENTITY_ID), "Show", '''' );
				ObjectDelete(mqDisplayObject);
				mqDisplayObject = OBJECT_NONE;
				GameState(1);
				SheetReference("menuicon.png", -1);
			}
			Refresh();
		}

		default:
		{
		}

	}

}

public AddWeapon( weaponName{64}, weaponId, ownerId )
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
	strformat(weapon[n].icon, _, true, "menuicon.png:%s", weaponName);
	
}

