// BeatMarkMode off-beat pins: syncopated attacks pinned at fractional beats
// re-seed the extrapolated grid and interpolate the ghost lines beside them.
//
// Rhythm 1 0.5 1 2.5 0.5 1.5 -> attacks at beats 0 1 1.5 2.5 5 5.5 7, nothing on
// 2 3 4 6. The player slows from 0.5 s/beat to 0.55 s/beat after beat 1, so plain
// extrapolation from the first two picks misses the attack on beat 5.
//
// Pure language: no server, no window, no Pen.
// Run: /Applications/SuperCollider.app/Contents/MacOS/sclang standalone-tests/offbeat-pin-test.scd
(
var h = (thisProcess.nowExecutingPath.dirname +/+ "test-helpers.scd").load;
var assert = h[\assert];
var assertClose = h[\assertClose];
var assertArr = h[\assertArr];
var mkNotes, tOf, beats, notes, bm, bm2, sel, lineAt, n;

"== off-beat pin tests ==".postln;

mkNotes = { |ts| ts.collect { |t| (midicmd: \noteOn, timestamp: t, midinote: 60, amp: 0.5) } };
tOf = { |b| (b <= 1).if { 1 + (0.5 * b) } { 1.5 + (0.55 * (b - 1)) } };
beats = [0, 1, 1.5, 2.5, 5, 5.5, 7];
notes = mkNotes.(beats.collect(tOf));
// the line for integer beat b (picks are beats 0 and 1)
lineAt = { |bm, b| bm.gridLines[b - bm.lineBeat(0)] };

// ------------------------------------------------- without pins: beat 5 is lost
bm = BeatMarkMode(notes, 5);
bm.selectedIndices = [0, 1];
bm.startManual;
assert.(lineAt.(bm, 5)[\noteIndex].isNil, "no pins: the attack on beat 5 is missed (0.5 s grid drifts)");

// ------------------------------------------------- beatAtTime / on-beat refusal
assertClose.(bm.beatAtTime(tOf.(1.5)), 1.55, "beatAtTime: fraction on the live grid");
assert.(bm.beatAtTime(0.5).isNil, "beatAtTime: nil before the grid");
n = bm.offPins.size;
bm.pinOffbeat(tOf.(0) + 0.5, 2, nil);   // 1.5 s: exactly beat 1
assert.(bm.offPins.size == n, "pinOffbeat: an on-beat time is refused");

// ------------------------------------------------- first pin re-seeds the tempo
bm.pinOffbeat(tOf.(1.5), 2, 2);
assert.(bm.offPins.size == 1, "pinOffbeat: pinned");
assertClose.(bm.offPins[0][\beat], 1.5, "pinOffbeat: rounded to the 8th");
(2..7).do { |b| assertClose.(lineAt.(bm, b)[\time], tOf.(b), "one pin: line % on the slowed tempo".format(b), 1e-9) };
assert.(lineAt.(bm, 5)[\noteIndex] == 4, "one pin: beat 5 adopts its attack");
assert.(lineAt.(bm, 7)[\noteIndex] == 6, "one pin: beat 7 adopts its attack");
assert.(lineAt.(bm, 2)[\noteIndex].isNil, "one pin: beat 2 stays a ghost");

// ------------------------------------------------- second pin, rounding on the corrected grid
bm.pinOffbeat(tOf.(2.5), 2, 3);
assert.(bm.offPins.collect(_[\beat]) == [1.5, 2.5], "second pin at 2.5");
(2..7).do { |b| assertClose.(lineAt.(bm, b)[\time], tOf.(b), "two pins: line %".format(b), 1e-9) };

// ------------------------------------------------- toggle off, and back
bm.pinOffbeat(tOf.(2.5), 2, 3);
assert.(bm.offPins.collect(_[\beat]) == [1.5], "same transient again removes its pin");
bm.pinOffbeat(tOf.(2.5), 2, 3);
assert.(bm.offPins.size == 2, "and pins it again");

// ------------------------------------------------- interpolation between two pins
bm2 = BeatMarkMode(mkNotes.([1.0, 1.5, 1.775, 2.35, 3.7]), 4);
bm2.selectedIndices = [0, 1];
bm2.startManual;
bm2.pinAtBeat(1.775, 1.5, 2);
bm2.pinAtBeat(2.35, 2.5, 3);
assertClose.(lineAt.(bm2, 2)[\time], (1.775 + 2.35) / 2, "ghost between two pins sits on their straight line");

// ------------------------------------------------- save + resume
sel = bm.selectionEvent;
assert.(sel[\offPins].collect(_[\beat]) == [1.5, 2.5], "selectionEvent: off-beat pins saved");
assert.(sel[\anchors].every { |a| a[\beat].frac == 0 }, "selectionEvent: anchors stay whole beats");
assertClose.(sel[\anchors][5][\src], tOf.(5), "selectionEvent: beat 5 anchor at the attack");
bm2 = BeatMarkMode(notes, 5);
bm2.selectedIndices = sel[\indices];
assert.(bm2.resume(sel), "resume: grid back");
assert.(bm2.offPins.collect(_[\noteIndex]) == [2, 3], "resume: pins re-attached to their notes");
assertArr.(bm2.gridTimes, bm.gridTimes, "resume: same grid", 1e-9);

// ------------------------------------------------- refusals and resets
bm.pinAtBeat(1.2, 0.5, nil);
assert.(bm.offPins.size == 2, "pinAtBeat: refused among the hand picks");
bm.exitMode;
assert.(bm.offPins.isEmpty, "exitMode clears the pins");
bm.selectedIndices = [0, 1];
bm.startDP;
bm.pinAtBeat(tOf.(1.5), 1.5, 2);
assert.(bm.offPins.isEmpty, "pinAtBeat: refused in DP mode");

h[\report].();
0.exit;
)
