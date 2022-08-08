
(
{
	var freq =[200,600,  430,800,999 ];
	var phasor = Phasor.ar(0, freq / SampleRate.ir, 0, 1);
	var squeezeStretch =9;// LFTri.ar({ 0.1.rrand(3) }!3, 0, 5, 0); // from -5 to 5
	var outPhase = phasor ** (2 ** squeezeStretch);
	SinOsc.ar(0, outPhase * 2pi, 0.1) 	
	=> RLPF.ar(_,9000)
}.play;
)
