/***********************************************
 *
 ***********************************************/
//getkey.wav

/*
"You got a small key! this can unlock many doors..."
"You got the Master key! this key can unlock special doors and chests."
*/
#include <drop_item>
InitDropItem(cout)
{
	type = 1;
	sprite_type = 's';
	sprite = "dropitems.png:key";
	numstring = 0;
}