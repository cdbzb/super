MIDIItem2 : MIDIItem {
	*new { |...args|
		^MIDIItem(*args)
	}
	*value{ |func|
		^MIDIItemPlayer(this.midiEvents)
	}
}
AbstractMidiEvents {
	noteOns {
		^MIDIItemPlayer(
			this.midiEvents
			.select{|e| e.midicmd == \noteOn}
		)
	}
	splitVoices { |maxJump=5 numVoices=2|
		^this.noteOns.midiEvents
		.separate{|i j| (j.midinote - i.midinote).abs > maxJump}
		=> _.clump(numVoices)
		=> _.flop
		=> _.collect(_.flat)
		// => _.sort{|e f| e.collect(_.midinote).mean > f.collect(_.midinote).mean}
	}
	doesNotUnderstand{|selector ...args|
		this.midiEvents.respondsTo(selector).if{
			^MIDIItemPlayer(
				Message(this.midiEvents, selector, args).()
			)
		}
	}
}
MIDIItem : AbstractMidiEvents { //class to record, save, and retrieve MIDIEvents for use with MicroKeys
	classvar <>folder, <all;
	var <>midiEvents , <name, <>initialCCValues;
	var restFirst, <initialRest, <notes ;
	var takes;
	classvar midiout, <recording;

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
		^ MIDIItem( UniqueID ).midiEvents_(midiEvents)
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
		Nvim.replace( "MIDIItem(\\\"%\\\")".format(name ++ "_" ++  Date.getDate.stamp) )
	}
	*mostRecent {
		^
		folder +/+
		( folder => PathName(_) => _.files => _.collect( { |i| i.fileNameWithoutExtension} ) => _.sort => _.last)
		=> Object.readArchive( _ )
	}
	ccPbind { |num |
		^this.ccTracks[num].eventsToPatternPairs.p
	}
	ccPbinds {
		^this.ccTracks.keys.collect{ |x|
			try{this.ccPbind(x)}
		}.select{|i| i.notNil}.asArray 
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
	}
	at {|num|
		^takes[num]
	}
	record { |mk latencyCompensation|
		var start = SystemClock.seconds;
		latencyCompensation = latencyCompensation ? Server.default.latency;
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
						timestamp: SystemClock.seconds - start - latencyCompensation,
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
			^SelfReturningObject()
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
			MIDIItemPlayer( this.makeNotes.deepCopy) 
		}{
			SelfReturningObject()
		}
	}
	save {
		// notes.isNil.if{this.makeNotes};
		this.writeArchive( folder +/+ name)
	}
	reset {
		midiEvents = List.new
	}
}

MIDIItemPlayer : AbstractMidiEvents { //class to filter and play MIDIItems
	var <midiEvents, tracks;
	*new {| midiEvents |
		^super.newCopyArgs( midiEvents)
	}
	play { |mk log=#[] from=0|

	// (log.size > 0).if{
		"# note amp sus".postln 
	// }
		;

		midiEvents.do{|e x| 
			((e.timestamp == 0) or: (x >= from)).if {
				var playFunc = mk.notNil.if{
					{
						e.mk_(mk).play; 
						log.includes( e.midicmd ).if {
							try{ "%: % % %".format(x, e.midinote, e.amp.round(0.001), e.sustain.round(0.001)).postln  }
						}
					} 
				}{
					{ e.play } 
				}; 
				TempoClock.sched(e.timestamp - midiEvents[from].timestamp, playFunc)
			}
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
	makeNotes {
		// should copy be deepCopy??
		var notes;
		var on = midiEvents.select{|e| e.midicmd == \noteOn}.deepCopy;
		var off = midiEvents.select{|e| e.midicmd == \noteOff}.deepCopy;
		var findMatch = {|midinote| off.collect{|e| e.midinote}.indexOf(midinote)}; //returns index
		on.do{|e| var match = off.removeAt(findMatch.(e.midinote)); e.sustain = match.timestamp - e.timestamp; };
		^on ++ midiEvents.reject{|e| e.type == \mk} => _.sort{|i j| i.timestamp < j.timestamp}
	}
	//modify only elements for which choiceFunc answers true
	filterOnly { |choiceFunc, actionFunc| 
		^this.collect(
			{|e x| choiceFunc.(e, x).debug("choice").if { actionFunc.(e, x) } {e}},
			midiEvents
		)
	}
	filterNotes { |func|
		var out = midiEvents.deepCopy;
		midiEvents.select({|e| e.midicmd == \noteOn})
		.collect({|e| [midiEvents.indexOf(e),  e]})
		.do({|e x| out.put(e[0], func.(e[1], x))});
		^MIDIItemPlayer(out)
	}
	//modify only tracks with CC (by number) or other specified midicmd (\bend, \noteOn, \poly)
	filterOnlyMidicmd {|track actionFunc|
		(
				case
					//use \noteOn for notes
					{ track.class == Symbol } {{|e|  e.midicmd == track}}
					{ track.class == Integer } {{|e| e.midicmd == \control and: ( e.ctlNum == track )}}
		)
		=> this.filterOnly( _, actionFunc )
	}
	muteCC{ |num|
		^MIDIItemPlayer(
			{|events| events.reject{|e| e.type == \setCC and: ( e.ctlNum == num )} },
			this.midiEvents,
		);
	}
	initialCCOnly{ |num|
		^MIDIItemPlayer(
			{|events| events.reject{|e| e.type == \setCC and: ( e.ctlNum == num ) and: (e.initial.isNil)} },
			midiEvents
		)
	}
	quantize{ |beats func choiceFunc recalcSustains=true |
		var tempoMap = MIDIItemTempoMap(midiEvents, choiceFunc, beats);
		// ^MIDIItemPlayer( wrappedFunc, midiEvents )
		func.notNil.if{
			^this.quantizeFunc(beats, func, choiceFunc, recalcSustains) 
		}{
			^this.collect( {|e| e.timestamp_(tempoMap.env[e.timestamp])}, midiEvents)
		}
	}
	quantizeFunc { |beats func choiceFunc recalcSustains=true |
		var tempoMap = MIDIItemTempoMap(midiEvents, choiceFunc, beats);
		this.collect({|e x| 
			(
				env: tempoMap.env, 
				e: e, 
				x: x,
				averageOffset: tempoMap.averageOffset,
			).use(func)
		}) => {|i|
				recalcSustains.if { ^i.recalcSustains }{ ^i }
		}
	}
	recalcSustains {
		^MIDIItemPlayer(
			I.d,
			this.makeNotes
		)
	}
	addLine { |name choiceFunc|
		var initialRestDur = midiEvents.select{|e| 
			e.type == \rest and: (e.timestamp == 0)
		}.collect(_.dur);
		var notes = 
		(choiceFunc ? I.d).value(

			midiEvents.select{|e| e.midicmd == \noteOn}
		);
		var midinotes = notes.collect{|e| e.midinote};
		var durs = notes.collect{|e| e.timestamp}.differentiate.drop(1)
		//last dur
		++ notes.last.sustain;

		// add initial rest
		( initialRestDur.size > 0 ).if{
			midinotes = midinotes.insert(0, \r);
			durs = durs.insert(0, initialRestDur[0])
		} ;
		^[ name, midinotes, durs].addLine;
	}
	notesPbind { |mk| 
		var res = List.new;
		var keys = [\midinote, \sustain, \amp, \dur];
		keys.do{|key|
			res.add(key);
			res.add(  
				midiEvents.select{|e| e.midicmd == \noteOn}.collect{|i|
					i[key] ? \r //avoid nil for rest
				}.q
			)
		};
		res = res ++ [
			type: \mk,
			mk: mk
		] => _.p;
		^res
	}
}
MIDIItemTempoMap{ //this is almost the same as TempoMap but with timestamps instead of beats 
	var <times, <beats;
	var <env, <averageOffset;

	*new {|midiEvents, choiceFunc, beats|
		^super.new.init( midiEvents, choiceFunc, beats)
	}
	init{| midiEvents, choiceFunc, b| 
		times = 
		(choiceFunc ? I.d)
		.value( midiEvents.select({|e| e.midicmd == \noteOn}))
		.collect{|e| e.timestamp};
		beats = b;
		env = Env([0] ++ beats.integrate, times.differentiate);
		averageOffset = times.collect{|i| env[i] - i}.mean;
		// set Addline here? or just what that method needs?
		
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
