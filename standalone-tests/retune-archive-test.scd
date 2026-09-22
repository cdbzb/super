// Headless regression test for RetuneArchive (retune-project.md §2e, v2 schema):
// record-time clock stamps serialized into (src, beat) anchors as append-only
// archive versions under _retune/<name>_<num>/N.retune, and resolved back from
// disk by AudioItem.recordedMapAt when the in-memory stamp is gone (the
// post-sclang-restart path). Pure language; fixtures live under
// AudioItem.folder/_retune and are cleaned up at the end.
// Run: /Applications/SuperCollider.app/Contents/MacOS/sclang standalone-tests/retune-archive-test.scd
(
var h = (thisProcess.nowExecutingPath.dirname +/+ "test-helpers.scd").load;
var assert = h[\assert];
var assertClose = h[\assertClose];
var assertArr = h[\assertArr];
var name = "zzz-retune-archive-test";
var savedRt = AudioItem.roundTripLatency;
var cleanup, mkNote, notes, mkPlayer, mt, env, list, stamp, v, d;
var ev, fMem, fDisk, memVals, diskVals, sampleBeats, maxErr, endMem, endDisk;
var cached, shiftEv, fShift, fShiftDisk, sVals, sValsDisk;
var rtStamp, fRt, rtDiff;
var flatList, flatStamp, fFlat;
var mig, vNotes;
var wild, wildStamp, savedTempo, fWildMem, fWildDisk, wildBeats, wildMem, wildDisk;

"== RetuneArchive / stamp persistence tests ==".postln;

cleanup = {
	[0, 1, 2, 3, 4].do { |num|
		var dir = RetuneArchive.dir(name, num);
		(dir +/+ "*.retune").pathMatch.do(File.delete(_));
		File.exists(dir).if { File.delete(dir) };
	};
	[0, 1, 2, 3, 4].do { |num| AudioItem.recordedMaps.removeAt(name.asSymbol, num) };
};
cleanup.();
AudioItem.roundTripLatency = 0;

// Non-flat base map: anchors at 1 s/beat for beats 0..4, closing anchor makes the
// final span 2 s/beat. On top a tempoEnv with a step and a ramp, so the composed
// clock exercises every beatToWall segment kind the serializer must capture.
mkNote = { |ts, note = 60| (midicmd: \noteOn, type: \mk, timestamp: ts,
	midinote: note, dur: 0.5, sustain: 0.5, amp: 0.5) };
notes = [0, 1, 2, 3, 4, 6].collect { |ts| mkNote.(ts) };
mkPlayer = { MIDIItemPlayer(notes.deepCopy, nil) };
mt = MIDIItemTempoMap(mkPlayer.(), { |n| n[0..4] }, [1, 1, 1, 1, 1]);
env = Env([1, 1, 2, 2], [2, 1, 3], [\step, \lin, \step]);
list = EventList.new;
list.tempoMap = mt;

// ------------------------------------------------- write a stamp, inspect the schema
stamp = list.prRecordStamp((when: 2, start: 0.5, latency: 0.2, lag: 0), env);
v = RetuneArchive.writeStamp(name, 0, stamp);
assert.(v == 0, "writeStamp: first version id is 0 (got %)".format(v));
assert.(File.exists(RetuneArchive.path(name, 0, 0)), "writeStamp: archive file exists");
assert.(RetuneArchive.versions(name, 0) == 1, "versions counts the new archive");

d = RetuneArchive.read(name, 0, 0);
assert.(d[\retuneVersion] == 2, "schema: retuneVersion 2");
assert.(d[\anchorSource] == \recordStamp, "schema: anchorSource \\recordStamp");
assert.(d[\midiEvents].isNil, "schema: stamp version has no notes (structural, no kind flag)");
assert.(d[\recordedAgainst][\when] == 2, "schema: recordedAgainst.when preserved");
assertClose.(d[\recordedAgainst][\start], 0.5, "schema: recordedAgainst.start preserved");
assert.(d[\recordedAgainst][\latencyConvention] == \raw, "schema: \\raw latency convention");
assertClose.(d[\anchors].first[\src], 0, "anchors: src 0 at the record-fire beat");
assertClose.(d[\anchors].first[\beat], 2, "anchors: beats absolute-at-record (start at when)");
assert.(d[\anchors].collect(_[\src]).differentiate.drop(1).every(_ > 0),
	"anchors: src strictly increasing");
assert.(d[\anchors].collect(_[\key]) == (0..d[\anchors].size - 1),
	"anchors: keys are 0..n-1 at birth");

// --------------------------------- in-memory vs disk-resolved playback equivalence
ev = (type: \audioItem, item: name);
AudioItem.recordedMaps.put(name.asSymbol, 0, stamp);
fMem = AudioItem.prSrcOffset(ev, list, 2, 0);
endMem = AudioItem.prSrcEndBeat(ev, list, 2, 0, 6.0, 0);
sampleBeats = (2, 2.25 .. 12);   // runs past the map + env domain -> tests \carry tail
memVals = sampleBeats.collect(fMem);

AudioItem.recordedMaps.removeAt(name.asSymbol, 0);
assert.(AudioItem.recordedMaps.at(name.asSymbol, 0).isNil, "in-memory stamp cleared");
fDisk = AudioItem.prSrcOffset(ev, list, 2, 0);
diskVals = sampleBeats.collect(fDisk);
maxErr = (memVals - diskVals).abs.maxItem;
assert.(maxErr < 2e-3,
	"disk-resolved srcOffset matches in-memory stamp (max err % s)".format(maxErr.round(1e-6)));
cached = AudioItem.recordedMaps.at(name.asSymbol, 0);
assert.(cached.notNil and: { cached[\map].notNil },
	"recordedMapAt caches the loaded (map-form) stamp");
endDisk = AudioItem.prSrcEndBeat(ev, list, 2, 0, 6.0, 0);
assertClose.(endDisk, endMem, "disk-resolved srcEndBeat matches in-memory", 2e-3);

// playing event's when may differ from the recorded when (post-quantize world):
// both forms map beat PROGRESS relative to their own b0
AudioItem.recordedMaps.put(name.asSymbol, 0, stamp);
fShift = AudioItem.prSrcOffset(ev, list, 5, 0);
sVals = (5, 5.25 .. 12).collect(fShift);
AudioItem.recordedMaps.removeAt(name.asSymbol, 0);
fShiftDisk = AudioItem.prSrcOffset(ev, list, 5, 0);
sValsDisk = (5, 5.25 .. 12).collect(fShiftDisk);
assert.((sVals - sValsDisk).abs.maxItem < 2e-3,
	"shifted b0: disk form still maps relative beat progress");

// ------------------------------------------------- roundTrip rides the archive
AudioItem.roundTripLatency = 0.05;
rtStamp = list.prRecordStamp((when: 2), env);
AudioItem.roundTripLatency = 0;
RetuneArchive.writeStamp(name, 1, rtStamp);
fRt = AudioItem.prSrcOffset(ev, list, 2, 1);   // resolves from disk (nothing in memory)
rtDiff = fRt.(4) - fDisk.(4);
assertClose.(rtDiff, 0.05, "roundTrip persists and shifts the read position", 2e-3);

// ------------------------------------------------- flat list (beatDur only)
flatList = EventList.new;
flatList.beatDur = 2;
flatStamp = flatList.prRecordStamp((when: 0), nil);
RetuneArchive.writeStamp(name, 2, flatStamp);
fFlat = AudioItem.prSrcOffset(ev, flatList, 0, 2);
assertClose.(fFlat.(3), 6, "flat-list stamp: 2 s/beat from disk", 2e-3);

// ---------------------- freeze-beatdur: a WILD list (EventList.new — no tempoMap
// AND no beatDur) must freeze the default clock INTO the stamp. Copying nil made
// the in-memory stamp resolve TempoClock.default.beatDur at playback time, so the
// same take played at one rate in its recording session and another after the
// default tempo moved — while the disk form (sampled at write time) stayed right.
wild = EventList.new;
assert.(wild.beatDur.isNil and: { wild.tempoMap.isNil }, "wild list: no clock of its own");
savedTempo = TempoClock.default.tempo;
TempoClock.default.tempo = 1;              // record-time default: 1 s/beat
wildStamp = wild.prRecordStamp((when: 0), nil);
// (== not assertClose: before the fix this is nil, and nil - 1 throws instead of failing)
assert.((wildStamp[\list].beatDur ? -1) == 1,
	"freeze-beatdur: nil beatDur frozen at record time (got %)"
		.format(wildStamp[\list].beatDur));
RetuneArchive.writeStamp(name, 4, wildStamp);
AudioItem.recordedMaps.put(name.asSymbol, 4, wildStamp);
fWildMem = AudioItem.prSrcOffset(ev, wild, 0, 4);
TempoClock.default.tempo = 4;              // playback-time default: 4x faster
wildBeats = (0, 0.5 .. 4);
wildMem = wildBeats.collect(fWildMem);
assertArr.(wildMem, wildBeats.asArray, "freeze-beatdur: in-memory stamp still 1 s/beat", 2e-3);
AudioItem.recordedMaps.removeAt(name.asSymbol, 4);
fWildDisk = AudioItem.prSrcOffset(ev, wild, 0, 4);
wildDisk = wildBeats.collect(fWildDisk);
assert.((wildMem - wildDisk).abs.maxItem < 2e-3,
	"freeze-beatdur: in-memory stamp matches disk after a default-tempo change (max err %)"
		.format((wildMem - wildDisk).abs.maxItem.round(1e-6)));
TempoClock.default.tempo = savedTempo;

// -------------------------- a newer notes-only version must not shadow the stamp
vNotes = RetuneArchive.write(name, 0, (retuneVersion: 2,
	midiEvents: [(timestamp: 0, dur: 1, midinote: 60)]));
assert.(vNotes == 1, "write appends (version 1 after the stamp)");
AudioItem.recordedMaps.removeAt(name.asSymbol, 0);
fDisk = AudioItem.prSrcOffset(ev, list, 2, 0);
assert.((sampleBeats.collect(fDisk) - memVals).abs.maxItem < 2e-3,
	"loadStamp skips newer versions without recordedAgainst");

// ------------------------------------------------- v1 migration at read
RetuneArchive.write(name, 3, (retuneVersion: 1,
	midiEvents: [(timestamp: 1.5, dur: 0.5, midinote: 60)]));
mig = RetuneArchive.read(name, 3, 0);
assertClose.(mig[\midiEvents].first[\srcStart], 1.5, "v1 read: srcStart = birth timestamp");
assertClose.(mig[\midiEvents].first[\srcDur], 0.5, "v1 read: srcDur = birth dur");
assert.(RetuneArchive.read(name, 9, 0).isNil, "read: missing version returns nil");
assert.(RetuneArchive.loadStamp(name, 3).isNil, "loadStamp: nil when no stamp version exists");

cleanup.();
AudioItem.roundTripLatency = savedRt;
h[\report].();
0.exit;
)
