// Keyboard nudging in the Take window: BeatMarkMode.nudgeLine (a grid line,
// local, as a free pin) and TakeTransients' hand edits (applyEdits / recordMove
// / recordDelete / recordAdd), plus the edits file round trip.
//
// Pure language apart from one fixture dir under TakeTransients.folder,
// removed at the end. No server, no window.
// Run: /Applications/SuperCollider.app/Contents/MacOS/sclang standalone-tests/nudge-test.scd
(
var h = (thisProcess.nowExecutingPath.dirname +/+ "test-helpers.scd").load;
var assert = h[\assert];
var assertClose = h[\assertClose];
var assertArr = h[\assertArr];
var name = "zzz-nudge-test";
var notes, bm, before, sel, bm2, raw, ed, out, ev, cleanup;

"== Nudge tests ==".postln;

cleanup = {
	var dir = TakeTransients.dir(name, 0);
	(dir +/+ "*").pathMatch.do(File.delete(_));
	File.exists(dir).if { File.delete(dir) };
};
cleanup.();

// ------------------------------------------------ BeatMarkMode.nudgeLine
notes = [1.0, 1.5, 2.0, 2.5, 3.0, 3.5].collect { |t| (timestamp: t, strength: 1) };
bm = BeatMarkMode(notes, 4.0);
bm.selectedIndices = [0, 1];
bm.startManual;
before = bm.gridLines.collect(_[\time]);
bm.nudgeLine(0.004);
assertClose.(bm.gridLines[0][\time], 2.004, "nudgeLine: current line moves by delta");
assert.(bm.gridLines[0][\pinned] == true and: { bm.gridLines[0][\noteIndex].isNil },
	"nudgeLine: the line becomes a free pin");
assertArr.(bm.gridLines.drop(1).collect(_[\time]), before.drop(1), "nudgeLine: later lines stay put");
assert.(bm.selectedIndices.includes(2).not, "nudgeLine: the line's old note leaves the selection");
bm.nudgeLine(10);
assertClose.(bm.gridLines[0][\time], 2.499, "nudgeLine: clamped 1 ms before the next line");
bm.nudgeLine(-10);
assertClose.(bm.gridLines[0][\time], 1.501, "nudgeLine: clamped 1 ms after the last pick");
bm.keyDown($]);
assertClose.(bm.gridLines[0][\time], 1.502, "keyDown ']': default fine step 1 ms");
bm.nudgeStep = { |coarse| coarse.if(0.05, 0.005) };
bm.keyDown(${);
assertClose.(bm.gridLines[0][\time], 1.501, "keyDown '{': host step, still clamped");
bm.nextLine; bm.keyDown($});
assertClose.(bm.gridLines[1][\time], 2.55, "keyDown '}': coarse host step on the current line");

// survives save + resume (time-based anchors keep free pins where they were)
sel = bm.selectionEvent;
bm2 = BeatMarkMode(notes, 4.0);
bm2.selectedIndices = sel[\indices];
assert.(bm2.resume(sel), "resume: grid back");
assertClose.(bm2.gridLines[1][\time], 2.55, "resume: nudged line where it was nudged");
assert.(bm2.gridLines[1][\pinned] == true, "resume: still a free pin");

// refused outside pick-mode grid lines
bm.prevLine; bm.prevLine;    // onto a hand pick
before = bm.lineTime(bm.currentLine);
bm.nudgeLine(0.01);
assertClose.(bm.lineTime(bm.currentLine), before, "nudgeLine: hand picks are left alone");
bm = BeatMarkMode(notes, 4.0);
bm.selectedIndices = [0, 1];
bm.startDP;
before = bm.gridLines[0][\time];
bm.nudgeLine(0.01);
assertClose.(bm.gridLines[0][\time], before, "nudgeLine: refused in DP mode");
bm = BeatMarkMode(notes, 4.0);
assert.(bm.keyDown($]).not, "keyDown: ']' not consumed without a grid (the host's)");

// ------------------------------------------------ transient hand edits
raw = [0.5, 1.0, 1.5, 2.0].collect { |t, i| (timestamp: t, amp: 0.5, strength: i + 1) };
out = TakeTransients.applyEdits(raw, []);
assertArr.(out.collect(_[\timestamp]), [0.5, 1.0, 1.5, 2.0], "applyEdits: no edits, same times");
assertArr.(out.collect(_[\detected]), [0.5, 1.0, 1.5, 2.0], "applyEdits: \\detected on every event");
assert.(out[0] !== raw[0] and: { raw[0][\detected].isNil }, "applyEdits: raw events untouched");

ed = TakeTransients.recordMove([], out[1], 1.01);
out[1][\timestamp] = 1.01;
ed = TakeTransients.recordMove(ed, out[1], 1.02);
assert.(ed.size == 1, "recordMove: a run of nudges is one edit (got %)".format(ed.size));
assertClose.(ed[0][\to], 1.02, "recordMove: latest target kept");
ed = TakeTransients.recordDelete(ed, out[2]);
ed = TakeTransients.recordAdd(ed, 1.75);
out = TakeTransients.applyEdits(raw, ed);
assertArr.(out.collect(_[\timestamp]), [0.5, 1.02, 1.75, 2.0], "applyEdits: move, delete, add");
assert.(out[1][\edited] == true and: { out[0][\edited].isNil }, "applyEdits: moved one marked \\edited");
assert.(out[2][\added] == true, "applyEdits: added one marked \\added");
assertClose.(out[2][\strength], 3, "addedEvent: median strength");

// re-detection drifts a few ms: edits still land
out = TakeTransients.applyEdits(raw.collect { |e| e.copy.put(\timestamp, e[\timestamp] + 0.003) }, ed);
assertArr.(out.collect(_[\timestamp]), [0.503, 1.02, 1.75, 2.003], "applyEdits: re-attach within editTol");

// moving an added hit edits its \add; deleting it drops the \add
out = TakeTransients.applyEdits(raw, ed);
ev = out[2];
ed = TakeTransients.recordMove(ed, ev, 1.8);
assert.(ed.count { |e| e[\op] == \add } == 1, "recordMove on an added hit: still one \\add");
assertClose.(TakeTransients.applyEdits(raw, ed)[2][\timestamp], 1.8, "recordMove on an added hit: moved");
ev[\timestamp] = 1.8;
ed = TakeTransients.recordDelete(ed, ev);
assert.(ed.count { |e| e[\op] == \add } == 0, "recordDelete on an added hit: \\add gone");
// moving back to where it was detected clears the edit
out = TakeTransients.applyEdits(raw, ed);
ed = TakeTransients.recordMove(ed, out[1], 1.0);
assert.(ed.count { |e| e[\op] == \move } == 0, "recordMove back home: no edit left");

// file round trip
TakeTransients.writeEdits(name, 0, [(op: \add, at: 1.25)]);
assert.(TakeTransients.loadEdits(name, 0)[0][\at] == 1.25, "writeEdits / loadEdits round trip");
assert.(TakeTransients.loadEdits(name, 1) == [], "loadEdits: none -> []");

cleanup.();
(h[\report].() == 0).if { 0.exit } { 1.exit };
)
