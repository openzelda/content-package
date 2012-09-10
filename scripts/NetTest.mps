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
#include <network>
#include <time>
enum message {
	countdown,
	text[128]
}

forward public KeyboardInput( unicode );
forward public NetMessage( player, array[], array_size );

new active = 0;
new names[32][10];
new messages[12][message];
new string[128] = {0,...};

Add( name[], msg[] )
{
	new m = 0;
	while ( m < 12 )
	{
		if ( !messages[m][countdown] )
			break;
		m++;
	}

	if ( m == 12 )
	{
		messages[0] = messages[1];
		messages[1] = messages[2];
		messages[2] = messages[3];
		messages[3] = messages[4];
		messages[4] = messages[5];
		messages[5] = messages[6];
		messages[6] = messages[7];
		messages[7] = messages[8];
		messages[8] = messages[9];
		messages[9] = messages[10];
		messages[10] = messages[11];
		m = 11;
	}

	messages[m][countdown] = 10000;
	new hour = 0, minute = 0;
	Time(hour, minute);
	strformat(messages[m][text], _, true, "[%02d:%02d] %s: %s", hour, minute, name, msg );
}


public NetMessage(player, array[], array_size)
{
	if ( !names[player][0] )
		NetworkPlayerName(player, names[player]);

	Add( names[player], array );
}

public KeyboardInput( unicode )
{
	new len = strlen(string);
	if ( len + 1 < sizeof(string) )
	{
		if ( unicode == 8 || unicode == 127 )
		{
			len--;
			string[len] = 0;
		}
		if ( unicode >= 32 )
		{
			string[len] = unicode;
			string[len+1] = 0;
			len++;
		}
	}
	if (unicode == 13 && len)
	{
		Add( "@SELF", string );
		NetworkMessage(1, 0, string, len+1);
		string[0] = 0;
	}
}

public Init(...)
{
	TextSprites(0,"");
}

main()
{
	if ( InputButton(6) == 1 )
	{
		active = !active;
		KeyboardWatch(active);
		GameState(active+1);
	}
	GraphicsDraw(string, TEXT, 10, 372, 6, 0,0);
	GraphicsDraw("4", RECTANGLE, 8, 368, 6, 200, 2, 0xFFFFFFAA );

	new m = 11;
	new p = 0;
	while ( m >= 0 )
	{
		if ( messages[m][countdown] > 0 )
		{
			GraphicsDraw(messages[m][text], TEXT, 10, 358 - (p*10), 6, 0,0);
			messages[m][countdown] -= GameFrame();
			if ( messages[m][countdown] <= 0 )
			{
				strformat(messages[m][text], _, true, "");
				messages[m][countdown] = 0;
			}
			p++;
		}
		m--;
	}
}
