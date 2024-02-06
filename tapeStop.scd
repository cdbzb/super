
(
SynthDef(\tapeStop,{
	arg bus = 12;
	var in = In.ar(12,1 );
	var a =LocalBuf(s.sampleRate * 2,1);
	BufWr.ar(in, a, Sweep.ar(1, 44100), 1.0 );
	BufRd.ar(1,a,Sweep.ar(1, Env([44099,44099,10],[4,1],-1).kr(2)) - 0.1, loop:1.0,interpolation:4)
	=> Out.ar(0,  _)
}).add
)
[freq: "1 3 5 4 3 4 2 3".df(\c).q(inf),dur:0.3,out:12,instrument:\stringyy].pp

Synth(\tapeStop)
