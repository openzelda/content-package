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
#include <entities>
#include <quest_types>
#tryinclude <map_default>

forward public EnemyKilled();

stock _enemycount = -1;

stock EnemyCheck( entity[], fun[] )
{
	if ( _enemycount >= 0 )
	{
		if ( _enemycount == 0 )
		{
			if ( entity[0] && fun[0] )
				EntityPublicFunction( entity, fun );
			else
				DialogShow( 1 );
			_enemycount = -2;
		}
	}
	else
	{

		_enemycount = 0;
		if ( EntitiesList(mapid) )
		{
			new string[64];

			while ( EntitiesNext(string, mapid) )
			{
				if ( TYPE_ENEMY == _TYPE:EntityPublicFunction( string, "GetType")  )
					_enemycount++;
			}

		}

	}

}

public EnemyKilled()
{
	_enemycount--;
}