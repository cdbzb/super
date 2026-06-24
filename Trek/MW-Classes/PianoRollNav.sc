// Shared piano-roll navigation for the Retune / MIDIItem editors: a horizontal time window
// [viewStart, viewEnd] over data bounds [start, end], plus a vertical pitch window
// [loNote, hiNote], with scroll/zoom matching the MIDIItem piano-roll keybindings:
//   h / l : scroll left / right        H / L : zoom out / in (left-anchored)
//   J / K : scroll pitch down / up by an octave
// Pixel transforms (xOf/tOf/yOf) honour a `pad` margin on all sides. Reusable so both guis
// navigate identically; keyDown(char) consumes the nav keys and returns true if it handled one.
PianoRollNav {
	var <>start, <>end;            // data time bounds (s)
	var <>viewStart, <>viewEnd;    // visible time window (s)
	var <>loNote, <>hiNote;        // visible pitch window (MIDI)
	var <>width, <>height, <>pad;  // pixels
	var <>minDur = 0.1, <>scrollFrac = 0.1, <>zoomOutF = 1.2, <>zoomInF = 0.8, <>octave = 12;

	*new { |start, end, loNote = 48, hiNote = 72, width = 1200, height = 460, pad = 46|
		^super.new.prInit(start, end, loNote, hiNote, width, height, pad)
	}
	prInit { |st, en, lo, hi, w, h, p|
		start = st; end = en.max(st + minDur);
		viewStart = start; viewEnd = end;
		loNote = lo; hiNote = hi;
		width = w; height = h; pad = p;
		^this
	}
	dur { ^(viewEnd - viewStart).max(minDur) }

	// ---- horizontal scroll (clamped to data bounds) ----
	scrollLeft  { ^this.prScroll(this.dur * scrollFrac.neg) }
	scrollRight { ^this.prScroll(this.dur * scrollFrac) }
	prScroll { |amt|
		var d = this.dur, vs = (viewStart + amt).clip(start, (end - d).max(start));
		viewStart = vs; viewEnd = vs + d; ^this
	}
	// ---- horizontal zoom (left-anchored, like MIDIItem: out x1.2, in x0.8) ----
	zoomOut { ^this.prZoom(zoomOutF) }
	zoomIn  { ^this.prZoom(zoomInF) }
	prZoom { |f|
		var nd = (this.dur * f).clip(minDur, end - start);
		var vs = viewStart.clip(start, (end - nd).max(start));
		viewStart = vs; viewEnd = (vs + nd).min(end);
		^this
	}
	resetView { viewStart = start; viewEnd = end; ^this }

	// ---- vertical pitch scroll (octave) ----
	pitchUp   { loNote = loNote + octave; hiNote = hiNote + octave; ^this }
	pitchDown { loNote = loNote - octave; hiNote = hiNote - octave; ^this }

	// ---- pixel transforms (pad margin on all sides) ----
	xOf { |t| ^pad + ((t - viewStart) / this.dur * (width - (2 * pad))) }
	tOf { |x| ^(((x - pad) / (width - (2 * pad)) * this.dur) + viewStart).clip(viewStart, viewEnd) }
	yOf { |m| ^(height - pad) - ((m - loNote) / ((hiNote - loNote).max(1)) * (height - (2 * pad))) }
	visible  { |t| ^(t >= viewStart) and: { t <= viewEnd } }
	overlaps { |t0, t1| ^(t1 >= viewStart) and: { t0 <= viewEnd } }

	// standard nav keybindings; returns true if it consumed the key, false otherwise so the
	// host gui can handle its own keys
	keyDown { |char|
		^case
		{ char == $h } { this.scrollLeft;  true }
		{ char == $l } { this.scrollRight; true }
		{ char == $H } { this.zoomOut; true }
		{ char == $L } { this.zoomIn;  true }
		{ char == $J } { this.pitchDown; true }
		{ char == $K } { this.pitchUp;   true }
		{ false }
	}
}
