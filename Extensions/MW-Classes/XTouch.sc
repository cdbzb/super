XTouch {
	classvar <>id = 1779843049;
	classvar functions;
	classvar <>mappings;
	classvar functionKeyToggles;
//	classvar functionKeyNotes=(54..61);
	classvar labels;
	*add { |function,note| 
		mappings.add(function->note);
		this.applyMappings;
//		functions.add{ MIDIFunc.noteOn(function,note,srcID:id) } }
}
	*addKey { |function key|
		var note=labels.at(key.asSymbol);
		this.add(function,note);
		^this
	}
	*resetMappings {
		
	}
	*applyMappings {
			mappings.pairsDo{|function midinote| 
//				MIDIdef.noteOn(midinote, function, srcID:id);
				MIDIFunc.noteOn(function,midinote,srcID:1779843049).permanent;
			};
	}
	*initClass {
		functions=List.new();
		functionKeyToggles=Bus.control(Server.default,8);
		labels=Dictionary.newFrom([
			'f1',54,
			'f2',55,
			'f3',56,
			'f4',57,
			'f5',58,
			'f6',59,
			'f7',60,
			'f8',61,
	]);
		mappings=Dictionary.newFrom([
			{
				Item.stop;
				TempoClock.all.do(_.clear);
				Server.default.freeMyDefaultGroup;
				Pipe.new("pressf1.sh","w");
			},93,
			{ defer{Window.closeAll} },51,
			{ defer{Server.default.meter}; },63,
			{ defer{Server.default.plotTreeL}; },62,
			{ Item.arm; },95,
			{ Item.armSection; },101,
			{ Item.abort_(true) },92,
			{ Song.play },94,
			{ Part.play; },47,
			{Document.current.path.load},91,
		]);


		fork{ 	MIDIClient.init;
			MIDIIn.connectAll;
			this.applyMappings;
			StageLimiter.activate;
		}
	}
	junk {
		|selector|
		selector=selector.asString;
		"f[1-8]".matchRegexp(~selector).if{~selector.at(1)}
	}

	/*
	XTouch.makeToggle(\f1,makeBus:true)
	XTouch.f1 //true
	XTouch.bus(\f1) //bus or return a control?
	SynthDef(\blah,{WhiteNoise.ar(0.1)*XTouch.bus(\f1).kr})
	NamedControl
	*/
	*new {
		^super.new.init()
	}
	init {
		111.postln;
		MIDIFunc.noteOn({ |vel num| vel.postln; num.postln;}
	)

	}
}


