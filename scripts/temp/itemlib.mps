
// Max number of different random items we can give out
new MaxItems = 30;

//----------------------------------------
// Name: Init()
//----------------------------------------
public Init()
{
   // Setup several strings to hold the item names which can be dropped
   AllocateStrings("this", MaxItems + 3, 32);
}

//----------------------------------------
// Name: AddItem()
//----------------------------------------
public AddItem(item[], probability)
{
   new n = 0;
   new itemStr[20];
  
   // Get the Number of items currently stored
   new NumItems;
   NumItems = GetValue("this", MaxItems+1);

   // Go through all this entities strings and find a free space
   for (n = 0; n < MaxItems; n++)
   {
      GetString("this", n, itemStr);

      if (strlen(itemStr) < 3)
      {
         // This one is free - record the item info here
         SetValue("this",  n,  probability);
         SetString("this", n, item);

         // Keep track of the number of items
         SetValue("this", MaxItems+1,  NumItems+1);
         return;
      }
   }
}


//----------------------------------------
// Name: RemoveItem()
//----------------------------------------
public RemoveItem(item[])
{
   new n = 0;
   new itemStr[20];

   new NumItems = GetValue("this", MaxItems+1);

   // Go through all this entities strings and match it with supplied item string
   for (n = 0; n < MaxItems; n++)
   {
      GetString("this", n, itemStr);

      if (strcmp(itemStr, item)==0)
      {
         // Delete this entry from the list
         SetValue("this",  n,  0);
         SetString("this", n, " ");

         // Keep track of the number of items
         SetValue("this", MaxItems+1,  NumItems-1);
         return;
      }
   }
}


//----------------------------------------
// Name: GetRandomItem()
//----------------------------------------
public GetRandomItem(x, y, item[])
{
   new n = 0;
   new tcount = 0;
   new pcount = AddProbabilities();
   new itemcode[20];

   /* If item[] is set to an entity code then create that entity
      instead of a random one */
   if ( strlen(item) > 2)
   {
      CreateItem(item, x, y);
      return;
   }
   
   // Generate a random number between 0 and pcount
   new r = random(pcount) * 4;
   
   for (n = 0; n < MaxItems; n++)
   {
      tcount += GetValue("this",  n);
     
      if (tcount > r)
      {
         // We have got our item - copy its code into the buffer supplied
         GetString("this", n, itemcode);
         CreateItem(itemcode, x, y);
         return;
      }
   }

   // No item dropped
}


//----------------------------------------
// Name: CreateItem()
//----------------------------------------
CreateItem(buffer[], x, y)
{
   new ident[20]; 
   new sprite[20];
   CreateEntity(buffer, x, y, ident);

   // adjust the new item's position a little base on its width and height
   GetImage(ident, sprite);
   new Iwidth  = GetWidth(sprite);
   new Iheight = GetHeight(sprite);
   SetX(ident, GetX(ident) - Iwidth / 2);
   SetY(ident, GetY(ident) - Iheight / 2);

   // Make this new Item "bounce" a little
   CallFunction(ident, false, "StartBounce", "NULL");
}


//----------------------------------------
// Name: AddProbabilities()
//----------------------------------------
AddProbabilities()
{
   new pcount = 0;
   new n = 0;

   // Go through all stored probabilities and add them together
   for (n = 0; n < MaxItems; n++)
      pcount += GetValue("this",  n);

   return pcount;
}

//----------------------------------------
// Name: DrawItemNumber()
//----------------------------------------
public DrawItemNumber( num, x, y, depth, alpha )
{
	// Some items will have numbers on them to say what they are
	// Worth, like bombs arrows etc.. this function will draw them in.
	// Have a pre-set list of numbers to draw
	if ( num == 1)
		PutSprite("_item1", x, y, depth + 1, 0, 255, 255, 255, alpha);
	else if ( num == 2 )
		PutSprite("_item2", x, y, depth + 1, 0, 255, 255, 255, alpha);
		
	else if ( num == 5 )
		PutSprite("_item5", x, y, depth + 1, 0, 255, 255, 255, alpha);
	
	else if ( num == 10 )
	{
		PutSprite("_item1", x, y, depth + 1, 0, 255, 255, 255, alpha);
		PutSprite("_item0", x + 3, y, depth + 1, 0, 255, 255, 255, alpha);
	}
	else if ( num == 20 )
	{
		PutSprite("_item2", x, y, depth + 1, 0, 255, 255, 255, alpha);
		PutSprite("_item0", x + 3, y, depth + 1, 0, 255, 255, 255, alpha);
	}
	else if ( num == 50 )
	{
		PutSprite("_item5", x, y, depth + 1, 0, 255, 255, 255, alpha);
		PutSprite("_item0", x + 5, y, depth + 1, 0, 255, 255, 255, alpha);
	}
	else if ( num == 100 )
	{
		PutSprite("_item1", x, y, depth + 1, 0, 255, 255, 255, alpha);
		PutSprite("_item0", x + 3, y, depth + 1, 0, 255, 255, 255, alpha);
		PutSprite("_item0", x + 7, y, depth + 1, 0, 255, 255, 255, alpha);
	}
	else if ( num == 200 )
	{
		PutSprite("_item2", x, y, depth + 1, 0, 255, 255, 255, alpha);
		PutSprite("_item0", x + 3, y, depth + 1, 0, 255, 255, 255, alpha);
		PutSprite("_item0", x + 7, y, depth + 1, 0, 255, 255, 255, alpha);
	}

}

