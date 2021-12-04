s.waitForBoot({
	SynthDef(\plong, {
		| out=0, amp=0.1, freq=#[ 200,900 ] |
		var sig1 =  [Convolution.ar(Saw.ar(freq*Demand.ar(Impulse.ar(1.0.rand),0,Dseq([1,2,4],inf)).lag(1),0.1), Dust.ar(10)=>FreeVerb.ar(_,0.6,0.8))
		,  Convolution.ar(Saw.ar(freq*Demand.ar(Impulse.ar(1.2.rand),0,Dseq([3,5,7],inf)).lag(1),0.1), Dust.ar(10)=>FreeVerb.ar(_,0.6,0.8))
		]	=> MoogFF.ar(_,2800);
		//var sig2 = HPF.ar(amp * Convolution.ar(Saw.ar(freq), Dust.ar(100)), 1000);
		Out.ar(out, sig1)
	}).add;
	
	s.sync;
	
	Synth(\plong);
});


(
{
	var seq=[5,4,3,2,3,1].dq;
	var durs=[1,1,1,1,1,1];
	var turn={|freq dur|
		[
			freq*[0,1,0].midicps,
			dur * [1,1,8]/10
		]
	};
	turn.(5,1)
}.value
)
