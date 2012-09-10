/***********************************************
 * Copyright (c) 2004-2006 Editors
 * Changes:  
 *	19/08/02 [lukex]: New file.
 ***********************************************/
#include <animation>
#include <foreign/journey>

new ArrowHitAnim1[20];
new ArrowTimeCount = 0;
new x;
new y;
new rot;
new Parent[20];
new Direction;
main()
{
	if (FirstRun())
	{
		GetParent("this", Parent)
		Direction = GetDirection(Parent);
		// Create 2 simple burning animations
		CreateAnim(10, ArrowHitAnim1);

		AddAnimframe(ArrowHitAnim1, 0,0, "ArrowAnimS0"); 
		AddAnimframe(ArrowHitAnim1, 0,0, "ArrowAnimS1");
		AddAnimframe(ArrowHitAnim1, 0,0, "ArrowAnimS2");
		AddAnimframe(ArrowHitAnim1, 0,0, "ArrowAnimS1");
		SetAnimLoop(ArrowHitAnim1, false);
		SetAnimSpeed(ArrowHitAnim1, 20);
		
		x = GetX("this");
		y = GetY("this");
		PlaySound("_bombplaced.wav", 240);
	}
	

	if ( Direction == north )
		rot = 180;
	else if ( Direction == east )
		rot = 270;
	else if ( Direction == south )
		rot = 0;
	else if ( Direction == west )
		rot = 90;

	// Draw the burning animation
	if ( ArrowTimeCount == 256 )
	{
		DeleteAnim( ArrowHitAnim1 );
		DeleteEntity("this");
	}
	else if ( FinishedAnim( ArrowHitAnim1 ) )
	{
		SetAnimCount( ArrowHitAnim1, 1 );
		DrawAnimNoInc(ArrowHitAnim1, x, y, y + 24, 0, 255, 255, 255, 255 - ArrowTimeCount, rot, 100);
	}

	else
	{
		DrawAnim(ArrowHitAnim1, x, y, y + 24, 0, 255, 255, 255, 255, rot, 100);
	}
	ArrowTimeCount++;
}
