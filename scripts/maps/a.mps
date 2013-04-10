#tryinclude <map_default>

new timer = 100;
forward public CreateItem()
main()
{
	

}


public CreateItem()
{
	//EntityCreate("attack_flamethrower1", "*", 100.0, 5.0, 4000, CURRENT_MAP, ''d'', 45.0 );
	EntityCreate("dropitem_arrow", "*", 100.0, 200.0, 4.0, CURRENT_MAP, ''n'', 5 );
	/*
	ObjectCreate( "deathanim01.png:animasd23",SPRITE, 10, 10, 5, 120, 120, RED );
	ObjectCreate( "deathanim01.png:anim", SPRITE, 20, 20, 5, 120, 120, RED );
	ObjectCreate( "deathanim01.png:anim", SPRITE, 20, 32, 5, 0, 0, RED );
	ObjectCreate( "deathanim01.png:anim", SPRITE, 220, 25, 5, 0, 0, RED );
	ObjectCreate( "deathanim01.png:anim", SPRITE, 20, 277, 5, 0, 0, RED );
	*/
}
