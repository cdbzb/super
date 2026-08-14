(
var e, r, ok, near, get, flat, cyc, threw, f, fired, ev, g, seen, forked, forked2, h, pv, pv2;
near = { |a, b, tol = 1e-6| (a - b).abs < tol };
ok = { |label, cond| ("%  %".format(cond.if("PASS","FAIL"), label)).postln };
get = { |evts, name, key| evts.detect { |x| x[\name] == name }[key] };

"=== SENTINEL START ===".postln;

// 8 beats: first 4 at 1 s/beat, last 4 at 0.5 s/beat
e = EventList(nil, \note);
e.tempoMap = TempoMap(1!8, [1,1,1,1,0.5,0.5,0.5,0.5]);

e.add(0, name: \a, midinote: 60, spb: { |t| t.secPerBeat });
e.add(6, name: \b, midinote: 62, spb: { |t| t.secPerBeat });
e.add(6, name: \c, midinote: 64, w: { ~wall }, two: { ~secsFor.(2) }, back: { ~beatsFor.(1) });
e.add(2, name: \d, midinote: 65, sib: { |t| t.midinote + 1 });
e.add(2, name: \z, midinote: 67, zero: { 99 }, extra: { \untouched }, filter: { |p| p });
// multi-`when` event: getSlice still resolves zero-arg funcs at ADD time, frozen
e.add([0, 1, 2], name: \s, midinote: { ~x + 60 });

r = e.resolvedEvents;

// --- local tempo at the event's own beat -----------------------------------
ok.("secPerBeat at beat 0 == 1",   near.(get.(r, \a, \spb), 1));
ok.("secPerBeat at beat 6 == 0.5", near.(get.(r, \b, \spb), 0.5));

// --- absolute + rebased reads ----------------------------------------------
// wall(6) = 4*1 + 2*0.5 = 5
ok.("~wall at beat 6 == 5",        near.(get.(r, \c, \w), 5));
// wall(8) - wall(6) = 6 - 5 = 1
ok.("~secsFor.(2) == 1",           near.(get.(r, \c, \two), 1));
// 1 second forward from wall 5 => 2 beats at 0.5 s/beat
ok.("~beatsFor.(1) == 2",          near.(get.(r, \c, \back), 2));

// --- siblings ---------------------------------------------------------------
ok.("sibling ~midinote visible",   get.(r, \d, \sib) == 66);

// --- arity-agnostic + exclusion ---------------------------------------------
ok.("zero-arg Function resolves",  get.(r, \z, \zero) == 99);
ok.("lazyExclude \\extra untouched",  get.(r, \z, \extra).isKindOf(Function));
ok.("lazyExclude \\filter untouched", get.(r, \z, \filter).isKindOf(Function));
ok.("stored event not mutated",    e.events.detect { |x| x[\name] == \a }[\spb].isKindOf(Function));

// --- getSlice add-time path unchanged ---------------------------------------
ok.("getSlice still freezes ~x",
	e.events.select { |x| x[\name] == \s }.collect { |x| x[\midinote] } == [60, 61, 62]);

// --- composes with \tempoTrack ---------------------------------------------
// multiplier 2 from beat 0 => every beat takes twice as long
e.add(0, name: \tt, tempoTrack: 2);
r = e.resolvedEvents;
ok.("tempoTrack composes (beat 0)", near.(get.(r, \a, \spb), 2));
ok.("tempoTrack composes (beat 6)", near.(get.(r, \b, \spb), 1));

// --- live: re-quantizing the clock changes what the Function reads ----------
e.tempoMap = TempoMap(1!8, 0.25!8);
ok.("re-reads after tempoMap swap", near.(get.(e.resolvedEvents, \b, \spb), 0.5));

// --- no lazy values => untouched fast path ----------------------------------
flat = EventList(nil, \note);
flat.add(0, midinote: 60);
ok.("no-lazy list returns stored event identity",
	flat.resolvedEvents[0] === flat.events[0]);

// --- cycle detection --------------------------------------------------------
cyc = EventList(nil, \note);
threw = false;
cyc.add(0, aa: { |t| ~bb }, bb: { |t| ~aa });
try { cyc.resolvedEvents } { threw = true };
ok.("circular lazy refs throw", threw);

// --- \func event type -------------------------------------------------------
f = EventList(nil, \note);
f.tempoMap = TempoMap(1!8, [1,1,1,1,0.5,0.5,0.5,0.5]);
fired = nil;
f.add(4, func: { fired = ~secsFor.(3) });          // <- the envir spelling
ok.("func: infers \\func type", f.events[0][\type] == \func);
ok.("func: kept as a Function", f.events[0][\func].isKindOf(Function));

ev = f.resolvedEvents[0];
// beat 4 -> 7 spans 3 half-beats past the tempo change: 0.5 * 3 = 1.5
ok.("proto lookup: at(\\secsFor)", near.(ev[\secsFor].(3), 1.5));
ok.("proto lookup: at(\\wall)",    near.(ev[\wall], 4));
ok.("know-syntax ev.secsFor(3)",   near.(ev.secsFor(3), 1.5));
ok.("know-syntax ev.wall",         near.(ev.wall, 4));
ev.play;
ok.("\\func play ran the Function, with context", near.(fired ? -1, 1.5));

// --- array `when` fans a callback out per slice ------------------------------
fired = List[];
f.add([0, 4, 6], func: { fired.add(~secsFor.(2)) }, gain: { ~x });
r = f.events.select { |x| x[\type] == \func and: { x[\gain].notNil } };
ok.("array when fans \\func out",  r.size == 3);
ok.("slice whens kept",            r.collect { |x| x[\when] } == [0, 4, 6]);
ok.("callback NOT called at add",  r.every { |x| x[\func].isKindOf(Function) });
ok.("~x still frozen alongside",   r.collect { |x| x[\gain] } == [0, 1, 2]);
f.resolvedEvents.select { |x| x[\gain].notNil }.do { |x| x.play };
// beat 0: 2 whole beats = 2;  beat 4: 4->6 = 1;  beat 6: 6->8 = 1
ok.("each slice reads its own beat", fired.every { |v, i| near.(v, [2, 1, 1][i]) });

// --- proto never shadows a key the event defines ----------------------------
f.add(0, name: \shadow, wall: \mine, extra: { });
ok.("event key wins over context",
	f.resolvedEvents.detect { |x| x[\name] == \shadow }[\wall] == \mine);

// --- callback-free events keep the fast path --------------------------------
ok.("no callback => no proto", flat.resolvedEvents[0].proto.isNil);

// --- slice number reachable at PLAY time ------------------------------------
g = EventList(nil, \note);
g.tempoMap = TempoMap(1!8, [1,1,1,1,0.5,0.5,0.5,0.5]);
seen = List[];
g.add([1, 5], func: { seen.add([~x, ~n, ~sliceIndex, ~secsFor.(~x + 1)]) });
ok.("sliceIndex stored on slice", g.events.collect { |x| x[\sliceIndex] } == [0, 1]);
g.resolvedEvents.do { |x| x.play };
// beat 1 (~x 0): 1 beat  = 1;   beat 5 (~x 1): 5->7 = 0.5+0.5 = 1
ok.("~x at play time",   seen.collect { |p| p[0] } == [0, 1]);
ok.("~n at play time",   seen.collect { |p| p[1] } == [2, 2]);
ok.("~sliceIndex alias", seen.collect { |p| p[2] } == [0, 1]);
ok.("~secsFor.(~x+1) per slice", seen.every { |p, i| near.(p[3], [1, 1][i]) });

// --- preview delay honours the tempoMap (axis 1) ----------------------------
// 8 beats at 2 s/beat: a 3-beat offset is 6 seconds of preview delay, not 3
pv = EventList(nil, \note);
pv.batchWindow_(-1);   // every nextPreviewOffset opens a fresh batch
pv.tempoMap = TempoMap(1!8, 2!8);
pv.nextPreviewOffset(0);                       // open a batch at beat 0
ok.("preview delay uses tempoMap",  near.(pv.prPreviewDelay(3, pv.prPreviewTempoEnv), 6));
ok.("preview delay 0 at origin",    near.(pv.prPreviewDelay(0, pv.prPreviewTempoEnv), 0));
// non-constant map: the batch must skew INSIDE it, not just overall
pv.tempoMap = TempoMap(1!8, [1,1,1,1,0.5,0.5,0.5,0.5]);
pv.nextPreviewOffset(0);
ok.("non-constant map skews within batch",
	near.(pv.prPreviewDelay(4, pv.prPreviewTempoEnv), 4)
	and: { near.(pv.prPreviewDelay(8, pv.prPreviewTempoEnv), 6) });
// batch origin is not beat 0: absolute beats decide, not the delta
pv.nextPreviewOffset(4);
ok.("delay measured from batch origin",
	near.(pv.prPreviewDelay(4, pv.prPreviewTempoEnv), 2));
// \tempoTrack composes into the preview clock too
pv.add(0, tempoTrack: 2);
pv.nextPreviewOffset(0);
ok.("tempoTrack composes into preview", near.(pv.prPreviewDelay(4, pv.prPreviewTempoEnv), 8));
// events before the batch origin clamp instead of scheduling in the past
pv.nextPreviewOffset(4);
ok.("negative offset clamps to 0", pv.prPreviewDelay(-2, pv.prPreviewTempoEnv) == 0);
// flat list (no tempoMap) is unchanged: delay == offset
pv2 = EventList(nil, \note);
pv2.batchWindow_(-1);
pv2.nextPreviewOffset(0);
ok.("flat list unchanged", near.(pv2.prPreviewDelay(3, pv2.prPreviewTempoEnv), 3));

// --- does the context survive into a fork? ----------------------------------
// Through the REAL path (play -> prepare -> fire), not a direct .play from the
// interpreter: the clock a fork inherits is whatever fire runs sends on, and that
// decides whether `.wait` inside the fork means seconds or beats.
forked = nil;
h = EventList(nil, \note);
h.tempoMap = TempoMap(1!8, [1,1,1,1,0.5,0.5,0.5,0.5]);
h.add(0, func: { fork { 0.05.wait; forked = [~x, ~secsFor.(1), thisThread.clock] } });
h.add(2, func: { { forked2 = [~secsFor.(1), thisThread.clock] }.fork(SystemClock) });
h.play;
{
	3.wait;
	ok.("context survives fork",  forked.notNil and: { near.(forked[1], 1) });
	ok.("~x nil on single event", forked.notNil and: { forked[0].isNil });
	// bare fork does NOT inherit the firing clock: Stream:play defaults to
	// TempoClock.default, so `.wait` inside means BEATS, not seconds
	ok.("bare fork lands on TempoClock.default",
		forked.notNil and: { forked[2] === TempoClock.default });
	ok.("fork(SystemClock) => seconds, context intact",
		forked2.notNil and: { near.(forked2[0], 1) } and: { forked2[1] === SystemClock });
	"=== SENTINEL DONE ===".postln;
}.fork(SystemClock);
)
