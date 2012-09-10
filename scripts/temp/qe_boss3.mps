/***********************************************
 * Copyright (c) 2005-2006 lukex
 * Changes:  
 *	09/09/05 [lukex]: New file.
 ***********************************************/

#include <foreign/journey>
#include <animation>
#include <float>
#include <core>


//==================================
//	Global Data
//==================================
new moving[4][20];
new LastImage[4][10] = { "_boss3_nh",  "_boss3_eh", "_boss3_sh", "_boss3_wh"};
new DeadAnim[20];

new float: HitCount;
new float:timer = 0.00;
new float:changeDir = 2.00;
new adj = 2;
new bool:explosion;

new enemyx;
new enemyy;
new width;
new height
new enemydir;
//----------------------------------------
// Name: main()
//----------------------------------------
main()
{
	if (FirstRun())
	{

		new dir_char[4] = {'n', 'e', 's', 'w' };
		new temp_string[10] = "_boss3_##";
		// Create the animations
		for (new n = 0; n < 4; n++)
		{
	      	CreateAnim( 8, moving[n] );
	      	temp_string[7] = dir_char[n];
			for (new q = 1; q < 4; q++)
			{
				temp_string[8] = q + 48;
				AddAnimframe(moving[n], 0, 0, temp_string );
			}
		}
		

		// Create the Death Animation using the enemy library - nmelib
		CreateAnim(8, DeadAnim);
		CallFunction("_enemylib", true, "CreateDeathAnim", "s", DeadAnim );
		
		SetType("this", enemyType);
		SetSpeed( "this", 25 );
		SetDamage("this", 75);
		SetMaxHealth("this", 300);
		SetHealth("this", 300);
		SetState("this", walking);
		SetMoveAngle("this", 270);
	}
	
	if (isDead("this")|| !isActive("this"))
		return;

	enemyx = GetX("this");
	enemyy = GetY("this");
	enemydir = GetDirection("this");

	width = GetAnimWidth(moving[enemydir]);
	height = GetAnimHeight(moving[enemydir]);


	ConsoleNumber("asd", GetState("this"))
	switch( GetState("this") )
	{
		case hit:
			Hit();
		case dying:
			Die();
		default:
			Walk();
	}
}

//----------------------------------------
// Name: Walk()
//----------------------------------------
Walk()
{
	if ( !GetPauseLevel() )
	{   
		// Check for a collision with the player
		CallFunction("_enemylib", true, "CheckForPlayer", "NULL");
		
		if(!AngleCollide("this", 16, 5, 126, false, 0, 0))
		{
			AngleMove("this");
		}
		else
		{
			ChangeDirection();
		}
		timer += 8*GetTimeDelta();
		if(timer >= changeDir)
		{
			changeDir = float(random(140) + 100) / 10;
			timer = 0.00;
			ChangeDirection();	
		}
		SetAngleFromDir("this");
	}
	
	DrawAnim(moving[enemydir], enemyx - (width/2), enemyy - (height/2), enemyy);
	SetCollisionRect("this", 0, false, enemyx - (width/2) + adj, enemyy - (height/2)+ adj, enemyx + (width/2) - adj, enemyy + (height/2) - adj);
	CheckForFood();
}

CheckForFood()
{
	switch(enemydir)
	{
		case south:
		{
			SetCollisionRect("this", 1, false, enemyx - adj, enemyy + (height/2), enemyx + adj, enemyy + (height/2) - adj);
			StartEntity(20, enemyx, enemyy + (height/2));
		}
		case east:
		{
			SetCollisionRect("this", 1, false, enemyx + (width/2), enemyy + adj, enemyx + (width/2) - adj, enemyy - adj);
			StartEntity(20, enemyx + (width/2), enemyy );
		}
		case west:
		{
			SetCollisionRect("this", 1, false, enemyx - (width/2), enemyy + adj, enemyx - (width/2) + adj, enemyy - adj);
			StartEntity(20, enemyx - (width/2), enemyy );
		}
		default:
		{
			SetCollisionRect("this", 1, false, enemyx - adj, enemyy - (height/2), enemyx + adj, enemyy - (height/2) + adj);
			StartEntity(20, enemyx, enemyy - (height/2) );
		}
	}
	new temp[32];
	new temp2[32];
	do 
	{ 
		ToString(GetCurrentEntity(), temp); 
    	GetImage(temp, temp2);
    	if ( !strcmp(temp2,"_bombweapon1") ) 
    	{ 
    		if ( CollideAll("this", temp) )
    		{
    			SetState("this", hit);
    			DeleteEntity(temp);
    		}
		} 
	} while( NextEntity() )
}

//----------------------------------------
// Name: HitByWeapon(wtype[], damage, x, y)
//----------------------------------------
public HitByWeapon(wtype[], damage, x, y)
{	
	if ( !strcmp( wtype, "sword" ) )
	{
		// Knock the player back a lot
		CallFunction("player1", false, "BeginKnockBack", "nnnn", GetX("this") + 8, GetY("this") + 12, 60, 30);
	}
}

//----------------------------------------
// Name: Hit()
//----------------------------------------
Hit()
{
	new colors[5][3] = { {19,125,19}, {253,211,65}, {225,88,5}, {32,211,238}, {238,32,32} };
	if (isVisible("this"))
	{
		PutSprite(LastImage[enemydir],  enemyx - (width/2), enemyy - (height/2), enemyy + height, 0, colors[ floatround(HitCount * 20.0) % 5 ][0], \
										  colors[ floatround(HitCount * 20.0) % 5 ][1], \
										  colors[ floatround(HitCount * 20.0) % 5 ][2]);
	}	
	if (GetPauseLevel() == 0)
	{
	
		SetCollisionRect("this", 0, false, enemyx - (width/2) + adj, enemyy - (height/2)+ adj, enemyx + (width/2) - adj, enemyy + (height/2) - adj);

		// Draw the enemy with different shades of colour becuase they have been hit

		if (HitCount >= 1.00 && !explosion)
		{
			CreateEntity("_explosion2", enemyx, enemyy, "dontcare");
			explosion = true;
		}
		// Check the hit counter, if it goes high enough then end this hit state
		HitCount += GetTimeDelta();
		if (HitCount >= 3.00)
		{
			HitCount = 0.00;
			// Leave the Hit state
			SetState("this", walking); 
			SetHealth("this", GetHealth("this") - 100);
			if ( GetHealth("this") <= 0)
			{
				SetPosition("this", enemyx - (width/2), enemyy - (height/2));
				SetState("this", dying);
			}
			explosion = false;
		}
	}
}

//----------------------------------------
// Name: Die()
//----------------------------------------
Die()
{	
		
	// Draw the enemy standing still
	if (GetAnimCount(DeadAnim) < 5)
		PutSprite(LastImage[enemydir], enemyx, enemyy, enemyy);  	
	
	// Overlay the death animation over the enemy
	CallFunction("_enemylib", true, "HandleDying", "ss", DeadAnim, LastImage[enemydir]);   
	SetHealth("this", 0);
}
