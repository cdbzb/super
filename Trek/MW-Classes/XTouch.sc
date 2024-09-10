XTouch : XMIDIController {
	classvar <>id = 1879431245;// INT
	classvar <>defs;
	//classvar <>id =  -1378392801;// EXT
	//classvar <>id = 1779843049;

	classvar functions;
	classvar <>mappings;
	classvar functionKeyToggles;
//	classvar functionKeyNotes=(54..61);
	classvar <labels;
	*add { |function,note| 
		mappings.add(function->note);
		this.applyMappings;
//		functions.add{ MIDIFunc.noteOn(function,note,srcID:id) } }
}
	*map { |function key|
		var note=labels.at(key.asSymbol);
		this.add(function,note);
		^this
	}
	*resetMappings {
		defs.do(_.free);
	}
	*applyMappings {
			mappings.pairsDo{|function label| 
			// use event for mapping (function, description)
			// mappings.pairsDo{| event label | 
			// var function = pair.function
				var midinote = labels.at(label);
				function = (function.class == Event).if{
					function.function.value //because function.funtion is a Ref
				}{
					function
				};
				function.cs.post;' '.post;midinote.postln;
				//MIDIFunc.noteOn(function,midinote,srcID:1779843049).permanent_(true);
				defs.add(MIDIdef.noteOn(\X ++ label =>_.asSymbol, function, midinote,srcID:XTouch.id).permanent_(true));
			};
	}
	*dump{

		mappings.keys.do{ |i|
			mappings.at(i).asString
			+
			(i.class == Event).if{
				i.name
			}{
				i.cs
			}
			=> _.postln
		}
	}
	*initClass {
		defs = List.new;
		functions=List.new();
		functionKeyToggles=Bus.control(Server.default,8);
		labels=Dictionary.newFrom([
			'track',40,
			'pan',42,
			'eq',44,
			'send',41,
			'plug-in',43,
			'inst',45,
			'global',51,
			'midi',62,
			'inputs',63,
			'audio tracks',64,
			'audio inst',65,
			'aux',66,
			'buses',67,
			'outputs',68,
			'user',69,
			'replace',88,
			'f1',54,
			'f2',55,
			'f3',56,
			'f4',57,
			'f5',58,
			'f6',59,
			'f7',60,
			'f8',61,
			'shift',70,
			'option',71,
			'read',74,
			'write',75,
			'trim',76,
			'save',80,
			'undo',81,

			'click',89,

			'solo',90,
			'rewind',91,
			'fast forward',92,
			'stop',93,
			'play',94,
			'record',81,

			'scrub',101,
			'bank up',47,


	]);
		mappings=Dictionary.newFrom([
			{
				Item.stop;
				TempoClock.all.do(_.clear);
				SystemClock.clear;
				Server.default.freeMyDefaultGroup;
				Pipe.new("pressf1.sh","w");
			}.addName(\stop),\stop,
			{ this.dump }.addName(\dump),\user,
			{ defer{Window.closeAll} }.addName( 'Close Windows' ),\global,
			{ defer{Server.default.meter}.addName('Meter'); },\inputs,
			{ defer{Server.default.plotTreeL}; }.addName( 'Plot Tree'),\midi,
			{ Item.arm; },\scrub,
			{ Item.armSection; },\solo,
			{ Item.abort_(true) },'fast forward',
			{ Song.play },\play,
			{ Part.play },'bank up',
			{Document.current.path.load}.addName('Load Document'),\rewind,
			{ Song.playSection(Song.cursor)} ,\click,
			{defer{ SynthDescLib.default.browse }},'inst',
			{Server.default.reboot},\replace
		]);


		fork{ 	
		//	MIDIClient.init;
		//	MIDIIn.connectAll;
			this.applyMappings;
		//	StageLimiter.activate;
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
		MIDIFunc.noteOn({ |vel num| vel.postln; num.postln;})

	}
}

KeyStage : XMIDIController {
	classvar <>id = -679037508;// INT
	classvar <playFunc;
	classvar <synths, <active;
	*initClass {
		ServerTree.add(
			{
				MIDIFunc.cc( {|val| if(val > 0) {Song.play}}, 41, nil, id );
				MIDIFunc.cc( {|val| if(val > 0) {~myFree.()}}, 42, nil, id )
			}
		);
	}
	*func { |synthFunc|
		synths = (0..128);
		active = List.new;
		MIDIdef.noteOn(key: \keyStage, func: {|v n c s|
			synths.put(n, synthFunc.value(v, n, c, s));
			active.add(n)
		});
		MIDIdef.noteOff(key:\keyStageOff, func:{|v n c s|
			synths[n].set(\gate, 0);
		});
	}
}
+Object{
	xplay{ |key|
		XTouch.map({this.play},key);
		^this
	}
}

+Function{
	addName { |name|
		^(name: name, function:`this)
	}
}
