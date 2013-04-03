// To ease development, <map_default> may include a Init Function.
// If You wish to use your own uncomment the next line
#define HASINITFUNCTION 1
#tryinclude <map_default>
#tryinclude <map_features/enemy_check>


public Init( ... )
{
	InitMap();
	RestetEnemyCount()
	EntityPublicFunction( ENTITY_MAIN, "SetDay", [ ARG_NUMBER, ARG_END ], 0);
}

main()
{
	CheckEnemy( "a", "OpenDoor" );
}
