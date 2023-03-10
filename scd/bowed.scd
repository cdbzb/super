s.reboot;


(
SynthDef(\bow, { arg out=0, freq=440, amp=0.5,force=1, gate=1,pos=0.07,c1=0.25,c3=31,pan=0 ; var vib, sig, vibratemod;
	vib = Gendy1.kr(1,1,1,1,0.1, 4,mul:0.003,add:1);
	vibratemod = LFNoise1.kr(2, mul:0.1, add:0.9);
	vib = vib * SinOsc.kr(5*vibratemod,0,0.007,1);
	freq = Lag.kr(freq,2);
	amp = Lag.kr(amp,3);
	sig = DWGBowed.ar(freq*vib, amp,force, gate,pos,0.1,c1,c3, release: 4);
	sig = DWGSoundBoard.ar(sig);
	//sig = BPF.ar(sig,430,1)+sig;
	//sig = BPF.ar(sig,490,1)+sig;
	//sig = LPF.ar(sig,6000);
	sig = FreeVerb.ar(sig, mix:0.3, room: 7);
	sig=sig*0.2;
	Out.ar(out, Pan2.ar(sig * 0.1, pan));
}).add;

{
	var aa;
	s.sync;
	//"/Users/michael/tank/super/start-from-commandline.scd".load;
	aa= Synth(\bow, [\freq, 700]);
	4.wait;
	aa.set(\freq, 400);
	4.wait;
	aa.set(\gate,0,\freq, 300);
	0.5.wait;
	Pmono(\bow, \dur, Pseq([3,4,3]), \freq, Pseq ([[600,800],[500,350],[200,1000]],1)).play;
	8.1.wait;
}.fork
)


