s.boot
s.reboot
s.meter

// synthdefs
(
SynthDef.new("mySine",{
	arg amp=0.1, freq=440, pan=0, amFreq=100, amAmp=0, fmFreq=100, fmAmp=0, busOut=0;
	var sig, aMod, fMod;
	aMod= SinOsc.ar(amFreq, 0, amAmp);
	fMod= SinOsc.ar(fmFreq, 0, fmAmp);
	sig = SinOsc.ar(freq+(fMod*1000) , 0, amp+aMod);
	Out.ar(busOut, sig);
}).send;
)
//synths
(
a = Synth(\mySine,[\busOut, 0, \fmFreq, 2000, \fmAmp, 0.1, \amAmp, 0, \amFreq, 1100]);

// c = { Out.ar(0,Pan2.ar(WhiteNoise.ar(0.01),0.1)) }.play
c = Synth(\mySine,[\busOut, 0,\amp,0.005, \freq, 2000, \fmFreq, 440, \fmAmp, 0.1, \amAmp, 0, \amFreq, 1110]);
d = Synth(\mySine,[\busOut, 1,\amp,0.005, \freq, 2000, \fmFreq, 440, \fmAmp, 0.1, \amAmp, 0, \amFreq, 1110]);

b = Synth(\mySine,[\busOut, 1, \fmFreq, 2012, \fmAmp, 0.1, \amAmp, 0.00, \amFreq, 1105]);
)
 
Pan

a.free;
b.free;
c.free;
d.free;
