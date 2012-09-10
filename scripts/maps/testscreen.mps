stock Fixed:Dir2Angle(d)
{
	d %= 8;
	return fixed(d*45);
}
main()
{

	if ( InputButton(13,0) )
	{
		TransitionPlayer( "player1", "", 0,  "Dungeon_One", 1, 2 );
		//SectionSet("Dungeon_One", 0, 0);
	}
	if ( InputButton(3,0) )
	{
		EntityCreate("attack_flamethrower1", "*", 60, 60, 4.0, CURRENT_MAP, _, "d", 5 );
	}
}
