Buffer.record
b=Buffer.alloc(s,s.sampleRate*8);
c=Buffer.alloc(s,s.sampleRate*8);
{RecordBuf.ar(SoundIn.ar(),b.bufnum,loop:0)}.play;
b.plot
b.play
(
{
	//var sig = Onsets.kr(
	//	FFT(LocalBuf(512),PlayBuf.kr(1,b,BufRateScale.kr(b),loop:0)),
	//	threshold:0.8,
	//	relaxtime:1,
	//	floor:0.1,
	//);
	var detect,sig = PlayBuf.ar(1,b.bufnum);
	//sig=Coyote.kr(1,b.bufnum);
	//RecordBuf.ar(sig,c.bufnum)
                          detect = PinkNoise.ar(Decay.kr(Coyote.kr(sig,
                                                                       fastMul: 0.6,
                                                                       thresh: 0.05,
							       		minDur:0.2), 0.2));
	RecordBuf.ar(detect,c.bufnum)
}.play
)
c.plot
