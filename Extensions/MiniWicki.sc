// Wicki layout for computer keyboard
// TODO: keycodes file/to chars if – works, clean makeEvenGui, add hide/show form code

MiniWicki {
	classvar <keyCodes, pitchClass;
	var midiRef, keyMap, synthMap, boxMap;
	var window;
	var <>volume;
	var <noteSeq, <durSeq, isRecording, clock, previousBeat;

	*new {
		^super.new.initMiniWicki;
	}
	
	initMiniWicki {
		this.setDefaultKeyCodes;
		this.setKeyboardLayout;
		volume = 0.2;
		isRecording = false;
		
		this.makeEventGui;
	}
	
	setDefaultKeyCodes {
		// MacBook (Spanish) keyboard keycodes, TODO: read from a file.
		keyCodes = [ 18, 19, 20, 21, 23, 22, 26, 28, 25, 29,
					 12, 13, 14, 15, 17, 16, 32, 34, 31, 35,
					 0, 1, 2, 3, 5, 4, 38, 40, 37, 41,
					 6, 7, 8, 9, 11, 45, 46, 43, 47, 44];
		
		pitchClass = ["C", "C#", "D", "D#", "E", "F", "F#", "G", "G#", "A", "A#", "B"];
	}
	
	setKeyCodes {
		var win, text, cancel, reset, done, arr;
		
		win = Window.new("set keycodes", Rect(300, 300, 500, 70), false);
		
		text = TextView.new(win, Rect(5, 5, 490, 20));
		text.setFont(Font("Helvetica-Bold", 20));
		
		cancel = Button.new(win, Rect(5,30, 160, 20));
		cancel.states = [["Cancel", Color.black, Color.gray]];
		
		reset = Button.new(win, Rect(170,30, 160, 20));
		reset.states = [["Reset", Color.black, Color.gray]];
		
		done = Button.new(win, Rect(335, 30, 160, 20));
		done.states = [["Done", Color.black, Color.gray]];

		
		arr = [];
		
		text.keyDownAction = {|view, char, modifiers, unicode, keycode|
			arr = arr.add(keycode);
		};
		
		cancel.action = {win.close};
		
		done.action = {
			win.close;
			if(arr.size == 40) {
				keyCodes = arr;
				this.setKeyboardLayout;
				"keycodes changed".postln;
			} {
				"error: keys != 40, keycodes not changed".postln;
			};
		};
		
		reset.action = {text.string = ""; arr = []};
		
		win.front;
	}
	
	setKeyboardLayout {|baseNote|
		var increment = 15;
		
		midiRef = baseNote ? 48;
		keyMap = IdentityDictionary.new;
		synthMap = IdentityDictionary.new;
		boxMap = IdentityDictionary.new;
		
		keyCodes.do{|key, i|
			if((i%10) == 0) {increment = increment - 5};
			keyMap.put(key, midiRef + increment + (i%10*2));
			synthMap.put(key, nil);
			boxMap.put(key, 0);
		};
	}
	
	transpose {|amount|
		this.setKeyboardLayout(midiRef + amount);
		window.refresh;
	}
	
	resetTransposition {
		this.setKeyboardLayout;
		window.refresh;
	}
	
	startRecording {
		clock = TempoClock.new;
		previousBeat = clock.beats;
		noteSeq = [];
		durSeq = [];
		"Recording".postln;
		isRecording = true	
	}
	
	stopRecording {
		durSeq.removeAt(0); // quita el primer valor y sincroniza con las notas
		durSeq = durSeq.add(clock.beats - previousBeat); // agrega la œltima duraci—n (no hay forma de adivinar cuando temina la melod’a)
		clock.stop;
		"Recording stoped".postln;
		isRecording = false
	}
	
	record {|midiNote|
		noteSeq = noteSeq.add(midiNote);
		durSeq = durSeq.add(clock.beats - previousBeat);
		previousBeat = clock.beats;
	}
	
	replay {
		Pbind(\freq, Pseq(noteSeq).midicps, \dur, Pseq(durSeq), \amp, volume).play;
	}
		
	makeEventGui {
		window = Window.new("MiniWicki", Rect(200, 200, 550, 220), false);
		window.view.background = Color.white;
		
		Pen.font = Font("Helvetica-Bold", 12);
		
		window.view.keyDownAction = {|view, char, modifiers, unicode, keycode|
			var midiNote;
			if(keyMap.includesKey(keycode)) {
				if(synthMap.at(keycode).isNil) {
					midiNote = keyMap.at(keycode);
					synthMap.put(keycode, Synth(\default, [freq: midiNote.midicps, amp: volume]));
					boxMap.put(keycode, 1);
					if(isRecording) {
						this.record(midiNote);
					};
					window.refresh;
				};
			};
			if(char == $ ) {
				if(isRecording) {
					this.stopRecording;
				} {
					this.startRecording;
				};
			};
		};
		
		window.view.keyUpAction = {|view, char, modifiers, unicode, keycode|
			if(keyMap.includesKey(keycode)) {
				if(synthMap.at(keycode).notNil) {
					synthMap.at(keycode).release;
					synthMap.put(keycode, nil);
					boxMap.put(keycode, 0);
					window.refresh;
				};
			};
		};
		
		window.drawHook = {
			var xbase = 20, ybase = 20;
			var x, y;
			var yOffset;
			var octave, pc;
			
			keyCodes.do{|key, i|
				if(boxMap.at(key) == 1) {Pen.color = Color.red} {Pen.color = Color.gray};
				yOffset = i div: 10;
				x = xbase + (i%10*45) + (yOffset*20);
				y = ybase + (yOffset*45);
				Pen.fillRect(Rect(x, y, 40, 40));
				octave = keyMap.at(key) div: 12 - 1;
				pc = keyMap.at(key) % 12;
				Pen.color = Color.black;
				Pen.stringAtPoint(pitchClass[pc]++octave, (x + 10)@(y + 5));
			};
		};
		
		window.onClose = {synthMap.do(_.free)};
		window.front;
	}
}
