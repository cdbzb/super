// AudioItem take selections: the marks versions seen the way MIDIItem shows its
// selections — densely numbered from 0 (negative from the newest), identical
// saves are no-ops, and events pick one with selection: N (marksVersion:, the raw
// archive id, still works and warns once).
//
// Pure language (writes and reads fixture archives, sends nothing). Fixtures
// under AudioItem.folder, removed at the end.
// Run: /Applications/SuperCollider.app/Contents/MacOS/sclang standalone-tests/take-selection-test.scd
(
var h = (thisProcess.nowExecutingPath.dirname +/+ "test-helpers.scd").load;
var assert = h[\assert];
var assertClose = h[\assertClose];
var name = "zzz-take-selection-test";
var cleanup, sf, idA, idB, idC, before, r, list, tk;
var marksA = [[0.5, 0], [1.0, 1], [1.5, 2]];
var marksB = [[0.6, 0], [1.2, 1], [1.8, 2]];
var res = { |e| AudioItem.prResolveSourceMap(e, name, 0) };

"== take selection tests ==".postln;

cleanup = {
	[TakeArchive.dir(name, 0), AudioItem.folder +/+ name].do { |d|
		(d +/+ "*").pathMatch.do(File.delete(_));
		File.exists(d).if { File.delete(d) };
	};
};
cleanup.();
list = EventList.new; list.beatDur = 1;
File.mkdir(AudioItem.folder +/+ name);
sf = SoundFile.new.headerFormat_("WAV").sampleFormat_("float").numChannels_(1).sampleRate_(48000);
sf.openWrite(AudioItem.folder +/+ name +/+ "0.wav");
sf.writeData(Signal.fill(48000 * 3, { 0.001.rand2 })); sf.close;

// archive: stamp (0), selection A (1), a tuning snapshot (2), selection B (3)
TakeArchive.write(name, 0, (retuneVersion: 2, anchors: [(src: 0, beat: 0), (src: 0.5, beat: 1)],
	recordedAgainst: (when: 0)));
idA = TakeArchive.writeMarks(name, 0, marksA, (indices: [0, 1, 2]));
TakeArchive.write(name, 0, (retuneVersion: 2, midiEvents: []));
idB = TakeArchive.writeMarks(name, 0, marksB, nil, (edited: true));

// ------------------------------------------------------------ dense numbering
assert.((idA == 1) and: { idB == 3 }, "fixture: archive ids have a gap (got % %)".format(idA, idB));
assert.(TakeArchive.selectionIds(name, 0) == [1, 3], "selectionIds: only the marks versions");
assert.(TakeArchive.selectionId(name, 0, 0) == 1, "selection 0 -> archive id 1");
assert.(TakeArchive.selectionId(name, 0, 1) == 3, "selection 1 -> archive id 3");
assert.(TakeArchive.selectionId(name, 0, -1) == 3, "selection -1 is the newest");
assert.(TakeArchive.selectionId(name, 0, -2) == 1, "selection -2 counts back");
assert.(TakeArchive.selectionId(name, 0, nil) == 3, "nil is the newest");
assert.(TakeArchive.selectionId(name, 0, 2).isNil, "past the end: nil");
assert.(TakeArchive.selectionId(name, 0, -3).isNil, "before the start: nil");
assert.(TakeArchive.selections(name, 0).collect(_[\selectionIndex]) == [0, 1], "selections: oldest first, numbered");
assert.(TakeArchive.loadMarks(name, 0)[\selectionIndex] == 1, "loadMarks: newest carries its selection number");
assert.(TakeArchive.loadMarks(name, 0, 1)[\selectionIndex] == 0, "loadMarks(id): its selection number");

// ------------------------------------------------------------ identical saves are no-ops
before = TakeArchive.versionIds(name, 0).size;
assert.(TakeArchive.writeMarks(name, 0, marksB, nil, (edited: true)) == idB, "identical save: answers the newest id");
assert.(TakeArchive.versionIds(name, 0).size == before, "identical save: nothing written");
assert.(TakeArchive.writeMarks(name, 0, marksB, nil, (edited: false)) != idB, "different extra: a new selection");
idC = TakeArchive.writeMarks(name, 0, marksA, (indices: [0, 1, 2]));
assert.(TakeArchive.selectionIds(name, 0).size == 4, "a re-save of an older selection is new (only the newest dedupes)");
assert.(TakeArchive.writeMarks(name, 0, marksA, (indices: [0, 1, 2])) == idC,
	"identical save with a selection Event: no-op (survives the archive round trip)");

// ------------------------------------------------------------ event keys
assert.(AudioItem.timingKeys.includes(\selection), "selection: is a timing key (routes to follow)");
assert.(AudioItem.marksVersionOf((selection: 0), name, 0) == 1, "selection: 0 -> archive id 1");
assert.(AudioItem.marksVersionOf((selection: -1), name, 0) == idC, "selection: -1 -> the newest");
assert.(AudioItem.marksVersionOf((selection: 9), name, 0) == -1, "missing selection: -1 (absent, warned)");
assert.(TakeArchive.loadMarks(name, 0, -1).isNil, "-1 loads nothing (no silent fallback to the newest)");
assert.(AudioItem.marksVersionOf((marksVersion: 3), name, 0) == 3, "marksVersion: still the archive id");
assert.(AudioItem.marksVersionOf((selection: 0, marksVersion: 3), name, 0) == 1, "selection: wins over marksVersion:");
assert.(AudioItem.marksVersionOf((), name, 0).isNil, "neither: nil = the newest");
assert.(AudioItem.marksVersionOf((srcResolved: true, marksVersion: 7, selection: 0), name, 0) == 7,
	"a resolved event keeps its id");

r = res.((item: name, followTrack: \selection, selection: 0));
assert.(r[\srcName] == \marks and: { r[\marksVersion] == 1 }, "resolve: followTrack: \\selection + selection: 0");
assertClose.(r[\srcMap].timeAt(r[\srcMap].beatDomain.first + 1) - r[\srcMap].timeAt(r[\srcMap].beatDomain.first),
	0.5, "resolve: selection 0's spacing (0.5 s), not the newest's");
r = res.((item: name, followTrack: \auto, selection: 1));
assert.(r[\srcName] == \marks and: { r[\marksVersion] == 3 }, "resolve: \\auto honours selection:");
r = res.((item: name, followTrack: \selection, selection: 9));
assert.(r[\srcName] == \stamp, "resolve: a missing selection falls through to the stamp (warned), never the newest silently");

// ------------------------------------------------------------ addItem guard
assert.(list.prAddAudioItem((name: name, num: 0), 0, nil, nil, nil, [\followTrack, \selection, \selection, 9]).isString,
	"addItem: refuses a selection the take lacks");
// a Take without Take.new (which would Buffer.read on the server)
tk = Take.newCopyArgs; tk.name = name; tk.num = 0;
assert.(tk.selection(0) === tk and: { tk.selectionIndex == 0 }, "Take.selection(n): chainable, sets the index");
assert.(tk.selections.size == 4, "Take.selections: the data");
assert.(tk.prSelectionId == 1, "Take: chosen selection -> archive id");
tk.selection(7);
assert.(tk.selectionIndex.isNil, "Take.selection: a missing one clears the choice (posted)");
tk.selection(0);
list.prAddAudioItem(tk, 0, nil, nil, nil, [\followTrack, \selection]);
assert.(list.events.any { |e| (e[\item] == name) and: { e[\selection] == 0 } },
	"addItem: the take's chosen selection rides on the event");

cleanup.();
h[\report].();
0.exit;
)
