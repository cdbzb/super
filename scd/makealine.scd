(
	~ttt = {arg freq=400, amp=0.1, cutoff=500, q=1, pan; var sig;
		sig = Saw.ar(freq, amp);
		sig = RLPF.ar(sig, cutoff, q);
		Pan2.ar(sig, pan);
		};
)

(
	Instr(\sin, {arg f, freq=f, amp=0.1;
		SinOsc.ar(freq,0,amp)
	});
)
Instr(\sin);


a= Instr(\sin).head(s, (freq:500));
b=Patch(\sin,[300]).play;

b.set(\freq,700);

a= {arg freq=440; SinOsc.ar(freq,0,0.1)}.play
a.set(\freq,300);
a.setRates(\freq,500);


a=Instr(\sin).head(s);
a.play;

Instr.dir;
Instr(\sin).gui;
InstrBrowser.new.gui;
p=Patch(\sin);
p.play;
p.set(\freq, 366);
Spec
ControlSpec;


p.free;
p.play;
p.freq = 577;
p.set(\freq, 666);
p=Instr(\sin);

p.play;
p.set(\freq,777);
p;
a=NodeProxy(s);
a.source=~ttt;
a.play;

b=NodeProxy(s, \control);
b.source={arg freq; SinOsc.kr(freq, mul: 10, add: 300)};
b.play;

a.xmap(\freq, b, 3);
a.fadeTime=0;
a.setRates(\freq, 300,5 );
a.set(\freq,200);
a.setRates(\freq, 10;

b.set(\freq,5);
b.source={Line.kr(100,500,6)};
s.queryAllNodes;

