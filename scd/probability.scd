
a=Routine{loop{1.gaussian(2).yield}}
b=Routine{loop{300.pareto(10).yield}}
a=Routine{loop{300.logistic(100).yield}}
a=Routine{loop{300.weibull(100).yield}}
a.next
[freq:a+50*5].p.trace.play
(note:1).play
{SinOsc.ar( b.nextN( 90),0,0.05)=>Mix.ar(_)}.play(s,1)
{SinOsc.ar( a.nextN( 90),0,0.05)=>Mix.ar(_)}.play(s,1)
	b.nextN(100).sort.plot
	(1..10).cauchy.plot
	(
		a=Routine{loop{300.logistic(200).yield}};
		[freq:(a ? 300),dur:a/300,type:\reedy].pp

	)
	(

		a=Routine{loop{300.pareto(10).yield}};
		[note:(a/20).floor,dur:0.1].pp
	)

Pbind

	b=Bus.control(s,100);
	(
	y={ 
		//var freqs = (1..100);
		SinOsc.ar(\freq.kr((1..60)*299,2),0,\amp.kr((0.01 ! 60),0.5))
		=>Splay.ar(_)
	}.play
	)
	y.map(\amp,b.index)
	fork{10.do{(y.set(\amp,Harmonics.new(100).formant(10.rand,20.rand);0.5.wait))}}
	[type:\set,id:y.nodeID,args:[\freq],note:[1,2,3].q(inf),freq:Pfunc({|e|[e.note * (1..60) * 240]})].p.trace.play;
	(
		fork{
			loop{
				y.set(\freq,Harmonics.new(60).ramp(1,1)*900);
				3.0.rand.wait;
				y.set(\amp,Array.fill(100,{|i|0.1/(i+1)}));
				3.0.rand.wait;
				y.set(\amp, Array.fill(100,{|i|(i.even).if{0.1/(i+1)}{0}}));
				3.0.rand.wait;
			}
		}
	)
	y.set(\amp, Array.fill(100,{|i|(i.even).if{0.1/((i+1)**2)}{0}}))
	b.set(Harmonics.new(100).formant(5,10))
	b.set(0.001!100)
	b.set(Harmonics(100).ramp(0.01,-0.0001))

{Array.fill(60,{500.rand.pareto(4)})=>{|i|SinOsc.ar(i,0,4*i.reciprocal*Env.perc(2.5, 14.rand).kr(2))}=>Mix.ar(_)}.play(s,1)

(//space engime
	fork{
		50.do{
			var a={Array.fill(30,{1900.pareto(3)})=>{|j| var i = \freq.kr(j,8);FSinOsc.ar(i,0,24*i.reciprocal**2*Env.linen(2.5,10, 24.rand).kr(2))}=>Mix.ar(_)}.play(s,2.rand);
			fork{10.do{2.wait;a.set(\freq, Array.fill(30,{500.pareto(2)}))}};
			10.wait;
		}
	}
)
(
[
	dur:0.2,
	end: Effect.lfo({ Env.perc(0,10).kr(2) }) ,
	amp: Effect.lfo({LFBrownNoise2.kr(1)}),
	pan: Effect.lfo({LFBrownNoise2.kr(1)}),
//	freq: Effect.lfo({ Env.linen(3,2,8,400).kr(2) }),
//note:Pfunc({b.getSynchronous}),
note:Env.linen(2,3,4,5);
//	amp:Pfunc({|e|e.lfo.asMap}),
].p.trace.play
)
	b=Bus.new(\control,1,1)
	{SinOsc.kr(0.4).unipolar}.play(s,b)
	b.get
	b.getSynchronous

	Bus
	a.synth.isRunning
a.bus.scope
a=Bus.control
a.index
