MIDIItem2 {
	classvar <>folder;
	var <>midiEvents , <name, <>initialCCValues;
	var stamp;
	var restFirst, <initialRest, <notes, <ccTracks;
	var takes;
	var <>mk;
	classvar midiout;

	*initClass {
		var parent;
		Class.initClassTree(MIDIOut);
		folder = this.filenameSymbol.asString.dirname.dirname +/+ "MIDI-items";
		File.exists(folder).not.if{ "mkdir %".format(folder).unixCmd };
		Event.addEventType(\setCC, { CC(~ctlNum, mk: ~mk).setRaw( ~control ) });
		Event.addEventType(\setBend, { CC(~ctlNum, mk: ~mk).setRaw( ~control ) });
		Event.addEventType(\setPoly, {
			( ~mk.keys[~midinote] != 0 ).if {
				 ~mk.keys[~midinote].().set(\poly, ~polyTouch) 
			}{
				~type = \rest
			}
		})	
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
			^Object.readArchive(folder +/+ name).mk_(mk) //saved mk won't be right otherwise - should not even save?
		} {
			\new.postln; 
			^super.new.init(name, restFirst, mk)
		}
	}
	*newFrom{ |midiEvents mk|
		^ MIDIItem2( UniqueID ).mk_(mk).midiEvents_(midiEvents)
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
	ccPbind { |num |
		^this.ccTracks[num].eventsToPatternPairs.p
	}
	ccPbinds {
		^this.ccTracks.keys.collect{ |x|
			try{this.ccPbind(x)}
		}.select{|i| i.notNil}.asArray 
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
			[
				this.notesPbind ,
			]
			++ this.ccPbinds
			// ++ (initialRest ++ ccTracks[\poly]  => _.q)
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
		midiEvents = notes ++ midiEvents.reject{|e| e.type == \mk} => _.sort{|i j| i.timestamp < j.timestamp}
	}
	makeCCs { //seperate CC bend and poly data into tracks with \dur key for use in Pbinds
		ccTracks = midiEvents.select{|e| e.midicmd == \control }.copy // do I need copy here??
		.select{|i| i.ctlNum.notNil}
		.sort{ |i j|
			i.ctlNum  < j.ctlNum
		}
		.separate{ |i j| i.ctlNum != j.ctlNum}
		.do{|subarray| subarray.setDurs }
		.collect{|subarray| subarray[0] !? {|i| i.ctlNum -> subarray }}
		.asDict;
		ccTracks.add(
			\poly -> midiEvents.select{|e| e.midicmd == \polytouch }.copy
			.setDurs
		);
		ccTracks.add(
			\bend -> midiEvents.select{|e| e.midicmd == \bend }.copy.setDurs
		);
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
		mk.activate;
		midiEvents = List[];
		CC.getValues.asKeyValuePairs.pairsDo{ | i j |
			midiEvents.add(
				(
					midicmd: \control,
					timestamp: SystemClock.seconds - start,
					type: \setCC,
					initial: true,
					mk: mk,
					// midiout: midiout ? this.class.getMidiOut,
					ctlNum: i,
					control: CC(i).spec.unmap(j) * CC(i).rawScale, //put back in original
				)
			)
		};
		midiEvents.add (
			(
				midicmd: \control,
				timestamp: SystemClock.seconds - start,
				type: \setPoly,
				initial: true,
				mk: mk,
				// midiout: midiout ? this.class.getMidiOut,
				ctlNum: \polytouch,
				control: 0,
				midinote: \r
			)
	);
		restFirst.if{ initialRest = [( type: \rest, timestamp: SystemClock.seconds - start)] };
		
		[\noteOn, \noteOff, \control, \polytouch, \bend ].do{ |cmd|
			MIDIdef(\record ++ cmd => _.asSymbol, func: { |val num| 
				midiEvents.add(
					(
						midicmd: cmd,
						timestamp: SystemClock.seconds - start,
						midiout: midiout ? this.class.getMidiOut,
						// type: \midi
					).postln
					++
						switch( cmd, 
							\noteOn,{ (type: \mk, mk: mk, midinote: num, amp: val/127 ) },
							\noteOff,{ (type: \midi, mk: mk, midinote: num, amp: val/127 ) },
							\polytouch, { (type: \setPoly, midinote: num, polyTouch: val, mk: mk) },
							\control, { (type: \setCC, ctlNum:num, control: val, mk: mk)},
							\bend, { (type: \setBend, ctlNum:\bend, control: val)},
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
	playRaw {
		var playbackEvents;
		this.stop;
		fork{
			// midiEvents.collect(_.timestamp).differentiate.drop(1).do{|i x|
			this.midiEvents.collect(_.timestamp).differentiate.drop(1).do{|i x|
				midiEvents[x].play;
				i.wait;
			}
		}
	}
	play {
		^this.player.play
	}
	player{ |num|
		^MIDIItemPlayer(I.d, midiEvents, mk)
		// ^MIDIItemPlayer(
		// 	{|events| events.reject{|e| e.type == \setCC and: ( e.ctlNum == num )} },
		// 	this.midiEvents,
		// 	this.mk
		// );
	}
	save {
		notes.isNil.if{this.makeNotes};
		this.writeArchive( folder +/+ name)
	}
	reset {
		midiEvents = List.new
	}

}

MIDIItemPlayer{ //class to filter and play MIDIItems
	var <func, <midiEvents, <mk, <outEvents;
	*new {|func midiEvents mk|
		^super.newCopyArgs(func, midiEvents, mk).init
	}
	init{
		outEvents = func.(midiEvents)
	}
	play {
		fork{
			outEvents.collect(_.timestamp).differentiate.drop(1).do{|i x|
				outEvents[x].play;
				i.wait;
			}
		}		
	}
	filter {| func |
		^MIDIItemPlayer(
			func,
			this.outEvents,
			this.mk
		);
	}
	muteCC{ |num|
		^MIDIItemPlayer(
			{|events| events.reject{|e| e.type == \setCC and: ( e.ctlNum == num )} },
			this.outEvents,
			this.mk
		);
	}
	initialCCOnly{ |num|
		^MIDIItemPlayer(
			{|events| events.reject{|e| e.type == \setCC and: ( e.ctlNum == num ) and: (e.initial.isNil)} },
			midiEvents,
			mk
		)
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
			^this.collect({ |i| i.asAssociations.sort.asPairs}).flop.collect{|i|
				( i[0].class == Symbol ).if { i[0] }{ i.q }
			}
		}
}
