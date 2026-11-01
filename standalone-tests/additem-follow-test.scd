// addItem(take, followTrack: ...) on a MIDI take: ONE \mi2 event instead of
// flattened notes, so the follow decision is made at play time and a later
// edit to the list's clock re-places it per the source (EventList.prAddItemMi2).
// followTrack: false = recorded seconds (sealed \mi2), \list / \stamp follow.
// Pure language: fake players, inert \testHit, prepare() only.
// Run: /Applications/SuperCollider.app/Contents/MacOS/sclang standalone-tests/additem-follow-test.scd
(
var h = (thisProcess.nowExecutingPath.dirname +/+ "test-helpers.scd").load;
var assert = h[\assert];
var assertClose = { |a, b, msg, tol = 1e-6| h[\assertClose].(a, b, msg, tol) };
var assertArr = { |a, b, msg, tol = 1e-6| h[\assertArr].(a, b, msg, tol) };
var mkPlayer = { |stamps, epoch|
	var evts = List.newFrom(stamps.collect { |t, i|
		(midicmd: \noteOn, type: \mk, midinote: 60 + i, amp: 0.5,
			timestamp: t, sustain: 0.25, dur: 0.25)
	});
	MIDIItemPlayer(evts, nil).recordEpoch_(epoch)
};
var mkList, l, ep, p, added, ev, times, sizeBefore;

"== addItem followTrack tests ==".postln;
Event.addEventType(\testHit, { });

// list at 2 beats/s; the take started sounding 2 s after beat 0 (beat 4),
// notes 0.5 s apart (one beat each at the recording tempo)
mkList = {
	var x = EventList.new;
	x.beatDur = 0.5;
	x.add(0, type: \testHit);
	x.leadTime = 0.05;
	x.play(0);
	x
};
l = mkList.();
ep = l.lastPlayEpoch;
p = mkPlayer.([0, 0.5, 1], ep[\seconds] + 2);

// -- flattened path unchanged without followTrack
added = l.addItem(p);
assertArr.(added.collect(_[\when]).asArray, [4, 5, 6], "no followTrack: flattened notes at recorded beats");

// -- followTrack: false -> one sealed \mi2 at the take's start
l = mkList.(); ep = l.lastPlayEpoch; p = mkPlayer.([0, 0.5, 1], ep[\seconds] + 2);
sizeBefore = l.events.size;
added = l.addItem(p, voice: \lead, followTrack: false, toBeat: 9, params: (coef: 0.2));
assert.(added.size == 1, "followTrack: one event returned");
ev = added[0];
assert.(l.events.size == (sizeBefore + 1), "followTrack: one event inserted");
assert.(ev[\type] == \mi2, "followTrack: event is \\mi2");
assert.(ev[\player] === p, "followTrack: event carries the player");
assertClose.(ev[\when], 4, "followTrack: when = recorded beat of the take's start");
assert.(ev[\followTrack] == false, "followTrack: value rides into the event");
assert.(ev[\voice] == \lead, "followTrack: voice tag applied");
assert.(ev[\toBeat] == 9 and: { ev[\params][\coef] == 0.2 }, "followTrack: other keywords pass through");

// edit the clock AFTER adding: 1 s/beat. toBeat: puts \mi2 on its follow path
// at align 0 (rangeOnly) — as performed: beat 4's new wall time + 0, 0.5, 1 s
l.beatDur = 1;
times = l.prepare(100, 0).select { |i| i[\label] == \mi2 }.collect(_[\time]).asArray.sort;
assertArr.(times, [104, 104.5, 105], "followTrack: false + toBeat: recorded seconds from beat 4 on the edited clock");

// plain followTrack: false (no range): sealed \mi2, one send, plays its own seconds
l = mkList.(); ep = l.lastPlayEpoch; p = mkPlayer.([0, 0.5, 1], ep[\seconds] + 2);
l.addItem(p, followTrack: false);
l.beatDur = 1;
times = l.prepare(100, 0).select { |i| i[\label] != \event }.collect(_[\time]).asArray;
assert.(times.size == 1, "followTrack: false: one sealed \\mi2 send");
assertClose.(times[0], 104, "followTrack: false: starts at beat 4 on the edited clock");

// -- \stamp: recorded beats re-placed on the edited clock: 4, 5, 6 -> 104, 105, 106
l = mkList.(); ep = l.lastPlayEpoch; p = mkPlayer.([0, 0.5, 1], ep[\seconds] + 2);
p.recordPlayEpoch = ep;
added = l.addItem(p, followTrack: \stamp);
assertClose.(added[0][\when], 4, "\\stamp: when = recorded beat of start");
l.beatDur = 1;
times = l.prepare(100, 0).select { |i| i[\label] == \mi2 }.collect(_[\time]).asArray.sort;
assertArr.(times.keep(3), [104, 105, 106], "\\stamp: recorded beats follow the edited clock");

// -- \list: recorded speed through the live clock: 0, 0.5, 1 s at 1 s/beat
l = mkList.(); ep = l.lastPlayEpoch; p = mkPlayer.([0, 0.5, 1], ep[\seconds] + 2);
added = l.addItem(p, followTrack: \list);
l.beatDur = 1;
times = l.prepare(100, 0).select { |i| i[\label] == \mi2 }.collect(_[\time]).asArray.sort;
assertArr.(times.keep(3), [104, 104.5, 105], "\\list: recorded speed from beat 4 on the live clock");

// -- numeric at: and offset:
l = mkList.(); p = mkPlayer.([0, 0.5, 1], 0);
added = l.addItem(3, p, followTrack: false, offset: 0.5);
assertClose.(added[0][\when], 3.5, "at: 3 + offset: 0.5");

// -- Symbol.addItem names the event after the track
l = mkList.(); ep = l.lastPlayEpoch; p = mkPlayer.([0, 0.5, 1], ep[\seconds] + 2);
l.use { added = \lick.addItem(p, followTrack: false) };
assert.(added[0][\name] == \lick, "Symbol.addItem: event named after the track");

// -- no epoch: refused with a warning String
added = EventList.new.addItem(mkPlayer.([0], 0), followTrack: false);
assert.(added.isString, "no epoch, at: nil: refused");

h[\report].();
0.exit;
)
