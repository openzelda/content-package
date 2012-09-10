/***********************************************
 * Copyright (c) 2007 Luke Salisbury
 * Changes:  
 *	21/08/07 [lukex]: New file.
 ***********************************************/
#include <foreign/journey>

main()
{
	if (FirstRun())
	{
		SetType("this", enemyType);
		SetDamage("this", 50);
		SetSpeed("this", 10);
		SetHealth("this", 25);
	}
	if ( GetHealth("this") <= 0 )
		SetDeadFlag("this", 1);
	if (!isActive("this") || isDead("this") )
		return;
	new x = GetX("this");
	new y = GetY("this")
	PutSprite("e_urchin", x, y, y + 16);
	SetCollisionRect("this", 0, false, x, y, x + 16, y + 16);
	CallFunction("_enemylib", true, "CheckForPlayer", "NULL");
}

//----------------------------------------
// Name: HitByWeapon(wtype[], damage, x, y)
//----------------------------------------
public HitByWeapon(wtype[], damage, x, y)
{    
	if ( !strcmp( wtype, "shield" ) )
	{
		/* really quicky written code */
		new angle = CalculateAngle(GetX("player1")+8,GetY("player1")+8, GetX("this")+8,GetY("this")+8);
		angle = (angle/90) * 90;
		SetMoveAngle("this", angle);
		AngleMove("this");
		SetSpeedMod("player1", -80);
		return
	}
	CallFunction("_enemylib", true, "BeginHit", "nnnn", damage, x, y, 0 );
}
