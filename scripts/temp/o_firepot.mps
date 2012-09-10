/***********************************************
 * Copyright (c) 2003-2006 lukex
 * Changes:  
 *	21/04/2003 [lukex]: New file.
 ***********************************************/
#include <animation>
#include <foreign/journey>
#include <core>

new firepotanim[20];

main()
{
	if (FirstRun())
	{
		SetType("this", enemyType);
		CreateAnim(6, firepotanim); 
		AddAnimframe(firepotanim, 0, 0, "o_firepota");
		AddAnimframe(firepotanim, 0, 0, "o_firepotb");
		AddAnimframe(firepotanim, 0, 0, "o_firepotc");
		SetOpenFlag("this", false);
	}
	new width  = GetWidth("o_firepot");
	new height = GetHeight("o_firepot");
	new x = GetX("this");
	new y = GetY("this");

	if ( isVisible("this") && isActive("this") )
	{
		SetCollisionRect("this", 0, true, x, y, x + width, y + height);
		if ( isOpen("this") )
			DrawAnim(firepotanim, x, y, y + height);
		else  
			PutSprite("o_firepot", x, y, y + height);
	}
	
}
//----------------------------------------
// Name: HitByWeapon(wtype[], damage, x, y)
//----------------------------------------
public HitByWeapon(wtype[], damage, x, y)
{
	// Check if pot was hit by a fire weapon
	if ( !strcmp( wtype, "fire" ) )
		SetOpenFlag("this", true);	
	return;
}
