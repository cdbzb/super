MIDIItem2 {
	classvar <>folder;
	var <midiEvents , <name, <>initialCCValues;
	var stamp;
	var restFirst, initialRest, <notes, <ccTracks;
	var takes;
	var <mk;
	classvar midiout;

	*initClass {
		var parent;
		Class.initClassTree(MIDIOut);
		folder = this.filenameSymbol.asString.dirname.dirname +/+ "MIDI-items";
		File.exists(folder).not.if{ "mkdir %".format(folder).unixCmd };
		Event.addEventType(\setCC, { CC(~ctlNum).setRaw( ~control ) });
		Event.addEventType(\setBend, { CC(~ctlNum).setRaw( ~control ) })
	}

	*getMidiOut {
			MIDIClient.initialized.not.postln
			.if{MIDIClient.init};
			midiout = MIDIOut.newByName("IAC Driver", "Bus 1");
			^midiout
	}

	*new { |name restFirst=true mk|
		folder.asPathName.entries.collect(_.fileName).includesEqual(name.asString).if{
			\reading.postln; 
			^Object.readArchive(folder +/+ name)
		} {
			\new.postln; 
			^super.new.init(name, restFirst, mk)
		}
	}

	init { |n r m|
		mk = m ? \default;
		"mk: %".format(mk).postln;
		takes = List[];
		restFirst = r;
		name = n;
		midiEvents = List.new;
		initialCCValues = ();
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

	noteEvents { 
		^notes.collect{|i|
			i.copy
			.type_( \mk )
			.mk_(mk)
		}
	}
	ccEvents { |cc|
		^ccTracks[cc].collect{|i|
			i.copy
			.type_( \setCC )
		}
	}
	ccPbind { |num |
		^this.ccEvents(num).eventsToPatternPairs.p
	}
	ccPpar {
		^this.ccTracks.keys.collect{ |x|
			this.ccPbind(x)
		} => Ppar (_)
	}
	notesPbind { 
		var res = List.new;
		var keys = [\midinote, \sustain, \amp, \dur];
		keys.do{|key|
			res.add(key);
			res.add(  
				notes.collect{|i|
					i[key] ? 0 //avoid nil for rest
				}.q
			)
		};
		res = res ++ [
			type: \mk,
			mk: mk,
		] => _.p;
		^res
	}
	ppar {
		^Ppar(
			[ this.notesPbind ]
			++ this.ccPpar
		)
	}
	makeNotes {
		// should copy be deepCopy??
		var on = midiEvents.select{|e| e.midicmd == \noteOn}.deepCopy;
		var off = midiEvents.select{|e| e.midicmd == \noteOff}.deepCopy;
		var findMatch = {|midinote| off.collect{|e| e.midinote}.indexOf(midinote)}; //returns index
		on.do{|e| var match = off.removeAt(findMatch.(e.midinote)).postln; e.sustain = match.timestamp - e.timestamp; };
		notes = initialRest.copy ? [] ++ on;
		notes.setDurs;
	}
	makeCCs {
		ccTracks = midiEvents.select{|e| [\control, \bend].includes(e.midicmd) }.deepCopy 
		.select{|i| i.ctlNum.notNil}
		.sort{ |i j|
			var a = i.ctlNum.isKindOf(Symbol).if{0}{i.ctlNum};
			var b = j.ctlNum.isKindOf(Symbol).if{0}{j.ctlNum};
			a < b
		}
		.separate{ |i j| i.ctlNum != j.ctlNum}
		.do{|subarray| subarray.setDurs }
		.collect{|subarray| subarray[0] !? {|i| i.ctlNum -> subarray }}
		.asDict;
	}
	ccsAsArraysOfPoints{
		^midiEvents.select{|e| e.midicmd == \control}.deepCopy
		.sort{ |i j| i.ctlNum < j.ctlNum }
		.separate{ |i j| i.cltNum == j.ctlNum }
		.collect{|sub| sub[0].ctlNum -> sub.collect{|i| Point(i.timestamp, i.control)}}
		=> _.asDict
	}
	stop{
		takes.insert(0, midiEvents);

		[\noteOn, \noteOff, \control, \polytouch, \bend ].do{
			|cmd|
			MIDIdef(\record ++ cmd => _.asSymbol).free
		};

		this.makeNotes;

		this.makeCCs;
		// midiEvents = midiEvents.setDurs //for midiEvents.play (raw play)
	}
	at{|num|
		^takes[num]
	}
	record{
		var start = SystemClock.seconds;

		midiEvents = List[];
		CC.getValues.asKeyValuePairs.pairsDo{ | i j |
			midiEvents.add(
				(
					midicmd: \control,
					timestamp: SystemClock.seconds - start,
					type: \midi,
					midiout: midiout ? this.class.getMidiOut,
					ctlNum: i,
					control: 
					CC(i).spec.unmap(j)
					// j
					* CC(i).rawScale, //put back in original

				).debug("CC:")
			)
		};

		restFirst.if{ initialRest = [( type: \rest, timestamp: SystemClock.seconds - start)] };
		
		[\noteOn, \noteOff, \control, \polytouch, \bend ].do{ |cmd|
			MIDIdef(\record ++ cmd => _.asSymbol, func: { |val num| 
				midiEvents.add(
					(
						midicmd: cmd,
						timestamp: SystemClock.seconds - start,
						midiout: midiout ? this.class.getMidiOut,
						type: \midi
					).postln
					++
						switch( cmd, 
							\noteOn,{ (midinote: num, amp: val/127 ) },
							\noteOff,{ (midinote: num, amp: val/127 ) },
							\polytouch, { (midinote: num, polyTouch: val) },
							\control, { (ctlNum:num, control: val)},
							\bend, { (ctlNum:\bend, control: val)},
							// \bend, { (val: val, ctlNum:) }
							
						)
						=> _.postln
					)
				},msgType: cmd, 
				srcID: KS.id,
				//eliminate cc0
				argTemplate: {|i| (cmd == \control).if{ i.isStrictlyPositive }{true}}
			)};
	}
	play {
		this.stop;
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
			^this.collect({ |i| i.asAssociations.sort.asPairs}).flop.collect{|i| ( i[0].class == Symbol ).if { i[0] }{ i.q }}
		}
}
