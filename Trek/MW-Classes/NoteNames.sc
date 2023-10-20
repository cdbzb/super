S{
	classvar steps, modes, <modeSteps;
	*initClass {
		steps = [\major,\major,\minor,\major,\major,\major,\minor]
		.collect{|i| V(2,i) };
		modes = [\major, \dorian, \phrygian, \lydian, \mixolydian, \minor, \locrian];
		modeSteps = modes.collect{|m x|
			m-> steps.collect{|i y| steps@@( x+y )}
		}.asEvent
	}
}
N{
	var <name, <accidental, <degree; 
	classvar <intervalsFromA, <semitonesFromA, <qualitiesFromA, accidentals, <>names;
	*initClass {
		qualitiesFromA = [\perfect, \major, \minor, \perfect, \perfect, \minor, \minor];
		intervalsFromA = qualitiesFromA.collect{|i x| V(x+1, i)};
		semitonesFromA = intervalsFromA.collect(_.semitones);
		names = [\a,\b,\c,\d,\e,\f,\g].collect{|i x|
			i -> x
		}.asDict
	}
	*new { | name accidental |
		^super.newCopyArgs(name, accidental).init
	}
	init {
		degree = names.at(name)
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
	classvar <perfectIntervalQualities,<imperfectIntervalQualities,<defaultIntervals, names;
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
		// default interval is in terms of quartertones
		// imperfect intervals have odd defaults perfect have even
		// seconds can be major or minor, so the default will be midway between
		defaultIntervals = [0, 3, 7, 10, 14, 17, 21, 24];
		names = [\unison, \second, \third, \fourth, \fifth, \sixth, \seventh, \octave].collect{|i x|
			x->i
		}.asDict
	}
	*new {|oneIndexedDegree quality|
		^super.newCopyArgs(oneIndexedDegree,quality).init
	}
	*fromAccidental {|accidental|
		var quality = switch( accidental,
			\sharp,       {\augmented} ,
			\doubleSharp, {'doubly-augmented'},
			\doubleFlat,  {'doubly,-diminished'},
			\flat,        {'diminished'},
			\natural,     {'perfect'}
		);
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

