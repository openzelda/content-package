/***********************************************
 *
 ***********************************************/

/*
"You got a pot of magic, this will replenish a small amount of your magic"
"You got a big pot of magic, this will replenish a large amount of your magic"
*/
#include <drop_item>
InitDropItem(cout)
{
	type = 1;
	sprite_type = 's';
	sprite = "dropitems.png:magic1";
	numstring = 0;
}