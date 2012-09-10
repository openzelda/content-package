/***********************************************
 * Copyright (c) 2001-2005 Editors
 * Changes:  
 *	19/12/01 [GD]: New file.
  *	17/04/05 [lukex]: Added fix for w_ & i_ entities
 ***********************************************/

#include <foreign/journey>
#include <core>
#include <counter>
#include <float>


//==================================
//   Global Data
//==================================
// Create Strings to hold the sprite codes
new OpenSpr[20] =  "o_chest1";
new CloseSpr[20] = "o_chest1a";

new width;
new height;
new param;
// Create some General Purpose Strings
new String1[20];
new SubEntity[64];
new ItemDesc[512];

// Create a flag to idicate if the chest was just opened
new JustOpened = false;
new float: OpenCount = 0.00;

// Create another flag for fading the music back in
new MusicFadeIn = false;
new float: MusicFade = 50.00;

//----------------------------------------
// Name: main()
//----------------------------------------
main()
{
   if (FirstRun())
   {
		AllocateStrings("this", 2, 32);
      param = GetParam("this");
      OpenSpr[6] = param;
      CloseSpr[6] = param;
      // Make the Chest Empty initially
      SetItem("this", "nothing");

      // Set the active distance for this entity
      SetActiveDist("this", 190);

      // Set this entity's basic type
      SetType("this", otherType);
      width  = GetWidth(OpenSpr);
      height = GetHeight(OpenSpr);
   }

   if (JustOpened)
      JustOpen();

   if (MusicFadeIn)
   {
      // Fade the music back in
      MusicFade += 100 * GetTimeDelta();
      if (MusicFade > 200)
         MusicFade = 200.00;
      SetMusicVolume( floatround(MusicFade) );
      if (MusicFade == 200)
         MusicFadeIn = false;
   }
 
   if (isActive("this"))
   {
      new x = GetX("this");
      new y = GetY("this");
    
      // Set a single Collision Rectangle for the Chest
      SetCollisionRect("this", 0, true, x, y, x + width, y + height);

      if (!isOpen("this"))
      {
        // Draw the Chest if visible
        if (isVisible("this"))
           PutSprite(OpenSpr, x, y, 1);
 
         // Check if the Q Key is pressed
         if (QKey())
         {
            // Check if the Player wants to Open the Chest
            if (NearPoint(x, y + (height / 2), GetX("player1"), GetY("player1"), width - 2))
            {
               // Check if the player is facing north
               if (GetDirection("player1") == north)
               {
                  OpenChest();
               }
            }
         }
      }
      else
      {
         // Draw the Chest in a closed state if visible
         if (isVisible("this"))
           PutSprite(CloseSpr, x, y, 1);
      }
   }
   else
   {
   	ClearCollisionRect("this" , 0);
   }
}


//----------------------------------------
// Name: OpenChest()
//----------------------------------------
OpenChest()
{ 
   if ( param == '2' && !GetCounterValue("masterKey") )
	return;
   // Set the open flag
   SetOpenFlag("this", true);
   PlaySound("_openchest.wav", 240);
SubEntity = "";
   // Get the Entity Code of the Item inside, place it into the String1 array, which is global
   GetItem("this", String1); // request Item
   GetString("this", 0, SubEntity);
      
   // If the item in the chest is still nothing then quit
   if (strcmp(String1, "nothing") == 0)
   {
      PlaySound("_openchest.wav", 240);
      return;
   }
   SetState("player1", standing);
   /* Create a Child Entity for the Item inside the Chest, place
      it at the players coordinates so it is picked up immediately.
      copy this new entities unique identifier into the SubEntity 
      array, which is global */

   if ( strlen(SubEntity) > 2 )
   {
      CreateEntityWithID(String1, GetX("player1"), GetY("player1"), SubEntity);
      SetOwnedFlag(SubEntity, true);
      GetString(SubEntity, 0, ItemDesc); // Get the Item Description from the sub item and place it in ItemDesc
   }
   else
   {
	SubEntity = "";
      CreateEntity(String1, GetX("player1"), GetY("player1"), SubEntity);
      // IF the thing inside the chest is an enemy then we can leave it here
      // Watch the mayhem as an enemy is unleashed from the chest.
      if ( GetType(SubEntity) == enemyType)
      {
         PlaySound("_openchest.wav", 240);
         return;
      }
      SetOwnedFlag(SubEntity, true);
      GetString(SubEntity, 0, ItemDesc); // Get the Item Description from the sub item and place it in ItemDesc
   }
   printf(ItemDesc);
   // Make the Child entity invisble
   SetVisibleFlag(SubEntity, false);
   
   // Make sure the sub entity doesnt play a sound effect when it is taken
   // See the item scripts for more info on this
   SetValue(SubEntity, 0, 1);

   
   GetImage(SubEntity, String1); // Get the image code of the Child Entity and place it in String1
   
   
   // Set the IsOpen flag to true
   JustOpened = true;
   OpenCount = 0.00;

   // Pause the Game
   SetPauseLevel(1);

   // Set music volume a little lower
   SetMusicVolume(125);

}


//----------------------------------------
// Name: JustOpen()
//----------------------------------------
JustOpen()
{
   new x = GetX("this");
   new y = GetY("this");

   new width  = GetWidth(OpenSpr);
   new ItemWidth = GetWidth(String1);


   // Play sound only once
   if (OpenCount == 0.00)
   {
      SetMusicVolume(50);  // Set music volume even lower
      PlaySound("_chestitem.wav", 240);
   }

   // Increment the Counter
   OpenCount += 1 * GetTimeDelta();
	ConsoleText("chest image", String1);
   // Show the Item floating above the Chest
   PutSprite(String1, x + (width / 2) - (ItemWidth / 2), \
                      y - (floatround(OpenCount * 30)),  y);

   // if 1 second hasnt passed then return
   if (OpenCount < 1)
      return;

   SetPauseLevel(0);

   // Put the Text Box
   if (strlen(ItemDesc) > 1)
   {
      SetTextBoxColor(255, 255, 255, 255);
      InitTextBox(ItemDesc, 200, true);
   }

   // Set the music to fade back in
   MusicFadeIn = true;

   JustOpened = false;
}






