/***********************************************

 * 
 ***********************************************/

#include <mokoi_quest>


new obj = -1;
new timeout = 0;

public Init(...)
{
	EntityGetPosition(_x_,_y_, _z_);
	UpdateDisplayPosition();
	obj = ObjectCreate("explosion.png:2", dx, dy, 4, 0, 0);
	ObjectFlag(obj, FLAG_ANIMLOOP, 0);
	timeout = AnimationGetLength("explosion.png:2");
}

public Close()
{
	ObjectDelete(obj);
}


main()

{

	if ( Countdown(timeout) )
		EntityDelete();

}

