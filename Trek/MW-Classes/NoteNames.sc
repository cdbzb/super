PtName {
	classvar noteNames = #[\A,\B,\C,\D,\E,\F,\G] ;
	classvar <intervals;
	var <name;
	*initClass {
		var intervalQualities = [\perfect, \major, \minor, \perfect,\perfect, \minor, \minor];
		intervals = intervalQualities.collect{|x i| 
			PtInterval(i, x)
		}
	}
	*new {| name| 
		^super.newCopyArgs(name)
	}
	semitonesFromA {
		var names = [\A,\B,\C,\D,\E,\F,\G];
		// ^semitones[names.indexOf(name)]
	}
	scaleDegree { |notename|
		^noteNames.indexOf(notename)
	}
	- {|that|
		^IntervalM(
			this.scaleDegree(that.name) - this.scaleDegree(this.name) + 1
		)
	}
}
AccidentalM {
	var <accidental;
	classvar semitones;
	initClass {
		semitones = Dictionary(
			\sharp -> 1,
			\flat -> -1,
			\doubleSharp -> 2,
			\doubleFlat -> -2
		)
	}
	*new { |accidental|
		^super.newCopyArgs(accidental)
	}
}
PitchM {
	var octave, pitchClass, accidental;
	*new { |pitchClass,accidental, octave| 
		^super.new.init(pitchClass,accidental, octave)
	}
	init { |p a o|
		pitchClass = PitchClassM(p);
		octave = o;
		accidental = Accidental(a);
	}
	printOn {
		\blah.postln
	}
}
PtInterval {
	classvar rawIntervals = #[0, 1.5, 3.5, 5, 7, 8.5, 10.5, 12];
	classvar <perfectIntervalQualities, <imperfectIntervalQualities;
	var <degree, <quality;
	*initClass {
		perfectIntervalQualities = (diminished:-1,perfect:0,augmented:1);
		imperfectIntervalQualities = ('doubly-diminished': -2.5, diminished:-1.5,minor:-0.5,major:0.5,augmented:1.5,'doubly-augmented':2.5);
	}
	*new{ |degree quality|
		^super.newCopyArgs(degree, quality)
	}
	semitones {
		^( rawIntervals[ degree - 1 ] + 
			rawIntervals[ degree  - 1].isInteger.if{
				perfectIntervalQualities.at(quality)
			}{
				imperfectIntervalQualities.at(quality)
			}
		)
	}
	+ {|that|
		var outSemitones, outDegree, outQuality, rawInterval;
		outSemitones = this.semitones + that.semitones;
		outDegree = that.degree + degree - 1;
		rawInterval = rawIntervals[ outDegree - 1 ];
		outDegree.postln;
		rawInterval.postln;
		

		outQuality = rawInterval.isInteger.if{
				perfectIntervalQualities.findKeyForValue(( outSemitones - rawInterval ).asInteger )
		}{
				imperfectIntervalQualities.findKeyForValue(( outSemitones - rawInterval ).asInteger)
		};
		^PtInterval(outDegree,outQuality)
	}
}
