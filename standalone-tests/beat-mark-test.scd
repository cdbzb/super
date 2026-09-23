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
var sch, times;

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

h[\report].();
0.exit;
)
