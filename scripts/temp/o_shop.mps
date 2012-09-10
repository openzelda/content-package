/***********************************************
 * Copyright (c) 2002-2005 Editors, lukex
 * Changes:  
 *	21/09/2002 [lukex]: New file.
 *	17/12/2004 [lukex]: Added the ablity to name item.
 ***********************************************/

#include <foreign/journey>
#include <core>
#include <counter>


new SubEntity[20];
new String1[20];
new ItemImage[32];
new PrintValue[20];
new message[1024];

main()
{

	if (FirstRun())
	{
		AllocateStrings("this", 2, 900);
		SetActiveInGroups("this", false);
		SetType("this", otherType);
		SetActiveDist("this", 320);
		GetString("this", 0, message);
		GetString("this", 1, SubEntity);
		if (strlen(message) <= 1)
			SetString("this", 0, "You just brought something");
	}

	new value = GetValue("this", 0);

	if ( isActive("this") && isVisible("this") && value > 0 )
 	{
		new x = GetX("this");
   		new y = GetY("this");
 		GetItem("this", String1); 
 		ToString(value, PrintValue);
 		new priceX = WorldToScreenX(x);
		new priceY = WorldToScreenY(y);
		SetCollisionRect("this", 0, true, x , y, x + 16, y + 16);
		GetImage("this", ItemImage);
		PutSprite(ItemImage, x, y, y + 6);
		if ( strlen(PrintValue) == 4 )
			priceX = priceX - 8;
		else if ( strlen(PrintValue) == 3 )
			priceX = priceX - 4;
		else if ( strlen(PrintValue) == 2 )
			priceX = priceX + 4;
		else if ( strlen(PrintValue) == 1 )
			priceX = priceX + 8;	 
		DrawBitmapText(PrintValue, priceX, priceY );
		if ( QKey() && GetPauseLevel() == 0) 
		{
			if ( Collide("this", "player1") ) 
			{
				SetTextBoxColor(255, 255, 255, 255);
				if ( GetCounterValue("rupees") >= value ) 
				{
					GetItem("this", String1); 
					GetString("this", 1, SubEntity);
					   if ( strlen(SubEntity) > 2 )
					   {
					      CreateEntityWithID(String1, GetX("player1"), GetY("player1"), SubEntity);
					      SetOwnedFlag(SubEntity, true);
					   }
					   else
					   {
					      CreateEntity(String1, GetX("player1"), GetY("player1"), SubEntity);
					      SetOwnedFlag(SubEntity, true);
					   }

					IncCounterValue("rupees", -value);
					GetString("this", 0, message);
					InitTextBox(message, 200, true);
					SetActiveFlag("this", false);
					ClearCollisionRect("this", 0);
				}
				else 
				{
					InitTextBox("You don't have enough rupees", 200, true);
				}
			}
		}
    }
}


