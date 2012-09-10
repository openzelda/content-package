/***********************************************
 * Copyright (c) 2002-2005 Editors, lukex
 * Changes:  
 *	21/05/2004 [lukex]: New file.
 ***********************************************/
#include <animation>
#include <foreign/journey>
#include <float>

new anim[20];
new float: MoveAmt 
new MoveAngle; 
new float: moveTimer;
new x;
new y;
new temp[20];
main()
{
	if ( FirstRun() ) 
	{
		SetSpeed("this", 20);
		SetMoveAngle("this", 0);
		SetDirection("this", west);
		CreateAnim(5, anim);
		AddAnimframe(anim, 0, 0 , "o_travelator1");
		AddAnimframe(anim, 0, 0 , "o_travelator1a");
		AddAnimframe(anim, 0, 0 , "o_travelator1b");
		SetAnimLoop(anim, true);
		x = GetX("this");
		y = GetY("this");
		MoveAngle = 0; 
	}
	
	if ( isActive("this") )
	{
		DrawAnim( anim, x, y, y + 1);
		SetCollisionRect("this", 0, 0, x-1, y-1, x+17, y+17);
		SetCollisionRect("this", 1, 0, x+5, y+5, x+12, y+12);
		StartEntity(32, x+8, y+8); 
		do  
		{
			ToString(GetCurrentEntity(), temp);
			if (GetType(temp) != otherType)
			{
				if (isActive(temp) && CollideAll("this", temp) ) 
				{ 
					move_object( temp );
				}
			}
			
		}while( NextEntity() )  	
	}
}

move_object( ident[] )
{
	moveTimer += GetTimeDelta();
	if( moveTimer < 0.07 )
		return;
	else
		moveTimer = 0.00;
	
	MoveAmt = 50 * GetTimeDelta();
	new Dir = GetDirection("this");
	if (Dir == east || Dir == west)
	{
		SetX( ident, GetX(ident) - floatround( MoveAmt * Cos(MoveAngle) ));
	}
	else 
	{
		SetY( ident, GetY(ident) - floatround( MoveAmt * Sin(MoveAngle) ));
	}

}