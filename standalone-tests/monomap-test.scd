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

(h[\report].() == 0).if { 0.exit } { 1.exit };
)
