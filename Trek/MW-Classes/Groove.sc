// A Groove is a monotone beat->beat reparametrization: it displaces onsets while
// leaving the pulse alone. Swing is the square-wave case; \sine and \tri give
// breathing/rubato feels. Both sides are beats in the SAME frame — an endomorphism,
// not an arrow between frames — so it deliberately does NOT answer timeAt/beatAt:
// EventList.prEmitMi2Follow and AudioItem.prSrcOffset duck-type on exactly that pair
// to decide a map converts beats<->seconds, and would consume a Groove as one.
//
// Built from a DURATION MULTIPLIER m(u) over a period, mean 1. Two consequences:
// the map is monotone for |amount| < 1 BY CONSTRUCTION (it can never fold back, so
// every inversion downstream — wallToBeat, beatAt — keeps working), and it advances
// exactly one period per period, so there is no net tempo drift. Displacement is the
// INTEGRAL of the multiplier: a square multiplier gives triangular displacement,
// which is why swing and a wave modulation are one family rather than two features.
//
// Total on the whole beat line (periodic), so unlike a tempo map it has no domain
// boundary and no extrapolation policy to reconcile when composed.
//
//   Groove.swing(1.5)                                   // 60:40 over 2 beats
//   Groove.modulate(periodBeats: 8, amount: 0.1, shape: \sine)
//   e.add(0, (type: \eventList, eventList: \child, followTrack: true,
//             groove: Groove.swing(1.5)))               // child swings, parent does not
Groove {
	var <shape, <periodBeats, <amount, <phase;

	// ratio is the musician's unit (long:short). 1.5 == 60:40, 2 == triplet 67:33.
	*swing { |ratio = 1.5, periodBeats = 2|
		^this.modulate(periodBeats, (ratio - 1) / (ratio + 1), \square)
	}
	// phase is a CYCLE FRACTION (0..1), not radians.
	*modulate { |periodBeats = 2, amount = 0.2, shape = \sine, phase = 0|
		^super.new.init(shape, periodBeats, amount, phase)
	}
	*identity { ^this.modulate(2, 0, \square) }

	init { |aShape, aPeriod, anAmount, aPhase|
		shape = aShape; periodBeats = aPeriod; amount = anAmount ? 0; phase = aPhase ? 0;
		(periodBeats.isNumber.not or: { periodBeats <= 0 }).if {
			"Groove: periodBeats must be > 0 (%) — using 2".format(periodBeats).warn;
			periodBeats = 2;
		};
		(amount.abs >= 1).if {
			("Groove: |amount| must be < 1 (%) — at 1 the multiplier reaches 0 and the "
				"map stops being invertible; clipping").format(amount).warn;
			amount = amount.sign * 0.999;
		};
		#[\square, \sine, \tri].includes(shape).not.if {
			"Groove: unknown shape % — using \\square".format(shape).warn;
			shape = \square;
		};
	}

	// Antiderivative of (multiplier - 1) over one normalized period, unphased.
	// Mean-zero multiplier => prI(0) == prI(1) == 0, so it extends periodically.
	prI { |x|
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
	// Phasing by subtraction keeps prPhi(0) == prPhi(1) == 0 for every shape, so
	// phase never introduces an offset or breaks period preservation.
	prPhi { |u| ^this.prI(u + phase) - this.prI(phase) }

	// straight beat -> grooved beat
	mapBeat { |beat| ^beat + (periodBeats * this.prPhi(beat / periodBeats)) }

	// grooved beat -> straight beat. Bisection, like EventList.wallToBeat's
	// subsampled case: displacement is bounded by periodBeats/2, so the straight
	// beat is inside [g - periodBeats, g + periodBeats].
	unmapBeat { |beat|
		var lo = beat - periodBeats, hi = beat + periodBeats, mid;
		(amount == 0).if { ^beat };
		60.do {
			mid = (lo + hi) * 0.5;
			(this.mapBeat(mid) < beat).if({ lo = mid }, { hi = mid });
		};
		^(lo + hi) * 0.5
	}

	// Position-aware span mapping, same contract as mapBeats/mapDurs — see
	// SequenceableCollection.mapSpansFrom (plusArray.sc). The epsilon clamp is not
	// belt-and-braces here: unmapBeat is bisection, so two grooved beats closer
	// than the final bracket can return the same float and yield a zero span.
	mapSpans   { |spans, from = 0| ^spans.mapSpansFrom(from, { |p| this.mapBeat(p)   }) }
	unmapSpans { |spans, from = 0| ^spans.mapSpansFrom(from, { |p| this.unmapBeat(p) }) }

	isIdentity { ^amount == 0 }
	storeArgs { ^[periodBeats, amount, shape, phase] }
	printOn { |stream|
		stream << "Groove.modulate(" << periodBeats << ", " << amount << ", "
			<< shape.asCompileString << ", " << phase << ")"
	}
}
