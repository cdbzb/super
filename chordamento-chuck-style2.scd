s.quit;
s.meter;
s=Server.local;
s.reboot;
s.queryAllNodes;
(
	//SinOsc => reverb => dac;
	a = {   arg freq=400, gate=1, release=3 , pan = 0.5; var sig;
		freq = 	Lag.kr(freq,3);		 // =>
		sig = 	SinOsc.ar(freq,0,0.1);	 // =>
		sig = 	Pan2.ar(sig,pos: pan);	 // =>
		sig =   EnvGen.kr( Env.adsr(0.02, release), gate, doneAction: 2) * sig;
		sig =	Out.ar(4,sig);           // =>
		sig;
	}.asDefName;


	b = { var sig; ///// VERB BUS 4
		sig = In.ar(4,2);
			//
		sig = FreeVerb.ar(sig, mix: 0.5, room:7 );
			//	
		sig = Out.ar(0,sig);
		sig;
	}.asDefName;

z = { s.sync;
	r=Synth(b);
	b=Synth(a,[\freq, 400, \pan, -1]);
	c=Synth(a,[\freq, 300,\pan, 1]);

2.wait;
	b.set(\freq,500);
	c.set(\freq,900);
3.wait;
"/Users/michael/tank/super/external-test.scd".load;
	b.set(\freq, 600);
	c.set(\freq, 400);
3.wait;
	b.set(\freq, 400);
	c.set(\freq, 300);
3.wait;
	b.release;
	c.release;
4.wait;
	~wibble.free;
//r.free;
}.fork
);

{Pan2.ar(Gendy2.ar(a:MouseX.kr(0.0,1.0),c:MouseY.kr(0.0,1.0)))}.play

(
~wibble = {Pan2.ar(SinOsc.ar(Gendy2.kr(2,1,SinOsc.kr(0.1,0,0.49,0.51),SinOsc.kr(0.13,0,0.49,0.51), 3.4,3.5, SinOsc.kr(0.17,0,0.49,0.51), SinOsc.kr(0.19,0,0.49,0.51),10,10,mul:50, add:350), -1, 0.03), 0.0)}.play
)

{Gendy1.kr()}.plot(1)



//Pmono (a, \dur, 1, \freq, Pwhite(1,8)*150,).play;
//z=Pmono (a, \dur, 2, \freq, Pseq([250,350,900,1100,400,450],)).play;
