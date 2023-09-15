N{
	var <degree, <accidental; 
	classvar <intervalsFromA, <semitonesFromA, <qualitiesFromA, accidentals;
	*initClass {
		qualitiesFromA = [\perfect, \major, \minor, \perfect, \perfect, \minor, \minor];
		intervalsFromA = qualitiesFromA.collect{|i x| V(x+1, i)};
		semitonesFromA = intervalsFromA.collect(_.semitones);
	}
	*new { | degree accidental |
		^super.newCopyArgs(degree -1, accidental)
	}
	- {|note|
		^
		(
			intervalsFromA[degree] + V.fromAccidental(accidental)
			-
			(intervalsFromA[note.degree] + V.fromAccidental(note.accidental))
		)
		//naaaah just interval from y to A - interval from x to A - accidentaY.asInterval + accidental X.asInterval
	}
}
V{
	classvar <perfectIntervalQualities,<imperfectIntervalQualities,<defaultIntervals;
	var <oneIndexedDegree, <quality, <direction, <defaultInterval,<degree ;
	*initClass{
		perfectIntervalQualities = (
			'doubly-diminished':-4,
			\diminished:-2,
			\perfect:0,
			\augmented:2,
			'doubly-augmented':4
		);
		imperfectIntervalQualities = (
			\diminished: -3,
			\minor: -1,
			\major: 1,
			\augmented:3
		);
		// default interval is twice the number of quartertones
		// imperfect intervals have odd defaults perfect have even
		// seconds can be major or minor, so the default will be midway between
		defaultIntervals = [0, 3, 7, 10, 14, 17, 21, 24];
	}
	*new {|oneIndexedDegree quality|
		^super.newCopyArgs(oneIndexedDegree,quality).init
	}
	*fromAccidental {|accidental|
		var quality = case
		{accidental == \sharp}{\augmented}
		{accidental == \doubleSharp}{'doubly-augmented'}
		{accidental == \doubleFlat}{'doubly-diminished'}
		{accidental == \flat}{'diminished'}
		{accidental == \natural}{'perfect'};
		^V(1, quality)
	}
	init{
		degree = oneIndexedDegree - (oneIndexedDegree.sign);
		direction =oneIndexedDegree.isNegative.if{-1}{1};
		defaultInterval = defaultIntervals[degree.abs]
	}
	quartertones {
		^(
			defaultInterval +
			defaultInterval.odd.if{
				imperfectIntervalQualities[quality] 
			}{
				perfectIntervalQualities[quality]
			}
			* direction
		)
	}
	semitones {
		^this.quartertones / 2
	}
	+ {|that|
		var outDegrees = degree + that.degree ;
		var error = this.quartertones + that.quartertones - defaultIntervals[outDegrees];
		var outQuality = defaultIntervals[outDegrees].odd.if{
			imperfectIntervalQualities.findKeyForValue(error.asInteger)
		}{
			perfectIntervalQualities.findKeyForValue(error.asInteger)
		};
		error.postln;
		^V(outDegrees + 1, outQuality)
	}
	invert {
		^V(oneIndexedDegree * ( -1 ), quality)
	}
	- {|that|
		^this + that.invert
	}
	printOn{|stream|
		stream << "V(" <<  oneIndexedDegree  << "," << quality << ")"
	}
}

