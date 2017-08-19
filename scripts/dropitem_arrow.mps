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
/* 
"You got one, stinking arrow!"
"You got 5 arrows! but, do you have a bow?"
"You got 10 arrows! find a bow and let 'em rip!"
"You got 20 arrows! who're you gonna shoot?"
"You got 50 arrows! thats a LOT, are you sure your quivers big enough?"
*/
#include <drop_item>

InitDropItem(count) 
{
	type =  ITEM_ARROW;
	sprite = "dropitems.png:arrow";
	msgString = LANG_ITEM_ARROW1;

} 
