/*********************************************** 
 * Copyright © Luke Salisbury 
 * 
 * You are free to share, to copy, distribute and transmit this work 
 * You are free to adapt this work 
 * Under the following conditions: 
 *  You must attribute the work in the manner specified by the author or licensor (but not in any way that suggests that they endorse you or your use of the work).  
 *  You may not use this work for commercial purposes. 
 * Full terms of use: http://creativecommons.org/licenses/by-nc/3.0/ 
 * Changes: 
 *     2010/01/11 [luke]: new file. 
 ***********************************************/ 
#include <mokoi_quest> 
#include <core> 

 
forward PUBLICFUNCTIONHIT 
 
new bouncing = false; 
new initialBounce; 
new willTimeOut = false; 
new TempBounce;     
new ImageAlpha = 255; 
new Fixed:bounceVelocity = 0.00; 
new Fixed:bounceY; 
new param; 
new width; 
new height; 
new worth = 0; 
 
new playSound = true; 
new pickable = true; 
 
new object:obj = NULLOBJECT; 
new object:shadow = NULLOBJECT; 
 
new type = 1; 
new GraphicTypes:sprite_type = SPRITE; 
new sprite[64]; 
new numstring = 0; 
 
 
public Init(...) 
{ 
	if ( numargs() > 0 ) 
		worth = getarg(0); 
	else 
		worth = 1; 
 
	dw = MiscGetWidth(sprite); 
	dh = MiscGetHeight(sprite); 
 
	GetEntityPosition(_x_, _y_, _z_, dx, dy, dz);
	InitDropItem( worth );  

	obj = ObjectCreate(sprite, sprite_type, dx, dy, dz,0,0,WHITE); 
	shadow = ObjectCreate( "", CIRCLE, dx, dy+24, 2, 16, 8, 0x000000DD );
	
	//LanguageString(line, returnstring[], maxlength=sizeof returnstring); 
} 
 
 
public Close() 
{ 
	ObjectDelete(obj); 
	ObjectDelete(shadow); 
} 


new errormessage[64]
main() 
{ 
	if ( pickable ) 
	{ 
		GetEntityPosition(_x_, _y_, _z_, dx, dy, dz);
		CollisionSet(SELF, 0, 0, dx, dy, dw, dh);
		ObjectPosition(obj, dx, dy - fround(bounceY), dz, 0, 0); 
	}
	DrawCharacter(worth, dx, dy, dz, WHITE, 255);

	// If the Item has been out for too long then make it disappear 
	if ( willTimeOut ) 
		TimeOut(); 
	 
	if ( bouncing ) 
		Bounce(); 
} 
 
DrawCharacter(number, px, py, pz, colour, alpha)
{
	new gfx[20];
	strformat(gfx, _, _, "alpha02.png:%d", number+48);
	GraphicsDraw(gfx, SPRITE, px, py, pz, 0, 0);
	return MiscGetWidth(gfx);
}


TimeOut() 
{ 
	static timer = 0; 
	static alpha = 25500; 
	 
	timer += GameFrame(); 
	 
	if ( timer > 10000 ) 
	{ 
		alpha -= GameFrame(); 
		ImageAlpha = alpha / 10; 
		 
		if ( alpha < 0 ) 
			EntityDelete(); 
	} 
} 
 
public StartBounce() 
{ 
	CollisionSet(SELF, 0, 0); 
	 
	bouncing = true; 
	bounceVelocity = 160.00; 
	bounceY = 0.00; 
	TempBounce = 120; 
	 
	initialBounce = _y_; 
	willTimeOut = true; 
} 
 
Bounce() 
{ 
	bounceVelocity -= GameFrame(); 
	bounceY += (bounceVelocity * GameFrame()); 
		 
	if ( initialBounce - fround(bounceY) > initialBounce ) 
	{ 
		if ( TempBounce < 20 ) 
		{ 
			bouncing = false; 
			pickable = true; 
		} 
		else 
		{ 
			bounceVelocity = fixed(TempBounce); 
			TempBounce = TempBounce / 2; 
			bounceY = 0.00; 
		} 
	} 
} 
 
PUBLICFUNCTIONHIT 
{ 
	EntityPublicFunction(attacker, "IncreaseItemCount", "nn", type, worth); 
	 
	if ( playSound ) 
		AudioPlaySound("powerup.wav"); 
	 
	EntityDelete(); 
}