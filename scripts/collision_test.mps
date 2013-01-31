#include <open_zelda>
forward public Hit( attacker[], angle, dist, attack, damage, x, y, rect );
enum temphit
{
	text[40]
	linex,
	liney,
	lineangle
}

new strings[20][temphit];
new m = 0;
main()
{
	EntityGetPosition(_x_,_y_, _z_);
	UpdateDisplayPosition();

	CollisionSet(SELF,1,TYPE_ENEMY,dx,dy,16,16);


	for ( new q = 0; q < 20; q++)
	{
		GraphicsDraw(strings[q][text], TEXT, dx,dy+20+(q*8),5,0,0,WHITE);
		DrawAngledLine( strings[q/4][linex], strings[q/4][liney], strings[q/4][lineangle], 20+(q*4));
	}
}

DrawAngledLine( x,y,angle,length)
{
	new Fixed:movex =  fsin(angle, degrees) * length;
	new Fixed:movey = fcos(angle, degrees) * length;

	
	GraphicsDraw("",LINE, x,y, 4, x- fround(movex), y- fround(movey), 0x000000FF + (length <<16) );

}

public Hit( attacker[], angle, dist, attack, damage, x, y, rect )
{
	if ( m < 79 )
	{
		strformat(strings[m/6][text], _,true, "%s - %d", attacker, angle );
		strings[m/6][linex] = x;
		strings[m/6][liney] = y;
		strings[m/6][lineangle] = angle;
	}

	m++;
}