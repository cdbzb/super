// String EventTypes
Event.addEventType(\yoeString3, {
    var instance;
    var releaseTime = ~release ? 2;
    
    // If gates are all zero, release current instance
    (~gates == [0, 0, 0, 0, 0]).if {
        Yoeminrak.env.use {
            ~currentInstance !? { |inst|
				fork{
					inst[\synth].release(releaseTime);
					s.sync;
					~currentInstance = nil;
				}
            };
        };
    } {
        // Otherwise, create new instance or update existing
        Yoeminrak.env.use {
            // If no current instance, create one
            (~currentInstance.isNil).if {
                ~currentInstance = ~func.();
            };
            instance = ~currentInstance;
        };
        
        // Set gates on the synth
        ~gates.notNil.if {
            instance[\synth].setn(\gates, ~gates);
        };
        
        // Set other synth parameters
        instance[\synth].set(\release, releaseTime);
        ~freqLag.notNil.if { instance[\synth].set(\freqLag, ~freqLag) };
        
        // Update busses from event parameters
        Server.default.makeBundle(0.0, {
            ~extra !? _.();
            
            // List of bus-mappable parameters
            [\root, \ornament, \chord, \width, \knum, \select, 
             \ampDist, \durDist, \ampDistParam, \durDistParam, 
             \ampScale, \durScale, \amp].do { |key|
                var value = currentEnvironment[key];
                var bus = instance[key];
                
                value.notNil.if {
                    case
                    { value.isNumber } {
                        try { instance[\running][key].release(releaseTime ? 0.1) };
                        bus.setn(value ! bus.numChannels);
                    }
                    { value.isKindOf(Function) } {
                        instance[\running].put(key, {
                            Env.cutoff(releaseTime: 0.1, level: 1.0, curve: \lin).kr(2, \gate.kr)
                            * value
                            => Out.kr(bus.index, _)
                        }.play);
                    }
                    { value.isKindOf(Array) } {
                        bus.setn(value);
                    }
                    { value.isKindOf(Tuple2) } {
                        bus.setAt(value.at1, value.at2);
                    }
                    { value.isKindOf(Tuple3) } {
                        Yoeminrak.env[\go].(bus, value.at1, value.at2, value.at3);
                    }
                    { value.isKindOf(Tuple4) } {
                        Yoeminrak.env[\go].(bus, value.at1, value.at2, value.at3, value.at4);
                    };
                };
            };
        });
    };
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
