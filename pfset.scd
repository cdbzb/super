(
	a=Pfset({
		~b=Bus.audio;
		c={CombN.ar(In.ar(~b),decaytime:\time.kr(5))
			* Env.cutoff(3).kr(2,gate:\gate.kr(1))}.play(s,1);
		~out = ~b
	},[
		degree:Pwhite(300,400,20)/15,
		dur:0.07
	].p,{
		~b.free;c.release
	});
	a.play
)
a.do(_.postln)
Pproto
c.set(\time,3)
c
s.plotTree
