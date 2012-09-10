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

#include <core>

enum SwitchEvent {
	active,
	entity[32],
	function[24]
}

forward public AddSwitch();
forward public SwitchPressed();
forward public SwitchRelease();


new switches = 0;
new switch_pressed = 0;
new events[2][SwitchEvent] = {{0, "dl_r2_d1", "CloseDoor"},{0, "dl_r2_d1", "OpenDoor"}};


DungeonMapInit()
{
	switches = 0;
	EntityGetSetting("on-event", events[1][function] );
	EntityGetSetting("off-event", events[0][function] );

	EntityGetSetting("on-entity", events[1][entity] );
	EntityGetSetting("off-entity", events[0][entity] );

	if ( events[0][function][0] && events[0][entity][0] )
		events[0][active] = true;
	if ( events[1][function][0] && events[1][entity][0] )
		events[1][active] = true;
	MapInit();
}

/* Switches */
public AddSwitch()
{
	switches++;
}

public SwitchPressed()
{
	switch_pressed++;
	if ( switch_pressed == switches)
	{
		if ( events[1][active] )
			EntityPublicFunction(events[1][entity], events[1][function]);
	}
}

public SwitchRelease()
{
	if ( switch_pressed == switches )
	{
		if ( events[0][active] )
			EntityPublicFunction(events[0][entity], events[0][function]);
	}
	switch_pressed--;

}

#if !defined INITFUNCTION
#define INITFUNCTION 1
public Init( ... )
{
	DungeonMapInit()
}
#endif
#include <map_default>