
(
	var phrase= [nil,nil];
	phrase[0]= {
		var planetGettingCloser=[\rest, 1, 0, 1, 5, 9, [5, 9, 13], 9];
		var planetGettingDurs  =[0.75, Pseq([0.25],5),0.55,0.25];
		Pbind( 
			\instrument, \default,
			\note, Pseq(planetGettingCloser),
			\dur, Pseq( planetGettingDurs )
		)
	}.value;

	phrase[1]= {
		var becomingVisual=[\rest, 9,9,9,[6, 9, 14],9,6];
		var becomingVisDur=[0.5, 0.25,0.5,0.25,0.50, 0.25,0.25];
		Pbind( 
			\instrument, \default,
			\note, Pseq(becomingVisual),
			\dur, Pseq(becomingVisDur)
		)
	}.value;

	~lick={
		phrase[0].play;
		2.7.wait;
		phrase[1].play;
	}


)
(
~wibble = {Pan2.ar(SinOsc.ar(Gendy2.kr(2,1,SinOsc.kr(0.1,0,0.49,0.51),SinOsc.kr(0.13,0,0.49,0.51), 3.4,3.5, SinOsc.kr(0.17,0,0.49,0.51), SinOsc.kr(0.19,0,0.49,0.51),10,10,mul:50, add:350), -1, 0.03), 0.0)};
)

(
	var sine,verb;
	//SinOsc => reverb => dac;
	sine  = {   arg freq=400, gate=1, release=3 , pan = 0.5; var sig;
		freq = 	Lag.kr(freq,3);		 // =>
		sig = 	SinOsc.ar(freq,0,0.1);	 // =>
		sig = 	Pan2.ar(sig,pos: pan);	 // =>
		sig =   EnvGen.kr( Env.adsr(0.02, release), gate, doneAction: 2) * sig;
		sig =	Out.ar(4,sig);           // =>
		sig;
	}.asDefName;


	verb= { var sig; ///// VERB BUS 4
		sig = In.ar(4,2);
			//
		sig = FreeVerb.ar(sig, mix: 0.5, room:7 );
			//	
		sig = Out.ar(0,sig);
		sig;
	}.asDefName;

~z = Routine( { 
	r=Synth(verb);
	b=Synth(sine,[\freq, 400, \pan, -1]);
	c=Synth(sine,[\freq, 300,\pan, 1]);

2.wait;
	b.set(\freq,500);
	c.set(\freq,900);
3.wait;
	{ d=Synth(sine,[\freq,950,\pan,0]);
		4.wait;
		d.set(\freq, 150);
		3.wait;
		d.release;
	}.fork;

	b.set(\freq, 600);
	c.set(\freq, 400);
3.wait;
	b.set(\freq, 400);
	c.set(\freq, 300);
3.wait;
	b.release;
	c.release;
4.wait;
//r.free;
});

)

(
	{
		var wib;
		~z.reset;
		~lick.value;
		3.wait;
		wib=~wibble.play;
		0.1.wait;
		~z.play;
		13.wait;
		wib.free;
	}.fork
)

~z.reset;
~z.play;
AbstractPlayer
~z.stop;
~z.resume;
~z.post;


s.freeAll;
s.reboot;
