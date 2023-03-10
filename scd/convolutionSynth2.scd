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
( //scotland
	3.do{
		{
			var freq=[1,3,5,4,2].df(\a).dq(inf);
			freq = Demand.ar(Dust.ar(10.rand)-0.01,0,freq);
			freq = freq * 6.rand;
			SinOsc.ar(freq,0,1)
			=> SinOsc.ar(freq+SinOsc.ar(3),_,1)
			=> SinOsc.ar(freq+1,_,SinOsc.ar(LFNoise1.kr(1)).range(1,10))
			=> SinOsc.ar(freq*2,_,0.1)
			=> AllpassC.ar(_,1,0.2,5)
			=> AllpassC.ar(_,1,0.8,5)
		}.play
	}
)
(
 //dirty scotland
		{
			var key = KeyState.kr(keycode: 38,  minval: 0,  maxval: 1,  lag: 0.2);
			var freq=[1,3,5,4,2].df(\a).dq(inf);
			freq = Demand.ar(Dust.ar(Rand(2,10)!3)-0.01,0,freq);
			freq = freq * ( Rand(0,6)!3 );
			SinOsc.ar(freq,0,1)
			=> SinOsc.ar(freq+SinOsc.ar(3),_,1)
			=> AllpassC.ar(_,1,0.2,5)
			=> SinOsc.ar(freq+1,_,SinOsc.ar(LFNoise1.kr(1)).range(1,5)!3)
			=> AllpassC.ar(_,1,0.8,5)
			=> SinOsc.ar(freq*2,_,0.1)
			=>Pan2.ar(_,[-1,0,1])
			//* Env.linen(0,10,1).kr(0,gate:key-0.01)
		}.play
)
