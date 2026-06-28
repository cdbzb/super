// VisualMetronome — a big window that flashes on the beat.
//
// All GUI mutation happens inside {}.defer (runs on the AppClock / main
// thread); the un-flash is scheduled on AppClock so it never blocks.
//
// Quick start:
//   VisualMetronome.flash;                       // open (if needed) + flash once
//   Pbind(\type, \visMetro, \dur, 1).play;       // flash every beat via the pattern system
//   VisualMetronome.close;
VisualMetronome {
	classvar <window, <view;
	classvar <>baseColor, <>flashColor;
	classvar <>flashDur = 0.08;          // seconds the flash stays lit
	classvar <>latency = 0;              // delay the flash to align with audio (e.g. s.latency)
	classvar <>windowBounds;             // override before first flash to reposition/resize

	*initClass {
		baseColor  = Color.grey(0.1);
		flashColor = Color.white;

		// Pattern-system hook: (\type, \visMetro). Optional keys:
		//   \flashDur   — override the lit duration for this beat
		//   \flashColor — override the flash colour for this beat
		//   \latency    — delay the flash (seconds) to line up with audio; set to
		//                 ~latency / s.latency to match server-scheduled sound
		Event.addEventType(\visMetro, {
			VisualMetronome.flash(~flashDur, ~flashColor, ~latency);
		});

		// Tear down the window on MyFree and on Cmd-. (matches MicroKeys/MIDIItem).
		MyFree.add({ VisualMetronome.close });
		CmdPeriod.add({ VisualMetronome.close });
	}

	// Open the window if it isn't already up. MUST be called on the app thread
	// (it is — every caller wraps it in .defer). Returns the window.
	*ensureWindow {
		if(window.isNil or: { window.isClosed }) {
			window = Window("Visual Metronome", windowBounds ?? { Rect(200, 200, 700, 700) });
			view = UserView(window, window.view.bounds)
				.resize_(5)              // stretch with the window in both dimensions
				.background_(baseColor);
			window.front;
		};
		^window
	}

	// Open (if needed) and flash once. `lat` delays the flash on the AppClock so
	// it can line up with server-latency-delayed audio.
	*flash { |dur, color, lat|
		dur = dur ? flashDur;
		color = color ? flashColor;
		lat = lat ? latency;
		{
			this.ensureWindow;
			view.background = color;
			AppClock.sched(dur, {
				if(view.notNil and: { window.isClosed.not }) {
					view.background = baseColor;
				};
				nil                      // return nil → don't reschedule
			});
		}.defer(lat);
	}

	*close {
		{ if(window.notNil and: { window.isClosed.not }) { window.close } }.defer;
	}

	*isOpen { ^window.notNil and: { window.isClosed.not } }
}
