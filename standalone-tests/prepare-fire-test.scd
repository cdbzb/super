// Headless regression test for the EventList prepare/fire split (§10,
// quantize-tempomap-project.md). Pure language — no server needed.
// Run: /Applications/SuperCollider.app/Contents/MacOS/sclang standalone-tests/prepare-fire-test.scd
(
var h = (thisProcess.nowExecutingPath.dirname +/+ "test-helpers.scd").load;
var assert = h[\assert];
var assertClose = { |a, b, msg, tol = 1e-9| h[\assertClose].(a, b, msg, tol) };
var epoch = 100;
var flat, tempo, child, parent, ftChild, ftParent, la, lb, orig, copied;
var sched, times, hits, missed, live, stopped, stress, bigSink, finish;
var ramp, rampEnv, ref, detHits, det, detT0, inv, invEnv;

"== EventList prepare/fire tests ==".postln;

// -- 1. flat list, beatDur 2: entries at epoch + when * beatDur ------------
flat = EventList.new;
flat.beatDur = 2;
flat.add(0, foo: 1); flat.add(1, foo: 2); flat.add(2, foo: 3);
sched = flat.prepare(epoch, 0);
times = sched.collect { |i| i[\time] }.asArray.sort;
assert.(sched.size == 3, "flat: 3 entries");
assertClose.(times[0], 100, "flat: beat 0 at epoch");
assertClose.(times[1], 102, "flat: beat 1 at epoch+2");
assertClose.(times[2], 104, "flat: beat 2 at epoch+4");

// -- 2. from gates and rebases -------------------------------------------
sched = flat.prepare(epoch, 1);
times = sched.collect { |i| i[\time] }.asArray.sort;
assert.(sched.size == 2, "from: beat-0 event dropped");
assertClose.(times[0], 100, "from: beat 1 lands on epoch");
assertClose.(times[1], 102, "from: beat 2 at epoch+2");

// -- 3. \tempoTrack multiplier consumed, not played ------------------------
tempo = EventList.new;
tempo.beatDur = 1;
tempo.add(0, tempoTrack: 2);
tempo.add(0, foo: 1); tempo.add(2, foo: 2);
sched = tempo.prepare(epoch, 0);
times = sched.collect { |i| i[\time] }.asArray.sort;
assert.(sched.size == 2, "tempoTrack: anchor event not scheduled");
assertClose.(times[0], 100, "tempoTrack: beat 0 at epoch");
assertClose.(times[1], 104, "tempoTrack: beat 2 at epoch+4 (2 s/beat)");

// -- 4. nested \eventList, own tempo ---------------------------------------
child = EventList.new;
child.beatDur = 0.5;
child.add(0, foo: 1); child.add(1, foo: 2); child.add(2, foo: 3);
parent = EventList.new;
parent.beatDur = 1;
parent.add((when: 4, newType: \eventList, eventList: child));
sched = parent.prepare(epoch, 0);
times = sched.collect { |i| i[\time] }.asArray.sort;
assert.(sched.size == 3, "nested own-tempo: 3 child entries");
assertClose.(times[0], 104, "nested own-tempo: child beat 0 at parent wall(4)");
assertClose.(times[1], 104.5, "nested own-tempo: child beatDur 0.5 kept");
assertClose.(times[2], 105, "nested own-tempo: child beat 2");

// -- 5. nested \eventList, followTrack: child rides parent tempo ----------
ftChild = EventList.new;
ftChild.beatDur = 0.25; // must be IGNORED under followTrack
ftChild.add(0, foo: 1); ftChild.add(1, foo: 2);
ftParent = EventList.new;
ftParent.beatDur = 1;
ftParent.add(0, tempoTrack: 2);
ftParent.add((when: 4, newType: \eventList, eventList: ftChild, followTrack: true));
sched = ftParent.prepare(epoch, 0);
times = sched.collect { |i| i[\time] }.asArray.sort;
assert.(sched.size == 2, "followTrack: 2 child entries");
assertClose.(times[0], 108, "followTrack: child beat 0 = parent beat 4 (2 s/beat)");
assertClose.(times[1], 110, "followTrack: child beat 1 = parent beat 5");

// -- 6. followTrack + rate (tempo: 2 => child beats at half parent spacing)
ftParent.events.pop;
ftParent.add((when: 4, newType: \eventList, eventList: ftChild, followTrack: true, tempo: 2));
sched = ftParent.prepare(epoch, 0);
times = sched.collect { |i| i[\time] }.asArray.sort;
assertClose.(times[0], 108, "followTrack rate: child beat 0 at parent beat 4");
assertClose.(times[1], 109, "followTrack rate: child beat 1 at parent beat 4.5");

// -- 7. followTrack from-trim: play from inside the child ------------------
ftParent.events.pop;
ftParent.add((when: 4, newType: \eventList, eventList: ftChild, followTrack: true));
sched = ftParent.prepare(epoch, 5);
times = sched.collect { |i| i[\time] }.asArray.sort;
assert.(sched.size == 1, "followTrack trim: pre-from child event dropped");
assertClose.(times[0], 100, "followTrack trim: child beat 1 lands on epoch");

// -- 8. cyclic nesting terminates ------------------------------------------
la = EventList.new;
lb = EventList.new;
la.add((when: 0, newType: \eventList, eventList: lb));
lb.add((when: 0, newType: \eventList, eventList: la));
sched = la.prepare(epoch, 0);
assert.(sched.size == 0, "cycle: guarded, empty schedule");

// -- 9. copyFrom keeps tempo + mix state -----------------------------------
orig = EventList.new;
orig.beatDur = 3;
orig.solo = [\bass];
orig.add(0, foo: 1);
copied = orig.copy;
assert.(copied.beatDur == 3, "copyFrom: beatDur kept");
assert.(copied.solo.notNil and: { copied.solo.includes(\bass) }, "copyFrom: solo kept");

// -- 9b. beatToWall: ramp segment over a tempoMap base ---------------------
// The cached sub-grid (prBuildRampSub/prRampSubAt) must agree with a fine
// brute-force integral of multiplier(x) * baseSecPerBeat(x).
ramp = EventList.new;
ramp.tempoMap = (
	timeAt: { |self, b| b + (0.05 * b * b) },
	beatAt: { |self, t| ((1 + (0.2 * t)).sqrt - 1) / 0.1 }
); // accelerating base clock, with its exact inverse
ramp.add(0, tempoTrack: 1);
ramp.add(4, tempoTrack: Env([1, 2], [8], \lin)); // ramp over beats 4..12
rampEnv = ramp.prPlayTempoEnv;
ref = { |b|
	var n = 4000, sum = 0;
	n.do { |i|
		var x0 = b * i / n, x1 = b * (i + 1) / n;
		sum = sum + (rampEnv.at((x0 + x1) / 2)
			* (ramp.tempoMap.timeAt(x1) - ramp.tempoMap.timeAt(x0)));
	};
	sum
};
[6, 10, 12, 14].do { |b|
	assertClose.(ramp.beatToWall(b, rampEnv), ref.(b),
		"rampSub: beatToWall(%) matches integral".format(b), 5e-3);
	assertClose.(ramp.wallToBeat(ramp.beatToWall(b, rampEnv), rampEnv), b,
		"rampSub: wallToBeat round trip at %".format(b), 1e-8);
};

// -- 9c. wallToBeat: exact flat/step/ramp inverses and held tail ----------
inv = EventList.new;
inv.beatDur = 0.5;
inv.add(0, tempoTrack: 2);
inv.add(4, tempoTrack: Env([2, 1], [4], \lin));
invEnv = inv.prPlayTempoEnv;
[0, 2, 4, 6, 8, 11].do { |b|
	assertClose.(inv.wallToBeat(inv.beatToWall(b, invEnv), invEnv), b,
		"wallToBeat: flat-base round trip at %".format(b), 1e-8);
};
assertClose.(inv.wallToBeat(-1, invEnv), 0, "wallToBeat: composed map clamps before zero");
assertClose.(inv.wallToBeat(inv.beatToWall(3), nil), 3,
	"wallToBeat: base-only round trip", 1e-9);

// -- 10. fire/stop (async): sends fire once, stop cancels ------------------
Event.addEventType(\testHit, { ~sink.add([~id, SystemClock.seconds]) });
hits = List[];
missed = List[];
live = EventList.new;
live.beatDur = 0.2;
// leadTime nil = adaptive: the epoch slides to prepare-end + latency, so the
// first send is always scheduled in the future and spacing stays exact.
live.add((when: 0, newType: \testHit, sink: hits, id: 1));
live.add((when: 1, newType: \testHit, sink: hits, id: 2));
live.play;
stopped = EventList.new;
stopped.beatDur = 0.1;
stopped.add((when: 0, newType: \testHit, sink: missed, id: 3));
stopped.play;
stopped.stop; // synchronous: gen bumped before any scheduled send runs

// -- 10b. leadTime set = deterministic: the epoch anchors to LOGICAL time, so
// the first SEND fires at exactly logical-t0 + leadTime (sound +latency later)
// — a co-evaluated (lag: leadTime) event coincides with the list's first beat.
// Run from a fresh clock callback (logical ~ physical) so this eval block's own
// drift doesn't eat the small test budget.
det = EventList.new;
det.beatDur = 0.1;
det.leadTime = 0.25;
detHits = List[];
det.add((when: 0, newType: \testHit, sink: detHits, id: 4));
SystemClock.sched(0.1, {
	detT0 = thisThread.seconds;
	det.play;
	nil
});

// -- 11. dense schedule: fire uses ONE clock slot, so a flattened \mi2-scale
// entry count must not hit "scheduler queue is full" (SystemClock's global
// queue is fixed-size; one schedAbs per entry overflowed it and went silent).
stress = EventList.new;
stress.beatDur = 0.0002; // 5000 events over ~1 s
bigSink = List[];
5000.do { |i| stress.events.add((when: i, type: \testHit, sink: bigSink, id: i)) };
stress.play;

finish = {
	assert.(hits.size == 2, "fire: both sends fired (got %)".format(hits.size));
	(hits.size == 2).if {
		assertClose.(hits[1][1] - hits[0][1], 0.2, "fire: beat spacing ~0.2 s", 0.06);
	};
	assert.(missed.size == 0, "stop: cancelled send never fired");
	assert.(detHits.size == 1, "leadTime: send fired");
	(detHits.size == 1).if {
		assertClose.(detHits[0][1] - detT0, 0.25,
			"leadTime: first send at exactly t0 + leadTime", 0.03);
	};
	assert.(bigSink.size == 5000, "dense: all 5000 sends fired (got %)".format(bigSink.size));
	h[\report].();
	0.exit;
};
SystemClock.sched(2.5, { finish.value; nil });
)
