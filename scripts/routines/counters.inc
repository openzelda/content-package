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
/* Counters */
#define CounterLocation[.name{20}, .screen_x, .screen_y]

new counters[3][CounterLocation] = { 
	{"p_rupees", 72, 36}, 
	{"p_arrows", 136, 36}, 
	{"p_bombs", 200, 36}
}


CreateCounters()
{
	for ( new q = 0; q < 3; q++ )
	{
		EntityCreate("counter", counters[q].name, 1,1,1, GLOBAL_MAP);
	}
}
