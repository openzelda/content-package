/***********************************************

 * 
 ***********************************************/

#include <open_zelda>


new obj = -1;
new timeout = 0;

public Init(...)
{
	EntityGetPosition(mqEntityPosition.x,mqEntityPosition.y, mqDisplayZIndex);
	UpdateDisplayPosition();
	obj = ObjectCreate("explosion.png:2", mqDisplayArea.x, mqDisplayArea.y, 4, 0, 0);
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

