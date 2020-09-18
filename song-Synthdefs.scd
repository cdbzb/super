s.waitForBoot({

	SynthDef(\trans, { |freq amp gate=1 out=0|
		var notes= Demand.kr(Dust.kr(0.3)+Impulse.kr(0.01,0.999),0,Dseq([freq,freq*2],inf));
		var sig=SinOsc.ar(Lag.kr(notes,0.6),0,0.1).distort*amp*Env.asr(0,1,5).kr(gate:gate);
		Out.ar(out,sig!2);
	}).add ;

	SynthDef(\two_tube,{|out=0 gate=1 |
		var in =In.ar(out,2);
		var sig=TwoTube.ar(in,d1length:507,d2length:819,loss:0.99);
		ReplaceOut.ar(out,sig*EnvGen.ar(Env.perc(0,7)));
	}).add;

	SynthDef(\rest,{}).add;

	SynthDef(\test,{|freq amp=1|Out.ar(1,amp*RLPF.ar(Saw.ar(freq.lag(2),0.1*EnvGen.kr(Env.linen(0.05,0.5,2),doneAction:2)),freq*2+1500+SinOsc.ar(5.2,0,350),2))}).add;

	SynthDef(\pluckD,{|freq=400 amp=1|
		var sig= Pluck.ar(WhiteNoise.ar(0.1),  trig: \trig.tr(1),  maxdelaytime: 0.2,  delaytime: freq.reciprocal,  decaytime: \del.kr(5),  coef: \coef.kr(0.6),  mul: 1,  add: 0) ;
		sig=CrossoverDistortion.ar(sig,\drive.kr(0.9),\smooth.kr(0.1));
		sig=Phaser2.ar(sig,0.5,0.15,rq:1);
		Out.ar(\out.ir,  sig*amp);
	}).add;
	SynthDef(\pluckDEnv,{|freq=400 amp=1 release=3|
		var envelope= Env.cutoff(release).kr(2,gate:\gate.kr(1));
		var sig= Pluck.ar(WhiteNoise.ar(0.1),  trig: \trig.tr(1),  maxdelaytime: 0.2,  delaytime: freq.reciprocal,  decaytime: \del.kr(5),  coef: \coef.kr(0.6),  mul: 1,  add: 0) ;
		sig=CrossoverDistortion.ar(sig,\drive.kr(0.9),\smooth.kr(0.1));
		sig=Phaser2.ar(sig,0.5,0.15,rq:1);
		Out.ar(\out.kr,  sig*amp*envelope);
	}).add;
	SynthDef (\cymbalsDS,{ //Dan Stowall Cymbals
		var lodriver, locutoffenv, hidriver, hicutoffenv, freqs, res, thwack;
		locutoffenv = EnvGen.ar(Env.perc(0.5, 5)) * 20000 + 10;
		lodriver = LPF.ar(WhiteNoise.ar(0.1), locutoffenv);
		hicutoffenv = (EnvGen.ar(Env.perc(1, 3))).range(10000,1);
		hidriver = HPF.ar(WhiteNoise.ar(0.1), hicutoffenv)
		* EnvGen.ar(Env.perc(1, 1, 0.25));
		thwack = EnvGen.ar(Env.perc(\att.kr(0.001),0.0001,1));
		freqs  = {exprand(300, 20000)}.dup(30);
		res	= Ringz.ar(lodriver + hidriver + thwack, freqs).mean;
		((res * 1) + (lodriver * 2) + thwack).dup * \amp.kr(0.1)
		=> ( Out.ar(\out.ir,_) <! DetectSilence.ar(_,doneAction:2))
	}).add;
	// more kicks
	SynthDef(\kick1, {
		var snd;
		snd = DC.ar(0);
		snd = snd + (SinOsc.ar(XLine.ar(800, 400, 0.01)) * Env.perc(0.0005, 0.01).ar);
		snd = snd + (BPF.ar(Hasher.ar(Sweep.ar), XLine.ar(800, 100, 0.01), 0.6) * Env.perc(0.001, 0.02).delay(0.001).ar);
		snd = snd + (SinOsc.ar(XLine.ar(172, 50, 0.01)) * Env.perc(0.0001, 0.3, 1, \lin).delay(0.005).ar(2));
		snd = snd.tanh;
		Out.ar(\out.kr(0), Pan2.ar(snd, \pan.kr(0), \amp.kr(0.1)));
	}).add;
	SynthDef(\kick2, {
		var snd;
		snd = DC.ar(0);
		snd = snd + (HPF.ar(Hasher.ar(Sweep.ar), 1320) * Env.perc(0.003, 0.03).ar * 0.5);
		snd = snd + (SinOsc.ar(XLine.ar(750, 161, 0.02)) * Env.perc(0.0005, 0.02).ar);
		snd = snd + (SinOsc.ar(XLine.ar(167, 52, 0.04)) * Env.perc(0.0005, 0.3).ar(2));
		snd = snd.tanh;
		Out.ar(\out.kr(0), Pan2.ar(snd, \pan.kr(0), \amp.kr(0.1)));
	}).add;
	SynthDef(\kick3, {
		var snd;
		snd = DC.ar(0);
		snd = snd + (SinOsc.ar(XLine.ar(1500, 800, 0.01)) * Env.perc(0.0005, 0.01, curve: \lin).ar);
		snd = snd + (BPF.ar(Impulse.ar(0) * SampleRate.ir / 48000, 6100, 1.0) * 3.dbamp);
		snd = snd + (BPF.ar(Hasher.ar(Sweep.ar), 300, 0.9) * Env.perc(0.001, 0.02).ar);
		snd = snd + (SinOsc.ar(XLine.ar(472, 60, 0.045)) * Env.perc(0.0001, 0.3, curve: \lin).delay(0.005).ar(2));
		snd = snd.tanh;
		Out.ar(\out.kr(0), Pan2.ar(snd, \pan.kr(0), \amp.kr(0.1)));
	}).add;
	// Basic drum kit
	SynthDef("hihat", {arg out = 0, amp = 0.5, att = 0.01, rel = 0.2, ffreq = 6000, pan = 0;
		var env, snd;
		env = Env.perc(att, rel, amp).kr(doneAction: 2);
		snd = WhiteNoise.ar;
		snd = HPF.ar(in: snd, freq: ffreq, mul: env);
		Out.ar(out, Pan2.ar(snd, pan));
	}).add;
	SynthDef("snare", {arg out = 0, amp = 0.1, sinfreq = 180, att = 0.01, rel = 0.2, ffreq = 2000, pan = 0;
		var env, snd1, snd2, sum;
		env = Env.perc(att, rel, amp).kr(doneAction: 2);
		snd1 = HPF.ar(
			in: WhiteNoise.ar,
			freq: ffreq,
			mul: env
		);
		snd2 = SinOsc.ar(freq: sinfreq, mul: env);
		sum = snd1 + snd2;
		Out.ar(out, Pan2.ar(sum, pan));
	}).add;
	SynthDef("kick", {arg out = 0, amp = 0.3, sinfreq = 60, glissf = 0.9, att = 0.01, rel = 0.45, pan = 0;
		var env, snd, ramp;
		env = Env.perc(att, rel, amp).kr(doneAction: 2);
		ramp = XLine.kr(
			start: sinfreq,
			end: sinfreq * glissf,
			dur: rel
		);
		snd = SinOsc.ar(freq: ramp, mul: env);
		snd = Pan2.ar(snd, pan);
		Out.ar(out, snd);
	}).add;
	// Basic saw synth for chords and bass
	SynthDef("sawSynthSustain", { arg out=0, freq = 440, amp = 0.1, att = 0.1, rel = 2, lofreq = 1000, hifreq = 3000, lagTime = 0.3;
		var env, snd;
		freq=Lag.kr(freq,lagTime);
		env = Env.asr(
			attackTime: att,
			sustainLevel: amp,
			releaseTime: rel,
		).kr(gate:\gate.kr(1),doneAction: 2);
		snd = Saw.ar(freq: freq * [0.99, 1, 1.001, 1.008]) * env;
		snd = LPF.ar(
			in: snd,
			freq: LFNoise2.kr(1).range(lofreq, hifreq)
		);
		snd = Splay.ar(snd);
		Out.ar(out, snd);
	}).add;

	SynthDef("sawSynth", { arg out=0, freq = 440, amp = 0.1, att = 0.1, rel = 2, lofreq = 1000, hifreq = 3000, lagTime = 0.3;
		var env, snd;
		freq=Lag.kr(freq,lagTime);
		env = Env.perc(
			attackTime: att,
			releaseTime: rel,
			level: amp
		).kr(doneAction: 2);
		snd = Saw.ar(freq: freq * [0.99, 1, 1.001, 1.008], mul: env);
		snd = LPF.ar(
			in: snd,
			freq: LFNoise2.kr(1).range(lofreq, hifreq)
		);
		snd = Splay.ar(snd);
		Out.ar(out, snd);
	}).add;

	SynthDef(\verb_fade,{|in time| FreeVerb.ar(in, room:0.8, mix:0.8)*Line.kr(1,0,time)}).add;

	//				 {{{1 moved to Library/sythdefs
	SynthDef(\vsti,{|in out=0|
		var sig=VSTPlugin.ar(nil,2);
		Out.ar(out,sig)
	}).add;

	SynthDef(\stringyy,{ |gate=1| //{{{
		var freq=\freq.kr(400,\freqLag.kr(0.05));
		var width=\width.kr(6);
		//var gate=\gate.kr(0);

		Gendy2.ar(minfreq:freq-width,maxfreq:freq+width)
		=>Mix.ar(_) *0.5
		+Gendy1.ar(minfreq:freq-width,maxfreq:freq+width) 
		* 0.1 * \amp.kr(0.5)
		=> (PlateReverb.ar(_,10) ++ (_*0.5)) => Mix.ar(_)
		* Env.asr(0.5,1,8).kr(2,gate:gate)
		=>Out.ar(\out.kr(0),_)
	}).add; //}}}

	SynthDef(\FreeVerb,{
		In.ar(\in.kr(0))
		=> FreeVerb.ar(_,\mix.kr(1/3),\room.kr(1/2),\damp.kr(1/2))
		=> Out.ar(\out.kr(0),_)
	},variants:(long:[mix:1,room:1,damp:0.5],dry:[mix:0])
).add;

SynthDef(\defaultPorto,{
	var freq=\freq.kr(400,0.5)-5;

	Gendy4.ar(4,1,1,1,freq-19,freq+19,\ampScale.kr(0.1),\durScale.kr(0.1),Rand(11)+1)
	+ Saw.ar(freq,0.05)
	* Env.asr(0.2,1,3).kr(2,gate:\gate.kr(1))
	* 0.1
	=> BMoog.ar(_,1800,0.2,2.1)
	=>FreeVerb.ar(_,0.4,1)
	=> Out.ar(Rand(4),_)
},variants:(
	noisy1: [\ampScale,1.0,\durScale,1.5],
	clean: [\ampScale,0.5,\durScale,5.5]
 )).add;
//TODO generalize this - seperate into proto
//	~synful=( // creates a nodeproxy playing on a private bus - .node and .bus respectively 
//		bus: Bus.audio(s,2),
//		controller: nil,
//		node:nil,
//		params:(expression:11),
//		expEnv:NodeProxy.control(s,1)!16, //expEnv[n].source={} is the jam....
//		fs:Array.newClear(16), //used internally by activate
//		activate:{|self chan=0 update=0.1| 
//			self.expEnv[chan].source=64;
//			{ var ch=chan;
//				loop({
//					self.expEnv[ch].bus.get({|value| self.fs[ch]=value+1*64});
//					self.expression(self.fs[ch],ch);
//					update.wait;
//				});
//			}.fork;
//		},
//		expression:{|self expression channel=0 | self.controller.sendMidi("B0".asHexIfPossible+channel,11,expression)},
//		plugin: 'SynfulOrchestra.vst',
//		setprog:{|self program bank channel| 
//			self.controller.sendMidi("B0".asHexIfPossible+channel,0,bank);//set bank then
//			self.controller.sendMidi("C0".asHexIfPossible+channel,program); //set program
//		},
//		init: { |self| //create node and controller + load plug 
//			self.controller=VSTPluginController(Synth(\vsti,[\out,self.bus]));
//			self.node=NodeProxy.audio(s,2).play;
//			self.node.source={In.ar(self.bus.index,2)};
//			{
//				s.sync;
//				self.controller.open("/Library/Audio/Plug-Ins/VST/"++self.plugin,
//					action:{self.controller.readProgram("/Users/michael/tank/super/SynfulTest.FXP"); });
//			}.fork;
//		},
//		set:{|self args| self.controller.set(args)},
//		patches:( flute:73, oboe:68, enghorn:69, clarinet:71, bassoon:70, horn:62, horn4:5, horn8:6, trumpet:56, trombone:57, violin:40, viola:41, cello:42, bass:43, violins:0, violins2:1, violas:2, cellos:3, basses:4),
//		banks:( none:0, mute1:2, mute2:3, stopped:4, arco:1, pizz:2, bartok:3, legno:4, trem:5, sulpont:6, tremsulpont:7, harmonics:8, mute:9),
//		patch:{| self patch bank=\none channel=0 | self.setprog( self.patches.at(patch),self.banks.at(bank),channel);postln("patch "++self.patches.at(patch)++" bank "++self.banks.at(bank))}
//
//	);
//	~synful.init;
"LOADED".postln;
~synthsLoaded=true;

}
)
;

