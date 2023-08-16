
	SynthDef(\verb_fade,{|in time| FreeVerb.ar(in, room:0.8, mix:0.8)*Line.kr(1,0,time)}).add;

