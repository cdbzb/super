//s.reboot;
//s.queryAllNodes;
(
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
//r.free;
}.fork
)
