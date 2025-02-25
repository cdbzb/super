( //primes
{
	var list = LazyList.iterate(0, (_+1)).select(_.isPrime).take(12).asArray;
	Impulse.ar(SinOsc.ar(0.1).range(0.9,1))
	=> Decay.ar(_, 0.5)
	* SinOsc.ar(list.asArray.dq(inf).demand(Drand([1,0.1], inf)) * 100, 0) /6
	=> CombN.ar(_, list, list, 16)
	=> {|i| JPverb.ar(i)/8 + i}
	=> Splay.ar(_)
}.play
)
