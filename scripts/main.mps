/*********************************************** 
 * Copyright © Luke Salisbury 
 * 
 * You are free to share, to copy, distribute and transmit this work 
 * You are free to adapt this work 
 * Under the following conditions: 
 *  You must attribute the work in the manner specified by the author 
 *  or licensor (but not in any way that suggests that they endorse you
 *  or your use of the work).  
 *  You may not use this work for commercial purposes. 
 * Full terms of use: http://creativecommons.org/licenses/by-nc/3.0/ 
 * Changes: 
 *     2010/01/11 [luke]: new file. 
 ***********************************************/ 
 
 
/* Main Entity has 3 more Public Functions */ 
forward public save(); 
forward public load(); 

forward public SetPlayer(n); 
forward public GetPlayer(); 

public controller = 1; 
public debug_game = debug; 


public Init( ... ) 
{ 
	GameState(GS_ALL); 

	EntityCreate("text", "TextFunctions", 0, 0, 0, GLOBAL_MAP); 
	//EntityCreate("dialog_box", "DialogFunctions", 0, 0, 0, GLOBAL_MAP); 
 
	if (debug_game) 
	{ 
		//EntityCreate("tester", "tester", 0, 0, 0, GLOBAL_MAP); 
		//EntityCreate("gun", "", 0, 0, 0, GLOBAL_MAP); 
	} 
 
	 
} 
 
public Close() 
{

}

main() 
{ 
/*
	new Fixed:q;
	new Fixed:w;
	new str{4};

	for (new i = 0; i < 360; i +=15)
	{
		w = fsin(i,degrees)*100;
		q =fcos(i,degrees)*100;
		GraphicsDraw("", LINE, 320,240,6.0, 320+fround(w), 240+fround(q) , 0x00FF00FF)

		StringFormat(str,_, "%d", i);
		GraphicsDraw(str, TEXT, 320+fround(w), 240+fround(q), 6.1, 0, 0, 0xFF0000FF )

	}
*/

} 

public SetPlayer(n) 
{ 
	controller = n; 
} 
public GetPlayer() 
{ 
	return controller; 
} 
 
 
