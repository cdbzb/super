PitchClassM {
	classvar semitones;
	var <name;
	*new {| name| 
		^super.newCopyArgs(name)
	}
	semitonesFromA {
		var semitones = [0,2,3,5,7,8,10];
		var names = [\A,\B,\C,\D,\E,\F,\G];
		^semitones[names.indexOf(name)]
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
IntervalM {
	var <degree, <quality;
	*new{ |degree quality|
		^super.newCopyArgs(degree, quality)
	}
}
