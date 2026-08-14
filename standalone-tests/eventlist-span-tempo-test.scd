(
var it, el, fresh, ok, near, allNear, base, a, b, c;
near = { |x, y, tol = 1e-9| (x - y).abs < tol };
allNear = { |x, y| (x.size == y.size) and: { x.every { |v, i| near.(v, y[i], 1e-9) } } };
ok = { |label, cond| ("%  %".format(cond.if("PASS","FAIL"), label)).postln };
"=== SENTINEL START ===".postln;

it = MIDIItem(\spanProbe);
[0.7, 1.7, 2.7, 4.1, 4.9, 6.1].do { |t, i|
	it.midiEvents = it.midiEvents.add((type: \mk, midicmd: \noteOn, timestamp: t, midinote: 60+i, veloc: 80));
	it.midiEvents = it.midiEvents.add((type: \mkOff, midicmd: \noteOff, timestamp: t+0.2, midinote: 60+i));
};
base = MIDIItemTempoMap(it, nil, 1!6);
fresh = { el = EventList(nil, \note); el.tempoMap = base; el };

// --- t0 survives every prMapEdit path --------------------------------------
ok.("t0 on the stored map",     near.(fresh.().tempoMap.t0, 0.7));
ok.("t0 survives quantize",       near.(fresh.().quantize(1).tempoMap.t0, 0.7));
ok.("t0 survives quantizeWindow", near.(fresh.().quantizeWindow(1).tempoMap.t0, 0.7));
ok.("t0 survives quantizeSpan",   near.(fresh.().quantizeSpan(1, 3, 1).tempoMap.t0, 0.7));
ok.("t0 survives setSpanTempo",   near.(fresh.().setSpanTempo(1, 3, 1).tempoMap.t0, 0.7));

// --- the restore must not disturb the shape --------------------------------
a = fresh.().tempoMap;
b = fresh.().quantize(0).tempoMap;          // amount 0 = bit-exact unchanged
ok.("quantize(0) leaves the shape alone",
	(0, 0.25 .. 8).every { |x| near.(a.timeAt(x), b.timeAt(x), 1e-9) });
ok.("quantize(0) leaves t0 alone", near.(b.t0, a.t0));

// --- setSpanTempo / setSpanBpm on the list ---------------------------------
el = fresh.().setSpanTempo(1, 3, 1);        // 1 bps = 60 bpm over beats 1..3
ok.("span set to the named tempo",
	near.(el.tempoMap.timeAt(3) - el.tempoMap.timeAt(1), 2.0, 1e-9));
ok.("setSpanBpm == setSpanTempo/60",
	near.(fresh.().setSpanBpm(1, 3, 60).tempoMap.timeAt(3),
	      fresh.().setSpanTempo(1, 3, 1).tempoMap.timeAt(3), 1e-9));

// material before the span is untouched; after it is SHIFTED, not rescaled
a = fresh.().tempoMap;
b = fresh.().setSpanTempo(1, 3, 1).tempoMap;
ok.("before the span: identical",
	(0, 0.25 .. 1).every { |x| near.(a.timeAt(x), b.timeAt(x), 1e-9) });
ok.("after the span: shifted, not rescaled",
	((3, 3.5 .. 6).collect { |x| b.timeAt(x) - a.timeAt(x) }
		.every { |d, i, all| near.(d, b.timeAt(3) - a.timeAt(3), 1e-9) }));

// --- a map with t0 == 0 takes the no-op path -------------------------------
el = EventList(nil, \note);
el.tempoMap = AnchorTempoMap([0, 1.2, 2.4], [0, 1, 2]);
ok.("t0 0 stays 0 through quantize", el.quantize(1).tempoMap.t0 == 0);

// --- guards -----------------------------------------------------------------
ok.("bps 0 refused", { fresh.().setSpanTempo(1, 3, 0) }.try { true } ? false);


// --- reading a span back ----------------------------------------------------
ok.("map spanBpm inverts setSpanBpm",
	near.(fresh.().setSpanBpm(1, 3, 44).tempoMap.spanBpm(1, 3), 44, 1e-9));
ok.("map spanTempo is bpm/60",
	near.(fresh.().setSpanBpm(1, 3, 44).tempoMap.spanTempo(1, 3), 44/60, 1e-9));
// on a FLAT span any sub-range reads the same tempo; ends off the anchors are
// fine either way, they just do not equal the span mean on a varying span
ok.("span ends need not be anchors",
	near.(fresh.().quantizeSpan(1, 4, 1).setSpanBpm(1, 4, 44).tempoMap.spanBpm(1.5, 3.25),
	      44, 1e-9));
ok.("sub-range of a VARYING span differs from its mean",
	near.(fresh.().setSpanBpm(1, 4, 44).tempoMap.spanBpm(1.5, 3.25), 44, 1e-9).not);
ok.("reads past the map end (extrapolates, not clamps)",
	fresh.().tempoMap.spanBpm(5, 9).notNil);
ok.("zero-width span answers nil", fresh.().tempoMap.spanBpm(2, 2).isNil);
ok.("reversed span answers nil",   fresh.().tempoMap.spanBpm(3, 1).isNil);
// reading is a question about a MAP: the list deliberately does not answer it,
// since a list-level spanBpm would have to compose \tempoTrack to be honest
ok.("EventList does not answer spanBpm", EventList.findMethod(\spanBpm).isNil);
ok.("EventList does not answer spanTempo", EventList.findMethod(\spanTempo).isNil);


// --- the median moves, the variation does not -------------------------------
// THE distinguishing property vs quantizeSpan: every span inside [1, 4] must be
// scaled by the SAME factor, so their bpm ratios to each other are untouched.
a = fresh.().tempoMap.tempoCurve;
b = fresh.().setSpanBpm(1, 4, 40).tempoMap.tempoCurve;
ok.("inner spans scale by one common factor",
	(1..3).collect { |i| b[i] / a[i] }.every { |r| near.(r, b[1] / a[1], 1e-9) });
ok.("the mean actually moved",
	near.(fresh.().setSpanBpm(1, 4, 40).tempoMap.spanBpm(1, 4), 40, 1e-9));
ok.("variation survived (spans still differ)",
	(b[1] - b[2]).abs > 1e-6);
// quantizeSpan is the complement: variation goes, mean stays
a = fresh.().tempoMap.spanBpm(1, 4);
b = fresh.().quantizeSpan(1, 4, 1);
ok.("quantizeSpan keeps the mean", near.(b.tempoMap.spanBpm(1, 4), a, 1e-9));
c = (1..3).collect { |i| b.tempoMap.tempoCurve[i] };
ok.("quantizeSpan removes the variation", c.every { |v| near.(v, c[0], 1e-6) });

"=== SENTINEL DONE ===".postln;
)
