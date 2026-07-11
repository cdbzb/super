// Headless regression suite for TempoMap / MIDIItemTempoMap invariants
// (milestone 0, quantize-tempomap-project.md §6). Pure language — no server.
// Run: /Applications/SuperCollider.app/Contents/MacOS/sclang standalone-tests/tempomap-test.scd
//
// Covers the M0 invariants + the M0 bug fixes:
//   - env/invEnv round-trip
//   - anchors preserved through .curve
//   - mapBeats / warpToArray preserve array length (clamp, not select)
//   - quantize(0) == identity
//   - range-quantize writes the right indices
//   - quantizeWindow leaves env consistent with its durs (no staleness)
//   - carry-forward boundary values (machine-confirm)
(
var h = (thisProcess.nowExecutingPath.dirname +/+ "test-helpers.scd").load;
var assert = h[\assert];
var assertClose = { |a, b, msg, tol = 1e-6| h[\assertClose].(a, b, msg, tol) };
var assertArr = { |a, b, msg, tol = 1e-6| h[\assertArr].(a, b, msg, tol) };
var t, r, warped, close, p, mt, mkNote, notes, sweep;

"== TempoMap / MIDIItemTempoMap tests ==".postln;

// wrap so an unexpected throw still reaches 0.exit (never leave a live sclang).
// try (not protect): the handler runs ONLY on error, not on success.
try {

// ------------------------------------------------------------------ TempoMap
// A jittery performance: ideal beats all 1, performed durs wobble.
t = TempoMap([1,1,1,1,1,1], [1,2,1,3,1,2]);

// -- 1. env (beat -> performed time) is a proper cumulative map ------------
assertClose.(t.at(0), 0, "TempoMap at(0) == 0");
assertClose.(t.at(t.beats.sum), t.durs.sum, "TempoMap at(total beats) == total durs");
sweep = (0, 0.25 .. t.beats.sum);
assert.(sweep.differentiate.drop(1).collect { |d, i|
	t.at(sweep[i + 1]) - t.at(sweep[i]) }.every(_ >= -1e-9),
	"TempoMap at() is monotonic non-decreasing");

// -- 2. mapBeats reproduces durs on the ideal grid, preserves length -------
warped = t.mapBeats(1 ! 6);
assert.(warped.size == 6, "mapBeats: length preserved on unit beats");
assertArr.(warped, [1,2,1,3,1,2], "mapBeats: reproduces performed durs");

// -- 2b. direction-explicit protocol aliases ------------------------------
assertClose.(t.timeAt(2), t.at(2), "TempoMap timeAt aliases beat -> time");
assertClose.(t.beatAt(t.timeAt(2.5)), 2.5, "TempoMap beatAt inverts timeAt");
assertArr.(t.mapDurs(t.mapBeats([1,2,1,2])), [1,2,1,2],
	"TempoMap mapDurs maps second durs back to beats");
assertArr.(t.mapBeats([1,1], 1), [2,1],
	"TempoMap mapBeats: nonzero beat origin selects local tempo");
assertArr.(t.mapDurs([2,1], 1), [1,1],
	"TempoMap mapDurs: nonzero time origin selects local tempo");
assertArr.(t.beatDomain, [0,6], "TempoMap beatDomain reports relative extent");
assertArr.(t.timeDomain, [0,10], "TempoMap timeDomain reports relative extent");
assert.(t.extrapolation == \clamp, "TempoMap declares legacy clamp policy");
assertClose.(t.timeAt(100), t.timeDomain.last,
	"TempoMap clamp policy matches out-of-domain behavior");

// -- 3. mapBeats preserves length across a ZERO-length span ----------------
// [1,0,1] integrates to a repeated position -> a 0 dur; the old
// .select(_.isStrictlyPositive) DROPPED it and desynced the array.
warped = TempoMap([1,1,1],[1,1,1]).mapBeats([1,0,1]);
assert.(warped.size == 3, "mapBeats: zero-span keeps length (clamp not select)");
assert.(warped[1] > 0, "mapBeats: zero-span clamped positive");
assert.(warped[1] < 1e-3, "mapBeats: zero-span stays ~0");

// -- 4. warpToArray (plusArray) also clamps, not selects -------------------
warped = [1,0,1].warpTo([1,1,1,1]);
assert.(warped.size == 3, "warpToArray: zero-span keeps length");

// -- 5. quantize(0) == identity -------------------------------------------
r = t.quantize(0);
assertArr.(r.durs, t.durs, "quantize(0): durs unchanged");
assertArr.(r.beats, t.beats, "quantize(0): beats unchanged");

// -- 6. quantize(1) == constant mean tempo --------------------------------
r = t.quantize(1);
close = t.durs.sum / t.beats.sum;   // mean seconds-per-beat
assertArr.(r.durs, t.beats * close, "quantize(1): rigid mean tempo");
assertClose.(r.durs.sum, t.durs.sum, "quantize(1): total duration preserved");

// -- 7. range-quantize writes the RIGHT indices ---------------------------
// durs [1,2,3,4,5,6]; quantize(1) over indices 2..4 -> those become the
// range mean (12/3 = 4), everything else untouched. The old
// (start..end).do bug wrote at start+start.. and read past `quantized`.
t = TempoMap([1,1,1,1,1,1], [1,2,3,4,5,6]);
r = t.quantize(1, 2, 4);
assertArr.(r.durs, [1,2,4,4,4,6], "quantizeRange: correct indices written");
// and no off-by-one nil when end omitted (defaults to last index)
r = t.quantize(0, 1);   // amount 0 -> identity even over the default range
assertArr.(r.durs, t.durs, "quantizeRange: end defaults to last index (no nil)");

// -- 8. quantizeWindow leaves env consistent with its durs (no staleness) --
// env is read by at()/mapBeats; if quantizeWindow mutates durs but not env,
// the result MAPS LIKE THE UNQUANTIZED ORIGINAL.
t = TempoMap([1,1,1,1,1,1], [1,3,1,3,1,3]);
r = t.quantizeWindow(1, 3);
assertArr.(r.env.levels, ([0] ++ r.durs).integrate,
	"quantizeWindow: env tracks mutated durs");
// the durs setter must rebuild env too
t = TempoMap([1,1,1], [1,1,1]);
t.durs = [2,2,2];
assertArr.(t.env.levels, [0,2,4,6], "durs setter rebuilds env");

// -- 8b. dursToBeats / interpolateBeatInverse (performed time -> beat) ------
// Was broken (constant output -> [x,0,0,...]): interpolateBeatInverse built a
// malformed Env per call. Now the cached env.invert (plusEnv.sc).
t = TempoMap([1,1,1,1,1,1], [1,2,1,3,1,2]);
assertArr.(t.dursToBeats([1,2,1,3,1,2]), 1 ! 6,
	"dursToBeats: performed durs back to unit beats");
// roundtrip with mapBeats on an uneven beat grid
assertArr.(t.dursToBeats(t.mapBeats([0.5, 1.5, 2, 1, 1])), [0.5, 1.5, 2, 1, 1],
	"dursToBeats: inverse of mapBeats");
// mid-span: time 2 lies halfway through the 2s span (beat 1 -> 2)
assertClose.(t.interpolateBeatInverse(2), 1.5, "interpolateBeatInverse: mid-span");
// at() roundtrip
[0.5, 2.0, 5.5, 8.0].do { |time|
	assertClose.(t.at(t.interpolateBeatInverse(time)), time,
		"interpolateBeatInverse: at() roundtrip time" + time)
};

// -------------------------------------------------------- MIDIItemTempoMap
// Build a synthetic player so this is pure-language (no MIDI fixture).
// 6 noteOns; first 5 are anchors, 6th + its dur sets the closing anchor.
mkNote = { |ts, note = 60| (midicmd: \noteOn, type: \mk, timestamp: ts,
	midinote: note, dur: 1, sustain: 1, amp: 0.5) };
notes = [0, 1, 2, 3, 4, 6].collect { |ts| mkNote.(ts) };
p  = MIDIItemPlayer(notes, nil);
mt = MIDIItemTempoMap(p, { |n| n[0..4] }, [1,1,1,1,1]);

// closing anchor: last note at 6 + dur 1 = 7, so the final span (ideal beat
// 4->5) maps to performed 4->7 = 3 s/beat.
// -- 9. MIDIItemTempoMap env/invEnv (at <-> timeAt) round-trip -------------
[0.5, 2.0, 3.5].do { |beat|
	assertClose.(mt.at(mt.timeAt(beat)), beat,
		"mi2 round-trip beat" + beat, 1e-4)
};
assertClose.(mt.beatAt(mt.timeAt(2.5)), 2.5,
	"mi2 beatAt inverts timeAt", 1e-4);
assertClose.(mt.beatAt(mt.timeAt(-1)), -1,
	"mi2 protocol carries boundary tempo before domain", 1e-4);
assertClose.(mt.beatAt(mt.timeAt(7)), 7,
	"mi2 protocol carries boundary tempo after domain", 1e-3);

// -- 10. mapBeats reproduces performed spans on the beat grid --------------
warped = mt.mapBeats(1 ! 5);
assert.(warped.size == 5, "mi2 mapBeats: length preserved");
assertArr.(warped, [1,1,1,1,3], "mi2 mapBeats: reproduces performed spans", 1e-4);
assertArr.(mt.mapDurs(warped), 1 ! 5,
	"mi2 mapDurs maps second durs back to beats", 1e-4);
assertArr.(mt.mapBeats([1,1], 3), [1,3],
	"mi2 mapBeats: nonzero beat origin selects local tempo", 1e-4);
assertArr.(mt.mapDurs([1,3], 3), [1,1],
	"mi2 mapDurs: nonzero time origin selects local tempo", 1e-4);
assertArr.(mt.mapBeats([1,1], 5), [3,3],
	"mi2 mapBeats: nonzero origin carries final tempo past domain", 1e-3);
assertArr.(mt.mapDurs([3,3], 7), [1,1],
	"mi2 mapDurs: nonzero origin carries final tempo past domain", 1e-3);
assertArr.((1 ! 5).warpTo(mt), warped,
	"legacy warpTo remains zero-origin mapBeats", 1e-4);
assertArr.(mt.beatDomain, [0,5], "mi2 beatDomain reports relative extent");
assertArr.(mt.timeDomain, [0,7], "mi2 timeDomain reports relative extent");
assert.(mt.extrapolation == \carry, "mi2 declares carry policy");
assert.(mt.timeAt(6) > mt.timeDomain.last,
	"mi2 carry policy continues beyond time domain");
assertArr.(mt.curve(1).beatDomain, mt.beatDomain,
	"mi2 curved map preserves beat domain", 1e-4);
assertArr.(mt.clump(2).timeDomain, mt.timeDomain,
	"mi2 clumped map preserves time domain", 1e-4);

// -- 11. carry-forward boundary: beats past the map extrapolate at the -----
// final tempo (3 s/beat), and length is preserved (no drop).
warped = (1 ! 8).warpTo(mt);
assert.(warped.size == 8, "mi2 carry-forward: length preserved past domain");
assertArr.(warped, [1,1,1,1,3,3,3,3], "mi2 carry-forward: final tempo held", 1e-3);

// -- 12. .curve preserves anchors -----------------------------------------
// curve(0) == linear bit-for-similar; curve(1) still passes through anchors.
assertArr.((1 ! 8).warpTo(mt.curve(0)), (1 ! 8).warpTo(mt),
	"mi2 curve(0) == linear", 1e-4);
assertArr.((1 ! 5).warpTo(mt.curve(1)), [1,1,1,1,3],
	"mi2 curve(1) passes through anchors", 1e-3);

// -- 13. scaleBeats: relabel the beat axis, non-mutating -------------------
r = mt.scaleBeats(2);
assertArr.(r.beats, [2,2,2,2,2], "scaleBeats: beats multiplied by k");
assertArr.(mt.beats, [1,1,1,1,1], "scaleBeats: original map unchanged");
// pure relabel: same performed time, addressed at k*beat
assertClose.(r.timeAt(2), mt.timeAt(1), "scaleBeats: timeAt(k*b) == old timeAt(b)", 1e-4);
// tempo scales by k
assertClose.(r.bps, mt.bps * 2, "scaleBeats: bps scales by k", 1e-4);
// to reproduce the anchor gaps you now feed k-beat spans
assertArr.((2 ! 5).warpTo(r), [1,1,1,1,3],
	"scaleBeats: (k!n).warpTo reproduces performed spans", 1e-3);

// -- 14. MIDIItemPlayer.scaleBeats flows into tempomap (what asEventList uses) --
// p has 6 noteOns; with no selection, tempomap(1!6) uses I.d (all 6) as anchors.
assertArr.(p.scaleBeats(2).tempomap(1 ! 6).beats, 2 ! 6,
	"player scaleBeats: tempomap beats scaled");
assertArr.(p.tempomap(1 ! 6).beats, 1 ! 6,
	"player scaleBeats: original player unchanged (non-mutating)");
// env drives asEventList's `when`; performed time 1 maps to 2x the beat
assertClose.(p.scaleBeats(2).tempomap(1 ! 6).at(1), 2,
	"player scaleBeats: env (when source) doubles", 1e-4);
assertClose.(p.tempomap(1 ! 6).at(1), 1, "player scaleBeats: unscaled env unchanged", 1e-4);
assertArr.(p.scaleBeats(2).scaleBeats(2).tempomap(1 ! 6).beats, 4 ! 6,
	"player scaleBeats: composes");

// -- 15. trim(from, to): beat-domain sub-map, re-zeroed, t0 preserves offset --
r = mt.trim(1, 3);
assertArr.(r.beats, [1,1], "trim: beats are the windowed gaps");
assertArr.(r.times, [0,1,2], "trim: times re-zeroed to window start");
assertClose.(r.t0, mt.t0 + 1, "trim: t0 absorbs the offset");
assertArr.((1 ! 2).warpTo(r), [1,1], "trim: warpTo reproduces windowed spans");
// absolute placement preserved: r's beat 0 == mt's beat 1
assertClose.(r.timeAt(0) + r.t0, mt.timeAt(1) + mt.t0, "trim: absolute start preserved", 1e-4);
assertArr.(mt.beats, [1,1,1,1,1], "trim: original map unchanged");
// window crossing the fast final span (ideal beat 4->5 is 3 s/beat)
r = mt.trim(3, 5);
assertArr.((1 ! 2).warpTo(r), [1,3], "trim: fast final span captured", 1e-4);
// fractional / mid-span endpoints
r = mt.trim(0.5, 2.5);
assertClose.(r.beats.sum, 2, "trim: total beats == to - from");
assertClose.(r.timeAt(r.beats.sum) + r.t0, mt.timeAt(2.5) + mt.t0,
	"trim: window end preserved", 1e-4);
// to defaults to the map end -> trim(0) is identity
assertArr.(mt.trim(0).beats, mt.beats, "trim(0): identity");

// -- 16. clump: lower anchor resolution, pick placement, pinned endpoints --
r = mt.clump(2);
assertArr.(r.beats, [2,2,1], "clump(2): spans merged with remainder retained");
assertArr.(r.times, [0,2,4,7], "clump(2): boundary anchor times picked verbatim");
assertClose.(r.timeAt(0), mt.timeAt(0), "clump(2): first endpoint pinned");
assertClose.(r.timeAt(r.beats.sum), mt.timeAt(mt.beats.sum),
	"clump(2): last endpoint pinned");
assertArr.(mt.beats, [1,1,1,1,1], "clump: original map unchanged");

// array sizes cycle; [1,2] over five spans -> groups 1,2,1,1(remainder)
r = mt.clump([1,2]);
assertArr.(r.beats, [1,2,1,1], "clump(array): group sizes cycle");
assertArr.(r.times, [0,1,3,4,7], "clump(array): correct picked anchors");

// arbitrary beat values are summed, rather than assuming unit beats
r = MIDIItemTempoMap(p, { |n| n[0..4] }, [1,2,3,4,5]).clump([2,1]);
assertArr.(r.beats, [3,3,9], "clump: re-aggregates non-unit beat spans");

// a transform after curve deliberately returns to linear; curvature composes after it
r = mt.curve(1).clump(2);
assert.(r.curved.not, "clump(curved map): rebuilds linear map");
assertArr.(r.times, [0,2,4,7], "clump(curved map): picks original anchors");

} { |e|
	h[\fail].("EXCEPTION - " ++ e.errorString);
};

// -------------------------------------------------------------------- report
h[\report].();
0.exit;
)
