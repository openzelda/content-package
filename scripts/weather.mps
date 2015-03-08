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
 
forward public SetDay(able); 
 
new DayNight[24] = [ 
	0x4E5CAFFF,\ 
	0x5964A9FF,\ 
	0x606BAEFF,\ 
	0x6A76BAFF,\ 
	0x6E76BAFF,\ 
	0x7883C6FF,\ 
	0x98A3E8FF,\ 
	0xB6BEEEFF,\ 
	0xD6DAF3FF,\ 
	0xF4F5FBFF,\ 
	0xFFFFFFFF,\ 
	0xFFFFFFFF,\ 
	0xF7F8ECFF,\ 
	0xF7F8E7FF,\ 
	0xEFF2E1FF,\ 
	0xEDEDD2FF,\ 
	0xE8ECC8FF,\ 
	0xE8E1BEFF,\ 
	0xE4C47EFF,\ 
	0xE5A67EFF,\ 
	0xE59E96FF,\ 
	0x7D7CC8FF,\ 
	0x766FD8FF,\ 
	0x645CBEFF\ 
]; 
public hour = 12; 
public minute = 0; 
public Fixed:seconds = 0.0; 
new daynight = 0; 
new Fixed:timemod = 500.00; 
 
public Init( ... ) 
{ 
	SetDay(0); 
} 
 
public Close() 
{ 
 
} 
 
main() 
{ 
	HandleDayNight(); 
} 
 
 
HandleDayNight() 
{ 
	seconds += GameFrameSeconds() * timemod; 
	if ( seconds >= 60.0 ) 
	{ 
		minute++; 
		seconds -= 60.0; 
	} 
	if ( minute >= 60 ) 
	{ 
		hour++; 
		minute -= 60; 
	} 
	if ( hour > 23 )  
		hour -= 24; 
 
	if ( daynight ) 
	{ 
		// TODO: Smooth out changes 
		new str[6]; 
		StringFormat(str, _, "%d:%02d", hour, minute); 
		//CustomText(str, -1, -2, 6000, 100, 1, 255); 
		LayerColour(0, DayNight[hour]); 
		LayerColour(1, DayNight[hour]); 
		LayerColour(2, DayNight[hour]); 
		LayerColour(3, DayNight[hour]); 
		LayerColour(4, DayNight[hour]); 
		LayerColour(5, DayNight[hour]); 
	} 
} 
 
public SetDay(able) 
{ 
	daynight = able; 
	if ( !daynight ) 
	{ 
		LayerColour(0, 0xFFFFFFFF); 
		LayerColour(1, 0xFFFFFFFF); 
		LayerColour(2, 0xFFFFFFFF); 
		LayerColour(3, 0xFFFFFFFF); 
		LayerColour(4, 0xFFFFFFFF); 
		LayerColour(5, 0xFFFFFFFF); 
	} 
} 
 
 
