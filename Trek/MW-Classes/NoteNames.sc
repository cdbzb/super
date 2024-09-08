S{
	classvar steps, modes, <modeSteps;
	var <array;
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
			^super.new.init(i)
		}
	}
	*new{ |name from|
		^super.new.init(name, from)
	}
	init{ |name from|
		from = case {from.isKindOf(N) }{from.asV }
		{from.isKindOf(V)}{from}
		{from.isNil}{V(1, \perfect)};
		array = modeSteps.at(name).inject([V(1, \perfect)], {|a b| a ++ (a.last + b)})
		.collect(_ + from)
	}
	notes{ 
		^array.collect(_.fromN)
	}
	*from{|key|
		^super.new(name)

		
	}
}

N {
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
	*new { | name accidental octave=5 |
		^super.newCopyArgs(name, accidental, octave).init
	}
	init {
		degree = names.at(name)
	}
	asV {
		^(intervalsFromA.wrapAt(degree) + V.fromAccidental(accidental) + V(octave - 5 * 8, \perfect)
	) 
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
		stream << "N(" <<  name << "," << accidental <<  "," << octave << ")"
	}
}
V { 
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
		defaultIntervals = [0, 3, 7, 10, 14, 17, 21];
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
		defaultInterval = defaultIntervals@@(degree.abs);
	}
	fromN { |n|
		var sum;
		n = n ? N(\a, \natural);
		sum = this + n.asV ;
		^N(
			noteNames.wrapAt(sum.degree),
			this.class.getAccidental(
				(sum - V(sum.degree + sum.degree.sign, V.qualitiesFromA.wrapAt(sum.degree))).quality 
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
			+ (( degree.abs / 7 ).floor.asInteger * 24)
			* direction
		)
	}
	semitones {
		^this.quartertones / 2 + ( octave * 12 )
	}
	+ {|that|
		var outDegrees = degree + that.degree 
		=> _.debug("outDegrees:")
		;
		var qualityInQuartertones = (this.quartertones.debug("this.quarter:") + that.quartertones.debug("that.quarter:")).abs % 24 - 
		( defaultIntervals.wrapAt(outDegrees.abs) * outDegrees.sign )
		=> _.debug("qualityInQuartertones:")
		;
		var outQuality = defaultIntervals.wrapAt(outDegrees.abs) => _.debug("outQuality:" ) =>_.odd =>_.if{
			imperfectIntervalQualities.findKeyForValue(qualityInQuartertones.abs % 24 * qualityInQuartertones.sign)
		}{
			perfectIntervalQualities.findKeyForValue(qualityInQuartertones.abs % 24 * qualityInQuartertones.sign)
		};
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

