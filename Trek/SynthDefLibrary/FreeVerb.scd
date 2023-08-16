
	SynthDef(\FreeVerb,{
		In.ar(\in.kr(0))
		=> FreeVerb.ar(_,\mix.kr(1/3),\room.kr(1/2),\damp.kr(1/2))
		=> Out.ar(\out.kr(0),_)
	},variants:(long:[mix:1,room:1,damp:0.5],dry:[mix:0])
).add;

