// The tempo-map editor (quantize-tempomap-project.md §12b D, built as §12c
// step 5 together with BeatMarkMode — the two halves of the old monolithic
// AbstractMidiEvents.gui: "where are the beats" and "what should the tempo be").
//
// MODEL — an IMMUTABLE AnchorMap (beat -> ABSOLUTE take seconds) plus an undo
// stack, which immutability makes free: undo is an array of maps and every edit
// is a fresh map, so nothing can be half-applied. Every edit is one of the §12b A
// span operations (transformSpan / stretchSpan / setSpanTempo / quantizeSpan),
// so "bar 5 sags" is an algebra expression rather than a new feature. The map
// itself is never mutated and the source grid is never touched: `commit` hands
// the result out (MapEditor.last, and the onSave hook) for the caller to apply
// with warpTo (destructive) or sourceTempoMap: (non-destructive) — the same
// choice §12c' gives retimeSpan.
//
// VIEW — the tempo lane: instantaneous bpm as a step line (the honest
// piecewise-constant reading of a PL map) with the whole-grid mean dashed
// through it, beat ticks on the baseline, and a bpm number only where a span is
// far enough off the mean to be worth reading. The lane is also the EDIT
// SURFACE: a click-drag across it selects a beat span.
//
// NO BARS. Deferred by §12b D (2026-07-31): nothing in the system groups beats
// into bars and Michael's meters shift, so a span is named by its two beat
// numbers, there is no per-bar shading, and nothing here assumes 4 of anything.
//
// Host hooks (all optional):
//   sourceFunc { }            -> [times, subdiv]: the beat grid to read a map off
//   onChange   { }            -> the model moved; refresh the view
//   audition   { |times| }    -> click through these candidate times
//   onSave     { |map| }      -> commit the edited map
//   drawOver   { |xOf, laneTop, laneBot| } -> host paint inside the lane strip
//
// Media-agnostic like BeatMarkMode: `times` are seconds and nothing else is
// assumed, so the same editor sits over the audio waveform in §9c step 3.
MapEditor {
	// the most recently committed map, so a gui session that has been closed
	// still leaves its work reachable from the REPL
	classvar <>last;

	var <>sourceFunc, <>onChange, <>audition, <>onSave, <>drawOver;
	var <map;                       // current AnchorMap (beat -> absolute sec), or nil
	var <baseMap;                   // the map as loaded, for revert
	var <rawTimes, <subdiv = 1;     // the source grid, and what one beat is worth in it
	var <undoStack, <redoStack;
	var <spanFrom, <spanTo;         // selected beat span; nil,nil == the whole map
	var <editing = false;           // map-edit mode ('m')
	var <edited = false;            // an edit has been made; blocks reload-on-invalidate
	var <>showLane = true;          // the 't' toggle
	var <>laneTop = 52, <>laneBot = 116;
	var <>devThresh = 0.05;         // label a span only if it is this far off the mean
	var <>minLabelW = 30;           // ...and at least this many pixels wide
	var loaded = false, cache, dragAnchor;

	*new { ^super.new.prInit }
	prInit {
		undoStack = []; redoStack = [];
		rawTimes = [];
		^this
	}

	// beat -> ABSOLUTE take seconds from a beat-grid times array: beat i/subdiv
	// was played at times[i]. nil when the times cannot BE a map (fewer than two,
	// or a non-increasing gap) — the lane then has nothing to draw and nothing is
	// editable, which is the honest answer for an empty or broken grid.
	*mapFromTimes { |times, subdiv = 1|
		var xs, ok = true;
		times = times.asArray;
		(times.size < 2).if { ^nil };
		times.doAdjacentPairs { |a, b| (b <= a).if { ok = false } };
		ok.not.if { ^nil };
		xs = times.size.collect { |i| i / subdiv };
		^AnchorMap.fromAnchors(xs, times, fromFrame: \beat, toFrame: \sec)
	}

	// ---- source ------------------------------------------------------------

	// (re)read the beat grid from the host. Lazy, so the expensive part (the
	// host's beatTimes, which builds a tempo map) is paid at most once per
	// change, in the draw that actually needs it.
	prEnsure {
		var res, times, sub;
		loaded.if { ^this };
		loaded = true;
		res = sourceFunc !? { sourceFunc.value };
		times = ((res !? { res[0] }) ? []).asArray;
		sub = (res !? { res[1] }) ? 1;
		((sub.isNumber.not) or: { sub <= 0 }).if { sub = 1 };
		rawTimes = times;
		subdiv = sub;
		map = MapEditor.mapFromTimes(times, sub);
		baseMap = map;
		undoStack = []; redoStack = [];
		edited = false;
		cache = nil;
		^this
	}

	// the beat source changed under us (a re-pick, a save, a cleared selection).
	// An EDITED map is never dropped silently — the user's work outranks a
	// cheaper redraw, and `reload` is the explicit way to throw it away.
	invalidate {
		edited.if { ^this };
		loaded = false;
		cache = nil;
		^this
	}
	reload {
		loaded = false; edited = false; cache = nil;
		^this.prEnsure
	}

	times { this.prEnsure; ^map.notNil.if { map.ys }{ rawTimes } }
	beats {
		this.prEnsure;
		^map.notNil.if { map.xs }{ rawTimes.size.collect { |i| i / subdiv } }
	}
	domain { this.prEnsure; ^map !? { map.domain } }

	// bpm per beat span, memoized. An empty `times` means "no source, no lane"
	// and is cached too: a nil cache would rebuild on every animation frame.
	laneData {
		var times, bpms, mean;
		cache !? { ^cache };
		this.prEnsure;
		times = this.times;
		bpms = MIDIItemPlayer.bpmFromTimes(times, subdiv);
		mean = bpms.reject(_.isNil);
		cache = (
			times: times,
			bpms: bpms,
			subdiv: subdiv,
			mean: (mean.size > 0).if { mean.sum / mean.size }
		);
		^cache
	}
	hasLane { ^this.laneData[\times].size >= 2 }
	meanBpm { ^this.laneData[\mean] }

	// ---- span selection ----------------------------------------------------

	// beat coordinate of a take time, clipped into the map's domain (so a cursor
	// parked in the throat-clearing intro selects beat 0, not a negative beat)
	beatAt { |time|
		var d;
		this.prEnsure;
		map.isNil.if { ^nil };
		d = map.domain;
		^map.invAt(time).clip(d[0], d[1])
	}
	timeAt { |beat| this.prEnsure; ^map !? { map.at(beat) } }

	// the edited region as [from, to] beat numbers — the whole domain when no
	// span has been picked, which makes every op below default to whole-map
	// (exactly what it did before §12b A made it local). nil when there is no map.
	spanRange {
		var d;
		this.prEnsure;
		map.isNil.if { ^nil };
		d = map.domain;
		^[spanFrom ? d[0], spanTo ? d[1]]
	}

	// mean bpm over the current span, read off the map (not off the notes)
	spanBpm {
		var r = this.spanRange, dt;
		r.isNil.if { ^nil };
		dt = map.at(r[1]) - map.at(r[0]);
		^(dt > 1e-9).if { 60 * (r[1] - r[0]) / dt }
	}

	selectSpan { |fromBeat, toBeat|
		spanFrom = fromBeat; spanTo = toBeat;
		onChange !? { onChange.value };
		^this
	}
	selectAll {
		spanFrom = nil; spanTo = nil;
		onChange !? { onChange.value };
		^this.prPost("span = the whole map")
	}
	setSpanStart { |time|
		var b = this.beatAt(time);
		b.isNil.if { ^this.prPost("no editable tempo map (no beat grid)") };
		spanFrom = b;
		(spanTo.notNil and: { spanTo <= spanFrom }).if { spanTo = nil };
		onChange !? { onChange.value };
		^this.prPost("span from beat %".format(b.round(0.001)))
	}
	setSpanEnd { |time|
		var b = this.beatAt(time);
		b.isNil.if { ^this.prPost("no editable tempo map (no beat grid)") };
		spanTo = b;
		(spanFrom.notNil and: { spanFrom >= spanTo }).if { spanFrom = nil };
		onChange !? { onChange.value };
		^this.prPost("span to beat %".format(b.round(0.001)))
	}

	// ---- edits (each pushes the previous map onto the undo stack) -----------

	// straighten the span toward one constant tempo; amount blends 0..1
	quantizeSpan { |amount = 1|
		^this.prSpanEdit("quantize %".format(amount),
			{ |m, a, b| m.transformSpan(a, b, { |cell| cell.quantize(amount) }) })
	}
	// smooth the tempo through the span's anchors (monotone cubic, resampled)
	curveSpan { |amount = 1|
		^this.prSpanEdit("curve %".format(amount),
			{ |m, a, b| m.transformSpan(a, b, { |cell| cell.curve(amount) }) })
	}
	// drop interior anchors, keeping every `groups`-th one — resolution reduction
	clumpSpan { |groups = 2|
		^this.prSpanEdit("clump %".format(groups),
			{ |m, a, b| m.transformSpan(a, b, { |cell| cell.clump(groups) }) })
	}
	// scale the span's performed width, shape preserved. factor > 1 = slower.
	// Everything after it shifts on the seconds axis, which IS the wanted ripple
	// (§12b A); preserveTotal pins the take's total length instead.
	stretchSpan { |factor, preserveTotal = false|
		^this.prSpanEdit("stretch x%".format(factor.round(0.001)),
			{ |m, a, b| m.stretchSpan(a, b, factor, preserveTotal) })
	}
	setSpanBpm { |bpm|
		^this.prSpanEdit("% bpm".format(bpm.round(0.1)),
			{ |m, a, b| m.setSpanTempo(a, b, bpm / 60) })
	}
	// escape hatch: any AnchorMap -> MonoMap function, applied to the span's cell
	applyToSpan { |func, name = "edit"|
		^this.prSpanEdit(name, { |m, a, b| m.transformSpan(a, b, func) })
	}

	prSpanEdit { |name, func|
		var r, res;
		this.prEnsure;
		map.isNil.if { ^this.prPost(name ++ ": no editable tempo map (no beat grid)") };
		r = this.spanRange;
		res = { func.value(map, r[0], r[1]) }.try { |err|
			this.prPost("% refused: %".format(name, err.errorString));
			nil
		};
		res.isNil.if { ^this };
		this.prPush(res);
		^this.prPost("% on beats %..% -> % bpm mean"
			.format(name, r[0].round(0.01), r[1].round(0.01),
				this.spanBpm !? (_.round(0.1))))
	}

	prPush { |newMap|
		undoStack = undoStack.add(map);
		redoStack = [];
		map = newMap;
		edited = true;
		cache = nil;
		onChange !? { onChange.value };
		^this
	}

	undo {
		undoStack.isEmpty.if { ^this.prPost("nothing to undo") };
		redoStack = redoStack.add(map);
		map = undoStack.last;
		undoStack = undoStack.drop(-1);
		cache = nil;
		onChange !? { onChange.value };
		^this.prPost("undo (% left)".format(undoStack.size))
	}
	redo {
		redoStack.isEmpty.if { ^this.prPost("nothing to redo") };
		undoStack = undoStack.add(map);
		map = redoStack.last;
		redoStack = redoStack.drop(-1);
		cache = nil;
		onChange !? { onChange.value };
		^this.prPost("redo (% left)".format(redoStack.size))
	}
	// back to the map as loaded, as ONE more undoable step (so revert itself can
	// be undone — the stack is the only history and nothing leaves it)
	revert {
		this.prEnsure;
		baseMap.isNil.if { ^this.prPost("nothing to revert to") };
		(map === baseMap).if { ^this.prPost("already the loaded map") };
		undoStack = undoStack.add(map);
		redoStack = [];
		map = baseMap;
		cache = nil;
		onChange !? { onChange.value };
		^this.prPost("reverted to the loaded map")
	}

	// ---- audition + commit -------------------------------------------------

	// click through the CANDIDATE map before committing (§12b D phase 2): the
	// whole beats of the span, at the times the edited map puts them, handed to
	// the host's click scheduler. Whole beats only — a subdivided (curved) lane
	// would otherwise audition as a picket fence.
	auditionSpan {
		var r = this.spanRange, lo, hi, times = [];
		r.isNil.if { ^this.prPost("audition: no tempo map") };
		audition.isNil.if { ^this.prPost("audition: the host has no audition hook") };
		lo = r[0].roundUp(1); hi = r[1];
		(lo <= hi).if { times = (lo, lo + 1 .. hi).collect { |b| map.at(b) } };
		(times.size < 1).if { ^this.prPost("audition: no whole beats in the span") };
		audition.value(times);
		^this.prPost("auditioning % beats (% bpm mean)"
			.format(times.size, this.spanBpm !? (_.round(0.1))))
	}

	// Hand the edited map out. It stays a plain AnchorMap in beat -> absolute
	// take seconds, which is what warpTo and EventList.sourceTempoMap: both
	// accept, so the destructive/non-destructive choice stays the caller's.
	// `edited` is deliberately NOT cleared: the source grid has not changed, so
	// re-reading it would silently replace the committed map on the next redraw.
	commit {
		this.prEnsure;
		map.isNil.if { ^this.prPost("commit: no tempo map") };
		MapEditor.last = map;
		baseMap = map;
		onSave !? { onSave.value(map) };
		^this.prPost("committed. MapEditor.last is this map (beat -> absolute seconds): "
			"player.warpTo(MapEditor.last), or list.sourceTempoMap = MapEditor.last")
	}

	// ---- modes + keys ------------------------------------------------------

	toggleEditing {
		this.prEnsure;
		editing = editing.not;
		(editing and: { map.isNil }).if {
			this.prPost("no editable tempo map — mark beats (e/E) or load a selection")
		};
		onChange !? { onChange.value };
		^this.prPost("edit " ++ editing.if("on", "off"))
	}

	toggleLane {
		showLane = showLane.not;
		onChange !? { onChange.value };
		("Tempo lane " ++ showLane.if("on", "off")
			++ ((showLane and: { this.hasLane.not }).if {
				" (no beat grid — select notes, or e/E)" }{ "" })).postln;
		^this
	}

	// `m` toggles map-edit mode from anywhere; every other key is consumed only
	// while the mode is ON, so the host's own bindings are untouched by default.
	// Answers true when the key was consumed.
	keyDown { |char, cursorTime|
		(char == $m).if { this.toggleEditing; ^true };
		editing.not.if { ^false };
		^case
		{ char == $i } { this.setSpanStart(cursorTime); true }
		{ char == $o } { this.setSpanEnd(cursorTime); true }
		{ char == $A } { this.selectAll; true }
		{ char == $Q } { this.quantizeSpan(1); true }
		{ char == $V } { this.curveSpan(1); true }
		{ char == $N } { this.clumpSpan(2); true }
		{ char == $S } { this.stretchSpan(1.05); true }
		{ char == $F } { this.stretchSpan(1 / 1.05); true }
		{ char == $B } { this.setSpanBpm(this.meanBpm ? 60); true }
		{ char == $P } { this.auditionSpan; true }
		{ char == $u } { this.undo; true }
		{ char == $U } { this.redo; true }
		{ char == $Z } { this.revert; true }
		{ char == $W } { this.commit; true }
		{ false }
	}

	// click-drag across the LANE STRIP selects a beat span. Answers true when the
	// lane consumed the event, so the host skips its own note hit-testing.
	mouseDown { |x, y, viewStart, viewEnd, width|
		editing.not.if { ^false };
		((y < laneTop) or: { y > laneBot }).if { ^false };
		this.prEnsure;
		map.isNil.if { ^false };
		dragAnchor = this.beatAt(this.prTimeOf(x, viewStart, viewEnd, width));
		spanFrom = dragAnchor; spanTo = dragAnchor;
		onChange !? { onChange.value };
		^true
	}
	mouseMove { |x, y, viewStart, viewEnd, width|
		var b;
		dragAnchor.isNil.if { ^false };
		b = this.beatAt(this.prTimeOf(x, viewStart, viewEnd, width));
		spanFrom = min(dragAnchor, b); spanTo = max(dragAnchor, b);
		onChange !? { onChange.value };
		^true
	}
	mouseUp {
		dragAnchor.isNil.if { ^false };
		dragAnchor = nil;
		// a click without a drag means "no span" — the whole map again
		((spanFrom.isNil or: { spanTo.isNil }) or: { (spanTo - spanFrom) < 1e-6 }).if {
			spanFrom = nil; spanTo = nil;
			this.prPost("span = the whole map")
		}{
			this.prPost("span beats %..% (% bpm mean)"
				.format(spanFrom.round(0.01), spanTo.round(0.01),
					this.spanBpm !? (_.round(0.1))))
		};
		onChange !? { onChange.value };
		^true
	}
	prTimeOf { |x, viewStart, viewEnd, width|
		^viewStart + (x * (viewEnd - viewStart) / width)
	}

	// ---- view --------------------------------------------------------------

	// §12D phase 1: the tempo lane — instantaneous bpm (1/slope of the beat->time
	// map, i.e. the bpm between adjacent beat anchors) as a step line: the honest
	// piecewise-constant reading of a PL map. Draw it BEFORE the notes so it can
	// never occlude them; the strip lives at laneTop..laneBot, clear of the help
	// line (y 10) and the beat-mark status line (y 30).
	drawLane { |viewStart, viewEnd, width|
		var d, times, bpms, mean, sub, timeScale, laneH;
		var lo = inf, hi = -inf, pad, yOf, xOf, prevY;
		showLane.not.if { ^this };
		d = this.laneData;
		times = d[\times];
		(times.size < 2).if { ^this };
		bpms = d[\bpms]; mean = d[\mean]; sub = d[\subdiv];
		timeScale = width / (viewEnd - viewStart);
		laneH = laneBot - laneTop;
		// auto-range over the VISIBLE spans, with the whole-grid mean always in
		// range, so a uniformly sagging window still reads against the average
		bpms.do { |b, i|
			((b.notNil and: { times[i + 1] >= viewStart }) and: { times[i] <= viewEnd }).if {
				lo = lo.min(b); hi = hi.max(b);
			}
		};
		mean !? { lo = lo.min(mean); hi = hi.max(mean) };
		(lo > hi).if { ^this };
		pad = ((hi - lo) * 0.1).max(1); // ~10% headroom, never a zero range
		lo = lo - pad; hi = hi + pad;
		yOf = { |b| laneBot - ((b - lo) / (hi - lo) * laneH) };
		xOf = { |t| ((t - viewStart) * timeScale).clip(0, width) };
		// backing, so the key shading doesn't muddy the line (the notes are drawn
		// after this and stay on top)
		Pen.color = Color(1, 1, 1, 0.7);
		Pen.addRect(Rect(0, laneTop, width, laneH));
		Pen.fill;
		Pen.color = Color.gray(0.6, 0.6);
		Pen.line(0@laneTop, width@laneTop);
		Pen.line(0@laneBot, width@laneBot);
		Pen.stroke;
		// dashed midline at the mean bpm of the WHOLE grid
		mean !? {
			var my = yOf.(mean);
			Pen.color = Color.gray(0.45, 0.8);
			(width / 14).floor.asInteger.do { |k|
				var x = k * 14;
				Pen.line(x@my, (x + 7)@my);
			};
			Pen.stroke;
		};
		// the step line itself: horizontal per span, vertical at the anchors
		Pen.color = Color.gray(0.3, 0.85);
		Pen.width = 1.5;
		bpms.do { |b, i|
			var x0, x1, y;
			((b.notNil and: { times[i + 1] >= viewStart }) and: { times[i] <= viewEnd }).if {
				x0 = xOf.(times[i]);
				x1 = xOf.(times[i + 1]);
				y = yOf.(b).clip(laneTop, laneBot);
				prevY !? { Pen.line(x0@prevY, x0@y) };
				Pen.line(x0@y, x1@y);
				prevY = y;
			}
		};
		Pen.stroke;
		Pen.width = 1;
		// beat ticks on the baseline — whole beats only, so a subdivided (curved)
		// lane doesn't become a picket fence
		Pen.color = Color.gray(0.5, 0.8);
		times.do { |t, i|
			(((i % sub) == 0) and: { (t >= viewStart) and: { t <= viewEnd } }).if {
				var x = xOf.(t);
				Pen.line(x@(laneBot - 5), x@laneBot);
			}
		};
		Pen.stroke;
		// lane range, at the left edge
		Pen.stringAtPoint(hi.round(1).asInteger.asString,
			Point(2, laneTop + 1), Font("Helvetica", 9), Color.gray(0.35));
		Pen.stringAtPoint(lo.round(1).asInteger.asString,
			Point(2, laneBot - 11), Font("Helvetica", 9), Color.gray(0.35));
		// bpm numbers only where they say something — per-segment labels at
		// quarter density are unreadable
		(mean.notNil and: { mean > 0 }).if {
			bpms.do { |b, i|
				var x0, x1, y;
				(b.notNil and: { (b - mean).abs > (mean * devThresh) }).if {
					x0 = xOf.(times[i]);
					x1 = xOf.(times[i + 1]);
					(((x1 - x0) >= minLabelW) and: {
						(times[i + 1] >= viewStart) and: { times[i] <= viewEnd }
					}).if {
						y = yOf.(b).clip(laneTop + 11, laneBot);
						Pen.stringAtPoint(b.round(1).asInteger.asString,
							Point(x0 + 2, y - 11), Font("Helvetica", 9),
							Color.gray(0.2));
					}
				}
			};
		};
		drawOver !? { drawOver.value(xOf, laneTop, laneBot) };
		^this
	}

	// on TOP of the notes: the selected beat span across the whole roll, its two
	// edges, and the edit status. Only while map-edit mode is on, so the gui is
	// pixel-for-pixel what it was when the mode is off.
	drawEditOverlay { |viewStart, viewEnd, width, height = 1600|
		var r, timeScale, x0, x1;
		editing.not.if { ^this };
		timeScale = width / (viewEnd - viewStart);
		r = this.spanRange;
		r !? {
			x0 = ((map.at(r[0]) - viewStart) * timeScale).clip(0, width);
			x1 = ((map.at(r[1]) - viewStart) * timeScale).clip(0, width);
			Pen.color = Color(1, 0.75, 0.1, 0.16);
			Pen.addRect(Rect(x0, 0, (x1 - x0).max(1), height));
			Pen.fill;
			Pen.width = 2;
			Pen.color = Color(0.9, 0.45, 0, 0.9);
			Pen.line(x0@0, x0@height);
			Pen.line(x1@0, x1@height);
			Pen.stroke;
			Pen.width = 1;
		};
		Pen.stringAtPoint(this.statusString, Point(10, laneBot + 4),
			Font("Helvetica", 11), Color(0.8, 0.3, 0));
		^this
	}

	statusString {
		var r = this.spanRange, b = this.spanBpm;
		var span = r.isNil.if { "no map" }{
			"beats %..%".format(r[0].round(0.01), r[1].round(0.01))
		};
		var bpm = b.isNil.if { "" }{ " · % bpm".format(b.round(0.1)) };
		var flag = edited.if { " · edited" }{ "" };
		^"MAP EDIT  " ++ span ++ bpm ++ flag
		++ "   i/o span · drag lane · A all · Q straighten · V curve · N clump · "
		++ "S/F slower/faster · B mean bpm · P audition · u/U undo · Z revert · W commit"
	}

	prPost { |msg| ("map: " ++ msg).postln; ^this }
}
