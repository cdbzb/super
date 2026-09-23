// Playback from marks (audio-beat-marking-plan.md step 6): addItem(take, at:,
// marks:) and AudioItem.prResolveMarks, which turns `marks:` into the frame rules
// at prepare time.
//
// The acceptance math: through the resolved event, marked beat k (counted from
// `at`) reads the take at exactly anchor k's file second — for an unstamped
// take AND for a stamped one (the stamp's round trip must not be added again:
// marks are physical file positions).
//
// Pure language. Fixtures under AudioItem.folder, removed at the end.
// Run: /Applications/SuperCollider.app/Contents/MacOS/sclang standalone-tests/take-marks-playback-test.scd
(
var h = (thisProcess.nowExecutingPath.dirname +/+ "test-helpers.scd").load;
var assert = h[\assert];
var assertClose = h[\assertClose];
var names = ["zzz-marks-play-bare", "zzz-marks-play-stamped"];
var srcs = [0.73, 1.21, 1.74, 2.2, 2.71];
var at = 8, list, cleanup, check, res, added;

"== playback from marks tests ==".postln;

cleanup = {
	names.do { |n|
		[TakeArchive.dir(n, 0), AudioItem.folder +/+ n].do { |d|
			(d +/+ "*").pathMatch.do(File.delete(_));
			File.exists(d).if { File.delete(d) };
		};
		AudioItem.recordedMaps.removeAt(n.asSymbol, 0);
	}
};
cleanup.();
list = EventList.new;

names.do { |n|
	TakeArchive.writeMarks(n, 0, srcs.collect { |t, i| [t, i] }, nil);
};
// the stamped take: a record stamp (round trip 0.05) that marks must not stack on
TakeArchive.write(names[1], 0, (
	retuneVersion: 2, anchors: [(key: 0, src: 0, beat: 0), (key: 1, src: 1, beat: 1)],
	anchorSource: \recordStamp,
	recordedAgainst: (when: 0, start: 0, roundTrip: 0.05, latencyConvention: \raw)
));

check = { |n|
	var ev = (item: n, take: 0, when: at, start: 0, marks: true, newType: \audioItemTempoFollow);
	var r = AudioItem.prResolveMarks(ev, n, 0);
	var f = AudioItem.prSrcOffset(r, list, at, 0);
	assert.(r[\sourceMapIsPhysical] == true, "% resolve: physical".format(n));
	assertClose.(r[\start], srcs.first, "% resolve: start = first mark's file second".format(n));
	srcs.do { |t, k|
		assertClose.(r[\start] + f.(at + k), t,
			"% marked beat % reads file second %".format(n, k, t));
	};
	assertClose.(r[\start] + f.(at + 1.5), (srcs[1] + srcs[2]) / 2,
		"% between marks: linear".format(n));
	assertClose.(AudioItem.prSrcEndBeat(r, list, at, r[\start], srcs[3], 0), at + 3,
		"% prSrcEndBeat inverts it".format(n));
	r
};
check.(names[0]);
assert.(AudioItem.t0(names[1], 0) == 0.05, "precondition: the stamped take has t0 0.05");
check.(names[1]);

// explicit sourceTempoMap wins; no marks key is a no-op
res = AudioItem.prResolveMarks((marks: true, sourceTempoMap: \mine), names[0], 0);
assert.(res[\sourceTempoMap] == \mine, "resolve: an explicit sourceTempoMap wins");
res = (item: names[0]);
assert.(AudioItem.prResolveMarks(res, names[0], 0) === res, "resolve: no marks -> event untouched");
res = AudioItem.prResolveMarks((marks: 99), names[0], 0);
assert.(res[\sourceTempoMap].isNil, "resolve: a missing version warns and plays unmarked");

// --------------------------------------------------------- addItem(marks:)
File.mkdir(AudioItem.folder +/+ names[0]);
added = list.addItem(Take(names[0], 0), at: at, marks: true);
assert.(added.isKindOf(Array) and: { added.first[\marks] == true },
	"addItem: the event carries marks: true");
assert.(added.first[\newType] == \audioItemTempoFollow, "addItem: a tempo-follow event");
assert.(added.first[\sourceTempoMap].isNil, "addItem: the map is NOT frozen into the event");
res = list.addItem(Take("zzz-marks-play-none", 0), at: at, marks: true);
assert.(res.isString, "addItem: a take with no marks refuses with a warning");

cleanup.();
h[\report].();
0.exit;
)
