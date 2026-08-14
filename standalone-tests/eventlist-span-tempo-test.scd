(
var it, el, fresh, ok, near, allNear, base, a, b;
near = { |x, y, tol = 1e-9| (x - y).abs < tol };
allNear = { |x, y| (x.size == y.size) and: { x.every { |v, i| near.(v, y[i], 1e-9) } } };
ok = { |label, cond| ("%  %".format(cond.if("PASS","FAIL"), label)).postln };
"=== SENTINEL START ===".postln;

it = MIDIItem(\spanProbe);
[0.7, 1.9, 3.1, 4.3, 5.5, 6.7].do { |t, i|
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

"=== SENTINEL DONE ===".postln;
)
