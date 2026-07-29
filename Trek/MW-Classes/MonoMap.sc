// TempoMap V2 core (see tempomap-v2-design.md). A MonoMap is a strictly
// increasing map between two named axes, with an inverse. Everything the old
// map zoo did — TempoMap, PlacedTempoMap, TempoWarp, Groove — is one of these
// plus combinators. This file is the step-1 core: frames, per-end extension,
// compose / inverse / place, generic span mapping, and the piecewise-linear
// implementation. PL fusion, Cyclic cells, and fromFunction come later.
//
// Frames: a MapFrame names a SPECIFIC axis (dimension + tag), not a dimension —
// two maps compose only when the inner toFrame equals the outer fromFrame,
// checked at construction, hard error on mismatch. Frames are load-bearing:
// timeAt/beatAt dispatch on frame dimensions (\beat, \sec), replacing the old
// respondsTo duck-typing.
//
// Extension: per end, \carry (extend at the boundary slope) or \error.
// No \clamp in the core — a clamped map is not invertible outside its domain.
// Total maps (affine) have domain nil; their extension slots are inert.

MapFrame {
	var <dimension, <tag;
	*new { |dimension = \any, tag|
		^super.newCopyArgs(dimension.asSymbol, (tag ?? { this.prNextTag }).asSymbol)
	}
	// auto-minted frames are unique: nothing composes with them by accident
	*mint { |dimension = \any| ^this.new(dimension) }
	*prNextTag { ^("f" ++ UniqueID.next).asSymbol }
	== { |that|
		^that.isKindOf(MapFrame) and: {
			dimension == that.dimension and: { tag == that.tag }
		}
	}
	hash { ^dimension.hash bitXor: tag.hash }
	printOn { |stream| stream << "MapFrame(" << dimension << ", " << tag << ")" }
	storeArgs { ^[dimension, tag] }
}

MonoMap {
	var <fromFrame, <toFrame, <extendBelow = \carry, <extendAbove = \carry;

	// nil frame arg mints a unique frame; a bare Symbol is taken as a dimension.
	prAsFrame { |frame, dimension = \any|
		frame.isKindOf(MapFrame).if { ^frame };
		frame.isKindOf(Symbol).if { ^MapFrame.mint(frame) };
		^MapFrame.mint(dimension)
	}
	prSetPolicy { |below, above|
		extendBelow = below ? \carry; extendAbove = above ? \carry;
		[extendBelow, extendAbove].do { |p|
			#[\carry, \error].includes(p).not.if {
				Error("MonoMap: extension must be \\carry or \\error, got %".format(p)).throw
			}
		}
	}

	// subclasses: at(x), invAt(y), inverse, domain ([lo, hi] in input coords, nil = total)
	at { |x| ^this.subclassResponsibility(thisMethod) }
	invAt { |y| ^this.subclassResponsibility(thisMethod) }
	inverse { ^this.subclassResponsibility(thisMethod) }
	domain { ^nil }
	range { var d = this.domain; ^d !? { [this.at(d[0]), this.at(d[1])] } }

	// f >> g : apply f, then g. Frame-checked in ComposedMap's constructor.
	>> { |outer| ^ComposedMap([this, outer]) }

	// f ++ g : concatenation, NOT composition — g's shape is laid after f's,
	// starting where f ended on both axes. Sugar for the finite two-cell MapSeq;
	// both operands must have finite domains (MapSeq validates). The result
	// keeps THIS map's frames (g is a shape; its frames are ignored).
	++ { |other| ^MapSeq([this, other], 1, this.fromFrame, this.toFrame) }

	// Same mapping, new axes. THE reuse mechanism: a map's shape (a swing
	// template, a metronome) is reusable, but only by explicit rebinding —
	// there are no wildcard frames.
	withFrames { |fromFrame, toFrame| ^this.subclassResponsibility(thisMethod) }

	// Collapse to a single concrete map. AffineMap and AnchorMap are already
	// their own baked form; only ComposedMap has work to do.
	bake { ^this }

	// Absolute placement: at(x) == this.at(x - fromOrigin) + toOrigin.
	// Replaces PlacedTempoMap and scattered `+ t0` arithmetic. New external
	// frames are minted (same dimensions) unless given.
	place { |fromOrigin = 0, toOrigin = 0, fromFrame, toFrame|
		var inF = this.prAsFrame(fromFrame, this.fromFrame.dimension);
		var outF = this.prAsFrame(toFrame, this.toFrame.dimension);
		^AffineMap(1, fromOrigin.neg, inF, this.fromFrame)
			>> this
			>> AffineMap(1, toOrigin, this.toFrame, outF)
	}

	// Span mapping, written once: differences of cumulative at/invAt. Spans are
	// relative so they need an origin. Non-positive results clamp to 1e-9 rather
	// than drop (the mapBeats length-preservation convention).
	mapSpans { |spans, from = 0|
		var pos = from, prev = this.at(from), out = Array(spans.size);
		spans.do { |s| var y;
			pos = pos + s;
			y = this.at(pos);
			out = out.add(max(y - prev, 1e-9));
			prev = y;
		};
		^out
	}
	unmapSpans { |spans, from = 0|
		var pos = from, prev = this.invAt(from), out = Array(spans.size);
		spans.do { |s| var x;
			pos = pos + s;
			x = this.invAt(pos);
			out = out.add(max(x - prev, 1e-9));
			prev = x;
		};
		^out
	}

	// Frame-dispatched sugar. Valid only when the map connects a beat axis and
	// a seconds axis — a beat->beat map (a groove) answers neither.
	timeAt { |beat|
		(fromFrame.dimension == \beat and: { toFrame.dimension == \sec }).if { ^this.at(beat) };
		(fromFrame.dimension == \sec and: { toFrame.dimension == \beat }).if { ^this.invAt(beat) };
		Error("timeAt: % maps % -> %, not beat<->sec"
			.format(this.class, fromFrame.dimension, toFrame.dimension)).throw
	}
	beatAt { |time|
		(fromFrame.dimension == \sec and: { toFrame.dimension == \beat }).if { ^this.at(time) };
		(fromFrame.dimension == \beat and: { toFrame.dimension == \sec }).if { ^this.invAt(time) };
		Error("beatAt: % maps % -> %, not beat<->sec"
			.format(this.class, fromFrame.dimension, toFrame.dimension)).throw
	}
	mapsDimensions { |a, b|
		^(fromFrame.dimension == a) and: { toFrame.dimension == b }
	}

	prExtensionError { |x, end|
		Error("%: % outside domain % (% end is \\error)"
			.format(this.class, x, this.domain, end)).throw
	}
}

// Total affine map: x * scale + offset, scale > 0. The placement primitive.
AffineMap : MonoMap {
	var <scale, <offset;
	*new { |scale = 1, offset = 0, fromFrame, toFrame|
		^super.new.initAffine(scale, offset, fromFrame, toFrame)
	}
	initAffine { |aScale, anOffset, inF, outF|
		scale = aScale; offset = anOffset;
		(scale <= 0).if {
			Error("AffineMap: scale must be > 0, got %".format(scale)).throw
		};
		fromFrame = this.prAsFrame(inF);
		toFrame = this.prAsFrame(outF);
	}
	at { |x| ^(x * scale) + offset }
	invAt { |y| ^(y - offset) / scale }
	inverse { ^AffineMap(scale.reciprocal, offset.neg / scale, toFrame, fromFrame) }
	withFrames { |fromFrame, toFrame| ^AffineMap(scale, offset, fromFrame, toFrame) }
	printOn { |stream|
		stream << "AffineMap(" << scale << ", " << offset << ")"
	}
}

// Piecewise-linear map through strictly increasing anchors (xs[i] -> ys[i]).
// The workhorse: fromAnchors is the media-neutral constructor, fromSpans the
// (beats, durs) form. \carry extends at the end-segment slopes.
AnchorMap : MonoMap {
	var <xs, <ys, prInverse;
	*new { |xs, ys, fromFrame, toFrame, extendBelow, extendAbove|
		^super.new.initAnchor(xs, ys, fromFrame, toFrame, extendBelow, extendAbove)
	}
	// args spelled out, not `... rest`: sclang cannot bind keyword args to a
	// rest parameter and silently drops them (frames would be minted instead)
	*fromAnchors { |xs, ys, fromFrame, toFrame, extendBelow, extendAbove|
		^this.new(xs, ys, fromFrame, toFrame, extendBelow, extendAbove)
	}
	// paired span arrays starting at (x0, y0) — cumulative sums of the spans
	*fromSpans { |spansIn, spansOut, x0 = 0, y0 = 0, fromFrame, toFrame, extendBelow, extendAbove|
		^this.new(
			([x0] ++ spansIn).integrate,
			([y0] ++ spansOut).integrate,
			fromFrame, toFrame, extendBelow, extendAbove)
	}
	initAnchor { |anXs, anYs, inF, outF, below, above|
		xs = anXs.asArray.collect(_.asFloat);
		ys = anYs.asArray.collect(_.asFloat);
		(xs.size != ys.size or: { xs.size < 2 }).if {
			Error("AnchorMap: need equal-size anchor arrays of at least 2 points (got % and %)"
				.format(anXs.size, anYs.size)).throw
		};
		[xs, ys].do { |a|
			a.doAdjacentPairs { |p, q|
				(q <= p).if {
					Error("AnchorMap: anchors must be strictly increasing (% then %)"
						.format(p, q)).throw
				}
			}
		};
		fromFrame = this.prAsFrame(inF);
		toFrame = this.prAsFrame(outF);
		this.prSetPolicy(below, above);
	}
	domain { ^[xs.first, xs.last] }
	at { |x|
		var i;
		(x < xs.first).if {
			(extendBelow == \error).if { this.prExtensionError(x, \below) };
			^ys.first + ((x - xs.first) * this.prSlope(0))
		};
		(x > xs.last).if {
			(extendAbove == \error).if { this.prExtensionError(x, \above) };
			^ys.last + ((x - xs.last) * this.prSlope(xs.size - 2))
		};
		i = this.prSegment(xs, x);
		^ys[i] + ((x - xs[i]) * this.prSlope(i))
	}
	invAt { |y| ^this.inverse.at(y) }
	// exact and cheap: swap the anchor arrays (extension ends keep their sides —
	// the map is increasing, so below stays below)
	inverse {
		^prInverse ?? {
			prInverse = AnchorMap(ys, xs, toFrame, fromFrame, extendBelow, extendAbove)
		}
	}
	withFrames { |fromFrame, toFrame|
		^AnchorMap(xs, ys, fromFrame, toFrame, extendBelow, extendAbove)
	}
	// ---- Transforms (design doc, "Transforms vs application"). Each returns a
	// NEW AnchorMap and never mutates the receiver. A transform reinterprets the
	// SAME two axes, so fromFrame/toFrame and the per-end extension policy carry
	// over unchanged. MapSeq and ComposedMap deliberately have no transform
	// methods: `.bake` to an AnchorMap first, then transform.

	// Resample at lower anchor density ("pick" placement,
	// quantize-tempomap-project.md §3a): keep each group's BOUNDARY anchors
	// verbatim, drop the interior ones. `groups` is a positive integer (merge
	// every n spans) or an array of them, CYCLED Pseq-style like
	// Collection:clumps, so clump([4]) is "by 4-beat bars forever" and
	// clump([2,4,6]) is mixed meter. The remainder group is always kept, so the
	// first and last anchors survive (endpoint pinning) and both total extents
	// are unchanged. Result always has >= 2 anchors. Compose curvature after:
	// map.clump(4).curve(amount).
	clump { |groups = 2|
		var sizes = groups.asArray, nSpans = xs.size - 1, keep = [0], pos = 0, gi = 0;
		(sizes.isEmpty or: {
			sizes.any { |n| n.isNumber.not or: { n.asInteger != n } or: { n <= 0 } }
		}).if {
			Error("AnchorMap.clump: group sizes must be positive integers, got %"
				.format(groups)).throw
		};
		while { pos < nSpans } {
			pos = min(pos + sizes.wrapAt(gi), nSpans);
			keep = keep.add(pos);
			gi = gi + 1;
		};
		^AnchorMap(keep.collect { |i| xs[i] }, keep.collect { |i| ys[i] },
			fromFrame, toFrame, extendBelow, extendAbove)
	}

	// Monotone cubic Hermite (PCHIP) through the anchors, SAMPLED back to a PL
	// map with `oversample` segments per original span (ported from
	// MIDIItemTempoMap.prCurve). Fritsch-Carlson tangent clamping keeps the
	// underlying curve monotone, hence the sampled result too. The curve passes
	// through every anchor, so anchors stay locked and only the shape between
	// them bends; the original anchors are sample points and are snapped
	// bit-exact. `amount` blends linear (0) to full curve (1). At amount 0 the
	// curve IS the receiver, so we return its anchors rather than emit
	// oversample-times-redundant collinear ones.
	curve { |amount = 1, oversample = 16|
		var n = xs.size, m, bs, ts;
		(oversample.isNumber.not
			or: { oversample.asInteger != oversample }
			or: { oversample < 1 }).if {
				Error("AnchorMap.curve: oversample must be a positive integer, got %"
					.format(oversample)).throw
		};
		(amount == 0).if {
			^AnchorMap(xs, ys, fromFrame, toFrame, extendBelow, extendAbove)
		};
		m = this.prMonotoneTangents(xs, ys);
		bs = Array(((n - 1) * oversample) + 1);
		ts = Array(((n - 1) * oversample) + 1);
		(n - 1).do { |k|
			var h = xs[k + 1] - xs[k], dy = ys[k + 1] - ys[k];
			oversample.do { |j|
				var u = j / oversample;
				var lin = ys[k] + (dy * u);
				var herm = this.prHermite(u, ys[k], ys[k + 1], m[k] * h, m[k + 1] * h);
				bs = bs.add(xs[k] + (h * u));
				ts = ts.add(lin + ((herm - lin) * amount));
			};
			// u == 0 is algebraically exact already; assign anyway so no rounding
			// can ever move an original anchor off its recorded position
			bs[k * oversample] = xs[k];
			ts[k * oversample] = ys[k];
		};
		bs = bs.add(xs.last); ts = ts.add(ys.last);
		^AnchorMap(bs, ts, fromFrame, toFrame, extendBelow, extendAbove)
	}

	// Blend every span's OUTPUT width toward the width it would have at the
	// uniform mean slope (total output extent / total input extent); input
	// anchors are untouched. Same numbers as the old TempoMap.quantize. It is
	// computed as a blend of the ANCHORS toward the straight line through the
	// endpoints — the same map, but bit-exact at amount 0 and endpoint-pinning
	// for free. amount 1 is the rigid constant-slope map. Strictly monotone for
	// any amount in [0, 1]: a convex blend of two strictly increasing anchor
	// sets. Total output extent is preserved exactly.
	quantize { |amount = 1|
		var x0 = xs.first, y0 = ys.first;
		var slope = (ys.last - y0) / (xs.last - x0);
		var newYs = xs.collect { |x, i|
			(ys[i] * (1 - amount)) + ((y0 + ((x - x0) * slope)) * amount)
		};
		// pin both ends bit-exact (the blend is already equal to within rounding)
		newYs[0] = ys.first;
		newYs[newYs.size - 1] = ys.last;
		^AnchorMap(xs, newYs, fromFrame, toFrame, extendBelow, extendAbove)
	}

	// Local quantize: each span blends toward the mean slope over a window
	// centred on that span. The window is `window` INPUT-AXIS units wide — NOT a
	// count of anchors as the old TempoMap.quantizeWindow used, because with
	// irregular anchors an index window covers inconsistent musical widths
	// (quantize-tempomap-project.md §6a, "keep smoothing beat-domain aware").
	// The local mean slope is input-overlap weighted, i.e. exactly (output
	// covered by the window) / (input covered by the window), clipped at the
	// domain ends. `window` defaults to a quarter of the input extent.
	// Endpoints: the first anchor is fixed and interior anchors DRIFT (that is
	// the smoothing); the far end is pinned by scaling every new width by one
	// factor, so the total output extent is preserved exactly and monotonicity
	// survives (a positive scale). O(spans^2) — anchor counts here are small.
	quantizeWindow { |amount = 1, window|
		var w = window ?? { (xs.last - xs.first) / 4 };
		var nSpans = xs.size - 1, inW, outW, newW, newYs;
		(w.isNumber.not or: { w <= 0 }).if {
			Error("AnchorMap.quantizeWindow: window must be > 0 input units, got %"
				.format(window)).throw
		};
		// bit-exact identity: the width round trip below is not exact at amount 0
		(amount == 0).if {
			^AnchorMap(xs, ys, fromFrame, toFrame, extendBelow, extendAbove)
		};
		inW = xs.differentiate.drop(1);
		outW = ys.differentiate.drop(1);
		newW = nSpans.collect { |i|
			var lo = ((xs[i] + xs[i + 1]) * 0.5) - (w * 0.5);
			var hi = lo + w;
			var num = 0, den = 0, local;
			nSpans.do { |j|
				var o = min(hi, xs[j + 1]) - max(lo, xs[j]);
				(o > 0).if { num = num + (o * outW[j] / inW[j]); den = den + o };
			};
			// den > 0 always: span i itself overlaps its own centred window
			local = (den > 0).if { num / den } { outW[i] / inW[i] };
			(outW[i] * (1 - amount)) + (local * inW[i] * amount)
		};
		newW = newW * ((ys.last - ys.first) / newW.sum);
		newYs = ([ys.first] ++ newW).integrate;
		newYs[nSpans] = ys.last;
		^AnchorMap(xs, newYs, fromFrame, toFrame, extendBelow, extendAbove)
	}

	// cubic Hermite basis on one span, local u in [0, 1]
	prHermite { |u, y0, y1, m0, m1|
		var u2 = u * u, u3 = u2 * u;
		^( ((2 * u3) - (3 * u2) + 1) * y0 )
		+ ( (u3 - (2 * u2) + u) * m0 )
		+ ( (((-2) * u3) + (3 * u2)) * y1 )
		+ ( (u3 - u2) * m1 )
	}
	// per-node tangents dy/dx with the Fritsch-Carlson monotonicity clamp:
	// keeps the interpolant increasing, so tempo can never go negative
	prMonotoneTangents { |x, y|
		var dx = x.differentiate.drop(1).collect { |i| max(i.abs, 1e-9) };
		var d = y.differentiate.drop(1) / dx;   // secant slopes, size n-1
		var n = x.size;
		var m = [d[0]];
		(n - 2).do { |i| m = m.add((d[i] + d[i + 1]) * 0.5) };
		m = m.add(d.last);
		(n - 1).do { |k|
			(d[k] == 0).if
				{ m[k] = 0; m[k + 1] = 0 }
				{
					var a = m[k] / d[k];
					var bb = m[k + 1] / d[k];
					var s = (a * a) + (bb * bb);
					(s > 9).if {
						var tau = 3 / s.sqrt;
						m[k] = tau * a * d[k];
						m[k + 1] = tau * bb * d[k];
					}
				}
		};
		^m
	}

	prSlope { |i| ^(ys[i + 1] - ys[i]) / (xs[i + 1] - xs[i]) }
	// binary search: greatest i with a[i] <= x, in 0..size-2
	prSegment { |a, x|
		var lo = 0, hi = a.size - 2, mid;
		while { lo < hi } {
			mid = (lo + hi + 1) div: 2;
			(a[mid] <= x).if { lo = mid } { hi = mid - 1 };
		};
		^lo
	}
	printOn { |stream|
		stream << "AnchorMap(" << xs.size << " anchors, [" << xs.first << ".." << xs.last << "])"
	}
}

// Lazy composition, applied left to right. Frames checked here, at
// construction; domain errors surface at apply time (checkComposable is the
// opt-in early check, for authoring and tests).
ComposedMap : MonoMap {
	var <maps;
	*new { |maps|
		^super.new.initComposed(maps)
	}
	initComposed { |someMaps|
		// flatten nested compositions so chains stay one level deep
		maps = someMaps.collect { |m|
			m.isKindOf(ComposedMap).if { m.maps } { [m] }
		}.flatten(1);
		(maps.size < 1).if { Error("ComposedMap: empty chain").throw };
		maps.doAdjacentPairs { |f, g|
			(f.toFrame == g.fromFrame).not.if {
				Error("ComposedMap: frame mismatch — % feeds % but % expects %"
					.format(f, f.toFrame, g, g.fromFrame)).throw
			}
		};
		fromFrame = maps.first.fromFrame;
		toFrame = maps.last.toFrame;
	}
	at { |x| var v = x; maps.do { |m| v = m.at(v) }; ^v }
	invAt { |y| var v = y; maps.reverseDo { |m| v = m.invAt(v) }; ^v }
	inverse { ^ComposedMap(maps.reverse.collect(_.inverse)) }
	domain { ^maps.first.domain }
	// rebind the chain's outer ends; interior frames are already consistent
	withFrames { |fromFrame, toFrame|
		// guarded: maps[1..0] is a DESCENDING range in sclang, not an empty slice
		var middle = (maps.size > 2).if { maps[1..maps.size - 2] } { [] };
		(maps.size == 1).if { ^ComposedMap([maps.first.withFrames(fromFrame, toFrame)]) };
		^ComposedMap(
			[maps.first.withFrames(fromFrame, maps.first.toFrame)]
			++ middle
			++ [maps.last.withFrames(maps.last.fromFrame, toFrame)])
	}
	// Exact PL fusion (design doc, Performance). PL composed with PL is PL, so
	// the chain collapses with ZERO approximation error — no resampling, no
	// anchor blowup. All-affine folds to one AffineMap; any AnchorMap in the
	// chain gives one AnchorMap whose breakpoints are the union of every
	// AnchorMap's xs pulled back to the chain's input axis.
	bake {
		var bps, xs = [], ys = [];
		// reserved: a link that is neither affine nor PL (Cyclic, curved) has
		// no exact PL fusion — leave the whole chain symbolic rather than guess
		maps.every { |m| m.isKindOf(AffineMap) or: { m.isKindOf(AnchorMap) } }.not.if { ^this };
		maps.every(_.isKindOf(AffineMap)).if { ^this.prBakeAffine };
		bps = this.prPullbackXs;
		// keep only strictly increasing pairs: pullback can land two
		// breakpoints on top of each other, which AnchorMap rejects
		bps.do { |x|
			var y = this.at(x);
			(xs.isEmpty or: {
				((x - xs.last) > (1e-12 * max(1.0, x.abs)))
				and: { (y - ys.last) > (1e-12 * max(1.0, y.abs)) }
			}).if { xs = xs.add(x); ys = ys.add(y) }
		};
		xs.isEmpty.if { ^this };
		// AnchorMap needs 2 anchors; a chain that collapsed to one keeps its
		// (constant) slope, so any second point on the input axis will do
		(xs.size < 2).if {
			xs = xs.add(xs.last + 1);
			ys = ys.add(this.at(xs.last));
		};
		^AnchorMap(xs, ys, fromFrame, toFrame,
			this.prExtendPolicy(\extendBelow), this.prExtendPolicy(\extendAbove))
	}
	prBakeAffine {
		var scale = 1, offset = 0;
		maps.do { |m| scale = scale * m.scale; offset = (offset * m.scale) + m.offset };
		^AffineMap(scale, offset, fromFrame, toFrame)
	}
	// every AnchorMap's xs, pulled back through the inverses of the links
	// before it, sorted. Dropped when an upstream \error end refuses the
	// pullback: such a breakpoint is unreachable from the input axis.
	prPullbackXs {
		var raw = [];
		maps.do { |m, i|
			m.isKindOf(AnchorMap).if {
				m.xs.do { |x|
					var v = x, ok = true;
					try { i.reverseDo { |j| v = maps[j].invAt(v) } } { ok = false };
					ok.if { raw = raw.add(v) };
				}
			}
		};
		^raw.sort
	}
	// conservative: \error if ANY link errors on that end, because out there
	// the chain would have run off that link's domain and thrown.
	prExtendPolicy { |selector|
		^maps.any { |m| m.perform(selector) == \error }.if { \error } { \carry }
	}

	// Early range check: each map's range endpoints must sit inside the next
	// map's domain wherever that next map has an \error end. Total inner maps
	// can't be checked this way and are skipped.
	checkComposable {
		maps.doAdjacentPairs { |f, g|
			var r = f.range, d = g.domain;
			(r.notNil and: { d.notNil }).if {
				((g.extendBelow == \error) and: { r[0] < d[0] }).if {
					Error("checkComposable: % range % starts below % domain %"
						.format(f, r, g, d)).throw
				};
				((g.extendAbove == \error) and: { r[1] > d[1] }).if {
					Error("checkComposable: % range % ends above % domain %"
						.format(f, r, g, d)).throw
				};
			}
		};
		^this
	}
	printOn { |stream|
		stream << "ComposedMap(";
		maps.do { |m, i| (i > 0).if { stream << " >> " }; m.printOn(stream) };
		stream << ")"
	}
}

// Concatenation / tiling (design doc, "Cyclic maps (changing meters)").
// Finite-domain maps ("cells") laid end to end, each starting where the
// previous ended on BOTH axes, cycling the list Pseq-style for `repeats`
// passes; `repeats: inf` tiles the whole real line (negative side included)
// and the map is total. Continuous and monotone by construction; slope may
// jump at a join (bar-line tempo change), position never does.
//
// Cells are SHAPES: their frames are ignored beyond a dimension-consistency
// check, and the MapSeq binds its own frames like withFrames does. Cell
// coordinates are relative — a cell's domain lo maps to the tile's start —
// so the MapSeq itself starts at 0 on both axes; absolute placement is
// `place`'s job. Drift (out width != in width) is allowed: it tiles into a
// steady per-cycle stretch. Each MonoMap subclass is one evaluation
// strategy; MapSeq's is "locate the tile, delegate to the cell".
//
//   MapSeq([barIn5, barIn4], inf)                  // changing meter, forever
//   MapSeq.swing(1.5)                              // Groove.swing as cells
//   MapSeq.modulate(8, 0.1, \sine)                 // sampled wave cell
//   aMap ++ anotherMap                             // finite pair
MapSeq : MonoMap {
	var <cells, <repeats, <inWidths, <outWidths, <inCum, <outCum;
	var <cycleIn, <cycleOut, inLos, outLos;

	*new { |cells, repeats = 1, fromFrame, toFrame, extendBelow, extendAbove|
		^super.new.initMapSeq(cells, repeats, fromFrame, toFrame, extendBelow, extendAbove)
	}

	// ---- cell sugar. The combinator proper knows nothing about music; these
	// class methods are where swing ratios and wave shapes live. Cell builders
	// return AnchorMaps (usable anywhere); the *swing / *modulate / *groove
	// forms return ready infinite MapSeqs on a single shared beat axis, which
	// is what a Groove is (design doc: "a total map whose two frames are the
	// same beat axis").

	// Groove.swing semantics: the long note takes ratio/(ratio+1) of the
	// period, so swing(1.5) over 2 beats puts straight beat 1 at grooved 1.2.
	*swingCell { |ratio = 1.5, periodBeats = 2, fromFrame, toFrame|
		var w = periodBeats;
		((ratio.isNumber.not) or: { ratio <= 0 }).if {
			Error("MapSeq.swingCell: ratio must be > 0, got %".format(ratio)).throw
		};
		^AnchorMap(
			[0, w * 0.5, w],
			[0, w * ratio / (ratio + 1), w],
			fromFrame ? \beat, toFrame ? \beat)
	}
	// Sampled PL approximation of Groove's wave displacement (Groove.prI):
	// displacement is the antiderivative of a mean-1 duration multiplier, so
	// it vanishes at both cell ends and the cell preserves its period exactly.
	// nSegments defaults to 16 (~1e-3 absolute vs the closed form at
	// amount 0.2); a closed-form cell class comes only if that ever audibly
	// matters. phase is a CYCLE FRACTION (0..1), as in Groove.
	*waveCell { |periodBeats = 2, amount = 0.2, shape = \sine, phase = 0,
		nSegments = 16, fromFrame, toFrame|
		var w = periodBeats, xs, ys;
		(w.isNumber.not or: { w <= 0 }).if {
			Error("MapSeq.waveCell: periodBeats must be > 0, got %".format(w)).throw
		};
		(amount.abs >= 1).if {
			Error("MapSeq.waveCell: |amount| must be < 1 (%) — at 1 the multiplier "
				"reaches 0 and the cell stops being invertible".format(amount)).throw
		};
		#[\square, \sine, \tri].includes(shape).not.if {
			Error("MapSeq.waveCell: unknown shape %".format(shape)).throw
		};
		xs = (nSegments + 1).collect { |i| w * i / nSegments };
		ys = (nSegments + 1).collect { |i|
			var u = i / nSegments;
			(w * u) + (w * (this.prWaveI(u + phase, amount, shape)
				- this.prWaveI(phase, amount, shape)))
		};
		// endpoints are exact by construction; kill float dust so the tiling
		// joins land on the nominal grid
		ys[0] = 0.0; ys[nSegments] = w.asFloat;
		^AnchorMap(xs, ys, fromFrame ? \beat, toFrame ? \beat)
	}
	// Groove.prI: antiderivative of (multiplier - 1) over one normalized
	// period, mean-zero so prWaveI(0) == prWaveI(1) == 0.
	*prWaveI { |x, amount, shape|
		var t = x - x.floor;
		^switch (shape)
			{ \square } { amount * min(t, 1 - t) }
			{ \sine }   { amount * (1 - cos(2pi * t)) / (2pi) }
			{ \tri }    {
				(t <= 0.5).if(
					{ amount * ((2 * t * t) - t) },
					{ amount * ((-2 * t * t) + (3 * t) - 1) })
			}
	}
	// one or more cells tiled forever on a single beat axis == a Groove
	*groove { |cells, fromFrame, toFrame|
		var f = fromFrame ?? { MapFrame.mint(\beat) };
		^MapSeq(cells.asArray, inf, f, toFrame ? f)
	}
	*swing { |ratio = 1.5, periodBeats = 2, fromFrame, toFrame|
		^this.groove([this.swingCell(ratio, periodBeats)], fromFrame, toFrame)
	}
	*modulate { |periodBeats = 2, amount = 0.2, shape = \sine, phase = 0,
		nSegments = 16, fromFrame, toFrame|
		^this.groove(
			[this.waveCell(periodBeats, amount, shape, phase, nSegments)],
			fromFrame, toFrame)
	}

	initMapSeq { |someCells, someRepeats, inF, outF, below, above|
		var inDims, outDims, inD, outD;
		cells = someCells.asArray;
		(cells.size < 1).if { Error("MapSeq: need at least one cell").throw };
		cells.do { |c|
			c.isKindOf(MonoMap).not.if {
				Error("MapSeq: cells must be MonoMaps, got %".format(c.class)).throw
			};
			c.domain.isNil.if {
				Error("MapSeq: cells must have a finite domain — % is total".format(c)).throw
			};
		};
		repeats = someRepeats ? 1;
		((repeats == inf) or: { repeats.isInteger and: { repeats > 0 } }).not.if {
			Error("MapSeq: repeats must be a positive integer or inf, got %"
				.format(repeats)).throw
		};
		// cells are shapes, so their frame TAGS are ignored; only the
		// dimensions have to agree (\any is the wildcard the minter uses)
		inDims = cells.collect { |c| c.fromFrame.dimension }.reject { |d| d == \any };
		outDims = cells.collect { |c| c.toFrame.dimension }.reject { |d| d == \any };
		(inDims.asSet.size > 1).if {
			Error("MapSeq: cells disagree on the input dimension %".format(inDims)).throw
		};
		(outDims.asSet.size > 1).if {
			Error("MapSeq: cells disagree on the output dimension %".format(outDims)).throw
		};
		inD = inDims.isEmpty.if { \any } { inDims.first };
		outD = outDims.isEmpty.if { \any } { outDims.first };

		inLos = cells.collect { |c| c.domain[0] };
		outLos = cells.collect { |c| c.at(c.domain[0]) };
		inWidths = cells.collect { |c| c.domain[1] - c.domain[0] };
		outWidths = cells.collect { |c, i| c.at(c.domain[1]) - outLos[i] };
		[inWidths, outWidths].do { |ws|
			ws.do { |w|
				(w <= 0).if {
					Error("MapSeq: cell widths must be > 0 (got %)".format(w)).throw
				}
			}
		};
		// cumulative tile starts, size n+1; last entry is the cycle width
		inCum = ([0] ++ inWidths).integrate;
		outCum = ([0] ++ outWidths).integrate;
		cycleIn = inCum.last;
		cycleOut = outCum.last;

		fromFrame = this.prAsFrame(inF, inD);
		toFrame = this.prAsFrame(outF, outD);
		this.prSetPolicy(below, above);
	}

	domain { ^(repeats == inf).if { nil } { [0, repeats * cycleIn] } }

	at { |x|
		var p, local, k, hiIn;
		(repeats != inf).if {
			hiIn = repeats * cycleIn;
			(x < 0).if {
				(extendBelow == \error).if { this.prExtensionError(x, \below) };
				^cells.first.at(inLos.first + x) - outLos.first
			};
			(x > hiIn).if {
				(extendAbove == \error).if { this.prExtensionError(x, \above) };
				// past the end: keep going through the LAST cell (each pass runs
				// the whole list, so that is always cells.last)
				^((repeats - 1) * cycleOut) + outCum[cells.size - 1]
					+ (cells.last.at(inLos.last + (x - hiIn) + inWidths.last)
						- outLos.last)
			};
		};
		// floor division so negative x tiles too (the old Groove was total)
		p = (x / cycleIn).floor;
		((repeats != inf) and: { p >= repeats }).if { p = repeats - 1 };
		local = x - (p * cycleIn);
		k = this.prTile(inCum, local);
		^(p * cycleOut) + outCum[k]
			+ (cells[k].at(inLos[k] + (local - inCum[k])) - outLos[k])
	}

	invAt { |y|
		var p, local, k, hiOut;
		(repeats != inf).if {
			hiOut = repeats * cycleOut;
			(y < 0).if {
				(extendBelow == \error).if { this.prRangeError(y, \below) };
				^cells.first.invAt(outLos.first + y) - inLos.first
			};
			(y > hiOut).if {
				(extendAbove == \error).if { this.prRangeError(y, \above) };
				^((repeats - 1) * cycleIn) + inCum[cells.size - 1]
					+ (cells.last.invAt(outLos.last + (y - hiOut) + outWidths.last)
						- inLos.last)
			};
		};
		p = (y / cycleOut).floor;
		((repeats != inf) and: { p >= repeats }).if { p = repeats - 1 };
		local = y - (p * cycleOut);
		k = this.prTile(outCum, local);
		^(p * cycleIn) + inCum[k]
			+ (cells[k].invAt(outLos[k] + (local - outCum[k])) - inLos[k])
	}

	// the tiling is increasing, so a per-end policy keeps its side
	inverse {
		^MapSeq(cells.collect(_.inverse), repeats, toFrame, fromFrame,
			extendBelow, extendAbove)
	}
	withFrames { |fromFrame, toFrame|
		^MapSeq(cells, repeats, fromFrame, toFrame, extendBelow, extendAbove)
	}

	// Finite tilings of PL cells flatten to one AnchorMap: translate each
	// cell's anchors by its cumulative offsets and drop the duplicated joins.
	// Infinite repeats cannot be finite anchors, and a cell that does not bake
	// to a PL map of the same width keeps the structure symbolic.
	bake {
		var baked, xs = [], ys = [], ok = true;
		(repeats == inf).if { ^this };
		baked = cells.collect(_.bake);
		baked.do { |b, k|
			(b.isKindOf(AnchorMap)
				and: { ((b.xs.last - b.xs.first) - inWidths[k]).abs < 1e-9 }
				and: { ((b.ys.last - b.ys.first) - outWidths[k]).abs < 1e-9 }).not.if {
					ok = false
				}
		};
		ok.not.if { ^this };
		repeats.do { |p|
			baked.do { |b, k|
				var xoff = (p * cycleIn) + inCum[k] - b.xs.first;
				var yoff = (p * cycleOut) + outCum[k] - b.ys.first;
				b.xs.do { |x, i|
					var xv = x + xoff, yv = b.ys[i] + yoff;
					// joins land on top of the previous cell's last anchor
					(xs.isEmpty or: {
						((xv - xs.last) > (1e-12 * max(1.0, xv.abs)))
						and: { (yv - ys.last) > (1e-12 * max(1.0, yv.abs)) }
					}).if { xs = xs.add(xv); ys = ys.add(yv) }
				}
			}
		};
		(xs.size < 2).if { ^this };
		^AnchorMap(xs, ys, fromFrame, toFrame, extendBelow, extendAbove)
	}

	// greatest i in 0..size-2 with cum[i] <= v (binary search, prSegment's twin)
	prTile { |cum, v|
		var lo = 0, hi = cum.size - 2, mid;
		while { lo < hi } {
			mid = (lo + hi + 1) div: 2;
			(cum[mid] <= v).if { lo = mid } { hi = mid - 1 };
		};
		^lo
	}
	prRangeError { |y, end|
		Error("%: % outside range % (% end is \\error)"
			.format(this.class, y, this.range, end)).throw
	}
	printOn { |stream|
		stream << "MapSeq(" << cells.size << " cells, cycle " << cycleIn
			<< "->" << cycleOut << ", repeats " << repeats << ")"
	}
}

// V2 bridge (tempomap-v2-design.md step 5a): the old world enters the core at
// explicit seams; TempoMap itself is frozen (see tempomap-compat-test.scd).
+ TempoMap {
	// Snapshot of beats/durs as an AnchorMap — later mutation of this TempoMap
	// does not leak in. Boundary is \carry by default, deliberately NOT the old
	// clamp: clamp is not invertible and the core refuses it.
	asMonoMap { |fromFrame, toFrame, extendBelow, extendAbove|
		^AnchorMap.fromSpans(beats, durs,
			fromFrame: fromFrame ? \beat, toFrame: toFrame ? \sec,
			extendBelow: extendBelow, extendAbove: extendAbove)
	}
}
