// String EventTypes
Event.addEventType(\yoeString3,{
	(~gates != [0,0,0,0,0]).if {
		Yoeminrak.env.use {( ~playing.isNil ).if {~synth = ~func.();~playing=true}};
	};
	Server.default.makeBundle(0.2,{
		~gates.notNil.if {
			Yoeminrak.env[\synth].setn(\gates, ~gates);
			(~gates == [0,0,0,0,0]).if { Yoeminrak.env[\playing] = nil };
		};
		~extra !? _.();
		Yoeminrak.env[\synth].set(\release, ~release);
		Yoeminrak.env[\synth].set(\freqLag, ~freqLag);
		currentEnvironment.keysValuesDo {|i j|
			Yoeminrak.env.use{
				Yoeminrak.env[i] !?
				{|bus|
					case
					{ j.isNumber } { try { ~running[i].release(~release ? 0.1) }; bus.setn(j ! bus.numChannels) } 
					{ j.isKindOf(Function)} {
						~running.put(i, {
							Env.cutoff(releaseTime:0.1, level:1.0, curve:\lin).kr(2, \gate.kr)
							* j
							=> Out.kr(bus, _) 
						}.play )
					}
					{ j.isKindOf(Array) } { bus.setn(j) }
					{ j.isKindOf(Tuple2) } { bus.setAt(j.at1, j.at2) }
					{ j.isKindOf(Tuple3) } { ~go.(bus, j.at1,j.at2, j.at3  ) }
					{ j.isKindOf(Tuple4) } { ~go.(bus, j.at1,j.at2, j.at3, j.at4) }
				}
			}
		}
	}
)
});

Event.addEventType(\yoeString2, {
	var freq = 5.collect {|i|~freq.asArray.wrapAt(i)} ;
	var gates = 5.collect {|i| 
		var f = ~freq.asArray.wrapAt(i);
		if(f == "r", { 0 }, { 1 })
	};
	var pitches = 5.collect {|i|
		var f = ~freq.asArray.wrapAt(i);
		if((f == "r") || (f == "-"), { Yoeminrak.env[\pitch].getnSynchronous(5)[i] }, { f })
	};
	var go = { |newPitch time=1 curve| 
		{
			Env([Yoeminrak.env[\pitch].kr => Latch.kr(_,1), newPitch], time, curve).kr(2,gate:1)
			=> Out.kr(Yoeminrak.env[\pitch].index, _)
		}.play 
	};

	( Yoeminrak.env[\synth].isPlaying.not or: Yoeminrak.env[\resting] ).if{
		Yoeminrak.env.use{~synth=~synthFunc2.(~freqLag, ~knum,~width).register; ~resting = false};
	};

	Yoeminrak.env[\synth].set(\freqLag, ~freqLag ? 2);
	try{
		go.(pitches, ~time ? 0.1 => _.postln, ~curve);
	};
	(~freq.asString == "r" ).if {
		Yoeminrak.env[\synth].setn(\myGate, [0,0,0,0,0]);
	} {
		Yoeminrak.env[\synth].setn(\myGate, [1,1,1,1,1]);
	};
	~ornament !? _.(~dur);
	Yoeminrak.env[\synth].setn(\knum, ~knum);
	Yoeminrak.env[\synth].setn(\chord, ~chord);
	Yoeminrak.env[\synth].setn(\select, ~select);
	Yoeminrak.env[\synth].setn(\width, ~width ? 1.05);
});

Event.addEventType(\yoeString, {
	var freq = 5.collect {|i|~freq.asArray.wrapAt(i)} ;
	var gates = 5.collect {|i| 
		var f = ~freq.asArray.wrapAt(i);
		if(f == "r", { 0 }, { 1 })
	};
	var pitches = 5.collect {|i|
		var f = ~freq.asArray.wrapAt(i);
		if((f == "r") || (f == "-"), { Yoeminrak.env[\pitch].getnSynchronous(5)[i] }, { f })
	};
	var go = { |newPitch time=1 curve| 
		{
			Env([Yoeminrak.env[\pitch].kr => Latch.kr(_,1), newPitch], time, curve).kr(2,gate:1).poll 
			=> Out.kr(Yoeminrak.env[\pitch].index, _)
		}.play 
	};

	( Yoeminrak.env[\synth].isPlaying.not or: Yoeminrak.env[\resting] ).if{
		Yoeminrak.env.use{~synth=~synthFunc.(~freqLag, ~knum,~width).register; ~resting = false};
	};

	~freqLag.notNil.if {Yoeminrak.env[\synth].set(\freqLag, ~freqLag )};
	try{
		go.(pitches, ~time ? 0.1 => _.postln, ~curve);
	};
	(~freq.asString == "r" ).if {
		Yoeminrak.env[\synth].setn(\myGate, [0,0,0,0,0]);
	} {
		Yoeminrak.env[\synth].setn(\myGate, [1,1,1,1,1]);
	};
	~ornament !? _.(~dur);
	Yoeminrak.env[\synth].setn(\knum, ~knum);
	Yoeminrak.env[\synth].setn(\width, ~width ? 1.05);
});
