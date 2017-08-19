/*********************************************** 
 * Copyright © Luke Salisbury 
 * 
 * You are free to share, to copy, distribute and transmit this work 
 * You are free to adapt this work 
 * Under the following conditions: 
 *  You must attribute the work in the manner specified by the author 
 *  or licensor (but not in any way that suggests that they endorse you
 *  or your use of the work).  
 *  You may not use this work for commercial purposes. 
 * Full terms of use: http://creativecommons.org/licenses/by-nc/3.0/ 
 * Changes: 
 *     2012/01/30  [luke]: new file. 
 ***********************************************/ 
/* Public Events
 *  wrapper around EntityPublicFunction so user don't use the wrong code
 */

#include <system>
#define PUBLIC_EVENT_HIT		public Hit( entity:attacker, angle, dist, attack, damage, x, y, rect )
#define PUBLIC_EVENT_AWAKING	public Awaking( entity:attacker, rect )
#define PUBLIC_EVENT_PRESSED	public Pressed( entity:attacker )
#define PUBLIC_EVENT_PUSH		public Push( entity:attacker, rect, angle )
#define PUBLIC_EVENT_HURT		public Hurt( type, damage, angle )
#define PUBLIC_EVENT_PICKUP		public Pickup( entity:attacker )



/***
<function name="TransitionPlayer">
	<summary>Changes the Section, while keeping the same grid location.</summary>
	<param name="section[]" default="" type="s"></param>
	<param name="gridx" default="-1" type="n"></param>
	<param name="gridy" default="-1" type="n"></param>
</function>
***/

stock entity:transitionEntity = 0;

stock CreateTransitionEntity()
{
	transitionEntity = EntityCreate( "transition", "transition", 0, 0, 0, GLOBAL_MAP);
}

stock Transition( map_name{64} )
{
	new map_id = MapGetIdent(map_name, -1);
	if ( map_id )
	{
		if ( !transitionEntity )
		{
			transitionEntity = entity:EntityHash("transition");
		}
		return EntityPublicFunction(transitionEntity, "SetTarget", [ ARG_NUMBER, ARG_NUMBER, ARG_NUMBER, ARG_NUMBER, ARG_END ], _, 0, 0, map_id, 0 );
	}
}

stock TransitionMap( section_name{64}, x, y )
{
	new section_id = WorldLoad(section_name);
	new map_id = WorldGetIdent(section_id, x, y);

	if ( section_id )
	{
		if ( !transitionEntity )
		{
			transitionEntity = entity:EntityHash("transition");
		}
		ConsoleLog("transitionEntity %d", transitionEntity);

		return EntityPublicFunction(transitionEntity, "SetTarget", [ ARG_N, ARG_N, ARG_N, ARG_N, ARG_END ], _, 0, 0, map_id, 0 );
	}
}

stock TransitionPlayerReset( entity:player, nmapid )
{
	if ( !transitionEntity )
	{
		transitionEntity = entity:EntityHash("transition");
	}
	return EntityPublicFunction(transitionEntity, "SetTarget", [ ARG_NUMBER, ARG_NUMBER, ARG_NUMBER, ARG_NUMBER, ARG_END ], _, player, 0, nmapid, 1 );
}

stock TransitionPlayer( entity:player, entity:target, nmapid = 0 )
{
	if ( !transitionEntity )
	{
		transitionEntity = entity:EntityHash("transition");
	}
	return EntityPublicFunction(transitionEntity, "SetTarget", [ ARG_NUMBER, ARG_NUMBER, ARG_NUMBER, ARG_NUMBER, ARG_END ], _, player, target, nmapid, 0 );
}

stock CallEntityHit( entity:entity, entity:attacker, angle, dist, attack, damage, x, y, rect )
{
	return EntityPublicFunction( entity, "Hit", [ ARG_NUMBER, ARG_NUMBER, ARG_NUMBER, ARG_NUMBER, ARG_NUMBER, ARG_NUMBER,  ARG_NUMBER, ARG_NUMBER, ARG_END ], _, attacker, angle, dist, attack, damage, x, y, rect);
}

stock CallEntityAwaking( entity:entity, entity:attacker, rect)
{
	return EntityPublicFunction( entity, "Awaking", [ ARG_NUMBER, ARG_NUMBER, ARG_END ], _, attacker, rect);
}

stock CallEntityPressed( entity:entity, attacker, rect, angle)
{
	return EntityPublicFunction( entity, "Pressed", [ ARG_NUMBER, ARG_NUMBER, ARG_NUMBER, ARG_END ], _, attacker, rect, angle);
}


stock CallEntityHurt( entity:entity, weapon_type, damage, angle)
{
	return EntityPublicFunction( entity, "Hurt", [ ARG_NUMBER, ARG_NUMBER, ARG_NUMBER, ARG_END ], _, weapon_type, damage, angle);
}


stock CallEntityPush( entity:entity, attacker, rect, angle)
{
	return EntityPublicFunction( entity, "Push", [ ARG_NUMBER, ARG_NUMBER, ARG_NUMBER, ARG_END ], _, attacker, rect, angle);
}

stock CallEntityPickup( entity:entity, attacker )
{
	return EntityPublicFunction( entity, "Pickup", [ ARG_NUMBER, ARG_END ], _, attacker );
}

stock CallEntityUse( entity:entity, displayObject, direction )
{
	return EntityPublicFunction( entity, "Use", [ ARG_NUMBER, ARG_NUMBER, ARG_END ], _, displayObject, direction );
}

stock CallEntityMovePlayer( entity:entity, entity:player, Directions:direction )
{
	return EntityPublicFunction( entity, "MovePlayer", [ ARG_NUMBER, ARG_NUMBER, ARG_END ], _, _:player, _:direction );
}

stock CallEntityChangeCounter( entity:entity, counter_id, value )
{
	return EntityPublicFunction( entity, "IncreaseItemCount", [ ARG_NUMBER, ARG_NUMBER, ARG_END ], _, counter_id, value );
}

