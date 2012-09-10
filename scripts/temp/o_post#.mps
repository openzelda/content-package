/* This file is Public Domain */
/***********************************************
 * o_post# Entity Script
 * 
 * Author: Satanman
 * Date:   30th July 2002
 *
 * Desc:   hammerable things
 *
 * Usage:  hit 'em!!!
 *
 * Uses _itemlib Library
 *
 * Sprites: hammer.spt
 *         
 ***********************************************/
#include <foreign/journey>
#include <float>
#include <animation>
#include <core>

//   Global Data
new mainSpr[20];
new underSpr[20];
new width;    // The Width and Height of the main sprite
new height;
new param;


//----------------------------------------
// Name: main()
//----------------------------------------
main()
{
	if (FirstRun())
	{
		Respawn("this", 120);
		param = GetParam("this");
		
		if (param == 'w') //wooden post
		{
			mainSpr = "o_postw";
			underSpr = "o_postw2";
		} else if (param == 'd') //dark world post
		{
			mainSpr = "o_postd";
			underSpr = "o_postd2";
		} else if (param == 'h') //head dude post
		{
			CreateAnim(6, mainSpr);
			AddAnimframe(mainSpr, 0, 0, "o_posth");
			AddAnimframe(mainSpr, 0, 0, "o_posth2");
			AddAnimframe(mainSpr, 0, 0, "o_posth3");
			AddAnimframe(mainSpr, 0, 0, "o_posth2");
			underSpr = "o_posth4";
		}
		// Set this entity's basic type
		SetType("this", otherType);
		// Record the width and height of the main sprite for later use
		if (param == 'h')
		{
			width  = GetAnimWidth(mainSpr);
			height = GetAnimHeight(mainSpr);
		}else{
			width  = GetWidth(mainSpr);
			height = GetHeight(mainSpr);
		}
	}
    if (isActive("this"))
	{
		new x = GetX("this");
		new y = GetY("this");

		if (isVisible("this"))
		{ 
			// Is this entity has been killed ;) then draw the sprite underneath
			if (isDead("this"))
			{
				PutSprite(underSpr, GetX("this"), GetY("this"), 1);
				SetCollisionRect("this", 0, false, x, y, x + width, y + height);
			}
			else
			{
			// If it hasnt been picked up and is still active set a solid collision rect and draw the thing
				if (param == 'h')
					DrawAnim(mainSpr, x, y, 2);
				else
					PutSprite(mainSpr, x, y, 2 );
				SetCollisionRect("this", 0, true, x, y, x + width, y + height);
			}
		}
	}
}

//----------------------------------------
// Name: HitByWeapon(wtype[], damage)
//----------------------------------------
public HitByWeapon(wtype[], damage)
{
	// We should see what kind of weapon is hitting this entity
	// from the wtype param and make a decision based on that.
	if (!strcmp("hammer", wtype))
		SetDeadFlag("this", true);
}