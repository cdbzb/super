(
var mk, item, tm, c, ok, near, allNear;
near = { |a, b, tol = 1e-6| (a - b).abs < tol };
allNear = { |a, b| (a.size == b.size) and: { a.every { |v, i| near.(v, b[i]) } } };
ok = { |label, cond| ("%  %".format(cond.if("PASS","FAIL"), label)).postln };
"=== SENTINEL START ===".postln;

mk = { |onsets, tail = 0.2|
	var it = MIDIItem(("tc" ++ UniqueID.next).asSymbol);
	onsets.do { |t, i|
		it.midiEvents = it.midiEvents.add(
			(type: \mk, midicmd: \noteOn, timestamp: t, midinote: 60 + i, veloc: 80));
		it.midiEvents = it.midiEvents.add(
			(type: \mkOff, midicmd: \noteOff,
			 timestamp: t + ((i == (onsets.size - 1)).if(tail, 0.1)), midinote: 60 + i));
	};
	it
};

// steady 1.2 s/beat = 50 bpm, 4 marks -> 4 spans (closing repeats the last)
tm = MIDIItemTempoMap(mk.([0, 1.2, 2.4, 3.6]), nil, 1!4);
c = tm.tempoCurve;
ok.("one value per span",        c.size == 4);
ok.("steady take reads 50 bpm",  allNear.(c, 50 ! 4));

// a slowing take: 1.0, 1.2, 1.5 -> 60, 50, 40, then 40 repeated as the close
tm = MIDIItemTempoMap(mk.([0, 1.0, 2.2, 3.7]), nil, 1!4);
ok.("uneven spans read per-span", allNear.(tm.tempoCurve, [60, 50, 40, 40]));

// non-unit beat gaps: 2 beats in 2.4 s is still 50 bpm, not 25
tm = MIDIItemTempoMap(mk.([0, 2.4, 4.8]), nil, [2, 2, 2]);
ok.("beat-gap of 2 reads 50 bpm", allNear.(tm.tempoCurve, 50 ! 3));

// subdiv resamples and agrees with the anchors on a linear map
tm = MIDIItemTempoMap(mk.([0, 1.2, 2.4, 3.6]), nil, 1!4);
c = tm.tempoCurve(4);
ok.("subdiv 4 gives 4x the points", c.size == 16);
ok.("subdiv agrees with anchors",   c.every { |v| near.(v, 50, 1e-6) });
ok.("subdiv 0 warns and returns []", tm.tempoCurve(0) == []);

// TempoMap stores spans directly
tm = TempoMap([1, 1, 2], [1.0, 1.2, 2.4]);
ok.("TempoMap per-span bpm", allNear.(tm.tempoCurve, [60, 50, 50]));

// AnchorTempoMap inherits it
tm = AnchorTempoMap([0, 1.2, 2.4], [0, 1, 2]);
ok.("AnchorTempoMap inherits tempoCurve", allNear.(tm.tempoCurve, [50, 50]));
ok.("responds to plotTempo", tm.respondsTo(\plotTempo));

"=== SENTINEL DONE ===".postln;
)
