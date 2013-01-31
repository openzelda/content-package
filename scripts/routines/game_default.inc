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
#include <quest_types> 
#include <core> 

stock operator%(Fixed:oper1, Fixed:oper2)
	return fround(oper1*1000)%fround(oper2*1000);
stock operator%(Fixed:oper1, oper2)
	return fround(oper1*1000)%(oper2*1000);

/*public functions */ 
forward public SetState(q); 
forward public GetState(); 
forward public GetType();
forward public SetType(q); 
forward public GetDir(); 
forward public SetDir(q); 
 
public _STATE:_state_ = ALIVE;
public _type_ = 0; 
public _dir_ = SOUTH; 

stock _animdir_ = 0;
new last_dir = -1;
new _STATE:last_state =  _STATE:-1;

stock update = false; 
 
public GetDir() 
{ 
	return _dir_; 
} 
 
public SetDir(q) 
{ 
	q %= 8; 
	_dir_ = q; 
	_animdir_ = q/2;
	return _dir_; 
} 
 
public GetState() 
{ 
	return _state_; 
}

public SetState(q) 
{ 
	_state_ = _STATE:q; 
	return _state_; 
}

public GetType() 
{ 
	return _type_; 
}

public SetType(q) 
{ 
	_type_ = q; 
	return _type_; 
}

stock HasStateChanged()
{
	new changed = false;
	if ( _state_ != last_state || _dir_ != last_dir )
		changed = update = true;
	else
		update = false;
	last_state = _state_;
	last_dir = _dir_;
	return changed;
}

stock GetEntityPosition( &Fixed:fx, &Fixed:fy, &Fixed:fz, &ix, &iy, &iz, &il)
{
	EntityGetPosition(fx, fy, fz); // Fixed Position
	ix = fround(fx, round_unbiased); // Display Positions
	iy = fround(fy, round_unbiased);
	il = fround(fz, round_floor);
	iz = (il ? il*1000 : 20 ) + ( iy > -10 ? (iy/8) : -9);
}

stock SetEntityVar()
{

}