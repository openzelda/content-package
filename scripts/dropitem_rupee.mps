/***********************************************
 *
 ***********************************************/

/*
"You found a Green Rupee, this is only worth 1 rupee"
"You found a Blue Rupee, this is worth only 5 rupees"
"You found a Red Rupee, this is worth 20 rupees!"
"You found a Purple Rupee, this is worth a whopping 50 rupees!"
*/
#include <drop_item>
InitDropItem(cout)
{
	type = 1;
	sprite_type = 's';
	sprite = "dropitems.png:bomb";
	numstring = 0;
}
