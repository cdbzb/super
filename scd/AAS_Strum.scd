a=AAS_Strum.new;
(
a.setPlayMode(\strum);
[type:\strum, 
	switch:[\up,\down,\up,\1,\fu,\f,Prand([\fu,\1,\2,\3])].q(inf), 
	mode: [\strum,\pick].q(inf).stutter(10),
	lag:0.1, dur:1/4 + [0.01,-0.01].q(inf), legato:0.1 ].p
+= [type:\strum,legato:1.1,dur:4, midinote:[[1],[2,4,6],[3,5.5,12]].dm(\e,octave:4).q(inf)].p
<> (
	instance:a,
	out: Effect(
		Phaser2.ar(_,rate:0.1,fb:1.9,rq:1)
	).bus.index
) => _.play
)

