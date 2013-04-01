/***********************************************
 *
 ***********************************************/
#include <open_zelda>
#include <core>

new mainAnim[20];
new parent[64];
new width = 1;
new height = 1;

new obj = -1;
new timeout = 0, length;

public Init(...)
{
	GetEntityPosition(mqEntityPosition.x, mqEntityPosition.y, mqEntityPosition.z, mqDisplayArea.x, mqDisplayArea.y, mqDisplayZIndex, mqDisplayLayer);;
	/*
	AddAnimframe(mainAnim, 0, 0, "_icerod10");
	AddAnimframe(mainAnim, 0, 0, "_icerod11");
	AddAnimframe(mainAnim, 0, 0, "__none");
	*/
	
	obj = ObjectCreate("icerod.png:1", SPRITE, mqDisplayArea.x, mqDisplayArea.y, 4, 0, 0);
	ObjectFlag(obj, FLAG_ANIMLOOP, false);
	length = AnimationGetLength("icerod1.png:1");
	timeout = length;
}

public Close()
{
	ObjectDelete(obj);
}

main()
{
	// Check if the animation is finsihed
	if ( Countdown(timeout) )
	{
		timeout = length;
		GetRandomSpot();	
	}
}


//----------------------------------------
// Name: SetArea()
//----------------------------------------
public SetArea( nx, ny, wid, hei )
{
	EntitySetPosition(nx,ny);
	mqEntityPosition.y = ny;
	mqEntityPosition.x = nx;
	width = wid;
	height = hei;
	GetRandomSpot();
}

//----------------------------------------
// Name: GetRandomSpot()
//----------------------------------------
GetRandomSpot()
{
	new border = 2;
	
	// Get a new random position for the sparkle
	mqEntityPosition.x = random(width - border*2)  + mqEntityPosition.x;
	mqEntityPosition.y = random(height - border*2) + mqEntityPosition.y;
	
	mqEntityPosition.x += border;
	mqEntityPosition.y += border;
}
