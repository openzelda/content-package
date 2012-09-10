/***********************************************
 * Copyright (c) 2002-2005 Editors, KC
 * Changes:  
 *	22/10/2003 [KC]: New file.
 *	19/02/2005 [Lukex]: needed changes to work with newwer enemylib
 ***********************************************/

#include <foreign/journey>
#include <animation>
#include <float>
#include <core>

//   Global Data
new MainImage[20];
new walkAnim[20];
new tailAnim[20];
new tailAnim2[20];
new tailAnim3[20];
new eyeAnim[20];
new DeadAnim[20];	     // String holds animation identifier of death animation
new FallAnim[20];	     // String holds animation identifier of falling animation
new LastImage[20];       // holds sprite code of the last drawn image
new float: StunCount;
new float: HitCount;	 // Counter used when the enemy has been hit
new adj = 2;		     // Collision rectangle adjustment value
new float: movetimer = 0.00;
new float: angletimer = 0.00;
new OldX[200];
new OldY[200];
new ang;
new var;
//new float: framenum = 30;
//new float: f1 = 10;
//new float: framenum2 = 30;
//new float: pixnum1 = 400.00;
//new float: pixnum2 = 600.00;
new float: soundtime = 0.00;
new float: dietime = 0.00;
new float: notanotherfloat = 0.00;
new float: justonemoretimer = 0.00;

new param;
new eyetimer;


//----------------------------------------
// Name: main()
//----------------------------------------
main()
{
	if (FirstRun())
	{
		// Create the animations
		param = GetParam("this");
		if(param == '1')  //small moldrom
		{
			MainImage = "worm1";
			LastImage = "worm1";
			SetDamage("this", 100);
			SetHealth("this", 100);
			SetMaxHealth("this", 100);
			SetSpeed( "this", 100); 
			SetWeight("this", 20);
			// Create the Death Animation using the enemy library - nmelib
			CreateAnim(8, DeadAnim);
			CallFunction("_enemylib", true, "CreateDeathAnim", "s", DeadAnim );
		}
		else if(param == 'b') //boss moldrom
		{
			CreateAnim(8, walkAnim);
			CreateAnim(8, tailAnim);
			CreateAnim(8, tailAnim2);
			CreateAnim(8, tailAnim3);
			CreateAnim(8, eyeAnim);
			
			AddAnimframe(walkAnim, 0, 0, "wormb");
			AddAnimframe(walkAnim, 0, 0, "wormb2");
			
			AddAnimframe(eyeAnim, 0, 0, "_boss_worm_eye_e");  //for where the eyes go psycho
			AddAnimframe(eyeAnim, 0, 0, "_boss_worm_eye_se");
			AddAnimframe(eyeAnim, 0, 0, "_boss_worm_eye_s");
			AddAnimframe(eyeAnim, 0, 0, "_boss_worm_eye_sw");
			AddAnimframe(eyeAnim, 0, 0, "_boss_worm_eye_w");
			AddAnimframe(eyeAnim, 0, 0, "_boss_worm_eye_nw");
			AddAnimframe(eyeAnim, 0, 0, "_boss_worm_eye_n");
			AddAnimframe(eyeAnim, 0, 0, "_boss_worm_eye_ne");
			
			AddAnimframe(tailAnim, 0, 0, "wormb3");
			AddAnimframe(tailAnim, 0, 0, "wormb4");
			
			AddAnimframe(tailAnim2, 0, 0, "wormb5");
			AddAnimframe(tailAnim2, 0, 0, "wormb6");
			
			AddAnimframe(tailAnim3, 0, 0, "wormbtail1");
			AddAnimframe(tailAnim3, 0, 0, "wormbtail2");
			SetDamage("this", 200);
			SetHealth("this", 300);
			SetMaxHealth("this", 300);
			SetSpeed( "this", 100);
			SetWeight("this", 200);
			// Create the Death Animation using the enemy library
			CreateAnim(4, DeadAnim);
			CallFunction("_enemylib", true, "CreateDeathAnim", "s", DeadAnim );
			
		}
		
		
		// Create the Falling Animation using the enemy library
		CreateAnim(8, FallAnim); 
		CallFunction("_enemylib", true, "CreateFallAnim", "s", FallAnim );
		
		// Set some general parameters
		SetActiveDist("this", 320);
		SetType("this", enemyType);
		
		SetMoveAngle("this", 180);
	}
	
	if (!isActive("this") || isDead("this"))
		return;
	
	// Check for a collision with the player
	CallFunction("_enemylib", true, "CheckForPlayer", "NULL");
	
	// Call a function for the enemy depending on its state
	switch( GetState("this") )
	{
		case standing:
			Walk();
		case walking:
			Walk();
		case hit:
			Hit();
		case dying:
			Die();
		case falling:
			CallFunction("_enemylib", true, "Fall", "snn", FallAnim, GetWidth("worm1"), GetHeight("worm1"));
		case burning:
			Burn();
		case stunned:
			Stunned();
		case frozen:
			Freeze();
	}
	
	// Check for holes in the ground
	CallFunction("_enemylib", true, "CheckForHoles", "s", FallAnim);
}

//----------------------------------------
// Name: Walk()
//----------------------------------------
Walk()
{
	SetState("this", walking);
	
	// Get the width and height of the Current animation
	new width;
	new height;
	new soundvar2 = true;
	dietime = 0.00;
	// Get the width and height of the Current animation
	if(param == '1')
	{
		width = GetWidth(MainImage);
		height = GetHeight(MainImage);
	}
	else if(param == 'b')
	{
		width  = GetAnimWidth(walkAnim);
		height = GetAnimHeight(walkAnim);
	}
	
	// Move the Enemy
	if (GetPauseLevel() == 0)
	{
		
		angletimer += 180*GetTimeDelta();
		if(movetimer < 0.90)
		{
			movetimer += GetTimeDelta();
		}
		if(movetimer >= 0.90)
		{
			
			var = random(3);
			ang = GetMoveAngle("this");
			angletimer = 0.00;
			movetimer = 0.00;
		}
		
		notanotherfloat += 200*GetTimeDelta();
		if(notanotherfloat >= 1.00)
		{
			WhereIsIt();
			notanotherfloat = 0.00;
		}
		//if(random(500) == 1)    <-- this is needed for alternate method
		//{
		//	f1 = 20000*GetTimeDelta();
			//notanotherfloat = 0.00;
		//}
		if(var == 0)
		{
			SetMoveAngle("this", ang);
		}
		else if(var == 1)
		{
			SetMoveAngle("this", ang + floatround(angletimer));
		}
		else if(var > 1)
		{	
			SetMoveAngle("this", ang - floatround(angletimer));
		}
		eyetimer = GetMoveAngle("this");
		
		if(param == 'b')
		{
			soundtime += 10*GetTimeDelta();
			if(soundtime >= 2.5)
			{
				PlaySound("wormsound.wav", 170);
				soundtime = 0.00;
			}
		}	
		
		// Check for Collisions
		if(AngleCollide("this", 8, 5, 240, true, width / 2, height / 2))
		{
			if(soundvar2 == true && param == 'b')
			{
				PlaySound("LandInDirt.wav", 190);
				soundvar2 = false;
			}
			ang = GetMoveAngle("this") - 180;  //bounces off of walls
			AngleMove("this");
		}
		else
		{
			if(soundvar2 == false)
			{
				soundvar2 = true;
			}
			AngleMove("this");
		}
		
		if(param == 'b' && GetState("player1") == using && GetState("player1") != knocked)
		{
			justonemoretimer += 4*GetTimeDelta();
			if(justonemoretimer > 1.00 && NearPoint(OldX[40] + 16, OldY[40] + 16, GetX("player1"), GetY("player1"), 40))  //to prevent the player from just wacking the thing a bunch of times right as it gets out of the hit state
			{
				new temp[20];
				new temp2[20];  //and do the same for any other swords, unless you have a better idea
      		temp = "_swordweapon1";
      		temp2 = "_swordweapon2";
        		if(CollidePoint(temp, OldX[40] + 9, OldY[40] + 9))
				{
						HitCount = 0.00;
						CallFunction("_enemylib", true, "BeginHit", "nnn", 50, GetX(temp), GetY(temp) );
				}else if(CollidePoint(temp, OldX[40] + 23, OldY[40] + 23))
				{
						HitCount = 0.00;
						CallFunction("_enemylib", true, "BeginHit", "nnn", 50, GetX(temp), GetY(temp) );
				}else if(CollidePoint(temp, OldX[40] + 16, OldY[40] + 16))
				{
						HitCount = 0.00;
						CallFunction("_enemylib", true, "BeginHit", "nnn", 50, GetX(temp), GetY(temp) );		
				}else if(CollidePoint(temp, OldX[40] + 9, OldY[40] + 23))
				{
						HitCount = 0.00;
						CallFunction("_enemylib", true, "BeginHit", "nnn", 50, GetX(temp), GetY(temp) );
				}else if(CollidePoint(temp, OldX[40] + 23, OldY[40] + 9))
				{
						HitCount = 0.00;
						CallFunction("_enemylib", true, "BeginHit", "nnn", 50, GetX(temp), GetY(temp) );
				}
				if(CollidePoint(temp2, OldX[40] + 9, OldY[40] + 9))
				{
						HitCount = 0.00;
						CallFunction("_enemylib", true, "BeginHit", "nnn", 50, GetX(temp2), GetY(temp2) );
				}else if(CollidePoint(temp2, OldX[40] + 23, OldY[40] + 23))
				{
						HitCount = 0.00;
						CallFunction("_enemylib", true, "BeginHit", "nnn", 50, GetX(temp2), GetY(temp2) );
				}else if(CollidePoint(temp2, OldX[40] + 16, OldY[40] + 16))
				{
						HitCount = 0.00;
						CallFunction("_enemylib", true, "BeginHit", "nnn", 50, GetX(temp2), GetY(temp2) );		
				}else if(CollidePoint(temp2, OldX[40] + 9, OldY[40] + 23))
				{
						HitCount = 0.00;
						CallFunction("_enemylib", true, "BeginHit", "nnn", 50, GetX(temp2), GetY(temp2) );
				}else if(CollidePoint(temp2, OldX[40] + 23, OldY[40] + 9))
				{
						HitCount = 0.00;
						CallFunction("_enemylib", true, "BeginHit", "nnn", 50, GetX(temp2), GetY(temp2) );
				}
			}
		}
  
		//f1 = 20000*GetTimeDelta();       //alternate method, just change OldX[12] to OldX[framenum] (and do same for smaller tail)
		//framenum = floatround(floatdiv(pixnum1,f1));
		//if(framenum > 180)
		//{
		//	framenum = 180;
		//}
		/* Divide the dividend float by the divisor float */
		//native float:floatdiv(float:dividend, float:divisor);
		//framenum2 = floatround(floatdiv(pixnum2,f1));

		//if(framenum2 > 199)
		//{
		//	framenum2 = 199;
		//}
		
		
	}
	
	// Draw the enemy
	new x = GetX("this");
	new y = GetY("this");
	
	if (isVisible("this"))
	{
		if(param == '1')
		{
			PutSprite(MainImage, x, y, y + height, 50);
			PutSprite("worm2", OldX[5], OldY[5], OldY[5] + 8, 20);   //want the tail to follow shortly behind
			PutSprite("worm3", OldX[9] + 5, OldY[9] + 5, OldY[9] + 4, 10);  //ditto
			PutSprite("wormeye", x + 5 - floatround(7*Cos(eyetimer + 30)), y + 5 - floatround(7*Sin(eyetimer + 30)), y + 30, 60); //needs eyes of course!
			PutSprite("wormeye", x + 5 - floatround(7*Cos(eyetimer - 30)), y + 5 - floatround(7*Sin(eyetimer - 30)), y + 30, 60);
			// Set a collision rectangle around the Enemy
			SetCollisionRect("this", 0, false, x + adj, y + adj, x + width - adj, y + height - adj);
		}
		else if(param == 'b')
		{
			DrawAnim(walkAnim, x, y, y + 32, 50);
			DrawAnim(tailAnim, OldX[12]+ 2, OldY[12] + 2, OldY[12] + 16, 20);
			DrawAnim(tailAnim, OldX[24]+ 2, OldY[24] + 2, OldY[24] + 16, 20);
			DrawAnim(tailAnim2, OldX[33] + 7, OldY[33] + 7, OldY[33] + 12, 15);
			DrawAnim(tailAnim3, OldX[40] + 7, OldY[40] + 7, OldY[40] + 12, 10);
			PutSprite("_boss_worm_eye_e", x + 13 - floatround(10*Cos(eyetimer + 30)), y + 13 - floatround(10*Sin(eyetimer + 30)), y + 36, 65, 255,255,255,255, eyetimer - 180); //needs eyes of course!
			PutSprite("_boss_worm_eye_e", x + 13 - floatround(10*Cos(eyetimer - 30)), y + 13 - floatround(10*Sin(eyetimer - 30)), y + 36, 65, 255,255,255,255, eyetimer - 180);
			SetCollisionRect("this", 0, false, x + 6, y + 6, x + width - 6, y + height - 6);
			//SetCollisionRect("this", 1, false, OldX[40] + 9, OldY[40] + 9, OldX[40] + width - 9, OldY[40] + height - 9);
			
		}
	}
	
	
}
WhereIsIt()
{
	new n;
	new x = GetX("this");
	new y = GetY("this");
	
	// Only proceed if we have actually moved
	//if (x == OldX[0] && y == OldY[0])
	//	return; 
	
	// We want to insert a new value into the array, so move all the values along one
	for ( n = 200 - 1; n > 0; n-- )
	{ 
		OldX[n] = OldX[n - 1];
		OldY[n] = OldY[n - 1];
	}
	
	// Record the current position of the player in the OldX and OldY arrays
	OldX[0] = x;
	OldY[0] = y;
}


//----------------------------------------
// Name: Stand()
//----------------------------------------
Stand( justDraw )
{
	new width;
	new height;
	// Get the width and height of the Current animation
	if(param == '1')
	{
		width  = GetWidth(MainImage);
		height = GetHeight(MainImage);
	}
	else if(param == 'b')
	{
		width  = GetAnimWidth(walkAnim);
		height = GetAnimHeight(walkAnim);
	}
	new x = GetX("this");
	new y = GetY("this");
	
	notanotherfloat += 200*GetTimeDelta();
	if(notanotherfloat >= 1.00)
	{
		WhereIsIt();
		notanotherfloat = 0.00;
	}
	
	// Draw the enemy and its shadow
	if (isVisible("this"))
	{
		if(param == '1')
		{
			PutSprite(MainImage, x, y, y + 16);
			PutSprite("worm2", OldX[5], OldY[5], OldY[5] + 8);
			PutSprite("worm3", OldX[9] + 5, OldY[9] + 5, OldY[9] + 4);
			PutSprite("wormeye", x + 5 - floatround(7*Cos(eyetimer + 30)), y + 5 - floatround(7*Sin(eyetimer + 30)), y + 20, 10);
			//PutSprite("shadow1", (x + width / 2) - 8, y + height - 15, 2);
			PutSprite("wormeye", x + 5 - floatround(7*Cos(eyetimer - 30)), y + 5 - floatround(7*Sin(eyetimer - 30)), y + 20, 10);
			// Set a collision rectangle around the Enemy
			SetCollisionRect("this", 0, false, x + adj, y + adj, x + width - adj, y + height - adj);
		}
		else if(param == 'b')
		{
			DrawAnim(walkAnim, x, y, y + 32);
			DrawAnim(tailAnim, OldX[10]+ 2, OldY[10] + 2, OldY[10] + 16);
			DrawAnim(tailAnim, OldX[22]+ 2, OldY[22] + 2, OldY[22] + 16);
			DrawAnim(tailAnim2, OldX[30] + 6, OldY[30] + 6, OldY[30] + 12);
			DrawAnim(tailAnim3, OldX[37] + 6, OldY[37] + 6, OldY[37] + 12);
			DrawAnim(eyeAnim, x + 13 - floatround(10*Cos(eyetimer + 30)), y + 13 - floatround(10*Sin(eyetimer + 30)), y + 34, 1);
			DrawAnim(eyeAnim, x + 13 - floatround(10*Cos(eyetimer - 30)), y + 13 - floatround(10*Sin(eyetimer - 30)), y + 34, 1);
			// Set a collision rectangle around the Enemy
			SetCollisionRect("this", 0, false, x + 6, y + 6, x + width - 6, y + height - 6);
		}
	}
}

//----------------------------------------
// Name: HitByWeapon(wtype[], damage, x, y)
//----------------------------------------
public HitByWeapon(wtype[], damage, x, y)
{
	new state = GetState("this");
	if (state == hit || state == dying || state == burning )
		return;
		
	if(param == 'b')
	{
		if ( !strcmp( wtype, "sword" ) )
		{
			CallFunction("player1", false, "BeginKnockBack", "nnnn", GetX("this") + 8, GetY("this") + 12, 90, 50);
			justonemoretimer = -1.50;
			return;
		}
		else
		{return;
		}
			
	}
	// Check if this enemy was hit by a weapon that can stun
	if ( !strcmp( wtype, "stun" ) && state != stunned && state != frozen )
	{
		//StunCount = float(damage);
		//SetState("this", stunned);
		return;
	}
	
	// Check if this enemy was hit by a fire weapon
	if ( !strcmp( wtype, "fire" ) )
	{
		// Set the enemy on fire - watch them burn muhahahaha
		if (CallFunction("_enemylib", true, "SetOnFire", "s", LastImage))
		StunCount = 32.00;  // function succeded, make the enemy stunned for a while then kill them
		return;
	}
	if(param == '1')
	{
		if ( !strcmp( wtype, "Powder"))
  		{
   			SetDeadFlag("this",true);
   			SetActiveFlag("this",false);
   			//CreateEntity("miscblob1",GetX("this"),GetY("this"),"blob");
   			return;
   		}
	}
	// Check if this enemy was hit by an ice weapon
	if ( !strcmp( wtype, "ice" ) )
	{
		// Put this enemy on ice
		CallFunction("_enemylib", true, "BeginFreeze", "s", LastImage);
		return;
	}
	
	HitCount = 0.00;
	CallFunction("_enemylib", true, "BeginHit", "nnn", damage, x, y );
}

//----------------------------------------
// Name: Hit()
//----------------------------------------
Hit()
{
	new colors[5][3] = { {19,125,19}, {253,211,65}, {225,88,5}, {32,211,238}, {238,32,32} };
	new width;
	new height;
	// Get the width and height of the Current animation
	if(param == '1')
	{
		width  = GetWidth(MainImage);
		height = GetHeight(MainImage);
	}
	else if(param == 'b')
	{
		width  = GetAnimWidth(walkAnim);
		height = GetAnimHeight(walkAnim);
	}
	
	// Move the enemy if the game is completely unpaused
	if (GetPauseLevel() == 0)
	{
		if(param == '1')
		{
			AngleMove("this");
			AngleCollide("this", 5, 5, 126, 0, width / 2, height / 2);
		}
		notanotherfloat += 200*GetTimeDelta();
		if(notanotherfloat >= 1.00)
		{
			WhereIsIt();
			notanotherfloat = 0.00;
		}
	}
	new x = GetX("this");
	new y = GetY("this");
	
	// Draw the enemy with different shades of colour becuase they have been hit
	if (isVisible("this"))
	{
		if(param == '1')
		{
			PutSprite(MainImage, x, y, y + height, 50, colors[ floatround(HitCount * 20.0) % 5 ][0], \
		                           			 colors[ floatround(HitCount * 20.0) % 5 ][1], \
		                           			 colors[ floatround(HitCount * 20.0) % 5 ][2], 255, 0, 100);
			PutSprite("worm2", OldX[3], OldY[3], OldY[3] + 8, 20, colors[ floatround(HitCount * 20.0) % 5 ][0], \
		                           			 colors[ floatround(HitCount * 20.0) % 5 ][1], \
		                           			 colors[ floatround(HitCount * 20.0) % 5 ][2], 255, 0, 100);
			PutSprite("worm3", OldX[5] + 4, OldY[5] + 4, OldY[5] + 4, 10, colors[ floatround(HitCount * 20.0) % 5 ][0], \
		                           			 colors[ floatround(HitCount * 20.0) % 5 ][1], \
		                           			 colors[ floatround(HitCount * 20.0) % 5 ][2], 255, 0, 100);
			PutSprite("wormeye", x + 5 - floatround(7*Cos(eyetimer + 30)), y + 5 - floatround(7*Sin(eyetimer + 30)), y + 30, 60, colors[ floatround(HitCount * 20.0) % 5 ][0], \
		                           			 colors[ floatround(HitCount * 20.0) % 5 ][1], \
		                           			 colors[ floatround(HitCount * 20.0) % 5 ][2], 255, 0, 100);
			PutSprite("wormeye", x + 5 - floatround(7*Cos(eyetimer - 30)), y + 5 - floatround(7*Sin(eyetimer - 30)), y + 30, 60, colors[ floatround(HitCount * 20.0) % 5 ][0], \
			                           		 colors[ floatround(HitCount * 20.0) % 5 ][1], \
		                           			 colors[ floatround(HitCount * 20.0) % 5 ][2], 255, 0, 100);
		}
		else if(param == 'b')
		{
			DrawAnim(walkAnim, x, y, y + 32, 40,colors[ floatround(HitCount * 20.0) % 5 ][0], \
		                           			 colors[ floatround(HitCount * 20.0) % 5 ][1], \
		                           			 colors[ floatround(HitCount * 20.0) % 5 ][2], 255, 0, 100);
			DrawAnim(tailAnim, OldX[9]+ 2, OldY[9] + 2, OldY[9] + 16, 10, colors[ floatround(HitCount * 20.0) % 5 ][0], \
		                           			 colors[ floatround(HitCount * 20.0) % 5 ][1], \
		                           			 colors[ floatround(HitCount * 20.0) % 5 ][2], 255, 0, 100);
			DrawAnim(tailAnim2, OldX[15] + 6, OldY[15] + 6, OldY[15] + 12, 5, colors[ floatround(HitCount * 20.0) % 5 ][0], \
		                           			 colors[ floatround(HitCount * 20.0) % 5 ][1], \
		                           			 colors[ floatround(HitCount * 20.0) % 5 ][2], 255, 0, 100);
			DrawAnim(tailAnim3, OldX[20] + 6, OldY[20] + 6, OldY[20] + 12, 0, colors[ floatround(HitCount * 20.0) % 5 ][0], \
		                           			 colors[ floatround(HitCount * 20.0) % 5 ][1], \
		                           			 colors[ floatround(HitCount * 20.0) % 5 ][2], 255, 0, 100);
		   DrawAnim(eyeAnim, x + 12 - floatround(10*Cos(eyetimer + 30)), y + 12 - floatround(10*Sin(eyetimer + 30)), y + 34, 60, colors[ floatround(HitCount * 20.0) % 5 ][0], \
		                           			 colors[ floatround(HitCount * 20.0) % 5 ][1], \
		                           			 colors[ floatround(HitCount * 20.0) % 5 ][2], 255, 0, 100);
		   DrawAnim(eyeAnim, x + 12 - floatround(10*Cos(eyetimer - 30)), y + 12 - floatround(10*Sin(eyetimer - 30)), y + 34, 60, colors[ floatround(HitCount * 20.0) % 5 ][0], \
		                           			 colors[ floatround(HitCount * 20.0) % 5 ][1], \
		                           			 colors[ floatround(HitCount * 20.0) % 5 ][2], 255, 0, 100);
		}
	}
	
	// Check the hit counter, if it goes high enough then end this hit state
	HitCount += GetTimeDelta();
	if(param == '1')
	{
		if (HitCount >= 0.3)
		{
			// Leave the Hit state
			SetState("this", walking); 
			SetSpeedMod("this", 0);
		}
	}
	else
	{
		if (HitCount >= 0.9)
		{
			// Leave the Hit state
			SetState("this", walking); 
			SetSpeedMod("this", 10);
			//justonemoretimer = 0.00;
		}
	}
}

//----------------------------------------
// Name: Die()
//----------------------------------------
Die()
{	
		
	notanotherfloat += 200*GetTimeDelta();
	if(notanotherfloat >= 1.00)
	{
		WhereIsIt();
		notanotherfloat = 0.00;
	}
	// Overlay the death animation over the enemy
	if(param == '1')
	{
		// Draw the enemy standing still
		if (GetAnimCount(DeadAnim) < 5)
			Stand( true );   
		CallFunction("_enemylib", true, "HandleDying", "ss", DeadAnim, LastImage);   
	}
	else
	{
		new dievar;
		dietime += 6*GetTimeDelta();
		if(dietime >= 2.00)
		{
			dievar = random(4);
			if(dievar == 0)
			{
				CreateEntity("_explosion2", GetX("this")+ 3, GetY("this") + 3);
			}
			else if(dievar == 1)
			{
				CreateEntity("_explosion2", GetX("this") + 26, GetY("this") + 3);
			}
			else if(dievar == 2)
			{
				CreateEntity("_explosion2", GetX("this") + 3, GetY("this") + 26);
			}
			else if(dievar > 2)
			{
				CreateEntity("_explosion2", GetX("this") + 26, GetY("this") + 26);
			}
			PlaySound("_doorclose.wav", 180);
			dietime = 1.00;
		}
		// Draw the enemy standing still
		if (GetAnimCount(DeadAnim) < 12)
			Stand( true ); 
		CallFunction("_enemylib", true, "HandleDying", "ss", DeadAnim, "wormb");
	}
	SetHealth("this", 0);
}

//----------------------------------------
// Name: Stunned()
//----------------------------------------
Stunned()
{
	// Display the enemy stood still
	Stand( true );
	
	// decrement the Stun counter
	StunCount -= 10 * GetTimeDelta();
	CallFunction("_enemylib", true, "Stunned", "n", floatround(StunCount));
}

//----------------------------------------
// Name: Burn()
//----------------------------------------
Burn()
{
	// This function should be called when the enemy is the the burning state
	// Use the stunned state to make the enemy stand still while they burn
	Stunned();	
	
	// if the stun count gets below a certain level then kill then enemy
	if (StunCount <= 12)
		CallFunction("_enemylib", true, "KillEnemy", "n", 1);
}

//----------------------------------------
// Name: Freeze()
//----------------------------------------
Freeze()
{
	// Draw the enemy in a standing position, but draw them blue
	new x = GetX("this");
	new y = GetY("this");
	new width  = GetWidth(MainImage);
   new height = GetHeight(MainImage);
	
	if (isVisible("this"))
	{
		PutSprite(MainImage, x, y, y + height, 0, 100, 100, 255);
		PutSprite("shadow1", (x + width / 2) - 8, y + height - 15, 2);
	}
}