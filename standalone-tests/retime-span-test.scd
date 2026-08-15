// Headless regression suite for §12c' (quantize-tempomap-project.md):
// MIDIItemPlayer.onsets — the beat-window query that answers performed times —
// and MIDIItemPlayer.retimeSpan — the re-anchor that pairs those onsets with
// the beats they were MEANT to land on, riding the committed §12b algebra
// (asMonoMap(origin: \absolute) -> transformSpan -> AnchorMap.fromSpans).
// Pure language — no server, no disk.
// Run: /Applications/SuperCollider.app/Contents/MacOS/sclang standalone-tests/retime-span-test.scd
//
// Fixture convention: [midinote:..., dur:...].asMIDIItem stamps timestamps in
// BEATS, which these tests read as seconds — fine here, the maps only care that
// the two axes are consistent. It also makes the un-edited map the IDENTITY, so
// a warped timestamp IS the beat the note landed on and every expectation below
// can be read off by eye. NOTE: MIDIItem.notes/.player hand back a fresh
// deepCopy each call, so markSelection must be applied to a HELD player.
(
var h = (thisProcess.nowExecutingPath.dirname +/+ "test-helpers.scd").load;
var assert = h[\assert];
var assertClose = { |a, b, msg, tol = 1e-6| h[\assertClose].(a, b, msg, tol) };
var assertArr = { |a, b, msg, tol = 1e-6| h[\assertArr].(a, b, msg, tol) };
var mkPlayer, sameArr, stamps;
var throws = { |fn| var t = false; try { fn.value } { t = true }; t };
var p, chord, bare, durs, ons, m0, m2, mStr, mTo, base, warped, tight, orig;
var errMsg;
var secF, idMap, off, offOrig, tm, mRel, mAbs;
var slow, sDurs, sOns, sOrig, sM0, sM2, sReq, sFlat, mFix, manual;

"== onsets / retimeSpan (§12c') + requantizeSpan (§12f) tests ==".postln;

// player from a pitch/dur spec, with a selection stamped on the HELD player.
// indices/coords index the NOTES (noteOns), matching a saved selection.
mkPlayer = { |midinotes, dur, indices, coords|
	var pl = [midinote: midinotes, dur: dur].asMIDIItem.player;
	indices !? { pl.markSelection(indices, coords) };
	pl
};
stamps = { |pl| pl.notes.collect(_.timestamp) };
// the message of the error a thunk raises ("" when it raises none), for the
// guards whose PREFIX is the thing under test
errMsg = { |fn| var m = ""; try { fn.value } { |e| m = e.errorString }; m };
// exact equality, for the "must be bit-identical" claims
sameArr = { |a, b, msg| h[\assert].((a == b), msg + "(got % want %)".format(a, b)) };

try {

// A two-bar take. Bar 1 (beats 0-4) is played dead even; bar 2 (beats 4-8) is
// the uneven one: five events at 4 / 4.9 / 5.1 / 6.1 / 7.4 that were MEANT to be
// "ex x q qe e" = [0.75, 0.25, 1, 1.5, 0.5]. Only the bar lines are selected
// (notes 0, 4, 9 at beats 0, 4, 8), so the map interpolates bar 2 evenly and
// every inner event sits on the wrong beat until retimeSpan fixes it.
p = mkPlayer.([60, 62, 64, 65, 67, 69, 71, 72, 74, 76],
	[1, 1, 1, 1, 0.9, 0.2, 1.0, 1.3, 0.6, 1], [0, 4, 9], [0, 4, 8]);
orig = stamps.(p);
assertArr.(orig, [0, 1, 2, 3, 4, 4.9, 5.1, 6.1, 7.4, 8], "fixture: performed onsets");
assertClose.(p.timeAtBeat(4), 4, "fixture: beat 4 is performed at 4 s");
assertClose.(p.timeAtBeat(8), 8, "fixture: beat 8 is performed at 8 s");

// ------------------------------------------------------------------- onsets
ons = p.onsets(4, 8);
assertArr.(ons, [4, 4.9, 5.1, 6.1, 7.4], "onsets: the five events of bar 2");
assert.(ons.isKindOf(Array), "onsets: answers an Array");
// [from, to): the beat-4 downbeat is IN, the beat-8 downbeat is OUT — so
// retimeSpan gets one onset per dur and takes the closing time from the map
// (ArrayedCollection:indexOf is slot-identical, so `includes(4.0)` would miss an
// Integer 4 — compare numerically instead)
assertClose.(ons.first, 4, "onsets: fromBeat is INCLUSIVE (the downbeat is in)");
assert.(ons.every { |t| t < 8 }, "onsets: toBeat is EXCLUSIVE (the next downbeat is out)");
assertArr.(p.onsets(0, 4), [0, 1, 2, 3], "onsets: the previous bar, same rule");
assert.((p.onsets(0, 4) ++ p.onsets(4, 8)).asFloat.asSet.size == 9,
	"onsets: adjacent windows partition — 9 events, nothing counted twice");
assertArr.(p.onsets(8, 9), [8], "onsets: the beat-8 note IS picked by the next window");
assertArr.(p.onsets(4, 4), [], "onsets: empty window -> []");
assertArr.(p.onsets(4, 3), [], "onsets: reversed window -> []");
// beats, not seconds: the window is asked through the map. Beats 4..6 of bar 2
// are performed seconds 4..6, which holds three of the five events.
assertArr.(p.onsets(4, 6), [4, 4.9, 5.1], "onsets: a partial window stops where asked");

// choiceFunc: a picker over the noteOns (filter's choiceFunc convention), applied
// BEFORE the window and the dedupe
assertArr.(p.onsets(4, 8, choiceFunc: { |n| n.midinote < 71 }), [4, 4.9],
	"onsets: choiceFunc narrows to a register");
assertArr.(p.onsets(4, 8, choiceFunc: { |n| n.midinote > 200 }), [],
	"onsets: a choiceFunc that keeps nothing -> []");
assertArr.(p.onsets(4, 8, choiceFunc: { |n, i| i.even }), [4, 5.1, 7.4],
	"onsets: choiceFunc gets the note AND its index");
assertArr.(p.onsets(4, 8, choiceFunc: nil), ons, "onsets: choiceFunc nil keeps every note");

// -------------------------------------------------------------- chord dedupe
// same take with an extra chord tone 10 ms after the 4.9 event — one rhythmic
// event, two notes. The high tone (79) is first, the low one (55) second.
chord = mkPlayer.([60, 62, 64, 65, 67, 79, 55, 71, 72, 74, 76],
	[1, 1, 1, 1, 0.9, 0.01, 0.19, 1.0, 1.3, 0.6, 1], [0, 4, 10], [0, 4, 8]);
assertArr.(stamps.(chord), [0, 1, 2, 3, 4, 4.9, 4.91, 5.1, 6.1, 7.4, 8],
	"fixture: the chord tone lands 10 ms after its partner");
assertArr.(chord.onsets(4, 8), [4, 4.9, 5.1, 6.1, 7.4],
	"onsets: a chord is ONE event — the cluster collapses to its FIRST onset");
assertArr.(chord.onsets(4, 8, dedupe: 0), [4, 4.9, 4.91, 5.1, 6.1, 7.4],
	"onsets: dedupe 0 disables the collapse (both tones survive)");
assertArr.(chord.onsets(4, 8, dedupe: 0.005), [4, 4.9, 4.91, 5.1, 6.1, 7.4],
	"onsets: a dedupe below the gap keeps both");
assertArr.(chord.onsets(4, 8, dedupe: 0.5), [4, 4.9, 6.1, 7.4],
	"onsets: a wide dedupe chains 4.9/4.91/5.1 into one cluster, first kept");
// choiceFunc runs FIRST: keeping only the low tone yields 4.91, which a
// dedupe-then-pick order could never return (4.91 would already be gone)
assertArr.(chord.onsets(4, 8, choiceFunc: { |n| n.midinote < 60 }), [4.91],
	"onsets: choiceFunc is applied BEFORE dedupe (the second chord tone survives alone)");

// ------------------------------------------------------- no selection / args
bare = mkPlayer.([60, 62, 64], 1);
"  (expect one 'needs a loaded selection' warning next)".postln;
assertArr.(bare.onsets(0, 4), [], "onsets: no selection -> warns and answers []");
"  (expect one 'must be numbers' warning next)".postln;
assertArr.(p.onsets(\four, 8), [], "onsets: non-numeric window -> warns and answers []");

// ---------------------------------------------------------------- retimeSpan
durs = "ex x q qe e".beats;
assertArr.(durs, [0.75, 0.25, 1, 1.5, 0.5], "fixture: the intended rhythm of bar 2");
assertClose.(durs.sum, 4, "fixture: the durs fill the span exactly");

m0 = p.tempomap.asMonoMap(origin: \absolute);   // the unedited map, for reference
m2 = p.retimeSpan(4, durs, ons);
assert.(m2.isKindOf(AnchorMap), "retimeSpan: answers a baked AnchorMap, got %".format(m2.class));
assert.(m2.mapsDimensions(\beat, \sec), "retimeSpan: still a beat -> sec map");
assertArr.(m2.xs, [0, 4, 4.75, 5, 6, 7.5, 8, 12],
	"retimeSpan: the span's beats are now the cumulative dur positions");
assertArr.(m2.ys, [0, 4, 4.9, 5.1, 6.1, 7.4, 8, 12],
	"retimeSpan: paired with the performed onsets, boundaries from the map");
// no ripple: both span boundaries, and everything outside, are the old map's
assertClose.(m2.at(4), m0.at(4), "retimeSpan: the span's start time is unchanged");
assertClose.(m2.at(8), m0.at(8), "retimeSpan: the span's end time is unchanged");
assertClose.(m2.at(12), m0.at(12), "retimeSpan: nothing after the span moved");
assertClose.(m2.at(2), m0.at(2), "retimeSpan: nothing before the span moved");

// the result answers the frame-dispatched sugar in both directions
assertClose.(m2.timeAt(4.75), 4.9, "retimeSpan: result answers timeAt (beat -> sec)");
assertClose.(m2.beatAt(4.9), 4.75, "retimeSpan: result answers beatAt (sec -> beat)");
assertClose.(m2.timeAt(m2.beatAt(6.1)), 6.1, "retimeSpan: the result round-trips");

// applied: warpTo takes a MonoMap (§12 seam), and each onset lands on the beat
// it was meant for — the whole point of the exercise
base = stamps.(p.warpTo(m0));
warped = stamps.(p.warpTo(m2));
assertArr.(base, [0, 1, 2, 3, 4, 4.9, 5.1, 6.1, 7.4, 8],
	"warpTo(unedited map): the fixture map is the identity");
assertArr.(warped, [0, 1, 2, 3, 4, 4.75, 5, 6, 7.5, 8],
	"warpTo(retimed map): every onset lands on its cumulative dur position");
sameArr.(warped.keep(5), base.keep(5), "warpTo: notes BEFORE the span are bit-unchanged");
sameArr.(warped.drop(9), base.drop(9), "warpTo: notes AFTER the span are bit-unchanged");
sameArr.(stamps.(p), orig,
	"retimeSpan + warpTo are non-mutating — the receiver still has its performed times");

// String durs, same precedent as `tempomap`
mStr = p.retimeSpan(4, "ex x q qe e", ons);
sameArr.(mStr.xs, m2.xs, "retimeSpan: a String dur spec is parsed with .beats (xs)");
sameArr.(mStr.ys, m2.ys, "retimeSpan: a String dur spec is parsed with .beats (ys)");

// `to` given: a CHECK, not a rescale
mTo = p.retimeSpan(4, durs, ons, 8);
sameArr.(mTo.ys, m2.ys, "retimeSpan: a consistent `to` changes nothing");
assert.(throws.({ p.retimeSpan(4, durs, ons, 9) }),
	"retimeSpan: an inconsistent `to` is an error, not a stretch");
assert.(throws.({ p.retimeSpan(4, durs, ons, 8 + 1e-12) }).not,
	"retimeSpan: `to` is checked to 1e-9, so float dust passes");

// onsets: required, counted, ordered, and inside the span
assert.(throws.({ p.retimeSpan(4, durs, nil) }),
	"retimeSpan: onsets is required — this method never picks");
assert.(throws.({ p.retimeSpan(4, durs, ons.drop(1)) }),
	"retimeSpan: fewer onsets than durs is an error");
assert.(throws.({ p.retimeSpan(4, durs, ons ++ [7.8]) }),
	"retimeSpan: more onsets than durs is an error");
assert.(throws.({ p.retimeSpan(4, durs, [4, 5.1, 4.9, 6.1, 7.4]) }),
	"retimeSpan: onsets must be strictly increasing");
assert.(throws.({ p.retimeSpan(4, durs, [4, 4.9, 5.1, 6.1, 8.5]) }),
	"retimeSpan: an onset at or past the span's end is an error");
// misalignment: half the first dur's performed width (0.75 s -> 0.375 s) is the
// tolerance. 0.5 s out is refused; 0.3 s out is absorbed.
assert.(throws.({ p.retimeSpan(4, durs, [4.5, 4.9, 5.1, 6.1, 7.4]) }),
	"retimeSpan: a first onset off by more than half the first dur is an error");
assert.(throws.({ p.retimeSpan(4, durs, [4.3, 4.9, 5.1, 6.1, 7.4]) }).not,
	"retimeSpan: a first onset inside the tolerance is accepted");
// durs themselves
assert.(throws.({ p.retimeSpan(4, [1, -1, 4], [4, 4.9, 5.1]) }),
	"retimeSpan: a non-positive dur is an error");
assert.(throws.({ p.retimeSpan(4, [], []) }), "retimeSpan: empty durs is an error");
assert.(throws.({ bare.retimeSpan(0, [1, 1], [0, 1]) }),
	"retimeSpan: no loaded selection is an error");
// span bounds are the algebra's business — [from, to] must be in the domain
assert.(throws.({ p.retimeSpan(10, durs, [10, 10.9, 11.1, 12.1, 13.4]) }),
	"retimeSpan: a span running past the map's domain is refused by transformSpan");

// -------------------------------------------------- the composed one-liner
// what the doc pins as the canonical call: query, then re-anchor.
tight = p.retimeSpan(4, "ex x q qe e".beats, p.onsets(4, 8));
sameArr.(tight.ys, m2.ys, "canonical: retimeSpan(from, durs, onsets(from, to)) composes");
assertArr.(stamps.(p.warpTo(tight)), [0, 1, 2, 3, 4, 4.75, 5, 6, 7.5, 8],
	"canonical: the one-liner warps the take onto its intended rhythm");

// and the chord take composes too — dedupe means the extra tone does not
// become a sixth event that no dur is waiting for
assert.(chord.onsets(4, 8).size == 5, "canonical: the chord take still yields 5 events");
tight = chord.retimeSpan(4, durs, chord.onsets(4, 8));
assertArr.(tight.ys, [0, 4, 4.9, 5.1, 6.1, 7.4, 8, 12],
	"canonical: the chord take re-anchors on the cluster's first onset");

// ================================================ §12f: warpTo's sec -> sec branch
// A map from the seconds axis to ITSELF is a time remap, not a tempo map: it
// says "the second this was played at becomes that second", so warpTo applies
// it raw — absolute in, absolute out, no t0/start arithmetic — instead of
// routing it through asAnchorTempoMap, which only knows beat<->sec.
secF = m0.toFrame;                                  // the take's ABSOLUTE sec axis
idMap = AnchorMap([0, 12], [0, 12], secF, secF);
assert.(idMap.mapsDimensions(\sec, \sec), "sec->sec: the identity fixture map maps sec -> sec");
assert.(throws.({ idMap.asAnchorTempoMap }),
	"sec->sec: the beat<->sec path really would have refused it (so the branch is load-bearing)");
sameArr.(stamps.(p.warpTo(idMap)), orig, "warpTo(sec->sec identity): nothing moves at all");
// dropBefore works in this branch too, with the same reject/clamp rule
sameArr.(stamps.(p.warpTo(idMap, 3)), orig.drop(3),
	"warpTo(sec->sec, dropBefore): notes before the threshold are dropped");
sameArr.(stamps.(p.warpTo(idMap, nil)), orig,
	"warpTo(sec->sec, dropBefore nil): the no-policy path is bit-identical");

// raw application: no origin offset. A take whose first event is at 10 s (start
// == 10) run through a doubling map lands at 2t, not at 2(t - start) + start.
off = MIDIItemPlayer(p.midiEvents.deepCopy.collect { |e| e.timestamp = e.timestamp + 10; e }, nil);
offOrig = stamps.(off);
assert.(off.start == 10, "fixture: the offset take's start is 10 s (got %)".format(off.start));
sameArr.(stamps.(off.warpTo(AffineMap(2, 0, \sec, \sec))), offOrig * 2,
	"warpTo(sec->sec): timestamps go in ABSOLUTE — no start/t0 subtraction");
sameArr.(stamps.(off.warpTo(AffineMap(1, 0.5, \sec, \sec))), offOrig + 0.5,
	"warpTo(sec->sec): an affine shift is a shift, and a total map needs no anchors");
sameArr.(stamps.(off), offOrig, "warpTo(sec->sec): the receiver is untouched");

// ---------------------------------------------------------- the relative-axis trap
// One tempomap object, two snapshots: the \relative one measures seconds from
// its own first anchor, so a sec -> sec map built on THAT axis would shift the
// take by t0 rather than remap it. Only an exact frame match is an error.
tm = p.tempomap;
mRel = tm.asMonoMap(origin: \relative);
mAbs = tm.asMonoMap(origin: \absolute);
assert.(throws.({ p.warpTo((mRel.inverse >> mRel).bake) }),
	"warpTo: a sec->sec map on this take's RELATIVE seconds axis is refused");
assert.(errMsg.({ p.warpTo((mRel.inverse >> mRel).bake) }).contains("origin"),
	"warpTo: the relative-axis error names the way out (origin: \\absolute)");
sameArr.(stamps.(p.warpTo((mAbs.inverse >> mAbs).bake)), orig,
	"warpTo: the same composition on the ABSOLUTE axis is accepted, and is the identity");

// ===================================================== §12f: requantizeSpan
// A take whose map is NOT the identity, which is what makes the difference
// visible: bar 1 is slow (4 beats over 5 s), bar 2 fast (4 beats over 3 s), and
// two notes trail past the last anchor. Only the bar lines are selected (notes
// 0, 4, 9 at beats 0, 4, 8), so bar 2's inner events sit on the wrong beats.
slow = mkPlayer.([60, 62, 64, 65, 67, 69, 71, 72, 74, 76, 77, 79],
	[1.25, 1.25, 1.25, 1.25, 0.7, 0.2, 0.7, 0.8, 0.6, 0.4, 0.3, 0.3], [0, 4, 9], [0, 4, 8]);
sOrig = stamps.(slow);
sDurs = "ex x q qe e".beats;
assertArr.(sOrig, [0, 1.25, 2.5, 3.75, 5, 5.7, 5.9, 6.6, 7.4, 8, 8.4, 8.7],
	"fixture: the uneven take's performed onsets");
sM0 = slow.tempomap.asMonoMap(origin: \absolute);
assertArr.(sM0.xs, [0, 4, 8, 12], "fixture: the map's beats (bar lines + closing anchor)");
assertArr.(sM0.ys, [0, 5, 8, 11], "fixture: bar 1 takes 5 s, bar 2 takes 3 s — NOT the identity");
sOns = slow.onsets(4, 8);
assertArr.(sOns, [5, 5.7, 5.9, 6.6, 7.4], "fixture: the five performed onsets of bar 2");

// what warpTo does with the retimed BEAT map: it flattens the WHOLE take onto
// the ideal 1 s/beat grid (warpTo is quantize's engine) — bar 1 was played
// 1.25 s to the beat and comes back at 1 s to the beat. Correct for quantize,
// wrong for "fix bar 2".
sM2 = slow.retimeSpan(4, sDurs, sOns);
sFlat = stamps.(slow.warpTo(sM2));
// the last two events sit PAST the final mark, in the closing span: 3 performed
// seconds carrying 4 beats, so 8.4 s -> 8 + 0.4*4/3 and 8.7 s -> 8 + 0.7*4/3
assertArr.(sFlat, [0, 1, 2, 3, 4, 4.75, 5, 6, 7.5, 8, 8 + (0.4 * 4 / 3), 8 + (0.7 * 4 / 3)],
	"warpTo(beat map): every event lands on its BEAT — the whole take is flattened");
assert.((sFlat[1] - sOrig[1]).abs > 0.2,
	"warpTo(beat map): even bar 1, which nobody edited, has moved");

// requantizeSpan instead: warpTo of (mNew.inverse >> mOld), the sec -> sec
// statement. Only bar 2's inner events move.
sReq = slow.requantizeSpan(4, sDurs, sOns);
assert.(sReq.isKindOf(MIDIItemPlayer), "requantizeSpan: answers a player, got %".format(sReq.class));
assertArr.(stamps.(sReq), [0, 1.25, 2.5, 3.75, 5, 5.5625, 5.75, 6.5, 7.625, 8, 8.4, 8.7],
	"requantizeSpan: the span's onsets move, the performed take around them does not");
sameArr.(stamps.(sReq).keep(4), sOrig.keep(4),
	"requantizeSpan: everything BEFORE the span is bit-identical");
sameArr.(stamps.(sReq).drop(9), sOrig.drop(9),
	"requantizeSpan: the span's end and everything AFTER it are bit-identical");
// where the moved events land: mOld's time for each cumulative-dur beat
assertArr.(stamps.(sReq)[4..8], [4, 4.75, 5, 6, 7.5].collect { |b| sM0.at(b) },
	"requantizeSpan: each onset lands where the OLD map puts its intended beat");
sameArr.(stamps.(slow), sOrig, "requantizeSpan: the receiver keeps its performed times");
// a String dur spec, and `to` as a check, exactly as retimeSpan takes them
sameArr.(stamps.(slow.requantizeSpan(4, "ex x q qe e", sOns)), stamps.(sReq),
	"requantizeSpan: a String dur spec is parsed with .beats");
sameArr.(stamps.(slow.requantizeSpan(4, sDurs, sOns, 8)), stamps.(sReq),
	"requantizeSpan: a consistent `to` changes nothing");

// ------------------------------------------------- the frame wart, and the manual form
// Every `tempomap` call builds a fresh MIDIItemTempoMap, so asMonoMap mints a
// fresh BEAT frame: two snapshots taken separately refuse to compose. That is
// why requantizeSpan takes ONE snapshot and hands it to the shared builder.
assert.(throws.({
	slow.tempomap.asMonoMap(origin: \absolute).inverse >> slow.tempomap.asMonoMap(origin: \absolute)
}), "frames: two separate tempomap snapshots refuse to compose (a new beat axis per call)");
// withFrames is the repair when the two maps DID come from separate calls —
// and the hand-built composition reproduces requantizeSpan exactly
mFix = sM0.withFrames(sM2.fromFrame, sM2.toFrame);
manual = stamps.(slow.warpTo((sM2.inverse >> mFix).bake));
sameArr.(manual, stamps.(sReq),
	"manual (mNew.inverse >> mOld.withFrames(...)) == requantizeSpan, timestamp for timestamp");

// -------------------------------------------------------------- shared guards
// The guards live in the builder both methods call, so they fire identically —
// only the name in the message changes.
assert.(throws.({ slow.requantizeSpan(4, sDurs, nil) }),
	"requantizeSpan: onsets is required here too");
assert.(throws.({ slow.requantizeSpan(4, sDurs, sOns.drop(1)) }),
	"requantizeSpan: one onset per dur");
assert.(throws.({ slow.requantizeSpan(4, sDurs, [5, 5.9, 5.7, 6.6, 7.4]) }),
	"requantizeSpan: onsets must be strictly increasing");
assert.(throws.({ slow.requantizeSpan(4, sDurs, sOns, 9) }),
	"requantizeSpan: an inconsistent `to` is an error, not a stretch");
assert.(throws.({ slow.requantizeSpan(4, sDurs, [5.5, 5.7, 5.9, 6.6, 7.4]) }),
	"requantizeSpan: a first onset outside the tolerance is an error");
assert.(errMsg.({ slow.requantizeSpan(4, sDurs, sOns.drop(1)) }).contains("requantizeSpan:"),
	"requantizeSpan: the guards name requantizeSpan, not retimeSpan");
assert.(errMsg.({ slow.requantizeSpan(4, sDurs, sOns.drop(1)) }).contains("retimeSpan").not,
	"requantizeSpan: retimeSpan is not mentioned at all");
assert.(errMsg.({ bare.requantizeSpan(0, [1, 1], [0, 1]) })
	.contains("requantizeSpan needs a loaded selection"),
	"requantizeSpan: no loaded selection is an error, in its own name");
// and retimeSpan's own messages are unchanged by the refactor
assert.(errMsg.({ p.retimeSpan(4, durs, ons.drop(1)) }).contains("retimeSpan:"),
	"retimeSpan: its messages still say retimeSpan");
assert.(errMsg.({ bare.retimeSpan(0, [1, 1], [0, 1]) })
	.contains("retimeSpan needs a loaded selection"),
	"retimeSpan: the no-selection message is unchanged");

} { |err|
	("UNCAUGHT: " ++ err.errorString).postln;
	err.throw;
};

(h[\report].() == 0).if { 0.exit } { 1.exit };
)
