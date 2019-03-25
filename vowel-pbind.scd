(
	SynthDef(\voweler,{
		 var sig,vowl,vowel1,vowel2;
		vowel1=Vowel(\a,\bass);
		vowel2=Vowel(\i,\tenor);
		vowl=vowel1.blend(vowel2,\blend.kr(0,0.5));
		sig=Formants.ar(\freq.kr(440,0.1),vowl);
		sig=Out.ar([0,1],sig);
	}).add
)
(
	a=Pmono(	 \voweler,
		\dur, Pseq([1,2],inf),
		\degree, Pseq([[8,10],10s],inf),
		\blend, Pseq([0,0.5,0.3,1,0.7],inf)
	);
	
	b=Pmono(	 \voweler,
		\dur, Pseq([1,2],inf),
		\degree, Pseq([5, 5, 5, 5, 5, 5, -1],inf),
		\blend, Pseq([0,0.5,1,0.7],inf)
	)
)

a.play;
b.play;

a=Pseq([\a,\e,\i,\o,\u],inf).asStream;
b=Pseq([\tenor, \bass, \alto, \soprano],inf).asStream;
c=Vowel(a.next,b.next).postln;
a.next;
b.next;
d={Formant.ar(400,Vowel(a,b))};
d.play;

Pmono(\test,
	)

	
		s.prepareForRecord("/Users/michael/tank/SchaferHouse/SOUND/AI SOUNDS/vowel-pbind.wav");
		s.record;
		a=SynthDef(\test,{|freq, vowel=\i| 
			var vib = Vibrato.ar(freq.lag(0.3), 6);
			var asr = EnvGen.ar(Env.asr(0.2,1,0.5));
			var sig = Formants.ar(vib,Vowel().addControls(lag: 1));
			////sig=FreeVerb.ar(sig, room:0.75);
			Out.ar([0,1],sig);
		}).add;

		a.allControlNames;

		(
		PmonoArtic(\test,
			\freq,Pxrand([200,150,160,300,200,40,523, 560,],inf),
			\freqs, Pseq([Vowel(\a).freqs,Vowel(\u).freqs,Vowel(\i,\tenor).freqs],inf),
			\widths, Pseq([Vowel(\a).widths,Vowel(\u).widths,Vowel(\i,\tenor).widths],inf),
			\dBs, Pseq([Vowel(\a).dBs,Vowel(\u).dBs,Vowel(\i,\tenor).dBs],inf),
			\legato, Prand([1,1,0,0,1,1,0.9],inf),
			\dur, Pwhite(0.05,0.25,inf)).play;
		//Synth(\test,Vowel(\i));
	)
	
	s.stopRecording;


a=Vowel(\a,\bass);
a.asKeyValuePairs;
a.freqs;

a.freqs;
a.freqs_({|i| 100 * (i+1) }!5)
a.freqs_({|i| i+100; });
b=\a;
a=Vowel(b,\bass);
