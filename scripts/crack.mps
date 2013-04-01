/***********************************************
 * 
 ***********************************************/

#include <open_zelda>


new doorOpen[64];	// String to hold the sprite of the Door's Arch
new doorClose[64];	// String to hold the sprite of the Door's Arch
new doorArch[64];	// String to hold the sprite of the Door's Arch
new doorAnim[64];	// String to hold the sprite of the Door's Arch
new width;		// Used to store the widht and height of the door

new height;
new offset = 4;

new xoffset;

new yoffset;

new bool:open = false;
new sprite[64];
new obj = -1;
new arch = -1;
public Init(...)

{
	mqType = TYPE_DOOR;
	EntityGetSetting("object-sprite", doorOpen);
	
	strformat(doorClose, _, _, "%s-closed", doorOpen);
	strformat(doorArch, _, _, "%s-arch", doorOpen);
		
	EntityGetPosition(mqEntityPosition.x,mqEntityPosition.y, mqDisplayZIndex);
	UpdateDisplayPosition();
	obj = ObjectCreate(doorOpen, 's', mqDisplayArea.x, mqDisplayArea.y, 2, 0, 0);
	width = MiscGetWidth(doorOpen);

	height = MiscGetHeight(doorOpen);
	if ( MiscGetHeight(doorArch) )
	{
		arch = ObjectCreate(doorArch, 's', mqDisplayArea.x, mqDisplayArea.y, 4, 0, 0);
	}
	CloseDoor();
}


public OpenDoor()
{
	open = true;
	MaskFill(mqEntityPosition.x + xoffset, mqEntityPosition.y + yoffset, width - (xoffset*2), height - (yoffset*2), 255);
	CollisionSet(SELF, 0);
	ObjectReplace(obj, doorAnim, 'a'); 
	ObjectFlag(obj, FLAG_ANIMLOOP, false);
}

public CloseDoor()
{
	open = false;
	MaskFill(mqEntityPosition.x, mqEntityPosition.y, width, height, 255);
	CollisionSet(SELF, 0, mqType, mqDisplayArea.x, mqDisplayArea.y, width, height);
	ObjectReplace(obj, doorClose, 's');
}



main()

{

	

}



//----------------------------------------

// Name: Hit(attacker[], type, damage, x, y, rect)

//----------------------------------------

public Hit(attacker[], type, damage, x, y, rect)

{

	// Check if an explosion hit the wall

	if ( type&AEXPLOSION == AEXPLOSION )

		OpenDoor();
	else if ( type&ASWORD == ASWORD )

		AudioPlaySound("swordclink.wav", x, y);

}



