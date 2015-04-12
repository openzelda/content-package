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
#include <player>
#include <entity_health>

/* Variable */
new hudEntity = 0;
new menuEntity = 0;
new controller = 0;

new Fixed:pushDelay = 0.00;


/* Public Functions */
forward public UpdatePosition();
forward public GiveWeapon( weapon{} );
forward public SetWeapon( weapon_id, slot );
forward public SetPlayerSprites( normal{32}, push{32}, pull{32}, swim{32}, using{32} );
forward public SetRestartPosition( point, ndescription{}, nx, ny, nmapid );
forward public UsingCustomAnimation()


forward public GetItemCounter( type );
forward public IncreaseItemCount( type, worth );

 /* Animation Code */ 
#define STATE_FLIP (qDisplayDirection == 3 ? 16 : 0)
#define STATE_GRAPHIC animation[qState][qDisplayDirection]

stock animationUsingCustom = false;
stock animation[STATE_COUNT][4]{32} = [
	//SOUTH, WEST, NORTH, EAST, 
	/* ALIVE */			["", "", "", ""],
	/* STANDING */		["", "", "", ""],
	/* MOVING */		["", "", "", ""],
	/* HIT */			["", "", "", ""],
	/* KNOCKED */		["", "", "", ""],
	/* JUMPING */		["", "", "", ""],
	/* SWIMMING */		["", "", "", ""],
	/* FLOATING */		["", "", "", ""],
	/* CHASING */		["", "", "", ""],
	/* USING */			["", "", "", ""],
	/* LIFTING */		["", "", "", ""],
	/* STANDLIFT */		["", "", "", ""],
	/* WALKLIFT */		["", "", "", ""],
	/* SPECIALSTATE */	["", "", "", ""],
	/* FALLING */		["", "", "", ""],
	/* WAITING */		["", "", "", ""],
	/* LEAPING */		["", "", "", ""],
	/* PUSHING */		["", "", "", ""],
	/* PULLING */		["", "", "", ""],
	/* DYING */			["", "", "", ""],
	/* DEAD */			["", "", "", ""],
	/* GONE */			["", "", "", ""]
];

public UsingCustomAnimation()
{
	animationUsingCustom = true;
}

SetStateGraphic( EntityState:s, parent[], south_graphic[], west_graphic[], north_graphic[], east_graphic[] )
{
	s = EntityState:NumberClamp( _:s, _:ALIVE, _:DEAD );
	StringFormat( animation[s][0], _, "%s:%s", parent, south_graphic);
	StringFormat( animation[s][1], _, "%s:%s", parent, east_graphic);
	StringFormat( animation[s][2], _, "%s:%s", parent, north_graphic);
	StringFormat( animation[s][3], _, "%s:%s", parent, west_graphic);
}

public SetPlayerSprites( normal{32}, push{32}, pull{32}, swim{32}, using{32} )
{
	SheetReference(normal);
	SheetReference(push);
	SheetReference(pull);
	SheetReference(swim);
	SheetReference(using);

	SetStateGraphic( STANDING, normal, "front_0", "side_0", "back_0", "side_0" );
	SetStateGraphic( MOVING, normal, "front", "side", "back", "side" );
	SetStateGraphic( USING, using, "front", "side", "back", "side" );
	SetStateGraphic( KNOCKED, normal, "front_knock", "side_knock", "back_knock", "side_knock" );
	SetStateGraphic( PUSHING, push, "front", "side", "back", "side" );
	SetStateGraphic( PULLING, pull, "front", "side", "back", "side" );
	SetStateGraphic( DYING, normal, "death", "death", "death", "death" );
	SetStateGraphic( DEAD, normal, "death_1", "death_1", "death_1", "death_1" );

}

/* Restart Point Code */
#define RestartPoint[.description{32}, .x, .y, .dir, .mapid, .active]
new _restart[3][RestartPoint];

public SetRestartPosition( point, ndescription{}, nx, ny, nmapid )
{

	point %= 3;
	StringCopy(_restart[point].description, ndescription);

	if ( nx == -1 )
		_restart[point].x = _:qPosition.x;
	else
		_restart[point].x = nx;

	if ( ny == -1 )
		_restart[point].y = _:qPosition.y;
	else
		_restart[point].y = ny;

	_restart[point].mapid = nmapid;
	_restart[point].active = 1;

}

/* Hurting and Death */
new hit = 0;
new hidden = 1;
new DeathCount = 0;
HandleDeath()
{
	ObjectPosition(qObject, qDisplayArea.x, qDisplayArea.y, qPosition.z, 0, 0);
	if ( qState == DEAD )
	{
		DeathCount = 0;
		ObjectReplace(qObject, animation[DEAD][0], SPRITE);
		EntityPublicFunction( EntityHash("TextFunctions"), "CustomText", ''snnnnnn'', _, "Press Enter to continue", -1, -1, 6.000, 11, 2, 255 );
		if ( InputButton( 6 ) )
		{
			qHealth = qMaxHealth;
			qState = STANDING;
			LayerColour(0, 0xFFFFFFFF);
			LayerColour(1, 0xFFFFFFFF);
			LayerColour(2, 0xFFFFFFFF);
			LayerColour(3, 0xFFFFFFFF);
			LayerColour(4, 0xFFFFFFFF);
			LayerColour(5, 0xFFFFFFFF);
		
			ObjectReplace(qObject, animation[STANDING][0], SPRITE);
			//TransitionPlayer( internal_ident, 0, _restart[0].mapid, "");
			EntitySetPosition( _restart[0].x, _restart[0].y, _ );
		}
	}
	else if ( qState == DYING ) 
	{
		LayerColour(0, 0xFF0000FF);
		LayerColour(1, 0xFF0000FF);
		LayerColour(2, 0xFF0000FF);
		LayerColour(3, 0xFF0000FF);
		LayerColour(4, 0xFF0000FF);
		LayerColour(5, 0xFF0000FF);
		
		if ( DeathCount == 0 )
		{
			DeathCount = AnimationGetLength( "p01n.png", "death" );
			ObjectReplace(qObject, animation[DYING][0], SPRITE);
		}
		if ( TimerCountdown(DeathCount) )
			qState = DEAD;
	}
}

/* Weapon */
new weapon_action[3] = [0,0,0];
new qSelectedWeapons[4];
new qUsingWeapon = -1;

public GiveWeapon( weapon{} )
{
	new hash;
	new entityName{64};
	StringCopy(entityName, weapon);

	hash = EntityCreate( entityName, "", 0, 0, qPosition.z, GLOBAL_MAP );

	EntityPublicFunction( hash, "SetOwner", ''n'', _, internal_ident );
	EntityPublicFunction( hudEntity, "AddWeapon", ''snn'', _, entityName, hash, internal_ident );

	SetWeapon( hash, BUTTON_ACTION1 );
}

public SetWeapon( weapon_id, slot )
{
	if ( slot >= 0 && slot < 4 ) 
	{
		qSelectedWeapons[slot] = weapon_id;
	}
}

/* Items */
new qCounters[16];
new countersSize[6] = [ 300, 20, 20, 500, 9, 300]; 
ipow(base, exp)
{
	new result = 1;
	while (exp)
	{
		if (exp & 1)
			result *= base;
		exp >>= 1;
		base *= base;
	}

	return result;
}

public GetItemCounter( type )
{
	if ( type < 16 && type >= 0)
	{
		return qCounters[type];
	}
	return 

}

CreateItemCounters()
{
	for ( new q = 0; q < 6; q++ ) 
	{
		qCounters[q]= EntityCreate("counter", "", 0, 0, 1, GLOBAL_MAP, [ARG_RETURN_NUMBER, ARG_RETURN_NUMBER, ARG_END], _, 0, countersSize[q] ); 
	}
}

public IncreaseItemCount( type, worth )
{
	if ( type < 16 && type >= 0)
	{	
		if ( qCounters[type] )
		{
			EntityPublicFunction( qCounters[type], "@IncreaseTarget", [ARG_NUMBER, ARG_END], _, worth );
		}
	}
}




