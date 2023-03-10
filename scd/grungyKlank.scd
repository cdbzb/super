(
{
	0.3* Dust.ar(100)+Crackle.ar(1) 
	=> DynKlank.ar(`[ 
		Array.fill(100,{100.exprand(4000)}).scramble.reshapeLike([ (0..49),(50..99) ]),
		( (100..1)/1000 ).scramble.reshapeLike([ (0..49),(50..99) ])
		,
		SinOsc.ar([0.077, 0.08 ],[2pi.rand,2pi.rand]).exprange(0.01,0.5)
	], _, freqscale:1.0, freqoffset:0.0, decayscale:1.0)
	=> LPF.ar(_,1500)
}.play
)
