//  to add controls (from the Help)
//  (
//  x = SynthDef(\vowel, {|freq = 420|
//      Out.ar(0, 
//          Formants.ar(freq.lag(0.1), Vowel(\a).addControls(lag: 1)) * 0.01
//      )
//  }).play
//  )
//  	        
//  x.setn(*([\freq, exprand(100, 1000)] ++ Vowel(\u, \soprano).asKeyValuePairs));

(
	~vowels = [\a,\e,\i,\o,\u];
	~voices = [\soprano,\alto,\tenor,\counterTenor,\bass];
	~vowelBlender = { |voice vowel|
		Formants.ar(Formants)
       	}
	~chooseOne= {
		var vowels = [\a,\e,\i,\o,\u];
		var voices = [\soprano,\alto,\tenor,\counterTenor,\bass];
		Vowel(vowels.choose,voices.choose);
	// a=Vowel.formlib; // Dictionary
})

a=SynthDef(\test , {Formants.ar(400,Vowel(\a).addControls(id: \tt, lag: 1))}).add
a.allControlNames;


(
	SynthDef(\voweler,{ //freq blend
		 var sig,vowl,vowel1,vowel2,vib,env;
		vowel1=Vowel(\a,\bass);
		vowel2=Vowel(\i,\tenor);
		vowl=vowel1.blend(vowel2,\blend.kr(0,0.5));
		vib=Vibrato.ar(\freq.kr(440,0.1),\rate.kr(5,1),\width.kr(0.07) ,onset:1);
		sig=Formants.ar(vib,vowl);
		env=EnvGen.kr(Env.asr(0.05,0.5));
		sig=Out.ar([0,1],sig*env*\amp.kr(1,2));
	}).add;

	

	PmonoArtic(	\voweler,
		\freq, Pwhite(100,500), 
		\dur, Pwhite(0.15,1.5),
		\blend, Pwhite(0,1),
		\legato, Prand([1,1,1,1,0.9],inf),
		\rate, Pwhite(4,6),
		\amp, Pwhite(0.5,1)
	).play		;

	PmonoArtic(	\voweler,
		\freq, Pwhite(200,700), 
		\dur, Pwhite(0.15,1),
		\blend, Pwhite(0,1),
		\legato, Prand([1,1,1,1,0.9],inf),
		\rate, Pwhite(4,6),
		\amp, Pwhite(0.5,1)
	).play		

)

