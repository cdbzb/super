MIDIItem2 {
	classvar <>folder, <all;
	var <>midiEvents , <name, <>initialCCValues;
	var stamp;
	var restFirst, <initialRest, <notes ;
	var takes;
	classvar midiout, recording;

	*initClass {
		var parent;
		all = Dictionary.new(256);
		folder = this.filenameSymbol.asString.dirname.dirname +/+ "MIDI-items";
		File.exists(folder).not.if{ "mkdir %".format(folder).unixCmd };
	}

	*new { |name restFirst=true |
		all.keys.includes(name).if { ^all[name] };
		folder.asPathName.entries.collect(_.fileName).includesEqual(name.asString).if{
			\reading.postln; 
			^Object.readArchive(folder +/+ name).register //saved mk won't be right otherwise - should not even save?
		} {
			\new.postln; 
			^super.new.init(name, restFirst).register
		}
	}
	*newFrom{ |midiEvents |
		^ MIDIItem2( UniqueID ).midiEvents_(midiEvents)
	}

	init { |n r m|
		takes = List[];
		restFirst = r;
		name = n;
		midiEvents = List.new;
		initialCCValues = ();
	}
	register {
		all.add(name -> this)
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
		on.do{|e| var match = off.removeAt(findMatch.(e.midinote)); e.sustain = match.timestamp - e.timestamp; };
		notes = initialRest.copy ? [] ++ on;
		notes.setDurs;
		^notes ++ midiEvents.reject{|e| e.type == \mk} => _.sort{|i j| i.timestamp < j.timestamp}
	}
	ccsAsArraysOfPoints{
		^midiEvents.select{|e| e.midicmd == \control}.deepCopy
		.sort{ |i j| i.ctlNum < j.ctlNum }
		.separate{ |i j| i.cltNum == j.ctlNum }
		.collect{|sub| sub[0].ctlNum -> sub.collect{|i| Point(i.timestamp, i.control)}}
		=> _.asDict
	}
	*stopRecording {
		[\noteOn, \noteOff, \control, \polytouch, \bend ].do{
			|cmd|
			MIDIdef(\record ++ cmd => _.asSymbol).free
		};
		recording.stop; recording = nil;
	}
	stop {
		takes.insert(0, midiEvents);

		// this.makeNotes;  // move this to player
		//
		// this.makeCCs; //move this to player

		// midiEvents = midiEvents.setDurs //for midiEvents.play (raw play)
	}
	at {|num|
		^takes[num]
	}
	record { |mk|
		var start = SystemClock.seconds;
		mk.activate;
		recording = this;
		midiEvents = List[];
		CC.getValues.asKeyValuePairs.pairsDo{ | i j |
			midiEvents.add(
				(
					midicmd: \control,
					timestamp: SystemClock.seconds - start,
					type: \setCC,
					initial: true,
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
						// type: \midi
					).postln
					++
						switch( cmd, 
							\noteOn,{ (type: \mk, midinote: num, amp: val/127 ) },
							\noteOff,{ (type: \mkOff, midinote: num, amp: val/127 ) },
							\polytouch, { (type: \setPoly, midinote: num, polyTouch: val, ) },
							\control, {
								( num == 64 ).if{
									(type:\setDamper, control: val).postln 
								} { 
									(type: \setCC, ctlNum:num, control: val).postln
								} 
							},
							\bend, { (type: \setBend, ctlNum:\bend, control: val)},
							// \bend, { (val: val, ctlNum:) }
							
						)
						=> _.postln
					)
				},msgType: cmd, 
				//eliminate cc0
				msgNum: (cmd == \control).if{ (..127) },
				srcID: KS.id,
				// argTemplate: {|i| (cmd == \control).if{ i.isStrictlyPositive }{true}}
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
	play { |mk|
		^this.player.play(mk)
	}
	player {|func| 
		^if(recording != this) {
			MIDIItemPlayer(func ? I.d, this.makeNotes.deepCopy) 
		}{
			SelfReturningObject()
		}
		// ^MIDIItemPlayer(
		// 	{|events| events.reject{|e| e.type == \setCC and: ( e.ctlNum == num )} },
		// 	this.midiEvents,
		// 	this.mk
		// );
	}
	save {
		// notes.isNil.if{this.makeNotes};
		this.writeArchive( folder +/+ name)
	}
	reset {
		midiEvents = List.new
	}

}

MIDIItemPlayer { //class to filter and play MIDIItems
	var <func, <midiEvents, <outEvents, tracks;
	*new {|func midiEvents |
		^super.newCopyArgs(func, midiEvents).init
	}
	init{
		outEvents = func.(midiEvents)
	}
	play { |mk|
		outEvents.do{|e| 
			var playFunc = mk.notNil.if{ {e.mk_(mk).play} }{ { e.play } } ; 
			TempoClock.sched(e.timestamp, playFunc)
		}
	}
	tracks {
		^(tracks ? this.makeTracks)
	}
	makeTracks { //seperate CC bend and poly data into tracks with \dur key for use in Pbinds
		tracks = midiEvents.select{|e| e.midicmd == \control }.copy // do I need copy here??
		.select{|i| i.ctlNum.notNil}
		.sort{ |i j|
			i.ctlNum  < j.ctlNum
		}
		.separate{ |i j| i.ctlNum != j.ctlNum}
		.do{|subarray| subarray.setDurs }
		.collect{|subarray| subarray[0] !? {|i| i.ctlNum -> subarray }}
		.asDict;
		tracks.add(
			\poly -> midiEvents.select{|e| e.midicmd == \polytouch }
		);
		tracks.add(
			\bend -> midiEvents.select{|e| e.midicmd == \bend }
		);
		^tracks
	}
	filter{ |func|
		^MIDIItemPlayer(
			{|e| e.collect(func) }, 
			outEvents
		)
	}
	filterChoice{ |choiceFunc, actionFunc| 
		^this.filter(
			{|e| choiceFunc.(e).debug("choice").if { actionFunc.(e) } {e}},
			outEvents
		)
	
	}
	filterTrack{|track actionFunc|
		(
				case
					//use \noteOn for notes
					{ track.class == Symbol } {{|e|  e.midicmd == track}}
					{ track.class == Integer } {{|e| e.midicmd == \control and: ( e.ctlNum == track )}}
		)
		=> this.filterChoice( _, actionFunc )
	}
	
	// filter {| func |
	// 	^MIDIItemPlayer( func, this.outEvents);
	// }

	muteCC{ |num|
		^MIDIItemPlayer(
			{|events| events.reject{|e| e.type == \setCC and: ( e.ctlNum == num )} },
			this.outEvents,
		);
	}
	initialCCOnly{ |num|
		^MIDIItemPlayer(
			{|events| events.reject{|e| e.type == \setCC and: ( e.ctlNum == num ) and: (e.initial.isNil)} },
			midiEvents
		)
	}
}
SelfReturningObject {
	*new{
		^super.new
	}
	doesNotUnderstand{
		^this
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
