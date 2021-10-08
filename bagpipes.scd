(
{
{
		var a = Dseq([[1,3],[2,4],[ 3,6,9 ]],inf);
		var d = Demand.kr(Dust.kr(0.6),1,a);
		var b = Dseq(d,inf);
		var c = Demand.kr(Dust.kr(10),1,b);
		Impulse.ar(c*100+400)
		+ Impulse.ar(266)
		* 0.1 
	} ! 2 => Mix.ar(_) => Pan2.ar(_,SinOsc.ar(0.03))
}.play
)
