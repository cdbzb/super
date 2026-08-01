// Headless regression suite for the §12C "clean beat playback" click grid
// (quantize-tempomap-project.md): MIDIItemPlayer.beatTimes — the absolute
// performed times of every 1/subdiv beat of a loaded selection, which is what
// the gui now uses for clicks, cursor snapping and the count-in when no
// extrapolate/DP grid is up. Pure language — no server, no disk.
// Run: /Applications/SuperCollider.app/Contents/MacOS/sclang standalone-tests/beat-times-test.scd
//
// Fixture convention: [midinote:..., dur:...].asMIDIItem stamps timestamps in
// BEATS, which these tests read as seconds — fine here, the maps only care that
// the two axes are consistent. NOTE: MIDIItem.notes/.player hand back a fresh
// deepCopy each call, so markSelection must be applied to a HELD player (or the
// item's own midiEvents must be stamped directly) — see trim-intro-test.scd.
(
var h = (thisProcess.nowExecutingPath.dirname +/+ "test-helpers.scd").load;
var assert = h[\assert];
var assertClose = { |a, b, msg, tol = 1e-6| h[\assertClose].(a, b, msg, tol) };
var assertArr = { |a, b, msg, tol = 1e-6| h[\assertArr].(a, b, msg, tol) };
var mkPlayer;
var p, bt, half, item, uneven, junk, legacy, empty, bpm;

"== beatTimes (§12C) tests ==".postln;

// player from a pitch/dur spec, with a selection stamped on the HELD player.
// indices/coords index the NOTES (noteOns), matching a saved selection.
mkPlayer = { |midinotes, durs, indices, coords|
	var pl = [midinote: midinotes, dur: durs].asMIDIItem.player;
	indices !? { pl.markSelection(indices, coords) };
	pl
};

try {

// ------------------------------------------------------------ uneven anchors
// three anchors, one beat apart in BEAT terms but 1s then 2s in performed time.
// The closing anchor (clip end) adds one more beat span, so the domain is 3.
p = mkPlayer.([60, 62, 64], [1, 2, 1], [0, 1, 2], [0, 1, 2]);
assertArr.(p.notes.collect(_.timestamp), [0, 1, 3], "fixture: performed onsets 0/1/3");

bt = p.beatTimes;
assert.(bt.size == 4, "beatTimes: 4 beats (0..3 — the closing anchor is included), got %"
	.format(bt.size));
assertArr.(bt.keep(3), [0, 1, 3], "beatTimes: anchor beats land on the selected notes");
// every integer beat agrees with timeAtBeat — beatTimes IS that, sampled
4.do { |i|
	assertClose.(bt[i], p.timeAtBeat(i), "beatTimes[%] == timeAtBeat(%)".format(i, i))
};
// the last entry is the map's closing anchor (clip end), not a played note
assertClose.(bt.last, p.timeAtBeat(3), "beatTimes: last entry is the closing anchor");
assert.(bt.last > p.notes.last.timestamp, "beatTimes: the closing beat is past the last note");
// strictly increasing — a click grid must be monotone
assert.(bt.differentiate.drop(1).every(_ > 0), "beatTimes: strictly increasing");

// -------------------------------------------------------------------- subdiv
half = p.beatTimes(2);
assert.(half.size == 7, "beatTimes(2): 7 half-beats over a 3-beat domain, got %"
	.format(half.size));
assertArr.((0 .. 3).collect { |i| half[i * 2] }, bt,
	"beatTimes(2): the integer beats are preserved exactly");
// per-SPAN interpolation: the half beat inside the 1s span is at 0.5, the one
// inside the 2s span at 2 — a naive uniform division of the whole 0..3s domain
// into 6 would have put every half-beat 0.5s apart.
assertClose.(half[1], 0.5, "beatTimes(2): half beat follows the LOCAL span (fast span)");
assertClose.(half[3], 2.0, "beatTimes(2): half beat follows the LOCAL span (slow span)");
assert.((half[3] - half[2]) != (half[1] - half[0]),
	"beatTimes(2): spacing differs between spans (not a uniform split)");
assertClose.(p.beatTimes(4).size, 13, "beatTimes(4): density scales with subdiv");
assertArr.((0 .. 6).collect { |i| p.beatTimes(4)[i * 2] }, half,
	"beatTimes(4): contains every half-beat of beatTimes(2)");

// ----------------------------------------- interpolation across a 2-beat gap
// Anchors at beats 0, 1, 3, 4; an UNSELECTED note sits at 1.7s inside the
// 2-beat span. Beat 2 must sit where the map puts it (the span midpoint, 2.0),
// not on the nearest note the way a note-snapping grid would.
uneven = mkPlayer.([60, 62, 63, 64, 65], [1, 0.7, 1.3, 1, 1], [0, 1, 3, 4], [0, 1, 3, 4]);
assertArr.(uneven.notes.collect(_.timestamp), [0, 1, 1.7, 3, 4],
	"fixture: an unselected note at 1.7 inside the 2-beat span");
bt = uneven.beatTimes;
assertClose.(bt[2], 2.0, "beatTimes: the ghost beat is the map's interpolation (2.0)");
assert.((bt[2] - 1.7).abs > 0.25, "beatTimes: the ghost beat is NOT snapped to the note at 1.7");
assertArr.(bt.keep(5), [0, 1, 2, 3, 4], "beatTimes: anchors + ghost beat");
5.do { |i|
	assertClose.(bt[i], uneven.timeAtBeat(i), "uneven: beatTimes[%] == timeAtBeat(%)".format(i, i))
};

// --------------------------------------------------------- absolute placement
// a junk intro means beat 0 is NOT time 0: the grid is absolute (timeAt + t0).
junk = mkPlayer.([48, 60, 62, 64], [0.5, 1, 1, 1], [1, 2, 3], [0, 1, 2]);
bt = junk.beatTimes;
assertClose.(bt[0], 0.5, "beatTimes: beat 0 is the first SELECTED note (t0 applied)");
assertArr.(bt.keep(3), [0.5, 1.5, 2.5], "beatTimes: absolute times, junk intro excluded");
assert.(bt.every { |t| t >= 0.5 }, "beatTimes: nothing before the first anchor");

// ------------------------------------------------------ selection plumbing
// markers ride a deepCopy, so a selection stamped on the ITEM reaches the
// player exactly like a reloaded saved selection does (no tracker state).
item = [midinote: [60, 62, 64], dur: [1, 2, 1]].asMIDIItem;
item.midiEvents.select { |e| e.midicmd == \noteOn }.do { |e, i| e[\selBeat] = i };
assertArr.(item.player.beatTimes, [0, 1, 3, item.player.timeAtBeat(3)],
	"beatTimes: works from markers stamped on the item (reloaded selection)");

// legacy index-based selection (no \selBeat markers) resolves through prSelectionArgs
legacy = mkPlayer.([60, 62, 64], [1, 2, 1]);
legacy.currentSelection = (indices: [0, 1, 2], beats: [1, 1]);
assertArr.(legacy.beatTimes, [0, 1, 3, legacy.timeAtBeat(3)],
	"beatTimes: falls back to currentSelection[\\indices]");

// ------------------------------------------------------------- degenerate in
empty = mkPlayer.([60, 62, 64], 1);
assert.(empty.beatTimes == [], "beatTimes: no selection -> []");
assert.(empty.beatTimes(4) == [], "beatTimes: no selection -> [] at any subdiv");
"  (expect two 'subdiv must be a positive number' warnings next)".postln;
assert.(p.beatTimes(0) == [], "beatTimes: subdiv 0 -> []");
assert.(p.beatTimes(-2) == [], "beatTimes: negative subdiv -> []");

// ------------------------------------------- bpmFromTimes (§12D tempo lane)
// the tempo lane is nothing but this over beatTimes / the gui's gridLines
p = mkPlayer.([60, 62, 64], [1, 2, 1], [0, 1, 2], [0, 1, 2]);
bt = p.beatTimes;                       // [0, 1, 3, 4] — 1s, 2s, 1s spans
bpm = MIDIItemPlayer.bpmFromTimes(bt);
assert.(bpm.size == (bt.size - 1), "bpmFromTimes: one bpm per span, got %".format(bpm.size));
assertArr.(bpm, [60, 30, 60], "bpmFromTimes: 60/(span) per adjacent pair");
// subdiv: half-beat spacing at the same performed tempo reads the same bpm
half = p.beatTimes(2);
assertArr.(MIDIItemPlayer.bpmFromTimes(half, 2).keep(2), [60, 60],
	"bpmFromTimes(subdiv): 1/2-beat gaps of the fast span still read 60 bpm");
assertClose.(MIDIItemPlayer.bpmFromTimes(half, 2)[2], 30,
	"bpmFromTimes(subdiv): the slow span reads 30 bpm at any density");
// a constant grid gives a constant lane (the flat line the eye expects)
assertArr.(MIDIItemPlayer.bpmFromTimes([0, 0.5, 1, 1.5]), [120, 120, 120],
	"bpmFromTimes: an even grid is flat");
// degenerate input: nils keep the array aligned with the spans, no division blow-up
assertArr.(MIDIItemPlayer.bpmFromTimes([0, 1, 1, 2]).at([0, 2]), [60, 60],
	"bpmFromTimes: a zero-width span doesn't disturb its neighbours");
assert.(MIDIItemPlayer.bpmFromTimes([0, 1, 1, 2])[1].isNil,
	"bpmFromTimes: a zero-width span reads nil, keeping the array span-aligned");
assert.(MIDIItemPlayer.bpmFromTimes([]) == [], "bpmFromTimes: empty times -> []");
assert.(MIDIItemPlayer.bpmFromTimes([1]) == [], "bpmFromTimes: a single time -> []");
assert.(MIDIItemPlayer.bpmFromTimes(nil) == [], "bpmFromTimes: nil times -> []");
"  (expect two more 'subdiv must be a positive number' warnings next)".postln;
assert.(MIDIItemPlayer.bpmFromTimes([0, 1, 2], 0) == [], "bpmFromTimes: subdiv 0 -> []");
assert.(MIDIItemPlayer.bpmFromTimes([0, 1, 2], -1) == [], "bpmFromTimes: negative subdiv -> []");

// a two-note selection is the minimum useful grid and still works
p = mkPlayer.([60, 62], [1, 1], [0, 1], [0, 1]);
bt = p.beatTimes;
assert.(bt.size >= 2, "beatTimes: a 2-anchor selection still yields a grid (% beats)"
	.format(bt.size));
assertClose.(bt[0], 0, "beatTimes: 2-anchor grid starts at the first anchor");
assertClose.(bt[1], 1, "beatTimes: 2-anchor grid hits the second anchor");

} { |err|
	("UNCAUGHT: " ++ err.errorString).postln;
	err.throw;
};

(h[\report].() == 0).if { 0.exit } { 1.exit };
)
