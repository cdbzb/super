(
var item, mk, tm, spans, ok, near, one, pl;
near = { |a, b, tol = 1e-6| (a - b).abs < tol };
ok = { |label, cond| ("%  %".format(cond.if("PASS","FAIL"), label)).postln };
"=== SENTINEL START ===".postln;

// marks at a steady 1.2 s, and a LONG final sustain so bounds.end sits well
// past the last mark (the case the old fallback got wrong in the other direction)
mk = { |onsets, tail|
	var it = MIDIItem(("t" ++ UniqueID.next).asSymbol);
	onsets.do { |t, i|
		it.midiEvents = it.midiEvents.add(
			(type: \mk, midicmd: \noteOn, timestamp: t, midinote: 60 + i, veloc: 80));
		it.midiEvents = it.midiEvents.add(
			(type: \mkOff, midicmd: \noteOff, timestamp: t + ((i == (onsets.size - 1)).if(tail, 0.2)),
				midinote: 60 + i));
	};
	it
};

// --- steady tempo: every span must be equal, closing one included -----------
item = mk.([0, 1.2, 2.4, 3.6], 2.5);          // tail pushes bounds.end to 6.1
tm = MIDIItemTempoMap(item, nil, 1!4);
spans = tm.times.differentiate.drop(1);
ok.("4 marks -> 4 spans", spans.size == 4);
ok.("closing span repeats the last measured span", near.(spans.last, 1.2));
ok.("all spans equal on a steady take", spans.every { |s| near.(s, 1.2) });
ok.("bps is the played tempo", near.(tm.bps, 1 / 1.2, 1e-9));
ok.("bounds.end ignored", near.(tm.times.last, 4.8));

// --- short tail: the original failure direction ----------------------------
item = mk.([0, 1.2, 2.4, 3.6], 0.3);          // bounds.end = 3.9, only 0.3 past
tm = MIDIItemTempoMap(item, nil, 1!4);
spans = tm.times.differentiate.drop(1);
ok.("short tail no longer shortens the last span", near.(spans.last, 1.2));

// --- uneven marks: repeat the LAST span, not the mean ----------------------
item = mk.([0, 1.0, 2.0, 3.5], 1.0);
tm = MIDIItemTempoMap(item, nil, 1!4);
spans = tm.times.differentiate.drop(1);
ok.("repeats last span (1.5), not the mean", near.(spans.last, 1.5));

// --- explicit closingAnchor still wins -------------------------------------
pl = mk.([0, 1.2, 2.4, 3.6], 0.3).player;   // closingAnchor lives on the PLAYER
pl.closingAnchor = (time: 5.0, beats: 1);
tm = MIDIItemTempoMap(pl, nil, 1!4);
ok.("explicit closingAnchor wins", near.(tm.times.last, 5.0));

// --- single mark falls back to bounds.end ----------------------------------
one = mk.([0.5], 1.5);
tm = { MIDIItemTempoMap(one, nil, [1]) }.try;
ok.("single mark still builds (bounds.end fallback)",
	tm.notNil and: { near.(tm.times.last, 1.5) });

// --- extrapolation past the end now carries the played tempo ---------------
item = mk.([0, 1.2, 2.4, 3.6], 2.5);
tm = MIDIItemTempoMap(item, nil, 1!4);
ok.("beat 10 extrapolates at played tempo", near.(tm.timeAt(10), 12.0, 1e-6));


// --- init guards ------------------------------------------------------------
// one beat gap per MARK: 4 marks -> 5 anchors -> 4 spans, so 1!4 is right and
// 1!5 (the "one per anchor" mistake) must be refused, not silently built
item = mk.([0, 1.2, 2.4, 3.6], 0.2);
ok.("correct size builds",       { MIDIItemTempoMap(item, nil, 1!4) }.try.notNil);
ok.("too many beat gaps throws", { MIDIItemTempoMap(item, nil, 1!5) }.try { true } ? false);
ok.("too few beat gaps throws",  { MIDIItemTempoMap(item, nil, 1!3) }.try { true } ? false);
ok.("nil beats throws",          { MIDIItemTempoMap(item, nil, nil) }.try { true } ? false);
ok.("no marks throws",
	{ MIDIItemTempoMap(MIDIItem(\emptyProbe), nil, [1]) }.try { true } ? false);
// a chord (two marks at one timestamp) still BUILDS — warns, and the degenerate
// span reads as no tempo rather than a bogus one
tm = { MIDIItemTempoMap(mk.([0, 1.2, 1.2, 2.4], 0.2), nil, 1!4) }.try;
ok.("duplicate mark times still build", tm.notNil);
ok.("degenerate span reads nil", tm.notNil and: { tm.tempoCurve.any(_.isNil) });

"=== SENTINEL DONE ===".postln;
)
