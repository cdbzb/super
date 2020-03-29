
(
	{Saw.ar(\freq.kr(200,1),0.1)
	* Env.asr(0.5,1,\rel.kr(3)).kr(2,gate:\gate.kr(0))
	=>Pan2.ar(_,\pan.kr(0))
	=>Out.ar(\out.kr(0),_)
}
=> SynthDef(\sawz,_)
=> _.add;

{In.ar(\in.kr(9),2)
=>FreeVerb.ar(_,1,1)
=>Out.ar(\out.kr(0),_)
}
=>SynthDef(\verb,_)
=> _.add;

)
(
	a= Synths(\sawz,\freq,[200,300,340,360,480],\pan, 5.collect({rrand(-1,1)}) ,\gate,1!5);
	a.set(\pan,-1!5)
	a.release(2)
	a.set(\gate,-4!5)
	a.synths.do(_.set(\gate,-1))
	a.release(3)
	b=FX(a,\verb);
	b.set(\out,1)
	b.set(\mix,0.2)
	b.bus
	a.set(\gate,1);
	a.set(\freq,[250,350,450,500,750].scramble)
	a.set(\out,b.bus)
	a
	a.synths.do(_.set(\freq,rrand(800,400)))
	s.plotTree
)


Synth
