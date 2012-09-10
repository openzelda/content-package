/***********************************************
 * fairy.zes
 * 
 * Author: Kouruu
 * Date:   January 9, 2005
 *
 * Desc:  Fairy entity from LTTP. Heals player by six hearts.
 *        Sprites ripped by KingofHeart
 *
 * Usage:  Place in landscape designer or SetItem() to any object you choose.
 *
 * Note:  If you use bottles in your quest, you will need to create a DeathFairy.
 *        The DeathFairy will be called when you die. See Readme.txt for instructions
 *         
 * SpriteSheets:  fairy.spt
 *
 * SFX:  heal1.wav, heart.wav
 *
 ***********************************************/

#include <foreign/journey>
#include <float>
#include <core>
#include <animation>

new daCurrentSprite[3][20];   // Hold the current sprite image when drawing the entity
new float: datimer = 2.00;  // Timer used when healing player to give a delay
new HeartCount = 0;          // Heart Counter to tell how many hearts have healed so far
new willTimeOut;
new ImageAlpha = 255;
new x;
new y;	
new Stand = false;
new float: standcount = 0.00;
new Taken = false;
new cDir = 0;
new FinishHeal = false;	
new DeathFairy = false;   // The Death Fairy is special since I didn't wan't to modify
new FirstSent = false;	  // the player1.zes too much, I created this flag.
new AnimCount = 0;
new locx;
new locy;
new sprinklecount = 0;
new played = false;

main()
{
	if (FirstRun())
	{
		new n;
		for(n = 0; n < 2; n++)
			CreateAnim(2, daCurrentSprite[n]);
		CreateAnim(6, daCurrentSprite[2]);	
		//Set some general parameters
		SetImage("this", "fairy");
		SetDirection("this", west);
		SetType("this", itemType); // Even though its not but we wan't to take it when we use a boomy
		SetSpeed( "this", 40 );
	        for(n = 0; n < 3; n++)
        		SetAnimSpeed(daCurrentSprite[n], 10);   

		AddAnimframe(daCurrentSprite[0], 0, 0, "fairy");
		AddAnimframe(daCurrentSprite[0], 0, 0, "fairye1");
		AddAnimframe(daCurrentSprite[1], 0, 0, "fairyw");
		AddAnimframe(daCurrentSprite[1], 0, 0, "fairyw1");
		AddAnimframe(daCurrentSprite[2], 0, 0, "fairyheal");
		AddAnimframe(daCurrentSprite[2], 0, 0, "fairyheal");
		AddAnimframe(daCurrentSprite[2], 0, 0, "fairyheal1");
		AddAnimframe(daCurrentSprite[2], 0, 0, "fairyheal1");
		AddAnimframe(daCurrentSprite[2], 0, 0, "fairyheal");
		AddAnimframe(daCurrentSprite[2], 0, 0, "fairyheal");
		SetAnimLoop(daCurrentSprite[0], true);
		SetAnimLoop(daCurrentSprite[1], true);
		SetAnimLoop(daCurrentSprite[2], false);
		willTimeOut = true;
		
		// Allocate 2 text strings, 300 characters long 
		AllocateStrings("this", 2, 300);

		// Set a description for this item
		SetString("this", 0, "You found a fairy! This will add to your life total.");
		// Set bugnet description for this item
		SetString("this", 1, "You caught a fairy!  Use it when you get low on health.");
	}

	if ( isActive("this"))
	{
		HeartCount = 0;
		if ( Collide("this", "player1") )
			ItemTake();
 
		x = GetX("this");
		y = GetY("this");

		// Move the fairy
		FairyMove();
      
		// Set up 1 collision rectangle for the item
		SetCollisionRect("this", 0, false, x, y, x + GetAnimWidth(daCurrentSprite[cDir]), y + GetAnimHeight(daCurrentSprite[cDir]));

		// If the Item is visible then draw it
		if (isVisible("this") && !FirstRun("this")) 
		{
			DrawAnim(daCurrentSprite[cDir], x, y, y + GetAnimHeight(daCurrentSprite[cDir]), 0, 255,255,255, ImageAlpha);
			if(cDir == 0)
				PutSprite("shadow3", x, y + GetAnimHeight(daCurrentSprite[cDir]) - 6, 2, 0, 255,255,255, ImageAlpha);
			else
				PutSprite("shadow3", x + 8, y + GetAnimHeight(daCurrentSprite[cDir]) - 6, 2, 0, 255,255,255, ImageAlpha);
		}

		// If the Item has been out for too long then make it disappear
		if (willTimeOut)
			TimeOut();
	}
	else
   		FairyHeal();	
}

//----------------------------------------
// Name: TimeOut()
//----------------------------------------
TimeOut()
{
   static float: timer = 0.00;
   static float: alpha = 255.00;

   timer += GetTimeDelta();

   if (timer > 10)
   {
      alpha -= (10 * GetTimeDelta());
      ImageAlpha = floatround(alpha);

      // If the Timer runs out then delete the item
      if (alpha < 0.00)
         DeleteEntity("this");
   }
}

//----------------------------------------
// Name: ItemTake()
//----------------------------------------
public ItemTake()
{
	if(!Taken)
	{
		// Make the Item disappear when taken
		SetActiveFlag("this", false);

		// Other scripts can disable the sound effect on items by setting their first value to 1
		// This is mainly for chests
		if ( GetValue("this", 0) == 0 )
			PlaySound("heal1.wav", 240);
		if(willTimeOut && FinishHeal)
			DeleteEntity("this");
		Taken = true;
		new Desc[20];
		GetString("this", 0, Desc);
		InitTextBox(Desc, 200, true);
	}
}

//----------------------------------------
// Name: SetTimeOut()
//----------------------------------------
public SetTimeOut()
{
	willTimeOut = false;
	Taken = false;
}

//----------------------------------------
// Name: FairyMove()
//----------------------------------------
FairyMove()
{
	new adjust = 3;
	new height = GetAnimHeight(daCurrentSprite[cDir]);
	new width = GetAnimWidth(daCurrentSprite[cDir]);
	new count[5];

	// Move the fairy if the game is unpaused
	if (GetPauseLevel() == 0)
	{
		if(Stand)
		{
			if(standcount < 1.00)
				standcount += GetTimeDelta();
			else
			{
				standcount = 0.00;
				Stand = false;
			}
			return;
		}
		if (random(300) == 1)
			Stand = true;
		// Sometimes randomly change direction
		if (random(300) == 1 && !Stand)
		{
			ChangeDirection("this");
			SetAngleFromDir("this");
		}
		new width = GetAnimWidth(daCurrentSprite[cDir]);
		new height = GetAnimHeight(daCurrentSprite[cDir]); 
		// Check for Collisions
		if (AngleCollide("this", 5, 5, 128, true, width / 2, height / 2))
		{
			ChangeDirection("this");
			SetAngleFromDir("this");
		}
		new Dir = GetDirection("this");
		if ( Dir == northeast || Dir == east || Dir == southeast )
		{
			cDir = 0;
		}
		else if ( Dir == northwest || Dir == west || Dir == southwest )
		{
			cDir = 1;
		}
	 
		// Move the fairy
		if(!Stand)
			AngleMove("this");
	}
	
}

//----------------------------------------
// Name: FairyHeal()
//----------------------------------------
FairyHeal()
{
	if(DeathFairy)
		SetState("this", hit);
	if(HeartCount == 6)
	{
		FinishHeal = true;
		datimer = 2.00;
		return;
	}
	if(GetHealth("player1") >= GetMaxHealth("player1"))
	{
		HeartCount == 6;
		datimer = 2.00;
		FinishHeal = true;
		return;
	}
	if(datimer < 0.13)
		datimer += GetTimeDelta();
	else
	{
		datimer = 0.00;
		HeartCount += 1;
		SetHealth("player1", GetHealth("player1") + 100);
		PlaySound("heart.wav", 240);
	}
}

//----------------------------------------
// Name: HitByWeapon()
//----------------------------------------
public HitByWeapon(weapon[20], Damage, x, y)
{
	new Temp[20];
	if(!strcmp(weapon, "Bugnet"))
	{
		CreateEntity("i_bottlefill5", x, y, Temp);
		new TempString[100];
		GetString(Temp, 0, TempString);
		if(!strcmp(TempString, "You have no empty bottles"))
			return false;
		HeartCount = 6;
		datimer = 2.00;
		SetActiveFlag("this", false);
		return true;
	}
}

//----------------------------------------
// Name: SendDeathFairy()
//----------------------------------------
public SendDeathFairy()
{
	if(FirstSent)
	{
		if(!FindFairyinBottle())
			return -1;
		x = GetX("player1");
		y = GetY("player1");
		for(new n = 0; n < 3; n++)
			SetAnimCount(daCurrentSprite[n], 0);
		FirstSent = false;  //Kinda like FirstRun() except we have to reset it after we finish healing the player	
		SetState("this", walking);
		locx = x;
		locy = y - 34;
		y -= 14;
		SetX("this", x);
		SetY("this", y);
		standcount = 0.00;
		AnimCount = 0;
		sprinklecount = 0;
		return 2;
	}
}

//----------------------------------------
// Name: InitDeathFairy()
//----------------------------------------
public InitDeathFairy()
{
	SetVisibleFlag("this", false);
	SetState("this", dying);
	willTimeOut = false;
	DeathFairy = true;
	FirstSent = true;
}

//----------------------------------------
// Name: FindFairyinBottle()
//----------------------------------------
FindFairyinBottle() 
{
	new temp[32]; 
	new n_string[4];
	new n 
	for ( n = 0; n < 4; n++)
	{
		temp = "i_bottle";
		ToString(n, n_string);
		strcat( temp, n_string);
		if ( isOwned(temp) )
		{
			if ( GetValue(temp, 0) == 5 )
			{
				SetValue(temp, 0, 0);
				SetImage(temp, "i_bottlee");
				SetString(temp, 1, "Empty Bottle");	
				return true;
			}
		}
	}

	return false;
}

//----------------------------------------
// Name: DeathFairyWalk()
//----------------------------------------
DeathFairyWalk()
{
	SetPauseLevel(0);
	SetState("this", walking);
	// Move the Fairy
	DrawAnim(daCurrentSprite[0], x, y, y, 0, 255, 255, 255, 200);
	SetMoveAngle("this",  CalculateAngle(x, y, locx, locy));
	AngleMove("this");
	if( x == locx && y == locy)
		SetState("this", standing);
	if(sprinklecount == 2 && x == locx && y == locy && AnimCount == 5)
		SetState("this", hit);
	SetPauseLevel(2);		
}

//----------------------------------------
// Name: DeathFairyStand()
//----------------------------------------
DeathFairyStand()
{
	SetPauseLevel(0);
	// Wait a sec
	SetState("this", standing);
	DrawAnim(daCurrentSprite[0], x, y, y, 0, 255, 255, 255, 200);
	standcount += GetTimeDelta();
	if(standcount >= 1.50)
	{
		standcount = 0.00;
		if(sprinklecount < 2)
		{
			AnimCount = 0;
			SetState("this", using);
		}
		else
		{
			locx = x + 100;
			AnimCount = 5;
			locy = y - 30;
			SetState("this", walking); 	
		}
	}
	SetPauseLevel(2);
}

//----------------------------------------
// Name: DeathFairySprinkle()
//----------------------------------------
DeathFairySprinkle()
{
	SetPauseLevel(0);
	SetState("this", using);
	// Sprinkle	
	new xoffset = 10;
	new yoffset = 12;
	new Sparkle[20];
		DrawAnim(daCurrentSprite[2], x, y, y, 0, 255, 255, 255, 200);
		if(GetAnimCount(daCurrentSprite[2]) == 2)
		{
			if(!played)
			{
				CreateEntity("sparkle1", x + xoffset, y + yoffset, Sparkle);
				PlaySound("heal1.wav", 240);
				played = true;
			}
		}
		if(AnimCount < 2)
		{
			y++;
			SetY("this", y);
			AnimCount++;
		}
		if(FinishedAnim(daCurrentSprite[2]))
		{
			SetAnimCount(daCurrentSprite[2], 0);
			sprinklecount++;
			played = false;
			SetState("this", walking);
		}
		SetPauseLevel(2);
}

//----------------------------------------
// Name: DeathFairyIdle()
//----------------------------------------
DeathFairyIdle()
{
	return;
}

//----------------------------------------
// Name: DeathFairyMain()
//----------------------------------------
public DeathFairyMain()
{
	if(FinishHeal)
	{
		FirstSent = true;
		HeartCount = 0;
		SetState("this", dying);
		SetPauseLevel(0);
		FinishHeal = false;
	}
	x = GetX("this");
	y = GetY("this");
	switch(GetState("this"))
	{
		case standing:
			DeathFairyStand();
		case walking:
			DeathFairyWalk();
		case using:
			DeathFairySprinkle();
		case hit:
			FairyHeal();
		case dying:
			DeathFairyIdle();	
	}
}