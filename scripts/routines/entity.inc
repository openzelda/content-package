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
 *     2013/04/01 [luke]: new file.
 ***********************************************/

/* States */
#define STATE_FLIP (qDisplayDirection == 3 ? 16 : 0)
#define STATE_GRAPHIC StateGraphics[qState][qDisplayDirection]
stock StateGraphics[STATE_COUNT][4]{32};




stock SetStateGraphic( EntityState:s, parent{}, south_graphic{}, west_graphic{}, north_graphic{}, east_graphic{} )
{
	s =  EntityState:NumberClamp( _:s, _:ALIVE, _:DEAD );
	StringFormat( StateGraphics[s][0], _, "%s:%s", parent, south_graphic);
	StringFormat( StateGraphics[s][1], _, "%s:%s", parent, west_graphic);
	StringFormat( StateGraphics[s][2], _, "%s:%s", parent, north_graphic);
	StringFormat( StateGraphics[s][3], _, "%s:%s", parent, east_graphic);
}