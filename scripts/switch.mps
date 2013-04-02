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


#define RELEASED 0
#define PRESSED 1

forward PUBLIC_EVENT_PRESSED

new obj = -1;
new audio = false;
new state_changed = false;
new pressed = false;

new events[2][SwitchEvent];

public Init(...)
{
	SetupEntity( _STATE:RELEASED, TYPE_SWITCH, obj, 32, 32 );

	EntityGetSetting("on-event", events[1].function );
	events[1].entity = EntityGetSettingHash("on-entity");
	events[1].active = ( StringLength(events[1].function) && events[1].entity );

	EntityGetSetting("off-event", events[0].function );
	events[0].entity = EntityGetSettingHash("off-entity");
	events[0].active = ( StringLength(events[0].function) && events[0].entity );
	

	CollisionSet(SELF, 0, TYPE_SWITCH, mqDisplayArea.x+8, mqDisplayArea.y+8, mqDisplayArea.w-16, mqDisplayArea.h-16);
	EntityPublicFunction(__MAP__, "AddSwitch"); // Add to map switch count.
}

public Close()
{
	CollisionSet(SELF, 0, 0);
}

PUBLIC_EVENT_PRESSED
{
	state_changed = true;
	pressed = 1;
}

main()
{
	/* Check if block is on switch or a player is standing on it */
	if ( MaskGetValue(mqDisplayArea.x+12, mqDisplayArea.y+12) == MASK_BLOCK || pressed )
	{
		state_changed = ( mqState == _STATE:RELEASED ? true : false );
		mqState = _STATE:PRESSED;
		pressed = 0;
	}
	else
	{
		state_changed = ( mqState == _STATE:PRESSED ? true : false );
		mqState = _STATE:RELEASED;
	}


	if ( state_changed )
	{
		audio = false;
		if ( events[mqState].active )
			EntityPublicFunction(events[mqState].entity, events[mqState].function);
		ObjectReplace( obj, ( mqState == _STATE:PRESSED ? "switch01.png:2" : "switch01.png:1"), SPRITE );
		SoundPlayOnce( audio, ( mqState == _STATE:PRESSED ? "switch_pressed.wav" : "switch_release.wav") );
	}
	state_changed = false;

}
