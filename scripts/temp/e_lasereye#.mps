/* This file is Public Domain */
/************************************************************************
* e_lasereye# Entity Script
* 
* Author: Satanman
* Date:   22 July 2002
*
* Desc:   A cool eye that lasers your ass whenever you cross it's 
*		  Line of vision
*
* Usage:  Place in the Landscape Designer.
*
* Sprites: level7_Dungeon.spt
*         
*         
***********************************************************************/
#include <foreign/journey>
#include <animation>
#include <float>
new eyeAnim[20];	// String to store the Identifier of the eye animation
new width;		    // Used to store the width and height of the eye
new height;
new xoffset = 0;
new yoffset = 0;
new param;			// Will hold the parameter passed to this script
new x;
new y;
new playerangle;
new Animate = false;
new float: timer = 0.00;
new float: subtimer = 0.00;

//----------------------------------------
// Name: main()
//----------------------------------------
main()
{
	if (FirstRun())
	{
		// Get the parameter passed to this script from the sprite code
		param = GetParam("this");
				
		// Create the eye Animation
		CreateAnim(1, eyeAnim);
		
		// Add Frames to Animation depending on what the parameter is
		if ( param == 'n' )       // North
		{
			SetDirection("this", north);
			AddAnimframe(eyeAnim, 0, 0, "e_lasereyena");
			AddAnimframe(eyeAnim, 0, 0, "e_lasereyen");
		}
		else if ( param == 'e' )  // East
		{
			SetDirection("this", east);
			AddAnimframe(eyeAnim, 0, 0, "e_lasereyeea");
			AddAnimframe(eyeAnim, 0, 0, "e_lasereyee");
		}
		else if ( param == 's' )  // South
		{
			SetDirection("this", south);
			AddAnimframe(eyeAnim, 0, 0, "e_lasereyesa");
			AddAnimframe(eyeAnim, 0, 0, "e_lasereyes");
		}
		else if ( param == 'w' )  // West
		{
			SetDirection("this", west);
			AddAnimframe(eyeAnim, 0, 0, "e_lasereyewa");
			AddAnimframe(eyeAnim, 0, 0, "e_lasereyew");
		}
		
		// Set the active distance for this entity
		SetActiveDist("this", 190);
		
		// Set this entity's basic type
		SetType("this", enemyType);
		
		// Record the width and height of the main sprite for later use
		width  = GetAnimWidth(eyeAnim);
		height = GetAnimHeight(eyeAnim);
		x = GetX("this");
		y = GetY("this");
	}
	if (GetPauseLevel() == 0)
	{
			
		// Create a collsion rectangle around the eye - no particular reason, though
		SetCollisionRect("this", 0, false, x, y, x + width, y + height);
		
		if (isActive("this"))
		{
			playerangle = CalculateAngle(x,y,GetX("player1"),GetY("player1"));
			if (!Animate)
				lase(playerangle);
			
		}
	}
	if (!Animate)
	{
		if (GetAnimCount(eyeAnim) == 1)
			SetAnimCount(eyeAnim, 0);
		// Draw the eye animation without affecting the animation counter
		DrawAnimNoInc(eyeAnim, x, y, 999999);
	} else {
		if (GetAnimCount(eyeAnim) == 0)
			SetAnimCount(eyeAnim, 1);
		// Draw the eye animation without affecting the animation counter
		DrawAnimNoInc(eyeAnim, x, y, 999999);
		if (GetPauseLevel() == 0)
			shoot_laser();
	}
}

//----------------------------------------
// Name: lase()
//----------------------------------------
lase(angle)
{
	if (param == 's')
	{
		if (angle <= 100 && angle >= 80 )
			shoot_laser();
		else
			Animate = false;
	} else if (param == 'w')
	{
		if (angle <= 190 && angle >= 170 )
			shoot_laser();
		else
			Animate = false;
	} else if (param == 'n')
	{
		if (angle <= 280 && angle >= 260 )
			shoot_laser();
		else
			Animate = false;
	} else if (param == 'e')
	{
		if (angle <= 10 || angle >= 350 )
			shoot_laser();
		else
			Animate = false;
	}
}

//----------------------------------------
// Name: shoot_laser()
//----------------------------------------
shoot_laser()
{
	if (timer <= 2.00)
	{
		if (timer >= 0.50)
		{
			if ( subtimer >= 0.09 )
			{
				if (param == 'n')
					CreateEntity("e_laser1", x, y + height, "_laser");
				else if (param == 'e')
					CreateEntity("e_laser1", x - width / 2, y + height / 2, "_laser");
				else if (param == 's')
					CreateEntity("e_laser1", x, y - height, "_laser");
				else if (param == 'w')
					CreateEntity("e_laser1", x + width, y + height / 2, "_laser");
				subtimer = 0.00;
			}
		}
//		else
//		{
			subtimer += GetTimeDelta();
//		}
	Animate = true;	
	} else if (timer > 2.50)
	{
		timer = 0.00;
		Animate = false;
	}
	timer += GetTimeDelta();
}