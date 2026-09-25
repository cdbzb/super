// sourceTempoMap: as a Function (audio-beat-marking-plan.md step 10). The
// function runs with .use in an environment offering the take's sources as
// MonoMaps in ONE frame — beat -> FILE seconds — ~marks and ~stamp, plus the
// event's own keys through the proto. Whatever it answers is used as a
// latency-included map, origin at its first anchor.
//
// Pure language. Fixtures under AudioItem.folder, removed at the end.
// Run: /Applications/SuperCollider.app/Contents/MacOS/sclang standalone-tests/source-map-function-test.scd
(
var h = (thisProcess.nowExecutingPath.dirname +/+ "test-helpers.scd").load;
var assert = h[\assert];
var assertClose = h[\assertClose];
var assertArr = h[\assertArr];
var bare = "zzz-srcfn-bare", stamped = "zzz-srcfn-stamped";
var srcs = [0.73, 1.21, 1.74, 2.2, 2.71];
var b0 = 8, list, cleanup, r, f, g, envir, pos, l, mt, mkNote, notes, times;

"== sourceTempoMap: Function tests ==".postln;

cleanup = {
	[bare, stamped].do { |n|
		[TakeArchive.dir(n, 0), AudioItem.folder +/+ n].do { |d|
			(d +/+ "*").pathMatch.do(File.delete(_));
			File.exists(d).if { File.delete(d) };
		};
		AudioItem.recordedMaps.removeAt(n.asSymbol, 0);
	}
};
cleanup.();
list = EventList.new; list.beatDur = 1;
TakeArchive.writeMarks(bare, 0, srcs.collect { |t, i| [t, i] }, nil);
TakeArchive.write(stamped, 0, (
	retuneVersion: 2, anchors: [(key: 0, src: 0, beat: 0), (key: 1, src: 0.5, beat: 1),
		(key: 2, src: 1.1, beat: 2)],
	anchorSource: \recordStamp,
	recordedAgainst: (when: 0, start: 0, roundTrip: 0.05, latencyConvention: \raw)
));

// file second at which beat k (from when:) is read, through the resolved event
pos = { |ev, k|
	var rr = AudioItem.prResolveSourceMap(ev, ev[\item], 0);
	var ff = AudioItem.prSrcOffset(rr, list, b0, 0);
	(rr[\start] ? 0) + ff.(b0 + k)
};

// ----------------------------------------------------------- the environment
envir = AudioItem.prSourceEnvir((item: bare, take: 0, when: b0), bare, 0);
assert.(envir[\marks].isKindOf(MonoMap), "~marks is a MonoMap");
assertArr.(envir[\marks].ys, srcs, "~marks: file seconds of the marks");
assert.(envir[\stamp].isNil, "~stamp: nil on an unstamped take");
envir = AudioItem.prSourceEnvir((item: stamped, take: 0), stamped, 0);
assert.(envir[\marks].isNil, "~marks: nil when the take has none");
assertClose.(envir[\stamp].at(1), 0.5 + 0.05, "~stamp: file seconds = stamp seconds + t0");
assert.(envir.use { ~item } == stamped, "the event's keys read through the proto");

// ------------------------------------------------------------- equivalences
assertClose.(pos.((item: bare, take: 0, when: b0, sourceTempoMap: { ~marks }), 3),
	pos.((item: bare, take: 0, when: b0, sourceTempoMap: \marks), 3),
	"{ ~marks } == \\marks");
assertClose.(pos.((item: stamped, take: 0, when: b0, sourceTempoMap: { ~stamp }), 2),
	pos.((item: stamped, take: 0, when: b0), 2),
	"{ ~stamp } == the default stamp path (no double t0)");
assertClose.(pos.((item: stamped, take: 0, when: b0, sourceTempoMap: { ~stamp }), 2), 1.1 + 0.05,
	"{ ~stamp }: beat 2 at stamp 1.1 s + t0");

// -------------------------------------------------------------- an edit
// quantize(1) straightens the marks: beat k at first + k * (last - first) / 4
g = (srcs.last - srcs.first) / 4;
assertClose.(pos.((item: bare, take: 0, when: b0, sourceTempoMap: { ~marks.quantize(1) }), 2),
	srcs.first + (2 * g), "{ ~marks.quantize(1) }: evenly spaced between first and last mark");
assertClose.(pos.((item: bare, take: 0, when: b0, sourceTempoMap: { ~marks.quantize(1) }), 0),
	srcs.first, "…the origin is the result's first anchor");
r = AudioItem.prResolveSourceMap((item: bare, take: 0, sourceTempoMap: { ~marks.quantize(1) }), bare, 0);
assert.(r[\srcName] == \function and: { r[\srcLatencyIncluded] }, "a function result includes the latency");

// ---------------------------------------------------------- failures fall back
r = AudioItem.prResolveSourceMap((item: stamped, take: 0, sourceTempoMap: { ~marks.quantize(1) }), stamped, 0);
assert.(r[\srcName] == \stamp, "a function that errors (nil ~marks) warns and uses the default");
r = AudioItem.prResolveSourceMap((item: bare, take: 0, sourceTempoMap: { 42 }), bare, 0);
assert.(r[\srcName] == \marks, "a function answering a non-map warns and uses the default (the marks)");

// ------------------------------------------------------ not a plain lazy value
assert.(EventList.lazyExclude.includes(\sourceTempoMap), "\\sourceTempoMap is excluded from the lazy pass");
assert.(EventList.lazyExclude.includes(\followTrack), "\\followTrack is excluded from the lazy pass");
l = EventList.new; l.beatDur = 1;
l.add((when: 0, newType: \audioItem, item: bare, take: 0, sourceTempoMap: { ~marks }));
assert.(l.events.last[\sourceTempoMap].isKindOf(Function), "add() keeps the Function (not evaluated at add time)");

// ------------------------------------------------------ \mi2 takes a Function too
mkNote = { |ts| (midicmd: \noteOn, type: \mk, timestamp: ts, midinote: 60, dur: 0.5, sustain: 0.5, amp: 0.5) };
notes = [0, 1, 2, 3, 6, 7].collect { |ts| mkNote.(ts) };
mt = MIDIItemTempoMap(MIDIItemPlayer(notes.deepCopy, nil), { |n| n[0..4] }, [1, 1, 1, 1, 1]);
times = { |src|
	var ll = EventList.new;
	ll.beatDur = 1;
	ll.events.add((when: 0, type: \mi2, player: MIDIItemPlayer(notes.deepCopy, nil),
		followTrack: src));
	ll.prepare(100, 0).collect { |i| i[\time] }.asArray.sort
};
assertArr.(times.({ mt }), times.(mt), "\\mi2: { map } == the map object");

cleanup.();
h[\report].();
0.exit;
)
