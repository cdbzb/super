
a=Line.kr(0,1000,60).asStream
	a=Env.triangle(60).asStream
	a.next
	Synth(\default,[\freq,a*500])
	b=Routine({ loop{1000.rand.yield} })
	b.next
	Synth(\default,[\freq,b.next])
	~freq=fork{loop{1000.rand.yield}}
~dur=fork{loop{1.0.rand.yield}}
~freq={Env.triangle(60).asStream*1000};
b=4.collect{Bus.control(s,1)}
$a.ascii
fork{"Rottenbacher".do{|i| Synth(\default,[\freq,i.ascii*3]);0.1.wait}}
"Joseph".ascii
Pbind(*[midinote:Pseq("Joseph".ascii/2,inf),dur:Pseq("Rottenbacher".ascii,inf)/200.rand]).play
Char
	b.do{|i x| {SinOsc.kr(0.1*x+0.1)}.play(s,i.index)}
	
b.get
	(
	 Synth(\default,[\freq,(b[0].getSynchronous.value.squared)*500]);
	 Synth(\default,[\freq,(b[1].getSynchronous.value.squared)*700])
	)
	c=b.getSynchronous.value
	c
	Bus
Routine
~freq.next
	~freq.reset
~dur.next
	~notes=fork{~freq.reset;100.do{Synth(\default,[\freq,~freq.next]);~dur.next.wait}}

c=Routine{20.do {1000.rand.yield}}.asStream
	c.next
b.next
	
