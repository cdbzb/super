// Headless regression test for §9a step 3 (EventList.captureFragment) and the
// §9b insertion primitive (EventList.addItem) — quantize-tempomap-project.md.
// Pure language: plays only inert \testHit events.
// Run: /Applications/SuperCollider.app/Contents/MacOS/sclang standalone-tests/capture-fragment-test.scd
(
var h = (thisProcess.nowExecutingPath.dirname +/+ "test-helpers.scd").load;
var assert = h[\assert];
var assertClose = { |a, b, msg, tol = 1e-6| h[\assertClose].(a, b, msg, tol) };
var assertArr = { |a, b, msg, tol = 1e-6| h[\assertArr].(a, b, msg, tol) };
// fake take player: note stamps in seconds-from-record + the wall sound epoch
var mkPlayer = { |stamps, epoch|
	var evts = List.newFrom(stamps.collect { |t, i|
		(midicmd: \noteOn, type: \mk, midinote: 60 + i, amp: 0.5,
			timestamp: t, sustain: 0.25, dur: 0.25)
	});
	MIDIItemPlayer(evts, nil).recordEpoch_(epoch)
};
var flat, tempo, ep, added, whens, sizeBefore, finish;

"== captureFragment / addItem tests ==".postln;

Event.addEventType(\testHit, { });   // inert send target

// -- 1. flat list: recorded seconds == list beats ---------------------------
flat = EventList.new;
flat.beatDur = 1;
flat.add(0, type: \testHit);
flat.leadTime = 0.05;
flat.play(0);
ep = flat.lastPlayEpoch;
assert.(ep.notNil, "flat: lastPlayEpoch set by play");
sizeBefore = flat.events.size;
// take whose first note SOUNDED exactly 2 s after beat 0 sounded
added = flat.captureFragment(mkPlayer.([0, 0.5, 1.25], ep[\seconds] + 2), voice: \lead);
whens = added.collect(_[\when]).asArray;
assertArr.(whens, [2, 2.5, 3.25], "flat: sound offsets land as beats");
assert.(flat.events.size == (sizeBefore + 3), "flat: events inserted into list");
assert.(added.every { |e| e[\voice] == \lead }, "flat: voice tag applied");
assert.(added.every { |e| e[\latency] == Server.default.latency }, "flat: latency stamped");
assert.(added.every { |e| e[\type] == \mk }, "flat: event types preserved");

// -- 2. beatDur scales the conversion ---------------------------------------
flat = EventList.new;
flat.beatDur = 2;
flat.add(0, type: \testHit);
flat.leadTime = 0.05;
flat.play(0);
ep = flat.lastPlayEpoch;
added = flat.captureFragment(mkPlayer.([0, 1], ep[\seconds] + 3));
whens = added.collect(_[\when]).asArray;
assertArr.(whens, [1.5, 2], "beatDur 2: 3 s + [0,1] s -> beats [1.5,2]");

// -- 3. tempoTrack env: wall inverts through the composed clock -------------
tempo = EventList.new;
tempo.beatDur = 1;
tempo.add(0, tempoTrack: 2);   // 2 s/beat
tempo.add(0, type: \testHit);
tempo.leadTime = 0.05;
tempo.play(0);
ep = tempo.lastPlayEpoch;
added = tempo.captureFragment(mkPlayer.([0, 1], ep[\seconds] + 3));
whens = added.collect(_[\when]).asArray;
assertArr.(whens, [1.5, 2], "tempoTrack 2: 3 s + [0,1] s -> beats [1.5,2]");

// -- 4. play from mid-list: epoch anchors at fromBeat ------------------------
flat = EventList.new;
flat.beatDur = 1;
flat.add(0, type: \testHit); flat.add(2, type: \testHit);
flat.leadTime = 0.05;
flat.play(2);
ep = flat.lastPlayEpoch;
assertClose.(ep[\fromBeat], 2, "from: epoch records fromBeat");
// sound 1 s after beat 2 sounded -> beat 3
added = flat.captureFragment(mkPlayer.([0], ep[\seconds] + 1));
assertClose.(added[0][\when], 3, "from: capture lands relative to fromBeat");

// -- 5. epoch survives later mutation (capture-after-requantize) ------------
flat.beatDur = 100;   // mutate AFTER play; capture must use the epoch's env
added = flat.captureFragment(mkPlayer.([0], ep[\seconds] + 1));
assertClose.(added[0][\when], 3, "mutation: capture still uses lastPlayEpoch env");

// -- 6. guards ----------------------------------------------------------------
flat = EventList.new;
flat.beatDur = 1;
added = flat.captureFragment(mkPlayer.([0], 0));
assert.(added.isKindOf(String), "guard: no lastPlayEpoch -> warn, no insert");
assert.(flat.events.isNil or: { flat.events.size == 0 } or: {
	flat.events.every { |e| e[\when].isNil.not }
}, "guard: list untouched by refused capture");
flat.add(0, type: \testHit); flat.leadTime = 0.05; flat.play(0);
added = flat.captureFragment(mkPlayer.([0], nil));
assert.(added.isKindOf(String), "guard: nil recordEpoch -> warn, no insert");

// -- 7. addItem: flat placement at a beat ------------------------------------
flat = EventList.new;
flat.beatDur = 1;
sizeBefore = (flat.events ? []).size;
added = flat.addItem(mkPlayer.([1, 1.5, 2.25], nil), at: 4, voice: \fill);
whens = added.collect(_[\when]).asArray;
assertArr.(whens, [4, 4.5, 5.25], "addItem: timestamps rebased to item start + at");
assert.(flat.events.size == (sizeBefore + 3), "addItem: events inserted");
assert.(added.every { |e| e[\voice] == \fill }, "addItem: voice tag applied");

h[\report].();
0.exit;
)
