/***********************************************
 *
 ***********************************************/
#include <quest_types>
forward public Hit( attacker[], angle, dist, attack, damage, x, y,rect );

stock Fixed:_x_, Fixed:_y_, Fixed:_z_;
stock dx, dy, dz;
new Fixed:_angle_ = 270.0;
new active = 0;
new _speed_ = 80;
new obj = -1;

public Init( ... )
{
	EntityGetPosition(_x_, _y_, _z_);
	dx = fround(_x_, round_unbiased)+16;
	dy = fround(_y_, round_unbiased)+16;
	dz = fround(_z_, round_unbiased);

	obj = ObjectCreate("aquamentus.png:flame", SPRITE, dx, dy, 5, 32, 32);
	ObjectEffect(obj,_,_,2000,2000);
	AudioPlaySound( "effect_fire1.wav", dx, dy );

	if ( numargs() )
		_angle_ = Fixed:getarg(0);
}

public Close()
{
	ObjectDelete( obj );
}

main()
{
	active += GameFrame();
	if ( active > 7000 )
	{
		EntityDelete();
		return;
	}

	new Fixed:speed =  _speed_ * GameFrame2();
	new Fixed:movex = fsin(_angle_, degrees) * speed;
	new Fixed:movey = fcos(_angle_, degrees) * speed;

	_x_ += movex;
	_y_ += movey;

	dx = fround(_x_, round_unbiased)+16 ;
	dy = fround(_y_, round_unbiased)+16;

	if ( MaskGetValue(dx, dy) > 200 )
		EntityDelete();

	ObjectPosition(obj, dx-16, dy-16, 5, 0, 0);
	CollisionFromObject(obj, TYPE_ENEMY);
}

public Hit( attacker[], angle, dist, attack, damage, x, y,rect )
{
	if ( attack&APLAYER == APLAYER )
	{
		EntityPublicFunction( attacker, "Hurt", "nn", AFIRE, 50 );
		EntityDelete();
	}
	else if ( attack&ASHIELD == ASHIELD )
	{
		EntityDelete();
	}

}

