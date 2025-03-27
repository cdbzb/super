MIDIItem2 : MIDIItem{
	*new { |...args|
		^MIDIItem(*args)
	}
	*value{ |func|
		^MIDIItemPlayer(this.midiEvents, this)
	}
}
AbstractMidiEvents { 
	// class for MIDIItem and MIDIItemPlayer
	gui { |take| 
		var notes, start, end, width, height, window, view;
		take = take ? (this.takes.size - 1);
		notes = this.take(take).notes;
		start = notes[0].timestamp;
		end = notes.last.timestamp + notes.last.sustain;
		width = 1400;
		height = 800;
		// Create a window
		window = Window("Piano Roll", Rect(100, 100, width, height)).front;

		// Create a UserView for drawing
		view = UserView(window, Rect(0, 0, width, 1600))
		.background_(Color.white);


		// Define the drawing function
		view.keyDownAction_({ |view char|
			switch (char, 
				$q, {window.close; "open -a WezTerm.app".unixCmd},
				$0, {window.close; this.gui(0)},
				$1, {window.close; this.gui(1)},
				$2, {window.close; this.gui(2)},
				$j, {window.close; take = take - 1; this.gui(take: take)},
				$k, {window.close; take = take - 1; this.gui(take: take)}
			)
		});
		view.drawFunc = {
			var noteHeight = 1600 / 128; // Height of each note row (window height divided by 128 notes)
			var timeScale = width / (end - start); // Pixels per second

			// Draw the piano roll grid
			Pen.color = Color.gray(0.8);
			128.do { |i| // 128 MIDI notes (0–127)
				var y = i * noteHeight; // Calculate y position (no inversion for now)
				Pen.line(0@y, width@y);
			};
			Pen.stroke;
			// Draw the notes
			notes.do { |e num|
				var y =   height - (e.midinote - 30 * noteHeight).debug("y") ; // Calculate y position (no inversion for now)
				var x = e.timestamp - start *  timeScale ; // Start at time 0 (you can adjust this if your events have start times)
				var width = ( e.sustain ? 100 ) * timeScale ;

				// Draw the note rectangle
				Pen.color = Color.blue( e.amp ); // Use amplitude for color intensity
				Pen.addRect(Rect(x, y, width, noteHeight).debug("rect"));
				Pen.fill;
				Pen.color = Color.black;
				Pen.stringAtPoint(
					num.asString, // Convert MIDI note number to string
					Point(x, y - 15),  // Position text slightly above the rectangle
					Font.default,
					Color.black
				);

			};
		// === NEW CODE: Display `take` in the upper-left corner ===
		//if (this.takes.notNil) { // Only draw if `take` exists
			// Pen.color = Color(100, 100, 100, 0.5); // Black with 50% transparency
			Pen.stringAtPoint(
				take.asString, // Convert `take` to string
				Point(120, 120), // Position (x, y) from top-left corner
				Font("Helvetica", 48), // Large font size
				Color(0, 0, 0, 0.5) // Semi-transparent black
			);
		//};
		};

		// Refresh the view
		view.refresh;
	}
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
				Message(this.midiEvents.deepCopy, selector, args).(),
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
		^(
			end: this.midiEvents.last.timestamp + ( this.midiEvents.last.dur ? 0 ),  
			start: this.midiEvents[0].timestamp
		)
	}

	quantize { |beats func choiceFunc recalcSustains=true |
		var tempoMap = MIDIItemTempoMap(this, choiceFunc, beats);
		func.notNil.if{
			^this.quantizeFunc(beats, func, choiceFunc, recalcSustains) 
		}{
			^this.collect( {|e| e.timestamp_(tempoMap[e.timestamp])})
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
}

MIDIItem : AbstractMidiEvents { //class to record, save, and retrieve MIDIEvents for use with MicroKeys
	classvar <>folder, <all;
	var <>midiEvents , <name, <>initialCCValues;
	var restFirst, <initialRest, notes ;
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
//
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
	notes {
		notes.isNil.if{
			^this.player.notes
		};
		^notes
	}
	insert {
		Nvim.replace( "MIDIItem(\\\"%\\\")".format(name) )
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
		^(notes ++ midiEvents.reject{|e| [\mk].includes(e.type)}).sort{|i j| i.timestamp < j.timestamp}
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
		recording.stop; recording.save; recording = nil;
	}
	stop {
		if (midiEvents.select{|e| e.timestamp > 0}.size > 0) {
			takes.add(midiEvents);		
		}
	}

	at {|num|
		^takes[num]
	}
	*record {
		var mks = MicroKeys.all.values.select{|i| i.active }.collect(_.name);
		Nvim.replace( "MIDIItem(\\\"%\\\").record(%)".format(name ++ "_" ++  Date.getDate.stamp, mks.cs) )
	}
	record { |mk latencyCompensation|
		var start = SystemClock.seconds;
		var initialEvent =
		(
			midicmd: \control,
			timestamp: SystemClock.seconds - start,
			initialEvent: true,
		);
		latencyCompensation = latencyCompensation ? Server.default.latency;
		mk.do{|i| (i.isKindOf(Symbol).if{ MicroKeys(i) }{ i }).monitor};
		recording = this;
		midiEvents = List[];
		// add Events to set initial CC values to midiEvents
		CC.getValues(mk).asKeyValuePairs.pairsDo{ | i j |
			midiEvents.add(
				initialEvent ++ (
					type: \setCC,
					ctlNum: i,
					// control: CC(i).spec.unmap(j) * CC(i).rawScale , //put back in original
					control: j
				)
			)
		};
		midiEvents.add(
			initialEvent ++ (
				type: \setPoly,
				ctlNum: \polytouch,
				control: 0,
				midinote: \r
			)
	);
		restFirst.if{ initialRest = [( type: \rest, timestamp: SystemClock.seconds - start)] };
		
		//make MIDIdefs
		[\noteOn, \noteOff, \control, \polytouch, \bend ].do{ |cmd|

			MIDIdef(\record ++ cmd => _.asSymbol, func: { |val num| 
				\recordDef.postln;
				midiEvents.add(
					(
						midicmd: cmd,
						timestamp: SystemClock.seconds - start - latencyCompensation,
					)//.postln
					++
						switch( cmd, 
							\noteOn,{ (type: \mk, midinote: num, amp: val/127 )},
							\noteOff,{ (type: \mkOff, midinote: num, amp: val/127 ) },
							\polytouch, { (type: \setPoly, midinote: num, polyTouch: val, ) },
							\control, {
								( num == 64 ).if{
									(type:\setDamper, ctlNum:\damper, control: val)//.postln 
								} { 
									//TODO do away with this divisions ???
									(type: \setCC, ctlNum:num, control: val / 127)//.postln
								} 
							},
							\bend, { (type: \setBend, ctlNum:\bend, control: val / 16384)},
							// \bend, { (val: val, ctlNum:) }
							
						)
						// => _.postln
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
	play { |mk name clock post overdub=false |
		^this.player.play(mk, overdub: overdub)
	}
	player {|func take| 
		^if(recording != this) {
			MIDIItemPlayer( this.deepCopy.makeNotes, this) 
		}{
			SelfReturningObject()
		}
	}
	save {
		// notes.isNil.if{this.makeNotes};
		this.writeArchive( folder +/+ name)
	}
	delete {
		var result = folder +/+ name => File.delete(_); 
		this.free;
		^"file succeeded: %".format(result);
	}
	reset {
		midiEvents = List.new
	}
	take {|num|
		(num < 0).if { num = takes.size - 1 + num  };
		num.debug("num1");
		(num < 0 or: (num > (takes.size - 1))).if { ^"only % takes in %".format(takes.size, name).postln};
		num.debug("num2");
		^MIDIItemPlayer(takes[num], this).recalcSustains
	}
}

MIDIItemPlayer : AbstractMidiEvents { //class to filter and play MIDIItems
	classvar <playing;
	var <midiEvents, <source;
	var <>start, <>end;
	var tracks;
	*new {| midiEvents source |
		^super.newCopyArgs(midiEvents.deepCopy, source).init
	}
	*stopAll {
		playing.do({ |i| 
			i.restoreCCValues;
			playing.remove(i)
		})
	}
	init{
		this.start = this.bounds.start;
		this.end = this.bounds.end;
	}
	*initClass{
		playing = Set[];
		MyFree.add({MIDIItemPlayer.stopAll});
		Event.addEventType(\mi, {
			~dur = ~player[~to+1].timestamp - ~player[~from].timestamp;
			~clock = TempoClock(~tempo ? 1 / ~stretch ? 1);
			~player.fromNoteTo(~from, ~to).play(~mk, clock: ~clock) 
		}, parentEvent: (type: \durEvent));
		Event.addEventType(\mi2, {
			~filter.notNil.if{~player = ~filter.(~player)};
			// '!?'.help
			~dur = (~player.end.isNil.if {~player.bounds.end}) - (~player.start ? ~player.bounds.start);
			~clock = TempoClock(~tempo ? 1 / ~stretch ? 1);
			~player.play(~mk, clock: ~clock) 
		}, );
		Event.addParentType(\mi2,
			(
				finish: {|e| 
					(e.params.notNil).if { 
						// \setParams.postln;
						e.player = e.player.setParams(e.params) 
					}
					// implement lag and some setting to increase the duration
					// maybe .filter({|e| e.collect{|f| f.timestamp = f.timestamp + f.lag}})
				},
				parent: (type: \durEvent)
			)
		);
	}

	setBounds {|event|
		start = event.start; end = event.end
	}
	copyBounds {|mi|
		start = mi.bounds.start; end =mi.bounds.end
	}

	play { |mk clock post=#[] overdub=false take|


		(mk.rank > 0).if { mk.do{|i| this.play(i, clock, post, overdub) }; ^this };

		mk.isKindOf(Symbol).if {
			overdub.if { 
				mk = MicroKeys(mk) 
			} {
				mk = MicroKeys.newFrom(mk, UniqueID.next) 
			}
		};
		// (mk.size > 1).if { 'play first'.postln; mk.do(this.play() };
		playing.add(mk);

		(post.size > 0).if{
			"# note amp sus".postln 
		};
		mk.storeCCValues;
		midiEvents.do{|e x| 
			var from = start ? 0;
			var to = end ? midiEvents.last.timestamp;

			((e.timestamp == 0) or: (e.timestamp >= from) and: (e.timestamp <=  to )).if {
				var playFunc = mk.notNil.if{
					{
						e
						.mk_(mk.name)
						.latency_(Server.default.latency)
						.play; 
					} 
				}{
					{ 
						e
						.latency_(Server.default.latency)
						.play
					} 
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
	
	dur {
		^(end - start)
	}

	noteIndices {
		^midiEvents.select{|e| e.midicmd == \noteOn }
		.collect{|i x| x->midiEvents.indexOf(i) }
		.asDict
	}

	chaseCCs { |from|
		^midiEvents
		.select{|e| e.timestamp <= from }
		.select{|e| e.ctlNum.notNil }
		.sort{|i j| i.ctlNum <= j.ctlNum }
		.separate{|i j| i.ctlNum != j.ctlNum }
		.collect{|e| e.last}
			// .sort({|i j| i.timestamp <= j.timestamp}).last
	}
	notesStraddling {|time|
			^midiEvents.select{|e| e.midicmd == \noteOn }
			.select{|e| e.timestamp <= time and: (e.timestamp + e.sustain >= time )};
	}

	from {|from to trim=true| 
		//makes a new player starting from from
		//clips initial notes if trim==true 
		//changes timestamps to start at 0
		
		var firstNotes = this.notesStraddling(from).deepCopy; // Array

		if (trim and: (firstNotes.size > 0)) {

			firstNotes.do{|e|
				e.sustain = e.sustain - (from - e.timestamp);
				e.timestamp = from 
			}
		}

		^(
			firstNotes ++
			this.chaseCCs(from) ++
			midiEvents.select{|i| i.timestamp >= from and: (i.timestamp <= (to ? inf)) }.deepCopy
			.do{|e| e.timestamp = e.timestamp - from} //adjust times to start at 0
			// [(),(),()].do(_.dur = 3)
			=> MIDIItemPlayer(_, this.source)
		)
	}

	fromNote {|from to|
		to = to ? midiEvents.select{|e| e.midicmd == \noteOn}.size;

		^this.filter({|e| 

			var res = this.chaseCCs(this.noteIndices[from]) 
			++ e[this.noteIndices[from]..this.noteIndices[to - 1]].setDurs;

			{
				this.noteIndices[to + 1].notNil.if {
					res.drop(-1)
				}{
					res
				}
			}
	});
	}

	//deprecate this
	fromNoteTo{ |from to| ^this.fromNote(from, to) }

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
		//key-value pairs - values are patterns
		//for an array, use a pseq
		var event = array.asEvent, makeOutEvent;
		event.keys.do{|i| event[i] = event[i].asStream};
		makeOutEvent = {|x|
			event.keys.collect{|k| 
				().put(k, event[k].next)
			}.inject( (), _ ++ _ )
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
			func.(midiEvents.deepCopy),
			this.source
		)
	}
	//modify only elements for which choiceFunc answers true
	filterOnly { |choiceFunc, actionFunc| 
		^this.collect(
			{|e x| choiceFunc.(e, x).if { actionFunc.(e, x) } {e}},
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
	tempomap {|beats choiceFunc|
		beats.isString.if{ beats = beats.beats };
		^MIDIItemTempoMap(this, choiceFunc, beats)
	}
	recalcSustains {
		^MIDIItemPlayer(
			this.makeNotes,
			this.source
		)
	}
	synthVPbind { |choiceFunc|
		var initialRestDur = midiEvents.select{|e| 
			e.type == \rest and: (e.timestamp == 0)
		}.collect(_.dur);
		var notes = (choiceFunc ? I.d).value(
			midiEvents.select{|e| e.midicmd == \noteOn}
		);
		var midinotes = notes.collect{|e| e.midinote};
		var durs = notes.collect{|e| e.timestamp}.differentiate.drop(1)
		//last dur
		++ notes.last.sustain;

		// insert initial rest
		if (initialRestDur.size > 0) {
			midinotes = midinotes.insert(0, 60); //will be made rest by \r in lyric
			durs = durs.insert(0, initialRestDur[0])
		}{ 
			if (notes[0].timestamp > 0) {
			midinotes = midinotes.insert(0, 60); //will be made rest by \r in lyric
			durs = durs.insert(0, notes[0].timestamp)
			}
		}

		^[midinote: midinotes, dur: durs].p
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
		// env = Env([0] ++ beats.integrate, times.differentiate);
		env = Env([0] ++ ([0] ++ beats.integrate + midiItem.start), times.differentiate );
		// tempoMap = TempoMap(beats, times.differentiate.drop(1)) //what about the last dur!!!!!
	}
	offsets{
		^times.collect{|i| env[i] - i};
	}
	averageOffset{
		^this.offsets.mean
	}
	at{|x|
		^env[x]
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
