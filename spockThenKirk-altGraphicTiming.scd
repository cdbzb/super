( //Patterns
	~tune= { | synth=\default, amp=1, pan=0 |
	PmonoArtic(	 synth ,
		\dur, 	 Pseq([2/3,((1/3)+(1/2)),1/4,1/4],3) ++	(Pseq([2,1,1,2,2])/4),
		\degree, Pseq([8, 5, 6, 7],3)-1 ++ (Pseq([8,7,8,9,5])-1),
		\root, -3,
		\legato, Pseq([Pseq([1,0.5, 1,0.9],3), 	1,1,1,1,1]),
		\amp,amp,
		\pan,pan,

		\tempo, 85/60,
		\func,Pfunc({{t.string=~words.next}.defer}),
	).play
};
	~descant={ |synth=\default, amp=0.3 |
       Pbind(	\instrument, synth,
       		\degree, Pseq([\r, 5, 4, 3, 2, 4, 3, 2],1)-1+7, 
		\root, -3,
		\amp,amp
	).play 
};
	~offbeats={ |synth=\twotube|
	Pbind(	\instrument, synth,
		\dur, Pseq([1, 2, 2, 2], 1),
		\degree, 4,
		\root, -3,
		\octave, 4,
		\dummy, Pseq([\r, 1, 1, 1],1 )
		 ).play
       	};

	~off2={ |synth=\caw, amp=0.1|
		Pbind(	\instrument, synth,
		\dur, Pseq([1, 2, 2, 2], 1),
		\dummy, Pseq([\r, 1, 1, 1],1 ),
			\delay1,Pwhite(100,300),
			\delay2,Pwhite(100,300),
			\loss, Pwhite(0.99,0.9999),
			\len,Pwhite(3.1,8.0),
		       	\pan,Pwhite(-1,1.0),
			\amp,amp,
		       	\k,Pwhite(0,1.0) ).play};

//SynthDefs

	SynthDef(\caw ,{arg amp=0.01, delay1=100, delay2=50, k=0.0, loss=0.999,len=0.5, pan=0.0; 
	var source; 
	source= WhiteNoise.ar(0.4)*EnvGen.ar(Env([amp,amp,0,0],[(delay1+delay2)/SampleRate.ir,0.0,1.0]));
	Out.ar(0,Pan2.ar(TwoTube.ar(source,k,loss,delay1,delay2)*EnvGen.ar(Env([0,1,1,0],[0.001]++((len-0.001)*[0.4,0.6])),doneAction:2),pan)); 
	}).add; 

SynthDef(\aaa, { |out| 
	var vib = Vibrato.ar(\freq.kr(400,\flag.kr(0.1)),
		\rate.kr(6,0.1),
		\width.kr(0.005,0.1));
	var sig = Saw.ar(vib,\amp.kr(0.1));
	Out.ar(out,Pan2.ar(sig,\pan.kr(0),\amp.kr));
	}).add;

SynthDef(\pad, {|freq=300 gate=1|
	var sig = Splay.ar({ Saw.ar(freq+rrand(-8,8),0.1)}!8);  
	var env = EnvGen.kr(Env.asr(0.05,\vel.kr(0.5),1,4),gate);
	Out.ar(0,sig*env*\amp.kr(0.5))
	}).add;

SynthDef(\twotube,{arg delay1=1000, delay2=500, k=0.0, loss=0.999, dur=0.5, pan=0.0; 
	var source; 
	source= ModSin(1000*LFNoise1.kr(1)+200).distort;
	Out.ar(0,Pan2.ar(TwoTube.ar(source,k,loss,delay1,delay2)*EnvGen.ar(Env([0,1,1,0],[0.001]++((dur-0.001)*[0.4,0.6])),doneAction:2),pan, level: 0.1)); 
	}).add;

	SynthDef(\vowel, {|freq = 420|
	Out.ar([0,1],
		Formants.ar(Vibrato.kr(freq.lag(0.1)), Vowel(\a).addControls(lag: 1)) * 0.1 * \amp.kr(1)
    ) }).add;
)
(//window
	~windowSetup = { |height=500, width=500, fontsize=64|
		w = Window.new(bounds: Rect(0,0,500,500), border:true).front; // can't be manually closed
		//w.view.background=Color.white;
		t=StaticText(w,w.bounds);
		t.string=" ";
		t.align=\center;
		t.font=Font("Monaco",96);
		w.front;
		CmdPeriod.doOnce({ w.close });
		//w.drawFunc = { t.string=~words.next;};
		~words.reset;
//c=Image.new(~cards.at(item-1));
//~window.drawFunc = {
//Pen.drawImage( Point(0, 0), c)};
	};
)
(
	~windowSetup.();
	a=Image.open("/Users/michael/tank/super/Spock.png");
	w.drawFunc_({
		Pen.drawImage( Point(200,200), a, operation: 'sourceOver', opacity:1;
	)});
	w.refresh;
	w.front;
	~words.reset;

	{
	~b1=Buffer.read(s,"/Users/michael/tank/super/Trek-samples/kirk.wav");
	s.recChannels_(2);
	s.recHeaderFormat_("wav");
	s.recSampleFormat_("float");
	s.prepareForRecord("/tmp/Spock.wav");
	s.sync;
	//s.record;
	~tune.(\vowel, 0.18);
	~descant.(\pad,0.2);
	~offbeats.(\twotube);
	~offbeats.(\default);
	~off2.(\caw,[\amp,0.04]);

	3.6.wait;
	~b1.play;
	//{t.string="(kirk)";
	//w.refresh}.defer;
	//s.stopRecording;
	9.wait;
	{w.close}.defer
	}.fork
)

ss.reboot;

(
	~words=Pseq([
		" ",
		"Some-",
		"one"  ,
		"or"   ,
		"or"   ,
		"some-",
		"thing",
		"is",
		"is",
		"is",
		"try-",
		"ing",
		"to a-",
		"to a-",
		"tract",
		"our",
		"attention!",
		"attention!",
		"attention!",
		"(kirk)"
	],inf).asStream
)
s.reboot;
