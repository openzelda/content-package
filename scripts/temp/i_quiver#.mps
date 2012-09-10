/***********************************************
 * Open Legends Media License
 * Copyright (c) 2003-2005 Open Legends Project
 * Changes:  
 *	10/05/2005 [lukex]: New file.
 ***********************************************/
#include <foreign/journey>
#include <counter>

main()
{
	if (FirstRun())
	{
		printf("Quiver Created");
		new param = GetParam("this");
		AllocateStrings("this", 1, 100);
		SetType("this", itemType);

		if ( GetCounterMax("arrows") == -1)
			newcounter();

		if (param == '0')
		{
			SetString("this", 0,  "You now own a Quiver");
			SetCounterMax("arrows", 20);
			SetCounterTarget("arrows", 20);
		} 
		else if (param == '1')
		{
			SetString("this", 0,  "You got a larger Quiver, now you can hold 50 arrows");
			SetCounterMax("arrows", 50);
			SetCounterTarget("arrows", 50);
		} 
		else if (param == '2')
		{
			SetString("this", 0,  "You got a larger Quiver, now you can hold 100 arrows");
			SetCounterMax("arrows", 100);
			SetCounterTarget("arrows", 100);
		}
		else if (param == '3')
		{
			SetString("this", 0,  "You got a larger Quiver, now you can hold 200 arrows");
			SetCounterMax("arrows", 200);
			SetCounterTarget("arrows", 200);
		}
	}
}

newcounter()
{
	CreateCounterWithID(0, 20,  "arrows");
	CallFunction("_itemlib", false, "AddItem", "sn", "_itemarrow1", 65);  // 1 arrow
	CallFunction("_itemlib", false, "AddItem", "sn", "_itemarrow2", 20);  // 5 arrows
	CallFunction("_itemlib", false, "AddItem", "sn", "_itemarrow3", 7);   // 10 arrows
	CallFunction("_itemlib", false, "AddItem", "sn", "_itemarrow4", 1);   // 20 arrows
}