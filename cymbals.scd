
x = {
	var driver, cutoffenv, freqs, res;

	cutoffenv = EnvGen.ar(Env.perc(0, 5)) * 20000 + 10;

	driver = LPF.ar(WhiteNoise.ar(0.1), cutoffenv);

	freqs  = {exprand(300, 20000)}.dup(100);

	res    = Ringz.ar(driver, freqs).mean.dup

}.play;

)

x.free;
(

x = {

	var lodriver, locutoffenv, hidriver, hicutoffenv, freqs, res;

	locutoffenv = EnvGen.ar(Env.perc(0.25, 5)) * 20000 + 10;

	lodriver = LPF.ar(WhiteNoise.ar(0.1), locutoffenv);

	hicutoffenv = 10001 - (EnvGen.ar(Env.perc(1, 3)) * 10000);

	hidriver = HPF.ar(WhiteNoise.ar(0.1), hicutoffenv);

	hidriver = hidriver * EnvGen.ar(Env.perc(1, 2, 0.25));

	freqs  = {exprand(300, 20000)}.dup(100);

	res    = Ringz.ar(lodriver + hidriver, freqs).mean.dup

}.play;

)



x.free;
(

x = {

	var lodriver, locutoffenv, hidriver, hicutoffenv, freqs, res;

	locutoffenv = EnvGen.ar(Env.perc(0.5, 5)) * 20000 + 10;

	lodriver = LPF.ar(WhiteNoise.ar(0.1), locutoffenv);

	hicutoffenv = 10001 - (EnvGen.ar(Env.perc(1, 3)) * 10000);

	hidriver = HPF.ar(WhiteNoise.ar(0.1), hicutoffenv);

	hidriver = hidriver * EnvGen.ar(Env.perc(1, 2, 0.25));

	freqs  = {exprand(300, 20000)}.dup(100);

	res    = Ringz.ar(lodriver + hidriver, freqs).mean;

	((res * 1) + (lodriver * 2)).dup;

}.play;

)


(

x = {

	var lodriver, locutoffenv, hidriver, hicutoffenv, freqs, res, thwack;

	locutoffenv = EnvGen.ar(Env.perc(0.5, 5)) * 20000 + 10;
	lodriver = LPF.ar(WhiteNoise.ar(0.1), locutoffenv);
	hicutoffenv = 10001 - (EnvGen.ar(Env.perc(1, 3)) * 10000);
	hidriver = HPF.ar(WhiteNoise.ar(0.1), hicutoffenv);
	hidriver = hidriver * EnvGen.ar(Env.perc(1, 2, 0.25));
	thwack = EnvGen.ar(Env.perc(0.001,0.001,1));
	freqs  = {exprand(300, 20000)}.dup(100);
	res    = Ringz.ar(lodriver + hidriver + thwack, freqs).mean;
	((res * 1) + (lodriver * 2) + thwack).dup;
}.play;

)

(

{

	var lodriver, locutoffenv, hidriver, hicutoffenv, freqs, res, thwack;

	locutoffenv = EnvGen.ar(Env.perc(0.5, 5)) * 20000 + 10;
	lodriver = LPF.ar(WhiteNoise.ar(0.1), locutoffenv);
	hicutoffenv = 10001 - (EnvGen.ar(Env.perc(1, 3)) * 10000);
	hidriver = HPF.ar(WhiteNoise.ar(0.1), hicutoffenv);
	hidriver = hidriver * EnvGen.ar(Env.perc(1, 1, 0.25));
	thwack = EnvGen.ar(Env.perc(\att.kr(0.001),0.0001,1));
	freqs  = {exprand(300, 20000)}.dup(30);
	res    = Ringz.ar(lodriver + hidriver + thwack, freqs).mean;
	((res * 1) + (lodriver * 2) + thwack).dup * \amp.kr(0.1)
	=> ( Out.ar(\out.ir,_) <! DetectSilence.ar(_,doneAction:2))
}=>SynthDef(\cymbalsDS,_)=>_.add;
)
Synth(\cymbalsDS,[\out,2,\att,0.001,\amp,0.05]);
(// I wanted to be certain
	[
		(instrument:\cymbalsDS,out:2,att:0.001,amp:0.03)=>Pfin(1,_),
		//[amp:[0.13,0.09].q(inf),degree:([1,3,5]!4++[[0,1,3,5]]).q-1,out:2,sustain:0.3!4++[2]].p,
		
		[
			amp:[0.13,0.09].q(inf),
			degree:([1,3,5]!4++[[0,4,5]]).q-1,
			out:2,
			sustain: 0.3!4++[2]=>Pseq(_)
		].p
		,
		[out:2,degree:[1,1,0,0,4-7].q-1,dur:[3,1,3,1,4].q/2,octave:[2,3,4]].p,
	]=>Ppar(_)=>Pset(\root,6,_)=>_.play;s.meter
)
Monitor.new.play(2,2,0,2)
x.free;
s.meter
