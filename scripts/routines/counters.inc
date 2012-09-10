/* Counters */
enum CounterLocation {
	name[20 char],
	x,
	y
}

new counters[3][CounterLocation] = { 
	{!"p_rupees", 72, 36}, 
	{!"p_arrows", 136, 36}, 
	{!"p_bombs", 200, 36}
}


CreateCounters()
{
	for ( new q = 0; q < 3; q++ )
	{
		EntityCreate("counter", counters[q][name], 1,1,1, GLOBAL_MAP);
	}
}
