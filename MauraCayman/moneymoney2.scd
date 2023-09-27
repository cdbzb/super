(
~moneymoney = {|tempo=1|
	fork{ 
	var chord = Bus(s,3);
	var r = Recorder.new(s);
	r.recHeaderFormat = "wav";
	r.recSampleFormat = "int24";
	r.filePrefix = "MoneyChanging_";
	// r.record;
	0.05.wait;
	( SynthDef( \percTriangle,{
		var freqs= [4067,4039,3509,3250,2845,2509,1539,1517,1388.6,1349.6,892.5,724.6252,152];
		// SinOsc.ar( freqs,0,0.01 )
		Klank.ar(
			`[
				freqs.sort* 1.5,
				(freqs.size..1).reciprocal,
				(1..freqs.size) /3  
			],Env.perc(0,0.01).kr(0,gate:\trig.tr) * WhiteNoise.ar(0.01))
			* \amp.kr(0.1)
			=> Pan2.ar(_,\pan.kr(-1))
			=> Out.ar(\out.kr(0),_)
		}).add
	);
	{
		var seq = [
			[1, 2, 5].df(\c),
			[3, 5, 11].df(\a, 4),
			[5, 11, 13].df(\f, 4),
			[1, 3, 5].df(\d),
			[3, 5, 1].df(\b,4),
			[5, 11, 3].df(\g,4),
			[1, 3, -5].df(\e,\minor,4),
			[5, 11, 13].df(\f,4),
		].flop.collect(_.dq(4));
		Demand.kr(Impulse.kr(1/4),0,seq.flat)
		// * [0,1].dq(inf).demand([8,8,8,8,8,8,8,8]).midiratio.poll // not really right
		=> Out.kr(chord,_)
	}.play;
	{
		In.kr(chord,3).lag2(2)
		=> Saw.ar(_,0.05)
		* Env.perc(0.005, 0.3).kr(0,Impulse.kr(8))
	}.play;
	l =  \bd_808  ; h=[ \visual_pad,\sn_808 ];
	// s.plotTree;
	[
		amp: [0.1,0.03],
		instrument: [l,l,h,l, h,\r,\r,h].q(inf),
		dur: 1/8
	].p.findur(128).play;
	[
		amp: [1,1,0,1,0,0,0,0].q(inf) /60,
		instrument: \harp,
		// freq: [1, -7].df(\c).stutter(32).q(inf),
		dur: 1/8
	];//.pp;
	[
		instrument: \percTriangle,
		t_trig:1,
		dur:1/6,
		pan: Pwhite(-1,1,inf)
	].pm.findur(128).play;
	[
		freq: [11, 6, 4, 2, -7, -5, -4.5, -2.5].df(\c,6).q(inf),
		dur:1,
		amp: [1,0].stutter(16).q/10,
		// legato:[ 1,0.5 ].stutter(16).q,
		instrument: \sawSynthSustain,
		center: [-1,1].stutter(8).q(inf),
		out: Effect.bus({|i| 
			i = PitchShift.ar(i,[0,1, 2, 3, 4].dq(inf).demand(8!32).midiratio.poll); // not really right;
			CombN.ar(i, 0.4, 0.39,9) /2 + i * LFTri.ar(0.12).range(0,1)
			/3

		},inputChannels:2)
	];//.ppm
	[
		freq: [
			// 11, 6, 4, 2, 1.5, -6, -3, -1.5,  11, 6, 4, 7, 6, 4.5, 2, 1,
			11, 6, 3, 7,
			6, 4.5, 2, 5,
			4, 12, 6, 13, 
			14.5, 12, 6, 11.5,
			12.5,7, 5.5,11.5,
			12, 7, 5, 11.5, 
			13, 7, 5, 12.5,
			14, 11, 6, 7

		].df(\c)
		=> _.q(4),
		dur:1,
		// amp: [1,0].stutter(16).q/10,
		instrument: \sawSynthSustain,
		center: [-1,1].stutter(8).q(inf),
		out: Effect.bus({|i| 
			CombN.ar(i, 0.4, 0.39,9) /2 + i * LFTri.ar(0.11).range(0.1,1)
			/4

		},inputChannels:2)
	].ppm;
	132.wait;
	r.stopRecording
}})

