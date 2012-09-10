/***********************************************
 * Copyright (c) 2004-2006 Editors
 * Changes:  
 *	19/08/02 [lukex]: New file.
 *	01/12/02 [Satanman]: Added Different types of Arrows, some bug fixing.
 *	19/08/03 [lukex]: Added Tunic Support.
 *	26/04/05 [lukex]: Added Arrow Selections.
 *	10/05/05 [lukex]: Added Quiver Support.
 ***********************************************/

#include <animation>
#include <foreign/journey>
#include <counter>
#include <core>


const DEBUGSCRIPT = 0;
const arrowsType = 20;

new keyFirstPress = false;
new arrowNeeded = 1;	// arrows needed to fire the weapon
		// magic needed to fire the weapon
new param;
new Anim[4][20]; // Create 4 strings to store the Identifiers of the Player animations for each direction
new wimage[4][] = {"_bow1n", "_bow1e", "_bow1s", "_bow1w" }; // Create an array of strings to hold the names
new PlayerSuit = 1; 			// Player suit (Mar. 03)
new LastPlayerSuit = 1;
new arrowType = 0;
new arrowsOwned[7] = "n";
new arrowsNamed[6][7] = {"Normal", "Fire", "Ice", "Light", "Bomb", "Silver"};
new magicNeeded = 0;
new magicNeededArray[6];

new menuCurrent = 0;

main()
{
	if (FirstRun())
	{
		SetType("this", weaponType);
		param = GetParam("this");
		AllocateStrings("this", 2, 100);
		SetImage("this", "w_bow1");
		
		if (param == '2')
		{
			if ( GetCounterMax("arrows") == -1 )
			{
				CreateCounterWithID(0, 20,  "arrows");
				CallFunction("_itemlib", false, "AddItem", "sn", "_itemarrow1", 65);  // 1 arrow
				CallFunction("_itemlib", false, "AddItem", "sn", "_itemarrow2", 20);  // 5 arrows
				CallFunction("_itemlib", false, "AddItem", "sn", "_itemarrow3", 7);   // 10 arrows
				CallFunction("_itemlib", false, "AddItem", "sn", "_itemarrow4", 1);   // 20 arrows
				SetCounterTarget("arrows", 20);
			}
			SetString("this", 0,  "You got the bow! Give it a try!");		// For Chests
			SetString("this", 1,  "Long Bow");	// For menu      
			SetImage("this", "w_bow2");
			SetValue("this", 2, 4); //So Menu know it uses arrows
			SetOwnedFlag("this", 1);
			printf("Long Bow Created");
		} 
		else if (param == '1')
		{
			if ( GetCounterMax("arrows") == -1 )
			{
				CreateCounterWithID(0, 20,  "arrows");
				CallFunction("_itemlib", false, "AddItem", "sn", "_itemarrow1", 65);  // 1 arrow
				CallFunction("_itemlib", false, "AddItem", "sn", "_itemarrow2", 20);  // 5 arrows
				CallFunction("_itemlib", false, "AddItem", "sn", "_itemarrow3", 7);   // 10 arrows
				CallFunction("_itemlib", false, "AddItem", "sn", "_itemarrow4", 1);   // 20 arrows
				SetCounterTarget("arrows", 20);
			}
			SetString("this", 0,  "You got the bow! Give it a try!");		// For Chests
			SetString("this", 1,  "Normal Bow");	// For menu      
			SetImage("this", "w_bow1");
			SetValue("this", 2, 4); //So Menu know it uses arrows
			SetOwnedFlag("this", 1);
			printf("Normal Bow Created");
		
		} 
		else 
		{
			SetType("this", arrowsType);
			if (param == 'n')
			{
				SetImage("this", "w_bown");
				
				magicNeeded = 0;
				arrowsOwned = "";
			} 
			else if (param == 'f')
			{
				SetString("this", 0,  "You got fire arrows! These magic arrows leave a trail of fire in their wake!");	// For Chests
				SetImage("this", "w_bowf");	
				magicNeeded = 2;
				arrowsOwned = "";
			} 
			else if (param == 'i')
			{
				SetString("this", 0,  "You got ice arrows! These magic arrows freeze anything they come across!");		// For Chests
				SetImage("this", "w_bowi");
				magicNeeded = 2;
				arrowsOwned = "";
			} 
			else if (param == 'l')
			{
				SetString("this", 0,  "You got light arrows! The light of justice shalt smite evil in ye olde english!");		// For Chests
				SetImage("this", "w_bowl");
				magicNeeded = 6;
				arrowsOwned = "";
			} 
			else if (param == 'b')
			{
				SetString("this", 0,  "You got bomb arrows! These arrows explode on contact, so don't drop them!");		// For Chests
				SetImage("this", "w_bowb");
				magicNeeded = 4;
				arrowsOwned = "";
			}
			else if (param == 's')
			{
				SetString("this", 0,  "You got silver arrows! Now you can take out werewolfs in one shot.");		// For Chests
				SetImage("this", "w_bowb");
				magicNeeded = 4;
				arrowsOwned = "";
			}
			SetValue("this", 3, magicNeeded);
			SetOwnedFlag("this", 1);
		}


		// Create the Animations
		for ( new n = 0; n < 4; n++ )
		{
			CreateAnim(6, Anim[n]);
			SetAnimLoop(Anim[n], false);
		}

		SetPlayerSuit(PlayerSuit);
	}
	/*  Debugging */
	if (DEBUGSCRIPT)
	{
	  	ConsoleNumber("arrowType", arrowType );
	  	for (new n = 0; n < 7; n ++) 
		{
			ConsoleNumber( "arrowsOwned[]", arrowsOwned[n] );
		}
		ConsoleNumber("currentArrow", arrowsOwned[arrowType] );
		ConsoleNumber("GetValue(this, 0)", GetValue("this", 0) );
	}
	/*  Debugging */
}

public MenuSelected()
{
	new x = GetX("player1");
	new y = GetY("player1");
	SetX("this", x);
	SetY("this", y);
	UpdateMenu();
	return 2;
}
public MenuUnselected()
{
	return -1;
}
public SubMenu()
{
	new n = 0;
	new image[7] = "w_bowx";
	while (arrowsOwned[n])
	{
		image[5] = arrowsOwned[n];
		DrawColourImage(image, 30 + (n * 40), 400, (menuCurrent == n ? White : Gray), .scale = 200);
		n++;
	}
	if (LeftKey()) 
	{ 
		SetLeftKey(false); 
		if (menuCurrent < 1)
        	menuCurrent = 0
		else
			menuCurrent-- ;  
	} 
	if (RightKey()) 
	{ 
		SetRightKey(false);
		if (menuCurrent > n - 2 )
			menuCurrent = n - 1
		else
			menuCurrent++ ;   
	}
	
	
	if (GetAKey() || GetSKey() )
	{
		arrowType = menuCurrent
		magicNeeded = magicNeededArray[menuCurrent];
		return;	
	}
	return 1;
}
UpdateMenu()
{
	new ImageBuffer[20];
	new temp[20];
	new NumItems = 1;
	StartEntity(-1); 
	do  
	{
		ToString(GetCurrentEntity(), temp);
		
		if (GetType(temp) == arrowsType )  
		{
			// Get the image of the current item
			GetImage( temp, ImageBuffer );
								
			if (ImageBuffer[5] > 96)
			{
				arrowsOwned[NumItems] = ImageBuffer[5];
				magicNeededArray[NumItems] = GetValue(temp, 3);
				NumItems++;

			}
		}
	}while( NextEntity() )  	
}



//----------------------------------------
// Name: Init()
//----------------------------------------
public Init()
{
	if ( LastPlayerSuit != PlayerSuit )
 		SetPlayerSuit(PlayerSuit);


	// Reset all animations
	for ( new n = 0; n < 4; n++ )
		SetAnimCount(Anim[n], 0);

	new x = GetX("player1");
	new y = GetY("player1");
	SetX("this", x);
	SetY("this", y);
	SetDirection("this", GetDirection("player1"));
	PlaySound("w_arrow.wav", 240); 
	

	if (DEBUGSCRIPT)
	{
	  	ConsoleNumber("currentArrow", arrowsOwned[arrowType] );
	}

	keyFirstPress = true;
}
//----------------------------------------
// Name: DrawWeapon()
//----------------------------------------
public DrawWeapon( keyHeld )
{
	// Get the Correct Animation
	new dir = GetDirection("this");
	new width  = GetAnimWidth(Anim[dir]);
	new height = GetAnimHeight(Anim[dir]);
	new x = GetX("this");
	new y = GetY("this");
	new bowImages[2];
	new xoff[2];            // X and Y offsets for the bow images
	new yoff[2];	
	new sx;
	new sy;
	new AnimCount;
	new depth = y + height;

	if ( dir == north)
	{
		bowImages = {0,0};
		xoff = {-2, -2};
		yoff = {-2, -2};
		depth = y;
	}
	else if ( dir == east)
	{
		bowImages = {1,1};
		xoff = {11, 11};   
		yoff = {8, 8};   
	}
	else if ( dir == south)
	{
		bowImages = {2,2};
		xoff = {5, 5};
		yoff = {15, 15};
	}
	else if ( dir == west)
	{
		bowImages = {3,3};
		xoff = {-2, -2};
		yoff = {8, 8};      
	}

	// Draw the Player animation
	if (isVisible("player1"))
	{
		// Draw the Player
		if ( !keyHeld )
		{
			DrawAnim(Anim[dir], x, y, y + height);
		}
		else
		{
			DrawAnimNoInc(Anim[dir], x, y, y + height);
		}
		AnimCount = GetAnimCount(Anim[dir]);
		// Draw the image of the weapon
		sx = x + xoff[AnimCount];
		sy = y + yoff[AnimCount] - 9;
		PutSprite(wimage[bowImages[AnimCount]], sx, sy, depth);

		// Draw the Player's shadow
		PutSprite("shadow1", x, y, 2);		
		if (keyFirstPress)
		{
			keyFirstPress = false;
			if ( GetCounterValue("arrows") < arrowNeeded || GetCounterValue("magic") < magicNeeded)
			{
				// Player doesn't have enough of something
				PlaySound("_error.wav", 240);
				//SetState("player1", standing);
			}
			else
			{
				// Decrease arrow + magic counters
				IncCounterTarget("arrows", -arrowNeeded);
				IncCounterTarget("magic", -magicNeeded);
		
				
				ConsoleNumber("arrowType",arrowsOwned[arrowType]);
				if (arrowsOwned[arrowType] == 'f')
					CreateEntity("w_arrowf", x + 4, y + 4, "firearrow");
				else if (arrowsOwned[arrowType] == 'i')
					CreateEntity("w_arrowi", x + 4, y + 4, "icearrow");
				else  if (arrowsOwned[arrowType] == 'l')
					CreateEntity("w_arrowl", x + 4, y + 4, "lightarrow");
				else if (arrowsOwned[arrowType] == 'n')
					CreateEntity("w_arrown", x + 4, y + 4, "arrow");
				else if (arrowsOwned[arrowType] == 'b')
					CreateEntity("w_arrowb", x + 4, y + 4, "bombarrow");
			}
		}


	}
	else
		IncrementAnim(Anim[dir]);

	
	if ( !keyHeld )
	{
		// Check if the weapon animation is over
		if (FinishedAnim(Anim[dir]))
		{
			SetState("player1", standing); // Return control back to player entity
		}
	}
}


//-----------------------------------------------------
// Name: SetPlayerSuit()
// Desc: Changes the players Animation
//-----------------------------------------------------
public ChangePlayerSuit(ChangeTo) {
	PlayerSuit = ChangeTo;
}

public GetPlayerSuit() {
	return PlayerSuit;
}

SetPlayerSuit(NewPlayerSuit)
{
	LastPlayerSuit = NewPlayerSuit;
	for (new n = 0; n < 4; n++ )
	{
		DeleteAnim(Anim[n]);
		CreateAnim(6, Anim[n]);
	}
	// Add Frames to player Animations			
	if (NewPlayerSuit == 1)
	{
		AddAnimframe(Anim[0], 0, -9, "__swdn7");
		AddAnimframe(Anim[1], 0, -9, "__swde4");
		AddAnimframe(Anim[2], 0, -9, "__swds3");
		AddAnimframe(Anim[3], 0, -9, "__swdw4");	
	}
	else if (NewPlayerSuit == 2)
	{
		AddAnimframe(Anim[0], 0, -9, "__twdn7");
		AddAnimframe(Anim[1], 0, -9, "__twde4");
		AddAnimframe(Anim[2], 0, -9, "__twds3");
		AddAnimframe(Anim[3], 0, -9, "__twdw4");	
	}
	else if (NewPlayerSuit == 3)
	{
		AddAnimframe(Anim[0], 0, -9, "__uwdn7");
		AddAnimframe(Anim[1], 0, -9, "__uwde4");
		AddAnimframe(Anim[2], 0, -9, "__uwds3");
		AddAnimframe(Anim[3], 0, -9, "__uwdw4");	
	}
}
