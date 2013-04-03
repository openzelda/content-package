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

new object:axis_obj[2];
new object:button_obj[6];
new color[3] = [ 0x000000FF, 0xFFFF00FF, 0xFFFFFFFF ];

main()
{

	axis(0, axis_obj[0], 200, 300);
	axis(1, axis_obj[1], 300, 300);

	button(0, button_obj[0], 100, 100);
	button(1, button_obj[1], 100, 100);
	button(2, button_obj[2], 100, 100);
	button(3, button_obj[3], 100, 100);
	button(4, button_obj[4], 100, 100);
	button(6, button_obj[5], 100, 100);
}

public Init(...) 
{
	axis_obj[0] = ObjectCreate("", RECTANGLE, 200, 300, 5000, 16, 64, 0xFF0000FF);
	axis_obj[1] = ObjectCreate("", RECTANGLE, 300, 300, 5000, 64, 16, 0xFF0000FF);
	button_obj[0] = ObjectCreate("", CIRCLE, 16, 300, 5000, 14, 14, 0xFF0000FF);
	button_obj[1] = ObjectCreate("", CIRCLE, 32, 300, 5000, 14, 14, 0xFF0000FF);
	button_obj[2] = ObjectCreate("", CIRCLE, 48, 300, 5000, 14, 14, 0xFF0000FF);
	button_obj[3] = ObjectCreate("", CIRCLE, 64, 300, 5000, 14, 14, 0xFF0000FF);
	button_obj[4] = ObjectCreate("", CIRCLE, 80, 300, 5000, 14, 14, 0xFF0000FF);
	button_obj[5] = ObjectCreate("", CIRCLE, 96, 300, 5000, 14, 14, 0xFF0000FF);
}

public Close()
{
	ObjectDelete(axis_obj[0]);
	ObjectDelete(axis_obj[1]);
	ObjectDelete(button_obj[0]);
	ObjectDelete(button_obj[1]);
	ObjectDelete(button_obj[2]);
	ObjectDelete(button_obj[3]);
	ObjectDelete(button_obj[4]);
	ObjectDelete(button_obj[5]);
}



axis(n, obj, x, y)
{
	new a = InputAxis(n)/8;
	if ( a > 0 )
		ObjectPosition(obj, x, y-5, 3000, a, 10); 
	else if ( a < 0 )
		ObjectPosition(obj, x+a, y-5, 3000, 0-a, 10); 
	else
		ObjectPosition(obj, x-1, y-5, 3000, 1, 10); 
}


button(n, obj, x, y)
{
	new mode = InputButton(n);
	mode = NumberClamp( mode, 0, 2 );
	ObjectEffect( obj, color[mode] );
}
