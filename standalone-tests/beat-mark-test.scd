// BeatMarkMode model changes for audio beat marking (audio-beat-marking-plan.md
// step 4): class-side click math, gridTimes including the picks, saving by
// times, free pins.
//
// Pure language: no server, no window, no Pen.
// Run: /Applications/SuperCollider.app/Contents/MacOS/sclang standalone-tests/beat-mark-test.scd
(
var h = (thisProcess.nowExecutingPath.dirname +/+ "test-helpers.scd").load;
var assert = h[\assert];
var assertClose = h[\assertClose];
var assertArr = h[\assertArr];
var sch, times, mkNotes, bm, bm2, sel, sel2, notesA, notesB;

"== BeatMarkMode tests ==".postln;

// ------------------------------------------------------ 4a. click math
times = [1.0, 1.5, 2.0, 2.6, 3.2];
assertClose.(BeatMarkMode.localPeriod(times, 1.2), 0.5, "localPeriod: span starting at/after t");
assertClose.(BeatMarkMode.localPeriod(times, 2.1), 0.6, "localPeriod: later span");
assertClose.(BeatMarkMode.localPeriod(times, 9), 0.6, "localPeriod: past the end uses the last span");
assert.(BeatMarkMode.localPeriod([1.0], 0).isNil, "localPeriod: nil with fewer than 2 times");

sch = BeatMarkMode.clickSchedule(times, 1.5);
assertClose.(sch[\offset], 0, "clickSchedule: no count-in, no offset");
assertArr.(sch[\clicks].collect(_[0]), [0, 0.5, 1.1, 1.7], "clickSchedule: grid clicks from fromTime");
assert.(sch[\clicks].every { |c| c[1].isNil }, "clickSchedule: grid clicks at default level");

sch = BeatMarkMode.clickSchedule(times, 1.5, 2);
assertClose.(sch[\offset], 1.0, "clickSchedule: count-in offset = n * local period");
assertArr.(sch[\clicks].collect(_[0]), [0, 0.5, 1.0, 1.5, 2.1, 2.7],
	"clickSchedule: count-in clicks, then the grid shifted by the offset");
assertArr.(sch[\clicks].keep(2).collect(_[1]), [0.2, 0.1], "clickSchedule: count-in accent");

sch = BeatMarkMode.clickSchedule(times, 1.5, 2, false);
assert.(sch[\clicks].size == 2, "clickSchedule: clicks: false keeps only the count-in");

sch = BeatMarkMode.clickSchedule([], 0, 4);
assert.((sch[\offset] == 0) and: { sch[\clicks].isEmpty },
	"clickSchedule: no grid, no count-in, no clicks");

// ------------------------------------------- 4b. gridTimes includes the picks
mkNotes = { |ts| ts.collect { |t| (midicmd: \noteOn, timestamp: t, midinote: 60, amp: 0.5) } };
bm = BeatMarkMode(mkNotes.([0.3, 0.8, 1.3, 1.8, 2.3, 2.8]), 3);
bm.selectedIndices = [0, 1];
bm.startManual;
assertClose.(bm.gridTimes.first, 0.3, "gridTimes (e): starts at the first pick, not the first line");
assertArr.(bm.gridTimes, [0.3, 0.8, 1.3, 1.8, 2.3, 2.8], "gridTimes (e): picks then lines");
assert.(MapEditor.mapFromTimes(bm.gridTimes).domain[0] == 0,
	"gridTimes (e): a map read off it has beat 0 at the first pick");
bm.exitMode;
bm.selectedIndices = [0, 1];
bm.startDP;
assertClose.(bm.gridTimes.first, 0.3, "gridTimes (E): the DP seed and the pick before it are included");
assert.(bm.gridTimes.differentiate.drop(1).every(_ > 0), "gridTimes (E): strictly increasing");
assert.(bm.gridTimes.size == bm.selectionEvent[\indices].size,
	"gridTimes agrees with selectionEvent on how many beats there are");

// ------------------------------------------------- nearestIndex (binary search)
bm = BeatMarkMode(mkNotes.([0.3, 0.8, 0.8, 1.3, 2.0]), 3);
assert.(bm.nearestIndex(0.85) == 1, "nearestIndex: first of a chord group");
assert.(bm.nearestIndex(1.05) == 1, "nearestIndex: midway ties go to the earlier note (chord's first)");
assert.(bm.nearestIndex(1.05, 0.1).isNil, "nearestIndex: nil beyond tol");
assert.(bm.nearestIndex(-5) == 0 and: { bm.nearestIndex(9) == 4 }, "nearestIndex: clamps at the ends");
bm2 = BeatMarkMode(mkNotes.([2.0, 0.3, 1.3]), 3);   // unsorted: linear fallback
assert.(bm2.nearestIndex(0.4) == 1, "nearestIndex: unsorted notes use the linear scan");

// ------------------------------------------ 4c. save by times, resume by times
notesA = mkNotes.([0.3, 0.8, 1.3, 1.8, 2.3, 2.8, 3.3]);
bm = BeatMarkMode(notesA, 3.5);
bm.selectedIndices = [0, 1];
bm.startManual;
sel = bm.selectionEvent;
assert.(sel[\anchors].notNil, "selectionEvent: carries \\anchors");
assertArr.(sel[\anchors].collect(_[\src]), bm.gridTimes, "anchors: src == gridTimes");
assertArr.(sel[\anchors].collect(_[\beat]), (0..bm.gridTimes.size - 1), "anchors: beats 0..n-1");
assertArr.(sel[\manualTimes], [0.3, 0.8], "selectionEvent: \\manualTimes");
// re-detect with jitter AND an extra spurious note: indices shift, times hold
notesB = mkNotes.([0.1, 0.302, 0.797, 1.05, 1.303, 1.8, 2.299, 2.8, 3.301]);
bm2 = BeatMarkMode(notesB, 3.5);
assert.(bm2.resume(sel), "resume by times: restored on re-detected notes");
assertArr.(bm2.gridTimes, [0.302, 0.797, 1.303, 1.8, 2.299, 2.8, 3.301],
	"resume by times: each anchor re-attached to the nearest new note", 1e-9);
assert.(bm2.selectedIndices.includes(3).not, "resume by times: the spurious note is not picked");
// the index-only (legacy MIDI) path still works
sel2 = sel.copy; [\anchors, \manualTimes, \freePins].do { |k| sel2.removeAt(k) };
bm2 = BeatMarkMode(notesA, 3.5);
bm2.selectedIndices = sel2[\indices].copy;
assert.(bm2.resume(sel2), "resume: legacy index-only save still restores");
assertArr.(bm2.gridTimes, bm.gridTimes, "resume: legacy save gives the same grid");

// DP save round-trips by times too
bm = BeatMarkMode(notesA, 3.5);
bm.selectedIndices = [0, 1];
bm.startDP;
sel = bm.selectionEvent;
assertClose.(sel[\seedTime], 0.8, "DP save: \\seedTime");
bm2 = BeatMarkMode(notesB, 3.5);
assert.(bm2.resume(sel) and: { bm2.dpMode }, "DP resume by times: tracker rebuilt");
assert.(bm2.gridTimes.size == bm.gridTimes.size, "DP resume by times: same number of beats");

// -------------------------------------------------- 4d. free pins (pick mode)
bm = BeatMarkMode(notesA, 3.5);
bm.selectedIndices = [0, 1];
bm.startManual;
bm.pinLine(1, 1.9);   // line 1 was at 1.8 on a note; pin it off-note
assert.(bm.gridLines[1][\pinned] == true and: { bm.gridLines[1][\noteIndex].isNil },
	"pinLine: a free pin has no note");
assertClose.(bm.gridLines[1][\time], 1.9, "pinLine: at the given time");
assertClose.(bm.gridLines[2][\time], 2.5, "pinLine: the lines after it re-extrapolate from it");
assert.(bm.gridTimes.includes(1.9), "pinLine: gridTimes includes the free pin");
sel = bm.selectionEvent;
assertArr.(sel[\freePins], [1.9], "selectionEvent: \\freePins");
bm2 = BeatMarkMode(notesA, 3.5);
assert.(bm2.resume(sel), "resume: grid with a free pin restores");
assert.(bm2.gridLines[1][\pinned] == true, "resume: the free pin survives (no note nearby)");
bm.moveLine(1, 1.81, 0.05);
assert.(bm.gridLines[1][\noteIndex] == 3, "moveLine: snaps to a note within tol (a pick)");
bm.moveLine(2, 2.55, 0.02);
assert.(bm.gridLines[2][\pinned] == true, "moveLine: nothing within tol -> free pin");
bm.unpinLine(2);
assert.(bm.gridLines[2][\pinned] != true, "unpinLine: back to an extrapolated line");
bm.exitMode; bm.selectedIndices = [0, 1]; bm.startDP;
bm.pinLine(1, 1.9);
assert.(bm.gridLines[1][\pinned] != true, "pinLine: refused in DP mode");

// ------------------------------------------ tracker: cluster sizes + salience hook
notesA = mkNotes.([0.3, 0.31, 0.32, 0.8, 1.3, 1.33, 1.8]);
bm = MIDIBeatTracker(notesA, 0.5, 0);
assertArr.(bm.prClusterSizes,
	notesA.collect { |n| notesA.count { |m| (m[\timestamp] - n[\timestamp]).abs < 0.03 } },
	"prClusterSizes: two-pointer count == pairwise count");
bm = BeatMarkMode(notesA, 2);
bm.salienceFunc = { |n| 7 };
bm.selectedIndices = [0, 3];
bm.startDP;
assert.(bm.beatTracker.saliences.every(_ == 7), "salienceFunc: handed to the DP tracker");

h[\report].();
0.exit;
)
