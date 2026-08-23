// TempoMap V2 core (see tempomap-v2-design.md). MonoMaps are strictly
// increasing, invertible maps between named axes. This file defines the map
// types, combinators, transforms, and legacy bridges.
//
// A MapFrame identifies a specific axis by dimension and tag. Composition
// requires matching frames; timeAt/beatAt dispatch on frame dimensions.
//
// Extension: per end, \carry (extend at the boundary slope) or \error.
// No \clamp in the core — a clamped map is not invertible outside its domain.
// Total maps (affine) have domain nil; their extension slots are inert.

MapFrame {
	classvar prSourceFrames;
	var <dimension, <tag;
	*new { |dimension = \any, tag|
		^super.newCopyArgs(dimension.asSymbol, (tag ?? { this.prNextTag }).asSymbol)
	}
	// auto-minted frames are unique: nothing composes with them by accident
	*mint { |dimension = \any| ^this.new(dimension) }
	*prNextTag { ^("f" ++ UniqueID.next).asSymbol }

	// Return the cached frame for (source, slot), minting it if needed. Maps from
	// the same source therefore share an axis and can compose. Bridges use this
	// for take-wall frames. The slot defaults to dimension; the cache retains
	// sources until cleared.
	*forSource { |source, dimension = \any, slot|
		var perSource;
		slot = slot ? dimension;
		prSourceFrames ?? { prSourceFrames = IdentityDictionary.new };
		perSource = prSourceFrames.at(source) ?? {
			var d = IdentityDictionary.new;
			prSourceFrames.put(source, d);
			d
		};
		^perSource.at(slot) ?? {
			var f = this.mint(dimension);
			perSource.put(slot, f);
			f
		}
	}
	// Return an existing source frame without minting or retaining a new source.
	*peekSource { |source, slot = \any|
		var perSource = prSourceFrames !? { prSourceFrames.at(source) };
		^perSource !? { perSource.at(slot) }
	}
	*clearSourceFrames { prSourceFrames = nil }
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

	// Concatenate two finite maps. `other` is treated as a shape and may be a
	// legacy map supported by asMonoMap. Composition uses >> instead.
	++ { |other| ^MapSeq([this, other], 1, this.fromFrame, this.toFrame) }

	// Rebind the same shape to new axes.
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

	// Span mapping: differences of cumulative at/invAt. Contract (origin,
	// length preservation, epsilon clamp) lives on mapSpansFrom in plusArray.sc.
	mapSpans   { |spans, from = 0| ^spans.mapSpansFrom(from, { |p| this.at(p)    }) }
	unmapSpans { |spans, from = 0| ^spans.mapSpansFrom(from, { |p| this.invAt(p) }) }

	mapsDimensions { |a, b|
		^(fromFrame.dimension == a) and: { toFrame.dimension == b }
	}

	// Frame-dispatched sugar. Valid only when the map connects a beat axis and
	// a seconds axis — a beat->beat map (a groove) answers neither.
	timeAt { |beat|
		this.mapsDimensions(\beat, \sec).if{ ^this.at(beat)};
		this.mapsDimensions(\sec, \beat).if{ ^this.invAt(beat)};
		Error("timeAt: % maps % -> %, not beat<->sec"
			.format(this.class, fromFrame.dimension, toFrame.dimension)).throw
	}
	beatAt { |time|
		this.mapsDimensions(\sec, \beat).if{ ^this.at(time)};
		this.mapsDimensions(\beat, \sec).if{ ^this.invAt(time)};
		Error("beatAt: % maps % -> %, not beat<->sec"
			.format(this.class, fromFrame.dimension, toFrame.dimension)).throw
	}

	// Mean output units per input unit. Bounds follow the map's extension policy.
	spanSlope { |from, to|
		(from.isNumber and: to.isNumber).not.if {
			Error("%.spanSlope: from and to must be numbers, got % and %"
				.format(this.class, from, to)).throw
		};
		(from >= to).if {
			Error("%.spanSlope: need from < to, got % and %"
				.format(this.class, from, to)).throw
		};
		^(this.at(to) - this.at(from)) / (to - from)
	}
	// Mean beats per second for a beat -> sec map; nil for near-zero output width.
	// This is the inverse of setTempo over the same span.
	spanTempo { |from, to|
		var slope;
		this.mapsDimensions(\beat, \sec).not.if {
			Error("%.spanTempo: needs a beat -> sec map, this one maps % -> %"
				.format(this.class, fromFrame.dimension, toFrame.dimension)).throw
		};
		slope = this.spanSlope(from, to);
		// Avoid unstable reciprocals near zero.
		^(slope > 1e-9).if { slope.reciprocal }
	}
	spanBpm { |from, to| ^this.spanTempo(from, to) !? (_ * 60) }

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
	// Return q-family durations. initialDur is first; w is exit/entry tempo, so
	// the final duration approaches initialDur/w. Uses ritard's quadrature.
	*ritardDurs { |initialDur = 1, numDurs = 8, w = 0.5, q = 2, oversample = 32|
		((numDurs.isNumber.not)
			or: { numDurs.asInteger != numDurs }
			or: { numDurs < 1 }).if {
				Error("AnchorMap.ritardDurs: numDurs must be a positive integer, got %"
					.format(numDurs)).throw
		};
		((initialDur.isNumber.not) or: { initialDur <= 0 }).if {
			Error("AnchorMap.ritardDurs: initialDur must be > 0, got %"
				.format(initialDur)).throw
		};
		((w.isNumber.not) or: { w <= 0 }).if {
			Error("AnchorMap.ritardDurs: w must be > 0 — it is a tempo RATIO "
				"(end / start), not a bpm; got %".format(w)).throw
		};
		q.isNumber.not.if {
			Error("AnchorMap.ritardDurs: q must be a number, got %".format(q)).throw
		};
		((oversample.isNumber.not)
			or: { oversample.asInteger != oversample }
			or: { oversample < 1 }).if {
				Error("AnchorMap.ritardDurs: oversample must be a positive integer, got %"
					.format(oversample)).throw
		};
		^(0 .. (numDurs - 1)).collect { |i|
			var acc = 0.0;
			var prev = this.prRitardV(i / numDurs, w, q).reciprocal;
			oversample.do { |j|
				var cur = this.prRitardV(
					(i + ((j + 1) / oversample)) / numDurs, w, q).reciprocal;
				acc = acc + ((prev + cur) * 0.5 / oversample);
				prev = cur
			};
			acc * initialDur
		}
	}
	initAnchor { |anXs, anYs, inF, outF, below, above|
		/*
		 collect() is the defensive COPY as much as the coercion: without it the map
		 shares storage with the caller's arrays, so a later `xs[i] = ...` would edit
		 the anchors behind the strictly-increasing check and the prInverse cache.
		*/
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
	// ---- Non-mutating transforms. Frames and extension policies are preserved.
	// Bake MapSeq or ComposedMap before applying them.

	// Keep only group-boundary anchors. `groups` is a positive integer or a
	// cyclic array of sizes. Endpoints and total extents are preserved.
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

	// Sample a monotone cubic Hermite curve with `oversample` segments per span.
	// Fritsch-Carlson tangent clamping preserves monotonicity. Original anchors
	// stay exact; `amount` blends linear (0) to curved (1).
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

	// Blend output anchors toward the line through the endpoints. amount 0 is
	// unchanged; 1 gives constant slope. For amount in [0, 1], monotonicity and
	// total output extent are preserved. Optional bounds limit the edit; bounds
	// equal to the full domain give the same exact result as an unbounded call.
	quantize { |amount = 1, from, to|
		(from.isNil and: { to.isNil }).if { ^this.prQuantizeAll(amount) };
		^this.transformSpan(from ? xs.first, to ? xs.last, { |cell|
			cell.prQuantizeAll(amount) })
	}
	prQuantizeAll { |amount = 1|
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

	// Apply a Friberg–Sundberg tempo curve. `w` is exit/entry tempo and `q`
	// positions the change. w is required unless quantize is 1, where nil fits
	// it from the map's end slopes. Endpoints stay fixed. `quantize` selects the
	// base: 0 preserves recorded rubato; 1 first makes it constant-slope.
	ritard { |w, q = 2, amount = 1, oversample = 32, quantize = 0|
		var x0 = xs.first, x1 = xs.last, y0 = ys.first, y1 = ys.last;
		var span = x1 - x0, height = y1 - y0, nSpans = xs.size - 1;
		var ratio, allXs, vs, cum, k, origYs, baseYs, base, newYs;
		this.mapsDimensions(\beat, \sec).not.if {
			Error("AnchorMap.ritard: needs a beat -> sec map, this one maps % -> %"
				.format(fromFrame.dimension, toFrame.dimension)).throw
		};
		q.isNumber.not.if {
			Error("AnchorMap.ritard: q must be a number, got %".format(q)).throw
		};
		(oversample.isNumber.not
			or: { oversample.asInteger != oversample }
			or: { oversample < 1 }).if {
				Error("AnchorMap.ritard: oversample must be a positive integer, got %"
					.format(oversample)).throw
		};
		((amount < 0) or: { amount > 1 }).if {
			"AnchorMap.ritard: amount % is outside [0, 1] — monotonicity is only "
				"guaranteed inside it".format(amount).warn
		};
		// Preserve the original anchors for the identity case.
		(amount == 0).if {
			^AnchorMap(xs, ys, fromFrame, toFrame, extendBelow, extendAbove)
		};
		((quantize.isNumber.not) or: { quantize < 0 } or: { quantize > 1 }).if {
			Error("AnchorMap.ritard: quantize must be a number in [0, 1], got %"
				.format(quantize)).throw
		};
		// A fitted w reads the trend off this map's own end slopes. Multiplying that
		// back onto an unflattened base would apply the trend twice, so it is refused
		// rather than silently doubled.
		(w.isNil and: { quantize < 1 }).if {
			Error("AnchorMap.ritard: w must be given when quantize < 1 — fitting it from "
				"this map's ends and then multiplying it back on would double the trend "
				"already in the performance").throw
		};
		ratio = w ?? { this.prFitTempoRatio };
		((ratio.isNumber.not) or: { ratio <= 0 }).if {
			Error("AnchorMap.ritard: w must be > 0 — it is a tempo RATIO (end / start), "
				"not a bpm; got %".format(w)).throw
		};
		allXs = (0 .. (nSpans * oversample)).collect { |i|
			x0 + (span * i / (nSpans * oversample))
		};
		(xs.size > 2).if { allXs = allXs ++ xs.copyRange(1, xs.size - 2) };
		allXs = allXs.sort;
		// Merge original anchors with the sampling grid without duplicates.
		allXs = allXs.select { |x, i|
			(i == 0) or: { (x - allXs[i - 1]) > (1e-12 * max(1.0, x.abs)) }
		};
		allXs[0] = x0; allXs[allXs.size - 1] = x1;
		vs = allXs.collect { |x| this.prRitardV((x - x0) / span, ratio, q) };
		origYs = allXs.collect { |x| this.prAnchorY(x) };
		// The integrand is weighted by the BASE's performed durations, so the curve
		// multiplies that base instead of replacing it. quantize 1 makes the base
		// constant-slope, which is exactly the old "integrate over input width" path.
		base = (quantize > 0).if { this.prQuantizeAll(quantize) };
		baseYs = base.isNil.if { origYs } { allXs.collect { |x| base.prAnchorY(x) } };
		// Integrate reciprocal tempo by trapezoid; normalization pins both ends.
		cum = Array(allXs.size).add(0.0);
		(allXs.size - 1).do { |i|
			cum = cum.add(cum[i] + ((baseYs[i + 1] - baseYs[i]) * 0.5
				* (vs[i].reciprocal + vs[i + 1].reciprocal)))
		};
		k = height / cum.last;
		newYs = cum.collect { |c, i|
			(origYs[i] * (1 - amount)) + ((y0 + (c * k)) * amount)
		};
		// Pin both ends bit-exactly.
		newYs[0] = y0;
		newYs[newYs.size - 1] = y1;
		^AnchorMap(allXs, newYs, fromFrame, toFrame, extendBelow, extendAbove)
	}

	// Blend with a map on the same frames, using the union of both anchor sets.
	// amount 0 is this map; 1 is `other`.
	blendWith { |other, amount = 1|
		var us, ys2;
		(fromFrame == other.fromFrame and: { toFrame == other.toFrame }).not.if {
			Error("AnchorMap.blendWith: frame mismatch — % / % vs % / %"
				.format(fromFrame, toFrame, other.fromFrame, other.toFrame)).throw
		};
		((amount < 0) or: { amount > 1 }).if {
			"AnchorMap.blendWith: amount % is outside [0, 1] — monotonicity is only "
				"guaranteed inside it".format(amount).warn
		};
		us = (xs ++ (other.tryPerform(\xs) ? []).asArray).sort;
		// drop duplicates: two maps sharing an anchor would give AnchorMap a repeat
		us = us.select { |x, i| (i == 0) or: { (x - us[i - 1]) > (1e-12 * max(1.0, x.abs)) } };
		ys2 = us.collect { |x| this.at(x).blend(other.at(x), amount) };
		^AnchorMap(us, ys2, fromFrame, toFrame, extendBelow, extendAbove)
	}

	// Smooth each span toward the overlap-weighted mean slope of a centered
	// input-axis window, defaulting to one quarter of the input extent. Endpoints
	// and total output extent stay fixed. O(n^2).
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

	// Materialize high-end \carry extrapolation as an anchor without changing the
	// map's values. Low-end growth would move the origin and is deliberately absent;
	// \error policy refuses extension.
	extendTo { |to|
		to.isNumber.not.if {
			Error("AnchorMap.extendTo: `to` must be a number, got %".format(to)).throw
		};
		(to <= xs.last).if { ^this };
		(extendAbove == \error).if {
			Error("AnchorMap.extendTo: cannot reach % — this map's high end is \\error, "
				"so it has no extrapolation to materialize (domain %)"
				.format(to, this.domain)).throw
		};
		^AnchorMap(
			xs ++ [to],
			ys ++ [ys.last + ((to - xs.last) * this.prSlope(xs.size - 2))],
			fromFrame, toFrame, extendBelow, extendAbove)
	}

	// ---- Local, non-mutating edits. Cut into cells, edit one, then reassemble.

	// Cut at strictly increasing interior boundaries; none returns the whole map
	// as one cell. Cells retain absolute coordinates. New cut anchors are exact
	// PL points. Outer policies are preserved; internal ends use \carry.
	slices { |boundaries|
		var raw = boundaries.asArray, cuts, edges, n;
		raw.any { |x| x.isNumber.not }.if {
			Error("AnchorMap.slices: boundaries must be numbers, got %"
				.format(boundaries)).throw
		};
		cuts = raw.collect(_.asFloat);
		cuts.doAdjacentPairs { |a, b|
			(b <= a).if {
				Error("AnchorMap.slices: boundaries must be strictly increasing (% then %)"
					.format(a, b)).throw
			}
		};
		cuts.do { |x|
			((x <= xs.first) or: { x >= xs.last }).if {
				Error("AnchorMap.slices: boundary % is not strictly inside the domain %"
					.format(x, this.domain)).throw
			}
		};
		edges = [xs.first] ++ cuts ++ [xs.last];
		n = edges.size - 1;
		^n.collect { |k|
			var lo = edges[k], hi = edges[k + 1], cellXs, cellYs;
			cellXs = [lo]; cellYs = [this.prAnchorY(lo)];
			xs.do { |x, i|
				((x > lo) and: { x < hi }).if {
					cellXs = cellXs.add(x); cellYs = cellYs.add(ys[i])
				}
			};
			cellXs = cellXs.add(hi); cellYs = cellYs.add(this.prAnchorY(hi));
			AnchorMap(cellXs, cellYs, fromFrame, toFrame,
				(k == 0).if { extendBelow } { \carry },
				(k == (n - 1)).if { extendAbove } { \carry })
		}
	}

	// Replace one span with func.(cell). The result must bake to an AnchorMap and
	// keep the input width. Output-width changes shift later material.
	transformSpan { |from, to, func|
		var cells, mid, edited;
		# cells, mid = this.prSpanCells(from, to, \transformSpan);
		edited = func.value(cells[mid]);
		edited.isKindOf(MonoMap).not.if {
			Error("AnchorMap.transformSpan: func must answer a MonoMap, got %"
				.format(edited.class)).throw
		};
		edited = edited.bake;
		edited.isKindOf(AnchorMap).not.if {
			Error("AnchorMap.transformSpan: func's map does not bake to an AnchorMap (got %)"
				.format(edited.class)).throw
		};
		this.prCheckSpanWidth(cells[mid], edited, \transformSpan);
		^this.prFromCells(cells.copy.put(mid, edited), \transformSpan)
	}


	// Re-anchor one span from input-unit IOIs (`durs`) and performed output-axis
	// positions (`onsets`). `to` defaults to from + durs.sum and only validates
	// the span. amount 0 is unchanged; 1 fully aligns events. Total width stays
	// fixed up to the first-onset tolerance below, so later material can move by
	// that same bounded offset.
	quantizeToRhythm { |durs, onsets, from, to, amount = 1|
		var sum, edited;
		durs.isString.if { durs = durs.beats };
		durs = durs.asArray;
		(from.isNumber.not).if {
			Error("AnchorMap.quantizeToRhythm: from must be an input-axis number, "
				"got %".format(from)).throw
		};
		(durs.isEmpty or: { durs.every { |d| d.isNumber and: { d > 0 } }.not }).if {
			Error("AnchorMap.quantizeToRhythm: durs must be a non-empty array of "
				"positive input-unit IOIs, got %".format(durs)).throw
		};
		sum = durs.sum;
		to = to ?? { from + sum };
		(to.isNumber.not).if {
			Error("AnchorMap.quantizeToRhythm: to must be an input-axis number, "
				"got %".format(to)).throw
		};
		(((to - from) - sum).abs > 1e-9).if {
			Error("AnchorMap.quantizeToRhythm: the durs span % but [%, %] is % — "
				"`to` is a check, not a rescale, so fix the count or leave `to` out"
				.format(sum, from, to, to - from)).throw
		};
		onsets.isNil.if {
			Error("AnchorMap.quantizeToRhythm: onsets is required — % durs, no "
				"onsets. This method never picks; query them first, e.g. "
				"p.onsets(%, %)".format(durs.size, from, to)).throw
		};
		onsets = onsets.asArray;
		onsets.every(_.isNumber).not.if {
			Error("AnchorMap.quantizeToRhythm: onsets must be performed positions "
				"on the output axis, got %".format(onsets)).throw
		};
		(onsets.size != durs.size).if {
			Error("AnchorMap.quantizeToRhythm: % onsets for % durs — one onset per "
				"rhythmic event. Got: %".format(onsets.size, durs.size, onsets)).throw
		};
		onsets.differentiate.drop(1).every(_ > 0).not.if {
			Error("AnchorMap.quantizeToRhythm: onsets must be strictly increasing, "
				"got %".format(onsets)).throw
		};
		// Edit one cell; transformSpan preserves everything outside it.
		edited = this.transformSpan(from, to, { |cell|
			// Reject a first onset more than half a performed duration from the start.
			var lo = cell.at(from), hi = cell.at(to);
			var tol = 0.5 * (cell.at(from + durs[0]) - lo);
			((onsets.first - lo).abs > tol).if {
				Error("AnchorMap.quantizeToRhythm: % sits at % in the current map, "
					"but the first onset is at % — off by %, more than half the "
					"first dur's performed width (%). Wrong span, or a "
					"missing/extra leading onset?"
					.format(from, lo, onsets.first, onsets.first - lo, tol)).throw
			};
			(onsets.last >= (hi - 1e-9)).if {
				Error("AnchorMap.quantizeToRhythm: the last onset (%) is at or past "
					"the span's end (% = %) — every onset must lie inside the span's "
					"performed window.".format(onsets.last, to, hi)).throw
			};
			// Close the final output span at the map's end; retain absolute coordinates.
			AnchorMap.fromSpans(durs, (onsets ++ [hi]).differentiate.drop(1),
				x0: from, y0: onsets.first,
				fromFrame: cell.fromFrame, toFrame: cell.toFrame)
		});
		^(amount == 1).if { edited } { this.blendWith(edited, amount) }
	}

	// Scale a span's output width while preserving its internal proportions.
	// preserveTotal compensates by uniformly scaling material outside the span.
	// This private factor scales duration (> 1 is slower); public scaleTempo
	// scales tempo.
	prStretchSpan { |from, to, factor, preserveTotal = false|
		var cells, mid, spanW, total, k;
		((factor.isNumber.not) or: { factor <= 0 }).if {
			Error("AnchorMap.scaleTempo: k must be > 0, got %".format(factor.reciprocal)).throw
		};
		# cells, mid = this.prSpanCells(from, to, \scaleTempo);
		spanW = cells[mid].ys.last - cells[mid].ys.first;
		cells = cells.copy.put(mid, cells[mid].prScaledY(factor));
		preserveTotal.if {
			(cells.size < 2).if {
				Error("AnchorMap.scaleTempo: preserveTotal needs material outside the "
					"span, but [%, %] covers the whole domain %"
					.format(from, to, this.domain)).throw
			};
			total = ys.last - ys.first;
			k = (total - (spanW * factor)) / (total - spanW);
			(k <= 0).if {
				Error("AnchorMap.scaleTempo: k % leaves no room — the stretched span (%) "
					"is not shorter than the whole output extent (%)"
					.format(factor.reciprocal, spanW * factor, total)).throw
			};
			cells = cells.collect { |c, i| (i == mid).if { c } { c.prScaledY(k) } };
		};
		^this.prFromCells(cells, \scaleTempo)
	}

	// Set a span's mean slope while preserving its internal proportions.
	setSlope { |slope, from, to|
		var outW;
		((slope.isNumber.not) or: { slope <= 0 }).if {
			Error("AnchorMap.setSlope: slope must be > 0, got %".format(slope)).throw
		};
		from = from ? xs.first; to = to ? xs.last;
		this.prCheckSpan(from, to, \setSlope);
		outW = this.prAnchorY(to) - this.prAnchorY(from);
		^this.prStretchSpan(from, to, slope * (to - from) / outW)
	}

	// Set mean beats per second on a beat -> sec map. Optional bounds default to
	// the whole map; internal rubato is preserved by uniform scaling.
	// m.setTempo(x, a, b).spanTempo(a, b) == x.
	setTempo { |bps, from, to|
		this.mapsDimensions(\beat, \sec).not.if {
			Error("AnchorMap.setTempo: needs a beat -> sec map, this one maps % -> %"
				.format(fromFrame.dimension, toFrame.dimension)).throw
		};
		((bps.isNumber.not) or: { bps <= 0 }).if {
			Error("AnchorMap.setTempo: bps must be > 0, got %".format(bps)).throw
		};
		^this.setSlope(bps.reciprocal, from, to)
	}
	// Same operation in bpm. setBpm is the ABSOLUTE form ("land on this value"),
	// scaleTempo the relative one ("multiply by k").
	setBpm { |bpm, from, to|
		((bpm.isNumber.not) or: { bpm <= 0 }).if {
			Error("AnchorMap.setBpm: bpm must be > 0, got %".format(bpm)).throw
		};
		^this.setTempo(bpm / 60, from, to)
	}

	// Apply ritard to a span. pinEntry preserves incoming tempo by stretching the
	// span and shifting later material; otherwise width stays fixed. High-end
	// \carry is extended automatically. toBpm requires pinEntry and replaces w.
	// `quantize` is ritard's, forwarded: 0 multiplies the performance in the span,
	// 1 flattens it first (what this did before the change).
	ritardSpan { |from, to, w, q = 2, amount = 1, pinEntry = false, toBpm, quantize = 0|
		var shaped;
		var grown = this.extendTo(to);
		(grown !== this).if {
			^grown.ritardSpan(from, to, w, q, amount, pinEntry, toBpm, quantize)
		};
		this.prCheckSpan(from, to, \ritardSpan);
		toBpm.notNil.if {
			w.notNil.if {
				Error("AnchorMap.ritardSpan: give w OR toBpm, not both (got % and %)"
					.format(w, toBpm)).throw
			};
			((toBpm.isNumber.not) or: { toBpm <= 0 }).if {
				Error("AnchorMap.ritardSpan: toBpm must be > 0, got %".format(toBpm)).throw
			};
			(pinEntry != true).if {
				Error("AnchorMap.ritardSpan: toBpm needs pinEntry: true — without it the "
					"span is rescaled to keep its width and the exit tempo is not the "
					"target").throw
			};
			(from <= xs.first).if {
				Error("AnchorMap.ritardSpan: toBpm is resolved against the tempo arriving "
					"at %, and the span starts at the domain edge — there is none"
					.format(from)).throw
			};
			// With pinEntry, w times the incoming tempo is the requested exit tempo.
			w = (toBpm / 60) * this.prSlopeBefore(from)
		};
		shaped = this.transformSpan(from, to, { |cell|
			cell.ritard(w, q, amount, quantize: quantize) });
		pinEntry.not.if { ^shaped };
		// amount 0 is identity for the entire edit, including pinEntry.
		(amount == 0).if { ^shaped };
		(from <= xs.first).if {
			"AnchorMap.ritardSpan: pinEntry needs material before the span to take its "
				"entry tempo from, but [%, %] starts at the domain edge"
				.format(from, to).warn;
			^shaped
		};
		// Slope is sec/beat, so this ratio matches the shaped entry to the incoming tempo.
		^shaped.prStretchSpan(from, to,
			this.prSlopeBefore(from) / shaped.prSlopeAfter(from))
	}

	// Concatenate maps and smooth their tempo seam over `before` and `after`.
	// `other` is treated as a shape and rebound to this map's axes; dimensions
	// must still be beat -> sec. `w` defaults to the outside-tempo ratio.
	easeTo { |other, before = 1, after = 0, q = 2, amount = 1, w|
		var joined, join, lo, hi, dx, dy;
		(other.isKindOf(MonoMap).not and: { other.respondsTo(\asMonoMap) }).if {
			other = other.asMonoMap
		};
		(other.isKindOf(AnchorMap).not and: { other.isKindOf(MonoMap) }).if {
			other = other.bake
		};
		other.isKindOf(AnchorMap).not.if {
			Error("AnchorMap.easeTo: needs a map that bakes to anchors, got %"
				.format(other.class)).throw
		};
		this.mapsDimensions(\beat, \sec).not.if {
			Error("AnchorMap.easeTo: needs a beat -> sec map, this one maps % -> %"
				.format(fromFrame.dimension, toFrame.dimension)).throw
		};
		other.mapsDimensions(\beat, \sec).not.if {
			Error("AnchorMap.easeTo: `other` must be a beat -> sec map, that one maps "
				"% -> %".format(other.fromFrame.dimension, other.toFrame.dimension)).throw
		};
		// other is a shape: rebind it onto this map's axes rather than refusing.
		(fromFrame == other.fromFrame and: { toFrame == other.toFrame }).not.if {
			other = other.withFrames(fromFrame, toFrame)
		};
		((before.isNumber.not) or: { after.isNumber.not }
			or: { before < 0 } or: { after < 0 }).if {
				Error("AnchorMap.easeTo: before and after must be >= 0, got % and %"
					.format(before, after)).throw
		};
		((before + after) <= 0).if {
			Error("AnchorMap.easeTo: the ease window has no width — give before "
				"and/or after").throw
		};
		(before >= (xs.last - xs.first)).if {
			Error("AnchorMap.easeTo: before % does not fit in this map's % beats, and "
				"the window needs material ahead of it to take its entry tempo from"
				.format(before, xs.last - xs.first)).throw
		};
		(after > (other.xs.last - other.xs.first)).if {
			Error("AnchorMap.easeTo: after % does not fit in other's % beats"
				.format(after, other.xs.last - other.xs.first)).throw
		};
		// Preserve this map's low policy and other's high policy.
		joined = MapSeq([this, other], 1, fromFrame, toFrame,
			extendBelow, other.extendAbove).bake;
		joined.isKindOf(AnchorMap).not.if {
			Error("AnchorMap.easeTo: the concatenation did not bake to anchors").throw
		};
		// bake translates to (0, 0); restore this map's origin.
		dx = xs.first - joined.xs.first;
		dy = ys.first - joined.ys.first;
		((dx != 0) or: { dy != 0 }).if {
			joined = AnchorMap(joined.xs + dx, joined.ys + dy,
				fromFrame, toFrame, extendBelow, other.extendAbove)
		};
		join = xs.last;
		lo = join - before;
		hi = join + after;
		// Fit from tempos outside the region being reshaped.
		w = w ?? { joined.prSlopeBefore(lo) / joined.prSlopeAfter(hi) };
		// Flatten the window first; otherwise the existing seam is scaled, not removed.
		^joined.ritardSpan(lo, hi, w, q, amount, true, quantize: 1)
	}

	// Multiply tempo by `k`, preserving beat positions and rubato. Optional bounds
	// ripple later material unless preserveTotal rescales the material outside.
	// Use setBpm/setTempo for an absolute target.
	scaleTempo { |k = 1, from, to, preserveTotal = false|
		((k.isNumber.not) or: { k <= 0 }).if {
			Error("AnchorMap.scaleTempo: k must be > 0, got %".format(k)).throw
		};
		(from.isNil and: { to.isNil } and: { preserveTotal.not }).if {
			^this.prScaledY(k.reciprocal)
		};
		^this.prStretchSpan(from ? xs.first, to ? xs.last, k.reciprocal, preserveTotal)
	}

	// value at a cut: bit-exact when the cut IS an anchor, the PL lerp otherwise
	prAnchorY { |x|
		var i = xs.indexOf(x);
		^i.notNil.if { ys[i] } { this.at(x) }
	}
	// pure output-axis scale about this map's own start. factor 1 answers the
	// receiver rather than round-tripping through y0 + (y - y0), which is not
	// bit-exact.
	prScaledY { |factor|
		var y0 = ys.first;
		(factor == 1).if { ^this };
		^AnchorMap(xs, ys.collect { |y| y0 + ((y - y0) * factor) },
			fromFrame, toFrame, extendBelow, extendAbove)
	}
	prCheckSpan { |from, to, caller|
		((from.isNumber.not) or: { to.isNumber.not }).if {
			Error("AnchorMap.%: from and to must be numbers, got % and %"
				.format(caller, from, to)).throw
		};
		(from >= to).if {
			Error("AnchorMap.%: need from < to, got % and %".format(caller, from, to)).throw
		};
		((from < xs.first) or: { to > xs.last }).if {
			Error("AnchorMap.%: span [%, %] is not inside the domain %"
				.format(caller, from, to, this.domain)).throw
		};
		^this
	}
	// [cells, index of the span's cell]. A span end that coincides with a domain
	// end is NOT cut: slices refuses a boundary there (it would make a
	// zero-width cell), and there is nothing to keep on that side anyway.
	prSpanCells { |from, to, caller|
		var cuts = [];
		this.prCheckSpan(from, to, caller);
		(from > xs.first).if { cuts = cuts.add(from) };
		(to < xs.last).if { cuts = cuts.add(to) };
		^[this.slices(cuts), (from > xs.first).if { 1 } { 0 }]
	}
	prCheckSpanWidth { |cell, edited, caller|
		var want = cell.xs.last - cell.xs.first;
		var got = edited.xs.last - edited.xs.first;
		((got - want).abs > 1e-9).if {
			Error("AnchorMap.%: the transform changed the span's INPUT width (% -> %); "
				"input positions are labels and must survive".format(caller, want, got)).throw
		};
		^edited
	}
	// Reassemble and validate cells, restoring the receiver's absolute origin.
	prFromCells { |someCells, caller|
		var baked = MapSeq(someCells, 1, fromFrame, toFrame, extendBelow, extendAbove).bake;
		baked.isKindOf(AnchorMap).not.if {
			Error("AnchorMap.%: the edited cells do not flatten to anchors (got %)"
				.format(caller, baked.class)).throw
		};
		^AnchorMap(baked.xs + xs.first, baked.ys + ys.first,
			fromFrame, toFrame, extendBelow, extendAbove)
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

	// Normalized Friberg–Sundberg tempo: v(0)=1, v(1)=w. q controls the timing of
	// change; q=0 uses the geometric limit w**u. Class-side for ritardDurs reuse.
	*prRitardV { |u, w, q|
		(q.abs < 1e-9).if { ^w ** u };
		^(max(1 + (((w ** q) - 1) * u), 1e-12)) ** (q.reciprocal)
	}
	prRitardV { |u, w, q| ^this.class.prRitardV(u, w, q) }
	// Fit exit/entry tempo from the cell; a single span implies ratio 1.
	prFitTempoRatio {
		var nSpans = xs.size - 1;
		(nSpans < 2).if {
			"AnchorMap.ritard: cannot fit w from a single-span cell — using 1 "
				"(constant tempo)".warn;
			^1.0
		};
		^this.prSlope(0) / this.prSlope(nSpans - 1)
	}
	// Find adjacent slopes by tolerant anchor position; outside uses the carry slope.
	prSlopeBefore { |x|
		var i = xs.detectIndex { |v| v >= (x - 1e-9) };
		^this.prSlope(max((i ? (xs.size - 1)) - 1, 0))
	}
	prSlopeAfter { |x|
		var i = xs.detectIndex { |v| v > (x + 1e-9) };
		^this.prSlope(min(max((i ? (xs.size - 1)) - 1, 0), xs.size - 2))
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

// Lazy left-to-right composition. Frames are checked at construction; call
// checkComposable for an early domain check.
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
	// Fuse affine and piecewise-linear chains exactly. All-affine chains become
	// one AffineMap; otherwise pulled-back breakpoints form one AnchorMap.
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

// Concatenate finite-domain cells for `repeats` passes. inf tiles the whole
// real line. Joins are position-continuous, though slope may jump; differing
// input/output widths intentionally accumulate drift. Cells are shapes: tags
// and origins are ignored, but dimensions must agree. MapSeq begins at (0, 0);
// use place for absolute coordinates.
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

	// ---- Musical cell builders. Cell methods return AnchorMaps; swing,
	// modulate, and groove return infinite beat-axis MapSeqs.

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

	// Coerce supported legacy cells through asMonoMap.
	initMapSeq { |someCells, someRepeats, inF, outF, below, above|
		var inDims, outDims, inD, outD;
		cells = someCells.asArray.collect { |c|
			(c.isKindOf(MonoMap) or: { c.respondsTo(\asMonoMap).not }).if({ c }, { c.asMonoMap })
		};
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

	// ---- Non-mutating cell editing. Reconstruction revalidates the new cells.
	replaceCell { |i, cell|
		((i.isNumber.not) or: { i.asInteger != i }
			or: { i < 0 } or: { i >= cells.size }).if {
				Error("MapSeq.replaceCell: index % is out of range 0..%"
					.format(i, cells.size - 1)).throw
		};
		^MapSeq(cells.copy.put(i.asInteger, cell), repeats,
			fromFrame, toFrame, extendBelow, extendAbove)
	}
	// func.(cell, index) -> cell
	collectCells { |func|
		^MapSeq(cells.collect { |c, i| func.value(c, i) }, repeats,
			fromFrame, toFrame, extendBelow, extendAbove)
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

// Function-backed map. The caller supplies both directions and guarantees
// monotonicity. The domain declares the trusted interval: \carry trusts calls
// outside it; \error refuses them. FunctionMaps cannot fuse; sample explicitly
// approximates one as anchors.
FunctionMap : MonoMap {
	var <func, <invFunc, prDomain, prRange;
	*new { |func, invFunc, domain, fromFrame, toFrame, extendBelow, extendAbove|
		^super.new.initFunctionMap(func, invFunc, domain, fromFrame, toFrame,
			extendBelow, extendAbove)
	}
	// design-doc spelling; same thing
	*fromFunction { |func, invFunc, domain, fromFrame, toFrame, extendBelow, extendAbove|
		^this.new(func, invFunc, domain, fromFrame, toFrame, extendBelow, extendAbove)
	}
	initFunctionMap { |f, fInv, aDomain, inF, outF, below, above|
		func = f; invFunc = fInv;
		(func.isNil or: { invFunc.isNil }).if {
			Error("FunctionMap: needs both directions — "
				"a map with no inverse is not a MonoMap").throw
		};
		aDomain.notNil.if {
			prDomain = aDomain.asArray.collect(_.asFloat);
			(prDomain.size != 2).if {
				Error("FunctionMap: domain must be [lo, hi], got %".format(aDomain)).throw
			};
			(prDomain[1] < prDomain[0]).if {
				Error("FunctionMap: domain % is empty".format(prDomain)).throw
			};
		};
		fromFrame = this.prAsFrame(inF);
		toFrame = this.prAsFrame(outF);
		this.prSetPolicy(below, above);
	}
	domain { ^prDomain }
	// cached: each end costs a call into the wrapped function
	range { ^prDomain !? { prRange ?? { prRange = [func.value(prDomain[0]), func.value(prDomain[1])] } } }

	at { |x|
		prDomain.notNil.if {
			((x < prDomain[0]) and: { extendBelow == \error }).if {
				this.prExtensionError(x, \below)
			};
			((x > prDomain[1]) and: { extendAbove == \error }).if {
				this.prExtensionError(x, \above)
			};
		};
		^func.value(x)
	}
	// the guard is on the OUTPUT axis here; the map is increasing, so below
	// stays below (same convention as AnchorMap.inverse)
	invAt { |y|
		var r = this.range;
		r.notNil.if {
			((y < r[0]) and: { extendBelow == \error }).if { this.prRangeError(y, \below) };
			((y > r[1]) and: { extendAbove == \error }).if { this.prRangeError(y, \above) };
		};
		^invFunc.value(y)
	}
	inverse {
		^FunctionMap(invFunc, func, this.range, toFrame, fromFrame,
			extendBelow, extendAbove)
	}
	withFrames { |fromFrame, toFrame|
		^FunctionMap(func, invFunc, prDomain, fromFrame, toFrame,
			extendBelow, extendAbove)
	}

	// Approximate the function with n uniform segments. Unlike bake, this is not exact.
	sample { |n = 128|
		var lo, hi, xs;
		prDomain.isNil.if {
			Error("FunctionMap.sample: needs a finite domain to sample over").throw
		};
		(n.isNumber.not or: { n.asInteger != n } or: { n < 1 }).if {
			Error("FunctionMap.sample: n must be a positive integer, got %".format(n)).throw
		};
		# lo, hi = prDomain;
		(hi <= lo).if {
			Error("FunctionMap.sample: domain % has no width".format(prDomain)).throw
		};
		xs = (n + 1).collect { |i| lo + ((hi - lo) * i / n) };
		xs[n] = hi;   // no rounding drift on the far end
		^AnchorMap(xs, xs.collect { |x| func.value(x) },
			fromFrame, toFrame, extendBelow, extendAbove)
	}

	prRangeError { |y, end|
		Error("%: % outside range % (% end is \\error)"
			.format(this.class, y, this.range, end)).throw
	}
	printOn { |stream|
		stream << "FunctionMap(" << (prDomain ?? { "total" }) << ")"
	}
}

// Legacy TempoMap bridge. The result is a snapshot with invertible extension.
+ TempoMap {
	// Snapshot beats/durs. Defaults to \carry because clamping is not invertible.
	asMonoMap { |fromFrame, toFrame, extendBelow, extendAbove|
		^AnchorMap.fromSpans(beats, durs,
			fromFrame: fromFrame ? \beat, toFrame: toFrame ? \sec,
			extendBelow: extendBelow, extendAbove: extendAbove)
	}
}

// Exact linear-anchor snapshot of a MIDIItemTempoMap.
+ MIDIItemTempoMap {
	// Snapshot beat -> sec. \relative starts seconds at the first anchor;
	// \absolute adds t0. Their frames intentionally differ. Seconds frames are
	// shared per take; beat frames are per map. Curved maps require allowCurved,
	// which explicitly discards the curve and keeps its linear anchors.
	asMonoMap { |fromFrame, toFrame, origin = \relative, allowCurved = false,
		extendBelow, extendAbove|
		var ys = times.asArray;
		#[\relative, \absolute].includes(origin).not.if {
			Error("MIDIItemTempoMap.asMonoMap: origin must be \\relative or "
				"\\absolute, got %".format(origin)).throw
		};
		(curved and: { allowCurved.not }).if {
			Error("MIDIItemTempoMap.asMonoMap: this map is curved (curveAmount %) and "
				"the snapshot would keep only its linear anchors. Pass allowCurved: true "
				"to drop the curve deliberately.".format(curveAmount)).throw
		};
		(origin == \absolute).if { ys = ys + t0 };
		^AnchorMap.fromAnchors(
			[0] ++ beats.asArray.integrate, ys,
			fromFrame: fromFrame ?? { MapFrame.forSource(this, \beat) },
			toFrame: toFrame ?? { MapFrame.forSource(midiEvents ? this, \sec, origin) },
			extendBelow: extendBelow, extendAbove: extendAbove)
	}
}

// Live FunctionMap bridge for EventList's bidirectional clock.
+ EventList {
	// Live beat -> sec map: later EventList edits remain visible. tempoEnv is
	// captured once for memoization; false ignores tempo-track events. The lower
	// end is \error because EventList clamps below beat 0 and is not invertible
	// there. Frames are distinct per list, so maps from different lists require
	// an explicit rebase affine before composition.
	asMonoMap { |fromFrame, toFrame, useTempoTrack = true, extendBelow, extendAbove|
		var tEnv = useTempoTrack.if { this.tempoEnv };
		^FunctionMap(
			{ |beat| this.beatToWall(beat, tEnv) },
			{ |sec| this.wallToBeat(sec, tEnv) },
			[0, this.prMonoMapExtent(tEnv)],
			fromFrame ?? { MapFrame.forSource(this, \beat) },
			toFrame ?? { MapFrame.forSource(this, \sec) },
			extendBelow ? \error,
			extendAbove)
	}
	// Beat extent this list vouches for: its last event, or the end of the
	// \tempoTrack automation when that runs past it.
	prMonoMapExtent { |tEnv|
		var hi = 0;
		events.do { |e| hi = max(hi, e[\when] ? 0) };
		tEnv !? { hi = max(hi, tEnv.times.sum) };
		^hi
	}
}

// Reverse bridge for legacy consumers that require AnchorTempoMap.
+ MonoMap {
	// Bake exact finite anchors into a new AnchorTempoMap. Symbolic or infinite
	// maps are refused rather than sampled silently. rebase shifts the first
	// seconds anchor to zero for an EventList clock. Leave it false for warpTo,
	// which needs the take-absolute first timestamp as t0.
	asAnchorTempoMap { |rebase = false|
		var baked = this.bake, times, beats;
		baked.isKindOf(AnchorMap).not.if {
			baked.isKindOf(AffineMap).if {
				Error(
					"cant make AnchorMap from AffineMap - Slice a finite region first, "
					"e.g. AnchorMap([lo, hi], [map.at(lo), map.at(hi)], map.fromFrame, map.toFrame)."
				).throw
			};
			Error("MonoMap.asAnchorTempoMap: % stayed symbolic under bake (a FunctionMap "
				"link cannot fuse, and a MapSeq with infinite repeats has no finite anchor "
				"table). Freeze explicitly with .sample(n), or give MapSeq finite repeats "
				.format(baked.class)).throw
		};
		// Orientation comes from the frame DIMENSIONS, never from a guess about
		// which array "looks like" seconds. \any (an unbound shape) is refused
		// along with beat->beat grooves: binding real axes is withFrames' job.
		baked.mapsDimensions(\beat, \sec).if { beats = baked.xs; times = baked.ys } {
			baked.mapsDimensions(\sec, \beat).if { times = baked.xs; beats = baked.ys } {
				Error("MonoMap.asAnchorTempoMap: an AnchorTempoMap is a beat<->sec map, but "
					"this one maps % -> %. Bind the real axes with withFrames(fromFrame, "
					"toFrame)"
					.format(baked.fromFrame.dimension, baked.toFrame.dimension)).throw
			}
		};
		rebase.if { times = times - times.first };
		^AnchorTempoMap(times, beats)
	}
}
