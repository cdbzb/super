// Headless regression test for the ONE follow key (EventList.followSource),
// same convention on both media:
//   followTrack: \auto (or true) = the take's marks (MIDI: saved selection),
//                             else its record stamp, else \list. Legacy
//                             \eventList reads as \auto, with a warning
//   followTrack: \list       = the list's live clock (recorded speed)
//   followTrack: <number>    = flat, that many s/beat (\flat == 1)
//   followTrack: <map>/\marks/\stamp = that source
// Legacy sourceTempoMap / sourceBeatDur still work and win. A retimed (quantized)
// \mi2 player plays flat under \auto; a sealed \mi2 before `from` is trimmed.
// Pure language except an 8 s fixture wav written under AudioItem.folder
// (cleaned up at the end).
// Run: /Applications/SuperCollider.app/Contents/MacOS/sclang standalone-tests/followtrack-forward-test.scd
(
var h = (thisProcess.nowExecutingPath.dirname +/+ "test-helpers.scd").load;
var assert = h[\assert];
var assertArr = h[\assertArr];
var assertClose = h[\assertClose];
var mkNote, notes, mkPlayer, mt, mkList, timesFor, flatTimesFor;
var tA, tB, tFlat, tOverride, tFlatLabel;
var ftChild, ftParentT, ftParentE, sT, sE;
var aName = "zzz-followtrack-test", aDir, aPath, sf;
var tBase, tEvList, tAFlat, tFtTrue;
var gSrc, gOneKey, gOnMapList, gTrimSrc, gTrimEvList, aSrc, aSrcOneKey, aSrcOnMapList;
var tDir, stampList, stamp, aNoStamp, aStamped, aStampedFlat, aStamped2, tPath, tLines;
var tOutDevice, tRig, tRig2;
var stampSnap, mkMarked, sAuto, sRetimed, sHalf, sSealed, mkStamped, stampSrcList, sDefault, sLive, sExplicit, sAlone, sTrim, sTrimMap, sNoStamp, halfList;

"== followTrack forwarding tests ==".postln;

assert.(AudioItem.eventItemName((name: \eventLabel, item: \asset)) == \asset,
	"audio identity: item wins over the EventList name");
assert.(AudioItem.eventItemName((name: \legacyAsset)) == \legacyAsset,
	"audio identity: legacy name remains supported");

// Synthetic take: anchors at 1 s/beat for beats 0..3, then a MEASURED span of
// 3 s/beat (mark at 6, not 4). The closing anchor repeats that last measured
// span (fe898d18) rather than reading the clip end, so the map is non-flat and
// the map and flat paths must disagree.
mkNote = { |ts, note = 60| (midicmd: \noteOn, type: \mk, timestamp: ts,
	midinote: note, dur: 0.5, sustain: 0.5, amp: 0.5) };
notes = [0, 1, 2, 3, 6, 7].collect { |ts| mkNote.(ts) };
mkPlayer = { MIDIItemPlayer(notes.deepCopy, nil) };
mt = MIDIItemTempoMap(mkPlayer.(), { |n| n[0..4] }, [1, 1, 1, 1, 1]);

mkList = { |ev|
	var l = EventList.new;
	l.tempoMap = mt;
	l.events.add(ev);
	l
};
timesFor = { |ev, from = 0|
	mkList.(ev).prepare(100, from).collect { |i| i[\time] }.asArray.sort
};
// flat list (no tempoMap): the "after a destructive quantize" world, where the
// list no longer owns the take's map and it must be stamped per event instead
flatTimesFor = { |ev, from = 0|
	var l = EventList.new;
	l.beatDur = 1;
	l.events.add(ev);
	l.prepare(100, from).collect { |i| i[\time] }.asArray.sort
};

// ---------------------------------------------------------------- \mi2
tA = timesFor.((when: 0, type: \mi2, player: mkPlayer.(),
	followTrack: true, sourceTempoMap: \eventList));
tB = timesFor.((when: 0, type: \mi2, player: mkPlayer.(),
	followTrack: \eventList));
tFlat = timesFor.((when: 0, type: \mi2, player: mkPlayer.(),
	followTrack: 1));
tOverride = timesFor.((when: 0, type: \mi2, player: mkPlayer.(),
	followTrack: \flat, sourceTempoMap: \eventList));
tFlatLabel = timesFor.((when: 0, type: \mi2, player: mkPlayer.(),
	followTrack: \flat));

assert.(tA.size == 6, "mi2: two-key form schedules all 6 notes (got %)".format(tA.size));
assertArr.(tB, tA, "mi2: unmarked, unstamped \\auto == legacy sourceTempoMap: \\eventList (the list)");
assertArr.(timesFor.((when: 0, type: \mi2, player: mkPlayer.(), followTrack: \list)), tA,
	"mi2: followTrack: \\list == legacy sourceTempoMap: \\eventList");
assertArr.(timesFor.((when: 0, type: \mi2, player: mkPlayer.(), followTrack: true)), tA,
	"mi2: followTrack: true == \\eventList (both \\auto)");
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

// ------------------------------------------- \mi2 general case: map OBJECT
// Flat list + stamped take map: recorded seconds invert through the map to
// ideal beats, which the flat list renders 1:1 — so wall times ARE the ideal
// beats. mt: 1 s/beat for beats 0..3, then 3 s/beat for beat 3->4 and for the
// closing span that repeats it, so the note at recorded second 7 lands on
// beat 4 + (7-6)/3 = 4.3333.
gSrc = flatTimesFor.((when: 0, type: \mi2, player: mkPlayer.(),
	followTrack: true, sourceTempoMap: mt));
gOneKey = flatTimesFor.((when: 0, type: \mi2, player: mkPlayer.(),
	followTrack: mt));
assertArr.(gSrc, [100, 101, 102, 103, 104, 104 + (1/3)],
	"mi2 map object: recorded seconds land on ideal beats", 1e-6);
assertArr.(gOneKey, gSrc, "mi2: followTrack: <map> == true + sourceTempoMap: <map>");

// On a list that DOES own the map (b0 = 0), the stamped map and \eventList are
// the same inversion — including the mid-list `from` trim path.
gOnMapList = timesFor.((when: 0, type: \mi2, player: mkPlayer.(),
	followTrack: true, sourceTempoMap: mt));
assertArr.(gOnMapList, tA, "mi2: stamped list-own map == sourceTempoMap: \\eventList");
gTrimSrc = timesFor.((when: 0, type: \mi2, player: mkPlayer.(),
	followTrack: true, sourceTempoMap: mt), 2.5);
gTrimEvList = timesFor.((when: 0, type: \mi2, player: mkPlayer.(),
	followTrack: \eventList), 2.5);
assertArr.(gTrimSrc, gTrimEvList, "mi2: map-object trim matches \\eventList trim");

// ------------------------------------------- \mi2 record stamp (recordPlayEpoch)
// A take overdubbed against a list playing mt: epoch at wall 0, beat 0, and the
// take's timestamp 0 sounded at wall 0, so recorded beat == mt.beatAt(ts). The
// epoch's list is a detached snapshot, so mutating stampSrcList afterwards must
// not move the take.
stampSrcList = EventList.new;
stampSrcList.tempoMap = mt;
stampSnap = stampSrcList.prClockSnapshot;   // taken ONCE, at "record time"
mkStamped = {
	mkPlayer.().recordEpoch_(0)
	.recordPlayEpoch_((seconds: 0, fromBeat: 0, tempoEnv: nil, list: stampSnap))
};
sDefault = flatTimesFor.((when: 0, type: \mi2, player: mkStamped.(), followTrack: \eventList));
assertArr.(sDefault, gSrc, "mi2 stamp: bare \\eventList resolves the recorded clock", 1e-6);
sExplicit = flatTimesFor.((when: 0, type: \mi2, player: mkStamped.(), followTrack: \stamp));
assertArr.(sExplicit, gSrc, "mi2 stamp: followTrack: \\stamp == default", 1e-6);
stampSrcList.tempoMap = nil;
assertArr.(flatTimesFor.((when: 0, type: \mi2, player: mkStamped.(), followTrack: \eventList)), gSrc,
	"mi2 stamp: survives later source-list mutation", 1e-6);
stampSrcList.tempoMap = mt;
// The point of the stamp: after the list's map is changed (here to a flat
// 0.5 s/beat), the take keeps its RECORDED beats and the new map re-places them;
// the live \eventList source instead re-inverts through the new map.
halfList = { |ev, from = 0|
	var l = EventList.new;
	l.beatDur = 0.5;
	l.events.add(ev);
	l.prepare(100, from).collect { |i| i[\time] }.asArray.sort
};
sDefault = halfList.((when: 0, type: \mi2, player: mkStamped.(), followTrack: \eventList));
assertArr.(sDefault, 100 + ([0, 1, 2, 3, 4, 4 + (1/3)] * 0.5),
	"mi2 stamp: edited map re-places recorded beats", 1e-6);
sLive = halfList.((when: 0, type: \mi2, player: mkStamped.(), followTrack: \list));
assertArr.(sLive, 100 + [0, 1, 2, 3, 6, 7],
	"mi2: \\list on a map-less list plays recorded seconds through its beatDur", 1e-6);
// sourceTempoMap alone (no followTrack) follows instead of falling to sealed
sAlone = flatTimesFor.((when: 0, type: \mi2, player: mkPlayer.(), sourceTempoMap: mt));
assertArr.(sAlone, gSrc, "mi2: legacy sourceTempoMap alone implies following", 1e-6);
// trim: a mid-list `from` on a stamped take matches the same map as an object
sTrim = flatTimesFor.((when: 0, type: \mi2, player: mkStamped.(), followTrack: \eventList), 2.5);
sTrimMap = flatTimesFor.((when: 0, type: \mi2, player: mkPlayer.(), followTrack: mt), 2.5);
assertArr.(sTrim, sTrimMap, "mi2 stamp: trim matches map-object trim", 1e-6);
// \stamp on an unstamped take warns and falls back to \eventList
sNoStamp = timesFor.((when: 0, type: \mi2, player: mkPlayer.(), followTrack: \stamp));
assertArr.(sNoStamp, tA, "mi2: \\stamp without recordPlayEpoch == \\list");

// ------------------------------------------- \mi2 \auto: marks, retimed, numbers
// A player with a saved selection (here a tempoMap_ override) resolves \auto to
// its own map — the doubling case: follow the notes asEventList already placed.
mkMarked = { mkPlayer.().tempoMap_(mt) };
sAuto = flatTimesFor.((when: 0, type: \mi2, player: mkMarked.(), followTrack: true));
assertArr.(sAuto, gSrc, "mi2 \\auto: a marked player follows its own map", 1e-6);
// marks beat the stamp (the deliberate act wins)
// (a selection counting each anchor gap as 2 beats — distinct from the stamp's beats)
sAuto = flatTimesFor.((when: 0, type: \mi2, followTrack: true,
	player: mkStamped.().tempoMap_(MIDIItemTempoMap(mkPlayer.(), { |n| n[0..4] }, [2, 2, 2, 2, 2]))));
assertArr.(sAuto, 100 + ((gSrc - 100) * 2), "mi2 \\auto: marks win over the stamp", 1e-6);
// a retimed player (quantize / warpTo): timestamps already ARE beats — flat
sRetimed = flatTimesFor.((when: 0, type: \mi2, followTrack: true,
	player: mkStamped.().tempoMap_(mt).prMarkRetimed));
assertArr.(sRetimed, 100 + [0, 1, 2, 3, 6, 7], "mi2 \\auto: a retimed player plays flat", 1e-6);
assert.(mkPlayer.().prMarkRetimed.filter { |e| e }.retimed == true, "retimed rides through filters");
// a number is seconds per beat
sHalf = flatTimesFor.((when: 0, type: \mi2, player: mkPlayer.(), followTrack: 0.5));
assertArr.(sHalf, 100 + ([0, 1, 2, 3, 6, 7] * 2), "mi2: followTrack: 0.5 = 0.5 s/beat", 1e-6);

// ------------------------------------------- sealed \mi2 before `from` is trimmed
sSealed = flatTimesFor.((when: 0, type: \mi2, player: mkPlayer.()), 2.5);
assert.((sSealed.size == 1) and: { (sSealed[0] - 100).abs < 1e-6 },
	"sealed mi2 started before from: one trimmed send at from (got %)".format(sSealed));
assert.(flatTimesFor.((when: 0, type: \mi2, player: mkPlayer.()), 9).size == 0,
	"sealed mi2 wholly before from: nothing");

// ------------------------------------------- \mi2 fromBeat / toBeat / align
// flat source (1 s/beat): item beats == recorded seconds [0, 1, 2, 3, 6, 7]
assertArr.(flatTimesFor.((when: 0, type: \mi2, player: mkPlayer.(), followTrack: 1, fromBeat: 2)),
	100 + [0, 1, 4, 5], "mi2 fromBeat: 2 — source beat 2 sounds at when:, earlier notes trimmed", 1e-6);
assertArr.(flatTimesFor.((when: 3, type: \mi2, player: mkPlayer.(), followTrack: 1, fromBeat: 2)),
	103 + [0, 1, 4, 5], "mi2 fromBeat: rebased onto a later when:", 1e-6);
assertArr.(flatTimesFor.((when: 0, type: \mi2, player: mkPlayer.(), followTrack: 1, fromBeat: 2, toBeat: 6)),
	100 + [0, 1], "mi2 toBeat: 6 — half-open, the note on beat 6 is cut", 1e-6);
assertArr.(flatTimesFor.((when: 0, type: \mi2, player: mkPlayer.(), followTrack: mt, toBeat: 4)),
	100 + [0, 1, 2, 3], "mi2 toBeat on a map source cuts in its beats", 1e-6);
assert.(flatTimesFor.((when: 0, type: \mi2, player: mkPlayer.(), fromBeat: 0)).size == 6,
	"mi2 fromBeat alone implies following");
// align on the marked map: 1 = its beats (gSrc), 0 = as performed, 0.5 between
assertArr.(flatTimesFor.((when: 0, type: \mi2, player: mkPlayer.(), followTrack: mt, align: 1)), gSrc,
	"mi2 align: 1 == plain follow", 1e-6);
assertArr.(flatTimesFor.((when: 0, type: \mi2, player: mkPlayer.(), followTrack: mt, align: 0)),
	100 + [0, 1, 2, 3, 6, 7], "mi2 align: 0 == as performed", 1e-6);
assertArr.(flatTimesFor.((when: 0, type: \mi2, player: mkPlayer.(), followTrack: mt, align: 0.5)),
	(gSrc + (100 + [0, 1, 2, 3, 6, 7])) / 2, "mi2 align: 0.5 blends the wall times", 1e-6);
assert.(flatTimesFor.((when: 0, type: \mi2, player: mkPlayer.(), align: 1)).size == 6,
	"mi2 align alone implies following");

// ------------------------------------------- renamed audio keys read their old names
assert.(AudioItem.startSec((start: 1.5)) == 1.5, "startSec: start:");
assert.(AudioItem.startSec((startPos: 2.5)) == 2.5, "startSec: legacy startPos: (warns)");
assert.(AudioItem.startSec((start: 1, startPos: 2)) == 1, "startSec: start: wins");
assert.(AudioItem.startSec(()) == 0, "startSec: default 0");
assert.(AudioItem.prMapIncludesLatency((sourceMapIncludesLatency: true)), "latency flag");
assert.(AudioItem.prMapIncludesLatency((sourceMapIsPhysical: true)), "legacy sourceMapIsPhysical: (warns)");
assert.(AudioItem.prMapIncludesLatency(()).not, "latency flag default false");

// ------------------------------------------- nested lists: fromBeat / toBeat
assert.(EventList.listRange((fromBeat: 2, toBeat: 5)) == [2, 5], "listRange: fromBeat/toBeat");
assert.(EventList.listRange((start: 2, end: 5)) == [2, 5], "listRange: legacy start/end (warns)");
assert.(EventList.listRange((fromBeat: 1, start: 2)) == [1, nil], "listRange: fromBeat wins, open end");
assert.(EventList.listRange(()) == [0, nil], "listRange: default whole child");

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

tBase   = timesFor.((when: 0, type: \audioItemTempoFollow, item: aName, dur: 6));
tEvList = timesFor.((when: 0, type: \audioItem, followTrack: \eventList, item: aName, dur: 6));
tAFlat  = timesFor.((when: 0, type: \audioItemTempoFollow, item: aName, dur: 6, sourceBeatDur: 1));
tFtTrue = timesFor.((when: 0, type: \audioItem, followTrack: 1, item: aName, dur: 6));

assert.(tBase.size > 0, "audio: tempo-follow produced a schedule (% entries)".format(tBase.size));
assertArr.(tEvList, tBase, "audio: followTrack: \\eventList == \\audioItemTempoFollow");
assertArr.(tFtTrue, tAFlat, "audio: followTrack: 1 == legacy sourceBeatDur: 1");
assertArr.(timesFor.((when: 0, type: \audioItem, followTrack: true, item: aName, dur: 6)), tBase,
	"audio: followTrack: true == \\audioItemTempoFollow (\\auto)");
assert.((tAFlat.size != tBase.size) or: { (tAFlat - tBase).abs.maxItem > 1e-6 },
	"audio sanity: flat differs from base-map source (% vs % entries)".format(tAFlat.size, tBase.size));
assert.(timesFor.((when: 0, type: \audioItem, name: aName)).size == 1,
	"audio: legacy name fallback stays sealed (1 entry)");
// record: true only means record when ARMED: armed keeps the sealed path,
// unarmed routes to follow playback (rapid record/play toggle workflow)
AudioItem.armed = true;
assert.(timesFor.((when: 0, type: \audioItem, item: aName, followTrack: \eventList,
	record: true, dur: 6)).size == 1,
	"audio: record: true + armed stays sealed (1 entry)");
AudioItem.armed = false;
assert.(timesFor.((when: 0, type: \audioItem, item: aName, followTrack: \eventList,
	record: true, dur: 6)).size > 1,
	"audio: record: true unarmed follows track");

// ------------------------------------------- \audioItem general case: map OBJECT
// Flat list + stamped take map: the source advances through the map (10 s of
// source needed for dur: 6), so the 8 s file exhausts early — fewer entries than
// the flat source's 24. On the map-owning list the stamped map must reproduce
// the base-map default exactly.
aSrc = flatTimesFor.((when: 0, type: \audioItem, followTrack: true,
	sourceTempoMap: mt, item: aName, dur: 6));
aSrcOneKey = flatTimesFor.((when: 0, type: \audioItem, followTrack: mt,
	item: aName, dur: 6));
assert.((aSrc.size > 0) and: { aSrc.size < 24 },
	"audio map object: source exhausts file early (% entries)".format(aSrc.size));
assertArr.(aSrcOneKey, aSrc, "audio: followTrack: <map> == true + sourceTempoMap: <map>");
aSrcOnMapList = timesFor.((when: 0, type: \audioItem, followTrack: true,
	sourceTempoMap: mt, item: aName, dur: 6));
assertArr.(aSrcOnMapList, tBase, "audio: stamped list-own map == base-map default");

// ------------------------------------------- record-time clock stamp (§9a step 2)
// Without a stamp, bare \eventList on a flat list is the flat base clock; with a
// stamp (what the take was ACTUALLY recorded against) the same event resolves the
// recorded map — the post-destructive-quantize "just works" path.
aNoStamp = flatTimesFor.((when: 0, type: \audioItem, followTrack: \eventList,
	item: aName, dur: 6));
assert.(aNoStamp.size == 24, "stamp: absent — flat list base (% entries)".format(aNoStamp.size));
stampList = EventList.new;
stampList.tempoMap = mt;
stamp = stampList.prRecordStamp((when: 0, start: 0), nil);
AudioItem.recordedMaps.put(aName.asSymbol, 0, stamp);
aStamped = flatTimesFor.((when: 0, type: \audioItem, followTrack: \eventList,
	item: aName, dur: 6));
assertArr.(aStamped, aSrc, "stamp: bare \\eventList resolves the recorded clock");
aStampedFlat = flatTimesFor.((when: 0, type: \audioItem, followTrack: 1,
	item: aName, dur: 6));
assert.(aStampedFlat.size == 24, "stamp: explicit flat source (followTrack: 1) still wins");
stampList.tempoMap = nil; // stamp must be detached from the source list
aStamped2 = flatTimesFor.((when: 0, type: \audioItem, followTrack: \eventList,
	item: aName, dur: 6));
assertArr.(aStamped2, aSrc, "stamp: survives later source-list mutation");

// round-trip compensation: a stamp carrying roundTrip reads the file later, so
// the 8 s file exhausts at an earlier beat than the uncompensated stamp
stampList.tempoMap = mt;
// AudioItem.roundTripLatency now reads AudioInterface.current first and only falls
// back to this global. Point the server at an unregistered device so the fallback
// path is what gets exercised here, whatever rig happens to be measured.
tOutDevice = Server.default.options.outDevice;
Server.default.options.outDevice_("zzz-no-such-interface");
AudioItem.roundTripLatency = 0.5;
stamp = stampList.prRecordStamp((when: 0, start: 0), nil);
AudioItem.roundTripLatency = 0;
assert.(stamp[\roundTrip] == 0.5, "stamp: captures AudioItem.roundTripLatency");
assert.(stamp[\latencyConvention] == \raw, "stamp: tagged \\raw convention");
AudioItem.recordedMaps.put(aName.asSymbol, 0, stamp);
aStamped2 = flatTimesFor.((when: 0, type: \audioItem, followTrack: \eventList,
	item: aName, dur: 6));
assert.(aStamped2.size < aSrc.size,
	"stamp: roundTrip shifts source reads later (% < % entries)".format(aStamped2.size, aSrc.size));
AudioItem.recordedMaps.put(aName.asSymbol, 0, nil);
Server.default.options.outDevice_(tOutDevice);

// ------------------------------------------- startup.scd latency pinning
// Pinning moved to AudioInterface and is now per-rig: each interface writes its own
// roundTrip/outputShare lines, so re-measuring one rig leaves the others alone.
tPath = AudioItem.folder +/+ "zzz-followtrack-startup.scd";
tRig = AudioInterface(\zzzTestRig, "zzz-test-out", "zzz-test-in", 2);
File.use(tPath, "w", { |f| f.write("s.boot;\n\"hello\".postln;\n") });
tRig.roundTrip = 0.014;
tRig.writeStartup(tPath);
tLines = File.readAllString(tPath).split(Char.nl);
assert.(tLines.detect { |l| l.contains("AudioInterface('zzzTestRig').roundTrip = 0.014;") }.notNil,
	"startup: assignment appended");
assert.(tLines[0] == "s.boot;" and: { tLines[1] == "\"hello\".postln;" },
	"startup: existing content preserved");
tRig.roundTrip = 0.021;
tRig.writeStartup(tPath);
tLines = File.readAllString(tPath).split(Char.nl);
assert.(tLines.count { |l| l.contains("AudioInterface('zzzTestRig').roundTrip") } == 1,
	"startup: re-measure replaces, never duplicates");
assert.(tLines.detect { |l| l.contains("= 0.021;") }.notNil,
	"startup: replaced with the new value");
assert.(tLines.count { |l| l.contains("outputShare") } == 0,
	"startup: no outputShare line while the split is unknown");
// outputShare rides along on the same write — it is what splits out the MIDI-side
// term (§9a step 5), since the loopback can only ever measure the sum
tRig.outputShare = 0.5;
tRig.writeStartup(tPath);
tLines = File.readAllString(tPath).split(Char.nl);
assert.(tLines.detect { |l| l.contains("AudioInterface('zzzTestRig').outputShare = 0.5;") }.notNil,
	"startup: outputShare pinned alongside the round trip");
assert.(tLines.count { |l| l.contains("AudioInterface('zzzTestRig').roundTrip") } == 1,
	"startup: round trip still single after adding outputShare");
assert.(tRig.outputLatency == 0.0105, "outputLatency = roundTrip * outputShare");
tRig.roundTrip = 0.03; tRig.outputShare = 0.5;
tRig.writeStartup(tPath);
tLines = File.readAllString(tPath).split(Char.nl);
assert.(tLines.count { |l| l.contains("AudioInterface('zzzTestRig').outputShare") } == 1,
	"startup: outputShare replaced, never duplicated");
assert.(tLines.detect { |l| l.contains("roundTrip = 0.03;") }.notNil,
	"startup: round trip replaced with the new value");
assert.(tLines[0] == "s.boot;" and: { tLines[1] == "\"hello\".postln;" },
	"startup: existing content still preserved after two-line pin");
// a SECOND rig's pins must not disturb the first — the per-device point
tRig2 = AudioInterface(\zzzTestRig2, "zzz-test-out-2", nil, 2);
tRig2.roundTrip = 0.077;
tRig2.writeStartup(tPath);
tLines = File.readAllString(tPath).split(Char.nl);
assert.(tLines.count { |l| l.contains("AudioInterface('zzzTestRig').roundTrip") } == 1,
	"startup: first rig's pin survives a second rig's write");
assert.(tLines.detect { |l| l.contains("AudioInterface('zzzTestRig').roundTrip = 0.03;") }.notNil,
	"startup: first rig kept its own value");
assert.(tLines.detect { |l| l.contains("AudioInterface('zzzTestRig2').roundTrip = 0.077;") }.notNil,
	"startup: second rig pinned independently");
File.delete(tPath);

// ------------------------------------------- take numbering ignores strays
tDir = AudioItem.folder +/+ "zzz-followtrack-takes";
File.mkdir(tDir);
File.use(tDir +/+ "0.wav", "w", { |f| f.write("x") });
File.use(tDir +/+ "2.wav", "w", { |f| f.write("x") });
File.use(tDir +/+ "2.json", "w", { |f| f.write("{}") });
File.use(tDir +/+ "notes.txt", "w", { |f| f.write("stray") });
assert.(AudioItem.latestTake(tDir) == 2,
	"takes: latestTake is highest numeric stem (got %)".format(AudioItem.latestTake(tDir)));
assert.(AudioItem.nextTake(tDir) == 3,
	"takes: nextTake one past highest (got %)".format(AudioItem.nextTake(tDir)));
assert.(AudioItem.takePath(tDir, 2).endsWith("2.wav"),
	"takes: takePath skips non-audio sidecar (got %)".format(AudioItem.takePath(tDir, 2)));
[tDir +/+ "0.wav", tDir +/+ "2.wav", tDir +/+ "2.json", tDir +/+ "notes.txt"].do(File.delete(_));
File.delete(tDir);

File.delete(aPath);
File.delete(aDir);

h[\report].();
0.exit;
)
