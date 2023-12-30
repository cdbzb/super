(
/*
"open" + "/Users/michael/trek/BySection/Master + 1semitone.m4v 4TRANSCRIBE.RPP".escapeChar(Char.space) => _.unixCmd
*/
{
Song(\visual,[]).current;
Require('boilerplate.scd');
Stills().current;
( Song.synthVTracks=EventWithDefault(
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

)
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
// P.tune(_ <> [rest: [1, 1, 1, 1, 1, 1, \r, 1, \r].q,att:0, rel: 1, instrument: \sparkTriangle, amp: 0.04, freqLag: 0.05, width: 0.005].p);
P(\tuneDouble, music: { |p b e| //meh
	fork{
		var barrier = Barrier.collect({
			var freq = \freq.kr(200);
Pulse.ar(freq, \width.kr(0.3))
			=> RLPF.ar(_,freq* 3.2)
			=> Pan2.ar(_,1)
			+ VarSaw.ar(freq, width: 0.5)

			* Env.perc(0.05, \rel.kr(3)).kr(2,gate:1)
			* \amp.kr(0.1)
			=> {|i|i => BAllPass.ar(_, 1200 * SinOsc.ar(3).range(0.5,1.2))
			+ i
			=> HPF.ar(_,220)
			/3
		}		
		=> Out.ar(\bus.kr(0), _)
	}.asDefName
);
barrier.()[0] =>
[
	freq: [\r, -6.5, 1, 3, 5, 11,].df('c#',\whole) ++ [[1, 3, 7],  5.5].df(\a,4, \mixolydian) => _.q,
	legato: [1, 5, 4, 3, 2, 0.9,  [2, 2, 1], 1].q,
	dur: b.parse([1, 1, 1, 1, 1, 2, 1, 1]).q,
	instrument: _
] => _.pp
	}
});

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
			out: Effect.bus( { |i|  i.tanh * SinOsc.ar(3.5).range(0.5,1) => FreeVerb.ar(_,0.02,1)}, out:1 ),
			// lag: x * 0.11,
			dur: [b.sum,0,0] + e.bNext.parse([5,7,1]) => _.q,
			strum:0.05,
			instrument: \defaultPiano
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
		* Env.asr().kr(0,gate:i.gateSeq)
	},
	{|i| Splay.ar(i)}
).play
});
["Coming from a star system directly ahead.","6 5 6 7 11 12 11 6 ".dm('c#') ++ "1 2 3 4 5".dm('e',\whole)].addLine;
{
P.synthVs(role: \sulu, take: [\lead, \double], params: {|p b| [
		lyrics: "coming + from a star - system + directly + + ahead +",
		filter: (midinote: _ - 12), 
		legato: [ [1, 1,	1, 1, 1,  1,   1, 0.4, 1, 1, 1, 1, 1.2] ],
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
P.tune( _ <> [instrument: \defaultPiano].p );
P(\counterRyhthm, music: { |p b e|
	[
		// instrument: cymbal_808,
		dur: b.parse([1, 1, 1, 1, 1, 1, 1, 1, 1, 0.5, [0.5, 2/3], [1/3, 1], 1]).q,
		rest: [\r, \r, \r, \r, \r, \r, \r, \r, \r, \r, 1, 1, 1].q,
		freq: [1, 1, 1, 1, 1, 1, 1, 1, 1, 1,    -6, 1, 3].df('e',[4, 5], \whole).q,
		out: [1, 2],
		legato: 3,
		// amp: 1
	].pp
});
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
}.();
[" It's not a signal, sir."," 7 11 6 12 7 4".dm('d#')].addLine;/*UHURA:*/
P.still(\uhuru,start:\signal, timecode: 8.716.seconds, music: { |p b e|
	e.still.( 
		wait: b.sum + e.bNext.sum,
		text: ["its not a signal","sir"],
	).sequenceText2(
		b.sum.bubble, [ 
			["",""],
		],
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
P(\pizz, music: { |p b e|
	[
		dur: "qqq q q q".asBeats.warpTo(e.tempoMap).q,
		freq: [\r, 12, 7, 4].df('e-').q,
		instrument: \twang,
		out:2
	].pp
});
( SynthDef(\visualToot,{
	var freq = \freq.kr(200);
Pulse.ar(freq )
	+ SinOsc.ar(freq)

	* Env.asr(0.01,1,0.1).kr(2,gate:\gate.kr(1))
	* \amp.kr(0.1)
	=> Out.ar(\out.kr(0),_)

}).add;
);
["It does not seem to even exist, and yet","7 11 12 13 11 12 13 11 14.5 15 15.5".dm(\c,\mixolydian)].addLine;
P.still(\clear, timecode: 0.seconds, music: { |p b e|
	e.still.( 
		wait: b.sum,
		text: ["It does not seem","to even exist"],
	).sequenceText2(
		b.parse([9]), [ 
			["and","yet"],
		],
	)
});
Song.setTempoMap(P.calcStart()," E E E Q E E E E qe e q");
P(\doubling, music: { |p b e|
	[
		freq: [\r,4.5,5,5.5].q,
		dur: b.parse([8, 1, 1, 1]).q,
		amp:0.05,
		instrument: \wash
	].pp;
	[
		freq: [\r,4.5,5,5.5].df(\c) .q,
		dur: b.parse([8, 1, 1, 1]).q,
		freqLag: 0.4,
		instrument: \wash,

		amp:0.05,
	].ppm
});
P(\square, music: { |p b e|
	[
		freq: [\r,[3, 11],[1, 5],  [-6.5, 6.5],[3, 11,]].df('c',6).q,
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
P(\twangThree, music: { |p b e|
	[
		freq: [\r, 14.5, 15, 15.5 ].df(\c).q,
		dur: b.parse([8,1,1,1]).q,
		instrument: \harp, coef:0.6, amp:0.08,
		out: Effect.bus({|i| i => Pan2.ar(_,0)  },)

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

P.still(\clear, timecode: 0.seconds, music: { |p b e|
	e.still.( 
		wait: b.sum,
		text: ["its affecting","all my channels"],
	)
});
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
	Song.setTempoMap(\affecting,"q q q q q q qq qq");
	Song.affectingTempoMap = Song.tempoMap[\affecting];//.quantizeDft(0.0)
P(\drums, music: { |p b e|
		[
			instrument: 
			"skskskk".as(Array).collect{|i|( i==$s ).if{\sn_808}{\kick_gentle}}
			.q,
			// dur: b.q,
			dur: "q q q q q q qq qq".asBeats.warpTo(p.affectingTempoMap).q,
			amp: [0.19,0.09].q(4) + 0.05 
		].pp;
		(lag:b.parse([6]).unbubble.sum, instrument: \cymbalsDS,amp:0.02 ).play
});
P(\bass, music: { |p b e|
		[
			freq: [5, 5,3, 4, 4, 4, 1].df('a-',2).q,
			amp:[3, 3, 1, 3, 3, 3, 3, 4]/8=>_.q,
			dur: "q Q E q qq q qq".asBeats.warpTo(p.affectingTempoMap).q
		].pp
});
P(\shaker, music: { |p b e|

		[
			dur: "e e e e e e e e e e e e e e e e e e e e ee".asBeats.warpTo(e.tempoMap.quantizeWindow(0.5))
			* [12,10] / 11  
			// => _.push(7,-0.02)
			// => _.push(6,-0.02)
			// => _.warpTo(e.tempoMap.quantizeDft())
			=> _.q
			,
			// instrument:\cymbalsDS,
			instrument:\hat_808,

			amp:[4,2,3,2] -0.5 /25 =>_.q(inf),
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
P(\chord, music: { |p b e|
	( freq: [-7, 1.5, 3].df(\d, \mixolydian),  ).play
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
P.synthVs(role: \spock, take: [\lead,\double], params: {|p b| [
		lyrics: "someone + or - something + is attempting + + to attract + our attention + +",
		legato: [[1, 0.5,  1, 1, 1, 0.5, 1, 1, 1, 0.5, 1, 1, 1, 1, 1, 1, 1]],
		pitchTake: [1,3],
		paramGender: 0,
		filter: (midinote: _ - 12), 
	] }, music:[-1,1].collect{|pan| {|p b e|
		{
			e.playbuf
			// * -5.dbamp
			// /2
			* -2.dbamp
			=> Pan2.ar(_,pan)
			// => p.synthVTracks.at(e.key).()
		}.play
	} });
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
P.still(\kirkAgain, timecode: 24.6.seconds, music: { |p b e|
			e.still.( 
				wait: b[..8].sum,
				text: ["someone","or something"]
			).sequenceText2(
				e.bAll.parse([5,4,9]), [ 
					["has","succeeded"],
					["",""]
				],
			)
});
P.still(\clear,syl:8, timecode: 0.seconds, music: { |p b e|
			e.still.( 
				wait: b.drop(1).sum + e.bNext[..5].sum,
				text: ["our dis-","tress signals have been"],
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
P.synthVs(role: \kirk, take: [\lead,\double],
		pbind: Song.enlarge(7),
		params: {|p b| [
			lyrics: "someone + or something + has succeeded + + our di r stress signals + have been - ",
			phonemes: [["", "", "", "", "", "", "", "", "", "", "d ih", "", "", "", "", "", "", ""]], 
			// legato: [1, 1, 1, 1, 1, 1, 1, 1, 0.7, 1, 1],
			legato: [[1, 0.8, 1, 1, 0.8, 1, 1, 1, 0.7, 1, 1, 1,1,1,1,1,1,1, ]],
			lag: [[ 0.1, 0.05, 0, 0.0, 0.0, 0.0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0,  ]],
			pitchExpression: 1.0,
			filter: (midinote: _ - ( 12 ! 12 ++ ( 0!7 ) => _.flat )), 
			pitchTake: [1,3],
			paramToneShift: 300,
			paramTension: 1
		] }, music:{|p b e|
			{
				e.playbuf
				=> p.synthVTracks.at(e.key).()
				=> Pan2.ar(_,0)
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
P.still(\clear, timecode: 0.seconds, music: { |p b e|
			e.still.( 
				wait: b.sum,
				text: ["activated","we've been"],
			).sequenceText2(
				b.parse([7]), [ 
					["given a direction","to"],
				],
			)
});
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
		] }, music:
		[0, 0].collect{|pan|
			{|p b e|
				{
					e.playbuf
					// => p.synthVTracks.at(e.key).()
					=> Pan2.ar(_,pan)

				}.play
			}
		}
	);
[" follow, but how? What's causing it?"," 3 1 2 3 3 5 3 1".dm('a#')].addLine;
P.still(\clear, timecode: 0.seconds, music: { |p b e|
		e.still.( 
			wait: b.sum,
			text: ["follow,","but how?"],
		).sequenceText2(
			b.parse([4]), [ 
				["what's causing","it?"],
			],
		)
});
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
P.synthVs(role: \kirk, take: [\lead, \double], params: {|p b| [
		lyrics: "r r but how what's causing + it?",
		legato: [[1, 1, 1, 0.8, 1, 1, 1, 1,  ]],
		filter: (midinote: _ - 12), 
		pitchTake: [1, 3]
	] }, music:{|p b e|
		{
			e.playbuf
			=> p.synthVTracks.at(e.key).()
			=> Pan2.ar(_,0)
		}.play

});
[" I do not know. not even a vulcan can know the unknown",[11, 11, 11, 11, 5, 6, 7, 11, 5, 4, 3, 3, 3, 2].dm('d#')].addLine;/*SPOCK:*/
P(\chords, music: { |p b e|
	[
		freq: [
			[1, 3, 5],
			[1, 3, 6],
			[1, 4, 6],
			[2, 4, 6],
			[5, 7, 3],
			[4, 6, 2]
		].df('e-').q
		=> _.dupEach(2)
		,
		// dur: "qq qq qq qq qq qq".asBeats.warpTo( e.tempoMap.quantizeDft ).q,
		dur: "q q q q q q q q q q q e".asBeats.warpTo( e.tempoMap.quantizeDft ).q,
		instrument: \default,
		out: Effect.bus({|i| 
			i 
			=> CrossoverDistortion.ar(_,0.1,0.95)
			// /10
			+ i.tanh
			// => Pan2.ar(_,1)
			*4
			=> Phaser2.ar(_,rate: 0.2)
		},inputChannels:2, out: 1)

	].pp
});
P.still(\spockAgain, timecode: 29.254.seconds, music: { |p b e|
		e.still.( 
			wait: b.sum,
			text: ["I","do not know"],
		).sequenceText2(
			b.parse([4]), [ 
				["not even a Vulcan can","know the unknown"],
			],
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
P.synthVs(role: \spock, take: [\lead, \double], params: {|p b| [
		lyrics: " I do not know. not even a Vulcan + can know the unknown +",
		filter: (midinote: _ - 12), 
		pitchTake: [1, 3]
	] }, music:{|p b e|
		{
			e.playbuf
			=> p.synthVTracks.at(e.key).()
			=> Pan2.ar(_,0)
		}.play

});
P.synthVs(\kevin, take: [\aah, \aahDbl],
	pbind:{|p b| 
		[
			dur: "qqe e e e q".asBeats.warpTo( Song.tempoMap['not even'] ),
			midinote: [3, 4, 3, 2, 4].dm('e-'),

		].p
	},
	params: {|p b| [
		lyrics: "awe - - - -  ",
		legato: [[1, 1, 1, 1, 2, ]],
		pitchTake: [1, 3],
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
			=> Pan2.ar(_,0)
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
P.still(\clear, timecode: 0.seconds, music: { |p b e|
		e.still.( 
			wait: b.sum,
			text: ["we","are"],
		).sequenceText2(
			b.parse([2]), [ 
				["hundreds of light years past","where any"],
			],
		)
});
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
P.synthVs(role: \spock, 
	pbind: Song.enlarge(9),
	take: [\lead, \double], params: {|p b| [
		lyrics: "we are hundreds + of light years past where any + star ship has ever + explored + before +",
		legato: [[1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 0.8, ]],

		pitchTake: [1, 3],
		pitchExpression: 0.8,
		vocalMode: \Rough
	] }, music:{|p b e|
		{
			e.playbuf
			=> p.synthVTracks.at(e.key).()
			=> FreeVerb.ar(_,0.1,1)
			=> Pan2.ar(_,0)
		}.play

});
P(\chords, music: { |p b e|
	[
		freq: [
			\r,
			[1, 3, 5],
			[2, 3, 5],
			[-7, 3, 5.5],
			[-7, 4.5, 5.5],
			[2, 3, 6],
			[1, 3, 6]
		].df(\c, 6).q
		// => _.dupEach(2)
		,
		// dur: "qq qq qq qq qq qq".asBeats.warpTo( e.tempoMap.quantizeDft ).q,
		dur: "q q q q q q q".asBeats.warpTo( e.tempoMap.quantizeDft ).q,
		instrument: \default,
		out: Effect.bus({|i| 
			i 
			=> CrossoverDistortion.ar(_,0.1,0.95)
			// /10
			+ i.tanh
			// => Pan2.ar(_,1)
			*4
			=> Phaser2.ar(_,rate: 0.2)
		},inputChannels:2, out: 1)

	].pp
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
			=> {|i| CombC.ar(
				i,
				0.2, 
				"q q q ".asBeats.warpTo( e.tempoMap ) / 2 => _.dq => _.demand( "q q q".asBeats.warpTo( e.tempoMap ) ),
			 b[..2].sum * 3)
			 /3 + i
		 }
			
			=> Pan2.ar(_,1)}
		)
	].pp.play
});
[" Earth ship has ever explored.","3 3 2 4 3 2 1 -7 2".dm('d')].addLine;
P.still(\clear, timecode: 0.seconds, music: { |p b e|
	e.still.( 
		wait: b.sum ,
		text: ["starship has","ever explored before"],
	)
});
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
P.synthVs(\kevin, take: [\bg, \bgDbl],
filter: (midinote:[11, 11, 7 ,7 ,6 ,5 ,4, 4, 3].dm('d',4,\mixolydian)), 
params: {|p b| [
	lyrics: "star ship has ever + explored + before +",
	pitchTake: [1, 3]
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
Song.planetKey_('c');
[" Planet dead ahead, Captain. Becoming visual.","-7 1 3 5.5 11 5.5 5.5 5.5 5.5 11.5 5.5 1.5".dm(Song.planetKey)].addLine;/*SULU:*/

P.still(\suluAgain, timecode: 39.796.seconds, music: { |p b e|
	e.still.( 
		wait: b.sum,
		text: ["planet getting","closer"],
	).sequenceText2(
		b.parse([6]), [ 
			["becoming","visual"],
		],
	)
});

P(\chord,syl:3, lag:-0.05, music: { |p b e|
	[
		["1 3 5"," 11 13 15 21" ].collect (_.df(p.planetKey,\whole)),
		// ["1 3 6".df('f#')," 11 13 16".df('f#')],
		[" 1 3 5 11"," 11 13 15 11"].collect(_.df(p.planetKey) * midiratio(1) )
	].flop
	.collect
	{|i x|
		[ 
			freq: i .q,
			out: Effect.bus( { |i|  i * SinOsc.ar(3.5).range(0.5,1) => FreeVerb.ar(_,0.02,1)},inputChannels:2, out:1 ),
			// lag: x * 0.11,
			dur: b.parse([5,1]) => _.q,
			strum:0.05,
			// amp: Pfunc({|e| e.freq.cpsmidi.linexp(60,70,0.08,0.03) })
		].pp
	}
});
// P.tune();
P(\arp, music: { |p b e|
	[
		instrument: \harp,
		freq: [-7, 1, 3, 5.5, 11].df(p.planetKey).q,
		dur: b.q
	].pp
});
P.synthVs(role: \sulu, take: [\lead,\double2], params: {|p b| [
	lyrics: "planet + getting + closer + becoming + + visual + +",
	legato: [[1, 1, 1, 1, 1, 0.6, 1, 1, 1, 1, 1, 1, ]],
	lag: [[0.05, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0,]],
	filter: (midinote: _ - 12), 
	pitchTake: [ 2, 3 ],
	pitchExpression:1.4,
	paramTension:1
] }, music:{|p b e|
	{
		e.playbuf
		=> p.synthVTracks.at(e.key).()
		=> Pan2.ar(_,1)
		/2
	}.play

});
P(\doubling,syl:8, music: { |p b e|
	[
		freq: [11.5,5.5,1.5].df(p.planetKey).q,
		dur: b.drop(1).q,
		instrument: \visual_pad, amp: 0.35,
		freqLag: 0.1
	].ppm
});

["planet","r",[8.5]].addLine;
P.still(\planet, timecode: 43.571.seconds, music: { |p b e|
	e.still.( 
		wait: b.sum,
		text: ["",""],
	)
});
P(\wibble, music:{
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
			var f={|i| i/400 * 1.df('f#',6)};
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
P(\trill, music: { |p b e|
		[
			// lag:8,
			freq: [1,2].df('f#').q(inf),
			dur:Pwhite(0.05,0.06,inf),
			// amp: [Pfindur(8,[0.1].q(inf)), Pgeom(0.1,0.98,inf)].q,
			amp: Pseg([0, 0, 0.1 * -4.dbamp, 0],[2.5,5.5,8],[1,-6])
			// out: subMaster.index + [2,3]
		].p.play
		;
		[1,2,4,5].df('c#').do{|i x|(
			freq: i,
			instrument: \stringyy,
			wet:0,
			// attack:8, 
			dur:9,
			// lag:8,
			amp:0.2,
			rel:19,
			out: Effect.bus({|i| i *
				Env([0,0, -4.dbamp,0],[2.5,5.5,12],[1,-2])
				.kr(2,gate:1)
			},out:x,inputChannels:4)
		).play
	}});
}.();
[" Class M planet, Captain.","5 2 11 5 2 -6".dm('b')].addLine;/*SPOCK:*/
P(\chords, music: { |p b e|
	[
		freq: [-5, 1, 2, 4].bubble ++ [-2, -4, -5, 2].bubble ++ [-7, -3, -4.5].bubble => _.df('c#') => _.q ,
		dur: b.parse([6,6]) ++ e.bNext[..4] =>_.q,
		instrument: \stringyy,
		freqLag: 0.8,
		wet: 0.1,
		out: (0..3)
	].ppm;
	[
		freq: [\r] ++ ['f#', 'd#', 'c'].collect{|i| [ 4, 1, -5, -2, -16].df(i,5) } => _.flat => _.q,
		dur: b.parse([2, 1, 1, 1, 1, 2, 1, 1, 1, 1, 2]).q,
		instrument: \sparkTriangle, width: 0.1
	].pp
});
P(\bass, music: { |p b e|
	[
		instrument: \sawSynth,
		freq: ['f#','d#','f'].collect([1, -5].df(_,5)).flat.q,
		dur: b.parse([1, 5, 1,5, 1, 5]) ++ e.bNext[..4] =>_.q,
		out: [2,3],
		amp: 0.05
	].pp;
});
P.still(\spockClassM, timecode: 46.865.seconds, music: { |p b e|
	 e.still.( 
		wait: b.sum,
		text: ["class M planet","Captain"],
	)
});
// P.tune();
P(\line, music: { |p b e|
	[
		freq: [\r,11, 5, 2, -6, -3].df('b',[ 4, 5 ]).q,
		dur: b.parse([2, 1, 1, 1, 1]) ++ e.bNext.sum => _.q
	]//.pp
});
P.synthV(role: \spock, take: \lead, params: {|p b| [
	lyrics: "Class em planet + captain +",
	lag: [0.06, 0, 0, 0, 0, 0],
	filter: (midinote: _ - 12), 
	pitchTake: 1
] }, music:{|p b e|
	{
		e.playbuf
		=> p.synthVTracks.at(e.key).()
		=> Pan2.ar(_,0)
		// => {|i| Fverb.ar(i[0], i[1],decay:5) /4 +i *0.6
	}.play

});
[" Close to Earth conditions.","5 2 11 5 2 -6".dm('a-')].addLine;/*KIRK:*/
P.still(\kirkClose, timecode: 48.072.seconds, music: { |p b e|
	 e.still.( 
		wait: b.sum,
		text: ["close to","Earth conditions"],
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
		=> Pan2.ar(_,0)
		=> {|i| Fverb.ar(i,i)/6 + i /3 }
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
		text: ["with two very important","exceptions"],
	)
});
P(\accents, music: { |p b e|
	// [
	// 	freq: [\r, 1, 1,].df(\c, 4).q,
	// 	dur: b.parse([1, 4,3 ]).q
	// ].pp;
	[
		freq: [4, 1, -5].df(\c).q,
		dur: b[0..2].q,
		instrument: \harp,coef:0.1, amp:0.02,
		out: Effect.bus({|i| CombN.ar(i,b[0]*1.33,b[0]*1.33, b.sum/2) /2 * [0,1] + i },)
	].pp
});
P.synthVs(role: \spock, take: [\lead,\double], params: {|p b| [
	lyrics: " with r two very + important + + exceptions + +",
	// lyrics: " r with  two very + important + + exceptions + +",
	filter: [(midinote: _ - 12),(midinote: _)],
	legato: [[1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 0.7]],

	pitchTake: [1,3]
] }, music:[-0.1,0.1].collect{|pan|{|p b e|
	{
		e.playbuf
		=> p.synthVTracks.at(e.key).()
		=> Pan2.ar(_,pan)
		/2
	}.play

}});
P.tune();
P(\bassnotes, syl:8, music: { |p b e|
	[
		freq:"5.5 -5.5 1.5 -1.5".df('c',[ 4,5 ]).q,
		dur: b.drop(1) ++ e.bNext => _.q,
		instrument: \sawSynth
	].pp
});
 ["Its much older than Earth", "5 5 11 5 5 5 5".dm('f#',4)].addLine;
 P.still(\clear, timecode: 0.seconds, music: { |p b e|
 	 e.still.( 
 		wait: b.sum,
 		text: ["its much","older than the Earth"],
 	)
 });
P.synthVs(role: \spock, take: [\lead,\double], params: {|p b| [
	lyrics: "its much older + than the Earth",
	pitchTake: [1,3]
] }, music:[-0.1,0.1].collect{|pan|{|p b e|
	{
		e.playbuf
		=> p.synthVTracks.at(e.key).()
		=> Pan2.ar(_,pan)
		* -6.dbamp
	}.play

}});
P(\arpeggio,syl:1, music: { |p b e|
	(
		freq: [1,5,11,13,15,21,23,25].df('f#',3,\minor),
		strum: 0.05,
		dur: b.sum,
		instrument: \defaultPiano,
		out: Effect.bus({|i| 
			i 
			=>RLPF.ar(_, 700 * Gendy2.ar(maxfreq:3,minfreq:1).range(0.5,2), rq:0.5)
			=> {|i| CombN.ar(i, 0.5, 0.5, 5) /2 => Pan2.ar(_, Line.kr(-1,0.2,3)) + i}
		}, inputChannels:2)
	).play
});
P.tune();
[" and about a half million years ago, its","3 2 1 -7".dm(\b,\harmonicMinor) ++ "5 5 6 5 6 5 4 1 4".dm(\a)].addLine;
P.still(\clear, timecode: 0.seconds, music: { |p b e|
	 e.still.( 
		wait: b.sum,
		text: ["and about a","half million years ago, its"],
	)
});
Song.durs.filter(\half,_ * 1.05);
P.synthVs(role: \spock, take: [\lead,\double],
    pbind: Song.enlarge(4),
	params: {|p b| [
	filter: (midinote: _ - 12), 
	lyrics: "and about + a half million + years - - ago + its atmosphere + + was",
	legato: [[0.8, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 0.8, 1, 1, 1, 1, 1, ]],
	pitchTake: [1,3]
] }, music:[-0.1,0.1].collect{|pan|{|p b e|
	{
		e.playbuf
		=> p.synthVTracks.at(e.key).()
		=> Pan2.ar(_,pan)
		* -6.dbamp
	}.play
}});
Song.setTempoMap(\about,"e x xe e q e x g g xe x xe x ");
P.tune();
P(\click, music: { |p b e|
	[
		dur: "q q q q q q".asBeats.warpTo( e.tempoMap.quantizeWindow(0.2) ).q,
		instrument: \hihat
	].pp
});
P(\bassline, music: { |p b e|
	[
		freq: [3, 2, 1, -7].df(\b,[3], \harmonicMinor).q,
		dur: "e e e e".asBeats.warpTo( e.tempoMap ).q,
		instrument: \sawSynth, amp: [0.03,0.08]
		// rel: 0.8
	].pp;
	[
		freq: [3, 2, 1, -7].df(\b,[3], \harmonicMinor).q,
		dur: "e x xe x e".asBeats.warpTo( e.tempoMap ).q,
		instrument: \harp,coef: 0.05, decaytime: 1,
		out: Effect.bus({|i| Phaser2.ar(i, rate: 0.5) /3 },)
		// instrument: \sawSynth, amp: [0.03,0.08]
		// rel: 0.8
	].pp
});
P(\keys, music: { |p b e|
	[
		freq: [\r,[-1,-3, -5, 1, 3, 5], [-5, 3, 5]].df('b-',3,\diminished) 
		++ [ [-1,1], 1 ].df(\a,3)
		// ++ [[-1,1], 11, 3].df(\d,3)
		=> _.q,
		dur: "qq q q q q ".asBeats.warpTo( e.tempoMap).q,
		out: Effect.bus({|i| SineShaper.ar(i*3, limit: 0.2,  ) => Pan2.ar(_,0.2) },)
	].pp
});
[" atmosphere was"," 3 1 -6 3".dm(\a)].addLine;
P.still(\clear, timecode: 0.seconds, music: { |p b e|
	 e.still.( 
		wait: b.sum,
		text: ["atmosphere","was"],
	)
});
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
P.still(\clear, timecode: 0.seconds, music: { |p b e|
	 e.still.( 
		wait: b.sum,
		text: ["totally ripped","away by"],
	)
});
P.synthVs(role: \spock, take: [\lead,nil],
	params: {|p b| [
	filter: (midinote: _ - 12), 
	lyrics: "totally + + ripped away + by",
	vocalMode: \Rough,
	legato: [[1,1, 1, 1, 1, 1, 0.7, ]],
	pitchTake: [1,3]
] }, music:[-0.1,0.1].collect{|pan|{|p b e|
	{
		e.playbuf
		=> p.synthVTracks.at(e.key).()
		=> Pan2.ar(_,pan)
		/2.5
	}.play

}});
P(\drumz, music: { |p b e|
	[
		dur: "qq qq qq qq".asBeats.warpTo( e.tempoMap ).q,
		instrument: \cymbalsDS,
		amp: 0.02
	].pp;
	[
		instrument: \bd_808,
		dur: "q qq q".asBeats.warpTo( e.tempoMap ).q
	].pp
});
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
P.still(\clear, timecode: 0.seconds, music: { |p b e|
	 e.still.( 
		wait: b.sum,
		text: ["some sort of","cataclysm"],
	)
});
P(\dyad, music: { |p b e|
	[
		freq: [1,5].df(\f),
		instrument: \harp,coef:0.7,
		dur: b.parse([1, 1, 1, 4]).q,
		out: Effect.bus({|i|CrossoverDistortion.ar(i)/10 },out:2)
	].pp
});
P.synthVs(role: \spock, take: [\lead,\double],
	params: {|p b| [
	filter: (midinote: _ - 12), 
	lyrics: "some sort of cataclysm + + +",
	legato: [[1, 1, 0.8, 1, 1, 1, 0.8, ]],
	vocalMode: \Rough,
	pitchTake: [1,3]
] }, music:[-0.1,0.1].collect{|pan|{|p b e|
	{
		e.playbuf
		=> p.synthVTracks.at(e.key).()
		=> Pan2.ar(_,pan)
		/2
		=> {|i|  CombN.ar(i,0.3,0.3,3)/2 + i}
	}.play

}});
// P.tune();
P(\bass, music: { |p b e|
	[
		freq: [3,3,3,-5, 1,].df(\g,2,\minor).q,
		dur: e.bAll.parse([1,1,1,[1,1,1,0.5],[0.5,1],2]).q,
		amp: [1, 1, 1, 1, 0.9, 0.8, 0.7, 0.6].q
	].pp
});
P(\pf, music: { |p b e|
	[
		freq: [[4,5],[4,5],[4,5],[4,5],3,[2,5],1].df(\f).q,
		dur: b.q,
		instrument: \help_oteypiano,
		amp:0.3,
		out: Effect.bus({|i| OteySoundBoard.ar(i*2,c:2).tanh => SineShaper.ar(_,0.2) => {|i| CrossoverDistortion.ar(i)/10 + i} },)
	].pp
});
P(\cymbal,syl:2, music: { |p b e|
	(
		instrument: \cymbalsDS, amp: 0.05
	).play
});
["The planet has evidently been dead since then.","5 4 3 4 11 7 7 6".dm(\c) ++"5 5 2 4".dm('c#')].addLine;
Song.setTempoMap('dead since',"e Q Q QE E E e ee e Q E q");
P(\ride, music: { |p b e|
	[
		instrument: \cymbal_808,
		dur: "eq qq qq qq q".asBeats.warpTo( e.tempoMap ).q,
		amp: 0.6,
		rest: MuteFirst()
	].pp
});
P.still(\clear, timecode: 0.seconds, music: { |p b e|
	 e.still.( 
		wait: b.sum,
		text: ["the planet","has"],
	).sequenceText2(
			b.parse([4, 4]), [ 
			["evidently",""],
			["been dead","since then"]
			],
	)
});
P(\click, music: { |p b e|
	[
		dur: "e q q q q".asBeats.warpTo( e.tempoMap ).q,
	].pp
});
P(\bass, music: { |p b e|
	[
		freq: [\r, 1, 3, 4].df(\c,3,\whole).q,
		dur: "e qq qq qqq".asBeats.warpTo( e.tempoMap ).q,
		amp: [0.5,0.5,0.3,0.1].q
	].pp
});
P(\keys, music: { |p b e|
	MegaBind(
		[
			[\r, 5,  \_, \_, \_, 4.5 ],
			[\r, \_, \_, \_, \_, 14.5 ],
			[\r, 4,  3,  2,  \_, \_],
			[\r, 1,  \_, \_, -7, \_]
		].df(\c)
		,
		"e Q Q Q q q".asBeats.warpTo( e.tempoMap ),
		[

		],
		{|i|  
			Saw.ar(i.freqSeq,0.1)
			* Env.asr(0,1,3).kr(2,gate:i.gateSeq)
		},
		{|i| Splay.ar(i)}
	).play
});
P.synthVs(role: \spock, take: [\lead, \double],
	params: {|p b| [
	filter: (midinote: _ - 12), 
	lyrics: "The planet + has evidently + + + been dead since then.",
	legato: [[1, 1, 1, 0.8, 1, 1, 1, 0.7, 1, 1, 1, 0.8, ]],
	vocalMode: \Gentle,
	pitchTake: [1,3]
] }, music:[-0.1,0.1].collect{|pan|{|p b e|
	{
		e.playbuf
		=> p.synthVTracks.at(e.key).()
		=> Pan2.ar(_,pan)
		=> HPF.ar(_,400)
		/2
	}.play

}});
P.synthV(\kevin, take: \lead,
	filter: (midinote: 60), 
	params: {|p b| [
	lyrics: "r planet +",
	pitchTake: 1,
] }, music:{|p b e|
	{
		e.playbuf
		=> p.synthVTracks.at(e.key).()
		=> {|i| CombN.ar(i,0.3,0.3,3)/2 + i /6}
		=> Pan2.ar(_,1)
	}.play
});
P.synthV(\kevin, take: \bg2, params: {|p b| [
	filter: (midinote: 64), 
	lyrics: "r r r r r r dent lee r r r r r",
	pitchTake: 1
] }, music:{|p b e|
	{
		e.playbuf
		=> p.synthVTracks.at(e.key).()
		=> {|i| CombN.ar(i,0.3,0.3,3)/2 + i /6}
		=> Pan2.ar(_,1)
	}.play
});
P(\vibes, music: { |p b e|
	[
		freq: [\r,[4, 5, 11],7, 13].df(\c,6).q,
		dur: "e qq qq q".asBeats.warpTo( e.tempoMap ).q,
		strum: 0.06,
		out: Effect.bus({|i| i => FreeVerb.ar(_,0.5,1) * SinOsc.ar(3) * 2 },inputChannels:2)
	].pp
});
// P.tune();
Song.durs.filter(\evidently,{|i| var last = i.last; i.dropLast ++ (last * 0.75) });
["Sensors detect no life of any kind.","2 3 1 -6 1 4 1 2 3 4".dm(\e)].addLine;
P.still(\clear, timecode: 0.seconds, music: { |p b e|
	 e.still.( 
		wait: b.sum,
		text: ["sensors detect no life","of any kind"],
	)
});
P.synthV(role: \spock, take: \lead, params: {|p b| [
	lyrics: "Sensors + detect + no life of any + kind.",
	lag: [0.05,0 ,0 ,0 ,0 ,0 ,0 ,0 ,0 ,0 ],
	legato: [1, 1, 1, 1, 1, 1, 1, 1, 1, 0.7, ],
	filter: (midinote: _ - 12), 
	vocalMode: \Gentle,
	pitchTake: 1,
	loudness: Env([1,1,0],b.parse([2,8]) + [0,1])
] }, music:{|p b e|
	{
		e.playbuf
		=> p.synthVTracks.at(e.key).()
		=> HPF.ar(_,400)
		=> Pan2.ar(_)
		* -6.dbamp

	}.play
});
// P.tune();
P.tune(\detect, _ <> [freq: [1,4].df(\e,[5,6]),out:(1..4), amp:0.05].p);
P(\bass, music: { |p b e|
	[
		freq: [11, 5, 5, 5, 11].df(\a,3).q,
		dur: b.parse([6, 1, 1, 1, 1]).q,
		amp: 0.1
	].pp
});
[" All of your questions will be answered in time, Captain Kirk.", "4 3 2 1 2 2 3 2 1 -7 -7".dm(\c) ].addLine;/*SARGON [OC]:*/
P.synthV(role: \vocoder, take: \lead, params: {|p b| [
	filter: (midinote: 45!11), 
	lyrics: "All of your questions + will be answered + in time",
	pitchTake: 1
] }, music:{|p b e|
	p.vocodeTune.(p, b, e, e.rpp,
		modGain:1,
		gain: p.g2,
		carrierGain:1,
		dur: b.sum + 3,
		sus: b.sum + 3,
		durRel:2
	);
	{
		Song.laMer => PlayBuf.auto(2,_,rate: 0.midiratio ) / 8
	}.play(s,p.carrierBus)
});
P(\connector, music: { |p b e|
	[
		freq: [\r,6.5, 6].df(\d,4, \minor).q,
		dur: b.parse([9, 2]) ++ e.bNext.parse([9]) => _.q,
		amp:0.2,
		freqLag:2,
		instrument: \visual_pad
	].ppm
});
P.still(\sargon, timecode: 105.188.seconds, music: { |p b e|
	 e.still.( 
		wait: b.sum,
		text: ["all of your questions","will be answered in time"],
	)
});
[" Are your hailing frequencies open?","3 1 5 4 3 4 5 ".dm('e-',\lydian) ++ "3 1".dm(\d)].addLine;/*KIRK*/
P(\chord, music: { |p b e|
	[
		freq: [[1, 3, ].df(\e,4,\lydian), [1, 3, ].df('e-',4), [1, 3, ].df(\d,4,\whole) ].q,
		dur: b.parse([2, 5, 2]).q,
		instrument: \visual_pad
	].ppm
});
P.synthV(role: \kirk, take: \lead, params: {|p b| [
	filter: (midinote: _ - 12), 
	lyrics: " Are your hailing + frequencies + + open +",
	pitchTake: 1
] }, music:{|p b e|
	{
		e.playbuf
		=> p.synthVTracks.at(e.key).()
		=> Pan2.ar(_,-0.3)
		=> {|i| Fverb.ar(i[0], i[1],decay:5) /4 +i *0.6
	}		/2
	}.play

});
P.tune();
P.still(\kirkHailing, timecode: 111.8.seconds, music: { |p b e|
	 e.still.( 
		wait: b.sum,
		text: ["are your","hailing frequencies open"],
	)
});
[" No, sir.","1 -1".dm(\g)].addLine;/*UHURA:*/
P.synthV(role: \uhuru, take: \lead, params: {|p b| [
	lyrics: "no sir",
	pitchTake: 1
] }, music:{|p b e|
	{
		e.playbuf
		=> p.synthVTracks.at(e.key).()
		=> Pan2.ar(_,0.4)
		=> {|i| Fverb.ar(i[0], i[1],decay:5) /4 +i * 0.6}
		/2
	}.play

});
P.tune();
P.still(\UhuraSpeaking, timecode: 113.15.seconds, music: { |p b e|
	 e.still.( 
		wait: b.sum,
		text: ["no","sir"],
	)
});
["SARGON [OC]: I am Sargon.","1 -7 4 3".dm('c#')].addLine;
Song.g2 = 6.dbamp;
P.still(\sargon, timecode: 114.7.seconds, music: { |p b e|
	 e.still.( 
		wait: b.sum,
		text: ["I am","Sargon"],
	)
});
// P.tune()
P(\bassnotes, music: { |p b e|
	[
		freq: [ [-1, 1].df('c#',3),[-1,1].df('f#',2) ].q,
		dur: b.parse([2,2]).q,
		legato: [1, 0.8].q,
		amp: 0.1 * p.g2

	].pp;
	[
		freq: [\r, [ 3, 5, 11 ],[3,5,7]].df('f#').q,
		dur: b.parse([2,1,1]).q,
		strum: [0,0.05,0].q,
		instrument: \default,
		legato: [1, 1, 0.4].q,
		amp: 0.1 * p.g2
	].pp
});
P(\line, music: { |p b e|
	[
		midinote: "1 -7 -6 -5".dm('c#').q,
		dur: b.parse([ 1, 1, 1 ]).q,
		legato: 1,
		instrument: \stringyy,
		amp: 0.1 * p.g2
		
	].ppm;
	[
		freq: 1.df('c#'),
		dur: b.sum,
		instrument: \sawSynthSustain,
		att:[1].q,
		amp: 0.02 * p.g2
	].pp;
	(
		instrument: \cymbalsDS,
		att:0.1,
		lag: b.parse([2]).unbubble,
		amp: 0.01 * p.g2
	).play
});
// Require("boilerplate.sc");
P.synthV(role: \vocoder, take: \lead, params: {|p b| [
	lyrics: "I am sargon +",
	legato: [0.7, 1, 1, 0.7, ],
	pitchTake: 1,
	filter: (midinote: _ - 12), 
] }, music:{|p b e|
	p.vocodeTune.(p,b,e,e.rpp,
		modGain:1,
		gain:p.g2,
		carrierGain:2,
		dur: b.sum ,
		att:0,
		sus:b.sum,
		rel:0.05,
		durRel:1,
	)

});
["It is the energy of my thoughts which has","1 -7 1 3 4 3 1".dm('e-') ++ "1 4 3 4".dm(\e)].addLine;
P(\bassnote, music: { |p b e|
	[
		freq: [\r, 3.df('e-'), 4.df(\e,4) ].q / 4,
		dur: b.parse([3,5,3]).q,
		amp: 0.1 * p.g2
	].pp
});
P.still(\clear, timecode: 0.seconds, music: { |p b e|
	 e.still.( 
		wait: b.sum,
		text: ["it is the energy","of my thoughts which has"],
	)
});
// P.tune();
P.synthV(role: \vocoder, take: \lead,
	filter: (midinote: _ - 12), 
	params: {|p b| [
	lyrics: "It is the energy + + of my thoughts which has",
	pitchTake: 1,
]}, music:{|p b e|
	p.vocodeTune.(p,b,e,e.rpp,
		modGain:1,
		gain: p.g2,
		carrierGain:2,
		durRel: 1,
		// chord:#[2]
	)

});
P(\chord,syl: 7, music: { |p b e|
	(
		instrument: \stringyy,
		freq: [3, 5, 11].df('a',[3,4,5,6,7]).flat,
		out: [2,3,4],
		release: 12,
		amp: 0.1 * p.g2,
		attack:2
	).play
});
["(boom) touched your instruments and directed you here.","7 11 5 4 2 3".dm(\c) ++ "3 4 3 1 -5 11.5".dm('a',4)].addLine;
P.still(\clear,syl:0, timecode: 0.seconds, music: { |p b e|
	 e.still.( 
		wait: b.drop(1).sum,
		text: ["touched","your instruments"],
	).sequenceText2(
			b.drop(1).parse([5]), [ 
			["and directed you","here"],
			],
	)
});
P(\openStrings, music: { |p b e|
	[
		freq: [\r, [1,5,12].df(\g,4),[-5, 1, 4].df(\a,3), [-1,1].df('f#',3) ].q,
		dur: b.parse([3, 5, 3, 1]).q,
		strum: 0.05,
		instrument: \stringyy, mix: 0 ,
		amp: 0.1 ,
		instrument: \harp, mix: 0 , coef: 0.7, out: Effect.bus({|i| DWGReverbC1C3.ar(i) /2 },)
	].pp
});
P(\chord,syl: 10, music: { |p b e|
	(
		instrument: \stringyy,
		freq: [ 5, 11, 13].df('f#',[3,4,5,6,7]).flat,
		out: [2,3,4],
		release: 12,
		attack:2,
		amp: 0.1 * p.g2
	).play
});
P.tune(_ <> [rest: [\r, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1].q, instrument: \visual_pad, amp: 0.2 * Song.g2].p);
P(\note, music: { |p b e|
P.calcStart().postln;
	(
		freq: p.tune[e.start].list[0].midicps,
		instrument: \defaultPorto,
		amp: 0.1 //* p.g2
	).play;
	(
		freq: p.tune[e.start].list[0].midicps,
		instrument: \harp,
		amp: 0.1 //* p.g2
	).play;
	(
		freq: p.tune[e.start].list[0].midicps / [2,4],
		out: Effect.bus({|i| DWGReverbC1C3.ar(i) * 2 },),
		amp: 0.1 //* p.g2
		// instrument: \harp,
	).play
});
P.synthV(role: \vocoder, take: \lead, params: {|p b| [
	lyrics: "r touched your instruments + + and directed + + you here.",
	filter: (midinote: _ - 12), 
	pitchTake: 1
] }, music:{|p b e|
	p.vocodeTune.(
		p,b,e,e.rpp,
		modGain: 1.5,
		gain: p.g2,
		att:0, sus:b.sum-0.5, rel:0.55
	)

});
["Now at this closer distance","5 4 3 2 1 3 2 4 3 3 2 2 1 -7 -6 4.5".dm(\d)].addLine;
Song.durs.filter(_*1.3);
P.still(\clear, timecode: 0.seconds, music: { |p b e|
	 e.still.( 
		wait: b.sum,
		text: ["now at this","closer distance"],
	).sequenceText2(
			b.parse([7, 5, 2]), [ 
			["I can speak","to you"],
			["",""],
			["at","last"]
			],
	)
});
P.tune( { |i| i  <> [legato: 3,amp:0.03 * Song.g2].p => Pmul(\freq,[0.25,0.5,1],_) });
P(\pad, music: { |p b e|
	[
		instrument: \visual_pad,
		freq: 1.df(\a),
		dur: b.q,
		amp: 0.1 * p.g2
		// dur: b.sum
	].pp
});
P.synthV(role: \vocoder, take: \lead, params: {|p b| [
	lyrics: "Now at this closer + distance + I can speak to you r r at last",
	filter: (midinote: _ - 12), 
	pitchTake: 1
] }, music:{|p b e|
	var env = Effect.lfo({ Env.linen(2.5,b.sum-1,2, -10, 8).kr(2,gate:1)}).bus.index;
	{
PlayBuf.auto(2,Song.laMer,trigger:TDuty.ar(4,0), rate: [2,3].dq.demand(b.parse([ 14,2 ])).midiratio) /20
	}
	.play(s,p.carrierBus)
	;
	
	{
		Saw.ar(
			[ 1, -7 ].df(\a).dq.demand(b.parse([ 14,2 ])) /[2,3,4,8]// + Gendy1.arWidth(freq:0.1).range(-10,10)
			)
			* Env.linen(2,b.sum-1,1).kr /80
			=> Out.ar(p.carrierBus,_);
			// Silent.ar
	}.play;
	p.vocodeTune.(p,b,e,e.rpp,
		dur:b.sum + 2,
		modGain: 1,
		sus:b.sum + 3,
		gain: p.g2,
		att:1,
		// sus: b.parse([9]).sum,
		rel:2,
		mix:0.9,
		durRel:1

	);

	// fork{0.25.wait; Song.ambiSynth.map(\gain,env) } //use this if sus line is commented out
});
[" Who are you, Sargon?","-7 3 1 -7 -5".dm(\c,\mixolydian)].addLine;/*KIRK:*/
P.still(\kirk, timecode: 125.75.seconds, music: { |p b e|
	 e.still.( 
		wait: b.sum,
		text: ["who are you","Sargon?"],
	)
});
P.synthV(role: \kirk, take: \lead, params: {|p b| [
	lyrics: "Who are you sargon +",
	pitchTake: 1
] }, music:{|p b e|
	{
		e.playbuf
		// => p.synthVTracks.at(e.key).()
		=> Pan2.ar(_,0)
		=> {|i| Fverb.ar(i[0], i[1],decay:5) /4 +i *0.6}
		/3
	}.play

});
["SARGON [OC]: Please assume a standard orbit about our planet, Captain.","1 2 2 1 2 3 3 2 1 2 3/c# 4 3 2 1/e-".dm2].addLine;
P.still(\clear, timecode: 0.seconds, music: { |p b e|
	 e.still.( 
		wait: b.sum,
		text: ["please","assume"],
	).sequenceText2(
			b.parse([3, 5]), [ 
			["a standard","orbit"],
			["about our planet,","Captain"]
			],
	)
});
P(\bass, music: { |p b e|
	[		instrument: \sawSynthSustain,
		freq: [-21, -22].df('c#').q,
		att: 3,
		dur: b.parse([1, b.size-1]).q,
		legato: [2, 1].q,
		out: Effect.bus({|i| i * Line.kr(1,0,b.sum+1) },inputChannels:2),
		amp: 0.1 * p.g2
	].p.play
});
/* P.still(\listening, timecode: 127.7.seconds, music: { |p b e|
	 e.still.( wait: b.sum, text: ["",""],)
}); */
/* P.still(\kirk, timecode: 132.5.seconds, music: { |p b e|
	 e.still.( wait: b.sum, text: ["",""],)
}); */
P.synthV(role: \vocoder, take: \lead, params: {|p b| [
	lyrics: "Please assume + a standard + orbit + about + our planet + captain + ",
	pitchTake: 1
] }, music:{|p b e|
	p.vocodeTune.(p,b,e,e.rpp,
		chord: #[1,2,1.5,4],
		mix: 0.9,
		width:1.02,
		modGain:2 ,
		gain: p.g2,
		wet:0.1
	)

});

[" Is that a request or demand?","3 5 7 11 13 11 7 5 15".dm(\e,\mixolydian)].addLine;/*KIRK:*/
P(\bassline, music: { |p b e|
	[
		freq: [3,-6.5].df('e',\mixolydian).q,
		instrument: \stringyy,
		dur: b.parse([8, 1]).q, 
		amp: 0.2,
		out: Effect.bus({|i| i * Env([0.3, 1], b[..8].sum).kr(0,gate:1) },)
	].ppm
});
P.still(\kirkRequest, timecode: 131.6.seconds, music: { |p b e|
	 e.still.( 
		wait: b.sum,
		text: ["is that a request","or a demand"],
	)
});
P.synthV(role: \kirk, take: \lead, params: {|p b| [
	filter: (midinote: _ - 12), 
	lyrics: "Is that a request + or a demand +",
	loudness: Env([ 3,0,3,0,3,0,3,0,3 ] ,b + [0.1,0,0,0,0,0,0,0,0]),
	legato: [1, 1, 1, 1, 0.9, 1, 0.7, 1, 1, ],
	pitchTake: 1
] }, music:{|p b e|
	{
		e.playbuf
		// => p.synthVTracks.at(e.key).()
		=> Pan2.ar(_,0)
		=> {|i| Fverb.ar(i[0], i[1],decay:5) /4 +i *0.6}
		/3
	}.play

});
P.tune(_ <>[instrument:\harp].p);
["SARGON [OC]: The choice is yours.","1 1 1 5".dm('f#')].addLine;
P(\bassnote,syl:2, music: { |p b e|
	(
		freq: [-11,-1].df('f#'),
		out: Effect.bus({|i| DWGReverbC1C3.ar(i) },),
		amp: 0.1 * p.g2
	).play
});
P.still(\clear, timecode: 0.seconds, music: { |p b e|
	 e.still.( 
		wait: b.sum,
		text: ["the choice","is yours"],
	)
});
P.synthV(role: \vocoder, take: \lead, params: {|p b| [
	lyrics: "the choice is yours",
	// filter: (midinote: _ - 12), 
	filter: (midinote: 50!4), 
	pitchTake: 1
] }, music:{|p b e|
	p.vocodeTune.(p,b,e,e.rpp,
		echo:0.2, modGain:4,
		gain: p.g2,
		chord: #[2,4,6,8],
		att:0,
		// sus:10,
		// rel:5,
		dur:b.sum,
		mix: 0.99
	)

});
/* P.still(\sargonreads, timecode: 140.seconds, music: { |p b e|
	 e.still.( 
		 fadeIn:2,
		wait: b.sum,
		text: ["",""],
	)
}); */
["I read what is in your mind.","3 11 7 3 2 7 3".dm(\d)].addLine;
P(\bassline, music: { |p b e|
	[
		freq: [2, 1, -7].df('e',[3,4],\mixolydian).q,
		instrument: \stringyy,
		width:{4.rrand(8.0)}!4,
		dur: b.parse([4, 2, 1]).q,
		amp: 0.2 ,
		out: (0..4)
		// out: Effect.bus({|i| i * Env([0.3, 1], b[..8].sum).kr(0,gate:1) },)
	].ppm
});
P.still(\clear, timecode: 0.seconds, music: { |p b e|
	 e.still.( 
		wait: b.sum,
		text: ["I read what is","in your mind"],
	)
});
P(\chords, music: { |p b e|
	[
		freq: [ [2,2], [1,3], [-7, 6] ].df(\e,[4,5],\mixolydian).q,
		dur: b.parse([4, 2, 1]).q,
		instrument: \stringyy, mix:0.1,amp:0.05,
		out: p.carrierBus
	].pp;
	[
		freq: [ [2,2], [1,3], [-7, 6] ].df(\e,4, \mixolydian).q,
		dur: b.parse([4, 2, 1]).q,
		instrument: \stringyy, mix:0.1,amp:0.05,
		out: 0
	].pp;

});
P.tune( _ <> [instrument: \sawSynth, out: Song.carrierBus, amp:0.02].p );
P.synthV(role: \vocoder, take: \lead, params: {|p b| [
	filter: (midinote: 45!7), 
	lyrics: "I read what is in your mind",
	pitchTake: 1
] }, music:{|p b e|
	p.vocodeTune.(p,b,e,e.rpp,
		modGain:2,mix:0.8,width:1.01,
		gain: p.g2,
		rel:0.1,sus:b.sum, att:0
	)

});
P.tune();
["Words are unnecessary.","3 4 5  2 1 -7 -6".dm('a-', \mixolydian)].addLine;
P.still(\clear, timecode: 0.seconds, music: { |p b e|
	 e.still.( 
		wait: b.sum,
		text: ["words are","unnecessary"],
	)
});
P.tune({|i| i=>_.fin(3) <> [instrument: \visual_pad, legato: [1, 1, 3 ],amp:0.15].pm});
P.synthV(role: \vocoder, take: \lead, params: {|p b| [
	lyrics: "words are unnecessary + + + +",
	filter: (midinote: 48), 
	pitchTake: 1
] }, music:{|p b e|
	p.vocodeTune.(p,b,e,e.rpp,
		modGain:1.5,
		gain: p.g2,
		chord:#[1,4],
		durRel:2,
	)

});
P(\connector, music: { |p b e|
	[
		freq: [\r,2, 1, -7, -6, -5.5].df('a-',[4, 5],\mixolydian).q,
		dur: e.bAll.parse([3, 1, 1, 1, 1, 3]).q,
		instrument: \sparkTriangle, depth: 0.01, amp: 0.03, out:2
	].ppm
});
[" The planet is dead.","1 1 1 1 4.5".dm(\c)].addLine;/*KIRK:*/
P(\growl, music: { |p b e|
	(
		instrument: \stringyy,
		freq: [-21,-11].df(\c,[4,5]),
		mix:0, amp:0.06, out: Effect.bus({|i| i=>HPF.ar(_,200) },inputChannels:2)
	).play
});
P.still(\kirkDead, timecode: 143.1.seconds, music: { |p b e|
	 e.still.( 
		wait: b.sum,
		text: ["the planet is","dead"],
	)
});
P.tune(_ <>[instrument:\harp].p);
P(\accent,syl:3, music: { |p b e|
	{
		SawBL.ar(
			// freq: Gendy1.arWidth(freq: [1, 4, 11, 14].df(\c,3)),
			freq:[1,4.5,3, 11, 14.5].df(\c,3)
			+ Gendy1.arWidth(freq:{ 0.5.rrand(1) }!4,width:1.01).range(-10,10)
		)
		+ Gendy1.arWidth(freq:[1, 4.5, 11, 14.5].df(\c))
		* Env([1,0],b.drop(1).sum + 5).kr(2,gate:1)
		/60
	}.play
});
P.synthV(role: \kirk, take: \lead, params: {|p b| [
	lyrics: "the planet + is dead",
	legato: [1, 1, 1, 1, 0.66, ],
	pitchTake: 1
] }, music:{|p b e|
	{
		e.playbuf
		=> p.synthVTracks.at(e.key).()
		=> Pan2.ar(_,0)
		=> {|i| Fverb.ar(i[0], i[1],decay:5) /4 +i *0.6}
		/3
	}.play

});
["There's no possibility of life there as we understand life.","1 2 4 3 2 1 -6 2/d 4 3 1 2 2 3 3/e 3/b-/4".dm2].addLine;
P(\bass, music: { |p b e|
	[
		freq: [-5, -6, -16, -1].df(\d).q,
		dur: b.parse([4, 4, 6, 2]).q,
		// stretch: [1, 1, 2].q,
		instrument: \reedy,
		out: Effect.bus({|i| Fverb.ar(i,i,decay:80)/2 + i },),
		amp: 0.04
	].ppm;

});
P(\connector,syl: 9, music: { |p b e|
	[
		// instrument: [\harp, \stringyy],
		instrument: \sparkTriangle, depth: 0.001, amp: 0.05, out: 3,
		freq: "1 2 2 3 3 -6.5 4.5  5".df('e').q,
		dur: b.drop(1).parse([1, 1, 1, 1, 1, 1]) ++ e.bNext => _.q,
		// amp: [0.02,0.2],
		coef: 0.1
	].ppm
});
P.still(\clear, timecode: 0.seconds, music: { |p b e|
	 e.still.( 
		wait: b.sum,
		text: ["there's no possibility","of life there"],
	).sequenceText2(
			b.parse([10]), [ 
			["as we understand","life"],
			],
	)
});
P.synthV(role: \kirk, take: \lead, params: {|p b| [
	lyrics: "There's no possibility + + + + of life there as we understand + + life.",
	pitchTake: 1
] }, music:{|p b e|
	{
		e.playbuf
	=> p.synthVTracks.at(e.key).()
	=> Pan2.ar(_,0)
		=> {|i| Fverb.ar(i[0], i[1],decay:5) /4 +i *0.6}
		/3
	}.play

});
P.tune();
[" [OC]: And I am as dead as my planet.","5 6 5 4 3 2 3 2 1".dm('e-',\minor)].addLine;/*SARGON:*/
P(\bassline, music: { |p b e|
	[
		freq: [5, 6, 5, 4, 3, 2, -7.5, [-1, -5, 1]].df('e-',[ 3,3 ], \minor).q,
		dur: b.q + [0,0,0,0,0,0,0,8].q,
		// legato: [1, 1, 1, 1, 1, 1, 1, 5, ].q,
		instrument:\reedy,
		amp: 0.1 * p.g2,
		out:[0,1],
	].ppm
});
P.still(\clear, timecode: 0.seconds, music: { |p b e|
	 e.still.( 
		wait: b.sum,
		text: ["and I","am as dead"],
	).sequenceText2(
			b.parse([5, 4]), [ 
			["as my","planet"],
			["does that frighten you", "James Kirk"]
			],
	)
});
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
		gain: p.g2,
		enlarge: 7, tune: p.tune[e.start].list ++ p.tune[e.start+1].list, dur: b.sum + e.bNext.sum + 2, sus:b.sum+e.bNext.sum+2)
});
/// end here???
["Does that frighten you, James Kirk?","4 3 7 5 3 2 1/b-/mixolydian/4".dm2].addLine;
P.still(\suluAndSomeone, timecode: 150.seconds, music: { |p b e|
	 e.still.( 
		wait: b.sum,
		text: ["does that frighten you","James Kirk"],
	)
});
P.tune(_ <> [instrument: \visual_pad,amp:0.15].pm);
// ["For if it does,","r"].addLine;
// ["if you let what is left of me perish,","r"].addLine;
// ["then all of you, my children,","r"].addLine; 
// ["all of mankind must perish, too.","r"].addLine;

)


