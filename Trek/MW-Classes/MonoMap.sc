// TempoMap V2 core (see tempomap-v2-design.md). A MonoMap is a strictly
// increasing map between two named axes, with an inverse. Everything the old
// map zoo did — TempoMap, PlacedTempoMap, TempoWarp, Groove — is one of these
// plus combinators. This file is the core: frames, per-end extension,
// compose / inverse / place, generic span mapping, the piecewise-linear
// implementation with exact fusion, MapSeq tiling, the anchor transforms, the
// function-backed escape hatch, and the bridges from the old classes.
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
	classvar prSourceFrames;
	var <dimension, <tag;
	*new { |dimension = \any, tag|
		^super.newCopyArgs(dimension.asSymbol, (tag ?? { this.prNextTag }).asSymbol)
	}
	// auto-minted frames are unique: nothing composes with them by accident
	*mint { |dimension = \any| ^this.new(dimension) }
	*prNextTag { ^("f" ++ UniqueID.next).asSymbol }

	// A frame minted once per SOURCE OBJECT and cached, so that two maps derived
	// from the same thing land on the SAME axis and therefore compose. This is
	// how the bridges mint "producer" frames: a take's wall clock is one axis no
	// matter how many tempo maps read it, while each map's beat reading is its
	// own axis. `slot` separates several axes of the SAME dimension off one
	// source (e.g. a take's relative and absolute seconds); it defaults to the
	// dimension, so one source's beat and sec axes never collide.
	// The cache holds its keys strongly — a source object stays alive as long as
	// its frames are registered; clearSourceFrames drops the lot.
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
	// Non-minting lookup: the frame ALREADY registered for (source, slot), or nil.
	// forSource mints on a miss and retains the source strongly, so asking a mere
	// question through it — "is this map's seconds axis that take's relative
	// axis?" (the warpTo frame check) — would pollute the registry and pin an
	// object alive for every comparison. `slot` defaults the way forSource's does.
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

	/*
	 f ++ g : concatenation, NOT composition — g's shape is laid after f's,
	 starting where f ended on both axes. Sugar for the finite two-cell MapSeq;
	 both operands must have finite domains (MapSeq validates). The result
	 keeps THIS map's frames (g is a shape; its frames are ignored). `other`
	 may be an old-world map — MapSeq coerces cells through asMonoMap.
	*/
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

	// Mean slope over [from, to] — output units per input unit.
	// Defined here rather than on AnchorMap so a MapSeq or a ComposedMap answers
	// it too; `at` applies whatever extension policy the map carries, so a span
	// reaching outside the domain follows the same \carry / \error rule as any
	// other lookup rather than inventing a third behaviour.
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
	// beat -> sec only: the span's mean tempo in beats per second — exactly the
	// quantity setSpanTempo sets, so `m.setSpanTempo(a, b, x).spanTempo(a, b)` is
	// x. Guarded on frame DIMENSIONS like timeAt/beatAt: asking a groove
	// (beat->beat) for a tempo is a units error, not a shape error. nil when the
	// span has no output width (a clamped region), where no tempo is defined.
	spanTempo { |from, to|
		var slope;
		this.mapsDimensions(\beat, \sec).not.if {
			Error("%.spanTempo: needs a beat -> sec map, this one maps % -> %"
				.format(this.class, fromFrame.dimension, toFrame.dimension)).throw
		};
		slope = this.spanSlope(from, to);
		// 1e-9 here is a near-zero guard, not a positivity test: isStrictlyPositive
		// would let a 1e-12 slope through and return a 1e12 tempo.
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

	// Replace interior timing with the Friberg–Sundberg q family. w is exit/entry
	// tempo (nil fits the existing ends); q controls where the change occurs.
	// Endpoints and total width remain fixed. ritardSpan(pinEntry: true) instead
	// preserves entry continuity by allowing the width to grow.
	ritard { |w, q = 2, amount = 1, oversample = 32|
		var x0 = xs.first, x1 = xs.last, y0 = ys.first, y1 = ys.last;
		var span = x1 - x0, height = y1 - y0, nSpans = xs.size - 1;
		var ratio, allXs, vs, cum, k, origYs, newYs;
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
		// Integrate reciprocal tempo by trapezoid; normalization pins both ends.
		cum = Array(allXs.size).add(0.0);
		(allXs.size - 1).do { |i|
			cum = cum.add(cum[i] + ((allXs[i + 1] - allXs[i]) * 0.5
				* (vs[i].reciprocal + vs[i + 1].reciprocal)))
		};
		k = height / cum.last;
		origYs = allXs.collect { |x| this.prAnchorY(x) };
		newYs = cum.collect { |c, i|
			(origYs[i] * (1 - amount)) + ((y0 + (c * k)) * amount)
		};
		// Pin both ends bit-exactly.
		newYs[0] = y0;
		newYs[newYs.size - 1] = y1;
		^AnchorMap(allXs, newYs, fromFrame, toFrame, extendBelow, extendAbove)
	}

	// Blend toward ANOTHER map on the same axes: amount 0 is this map (bit-exact),
	// 1 is `other`, in between a convex blend and so strictly monotone, same argument
	// as quantize. Sampled on the UNION of both breakpoint sets, because the maps
	// generally differ in where their anchors sit — retimeSpan's output is this map
	// with one cell's anchors replaced, so the union keeps every corner of both. Where
	// the two agree (outside an edited span) the blend is the identity by
	// construction, at every amount. Frames must match: the whole point is that both
	// describe the same axis, and a mismatch means one of them was minted separately.
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

	// ---- Local editing (quantize-tempomap-project.md §12b A). A local edit is
	// an UNBAKE: `bake` already flattens a MapSeq into an AnchorMap exactly, so
	// the only missing move is its inverse — cut an AnchorMap into cells, edit
	// one, reconcatenate. Every transform above is then local for free
	// (`map.transformSpan(16, 24, _.quantize(1))`) with no new map class. Like
	// the transforms, these return NEW maps, never mutate, and carry the frames
	// and the per-end extension policy over unchanged.

	// Cut the domain at `boundaries` (a number, or an array of them: strictly
	// increasing and strictly inside the open interval (xs.first, xs.last)) and
	// answer the cells. No boundaries answers one cell, the whole map.
	//
	// Cells are in ABSOLUTE coordinates — cell i starts where cell i-1 ended on
	// both axes — which is what MapSeq wants: it reads a cell's domain[0] (and
	// its value there) as that cell's local origin, so
	// `MapSeq(map.slices(bars), 1, map.fromFrame, map.toFrame)` is the map
	// again, up to the translation to (0, 0) that a MapSeq always imposes
	// (transformSpan puts the origin back).
	//
	// A boundary that is not already an anchor synthesizes one via at(x). That
	// is EXACT, not a resampling: the map is piecewise linear, so the new anchor
	// lies on the segment it splits. A boundary that IS an anchor cuts there
	// without duplicating it.
	//
	// Extension: the two outer ends keep the receiver's policy, every interior
	// cut end is \carry. A cut is not a domain edge — an \error there would be a
	// map that refuses to be put back together.
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

	// Apply `func` to ONE span and put the result back. Slices at [from, to]
	// (no cut where a boundary already IS a domain end), hands the middle cell —
	// an AnchorMap in the receiver's absolute input coordinates — to func,
	// reconcatenates, and translates the whole thing back so the first anchor
	// sits exactly where it did. func may answer any MonoMap that bakes to an
	// AnchorMap, so the shape can be authored from scratch, not only derived.
	//
	// The result's INPUT width may not change: on a beat->sec map the input axis
	// carries beat NUMBERS, and moving them would relabel every later event.
	// The OUTPUT width may change freely — everything after the span then shifts
	// by the delta, which IS the wanted ripple ("bar 5 dragged" -> the take gets
	// shorter and the following bars keep their shape, translated).
	// Out-of-domain edits require explicit extendTo; ritardSpan extends its high end.
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

	// Scale one span's output width by `factor`, keeping its internal shape: a
	// pure y-scale of the cell about its own start, so anchors inside the span
	// keep their relative output proportions. factor > 1 makes the span take
	// longer (slower, on a beat->sec map).
	//
	// preserveTotal pins the map's TOTAL output extent by rescaling everything
	// OUTSIDE the span by one common factor. Widths stay positive under a
	// positive scale, so monotonicity survives — but the compensating factor
	// itself must stay positive, i.e. the stretched span must still fit inside
	// the original total. It is refused rather than fudged, and so is a span
	// that covers the whole domain (nothing left to compensate with).
	stretchSpan { |from, to, factor, preserveTotal = false|
		var cells, mid, spanW, total, k;
		((factor.isNumber.not) or: { factor <= 0 }).if {
			Error("AnchorMap.stretchSpan: factor must be > 0, got %".format(factor)).throw
		};
		# cells, mid = this.prSpanCells(from, to, \stretchSpan);
		spanW = cells[mid].ys.last - cells[mid].ys.first;
		cells = cells.copy.put(mid, cells[mid].prScaledY(factor));
		preserveTotal.if {
			(cells.size < 2).if {
				Error("AnchorMap.stretchSpan: preserveTotal needs material outside the "
					"span, but [%, %] covers the whole domain %"
					.format(from, to, this.domain)).throw
			};
			total = ys.last - ys.first;
			k = (total - (spanW * factor)) / (total - spanW);
			(k <= 0).if {
				Error("AnchorMap.stretchSpan: factor % leaves no room — the stretched "
					"span (%) is not shorter than the whole output extent (%)"
					.format(factor, spanW * factor, total)).throw
			};
			cells = cells.collect { |c, i| (i == mid).if { c } { c.prScaledY(k) } };
		};
		^this.prFromCells(cells, \stretchSpan)
	}

	// Set the span's MEAN slope (output units per input unit) exactly while
	// preserving its internal shape — the stretchSpan factor that lands the
	// span's output width on slope * input width.
	setSpanSlope { |from, to, slope|
		var outW;
		((slope.isNumber.not) or: { slope <= 0 }).if {
			Error("AnchorMap.setSpanSlope: slope must be > 0, got %".format(slope)).throw
		};
		this.prCheckSpan(from, to, \setSpanSlope);
		outW = this.prAnchorY(to) - this.prAnchorY(from);
		^this.stretchSpan(from, to, slope * (to - from) / outW)
	}

	// beat -> sec only: bps is beats per second, so the target slope is 1/bps
	// seconds per beat. Guarded on the frame DIMENSIONS rather than duck-typing,
	// like timeAt/beatAt — asking a groove (beat->beat) for a tempo is a units
	// error, not a shape error.
	setSpanTempo { |from, to, bps|
		this.mapsDimensions(\beat, \sec).not.if {
			Error("AnchorMap.setSpanTempo: needs a beat -> sec map, this one maps % -> %"
				.format(fromFrame.dimension, toFrame.dimension)).throw
		};
		((bps.isNumber.not) or: { bps <= 0 }).if {
			Error("AnchorMap.setSpanTempo: bps must be > 0, got %".format(bps)).throw
		};
		^this.setSpanSlope(from, to, bps.reciprocal)
	}

	// the point of the whole exercise: a whole-map transform, applied to a span
	quantizeSpan { |from, to, amount = 1|
		^this.transformSpan(from, to, _.quantize(amount))
	}

	// Apply ritard to a span. pinEntry preserves incoming tempo by stretching the
	// span and shifting later material; otherwise width stays fixed. High-end
	// \carry is extended automatically. toBpm requires pinEntry and replaces w.
	ritardSpan { |from, to, w, q = 2, amount = 1, pinEntry = false, toBpm|
		var shaped;
		var grown = this.extendTo(to);
		(grown !== this).if {
			^grown.ritardSpan(from, to, w, q, amount, pinEntry, toBpm)
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
		shaped = this.transformSpan(from, to, { |cell| cell.ritard(w, q, amount) });
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
		^shaped.stretchSpan(from, to,
			this.prSlopeBefore(from) / shaped.prSlopeAfter(from))
	}

	// Concatenate maps and smooth their tempo seam with one pinEntry ritardSpan.
	// before/after define the window; w defaults to the fitted outside-tempo ratio.
	easeTo { |other, before = 1, after = 0, q = 2, amount = 1, w|
		var joined, join, lo, hi, dx, dy;
		other.isKindOf(AnchorMap).not.if {
			Error("AnchorMap.easeTo: needs another AnchorMap, got %"
				.format(other.class)).throw
		};
		(fromFrame == other.fromFrame and: { toFrame == other.toFrame }).not.if {
			Error("AnchorMap.easeTo: frame mismatch — % / % vs % / %"
				.format(fromFrame, toFrame, other.fromFrame, other.toFrame)).throw
		};
		this.mapsDimensions(\beat, \sec).not.if {
			Error("AnchorMap.easeTo: needs a beat -> sec map, this one maps % -> %"
				.format(fromFrame.dimension, toFrame.dimension)).throw
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
		// Fit from tempos outside the region being replaced.
		w = w ?? { joined.prSlopeBefore(lo) / joined.prSlopeAfter(hi) };
		^joined.ritardSpan(lo, hi, w, q, amount, true)
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
	// Reassemble edited cells. A MapSeq of them IS the map again, and bake
	// flattens it back to anchors — but a MapSeq starts at 0 on both axes, so
	// the receiver's origin is added back here. Everything is revalidated on the
	// way through the two constructors, so an edit that broke monotonicity
	// errors here instead of yielding a bad map.
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

	/*
	 Cells are coerced through asMonoMap, so every old-world map (TempoMap,
	 MIDIItemTempoMap, an EventList's clock) is a cell without the caller
	 spelling the bridge out: MapSeq([aTempoMap, anotherMap]) and
	 `aMap ++ aTempoMap` both work. Anything with no bridge still raises the
	 same "cells must be MonoMaps" error, naming ITS class rather than a
	 doesNotUnderstand from inside the width arithmetic.
	*/
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

	// ---- cell editing (quantize-tempomap-project.md §12b A). Non-mutating, so
	// a bar list is directly editable: the new cell array goes back through the
	// constructor, which revalidates widths, dimensions and repeats. Everything
	// else — repeats, frames, per-end extension — is kept, since replacing a
	// cell reinterprets the same two axes, exactly like AnchorMap's transforms.
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

// The analytic escape hatch (design doc, "Constructors": fromFunction), made
// real for step 5d. The caller supplies BOTH directions and guarantees
// monotonicity — nothing here can check it. Used to wrap a tempo source that
// already answers both directions (EventList) instead of merging it into the
// core.
//
// Extension policy reads differently here than on the PL maps: \carry means
// "the wrapped function is trusted outside the domain" (it usually is — an
// analytic map is defined everywhere, and EventList holds its final tempo past
// the last event), \error refuses. So `domain` is a DECLARATION of the interval
// the caller vouches for, not a table bound. It is the only way to fence off a
// region where the wrapped function is NOT invertible — which is exactly why
// EventList's map declares \error below beat 0.
//
// This map cannot fuse: `bake` returns it unchanged, and any chain containing
// one stays symbolic, paying the wrapped function on every lookup. `sample` is
// the explicit, approximate freeze.
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

	// Freeze to an AnchorMap by sampling n even steps across the domain.
	// APPROXIMATE by construction — exact only where the wrapped map is
	// piecewise linear with its breakpoints on the sample grid. Deliberately NOT
	// called `bake`: bake is exact by contract, and a function map has no exact
	// finite form. Frames and extension policy carry over, so the result drops
	// into any chain the original fitted.
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

// Step 5c. A MIDIItemTempoMap is already an anchor map wearing a different
// constructor: prBuildLinear builds env/invEnv from exactly `times` and
// `beats`, so the snapshot below is EXACT, not a resampling. Its declared
// extrapolation is already \carry, so unlike TempoMap there is no clamp to
// argue with.
+ MIDIItemTempoMap {
	// beat -> sec, snapshotted: later mutation of this map (scaleBeats, trim,
	// curve) does not leak into the result.
	//
	// origin: \relative (default) matches `timeAt` — seconds from the first
	//   anchor. \absolute adds t0, matching EventList.timeAtBeat's
	//   `tm.timeAt(beat) + tm.t0`. These are DIFFERENT axes and get different
	//   frames on purpose: composing a relative map with an absolute one is the
	//   t0 bug the frame system exists to catch.
	//
	// Frames: the \sec frame is keyed on the TAKE (the midiEvents array), so two
	// maps read off one recording — different choiceFunc, different beat
	// spellings — share a single wall axis and compose. The \beat frame is keyed
	// on THIS map, since a different choiceFunc is a different reading of the
	// beats; repeated asMonoMap calls on one map still agree. Anchor-built maps
	// (fromAnchors, no MIDI source) have no take and key both on themselves.
	//
	// Curved maps are refused rather than silently flattened (design doc: curved
	// snapshot deferred). The linear anchors survive `curve` untouched, so
	// allowCurved: true takes them and drops the curve, explicitly.
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

// Step 5d. EventList's composed clock (recorded tempoMap x \tempoTrack
// automation) answers both directions already, so it enters V2 by being
// WRAPPED, not merged: the goal was "any tempo source answers the protocol",
// not "one engine".
+ EventList {
	// beat -> sec, LIVE: the returned map reads this list, so later edits to
	// events / tempoMap / beatDur show through. That is deliberate — an
	// EventList is a live object and a silent stale snapshot would be worse —
	// and it is the one place the bridges differ, since TempoMap.asMonoMap and
	// MIDIItemTempoMap.asMonoMap both snapshot. Call `.sample(n)` on the result
	// to freeze it.
	//
	// The tempoEnv is captured ONCE, here: beatToWall/wallToBeat take it as an
	// argument and memoize against its identity, so rebuilding it per lookup
	// would thrash that cache. useTempoTrack: false captures nil instead, which
	// is the base-tempo-only map (a materially different map — nil there means
	// "ignore \tempoTrack events", not "no tempo").
	//
	// Extension: \error below, because beatToWall CLAMPS at beat 0 (returns 0
	// for any beat <= 0) and so does wallToBeat below 0 s. A clamped region is
	// not invertible and the core does not carry one silently — a pickup before
	// beat 0 now raises instead of quietly reading 0. Above the last event the
	// wrapped function holds the final multiplier, which is honest \carry, so
	// the upper bound only shapes `range` and checkComposable.
	//
	// Frames are minted per list, so composing two lists' maps is a hard error
	// until an explicit rebase affine is inserted between them — the wall frames
	// really are offset by their tempoMaps' t0 (see prBeatFromSource).
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

// §12 seam — the REVERSE bridge. Steps 5a-5d carry the old world INTO V2; this
// carries a core map back OUT, once, at an explicit boundary, so the old
// consumers (warpTo's env walk, EventList's beatToWall integral) keep running on
// the object they already understand and never learn what a MonoMap is.
+ MonoMap {
	// This map's anchors as a concrete AnchorTempoMap.
	//
	// `.bake` first, always: the old engines look the map up per event and have
	// no way to say "flatten yourself", so the exact PL fusion happens HERE,
	// where it is still exact, rather than being paid per lookup forever. A map
	// that cannot bake to finite anchors is refused with the way out named —
	// guessing (sampling silently) would hand the old world an approximation it
	// could never tell apart from a recording.
	//
	// Two placements, because the two consumers mean different things by the
	// seconds axis, and AnchorTempoMap's t0 is exactly that difference:
	//   rebase: false — times pass through, so t0 == the first anchor's sec
	//     value. That is warpTo's contract: t0 is the ABSOLUTE timestamp at which
	//     the take's first anchor was played, and warpTo maps around it
	//     (`timestamp - origin` ... `+ origin`). Take-absolute placement.
	//   rebase: true — times shift so the first anchor sits at 0 s, hence t0 == 0.
	//     That is a list clock: an EventList's tempoMap is a SHAPE read from beat
	//     0 (prBaseWallAt/baseWallDelta call timeAt and never add t0), so a map
	//     that happens to start 40 s into a take must not push the whole list 40
	//     s late.
	// Non-mutating: the receiver is untouched and the result shares no state with it.
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
