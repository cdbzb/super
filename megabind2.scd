
(
MegaBind(
	pitches:[
		[14, 13, \r, \r, \r, \r, \r, 13, 13, 12, \r, \r, \r, \r, \r, 11, ],
		[14, 13, 11,  5,  3,  5,  11,  13, 13, 12, 7,  5,  4,  5,  7,  11]
	].df(\a),
	durs:1!16/1.7,
	bind:[
		wave: [Saw,Pulse],
		amp: [[2,1,0.5,1.5,1,0.5,0.5],0.1!16],
		attack: [ {|i|Env.perc(0.01,5).kr(0,gate:i.dur.tduty * i.freq.asDemandGate.dq.demand(i.dur))},{ 1 } ],
		lag:[0,0.1]
	],
	inner:{|i|
		i.wave.ar(
			i.freqSeq
			.lag(i.lag)
			+ SinOsc.kr(rrand([5,6],7.0),0,3)
		) 
		* Env.asr(0,1,3).kr(0,gate:i.freqGate)
		//* [0.001,1] *
		* i.amp.spanRests(i.freq).dq.demand(i.dur)
		* i.attack.(i)
	},
	fx:{|i v| 
		TwoTube.ar(i,0.8,0.97,999,567)
		=> Phaser2.ar(_,SinOsc.ar(0.1),rate:0.1,skew:1,modulation:0.9,feedback:0.9,stages:16)
		=> Splay.ar(_) * 0.5
		=> HNF.ar(_,SinOsc.ar(0.2).range(400,4000),0.5)
		=> SafetyLimiter.ar(_)
		* Env.asr(1,1,12).kr(2,gate: 1)
}
).play
)

// current 5 speak layout 1 2 F 4 3 S 5 R

(
{
	[Dust.ar(15)*4,
		Gendy1.arWidth(
			freq:LFSaw.kr(0.1).range(800,100)/2,
			width:1.14
		)
	].choose
	* 0.1 
	=> { |i| PanAz.ar(
		5,  
		in:i,  
		pos: LFSaw.kr(0.1).bipolar,  
		vel: 1.0,  width: 2.0,  orientation: 0.5
	)} 
	=> {|i| i[[0,1,4,2,3]]}
	=> EchoNone.ar(_,1.2,1.2,8)
}.play
)

(
4.do{
	{ Saw(300.rrand(800)) * (Dust(0.5 * 4.rand,pi.rand).decay(0.1) )
	*5
	=> _.moogFF(SinOsc([3, 5 ]).unipolar*800 + Env.triangle(8,4000).kr(),3)
	=> _.freeVerb(1,1) 
	* Env.linen(5,5,5).kr(0) =>| DetectSilence.ar(_,doneAction:2) }.play; 
}
)
