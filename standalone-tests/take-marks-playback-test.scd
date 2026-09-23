// Playback from marks (audio-beat-marking-plan.md steps 6 and 8):
// sourceTempoMap: \marks, resolved at prepare time by
// AudioItem.prResolveSourceMap, which sets the frame rules itself.
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
	var ev = (item: n, take: 0, when: at, start: 0, sourceTempoMap: \marks, type: \audioItem);
	var r = AudioItem.prResolveSourceMap(ev, n, 0);
	var f = AudioItem.prSrcOffset(r, list, at, 0);
	assert.(r[\srcLatencyIncluded] == true, "% resolve: marks include the latency".format(n));
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

// an unknown name and a missing version fall back to the default source
res = AudioItem.prResolveSourceMap((sourceTempoMap: \mine), names[1], 0);
assert.(res[\srcName] != \marks and: { res[\srcMap].notNil },
	"resolve: an unknown name warns and uses the default (the stamp)");
res = AudioItem.prResolveSourceMap((sourceTempoMap: \marks, marksVersion: 99), names[0], 0);
assert.(res[\srcName] != \marks, "resolve: a missing marks version warns and plays unmarked");
// the old key still works, with a warning
res = AudioItem.prResolveSourceMap((marks: true), names[0], 0);
assert.(res[\srcName] == \marks, "resolve: legacy marks: true reads as sourceTempoMap: \\marks");

// ------------------------------------------- addItem(sourceTempoMap: \marks)
File.mkdir(AudioItem.folder +/+ names[0]);
added = list.addItem(Take(names[0], 0), at: at, sourceTempoMap: \marks);
assert.(added.isKindOf(Array) and: { added.first[\sourceTempoMap] == \marks },
	"addItem: the event carries sourceTempoMap: \\marks (the name, not a frozen map)");
assert.(added.first[\newType] == \audioItem and: { added.first[\followTrack] == \eventList },
	"addItem: a following \\audioItem event");
res = list.addItem(Take("zzz-marks-play-none", 0), at: at, sourceTempoMap: \marks);
assert.(res.isString, "addItem: a take with no marks refuses with a warning");

cleanup.();
h[\report].();
0.exit;
)
