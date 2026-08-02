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

"== onsets / retimeSpan (§12c') tests ==".postln;

// player from a pitch/dur spec, with a selection stamped on the HELD player.
// indices/coords index the NOTES (noteOns), matching a saved selection.
mkPlayer = { |midinotes, dur, indices, coords|
	var pl = [midinote: midinotes, dur: dur].asMIDIItem.player;
	indices !? { pl.markSelection(indices, coords) };
	pl
};
stamps = { |pl| pl.notes.collect(_.timestamp) };
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
assertArr.(m2.ys, [0, 4, 4.9, 5.1, 6.1, 7.4, 8, 9],
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
assertArr.(tight.ys, [0, 4, 4.9, 5.1, 6.1, 7.4, 8, 9],
	"canonical: the chord take re-anchors on the cluster's first onset");

} { |err|
	("UNCAUGHT: " ++ err.errorString).postln;
	err.throw;
};

(h[\report].() == 0).if { 0.exit } { 1.exit };
)
