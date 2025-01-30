(
~gui = {| midiitem |
	var notes = midiitem.midiEvents.select{|i| i.midicmd == \noteOn};
	var start = notes[0].timestamp;
	var end= notes.last.timestamp + notes.last.sustain;
	var width = 1400;
	var height = 800;
	// Create a window
	w = Window("Piano Roll", Rect(100, 100, width, height)).front;

	// Create a UserView for drawing
	u = UserView(w, Rect(0, 0, width, 1600))
	.background_(Color.white);

	// Define the drawing function
	u.drawFunc = {
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
	notes.do { |event num|
		var note = event[\midinote];
		var sustain = event[\sustain ];
		var amp = event[\amp];
		var y =   height - (note - 30 * noteHeight).debug("y") ; // Calculate y position (no inversion for now)
		var x = event.timestamp - start *  timeScale ; // Start at time 0 (you can adjust this if your events have start times)
		var width = ( sustain ? 100 ) * timeScale ;

		// Draw the note rectangle
		Pen.color = Color.blue( 1 ); // Use amplitude for color intensity
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
};

// Refresh the view
u.refresh;
}
))
MIDIItem.mostRecent.player => ~gui.(_)
MIDIItem.mostRecent.player.midiEvents.select{|e| e.midicmd == \noteOn}[4]
=> ~gui.(_)
~gui.((midiEvents: ~data ))
~gui.(m.from(16))
~gui.()
~gui.( MIDIItem("_250119_105441").take(11)).play(MicroKeys(\default))
MIDIItem("_250119_105441").take(11).play(MicroKeys(\default).synth_(\default))
