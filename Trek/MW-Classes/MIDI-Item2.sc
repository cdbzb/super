MIDIItem2 {
	classvar <>folder;
	var <midiEvents , <name, <>initialCCValues;
	var stamp;
	var restFirst, <notes, <ccTracks;
	classvar midiout;

	*initClass {
		var parent;
		Class.initClassTree(MIDIOut);
		folder = this.filenameSymbol.asString.dirname.dirname +/+ "MIDI-items";
		File.exists(folder).not.if{ "mkdir %".format(folder).unixCmd };
		Event.addEventType(\setCC, { CC(~ctlNum).set( ~control / 127 ) })
	}

	*getMidiOut {
			MIDIClient.init;
			midiout = MIDIOut.newByName("IAC Driver", "Bus 1");
			^midiout
	}

	*new { |name restFirst=false synthFunc|
		folder.asPathName.entries.collect(_.fileName).includesEqual(name.asString).if{
			\reading.postln; 
			^Object.readArchive(folder +/+ name)
		} {
			\new.postln; 
			^super.new.init(name, restFirst, synthFunc)
		}
	}

	*insertNew{|name|
		Nvim.replace( "MIDIItem2(\\\"%\\\")".format(name ++ "_" ++  Date.getDate.stamp) )
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
	ccEvents { |cc|
		^ccTracks[cc].collect{|i|
			i.copy
			.type_( \setCC )
		}
	}
	ccPbind { |num microkeys|
		^this.ccEvents(num).eventsToPatternPairs.p
	}
	ccPpar { |microkeys|
		^this.ccTracks.keys.collect{ |x|
			this.ccPbind(x, microkeys)
		} => Ppar (_)
	}
	notesPbind { |microkeys|
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
	ppar {
		^Ppar(
			[ this.notesPbind ]
			++ this.ccPpar
		)
	}
	init { |n r sf|
		restFirst = r;
		name = n;
		midiEvents = List.new;
		initialCCValues = ();
	}
	makeNotes {
		// should copy be deepCopy??
		var on = midiEvents.select{|e| e.midicmd == \noteOn}.deepCopy;
		var off = midiEvents.select{|e| e.midicmd == \noteOff}.deepCopy;
		var findMatch = {|midinote| off.collect{|e| e.midinote}.indexOf(midinote)}; //returns index
		on.do{|e| var match = off.removeAt(findMatch.(e.midinote)).postln; e.sustain = match.timestamp - e.timestamp; };
		on.setDurs;
		notes = on
	}
	makeCCs {
		ccTracks = midiEvents.select{|e| e.midicmd == \control}.copy 
		.sort{ |i j| i.ctlNum < j.ctlNum }
		.separate{ |i j| i.cltNum == j.ctlNum }
		.do{|subarray| subarray.setDurs }
		.collect{|subarray| subarray[0] !? {|i| i.ctlNum -> subarray }}
		.asDict;
	}
	ccsAsArraysOfPoints{
		^midiEvents.select{|e| e.midicmd == \control}.copy
		.sort{ |i j| i.ctlNum < j.ctlNum }
		.separate{ |i j| i.cltNum == j.ctlNum }
		.collect{|sub| sub[0].ctlNum -> sub.collect{|i| Point(i.timestamp, i.control)}}
		=> _.asDict
	}
	stop{
		[\noteOn, \noteOff, \control, \polytouch, \bend ].do{
			|cmd|
			MIDIdef(\record ++ cmd).free
		};

		this.makeNotes;
		this.makeCCs;
		// midiEvents = midiEvents.setDurs //for midiEvents.play (raw play)
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
						midiout: midiout ? this.getMidiOut,
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
				srcID: KS.id,
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
		notes.isNil.if{this.makeNotes};
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
 
+ SequenceableCollection {
		setDurs { |finalDur = 1| 
			var durs = this
			.sort{|i j| i.timestamp < j.timestamp}
			.collect(_.timestamp).differentiate.drop(1) ++ finalDur ;
			durs.do{|i x| try{ this[x].dur = i }  };
			^this
		}
		eventsToPatternPairs{
			^this.collect(_.asKeyValuePairs).flop.collect{|i| ( i[0].class == Symbol ).if { i[0] }{ i.q }}
		}
}
