#include <public_events>

/* Public Function */
forward PUBLIC_EVENT_HIT;

stock Fixed:mqEntityPosition.x, Fixed:mqEntityPosition.y, Fixed:mqDisplayZIndex;
stock mqDisplayArea.x, mqDisplayArea.y, mqDisplayZIndex, mqDisplayLayer;
new ang = 0;



public Init( ... )
{
	GetEntityPosition( mqEntityPosition.x, mqEntityPosition.y, mqDisplayZIndex, mqDisplayArea.x, mqDisplayArea.y, mqDisplayZIndex, mqDisplayLayer);

}

main()
{
	CollisionSet(SELF, 1, TYPE_ENEMY, mqDisplayArea.x, mqDisplayArea.y, 32, 32 );
	DebugText("Last Angle: %d", ang);

	GraphicsDraw("", RECTANGLE, mqDisplayArea.x+fround(fsin(ang, degrees)*64), mqDisplayArea.y+fround(fcos(ang, degrees)*64), 4, 32,32, BLACK);


}

PUBLIC_EVENT_HIT
{
	//Hit( attacker[], angle, dist, attack, damage, x, y, rect )
	ang = angle;



}