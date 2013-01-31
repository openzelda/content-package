#include <open_zelda>
#include <string>

native EntityNetworkSync();
native NetworkMessage(reliable, server, message[], length, reallength = sizeof(message));

forward public UpdatePosition();
forward public NetMessage( player, array[], size );
forward public Push(attacker[], rect, angle);

new obj =-1;
new audio = false;

public NetMessage(player, array[], size)
{
	if ( size )
	{
		MaskFill(dx, dy, dw, dh, 0);
		dx = GetBits( array[0], dx, 0, 16 );
		dy = GetBits( array[0], dy, 16, 16 );
		ObjectPosition(obj, dx, dy, dz, 0, 0);
		MaskFill(dx, dy, dw, dh, 255);
		CollisionSet(SELF, 0, TYPE_PUSHABLE, dx-1, dy-1, dw+2, dh+2);
		EntitySetPosition(_x_,_y_, _z_);
		UpdateDisplayPosition();
	}
}

public Init(...)
{
	dw = dh = 32; 
	dz = 2;
	_speed_ = 40.0;
	_type_ = TYPE_PUSHABLE;

	obj = EntityGetNumber("object-id");
	ObjectInfo(obj, dw, dh);
	EntityGetPosition(_x_,_y_, _z_);
	UpdateDisplayPosition();
	StorePosition();
	UpdatePosition();
}

public UpdatePosition()
{
	MaskFill(dx, dy, dw, dh, MASK_CLEAR );
	EntityGetPosition(_x_,_y_, _z_);
	UpdateDisplayPosition();
	StorePosition();
	ObjectPosition(obj, dx, dy, dz, 0, 0);
	MaskFill(dx, dy, dw, dh, MASK_BLOCK );
	CollisionSet(SELF, 0, TYPE_PUSHABLE, dx-1, dy-1, dw+2, dh+2);
}

public Close()
{
	MaskFill(dx, dy, dw, dh, MASK_CLEAR);
	CollisionSet(SELF, 0, 0);
}

public Push(attacker[], rect, angle)
{
	if ( _state_ != MOVING )
	{
		angle = (angle/45)*45;
		if ( !(angle % 90) )
		{
			_angle_ = fixed(angle);
			SoundPlayOnce(audio, "object_push.wav");
			_state_ = MOVING;
			if ( _angle_ < 0 )
				_angle_ += 360;
			_angle_ = 360 - _angle_;
		}
	}
}

Update()
{
	CollisionSet(SELF, 0, TYPE_PUSHABLE, dx-1, dy-1, dw+2, dh+2);
	new message[1];
	SetBits( message[0], dx, 0, 16 );
	SetBits( message[0], dy, 16, 16 );
	NetworkMessage(1, 0, message, 1);
	EntityNetworkSync();
}

main()
{
	if ( _state_ == MOVING )
	{
		_state_ = STANDING;
		MaskFill(dx, dy, dw, dh, MASK_CLEAR);
		if ( EntityMove( MASK_NORMALGROUND ) )
		{
			ObjectPosition(obj, dx, dy, dz, 0, 0);
			Update();
		}
		MaskFill(dx, dy, dw, dh, MASK_BLOCK);
	}
}
