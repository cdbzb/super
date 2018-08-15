
(
	~quietsin = { arg freq=300,mod=10,lfreq=5,gate=1; var env,sig; 
		sig = SinOsc.ar(_,0,0.1)<> SinOsc.kr(lfreq,0,mod,freq);
		env = EnvGen.kr(_,gate,doneAction:2)<>Env.adsr(0.1,0,1,5);
		sig*env;
	}
)

a=~quietsin.play;
a.release;
a=~quietsin;
b={FreeVerb.ar(a)}.play;
a.set(\gate,0);
a.set(\lfreq,10);
a.set(\freq,400);

{	 SinOsc.ar(freq,0,amp);
	freq=freq+SinOsc.kr(lfreq,0,range);
a=~quietsin(300).play;
a=~quietsin.value(300);
a.play
s.meter;


~sin = {SinOsc.ar(_,0,_)};
b=~sin.(300,SinOsc.kr(5,0,10,350));
b.play;
b={~sin.(300,0.1)};
b.play;

f= _+2;
f.(3);

Patch(\sin,(f:300)).play;
b=Patch(\sin,(f:300));
b.set(\freq,450);
Patch(\sin,[KrNumberEditor(0.01,\freq)]).gui;

a={FreeVerb.ar(b)};
a.play;
b
a.play;
b.set(\freq,500);
b;
InstrBrowser.new.gui;
