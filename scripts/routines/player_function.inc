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

/* Variable */
public _maxhealth_ = 300;
public _health_ = 300;

new object:obj = OBJECT_NONE;
new selfid[64];
new self_hash_id = 0;
new hud_hash_id = 0;
new menu_hash_id = 0;
new controller = 0;

new Fixed:push_delay = 0.00;


/* Public Functions */
forward public UpdatePosition();
forward public Hurt(type, damage, angle);
forward public GiveWeapon( weapon[] );
forward public SetWeapon( weapon_id, n );
forward public SetPlayerSprites( normal{32}, push{32}, pull{32}, swim{32} );
forward public SetRestartPosition( point, ndescription[], nx, ny, nmapid );


 /* Animation Code */ 
#define STATE_FLIP (mqDisplayDirection == 3 ? 16 : 0)
#define STATE_GRAPHIC animation[_state_][mqDisplayDirection]


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

SetStateGraphic( _STATE:s, parent[], south_graphic[], west_graphic[], north_graphic[], east_graphic[] )
{
	s = _STATE:NumberClamp( _:s, _:ALIVE, _:DEAD );
	strformat( animation[s][0], _, true, "%s:%s", parent, south_graphic);
	strformat( animation[s][1], _, true, "%s:%s", parent, west_graphic);
	strformat( animation[s][2], _, true, "%s:%s", parent, north_graphic);
	strformat( animation[s][3], _, true, "%s:%s", parent, east_graphic);
}

public SetPlayerSprites( normal{32}, push{32}, pull{32}, swim{32} )
{
	SheetReference("p01push.png");
	SheetReference("p01pull.png");
	SheetReference("p01n.png");

	SetStateGraphic( STANDING, "p01n.png", "front_0", "side_0", "back_0", "side_0" );
	SetStateGraphic( MOVING, "p01n.png", "front", "side", "back", "side" );
	SetStateGraphic( KNOCKED, "p01n.png", "front_knock", "side_knock", "back_knock", "side_knock" );
	SetStateGraphic( PUSHING, "p01push.png", "front", "side", "back", "side" );
	SetStateGraphic( PULLING, "p01pull.png", "front", "side", "back", "side" );
	SetStateGraphic( DYING, "p01n.png", "death", "death", "death", "death" );
	SetStateGraphic( DEAD, "p01n.png", "death_1", "death_1", "death_1", "death_1" );

}

/* Restart Point Code */
#define RestartPoint[.description{32}, .section{64}, .x, .y, .dir, .mapid, .active]
new _restart[3][RestartPoint];

public SetRestartPosition( point, ndescription[], nx, ny, nmapid )
{
	point %= 3;
	strcopy(_restart[point].description, ndescription);

	if ( nx == -1 )
		_restart[point].x = _:mqEntityPosition.x;
	else
		_restart[point].x = nx;

	if ( ny == -1 )
		_restart[point].y = _:mqEntityPosition.y;
	else
		_restart[point].y = ny;

	
	if ( nmapid == -1 )
	{
	
		_restart[point].mapid = MapCurrent();
	}
	else
		_restart[point].mapid = nmapid;
	_restart[point].active = 1;
}

/* Hurting and Death */
new hit = 0;
new hidden = 1;
new DeathCount = 0;
HandleDeath()
{
	ObjectPosition(obj, mqDisplayArea.x, mqDisplayArea.y, mqDisplayZIndex, 0, 0);
	if ( _state_ == DEAD ) 
	{
		DeathCount = 0;
		ObjectReplace(obj, animation[DEAD][0], SPRITE);
		EntityPublicFunction( EntityHash("main"), "CustomText", "snnnnnn", "Press Enter to continue", -1, -1, 6, 11, 2, 255 );
		if ( InputButton( 6 ) )
		{
			_health_ = _maxhealth_;
			_state_ = STANDING;
			LayerColour(0, 0xFFFFFFFF);
			LayerColour(1, 0xFFFFFFFF);
			LayerColour(2, 0xFFFFFFFF);
			LayerColour(3, 0xFFFFFFFF);
			LayerColour(4, 0xFFFFFFFF);
			LayerColour(5, 0xFFFFFFFF);
		
			TransitionPlayer( self_hash_id, 0, _restart[0].mapid, "");
			EntitySetPosition( _restart[0].x, _restart[0].y, _ );
		}
	}
	else if ( _state_ == DYING ) 
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
			ObjectReplace(obj, animation[DYING][0], SPRITE);
		}
		if ( Countdown(DeathCount) )
			_state_ = DEAD;
	}
}

/* Weapon */

new weapon_action[3] = [0,0,0];
new weapons[4];
new weapon_active = -1;

public GiveWeapon( weapon[] )
{
	new hash;
	new entity{64};
	StringCopy(entity, weapon);
	hash = EntityCreate( entity, "", 0, 0, 1, GLOBAL_MAP );
	EntityPublicFunction( hash, "SetOwner", "n", self_hash_id );
	EntityPublicFunction( menu_hash_id, "AddWeapon", "sn", entity, hash, self_hash_id );
	SetWeapon( hash, BUTTON_ACTION1 );
}

public SetWeapon( weapon_id, n )
{
	if ( n >= 0 && n < 4 ) 
	{
		weapons[n] = weapon_id;
	}
}