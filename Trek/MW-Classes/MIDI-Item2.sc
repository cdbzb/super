MIDIItem2 : MIDIItem{
	*new { |...args|
		^MIDIItem(*args)
	}
	*value{ |func|
		^MIDIItemPlayer(this.midiEvents, this).copyBounds(this)
	}
}
AbstractMidiEvents { // class for MIDIItem and MIDIItemPlayer
gui { |take| 
    var notes, start, end, width, height, window, view;
    var selectedIndices; // Array to store selected note indices
    var startMidiNote = 36; // Starting MIDI note for display range
    var viewStart, viewEnd, zoomFactor = 1; // Horizontal view and zoom variables
    
    // Initialize selected indices array
    selectedIndices = [];
    
    this.respondsTo(\takes).if{
        take = take ? (this.takes.size - 1);
        notes = this.take(take).notes;
    }{
        notes = this.notes;
        take = 0
    };
    
    start = notes[0].timestamp;
    end = notes.last.timestamp + (notes.last.sustain ? 0);
    width = 1400;
    height = 800;
    
    // Initialize horizontal view
    viewStart = start;
    viewEnd = end;
    
    // Create a window and UserView
    window = Window("Piano Roll", Rect(100, 100, width, height)).front;
    view = UserView(window, Rect(0, 0, width, 1600))
    .background_(Color.white);
    
    // Define the keyboard actions
	// Replace the key action section in your gui method with this fixed version:

// Replace the key action section in your gui method with this fixed version:

view.keyDownAction_({ |view char|
    switch (char, 
        $q, {window.close; "open -a WezTerm.app".unixCmd},
        $0, {window.close; this.gui(0)},
        $1, {window.close; this.gui(1)},
        $2, {window.close; this.gui(2)},
        $j, {window.close; take = take - 1; this.gui(take: take)},
        $k, {window.close; take = take + 1; this.gui(take: take)},
        $J, {startMidiNote = (startMidiNote - 12).max(0); view.refresh; ("Scrolled down to MIDI note " ++ startMidiNote).postln}, 
        $K, {startMidiNote = (startMidiNote + 12).min(115); view.refresh; ("Scrolled up to MIDI note " ++ startMidiNote).postln}, 
        $h, { // Scroll left - FIXED
            var duration, scrollAmount, newViewStart, newViewEnd;
            duration = viewEnd - viewStart;
            scrollAmount = duration * 0.1;
            newViewStart = viewStart - scrollAmount;
            newViewEnd = viewEnd - scrollAmount;
            
            // Ensure we don't scroll past the beginning
            if(newViewStart < start) {
                newViewStart = start;
                newViewEnd = start + duration;
            };
            
            viewStart = newViewStart;
            viewEnd = newViewEnd;
            view.refresh;
            ("Scrolled left to " ++ viewStart.round(0.01)).postln;
        },
        $l, { // Scroll right - FIXED
            var duration, scrollAmount, newViewStart, newViewEnd;
            duration = viewEnd - viewStart;
            scrollAmount = duration * 0.1;
            newViewStart = viewStart + scrollAmount;
            newViewEnd = viewEnd + scrollAmount;
            
            // Ensure we don't scroll past the end
            if(newViewEnd > end) {
                newViewEnd = end;
                newViewStart = end - duration;
            };
            
            viewStart = newViewStart;
            viewEnd = newViewEnd;
            view.refresh;
            ("Scrolled right to " ++ viewStart.round(0.01)).postln;
        },
        $H, { // Zoom out horizontally - FIXED (anchored to left)
            var newDuration, newViewStart, newViewEnd;
            newDuration = (viewEnd - viewStart) * 1.2;
            newViewStart = viewStart; // Keep left boundary fixed
            newViewEnd = viewStart + newDuration;
            
            // Constrain to the bounds of the actual data
            if(newViewStart < start) {
                newViewStart = start;
                newViewEnd = start + newDuration;
            };
            if(newViewEnd > end) {
                newViewEnd = end;
                // Only adjust start if we hit the right boundary
                newViewStart = (end - newDuration).max(start);
            };
            
            viewStart = newViewStart;
            viewEnd = newViewEnd;
            view.refresh;
            ("Zoomed out, duration: " ++ (viewEnd - viewStart).round(0.01)).postln;
        },
        $L, { // Zoom in horizontally - FIXED (anchored to left)
            var newDuration, minDuration, newViewStart, newViewEnd;
            newDuration = (viewEnd - viewStart) * 0.8;
            minDuration = 0.1; // Minimum zoom level
            
            // Ensure minimum duration
            if(newDuration < minDuration) {
                newDuration = minDuration;
            };
            
            newViewStart = viewStart; // Keep left boundary fixed
            newViewEnd = viewStart + newDuration;
            
            // Ensure we stay within bounds
            if(newViewStart < start) {
                newViewStart = start;
                newViewEnd = start + newDuration;
            };
            if(newViewEnd > end) {
                newViewEnd = end;
                // Only adjust start if we hit the right boundary
                newViewStart = (end - newDuration).max(start);
            };
            
            viewStart = newViewStart;
            viewEnd = newViewEnd;
            view.refresh;
            ("Zoomed in, duration: " ++ newDuration.round(0.01)).postln;
        },
        $r, {selectedIndices = []; view.refresh; "Selection cleared".postln}, 
        $g, {("Selected note indices: " ++ selectedIndices).postln; selectedIndices}, 
        $?, {
            // Show help menu
            var helpWindow = Window("Piano Roll Help", Rect(200, 200, 400, 300)).front;
            var helpText = StaticText(helpWindow, Rect(10, 10, 380, 280))
                .string_("Piano Roll Keyboard Shortcuts:\n\n" ++
                    "q - Close window and open WezTerm\n" ++
                    "0, 1, 2 - Switch to take 0, 1, or 2\n" ++
                    "j - Previous take\n" ++
                    "k - Next take\n" ++
                    "J - Scroll down one octave\n" ++
                    "K - Scroll up one octave\n" ++
                    "h/l - Scroll horizontally left/right\n" ++
                    "H/L - Zoom out/in horizontally\n" ++
                    "r - Clear note selection\n" ++
                    "g - Get selected note indices\n" ++
                    "? - Show this help menu\n\n" ++
                    "Mouse:\n" ++
                    "Click notes to select/deselect them\n" ++
                    "Selected notes appear in red\n\n" ++
                    "Visual Guide:\n" ++
                    "Gray shading = Black keys\n" ++
                    "C note labels on left side\n" ++
                    "MIDI note range: 36-127 (scrollable)")
                .font_(Font("Helvetica", 12))
                .align_(\left);
            helpWindow.onClose_({helpWindow = nil});
        }
    )
});

    // Add mouse click handling
    view.mouseDownAction_({ |view, x, y, mod|
        var noteRange = 92; // Display 92 notes at a time
        var noteHeight = 1600 / noteRange;
        var timeScale = width / (viewEnd - viewStart);
        var clickedNoteIndex = nil;
        
        // Check if click is on a note
        notes.do { |e, idx|
            var noteY = height - ((e.midinote - startMidiNote) * noteHeight);
            var noteX = (e.timestamp - viewStart) * timeScale;
            var noteWidth = (e.sustain ? 100) * timeScale;
            var noteRect = Rect(noteX, noteY, noteWidth, noteHeight);
            
            // Check if click is within note rectangle
            if(noteRect.contains(Point(x, y))) {
                clickedNoteIndex = idx;
            };
        };
        
        // If we found a note, toggle its selection
        if(clickedNoteIndex.notNil) {
            if(selectedIndices.includes(clickedNoteIndex)) {
                selectedIndices.remove(clickedNoteIndex);
                ("Note " ++ clickedNoteIndex ++ " deselected").postln;
            } {
                selectedIndices = selectedIndices.add(clickedNoteIndex);
                ("Note " ++ clickedNoteIndex ++ " selected").postln;
            };
            view.refresh;
        };
    });
    
    // Define the drawing function
    view.drawFunc = {
        var noteRange = 92; // MIDI notes 36-127 (92 notes total)
        var noteHeight = 1600 / noteRange; // Height of each note row
        var timeScale = width / (viewEnd - viewStart); // Pixels per second
        var isBlackKey = { |midiNote|
            var noteInOctave = midiNote % 12;
            [1, 3, 6, 8, 10].includes(noteInOctave); // C#, D#, F#, G#, A#
        };
        var midiNoteToName = { |midiNote|
            var noteNames = ["c", "c#", "d", "d#", "e", "f", "f#", "g", "g#", "a", "a#", "b"];
            var octave = (midiNote / 12).floor;
            var noteIndex = midiNote % 12;
            noteNames[noteIndex] ++ octave.asString;
        };
        
        // Draw black key shading first
        noteRange.do { |i| // Display noteRange notes starting from startMidiNote
            var midiNote = i + startMidiNote;
            var y = height - (i * noteHeight); // Invert Y coordinate
            if(isBlackKey.(midiNote)) {
                Pen.color = Color.gray(0.9);
                Pen.addRect(Rect(0, y, width, noteHeight));
                Pen.fill;
            };
        };
        
        // Draw the piano roll grid
        Pen.color = Color.gray(0.8);
        noteRange.do { |i| // Display noteRange notes starting from startMidiNote
            var y = height - (i * noteHeight); // Invert Y coordinate
            Pen.line(0@y, width@y);
        };
        Pen.stroke;
        
        // Draw the notes
        notes.do { |e, num|
            var noteRange = 92; // Display 92 notes at a time
            var noteHeight = 1600 / noteRange;
            var y = height - ((e.midinote - startMidiNote) * noteHeight);
            var x = (e.timestamp - viewStart) * timeScale;
            var noteWidth = (e.sustain ? 100) * timeScale;
            
            // Only draw notes that are within the visible range (both vertical and horizontal)
            if(e.midinote >= startMidiNote and: (e.midinote < (startMidiNote + noteRange)) and:
               (e.timestamp >= viewStart) and: (e.timestamp <= viewEnd)) {
                // Change color if selected
                if(selectedIndices.includes(num)) {
                    Pen.color = Color.red(e.amp); // Selected notes are red
                } {
                    Pen.color = Color.blue(e.amp); // Normal notes are blue
                };
                
                Pen.addRect(Rect(x, y, noteWidth, noteHeight));
                Pen.fill;
                
                Pen.color = Color.black;
                Pen.stringAtPoint(
                    num.asString,
                    Point(x, y - 15),
                    Font.default,
                    Color.black
                );
            };
        };
        
        // Display take number
        Pen.stringAtPoint(
            take.asString,
            Point(120, 120),
            Font("Helvetica", 48),
            Color(0, 0, 0, 0.5)
        );
        
        // Draw note name labels on the left
        Pen.color = Color.black;
        noteRange.do { |i|
            var midiNote = i + startMidiNote;
            var y = height - (i * noteHeight); // Invert Y coordinate
            var noteName = midiNoteToName.(midiNote);
            // Only draw labels for C notes and every 12 notes to avoid clutter
            if(midiNote % 12 == 0) {
                Pen.stringAtPoint(
                    noteName,
                    Point(5, y + (noteHeight / 2) - 6),
                    Font("Helvetica", 10),
                    Color.black
                );
            };
        };
        
        // Display selection instructions
        Pen.stringAtPoint(
            "Click notes to select, press 'r' to reset, 'g' to get indices",
            Point(10, 10),
            Font("Helvetica", 14),
            Color.black
        );
    };
    
    // Refresh the view
    view.refresh;
    
    // Return a function that gives access to the selected indices
    ^{ selectedIndices };
}
	noteOns {
		^MIDIItemPlayer(
			this.midiEvents.select{|e| e.midicmd == \noteOn},
			this.source
		).copyBounds(this)
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
        // for collect - reject - select - drop 
		this.midiEvents.respondsTo(selector).if{
			^MIDIItemPlayer(
				Message(this.midiEvents.deepCopy, selector, args).(),
				this.source
			).copyBounds(this)
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
			^this.warpTo(tempoMap)
		}
	}
    quantizeFunc { |beats func choiceFunc recalcSustains=true |
        var tempoMap = MIDIItemTempoMap(this, choiceFunc, beats);
        this.collect({|e x| 
            (
                env: tempoMap.env, 
                quantized: tempoMap.env[e.timestamp - this.start],
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
	var <takes, <recordedMks, <>recordedMk;
	classvar midiout, <recording;

	*initClass {
		var parent;
		all = Dictionary.new(256);
		folder = this.filenameSymbol.asString.dirname.dirname +/+ "MIDI-items";
		File.exists(folder).not.if{ "mkdir %".format(folder).unixCmd };
		MyFree.add({ this.stopRecording });
		CmdPeriod.add(this);
		// TempoClock.default=TempoClock(queueSize:8192).permanent_(true)
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
			^super.new.initMIDIitem(name, restFirst)
		}
	}
	*newFrom { |midiEvents |
		^ MIDIItem( UniqueID ).midiEvents_(midiEvents)
	}
	*record {|name="item"|
		var stamp = name ++ "_" ++ Date.getDate.stamp;
		Nvim.replace( "MIDIItem2(\"%\").record".format(stamp) )
	}
	initMIDIitem {|n r|
		takes = List[];
		recordedMks = List[];
		restFirst = r;
		name = n;
		midiEvents = List.new;
		initialCCValues = ();
		this.register;
		^this
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
	register {
		all.add(name -> this)
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
	makeNotesFromMidiEvents { |array|
		var events = array.deepCopy;
		var on = events.select{|e| e.midicmd == \noteOn};
		var off = events.select{|e| e.midicmd == \noteOff};
		var offMidinotes = off.collect{|e| e.midinote};
		var findMatch = {|midinote| offMidinotes.indexOf(midinote)}; //returns index
		var notes;
		on.do{|e| try{
			var index = findMatch.(e.midinote);
			var match = off.removeAt(index);
			offMidinotes.removeAt(index);
			e.sustain = match.timestamp - e.timestamp
		}
		};
		notes = initialRest.copy ? [] ++ on;
		notes.setDurs;
		^(notes ++ array.reject{|e| e.type == \mk}).sort{|i j| i.timestamp < j.timestamp}
	}
	makeNotes {
		// should copy be deepCopy??
		var events = midiEvents.deepCopy;
		var on = events.select{|e| e.midicmd == \noteOn};
		var off = events.select{|e| e.midicmd == \noteOff};
		var findMatch = {|midinote| off.collect{|e| e.midinote}.indexOf(midinote)}; //returns index
		var notes;
		on.do{|e| try{var match = off.removeAt( findMatch.(e.midinote) ); e.sustain = match.timestamp - e.timestamp;} };
		notes = initialRest.copy ? [] ++ on;
		notes.setDurs;
		^(notes ++ midiEvents.reject{|e| [\mk].includes(e.type)}).sort{|i j| i.timestamp < j.timestamp}
	}
	ccsAsArraysOfPoints{
		^midiEvents.select{|e| e.midicmd == \control}.deepCopy
		.sort{ |i j| i.ctlNum < j.ctlNum }
		.separate{ |i j| i.ctlNum == j.ctlNum }
		.collect{|sub| sub[0].ctlNum -> sub.collect{|i| Point(i.timestamp, i.control)}}
		=> _.asDict
	}
	*stopRecording {
		[\noteOn, \noteOff, \control, \polytouch, \bend ].do{
			|cmd|
			MIDIdef((\record ++ cmd).asSymbol).free
		};
		recording.notNil.if {recording.stop; recording.save; recording = nil;}
	}
	stop {
		if (midiEvents.select{|e| e.timestamp > 0}.size > 0) {
			takes.add(midiEvents);
			recordedMks = recordedMks ? List[];
			recordedMks.add(recordedMk);
		}
	}
	at {|num|
		^takes[num]
	}
    record {
        |mk latencyCompensation|
        var start = SystemClock.seconds;
        var initialEvent =
        (
            midicmd: \control,
            timestamp: SystemClock.seconds - start,
            initialEvent: true,
        );
        mk.isKindOf(Event).if {
            var base = MicroKeys.current.asEvent;
            recordedMk = base.putAll(mk);
            mk = recordedMk.play[\mk]
        };
        mk = mk ? MicroKeys.current;
        recordedMk = recordedMk ? mk.isKindOf(MicroKeys).if{ mk.asEvent }{ mk };
        latencyCompensation = latencyCompensation ? Server.default.latency;
        mk.do{|i| (i.isKindOf(Symbol).if{ MicroKeys(i) }{ i }).monitor};
        recording = this;
        midiEvents = List[];
        // add Events to set initial CC values to midiEvents
        MicroKeys.ccs.asKeyValuePairs.pairsDo{ | i j |
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
        restFirst.if { initialRest = [( type: \rest, timestamp: SystemClock.seconds - start)] };

        //make MIDIdefs - FIXED: Different parameter patterns for different message types

        // Messages with val, num, chan parameters
        [\noteOn, \noteOff, \control, \polytouch ].do { |cmd|
            MIDIdef((\record ++ cmd).asSymbol, func: { |val num chan src|
                MicroKeys.excludeSrcIDs.includes(src).not.if {
                midiEvents.add(
                    (
                        midicmd: cmd,
                        timestamp: SystemClock.seconds - start - latencyCompensation,
                        channel: chan,
                    )//.postln
                    ++ switch (cmd) 
                        {\noteOn} { (type: \mk, midinote: num, amp: val/127 )}
                        {\noteOff} { (type: \mkOff, midinote: num, amp: val/127 ) }
                        {\polytouch} { (type: \setPoly, midinote: num, polyTouch: val, ) }
                        {\control} {
                            ( num == 64 ).if{
                                (type:\setDamper, ctlNum:\damper, control: val)//.postln 
                            } { 
                                ( num == 74 ).if{
                                    (type: \setCC74, ctlNum: 74, control: val / 127)
                                } {
                                    //TODO do away with this divisions ???
                                    (type: \setCC, ctlNum:num, control: val / 127)//.postln
                                }
                            } 
                        }
                    )
				}},msgType: cmd,
				msgNum: (cmd == \control).if{ (0..127) },
			)
		};

        // Messages with only val, chan parameters - NO num parameter!
        [\bend, \touch ].do { |cmd|
            MIDIdef((\record ++ cmd).asSymbol, func: { |val chan src|
                MicroKeys.excludeSrcIDs.includes(src).not.if {
                midiEvents.add(
                    (
                        midicmd: cmd,
                        timestamp: SystemClock.seconds - start - latencyCompensation,
                        channel: chan,
                    )
                    ++ switch(cmd)
                        {\bend} { (type: \setBend, ctlNum:\bend, control: val / 16384) }
                        {\touch} { (type: \setPressure, ctlNum:\pressure, control: val / 127) }
                )
            }},msgType: cmd )
        };
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
		mk = case
			{ mk.isKindOf(Event) && recordedMk.isKindOf(Event) } {
				var e = (proto: recordedMk) ++ mk;
				e.play[\mk]
			}
			{ mk.isKindOf(Event) } { mk.play[\mk] }
			{ mk.notNil } { mk.isKindOf(Symbol).if{ MicroKeys(mk) }{ mk } }
			{ recordedMk.isKindOf(Event) } { recordedMk.play[\mk] }
			{ recordedMk.notNil } { MicroKeys(recordedMk) };
		^this.player.play(mk, overdub: overdub)

	}
	player {|func take| 
		^if(recording != this) {
			// MIDIItemPlayer( this.deepCopy.makeNotes, this) 
			MIDIItemPlayer( this.makeNotesFromMidiEvents(midiEvents), this) 
		}{
			SelfReturningObject()
		}
	}
	save {
		// notes.isNil.if{this.makeNotes};
		this.writeArchive( folder +/+ name)
	}
	filterCC { |ctlNum=0 suffix="noZeros"|
		var newName = name ++ "_" ++ suffix;
		var mi = this.class.new(newName, false);
		mi.midiEvents = midiEvents.reject{|e| (e.midicmd == \control) and: {e.ctlNum == ctlNum}};
		mi.save;
		"filterCC: removed CC % from % → %".format(ctlNum, name, newName).postln;
		^mi
	}
	delete {
		var result = File.delete(folder +/+ name); 
		this.free;
		^"file succeeded: %".format(result);
	}
	reset {
		midiEvents = List.new
	}
	take {|num|
		var obj;
		(num < 0).if { num = takes.size + num  };
		(num < 0 or: (num > (takes.size - 1))).if { ^"only % takes in %".format(takes.size, name).postln};
		obj = MIDIItemPlayer(this.makeNotesFromMidiEvents(takes[num]), this);//.recalcSustains
		obj.recordedMk = recordedMks !? _[num];
		^obj
	}
}

MIDIItemPlayer : AbstractMidiEvents { //class to filter and play MIDIItems
	classvar <playing;
	var <midiEvents, <source, <>recordedMk;
	var <>start, <>end;
	var tracks;

	*new {| amidiEvents source |
		var player, bounds;
		var midiEvents = (amidiEvents.size != 0).if{ amidiEvents.deepCopy }{ [(type: \rest, timestamp:0, dur: 1, sustain: 1)]};
		player = super.newCopyArgs(midiEvents, source);
		midiEvents.notNil.if { //this should not be necessary!!!!
			bounds = (
				end: midiEvents.last.timestamp + ( midiEvents.last.dur ? 0 ),  
				start: midiEvents[0].timestamp max: 0
			);
			player.start = bounds.start;
			player.end = bounds.end;
		}{"MidiEvents nil!!".warn};
		^player
	}
	*stopAll {
		playing.do({ |i| 
			i.restoreCCValues;
			playing.remove(i)
		})
	}
	*initClass{
		playing = Set[];
		MyFree.add({MIDIItemPlayer.stopAll});
		Event.addEventType(\mi, {
			~dur = ~player[~to+1].timestamp - ~player[~from].timestamp;
			~clock = TempoClock(~tempo ? 1 / ~stretch ? 1);
			~player.fromNote(~from, ~to).play(~mk, clock: ~clock) 
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
	initialRest {
		^midiEvents.select{|e| e.timestamp == 0 and:  (e.type == \rest)}[0].dur
	}
	removeNote{ |index|
		var notes = midiEvents.select{|i| i.midicmd == \noteOn};
		^this.filter { |e| //remove bad note (should be method?) 
			index.asArray.do{ |x|
				var note =  notes[x];
				var off = e.select{|i| i.midicmd == \noteOff and: (i.timestamp >= note.timestamp) and: (i.midinote == note.midinote)}
				// .sort({|x y| x.timestamp < y.timestamp})
				.at(0);
				e.remove(note); e.remove(off)
			};
			e
		}
	}
	setBounds {|event|
		start = event.start; end = event.end
	}
	copyBounds {|mi|
		start = mi.start; end =mi.end
	}
	play { |mk clock post=#[] overdub=false take|
		(mk.rank > 0).if { mk.do{|i| this.play(i, clock, post, overdub) }; ^this };

		mk.isNil.if {
			var rmk = recordedMk ? source.recordedMk;
			mk = case
				{ rmk.isKindOf(Event) } { rmk.play[\mk] }
				{ rmk.notNil } { MicroKeys(rmk) }
		};
		mk.isKindOf(Event).if {
			var rmk = recordedMk ? source.recordedMk;
			mk = rmk.isKindOf(Event).if {
				var e = (proto: rmk) ++ mk;
				e.play[\mk]
			}{
				mk.play[\mk]
			}
		};
		mk.isKindOf(Symbol).if {
			overdub.if { 
				mk = MicroKeys(mk) 
			} {
				mk = MicroKeys.newFrom(mk, UniqueID.next) 
			}
		};
		// (mk.size > 1).if { 'play first'.postln; mk.do(this.play() };
		mk.notNil.if { playing.add(mk) };

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
						.mk_(mk.name ? mk)
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
	tempoMapFromIndices {
		|indices=#[0, 3, 5, 7] beats=#[1, 1, 1, 1]|
		^MIDIItemTempoMap(this, this.notes[indices], beats)
	}
	warpTo { |tempoMap|
			^this.collect( {|e| e.timestamp_(tempoMap[e.timestamp - start] + start)}) //is start right? or should get from the map?
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

	trim {|bool|
		bool.if{
			start = this[\timestamp][0];
		}
	}

	trimTimeStampsToStart {
		^this.collect {|i| i.timestamp = i.timestamp - start; i }
		.reject {|i| i.timestamp < 0}
		.start_(0)
	}

	fromNote {|from to trim=true|
		var indices = this.noteIndices;
		to = to ? midiEvents.select{|e| e.midicmd == \noteOn}.size;

		^this.filter({|e| 

			var res = this.chaseCCs(e[indices[from]].timestamp) 
			++ e[indices[from]..indices[to - 1]].setDurs;

			indices[to + 1].notNil.if {
				res.drop(-1)
			}{
				res
			}
		}).trim(trim)
	}

	//deprecate this
	fromNoteTo{ |from to| ^this.fromNote(from, to) }

	//collects either: the params of notes selected by Symbol
	//or the notes themselves if given a number
	//so this[\amp] returns [0.2, 0.3] etc and this[4] the 4th note
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
		on.do{|e| 
			try{
				var match = off.removeAt(findMatch.(e.midinote)); 
				e.sustain = match.timestamp - e.timestamp 
			}
		};
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

	filterEventsAndNotes{|func|
		^MIDIItemPlayer(
			// (indices: this.noteIndices).use{ func.(midiEvents).valueEnvir })
			func.(midiEvents, this.notes),
			this.source
		).copyBounds(this)
	}
	pickNotes { |list|
		^MIDIItemPlayer( this.notes[list], source: this).copyBounds(this)
	}
	filter {|func, key, choice, onlyNotes=false, midicmd|
		var choiceFunc, out, array, notes, evts;
		// midicmd builds a choice function
		midicmd.notNil.if {
			choice.notNil.if { "filter: midicmd overrides choice".warn };
			choiceFunc = case
				{ midicmd.class == Symbol } {{ |e| e.midicmd == midicmd }}
				{ midicmd.class == Integer } {{ |e| e.midicmd == \control and: (e.ctlNum == midicmd) }};
		} {
			choiceFunc = choice;
		};
		// key: extract one param from notes, apply func, write back
		key.notNil.if {
			(choiceFunc.notNil or: midicmd.notNil).if { "filter: key ignores choice/midicmd".warn };
			out = midiEvents.deepCopy;
			array = this[key];
			func.(array).do{|i x| this.notes(out)[x].put(key, i)};
			^MIDIItemPlayer(out, this.source).copyBounds(this)
		};
		// onlyNotes: func acts on notes array, spliced back in
		onlyNotes.if {
			choiceFunc.notNil.if { "filter: onlyNotes ignores choice/midicmd".warn };
			notes = func.(this.notes.copy);
			evts = this.midiEvents.copy;
			notes.do {|note index|
				evts.put(this.noteIndices[index], note)
			};
			^MIDIItemPlayer(evts, this.source).copyBounds(this)
		};
		// choice/midicmd: apply func only where choiceFunc is true
		choiceFunc.notNil.if {
			^this.collect(
				{|e x| choiceFunc.(e, x).if { func.(e, x) } {e}},
				midiEvents
			)
		};
		// base case: func receives full midiEvents array
		^MIDIItemPlayer(func.(midiEvents), this.source).copyBounds(this)
	}
	//deprecated — use filter(func, choice:choiceFunc)
	filterOnly { |choiceFunc, actionFunc|
		^this.filter(actionFunc, choice: choiceFunc)
	}
	//deprecated — use filter(func, onlyNotes:true)
    filterNotes { |func|
		^this.filter(func, onlyNotes: true)
    }

	notes { |aMidiEvents|
		^(aMidiEvents ? midiEvents).select({|e| e.midicmd == \noteOn})
	}

	pasteKey{|key precision=2|
		Nvim.replace(this[key].round(10 ** (precision * -1)))
	}
	//deprecated — use filter(func, key:key)
	filterNotesKey {|key func|
		^this.filter(func, key: key)
	}
	//deprecated — use filter(func, midicmd:track)
	filterOnlyMidicmd {|track actionFunc|
		^this.filter(actionFunc, midicmd: track)
	}
	muteCC{ |num|
		^MIDIItemPlayer(
			midiEvents.reject{|e| e.type == \setCC and: ( e.ctlNum == num )} ,
			this.source
		).copyBounds(this);
	}
	initialCCOnly{ |num|
		^MIDIItemPlayer(
			midiEvents.reject{|e| e.type == \setCC and: ( e.ctlNum == num ) and: (e.initial.isNil)} ,
			this.source
		).copyBounds(this)
	}
	tempomap {|beats choiceFunc|
		beats.isString.if{ beats = beats.beats };
		^MIDIItemTempoMap(this, choiceFunc, beats)
	}
	recalcSustains {
		^MIDIItemPlayer(
			this.makeNotes,
			this.source
		).copyBounds(this)
	}
	synthVPbind { |choiceFunc trimToStart=true|
		^trimToStart.if{
			this.trimTimeStampsToStart 
		}{ 
			this 
		}.doSynthVPbind(choiceFunc)
	}
	doSynthVPbind { |choiceFunc|
		var initialRestDur = midiEvents.select{|e| 
			e.type == \rest and: (e.timestamp == 0)
		}.collect(_.dur);
		var notes = (choiceFunc ? I.d).value(
			midiEvents.select{|e| e.midicmd == \noteOn}
		);
		var midinotes = notes.collect{|e| e.midinote};
		var durs = notes.collect{|e| e.timestamp}.differentiate.drop(1)
		//last dur
		++ (notes.last !? _.sustain ? 0);

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

    // choose the notes to make a Song line from (durations will be calculated)
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
		++ (notes.last.sustain ? 0);

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
		.collect{|e| e.timestamp } 
		++ midiItem.bounds.end
		=> {|i| i - i[0]} //relative to first item
		;
		beats = b;
		// env = Env([0] ++ beats.integrate, times.differentiate);
		env = Env([0] ++ ([0] ++ beats.integrate ), times.differentiate );
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
