// MonoMap core suite (tempomap-v2-design.md step 1). Pure language.
// Run: /Applications/SuperCollider.app/Contents/MacOS/sclang standalone-tests/monomap-test.scd
(
var h = (thisProcess.nowExecutingPath.dirname +/+ "test-helpers.scd").load;
var assert = h[\assert], assertClose = h[\assertClose], assertArr = h[\assertArr];
var throws = { |fn| var t = false; try { fn.value } { t = true }; t };

var beatF = MapFrame(\beat, \item);
var secF = MapFrame(\sec, \perf);
var listF = MapFrame(\beat, \list);

// m1: beat_item -> sec, anchors (0,2,4) -> (0,1,4); slopes 0.5 then 1.5
var m1 = AnchorMap([0, 2, 4], [0, 1, 4], beatF, secF);
var aff = AffineMap(2, 1, secF, listF);
var wallF = MapFrame(\sec, \wall);
var c, p, g, spans, b, ch, n2;
var ms, ms2, cellA, cellB, sw, gr, sn, gsn, dr, cat;
var m5, cv0, cv1, cv05, q0, q1, qw, qwd, jit, tm, varOf, widths;
var fm, fmT, fmS, mkNote, fxNotes, fxPlayer, tk1, tk2, mit, mitM, mitA, mitC;
var el, el2, elM, elFrozen, elFlat;
var sl, sp, mOff, tsId, qs, st, pt, ssl, stm, msq, mcells;
var ad, atm, atmInv, atmR, pk, pkF, elT, tmPass, elC, tEnvC;

// ---- MapFrame ----
assert.(MapFrame(\beat, \a) == MapFrame(\beat, \a), "frame value equality");
assert.((MapFrame(\beat, \a) == MapFrame(\beat, \b)).not, "frames differ by tag");
assert.((MapFrame(\beat, \a) == MapFrame(\sec, \a)).not, "frames differ by dimension");
assert.(MapFrame.mint(\beat) != MapFrame.mint(\beat), "minted frames are unique");

// ---- AffineMap ----
assertClose.(aff.at(3), 7, "affine at");
assertClose.(aff.invAt(7), 3, "affine invAt");
assertClose.(aff.inverse.at(7), 3, "affine inverse.at");
assert.(aff.inverse.fromFrame == listF and: { aff.inverse.toFrame == secF },
	"affine inverse swaps frames");
assert.(aff.domain.isNil, "affine is total");
assert.(throws.({ AffineMap(0, 1) }), "affine rejects scale <= 0");

// ---- AnchorMap ----
assertClose.(m1.at(0), 0, "anchor at first anchor");
assertClose.(m1.at(2), 1, "anchor at middle anchor");
assertClose.(m1.at(4), 4, "anchor at last anchor");
assertClose.(m1.at(1), 0.5, "interior lerp, first segment");
assertClose.(m1.at(3), 2.5, "interior lerp, second segment");
assertClose.(m1.at(-2), -1, "carry below at first-segment slope");
assertClose.(m1.at(5), 5.5, "carry above at last-segment slope");
assertClose.(m1.invAt(2.5), 3, "invAt");
assertClose.(m1.invAt(5.5), 5, "invAt past domain (carry)");
assert.(m1.inverse.fromFrame == secF and: { m1.inverse.toFrame == beatF },
	"anchor inverse swaps frames");
assertClose.(m1.inverse.at(m1.at(1.7)), 1.7, "roundtrip through inverse");
assertArr.(m1.domain, [0, 4], "domain from anchors");
assertArr.(m1.range, [0, 4], "range from anchors");
assert.(throws.({ AnchorMap([0, 2, 1], [0, 1, 2]) }), "rejects non-increasing xs");
assert.(throws.({ AnchorMap([0, 1], [0]) }), "rejects size mismatch");
assert.(throws.({ AnchorMap([0], [0]) }), "rejects single anchor");

g = AnchorMap([0, 2, 4], [0, 1, 4], beatF, secF, \error, \error);
assert.(throws.({ g.at(-1) }), "\\error below end throws");
assert.(throws.({ g.at(5) }), "\\error above end throws");
assertClose.(g.at(3), 2.5, "\\error map fine inside domain");

g = AnchorMap.fromSpans([2, 2], [1, 3], fromFrame: beatF, toFrame: secF);
assertArr.(g.xs, [0, 2, 4], "fromSpans xs = cumulative spans");
assertArr.(g.ys, [0, 1, 4], "fromSpans ys = cumulative spans");
assertClose.(g.at(3), m1.at(3), "fromSpans same map as fromAnchors");
assert.(g.fromFrame == beatF and: { g.toFrame == secF },
	"fromSpans binds frames passed as keyword args");
g = AnchorMap.fromAnchors([0, 2, 4], [0, 1, 4], fromFrame: beatF, toFrame: secF);
assert.(g.fromFrame == beatF and: { g.toFrame == secF },
	"fromAnchors binds frames passed as keyword args");
g = AnchorMap.fromSpans([2, 2], [1, 3], fromFrame: beatF, toFrame: secF, extendAbove: \error);
assert.(throws.({ g.at(5) }), "fromSpans binds extendAbove passed as keyword arg");
assertClose.(g.at(3), 2.5, "keyword-built \\error map fine inside domain");

// ---- compose ----
assert.(throws.({ m1 >> AffineMap(1, 0, listF, secF) }), "frame mismatch refuses compose");
c = m1 >> aff;
assertClose.(c.at(3), 6, "composed at (2.5 * 2 + 1)");
assertClose.(c.invAt(6), 3, "composed invAt");
assertClose.(c.inverse.at(6), 3, "inverse of composition");
assert.(c.fromFrame == beatF and: { c.toFrame == listF }, "composed frames = outer ends");
assert.((c >> AffineMap(1, 0, listF, beatF)).maps.size == 3,
	"nested composition flattens");

// ---- place ----
p = m1.place(10, 100);
assertClose.(p.at(13), 102.5, "place shifts both origins");
assertClose.(p.invAt(102.5), 13, "placed invAt");
assert.(p.fromFrame != beatF and: { p.fromFrame.dimension == \beat },
	"place mints a new frame, same dimension");

// ---- span mapping ----
spans = m1.mapSpans([1, 1, 1, 1]);
assertArr.(spans, [0.5, 0.5, 1.5, 1.5], "mapSpans from 0");
assertArr.(m1.mapSpans([1, 1, 1, 1], from: 1), [0.5, 1.5, 1.5, 1.5],
	"mapSpans is position-dependent");
assertArr.(m1.unmapSpans(spans), [1, 1, 1, 1], "unmapSpans inverts mapSpans");
assert.(m1.mapSpans([1, 1, 1, 1, 1, 1]).size == 6, "mapSpans preserves length past domain");
assertArr.((m1 >> aff).mapSpans([1, 1]), [1, 1], "span mapping through a composition");

// ---- frame-dispatched sugar ----
assertClose.(m1.timeAt(3), 2.5, "timeAt on beat->sec = at");
assertClose.(m1.beatAt(2.5), 3, "beatAt on beat->sec = invAt");
assertClose.(m1.inverse.timeAt(3), 2.5, "timeAt on sec->beat = invAt");
assertClose.(m1.inverse.beatAt(2.5), 3, "beatAt on sec->beat = at");
g = AnchorMap([0, 1, 2], [0, 1.2, 2], beatF, beatF);   // beat->beat, same frame
assert.(throws.({ g.timeAt(1) }), "timeAt refuses a beat->beat map");
assert.(g.mapsDimensions(\beat, \beat), "mapsDimensions inspects frames");

// ---- withFrames (shape reuse by explicit rebinding) ----
g = m1.withFrames(listF, secF);
assertClose.(g.at(3), m1.at(3), "withFrames keeps the mapping");
assert.(g.fromFrame == listF, "withFrames rebinds the input axis");
assert.(throws.({ m1 >> AffineMap(1, 0, listF, secF) }),
	"original still refuses frames the rebound copy accepts");
assert.((g >> AffineMap(1, 0, secF, listF)).notNil, "rebound copy composes on new axes");
g = AffineMap(2, 0, beatF, secF).withFrames(listF, secF);
assertClose.(g.at(3), 6, "affine withFrames keeps scale/offset");
g = (m1 >> aff).withFrames(listF, MapFrame(\sec, \other));
assertClose.(g.at(3), 6, "composed withFrames keeps the chain's values");
assert.(g.fromFrame == listF and: { g.toFrame.tag == \other },
	"composed withFrames rebinds only the outer ends");

// ---- checkComposable ----
g = AnchorMap([0, 10], [0, 10], secF, listF, \error, \error);
assert.((m1 >> g).checkComposable.notNil, "checkComposable passes when range fits");
g = AnchorMap([1, 3], [1, 3], secF, listF, \carry, \error);
assert.(throws.({ (m1 >> g).checkComposable }), "checkComposable catches range overrun");

// ---- bake (exact PL fusion) ----
assert.(aff.bake === aff, "MonoMap.bake default returns self (affine)");
assert.(m1.bake === m1, "MonoMap.bake default returns self (anchor)");

ch = m1 >> aff;
b = ch.bake;
assert.(b.isKindOf(AnchorMap), "anchor >> affine bakes to an AnchorMap");
assertArr.(m1.xs.collect { |x| b.at(x) }, m1.xs.collect { |x| ch.at(x) },
	"baked values exact at the contributing anchors", 1e-12);
assert.(h[\maxErrOver].(-3, 7, { |t| (b.at(t) - ch.at(t)).abs }, 500) < 1e-9,
	"baked chain matches on a grid past both ends (carry too)");
assert.(b.fromFrame == beatF and: { b.toFrame == listF }, "baked frames = chain outer ends");
assert.((b >> AffineMap(1, 0, listF, beatF)).notNil, "baked map composes where the chain did");
assert.(b.extendBelow == \carry and: { b.extendAbove == \carry },
	"all-\\carry chain bakes to \\carry");
assert.(h[\maxErrOver].(-2, 12, { |t| (b.inverse.at(t) - ch.inverse.at(t)).abs }, 500) < 1e-9,
	"baked inverse matches the chain's inverse");

ch = AffineMap(0.5, 3, beatF, secF) >> m1.inverse.withFrames(secF, listF);
assert.(ch.bake.isKindOf(AnchorMap), "affine >> anchor bakes to an AnchorMap");
assert.(h[\maxErrOver].(-4, 10, { |t| (ch.bake.at(t) - ch.at(t)).abs }, 500) < 1e-9,
	"affine >> anchor grid match");

ch = AffineMap(0.5, 3, beatF, secF) >> aff;
assert.(ch.bake.isKindOf(AffineMap), "all-affine chain bakes to an AffineMap");
assertClose.(ch.bake.at(4), ch.at(4), "all-affine bake keeps the values", 1e-12);
assert.(ch.bake.fromFrame == beatF and: { ch.bake.toFrame == listF },
	"all-affine baked frames = chain outer ends");

// three links: m1.xs (3) + n2.xs (4) pull back to 7 raw breakpoints, one duplicate
n2 = AnchorMap([0, 3, 6, 11], [0, 2, 5, 12], listF, wallF);
ch = m1 >> aff >> n2;
b = ch.bake;
assert.(h[\maxErrOver].(-2, 8, { |t| (b.at(t) - ch.at(t)).abs }, 1000) < 1e-9,
	"three-link chain grid match");
assert.(b.xs.size <= (m1.xs.size + n2.xs.size),
	"three-link bake deduped (% anchors from %+%)".format(b.xs.size, m1.xs.size, n2.xs.size));

g = AnchorMap([0, 2, 4], [0, 1, 4], beatF, secF, \error, \carry);
b = (g >> aff).bake;
assert.(b.extendBelow == \error and: { b.extendAbove == \carry },
	"\\error end propagates through bake, \\carry end does not");
assert.(throws.({ b.at(-1) }), "baked \\error end throws out there");
assertClose.(b.at(3), (g >> aff).at(3), "baked \\error map fine inside domain", 1e-12);

b = p.bake;   // p = m1.place(10, 100): affine adapter >> m1 >> affine adapter
assert.(b.isKindOf(AnchorMap), "place bakes to a single AnchorMap");
assert.(h[\maxErrOver].(5, 20, { |t| (b.at(t) - p.at(t)).abs }, 500) < 1e-9,
	"baked place matches the placed chain");

// ---- MapSeq: tiling (changing meter, two cells of different widths) ----
cellA = AnchorMap([0, 1, 3], [0, 1.5, 3]);   // in 3, out 3, bent at 1
cellB = AnchorMap([0, 2], [0, 2]);           // in 2, out 2, straight
ms = MapSeq([cellA, cellB], inf, beatF, listF);
assert.(ms.domain.isNil, "MapSeq repeats: inf is total");
assertClose.(ms.at(0), 0, "MapSeq at the origin");
assertClose.(ms.at(1), 1.5, "MapSeq inside the first cell");
assertClose.(ms.at(3), 3, "MapSeq at a cell join");
assertClose.(ms.at(5), 5, "MapSeq at the cycle boundary");
assertClose.(ms.at(6), 6.5, "MapSeq second tile, first cell");
assertClose.(ms.at(11), 11.5, "MapSeq third tile");
assertClose.(ms.at(-5), -5, "MapSeq negative x, cycle boundary");
assertClose.(ms.at(-4), -3.5, "MapSeq negative x tiles periodically");
assertClose.(ms.at(-2), -2, "MapSeq negative x at a cell join");
assertClose.(ms.at(6) - ms.at(1), 5, "MapSeq advances one cycle per cycle");
assertClose.(ms.invAt(2.025), 1.7, "MapSeq invAt, known value");
assertClose.(ms.invAt(-3.5), -4, "MapSeq invAt on a negative tile");
assertClose.(ms.invAt(ms.at(1.7)), 1.7, "MapSeq roundtrip at.invAt");

// drift: in width 2, out width 3 tiles into a steady stretch
dr = MapSeq([AnchorMap([0, 2], [0, 3])], inf);
assertArr.([-2, -1, 0, 1, 2, 3].collect { |k| dr.at(2 * k) }, [-6, -3, 0, 3, 6, 9],
	"drift cell: at(2k) == 3k across tiles");
assertClose.(dr.invAt(9), 6, "drift cell invAt");

// ---- cells vs the old Groove ----
sw = MapSeq.swing(1.5);
gr = Groove.swing(1.5);
assertClose.(sw.at(1), 1.2, "swing cell: straight 1 lands on grooved 1.2", 1e-12);
assertArr.(
	[0, 0.5, 1, 1.5, 2, 3, 3.5, -0.5, -1.5].collect { |x| sw.at(x) },
	[0, 0.5, 1, 1.5, 2, 3, 3.5, -0.5, -1.5].collect { |x| gr.mapBeat(x) },
	"swing MapSeq matches Groove.swing(1.5) exactly (PL vs PL)", 1e-12);
assertArr.(sw.mapSpans([1, 1, 1, 1]), [1.2, 0.8, 1.2, 0.8], "swing spans are 60:40");
assertClose.(sw.mapSpans([1, 1, 1, 1]).sum, 4,
	"mean span over a whole period == the straight span (no drift)");
assert.(sw.mapSpans([1, 1, 1, 1, 1]).size == 5, "mapSpans through a MapSeq keeps length");

sn = MapSeq.modulate(4, 0.15, \sine);
gsn = Groove.modulate(4, 0.15, \sine);
assert.(h[\maxErrOver].(-8, 8, { |t| (sn.at(t) - gsn.mapBeat(t)).abs }, 800) < 1e-2,
	"sampled sine cell tracks Groove.modulate within sampling tolerance");
assertArr.([-8, -4, 0, 4, 8].collect { |x| sn.at(x) }, [-8, -4, 0, 4, 8],
	"sine cell exact at the cell endpoints (zero displacement)", 1e-12);
assertClose.(sn.invAt(sn.at(2.3)), 2.3, "sine cell roundtrip");
sn = MapSeq.modulate(2, 0.3, \tri);
gsn = Groove.modulate(2, 0.3, \tri);
assert.(h[\maxErrOver].(-4, 6, { |t| (sn.at(t) - gsn.mapBeat(t)).abs }, 500) < 1e-2,
	"sampled tri cell tracks Groove.modulate");

// ---- finite repeats: domain and per-end extension ----
ms2 = MapSeq([cellA, cellB], 2, beatF, listF);
assertArr.(ms2.domain, [0, 10], "finite MapSeq domain is repeats * cycle");
assertArr.(ms2.range, [0, 10], "finite MapSeq range");
assertClose.(ms2.at(6), 6.5, "finite MapSeq inside the second pass");
assertClose.(ms2.at(10), 10, "finite MapSeq at the domain end");
assertClose.(ms2.at(12), 12, "carry above at the last cell's boundary slope");
assertClose.(ms2.at(-1), -1.5, "carry below at the first cell's boundary slope");
assertClose.(ms2.invAt(12), 12, "carry above through invAt");
g = MapSeq([cellA, cellB], 2, beatF, listF, \error, \error);
assert.(throws.({ g.at(-1) }), "MapSeq \\error below end throws");
assert.(throws.({ g.at(11) }), "MapSeq \\error above end throws");
assert.(throws.({ g.invAt(11) }), "MapSeq \\error end throws through invAt");
assertClose.(g.at(6), 6.5, "\\error MapSeq fine inside domain");

// ---- inverse / withFrames ----
g = ms.inverse;
assertClose.(g.at(2.025), 1.7, "MapSeq inverse values");
assert.(g.fromFrame == listF and: { g.toFrame == beatF }, "MapSeq inverse swaps frames");
assertClose.(g.at(ms.at(-4)), -4, "MapSeq inverse over a negative tile");
g = ms.withFrames(listF, beatF);
assertClose.(g.at(6), ms.at(6), "MapSeq withFrames keeps the mapping");
assert.(g.fromFrame == listF and: { g.toFrame == beatF }, "MapSeq withFrames rebinds frames");

// ---- ++ (finite-pair sugar) ----
cat = AnchorMap([0, 2], [0, 1], beatF, secF) ++ AnchorMap([0, 4], [0, 2]);
assert.(cat.isKindOf(MapSeq), "++ builds a MapSeq");
assertArr.(cat.domain, [0, 6], "++ domain is the sum of the cell widths");
assertClose.(cat.at(2), 1, "++ value where the first map ended");
assertClose.(cat.at(4), 2, "++ second map continues from there");
assertClose.(cat.at(6), 3, "++ value at the far end");
assert.(cat.fromFrame == beatF and: { cat.toFrame == secF },
	"++ keeps the left operand's frames");
assert.(throws.({ AnchorMap([0, 2], [0, 1]) ++ AffineMap(2, 0) }),
	"++ refuses a total (infinite-domain) operand");

// ---- bake ----
b = ms2.bake;
assert.(b.isKindOf(AnchorMap), "finite all-PL MapSeq bakes to an AnchorMap");
assert.(h[\maxErrOver].(-3, 13, { |t| (b.at(t) - ms2.at(t)).abs }, 800) < 1e-9,
	"baked MapSeq matches on a grid past both ends");
assert.(b.fromFrame == beatF and: { b.toFrame == listF }, "baked MapSeq keeps the frames");
assert.(b.xs.size == 7, "baked MapSeq dedupes the joins (% anchors)".format(b.xs.size));
assert.(MapSeq.swing(1.5).bake.isKindOf(MapSeq), "infinite MapSeq stays symbolic");
ch = ms2 >> AffineMap(2, 1, listF, wallF);
assert.(ch.bake === ch, "a chain containing a MapSeq bakes to itself");
assert.(h[\maxErrOver].(0, 10, { |t| (ch.bake.at(t) - ch.at(t)).abs }, 200) < 1e-12,
	"unbaked MapSeq chain is value-identical");

// ---- validation ----
assert.(throws.({ MapSeq([AffineMap(1, 0)]) }), "MapSeq refuses a total cell");
assert.(throws.({ MapSeq([cellA], 0) }), "MapSeq refuses repeats 0");
assert.(throws.({ MapSeq([cellA], 2.5) }), "MapSeq refuses fractional repeats");
assert.(throws.({ MapSeq([
		AnchorMap([0, 1], [0, 1], MapFrame(\beat, \x), MapFrame(\beat, \y)),
		AnchorMap([0, 1], [0, 1], MapFrame(\beat, \z), MapFrame(\sec, \w))]) }),
	"MapSeq refuses cells that disagree on a frame dimension");
assert.(MapSeq([
		AnchorMap([0, 1], [0, 1], MapFrame(\beat, \x), MapFrame(\beat, \y)),
		AnchorMap([0, 1], [0, 1])]).fromFrame.dimension == \beat,
	"\\any-dimension cells mix in and the MapSeq takes the stated dimension");

// ================= transforms (design doc step 4) =================
widths = { |map| map.ys.differentiate.drop(1) };
varOf = { |a| var mu = a.sum / a.size; a.collect { |v| (v - mu).squared }.sum / a.size };

// 5 spans of 1 beat, jittery seconds; mean slope 6/5 = 1.2
m5 = AnchorMap.fromSpans([1, 1, 1, 1, 1], [1, 2, 0.5, 1.5, 1],
	fromFrame: beatF, toFrame: secF);

// ---- clump ----
c = m5.clump(2);
assert.(c.xs.size == 4, "clump(2) on 5 spans keeps 4 anchors (got %)".format(c.xs.size));
assertArr.(c.xs, [0, 2, 4, 5], "clump(2) keeps the boundary xs verbatim");
assertArr.(c.ys, [0, 3, 5, 6], "clump(2) keeps the boundary ys verbatim");
assertArr.(c.domain, m5.domain, "clump preserves the input extent");
assertArr.(c.range, m5.range, "clump preserves the output extent (endpoints pinned)");
c = m5.clump([2, 1]);
assertArr.(c.xs, [0, 2, 3, 5], "clump([2,1]) cycles the group sizes");
assertArr.(c.ys, [0, 3, 3.5, 6], "clump([2,1]) ys follow the same index set");
assertArr.(m5.clump(4).xs, [0, 4, 5], "clump remainder group keeps the final anchor");
c = AnchorMap(m5.xs, m5.ys, beatF, secF, \error, \carry).clump(2);
assert.(c.fromFrame == beatF and: { c.toFrame == secF }, "clump carries the frames");
assert.(c.extendBelow == \error and: { c.extendAbove == \carry },
	"clump carries the per-end extension");
assert.(throws.({ m5.clump([2, 0]) }), "clump rejects non-positive group sizes");

// ---- curve ----
cv0 = m5.curve(0);
assert.(cv0.xs == m5.xs, "curve(0) xs are the receiver's, bit-exact");
assert.(cv0.ys == m5.ys, "curve(0) ys are the receiver's, bit-exact");
cv1 = m5.curve(1, 8);
assert.(cv1.xs.size == ((5 * 8) + 1),
	"curve(1, 8) has spans*oversample+1 anchors (got %)".format(cv1.xs.size));
assert.((0..5).every { |i| cv1.xs[i * 8] == m5.xs[i] },
	"curve preserves the original xs exactly");
assert.((0..5).every { |i| cv1.ys[i * 8] == m5.ys[i] },
	"curve preserves the original ys exactly (anchors stay locked)");
assert.(widths.(cv1).every { |v| v > 0 },
	"curve(1) is strictly monotone everywhere (Fritsch-Carlson clamp)");
assert.(h[\maxErrOver].(0, 5, { |t| (cv1.at(t) - m5.at(t)).abs }, 200) > 1e-3,
	"curve(1) actually bends away from the linear map");
cv05 = m5.curve(0.5, 8);
assert.(h[\maxErrOver].(0, 5,
	{ |t| (cv05.at(t) - ((m5.at(t) + cv1.at(t)) * 0.5)).abs }, 400) < 1e-12,
	"curve(0.5) is exactly halfway between linear and curve(1)");
ch = cv1 >> AffineMap(2, 1, secF, wallF);
assert.(ch.bake.isKindOf(AnchorMap), "a curved map bakes in a chain like any AnchorMap");
assert.(h[\maxErrOver].(0, 5, { |t| (ch.bake.at(t) - ch.at(t)).abs }, 200) < 1e-9,
	"baked curved chain is value-identical");
assert.(throws.({ m5.curve(1, 0) }), "curve rejects oversample < 1");

// ---- quantize ----
q0 = m5.quantize(0);
assert.(q0.ys == m5.ys, "quantize(0) is the identity, bit-exact");
q1 = m5.quantize(1);
assertArr.(widths.(q1), 1.2 ! 5, "quantize(1) gives every span the mean slope", 1e-12);
[0.3, 0.7, 1].do { |a|
	var q = m5.quantize(a);
	assertClose.(q.ys.last - q.ys.first, 6, "quantize(%) preserves the output extent".format(a), 1e-12);
};
[0.3, 0.7].do { |a|
	assert.(widths.(m5.quantize(a)).every { |v| v > 0 },
		"quantize(%) stays strictly monotone".format(a));
};
q1 = AnchorMap(m5.xs, m5.ys, beatF, secF, \carry, \error).quantize(0.5);
assert.(q1.fromFrame == beatF and: { q1.toFrame == secF and: { q1.extendAbove == \error } },
	"quantize carries the frames and extension");
tm = nil;
try { tm = TempoMap([1, 1, 1, 1, 1], [1, 2, 0.5, 1.5, 1]).quantize(1).durs };
assertArr.(widths.(m5.quantize(1)), tm ? [],
	"quantize(1) span widths match the old TempoMap.quantize(1).durs", 1e-9);

// ---- quantizeWindow ----
jit = AnchorMap.fromSpans(1 ! 12,
	[0.4, 0.6, 0.45, 0.65, 0.35, 0.7, 0.5, 0.55, 0.42, 0.68, 0.38, 0.62],
	fromFrame: beatF, toFrame: secF);
assert.(jit.quantizeWindow(0).ys == jit.ys, "quantizeWindow(0) is the identity, bit-exact");
qw = jit.quantizeWindow(1, 4);
assert.(varOf.(widths.(qw)) < varOf.(widths.(jit)),
	"quantizeWindow smooths: span-width variance drops (% -> %)"
		.format(varOf.(widths.(jit)).round(1e-5), varOf.(widths.(qw)).round(1e-5)));
assertClose.(qw.ys.last - qw.ys.first, jit.ys.last - jit.ys.first,
	"quantizeWindow preserves the total output extent", 1e-12);
assert.(widths.(qw).every { |v| v > 0 }, "quantizeWindow stays strictly monotone");
assert.(qw.fromFrame == beatF and: { qw.toFrame == secF }, "quantizeWindow carries the frames");
qwd = jit.quantizeWindow(1);
assertClose.(qwd.ys.last - qwd.ys.first, jit.ys.last - jit.ys.first,
	"quantizeWindow at the default window preserves the extent", 1e-12);
assertArr.(widths.(jit.quantizeWindow(1, 1000)), widths.(jit.quantize(1)),
	"a window wider than the domain reduces to the global quantize(1)", 1e-12);

// ============ local editing: slices / span transforms (§12 step 1) ============
// m5: xs [0,1,2,3,4,5], ys [0,1,3,3.5,5,6]

// ---- slices ----
sl = m5.slices(2);
assert.(sl.size == 2, "slices at one boundary gives two cells (got %)".format(sl.size));
assert.(sl.every(_.isKindOf(AnchorMap)), "slices answers AnchorMaps");
assertArr.(sl[0].xs, [0, 1, 2], "cut at an existing anchor: first cell xs");
assertArr.(sl[0].ys, [0, 1, 3], "cut at an existing anchor: first cell ys");
assertArr.(sl[1].xs, [2, 3, 4, 5], "second cell starts AT the cut, in absolute coords");
assertArr.(sl[1].ys, [3, 3.5, 5, 6], "second cell ys are absolute too");
assert.(sl[0].xs.last == sl[1].xs.first, "an existing anchor cut is not duplicated");
assertArr.(sl.collect { |c| c.xs.size }.sum ! 1, [7],
	"cutting at an anchor adds no anchors (6 + the shared cut)");
sl = m5.slices([2.5]);
assertArr.(sl[0].xs, [0, 1, 2, 2.5], "a mid-span cut synthesizes an anchor");
assertClose.(sl[0].ys.last, m5.at(2.5), "synthesized cut value == at(x), exactly", 1e-15);
assertClose.(sl[0].ys.last, 3.25, "synthesized cut value is the PL lerp");
assert.((sl[1].xs.first == 2.5) and: { sl[1].ys.first == sl[0].ys.last },
	"cells meet bit-exactly at the cut");
assert.(m5.slices([1, 2.5, 4]).size == 4, "n boundaries give n+1 cells");
assert.(m5.slices([]).size == 1, "no boundaries: one cell, the whole map");
assertArr.(m5.slices([]).first.ys, m5.ys, "the no-cut cell is the map itself");
assert.(throws.({ m5.slices([2, 2]) }), "slices rejects repeated boundaries");
assert.(throws.({ m5.slices([3, 1]) }), "slices rejects descending boundaries");
assert.(throws.({ m5.slices(0) }), "slices rejects a boundary at the domain start");
assert.(throws.({ m5.slices(5) }), "slices rejects a boundary at the domain end");
assert.(throws.({ m5.slices(7) }), "slices rejects a boundary outside the domain");
assert.(throws.({ m5.slices(-1) }), "slices rejects a boundary below the domain");
assert.(throws.({ m5.slices([\two]) }), "slices rejects a non-numeric boundary");
g = AnchorMap(m5.xs, m5.ys, beatF, secF, \error, \error);
sl = g.slices([2, 4]);
assert.(sl.every { |c| (c.fromFrame == beatF) and: { c.toFrame == secF } },
	"slices carries the frames to every cell");
assert.((sl[0].extendBelow == \error) and: { sl[0].extendAbove == \carry },
	"first cell keeps extendBelow; its cut end is \\carry");
assert.((sl[1].extendBelow == \carry) and: { sl[1].extendAbove == \carry },
	"an interior cell is \\carry at both cut ends");
assert.((sl.last.extendBelow == \carry) and: { sl.last.extendAbove == \error },
	"last cell keeps extendAbove; its cut end is \\carry");

// ---- round trip: slices -> MapSeq -> bake ----
msq = MapSeq(m5.slices([1, 2.5, 4]), 1, m5.fromFrame, m5.toFrame);
assertArr.(msq.domain, m5.domain, "the reassembled MapSeq spans the same input extent");
b = msq.bake;
assert.(b.isKindOf(AnchorMap), "slices -> MapSeq bakes back to anchors");
assertArr.(b.xs, [0, 1, 2, 2.5, 3, 4, 5], "round trip keeps every anchor and every cut", 1e-12);
assertArr.(m5.xs.collect { |x| b.at(x) }, m5.ys,
	"round trip is exact at every original anchor", 1e-12);
assert.(h[\maxErrOver].(0, 5, { |t| (b.at(t) - m5.at(t)).abs }, 500) < 1e-12,
	"round trip is exact across the whole domain");

// ---- transformSpan ----
tsId = m5.transformSpan(1, 4, { |cell| cell });
assertArr.(tsId.xs, m5.xs, "identity transformSpan keeps the xs", 1e-12);
assertArr.(tsId.ys, m5.ys, "identity transformSpan keeps the ys", 1e-12);
assert.((tsId.xs == m5.xs) and: { tsId.ys == m5.ys },
	"identity transformSpan is bit-exact on an integer-anchored map");
assert.((tsId.fromFrame == beatF) and: { tsId.toFrame == secF },
	"transformSpan carries the frames");
tsId = m5.transformSpan(1.5, 3.5, { |cell| cell });
assert.(h[\maxErrOver].(0, 5, { |t| (tsId.at(t) - m5.at(t)).abs }, 400) < 1e-12,
	"identity transformSpan at non-anchor cuts is the same map (extra anchors only)");
assertArr.(m5.transformSpan(0, 5, { |c| c.quantize(1) }).ys, m5.quantize(1).ys,
	"a whole-domain transformSpan is just the transform", 1e-12);
assert.(throws.({ m5.transformSpan(4, 1, { |c| c }) }), "transformSpan needs from < to");
assert.(throws.({ m5.transformSpan(2, 2, { |c| c }) }), "transformSpan refuses an empty span");
assert.(throws.({ m5.transformSpan(-1, 3, { |c| c }) }),
	"transformSpan refuses a span starting below the domain");
assert.(throws.({ m5.transformSpan(1, 9, { |c| c }) }),
	"transformSpan refuses a span running past the domain");
assert.(throws.({ m5.transformSpan(1, 4, { |c| AnchorMap([0, 5], [0, 3]) }) }),
	"transformSpan rejects a result whose INPUT width changed");
assert.(m5.transformSpan(1, 4, { |c| AnchorMap([0, 3], [0, 9]) }).notNil,
	"transformSpan accepts a from-scratch shape of the right input width");
assert.(throws.({ m5.transformSpan(1, 4, { |c| 7 }) }),
	"transformSpan rejects a non-MonoMap result");
assert.(throws.({ m5.transformSpan(1, 4, { |c| MapSeq.swing(1.5) }) }),
	"transformSpan rejects a result that does not bake to anchors");

// ---- quantizeSpan ----
qs = m5.quantizeSpan(1, 4);
assertArr.(qs.xs, m5.xs, "quantizeSpan keeps the input anchors", 1e-12);
assertArr.(widths.(qs)[1..3], (4/3) ! 3,
	"quantizeSpan(1) gives the span's spans its mean slope", 1e-12);
assertArr.([widths.(qs)[0], widths.(qs)[4]], [1, 1],
	"spans outside the quantized span keep their widths exactly", 1e-12);
assertArr.(qs.ys[4..5], m5.ys[4..5],
	"quantize preserves the span's output extent, so later anchors do not move", 1e-12);
assertClose.(qs.ys.first, 0, "quantizeSpan leaves the origin alone", 1e-12);
assertArr.(m5.quantizeSpan(1, 4, 0).ys, m5.ys, "quantizeSpan(amount 0) is the identity", 1e-12);

// ---- origin restoration on a map whose domain does not start at 0 ----
mOff = AnchorMap([16, 17, 18, 20], [40, 41, 43, 44], beatF, secF);
sp = mOff.transformSpan(17, 18, { |c| c });
assert.((sp.xs.first == 16) and: { sp.ys.first == 40 },
	"transformSpan restores the receiver's origin exactly");
assertArr.(sp.xs, mOff.xs, "off-origin identity keeps the xs", 1e-12);
assertArr.(sp.ys, mOff.ys, "off-origin identity keeps the ys", 1e-12);
sp = mOff.stretchSpan(17, 18, 2);
assertClose.(sp.at(16), 40, "off-origin edit keeps the first anchor put", 1e-12);
assertClose.(sp.at(17), 41, "material before the span is untouched", 1e-12);
assertClose.(sp.at(18), 45, "the span's output width (2) doubled", 1e-12);
assertClose.(sp.at(20), 46, "material after the span shifts by the delta (+2)", 1e-12);

// ---- stretchSpan ----
// span [1, 3]: output width 3.5 - 1 = 2.5
st = m5.stretchSpan(1, 3, 2);
assertArr.(st.xs, m5.xs, "stretchSpan never touches the input anchors", 1e-12);
assertClose.(st.ys[1], 1, "stretchSpan leaves earlier anchors alone", 1e-12);
assertClose.(st.ys[3] - st.ys[1], 5, "factor 2 doubles the span's output width", 1e-12);
assertClose.(st.ys[2] - st.ys[1], 4,
	"anchors inside keep their relative proportions (2 of 2.5 -> 4 of 5)", 1e-12);
assertClose.(st.ys.last - m5.ys.last, 2.5,
	"later material shifts by the span's original output width", 1e-12);
assertArr.(widths.(st)[3..4], widths.(m5)[3..4],
	"spans after the stretched span keep their widths exactly", 1e-12);
assertArr.(m5.stretchSpan(1, 3, 1).ys, m5.ys, "stretchSpan factor 1 is the identity", 1e-12);
assert.(throws.({ m5.stretchSpan(1, 3, 0) }), "stretchSpan rejects factor 0");
assert.(throws.({ m5.stretchSpan(1, 3, -1) }), "stretchSpan rejects a negative factor");
assert.(throws.({ m5.stretchSpan(1, 3, \x) }), "stretchSpan rejects a non-numeric factor");
// preserveTotal: total 6, span 2.5 -> 5, so the remaining 3.5 must become 1
pt = m5.stretchSpan(1, 3, 2, true);
assertClose.(pt.ys.last - pt.ys.first, m5.ys.last - m5.ys.first,
	"preserveTotal pins the total output extent", 1e-12);
assertClose.(pt.ys[3] - pt.ys[1], 5, "preserveTotal still stretches the span itself", 1e-12);
assertArr.([widths.(pt)[0], widths.(pt)[3], widths.(pt)[4]], [1, 1.5, 1] * (1 / 3.5),
	"everything outside is scaled by one common factor", 1e-12);
assert.(widths.(pt).every { |v| v > 0 }, "preserveTotal stays strictly monotone");
assert.(throws.({ m5.stretchSpan(0, 5, 2, true) }),
	"preserveTotal errors when the span is the whole domain");
assert.(throws.({ m5.stretchSpan(1, 3, 3, true) }),
	"preserveTotal errors when the stretched span would exceed the total");
assert.(m5.stretchSpan(1, 3, 2.3, true).notNil,
	"preserveTotal fine right up to the limit (2.5 * 2.3 < 6)");

// ---- setSpanSlope / setSpanTempo ----
ssl = m5.setSpanSlope(1, 3, 1);
assertClose.((ssl.ys[3] - ssl.ys[1]) / 2, 1, "setSpanSlope sets the mean slope exactly", 1e-12);
assertClose.((ssl.ys[2] - ssl.ys[1]) / (ssl.ys[3] - ssl.ys[1]), 2 / 2.5,
	"setSpanSlope preserves the span's internal shape", 1e-12);
assertArr.(ssl.xs, m5.xs, "setSpanSlope never touches the input anchors", 1e-12);
assertClose.(ssl.ys.first, 0, "setSpanSlope leaves the origin alone", 1e-12);
assertClose.(ssl.ys.last, 6 - 0.5, "setSpanSlope ripples the rest (2.5 s of span -> 2)", 1e-12);
assert.(throws.({ m5.setSpanSlope(1, 3, 0) }), "setSpanSlope rejects slope 0");
assert.(throws.({ m5.setSpanSlope(1, 3, -2) }), "setSpanSlope rejects a negative slope");
assert.(throws.({ m5.setSpanSlope(3, 1, 1) }), "setSpanSlope validates the span too");
stm = m5.setSpanTempo(1, 3, 2);
assertClose.(stm.ys[3] - stm.ys[1], 1, "setSpanTempo(2 bps): 2 beats take 1 second", 1e-12);
assertClose.(m5.setSpanTempo(1, 3, 2).ys.last, m5.setSpanSlope(1, 3, 0.5).ys.last,
	"setSpanTempo(bps) == setSpanSlope(1/bps)", 1e-12);
assert.(throws.({ m5.setSpanTempo(1, 3, 0) }), "setSpanTempo rejects bps 0");
assert.(throws.({ AnchorMap(m5.xs, m5.ys, MapFrame(\beat, \a), MapFrame(\beat, \b))
		.setSpanTempo(1, 3, 2) }),
	"setSpanTempo refuses a beat->beat map (a groove has no tempo)");
assert.(throws.({ AnchorMap(m5.xs, m5.ys, MapFrame(\sec, \a), MapFrame(\beat, \b))
		.setSpanTempo(1, 3, 2) }),
	"setSpanTempo refuses a sec->beat map (wrong direction)");
assert.(AnchorMap(m5.xs, m5.ys, MapFrame(\beat, \a), MapFrame(\sec, \b))
		.setSpanTempo(1, 3, 2).notNil,
	"setSpanTempo accepts any beat->sec frames");

// ---- MapSeq.replaceCell / collectCells ----
mcells = MapSeq([cellA, cellB], 2, beatF, listF, \error, \carry);
msq = mcells.replaceCell(1, AnchorMap([0, 2], [0, 4]));
assert.(msq.isKindOf(MapSeq) and: { (msq === mcells).not }, "replaceCell answers a NEW MapSeq");
assertArr.(msq.outWidths, [3, 4], "replaceCell installs the new cell");
assertArr.(mcells.outWidths, [3, 2], "replaceCell does not mutate the receiver");
assert.((msq.repeats == 2) and: { (msq.fromFrame == beatF) and: { msq.toFrame == listF } },
	"replaceCell keeps repeats and frames");
assert.((msq.extendBelow == \error) and: { msq.extendAbove == \carry },
	"replaceCell keeps the per-end extension");
assertClose.(msq.at(5), 7, "replaceCell changes the values (cycleOut 3 + 4)");
assertClose.(mcells.at(5), 5, "the original MapSeq still answers its old values");
assert.(throws.({ mcells.replaceCell(2, cellA) }), "replaceCell rejects an index past the end");
assert.(throws.({ mcells.replaceCell(-1, cellA) }), "replaceCell rejects a negative index");
assert.(throws.({ mcells.replaceCell(0.5, cellA) }), "replaceCell rejects a fractional index");
assert.(throws.({ mcells.replaceCell(0, AffineMap(1, 0)) }),
	"replaceCell revalidates through the constructor (total cell refused)");
g = mcells.collectCells { |c| AnchorMap(c.xs, c.ys * 2) };
assertArr.(g.outWidths, [6, 4], "collectCells maps every cell");
assertArr.(mcells.outWidths, [3, 2], "collectCells does not mutate the receiver");
assertClose.(g.at(5), 10, "collectCells changes the values");
assert.((g.repeats == 2) and: { g.fromFrame == beatF }, "collectCells keeps repeats and frames");
assertArr.(mcells.collectCells { |c, i| c }.outWidths, [3, 2],
	"collectCells with an identity func rebuilds the same tiling");
assert.(throws.({ mcells.collectCells { |c| AffineMap(1, 0) } }),
	"collectCells revalidates through the constructor");

// ---- bridge: TempoMap.asMonoMap + array warpTo dispatch (step 5a/5b) ----
g = TempoMap([1, 1, 1, 1], [1, 1, 2, 2]);
b = g.asMonoMap;
assert.(b.isKindOf(AnchorMap), "asMonoMap returns an AnchorMap");
assert.(b.mapsDimensions(\beat, \sec), "asMonoMap default frame dimensions");
assertArr.(b.mapSpans([1, 1, 1, 1]), g.mapBeats([1, 1, 1, 1]),
	"asMonoMap agrees with mapBeats inside the domain");
assertClose.(b.at(6), 10, "bridged map carries past the end (old clamp would flatline at 6)");
g.durs = [9, 9, 9, 9];
assertArr.(b.mapSpans([1, 1, 1, 1]), [1, 1, 2, 2],
	"asMonoMap is a snapshot — later TempoMap mutation does not leak in");
b = g.asMonoMap(fromFrame: beatF, toFrame: secF);
assert.(b.fromFrame == beatF, "asMonoMap binds given frames");
assertArr.([1, 1, 1, 1].warpTo(g.asMonoMap), g.asMonoMap.mapSpans([1, 1, 1, 1]),
	"array warpTo dispatches MonoMap to mapSpans");
g = TempoMap([1, 1, 1, 1], [1, 1, 2, 2]);
assertArr.([1, 1, 1].warpTo(g), g.mapBeats([1, 1, 1]),
	"array warpTo TempoMap path unchanged");
assertArr.([1, 1].warpTo(MapSeq.swing(1.5)), [1.2, 0.8],
	"warpTo works with any MonoMap (swing MapSeq)");

// ---- FunctionMap (the fromFunction escape hatch, step 5d's substrate) ----
fm = FunctionMap({ |x| x * 3 }, { |y| y / 3 }, [0, 10], beatF, secF);
assertClose.(fm.at(2), 6, "function map forward");
assertClose.(fm.invAt(6), 2, "function map inverse");
assertArr.(fm.domain, [0, 10], "function map domain is what it declared");
assertArr.(fm.range, [0, 30], "function map range is the image of its domain");
assertClose.(fm.inverse.at(6), 2, "function map inverse.at");
assert.(fm.inverse.fromFrame == secF and: { fm.inverse.toFrame == beatF },
	"function map inverse swaps frames");
assertArr.(fm.inverse.domain, [0, 30], "function map inverse domain is the range");
assert.(fm.bake === fm, "function map does not bake (no exact finite form)");
assert.(fm.withFrames(listF, wallF).fromFrame == listF, "function map withFrames");
assert.(throws.({ FunctionMap({ |x| x }) }), "function map needs both directions");
assert.(throws.({ FunctionMap({ |x| x }, { |y| y }, [5, 1]) }),
	"function map rejects an empty domain");
// \carry means "trust the function outside the domain"; \error fences it off
assertClose.(fm.at(20), 60, "carry trusts the function above the domain");
fmT = FunctionMap({ |x| x * 3 }, { |y| y / 3 }, [0, 10], beatF, secF, \error, \error);
assert.(throws.({ fmT.at(-1) }), "\\error below refuses under the domain");
assert.(throws.({ fmT.at(11) }), "\\error above refuses over the domain");
assert.(throws.({ fmT.invAt(-1) }), "\\error below guards the OUTPUT axis on invAt");
assertClose.(fmT.at(10), 30, "the domain end itself is inside");
// sample: exact on a linear map, frames and policy carried over
fmS = fm.sample(4);
assert.(fmS.isKindOf(AnchorMap), "sample freezes to an AnchorMap");
assert.(fmS.xs.size == 5, "sample n gives n+1 anchors");
assertClose.(fmS.xs.last, 10, "sample pins the far end of the domain");
assertClose.(fmS.at(7), 21, "sample of a linear map is exact");
assert.(fmS.fromFrame == beatF and: { fmS.toFrame == secF }, "sample keeps the frames");
assert.(throws.({ fm.sample(0) }), "sample rejects n < 1");
assert.(throws.({ FunctionMap({ |x| x }, { |y| y }).sample }),
	"sample needs a finite domain");

// ---- 5c: MIDIItemTempoMap.asMonoMap ----
// anchors at 10, 11, 12, 14 s for beats 0..3 — t0 10, relative times 0,1,2,4
mit = MIDIItemTempoMap.fromAnchors([10, 11, 12, 14], [0, 1, 2, 3]);
mitM = mit.asMonoMap;
assert.(mitM.isKindOf(AnchorMap), "MIDIItemTempoMap.asMonoMap returns an AnchorMap");
assert.(mitM.mapsDimensions(\beat, \sec), "5c maps beat -> sec");
assertArr.(mitM.xs, [0, 1, 2, 3], "5c beat anchors are the cumulative beat spans");
assertArr.(mitM.ys, [0, 1, 2, 4], "5c sec anchors are the relative times");
assertArr.([0, 0.5, 1, 2, 2.5, 3].collect { |b| mitM.at(b) },
	[0, 0.5, 1, 2, 2.5, 3].collect { |b| mit.timeAt(b) },
	"5c agrees with timeAt across the domain");
assertClose.(mitM.at(4), 6, "5c carries the final tempo past the end, like timeAt");
assertClose.(mitM.at(-1), -1, "5c carries the first tempo below 0, like timeAt");
assertClose.(mitM.invAt(4), 3, "5c inverts");
// absolute origin
mitA = mit.asMonoMap(origin: \absolute);
assertArr.(mitA.ys, [10, 11, 12, 14], "origin \\absolute adds t0");
assertArr.([0, 1.5, 3].collect { |b| mitA.at(b) },
	[0, 1.5, 3].collect { |b| mit.timeAt(b) + mit.t0 },
	"origin \\absolute matches timeAt + t0 (EventList.timeAtBeat's idiom)");
assert.((mitA.toFrame == mitM.toFrame).not,
	"relative and absolute seconds are different axes");
assert.(throws.({ mit.asMonoMap(origin: \wall) }), "origin must be relative or absolute");
// snapshot: no aliasing of the source arrays
mit.beats = [5, 5, 5];
assertArr.(mitM.ys, [0, 1, 2, 4], "5c is a snapshot — later mutation does not leak in");
// frames: shared per take, distinct per map
mkNote = { |ts, note = 60| (midicmd: \noteOn, type: \mk, timestamp: ts,
	midinote: note, dur: 0.5, sustain: 0.5, amp: 0.5) };
fxNotes = [0, 1, 2, 3, 4, 6].collect { |ts| mkNote.(ts) };
fxPlayer = MIDIItemPlayer(fxNotes, nil);
tk1 = MIDIItemTempoMap(fxPlayer, { |n| n[0..4] }, [1, 1, 1, 1, 1]);
tk2 = MIDIItemTempoMap(fxPlayer, { |n| n[0..4] }, [2, 2, 2, 2, 2]);
assert.(tk1.asMonoMap.toFrame == tk2.asMonoMap.toFrame,
	"two maps off one take share the wall axis");
assert.((tk1.asMonoMap.fromFrame == tk2.asMonoMap.fromFrame).not,
	"different beat readings of one take are different beat axes");
assert.(tk1.asMonoMap.fromFrame == tk1.asMonoMap.fromFrame,
	"repeated asMonoMap on one map agrees with itself");
assert.((tk1.asMonoMap.toFrame == mitM.toFrame).not,
	"anchor-built maps have no take, so they mint their own wall axis");
assert.((tk1.asMonoMap >> tk2.asMonoMap.inverse).isKindOf(ComposedMap),
	"shared wall axis lets one take's maps compose (a beat->beat relabel)");
// curved maps are refused, not silently flattened
mitC = MIDIItemTempoMap.fromAnchors([0, 1, 2, 4], [0, 1, 2, 3]).curve(1);
assert.(throws.({ mitC.asMonoMap }), "a curved map refuses to snapshot");
assertArr.(mitC.asMonoMap(allowCurved: true).ys, [0, 1, 2, 4],
	"allowCurved takes the linear anchors, explicitly dropping the curve");

// ---- 5d: EventList.asMonoMap ----
el = EventList.new;
el.beatDur = 0.5;
el.add(8, midinote: 60);
elM = el.asMonoMap;
assert.(elM.isKindOf(FunctionMap), "EventList.asMonoMap wraps, not merges");
assert.(elM.mapsDimensions(\beat, \sec), "5d maps beat -> sec");
assertClose.(elM.at(4), 2, "5d flat list: beat * beatDur");
assertClose.(elM.invAt(2), 4, "5d inverts back to beats");
assertArr.(elM.domain, [0, 8], "5d domain runs to the last event");
// the clamp at 0 is fenced off rather than carried
assert.(elM.extendBelow == \error, "5d declares \\error below (beatToWall clamps at 0)");
assert.(throws.({ elM.at(-1) }), "5d refuses beats below 0 instead of reading a clamped 0");
assertClose.(elM.at(20), 10, "5d carries above: the list holds its final tempo");
// \tempoTrack is captured and honoured
el2 = EventList.new;
el2.beatDur = 0.5;
el2.add(0, tempoTrack: 2);
el2.add(8, midinote: 60);
assertClose.(el2.asMonoMap.at(4), 4, "5d \\tempoTrack multiplier is in the map");
assertClose.(el2.asMonoMap(useTempoTrack: false).at(4), 2,
	"useTempoTrack: false is the base-tempo-only map");
// live, not a snapshot — and sample is the freeze
elFrozen = elM.sample(8);
el.beatDur = 1;
assertClose.(elM.at(4), 4, "5d is LIVE: a later beatDur change shows through");
assertClose.(elFrozen.at(4), 2, "sample froze the map at capture time");
el.beatDur = 0.5;
// frames are per list, so cross-list composition is refused until rebased
assert.(throws.({ el.asMonoMap >> el2.asMonoMap.inverse }),
	"two lists' wall axes do not compose by tag coincidence");
assert.(el.asMonoMap.fromFrame == el.asMonoMap.fromFrame,
	"repeated asMonoMap on one list agrees with itself");
assert.((MapFrame.forSource(el, \beat) == MapFrame.forSource(el, \sec)).not,
	"one source's beat and sec axes are different frames");
assert.(MapFrame.forSource(el, \beat) == MapFrame.forSource(el, \beat),
	"forSource is cached per source and slot");
assert.((MapFrame.forSource(el, \sec, \relative)
	== MapFrame.forSource(el, \sec, \absolute)).not,
	"an explicit slot splits two axes of the same dimension");
// a list whose tempo track outruns its events still vouches for the whole span
elFlat = EventList.new;
elFlat.beatDur = 1;
elFlat.add(0, tempoTrack: 1);
elFlat.add(2, tempoTrack: Tuple3(2, 12, \lin));
assert.(elFlat.asMonoMap.domain[1] >= 12,
	"5d extent covers a \\tempoTrack ramp running past the last event");

// ---- §12 seam: MonoMap -> AnchorTempoMap (the REVERSE bridge) ----
// beats 0,1,2,3 played at 10, 11, 12, 14 s (the 5c fixture, the other way round)
ad = AnchorMap([0, 1, 2, 3], [10, 11, 12, 14], MapFrame(\beat, \tk), MapFrame(\sec, \tk));
atm = ad.asAnchorTempoMap;
assert.(atm.isKindOf(AnchorTempoMap), "asAnchorTempoMap returns a concrete AnchorTempoMap");
assertClose.(atm.t0, 10, "rebase: false keeps the first anchor's seconds as t0 (take-absolute)");
assertArr.(atm.times, [0, 1, 2, 4], "anchor times normalized against t0");
assertArr.(atm.beats, [1, 1, 1], "beat SPANS come from the map's beat-side anchors");
// orientation is read from the frame dimensions, so the inverse map converts identically
atmInv = ad.inverse.asAnchorTempoMap;
assert.(ad.inverse.mapsDimensions(\sec, \beat), "the inverse really is sec -> beat");
assertClose.(atmInv.t0, atm.t0, "sec->beat orientation finds the same t0");
assertArr.(atmInv.times, atm.times, "sec->beat orientation recovers the same times");
assertArr.(atmInv.beats, atm.beats, "sec->beat orientation recovers the same beats");
// rebase: the two placements, and round trips against the source map
atmR = ad.asAnchorTempoMap(rebase: true);
assertClose.(atmR.t0, 0, "rebase: true puts the first anchor at 0 s (a list clock is a shape)");
assertArr.(atmR.times, atm.times, "rebase moves the origin only, never the shape");
assertArr.([0, 0.5, 2, 3, 4].collect { |b| atm.timeAt(b) + atm.t0 },
	[0, 0.5, 2, 3, 4].collect { |b| ad.at(b) },
	"rebase false: timeAt + t0 reproduces the source map (carry past the end included)");
assertArr.([0, 0.5, 2, 3].collect { |b| atmR.timeAt(b) },
	[0, 0.5, 2, 3].collect { |b| ad.at(b) - 10 },
	"rebase true: timeAt alone reproduces the source map's shape from 0");
assertArr.([10, 11.5, 14].collect { |t| atm.beatAt(t - atm.t0) },
	[10, 11.5, 14].collect { |t| ad.invAt(t) }, "beatAt inverts the source map");
// refusals: nothing is guessed or silently approximated
assert.(throws.({ AffineMap(2, 1, beatF, secF).asAnchorTempoMap }),
	"an AffineMap is total — no finite anchors to hand over");
assert.(throws.({ AnchorMap([0, 1], [0, 2], MapFrame(\beat, \x), MapFrame(\beat, \y))
	.asAnchorTempoMap }), "a beat->beat map (a groove) is not a tempo map");
assert.(throws.({ AnchorMap([0, 1], [0, 2]).asAnchorTempoMap }),
	"\\any dimensions refuse to guess an orientation (withFrames binds the real axes)");
assert.(throws.({ fm.asAnchorTempoMap }),
	"a FunctionMap stays symbolic under bake and is refused (.sample(n) is the freeze)");
assert.(throws.({ (fm >> AffineMap(2, 0, secF, wallF)).asAnchorTempoMap }),
	"a chain holding a FunctionMap is refused too");
assert.(throws.({ MapSeq([AnchorMap([0, 1], [0, 1], beatF, secF)], inf,
	beatF, secF).asAnchorTempoMap }), "infinite repeats have no finite anchor table");
assertArr.(fm.sample(4).asAnchorTempoMap.times, fm.sample(4).ys - fm.sample(4).ys.first,
	"the named way out works: sample(n) then convert");

// peekSource: a lookup that never mints
pk = EventList.new;
assert.(MapFrame.peekSource(pk, \beat).isNil, "peekSource on an unknown source is nil");
assert.(MapFrame.peekSource(pk, \beat).isNil,
	"peeking twice is still nil — the first peek minted nothing");
pkF = MapFrame.forSource(pk, \beat);
assert.(MapFrame.peekSource(pk, \beat) == pkF, "peekSource finds what forSource minted");
assert.(MapFrame.peekSource(pk, \sec).isNil, "peekSource does not leak across slots");

// ---- §12 seam: EventList.tempoMap_ coercion (extends 5d) ----
elT = EventList.new;
elT.tempoMap = ad;
assert.(elT.tempoMap.isKindOf(AnchorTempoMap),
	"a MonoMap assigned to tempoMap is coerced to a concrete AnchorTempoMap");
assert.(elT.tempoMap.isKindOf(MonoMap).not, "the list never holds a raw MonoMap");
assertClose.(elT.tempoMap.t0, 0, "a list clock is rebased: t0 == 0");
assertArr.([0, 1, 2.5, 3].collect { |b| elT.tempoMap.timeAt(b) },
	[0, 1, 2.5, 3].collect { |b| ad.at(b) - 10 },
	"the stored clock agrees with the source map's values from beat 0");
assertClose.(elT.baseWallDelta(0, 3), 4, "the coerced clock drives baseWallDelta");
// non-MonoMap assignment behaves exactly as before
tmPass = MIDIItemTempoMap.fromAnchors([5, 6, 7], [0, 1, 2]);
elT.tempoMap = tmPass;
assert.(elT.tempoMap === tmPass, "a non-MonoMap tempoMap is stored exactly as given");
assertClose.(elT.tempoMap.t0, 5, "and keeps its own t0 (no rebasing of old-world maps)");
elT.tempoMap = nil;
assert.(elT.tempoMap.isNil, "nil still clears the clock");
// swapping the clock invalidates the memoized beat->wall integral
elC = EventList.new;
elC.add(0, tempoTrack: 1);
elC.add(8, midinote: 60);
tEnvC = elC.tempoEnv;
elC.tempoMap = ad;
assertClose.(elC.beatToWall(3, tEnvC), 4, "beatToWall through the first coerced clock");
elC.tempoMap = AnchorMap([0, 1, 2, 3], [0, 2, 4, 8], MapFrame(\beat, \tk2), MapFrame(\sec, \tk2));
assertClose.(elC.beatToWall(3, tEnvC), 8,
	"assigning a new clock drops the cache keyed on the RETAINED tempoEnv");

MapFrame.clearSourceFrames;
assert.(MapFrame.forSource(el, \beat) != elM.fromFrame,
	"clearSourceFrames drops the registry (frames are re-minted after)");

(h[\report].() == 0).if { 0.exit } { 1.exit };
)
