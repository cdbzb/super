// Headless regression test for followTrack value-forwarding (§9b,
// quantize-tempomap-project.md), same convention on both media:
//   followTrack: true       = follow with the FLAT source (recorded seconds as beats;
//                             on \audioItem this forwards to sourceBeatDur: 1)
//   followTrack: \eventList = follow inverting through the list's own tempoMap
//                             (on \audioItem this is the tempo-follow native default)
// Explicit sourceTempoMap / sourceBeatDur wins over the forwarded value, and
// \audioItemTempoFollow passes through unchanged. Pure language except an 8 s
// fixture wav written under AudioItem.folder (cleaned up at the end).
// Run: /Applications/SuperCollider.app/Contents/MacOS/sclang standalone-tests/followtrack-forward-test.scd
(
var h = (thisProcess.nowExecutingPath.dirname +/+ "test-helpers.scd").load;
var assert = h[\assert];
var assertArr = h[\assertArr];
var mkNote, notes, mkPlayer, mt, mkList, timesFor;
var tA, tB, tFlat, tOverride, tFlatLabel;
var ftChild, ftParentT, ftParentE, sT, sE;
var aName = "zzz-followtrack-test", aDir, aPath, sf;
var tBase, tEvList, tAFlat, tFtTrue;

"== followTrack forwarding tests ==".postln;

// Synthetic take: anchors at 1 s/beat for beats 0..4, closing anchor makes the
// final span 3 s/beat — non-flat, so map and flat paths must disagree.
mkNote = { |ts, note = 60| (midicmd: \noteOn, type: \mk, timestamp: ts,
	midinote: note, dur: 0.5, sustain: 0.5, amp: 0.5) };
notes = [0, 1, 2, 3, 4, 6].collect { |ts| mkNote.(ts) };
mkPlayer = { MIDIItemPlayer(notes.deepCopy, nil) };
mt = MIDIItemTempoMap(mkPlayer.(), { |n| n[0..4] }, [1, 1, 1, 1, 1]);

mkList = { |ev|
	var l = EventList.new;
	l.tempoMap = mt;
	l.events.add(ev);
	l
};
timesFor = { |ev|
	mkList.(ev).prepare(100, 0).collect { |i| i[\time] }.asArray.sort
};

// ---------------------------------------------------------------- \mi2
tA = timesFor.((when: 0, type: \mi2, player: mkPlayer.(),
	followTrack: true, sourceTempoMap: \eventList));
tB = timesFor.((when: 0, type: \mi2, player: mkPlayer.(),
	followTrack: \eventList));
tFlat = timesFor.((when: 0, type: \mi2, player: mkPlayer.(),
	followTrack: true));
tOverride = timesFor.((when: 0, type: \mi2, player: mkPlayer.(),
	followTrack: \flat, sourceTempoMap: \eventList));
tFlatLabel = timesFor.((when: 0, type: \mi2, player: mkPlayer.(),
	followTrack: \flat));

assert.(tA.size == 6, "mi2: two-key form schedules all 6 notes (got %)".format(tA.size));
assertArr.(tB, tA, "mi2: followTrack: \\eventList == true + sourceTempoMap: \\eventList");
assert.((tFlat.size != tA.size) or: { (tFlat - tA).abs.maxItem > 1e-6 },
	"mi2 sanity: map path differs from flat path");
assertArr.(tOverride, tA, "mi2: explicit sourceTempoMap wins over followTrack value");
assertArr.(tFlatLabel, tFlat, "mi2: followTrack: \\flat follows with flat source");

// nested \eventList: non-boolean followTrack still follows (warns, treated as true)
ftChild = EventList.new;
ftChild.beatDur = 0.25;
ftChild.add(0, foo: 1); ftChild.add(1, foo: 2);
ftParentT = EventList.new;
ftParentT.beatDur = 1;
ftParentT.add(0, tempoTrack: 2);
ftParentT.add((when: 4, newType: \eventList, eventList: ftChild, followTrack: true));
ftParentE = EventList.new;
ftParentE.beatDur = 1;
ftParentE.add(0, tempoTrack: 2);
ftParentE.add((when: 4, newType: \eventList, eventList: ftChild, followTrack: \eventList));
sT = ftParentT.prepare(100, 0).collect { |i| i[\time] }.asArray.sort;
sE = ftParentE.prepare(100, 0).collect { |i| i[\time] }.asArray.sort;
assertArr.(sE, sT, "nested \\eventList: followTrack: \\eventList follows like true");

// ---------------------------------------------------------------- \audioItem
// 8 s fixture: short enough that the base-map source (10 s needed for dur: 6 on
// this map) exhausts the file early while the flat source (6 s) does not, so the
// two source domains produce different schedules.
aDir = AudioItem.folder +/+ aName;
aPath = aDir +/+ "0.wav";
File.mkdir(aDir);
sf = SoundFile.new.headerFormat_("WAV").sampleFormat_("int16")
	.numChannels_(1).sampleRate_(44100);
sf.openWrite(aPath).if {
	sf.writeData(Signal.newClear(44100 * 8));
	sf.close;
} { h[\fail].("could not write audio fixture") };

tBase   = timesFor.((when: 0, type: \audioItemTempoFollow, name: aName, dur: 6));
tEvList = timesFor.((when: 0, type: \audioItem, followTrack: \eventList, name: aName, dur: 6));
tAFlat  = timesFor.((when: 0, type: \audioItemTempoFollow, name: aName, dur: 6, sourceBeatDur: 1));
tFtTrue = timesFor.((when: 0, type: \audioItem, followTrack: true, name: aName, dur: 6));

assert.(tBase.size > 0, "audio: tempo-follow produced a schedule (% entries)".format(tBase.size));
assertArr.(tEvList, tBase, "audio: followTrack: \\eventList == \\audioItemTempoFollow");
assertArr.(tFtTrue, tAFlat, "audio: followTrack: true == sourceBeatDur: 1");
assert.((tAFlat.size != tBase.size) or: { (tAFlat - tBase).abs.maxItem > 1e-6 },
	"audio sanity: flat differs from base-map source (% vs % entries)".format(tAFlat.size, tBase.size));
assert.(timesFor.((when: 0, type: \audioItem, name: aName)).size == 1,
	"audio: plain \\audioItem stays sealed (1 entry)");
assert.(timesFor.((when: 0, type: \audioItem, name: aName, followTrack: \eventList,
	record: true, dur: 6)).size == 1,
	"audio: record: true stays sealed even with followTrack (1 entry)");

// forwarding unit checks (wall times can't see sourceBeatDur when the file is long enough)
assert.(EventList.new.prForwardAudioFollow((type: \audioItem, followTrack: true))[\sourceBeatDur] == 1,
	"forward: true stamps sourceBeatDur: 1");
assert.(EventList.new.prForwardAudioFollow((type: \audioItem, followTrack: \eventList))[\sourceBeatDur].isNil,
	"forward: \\eventList keeps base-map source (no sourceBeatDur)");
assert.(EventList.new.prForwardAudioFollow((type: \audioItem, followTrack: true, sourceBeatDur: 0.5))[\sourceBeatDur] == 0.5,
	"forward: explicit sourceBeatDur wins");
assert.(EventList.new.prForwardAudioFollow((type: \audioItemTempoFollow))[\sourceBeatDur].isNil,
	"forward: \\audioItemTempoFollow untouched");

File.delete(aPath);
File.delete(aDir);

h[\report].();
0.exit;
)
