#if defined _text_function_included
	#endinput
#endif
#define _text_function_included

new _text_screen[2] = [-1, -1];
new _text_font[2] = [-1, -1];

stock DrawSingleCharacter(achar, x, y, fixed:z, colour, alpha)
{
	new w,h;
	new gfx{24};
	StringFormat(gfx, _, "%s:%d", "alpha03.png", achar);
	
	SheetSpriteDimension(gfx,w,h);

	GraphicsDraw(gfx, SPRITE, x, y, z, 0, 0, NumberClamp(alpha,0,255) + colour);
	return w;
}

stock CustomText(message{}, message_length = -1, x = -1, y = -1, fixed:z = 6.00, box_width = 11, box_height = 2, alpha = 255)
{
	if ( _text_screen[0] == -1 )
	{
		MapCurrentDimension(_text_screen[0], _text_screen[1]);
		_text_screen[0] /= 2;
		_text_screen[1] /= 2;
		_text_font[0] = 8;
		_text_font[1] = 16;
	}
	new chars = 0;
	new lines = 0;
	new j;
	new colour = 1;
	new nx = x;

	if ( x == -1 )
	{
		new nw = message_length == -1 ? StringLength(message) : message_length;
		nw = (nw > box_width ? box_width : nw);
		x = _text_screen[0] - (_text_font[0] * nw);
	}
	else if ( y == -2 )
	{
		new nw = message_length == -1 ? StringLength(message) : message_length;
		nw = (nw > box_width ? box_width : nw);
		x = _text_screen[0] + _text_screen[0] - (_text_font[0] * nw * 2);
	}
	if ( y == -1 )
		y = _text_screen[1] - _text_font[1]*2;
	if ( y == -2 )
		y = _text_screen[1] + _text_screen[1] - _text_font[1]*2;
	nx = x;


	while ( message{j} )
	{
		if ( chars > box_width )
		{
			nx = x;
			y += _text_font[1]*2;
			lines++;
			chars = 0;
		}
		if ( lines > box_height  )
			break;
		
		switch ( message{j} )
		{
			case 33 .. 126:
			{
				nx += DrawSingleCharacter(message{j}, nx, y, z, 0xFFFFFF00, alpha);
				chars++;
			}
			case 32:
			{
				nx += _text_font[0]*2;
				colour = 1;
				chars++;
			}
			case 1 .. 9:
				colour = message{j};
			case 10:
			{
				nx = x;
				y += _text_font[1]*2;
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
				nx += DrawSingleCharacter('?', nx, y, z, 0xFFFFFF00, alpha);
				//Unsupported UNICODE
			}
		}

		j++;
	}
}