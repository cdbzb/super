b=SynthDef(\zzaz,{|freq| var sig=SinOsc.ar(freq,0,\amp.kr(0.1));Out.ar(0,sig)}).add
a=Synth(\zzaz)
a.set(\freq,300)
a.getn(0,2,(_.postln))
[ 300.0, 0.10000000149012 ]
[ 300.0, 0.10000000149012 ]

a.asArchive
a.allControlNames
SynthDef(\zzaz).allControlNames
b.allControlNames
b.synthDesc
b.allControlNames
a.checkArgs
Synth.checkArgs
a.class
a={FaustKBVerb.ar(Saw.ar( LFBrownNoise1.ar(4).range(200,300),0.2 ),Saw.ar(300,0.1))}
a.play
Platform.userExtensionDir
b={FaustKBVerb.ar(a.value)}
b.play



