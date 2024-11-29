MIDIItem2 : MIDIItem{
	*new { |...args|
		^MIDIItem(*args)
	}
	*value{ |func|
		^MIDIItemPlayer(this.midiEvents, this)
	}
}
AbstractMidiEvents {
	noteOns {
		^MIDIItemPlayer(
			this.midiEvents.select{|e| e.midicmd == \noteOn},
			this.source
		)
	}
	
	dur {
		^this.midiEvents.collect(_.dur).select(_.notNil).sum
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
				Message(this.midiEvents, selector, args).(),
				this.source
			)
		}{
			MIDIItemPlayer.findRespondingMethodFor(selector).notNil.if{
				^Message(this.player, selector, args).()
			}
		};
		this.class + "does not understand" + selector
	}

	bounds {
		^(end: this.midiEvents.last.timestamp + ( this.midiEvents.last.dur ? 0 ),  start: this.midiEvents[0].timestamp)
	}
}
MIDIItem : AbstractMidiEvents { //class to record, save, and retrieve MIDIEvents for use with MicroKeys
	classvar <>folder, <all;
	var <>midiEvents , <name, <>initialCCValues;
	var restFirst, <initialRest, <notes ;
	var <takes;
	classvar midiout, <recording;

	*initClass {
		var parent;
		all = Dictionary.new(256);
		folder = this.filenameSymbol.asString.dirname.dirname +/+ "MIDI-items";
		File.exists(folder).not.if{ "mkdir %".format(folder).unixCmd };
		MyFree.add({ this.stopRecording });
		CmdPeriod.add(this);
		TempoClock.default=TempoClock(queueSize:8192).permanent_(true)
	}

	*cmdPeriod{
		this.stopRecording
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
	source{
		^this
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
		^(notes ++ midiEvents.reject{|e| [\mk, \mkOff].includes(e.type)}).sort{|i j| i.timestamp < j.timestamp}
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
		var initial =
		(
			midicmd: \control,
			timestamp: SystemClock.seconds - start,
			initial: true,
		);
		latencyCompensation = latencyCompensation ? 0 ; //Server.default.latency;
		mk.activate;
		recording = this;
		midiEvents = List[];
		CC.getValues.asKeyValuePairs.pairsDo{ | i j |
			midiEvents.add(
				initial ++ (
					type: \setcc,
					ctlnum: i,
					control: cc(i).spec.unmap(j) * cc(i).rawscale, //put back in original
				)
			)
		};
		midiEvents.add(
			initial ++ (
				type: \setPoly,
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
			MIDIItemPlayer( this.makeNotes.deepCopy, this) 
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
	var <midiEvents, <source;
	var <>start, <>end;
	var tracks;
	*new {| midiEvents source |
		^super.newCopyArgs(midiEvents, source).init
	}
	init{
		this.start = this.bounds.start;
		this.end = this.bounds.end;
	}
	*initClass{
		Event.addEventType(\mi, {
			~dur = ~player[~to+1].timestamp - ~player[~from].timestamp;
			~clock = TempoClock(~tempo ? 1 / ~stretch ? 1);
			~player.fromNoteTo(~from, ~to).play(~mk, clock: ~clock) 
		}, parentEvent: (type: \durEvent));
		Event.addEventType(\mi2, {
			~dur = (~player.end ? ~player.bounds.end) - (~player.start ? ~player.bounds.start);
			~clock = TempoClock(~tempo ? 1 / ~stretch ? 1);
			~player.play(~mk, clock: ~clock) 
		}, parentEvent: (type: \durEvent))
	}

	setBounds {|event|
		start = event.start; end = event.end
	}
	copyBounds {|mi|
		start = mi.bounds.start; end =mi.bounds.end
	}

	play { |mk clock post=#[]|

		(post.size > 0).if{
			"# note amp sus".postln 
		};

		midiEvents.do{|e x| 
			var from = start ? 0;
			var to = end ? midiEvents.last.timestamp;

			((e.timestamp == 0) or: (e.timestamp >= from) and: (e.timestamp <=  to )).if {
				var playFunc = mk.notNil.if{
					{
						e
						.mk_(mk)
						.latency_(Server.default.latency)
						.play; 
					} 
				}{
					{ e.play } 
				}; 

				(clock ? TempoClock.default).sched(e.timestamp - ( start ? 0 ), playFunc);

				post.includes(e.midicmd).if{
					var dict = e.asDict;
					var logString = "% % % % % ".format(
						mk !? _.name,
						x,
						dict.at(\midinote),
						dict.at(\amp) !? _.round(0.001),
						dict.at(\sustain) !? _.round(0.001)
					);
					AppClock.sched(e.timestamp - midiEvents[from].timestamp, { logString.postln }) 
				}
			}
		}
	}
	noteIndices {
			^midiEvents.select{|e| e.midicmd == \noteOn}
			.collect{|i x| x->midiEvents.indexOf(i) }
			.asDict
	}

	fromNoteTo {|from to|
		^this.filter({|e| 
			e[this.noteIndices[from]..this.noteIndices[to + 1]].setDurs
			.drop(-1)
	});
	}

	//collects either: the params of notes selected by Symbol
	//or the notes themselves if given a number
	//so this[\amp] [0.2, 0.3] etc and this[4] the 4th note
	at { |index|
		index.isKindOf(Symbol).if{
			^midiEvents.select{|e| e.midicmd == \noteOn}
			.collect{|i x| i[index] }
		}{
			^midiEvents.select{|e| e.midicmd == \noteOn}
			.at(index)
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

	setParams { |array|
		var event = array.asEvent, makeOutEvent;
		event.keys.do{|i| event[i] = event[i].asStream};
		makeOutEvent = {|x|
			event.keys.collect{|k| ().put(k, event[k].next)}
			.inject( (), _ ++ _ )
		};
		^this.filter({|e|
			e.deepCopy.collect{|i x| i.params = i.params ++
				makeOutEvent.(x)
			}
		})
	}

	filter {|func|
		^MIDIItemPlayer(
			// (indices: this.noteIndices).use{ func.(midiEvents).valueEnvir })
			func.(midiEvents),
			this.source
		)
	}
	//modify only elements for which choiceFunc answers true
	filterOnly { |choiceFunc, actionFunc| 
		^this.collect(
			{|e x| choiceFunc.(e, x).debug("choice").if { actionFunc.(e, x) } {e}},
			midiEvents
		)
	}

	notes { |aMidiEvents|
		^(aMidiEvents ? midiEvents).select({|e| e.midicmd == \noteOn})
	}

	filterNotes { |func|
		var out = midiEvents.deepCopy;
		midiEvents.select({|e| e.midicmd == \noteOn})
		.collect({|e| [midiEvents.indexOf(e),  e]})
		.do({|e x| out.put(e[0], func.(e[1], x))});
		^MIDIItemPlayer(out, this.source)
	}
	pasteKey{|key precision=2|
		Nvim.replace(this[key].round(10 ** (precision * -1)))
	}
	filterNotesKey {|key func|
		var out = midiEvents.deepCopy;
		var array = this[key];
		func.(array).do{|i x| this.notes(out)[x].put(key, i)};
		^MIDIItemPlayer(out, this.source)
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
			midiEvents.reject{|e| e.type == \setCC and: ( e.ctlNum == num )} ,
			this.source
		);
	}
	initialCCOnly{ |num|
		^MIDIItemPlayer(
			midiEvents.reject{|e| e.type == \setCC and: ( e.ctlNum == num ) and: (e.initial.isNil)} ,
			this.source
		)
	}
	quantize{ |beats func choiceFunc recalcSustains=true |
		var tempoMap = MIDIItemTempoMap(this, choiceFunc, beats);
		func.notNil.if{
			^this.quantizeFunc(beats, func, choiceFunc, recalcSustains) 
		}{
			^this.collect( {|e| e.timestamp_(tempoMap.env[e.timestamp])}, midiEvents)
		}
	}
	quantizeFunc { |beats func choiceFunc recalcSustains=true |
		var tempoMap = MIDIItemTempoMap(this, choiceFunc, beats);
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
			this.makeNotes,
			this.source
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

MIDIItemTempoMap : AbstractMidiEvents { //this is almost the same as TempoMap but with timestamps instead of beats 
	var <times, <beats, <midiEvents;
	var <env, <tempoMap ;

	*new {|midiItem, choiceFunc, beats|
		^super.new.init( midiItem, choiceFunc, beats)
	}
	init{|midiItem, choiceFunc, b| 
		midiEvents = midiItem.midiEvents;
		times = (choiceFunc ? I.d)
		.value( midiEvents.select({|e| e.midicmd == \noteOn}))
		.collect{|e| e.timestamp}
		++ midiItem.bounds.end
		;
		beats = b;
		tempoMap = TempoMap(beats, times.differentiate.drop(1)) //what about the last dur!!!!!
	}
	offsets{
		^times.collect{|i| env[i] - i};
	}
	averageOffset{
		^this.offsets.mean
	}
	doesNotUnderstand{|selector ...args|
		tempoMap.respondsTo(selector).if{
			^Message(tempoMap, selector, args).()
		}{
		this.class + "does not understand" + selector	
		}
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
