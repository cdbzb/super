(
var a=[1,3,5,7].df('c',tuning:\sept1)*.x(1..100).select(_<(s.sampleRate/2));
a=a.itemsHisto.keys.asArray.sort;
g=Group.new;
 {a[1..180].collect{|i|
	var x = i**1.6;
	SinOsc.ar(
		i,
		//0,
		LFBrownNoise2.kr(2)*pi*4.rand,
		FSinOsc.kr(Rand(0.01,0.1)).unipolar 
		/ x * 19
	)=>Pan4.ar(_,2.rand*2-2/2,2.rand*2-2/2).tanh
}=>Mix.ar(_)
* Env.asr(3,1,10).kr(2,gate:\gate.kr(1))
}.play(g,0) ;


b=[
	freq:Prand([1,3,5,7].df('c',tuning:\sept1),inf),
	out:Effect(FreeVerb.ar(_,1,1),inputChannels:4).bus.index+Pwhite(0,1),
	dur:Pwhite(0.1,2),
	].p;
{
	{
		var n=Array.fill(30,SinOsc.ar(200.gaussian(1000).abs+LFBrownNoise2.kr(1000).range(1,10),0,0.001))=>Mix.ar(_) *Env.perc(Rand(0,10),Rand(4,15)).kr(2,gate:\gate.kr(1));
		n=Array.fill(30,SinOsc.ar(400.pareto(1).abs+LFBrownNoise2.kr(1000).range(1,10),0,0.001))=>Mix.ar(_) *Env.perc(Rand(0,10),Rand(4,15)).kr(0,gate:\gate.kr(1));
		Env.cutoff(16).kr(2,gate:\gate.kr(1));


		//200.gaussian(1000)
		DynKlank.ar(`[[1,3,4,6,11,13,14,16].df('c',tuning:\sept),0.001,Array.rand(8,7,16)!2],n)
		=> Limiter.ar(_,0.01)
	}.play(g,4.rand);
	rrand(2.5,6.0);
}.sched(rrand(1,5.0),c=TempoClock.new())
)
g.release;c.clear;
c
TempoClock
g.free;
