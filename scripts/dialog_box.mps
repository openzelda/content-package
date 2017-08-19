/*********************************************** 
 * Copyright © Luke Salisbury 
 * 
 * You are free to share, to copy, distribute and transmit this work 
 * You are free to adapt this work 
 * Under the following conditions: 
 *  You must attribute the work in the manner specified by the author 
 *  or licensor (but not in any way that suggests that they endorse you
 *  or your use of the work).  
 *  You may not use this work for commercial purposes. 
 * Full terms of use: http://creativecommons.org/licenses/by-nc/3.0/ 
 * Changes: 
 *     2010/01/11 [luke]: new file. 
 *     2013/01/31 [luke]: switch to Pawn 4 
 ***********************************************/ 
 
#define DIALOGCHAR[.x, .y, object:.obj] 
#define DIALOGWIDTH 30 
 
forward public dialogbox(line, x, y, z, image{64} ); 
 
new object:dialogBackground; 
new dialogLine = -1; 
new dialogText[200][DIALOGCHAR]; 
new dialogWidth = 120; 
new dialogHeight = 48; 
 
new fontWidth = 8; 
new fontHeight = 16; 
 
new gz= 0; 
 
public Init( ... ) 
{ 
	SheetReference( "alpha02.png", 1 ); 
} 
 
public Close() 
{ 
	SheetReference( "alpha02.png", -1 ); 
} 
 
main() 
{ 
	ConsoleOutput("dialogLine: %d", gz ); 
} 
 
DialogCharacter(c, achar, qx, qy, qz ) 
{ 
	new sprite{20}; 
	new w,h; 
 
	StringFormat(sprite, _, "alpha02.png:%d", achar); 
	SheetSpriteDimension(sprite, w, h); 
	if ( !w ) 
	{ 
		StringFormat(sprite, _, "alpha02.png:%d", '?'); 
		SheetSpriteDimension(sprite, w, h); 
	} 
	dialogText[c].x = qx; 
	dialogText[c].y = qy; 
	dialogText[c].obj = ObjectCreate(sprite, SPRITE, qx, qy, qz, 0, 0); 
	return w; 
 
} 
 
 
//¶ - paragraph 
//❶ 
//❷ 
 
public dialogbox(line, x, y, z, image{64} ) 
{ 
	new dialog{256}; 
	new tx = x; 
	new ty = y; 
	new nx = x; 
	new ny = y;	 
	new n = 0; 
	new on = 0; 
	new c = 0; 
	new space = -1; 
 
	 
	dialogLine = line;

	SheetSpriteDimension("alpha02.png:32", fontWidth, fontHeight);
 
	DialogGetString(dialogLine, dialog); 
 
	if ( ty < 0 ) 
		ty += ConfigGetNumber("screen.height"); 
	if ( tx < 0 ) 
		tx += ConfigGetNumber("screen.width"); 
 
	nx = tx; 
	ny = ty; 
 
	while ( dialog{n} && n < 256 ) // Never use strlen in a for or while loop 
	{ 
		if ( dialog{n} == 32 ) 
		{ 
			space = n; 
			nx += fontWidth; 
		} 
		else if ( dialog{n} == '\n' ) 
		{ 
			dialog{n} = '\n'; 
			space = 0; 
			c = 0; 
			ny += fontHeight; 
			nx = tx; 
		} 
		else if ( dialog{n} == '|' ) 
		{ 
			//Add Answer 
		} 
 
 
		if ( c++ >= DIALOGWIDTH ) 
		{ 
			if ( n - space > 6 ) 
			{ 
				DialogCharacter(n+on, '-', nx, ny, _:z + 10); 
				on++; 
			} 
			else if ( space > 0 ) 
			{ 
				ny += fontHeight; 
				nx = tx; 
				space = 0; 
				c = 0 
			} 
		} 
		if ( dialog{n} > 32 ) 
			nx += DialogCharacter(n+on, dialog{n}, nx, ny, _:z + 10); 
		n++; 
	} 
 
	if ( strlen(image) ) 
	{ 
		dialogBackground = ObjectCreate(image, SPRITE, tx, ty, z-1, dialogWidth, dialogHeight, WHITE, _); 
	} 
	else 
	{ 
		dialogBackground = ObjectCreate("", RECTANGLE, tx, ty, z-1, dialogWidth, dialogHeight); 
		ObjectEffect(dialogBackground, 0x00000077,_,_,_,_, STYLE_VGRADIENT,0x00000022); 
	} 
 
 
 
} 
