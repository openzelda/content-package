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
#include <mokoi_quest>

#define RELEASED 0
#define PRESSED 1

enum SwitchEvent {
	active,
	entity[32],
	function[24]
}

forward public Pressed(attacker[]);

new obj =-1;
new audio = false;
new state_changed = false;
new pressed = false;

new events[2][SwitchEvent] = {{0, "", ""},{0, "", ""}};

public Init(...)
{

	dw = dh = 32;
	_state_ = 0
	_type_ = TYPE_SWITCH;

	obj = EntityGetNumber("object-id");

	EntityGetPosition(_x_,_y_, _z_);
	UpdateDisplayPosition();

	EntityGetSetting("on-event", events[1][function] );
	EntityGetSetting("off-event", events[0][function] );

	EntityGetSetting("on-entity", events[1][entity] );
	EntityGetSetting("off-entity", events[0][entity] );

	if ( events[0][function][0] && events[0][entity][0] )
		events[0][active] = true;
	if ( events[1][function][0] && events[1][entity][0] )
		events[1][active] = true;

	CollisionSet(SELF, 0, TYPE_SWITCH, dx+8, dy+8, dw-16, dh-16);

	EntityPublicFunction("__map__", "AddSwitch");

}

public Close()
{
	CollisionSet(SELF, 0, 0);
}

public Pressed(attacker[])
{
	state_changed = true;
	pressed = 1;
}

main()
{
	//DebugText("%s %s", events[0][entity], events[0][function]);
	//DebugText("%s %s", events[1][entity], events[1][function]);

	if ( MaskGetValue(dx+12, dy+12) == MASK_BLOCK || pressed )
	{
		state_changed = ( _state_ == RELEASED ? true : false );
		_state_ = PRESSED;
		pressed = 0;
	}
	else
	{
		state_changed = ( _state_ == PRESSED ? true : false );
		_state_ = RELEASED;
	}
	if ( state_changed )
	{
		audio = false;
		if ( events[_state_][active] )
			EntityPublicFunction(events[_state_][entity], events[_state_][function]);
		ObjectReplace(obj, ( _state_ == PRESSED ? "switch01.png:2" : "switch01.png:1"), SPRITE);
		SoundPlayOnce(audio, ( _state_ == PRESSED ? "switch_pressed.wav" : "switch_release.wav"));
	}
	state_changed = false;

}
