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
 *     2013/04/01 [luke]: new file.
 ***********************************************/

stock SetObject( sprite[], x, y, Fixed:z )
{
	qObject = EntityGetObject(); 
	if ( qObject )
	{
		ObjectPosition( qObject, x, y, z, 0, 0 );
		ObjectReplace( qObject, sprite, SPRITE );

	}
	else
	{
		qObject = ObjectCreate( sprite, SPRITE, x, y, z, .global = true);
	}
}


stock ReplaceEntityGraphics( display_object[EntityGraphic], image{}, bool:flip, bool:force = false )
{
	if ( qUpdate || force )
	{
		ObjectReplace( display_object.obj, image, SPRITE );
		ObjectEffect( display_object.obj, .mirror = (flip ? 16 : 0) );
	}
}

stock UpdateEntityGraphics( display_object[EntityGraphic] )
{
	ObjectPosition( display_object.obj, qDisplayArea.x + display_object.x, qDisplayArea.y + display_object.y, qPosition.z + display_object.z, display_object.width, display_object.height);
}


stock CreateEntityGraphics( display_object[EntityGraphic], initial_sprite{} )
{
	display_object.obj = ObjectCreate( initial_sprite, SPRITE, qDisplayArea.x + display_object.x, qDisplayArea.y + display_object.y, qPosition.z + display_object.z, display_object.width, display_object.height, WHITE );
}

stock DeleteEntityGraphics( display_object[EntityGraphic] )
{
	ObjectDelete( display_object.obj );
	display_object.obj = OBJECT_NONE;
}


stock ColourEntityGraphics( display_object[EntityGraphic], colour )
{
	ObjectEffect( display_object.obj, colour );
}