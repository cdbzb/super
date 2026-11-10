// A nested \eventList WITHOUT followTrack plays on its own clock. Playing the
// parent from past the insert point must start the child partway in — the wall
// seconds already elapsed since its insert — not place the whole child before
// the epoch (fire then sent every past entry at once). Pure language.
// Run: sclang standalone-tests/nested-own-tempo-from-test.scd
(
var h = (thisProcess.nowExecutingPath.dirname +/+ "test-helpers.scd").load;
var assert = h[\assert], times = h[\assertArr];
var child, parent, timesFrom;

"== nested own-tempo from: tests ==".postln;
child = EventList(\zzzOwnTempoChild, \func);
child.beatDur = 1;   // child's own clock: 1 s per child beat
[0, 1, 2, 3].do { |b| child.add(b, func: { }) };

parent = EventList.new(nil, \eventList);
parent.beatDur = 0.5; // parent: 0.5 s per beat
parent.events.add((when: 2, type: \eventList, eventList: child));

timesFrom = { |from, ev|
	var l = EventList.new(nil, \eventList);
	l.beatDur = 0.5;
	l.events.add(ev ?? { (when: 2, type: \eventList, eventList: child) });
	l.prepare(100, from).collect(_[\time]).asArray.sort
};

times.(timesFrom.(0), [101, 102, 103, 104],
	"from before the insert: child on its own clock from parent beat 2 (wall 1 s)");
times.(timesFrom.(4), [100, 101, 102],
	"from past the insert: 1 s already elapsed, child starts at its beat 1");
assert.(timesFrom.(4).every { |t| t >= 100 }, "nothing scheduled before the epoch");
times.(timesFrom.(5), [100.5, 101.5],
	"from mid child-beat: next child events land after the remaining fraction");
times.(timesFrom.(20), [], "from past the whole child: nothing");
times.(timesFrom.(4, (when: 2, type: \eventList, eventList: child, toBeat: 1)), [],
	"from past a toBeat: cut: nothing");
times.(timesFrom.(4, (when: 2, type: \eventList, eventList: child, fromBeat: 1)), [100, 101],
	"fromBeat: trim plus elapsed: starts at child beat 2");

EventList.all.removeAt(\zzzOwnTempoChild);
h[\report].();
Server.all.do { |sv| sv.sendQuit = false };
0.exit;
)
