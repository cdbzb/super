(
//[Bridge]

Song(\visual,[]).current;

["/*SULU:*/ The reading's growing stronger, Captain.","r"].addLine;
["Coming from a star system directly ahead.","r"].addLine;
["It does not seem to even exist, and yet it's affecting all my channels.","r"].addLine;
["/*KIRK:*/ Well?","r"].addLine;
["/*KIRK:*/ Someone or something has succeeded.","r"].addLine;
["Our distress signal relays have been activated.","r"].addLine;
["We've been given a direction to follow, but how? What's causing it?","r"].addLine;
["Not even a Vulcan can know the unknown, Captain.","r"].addLine;
["We are hundreds of light years past where any Earth ship has ever explored.","r"].addLine;
["/*SULU:*/ Planet dead ahead, Captain. Becoming visual.","r"].addLine;
[" (There's a yellow and gold planet on the viewscreen.) ","r" ].addLine;
P(\sfx,start:\yellow, music:{
	var wibble = {Pan2.ar(SinOsc.ar(Gendy2.kr(2,1,SinOsc.kr(0.1,0,0.49,0.51),SinOsc.kr(0.13,0,0.49,0.51), 3.4,3.5, SinOsc.kr(0.17,0,0.49,0.51), SinOsc.kr(0.19,0,0.49,0.51),10,10,mul:50, add:350), -1, 0.03), 0.0)};
	var sine,verb,verbBus=Bus.audio;

	SynthDef(\visual_sine,{   arg freq=400, gate=1, release=3 , pan = 0.5; var sig;
		freq =	 Lag.kr(freq,3);		 // =>
		sig =	 SinOsc.ar(freq,0,0.1);	 // =>
		sig =	 Pan2.ar(sig,pos: pan);	 // =>
		sig =   EnvGen.kr( Env.adsr(0.02, release), gate, doneAction: 2) * sig;
		sig =	Out.ar(verbBus.index,sig);// =>
		sig;
	}).add;


	SynthDef(\visual_verb,{
		var sig = In.ar(verbBus.index,2);
		//
		sig = FreeVerb.ar(sig, mix: 0.5, room:7 );
		//	
		sig = Out.ar(0,sig);
		sig;
	}).add;

	Routine( { 
		wibble.play.dur(13);
		//0.2.wait;
		r=Synth(\visual_verb);
		b=Synth(\visual_sine,[\freq, 400, \pan, -1]);
		c=Synth(\visual_sine,[\freq, 300,\pan, 1]);

		2.wait;
		b.set(\freq,500);
		c.set(\freq,900);
		3.wait;
		{ 
			d=Synth(\visual_sine,[\freq,950,\pan,0]);
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
	}).play;

}
)
)
