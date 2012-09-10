#include <public_events>

/* Public Function */
forward PUBLICFUNCTIONHIT;

stock Fixed:_x_, Fixed:_y_, Fixed:_z_;
stock dx, dy, dz, dl;
new ang = 0;



public Init( ... )
{
	GetEntityPosition( _x_, _y_, _z_, dx, dy, dz, dl);

}

main()
{
	CollisionSet(SELF, 1, TYPE_ENEMY, dx, dy, 32, 32 );
	DebugText("Last Angle: %d", ang);

	GraphicsDraw("", RECTANGLE, dx+fround(fsin(ang, degrees)*64), dy+fround(fcos(ang, degrees)*64), 4, 32,32, BLACK);


}

PUBLICFUNCTIONHIT
{
	//Hit( attacker[], angle, dist, attack, damage, x, y, rect )
	ang = angle;



}