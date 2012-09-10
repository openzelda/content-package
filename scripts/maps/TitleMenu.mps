#include <default>
#include <string>
#include <graphics>
#include <entities>
#include <network>
#include <player>

forward public KeyboardInput( unicode )
forward public ReceivedData( size, data[] )
forward public MenuPush( dir );
forward public submitted();

new list[8][48];

new error[42] = "";
new message[11] = "User";
new active = 0;
new pick = 0;
	
public Init(...)
{
	list[0] = "Downloading server list";
	TextSprites(1,"");
	KeyboardWatch(1);
	OnlineData("ReceivedData", "mokoi.nfshost.com/servers/");
	EntityPublicFunction("main", "SetDay", "n", 0);

}

public ReceivedData( size, data[] )
{
	new s = 0;
	new c = 0;
	new i =0;
	while( c < size )
	{
		if ( data[c] == '\n' )
		{
			strmid( list[i], data, s, c, 47);
			s = c+1;
			i++;
		}

		if ( i == 8 )
			c = size;
		c++;
	}
	list[7] = "---End---";
	active = 1;
}

public KeyboardInput( unicode )
{
	new len = strlen(message);
	if ( len + 1 < sizeof(message) )
	{
		if ( unicode == 8 || unicode == 127 )
		{
			len--;
			message[len] = 0;
		}
		else if ( unicode >= 32 )
		{
			message[len] = unicode;
			message[len+1] = 0;
			len++;
		}
		
	}
}

public Close()
{
	KeyboardWatch(0);
	TextSprites(0,"");
}

main()
{
	if ( 0 <= pick <= 6 ) 
	{
		GraphicsDraw(list[pick], TEXT, 32, 224, 6, 0, 0, 0x00FFFFFF);
		if ( list[pick+1][0] )
			GraphicsDraw(list[pick+1], TEXT, 32, 256, 6, 0, 0);
	}
	if ( message[0] )
		GraphicsDraw( message, TEXT, 144, 128, 6, 0, 0 );
	if ( error[0] )
		GraphicsDraw( error, TEXT, 32, 352, 6, 0, 0, 0xFF0000FF );
}

public MenuPush( dir )
{
	if ( !active )
		return;
	pick += dir;

	if ( 0 <= pick <= 7 ) 
	{
		if ( !list[pick][0] )
			pick = 0;
	}
	else
	{
		pick = 0;
	}

}

public submitted()
{
	if ( !active )
		return;
	PlayerSetName(0, message);
	if ( 0 <= pick <= 7 ) 
	{
		ConfigSetString("server.ip", list[pick]);
		if ( NetworkConnect(message,"","") )
		{
			if ( EntityCreate("NetTest", "NetMessage", 6000, 6000, 6000, CURRENT_MAP) )
				SectionSet("world",3,5);
			else
				error = "Connection Error2";
		}
		else
		{
			error = "Connection Error";
		}
		
	}
}
