/***********************************************
 * Copyright (c) 2004-2006 Editors, lukex
 * Changes:  
 *	12/08/03 [lukex]: New file.
 *	03/03/05 [lukex]: removed the need strcmp from ShowTextBox.
 *	09/04/05 [lukex]: fix bug then more then one ~ in ShowTextBox.
  *	18/04/05 [lukex]: added fix for then DisplayTextBox is used with CallFunction
 ***********************************************/
#include <core>
#include <foreign/journey>

#include <float>
public ShowTextBox(entityString[], valueString) 
{
	new author[3] = {1819634533,2013265920, 0 };
 	new message[1024];
	new message_temp[1024];
	new name[8];
	new padding = 0;
	
	GetString(entityString, valueString, message);
	GetString("player1", 2, name);		
	new messageLength = strlen(message);
	new nameLength = strlen(name);
	
	for (new o; o < messageLength; o++)
	{
		if ( message[o] == 126 )
		{
			
			for (new q; q < nameLength; q++)
			{
				message_temp[o + q + padding] = name[q];
			}
			padding += nameLength - 1;
		}
		else
		{
			message_temp[o + padding] = message[o];
		}
	}
	
	InitTextBox( message_temp, 200, false);
}
public DisplayTextBox(pmessage[], text[]) 
{
	new author[3] = {1819634533,2013265920, 0 };
	new message[1024];
	new message_temp[1024];
	new padding = 0;
	strunpack(message, pmessage);
	new messageLength;
	new textLength;
	messageLength = strlen(message);
	textLength = strlen(text);
	
	for (new o; o < messageLength; o++)
	{
		if ( message[o] == 126 )
		{
			
			for (new q; q < textLength; q++)
			{
				message_temp[o + q + padding] = text[q];
			}
			padding += textLength - 1;
		}
		else
		{
			message_temp[o + padding] = message[o];
		}
	}
	
	InitTextBox( message_temp, 200, false);
}
public StringReplace(message[], text[]) 
{
	new author[3] = {1819634533,2013265920, 0 };
	new message_temp[1024];
	new padding = 0;
	
	new messageLength;
	new textLength;
	messageLength = strlen(message);
	textLength = strlen(text);
	
	for (new o; o < messageLength; o++)
	{
		
		if ( message[o] == 126 )
		{
			
			for (new q; q < textLength; q++)
			{
				message_temp[o + q + padding] = text[q];
			}
			padding += textLength - 1;
		}
		else
		{
			message_temp[o + padding] = message[o];
		}
	}
	//return message_temp;
	
}
public IsSelected(text[])
{
	new author[3] = {1819634533,2013265920, 0 };
	new entity[20];
	new entityName[20];
	GetString("player1", 0, entity);
	GetString(entity, 1, entityName);	
	if ( !strcmp(entityName, text) )
	{
	  	return true;
	}
	else
	{
		GetString("player1", 1, entity);
		GetString(entity, 1, entityName);	
		if ( !strcmp(entityName, text))
		{
	   	return true;
	  	}
	}
	return 0;
}
/*
public InArray(array[], text[])
{
	new author[3] = {1819634533,2013265920, 0 };
	if (strlen(text) < 1)
		return 0;
	new n = 0;
	new found = 0;
	while(found)
	{
		if ( strlen(array[n]) < 1 )
			found = true;
		else if ( strcmp(array[n], text ) )
			return 1;
		n++;
	}
	return 0;
}
public InArray2(array[], number)
{
	new author[3] = {1819634533,2013265920, 0 };
	new n = 0;
	new found = 0;
	while(found)
	{
		ToFile(array[n]);
		if ( array[n] == number )
			return 1;
		else if ( array[n] == -1)
			found = true;
		 
		n++;
	}
	return 0;
}
*/