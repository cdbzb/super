(
	a=PF();
	//do a few of these
	[type:\midi,midiout:a.controller.midi,midinote:Pbrown(1.0,12.0,Pwhite(1,2,inf),inf)+60+rrand(-10,10)].pp
)


[note:1,dev:Pfunc({1.postln})].pp
Event
Line
(
	b.isNil.if {b=Bus.control}{b};
	c={| bus start end sec| {Line.kr(start,end,sec)=>ReplaceOut.kr(bus.index,_)}};
	d={Saw.ar(b.kr,0.1* Env.triangle(10).kr(2))}.play;
	e=c.value(b,200,100,10).play([0,1].choose);
)

(
	~sink={|synth|
		var start;
		fork{
			b = Bus.control;
			synth.get(\freq,{|i|
				start=i;
				//{Line.kr(start,200,8)=>Out.kr(b,_)}.play;//=>_.play
				{Line.kr(0,200,8)}.play(s,b);//=>_.play
			});
			s.sync;
				synth.map(\freq,b);
		}
		
	}
)

(
	a={|freq=200| Saw.ar(freq,0.1)* Env.triangle(18).kr(2,gate:1)}.play;
	~sink.(a)
)

