/*
"open" + "/Users/michael/trek/BySection/Master + 1semitone.m4v 4TRANSCRIBE.RPP".escapeChar(Char.space) => _.unixCmd
*/
(
//[Bridge]

Song(\visual,[]).current;
// Require('boilerplate.scd');
Stills().current;

Song.synthVTracks=EventWithDefault(
	\default, {
		{|i|
			i
			// /10
		}
	},
	\cheng, {
		{|i|
			i
			*2.5
		}
	}

);
["The reading's growing stronger, Captain.","1 -6.5 1 3 5 11 5 4 3".dm('c#',\whole)].addLine;
Trek.cast.sulu = \an;
Trek.presets.put(\sulu,\an,[
	paramGender: -0.35,
	paramToneShift: 200,
]);
P.still(\suluClose, timecode: 1.385.seconds, music: { |p b e|
	 e.still.( 
		wait: b.sum+ e.bNext.sum,
		text: ["the readings","growing stronger, captain"],
	).sequenceText2(
			[b.sum, e.bNext.parse([8,5])].flat , [ 
			["coming from a","star system"],
			["directly","ahead"]
			],
	)
});
P.synthVs(role: \sulu, take:[\lead, \double], params: {|p b| [
	lyrics: "the readings + growing + stronger + captain +",
	legato: [ [1, 1, 1, 1, 1, 1, 0.7, 1, 0.9, ] ],
	filter: (midinote: _ - 12), 
	pitchTake: [1, 3],
	pitchExpression:1.2,
	paramTension: 1
] }, music: {
	var pan = [-1, 1];
	2.collect {|i|
		{|p b e|
			{
				e.playbuf
				// => p.synthVTracks.at(e.key).()
				=> Pan2.ar(_,pan[i])
				/2
			}.play
		}
	}
	}.()
);
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
P.synthVs(role: \sulu, take: [\lead, \double], params: {|p b| [
	lyrics: "coming + from a star - system + directly + + ahead +",
	filter: (midinote: _ - 12), 
	legato: [ [1, 1,    1, 1, 1,  1,   1, 0.4, 1, 1, 1, 1, 1.2] ],
	pitchTake: [1, 3],
	pitchExpression:1.4,
	paramTension:1
] }, music: {
	var pan = [-1, 1];
	2.collect {|i|
		{|p b e|
			{
				e.playbuf
				// => p.synthVTracks.at(e.key).()
				=> Pan2.ar(_,pan[i])
				/2
			}.play
		}
	}
	}.()
);
P.tune();
P(\extraNote,syl:11, music: { |p b e|
	(
		freq: [1,11].df(\c,4),
		dur:2
	).play;
	
	[
		dur: [ Song.durs[\system].list.last,0,0 ] + Song.durs[Song.section(\system)+1].list.parse([5,6,2]) => _.q,
		
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
[" It's not a signal, sir."," 7 11 6 12 7 4".dm('d#')].addLine;/*UHURA:*/
P.still(\uhuru,start:\signal, timecode: 8.716.seconds, music: { |p b e|
	 e.still.( 
		wait: b.sum + e.bNext.sum,
		text: ["its not a signal","sir"],
	)
});
Song.setTempoMap (\signal,"q q q q q q");
P(\square, music: { |p b e|
	[
		freq: [\r,[2, 7],[-7, 4]].df('d#',6).q,
		dur: b.parse([3, 2, 1]).q,
		legato:0.2,
		instrument: \visualToot,
		amp: 0.03
	].pp
});
( Song.signalBass = [
	instrument: \harp,
	decaytime: 2,
	coef: 0.8

];
);
P(\bass, music: { |p b e|
	[
		dur: "qqe e Q Q Q q".asBeats.warpTo(e.tempoMap).q,
		freq: [\r, 6, 7, 5, 1.5, 1].df(\g,2,\mixolydian).q,
	]
	++ p.signalBass
	=> _.pp
});
P.synthV(role: \uhuru, take: \lead, params: {|p b| [
	lyrics: "its not a signal + sir",
	filter: (midinote: _ - 12), 
	pitchTake: 1
] }, music:{|p b e|
	{
		e.playbuf
		=> p.synthVTracks.at(e.key).()
	}.play
});
// P.tune();
P(\pizz, music: { |p b e|
	[
		dur: "qqq q q q".asBeats.warpTo(e.tempoMap).q,
		freq: [\r, 12, 7, 4].df('e-').q,
		instrument: \twang,
		out:2
	].pp
});
["It does not seem to even exist, and yet","7 11 12 13 11 12 13 11 14.5 15 15.5".dm(\c,\mixolydian)].addLine;
Song.setTempoMap(P.calcStart()," E E E Q E E E E qe e q");
SynthDef(\visualToot,{
	var freq = \freq.kr(200);
	Pulse.ar(freq )
	+ SinOsc.ar(freq)

	* Env.asr(0.01,1,0.1).kr(2,gate:\gate.kr(1))
	* \amp.kr(0.1)
	=> Out.ar(\out.kr(0),_)

}).add;
P(\square, music: { |p b e|
	[
		freq: [\r,[3, 11],[1, 5],  [-6.5, 6.5],[1, 11]].df('c',6).q,
		dur: b.parse([3, 2, 3, 2, 1]).q,
		legato:0.2,
		instrument: \visualToot,
		amp: 0.03
	].pp
});

P(\pizz, music: { |p b e|
	[
		dur: "q e e q".asBeats.warpTo(e.tempoMap).q,
		freq: [\r, 13, 11, 5].df('c').q,
		instrument: \twang,
		out:3
	].pp
});
P(\bass, music: { |p b e|
	[
		dur:"q Q E e e q q q q".asBeats.warpTo(e.tempoMap).q,
		// instrument:\snare,
		freq: [\r, 3, 1, -5, -4.5, 4.5, 4, 3].df('c',3).q
	]
	++ p.signalBass
	=> _.pp
});
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
// P.tune();
["it's affecting all my channels.",[5, 5, 5, 5, 5, 6, 5, 4].dm('d#')].addLine;
P.synthVs(role: \uhuru, take: [\nil, \double], params: {|p b| [
	lyrics: "its affecting + + all my channels +",
	pitchTake: [1, 3],
] }, music: {
	var pan = [-1, 1];
	2.collect {|i|
		{|p b e|
			{
				e.playbuf
				// => p.synthVTracks.at(e.key).()
				=> Pan2.ar(_,pan[i])
				* -3.dbamp
			}.play
		}
	}
	}.()
);
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
		* -3.dbamp
	}.play
});
P(\drums, music: { |p b e|
	[
		instrument: 
		"skskskk".as(Array).collect{|i|( i==$s ).if{\sn_808}{\kick_gentle}}
		.q,
		dur: b.q,
		amp: [0.18,0.1].q(4) 
	].pp;
	(lag:b.parse([6]).unbubble.sum, instrument: \cymbalsDS,amp:0.02 ).play
});
Song.setTempoMap(\affecting,"q q q q q q qq q");
P(\bass, music: { |p b e|
	[
		freq: [5, 5,3, 4, 4, 4, 1].df('a-',2).q,
		amp:[3, 3, 1, 3, 3, 3, 3, 4]/8=>_.q,
		dur: "q Q E q qq q qq".asBeats.warpTo(e.tempoMap).q
	].pp
});
P(\shaker, music: { |p b e|

	[
		dur: [12,10].dup(16).flat / 22  
		// => _.push(7,-0.02)
		// => _.push(6,-0.02)
		=> _.warpTo(e.tempoMap)
		=> _.q
		,
		// instrument:\cymbalsDS,
		instrument:\hat_808,
		
		amp:[4,2,3,2] -0.5 /40 =>_.q(inf),
	].pp

});
P.tune();
P(\chord, music: { |p b e|
	[
		freq: [[3, 3, 3, 3, 3, 3, 4, 1],[-5,-5,-5,-5,-5,-6,-5,-4]].flop.df('d#').q,
		dur:b.q
	].pp

});
[" Well?",[1].dm('f#')].addLine;/*KIRK:*/
P.still(\kirk, timecode: 11.597.seconds, music: { |p b e|
	 e.still.( 
		wait: b.sum,
		text: ["well...",""],
	)
});
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
["Someone or something is attempting to attract our attention.","1 -5 -6 -7 1 -5 -6 -7 1 -5 -6 -7 1 -7 1 2 -5".dm(\a) + 1, [2/3,((1/3)+(1/2)),1/4,1/4]!3 ++( [2,1,1,2,2]/4) * 60 / 85=>_.flat ].addLine;
P.still(\spockClose, timecode: 15.633.seconds, music: { |p b e|
	 e.still.( 
		wait: b.sum,
		text: ["someone","or something"],
	).sequenceText2(
			b.parse([6,5,8]), [ 
			["is","attempting"],
			["to attract","our attention"]
			],
	)

});
P.synthV(role: \spock, take: \lead, params: {|p b| [
	lyrics: "someone + or - something + is attempting + + to attract + our attention + +",
	legato: [1, 0.5,  1, 1, 1, 0.5, 1, 1, 1, 0.5, 1, 1, 1, 1, 1, 1, 1],
	pitchTake: 1,
	paramGender: 0,
	filter: (midinote: _ - 12), 
] }, music:{|p b e|
	{
		e.playbuf
		// * -5.dbamp
		// /2
		* -2.dbamp
		// => p.synthVTracks.at(e.key).()
	}.play
});
P.double(role: \spock, take: \lead, params: {|p b| [
	pitchTake: 1
] }, music:{|p b e|
	{
		e.playbuf
		// => Pan2.ar(_,1)
		* -2.dbamp
		// => p.synthVTracks.at(e.key).()
	}.play

});
P(\comp,start:\attempting,music: {
	var busAmp = 4.dbamp;
	var clock = TempoClock.new.tempo_(85/60);

	//Patterns
	var tune= { | synth=\default, amp=1, pan=0 |
		PmonoArtic(	 synth ,
			\dur,	  Pseq([2/3,((1/3)+(1/2)),1/4,1/4],3) ++	(Pseq([2,1,1,2,2])/4),
			\degree, Pseq([8, 5, 6, 7],3)-1 ++ (Pseq([8,7,8,9,5])-1),
			\root, -3 + 1,
			\legato, Pseq([Pseq([1,0.5, 1,0.9],3),	 1,1,1,1,1]),
			\amp,amp,
			\pan,pan,

			// \tempo, 85/60,
		).play(clock:clock)
	};
	var descant={ |synth=\default, amp=0.3 |
		Pbind(	\instrument, synth,
			\degree, Pseq([\r, 5, 4, 3, 2, 4, 3, 2],1)-1+7, 
			\root, -3 + 1,
			\amp,amp
		).play(clock:clock)
	};
	var offbeats={ |synth=\visual_twotube amp=0.1|
		Pbind(	\instrument, synth,
			\dur, Pseq([1, 2, 2, 2], 1),
			\degree, 4,
			\root, -3 + 1,
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
			\k,Pwhite(0,1.0) 
		).play(clock:clock)};

			tune.(\visual_vowel, 0.18 * busAmp);
			descant.(\visual_pad,0.2 * busAmp);
			offbeats.(\visual_twotube, 0.1 * busAmp);
			offbeats.(\default, 0.1 * busAmp);
			off2.(\visual_caw,[\amp,0.04 * busAmp]);
		} );
[" Someone or something has succeeded. Our dis (boom)",[4, 1, 3, 4, 1, 3, 4].dm(\g) ++ [7, 1, 3, 2, -6.5].dm('f#',\diminished2) + 1 ].addLine;/*KIRK:*/
Song.setTempoMap(\succ,"ex e xe Q Q E E Q Q E E qq".asBeats);
P.still(\kirkAgain, timecode: 20.144.seconds, music: { |p b e|
	 e.still.( 
		wait: b.sum,
		text: ["someone","or something"],
	).sequenceText2(
			e.bAll.parse([5,4,9]), [ 
			["has","succeeded"],
			],
	)
});
// P.tune();
P(\bass, music: { |p b e|
	[
		dur: "q qq qq q q".asBeats warpTo: e.tempoMap =>_.q,
		// instrument: \snare,
		// rest: [1, 1, \r, 1, \r, 1, 1].q(inf)
		freq: [1, -5, -5, -4.5 ].df('c#',4).q,
		amp:0.6
	].p.trace.play
});
P(\bassnote,syl:10, music: { |p b e|
	( 
		freq: [-6.5,-16.5].df('a-',4) ,
	dur: b.drop(1),
	amp: 0.4
).play
});
P(\piano, music: { |p b e|
	[
		instrument: \help_oteypiano,
		out: Effect.bus({|i| i => FreeVerb.ar(_,0.3,0.9) *2.5=>SineShaper.ar(_,0.2)  },inputChannels:2),
		freq: [ [1,3],-5,-15,-7,[1,3],-5,-15,-7,1,[6,7,2.5],-4.5, ].df('c#') ++ [3,2].df('g',4,\diminished2)=>_.q,
		strum: [0,0,0,0,0,0,0,0,0,0.01,0,0,0].q,
		dur: b.parse([1,0.5,0.5,1,1,0.5,0.5,1,1,1,1,1, 1, 1]).q,
		rho: 1.2,
		amp:0.5,
	].pp
});
P(\bassConnector, music: { |p b e|
	MegaBind(
		[
			[\r,1.5, 1],
			[\r,-1.5,-1]
		].df('f#')
		,
		"qqqqq q q".asBeats + [0,0,0.5] => _.warpTo( e.tempoMap ),
		[],
		{|i| 
			Saw.ar(i.freqSeq / [2,3,4],0.1) 
			* Env.asr(releaseTime:4).kr(2,gate:i.gateSeq)
	},
		{|i|  Mix.ar(i)}
	).play
});
P.synthV(role: \kirk, take: \lead, params: {|p b| [
	lyrics: "someone + or something + has succeeded + + our di r ",
	// legato: [1, 1, 1, 1, 1, 1, 1, 1, 0.7, 1, 1],
	legato: [1, 0.8, 1, 1, 0.8, 1, 1, 1, 0.7, 1, 1, ],
	pitchExpression: 1.0,
	filter: (midinote: _ - 12), 
	pitchTake: 1,
	paramToneShift: 300,
	paramTension: 1
] }, music:{|p b e|
	{
		e.playbuf
		=> p.synthVTracks.at(e.key).()
	}.play
});
P(\ride, music: { |p b e|
	[
		rest: [\r, 1, 1, 1, ].q,
		instrument: \cymbalsDS, 
		amp: [ 0.0, 0.03,0.03,0.05 ].q,
		dur: "q qq q q".asBeats.warpTo( e.tempoMap ).q
	].pp
});
P.double(role: \kirk, take: \lead, params: {|p b| [
	
] }, music:{|p b e|
	{
		e.playbuf
		=> p.synthVTracks.at(e.key).()
		// => Pan2.ar(_,1)2
	}.play
});
["-stress signals have been (ba da ba da ba da).",[4, 2, -7, 1, 2, 1, -6,-6,-6,-6,-6,-6 ].dm('c#')  ].addLine;
Song.setTempoMap(\stress,"q e e e x x  x e x e x x");
P(\piano, music: { |p b e|
	[
	freq: 	[ [-6, 1, 4], [2, 4], -7, [1, 4], [2, 4], 1 ].df('c#').q,
	legato: [1, 1, 1, 1, [2,2,1], 1, ].q * 0.9,

	dur: b.q,
	amp:0.4,
		instrument: \help_oteypiano,
		out: Effect.bus({|i| i => FreeVerb.ar(_,0.3,0.9) *2.5=>SineShaper.ar(_,0.2)  },inputChannels:2),


	].pp
});
P(\pianoAndBass, syl: 5, music: { |p b e|
	var partAmp = 0.7;
	[
		freq: [ 6, 6, 6, 6, 5, 5 ].df('c#', [2]).q,
		dur: b.drop(1).q,
		amp:0.9 * partAmp,
		pan:1
		// instrument: \help_oteypiano,
		// out: Effect.bus({|i| i => FreeVerb.ar(_,0.3,0.9) *2.5=>SineShaper.ar(_,0.2)  },inputChannels:2),
	].pp;
	[
		freq: [ 6, 6, 6, 6, 5, 5 ].df('c#', [3,4]).q,
		dur: b.drop(1).q,
		amp:0.4 * partAmp,
		instrument: \help_oteypiano,
		out: Effect.bus({|i| i => FreeVerb.ar(_,0.3,0.9) *2.5=>SineShaper.ar(_,0.2)  },inputChannels:2),
	].pp;

});
P.synthVs(role: \kirk, take:[\lead, \double], params: {|p b| [
	lyrics: "stress signals + have been - r r r r r r",
	lag: [ [0.1,0,0,0,0,0,0,0] ],
	pitchTake: [1, 3]
] }, music:{
	var pan = [0, 0];
	2.collect {|i|
		{|p b e|
			{
				e.playbuf
				// => p.synthVTracks.at(e.key).()
				=> Pan2.ar(_,pan[i])
				
			}.play
		}
	}
	}.());
P(\snare, music: { |p b e|
	[
		// dur: b.drop(1).q,
		dur: "qqq x e x e x x".asBeats.warpTo( e.tempoMap
			.quantizeDft(0.5) 
			// .quantizeWindow(0.5)
		).q,
		rest: [\r].q ++ [1].q(6),
		instrument: \sn_808,
		tone: 188,
		snappy: 0.6,
		amp: 0.15
	].pp
});
[" activated. We've been given a direction to","11 7 5 2.5  4 5 4  6 5 4 6 7  6 5 7".dm('c#')].addLine;
P(\line, music: { |p b e|
	[
		freq: [\r, 5, 4, 3, 2, 1].df('e-',[5,4],\minor).q,
		dur:b.parse([ 7, 1, 1, 1, 1, 4 ]).q,
		out:0,
		instrument:\stringyy,
	].pm
	+=
	// ;
	[
		freq: [\r, 6.5, 5, 4, 3, 2].df('e-',[4,3],\minor).q,
		dur:b.parse([ 11, 1, 1, 1, 1 ]) ++ e.bNext.sum => _.flat => _.q,
		out: 1,
		instrument:\stringyy
	].pm
	<> (amp: 0.3,mix:0.0) => _.play
});
P(\bass, music: { |p b e|
	[
		freq: [\r,1, 4, ].df('e-',[ 2,3 ]).q,
		amp:0.8,
		dur: b.parse([7,  4,4 ]).q
	].pp
});
P(\note, music: { |p b e|
	(
		freq:1.df('c#'),
		out: Effect.bus({|i|  FreeVerb.ar(i*5,0.1,1)=> SineShaper.ar(_,0.1) },)
	).play
});
P(\pianodbl, music: { |p b e|
	[
		freq: [ [ 11, 13 ], 7, [11, 5 ], 2.5,  4, 5, 4,  6, 5, 4, 6, 7,  6, 5, 7 ].df('c#', [3,4]).q,
		legato: [1, 1, 0.8, 0.5, 0.9, 1, 1, ].q,
		lag: PLtuple( [ Pwhite(0,0.05) ,0] ),
		instrument: \help_oteypiano,
		out: Effect.bus({|i| i => FreeVerb.ar(_,0.2,0.9) *4.5=>SineShaper.ar(_,0.2) => BPF.ar(_, 1500,0.2,20)  },inputChannels:2),
		dur:b.q
	].pp
});
P.synthVs(role: \kirk, take: [\lead, \double],
	pbind: Song.enlarge(2),
	params: {|p b| [
	lyrics: "activated + + + We've been - given + a direction + + r to follow +",
	legato: [[1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 0.7, ]],
	filter: (midinote: _ - 12), 
	pitchTake: [1, 3]
] }, music:{
	var pan = [-1, -1];
	2.collect {|i|
		{|p b e|
			{
				e.playbuf
				// => p.synthVTracks.at(e.key).()
				=> Pan2.ar(_,pan[i])
				
			}.play
		}
	}
	}.());
[" follow, but how? What's causing it?"," 3 1 2 3 3 5 3 1".dm('a#')].addLine;
Song.setTempoMap(\follow,"ex xe e qe e q e e");
P(\pad, music: { |p b e|
	(
		instrument: \sawSynthSustain,
		freq:[-5,-15].df('e-',4),
		amp: 0.06,
		att: 2,
		dur: b.sum
	).play
});
P(\trem, music: { |p b e|
	[
		freq: [5, 6, 7].df('b-', \mixolydian).q,
		dur: b.parse([3,2,3]).q,
		instrument: \stringyy
		// instrument: \trem2
	].pp
});
P.tune();
P(\clav, music: { |p b e|
	[
		freq: [ [-7,3,5,  ], -7,[-7, 2, 5], 3, -7 ].df('b-',4,\mixolydian).q,
		dur: "ex xe e ex xe e e".asBeats.warpTo( e.tempoMap ).q,
		instrument: \harp
	].pp
});
P(\bass, music: { |p b e|
	[
		freq: [5, 5, 4,  5, 5, 4, 5].df('e-',[ 2,3 ]).q,
		legato: 0.7,
		dur: "q e e q e e q".asBeats.warpTo( e.tempoMap ).q,
		amp:0.8,
	].pp
});
P.synthV(role: \kirk, take: \lead, params: {|p b| [
	lyrics: "r r but how what's causing + it?",
	legato: [1, 1, 1, 0.8, 1, 1, 1, 1,  ],
	filter: (midinote: _ - 12), 
	pitchTake: 1
] }, music:{|p b e|
	{
		e.playbuf
		=> p.synthVTracks.at(e.key).()
	}.play

});
P.double(role: \kirk, take: \lead, params: {|p b| [
	
] }, music:{|p b e|
	{
		e.playbuf
		=> p.synthVTracks.at(e.key).()
	}.play
});
[" I do not know. not even a vulcan can know the unknown",[11, 11, 11, 11, 5, 6, 7, 11, 5, 4, 3, 3, 3, 2].dm('d#')].addLine;/*SPOCK:*/
// Stills.current.file
P.still(\spockAgain, timecode: 29.254.seconds, music: { |p b e|
	 e.still.( 
		wait: b.sum,
		text: ["",""],
	)
});
P(\kick, music: { |p b e|
	[
		dur: " qe e qe e qe e qe e qe e ".asBeats.warpTo( e.tempoMap.quantizeDft ).q,
		instrument: \kick3,
		amp:0.2
	].pp
	
});
Song.setTempoMap('not even',"q x xe qqe e e e q e e q x xe q");
P.synthV(role: \spock, take: \lead, params: {|p b| [
	lyrics: " I do not know. not even a Vulcan + can know the unknown +",
	filter: (midinote: _ - 12), 
	pitchTake: 1
] }, music:{|p b e|
	{
		e.playbuf
		=> p.synthVTracks.at(e.key).()
	}.play

});
P.double(role: \spock, take: \lead, params: {|p b| [
	pitchTake: 1
] }, music:{|p b e|
	{
		e.playbuf
		=> p.synthVTracks.at(e.key).()
	}.play

});
P.synthV(\kevin, take: \aah,
	pbind:{|p b| 
		[
			dur: "qqe e e e q".asBeats.warpTo( Song.tempoMap['not even'] ),
			midinote: [3, 4, 3, 2, 4].dm('e-'),
			
		].p
	},
	params: {|p b| [
	lyrics: "awe - - - -  ",
	legato: [1, 1, 1, 1, 2, ],
	pitchTake: 1,
	pitchExpression: 1.5,
	paramDefaultVibratoDepth: 1 //semitones
] }, music:{|p b e|
	{
		e.playbuf
		=> p.synthVTracks.at(e.key).()
	}.play
});
P(\cymbals, music: { |p b e|
	( instrument: \cymbalsDS, amp:0.03 ).play;
	[
		dur: 1.dup(11).warpTo( e.tempoMap.quantizeDft ).q,
		instrument: \cymbal_808,
		amp:1
	].pp
});
P.synthV(role: \spock, take: \bg, params: {|p b| [
	lyrics: "r r r r r r r r r r know the unknown +",
	filter: (midinote: [1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, -6].dm('e-',4)), 
	pitchTake: 1
] }, music:{|p b e|
	{
		e.playbuf
		=> p.synthVTracks.at(e.key).()
	}.play
});
P.double(\kevin, take: \aah, params: {|p b| [
	
] }, music:{|p b e|
	{
		e.playbuf
		=> p.synthVTracks.at(e.key).()
	}.play
});
P.tune();
P(\bass, music: { |p b e|
	{
		var freq = [
			// 7,
			11, 1, 6, 6, 4, 4, 2, 2, 5, 5, 4].df('e-',2);
		var durs = "
		// e
		q e qe e qe e qe e qe e //q
		".asBeats.warpTo(e.tempoMap);
		Saw.ar( freq.dq.demand(
			durs
		))
		// *0.1
		* ( Env.asr().kr(0,gate: TDuty.kr( durs.dq,0, gapFirst:0 ) ) 
		+ ( 0.5 * EnvGen.cutoff(b.sum,2) )
	)	
		=> LPF.ar(
			_,
			// 1 - Env.asr().kr(0,gate:TDuty( durs.dq,0 )
			// * 1000
			900
		// )
		)
	}.play
});
["We are hundreds of light years past where any","1 2 3 2 1 5.5 3 2 1 1 2 ".dm('c')].addLine;
P.tune();
Song.setTempoMap(\hundreds, "e ee e e e qe x xe e e e");
P(\bass, music: { |p b e|
	{
		var freq = [-1, 1,  2, 3, 4.5, 4.5, 5.5, 6, -6 ].df('c',3);
		var durs = "q q ee e e e e q q
		".asBeats.warpTo(e.tempoMap);
		Saw.ar( freq.dq.demand(
			durs
		))
		// *0.1
		* ( Env.asr().kr(0,gate: TDuty.kr( durs.dq,0, gapFirst:1 )) 
		+ ( 0.5 * EnvGen.cutoff(b.sum,2) )
	)	
		* Env([0,0,1],[[1].asBeats.warpTo( e.tempoMap ).unbubble,0]).kr(0,gate:1)
		=> LPF.ar(
			_,
			// 1 - Env.asr().kr(0,gate:TDuty( durs.dq,0 )
			// * 1000
			900
		// )
		)
	}.play
});
P.synthV(role: \spock, 
	pbind: Song.enlarge(9),
	take: \lead, params: {|p b| [
	lyrics: "we are thousands + of light years past where any + star ship has ever + explored + before +",
	legato: [1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 0.8, ],

	pitchTake: 1,
	pitchExpression: 0.8,
	vocalMode: \Rough
] }, music:{|p b e|
	{
		e.playbuf
		=> p.synthVTracks.at(e.key).()
		=> FreeVerb.ar(_,0.1,1)
	}.play

});
P.double(role: \spock, take: \lead, params: {|p b| [
] }, music:{|p b e|
	{
		e.playbuf
		=> p.synthVTracks.at(e.key).()
		=> BPF.ar(_,1200,2)
	}.play
});
P(\fuzz, music: { |p b e|
	[
		instrument: \NC_DistortedGuitar,
		freq: 
		[
			[\r, 1, -7, -6],
			[\r,-5, -3, -3]
		].flop
		.df('c').q,
		legato: [
			[1,1, 1, 1],
			[1,1, 2, 1]
		].flop.q,
		rest: [\r, 1, 1, 1].q,
		dur: "q qq qq q".asBeats.warpTo( e.tempoMap ).q,
		triq:1,
		out: Effect.bus({|i| AnalogVintageDistortion.ar(i,
			oversample:4,
			drivegain: 0.8,
			highgain: 1,
			// bias: 1
			// bias:2.0
		) => LeakDC.ar(_) /6
		=> Pan2.ar(_,1)}
	)
	].pp.play
});
[" Earth ship has ever explored.","3 3 2 4 3 2 1 -7 2".dm('d')].addLine;
// Song.setTempoMap(\explored,"q e x xe x x e e e");
Song.setTempoMap(\explored,"q e x xe x x e e q");
P(\click, music: { |p b e|
	[
		dur: [1, 1, 1, 1, 1].warpTo( e.tempoMap ).q
	].pp
});
P.tune();
P(\tamb, music: { |p b e|
	{
	var levels = [5,1,2,1] /5 => _.dq(inf);
	var durs =  
	1/4 ! 16
	+ ( [1, -1] /40 => _.dup(8) )
	=> _.flat 
	=> _.warpTo(e.tempoMap.quantizeDft(0.2))
	=> _.dq();
	var triggers = TDuty.kr( durs, 0,1,gapFirst:0 );
	var energy = EnvGen.ar( Env.linen(0, 0.00, 0.015), triggers, doneAction:0   ) 
		* Demand.kr(triggers,0,levels 
			// * 40
			// *8
		);
	Shakers.ar(3, energy:energy   , decay: 1).tanh
	
	// /5
	* 2
	=> Pan2.ar(_, 0.8)
	* EnvGen.cutoff(b.parse([4]).unbubble,3)
	// + SinOsc.ar(300,0,0.05)
	// => DelayN.ar(_,0.2 -0.03 )

}.play;

});

P(\cymbal, music: { |p b e|
	(
		instrument: \cymbalsDS,
		amp:0.05
	).play
});
P.tune();
P(\bass, music: { |p b e|

	//need to do legato!!
	{
		var freq = [1, 1, -4, -3].df('d',3);
		var durs = "q q qq q".asBeats.warpTo(e.tempoMap);
		Saw.ar( freq.dq.demand(
			durs
		))
		// *0.1
		* ( Env.asr(0.01,1,1).kr(0,gate: TDuty.kr( durs.dropLast.dq,0, gapFirst:1 )) 
		+ ( 0.5 * EnvGen.cutoff(b.sum,2) )
	)	

		=> LPF.ar(
			_,
			// 1 - Env.asr().kr(0,gate:TDuty( durs.dq,0 )
			// * 1000
			900
		// )
		)
	}.play
});
P.synthV(\kevin, take: \bg,
	filter: (midinote:[11, 11, 7 ,7 ,6 ,5 ,4, 4, 3].dm('d',4,\mixolydian)), 
	params: {|p b| [
	lyrics: "star ship has ever + explored + before +",
	pitchTake: 1
] }, music:{|p b e|
	{
		e.playbuf
		=> p.synthVTracks.at(e.key).()
		=> Pan2.ar(_,0.9)
		=> HPF.ar(_,200)
		/3
	}.play
});
P.double( \kevin, take: \bg, params: {|p b| [
	pitchTake: 1
] }, music:{|p b e|
	{
		e.playbuf
		=> p.synthVTracks.at(e.key).()
		=> Pan2.ar(_,0.9)
		=> HPF.ar(_,200)
		/3
	}.play

});
P(\fuzz, music: { |p b e|
	[
		dur: "q e e q".asBeats.warpTo( e.tempoMap ).q,
		freq: "5 5 4 1".df('g',3).q
	].p
	+=
	[
		dur: "q e x xq".asBeats.warpTo( e.tempoMap ).q,
		freq: "3 3 2 4".df('d',4).q
	].p
	+=
	[
		dur: "q q".asBeats.warpTo( e.tempoMap ).q,
		freq: "2 2".df('g',4)
	].p
	<> (out: Effect.bus( {|i|AnalogVintageDistortion.ar(i,
			oversample:4,
			drivegain: 0.9,
			highgain: 1,
		)
		/4
		=> BPF.ar(_,1200,1) * 3
	}
	))
	=> _.play

});
[" Planet dead ahead, Captain. Becoming visual.","-7 1 3 5.5 11 5.5 5.5 5.5 5.5 11.5 5.5 1.5".dm('c')].addLine;/*SULU:*/
P.still(\suluAgain, timecode: 39.796.seconds, music: { |p b e|
	 e.still.( 
		wait: b.sum,
		text: ["",""],
	)
});

P(\chord,syl:3, lag:-0.05, music: { |p b e|
	[
		["1 3 5".df('c#',\whole)," 11 13 15 21".df('c#',\whole) ],
		// ["1 3 6".df('f#')," 11 13 16".df('f#')],
		[" 1 3 5".df('d')," 11 13 15 ".df('d')]
	].flop
	.collect
	{|i x|
		[ 
			freq: i .q,
			out: Effect.bus( { |i|  i * SinOsc.ar(3.5).range(0.5,1) => FreeVerb.ar(_,0.02,1)}, out:1 ),
			// lag: x * 0.11,
			dur: b.parse([5,1]) => _.q,
			strum:0.05,
			// amp: Pfunc({|e| e.freq.cpsmidi.linexp(60,70,0.08,0.03) })
		].pp
	}
});
P.synthV(role: \sulu, take: \lead, params: {|p b| [
	lyrics: "planet + getting + closer + becoming + + visual + +",
	legato: [1, 1, 1, 1, 1, 0.6, 1, 1, 1, 1, 1, 1, ],
	filter: (midinote: _ - 12), 
	pitchTake: 1,
	pitchExpression:1.4,
	paramTension:1
] }, music:{|p b e|
	{
		e.playbuf
		=> p.synthVTracks.at(e.key).()
	}.play

});
P.double(role: \sulu, take: \lead, params: {|p b| [
	
] }, music:{|p b e|
	{
		e.playbuf
		=> p.synthVTracks.at(e.key).()
	}.play
});

["planet","r",[10]].addLine;
P.still(\planet, timecode: 43.571.seconds, music: { |p b e|
	 e.still.( 
		wait: b.sum,
		text: ["",""],
	)
});
P(\sfx, music:{
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
			var f={|i| i/400 * 1.df('c#',6)};
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
			b=Synth(\visual_sine,[\freq, f.(400), \pan, -1]);
			c=Synth(\visual_sine,[\freq, f.(300),\pan, 1]);
			2.wait;
			b.set(\freq,f.(500)); c.set(\freq,f.(900));
			3.wait;
			{ 
				var d=Synth(\visual_sine,[\freq,f.(950),\pan,0]);
				4.wait;
				d.set(\freq, f.(150));
				3.wait;
				d.release;
			}.fork;
			b.set(\freq, f.(600)); c.set(\freq, f.(400));
			3.wait;
			b.set(\freq, f.(400)); c.set(\freq, f.(300));
			3.wait;
			b.release; c.release;
			4.wait;
		}).play;

	});
	P(\tremolo, music: { |p b e|
		(

		).play
	});
	P(\strings,lag:8, music: { |p b e|
		[
			freq: [1,2].df('f#').q(inf),
			dur:Pwhite(0.05,0.06,inf),
			amp: Pgeom(0.1,0.98,inf)
		].pp;
		(
			freq: [1,2,4,5].df('c#'),
			instrument: \stringyy,
			wet:0,
			amp:0.2,
			rel:19
		).play
	});
[" Class M planet, Captain.","5 2 11 5 2 -6".dm('b')].addLine;/*SPOCK:*/
P.still(\spockClassM, timecode: 46.865.seconds, music: { |p b e|
	 e.still.( 
		wait: b.sum,
		text: ["",""],
	)
});
P.tune();
P(\line, music: { |p b e|
	[
		freq: [\r,11, 5, 2, -6, -3].df('b',[ 4, 5 ]).q,
		dur: b.parse([2, 1, 1, 1, 1]) ++ e.bNext.sum => _.q
	].pp
});
P.synthV(role: \spock, take: \lead, params: {|p b| [
	lyrics: "Class em planet + captain +",
	filter: (midinote: _ - 12), 
	pitchTake: 1
] }, music:{|p b e|
	{
		e.playbuf
		=> p.synthVTracks.at(e.key).()
	}.play

});
[" Close to Earth conditions.","5 2 11 5 2 -6".dm('a-')].addLine;/*KIRK:*/
P.still(\kirk, timecode: 48.072.seconds, music: { |p b e|
	 e.still.( 
		wait: b.sum,
		text: ["",""],
	)
});
P.synthV(role: \kirk, take: \lead, params: {|p b| [
	lyrics: "Close to Earth conditions + +",
	filter: (midinote: _ - 12), 
	pitchTake: 1
] }, music:{|p b e|
	{
		e.playbuf
		=> p.synthVTracks.at(e.key).()
	}.play

});
Song.setTempoMap(\Close,"Q E Q E Q E");
	
P(\line, music: { |p b e|
	[
		freq: [5, 2,11, 5, 2, -6, -3].df('a-',4).q,
		dur: "e e e e e e".asBeats.warpTo( e.tempoMap ) ++ e.bNext => _.q
	].pp
});
P.tune();
["(boom) With two very important exceptions.","4 1 5 3 4 1 5 4 5 5.5 -5.5".dm('c')].addLine;/*SPOCK:*/
P.still(\spock, timecode: 50.62.seconds, music: { |p b e|
	 e.still.( 
		wait: b.sum,
		text: ["",""],
	)
});
P.synthV(role: \spock, take: \lead, params: {|p b| [
	lyrics: " with r two very + important + + exceptions + +",
	pitchTake: 1
] }, music:{|p b e|
	{
		e.playbuf
		=> p.synthVTracks.at(e.key).()
	}.play

});
P.double(role: \spock, take: \lead,
	filter: (midinote: _ - 12), 
	params: {|p b| [
	pitchTake: 1,
] }, music:{|p b e|
	{
		e.playbuf
		=> p.synthVTracks.at(e.key).()
	}.play

});
P.tune();
P(\bassnotes, syl:8, music: { |p b e|
	[
		freq:"5.5 -5.5 1.5 -1.5".df('c',[ 4,5 ]).q,
		dur: b.drop(1) ++ e.bNext => _.q
	].pp
});
 ["Its much older than Earth", "5 5 11 5 5 5 5".dm('f#',4)].addLine;
P.synthV(role: \spock, take: \lead, params: {|p b| [
	lyrics: "its much older + than the Earth",
	pitchTake: 1
] }, music:{|p b e|
	{
		e.playbuf
		=> p.synthVTracks.at(e.key).()
	}.play

});
P.double(role: \spock, take: \lead, params: {|p b| [
	pitchTake: 1
] }, music:{|p b e|
	{
		e.playbuf
		=> p.synthVTracks.at(e.key).()
	}.play

});
P(\arpeggio,syl:1, music: { |p b e|
	(
		freq: [1,5,11,13,15,21,23,25].df('f#',3,\minor),
		strum: 0.05
	).play
});
P.tune();
[" and about a half million years ago, its","3 2 1 -7".dm(\b,\harmonicMinor) ++ "5 5 6 5 6 5 4 1 4".dm(\a)].addLine;
Song.setTempoMap(\about,"e x xe e q e x g g xe x xe x ");
P.tune();
P(\click, music: { |p b e|
	[
		dur: "q q q q q".asBeats.warpTo( e.tempoMap.quantizeWindow(0.2) ).q,
		instrument: \hihat
	].pp
});
P(\keys, music: { |p b e|
	[
		freq: [\r,[-1,-3, -5, 1, 3, 5], [-5, 3, 5]].df('b-',3,\diminished) 
		++ [ [-1,1], 1 ].df(\a,3)
		// ++ [[-1,1], 11, 3].df(\d,3)
		=> _.q,
		dur: "qq q q q q ".asBeats.warpTo( e.tempoMap).q
	].pp
});
[" atmosphere was"," 3 1 -6 3".dm(\a)].addLine;
Song.setTempoMap(\atmosphere,"ex x xe e");
P(\click, music: { |p b e|
	[
		dur: "x q e".asBeats.warpTo( e.tempoMap).q,
		rest: [\r,1,1,1,1,1,].q,
		instrument: \hihat
	].pp
});
P(\keys, music: { |p b e|
	[
		freq: [\r,[-1,1], 11, 3].df(\d,3)
		=> _.q,
		dur: "x q e e".asBeats.warpTo( e.tempoMap).q
	].pp
});
P(\pad, music: { |p b e|
	(
		freq: [ 1,3,5,7 ].df(\d),
		instrument: \stringyy,
		dur: b.sum
	).play
});
P(\flute, music: { |p b e|
	[
		freq: "1 3 4 3 ".df(\d,6).q,
		dur: "x x x e e e".asBeats.warpTo( e.tempoMap ).q,
		rest: [\r, 1, 1, 1, 1, 1].q,
		// instrument: \reedy, amp:0.000
		instrument: \wash, freqLag:0
	].ppm
});
P(\bass, music: { |p b e|
	[
		freq: [\r, -1, 1, 1, -1].df(\d,4).q,
		dur: "x e x xe e".asBeats.warpTo( e.tempoMap ).q,
		lag: [0, 0, 0.07,0,0].q,
		amp: [0,2,1,2,2]/20 => _.q
		// dur: [0.25, 0.5,0.25,0.75,0.5]/2 => _.warpTo(e.tempoMap) => _.q
	].pp
});
P.tune();
["totally ripped away by ","5 6 5 5 5 11 12".dm(\c)].addLine;
Song.setTempoMap(\ripped,"e e q qe e qe q");
P(\guitar, music: { |p b e|
	[
		freq: [2, 3, 2, 2, 1, -7, 1].df(\f,4,\mixolydian).q,
		dur: "e e q q q qe e".asBeats.warpTo( e.tempoMap ).q,
		instrument: \pluckD,
		amp:0.05
	].ppm
	;
	[
		freq: [-2, 2, -2, 1, -7, 1].df(\f,4,\mixolydian).q,
		dur: "q q q q qe e".asBeats.warpTo( e.tempoMap ).q,
		amp:0.5
	].pp
});
P.tune();
["some sort of cataclysm.","4 4 4 4 3 2 1".dm(\f)].addLine;
P.tune();
P(\bass, music: { |p b e|
	[
		freq: [3,3,3,-5, 1,4].df(\g,3,\minor).q,
		dur: e.bAll.parse([1,1,1,[1,1,1,0.5],[0.5,1],2]).q,
		amp:1,
	].pp
});
P(\pf, music: { |p b e|
	[
		freq: [4,5].dup(3) ++ [5] => _.df(\f) => _.q,
		dur: b.parse([1, 1, 1, 4]).q
	].pp
});
["The planet has evidently been dead since then.","5 4 3 4 11 7 7 6".dm(\c) ++"5 5 2 4".dm('c#')].addLine;
P.tune();
["Sensors detect no life of any kind.","2 3 1 -6 1 4 1 2 3 4".dm(\e)].addLine;
P.tune();
P.tune(\detect, _ <> [freq: [1,4].df(\e,6), amp:0.05].p);
[" All of your questions will be answered in time, Captain Kirk.", "4 3 2 1 2 2 3 2 1 -7 -7".dm(\c) ].addLine;/*SARGON [OC]:*/
P.synthV(role: \vocoder, take: \lead, params: {|p b| [
	filter: (midinote: 45!11), 
	lyrics: "All of your questions + will be answered + in time",
	pitchTake: 1
] }, music:{|p b e|
	p.vocodeTune.(p, b, e, e.rpp,
		dur: b.sum + 3,
		sus: b.sum + 3,
	)
});
P.still(\sargon, timecode: 105.188.seconds, music: { |p b e|
	 e.still.( 
		wait: b.sum,
		text: ["",""],
	)
});
P.tune();
[" Are your hailing frequencies open?","r",[3]].addLine;/*KIRK*/
P.still(\kirk, timecode: 112.48.seconds, music: { |p b e|
	 e.still.( 
		wait: b.sum,
		text: ["",""],
	)
});
[" No, sir.","r",[1]].addLine;/*UHURA:*/
["SARGON [OC]: I am Sargon.","1 -7 4 3".dm('c#')].addLine;
P.still(\sargon, timecode: 114.7.seconds, music: { |p b e|
	 e.still.( 
		wait: b.sum,
		text: ["",""],
	)
});
P.tune();
P(\bassnotes, music: { |p b e|
	[
		freq: [ [-1, 1].df('c#',3),[-1,1].df('f#',2) ].q,
		dur: b.parse([2,2]).q,
	].pp;
	[
		freq: [\r, [ 3, 5, 11 ],[3,5,7]].df('f#').q,
		dur: b.parse([2,1,1]).q,
		strum: [0,0.05,0].q,
		instrument: \default
	].ppm
});
P(\line, music: { |p b e|
	[
		midinote: "1 -7 -6 -5".dm('c#').q,
		dur: b.parse([ 1, 1, 1 ]).q,
		legato: 1,
		instrument: \stringyy,
		
	].ppm;
	[
		freq: 1.df('c#'),
		dur: b.sum,
		instrument: \sawSynthSustain,
		att:[1].q,
		amp: 0.02
	].pp;
	(
		instrument: \cymbalsDS,
		lag: b.parse([2]).unbubble,
		amp: 0.02
	).play
});
Require("boilerplate");
P.synthV(role: \vocoder, take: \lead, params: {|p b| [
	lyrics: "I am sargon +",
	legato: [0.7, 1, 1, 0.7, ],
	pitchTake: 1,
	filter: (midinote: _ - 12), 
] }, music:{|p b e|
	p.vocodeTune.(p,b,e,e.rpp)

});
["It is the energy of my thoughts which has","1 -7 1 3 4 3 1".dm('e-') ++ "1 4 3 4".dm(\e)].addLine;
P.tune();
P.synthV(role: \vocoder, take: \lead,
	filter: (midinote: _ - 12), 
	params: {|p b| [
	lyrics: "It is the energy + + of my thoughts which has",
	pitchTake: 1
]}, music:{|p b e|
	p.vocodeTune.(p,b,e,e.rpp)

});
P(\chord,syl: 7, music: { |p b e|
	(
		instrument: \stringyy,
		freq: [3, 5, 11].df('a',[3,4,5,6,7]).flat,
		out: [2,3,4],
		release: 12,
		attack:2
	).play
});
["(boom) touched your instruments and directed you here.","7 11 5 4 2 3".dm(\c) ++ "3 4 3 1 -5 11.5".dm('a',4)].addLine;
P(\openStrings, music: { |p b e|
	[
		freq: [\r, [1,5,12].df(\g,4),[-5, 1, 4].df(\a,3), [-1,1].df('f#',3) ].q,
		dur: b.parse([3, 5, 3, 1]).q,
		strum: 0.05,
		instrument: \stringyy, mix: 0 ,
		instrument: \harp, mix: 0 , coef: 0.7, out: Effect.bus({|i| DWGReverbC1C3.ar(i) /2 },)
	].pp
});
P(\chord,syl: 10, music: { |p b e|
	(
		instrument: \stringyy,
		freq: [ 5, 11, 13].df('f#',[3,4,5,6,7]).flat,
		out: [2,3,4],
		release: 12,
		attack:2
	).play
});
P.tune(_ <> [rest: [\r, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1].q].p);
P(\note, music: { |p b e|
	P.calcStart().postln;
	"e ".post; e.postln;
	"p ".post; p.postln;
	(
		freq: p.tune[e.start].list[0].midicps,
		instrument: \defaultPorto,
	).play;
	(
		freq: p.tune[e.start].list[0].midicps,
		instrument: \harp,
	).play;
	(
		freq: p.tune[e.start].list[0].midicps / [2,4],
		out: Effect.bus({|i| DWGReverbC1C3.ar(i) * 2 },)
		// instrument: \harp,
	).play
});
P.synthV(role: \vocoder, take: \lead, params: {|p b| [
	lyrics: "r touched your instruments + + and directed + + you here.",
	filter: (midinote: _ - 12), 
	pitchTake: 1
] }, music:{|p b e|
	p.vocodeTune.(p,b,e,e.rpp)

});
["Now at this closer distance","5 4 3 2 1 3 2 4 3 3 2 2 1 -7 -6 4.5".dm(\d)].addLine;
Song.durs.filter(_*1.3);
P.tune( { |i| i  <> [legato: 3,amp:0.03].p => Pmul(\freq,[0.25,0.5,1],_) });
P(\pad, music: { |p b e|
	[
		instrument: \visual_pad,
		freq: 1.df(\a),
		dur: b.q
		// dur: b.sum
	].pp
});
P.synthV(role: \vocoder, take: \lead, params: {|p b| [
	lyrics: "Now at this closer + distance + I can speak to you r r at last",
	filter: (midinote: _ - 12), 
	pitchTake: 1
] }, music:{|p b e|
	{
		PlayBuf.auto(2,Song.laMer,trigger:TDuty.ar(4,0), rate: [2,3].dq.demand(b.parse([ 14,2 ])).midiratio) /20
	}
	// .play(s,p.carrierBus)
	;
	
	{
		Saw.ar(
			[ 1, -7 ].df(\a).dq.demand(b.parse([ 14,2 ])) /[2,3,4,8]// + Gendy1.arWidth(freq:0.1).range(-10,10)
			)
			* Env.linen(2,b.sum-1,1).kr /200
			=> Out.ar(p.carrierBus,_);
			Silent.ar
	}.play;
	p.vocodeTune.(p,b,e,e.rpp,
		dur:b.sum + 0.5,
		att:1,
		// sus: b.parse([9]).sum,
		rel:0,
		mix:0.9

	)
});
[" Who are you, Sargon?","-7 3 1 -7 -5".dm(\c,\mixolydian)].addLine;/*KIRK:*/
P.still(\kirk, timecode: 125.75.seconds, music: { |p b e|
	 e.still.( 
		wait: b.sum,
		text: ["",""],
	)
});
P.synthV(role: \kirk, take: \lead, params: {|p b| [
	lyrics: "Who are you sargon +",
	pitchTake: 1
] }, music:{|p b e|
	{
		e.playbuf
		=> p.synthVTracks.at(e.key).()
		=> Pan2.ar(_,0)
		/3
	}.play

});

["SARGON [OC]: Please assume a standard orbit about our planet, Captain.","1 2 2 1 2 3 3 2 1 2 3/c# 4 3 2 1/e-".dm2].addLine;
P.still(\kirk, timecode: 132.5.seconds, music: { |p b e|
	 e.still.( 
		wait: b.sum,
		text: ["",""],
	)
});
P.synthV(role: \vocoder, take: \lead, params: {|p b| [
	lyrics: "Please assume + a standard + orbit + about + our planet + captain + ",
	pitchTake: 1
] }, music:{|p b e|
	p.vocodeTune.(p,b,e,e.rpp,
		chord: #[1,2,1.5,4],
		mix: 0.9,
		width:1.02,
		modGain:2,
		wet:0.1
	)

});

[" Is that a request or demand?","3 5 7 11 13 11 7 5 15".dm(\e,\mixolydian)].addLine;/*KIRK:*/
P.synthV(role: \kirk, take: \lead, params: {|p b| [
	filter: (midinote: _ - 12), 
	lyrics: "Is that a request + or a demand +",
	loudness: Env([ 3,0,3,0,3,0,3,0,3 ] ,b + [0.1,0,0,0,0,0,0,0,0]),
	legato: [1, 1, 1, 1, 0.9, 1, 0.7, 1, 1, ],
	pitchTake: 1
] }, music:{|p b e|
	{
		e.playbuf
		=> p.synthVTracks.at(e.key).()
	}.play

});
P.tune(_ <>[instrument:\harp].p);
["SARGON [OC]: The choice is yours.","1 1 1 5".dm('f#')].addLine;
P.synthV(role: \vocoder, take: \lead, params: {|p b| [
	lyrics: "the choice is yours",
	filter: (midinote: _ - 12), 
	pitchTake: 1
] }, music:{|p b e|
	p.vocodeTune.(p,b,e,e.rpp,
		echo:0.2, modGain:4,
		chord: #[2,4,6,8],
		mix: 0.99
	)

});
["I read what is in your mind.","3 11 7 3 2 7 3".dm(\d)].addLine;
P(\chords, music: { |p b e|
	[
		freq: [ [2,2], [1,3], [-7, 6] ].df(\e,\mixolydian).q,
		dur: b.parse([4, 2, 1]).q,
		instrument: \stringyy, mix:0.1,amp:0.05,
		out: p.carrierBus
	].pp;

});
P.tune( _ <> [instrument: \sawSynth, out: Song.carrierBus, amp:0.02].p );
P.synthV(role: \vocoder, take: \lead, params: {|p b| [
	filter: (midinote: 45!7), 
	lyrics: "I read what is in your mind",
	pitchTake: 1
] }, music:{|p b e|
	p.vocodeTune.(p,b,e,e.rpp,
		modGain:3,mix:0.8,width:1.01
	)

});
P.tune();
["Words are unnecessary.","3 4 5  2 1 -7 -6".dm('a-', \mixolydian)].addLine;
P.tune();
P.synthV(role: \vocoder, take: \lead, params: {|p b| [
	lyrics: "words are unnecessary + + + +",
	filter: (midinote: 48), 
	pitchTake: 1
] }, music:{|p b e|
	p.vocodeTune.(p,b,e,e.rpp,
		modGain:3,
	)

});
P(\connector, music: { |p b e|
	[
		freq: [\r,2, 1, -7, -6, -5.5].df('a-',\mixolydian).q,
		dur: e.bAll.parse([3, 1, 1, 1, 1, 3]).q
	].pp
});
[" The planet is dead.","1 1 1 1 4.5".dm(\c)].addLine;/*KIRK:*/
P.tune(_ <>[instrument:\harp].p);
P.synthV(role: \kirk, take: \lead, params: {|p b| [
	lyrics: "the planet + is dead",
	legato: [1, 1, 1, 1, 0.66, ],
	pitchTake: 1
] }, music:{|p b e|
	{
		e.playbuf
		=> p.synthVTracks.at(e.key).()
	}.play

});
["There's no possibility of life there as we understand life.","1 2 4 3 2 1 -6 2/d 4 3 1 2 2 3 3/e 3/b-/4".dm2].addLine;
P.synthV(role: \kirk, take: \lead, params: {|p b| [
	lyrics: "There's no possibility + + + + of life there as we understand + + life.",
	pitchTake: 1
] }, music:{|p b e|
	{
		e.playbuf
		=> p.synthVTracks.at(e.key).()
	}.play

});
P.tune();
[" [OC]: And I am as dead as my planet.","5 6 5 4 3 2 3 2 1".dm('e-',\minor)].addLine;/*SARGON:*/
P.synthV(role: \vocoder, take: \lead,
	pbind: Song.enlarge(7),
	// filter: (midinote: _ - 12), 
	filter: (midinote: 45!16), 
	params: {|p b| [
	lyrics: "And I am as dead as my planet + does that frighten + you James Kirk",
	legato: [1, 1, 1, 1, 1, 1, 1, 1, 0.8, 1, 1, 1, 1, 0.8, 1, 1, ],
	pitchTake: 1
] }, music:{|p b e|
	p.vocodeTune.(p,b,e,e.rpp,

		modGain:3,
		enlarge: 7, tune: p.tune[e.start].list ++ p.tune[e.start+1].list, dur: b.sum + e.bNext.sum + 2, sus:b.sum+e.bNext.sum+2)
});
/// end here???
["Does that frighten you, James Kirk?","4 3 7 5 3 2 1/b-/mixolydian/4".dm2].addLine;
P.tune();
["For if it does,","r"].addLine;
["if you let what is left of me perish,","r"].addLine;
["then all of you, my children,","r"].addLine; 
["all of mankind must perish, too.","r"].addLine;

)
