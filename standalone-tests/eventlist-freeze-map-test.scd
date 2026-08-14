(
var src, item, el, orig, frozen, probes, ok, near, allSame;
near = { |a, b, tol = 1e-9| (a - b).abs < tol };
ok = { |label, cond| ("%  %".format(cond.if("PASS","FAIL"), label)).postln };
"=== SENTINEL START ===".postln;

// a MIDIItem with a few notes, so tempomap is the init-built kind (has midiEvents)
item = MIDIItem(\freezeTest);
[0.7, 1.9, 3.2, 4.4, 5.6].do { |t, i|
	item.midiEvents = item.midiEvents.add(
		(type: \mk, midicmd: \noteOn, timestamp: t, midinote: 60 + i, veloc: 80));
	item.midiEvents = item.midiEvents.add(
		(type: \mkOff, midicmd: \noteOff, timestamp: t + 0.5, midinote: 60 + i));
};
orig = MIDIItemTempoMap(item, nil, 1!5);   // init path: keeps midiEvents
ok.("source really is init-built", orig.class == MIDIItemTempoMap and: { orig.isKindOf(AnchorTempoMap).not });

el = EventList(nil, \note);
el.tempoMap = orig;
frozen = el.tempoMap;

ok.("stored as AnchorTempoMap",  frozen.class == AnchorTempoMap);
ok.("no retained midiEvents",    { frozen.midiEvents; false }.try { true });
ok.("t0 preserved",              near.(frozen.t0, orig.t0));
ok.("beatDomain preserved",      near.(frozen.beatDomain[1], orig.beatDomain[1]));
ok.("bps preserved",             near.(frozen.bps, orig.bps));

// the shape itself, at fine resolution, inside AND past the end (extrapolation)
probes = (-20 .. 120).collect { |i| i * 0.1 };
allSame = probes.every { |b| near.(frozen.timeAt(b), orig.timeAt(b), 1e-9) };
ok.("timeAt identical everywhere (incl. extrapolation)", allSame);
allSame = probes.select { |x| x > 0 }.every { |s| near.(frozen.beatAt(s), orig.beatAt(s), 1e-9) };
ok.("beatAt identical everywhere", allSame);

// and the EventList reader that t0 feeds
ok.("list beatToWall unchanged",
	(0, 0.25 .. 8).every { |b|
		near.(el.beatToWall(b, nil), orig.timeAt(b), 1e-9) });

// an AnchorTempoMap assigned again is left alone (idempotent, no double-rebase)
el.tempoMap = frozen;
ok.("idempotent", el.tempoMap === frozen);

// a MonoMap still takes the old rebase path
el.tempoMap = AnchorMap([0, 4], [0, 5], \beat, \sec);
ok.("MonoMap path intact", el.tempoMap.class == AnchorTempoMap and: { near.(el.tempoMap.t0, 0) });

"=== SENTINEL DONE ===".postln;
)
