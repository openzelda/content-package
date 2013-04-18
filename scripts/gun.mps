#include <public_events>
#include <controller>
/* Init function is the call before anything else */
public Init(...)
{
	
}

/* Close function when it is deleted' */
public Close()
{
	
}

main()
{
	new x = InputPointer(0);
	new y = InputPointer(1);

	GraphicsDraw("", CIRCLE, x - 4, y - 4, 5000, 8, 8);
	CollisionSet(SELF, 0, 99, x - 4, y - 4, 8, 8);

	
	if ( CollisionCalculate() )
	{
		new entityId:current;
		new angle;
		new dist;
		new rect;
		new type;

		while ( CollisionGetCurrent(SELF, current, angle, dist, rect, type) )
		{
			if ( InputButton(BUTTON_POINTER_PRESS) )
			{
				CallEntityHit(current, entityId:0, random(360), dist, ASWORD, 50, x, y, rect);
			}
			CallEntityAwaking(current, entityId:0, rect);
		}
	}


}
