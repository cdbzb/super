( //makeadrone
	a=5.collect
	{
		{ Env.asr(2,1,9).kr(2,gate:\gate.kr(1))* Saw.ar(\freq.kr(300,1)*[0.3,0.5,0.7].choose+LFBrownNoise1.kr(3).range(0,20),0.05)=>Out.ar(\out.kr(2.rand),_)}.play
	};

 // and waggle it
	{
		{ a.do(_.set(\out,2.rand)) }.sched((20.0!80).rand);
		{ a.do(_.set(\freq,200.rand+200)) }.sched((20.0!8).rand);
	}.sched([0,15]);
	{a.do(_.release)}.sched(30)
)

////bunch of these 
{Item(\wibbbleComb).playbuf(rate:[1,0.6,1,10].choose)=>CombC.ar(_,1,LFBrownNoise1.kr(1).range(0.05,0.3),decaytime:[3,4,5,15].choose)=>Pan2.ar(_,LFBrownNoise1.kr(1).range(-1,1))}.play

(
	{
	{Item(\whibb).playbufMon(rrand(0.2,1.2))=>(Gain.ar(_,0.5)++PlateReverb.ar(_,0.8,0.8))=>MoogVCF.ar(_,rrand(800,4000)*SinOsc.kr(0.1).exprange(0.1,1),0.5)=>Mix.ar(_)=>Pan2.ar(_,rrand(-1,1))}.play;
}.sched((40!6).rand++0)
)

