(
~data = [
	(note: 60, dur: 1, amp: 0.5, timestamp: 0), // MIDI note 60 (C4), duration 1, amplitude 0.5
	(note: 62, dur: 0.5, amp: 0.7, timestamp: 1),
	(note: 64, dur: 0.75, amp: 0.6, timestamp: 1.5),
	(note: 65, dur: 0.25, amp: 0.8, timestamp: 2.25)
];
)

(
// Create a window
w = Window("Piano Roll", Rect(100, 100, 800, 1600)).front;

// Create a UserView for drawing
u = UserView(w, Rect(0, 0, 800, 1600))
    .background_(Color.white);

// Define the drawing function
u.drawFunc = {
    var noteHeight = 1600 / 128; // Height of each note row (window height divided by 128 notes)
    var timeScale = 100; // Pixels per second

    // Draw the piano roll grid
    Pen.color = Color.gray(0.8);
    128.do { |i| // 128 MIDI notes (0–127)
        var y = i * noteHeight; // Calculate y position (no inversion for now)
        Pen.line(0@y, 800@y);
    };
    Pen.stroke;

    // Draw the notes
    ~data.do { |event|
        var note = event[\note];
        var dur = event[\dur];
        var amp = event[\amp];
        var y = note * noteHeight; // Calculate y position (no inversion for now)
        var x = event.timestamp *  timeScale; // Start at time 0 (you can adjust this if your events have start times)
        var width = dur * timeScale;

        // Draw the note rectangle
        Pen.color = Color.blue(amp); // Use amplitude for color intensity
        Pen.addRect(Rect(x, y, width, noteHeight));
        Pen.fill;
    };
};

// Refresh the view
u.refresh;
))
