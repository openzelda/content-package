#tryinclude <map_default>
main()
{
	/**/
	if ( InputButton(0,0) == 1) // Check if button 1 on default player is just been press. it would equal 2 if it was held
	{
		SheetReplace("outside01.png", "outside02.png"); // Replace Display Object from one sheet to another.
	}

}