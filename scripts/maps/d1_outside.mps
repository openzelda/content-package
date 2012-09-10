#define INITFUNCTION 1

#include <map_features/enemy_check>

public Init( ... )
{
	MapInit();
	_enemycount = -1;
	EntityPublicFunction("main", "SetDay", "n", 0);
}

main()
{
	EnemyCheck( "a", "OpenDoor" );
}
