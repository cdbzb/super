(//even Stringier - do a bunch for each sec
{
	Gendy4.ar(floor(Saw.kr(1/10)*6),  durdist: 1,  adparam: 1.0,  ddparam: 1.0,  minfreq: 640,  maxfreq: 660,  ampscale: 0.5,  durscale: 0.5,  initCPs: 12,  knum: nil,  a: 1.17,  c: 0.31,  mul: 1.0,  add: 0.0)
	*0.1
	=> BMoog.ar(_, LFBrownNoise1.kr(1).range(80,2000),  q: 0.4,  mode: 0.0,  saturation: 0.95,  mul: 1.0,  add: 0.0)
}.play(s,1)
)
(
SynthDef(\MoreStringy,{
	|offset=0|
	var freq=offset+[300,350, 400,480 ];
	{
		Gendy1.ar(
			ampdist: \ampd.kr(6),  durdist: \ddis.kr(8),  adparam: \adp.kr(0.02),  ddparam: \ddp.kr(1/3),  minfreq:freq,  maxfreq:freq+6,  ampscale: 0.5,  durscale: 0.5,  initCPs: 2,  knum: nil,  mul: 1,  add: 0)  
		}
		* Env.asr(0.1,1,7).kr(2,\gate.kr(1))
		=> Out.ar(0,_)
	},variants: nil
).play;
)
b=Bus.control(s,1);

a=Synth(\MoreStringy);
a.set(\ampd,1)
a.set(\ddis,2)
(
b=Bus.control(s,1);
a=Synth(\MoreStringy);
a.set(\ampd,3)
{Line.kr(8,1,15)}.play(s,b);
a.map(\ampd,b);
{5.wait;a.free}.fork
)

(

b=4.collect{Bus.control(s,1)};
a=4.collect{ Synth(\MoreStringy,[\ampd,2.rand*3]) };
//a.set(\ampd,3)
4.do{|i| {Line.kr(1400,300, rrand(14.0,16)) }.play(s,b[i])}; 
a.do({|i x| i.map(\offset,b[x])});
{12.wait;a.do(_.release);5.wait;b.do(_.free)}.fork
)
b.index+2
a[0].set(\offset,300)
