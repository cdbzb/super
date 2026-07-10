// Monotone time-map algebra on Env: composition, inversion, linear baking.
//
// An Env whose levels are nondecreasing is a map from one time axis to another
// (beat -> wall, performed -> ideal, ...). These operators treat Env as such a
// map. Canonical representation is piecewise-linear, matching MIDIItemTempoMap
// (env / invEnv / .curve outputs are all built with \lin curves):
//
//   - compose / invert are EXACT on \lin input — no sampling anywhere.
//   - any other shape is baked to \lin first (`oversample` points per curved
//     span, same convention as MIDIItemTempoMap.curve).
//
// Domain semantics follow Env.at: values outside the outer env's domain clamp
// to its end levels. Slope-extrapolation past the domain (as in
// MIDIItemTempoMap.prAtExtrapolated) remains the map class's concern, not Env's.

+ Env {

	// every segment \lin / \linear / 0 -> compose/invert need no baking
	isLinearShaped {
		^curves.asArray.every { |c|
			(c === \lin) or: { c === \linear } or: { c == 0 }
		}
	}

	// nondecreasing at breakpoints. Every standard shape moves monotonically
	// between its endpoints, so the breakpoint check covers segment interiors.
	isMonotone {
		var lv = levels;
		(lv.size - 1).do { |i|
			(lv[i + 1] < lv[i]).if { ^false }
		};
		^true
	}

	// Resample every non-\lin segment to `oversample` linear pieces (via .at,
	// so any shape works); \lin segments and zero-length jumps pass through
	// untouched. Exact at all original breakpoints.
	bakeLinear { |oversample = 32|
		var timesAbs, cvs, pts, lvls;
		this.isLinearShaped.if { ^this.copy };
		timesAbs = [0] ++ times.integrate;
		cvs = curves.asArray;
		pts = List[0.0];
		lvls = List[levels[0]];
		times.size.do { |i|
			var t0 = timesAbs[i], t1 = timesAbs[i + 1], dt = t1 - t0;
			var c = cvs.wrapAt(i);
			var isLin = (c === \lin) or: { c === \linear } or: { c == 0 };
			((c === \step) or: { c === \hold }).if {
				"Env.bakeLinear: segment % is %; step/hold shapes are not maps — baking will ramp the jump".format(i, c).warn
			};
			(isLin.not and: { dt > 0 }).if {
				(oversample - 1).do { |j|
					var t = t0 + ((j + 1) / oversample * dt);
					pts.add(t);
					lvls.add(this.at(t));
				}
			};
			pts.add(t1);
			lvls.add(levels[i + 1]);
		};
		^Env(lvls.asArray, pts.asArray.differentiate.drop(1))
	}

	// Monotone-map inverse: swap the time and level axes (same construction as
	// MIDIItemTempoMap's invEnv = Env(times, beats)). Requires nondecreasing
	// levels; a flat segment inverts to a zero-length jump. Non-\lin input is
	// baked first, so the result is always \lin.
	invert { |oversample = 32|
		var e = this.isLinearShaped.if { this } { this.bakeLinear(oversample) };
		e.isMonotone.not.if {
			"Env.invert: levels are not nondecreasing — not invertible as a map".warn;
			^nil
		};
		^Env([0] ++ e.times.integrate, e.levels.differentiate.drop(1))
	}

	// Time-domain composition: result.at(t) == this.at(inner.at(t)) for all t
	// (exact when both are \lin; curved input is baked first). Breakpoints of
	// the result are inner's breakpoints plus the preimages of this's
	// breakpoints under each inner segment — piecewise-linear is closed under
	// composition, so nothing is approximated beyond the initial bake.
	// inner need not be monotone: preimages are taken per segment.
	compose { |inner, oversample = 32|
		var f, g, fCuts, gTimesAbs, gLevels, pts, lastT, lastV, outT, outL;
		f = this.isLinearShaped.if { this } { this.bakeLinear(oversample) };
		g = inner.isLinearShaped.if { inner } { inner.bakeLinear(oversample) };
		fCuts = [0] ++ f.times.integrate;   // f's breakpoints = cut values in g's level domain
		gTimesAbs = [0] ++ g.times.integrate;
		gLevels = g.levels;
		// walk g's segments in order, emitting (t, gValue) pairs: each segment
		// start, then the preimage of every f-cut the segment crosses, in
		// travel direction. Breakpoint levels come from gLevels (not g.at), so
		// zero-length jumps in g keep both sides.
		pts = List.new;
		g.times.size.do { |i|
			var t0 = gTimesAbs[i], t1 = gTimesAbs[i + 1], dt = t1 - t0;
			var v0 = gLevels[i], v1 = gLevels[i + 1], dv = v1 - v0;
			var lo = min(v0, v1), hi = max(v0, v1), crossed;
			pts.add([t0, v0]);
			((dt > 0) and: { dv != 0 }).if {
				crossed = fCuts.select { |u| (u > lo) and: { u < hi } };
				(dv < 0).if { crossed = crossed.reverse };
				crossed.do { |u|
					pts.add([t0 + ((u - v0) / dv * dt), u])
				}
			}
		};
		pts.add([gTimesAbs.last, gLevels.last]);
		// drop float-coincident duplicates (a preimage landing on an existing
		// breakpoint); genuine jumps survive — same t, different value
		outT = List.new;
		outL = List.new;
		lastT = nil;
		pts.do { |pair|
			var t = pair[0], v = f.at(pair[1]);
			((lastT.isNil) or: { (t - lastT) > 1e-12 } or: { (v - lastV).abs > 1e-12 }).if {
				outT.add(t);
				outL.add(v);
				lastT = t;
				lastV = v;
			}
		};
		^Env(outL.asArray, outT.asArray.differentiate.drop(1))
	}

	// f <> g — same spelling as AbstractFunction composition: (f <> g).at(t) == f.at(g.at(t))
	<> { |inner| ^this.compose(inner) }
	o { |inner| ^this.compose(inner) }
}
