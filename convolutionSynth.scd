s.waitForBoot({
	SynthDef(\plong, {
		| out=0, amp=0.1, freq=#[ 200,900 ] |
		var sig1 =  [Convolution.ar(Saw.ar(freq*Demand.ar(Impulse.ar(1),0,Dseq([1,2,4],inf)).lag(0.1),0.1), Dust.ar(100)=>FreeVerb.ar(_,0.6,0.8))
		,  Convolution.ar(Saw.ar(freq*Demand.ar(Impulse.ar(1.2),0,Dseq([3,5,7],inf)).lag(0.1),0.1), Dust.ar(100)=>FreeVerb.ar(_,0.6,0.8))
		]	=> MoogFF.ar(_,2800);
		//var sig2 = HPF.ar(amp * Convolution.ar(Saw.ar(freq), Dust.ar(100)), 1000);
		Out.ar(out, sig1)
	}).add;
	
	s.sync;
	
	Synth(\plong);
});
