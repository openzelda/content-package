#include <default>
#include <entities>
#include <graphics>
native NetworkConnect( name[] );

public Init( ... )
{
	EntityPublicFunction("main", "SetDay", "n", 0);
	ConfigSetString( "server.ip", "127.0.0.1" );
	NetworkConnect( "SYNC" );
	TextSprites(0,"");
}


main()
{
	
}
