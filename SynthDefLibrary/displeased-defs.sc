(
SynthDef(\trem2,{| rate=12 freq=499 scale=1 gate=1 out=0| //		{{{3
	//var force =LFBrownNoise1.kr(1).range(-0.20,8.8);
	var force=0.9;
	//var scale=SinOsc.ar(0.01).range(0.2,1.2);
	//var vel=1;
	var vel=SinOsc.kr(rate+LFBrownNoise1.kr(1)).range(0,1);//rate
	//var pos=0.2;
	var pos = LFBrownNoise1.kr(2).range(0.3,0.2);
	var env = Env.asr(0,1,\rel.kr(0.5)).kr(2,gate:gate);
	var sig = DWGBowed.ar(
		freq: freq,// + LFBrownNoise0.kr(2).range(0,10),  
		velb: vel,  
		force: force,  
		gate: 1,  
		pos: pos,  
		release: 0.5,  
		c1: 5,  //inverse of DC decaytime
		c3: 30, // hi freq decay 
		//impZ: 0.55*LFBrownNoise1.kr(0.5).range(0.02,1),  
		fB: 2 //inharmonicity
	); 
	sig= DWGSoundBoard.ar(sig,  c1: 20,  c3: 100,  mix: 0.8,  d1: 199*scale,  d2: 211*scale,  d3: 223*scale,  d4: 227*scale,  d5: 229*scale,  d6: 233*scale,  d7: 239*scale,  d8: 241*scale);
	sig=HPF.ar(sig,300)*0.05;
	sig=sig*\amp.kr(0.1)*10;
	//sig =PlateReverb.ar(sig,mix:0.8);
	Out.ar(out, Splay.ar(sig*env));
}
	).add.tag(\strings,\physical); 
)
