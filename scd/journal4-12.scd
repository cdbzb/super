(
a={
	{
		var freq = Env.new({3.0.rand}!5,{3.0.rand}!4) .kr(0,1);
		var freq2 = Env.new({3.0.rand}!3,{3.0.rand}!2).kr(0,1);
		var width = Env.new({3.0.rand}!3,{3.0.rand}!2).kr(0,1);
		[Saw.ar(freq*800+70)=>MoogFF.ar(_,freq2*800+70,2),Formant.ar(freq*400+70,freq2*1200+300)=>EchoNone.ar(_),Pulse.ar(freq*300+222,width)].choose
		* Env.perc(9.0.rand,9.0.rand).kr(2,1)
		*0.01
		+(freq.cos*freq2.cos*0.5)
	}.play(s,2.rand)
};
{
	{a.value}!20;7
}.sched(1)
)
1.gaussian
{1.gaussian}.play
(
a={SinOsc.ar(\freq.kr([100,200,300,400]=>_.flat,0.001),0,0.1)=>Splay.ar(_)}.play(s,1);
//{a.set(\freq,[200, 300,400,500 ].gaussian(10.rand));00.01.rand}.sched(0.01)
{a.set(\freq,[200, 300,400,500 ].cauchy(20));0.001}.sched(0.01)

//{a.set(\freq,[200, 300,400,500 ].pareto);0.1.gaussian}.sched(0.01)
)
