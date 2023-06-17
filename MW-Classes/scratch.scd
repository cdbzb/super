(

	a=Synth(\default,[\out,2])
	{|freq amp| Saw.ar(freq,amp)=>Pan4.ar(_,\x.kr(0),\y.kr(0))=>Out.ar(\out.kr(0),_)	}=>SynthDef(\test,_)=>_.add
	a=SynthBus(\test,[\amp,0.1,out:3,\freq,188,\gate:1]);
	a.controls

	a.x.source={SinOsc.ar(1)}
	a.x
	\test.controlNames
	SynthDescLib.at(\test)
	a.controlsPlus
	SynthBus.controlNames(\default)
	a=SynthBus(\default,[\amp,0.1,out:2,\freq,88,\gate:1]);
	a.out.source={2}
	a.controls
	a.freq.fadeTime=2
	a.freq.source={130}
	a.freq.source={99};
	a.amp.source={0.1};
	s.meter
	s.scope

	a.gate.source=1
	[\freq,1000,\amp,0.01].pairsDo{|k v|(Message(a,k)).value.source={v}}//.postln;k.postln}
	[\freq,100,\amp,0.1,\out:2].pairsDo{|k v|(Message(a,k)).value.source={v}}//.postln;k.postln}
	[\freq,1000,\amp,0.01].pairsDo{|k v| k.postln;v.postln}
	a.gate.source=1
	s.meter
)
a.release(5)
a.freq
Object
a.xxx(3)
