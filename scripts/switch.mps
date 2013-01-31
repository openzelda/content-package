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
#include <open_zelda>

#define RELEASED 0
#define PRESSED 1

forward PUBLICFUNCTIONPRESSED

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
	

	CollisionSet(SELF, 0, TYPE_SWITCH, dx+8, dy+8, dw-16, dh-16);
	EntityPublicFunction(__MAP__, "AddSwitch"); // Add to map switch count.
}

public Close()
{
	CollisionSet(SELF, 0, 0);
}

PUBLICFUNCTIONPRESSED
{
	state_changed = true;
	pressed = 1;
}

main()
{
	/* Check if block is on switch or a player is standing on it */
	if ( MaskGetValue(dx+12, dy+12) == MASK_BLOCK || pressed )
	{
		state_changed = ( _state_ == _STATE:RELEASED ? true : false );
		_state_ = _STATE:PRESSED;
		pressed = 0;
	}
	else
	{
		state_changed = ( _state_ == _STATE:PRESSED ? true : false );
		_state_ = _STATE:RELEASED;
	}


	if ( state_changed )
	{
		audio = false;
		if ( events[_state_].active )
			EntityPublicFunction(events[_state_].entity, events[_state_].function);
		ObjectReplace( obj, ( _state_ == _STATE:PRESSED ? "switch01.png:2" : "switch01.png:1"), SPRITE );
		SoundPlayOnce( audio, ( _state_ == _STATE:PRESSED ? "switch_pressed.wav" : "switch_release.wav") );
	}
	state_changed = false;

}
