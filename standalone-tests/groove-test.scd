// Headless regression test for Groove (beat->beat reparametrization) and the
// `groove:` key on a nested \eventList — quantize-tempomap-project.md.
// Pure language: schedules only inert \testHit events, never touches the server.
// Run: /Applications/SuperCollider.app/Contents/MacOS/sclang standalone-tests/groove-test.scd
(
var h = (thisProcess.nowExecutingPath.dirname +/+ "test-helpers.scd").load;
var assert = h[\assert];
var assertClose = { |a, b, msg, tol = 1e-6| h[\assertClose].(a, b, msg, tol) };
var assertArr = { |a, b, msg, tol = 1e-6| h[\assertArr].(a, b, msg, tol) };
var g, sp, child, parent, direct, mt;
var monotone, roundTrips, timesOf;

"== Groove tests ==".postln;

Event.addEventType(\testHit, { });   // inert send target

monotone = { |gg, lo = -3, hi = 9, n = 600|
	var prev = -1e9, ok = true;
	(n + 1).do { |i|
		var y = gg.mapBeat(lo + ((hi - lo) * i / n));
		(y <= prev).if { ok = false };
		prev = y;
	};
	ok
};
roundTrips = { |gg, tol = 1e-6|
	var ok = true;
	40.do { |i|
		var b = -2 + (i * 0.31);
		((gg.unmapBeat(gg.mapBeat(b)) - b).abs > tol).if { ok = false };
	};
	ok
};
timesOf = { |list, from = 0|
	list.prepare(100, from).collect { |i| i[\time] }.asArray.sort
};

// ---------------------------------------------------------------- identity
g = Groove.identity;
assertClose.(g.mapBeat(3.7), 3.7, "identity: amount 0 is a no-op");
assert.(g.isIdentity, "identity: reports isIdentity");
assertArr.(g.mapSpans([1, 1, 2]), [1, 1, 2], "identity: spans unchanged");

// ---------------------------------------------------------------- swing values
g = Groove.swing(1.5);            // amount 0.2 over 2 beats
assertClose.(g.mapBeat(0), 0, "swing: downbeat unmoved");
assertClose.(g.mapBeat(1), 1.2, "swing 1.5: offbeat lands at 1.2");
assertClose.(g.mapBeat(2), 2, "swing: one period advances exactly one period");
sp = g.mapSpans([1, 1], 0);
assertArr.(sp, [1.2, 0.8], "swing 1.5: spans are 60:40");
assertClose.(sp[0] / sp[1], 1.5, "swing: span ratio round-trips to the ratio argument");
sp = Groove.swing(2).mapSpans([1, 1], 0);
assertClose.(sp[0] / sp[1], 2, "swing 2 (triplet): span ratio is 2");

// ---------------------------------------------------------------- shape laws
#[\square, \sine, \tri].do { |shape|
	var gg = Groove.modulate(2, 0.3, shape);
	assertClose.(gg.mapBeat(0), 0, "%: origin fixed".format(shape));
	assertClose.(gg.mapBeat(2) - gg.mapBeat(0), 2,
		"%: period preserved — no net tempo drift".format(shape));
	assertClose.(gg.mapBeat(7) - gg.mapBeat(5), 2,
		"%: period preserved away from the origin".format(shape));
	assert.(monotone.(gg), "%: strictly monotone (invertible)".format(shape));
	assert.(roundTrips.(gg), "%: unmapBeat inverts mapBeat".format(shape));
	assertClose.(gg.mapSpans([1, 1]).sum, 2, "%: spans sum to the period".format(shape));
	assert.(gg.mapSpans([1, 1, 1]).size == 3, "%: mapSpans preserves length".format(shape));
};

// ---------------------------------------------------------------- phase
g = Groove.modulate(2, 0.3, \sine, 0.25);
assertClose.(g.mapBeat(0), 0, "phase: origin still fixed");
assertClose.(g.mapBeat(2) - g.mapBeat(0), 2, "phase: period still preserved");
assert.(monotone.(g), "phase: still monotone");
assert.(roundTrips.(g), "phase: still invertible");
assert.((g.mapBeat(1) - Groove.modulate(2, 0.3, \sine, 0).mapBeat(1)).abs > 1e-3,
	"phase: actually shifts the shape");

// ---------------------------------------------------------------- guards
g = Groove.modulate(2, 1.5, \sine);   // warns, clips below 1
assert.(g.amount.abs < 1, "guard: |amount| >= 1 clipped below 1");
assert.(monotone.(g), "guard: clipped amount is still monotone");
g = Groove.modulate(-1, 0.2, \sine);  // warns, falls back to 2
assert.(g.periodBeats > 0, "guard: non-positive periodBeats rejected");

// ---------------------------------------------------------------- nesting
child = EventList.new;
child.beatDur = 1;
[0, 1, 1.4, 2, 3].do { |b| child.events.add((when: b, type: \testHit)) };

parent = EventList.new;
parent.beatDur = 1;
parent.events.add((when: 0, type: \eventList, eventList: child, followTrack: true));
assertArr.(timesOf.(parent), [100, 101, 101.4, 102, 103],
	"nest: no groove key is a no-op");

parent.events[0][\groove] = Groove.swing(1.5);
assertArr.(timesOf.(parent), [100, 101.2, 101.52, 102, 103.2],
	"nest: groove displaces child beats on the child's own grid");

// the same positions placed directly in the parent — nesting with a groove must
// agree with hand-placing the grooved beats
direct = EventList.new;
direct.beatDur = 1;
[0, 1.2, 1.52, 2, 3.2].do { |b| direct.events.add((when: b, type: \testHit)) };
assertArr.(timesOf.(parent), timesOf.(direct),
	"nest: grooved child == events hand-placed at grooved beats");

// ---------------------------------------------------------------- rubato parent
// a parent whose own tempo bends, with a swung child: the two compose, and the
// parent's bend must survive untouched
mt = TempoMap([1, 1, 1, 1], [1, 1.5, 0.75, 1]);
parent.tempoMap = mt;
direct.tempoMap = mt;
assertArr.(timesOf.(parent), timesOf.(direct),
	"rubato: groove composes with a bending parent map");
assert.((timesOf.(parent) != timesOf.(direct.copy.tempoMap_(nil))),
	"rubato: the parent's tempo bend actually changes the result");
parent.tempoMap = nil;

// ---------------------------------------------------------------- mid-list from
// The cut is a GROOVED child beat, so `from` must resolve through unmapBeat. The
// event at child beat 1.4 grooves to 1.52 and must SURVIVE a cut at 1.5 — it is
// dropped if the trim forgets the inverse (straight 1.5 > 1.4).
// prepare rebases so beat `from` sits at the epoch (place subtracts fromWall), so
// the surviving times are the full-playback ones shifted down by the cut.
assertArr.(timesOf.(parent, 1.5), [100.02, 100.5, 101.7],
	"trim: mid-list from keeps events whose GROOVED position is past the cut");
assertArr.(timesOf.(parent, 1.5), timesOf.(parent).select { |t| t >= 101.5 } - 1.5,
	"trim: surviving events keep their full-playback spacing");
assert.(timesOf.(parent, 1.5).size == 3,
	"trim: the 1.4 event (grooves to 1.52) survives a cut at 1.5 — inverse applied");

h[\report].();
0.exit;
)
