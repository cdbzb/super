// Record stamps vs beat-marked versions in the per-take archive
// (audio-beat-marking-plan.md step 2b).
//
// A beat-marked version (anchorSource: \beatMark) carries anchors too. Before
// isStamp, loadStamp / repinRoundTrip took the newest version with
// recordedAgainst + anchors, so a marked version that copied recordedAgainst
// would have been adopted as the take's record-time clock.
//
// Asserted:
//   * isStamp: stamp yes, legacy (no anchorSource) yes, \beatMark no, notes-only no
//   * loadStamp / recordedMap skip a newer \beatMark version
//   * repinRoundTrip re-pins the stamp, not the marks
//
// Pure language; fixtures under AudioItem.folder/_retune, removed at the end.
// Run: /Applications/SuperCollider.app/Contents/MacOS/sclang standalone-tests/take-archive-stamp-test.scd
(
var h = (thisProcess.nowExecutingPath.dirname +/+ "test-helpers.scd").load;
var assert = h[\assert];
var assertClose = h[\assertClose];
var name = "zzz-take-archive-stamp-test";
var mkAnchors, stampV, marksV, legacyV, notesV, cleanup, st, v, d;

"== TakeArchive stamp vs marks tests ==".postln;

cleanup = {
	var dir = TakeArchive.dir(name, 0);
	(dir +/+ "*.retune").pathMatch.do(File.delete(_));
	File.exists(dir).if { File.delete(dir) };
	AudioItem.recordedMaps.removeAt(name.asSymbol, 0);
};
cleanup.();

mkAnchors = { |spacing| 4.collect { |i| (key: i, src: i * spacing, beat: i) } };
stampV = (
	retuneVersion: 2, name: name, num: 0,
	anchors: mkAnchors.(1.0), anchorSource: \recordStamp,
	recordedAgainst: (when: 0, start: 0, latency: 0.2, lag: 0,
		roundTrip: 0.05, latencyConvention: \raw)
);
// the hazard: a marked version that (wrongly) copied recordedAgainst forward
marksV = (
	retuneVersion: 2, name: name, num: 0,
	anchors: mkAnchors.(0.5), anchorSource: \beatMark,
	recordedAgainst: stampV[\recordedAgainst].copy
);
legacyV = stampV.copy;
legacyV.removeAt(\anchorSource);
notesV = (retuneVersion: 2, midiEvents: []);

// ------------------------------------------------------------- isStamp
assert.(TakeArchive.isStamp(stampV), "isStamp: a \\recordStamp version");
assert.(TakeArchive.isStamp(legacyV), "isStamp: a version without anchorSource (pre-marks)");
assert.(TakeArchive.isStamp(marksV).not, "isStamp: not a \\beatMark version");
assert.(TakeArchive.isStamp(notesV).not, "isStamp: not a notes-only version");

// --------------------------------------------- old name still answers (alias)
assert.(RetuneArchive.dir(name, 0) == TakeArchive.dir(name, 0), "RetuneArchive alias: same dir");
assert.(RetuneArchive.isStamp(stampV), "RetuneArchive alias: class methods inherited");

// ------------------------------------------------------ loadStamp skips marks
TakeArchive.write(name, 0, stampV);
TakeArchive.write(name, 0, marksV);
st = TakeArchive.loadStamp(name, 0);
assert.(st.notNil, "loadStamp finds the stamp under a newer marks version");
st !? {
	assertClose.(st[\map].timeAt(2), 2.0, "loadStamp answers the stamp's anchors, not the marks'");
	assertClose.(st[\roundTrip], 0.05, "loadStamp answers the stamp's round trip");
};
AudioItem.recordedMaps.removeAt(name.asSymbol, 0);
st = AudioItem.recordedMap(name, 0);
assert.(st.notNil and: { (st[\map].timeAt(2) - 2.0).abs < 1e-6 },
	"recordedMap resolves the stamp, not the marks");

// ------------------------------------------ repinRoundTrip re-pins the stamp
v = AudioItem.repinRoundTrip(name, 0, 0.07);
d = TakeArchive.read(name, 0, v);
assert.(d[\anchorSource] == \recordStamp, "repinRoundTrip copies the stamp version");
assertClose.(d[\anchors][2][\src], 2.0, "repinRoundTrip keeps the stamp's anchors");
AudioItem.recordedMaps.removeAt(name.asSymbol, 0);
st = AudioItem.recordedMap(name, 0);
assertClose.(st[\roundTrip], 0.07, "the re-pinned round trip is what recordedMap answers");

cleanup.();
h[\report].();
0.exit;
)
