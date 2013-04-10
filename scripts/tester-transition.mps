#include <controller>

new entityId:owner = entityId:0;

/* Init function is the call before anything else */
public Init(...)
{
	if ( numargs() >=1 )
	{
		//owner = entityId:getarg(0);
	}
}

/* Close function when it is deleted' */
public Close()
{
	
}

main()
{
	if ( InputButton(BUTTON_ACTION4) )
	{
		TransitionPlayer( owner, 0, 0, "testsection", 0, 0 );
	}
	if ( InputButton(BUTTON_ACTION5) )
	{
		new mapid = MapID("testscreen");
		TransitionPlayer( owner, 0, mapid, "", -1, -1 );
	}
	if ( InputButton(BUTTON_ACTION6) )
	{
		new mapid = MapCreate("testscreen", false);
		
		TransitionPlayer( owner, 0, mapid, "", -1, -1 );
	}





}
