(
[note:Pwhite(0,10),instrument:\sawSynthSustain,rel:3,legato:Pwhite(1,4),
//out:EffectNarrow(AnalogPhaserMod.ar(_,SinOsc.kr(0.1),skew:-1,feedback:0.95,modulation:1,stages:26),out:1).bus.index
out:EffectNarrow(Resonator.ar(_,freq:SinOsc.kr(0.1).range(100,150),structure:LFBrownNoise1.kr(0.3).unipolar),out:1,).bus.index
].pp;

)
