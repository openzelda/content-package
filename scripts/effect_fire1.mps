/***********************************************
 *
 ***********************************************/
#include <mokoi_quest>

new timeout = 1;
new object:obj = NULLOBJECT;

public Init( ... )
{
	new length = 1;
	EntityGetPosition(_x_,_y_, _z_);
	UpdateDisplayPosition();
	obj = ObjectCreate("fire1.png:1", SPRITE, dx, dy, 4, 0, 0);
	timeout = AnimationGetLength("fire1.png:1") * length;
	AudioPlaySound("fire1.wav", dx, dy);
}

public Close()
{
	ObjectDelete(obj);
}


main()
{
	if ( _state_ == DYING )
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

