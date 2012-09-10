/***********************************************
 * Copyright (c) 2002-2005 Editors, KingOfHeart
 * Changes:  
 *	22/07/2003 [KingOfHeart]: New file.
 ***********************************************/

#include <animation>
#include <foreign/journey>
#include <float>
#include <core>

new MainImage[20]="hoppingbunny";
new grass[20]= "grasswalk1";
new float: gravity = 700.00;  	// This should be made as a proper variable in OZ
new float: BounceVelocity = 280.00;
new float: BounceAmount   = 1.00;
new strugle[20];
new adj = 2;
new message[1024];
new MessageIndex = 0;
const TextLength = 600;
new DeadAnim[20];
new float: HitCount;
new state;
new LastImage[20];
main()
{
	
	if (FirstRun())
	{
	SetHealth("this",1);
	SetMaxHealth("this",1);
	SetDamage("this",50);
	SetActiveDist("this",320);
	AllocateStrings("this", 1, 640 ); 
	LastImage = MainImage;
	if (strlen(message) < 1)
	{
	SetString("this",0,"All right! Take it, thief!");
	}
	
	
	
	CreateAnim(6, strugle);   
      AddAnimframe(strugle, 0, 0, "hoppingbunnyf1");  
      AddAnimframe(strugle, 0, 0, "hoppingbunnyf2");
      
      // Create the Death Animation using the enemy library - nmelib
      CreateAnim(8, DeadAnim);
      CallFunction("_enemylib", true, "CreateDeathAnim", "s", DeadAnim );	
	}
	if(isDead("this")|| !isActive("this"))
	return;
	
	if(BounceAmount <= 20 && GetState("this")!= falling)
	{
	// Check for a collision with the player
	if(GetType("this")== enemyType)
   CallFunction("_enemylib", true, "CheckForPlayer", "NULL");
	}
	RandomItem();
	// Call a function for the enemy depending on its state
	switch( GetState("this") )
	{
		case standing:
			Jump();
		case walking:
			Jump();
		case hit:
			Hit();
		case dying:
			Die();
		case falling:
			Strugle();
	}
}
//-----------------------
//Name:Jump()
//-----------------------
Jump()
{
state = standing;
new x = GetX("this");
new y = GetY("this");
new width = GetWidth(grass);
new height = GetHeight(grass);
new widtha = GetWidth(MainImage);
new heighta = GetHeight(MainImage);

// Move the Enemy
	if (GetPauseLevel() == 0)
	{	
		// Decrease the bounce velocity
		BounceVelocity -= (gravity * GetTimeDelta());
		BounceAmount += (BounceVelocity * GetTimeDelta());
		
		// Check if the enemy hits the floor yet after bouncing
		if ( BounceAmount <= 0 )
		{
			// Start a new bounce
			BounceAmount = 1.00;
			BounceVelocity = 280.00;
			PlaySound("_boomerang.wav", 240);
			CheckForGrass();
			
			
		}
	}
		if (isVisible("this"))
		{
			if(BounceAmount > 1)
			{
		PutSprite(MainImage, x, y - floatround(BounceAmount), y + height);
			}
		PutSprite(grass, (x + width / 2) - 8, y + height, 2);
		}
		// Set a collision rectangle around the Enemy
	SetCollisionRect("this", 0, false, x, y , x + widtha, y + heighta);
		
}
//-----------------------
//Name:Strugle()
//-----------------------
Strugle()
{
state = falling;
new x = GetX("this");
new y = GetY("this");
new width = GetAnimWidth(strugle);
new height = GetAnimHeight(strugle);

	
	if(Collide("player1","this"))
	{
	new message[ TextLength ];
            GetString("this", MessageIndex, message);
            InitTextBox( message, 200, true);
            SetHealth("this",0);
            SetState("this",dying);
	}
if (isVisible("this"))
		{
		DrawAnim(strugle,x, y, y + height);
		}
		SetCollisionRect("this", 0, false, x + adj, y + adj, x + width - adj, y + height - adj);
}
//----------------------------------------
// Name: HitByWeapon(wtype[], damage, x, y)
//----------------------------------------
public HitByWeapon(wtype[], damage, x, y)
{
if(GetState("this")== dying ||GetState("this")== hit ||BounceAmount > 20 || GetType("this")!= enemyType)
return; 
HitCount = 0.00;
	CallFunction("_enemylib", true, "BeginHit", "nnn", damage, x, y );
}
//----------------------------------------
// Name: Hit()
//----------------------------------------
Hit()
{
   new colors[5][3] = { {19,125,19}, {253,211,65}, {225,88,5}, {32,211,238}, {238,32,32} };
   new width  = GetWidth(MainImage);
   new height = GetHeight(MainImage);

   // Move the enemy if the game is completely unpaused
   if (GetPauseLevel() == 0)
   {
      AngleMove("this");
      AngleCollide("this", 5, 5, 126, 0, width / 2, height / 2);
   }

   new x = GetX("this");
   new y = GetY("this");

   // Draw the enemy
   if (isVisible("this"))
   {
      DrawAnim(MainImage, x, y - floatround(BounceAmount), y + height, 0, colors[ floatround(HitCount * 20.0) % 5 ][0], \
                                           colors[ floatround(HitCount * 20.0) % 5 ][1], \
                                           colors[ floatround(HitCount * 20.0) % 5 ][2], 255, 0, 100);

      
   }

   // Check the hit counter
   HitCount += GetTimeDelta();

   if (HitCount >= 0.23)
   {
      // Leave the Hit state
      SetState("this", standing); 
      
   }
}
//----------------------------------------
// Name: Die()
//----------------------------------------
Die()
{
	new x = GetX("this");
new y = GetY("this");
new width = GetWidth(grass);
new height = GetHeight(grass);

    // Draw the enemy standing still
    if (GetAnimCount(DeadAnim) < 5)
        if (isVisible("this"))
		{
			if(state == falling)
			{
			DrawAnim(strugle,x, y - floatround(BounceAmount), y + height);
			}
			if(state == standing)
			{
			if(BounceAmount > 1)
			{
		PutSprite(MainImage, x, y - floatround(BounceAmount), y + height);
			}
		PutSprite(grass, (x + width / 2) - 8, y + height, 2);
			}
		}  	

    // Overlay the death animation over the enemy
    CallFunction("_enemylib", true, "HandleDying", "ss", DeadAnim, LastImage);   
    SetHealth("this", 0);
    SetValue("this",0);
}
//----------------------------------------
// Name: WalkTo()
//----------------------------------------
public WalkTo( x, y, instruction )
{
	if(!isActive("this")|| isDead("this")|| GetState("this")== falling || GetState("this")== dying || GetState("this")== hit)
	return;
	if ( instruction != -1 )
	{
		if ( instruction != GetValue("this", 4) ) // Check this is the current instruction		
			return 0;
	}
		
	// Handle this in the NPC library
	return CallFunction("_npclib", true, "WalkTo", "nnn", x, y, instruction);
	return 0;
}

//----------------------------------------
// Name: GetInstruction()
//----------------------------------------
public GetInstruction()
{
	// Return the current Person Script instruction
	return GetValue("this", 4);
}
//----------------------------------------
// Name: SetInstruction()
//----------------------------------------
public SetInstruction( NewInstruction, instruction )
{
	if ( instruction != -1 )
	{
		if ( instruction != GetValue("this", 4) ) // Check this is the current instruction
			return 0;
	}
	
	// The quest maker can use this to reset the npc's person script
	// back to any point, or foward.
	SetValue("this", 4, NewInstruction);
	return 1;
}
//-------------------------
//CheckForGrass()
//-------------------------
CheckForGrass()
{
new temp[20];
  
   // Go to the start of the Entity List
   StartEntity(300);
   
   // Loop through all the entities within a certain distance
   do
   {
      ToString(GetCurrentEntity(), temp);
       
      if (!isActive(temp) && GetType(temp) == otherType && GetWeight(temp)== 80)
      {
         // Check if the sword collides with the current entity
         if (NearPoint(GetX("this")+ 8, GetY("this")+ 8, GetX(temp)+ 8, GetY(temp)+ 8, 15))
         {
         SetState("this",falling);
         }
      }
      if (GetValue("this", 0)!= 0 && GetValue("this", 1)!= 0)
			{
			SetX("this",GetValue("this", 0));
			SetY("this",GetValue("this", 1));
			
			}
	}
	while(NextEntity())
}
//-----------------------------------------------
//RandomItem()
//-----------------------------------------------
RandomItem()
{
//This enemy should always give some kind of item
	if(random(3)== 0)
	{
	SetItem("this","_itemheart");
	}
	else if(random(3)== 1)
	{
	SetItem("this","_itemrupeeg");
	}
	else if(random(3)== 2)
	{
	SetItem("this","_itemrupeeb");
	}
	
}