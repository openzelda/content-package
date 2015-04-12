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
 *     2012/01/11 [luke]: new file. 
 ***********************************************/ 
 
#include <core>  
#include <graphics>  
#include <entities>  
#include <string>  
 

 
forward @SetValue(value)  
forward @SetTarget(target)  
forward @SetMin(m)  
forward @SetMax(m)  
forward @GetMin(m)  
forward @GetMax(m)  
forward @IncreaseTarget(m)  
forward @IncreaseValue(m)  
forward @GetValue()  
forward @SetSpeed(m)  
forward @SetWatch(m, entity:e, c[])  
 
 
 
new minv = 0;  
new maxv = 8192;  
public v = 0;
public Fixed:fv;  
public t = 0;  
new Fixed:s = 20.0;  
new w = -1;  
new call[20];  
new entity:entityId;  

public Init( ... )  
{  
	new c = numargs();  
  
	if ( c > 4 )  
		s = Fixed:getarg(4);  
	if ( c > 2 )  
		v = t = getarg(2);  
	if ( c > 3 )  
		 t = getarg(3);  
	if ( c > 1 )  
		maxv = getarg(1);  
	if ( c > 0 )  
		minv = getarg(0);  


}  
  
main()  
{
	
	if (v != t)  
	{
		new q = 0;
		
		ConsoleOutput("Counter [%d-%d] v:%d t:%d w:%d", minv, maxv, v, t, w); 
		
		if (v < t)
			fv += s*GameFrameSeconds();  
		else if (v > t) 
			fv -= s*GameFrameSeconds();
		
		q =  RealRound(fv, round_tozero);

		if (q != 0 )
		{
			v += q;
			fv  %= 1.000;
		}
		
	}  
	if ( v == w )  
	{  
		EntityPublicFunction(entityId, call);  
		w = -1;  
	}  
}  
  
@SetValue(value)  
{  
	if (v < minv)  
		v = minv;  
	else if (v > maxv)  
		v = maxv;  
	v = value;  
	t = value;  
}  
  
@SetTarget(target)  
{  
	if (t < minv)  
		t = minv;  
	if (t > maxv)  
		t = maxv;  
	t = target;  
}  
  
@SetMin(m)  
{  
	minv = m;  
}  
  
@SetMax(m)  
{  
	maxv = m;  
}  
  
@GetMin(m)  
{  
	return minv;  
}  
  
@GetMax(m)  
{  
	return maxv;  
}  
  
@IncreaseTarget(m)  
{  
	@SetTarget(t+m);  
}  
  
@IncreaseValue(m)  
{  
	@SetValue(v+m);  
}  
  
@GetValue()  
{  
	return v;  
}  
  
@SetSpeed(m)  
{  
	s = m;  
}  
  
@SetWatch(m, entity:e, c[])  
{  
	w = m;  
	entityId = e; 
	strcopy(call, c);  
}  
  
