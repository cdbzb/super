N {
	classvar <noteNames = #[\A,\B,\C,\D,\E,\F,\G] ;
	classvar <intervals;
	classvar accidentals;
	var <name, <accidental;

	*initClass {
		var intervalQualities = [\perfect, \major, \minor, \perfect,\perfect, \minor, \minor];
		intervals = intervalQualities.collect{|x i| V(i + 1, x ) };

	}
	*new {| name accidental| 
		^super.new.init(name, accidental)
	}
	init {|n a|
		name = n;
		accidental = a ? \natural
	}
	intervalFromA { 
		^intervals.at(this.scaleDegree ) + PtAccidental(accidental).asInterval
	}
	scaleDegree {
		^noteNames.indexOf(name)
	}
	- {|that|
		^this.intervalFromA - that.intervalFromA
	}
	+ {|that |
		var degree = noteNames.indexOf(this.name);
		^noteNames[ degree + that.degree - that.degree.sign ]
	}
	printOn {|stream|
		stream << "N( " << name << " " << accidental << ")"
	}
}
PtAccidental {
	var <accidental;  
	classvar unisonQualities;

	*initClass {
		unisonQualities = ('double-flat':'doubly-diminished', flat:'diminished',natural:\perfect,sharp:\augmented,'double-sharp':'doubly-augmented');
	}

	*new { |accidental|
		^super.newCopyArgs(accidental)
	}

	asInterval {
		^V(1, unisonQualities.at(accidental))
	}
}
PtPitch {
	var octave, pitchClass, accidental;
	*new { |pitchClass,accidental, octave| 
		^super.new.init(pitchClass,accidental, octave)
	}
	init { |p a o|
		pitchClass = p;
		octave = o;
		accidental = Accidental(a);
	}
	printOn {
		\blah.postln
	}
}

V {
	classvar <rawIntervals = #[0.0, 1.5, 3.5, 5.0, 7.0, 8.5, 10.5, 12.0];
	classvar <perfectIntervalQualities, <imperfectIntervalQualities;
	var <degree, <quality;
	*initClass {
		perfectIntervalQualities = (diminished:-1.0,perfect:0.0,augmented:1.0);
		imperfectIntervalQualities = ('doubly-diminished': -2.5, diminished:-1.5,minor:-0.5,major:0.5,augmented:1.5,'doubly-augmented':2.5);
	}
	*new{ |degree quality|
		^super.newCopyArgs(degree, quality)
	}
	semitones {
		^( 
			rawIntervals[ degree.abs - 1 ] + 
			( rawIntervals[ degree.abs - 1].frac == 0.0 ).if{
				perfectIntervalQualities.at(quality)
			}{
				imperfectIntervalQualities.at(quality)
			}
			* degree.sign
		)
	}
	invert {
		^this.class.new(degree * -1, quality)
	}
	+ {|that|
		var outSemitones, outDegree, outQuality, rawInterval;
		outSemitones = this.semitones + that.semitones;
		outDegree = ( that.degree - that.degree.sign ) + ( degree - degree.sign );
		outDegree = outDegree + outDegree.isNegative.if{-1}{1};
		rawInterval = rawIntervals[ outDegree.abs - 1 ];
		outQuality = ( rawInterval.frac==0.0 ).if{
				perfectIntervalQualities.findKeyForValue(outSemitones.abs - rawInterval )
		}{
				imperfectIntervalQualities.findKeyForValue(outSemitones.abs - rawInterval)
		}
		^V(outDegree,outQuality)
	}
	- {|that|
		^( this + that.invert )
	}
	printOn { | stream|
		stream << "Interval\(" <<  degree << ", " << quality << "\)" ;
	}
}
+Event {
	asN {
		var rootSemitonesFromA = this.root + 3;
		var name = N.noteNames[rootSemitonesFromA];
		^N(name) + V(this.degree)
	}
}
