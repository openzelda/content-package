/*********************************************** 
 * Copyright © Luke Salisbury 
 * 
 * You are free to share, to copy, distribute and transmit this work 
 * You are free to adapt this work 
 * Under the following conditions: 
 *  You must attribute the work in the manner specified by the author or licensor (but 
 *    not in any way that suggests that they endorse you or your use of the work).  
 *  You may not use this work for commercial purposes. 
 * Full terms of use: http://creativecommons.org/licenses/by-nc/3.0/ 
 * Changes: 
 *     2010/01/11 [luke]: new file. 
 ***********************************************/ 
#include <public_events> 
 
forward PUBLIC_EVENT_HIT 
forward public StartBounce();
 
new bouncing = false; 
new Fixed:bounceVelocity = 0.00; 
new Fixed:bounceY; 

new willTimeOut = false; 
new imageAlpha = 0xFFFFFFFF; 

new worth = 1; 
 
new playSound = true; 
new pickable = true; 
 
new object:shadowObject; 
 
new type = 1; 
new sprite{64}; 
new spriteType = SPRITE;
new msgString = 0; 
 
 
public Init(...) 
{ 
	if ( numargs() > 0 ) 
		worth = getarg(0); 


	InitDropItem( worth ); 

	SheetSpriteDimension(sprite, qDisplayArea.w, qDisplayArea.h );
 
	GetEntityPosition(qPosition.x, qPosition.y, qPosition.z, qDisplayArea.x, qDisplayArea.y); 

	if ( !EntityGetObject() )
	{
		qObject = ObjectCreate(sprite, SPRITE, qDisplayArea.x, qDisplayArea.y, qPosition.z, 0,0,WHITE);
		willTimeOut = true;
	}
	else
	{
		qObject = EntityGetObject();
	}
	shadowObject = ObjectCreate( "", CIRCLE, qDisplayArea.x, qDisplayArea.y+28, qPosition.z-1.000, 16, 8, 0x00000088 ); 

	StartBounce();
} 
 
 
public Close() 
{ 
	ObjectDelete(qObject); 
	ObjectDelete(shadowObject); 
} 
 
 
main() 
{ 
	if ( pickable ) 
	{ 
		CollisionSet(SELF, 0,TYPE_DROPITEM, qDisplayArea.x, qDisplayArea.y, qDisplayArea.w, qDisplayArea.h); 
	} 
 
	// If the Item has been out for too long then make it disappear 
	if ( willTimeOut ) 
		TimeOut(); 

	if ( bouncing ) 
	{
		Bounce(); 
		ObjectPosition(qObject, qDisplayArea.x, qDisplayArea.y - fround(bounceY), qPosition.z, 0, 0,WHITE); 
	}

	DrawItemNumber( qDisplayArea.x + 8, qDisplayArea.y +16 - fround(bounceY), qPosition.z + 0.1, imageAlpha );
	
} 

 
TimeOut() 
{ 
	static Fixed:timer = 0; 
	static Fixed:alpha = 255.0; 

	ConsoleOutput( " %q %q ", timer, alpha );
	timer += GameFrameSeconds(); 
	 
	if ( timer > 16.00 ) 
	{ 
		alpha -= 128.0 *GameFrameSeconds(); 

		if ( alpha <= 0 )
			EntityDelete();
		else
		{
			imageAlpha = 0xFFFFFF00 + fround(alpha, round_tozero); 
			ObjectEffect(qObject, imageAlpha);
		}
	} 
}

Bounce() 
{ 
	bounceVelocity -= GameFrameSeconds() * 100; 
	bounceY += (bounceVelocity * GameFrameSeconds()); 
		 
	if ( bounceY < 0.00 )  
	{
		bouncing = false; 
		willTimeOut = true;
		pickable = true;
		bounceY = 0;
	} 

} 

DrawItemNumber( x, y, Fixed:z, colour )
{
	// Some items will have numbers on them to say what they are
	// Worth, like bombs arrows etc.. this function will draw them in.
	// Have a pre-set list of numbers to draw
	if ( worth == 1)
		GraphicsDraw("dropitems.png:1", SPRITE, x, y, z, 0, 0, colour);
	else if ( worth == 2 )
		GraphicsDraw("dropitems.png:2", SPRITE, x, y, z, 0, 0, colour);
	else if ( worth == 5 )
		GraphicsDraw("dropitems.png:5", SPRITE, x, y, z, 0, 0, colour);
	else if ( worth == 10 )
	{
		GraphicsDraw("dropitems.png:1", SPRITE, x - 2, y, z, 0, 0, colour);
		GraphicsDraw("dropitems.png:0", SPRITE, x + 6, y, z, 0,  0, colour);
	}
	else if ( worth == 20 )
	{
		GraphicsDraw("dropitems.png:2", SPRITE, x - 2, y, z, 0,  0, colour);
		GraphicsDraw("dropitems.png:0", SPRITE, x + 6, y, z, 0, 0, colour);
	}
	else if ( worth == 50 )
	{
		GraphicsDraw("dropitems.png:5", SPRITE, x, y, z, 0,  0, colour);
		GraphicsDraw("dropitems.png:0", SPRITE, x + 10, y, z, 0,  0, colour);
	}
	else if ( worth == 100 )
	{
		GraphicsDraw("dropitems.png:1", SPRITE, x - 2, y, z, 0,  0, colour);
		GraphicsDraw("dropitems.png:0", SPRITE, x + 6, y, z, 0,  0, colour);
		GraphicsDraw("dropitems.png:0", SPRITE, x + 14, y, z, 0,  0, colour);
	}
	else if ( worth == 200 )
	{
		GraphicsDraw("dropitems.png:2", SPRITE, x - 2, y, z, 0,  0, colour);
		GraphicsDraw("dropitems.png:0", SPRITE, x + 6, z, 0,  0, colour);
		GraphicsDraw("dropitems.png:0", SPRITE, x + 14, y, z, 0,  0, colour);
	}

}

public StartBounce() 
{ 
	CollisionSet(SELF, 0, 0); 
	 
	bouncing = true; 
	bounceVelocity = 36.00; 
	bounceY = 0.00; 
	 
	//willTimeOut = true; 
} 
 

 
PUBLIC_EVENT_HIT 
{
	if ( attack == APLAYER )
	{ 
		EntityPublicFunction(attacker, "IncreaseItemCount", ''nn'', 2, type, worth); 
	 
		if ( playSound ) 
			AudioPlaySound("effect_powerup.wav"); 
	 
		EntityDelete();
	} 
}