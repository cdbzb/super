
	// via https://web.archive.org/web/20191104212834/https://www.nada.kth.se/utbildning/grukth/exjobb/rapportlistor/2010/rapporter10/szabo_adam_10131.pdf
SynthDef(\Rolandd, { | freq = 523.3572, mix=0.75, detune = 0.5 |
	var detuneCurve = { |x|
(10028.7312891634*x.pow(11)) -
(50818.8652045924*x.pow(10)) +
(111363.4808729368*x.pow(9)) -
(138150.6761080548*x.pow(8)) +
(106649.6679158292*x.pow(7)) -
(53046.9642751875*x.pow(6)) +
(17019.9518580080*x.pow(5)) -
(3425.0836591318*x.pow(4)) +
(404.2703938388*x.pow(3)) -
(24.1878824391*x.pow(2)) +
(0.6717417634*x) +
0.0030115596
	};
	var centerGain = { |x| (-0.55366 * x) + 0.99785 };
	var sideGain = { |x| (-0.73764 * x.pow(2)) + (1.2841 * x) + 0.044372 };

	var center = LFSaw.ar(freq.lag(0.2), Rand());
	var detuneFactor = freq * detuneCurve.(detune);
	var freqs = [
(freq - (detuneFactor * 0.11002313)),
(freq - (detuneFactor * 0.06288439)),
(freq - (detuneFactor * 0.01952356)),
// (freq + (detuneFactor * 0)),
(freq + (detuneFactor * 0.01991221)),
(freq + (detuneFactor * 0.06216538)),
(freq + (detuneFactor * 0.10745242))
	];
	var side = Mix.fill(6, { |n|
LFSaw.ar(freqs[n], Rand(0, 2))
	});

	var sig = (center * centerGain.(mix)) + (side * sideGain.(mix));



	sig = HPF.ar(sig * \amp.kr(0.1) / 3 ! 2, freq);
	sig * Env.asr().kr(2,\gate.kr(1))
	   => Out.ar(\out.kr(0), _)
}).add;

(
	   { arg out=0, freq=440, amp=0.1, pan=0, gate=1;
		   var z;
		   z = LPF.ar(
			   Mix.new(VarSaw.ar(freq * (\poly.kr(0) / 127 * \polyRange.kr(1) => _.midiratio) + [0, Rand(-0.4,0.0), Rand(0.0,0.4)], 0, 0.3, 0.3)),
			   XLine.kr(Rand(4000,5000), Rand(2500,3200), 1)
		   ) * Linen.kr(gate, 0.01, 0.7, 0.3, 2);
		   OffsetOut.ar(out, Pan2.ar(z, pan, amp));
	   } => SynthDef(\defaultMk, _) => _.add
   );

(
 SynthDef(\sawSynthBend, {
	 arg out=0, freq = 440, amp = 0.1, att = 0.1, rel = 2, lofreq = 1000, hifreq = 3000, lagTime = 0.3, spread=1, center=0, pulse = 0, t_trig = 0;
	 var env, snd;
	 freq=Lag.kr(freq * \bend.kr.midiratio.reciprocal, lagTime);
	 env = Env.asr(
		 attackTime: att,
		 sustainLevel: amp,
		 releaseTime: rel,
	 ).kr(gate:\gate.kr(1),doneAction: 2);
	 snd = Saw.ar(freq: freq * [0.99, 1, 1.001, 1.008]) * env;
	 snd = snd * ( (1 - pulse) + (pulse * Env.perc(att,\pulseRel.kr(1) ).kr(0,gate:t_trig)) );
	 snd = LPF.ar(
		 in: snd,
		 freq: LFNoise2.kr(1).range(lofreq, hifreq)
	 );
	 snd = Splay.ar(snd,spread:spread,center:center);
	 Out.ar(out, snd);
 }).add.tag(\mk)
);

(
Event.addEventType(type:\microtonic, func:{~instrument = \microtonic ++ '.' ++ ~instrument=> _.postln;~type=\note; currentEnvironment.play}, parentEvent:nil);

SynthDef("microtonic", {
  arg out,
  mix=50,level=(-5),distAmt=2,
  eQFreq=632.4,eQGain=(-20),
  oscAtk=0,oscDcy=500,
  oscWave=0,oscFreq=54,
  modMode=0,modRate=400,modAmt=18,
  nEnvAtk=26,nEnvDcy=200,
  nFilFrq=1000,nFilQ=2.5,
  nFilMod=0,nEnvMod=0,nStereo=1,
  oscLevel=1,nLevel=1,
  oscVel=100,nVel=100,modVel=100,
  fx_lowpass_freq=20000,fx_lowpass_rq=1,
  vel=64;

  // variables
  var osc,noz,nozPostF,snd,pitchMod,nozEnv,numClaps,oscFreeSelf,wn1,wn2,clapFrequency,decayer;

  // convert to seconds from milliseconds
  vel=LinLin.kr(vel,0,128,0,2);
  oscAtk=DC.kr(oscAtk/1000);
  oscDcy=DC.kr(oscDcy/1000);
  nEnvAtk=DC.kr(nEnvAtk/1000);
  nEnvDcy=DC.kr(nEnvDcy*1.4/1000);
  level=DC.kr(level);
  // add logistic curve to the mix
  mix=DC.kr(100/(1+(2.7182**((50-mix)/8))));
  // this is important at low freq
  oscFreq=oscFreq+5;

  // white noise generators (expensive)
  wn1=WhiteNoise.ar();
  wn2=WhiteNoise.ar();
  wn1=Clip.ar(wn1*100,-1,1);
  wn2=Clip.ar(wn2*100,-1,1);
  clapFrequency=DC.kr((4311/(nEnvAtk*1000+28.4))+11.44); // fit using matlab
  // determine who should free
  oscFreeSelf=DC.kr(Select.kr(((oscAtk+oscDcy)>(nEnvAtk+nEnvDcy)),[0,2]));

  // define pitch modulation1
  pitchMod=Select.ar(modMode,[
      Decay.ar(Impulse.ar(0.0001),(1/(2*modRate))), // decay
      SinOsc.ar(-1*modRate), // sine
      Lag.ar(LFNoise0.ar(4*modRate),1/(4*modRate)), // random
  ]);

  // mix in the the pitch mod
  pitchMod=pitchMod*modAmt/2*(LinLin.kr(modVel,0,200,2,0)*vel);
  oscFreq=((oscFreq).cpsmidi+pitchMod).midicps;

  // define the oscillator
  osc=Select.ar(oscWave,[
      SinOsc.ar(oscFreq),
      LFTri.ar(oscFreq,mul:0.5),
      SawDPW.ar(oscFreq,mul:0.5),
  ]);
  osc=Select.ar(modMode>1,[
      osc,
      SelectX.ar(oscDcy<0.1,[
          LPF.ar(wn2,modRate),
          osc,
      ])
  ]);

  // add oscillator envelope
  decayer=SelectX.kr(distAmt/100,[0.05,distAmt/100*0.3]);
  osc=osc*EnvGen.ar(Env.new([0.0001,1,0.9,0.0001],[oscAtk,oscDcy*decayer,oscDcy],\exponential),doneAction:oscFreeSelf);

  // apply velocity
  osc=(osc*LinLin.kr(oscVel,0,200,1,0)*vel).softclip;

  // generate noise
  noz=wn1;

  // optional stereo noise
  noz=Select.ar(nStereo,[wn1,[wn1,wn2]]);

  // define noise envelope
  nozEnv=Select.ar(nEnvMod,[
      EnvGen.ar(Env.new(levels: [0.001, 1, 0.0001], times: [nEnvAtk, nEnvDcy],curve:\exponential),doneAction:(2-oscFreeSelf)),
      EnvGen.ar(Env.new([0.0001,1,0.9,0.0001],[nEnvAtk,nEnvDcy*decayer,nEnvDcy*(1-decayer)],\linear)),
      Decay.ar(Impulse.ar(clapFrequency),1/clapFrequency,0.85,0.15)*Trig.ar(1,nEnvAtk+0.001)+EnvGen.ar(Env.new(levels: [0.001, 0.001, 1,0.0001], times: [nEnvAtk,0.001, nEnvDcy],curve:\exponential)),
  ]);

  // apply noise filter
  nozPostF=Select.ar(nFilMod,[
      BLowPass.ar(noz,nFilFrq,Clip.kr(1/nFilQ,0.5,3)),
      BBandPass.ar(noz,nFilFrq,Clip.kr(2/nFilQ,0.1,6)),
      BHiPass.ar(noz,nFilFrq,Clip.kr(1/nFilQ,0.5,3))
  ]);
  // special Q
  nozPostF=SelectX.ar((0.1092*(nFilQ.log)+0.0343),[nozPostF,SinOsc.ar(nFilFrq)]);

  // apply envelope to noise
  noz=Splay.ar(nozPostF*nozEnv);

  // apply velocities
  noz=(noz*LinLin.kr(nVel,0,200,1,0)*vel).softclip;

  // mix oscillator and noise
  snd=SelectX.ar(mix/100*2,[
      noz*0.5,
      noz*2,
      osc*1
  ]);

  // apply distortion
  snd=SineShaper.ar(snd,1.0,1+(10/(1+(2.7182**((50-distAmt)/8))))).softclip;

  // apply eq after distortion
  snd=BPeakEQ.ar(snd,eQFreq,1,eQGain/2);

  snd=HPF.ar(snd,20);

  snd=snd*level.dbamp*0.2;
  // free self if its quiet
  FreeSelf.kr((Amplitude.kr(snd)<0.001)*TDelay.kr(DC.kr(1),0.05));

  // apply some global fx
  snd=RLPF.ar(snd,fx_lowpass_freq,fx_lowpass_rq);

  // level
  Out.ar(0, snd);
}, 
variants: (
  kick: [
      distAmt: 34.064063429832,
      eQFreq: 80.661909666463,
      eQGain: 30.246815681458,
      level: -5.1201522322287,
      mix: 88.153877258301,
      modAmt: 33.019509360458,
      modMode: 0,
      modRate: 4.0523291566457,
      modVel: 35.558253526688,
      nEnvAtk: 2.1977363693469,
      nEnvDcy: 1104.977660676,
      nEnvMod: 0,
      nFilFrq: 392.00617432122,
      nFilMod: 0,
      nFilQ: 1.463421337541,
      nStereo: 1,
      nVel: 40.751650929451,
      oscAtk: 0,
      oscDcy: 726.5732892423,
      oscFreq: 48.060961337325,
      oscVel: 38.951644301414,
      oscWave: 0
  ],
  hihat: [
      distAmt: 1.9999999552965,
      eQFreq: 111.80335896926,
      eQGain: -36.059684753418,
      level: 0,
      mix: 0,
      modAmt: 0,
      modMode: 0,
      modRate: 2.8301886792453,
      modVel: 36.000001430511,
      nEnvAtk: 1.7076868541052,
      nEnvDcy: 90.509330260423,
      nEnvMod: 0,
      nFilFrq: 7447.9779098801,
      nFilMod: 2,
      nFilQ: 0.70710500896458,
      nStereo: 0,
      nVel: 43.002021312714,
      oscAtk: 0,
      oscDcy: 10,
      oscFreq: 20,
      oscVel: 40.999999642372,
      oscWave: 0
  ],
  snare: [
      distAmt: 35.499998927116,
      eQFreq: 59.707651558903,
      eQGain: -40,
      level: -4.9999159382834,
      mix: 60.833332061768,
      modAmt: 23.346161411536,
      modMode: 2,
      modRate: 12662.482988632,
      modVel: 40.000000596046,
      nEnvAtk: 0,
      nEnvDcy: 439.39704746109,
      nEnvMod: 0,
      nFilFrq: 245.05603577429,
      nFilMod: 2,
      nFilQ: 148.37726231182,
      nStereo: 0,
      nVel: 40.999999642372,
      oscAtk: 0,
      oscDcy: 68.739970893796,
      oscFreq: 251.73534018926,
      oscVel: 33.000001311302,
      oscWave: 0
  ],
  clap: [
      distAmt: 18.334101140499,
      eQFreq: 981.49547151245,
      eQGain: 28.736724853516,
      level: -6.1622793557187,
      mix: 8.7251434326172,
      modAmt: -48,
      modMode: 2,
      modRate: 10995.78120095,
      modVel: 27.000001072884,
      nEnvAtk: 34.526091455159,
      nEnvDcy: 199.32752864136,
      nEnvMod: 2,
      nFilFrq: 3571.0693697945,
      nFilMod: 1,
      nFilQ: 0.37636863434079,
      nStereo: 0,
      nVel: 25,
      oscAtk: 0.44352287396344,
      oscDcy: 1402.7378979947,
      oscFreq: 2459.9589879903,
      oscVel: 34.999999403954,
      oscWave: 0
  ]
)).add;
)
