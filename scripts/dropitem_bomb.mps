/***********************************************
 *
 ***********************************************/

/*
"You got a bomb! You can pick this up after you place it but be careful!"
"You got 5 bombs! You can pick a bomb up after you place it but be careful!"
"You got 10 bombs! You can pick a bomb up after you place it but be careful!"
*/
#include <drop_item>
InitDropItem(cout)
{
	type = 1;
	sprite_type = 's';
	sprite = "dropitems.png:bomb";
	numstring = 0;
}

