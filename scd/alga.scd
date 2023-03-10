Alga.boot
(
a = AN( 
	{Saw.ar(\freq.kr(444))}
	//outsMapping: [\low, [0,1],\high,[2,3]]
 );
b=AN({FreeVerb.ar(\in.ar([0,0]),1,1)});
b.from(a);
b.play;
c=AN({Saw.ar(1)});
a.from(c,\freq,scale:[200,300])
d={ Env.triangle(5).kr(2,gate:1)};
)
a.play


c= AN({SinOsc.ar(5)});
a.mixFrom(c,\freq,scale:[-1,1,122,990]) 
a.disconnect(\freq, c)
a <| \freq
