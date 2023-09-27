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
(
~moneymoney = {var chord = Bus(s,3);
{
	var one = [1, 2, 5].df(\c);
	var two = [1, 4, 5].df(\b,4);
	var seq = 3.collect{|i|[one[i], two[i]].dq(inf)};
	Demand.kr(Impulse.kr(1/4),0,seq.flat)
	* [0,1].dq(inf).demand([8,8,8,8,8,8,8,8]).midiratio.poll // not really right
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
].pp;
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
].ppm;
[
	freq: [11, 6, 4, 2, -7, -5, -4.5, -2.5].df(\c,6).q(inf),
	dur:1,
	amp: [1,0].stutter(16).q/10,
	// legato:[ 1,0.5 ].stutter(16).q,
	instrument: \sawSynthSustain,
	center: [-1,1].stutter(8).q(inf),
	out: Effect.bus({|i| 
		i = PitchShift.ar(i,[0,1].dq(inf).demand([8,8,8,8,8,8,8,8]).midiratio.poll); // not really right;
		CombN.ar(i, 0.4, 0.39,9) /2 + i * LFTri.ar(0.12).range(0,1)
		/3

	},inputChannels:2)
].ppm
})
