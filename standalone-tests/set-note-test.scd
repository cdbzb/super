// MIDIItemPlayer.setNote: edit the nth note, retarget its paired noteOff on a pitch change.
// Pure language, no server. No 0.exit, so it can run in the live session:
//   bin/sctest standalone-tests/set-note-test.scd
(
var h = (thisProcess.nowExecutingPath.dirname +/+ "test-helpers.scd").load;
var assert = h[\assert];
var throws = { |fn| var t = false; try { fn.value } { t = true }; t };
var on  = { |ts, n| (midicmd: \noteOn,  type: \mk,    timestamp: ts, midinote: n, dur: 1, amp: 0.5) };
var off = { |ts, n| (midicmd: \noteOff, type: \mkOff, timestamp: ts, midinote: n) };
// note 0: 60, note 1: 62, note 2: 60 again (same pitch as note 0, after its release)
var evs = [on.(0, 60), off.(0.9, 60), on.(1, 62), off.(1.9, 62), on.(2, 60), off.(2.9, 60)];
var p = MIDIItemPlayer(evs, nil);
var q, r, pitches;

"== setNote tests ==".postln;

q = p.setNote(0, \midinote, 64);
pitches = { |pl| pl.midiEvents.collect { |e| e.midinote } };
assert.(pitches.(q) == [64, 64, 62, 62, 60, 60], "setNote: noteOn and its own noteOff move together");
assert.(pitches.(p) == [60, 60, 62, 62, 60, 60], "setNote: receiver untouched");

q = p.setNote(2, \midinote, 65);
assert.(pitches.(q) == [60, 60, 62, 62, 65, 65],
	"setNote: a later note of the same pitch takes its own noteOff, not the first note's");

q = p.setNote([0, 1], (midinote: 70, amp: 0.1));
assert.(pitches.(q) == [70, 70, 70, 70, 60, 60], "setNote: an array of indices, an Event of changes");
assert.(q.midiEvents[0].amp == 0.1 and: { q.midiEvents[2].amp == 0.1 }, "setNote: non-pitch keys land on the noteOn");
assert.(q.midiEvents[1][\amp].isNil, "setNote: non-pitch keys do not touch the noteOff");

q = p.setNote(1, \amp, 0.9);
assert.(pitches.(q) == pitches.(p), "setNote: a non-pitch change leaves the noteOff alone");
assert.(q.midiEvents[2].amp == 0.9, "setNote: amp changed on note 1");

q = p.setNote([0, 2], midinote: [33, 34]);
assert.(pitches.(q) == [33, 33, 62, 62, 34, 34], "setNote: keyword with a parallel Array pairs index to value");
q = p.setNote([0, 2], midinote: [33, 34], amp: [2, 3]);
assert.(pitches.(q) == [33, 33, 62, 62, 34, 34], "setNote: two parallel keywords, pitches (noteOffs follow)");
assert.(q.midiEvents[0].amp == 2 and: { q.midiEvents[4].amp == 3 }, "setNote: two parallel keywords, amps pair by position");
q = p.setNote([0, 2], \midinote, [41, 42]);
assert.(pitches.(q) == [41, 41, 62, 62, 42, 42], "setNote: positional key with a parallel Array");
q = p.setNote([0, 2], midinote: 50);
assert.(pitches.(q) == [50, 50, 62, 62, 50, 50], "setNote: a scalar value goes to every listed note");
q = p.setNote([0, 1], (midinote: [70, 71], amp: 0.2));
assert.(pitches.(q) == [70, 70, 71, 71, 60, 60] and: { q.midiEvents[0].amp == 0.2 and: { q.midiEvents[2].amp == 0.2 } },
	"setNote: Event form pairs arrays and broadcasts scalars together");

assert.(throws.({ p.setNote(3, \midinote, 60) }), "setNote: a note past the end throws");

(h[\report].() == 0).if { "set-note: all passed".postln } { "set-note: FAILURES".postln };
)
