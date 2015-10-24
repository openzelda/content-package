/*********************************************** 
 * Copyright © Luke Salisbury 
 * 
 * You are free to share, to copy, distribute and transmit this work 
 * You are free to adapt this work 
 * Under the following conditions: 
 *  You must attribute the work in the manner specified by the author or licensor (but 
 *   not in any way that suggests that they endorse you or your use of the work).  
 *  You may not use this work for commercial purposes. 
 * Full terms of use: http://creativecommons.org/licenses/by-nc/3.0/ 
 * Changes: 
 *     2010/01/11 [luke]: new file. 
 ***********************************************/ 
#define RELEASED 0
#define PRESSED 1
 
forward PUBLIC_EVENT_PRESSED
 
new audio = false;
new state_changed = false;
new pressed = false;
 
new events[2][SwitchEvent]; 
 
 
public Init(...) 
{ 
	SetupEntity( EntityState:RELEASED, TYPE_SWITCH, qObject, 32, 32 ); 
 
	EntityGetSetting("on-event", events[1].function ); 
	events[1].entity = entity:EntityGetHash("on-entity"); 
	events[1].active = ( StringLength(events[1].function) && events[1].entity ); 
 
	EntityGetSetting("off-event", events[0].function ); 
	events[0].entity = entity:EntityGetHash("off-entity"); 
	events[0].active = ( StringLength(events[0].function) && events[0].entity ); 
	 
 
	CollisionSet(SELF, 0, TYPE_SWITCH, qDisplayArea.x+8, qDisplayArea.y+8, qDisplayArea.w-16, qDisplayArea.h-16); 
	EntityPublicFunction(MAP_ENTITY, "AddSwitch"); // Add to map switch count. 
 
} 
 
public Close() 
{ 
	CollisionSet(SELF, 0, 0); 
} 
 
PUBLIC_EVENT_PRESSED 
{ 
	state_changed = true; 
	pressed = true; 
} 
 
main() 
{ 
	/* Check if block is on switch or a player is standing on it */ 
	if ( MaskGetValue(qDisplayArea.x+12, qDisplayArea.y+12) == MASK_BLOCK || pressed ) 
	{ 
		state_changed = ( qState == EntityState:RELEASED ? true : false ); 
		qState = EntityState:PRESSED; 
		pressed = false; 
	} 
	else 
	{ 
		state_changed = ( qState == EntityState:PRESSED ? true : false ); 
		qState = EntityState:RELEASED; 
	} 
 
	if ( state_changed ) 
	{ 
		audio = false; 
		if ( events[qState].active ) 
		{ 
			EntityPublicFunction(events[qState].entity, events[qState].function); 
		} 
		ObjectReplace( qObject, ( qState == EntityState:PRESSED ? "switch01.png:2" : "switch01.png:1"), SPRITE ); 
		SoundPlayOnce( audio, ( qState == EntityState:PRESSED ? "switch_pressed.wav" : "switch_released.wav") ); 
	} 
	state_changed = false; 
 
} 
