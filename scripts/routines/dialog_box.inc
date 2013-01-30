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
 *     2013/01/31 [luke]: switch to Pawn 4
 ***********************************************/
forward public dialogbox(line);

#define DialogChar[.x, .y, .obj]
#define DIALOGWIDTH 35
#define DIALOGHEIGHT 6
#define FONTWIDTH 8
#define FONTHEIGHT 16

new dialog_obj = -1;
new dialog_line = -1;
new dialog_text[200][DialogChar];

HandleDialogBox()
{
	if ( dialog_line >= 0 )
	{
	/*
		new c = 0
		while ( dialog_text[c][obj] )
		{
			ObjectDelete(dialog_text[c][obj]);
			dialog_text[c][obj] = -1
			c++;
		}
		*/
		//SheetReference( "alpha02.png", -1);
		return true;
	}
	return false;
}

DialogCharacter(c, achar, qx, qy)
{
	new sprite{20};
	new w;
	strformat(sprite, _, 1, "alpha02.png:%d", achar);
	w = MiscGetWidth(sprite);
	if ( !w )
	{
		strformat(sprite, _, 1, "alpha02.png:%d", '?');
		w = MiscGetWidth(sprite);
	}
	dialog_text[c].x = qx;
	dialog_text[c].y = qy;
	dialog_text[c].obj = ObjectCreate(sprite, SPRITE, qx, qy, 6, 0, 0);
	return w;
}

//¶ - paragraph
public dialogbox(line)
{
	new dialog{256};
	new tx = 104;
	new ty = 104;
	new nx = 104;
	new n = 0;
	new on = 0;
	new c = 0;
	new space = -1;

	SheetReference( "alpha02.png" );
	DialogGetString(line, dialog);

	dialog_line = line;
	dialog_obj = ObjectCreate(" ", 'r', 100, 100, 6, 300, 4*32);
	ObjectEffect(dialog_obj, 0x00000077,_,_,_,_, STYLE_VGRADIENT,0x00000022);

	while ( dialog[n] && n < 256 ) // Never use strlen in a for or while loop
	{
		if ( dialog[n] == 32 )
		{
			space = n;
			nx += FONTWIDTH;
		}
		else if ( dialog[n] == '¶' ) // 0xC2 0xB6
		{
			dialog[n] = '\n';
			space = 0;
			c = 0;
			ty += FONTHEIGHT;
			nx = tx;
		}

		if ( c++ >= DIALOGWIDTH )
		{
			if ( n - space > 6 )
			{
				DialogCharacter(n+on, '-', nx, ty);
				on++;
			}
			else if ( space > 0 )
			{
				ty += FONTHEIGHT;
				nx = tx;
				space = 0;
				c = 0
			}
		}
		if ( dialog[n] > 32 )
			nx += DialogCharacter(n+on, dialog[n], nx, ty);
		n++;
	}
}
