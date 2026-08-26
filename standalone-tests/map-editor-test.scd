// Headless regression suite for the §12c step 5 extraction
// (quantize-tempomap-project.md): BeatMarkMode + MapEditor, the two controllers
// lifted out of the monolithic AbstractMidiEvents.gui. Pure language — no
// server, no window, no Pen: everything below is model, which is exactly the
// property the extraction was for.
// Run: /Applications/SuperCollider.app/Contents/MacOS/sclang standalone-tests/map-editor-test.scd
//
// Fixture convention (as in beat-times-test.scd): [midinote:..., dur:...]
// .asMIDIItem stamps timestamps in BEATS, read here as seconds.
(
var h = (thisProcess.nowExecutingPath.dirname +/+ "test-helpers.scd").load;
var assert = h[\assert];
var assertClose = { |a, b, msg, tol = 1e-6| h[\assertClose].(a, b, msg, tol) };
var assertArr = { |a, b, msg, tol = 1e-6| h[\assertArr].(a, b, msg, tol) };
var mkNotes, bm, bm2, sel, saved, changes, gridChanges, seen;
var me, src, times, m, before, auditioned, committed;

"== BeatMarkMode / MapEditor (§12c step 5) tests ==".postln;

// six notes one second apart, the simplest thing a beat grid can be built on
mkNotes = { |n = 6|
	[midinote: Array.fill(n, { |i| 60 + i }), dur: Array.fill(n, 1)]
		.asMIDIItem.player.notes
};

try {

// ---------------------------------------------------------- BeatMarkMode: 'e'
bm = BeatMarkMode(mkNotes.(), 6);
assert.(bm.extrapolateMode.not, "fresh: not in extrapolate mode");
assert.(bm.gridTimes.isNil, "fresh: no grid times (nothing for the clicks to use)");
assert.(bm.selectionEvent.isNil, "fresh: nothing selected -> no selection Event");

bm.selectedIndices = [0, 1];
bm.startManual;
assert.(bm.extrapolateMode, "'e': extrapolate mode on");
assert.(bm.dpMode.not, "'e': not the DP tracker");
assertArr.(bm.anchorPair, [0, 1], "'e': anchor pair is the last two picks' times");
assert.(bm.gridLines.size >= 4, "'e': grid extrapolated forward (% lines)"
	.format(bm.gridLines.size));
assertArr.(bm.gridLines.keep(4).collect(_[\time]), [2, 3, 4, 5],
	"'e': lines land one beat apart from the pair");
assertArr.(bm.gridLines.keep(4).collect(_[\noteIndex]), [2, 3, 4, 5],
	"'e': each line adopts the note under it");
assertArr.(bm.selectedIndices.copy.sort, [0, 1, 2, 3, 4, 5],
	"'e': the selection is the hand picks plus every adopted note");
assertArr.(bm.gridTimes.keep(4), [2, 3, 4, 5], "'e': gridTimes is the click source");

// ------------------------------------------------- BeatMarkMode: the 'w' payload
sel = bm.selectionEvent;
assertArr.(sel[\indices], [0, 1, 2, 3, 4, 5], "selectionEvent: indices in time order");
assertArr.(sel[\beats], [1, 1, 1, 1, 1], "selectionEvent: one beat per gap");
assertClose.(sel[\periodPrior], 1, "selectionEvent: periodPrior is the anchor gap");
assertArr.(sel[\manual], [0, 1], "selectionEvent: \\manual is the hand-picked partition");
assertClose.(sel[\contentStart], 0,
	"selectionEvent: content start defaults to the first selected note");
assert.(sel[\anchor].isNil, "selectionEvent: no DP anchor on a manual save");
sel = bm.selectionEvent(2.5);
assertClose.(sel[\contentStart], 2.5, "selectionEvent: an explicit content start wins");

// onSave gets the Event, and an empty selection saves nothing
saved = nil;
bm.onSave = { |s| saved = s };
assert.(bm.save.notNil, "save: answers the Event it persisted");
assert.(saved.notNil and: { saved[\indices].size == 6 }, "save: onSave hook got the Event");
bm2 = BeatMarkMode(mkNotes.(), 6);
saved = nil;
bm2.onSave = { |s| saved = s };
assert.(bm2.save.isNil, "save: nothing selected -> nil");
assert.(saved.isNil, "save: nothing selected -> the hook is not called");

// ----------------------------------------------- BeatMarkMode: resume (manual)
bm2 = BeatMarkMode(mkNotes.(), 6);
bm2.selectedIndices = bm.selectionEvent[\indices].copy;
assert.(bm2.resume(bm.selectionEvent), "resume: a manual save rebuilds a grid");
assert.(bm2.extrapolateMode, "resume: extrapolate mode back on");
assert.(bm2.dpMode.not, "resume: a manual save resumes manual, not DP");
assertArr.(bm2.selectedIndices.copy.sort, [0, 1, 2, 3, 4, 5],
	"resume: the selection comes back whole");
assertArr.(bm2.manualIndices, [0, 1], "resume: \\manual is honoured verbatim");
assert.(bm2.resume(nil).not, "resume: nil selection -> false");
assert.(bm2.resume((indices: [0, 1])).not, "resume: no periodPrior -> false (nothing to rebuild)");

// ---------------------------------------------------- BeatMarkMode: 'E' and DP
bm = BeatMarkMode(mkNotes.(), 6);
bm.selectedIndices = [0, 1];
bm.startDP;
assert.(bm.extrapolateMode and: { bm.dpMode }, "'E': DP mode on");
assert.(bm.beatTracker.notNil, "'E': a tracker was built");
assert.(bm.gridLines.size > 0, "'E': the DP found beats (% lines)".format(bm.gridLines.size));
sel = bm.selectionEvent;
assert.(sel[\anchor] == 1, "'E': the save carries the DP anchor");
assertArr.(sel[\pins], [], "'E': no pins yet");
bm2 = BeatMarkMode(mkNotes.(), 6);
bm2.selectedIndices = sel[\indices].copy;
assert.(bm2.resume(sel), "resume: a DP save rebuilds the tracker");
assert.(bm2.dpMode, "resume: DP save resumes in DP mode");
assertArr.(bm2.gridLines.collect(_[\time]), bm.gridLines.collect(_[\time]),
	"resume: the DP is deterministic — the saved grid reappears exactly");

// ----------------------------------------------- BeatMarkMode: keys + hooks
bm = BeatMarkMode(mkNotes.(), 6);
changes = 0; gridChanges = 0; seen = [];
bm.onChange = { changes = changes + 1 };
bm.onGridChange = { gridChanges = gridChanges + 1 };
bm.ensureVisible = { |t| seen = seen.add(t) };
assert.(bm.keyDown($h).not, "keys: h is the host's scroll while no grid is up");
assert.(bm.keyDown($j).not, "keys: j is the host's take switch while no grid is up");
assert.(bm.keyDown($z).not, "keys: an unowned key is never consumed");
bm.selectedIndices = [0, 1];
assert.(bm.keyDown($e), "keys: e is always consumed");
assert.(bm.extrapolateMode, "keys: e turned the mode on");
assert.(gridChanges > 0, "hooks: onGridChange fired when the grid was built");
assert.(seen.size > 0, "hooks: ensureVisible was asked to show the first line");
gridChanges = 0; changes = 0;
assert.(bm.keyDown($h), "keys: h is line navigation while a grid is up");
assert.(changes == 1, "hooks: navigation fires onChange only (cheap redraw)");
assert.(gridChanges == 0, "hooks: navigation does NOT invalidate the derived caches");
assert.(bm.keyDown($k), "keys: k re-picks while a grid is up");
assert.(gridChanges > 0, "hooks: a re-pick DOES invalidate (the beat grid moved)");
assert.(bm.keyDown($e), "keys: e again is consumed");
assert.(bm.extrapolateMode.not, "keys: e toggled the mode off");
assert.(bm.gridTimes.isNil, "keys: no grid -> no click source");
assert.(bm.keyDown($h).not, "keys: h is the host's again once the mode is off");

// too few picks is refused, not crashed
bm = BeatMarkMode(mkNotes.(), 6);
bm.selectedIndices = [0];
"  (expect a 'needs at least 2 selected notes' post next)".postln;
bm.startManual;
assert.(bm.extrapolateMode.not, "'e' with one note: refused, mode stays off");

// clear
bm = BeatMarkMode(mkNotes.(), 6);
bm.selectedIndices = [0, 1];
bm.startDP;
bm.clear;
assert.(bm.selectedIndices.isEmpty and: { bm.extrapolateMode.not }
	and: { bm.dpMode.not } and: { bm.gridLines.isEmpty } and: { bm.pinSet.isNil },
	"clear: every marking-mode variable is back to fresh");

// ------------------------------------------------------ MapEditor: the model
assert.(MapEditor.mapFromTimes([1]).isNil, "mapFromTimes: one time is not a map");
assert.(MapEditor.mapFromTimes([0, 1, 1]).isNil, "mapFromTimes: a zero gap is not a map");
assert.(MapEditor.mapFromTimes([0, 1, 0.5]).isNil, "mapFromTimes: a backwards gap is not a map");
m = MapEditor.mapFromTimes([0, 1, 2, 4], 1);
assert.(m.isKindOf(AnchorMap), "mapFromTimes: a valid grid answers an AnchorMap");
assertArr.(m.xs, [0, 1, 2, 3], "mapFromTimes: xs are beat numbers");
assert.(m.mapsDimensions(\beat, \sec),
	"mapFromTimes: beat -> sec, so setSpanTempo is legal on it");
// subdiv is beatTimes' own meaning: how many entries make ONE beat, so entry i
// sits at beat i/subdiv (a half-beat grid over two beats, here)
m = MapEditor.mapFromTimes([0, 0.5, 1], 2);
assertArr.(m.xs, [0, 0.5, 1], "mapFromTimes: subdiv 2 -> entry i is beat i/2");

// times = 0 1 2 4 5 6 : five beats, one of them (beat 2->3) twice as slow
times = [0, 1, 2, 4, 5, 6];
me = MapEditor.new;
me.sourceFunc = { [times, 1] };
assertArr.(me.times, times, "source: the lane reads the host's grid");
assertArr.(me.laneData[\bpms], [60, 60, 30, 60, 60], "laneData: bpm per beat span");
assertClose.(me.laneData[\mean], 54, "laneData: mean bpm over the whole grid");
assert.(me.hasLane, "laneData: a five-span grid has a lane");
assertArr.(me.spanRange, [0, 5], "span: defaults to the whole domain");
assertClose.(me.spanBpm, 50, "span: whole-map mean slope = 50 bpm (5 beats in 6 s)");
assert.(me.edited.not, "fresh: not edited");

// an empty source is not a lane and not editable, but must not throw
m = MapEditor.new;
m.sourceFunc = { [[], 1] };
assert.(m.map.isNil, "empty source: no map");
assert.(m.hasLane.not, "empty source: no lane");
assert.(m.spanRange.isNil, "empty source: no span");
"  (expect four 'no editable tempo map' posts next)".postln;
m.quantizeSpan(1); m.stretchSpan(2); m.setSpanBpm(120); m.auditionSpan;
assert.(m.map.isNil and: { m.edited.not }, "empty source: every edit is refused, nothing breaks");

// ----------------------------------------------------- MapEditor: whole-map edit
me.quantizeSpan(1);
assert.(me.edited, "quantize: the editor is now dirty");
assertArr.(me.times, [0, 1.2, 2.4, 3.6, 4.8, 6],
	"quantize(1) over the whole map: one constant tempo, both ends pinned");
assertArr.(me.laneData[\bpms], [50, 50, 50, 50, 50], "quantize: the lane is flat afterwards");
assert.(me.laneData[\times] === me.times, "laneData: rebuilt off the edited map");

// an invalidate must NOT silently drop the edit
me.invalidate;
assertArr.(me.times, [0, 1.2, 2.4, 3.6, 4.8, 6],
	"invalidate: an EDITED map outranks a cheaper re-read");
me.undo;
assertArr.(me.times, times, "undo: back to the map as loaded");
me.redo;
assertArr.(me.times, [0, 1.2, 2.4, 3.6, 4.8, 6], "redo: forward again");
me.revert;
assertArr.(me.times, times, "revert: back to the loaded map");
me.undo;
assertArr.(me.times, [0, 1.2, 2.4, 3.6, 4.8, 6], "revert is itself undoable");
me.reload;
assertArr.(me.times, times, "reload: the explicit way to throw the edits away");
assert.(me.edited.not, "reload: clean again");

// --------------------------------------------------------- MapEditor: span edits
// the whole point of §12b A: touch beats 2..3 and nothing before it moves
me.reload;
me.selectSpan(2, 3);
assertArr.(me.spanRange, [2, 3], "selectSpan: the edited region");
assertClose.(me.spanBpm, 30, "selectSpan: that span really is the slow one");
me.setSpanBpm(60);
assertClose.(me.timeAt(0), 0, "setSpanBpm: nothing before the span moves (beat 0)");
assertClose.(me.timeAt(1), 1, "setSpanBpm: nothing before the span moves (beat 1)");
assertClose.(me.timeAt(2), 2, "setSpanBpm: the span's start is where it was");
assertClose.(me.timeAt(3), 3, "setSpanBpm: one beat now takes one second");
assertClose.(me.timeAt(4), 4, "setSpanBpm: later material RIPPLES back by the delta");
assertClose.(me.timeAt(5), 5, "setSpanBpm: ...keeping its own shape");
assertArr.(me.laneData[\bpms], [60, 60, 60, 60, 60], "setSpanBpm: the sag is gone");

me.reload;
me.selectSpan(2, 3);
me.stretchSpan(2);
assertClose.(me.timeAt(2), 2, "stretchSpan: the span's start is fixed");
assertClose.(me.timeAt(3), 6, "stretchSpan: x2 doubles the span's performed width");
assertClose.(me.timeAt(5), 8, "stretchSpan: everything after shifts by the delta");

me.reload;
me.selectSpan(1, 4);
me.quantizeSpan(1);
assertClose.(me.timeAt(0), 0, "quantizeSpan: outside the span, untouched");
assertClose.(me.timeAt(1), 1, "quantizeSpan: the span's start is fixed");
assertClose.(me.timeAt(2), 1 + (4/3), "quantizeSpan: the span is straightened");
assertClose.(me.timeAt(4), 5, "quantizeSpan: the span's end is fixed too");
assertClose.(me.timeAt(5), 6, "quantizeSpan: no ripple — the span's width did not change");

// input width is a LABEL and must survive: a transform that changes it is refused
me.reload;
me.selectSpan(1, 4);
"  (expect one 'refused' post next)".postln;
me.applyToSpan({ |cell| AnchorMap([0, 1], [cell.ys.first, cell.ys.last]) }, "bad width");
assertArr.(me.times, times, "a transform that relabels the beats is refused, map unchanged");
assert.(me.edited.not, "...and the refusal does not mark the editor dirty");

// --------------------------------------------------- MapEditor: audition + commit
me.reload;
me.selectSpan(1, 4);
auditioned = nil;
me.audition = { |t| auditioned = t };
me.auditionSpan;
assertArr.(auditioned, [1, 2, 4, 5], "audition: the whole beats of the span, off the MAP");
// setSpanBpm sets the span's MEAN tempo and preserves the shape inside it
// (§12b A: setSpanSlope), so beats 2 and 3 stay unevenly placed — they just fit
// into 3 s instead of 4. The audition clicks the candidate, before any commit.
me.setSpanBpm(60);
me.auditionSpan;
assertArr.(auditioned, [1, 1.75, 3.25, 4],
	"audition: through the CANDIDATE map — mean tempo set, inner shape kept");

committed = nil;
MapEditor.last = nil;
me.onSave = { |mm| committed = mm };
me.commit;
assert.(committed.notNil, "commit: the onSave hook got the map");
assert.(MapEditor.last === committed, "commit: MapEditor.last is the same map");
assert.(committed.isKindOf(AnchorMap), "commit: a plain AnchorMap, for warpTo / sourceTempoMap:");
assert.(committed.mapsDimensions(\beat, \sec), "commit: beat -> absolute take seconds");
assert.(me.edited, "commit: still dirty, so the next invalidate cannot undo the commit");

// ------------------------------------------------------------ MapEditor: keys
me = MapEditor.new;
me.sourceFunc = { [times, 1] };
assert.(me.keyDown($Q, 0).not, "keys: the edit keys are inert until map-edit mode is on");
assert.(me.keyDown($u, 0).not, "keys: ...including undo");
assert.(me.keyDown($m, 0), "keys: m is always consumed");
assert.(me.editing, "keys: m turned map-edit mode on");
assert.(me.keyDown($Q, 0), "keys: Q straightens the span while editing");
assert.(me.edited, "keys: ...and it really edited the map");
assert.(me.keyDown($u, 0), "keys: u undoes");
assertArr.(me.times, times, "keys: undo put the loaded map back");
assert.(me.keyDown($z, 0).not, "keys: an unowned key falls through to the host");
assert.(me.keyDown($h, 0).not, "keys: the host's scroll is never shadowed");
assert.(me.keyDown($e, 0).not, "keys: the beat-mark keys are never shadowed");
me.keyDown($m, 0);
assert.(me.editing.not, "keys: m toggles back off");

// span picking from a cursor TIME (the 'i'/'o' keys)
me.reload;
me.keyDown($m, 0);
me.keyDown($i, 2);   // cursor at 2 s == beat 2
me.keyDown($o, 4);   // cursor at 4 s == beat 3
assertArr.(me.spanRange, [2, 3], "keys: i/o pick the span by cursor time");
me.keyDown($A, 0);
assertArr.(me.spanRange, [0, 5], "keys: A selects the whole map again");
// a cursor outside the map clips into the domain rather than extrapolating
me.keyDown($i, -100);
assertClose.(me.spanRange[0], 0, "beatAt: a cursor in the junk intro clips to beat 0");

// the lane strip is only live in map-edit mode, and only inside its own y band
me = MapEditor.new;
me.sourceFunc = { [times, 1] };
assert.(me.editing.not, "mouse: a fresh editor is not in map-edit mode");
assert.(me.mouseDown(10, 80, 0, 6, 1400).not, "mouse: the lane is inert with the mode off");
me.keyDown($m, 0);
assert.(me.editing, "mouse: map-edit mode on");
assert.(me.mouseDown(10, 200, 0, 6, 1400).not, "mouse: a click below the strip is the host's");
assert.(me.mouseDown(0, 80, 0, 6, 1400), "mouse: a click inside the strip starts a drag");
me.mouseMove(1400, 80, 0, 6, 1400);
me.mouseUp;
assertArr.(me.spanRange, [0, 5], "mouse: dragging the strip's width selects the whole grid");

// -------------------------------------------- the gui's wiring, minus the window
// AbstractMidiEvents.gui composes exactly this: one beat source, consulted live
// grid FIRST and loaded selection second, feeding both the click schedule
// (clickTimes) and the tempo lane (MapEditor.sourceFunc). Reproduced here so the
// composition is covered even though the window itself cannot be opened headless.
src = [midinote: [60, 62, 64, 65, 67, 69], dur: [1, 1, 2, 1, 1, 1]].asMIDIItem.player;
src.markSelection([0, 1, 2, 3, 4, 5], [0, 1, 2, 3, 4, 5]);
before = src.notes;                                   // hold: .notes deep-copies
bm = BeatMarkMode(before, before.last.timestamp + 1);
me = MapEditor.new;
// the gui's laneSource, verbatim in shape
me.sourceFunc = { var t = bm.gridTimes; t.isNil.if { t = src.beatTimes }; [t, 1] };
// the gui's clickTimes, verbatim in shape
seen = { bm.gridTimes ?? { src.beatTimes } };

assert.(src.beatTimes.size > 2, "gui wiring: the fixture selection has a beat grid");
assertArr.(me.times, src.beatTimes,
	"gui wiring: with no live grid the lane reads the selection's tempomap");
assertArr.(seen.value, src.beatTimes,
	"gui wiring: ...and so do the clicks — one source, two consumers");
assertArr.(me.laneData[\bpms], MIDIItemPlayer.bpmFromTimes(src.beatTimes, 1),
	"gui wiring: the lane's bpms are bpmFromTimes over that grid");

// mark beats live: what the eye sees now outranks what the selection remembers
bm.selectedIndices = [0, 1];
bm.startManual;
bm.onGridChange = { me.invalidate };   // the gui's invalidateLane hook
bm.keyDown($j);                        // a re-pick fires it
assert.(bm.gridTimes.notNil, "gui wiring: a live grid exists after 'e'");
assertArr.(me.times, bm.gridTimes,
	"gui wiring: the live e/E grid outranks the saved selection for the lane");
assertArr.(seen.value, bm.gridTimes, "gui wiring: ...and for the clicks");

// and an edited map still survives the beat source moving under it
me.quantizeSpan(1);
m = me.times.copy;
bm.keyDown($j);
assertArr.(me.times, m, "gui wiring: a re-pick does not silently discard an edited map");

} { |err|
	("UNCAUGHT: " ++ err.errorString).postln;
	err.throw;
};

(h[\report].() == 0).if { 0.exit } { 1.exit };
)
