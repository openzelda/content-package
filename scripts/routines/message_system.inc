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

stock __dialogEntity = 0;

stock DialogBox(dialogNumber, x, y, z, graphic{} )
{
	new entity = EntityCreate("dialog_box", "", 0,0,0, GLOBAL_MAP);
	if ( entity )
	{
		EntityPublicFunction(entity, "dialogbox", ''nnnns'', _,dialogNumber, x, y, z, graphic );

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

