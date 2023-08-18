
	SynthDef(\phase_verb ,{|out=0 depth=0.5 fb=0.3 rate=0.03 gate=1| //{{{
		XOut.ar(
			out,
			//Env.cutoff(6).kr(gate),
			Env.linen(0,8.5,6).kr(doneAction:2),
			Phaser2.ar(In.ar(out,2)+
			PlateReverb.ar(
				In.ar(out,2),mix:Env.linen(0,2.5,6).kr)
				,rate:rate,fb:fb,depth:depth
			)
		)
	}).add.tag(\effect);

SynthDef( \phase_verb2,{//{{{
	|out=5 depth=0.5 fb=0.3 rate=0.03|
	ReplaceOut.ar(
		out,Phaser2.ar(In.ar(out,1)+
		PlateReverb.ar( In.ar(out,1),mix:Env.linen(0,2.5,6).kr)
		,rate:rate,fb:fb,depth:depth))
	}
).add.tag(\effect);

 SynthDef(\harpS, { |gate=1 out=0 freq = 400|
	var in=PinkNoise.ar(1);
	var sig=Pluck.ar(in: in,  gate: gate,  maxdelaytime: 0.02,  delaytime: 1/freq,  decaytime: \decaytime.kr(10),  coef: \coef.kr(0.5),  mul: 0.7,  add: 0);
	sig = sig * \amp.kr(0.1) * 10;
	sig = LeakDC.ar(sig);
	sig => Pan2.ar(_,\pan.kr(0,\panLag.kr(0)))

	=> Out.ar(out,_);
	DetectSilence.ar(sig,doneAction:2);
},  rates: nil,  prependArgs: nil,  variants: nil,  metadata: nil
).add.tag(\pluck);

 SynthDef(\harp, { |gate=1 out=0 freq = 400|
	var in=PinkNoise.ar(1);
	var sig=Pluck.ar(in: in,  gate: gate,  maxdelaytime: 0.02,  delaytime: 1/freq,  decaytime: \decaytime.kr(10),  coef: \coef.kr(0.5),  mul: 0.7,  add: 0);
	sig = sig * \amp.kr(0.1) * 10;
	sig = LeakDC.ar(sig);
	Out.ar(out,sig);
	DetectSilence.ar(sig,doneAction:2);
},  rates: nil,  prependArgs: nil,  variants: nil,  metadata: nil
).add.tag(\pluck);

 SynthDef(\yowbass, {|freq=400 amp gate=1 dur=1|
	var sig=Formant.ar(freq,  formfreq: Line.kr(3060,00,dur),  bwfreq: 880,  mul: 1,  add: 0).distort;
	var env=Env.asr(0,1,1,1.5).kr(gate:gate,doneAction:2);
	Out.ar(0,sig*env*amp!2)}
	,  rates: nil,  prependArgs: nil,  variants: nil,  metadata: nil
).add.tag(\keys,\bass);

 SynthDef(\stab, {|out=0 freq=400 width=0.2 gate=1 amp=1|
	var sig=Pulse.ar(freq,width);
	var env=Env.asr(0.06,0.1,0.4).kr(gate:gate,doneAction:2);
	var fenv=Env.linen(0.0,0.1,0.7).kr(gate:gate)*freq*5;
	sig=RLPF.ar(sig,fenv,rq: 1);
	sig = Pan2.ar(sig,\pan.kr(-1));
	Out.ar(out, sig*env*amp);
},  rates: nil,  prependArgs: nil,  variants: nil,  metadata: nil
).add.tag(\keys);
