// One resolver for an audio event's source clock (audio-beat-marking-plan.md
// step 8): AudioItem.prResolveSourceMap decides "which beat is at which file
// second", and everything else only reads it. Also: fromBeat:/toBeat: (trim +
// rebase, as MIDI's fromBeat), start: trims on \marks, followTrack forwarding,
// timing keys route \audioItem to the follow path, and addItem is the same
// dialect as a hand-written add().
//
// Pure language (the follow builders read the fixture file but send nothing).
// Fixtures under AudioItem.folder, removed at the end.
// Run: /Applications/SuperCollider.app/Contents/MacOS/sclang standalone-tests/source-map-resolver-test.scd
(
var h = (thisProcess.nowExecutingPath.dirname +/+ "test-helpers.scd").load;
var assert = h[\assert];
var assertClose = h[\assertClose];
var assertArr = h[\assertArr];
var bare = "zzz-resolver-bare", stamped = "zzz-resolver-stamped";
var srcs = [0.73, 1.21, 1.74, 2.2, 2.71];
var b0 = 8, list, cleanup, r, f, ev, acts, sf, sig, a, b, sa, sb, savedArmed;
var res = { |e, n| AudioItem.prResolveSourceMap(e, n ? bare, 0) };

"== source-map resolver tests ==".postln;

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

// fixtures: a 3.5 s take file for each, marks on both, a stamp (round trip 0.05) on one
sig = Signal.fill(48000 * 7 div: 2, { 0.001.rand2 });
[bare, stamped].do { |n|
	File.mkdir(AudioItem.folder +/+ n);
	sf = SoundFile.new.headerFormat_("WAV").sampleFormat_("float").numChannels_(1).sampleRate_(48000);
	sf.openWrite(AudioItem.folder +/+ n +/+ "0.wav"); sf.writeData(sig); sf.close;
	TakeArchive.writeMarks(n, 0, srcs.collect { |t, i| [t, i] }, nil);
};
TakeArchive.write(stamped, 0, (
	retuneVersion: 2, anchors: [(key: 0, src: 0, beat: 0), (key: 1, src: 0.5, beat: 1)],
	anchorSource: \recordStamp,
	recordedAgainst: (when: 0, start: 0, roundTrip: 0.05, latencyConvention: \raw)
));

// ------------------------------------------------------------ resolver order
r = res.((sourceTempoMap: AnchorTempoMap([0, 1, 2], [0, 1, 2])));
assert.(r[\srcName] == \map, "a map object is used as given");
r = res.((sourceTempoMap: MapEditor.mapFromTimes([0, 0.5, 1])));
assert.(r[\srcMap].respondsTo(\beatDomain), "a MonoMap is converted once");
assert.(res.((sourceTempoMap: \marks))[\srcName] == \marks, "\\marks");
assert.(res.((sourceTempoMap: \stamp), stamped)[\srcName] == \stamp, "\\stamp on a stamped take");
assert.(res.((sourceTempoMap: \stamp))[\srcName] == \eventList, "\\stamp on an unstamped take falls back to the list clock");
r = res.((sourceTempoMap: \eventList), stamped);
assert.(r[\srcName] == \eventList and: { r[\srcMap].isNil }, "\\eventList = the list clock, even on a stamped take");
assert.(res.((sourceBeatDur: 0.5))[\srcName] == \flat, "sourceBeatDur alone = \\flat");
assert.(res.((), stamped)[\srcName] == \stamp, "default on a stamped take: the stamp");
assert.(res.(())[\srcName] == \eventList, "default on an unstamped take: the list clock");
r = res.((srcResolved: true, srcName: \x));
assert.(r[\srcName] == \x, "idempotent: a resolved event is not resolved again");

// \flat reads d s/beat, plus t0 (the latency is NOT in a flat clock)
ev = (item: stamped, take: 0, sourceTempoMap: \flat, sourceBeatDur: 0.5);
f = AudioItem.prSrcOffset(ev, list, b0, 0);
assertClose.(f.(b0 + 2), 0.05 + 1.0, "\\flat: 2 beats at 0.5 s/beat, plus the take's t0");
// the stamp through the one builder: beat 1 at 0.5 s, plus t0
f = AudioItem.prSrcOffset((item: stamped, take: 0), list, b0, 0);
assertClose.(f.(b0 + 1), 0.05 + 0.5, "stamp: read through its map, plus t0");
// the list clock
f = AudioItem.prSrcOffset((item: bare, take: 0), list, b0, 0);
assertClose.(f.(b0 + 3), 3, "list clock: beatDur 1, no t0 on an unstamped take");

// ------------------------------------------------------ fromBeat / toBeat
ev = (item: bare, take: 0, when: b0, start: 0, sourceTempoMap: \marks, fromBeat: 2, toBeat: 4);
r = res.(ev);
f = AudioItem.prSrcOffset(r, list, b0, 0);
assertClose.(r[\start] + f.(b0), srcs[2], "fromBeat: 2 — marked beat 2 sounds at when:");
assertClose.(r[\start] + f.(b0 + 1), srcs[3], "fromBeat: 2 — the next beat stays on the grid");
assertClose.(r[\dur], 2, "toBeat: 4 with fromBeat: 2 = 2 beats");
assertClose.(AudioItem.prSrcEndBeat(r, list, b0, r[\start], srcs[3], 0), b0 + 1,
	"prSrcEndBeat inverts it with fromBeat");

// ------------------------------------------------- start: trims on \marks
ev = (item: bare, take: 0, when: b0, start: 0.6, sourceTempoMap: \marks);
r = res.(ev);
assertClose.(r[\start], srcs.first, "\\marks: start: is the origin (first mark)...");
assertClose.(r[\srcTrim], 0.6, "...and the given start: becomes a trim");
acts = AudioItem.tempoFollowActions(ev, list, nil, 0);
assert.(acts.size > 0, "tempoFollowActions builds segments");
// the first segment waits until the beat where the source reaches origin + 0.6:
// between marks 1 (1.21) and 2 (1.74): beat 1 + (1.33 - 1.21) / 0.53
assertClose.(acts.first[0], b0 + 1 + (0.12 / 0.53),
	"start: trims — nothing sounds before origin + start, beats stay put", 1e-3);

// ------------------------------------------------------ followTrack forwarding
r = list.prForwardAudioFollow((type: \audioItem, followTrack: \eventList));
assert.(r[\sourceTempoMap].isNil and: { r[\sourceBeatDur].isNil },
	"followTrack: \\eventList forwards nothing (default source — keeps the stamp)");
assert.(list.prForwardAudioFollow((type: \audioItem, followTrack: true))[\sourceBeatDur] == 1,
	"followTrack: true = flat");
assert.(list.prForwardAudioFollow((type: \audioItem, followTrack: \marks))[\sourceTempoMap] == \marks,
	"followTrack: \\marks forwards the name");

// ------------------------------------------------------ routing
assert.(list.prIsAudioFollow((type: \audioItem, item: bare, sourceTempoMap: \marks)),
	"a timing key routes \\audioItem to the follow path");
assert.(list.prIsAudioFollow((type: \audioItem, item: bare)).not, "a bare \\audioItem stays sealed");
savedArmed = AudioItem.armed;
AudioItem.armed = true;
assert.(list.prIsAudioFollow((type: \audioItem, item: bare, record: true, sourceTempoMap: \marks)).not,
	"record: true while armed stays on the sealed recording path");
AudioItem.armed = savedArmed;

// ------------------------------------------------------ addItem == add()
a = EventList.new; a.beatDur = 1;
b = EventList.new; b.beatDur = 1;
ev = a.addItem(Take(bare, 0), at: 2, sourceTempoMap: \marks, fromBeat: 1, amp: 0.3).first;
assert.(ev[\amp] == 0.3 and: { ev[\fromBeat] == 1 }, "addItem forwards every other keyword into the event");
b.add((when: 2, newType: \audioItem, followTrack: \eventList, item: bare, take: 0, start: 0,
	sourceTempoMap: \marks, fromBeat: 1, amp: 0.3));
sa = a.prepare(0).collect(_[\time]);
sb = b.prepare(0).collect(_[\time]);
assert.(sa.size > 0, "parity: the addItem list prepares a schedule (% sends)".format(sa.size));
assertArr.(sa, sb, "parity: addItem and the hand-written event prepare the same schedule");

cleanup.();
h[\report].();
0.exit;
)
