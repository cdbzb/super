// Rest EventType
Event.addEventType(\yoeRest,{
	~dur = (~dur ? 1) * Yoeminrak.secDur.wrapAt( ~section ? 0 ) / 20;
	~type = \rest;
	currentEnvironment.play
});
