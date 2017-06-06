
s.meter
s.reboot

(
	x = [450,500,575];
	// rate is modulated 
	a = {Pan2.ar(SinOsc.ar((x.at(0)),0,0.2),SinOsc.kr(SinOsc.kr(0.03,1,0.1,0.01),0,0.1))}.play;
	b = {Pan2.ar(SinOsc.ar((x.at(1)),0,0.2),SinOsc.kr(SinOsc.kr(0.04,1,0.2,0.02),0.4,0.1))}.play;
	c = {Pan2.ar(SinOsc.ar((x.at(2)),0,0.2),SinOsc.kr(SinOsc.kr(0.05,1,0.1,0.03),0.8,0.1))}.play;
)

a.free;
b.free;
c.free;

