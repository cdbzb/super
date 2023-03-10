Scale
b=Tuning(5.collect(2 ** ( _/5 )))
a=Scale.new((0..4),5)
(
[
	effect:Effect({|i| 4.do{i= AllpassC.ar(i,0.2,0.2.rand+0.01*LFBrownNoise2.kr(0.09!4).range(0.5,1),8) };i},inputChannels:4).bus.index,
	out:Pwhite(0,3)+Pkey(\effect),
	scale:a,degree:Pwhite(-8,16,inf),dur:Pwhite(0.1,0.2,inf),legato:Prand([1,8,0.9,0.2],inf),].pp
)

(
[
	effect:Effect(
		{|i| 4.collect{i= AllpassC.ar(i,0.2,0.2.rand+0.01*LFBrownNoise2.kr(0.09!4).range(0.5,1),8) };i},inputChannels:4).bus.index,
		pan:Prand([-1,1],inf),
	out:Pwhite(0,3)+Pkey(\effect),
	scale:a,degree:Pwhite(-8,16,inf),dur:Pwhite(0.1,0.2,inf),legato:Prand([1,8,0.9,0.2],inf),].pp
)
[
	effect:Effect(
		{|i| 4.collect{i= AllpassC.ar(i,0.2,0.2.rand+0.01*LFBrownNoise2.kr(0.09!4).range(0.5,1),8) };i},inputChannels:4).bus.index,
		pan:Prand([-1,1],inf),
	out:Pwhite(0,3)+Pkey(\effect),
	scale:a,degree:Pwhite(-8,16,inf),dur:Pwhite(0.1,0.2,inf),legato:Prand([1,8,0.9,0.2],inf),].pp
Feedback.ar
OutFe
\feedback.help
InFeedback.ar
LocalIn.ar()
#

(
{
	var inputs;
	var bus= Bus.audio(s,4);
	var sig;
	var dry = 
	//Impulse.ar([10,11,12,13]/10);
	In.ar(bus.index,4);
	[scale:[Scale.new((0..4),pitchesPerOctave:5),Scale.major].q(inf),legato:Pwrand([ 0.05,1,5 ],[10,10,1]/21,inf),dur:0.3,out: bus.index+Pwhite(0,3),degree:Pwhite(-10,10),
	instrument:[\stringyy,\default].q(inf),
].p.play;
	inputs=LocalIn.ar(4)+dry;
	sig = 4.collect{|i| 
		CombN.ar(inputs[i],0.5,0.50.rand,1.0.rand+0.01)  
		+ CombN.ar(inputs[i],0.5,0.50.rand,2.0.rand+0.01)  
		+ CombN.ar(inputs[i],0.5,0.50.rand,rrand(0.01,1))  
		=> Mix.ar(_)
		=> AllpassN.ar(_,0.5,0.1*i,6.0.rand+0.01) 
		=> AllpassN.ar(_,0.5,0.1.rand+0.01,02.0.rand) 
		=> AllpassC.ar(_,0.5,0.1.rand+0.01+LFBrownNoise2.kr(1,mul:0.02).unipolar,6) 
	} * 0.1

	//+ DelayN.ar(dry,0.01,1/s.sampleRate) ;
	//+ dry;
	;
	LocalOut.ar(sig.at([1,2,3,0]));
	OffsetOut.ar(0,sig+(0.05*dry));

}.play
)
#

