/***********************************************
 *
 ***********************************************/
#include <open_zelda>

new timeout = 1;
new object:obj = OBJECT_NONE;

public Init( ... )
{
	new length = 1;
	EntityGetPosition(mqEntityPosition.x,mqEntityPosition.y, mqDisplayZIndex);
	UpdateDisplayPosition();
	obj = ObjectCreate("fire1.png:1", SPRITE, mqDisplayArea.x, mqDisplayArea.y, 4, 0, 0);
	timeout = AnimationGetLength("fire1.png:1") * length;
	AudioPlaySound("fire1.wav", mqDisplayArea.x, mqDisplayArea.y);
}

public Close()
{
	ObjectDelete(obj);
}


main()
{
	if ( mqState == DYING )
	{
		if ( Countdown(timeout) )
			EntityDelete();
	}
	else
	{
		if ( Countdown(timeout) )
		{
			ObjectReplace(obj, "fire1.png:2", SPRITE );
			ObjectFlag(obj, FLAG_ANIMLOOP, 0);
			timeout = AnimationGetLength("fire1.png:2");
		}
	}
}

