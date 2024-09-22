MIDIItem2 {
	classvar <>folder;
	var <midiEvents , <name, <>initialCCValues;
	var stamp;
	var restFirst, <notes;
	classvar midiout;

	*initClass {
		var parent;
		Class.initClassTree(MIDIOut);
		fork{
			MIDIClient.init;
			midiout = MIDIOut.newByName("IAC Driver", "Bus 1");
		};
		folder = this.filenameSymbol.asString.dirname.dirname +/+ "MIDI-items";
		File.exists(folder).not.if{ "mkdir %".format(folder).unixCmd };
	}
	*new {|name restFirst = false synthFunc|
		folder.asPathName.entries.collect(_.fileName).includesEqual(name.asString).if{\reading.postln; ^Object.readArchive(folder +/+ name)}
		{\new.postln; ^super.new.init(name, restFirst, synthFunc)}
	}
	*insertNew{|name|
		Nvim.replaceLineWith( "MIDIItem(\\\"%\\\")".format(name ++ "_" ++  Date.getDate.stamp) )
	}
	*mostRecent {
		^
		folder +/+
		( folder => PathName(_) => _.files => _.collect( { |i| i.fileNameWithoutExtension} ) => _.sort => _.last)
		=> Object.readArchive( _ )
	}
	noteEvents { |microkeys|
		^notes.collect{|i|
			i.copy
			.type_( \mk )
			.mk_(microkeys)
		}
	}
	asPbind { |microkeys|
		var res = List.new;
		var keys = [\midinote, \sustain, \amp, \dur];
		keys.do{|key|
			res.add(key);
			res.add(  
				notes.collect{|i|
					i[key]
				}.q
			)
		};
		res = res ++ [
			type: \mk,
			mk: microkeys,
			
		] => _.p;
		^res
	}
	init { |n r sf|
		restFirst = r;
		name = n;
		midiEvents = List.new;
		initialCCValues = ();
	}
	makeNotes {
		var on = midiEvents.select({|e| e.midicmd == \noteOn}).copy;
		var off = midiEvents.select({|e| e.midicmd == \noteOff}).copy;
		var findMatch = {|midinote| off.collect{|e| e.midinote}.indexOf(midinote)}; //returns index
		on.do{|e| var match = off.removeAt(findMatch.(e.midinote)).postln; e.sustain = match.timestamp - e.timestamp; };
		on.collect(_.timestamp).differentiate.drop(1) ++ 1 => _.do{|i x|
			on[x].dur = i
		};
		notes = on
	}
	stop{
		[\noteOn, \noteOff, \control, \polytouch, \bend ].do{|cmd|
			MIDIdef(\record ++ cmd).free
		}
	}
	record{
		initialCCValues = CC.getValues;

		restFirst.if{ midiEvents.add( (type: \rest, timestamp: SystemClock.seconds ) ) };
		
		[\noteOn, \noteOff, \control, \polytouch, \bend ].do{ |cmd|
			MIDIdef(\record ++ cmd, func: { |val num| 
				midiEvents.add(
					(
						midicmd: cmd,
						timestamp: SystemClock.seconds,
						midiout: midiout,
						type: \midi
					)
					++
						switch( cmd, 
							\noteOn,{ (midinote: num, amp: val/127 ) },
							\noteOff,{ (midinote: num, amp: val/127 ) },
							\polyTouch, { (midinote: num, polyTouch: val) },
							\control, { (ctlNum:num, control: val)},
							\bend, { (val: val) }
							
						)
					)
				},msgType: cmd, 
				//eliminate cc0
				argTemplate: {|i| (cmd == \control).if{ i.isStrictlyPositive }{true}}
			)};
	}
	play{
		this.stop;
		CC.setValues(initialCCValues);
		fork{
			midiEvents.collect(_.timestamp).differentiate.drop(1).do{|i x|
				midiEvents[x].play;
				i.wait;
			}
		}
	}
	save {
		this.writeArchive( folder +/+ name)
	}
	reset {
		midiEvents = List.new
	}

}
+ Synth{
	mapCC{ |param num spec|
		var cc = CC(param, num, spec);
		this.set(param, cc.spec.map(cc.spec.map(cc.val)));
		cc.mapSynth(this, param)
	}
}
