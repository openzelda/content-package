

stock __dialogEntity = 0;

stock DialogBox(dialogNumber, x, y, z, graphic{} )
{
	new entity = EntityCreate("dialog_box", "", 0,0,0, GLOBAL_MAP);
	if ( entity )
	{
		EntityPublicFunction(entity, "dialogbox", ''nnnns'', dialogNumber, x, y, z, graphic );

	}
	return entity;
}






// Message Map Functions
stock MessageMap(ident[] = "this", index, Message[], gotoNext, ...) {
    return 1;
}

stock GetNextMessage(ident[] = "this", index, index2) {
    return 1;
}

stock GetGotoNextMessage(ident[] = "this", index) {
    return 1;
}

stock GetNumNextMessages(ident[] = "this", index) {
    return 1;
}

