#include <string>
#include <graphics>
#include <entities>
#include <network>
#include <player>

forward public ReceivedData( size, data[] )

new online_version[64];

new music[64] = ""; 
new transition[20] = "";

new section_name[64] ="";
new section_grid = 0;

MapInit()
{
	EntityGetSetting("section", section_name); 
	section_grid = EntityGetNumber("map"); 

	EntityGetSetting("music", music, SELF); 
	AudioVolume(MUSIC, 64);
	if ( music[0] )
		AudioPlayMusic(music);
}
	
public Init(...)
{
	online_version = "Checking version";
	TextSprites(1,"alpha02.png");
	//OnlineData("ReceivedData", "openzelda.net/latest/20120401");
	EntityPublicFunction("main", "SetDay", "n", 0);
	MapInit();

}

public ReceivedData( size, data[] )
{
	strformat(online_version, _, _, "%s", data);
}

public Close()
{
	TextSprites(0,"");
}

StartGame(n)
{
	EntityPublicFunction("main", "SetPlayer", "n", n);

	new x = (section_grid % 64);
	new y = (section_grid / 64);

	TransitionPlayer( "", "", 0, section_name, x,y);
}

main()
{
	GraphicsDraw(online_version, TEXT, 160, 356, 6, 0, 0, 0xFFFFFFFF);

	if ( InputButton(16,1) )
		StartGame(1);
	if ( InputButton(16,2) )
		StartGame(2);

}


