forward public DropItem();

/* Init function is the call before anything else */
public Init(...)
{
	
}

/* Close function when it is deleted' */
public Close()
{
	
}

main()
{
	
	if ( InputButton(BUTTON_ACTION4) == 1 )
	{
		EntityCreate("dropitem_arrow", "", 160, 160, 3.0,MapCurrentIdent() , [ARG_RETURN_NUMBER,ARG_END], _, 10 )
	}

}



public DropItem()
{
	EntityCreate("dropitem_arrow", "", 100, 100, 3.0,MapCurrentIdent() , [ARG_END], 0 )

}