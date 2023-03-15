/*
"open /Users/michael/trek/BySection/Master + 1semitone.m4v.RPP ".unixCmd
*/
(
//[Bridge]

Song(\visual,[]).current;

Song.synthVTracks=EventWithDefault(
	\default, {
		{|i|
			i
			// /10
		}
	}
);
["The reading's growing stronger, Captain.","1 -6.5 1 3 5 11 5 4 3".dm('c#',\whole)].addLine;
Trek.cast.sulu = \an;
Trek.presets.put(\sulu,\an,[
	paramGender: -0.35,
	paramToneShift: 200,
]);
P.synthV(role: \sulu, take:\lead, params: {|p b| [
	lyrics: "the readings + growing + stronger + captain +",
	filter: (midinote: _ - 12), 
	pitchTake: 1,
	pitchExpression:1.2,
	paramTension: 1
] }, music:{|p b e|
	{
		e.playbuf
		// => p.synthVTracks.at(e.key).()
	}.play
});
P.double(role: \sulu, params: {|p b| [
		
	] }, music:{|p b e|
		{
			e.playbuf
			// => p.synthVTracks.at(e.key).()
		}.play
	});
P.tune();
P(\chord,syl:4, lag:-0.05, music: { |p b e|
	[
		["1 3 5".df('c#',\whole)," 11 13 15 21".df('c#',\whole) ],
		["1 3 6".df('f#')," 11 13 16".df('f#')],
		["1 3 5".df('a-',\whole)," 11 13 15 ".df('a-',\whole)]
	].flop
	.collect
	{|i x|
		[ 
			freq: i .q,
			out: Effect.bus( { |i|  i * SinOsc.ar(3.5).range(0.5,1) => FreeVerb.ar(_,0.02,1)}, out:1 ),
			// lag: x * 0.11,
			dur: [b.sum,0,0] + e.bNext.parse([5,7,1]) => _.q,
			strum:0.05,
			// amp: Pfunc({|e| e.freq.cpsmidi.linexp(60,70,0.08,0.03) })
		].pp
	}
});
P(\lowChord,syl:6, music: { |p b e|
	MegaBind(
		[
			[11, \_, \_,   \_,   ],
			[4,  \_, 5.5,  \_,   ],
			[\r, 3,  \_,   3.5,  ],
			[1,  \_, \_,   \r,   ],
			[\r, \r, -5.5, \_,   ],
			[-4, \_, -5.5, \_,   ],
			[\r, -3, \_,   -3.5, ],

		].df('c#',\whole)
		,
		b.drop(1) ++ e.bNext.parse([5,3]),
		[],
		{|i|  SinOsc.ar(i.freqSeq,0,0.1) 
		* Env.asr().kr(2,gate:i.gateSeq)
	},
		{|i| Splay.ar(i)}
	).play
});

["Coming from a star system directly ahead.","6 5 6 7 11 12 11 6 ".dm('c#') ++ "1 2 3 4 5".dm('e',\whole)].addLine;
P.synthV(role: \sulu, take: \lead, params: {|p b| [
	lyrics: "coming + from a star - system + directly + + ahead +",
	filter: (midinote: _ - 12), 
	legato: [1, 1,    1, 1, 1,  1,   1, 0.4, 1, 1, 1, 1, 0.9],
	pitchTake: 1,
	pitchExpression:1.4,
	paramTension:1
] }, music:{|p b e|
	{
		e.playbuf
		// => p.synthVTracks.at(e.key).()
	}.play
});

P.tune();
P(\extraNote,syl:11, music: { |p b e|
	(
		freq: [1,11].df(\c,4),
		dur:2
	).play;
	
	[
		dur: 
		[ Song.durs[\system].list.last,0,0 ] + Song.durs[Song.section(\system)+1].list.parse([5,6,3])
		=> _.q,
		
		freq: [[7, 12].df(\f,\mixolydian), [7, 12].df(\e,\mixolydian), [6, 11].df(\e)].q /2,
		// amp:0
	].p
	+= [
		dur: [ b.last,0,0,0,0,0 ] + Song.durs[Song.section(\system)+1].list.parse([5,3,3,[1,0.5],[0.5,1],1]) => _.q,
		freq: 
		[3].df(\f,\mixolydian) ++ [3,2.5].df(\e,\mixolydian) ++ [2,1.5,1].df(\e,\mixolydian) /2
		=> _.q,
		// amp:0
	].p
	<> (out:1,instrument:\wash)
	=> _.play
});
P.double(role: \sulu, take: \lead, params: {|p b| [
	
] }, music:{|p b e|
	{
		e.playbuf
		// => p.synthVTracks.at(e.key).()
	}.play
});
P(\lowChord,syl:7, music: { |p b e|
	MegaBind(
		[
			[1,  \_, \_, \r, \r],
			[\r, 2,  \_, \r, \r],
			[\r, \r, 3,  \_, \r],
			[\r, \r, \r, 4,  \r],
			[-1, \r, -3, -4, \r]

		].df('e',\whole)
		,
		b.drop(1),
		[],
		{|i|
			SinOsc.ar(i.freqSeq,0,0.1)
			* Env.asr().kr(2,gate:i.gateSeq)
		},
		{|i|  Mix.ar(i)}
	).play
});
Trek.cast.uhuru = \cheng;
P(\chords, music: { |p b e|
	
});
["/*UHURA:*/ It's not a signal, sir."," 7 11 6 12 7 4".dm('d#')].addLine;
P.synthV(role: \uhuru, take: \lead, params: {|p b| [
	lyrics: "its not a signal + sir",
	filter: (midinote: _ - 12), 
	pitchTake: 1
] }, music:{|p b e|
	{
		e.playbuf
		// => p.synthVTracks.at(e.key).()
	}.play
});
P.tune();
["It does not seem to even exist, and yet","7 11 12 13 11 12 13 11 14.5 15 15.5".dm(\c,\mixolydian)].addLine;
P.synthV(role: \uhuru, take: \lead, params: {|p b| [
	lyrics: "it does not seem to even + exist + and yet",
	legato: [1, 1, 1, 1, 1, 1, 1, 1, 0.6, 1, 0.5],
	filter: (midinote: _ - 12), 
	pitchTake: 1
] }, music:{|p b e|
	{
		e.playbuf
		=> p.synthVTracks.at(e.key).()
	}.play
});
P.tune();
["it's affecting all my channels.",[5, 5, 5, 5, 5, 6, 5, 4].dm('d#')].addLine;
P.synthV(role: \uhuru, take: \nil, params: {|p b| [
	lyrics: "its affecting + + all my channels +",
	pitchTake: 1,

] }, music:{|p b e|
	{
		e.playbuf
		=> p.synthVTracks.at(e.key).()
	}.play
});
P.synthV(role: \uhuru, take: \harmony,
	pbind: {|p b| [
		midinote:  [3, 3, 3, 3, 3, 3, 4, 1].dm('d#'),
		dur: b
	].p },
	params: {|p b| [
	lyrics: "its affecting + + all my channels +",
	pitchTake: nil
] }, music:{|p b e|
	{
		e.playbuf
		=> p.synthVTracks.at(e.key).()
	}.play
});
P(\drums, music: { |p b e|
	[
		instrument: 
		"skskskk".as(Array).collect{|i|( i==$s ).if{\snare}{\kick}}
		.q,
		dur: b.q
	].pp;
	(lag:b.parse([6]).unbubble.sum, instrument: \cymbalsDS,amp:0.02 ).play
});
P.double(role:\uhuru, take: \harmony, params: {|p b| [
	
] }, music:{|p b e|
	{
		e.playbuf
		=> p.synthVTracks.at(e.key).()
	}.play
});

P.tune();
P(\chord, music: { |p b e|
	[
		freq: [[3, 3, 3, 3, 3, 3, 4, 1],[-5,-5,-5,-5,-5,-6,-5,-4]].flop.df('d#').q,
		dur:b.q
	].pp

});
["/*KIRK:*/ Well?",[1].dm('f#')].addLine;
P.synthV(role: \kirk, take: \lead, params: {|p b| [
	lyrics: "well",
	// filter: (midinote: _ - 12), 
	pitchTake: 1,
	paramTension:1,
	paramToneShift:200
] }, music:{|p b e|
	{
		e.playbuf
		=> p.synthVTracks.at(e.key).()
	}.play
});

["Someone or something is attempting to attract our attention.","1 -5 -6 -7 1 -5 -6 -7 1 -5 -6 -7 1 -7 1 2 -5".dm(\a), [2/3,((1/3)+(1/2)),1/4,1/4]!3 ++( [2,1,1,2,2]/4) * 60 / 85=>_.flat
].addLine;
P.synthV(\mo, start: Song.section(\attract), take: \lead, params: {|p b| [
	lyrics: "someone + or - something + is attempting + + to attract + our attention + +",
	legato: [1, 0.5,  1, 1, 1, 0.5, 1, 1, 1, 0.5, 1, 1, 1, 1, 1, 1, 1],
	pitchTake: 1,
	paramTension: 0.9,
	paramGender: 0.35,
	paramToneShift: 200,
	filter: (midinote: _ - 12), 
] }, music:{|p b e|
	{
		e.playbuf
		* -5.dbamp
		// => p.synthVTracks.at(e.key).()
	}.play
});
P(\comp,start:\attempting,music: {
	var clock = TempoClock.new.tempo_(85/60);

	//Patterns
	var tune= { | synth=\default, amp=1, pan=0 |
		PmonoArtic(	 synth ,
			\dur,	  Pseq([2/3,((1/3)+(1/2)),1/4,1/4],3) ++	(Pseq([2,1,1,2,2])/4),
			\degree, Pseq([8, 5, 6, 7],3)-1 ++ (Pseq([8,7,8,9,5])-1),
			\root, -3,
			\legato, Pseq([Pseq([1,0.5, 1,0.9],3),	 1,1,1,1,1]),
			\amp,amp,
			\pan,pan,

			// \tempo, 85/60,
		).play(clock:clock)
	};
	var descant={ |synth=\default, amp=0.3 |
		Pbind(	\instrument, synth,
			\degree, Pseq([\r, 5, 4, 3, 2, 4, 3, 2],1)-1+7, 
			\root, -3,
			\amp,amp
		).play(clock:clock)
	};
	var offbeats={ |synth=\visual_twotube|
		Pbind(	\instrument, synth,
			\dur, Pseq([1, 2, 2, 2], 1),
			\degree, 4,
			\root, -3,
			\octave, 4,
			\dummy, Pseq([\r, 1, 1, 1],1 )
		).play(clock:clock)
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
			\k,Pwhite(0,1.0) ).play(clock:clock)};

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
["It's much older than Earth, and about a half million years ago, its atmosphere was","r"].addLine;
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
["For if it does,","r"].addLine;
["if you let what is left of me perish,","r"].addLine;
["then all of you, my children,","r"].addLine;
["all of mankind must perish, too.","r"].addLine;

)
