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

#include <core>
#define SwitchEvent[.active, .entity, .function{24}]

forward public AddSwitch();
forward public SwitchPressed();
forward public SwitchRelease();


new switches = 0;
new switch_pressed = 0;

new on_events[SwitchEvent];
new off_events[SwitchEvent];

DungeonMapInit()
{
	new entity_name{32} = "";
	
	switches = 0;

	EntityGetSetting("on-event", on_events.function );
	EntityGetSetting("on-entity", entity_name );
	on_events.entity = EntityHash(entity_name);

	entity_name = "";

	EntityGetSetting("off-event", off_events.function );
	EntityGetSetting("off-entity", entity_name );
	off_events.entity = EntityHash(entity_name); 



	if ( off_events.function[0] && off_events.entity )
		off_events[active] = true;
	if ( on_events.function[0] && on_events.entity )
		on_events[active] = true;
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
		if ( on_events.active )
			EntityPublicFunction(on_events.entity, on_events.function);
	}
}

public SwitchRelease()
{
	if ( switch_pressed == switches )
	{
		if ( off_events[active] )
			EntityPublicFunction(off_events.entity., off_events.function);
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
