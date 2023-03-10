[out:Pwhite(0,3,inf),amp:Pwhite(0.001,0.011),dur:Prand([1,0.5,[ 0.1 ].q(14),2],inf),tuning:\pythagorean,octave:Pwhite(3,7,inf),chord:Prand([[0].q(4),[4].q(5),8],inf),degree:Pfunc({|e| e.out + e.chord}),legato:Pfunc({|i| 2/(i.dur)})].pp


(
~proc=OfflineProcess();

b=Buffer.alloc(s,160000,2,1);
~proc.putAr(\pvrec, { |input time recBuf=1 fftSize=2048 hop= 0.5 window=1|
	var in, chain, bufnum, soundBufnum;
	bufnum = LocalBuf.new(fftSize);
	//Line.kr(1, 1, BufDur.kr(soundBufnum), doneAction: 2);
	//in = PlayBuf.ar(1, soundBufnum, BufRateScale.kr(soundBufnum), loop: 0);
	// note the window type and overlaps... this is important for resynth parameters
	chain = FFT(bufnum, input, hop, window);
	chain = PV_RecordBuf(chain,recBuf, 0, 1, 0, hop, window);
	// no ouput ... simply save the analysis to recBuf
	DC.ar(0.1)
})
);
(
~laMer= "/Volumes/REAPER/REAPER recordings/05 Debussy_ La Mer, L 109 - 1. De L'Aube À Midi Sur La Mer render 001.wav" ;
)

~proc=OfflineProcess();
~proc.putAr(\verb,{|input| FreeVerb.ar(input,1,1)})
a=~proc.process(~laMer,5)
a.resultFile(\verb)
~proc.outputPath = "/tmp/"
