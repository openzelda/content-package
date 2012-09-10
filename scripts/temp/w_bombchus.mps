/***********************************************
 * pbombchuweapon - Players bombchu weapon
 * 
 * Author: Kouruu - based off of _pbombweapon1
 * Date:   January 1, 2005
 *
 * Desc:   Script to allow the player to use bombchus as
 *		   a weapon, this script needs the actual bombchu
 *		   script - bombchuweapon to be included as well.
 * 
 * Usage:  Use in the players script
 * Changes: 22/02/2005 [lukex] : removed the need to change the main script.
 *         
 ***********************************************/
#include <foreign/journey>
#include <counter>
#include <float>
new float: timer = 0.5;

main()
{
	if (FirstRun())
	{
		// Set the image which appears in the start menu
		SetImage("this", "bombchuicon");
		
		// Set this entity's basic type
		SetType("this", weaponType);
	   
		// Create 2 string for the weapons descriptions
		AllocateStrings("this", 2, 64);	
		SetString("this", 0, "You Got Bombchus!  Set it and watch it run! :)");
		SetString("this", 1, "Bombchus");
		SetOwnedFlag("this", true);		// Bombchus are always avaiable on the menu
	}
	SetActiveDist("this", -1);
	if(timer < 0.5)
	{
		timer += GetTimeDelta();
	}
}


//----------------------------------------
// Name: Init()
//----------------------------------------
public Init()
{
	if(timer < 0.5)
		return -1;
	// Check the player actually has some bombchus
	if (GetCounterValue("bombchus") < 1)
	{
		// no bombchus
		PlaySound("_error.wav", 240);
		// Return control back to player entity
    		SetState("player1", standing);
		timer = 0;
		return -1;
	}

	// Decrease bombchu amount by 1
	IncCounterValue("bombchus", -1);
	// Play the sound of a bombchu being laid
	PlaySound("_bombplaced.wav", 240);
   
	new EntName[20];
	new x = GetX("player1");
	new y = GetY("player1");
	new dir = GetDirection("player1");
	
	// Adjust the bombchus position based on the player's direction
	if ( dir == north )
		y -= 12;
	else if ( dir == east )
		x += 12;
	else if ( dir == south )
		y += 12;
	else if ( dir == west )
		x -= 12;
			
	// We dont have to do much here - just create a bombchu entity
	// in front of the player.
	CreateEntity("w_bombchu", x, y, EntName);
	
	// Return control back to player entity
	SetState("player1", standing);
	timer = 0;
	return -1;
}