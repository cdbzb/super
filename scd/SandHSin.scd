(
{
	var freq, trig, reset, seq1;
	trig = Impulse.kr(20);
	seq1 = SinOsc.ar(2.1, mul: 200*(1+LFNoise1.kr(1)), add: 700); 
	freq = Demand.kr(trig, 0, seq1);
	CombN.ar( SinOsc.ar(freq + [0,1.7]).cubed.cubed.cubed * 0.1 , 1, 0.2, 2).distort;
}.play;
)




