~lfo = {SinOsc.ar(0.1,0,1)};
p=Patch(\sin,[{SinOsc.kr(5,0,1,300)}.play]);
p.play;
p.free;
s.boot;
q=Patch(\sin,());
q.play;

(
 p=Patch(\sin,
	 //{300 + SinOsc.kr(5,0,1)}
[f: 300,freq: {SinOsc.kr(5,0,1,300)}]
 );
 )
p.play;
InstrBrowser.new.gui;

(
 Instr(\sine,{arg freq;
	 SinOsc.ar(freq,0,0.1)});
 )

p= Patch(\sine, [ {SinOsc.kr(5,0,1,300)}]);
p  

p.free;

ProxySpace(s).push;
~out.play;
~out.source=Patch(\sin);
~out.set(\freq,200);
~lfo.source=({SinOsc.kr(5,0,10,300)});
~lfo.fadeTime = 5;
~lfo = 200;
~out.map(\freq,~freq);
~lfo.source={Line.kr(400,600,8)};
~out.get(\freq);



~freq.source=300.0;
~freq.source={arg freq=300, lfreq=5; SinOsc.kr(lfreq,0,100,freq)};
~freq=300;
~freq[1] = 200;
~freq[1];
~freq[2];

~freq.set(\freq,400);
~freq.set(\lfreq,2);
~lfo = {SinOsc.kr(5,0,20,400)};
~freq.map(\freq,~lfo);
~freq.map(\lfreq,(~ramp));
(
~ramp={Line.kr(2,100,10)};


~out.map(\freq,~freq);
~out.map(\freq,300);
~out.play;
~out.source={arg freq=400;SinOsc.ar(freq,0,0.1)};
~out[1].source={arg freq=600;SinOsc.ar(freq,0,0.1)};

~out[1] = { SinOsc.ar(500 * 1.2, 0, 0.1) };
~out[2] = { SinOsc.ar(400 * 1.2, 0, 0.1) };
~out[2]=nil;
