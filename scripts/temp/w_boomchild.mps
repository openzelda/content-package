/***********************************************
*
***********************************************/
#include <foreign/journey>
#include <float>
#include <core>

new obj = -1;
new timeActive = 0;
new float: airtime = 0.00;
new float: sparkleCount = 0.00;
new float: soundFXCount = 20.00;
new hitSomthing = false;
new wimage[64];
new parent[64];
new type = 'r';
new float: rotation = 0.00;
new range = 80;
new sparkleAmount = 0;

new event_id = -1;

public Init(...)
{
	//Check args for type
	//parent = 
	if (type == 'r') // Red
	{
		wimage = "weapon1.png:boom_red";
		range = 50;
	}
	else if (type == 'g') // Gold
	{
		wimage = "weapon1.png:boom_gold";
		range = 80;
		speed = 180;
		sparkleAmount = 12000;
	}
	else if (param == 'b') // Blue/ice
	{
		wimage = "weapon1.png:boom_blue";
		range = 90;
		speed = 180;
		sparkleAmount = 8000;
	}

	event_id = EntityCallFunction("events", "add_timer", "ReplayAudio", "w_boomerang.wav");
}

public Close()
{
	EntityCallFunction("events", "remove_timer", event_id);
}

public Collision(_type, )
{
	if ( _type == ENEMY )
	{
		hitSomthing = true;
				// If this is an ice boomerang then deal some ice damage
				if (param == 'r')
				{
					CallFunction( temp, false, "HitByWeapon", "snnn", "stun", 100, x, y);
					PlaySound("e_hurt.wav", 240);
					hitSomthing = true;
				}
				else if (param == 'g')
				{
					CallFunction( temp, false, "HitByWeapon", "snnn", "weapon", 100, x, y);
					hitSomthing = true;
				}
				else
					CallFunction( temp, false, "HitByWeapon", "snnn", "ice", 50, x, y);
	}
}

main()
{
	// Dont allow this entity to live for too long if it doesnt hit anything
	timeActive += GameFrame();
	if ( timeActive > 5000)
		EntityDelete();
		
	if ( !hitSomthing )
		EntityDelete();
	else
		BoomReturn();
		
	// Create a sparkly effect from the boomerang
	if ( sparkleAmount > 0)
	{
		sparkleCount += 100 * GameFrame();
		if ( sparkleCount > sparkleAmount )
		{	
			EntityCreate("fx_sparkle1", _pos_[0] + random(8), _pos_[1] + random(8), "*");
			sparkleCount = 0;
		}
	}
}

//----------------------------------------
// Name: MoveBoomerang()
//----------------------------------------
MoveBoomerang()
{
	new Buffer[20];
	
	if (GameState() == 1)
	{
		// Move the Boomerang
		AngleMove();
	
		// Test for a collision on the mask layer
		if ( AngleCollide(3, 3, 126, 0, 8, 8) )
		{
			// Make a small explosion effect
			EntityCreate("fx_explosion2", _pos_[0] + 8, _pos_[1] + 8, "*");
			AudioPlaySound("_swordclash.wav", _pos_[0] + 8, _pos_[1] + 8);
			hitSomthing = true;
		}
	}
	
	// Advance a counter to check how long its been in the air
	airtime += GameFrame();
	if ( airtime > range)
		hitSomthing = true;
	
	DrawBoom();	
}

//----------------------------------------
// Name: BoomReturn()
//----------------------------------------
BoomReturn()
{
	new Float:detect = 8.0;
	new Float:px, Float:py;
	EntityGetPosition(px, py, _z_, parent);
	
	
	if (GameState() == 1)
	{
		// Make the boomerang head towards the player
		_angle_ = CalculateAngle(_posf_[0], _posf_[1], px, py);
		AngleMove();
		
		// If the boomerang is near enough to the player then take it back
		if ( px >= _posf_[0] - detect && px <= _posf_[0] + detect)
		{
			if ( py >= _posf_[1] - detect && py <= _posf_[1] + detect)
			{
				EntityDelete();	// Player has the boomerang
			}
		}
		
		// If the boomerang is too far from the player then just return it anyway, this ensures
		// that it wont be lost, this is why the boomerang must be active all the time, even if the player
		// is way off the screen.
		if ( px < _posf_[0] - 300 || px > _posf_[0] + 300 || py < _posf_[1] - 300 || py > _posf_[1] + 300)
		{
			// Player has the boomerang
			EntityDelete();
		}
	}
	
	DrawBoom();
}

//----------------------------------------
// Name: DrawBoom()
//----------------------------------------
DrawBoom()
{
	// Make the weapon spin
	rotation += 900 * GameFrameFloat();
	if ( rotation >= 355.00 )
		rotation = 1.00;
	
	ObjectPosition(obj, _pos_[0], _pos_[1], _pos_[2], 0, 0);
	ObjectEffect(obj, _, floatround(rotation), _, _, _);
	CollisionSet(0, x - 4, y - 4, x + 4, y + 4);
}

//----------------------------------------
// Name: EndBoomerang()
//----------------------------------------
EndBoomerang()
{
		
}
