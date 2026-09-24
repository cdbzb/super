// Fixing a sloppy take recorded against a list (audio-beat-marking-plan.md
// step 11): seed the grid from the record stamp, keep edits local, save marks on
// the stamp's beat axis, keep each map's first beat through the resolver, and
// place a stamped take where it was recorded (addItem with no at:).
//
// Fixture stamp: 0.5 s per beat from the record event's fire beat (list beat
// 16), round trip 0.05 — so stamp beat k sits at file second 0.05 + 0.5 k.
//
// Pure language. Fixtures under AudioItem.folder, removed at the end.
// Run: /Applications/SuperCollider.app/Contents/MacOS/sclang standalone-tests/stamped-take-test.scd
(
var h = (thisProcess.nowExecutingPath.dirname +/+ "test-helpers.scd").load;
var assert = h[\assert];
var assertClose = h[\assertClose];
var assertArr = h[\assertArr];
var name = "zzz-stamped-take", bare = "zzz-stamped-bare";
var lat = 0.05, spb = 0.5, recWhen = 16;
var expected, played, notes, bm, bm2, sel, pairs, res, list, ev, r, f, added, sf, sig;

"== stamped take tests ==".postln;

~cleanup = {
	[name, bare].do { |n|
		[TakeArchive.dir(n, 0), AudioItem.folder +/+ n].do { |d|
			(d +/+ "*").pathMatch.do(File.delete(_));
			File.exists(d).if { File.delete(d) };
		};
		AudioItem.recordedMaps.removeAt(n.asSymbol, 0);
	}
};
~cleanup.();
TakeArchive.write(name, 0, (
	retuneVersion: 2,
	anchors: 9.collect { |k| (key: k, src: k * spb, beat: k) },
	anchorSource: \recordStamp,
	recordedAgainst: (when: recWhen, start: 0, roundTrip: lat, latencyConvention: \raw)
));
[name, bare].do { |n|
	File.mkdir(AudioItem.folder +/+ n);
	sig = Signal.fill(48000 * 5, { 0.001.rand2 });
	sf = SoundFile.new.headerFormat_("WAV").sampleFormat_("float").numChannels_(1).sampleRate_(48000);
	sf.openWrite(AudioItem.folder +/+ n +/+ "0.wav"); sf.writeData(sig); sf.close;
};
list = EventList.new; list.beatDur = 1;

// ------------------------------------------------------ stampBeatAt / stampWhen
assertClose.(AudioItem.stampBeatAt(name, 0, lat + (2 * spb)), 2, "stampBeatAt: file second -> stamp beat");
assert.(AudioItem.stampBeatAt(bare, 0, 1).isNil, "stampBeatAt: nil when unstamped");
assert.(AudioItem.stampWhen(name, 0) == recWhen, "stampWhen: the record event's list beat");

// ----------------------------------------------------------- seedLines
// expected beats 1..6; the playing is sloppy (+-30 ms) and beat 4 has no hit
expected = (1..6).collect { |k| lat + (k * spb) };
played = [0.02, -0.03, 0.025, nil, -0.02, 0.03];
notes = expected.collect { |t, i| played[i] !? { |d| (timestamp: t + d, strength: 1) } }.reject(_.isNil);
bm = BeatMarkMode(notes, 4);
assert.(bm.seedLines(expected), "seedLines: a grid came up");
assert.(bm.localEdits and: { bm.dpMode.not }, "seedLines: pick mode, local edits");
assertArr.(bm.gridTimes, expected.collect { |t, i| t + (played[i] ? 0) },
	"seedLines: each beat snapped to its hit; the missing one stays at the stamp", 1e-9);
bm.moveLine(0, expected[2] + 0.06, nil);   // line 0 = beat 3 (beats 1-2 are the picks)
assertClose.(bm.gridLines[1][\time], expected[3], "local edit: the next line did not move");
bm.unpinLine(0);
assertClose.(bm.gridLines[0][\time], expected[2], "unpin: back to the stamp's time");
sel = bm.selectionEvent;
assert.(sel[\local] == true, "selectionEvent: the local flag is saved");
bm2 = BeatMarkMode(notes, 4);
bm2.resume(sel);
assert.(bm2.localEdits, "resume: local edits come back");

// ------------------------------------------------------ marks on the stamp axis
pairs = sel[\anchors].collect { |a| [a[\src], a[\beat]] };   // beats 0..5 as marked
res = TakeGui.onStampAxis(name, 0, pairs);
assert.(res[1] == 1, "onStampAxis: first mark (stamp beat ~1) -> shift 1 (got %)".format(res[1]));
assertArr.(res[0].collect(_[1]), (1..6), "onStampAxis: beats 1..6, spacing kept");
res = TakeGui.onStampAxis(bare, 0, pairs);
assert.(res[1] == 0, "onStampAxis: unstamped takes stay 0-based");
// half notes marked as beats: the check warns (spans 2x the stamp) — here just runs
TakeGui.onStampAxis(name, 0, [[expected[0], 0], [expected[2], 1], [expected[4], 2]]);

// ------------------------------------------------ the resolver keeps the first beat
TakeArchive.writeMarks(name, 0, TakeGui.onStampAxis(name, 0, pairs)[0], sel);
ev = (item: name, take: 0, when: recWhen, start: 0, sourceTempoMap: \marks, type: \audioItem);
r = AudioItem.prResolveSourceMap(ev, name, 0);
assert.(r[\srcBeatOrigin] == 1, "resolver: \\marks origin = its first beat (1)");
f = AudioItem.prSrcOffset(r, list, recWhen, 0);
assertClose.(r[\start] + f.(recWhen + 1), pairs[0][0], "marked beat 1 plays at list beat 17 (= its stamp beat)");
assertClose.(r[\start] + f.(recWhen + 3), pairs[2][0], "marked beat 3 plays at list beat 19");
// ~marks and ~stamp now share the axis: at beat 3 they differ only by the sloppiness
r = AudioItem.prSourceEnvir(ev, name, 0);
assertClose.(r[\marks].at(3), r[\stamp].at(3), "~marks and ~stamp agree on beat 3 (within 30 ms)", 0.031);

// ------------------------------------------------------- recorded placement
added = list.addItem(Take(name, 0), sourceTempoMap: \marks);
assert.(added.isKindOf(Array) and: { added.first[\when] == recWhen },
	"addItem with no at: places a stamped take at its record beat");
added = list.addItem(Take(bare, 0), sourceTempoMap: \eventList);
assert.(added.isString, "addItem with no at: refuses an unstamped take");

~cleanup.();
h[\report].();
0.exit;
)
