(

~la = Buffer.read(s,"~/tank/super/samples/La_Mer_clean.aif".standardizePath)

().play
)

~len = 0.192;
~interval = {SinOsc.ar(0.1).range(0,7).floor* [1,1.25]=>_.lag2(0.1)}
~quad=FoaEncoderMatrix.newQuad;
( // a couple of these is nice!
{
	[
		BufRd.ar(2,b,Phasor.ar(1,BufRateScale.kr(b.bufnum)*~interval.midiratio,0,BufFrames.kr(b.bufnum)*~len)), 

		BufRd.ar(2,b,Phasor.ar(1,-1 *BufRateScale.kr(b.bufnum)*~interval.midiratio,0,BufFrames.kr(b.bufnum)*~len)) 
	].flat
	=> FoaEncode.ar(_,~quad)
	//=> FoaRTT.ar(_,Phasor.ar(1,0.1,-pi,pi)) //whaaaa???
	=> FoaRTT.ar(_,LFSaw.kr(0.1,0))
	=> Monitors.mbi(_)
}.play;
t =(freq:[1,2,3,5,6].df(\c),instrument:\stringyy).play
)
BufRd
s.meter
//1st chord C6
~mer={ BufRd.ar(2,~la,Phasor.ar(1,BufRateScale.kr(~la.bufnum),0,BufFrames.kr(~la.bufnum)*~len)) }
