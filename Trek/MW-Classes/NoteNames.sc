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
	*doesNotUnderstand {|i|
		modes.includes(i).if {
			^modeSteps.at(i).inject([V(1, \perfect)], {|a b| a ++ (a.last + b)})
		}
	}
}
N{
	var <name, <accidental, <octave=0, <degree; 
	classvar <intervalsFromA, <semitonesFromA, <qualitiesFromA, accidentals, <>names;
	*initClass {
		qualitiesFromA = [\perfect, \major, \minor, \perfect, \perfect, \minor, \minor];
		intervalsFromA = qualitiesFromA.collect{|i x| V(x+1, i)};
		semitonesFromA = intervalsFromA.collect(_.semitones);
		names = [\a,\b,\c,\d,\e,\f,\g].collect{|i x|
			i -> x
		}.asDict
	}
	*new { | name accidental octave |
		^super.newCopyArgs(name, accidental, octave).init
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
	printOn { |stream|
		stream << "N(" <<  name << "," << accidental << ")"
	}
}
V{
	classvar <perfectIntervalQualities,<imperfectIntervalQualities,<defaultIntervals, names;
	var <oneIndexedDegree, <quality, <octave, <direction, <defaultInterval,<degree, <octave ;
	classvar <noteNames;
	classvar <qualitiesFromA;
	classvar <intervalsFromA;

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
			\augmented: 3
		);
		// default interval is in terms of quartertones
		// imperfect intervals have odd defaults perfect have even
		// seconds can be major or minor, so the default will be midway between
		defaultIntervals = [0, 3, 7, 10, 14, 17, 21, 24];
		names = [\unison, \second, \third, \fourth, \fifth, \sixth, \seventh, \octave].collect{|i x|
			x->i
		}.asDict;
		noteNames = [\a,\b,\c,\d,\e,\f,\g];
		qualitiesFromA = [\perfect, \major, \minor, \perfect, \perfect, \minor, \minor,
			//second set for inverted intervals via wrapAt
			\perfect, \minor, \minor, \perfect,\perfect, \major, \major];
		intervalsFromA = qualitiesFromA.collect{|i x| V(x+1, i)};
	}
	*new {|oneIndexedDegree quality octave=0|
		^super.newCopyArgs(oneIndexedDegree, quality, octave).init
	}
	*fromAccidental {|accidental|
		var quality = switch( accidental,
			\sharp,       {\augmented} ,
			\doubleSharp, {'doubly-augmented'},
			\doubleFlat,  {'doubly-diminished'},
			\flat,        {'diminished'},
			\natural,     {'perfect'}
		);
		^V(1, quality)
	}
	*getAccidental {|quality|
		^switch(quality,
			\augmented, {\sharp},
			'doubly-augmented', {\doubleSharp},
			'doubly-diminished', {\doubleFlat},
			'diminished', {\flat},
			'perfect', {\natural}
		);
	}
	init{
		degree = oneIndexedDegree - (oneIndexedDegree.sign);
		direction = oneIndexedDegree.isNegative.if{-1}{1};
		defaultInterval = defaultIntervals[degree.abs];
	}
	asN {
		^N(
			noteNames.wrapAt(this.degree),
			this.class.getAccidental(
				(this - V(this.degree + this.degree.sign, V.qualitiesFromA.wrapAt(this.degree))).quality 
			)
		)
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
		^this.quartertones / 2 + ( octave * 12 )
	}
	+ {|that|
		var outDegrees = degree + that.degree ;
		var error = this.quartertones + that.quartertones - defaultIntervals.wrapAt(outDegrees.abs);
		var outQuality = defaultIntervals.wrapAt(outDegrees.abs).odd.if{
			imperfectIntervalQualities.findKeyForValue(error.asInteger % 8)
		}{
			perfectIntervalQualities.findKeyForValue(error.asInteger % 8)
		};
		error.debug("outDegrees");
		^V(outDegrees + outDegrees.sign, outQuality)
	}
	invert {
		^V(oneIndexedDegree * ( -1 ), quality, octave * -1)
	}
	- {|that|
		^this + that.invert
	}
	printOn{|stream|
		stream << "V(" <<  oneIndexedDegree  << "," << quality << ")"
	}
}

