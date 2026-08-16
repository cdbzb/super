// Headless regression test for the 2026-08-06 EventList work
// (quantize-tempomap-project.md §12h/§12i/§12j/§12k): the quantize family on
// EventList, alignTo, the align: nesting key, add()'s newType inference,
// itemAnchorBeat, addItem's align: nesting mode, and prBisectBeat's guard.
// Pure language — no server needed.
// Run: /Applications/SuperCollider.app/Contents/MacOS/sclang standalone-tests/align-test.scd
(
var h = (thisProcess.nowExecutingPath.dirname +/+ "test-helpers.scd").load;
var assert = h[\assert];
var assertClose = { |a, b, msg, tol = 1e-9| h[\assertClose].(a, b, msg, tol) };
var assertArr = { |a, b, msg, tol = 1e-9| h[\assertArr].(a, b, msg, tol) };
var epoch = 100;
// fixture builders (§12h fixtures are rebuilt per test — quantize is cumulative)
var mkClockList, walls, schedTimes, mkPlayer, mkNestParent, mkNestChild;
var q, qq, origWalls, w, res, err, total;
var parent, childA, childB, at1Walls;
var np, nc, tf, a1, own, a0, ah, g, tg, ag;
var list, snap, ep, p, psel, pfree, a, evd, added, sizeBefore, anchor, when;

"== align / EventList-quantize tests (§12h-§12k) ==".postln;

// uneven clock: anchor times [0, 1.0, 2.5, 3.2] at beats [0, 1, 2, 3]
mkClockList = {
	var l = EventList.new;
	l.beatDur = 1;
	l.tempoMap = AnchorTempoMap([0, 1.0, 2.5, 3.2], [0, 1, 2, 3]);
	l
};
walls = { |l, beats| var env = l.tempoEnv; beats.collect { |b| l.beatToWall(b, env) } };
schedTimes = { |l, from = 0| l.prepare(epoch, from).collect { |i| i[\time] }.asArray.sort };

// -- §12h quantize(0) is identity, quantize(1) is even, returns the list ------
q = mkClockList.();
origWalls = walls.(q, (0..3));
assertArr.(origWalls, [0, 1.0, 2.5, 3.2], "12h fixture: uneven walls as built");
res = q.quantize(0);
assert.(res === q, "quantize: returns the list (chainable)");
assertArr.(walls.(q, (0..3)), origWalls, "quantize(0): walls bit-identical", 1e-12);
q.quantize(1);
total = 3.2;
assertArr.(walls.(q, (0..3)), [0, total/3, total*2/3, total],
	"quantize(1): exactly even spacing, total preserved");

// -- §12h quantizeSpan straightens only [from, to] ----------------------------
q = mkClockList.();
q.quantizeSpan(0, 2, 1);
w = walls.(q, (0..3));
assertClose.(w[1], 1.25, "quantizeSpan(0,2,1): interior of span evened");
assertClose.(w[2], 2.5, "quantizeSpan: span end wall unchanged");
assertClose.(w[3], 3.2, "quantizeSpan: wall past the span untouched");

// -- §12h quantizeWindow: identity at 0, monotone + endpoint-pinned at 1 ------
q = mkClockList.();
q.quantizeWindow(0);
assertArr.(walls.(q, (0..3)), origWalls, "quantizeWindow(0): identity", 1e-12);
q.quantizeWindow(1, 2);
w = walls.(q, (0..3));
assert.(w.every { |x, i| (i == 0) or: { x > w[i - 1] } },
	"quantizeWindow(1): walls stay monotone");
assertClose.(w[0], 0, "quantizeWindow: first wall pinned");

// -- §12h nil map is a no-op; prMapEdit guards a non-map edit result ----------
qq = EventList.new;
qq.beatDur = 1;
assert.(qq.quantize(1) === qq, "quantize: nil-map list is a chainable no-op");
q = mkClockList.();
res = { q.prMapEdit { 42 } }.try;
assert.(res.isNil, "prMapEdit: non-MonoMap edit result throws");
assertArr.(walls.(q, (0..3)), origWalls, "prMapEdit: map untouched after the throw", 1e-12);

// -- §12i alignTo: amount 0 identity, amount 1 = parent grid, scale ----------
parent = mkClockList.();   // spans 1.0 / 1.5 / 0.7 s
childA = EventList.new;
childA.beatDur = 1;
childA.tempoMap = AnchorTempoMap([0, 0.8, 1.9, 3.1], [0, 1, 2, 3]);
origWalls = walls.(childA, (0..3));
res = childA.alignTo(parent, 0, 0);
assert.(res === childA, "alignTo: returns the list");
assertArr.(walls.(childA, (0..3)), origWalls, "alignTo(amount: 0): bit-identical", 1e-12);
childA.alignTo(parent, 0, 1);
at1Walls = walls.(parent, (0..3));
assertArr.(walls.(childA, (0..3)), at1Walls,
	"alignTo(amount: 1): child walls reproduce the parent grid (rubato included)");
childB = EventList.new;
childB.beatDur = 1;
childB.tempoMap = AnchorTempoMap([0, 0.8, 1.9], [0, 1, 2]);
childB.alignTo(parent, 0, 1, scale: 2);
assertClose.(walls.(childB, [1])[0], walls.(parent, [2])[0],
	"alignTo(scale: 2): child beat 1 spans parent beats 0..2");
qq = EventList.new;
assert.(qq.alignTo(parent) === qq, "alignTo: nil-map child is a no-op");

// -- §12j align: key — endpoints reduce exactly to the two branches -----------
mkNestChild = {
	var c = EventList.new;
	c.beatDur = 0.5;
	c.add(0, foo: 1); c.add(1, foo: 2); c.add(2, foo: 3);
	c
};
mkNestParent = { |nestEvent|
	var pa = EventList.new;
	pa.beatDur = 1;
	pa.add(0, tempoTrack: 2);   // 2 s/beat: follow and own placements differ
	pa.add(nestEvent);
	pa
};
nc = mkNestChild.();
tf = schedTimes.(mkNestParent.((when: 4, newType: \eventList, eventList: nc, followTrack: true)));
a1 = schedTimes.(mkNestParent.((when: 4, newType: \eventList, eventList: nc, align: 1)));
own = schedTimes.(mkNestParent.((when: 4, newType: \eventList, eventList: nc)));
a0 = schedTimes.(mkNestParent.((when: 4, newType: \eventList, eventList: nc, align: 0)));
assertArr.(tf, [108, 110, 112], "align fixture: followTrack times as expected");
assertArr.(own, [108, 108.5, 109], "align fixture: own-tempo times as expected");
assertArr.(a1, tf, "align: 1 bit-identical to followTrack: true", 1e-12);
assertArr.(a0, own, "align: 0 bit-identical to followTrack absent", 1e-12);
ah = schedTimes.(mkNestParent.((when: 4, newType: \eventList, eventList: nc, align: 0.5)));
assertArr.(ah, own.collect { |t, i| t.blend(tf[i], 0.5) },
	"align: 0.5 is the per-event blend of the two placements");
assert.(ah.every { |t, i| (t >= own[i]) and: { t <= tf[i] } },
	"align: 0.5 lies between the endpoints");

// -- §12j align: overrides a truthy followTrack (warns, uses the blend) -------
res = schedTimes.(mkNestParent.((when: 4, newType: \eventList, eventList: nc,
	followTrack: true, align: 0.5)));
assertArr.(res, ah, "align + truthy followTrack: align decides", 1e-12);

// -- §12j mid-list cut: bisected cut agrees with the closed-form one ----------
res = schedTimes.(mkNestParent.((when: 4, newType: \eventList, eventList: nc, align: 1)), 5);
tf = schedTimes.(mkNestParent.((when: 4, newType: \eventList, eventList: nc, followTrack: true)), 5);
assertArr.(res, tf, "mid-list align: 1 == followTrack cut (bisect vs closed form)", 1e-6);

// -- §12j groove composes with align: at both endpoints -----------------------
g = Groove.swing(2, 2);
tg = schedTimes.(mkNestParent.((when: 4, newType: \eventList, eventList: nc, groove: g)));
ag = schedTimes.(mkNestParent.((when: 4, newType: \eventList, eventList: nc, groove: g, align: 0)));
assertArr.(ag, tg, "groove + align: 0 == groove alone", 1e-12);
tg = schedTimes.(mkNestParent.((when: 4, newType: \eventList, eventList: nc, groove: g, followTrack: true)));
ag = schedTimes.(mkNestParent.((when: 4, newType: \eventList, eventList: nc, groove: g, align: 1)));
assertArr.(ag, tg, "groove + align: 1 == groove + followTrack", 1e-12);

// -- §12i x §12j: the bake and the key agree (scale 2 == rate 1/2) -------------
// alignTo(at: 4, amount: 1, scale: 2) pins child beat k at parent beat 4 + 2k;
// the play-time twin is align: 1 with tempo: 0.5 (rate = tempo/stretch = 1/2).
childA = mkNestChild.();
childA.tempoMap = AnchorTempoMap([0, 0.8, 1.9], [0, 1, 2]);
np = mkNestParent.((when: 4, newType: \eventList, eventList: childA));   // plain nest
childA.alignTo(np, 4, 1, scale: 2);
res = schedTimes.(np);
assertArr.(res, [108, 112, 116],
	"alignTo bake nested plain: child beats land on parent beats 4, 6, 8 (2 s/beat)");
nc = mkNestChild.();
nc.tempoMap = AnchorTempoMap([0, 0.8, 1.9], [0, 1, 2]);
tf = schedTimes.(mkNestParent.((when: 4, newType: \eventList, eventList: nc,
	align: 1, tempo: 0.5)));
assertArr.(tf, res, "align: 1 + tempo: 0.5 reproduces the alignTo(scale: 2) bake");

// -- add() infers newType: \eventList from an eventList: key -------------------
np = EventList.new;
np.beatDur = 1;
nc = mkNestChild.();
evd = np.add((when: 4, eventList: nc));
assert.(evd[\type] == \eventList, "add: newType inferred from eventList: key");
assert.(schedTimes.(np).size == 3, "add inference: nested child expands in prepare");

// -- itemAnchorBeat: no map == itemStartBeat; a t0 map shifts by t0 ------------
mkPlayer = { |stamps, recEpoch, playEpoch|
	var evts = List.newFrom(stamps.collect { |t, i|
		(midicmd: \noteOn, type: \mk, midinote: 60 + i, amp: 0.5,
			timestamp: t, sustain: 0.25, dur: 0.25)
	});
	MIDIItemPlayer(evts, nil).recordEpoch_(recEpoch).recordPlayEpoch_(playEpoch)
};
snap = EventList.new;
snap.beatDur = 1;
ep = (seconds: 50, fromBeat: 0, tempoEnv: snap.tempoEnv, list: snap);
list = EventList.new;
list.beatDur = 1;
pfree = mkPlayer.([0, 0.5, 1.5], 52.3, ep);   // take start sounded 2.3 s after beat 0
assertClose.(list.itemStartBeat(pfree), 2.3, "itemStartBeat: record-button beat");
assertClose.(list.itemAnchorBeat(pfree), 2.3,
	"itemAnchorBeat: no selection -> equals itemStartBeat");
psel = mkPlayer.([0, 0.5, 1.5], 52.3, ep);
psel.currentSelection = (indices: [1, 2]);     // first anchor = note at 0.5 s => t0 0.5
assertClose.(list.itemAnchorBeat(psel), 2.8,
	"itemAnchorBeat: selection with t0 0.5 -> itemStartBeat + t0");
assert.(list.itemAnchorBeat(mkPlayer.([0, 1], 52.3, nil)).isNil,
	"itemAnchorBeat: nil without a recordPlayEpoch");

// -- §12k addItem align: nests, blends the entry, tags voice -------------------
Event.addEventType(\testHit, { });
sizeBefore = list.events.size;
a = list.addItem(pfree, align: 0.5, voice: \lead);
assert.(a.isKindOf(Array) and: { a.size == 1 }, "addItem align: one-element Array");
evd = a[0];
assert.(evd[\type] == \eventList, "addItem align: nested event type");
assertClose.(evd[\align], 0.5, "addItem align: align stored on the event");
assert.(evd[\eventList].isKindOf(EventList), "addItem align: child is an EventList");
assert.(EventList.all.values.includes(evd[\eventList]).not,
	"addItem align: child is anonymous (not registered)");
assert.(evd[\eventList].events.size == 3, "addItem align: child got all 3 notes");
assert.(evd[\eventList].events.every { |e| e[\voice] == \lead },
	"addItem align: voice tag applied to child events");
// entry blend: anchor 2.3 -> blend(2.3, round 2.0, 0.5) = 2.15
assertClose.(evd[\when], 2.15, "addItem align: entry beat blended toward the grid");
assert.(list.events.size == (sizeBefore + 1), "addItem align: ONE event inserted");

// explicit at: wins over the computed entry
a = list.addItem(pfree, at: 7, align: 1);
assertClose.(a[0][\when], 7, "addItem align: explicit at: wins");

// selection t0 flows into the entry: anchor 2.8 -> blend(2.8, 3.0, 1) = 3.0
a = list.addItem(psel, align: 1);
assertClose.(a[0][\when], 3.0, "addItem align: t0 anchor rounds onto the grid at align 1");

// no epoch + no at: warns and inserts nothing
sizeBefore = list.events.size;
res = list.addItem(mkPlayer.([0, 1], 52.3, nil), align: 0.5);
assert.(res.isKindOf(String), "addItem align: no epoch -> warn string");
assert.(list.events.size == sizeBefore, "addItem align: nothing inserted on the warn path");

// -- prBisectBeat: unreachable cut warns, child schedules empty ----------------
nc = EventList.new;
nc.beatDur = 0.5;
nc.add(0, foo: 1);   // child is 0 beats long past its only event
np = EventList.new;
np.beatDur = 1;
np.add((when: 0, newType: \eventList, eventList: nc, align: 0.5));
res = np.prepare(epoch, 50);   // cut 50 beats past a sub-second child
assert.(res.size == 0, "prBisectBeat: unreachable cut -> empty schedule (warned)");

h[\report].();
0.exit;
)
