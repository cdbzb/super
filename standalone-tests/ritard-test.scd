// AnchorMap.ritard / ritardSpan — the Friberg & Sundberg q family as a span
// transform. Pure language, no server.
// Run: /Applications/SuperCollider.app/Contents/MacOS/sclang standalone-tests/ritard-test.scd
(
var h = (thisProcess.nowExecutingPath.dirname +/+ "test-helpers.scd").load;
var assert = h[\assert], assertClose = h[\assertClose], assertArr = h[\assertArr];
var throws = { |fn| var t = false; try { fn.value } { t = true }; t };

var beatF = MapFrame(\beat, \t), secF = MapFrame(\sec, \t);
// tempo ratio actually realised across a map: local tempo at the far end over
// local tempo at the near end, read off the first and last sampled segments
var endRatio = { |m|
	var x0 = m.xs.first, x1 = m.xs.last;
	m.spanTempo(m.xs[m.xs.size - 2], x1) / m.spanTempo(x0, m.xs[1])
};
// local tempo at x, relative to the map's opening tempo
var relTempoAt = { |m, x, eps = 0.005|
	m.spanTempo(x - eps, x + eps) / m.spanTempo(m.xs.first, m.xs[1])
};

// steady 2 bps over 4 beats
var flat = AnchorMap([0, 1, 2, 3, 4], [0, 0.5, 1.0, 1.5, 2.0], beatF, secF);
// a wobbly one: slopes 0.4, 0.7, 0.5, 0.6 sec/beat
var wob = AnchorMap([0, 1, 2, 3, 4], [0, 0.4, 1.1, 1.6, 2.2], beatF, secF);
// first span 2 bps, last span 1 bps -> a fit should read w = 0.5
var drifting = AnchorMap([0, 1, 2, 3], [0, 0.5, 1.1, 2.1], beatF, secF);
var groove = AnchorMap([0, 1, 2], [0, 1.2, 2], MapFrame(\beat, \a), MapFrame(\beat, \b));
// steady 2 bps over 6 beats, for the span/pinEntry tests
var host = AnchorMap([0, 1, 2, 3, 4, 5, 6],
	[0, 0.5, 1.0, 1.5, 2.0, 2.5, 3.0], beatF, secF);

var r, r0, r1, acc, rq0, rq1, rq3, fit, sPin, sFree, tail, w0, w1;
var ext, sOff, errMap;
var tb, tbUp, durs, accDurs, durMap;
var slow, fast, raw, ease, onJoin, onEntry, drift, selfRaw, selfEase, shifted, sEase;
var foreign, foreignEase, mkNote, plr, mt, mtEase;

"---- endpoints and structure ----".postln;
r = flat.ritard(0.5, 2);
assertClose.(r.xs.first, 0, "ritard keeps the input start");
assertClose.(r.xs.last, 4, "ritard keeps the input end (input width is a label)");
assert.(r.ys.first == 0.0, "ritard pins the output start bit-exact");
assert.(r.ys.last == 2.0, "ritard pins the output end bit-exact");
assertClose.(r.ys.last - r.ys.first, 2.0, "output width is PRESERVED (no ripple)");
assert.(r.ys.differentiate.drop(1).every(_ > 0), "result is strictly increasing");
assert.(r.xs.size > flat.xs.size, "result is resampled denser than the original");
[1, 2, 3].do { |b|
	assert.(r.xs.any { |x| (x - b).abs < 1e-12 },
		"original interior anchor % survives as a sample point".format(b))
};

"---- w is a tempo RATIO, end / start ----".postln;
assertClose.(endRatio.(r), 0.5, "w = 0.5 lands the end tempo at half the start tempo", 0.03);
acc = flat.ritard(1.5, 2);
assertClose.(endRatio.(acc), 1.5, "w > 1 is an accelerando, same formula", 0.03);
assertClose.(acc.ys.last, 2.0, "an accel preserves the output width too");

"---- w = 1 degenerates to constant tempo (agrees with quantize(1)) ----".postln;
r1 = wob.ritard(1, 2);
assertClose.(r1.spanTempo(0, 1), r1.spanTempo(3, 4),
	"w = 1 gives one tempo across the span");
assertClose.(r1.spanTempo(0, 1), wob.spanTempo(0, 4),
	"and that tempo is the span's mean, as quantize(1) would");
assertClose.(wob.ritard(1, 2).ys.last, wob.quantize(1).ys.last,
	"w = 1 and quantize(1) agree at the end");

"---- amount blends, 0 is bit-exact ----".postln;
r0 = wob.ritard(0.5, 2, 0);
assertArr.(r0.xs, wob.xs, "amount 0 answers the receiver's own anchors (xs)");
assertArr.(r0.ys, wob.ys, "amount 0 answers the receiver's own anchors (ys)");
w0 = wob.ritard(0.5, 2, 0.5);
assert.(w0.ys.differentiate.drop(1).every(_ > 0), "a half blend is still monotone");
assertClose.(w0.ys.last, 2.2, "a half blend still pins the output end");
w1 = wob.ritard(0.5, 2, 1);
assert.((endRatio.(w0) - 0.5).abs > (endRatio.(w1) - 0.5).abs,
	"a half blend sits between the original and the full model");

"---- q moves WHERE the change happens, not how far ----".postln;
rq0 = flat.ritard(0.5, 0);
rq1 = flat.ritard(0.5, 1);
rq3 = flat.ritard(0.5, 3);
[rq0, rq1, rq3].do { |m, i|
	assertClose.(endRatio.(m), 0.5,
		"q index % reaches the same end ratio".format(i), 0.03)
};
// v(1/2): q = 0 geometric is 0.7071, q = 1 linear is 0.75, q = 3 holds longer
assertClose.(relTempoAt.(rq0, 2), 0.5.sqrt, "q = 0 is the geometric limit w^u", 0.01);
assertClose.(relTempoAt.(rq1, 2), 0.75, "q = 1 is tempo linear in beats", 0.01);
assertClose.(relTempoAt.(rq3, 2), 0.5625 ** (1/3), "q = 3 holds the tempo longer", 0.01);
assert.(relTempoAt.(rq0, 2) < relTempoAt.(rq1, 2),
	"lower q dumps the slowdown earlier");
assert.(relTempoAt.(rq1, 2) < relTempoAt.(rq3, 2),
	"higher q gives way later");
// the whole point: positivity is free, so no q/w combination can break the map
[0.05, 0.2, 0.5, 0.9, 1.1, 4].do { |ww|
	[-2, 0, 0.5, 1, 2, 3, 8].do { |qq|
		assert.(flat.ritard(ww, qq).ys.differentiate.drop(1).every(_ > 0),
			"w % q % stays strictly increasing".format(ww, qq))
	}
};

"---- w = nil fits the ratio from the cell's own ends ----".postln;
fit = drifting.ritard(nil, 2);
assertClose.(endRatio.(fit), 0.5,
	"a fitted w reproduces the measured end/start tempo ratio", 0.03);
assertClose.(fit.ys.last, 2.1, "a fitted ritard still preserves the output width");

"---- ritardSpan: width-preserving by default ----".postln;
sFree = host.ritardSpan(2, 4, 0.5, 2);
assertClose.(sFree.at(4), 2.0, "without pinEntry the span's end time is unmoved");
assertClose.(sFree.at(6), 3.0, "so nothing after the span moves");
assert.(sFree.spanTempo(2, 2.05) > host.spanTempo(2, 2.05),
	"but the span now ENTERS faster than it did — the step up pinEntry removes");

"---- ritardSpan(pinEntry: true): tempo continuous, the take gets longer ----".postln;
sPin = host.ritardSpan(2, 4, 0.5, 2, 1, true);
assertClose.(sPin.spanTempo(1.9, 1.99), sPin.spanTempo(2.01, 2.1),
	"pinEntry matches the span's entry tempo to the incoming tempo", 0.02);
assertClose.(sPin.spanTempo(1.9, 1.99), 2.0,
	"and the incoming tempo is itself unchanged", 0.02);
assert.(sPin.at(4) > 2.0, "the ritarded span takes genuinely longer");
assert.(sPin.at(6) > 3.0, "everything after it shifts — the ripple");
tail = sPin.at(6) - sPin.at(4);
assertClose.(tail, 1.0, "the tail keeps its own shape, only translated");
assertClose.(sPin.at(5) - sPin.at(4), 0.5, "tail spans are untouched");
assertClose.(host.ritardSpan(2, 4, 0.5, 2, 1, false).at(6), 3.0,
	"pinEntry false is the default behaviour");
// amount 0 is the identity for the whole editor: pinEntry must not stretch the
// span by whatever step happened to be sitting at `from`
assertArr.(wob.ritardSpan(1, 3, 0.5, 2, 0, true).ys, wob.ys,
	"amount 0 with pinEntry answers the receiver, step at the seam and all");

"---- guards ----".postln;
assert.(throws.({ groove.ritard(0.5, 2) }),
	"ritard refuses a beat -> beat map (w and q are tempo claims)");
assert.(throws.({ flat.ritard(0, 2) }), "w must be > 0");
assert.(throws.({ flat.ritard(-1, 2) }), "w must be > 0 (negative)");
assert.(throws.({ flat.ritard(0.5, \two) }), "q must be a number");
assert.(throws.({ flat.ritard(0.5, 2, 1, 0) }), "oversample must be >= 1");
assert.(throws.({ flat.ritard(0.5, 2, 1, 2.5) }), "oversample must be an integer");
assert.(throws.({ host.ritardSpan(4, 2, 0.5) }), "ritardSpan needs from < to");

"---- extendTo: a span may run off the end (\\carry materializes the anchor) ----".postln;
// value-preserving: the grown map is the same function, only its domain moves
ext = host.extendTo(9);
assertArr.(ext.domain, [0, 9], "extendTo grows the domain to the requested bound");
assertClose.(ext.at(9), host.at(9), "extendTo is value-preserving at the new end");
[0, 2.5, 6, 8.5].do { |b|
	assertClose.(ext.at(b), host.at(b), "extendTo leaves at(%) untouched".format(b))
};
assert.(ext.xs.first == host.xs.first, "extendTo never moves the origin (xs)");
assert.(ext.ys.first == host.ys.first, "extendTo never moves the origin (ys)");
assert.(host.extendTo(6) === host, "extendTo is a no-op at the domain end");
assert.(host.extendTo(3) === host, "extendTo is a no-op inside the domain");
// upward only: growing DOWN would move the origin that t0 / rebase key off, so
// a span starting below the domain stays a caller error
assert.(throws.({ host.ritardSpan(-2, 4, 0.5) }),
	"a span starting below the domain is still refused (extendTo is upward only)");
// a rit running PAST the last anchor — the final ritardando case
sOff = host.ritardSpan(4, 9, 0.4, 2, 1, true);
assertArr.(sOff.domain, [0, 9], "ritardSpan past the end extends the map instead of throwing");
assertClose.(sOff.at(4), host.at(4), "...and everything before the span is unmoved");
assert.(sOff.at(9) > host.at(9), "...while the ritarded tail takes longer than the carry did");
assert.(sOff.ys.differentiate.drop(1).every(_ > 0), "...and the result is still monotone");
assertClose.(sOff.spanTempo(3.9, 3.99), sOff.spanTempo(4.01, 4.1),
	"pinEntry still matches the entry tempo when the span runs off the end", 0.02);
// \error declares "no opinion out here" and is respected
errMap = AnchorMap([0, 1, 2], [0, 1, 2], beatF, secF, \error, \error);
assert.(throws.({ errMap.extendTo(5) }), "extendTo refuses to grow an \\error high end");
assert.(throws.({ errMap.ritardSpan(1, 5, 0.5) }),
	"ritardSpan past an \\error end still refuses");
assert.(throws.({ host.extendTo(\nine) }), "extendTo needs a number");
// pinEntry at the domain edge has no incoming tempo: warns, does not throw
assertClose.(host.ritardSpan(0, 2, 0.5, 2, 1, true).at(6), 3.0,
	"pinEntry at the domain start degrades to width-preserving");

"---- toBpm: w stated absolutely ----".postln;
// host runs at 2 bps = 120 bpm; ask the span to end at 60 bpm
tb = host.ritardSpan(2, 4, nil, 2, 1, true, 60);
assertClose.(tb.spanTempo(3.98, 3.999) * 60, 60,
	"toBpm lands the span's exit tempo on the requested bpm", 1.0);
assertClose.(tb.spanTempo(1.9, 1.99), 2.0,
	"toBpm still enters at the incoming tempo", 0.02);
assertArr.(tb.ys, host.ritardSpan(2, 4, 0.5, 2, 1, true).ys,
	"toBpm 60 against an incoming 120 is exactly w = 0.5");
tbUp = host.ritardSpan(2, 4, nil, 2, 1, true, 180);
assert.(tbUp.at(4) < host.ritardSpan(2, 4, 0.5, 2, 1, true).at(4),
	"toBpm above the incoming tempo is an accelerando");
assert.(throws.({ host.ritardSpan(2, 4, 0.5, 2, 1, true, 60) }),
	"w and toBpm together is a conflict");
assert.(throws.({ host.ritardSpan(2, 4, nil, 2, 1, false, 60) }),
	"toBpm without pinEntry is refused — the exit would not be the target");
assert.(throws.({ host.ritardSpan(0, 4, nil, 2, 1, true, 60) }),
	"toBpm at the domain edge is refused — no incoming tempo to resolve against");
assert.(throws.({ host.ritardSpan(2, 4, nil, 2, 1, true, 0) }), "toBpm must be > 0");

"---- ritardDurs: the model as a plain Array ----".postln;
durs = AnchorMap.ritardDurs(0.25, 16, 0.4, 3);
assert.(durs.size == 16, "ritardDurs answers numDurs durations");
assert.(durs.differentiate.drop(1).every(_ > 0), "a rit's durs increase monotonically");
// each dur is the INTEGRAL of sec/beat across its beat, not a sample of the tempo
// at the beat's onset — so the ends approach initialDur and initialDur / w from
// inside as the durs get shorter, rather than hitting them
assertClose.(durs.first, 0.25, "the first dur is initialDur to within a beat's curvature", 0.005);
assert.(durs.first > 0.25, "...and sits just above it, being an average over a slowing beat");
assert.(durs.last < (0.25 / 0.4), "the last dur likewise sits just under initialDur / w");
assertClose.(AnchorMap.ritardDurs(0.25, 256, 0.4, 3).first, 0.25,
	"finer durs put the first one on initialDur", 0.005);
assert.(((AnchorMap.ritardDurs(0.25, 1024, 0.4, 3).last - (0.25 / 0.4)).abs
	< (AnchorMap.ritardDurs(0.25, 256, 0.4, 3).last - (0.25 / 0.4)).abs),
	"and the last one converges on initialDur / w as they get finer");
assertArr.(AnchorMap.ritardDurs(0.25, 8, 1, 2), 0.25 ! 8,
	"w = 1 is a flat array of initialDur");
accDurs = AnchorMap.ritardDurs(0.25, 8, 2, 2);
assert.(accDurs.differentiate.drop(1).every(_ < 0), "w > 1 shortens the durs");
assertClose.(accDurs.last, 0.125, "an accel's last dur is initialDur / w", 0.01);
// the array and the map transform are the same curve. ritard preserves total
// width, so give a flat map the durs' own total and it must reproduce them:
// same model, same quadrature, two independent code paths to the answer
durMap = AnchorMap.fromSpans(1 ! 16, (durs.sum / 16) ! 16, 0, 0, beatF, secF)
	.ritard(0.4, 3);
16.do { |i|
	assertClose.(durMap.at(i + 1) - durMap.at(i), durs[i],
		"ritardDurs[%] matches the same beat of a ritard-shaped map".format(i), 0.001)
};
assert.(throws.({ AnchorMap.ritardDurs(0.25, 0, 0.5) }), "numDurs must be >= 1");
assert.(throws.({ AnchorMap.ritardDurs(0.25, 4.5, 0.5) }), "numDurs must be an integer");
assert.(throws.({ AnchorMap.ritardDurs(0, 8, 0.5) }), "initialDur must be > 0");
assert.(throws.({ AnchorMap.ritardDurs(0.25, 8, 0) }), "ritardDurs w must be > 0");
assert.(throws.({ AnchorMap.ritardDurs(0.25, 8, 0.5, \two) }), "ritardDurs q must be a number");

"---- easeTo: smooth the tempo step at a seam ----".postln;
// slow map (1 bps) then fast map (2 bps): a step UP at the join
slow = AnchorMap([0, 1, 2, 3, 4], [0, 1, 2, 3, 4], beatF, secF);
fast = AnchorMap([0, 1, 2, 3, 4], [0, 0.5, 1.0, 1.5, 2.0], beatF, secF);
raw = (slow ++ fast).bake;
assertClose.(raw.spanTempo(3.5, 3.9), 1.0, "unassisted, the seam steps 1 bps...");
assertClose.(raw.spanTempo(4.1, 4.5), 2.0, "...straight up to 2 bps");
ease = slow.easeTo(fast, 2, 2);
assertArr.(ease.domain, [0, 8], "easeTo answers one map spanning both");
assert.(ease.ys.differentiate.drop(1).every(_ > 0), "the eased map is strictly increasing");
assertClose.(ease.spanTempo(0, 1.9), 1.0, "material before the window is untouched");
assertClose.(ease.at(2), slow.at(2), "and so are its times");
assertClose.(ease.spanTempo(1.9, 1.99), ease.spanTempo(2.01, 2.1),
	"tempo is continuous entering the window", 0.02);
assertClose.(ease.spanTempo(5.9, 5.99), ease.spanTempo(6.01, 6.1),
	"tempo is continuous LEAVING the window — w was fitted to the far side", 0.05);
assertClose.(ease.spanTempo(6.1, 8), 2.0, "and the far side runs at its own tempo");
// after: 0 lands the new tempo exactly on the join
onJoin = slow.easeTo(fast, 2, 0);
assertClose.(onJoin.spanTempo(3.9, 3.99), 2.0,
	"after: 0 reaches the new tempo at the join itself", 0.05);
assertClose.(onJoin.spanTempo(1.9, 1.99), 1.0, "still entering at the old tempo", 0.02);
// before: 0 is the mirror
onEntry = slow.easeTo(fast, 0.001, 2);
assertClose.(onEntry.spanTempo(3.9, 3.99), 1.0,
	"an ease almost entirely after the join still leaves the old tempo alone", 0.05);
// the seam of a map with itself is NOT trivial unless the map is flat
drift = AnchorMap([0, 1, 2, 3], [0, 0.5, 0.9, 1.2], beatF, secF);
selfRaw = (drift ++ drift).bake;
assert.((selfRaw.spanTempo(2.5, 2.9) - selfRaw.spanTempo(3.1, 3.5)).abs > 0.5,
	"a drifting map spliced to ITSELF has a real step at the seam");
selfEase = drift.easeTo(drift, 1, 1);
assertClose.(selfEase.spanTempo(1.9, 1.99), selfEase.spanTempo(2.01, 2.1),
	"easeTo fits that seam without being told w", 0.05);
assertClose.(selfEase.spanTempo(3.9, 3.99), selfEase.spanTempo(4.01, 4.1),
	"...on both sides", 0.05);
// amount blends back toward the performed tempo
assertArr.(drift.easeTo(drift, 1, 1, 2, 0).ys, selfRaw.ys,
	"amount 0 answers the plain concatenation");
// origin is preserved, like every other editor here
shifted = AnchorMap([10, 11, 12], [100, 101, 102], beatF, secF);
sEase = shifted.easeTo(fast, 1, 1);
assert.(sEase.xs.first == 10, "easeTo keeps the receiver's origin (xs)");
assert.(sEase.ys.first == 100, "easeTo keeps the receiver's origin (ys)");
assertArr.(sEase.domain, [10, 16], "and lays other after it in the receiver's frame");

// other is a SHAPE, like the right operand of ++: its frames are ignored, not
// checked. Two takes mint their own axes, so a frame check here would refuse
// the ordinary case (easing one recording into the next) while catching nothing
// a MapSeq does not already discard.
foreign = AnchorMap([0, 1, 2, 3, 4], [0, 0.5, 1.0, 1.5, 2.0],
	MapFrame(\beat, \other), MapFrame(\sec, \other));
foreignEase = slow.easeTo(foreign, 2, 2);
assertArr.(foreignEase.domain, [0, 8], "easeTo takes an other on foreign frames");
assertArr.(foreignEase.ys, ease.ys, "and answers exactly what the shared-frame call did");
assert.(foreignEase.fromFrame == beatF and: { foreignEase.toFrame == secF },
	"the result wears the RECEIVER's frames");
// DIMENSIONS still have to agree: seconds-per-beat is what is being smoothed.
assert.(throws.({ slow.easeTo(groove, 1, 1) }), "a beat -> beat other is a units error");
// old-world maps coerce through asMonoMap, both as receiver and as other
mkNote = { |ts| (midicmd: \noteOn, type: \mk, timestamp: ts, midinote: 60,
	dur: 1, sustain: 1, amp: 0.5) };
plr = MIDIItemPlayer((0..4).collect { |t| mkNote.(t) }, nil);
mt = MIDIItemTempoMap(plr, { |n| n }, 1 ! 5);
mtEase = mt.easeTo(fast, 2, 0);
assert.(mtEase.isKindOf(AnchorMap), "MIDIItemTempoMap.easeTo bridges to the core");
// mt is 5 beats (four measured spans plus the closing anchor), fast is 4
assertArr.(mtEase.domain, [0, 9], "the bridged seam spans both maps");
assertClose.(mtEase.spanTempo(4.9, 4.99), 2.0,
	"and the ease lands other's tempo on the join", 0.05);
assert.(slow.easeTo(mt, 1, 1).isKindOf(AnchorMap), "an old-world OTHER coerces too");
// anything that bakes to anchors is acceptable as other
assert.(slow.easeTo(fast ++ fast, 1, 1).isKindOf(AnchorMap), "a MapSeq other is baked");

assert.(throws.({ slow.easeTo(fast, 0, 0) }), "easeTo needs a window with width");
assert.(throws.({ slow.easeTo(fast, 4, 1) }),
	"before must leave material ahead of the window");
assert.(throws.({ slow.easeTo(fast, 1, 9) }), "after must fit inside other");
assert.(throws.({ slow.easeTo(fast, -1, 1) }), "before and after must be >= 0");
assert.(throws.({ slow.easeTo(42, 1, 1) }), "easeTo needs another AnchorMap");
assert.(throws.({ slow.easeTo(groove, 1, 1) }), "easeTo refuses a frame mismatch");

h[\report].();
"SUITE-DONE".postln;
)
