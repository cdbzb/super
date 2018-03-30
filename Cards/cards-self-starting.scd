s.boot;

(
~newDeck = {~deck = Array.series(52,1)};
~newDeck.value;
~whitenotes = Array.new(52);
~scale=[1,3,5,6,8,10,12];

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
	// c.plot;
});
	});}).play};

~playMidiAppClockOff = { arg speed = 0.1, vel=40, vari=25;
	Routine ({
	~deck.do({|item,i|
		AppClock.sched(i*speed,{
	m.noteOff(16, item+46, 40+25.rand);
	c=Image.new(~cards.at(item-1));
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

( q= { |speed, pause, vel, vari |
	Routine.new({
		20.do({	
			rrand(8,58).do({
				~playMidiAppClockOff.value (speed:speed,vel:vel,vari:vari).play;
				wait ((speed*52)+pause);
		});
	});
});

});
);

s=r.value(speed: 0.17,pause:1.3); 
t=q.value(speed: 0.17,pause:1.3);

(
TempoClock.default.sched(0, s);
TempoClock.default.sched(1, t); //the first number in parens here will be the note length in seconds
);

