(
//[Bridge]

Song(\visual,[]).current;

["/*SULU:*/ The reading's growing stronger, Captain.","r"].addLine;
["Coming from a star system directly ahead.","r"].addLine;
["/*UHURA:*/ It's not a signal, sir.","r"].addLine;
["It does not seem to even exist, and yet",".r"].addLine;
["it's affecting all my channels.","r"].addLine;
["/*KIRK:*/ Well?","r"].addLine;
["/*SPOCK:*/ Someone or something is attempting to attract our attention.","r"].addLine;
P(\comp,start:\attempting,music: {
	//Patterns
	var tune= { | synth=\default, amp=1, pan=0 |
		PmonoArtic(	 synth ,
			\dur,	  Pseq([2/3,((1/3)+(1/2)),1/4,1/4],3) ++	(Pseq([2,1,1,2,2])/4),
			\degree, Pseq([8, 5, 6, 7],3)-1 ++ (Pseq([8,7,8,9,5])-1),
			\root, -3,
			\legato, Pseq([Pseq([1,0.5, 1,0.9],3),	 1,1,1,1,1]),
			\amp,amp,
			\pan,pan,

			\tempo, 85/60,
		).play
	};
	var descant={ |synth=\default, amp=0.3 |
		Pbind(	\instrument, synth,
			\degree, Pseq([\r, 5, 4, 3, 2, 4, 3, 2],1)-1+7, 
			\root, -3,
			\amp,amp
		).play 
	};
	var offbeats={ |synth=\visual_twotube|
		Pbind(	\instrument, synth,
			\dur, Pseq([1, 2, 2, 2], 1),
			\degree, 4,
			\root, -3,
			\octave, 4,
			\dummy, Pseq([\r, 1, 1, 1],1 )
		).play
	};

	var off2={ |synth=\visual_caw, amp=0.1|
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

			tune.(\visual_vowel, 0.18);
			descant.(\visual_pad,0.2);
			offbeats.(\visual_twotube);
			offbeats.(\default);
			off2.(\visual_caw,[\amp,0.04]);
		} );


["/*KIRK:*/ Someone or something has succeeded.","r"].addLine;
["Our distress signal relays have been activated.","r"].addLine;
["We've been given a direction to follow, but how? What's causing it?","r"].addLine;
["/*SPOCK:*/ I do not know.","r"].addLine;
["Not even a Vulcan can know the unknown, Captain.","r"].addLine;
["We are hundreds of light years past where any Earth ship has ever explored.","r"].addLine;
["/*SULU:*/ Planet dead ahead, Captain. Becoming visual.","r"].addLine;
P(\sfx,start:\visual, music:{
	var sine,verb,verbBus=Bus.audio;
	var wibble = {
		Pan2.ar(
			SinOsc.ar(
				Gendy2.kr(
					2,
					1,
					SinOsc.kr(0.1,0,0.49,0.51),
					SinOsc.kr(0.13,0,0.49,0.51),
					3.4,
					3.5,
					SinOsc.kr(0.17,0,0.49,0.51),
					SinOsc.kr(0.19,0,0.49,0.51),
					10,
					10,
					mul:50, add:350
				), -1, 0.03
			), 0.0
		)};
		
		Routine( { 
			var r,b,c;
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
			s.sync;
			wibble.play.dur(13);
			//0.2.wait;
			r=Synth(\visual_verb);
			b=Synth(\visual_sine,[\freq, 400, \pan, -1]);
			c=Synth(\visual_sine,[\freq, 300,\pan, 1]);
			2.wait;
			b.set(\freq,500); c.set(\freq,900);
			3.wait;
			{ 
				var d=Synth(\visual_sine,[\freq,950,\pan,0]);
				4.wait;
				d.set(\freq, 150);
				3.wait;
				d.release;
			}.fork;
			b.set(\freq, 600); c.set(\freq, 400);
			3.wait;
			b.set(\freq, 400); c.set(\freq, 300);
			3.wait;
			b.release; c.release;
			4.wait;
		}).play;

	});
["/*SPOCK:*/ Class M planet, Captain.","r"].addLine;
["/*KIRK:*/ Close to Earth conditions.","r"].addLine;
["/*SPOCK:*/ With two very important exceptions.","r"].addLine;
["It's much older than Earth, and about a half million years ago, its atmosphere was","r".addLine;
["totally ripped away by some sort of cataclysm.","r"].addLine;
["The planet has evidently been dead since then.","r"].addLine;
["Sensors detect no life of any kind.","r"].addLine;
["/*SARGON [OC]:*/ All of your questions will be answered in time, Captain Kirk.","r"].addLine;
["/*KIRK*/ Are your hailing frequencies open?","r"].addLine;
["/*UHURA:*/ No, sir.","r"].addLine;
["SARGON [OC]: I am Sargon.","r"].addLine;
["It is the energy of my thoughts which has touched your instruments and directed you here.","r"].addLine;
["Now with this closer distance I can speak to you at last.","r"].addLine;
["/*KIRK:*/ Who are you, Sargon?","r"].addLine;
["SARGON [OC]: Please assume a standard orbit about our planet, Captain.","r"].addLine;
["/*KIRK:*/ Is that a request or demand?","r"].addLine;
["SARGON [OC]: The choice is yours.","r"].addLine;
["I read what is in your mind.","r"].addLine;
["Words are unnecessary.","r"].addLine;
["/*KIRK:*/ The planet is dead.","r"].addLine;
["There's no possibility of life there as we understand life.","r"].addLine;
["/*SARGON:*/ [OC]: And I am as dead as my planet.","r"].addLine;
["Does that frighten you, James Kirk?","r"].addLine;
["For if it does, if you let what is left of me perish, then all of you, my children, all of mankind must perish, too.","r"].addLine;

)
