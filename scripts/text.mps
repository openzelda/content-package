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


new screen[2];
new font[2];

forward public DrawCustomText(message{}, message_length, x, y, fixed:z, box_width, box_height, alpha)
forward public DrawCharacter(achar, x, y, fixed:z, colour, alpha);


public Init( ... )
{
	MapCurrentDimension(screen[0], screen[1]);
	screen[0] /= 2;
	screen[1] /= 2;
	font[0] = 8;
	font[1] = 16;

	SheetReference("alpha01.png", 1);
	SheetReference("alpha02.png", 1);
	SheetReference("alpha03.png", 1);

}

public Close()
{
	SheetReference("alpha01.png", -1);
	SheetReference("alpha02.png", -1);
	SheetReference("alpha03.png", -1);

}

main()
{

}

public DrawCharacter(achar, x, y, fixed:z, colour, alpha)
{
	new w,h;
	new gfx{24};
	StringFormat(gfx, _, "alpha03.png:%d", achar);
	
	SheetSpriteDimension(gfx,w,h);

	GraphicsDraw(gfx, SPRITE, x, y, z, 0, 0, NumberClamp(alpha,0,255) + colour);
	return w;
}

public DrawCustomText(message{}, message_length, x, y, fixed:z, box_width, box_height, alpha)
{
	new chars = 0;
	new lines = 0;
	new j;
	new colour = 1;
	new nx = x;

	if ( x == -1 )
	{
		new nw = message_length == -1 ? StringLength(message) : message_length;
		nw = (nw > box_width ? box_width : nw);
		x = screen[0] - (font[0] * nw);
	}
	else if ( y == -2 )
	{
		new nw = message_length == -1 ? StringLength(message) : message_length;
		nw = (nw > box_width ? box_width : nw);
		x = screen[0] + screen[0] - (font[0] * nw * 2);
	}
	if ( y == -1 )
		y = screen[1] - font[1]*2;
	if ( y == -2 )
		y = screen[1] + screen[1] - font[1]*2;
	nx = x;


	while ( message{j} )
	{
		if ( chars > box_width )
		{
			nx = x;
			y += font[1]*2;
			lines++;
			chars = 0;
		}
		if ( lines > box_height  )
			break;
		
		switch ( message{j} )
		{
			case 33 .. 126:
			{
				nx += DrawCharacter(message{j}, nx, y, z, 0xFFFFFF00, alpha);
				chars++;
			}
			case 32:
			{
				nx += font[0]*2;
				colour = 1;
				chars++;
			}
			case 1 .. 9:
				colour = message{j};
			case 10:
			{
				nx = x;
				y += font[1]*2;
				colour = 1;
				chars = 0;
				lines++;
			}
			case 11 .. 31:
			{
				//
			}
			default:
			{
				nx += DrawCharacter('?', nx, y, z, 0xFFFFFF00, alpha);
				//Unsupported UNICODE
			}
		}

		j++;
	}
}

