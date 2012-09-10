#include <mokoi_quest>

new IceAnim[8][20];
new Fixed:timeActive = 0.0;
new Fixed:hitCounter = 0.0;
new hitSomthing = false;
new obj = -1;

public Init(...)
{
/*
	AddAnimframe(IceAnim[n], 0,0, "_icerod10");
	AddAnimframe(IceAnim[n], 0,0, "_icerod11");
*/
	EntityGetPosition(_x_, _y_, _z_);
	UpdateDisplayPosition()
	obj = ObjectCreate("_icerod10", dx, dy, 4, 0, 0);
}


public Close()
{

}

main()
{
/*
	timeActive += GameFrame2();
	if ( timeActive > 5.0 )
		EntityDelete();
	if ( hitSomthing )
		EndAnim();
	else
		MoveIceBlast();
		*/
}

//----------------------------------------
// Name: EndAnim()
//----------------------------------------
EndAnim()
{
	hitCounter += GameFrame();
	if ( hitCounter > 2.5)
		EntityDelete();
		
	if ( hitCounter < 1.2 )
	{
	/*
		PutSprite("_icerod13", x - 8, y - 8, y);
		PutSprite("_icerod13", x,     y - 8, y);
		PutSprite("_icerod13", x - 8, y, y);
		PutSprite("_icerod13", x, y, y);
		*/
	}
	else
	{
	/*
		PutSprite("_icerod14", x - 12, y - 12, y);
		PutSprite("_icerod14", x + 4,      y - 12, y);
		PutSprite("_icerod14", x - 12, y + 4, y);
		PutSprite("_icerod14", x + 4, y + 4, y);
		*/
	}
}

//----------------------------------------
// Name: MoveIceBlast()
//----------------------------------------
MoveIceBlast()
{
	new xf[2][4] = { {-2,   2, -2, -10}, {-6, 0, 0 ,-6}};
	new yf[2][4] = { {-10, -2,  2,  -2}, {-6, -6, 0, 0}};
	new xp[2];
	new yp[2];
	
	// Move the entity
	new dir = 0; //GetDirection("this");
	if ( dir == north )
	{
		_angle_ = 90.0;
		yp[0] = -14;
		yp[1] = -26;
	}
	else if ( dir == east )
	{
		_angle_ = 180.0;
		xp[0] = 14;
		xp[1] = 26;
	}
	else if ( dir == south )
	{
		_angle_ = 270.0;
		yp[0] = 14;
		yp[1] = 26;
	}
	else if ( dir == west )
	{
		_angle_ = 0.0;
		xp[0] = -14;
		xp[1] = -26;
	}
	//EntityMove();
	
	if ( timeActive > 200 )
		_speed_ = 220;
		
	if ( timeActive > 250 )
	{
		/*
			DrawAnim(IceAnim[0], x - xp[0] - 6, y - yp[0] - 6, y);
			DrawAnim(IceAnim[1], x - xp[0],     y - yp[0] - 6, y);
			DrawAnim(IceAnim[2], x - xp[0] - 6, y - yp[0],     y);
			DrawAnim(IceAnim[3], x - xp[0],     y - yp[0],     y);
			
			PutSprite("_icerod12", x - xp[1] - 3, 	y - yp[1] - 3, y);
			PutSprite("_icerod12", x - xp[1] + 1, 	y - yp[1] - 3, y);
			PutSprite("_icerod12", x - xp[1] - 3, 	y - yp[1] + 1, y);
			PutSprite("_icerod12", x - xp[1] + 1, 	y - yp[1] + 1, y);
		*/
	}
	/*
		DrawAnim(IceAnim[4], x + xf[a][0], y + yf[a][0], y);
		DrawAnim(IceAnim[5], x + xf[a][1], y + yf[a][1], y);
		DrawAnim(IceAnim[6], x + xf[a][2], y + yf[a][2], y);
		DrawAnim(IceAnim[7], x + xf[a][3], y + yf[a][3], y);
	*/
		
	// Check if it hits a wall or somthing else
	CollisionTest();
}


//----------------------------------------
// Name: CollisionTest()
//----------------------------------------
CollisionTest()
{
	/*
	if (CheckForEnemies())
	{	
		hitSomthing = true;
		hitCounter = 0.00;
	}

	if ( AngleCollide("this", 3, 3, 126, 0, 0, 0) )
	{
		hitSomthing = true;
		hitCounter = 0.00;
	}
	*/
}


