( {var sig, vib; //dual opera singers with vocal fry
	vib= Vibrato.kr([MouseX.kr(1,1000),MouseX.kr(1,1000)*0.8],6,MouseY.kr(0.001,0.1));
	sig = Blip.ar(vib);
	sig=BPFStack.ar(sig,Vowel(\a,\tenor))*10;
	sig=FreeVerb.ar(sig, mix: 0.3,room:0.9, mul:[3,1]);
}.play
)
( //synthdef version
	SynthDef( \opera, {
		var vib=Vibrato.kr(\freq.kr(400, \flag.kr(1)),6,\depth.kr(0.05, 1));
		var sig = Blip.ar(vib,\buzz.kr(200));
		sig=BPFStack.ar(sig,Vowel(\a,\tenor))*10;
		sig=FreeVerb.ar(sig, mix: 0.3,room:0.9, mul:3);
		Out.ar([0,1],sig)
	}).add
)

(SynthDef( \lpf, { |out=0| ReplaceOut.ar(0,LPF.ar(In.ar(out,2),1280)) } )).add

(
	a=Panola.new("c4_2 g3_4 e g_4 ");
	b=PmonoArtic(\opera,
		\dur, Pn(a.durationPattern,inf),
		\midinote, Pn(a.midinotePattern+7,inf),
		\buzz,10,
		\legato, Pn(a.pdurPattern+0.5,inf));
	c=Pfx(b,\lpf).play
)

(///rhythmical robot vowels
x = SynthDef(\vowel, {|freq = 420|
	Out.ar([0,1],
		Formants.ar(Vibrato.kr(freq.lag(0.1)), Vowel(\a).addControls(lag: 1)) * 0.1
    ) }).play;

{ inf.do({
	x.setn(*([\freq, exprand(100, 1000)] ++ Vowel(\u, \soprano).asKeyValuePairs));
	0.2.wait;
	x.setn(*([\freq, exprand(10, 500)] ++ Vowel(\e,\bass).asKeyValuePairs));
	0.2.wait;
	x.setn(*([\freq, exprand(40, 1000)] ++ Vowel(\a, \soprano).asKeyValuePairs));
	0.2.wait;
	});
	0.2.wait;
}.fork
)

( //yow yow yow 
	SynthDef(\blendr, { var blend,vowl,sig,freq;
		blend = MouseY.kr(0,1);
		vowl = Vowel(\a,\bass).blend(Vowel(\i,\tenor),blend);
		freq=Vibrato.kr(MouseX.kr(20,1200,1),5);
		sig=Formants.ar(freq,vowl);
		sig=CombC.ar(sig);
		Out.ar([0,1],sig);
	}).add
)

a=Synth(\blendr);

(
	SynthDef(\blend_lfo, {  var blend,vowl,sig,freq,lfo;
		lfo=\lfo.kr(3);
		blend = SinOsc.kr(lfo,(3.141/2), mul:\width.kr(0.5));
		vowl = Vowel(\i,\soprano).blend(Vowel(\a,\tenor),blend);
		//vowl = \vowel1.kr(Vowel(\i,\tenor)).blend(\vowel2.kr(Vowel(\a,\bass)),blend);
		freq=Vibrato.kr( SinOsc.kr(lfo,mul: \height.kr(10,0.1) ,add: \fund.kr(300,\flag.kr(1.0))));
		//freq= SinOsc.kr(lfo,mul:10,add:fund)
		//freq=fund;
		sig=Formants.ar(freq,vowl);
		//sig=CombC.ar(sig);
		Out.ar([0,1],Pan2.ar(sig,\pan.kr(0),level:0.05));

	}).add
)

(
var low =Synth(\blend_lfo,[\fund, 200,\lfo, 2, \height, 50,\pan, -1 ]);
var high=Synth(\blend_lfo,[\fund, 300,\lfo, 4 ,\height, 25, \pan, 1 ]);
//a.set(//\lfo,3);
//a.set(\width,0.7);

{
inf.do({  
low.set(\fund, 120, \height, 40);
high.set(\fund, 360, \height, 20);
(3/3).wait;
low.set(\fund, 200, \height, 60);
high.set(\fund, 300, \height, 15);
(3/3).wait;
low.set(\fund, 240, \height, 10);
(2/3).wait;
});
(4/3).wait;
}.fork
)
s.meter;
s.reboot;





