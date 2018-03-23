s.boot
//Then these (For example) to play
~newDeck.value
~playMidi.value.play
~playMidiAppClock.value(speed:0.14).play
~newWhiteDeck.value
~playMidi.value (speed:0.2).play
~playMidiDurs.value (speed:0.2).play
// ~play.value(speed:0.1).play
~shuffle.value
~deck


s=r.value(speed: 0.1,pause:0.75); s.play;
s=r.value(speed: 0.11,pause:0); s.play;
s=r.value(speed: 0.17,pause:1.3); s.play;
s=r.value(speed: 0.25,pause:2); s.play;
s=r.value(speed: 0.12,pause:1); s.play;
s=r.value(speed: 0.12,pause:0.95); s.play; // the one I gave Mungo....
s=r.value(speed: 0.12,pause:); s.play; 


(
s=r.value(speed: 0.12,pause:4.95); s.play;
t=r.value(speed: 0.1,pause:8.75); t.play;
)

( //HERE FIRST

~newDeck = {~deck = Array.series(52,1)};
~newDeck.value;
~whitenotes = Array.new(52);
~scale=[1,3,5,6,8,10,12];
~cards = "/Volumes/tank/Cards/PNG/*.png".pathMatch;
~window = Window.new.front;

8.do({ arg i;
	~scale.do ({ arg degree,j;
		~whitenotes.add((i-2)*12+(degree+1));})});

~newWhiteDeck = {~deck = ~whitenotes};
~newWhiteDeck.value;


~shuffle = { |leftcount, rightcount|
	~left=Array.fill(26, { arg i; ~deck.at(i) });
	~right=Array.fill(26, { arg i; ~deck.at(i+26) });
	~whichHand=Array.series(52,1).scramble;
	~shuf=Array.new(52);
	52.do({|i| ~whichHand.at(i).even;
		if (~whichHand.at(i).even,
				{~shuf=~shuf.add(~left.removeAt(0))},
				{~shuf=~shuf.add(~right.removeAt(0))})
			});
			~deck=~shuf;
};

~durs = [0.25,0.33,0.5,0.66];

~play = { arg speed = 0.1;
	Routine ({
	~deck.do({|item,i|
		a=Synth(\marimba,[\freq, (item+38).midicps]);
		speed.wait;
	});})};
	MIDIClient.init;
	//m = MIDIOut(0, MIDIClient.destinations.at(0).uid);
	m=MIDIOut.newByName("IAC Driver","Bus 1");

~playMidi = { arg speed = 0.1;
	Routine ({
	~deck.do({|item,i|
	m.noteOn(16, item+46, 60);
	//(speed*(10+2.rand)/11).wait;
	speed.wait;
	});})};

~playMidiAppClock = { arg speed = 0.1, vel=40, vari=25;
	Routine ({
	~deck.do({|item,i|
		AppClock.sched(i*speed,{
	m.noteOn(16, item+46, 40+25.rand);
	c=Image.new(~cards.at(item-1));
	~window.drawFunc = {
		Pen.drawImage( Point(0, 0), c)};
	~window.refresh;
	// c.plot;
});
	});}).play};

~playMidiDurs = { arg speed = 0.1;
	Routine ({
	~deck.do({|item,i|
	m.noteOn(16, item+46, 57+6.rand);
	(speed*~durs.at(item % 4)).wait;
	});})};

( r= { |speed, pause, vel, vari |
	Routine.new({
		20.do({	
			rrand(8,58).do({
				~playMidiAppClock.value (speed:speed,vel:vel,vari:vari).play;
				wait ((speed*52)+pause);
				~shuffle.value});
		~newWhiteDeck.value;
		});
	});
});
)


//OLD

SynthDef(\marimba, {arg out=0, amp=0.1, t_trig=1, freq=100, rq=0.006;
	var env, signal;
	var rho, theta, b1, b2;
	b1 = 1.987 * 0.9889999999 * cos(0.09);
	b2 = 0.998057.neg;
	signal = SOS.ar(K2A.ar(t_trig), 0.3, 0.0, 0.0, b1, b2);
	signal = RHPF.ar(signal*0.8, freq, rq) + DelayC.ar(RHPF.ar(signal*0.9, freq*0.99999, rq*0.999), 0.02, 0.01223);
	signal = Decay2.ar(signal, 0.4, 0.3, signal);
	DetectSilence.ar(signal, 0.01, doneAction:2);
	Out.ar(out, signal*(amp*0.4)!2);
}).add;

