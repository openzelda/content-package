/*********************************************** 
 * Copyright © Luke Salisbury 
 * 
 * You are free to share, to copy, distribute and transmit this work 
 * You are free to adapt this work 
 * Under the following conditions: 
 *  You must attribute the work in the manner specified by the author or licensor (but 
 *    not in any way that suggests that they endorse you or your use of the work).  
 *  You may not use this work for commercial purposes. 
 * Full terms of use: http://creativecommons.org/licenses/by-nc/3.0/ 
 * Changes: 
 *     2010/01/11 [luke]: new file. 
 ***********************************************/ 
 
/* 
"You found a Green Rupee, this is only worth 1 rupee" 
"You found a Blue Rupee, this is worth only 5 rupees" 
"You found a Red Rupee, this is worth 20 rupees!" 
"You found a Purple Rupee, this is worth a whopping 50 rupees!" 
*/
 
#include <drop_item>
 
InitDropItem(count) 
{ 
	type = ITEM_RUPEE;

	if ( count == 5 )
		sprite = "dropitems.png:rupeeblue";
	else if ( count == 20 )
		sprite = "dropitems.png:rupeered";
	else if ( count == 50 )
		sprite = "dropitems.png:rupeepurple";
	else
		sprite = "dropitems.png:rupeegreen";
 
	msgString = 0; 
} 
