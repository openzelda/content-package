#define NOINITFUNCTION 1
#include <dungeon>
#include <helper>

forward public SetPlayerPosition(x, y, z);

new xx, yx, zx;
new timer = 100;
new Fixed:a = 1.0;
new Fixed:position[3][2] = { {272.0,96.0}, {336.0,240.0},{208.0,320.0} }; 

public SetPlayerPosition(x, y, z)
{
	xx = fround(Fixed:x)+8;
	yx = fround(Fixed:y)+32;
	zx = fround(Fixed:z);
}

main()
{
	if ( xx < 10 )
		return;
	if ( !MaskGetValue(xx+8, yx+8) )
	{
		if ( CountTimer( timer, 800 ) )
		{
			for ( a = 1.0; a < 380.0; a += 20.0 ) {
				EntityCreate("attack_flamethrower1", "*", position[0][0], position[0][1], 4.0, CURRENT_MAP, _, "d", a );
				EntityCreate("attack_flamethrower1", "*", position[1][0], position[1][1], 4.0, CURRENT_MAP, _, "d", a );
				EntityCreate("attack_flamethrower1", "*", position[2][0], position[2][1], 4.0, CURRENT_MAP, _, "d", a );
			}
		}
	}
}