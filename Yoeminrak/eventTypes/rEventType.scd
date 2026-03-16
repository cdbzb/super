// Rest EventType
Event.addEventType(\yoeRest,{
	~extra !? _.();
	~dur = (~dur ? 1) * Yoeminrak.secDur.wrapAt( ~section ? 0 ) / 20;
	~type = \rest;
	currentEnvironment.play
});
