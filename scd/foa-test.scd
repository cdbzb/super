FoaEncode

(
{#w,x,y,z = PinkNoise.ar(0.1)=>PanB.ar(_,SinOsc.ar(1.rand)*pi,SinOsc.ar(0.11.rand,1)*pi);DecodeB2.ar(2,w,x,y)}.play;
{#w,x,y,z =Impulse.ar(LFBrownNoise2.kr(0.3).unipolar+30.rand)*1=>PanB.ar(_,SinOsc.ar(0.1)*pi,SinOsc.ar(0.11,1)*pi);DecodeB2.ar(2,w,x,y)}.play;
{#w,x,y,z =BrownNoise.ar(0.01)=>PanB.ar(_,SinOsc.ar(0.01)*pi,SinOsc.ar(0.11,1)*pi);DecodeB2.ar(2,w,x,y)}.play;
( midinote:[1,3,5,7].dm,out:[0,1],instrument:\noizykey4,dur:100 ).play
)
"/Users/michael/tank/super/SynthDefLibrary/*".pathMatch.do (_.load)"

a=FoaEncoderKernel.newUHJ(2048,s,44100) 

