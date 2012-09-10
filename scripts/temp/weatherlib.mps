/***********************************************
 * Copyright (c) 2004-2006 Editors
 * Changes:  
 *	21/05/2003 [lukex / Satanman]: New file. 
 *	21/05/2004 [lukex]: Updated to be easier to be used.
 ***********************************************/

#include <counter>
#include <foreign/journey>
#include <core>
#include <float>



new isLanternOwned = false;
new darknessLevel = 0;
new _Weather:mode = _none;


new rainx[20]; //x and y of 20 raindrops
new rainy[20];
new float: animtimer = 0.00;
new float: thunderAt = 0.00;
new rainoffset[20]; //number of frames the raindrop is offset by; makes it look random
new hasmoved[20];
new string[16];


public HandleWeather()
{
	if (!isInside())
	{
		if (mode == _raining)
		{
			darknessLevel = 2;
			DrawDarkness();
			DrawRain();		 
		}
		else
		{
			darknessLevel = 0;
		}

		if (5 < GetHourCount() < 7 )
		{
			if ( random(60) == 1 )
				PlaySound("n_rooster.wav");
		}
		else if (20 < GetHourCount() < 22)
		{
			if ( random(60) == 1 )
				PlaySound("e_howl.wav");
		}


	}
	else
	{
		if ( darknessLevel > 0 ) 
			DrawDarkness();
	}
}


public AbleLantern(able)
{
	isLanternOwned = able;
}

public SetWeather(newweather)
{
	mode = newweather;
}

public SetDarknessLevel(level)
{
	darknessLevel = level;
}

DrawRain()
{
	
	//PlayMusic("rain.it");
	/*
	if( animtimer >= thunderAt && !playingThunder)
   	{
		thunderAt = float(random(500) + 2) / 500 ;
		PlaySound("_thunder.wav",255);
	}
	else if( animtimer >= ( thunderAt - 0.1 ) )
   	{
		DrawRectangle(0, 0, 640, 480, 255, 255, 255, 160); //Lighting Flash
	}
	*/
	for (new n = 0; n < 40; n++)
	{
		rainoffset[n] = random(5);
		//If there are 4 anim bits, playing at 10 fps
		if (animtimer < 0.2)
		{
			if (rainoffset[n] == 0)
			{
				if (hasmoved[n] == false)
				{
					rainx[n] = random(80) * 8; //get a random position
					rainy[n] = random(60) * 8;
					hasmoved[n] = true;
				}
				DrawImage("rain1", rainx[n], rainy[n], 255, 255, 255, 255, 0, 200); //draws it on the very top layer
			
			}
			else if (rainoffset[n] == 1)
			{
				DrawImage("rain2", rainx[n], rainy[n], 255, 255, 255, 255, 0, 200);
			 	hasmoved[n] = false;
			} 
			else if (rainoffset[n] == 2)
				DrawImage("rain3", rainx[n], rainy[n], 255, 255, 255, 255, 0, 200);
			else if (rainoffset[n] == 3)
				DrawImage("rain4", rainx[n], rainy[n], 255, 255, 255, 255, 0, 200);
		} 
		else if (animtimer < 0.4)
		{
			if (rainoffset[n] == 0)
			{
				DrawImage("rain2", rainx[n], rainy[n], 255, 255, 255, 255, 0, 200);
			 	hasmoved[n] = false;
			}
			else if (rainoffset[n] == 1)
				DrawImage("rain3", rainx[n], rainy[n], 255, 255, 255, 255, 0, 200);
			else if (rainoffset[n] == 2)
				DrawImage("rain4", rainx[n], rainy[n], 255, 255, 255, 255, 0, 200);
			else if (rainoffset[n] == 3)
			{
				if (hasmoved[n] == false)
				{
					rainx[n] = random(80) * 8; //get a random position
					rainy[n] = random(60) * 8;
					hasmoved[n] = true;
				}
				DrawImage("rain1", rainx[n], rainy[n], 255, 255, 255, 255, 0, 200); //draws it on the very top layer
			}
		} 
		else if (animtimer < 0.6)
		{
			if (rainoffset[n] == 0)
				DrawImage("rain3", rainx[n], rainy[n], 255, 255, 255, 255, 0, 200);
			else if (rainoffset[n] == 1)
				DrawImage("rain4", rainx[n], rainy[n], 255, 255, 255, 255, 0, 200);
			else if (rainoffset[n] == 2)
			{
				if (hasmoved[n] == false)
				{
					rainx[n] = random(80) * 8; //get a random position
					rainy[n] = random(60) * 8;
					hasmoved[n] = true;
				}
				DrawImage("rain1", rainx[n], rainy[n], 255, 255, 255, 255, 0, 200); //draws it on the very top layer
			}
			else if (rainoffset[n] == 3)
			{
				DrawImage("rain2", rainx[n], rainy[n], 255, 255, 255, 255, 0, 200);
			 	hasmoved[n] = false;
			}
		} 
		else if (animtimer < 0.8)
		{

			if (rainoffset[n] == 0)
				DrawImage("rain4", rainx[n], rainy[n], 255, 255, 255, 255, 0, 200);
			else if (rainoffset[n] == 1)
			{
				if (hasmoved[n] == false)
				{
					rainx[n] = random(80) * 8; //get a random position
					rainy[n] = random(60) * 8;
					hasmoved[n] = true;
				}
				DrawImage("rain1", rainx[n], rainy[n], 255, 255, 255, 255, 0, 200); //draws it on the very top layer
			}
			else if (rainoffset[n] == 2)
			{
				DrawImage("rain2", rainx[n], rainy[n], 255, 255, 255, 255, 0, 200);
			 	hasmoved[n] = false;
			}
			else if (rainoffset[n] == 3)
				DrawImage("rain3", rainx[n], rainy[n], 255, 255, 255, 255, 0, 200);

		}
	}

	animtimer += GetTimeDelta();

	if (animtimer >= 0.8)
	{
		animtimer = 0.00;
	}
}

DrawDarkness()
{
	new dir = GetDirection("player1");
	new xa = (GetX("player1") - GetWorldX()) * 2;
	new ya = (GetY("player1") - GetWorldY()) * 2;
	new rot = 0;
	new alpha = 0; 
	
	if (!darknessLevel)
		return;
	else if (darknessLevel == 4)
		alpha = 255;
	else if (darknessLevel == 3)
		alpha = 192;
	else if (darknessLevel == 2)
		alpha = 128;
	else if (darknessLevel == 1)
		alpha = 64;

	if ( dir == south ) 
	{
		rot = 0;
		ya += 24;
		xa -= 14;
	}
	else if ( dir == west )
	{
		rot = 90;
		xa -= 52;
		ya -= 14;
	}
	else if ( dir == north )
	{
		rot = 180;
		ya -= 64;
		xa -= 14;
	}
	else if ( dir == east )
	{
		rot = 270;
		xa += 24;
		ya -= 14;
	}
	
	(isLanternOwned ? DrawImage("i_lampdark", xa, ya, 255, 255, 255, alpha, rot, 200) : DrawRectangle(xa-32, ya-32, xa + 96, ya + 96, 0, 0, 0, alpha) );
	//above
	DrawRectangle(0, 0, 640, ya - 32, 0, 0, 0, alpha);
	//below
	DrawRectangle(0, ya + 96, 640, 480, 0, 0, 0, alpha);
	//left
	DrawRectangle(0, ya - 32, xa - 32, ya + 96, 0, 0, 0, alpha);
	//right
	DrawRectangle(xa + 96, ya - 32, 640, ya + 96, 0, 0, 0, alpha);

}