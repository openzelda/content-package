/***********************************************
 * Open Legends Media License
 * Copyright (c) 2002-2006 Open Legends Project, lukex
 * Changes:  
 *	12/07/2004 [lukex]: New file.
 *	22/02/2005 [lukex]: Added public function: FindBottleWith(What) 
 *	13/04/2005 [lukex]: removed the if/else stuff for param
 *	05/03/2006 [lukex]: uses i_bottle's SetBottleValue
 ***********************************************/
#include <core>
#include <foreign/journey>


const MAX_BOTTLES = 4;	
const MAX_FILLS = 6;
new image_array[6][20] = {"i_bottlee", "i_bottleg", "i_bottleb", "i_bottler", "i_bottlei", "i_bottlef"};

main()
{
	if (FirstRun())
	{
		new bottle_value = 0;
		AllocateStrings("this", 1, 100);
		new param = GetParam("this");
		bottle_value = param - 48;
		if ( bottle_value )
		{
			SetImage("this", image_array[bottle_value]);
			
			if ( FindEmptyBottle( bottle_value ) )
				SetString("this", 0, "You filled one of your bottles");
			else			
				SetString("this", 0, "You have no empty bottles");
		}
	}

}

public FindEmptyBottle(FillWith) 
{
	new temp[32]; 
	new n_string[4];
	new n 
	for ( n = 0; n < MAX_BOTTLES; n++)
	{
		temp = "i_bottle";
		ToString(n, n_string);
		strcat( temp, n_string);
		if ( isOwned(temp) )
		{
			if ( !GetValue(temp, 0) )
			{
				CallFunction(temp, false, "SetBottleValue", "n", FillWith);
				return true;
			}
		}
	}

	PlaySound("_error.wav", 240);
	return false;
}

public FindBottleWith(What, Empty) 
{
	new temp[32]; 
	new n_string[4];
	new n 
	for ( n = 0; n < MAX_BOTTLES; n++)
	{
		temp = "i_bottle";
		ToString(n, n_string);
		strcat( temp, n_string);
		if ( isOwned(temp) )
		{
			if ( GetValue(temp, 0) == What)
			{
				if ( Empty )
				{
					CallFunction(temp, false, "SetBottleValue", "n", 0);	
				}
				return n;
			}
		}
	}
	return -1;
}
