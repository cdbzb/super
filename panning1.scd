

s.reboot

(
	x = [450,500,575];
	// rate is modulated 
	a = {Pan2.ar(SinOsc.ar((x.at(0)),0,0.2),SinOsc.kr(SinOsc.kr(0.03,1,0.1,0.5),0,1))};
	b = {Pan2.ar(SinOsc.ar((x.at(1)),0,0.2),SinOsc.kr(SinOsc.kr(0.04,1,0.2,0.2),0.4,1))};
	c = {Pan2.ar(SinOsc.ar((x.at(2)),0,0.2),SinOsc.kr(SinOsc.kr(0.05,1,0.1,0.3),0.8,1))};
a.play;
b.play;
c.play;
)


