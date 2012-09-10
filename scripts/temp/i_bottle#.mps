/***********************************************
 * Copyright (c) 2002-2005 Editors, lukex
 * Changes:  
 *	12/07/2004 [lukex]: New file.
 *	06/12/2004 [lukex]: Minor changes to stop multiable usings.
 *	05/03/2006 [lukex]: Add SetBottleValue function
 ***********************************************/

#include <foreign/journey>
#include <animation>
#include <core>
#include <counter>
#include <float>



new bottle_value;
new image_array[6][20] = {"i_bottlee", "i_bottleg", "i_bottleb", "i_bottler", "i_bottlei", "i_bottlef"};
new text_array[6][20] = {"Empty Bottle", "Magic Potion", "Blue Potion", "Red Potion", "Bee", "Fairy"};
new keyFirstPress = false;

main()
{
	if (FirstRun())
	{
		SetType("this", itemType);
		SetOwnedFlag("this", true);
		AllocateStrings("this", 2, 128);
		SetValue("this", 0, 0);
		SetActiveDist("this", -2);
		SetImage("this", image_array[0]);
		SetString("this", 1, text_array[0]);	
	}
	bottle_value = GetValue("this", 0);
}


//----------------------------------------
// Name: Init()
//----------------------------------------
public Init()
{
	keyFirstPress = true
	bottle_value = GetValue("this", 0);
}

public DrawWeapon( keyHeld )
{
	ConsoleNumber("bottle", keyHeld);
	if ( keyFirstPress )
	{
		new SubEntity[20];
		// Check if bottle has something
		if (bottle_value == 0) 
		{
			//ToDo: Should swing.
			PlaySound("_error.wav", 200);
		} 
		else if (bottle_value == 1) 
		{
			IncCounterTarget("magic", 44);
			PlaySound("p_magicincrease.wav", 240);
		} 
		else if (bottle_value == 2) 
		{
			SetHealth("player1", GetMaxHealth("player1")); 
			IncCounterTarget("magic", 44);
			PlaySound("p_magicincrease.wav", 240)
		} 
		else if (bottle_value == 3) 
		{
			SetHealth("player1", GetMaxHealth("player1"));
		}
		else if (bottle_value == 4) 
		{
			//CreatEntity
		} 
		else if (bottle_value == 5) 
		{
			CreateEntity("i_fairy", GetX("player1"), GetY("player1"), SubEntity);
		}
		SetValue("this", 0, 0);
		SetImage("this", image_array[0]);
		SetString("this", 1, text_array[0]);
		keyFirstPress = false;
	}
	CallFunction("player1", false, "Stand", "nn", GetX("player1"), GetY("player1"));
	if ( !keyHeld )
	{
		return -1;
	}
}

public SetBottleValue(value) 
{
	SetValue("this", 0, value);
	SetImage("this", image_array[value]);
	SetString("this", 1, text_array[value]);	
}