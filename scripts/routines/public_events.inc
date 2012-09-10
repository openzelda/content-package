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
 *     2012/01/30  [luke]: new file. 
 ***********************************************/ 
/* Public Events
 *  wrapper around EntityPublicFunction so user don't use the wrong code
 */


#define PUBLICFUNCTIONHIT public Hit( attacker[], angle, dist, attack, damage, x, y, rect )
#define PUBLICFUNCTIONAWAKING public Awaking( attacker[], rect )


/***
<function name="TransitionPlayer">
	<summary>Changes the Section, while keeping the same grid location.</summary>
	<param name="section[]" default="" type="s"></param>
	<param name="gridx" default="-1" type="n"></param>
	<param name="gridy" default="-1" type="n"></param>
</function>
***/
stock TransitionPlayer( nplayer[], ntargetentity[], nmapid = 0, nsection[] = SELF, ngridx = -1, ngridy = -1 )
{
	if ( ngridx < 0 && ngridy < 0 )
		SectionGet(SELF, ngridx, ngridy);
	return EntityPublicFunction("transition", "SetTarget", "ssnsnn", nplayer, ntargetentity, nmapid, nsection, ngridx, ngridy );
}

stock CallEntityHit( entityid[], attacker[], angle, dist, attack, damage, x, y, rect )
{
	return EntityPublicFunction(entityid, "Hit", "snnnnnnn", attacker, angle, dist, attack, damage, x, y, rect);
}

stock CallEntityAwaking(entityid[], attacker[], rect)
{
	return EntityPublicFunction(entity, "entityid", "sn", attacker, rect);
}


/*
	else if ( type == TYPE_TRANSPORT )
	{
		//MovePlayer(player, dir)
		if ( EntityPublicFunction(current, "MovePlayer", "sn", selfid, _dir_) )
		{
			 _state_ = STANDING;
		}
	}
	else if ( type == TYPE_PUSHABLE && _state_ == PUSHING )
	{
		// public Push(attacker[], rect, angle)
		EntityPublicFunction(current, "Push", "snn", selfid, rect, angle);
	}
	else if ( type == TYPE_SWITCH )
	{
		// public Pressed(attacker[])
		EntityPublicFunction(current, "Pressed", "s", selfid);
	}
	else if ( type == TYPE_ITEM )
	{
		// public Pickup(attacker[])
		if ( EntityPublicFunction(current, "Pickup", "s", selfid) )
*/