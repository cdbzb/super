/*
[Bridge]
*/
( s.waitForBoot( {
	 //Setup Monitor for back channels
	 Song(\ending,[]).current;
	 "~/tank/super/Trek/Songs/boilerplate.scd".standardizePath.load;
	 {
		 ( ~synful1.isNil or: try{ ~synful1.syn.isPlaying.not } ).if
		 {
			 Song.currentSong.synful1 = ~synful1 = Synful();
			 Song.currentSong.synful2 = ~synful2 = Synful();
		 }{
			 Song.currentSong.synful1 = ~synful1;
			 Song.currentSong.synful2 = ~synful2;
		 };
		 Song.resources.condition=Condition();
		 Song.resources.infrastructure=
		 {
			 FunctionList.new.array_([
				 ( ~synful1.isNil or: try{ ~synful1.syn.isPlaying.not } ).if
				 {
					 Song.currentSong.synful1 = ~synful1 = Synful();
					 Song.currentSong.synful2 = ~synful2 = Synful();
				 },
				 { fork {
					 while( {
						 ~synful2.controller.loaded.not;
					 },{0.05.wait});
					 Song.resources.condition.test_(true).signal
				 }}
			 ]).value
		 }.inEnvir;
( Song.synthVTracks=EventWithDefault(
	\default, {
		{
			|i|
			var early = 0.5;
			var dryAmount = 1;
			EarlyRef.ar(i, source:[2,3,2], receiver:[0,0,0], roomsize:[4,5,6], hw:0.2, b:0.97, n:0, p:0, allp_lens:nil, allp_c:0.7)

			=> DWGReverbC1C3.ar(_, len:2000, c1:1, c3:10, mix:1-early /2,)
			+ ( i * dryAmount )
			/ 6 
			=> HPF.ar(_,100)
			=> DCompressor.ar(_, sidechainIn:0, sidechain:0, ratio:4, threshold:-40, attack:0.1, release:100.1, makeup:0.5, automakeup:1)
		}
	},
	\asterian, { 
		{
			|i|
			var early = 0.5;
			var dryAmount = 1;
			var dirty = VALadder.ar(i,1000,0.5,overdrive:0.8);
			dirty / 4
			=> EarlyRef.ar(_, source:[2,3,2], receiver:[0,0,0], roomsize:[4,5,6], hw:0.2, b:0.97, n:0, p:0, allp_lens:nil, allp_c:0.7)
			//
			=> DWGReverbC1C3.ar(_, len:2000, c1:1, c3:10, mix:1-early,)
			+ ( dirty /8 )
			// + ( i * dryAmount )
			// / 6 
		}
	}
));
	 }.value;
[ "(Uhura is screaming in terror before collapsing across her console. Chapel is standing rigid by the Captain's chair.) ","7 7.5/f/mixolydian".dm2, ].addLine;
{
P.still(\uhura, timecode: 4751.seconds, music: { |p b e|
	 e.still.( 
		wait: b.sum,
		text: ["",""],
	)
});
P.synthV(\cheng, take: \lead, params: {|p b| [
	lyrics: "aaaeaa r",
	filter: (midinote: _ + 12), 
	language: \Mandarin, vocalMode: \opera,
	// vocalMode: \Overdrive,
	pitchTake: 1,
	pitchDelta: Env( Array.rand(40,-100,100 ), Array.rand(39,0.02,0.07) )
] }, music:{|p b e|
	{
		e.playbuf
		=> PitchShift.ar(_, windowSize:0.2, pitchRatio:
			Gendy1.ar().range(0.98,1.01)
			, pitchDispersion:0.0, timeDispersion:0.0, mul:1.0, add:0.0)
		=> p.synthVTracks.at(e.key).()
	}.play

});
P(\notes, music: { |p b e|
	[
		freq: [1, 3, 5, 7].df(\f,\mixolydian).bubble ++ 1.df(\e,3).bubble => _.q,
		dur: b.q
	].pp
});
P.still(\collapse,lag:2, timecode: 4754.1.seconds, music: { |p b e|
	 e.still.( 
		wait: b.sum,
		text: ["",""],
	)
});
P(\bassnote, music: { |p b e|
	[
		freq: [\r, [-1,1],\r, -2].df(\e,3).q,
		instrument: \stringyy,mix: 0,amp:0.4,
		dur: e.bAll.parse([1, 1,1]).q,
		// legato: [0.7,1]
	].pp
});
["walking","r", [3]].addLine;
P(\walking, music: { |p b e|
	[
		freq: [1, 2, 3, 4].df(\e,\whole)=> Prand(_,inf),
		dur: 0.01,
		amp: Penv([0.01,0.1,0.1,0],b.sum/2),
		out: Pwhite(0,4)
	].p.findur(b.sum).play
});
P.still(\walking, timecode: 4800.73.seconds, music: { |p b e|
	 e.still.( 
		 fadeIn:1,
		wait: b.sum,
		fade: 1,
		text: ["",""],
	)
});
["SPOCK: (beat) Must I make an example of you, too, Helm? ",[4.5, 1, 2, 2, 3, 3, 3, 4.5, 4.5, 7, 5.5,7, 1].dm('f#',scale:\mixolydian)].addLine;
// Song.durs[\example].list.registerD
P(\walking,syl:0, music: { |p b e|
	[
		freq: [1, 2, 3, 4].df('f#',\whole)=> Prand(_,inf),
		dur: 0.01,
		amp: Penv([0.01,0.05,0.05,0],b.sum/3),
		out: Pwhite(0,4)
	].pp
});
P(\chord, music: { |p b e|
	[
		freq: [\r, [ 13, 14, 6]].df('f#',2,\whole).q,
		instrument: \stringyy,
		mix: 0,
		amp:[0.4, 0.2].q,
		out: [0,2].q,
		dur: b.q
	].p.play
});
	// P.tune(\example);
	//4806.66 nice red door....
P.still(\medium, timecode: 4806.25.seconds, music: { |p b e|
		e.still.( 
			wait: b.sum,
			text: ["",""],
		).sequenceText2(
			b.parse([1,7]), [
				["must I make","an example"],
				["of you too,","Helm?"]
			]
		)
});
P.synthV(role: \henoch, take: \lead,
		filter: (midinote: _ - 12), 
		params: {|p b| [
			vocalMode: \Overdrive,
			lyrics: "r must I make an axample + + of you - too Helm",
			legato: [1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 0.6, 0.8, ],
		] }, music:{|p b e|
			{
				e.playbuf
				=> p.synthVTracks.at(e.key).()
			}.play
});
["they enter",[1]].addLine;
P(\door, music: { |p b e|
	Synth(\door,[\amp,0.2])
});
P.still(\enter, timecode: 4808.seconds, music: { |p b e|
			e.still.( 
				wait: b.sum,
				text: ["",""],
			)
});
[ "/*SPOCK*/ Pain, Captain. (oooh) A-- nd you, my dear? " ,[12,11,7,6].dm(\g) ++ [7,11,5,3].dm('c#',octave:6)].addLine;
P.synthV(role: \henoch, take: \lead, params: {|p b| [
			filter: (midinote: _ - 24), 
			lyrics: "Pain captain + r and  you my dear",
			legato: [0.7, 1, 0.7, 1, 1, 1, 1, ],
			vocalMode: \Overdrive,
			pitchTake: 1
		] }, music:{|p b e|
			{
				e.playbuf
				// => p.synthVTracks.at(e.key).()
				=> Pan2.ar(_,0)
				/2
			}.play

});
P.still(\henoch_close, timecode: 4809.9.seconds, music: { |p b e|
			e.still.( 
				wait: b.parse([3]).unbubble,
				text: ["pain","captain"]
			)
});
P.still(\kirk_pain,syl:2, timecode: 4813.3.seconds, music: { |p b e|
			e.still.( 
				wait: b.drop(1)[0],
				fade:1
			);
			(freq:6.df(\g) + [0,5,11,23] , out: Effect.bus({|i| DWGReverbC1C3.ar(i) },)).play
});
P.tune(\Pain);
P.still(\turnedHead,syl:3, timecode: 4814.seconds, music: { |p b e|
	 e.still.( 
		wait: b.sum,
		text: ["and you","my dear"],
	)
});
P(\chord,start:\Pain,music:{|p b e| 
			MegaBind(
				[
					[1,\r,4.5],
					[3,\r,3],
					[5,\r,11.5],
					[7,\r,6.5]
				].df(\g),
				b.parse([3,3,2]),
				[
					vowel1: [\a,\i,\e,\u],
					vowel2: [\a,\i,\e,\u].scramble,
					rate: {0.25.rrand(0.15)}!4
				],
				{|i|
					Formants.ar( i.freqSeq, Vowel(i.vowel1,\alto).blend(Vowel(i.vowel2), SinOsc.kr(i.rate).range(0,1)))
					* Env.asr(3,1,3).kr(2,gate: i.gateSeq)
				},
				{|i|
					Splay.ar(i)
					*0.1
				}
			).play
});
P(\bassnote,start:\Pain,syl:2,music:{|p b e| 
			(degree:1,instrument:\stringyy,octave:[5],amp:0.4).play
});
P(\bassline,start:\Pain,music:{|p b e| 
			[
				freq:[ 1,3,4,-4.5 ].df(\g,octave:3).q,
				dur:b.parse([2,1,2,3]).q
			].pp
});
P(\cymbals,start:\Pain,music:{|p b e| 
			Synth(\cymbalsDS,[out:Effect(_*Line.kr(0,1,5)).bus.index])
});
P(\cymbals,start:\Pain,music:{|p b e| 
			Synth(\cymbalsDS,[out:Effect(_*Line.kr(0,1,5)).bus.index])
});
P(\cymbals2,start:\Pain,syl:5,music:{|p b e| 
			Synth(\cymbalsDS,[out:Effect(_*Line.kr(0,1,6)).bus.index])
});
P(\bassNote2,start:\Pain,music:{|p b e| 
			[
				dur:b.parse([3,2,2]).q,
				freq:[1,\r].df(\g,octave:3).q,
				instrument:\sawSynthSustain,
				octave:3,
				att:1,
				amp:0.1 
			].p.play
});
//TIME Leave time
[ "As Kirk and Mulhall double over, McCoy dashes to Spock's side, to inject him. /*SPOCK*/ Fortunately, Doctor," ,[-14.5,3,2,1,-7,-6.5,-7].dm(\f,scale:\minor)].addLine;
P.still(\comboShot, timecode: 4819.5.seconds, music: { |p b e|
	 e.still.( 
		wait: b.sum,
		text: ["",""],
	)
});
P.still(\bridge,syl:0, timecode: 4821.seconds, music: { |p b e|
	 e.still.( 
		wait: b.sum,
		text: ["fortunately","doctor"],
		fade: e.bNext.sum
	).sequenceText2(
			[b.drop(1).sum] ++ e.bNext.parse([6,8]), [ 
			["I know ","every thought" ],
			[ "of every mind","around me" ],
		]
	)
});
P(\chords, music: { |p b e|
	[
		freq: [\r,[7,11,13],[6,11,14]].df('b-',3,\mixolydian).q,
		dur: b.parse([5, 1, 1]).q,
		instrument: \pulse ,
		amp:0.12
	].pp
});
P(\line, music: { |p b e|
	[
		freq: [\r,4, 3, 2, 1, -5].df('e-',[ 6, 7 ]).q,
		dur: b.parse([1, 1, 1, 1, 1, 2]).q,
		instrument: \sparkTriangle,
		depth: [0,0,0,0,0,0.02,].q,
		amp:0.025,
		out: Effect.bus( { |i|  [i,0] + ([0,1] * CombN.ar(i, b[1],b[1])) }, out: 2 )
	].ppm
});
P(\bassnote, music: { |p b e|
	[
		freq: [\r,5,11,1].df('e-',2).q,
		dur: b.parse([5, 1]) => _.q,
		instrument:\sawSynth,
		out: Effect.bus( FreeVerb.ar(_,1,1) )
	].pp
});
P.synthVs(role: \henoch, take: [ \lead,\double ], params: {|p b| [
	lyrics: "r fortunately + + + doctor +",
	vocalMode: \Overdrive,
	//vocalMode: \Muted,
	legato: [ [1, 1, 1, 1, 1, 1, 0.80, ] ],
	filter: (midinote: _ - 12), 
	pitchTake: [ 1,3 ],
	loudness: Env([3,3, 0, 0, 4, 2], b.parse([1,1, 1, 1, 1]))
] }, music:{|p b e|
	{
		e.playbuf
		=> Pan2.ar(_,0)
		/2
		// => p.synthVTracks.at(e.key).()
	}.play

});
P(\trem,start:\Fortunately,music:{|p b e| 
		(freq:[-11,-21].df('b-'),instrument:\trem2,amp:0.2,out:1,scale:2,dur:b.sum,
		//out:Effect(FreeVerb.ar(_,0.4,1),inputChannels:1).bus.index
	).play
});
	}.value;
[ "I know every thou-- ght of every mind around me." ,[3, 1, 4, 2, -7.5, -6, -5, 3,4,5,7,6,5,4].dm('e-',scale:\mixolydian)].addLine;
P(\cymbal, music: { |p b e|
	(instrument: \cymbalsDS,amp:0.02).play
});
Song.setTempoMap('every mind',"e e e x xe x x e e e x xx x e");
	// P.tune();
P.synthVs(role: \henoch, take: [ \lead, \double ],
	filter: (midinote: _ - 12), 
	pitchTake: [1,3],
	params: {|p b| [
	lyrics: "I know evree + thought - of evree + mind a round - me  r",
	legato: [ [1,1,1,1,1,1,1,1,1,1,1,1,1,0.8] ],
] }, music:{|p b e|
	{
		e.playbuf
		 => p.synthVTracks.at(e.role).()
		 // /6
	}.play
});
P(\chords, music: { |p b e|
	[
		freq: [[5, 11, 13], [6, 11, 14], [5, 7.5, 12], [5, 11, 13], [4, 7, 12], [6, 11,14]].df('e-',\mixolydian).q,
		dur:" q q qq q q x".asBeats.warpTo( e.tempoMap ).q,
		instrument: \stringyy,
		amp:0.25
	].pp
});
P(\bass, music: { |p b e|
	[
		freq: [1, -4, -5, 1, -7, -4].df('e-',3,\mixolydian).q,
		dur: "eee e q q q q".asBeats.warpTo( e.tempoMap ).q,
		instrument: \sawSynth,
		amp: 0.2
	].pp
});
P(\tamb, music: { |p b e|
	{
	var levels = [5,1,2,1] /5 => _.dq(inf);
	var durs =  
	1/4 ! 21
	+ ( [1, -1] /50 => _.dup(8) )
	=> _.flat 
	=> _.warpTo(e.tempoMap
		.quantizeDft(0.5)
	)
	=> _.dq();
	var triggers = TDuty.kr( durs, 0,1,gapFirst:0 );
	var energy = EnvGen.ar( Env.linen(0, 0.00, 0.015), triggers, doneAction:0   ) 
		* Demand.kr(triggers,0,levels 
			// * 40
			// *8
		);
	Shakers.ar(3, energy:energy   , decay: 1).tanh
	=> Pan2.ar(_, 0.8)
}.play;

});
	// P.tune('every mind');
P(\drums, music: { |p b e|
		[
			"eeee e e eeee e e", 'bd_808', \amp,1/4,
			"ee ex xeeee ex xee",\sn_808,\amp,[0,1,0.5,1,0.5] /4 =>_.q
		].dmx2(1, e.tempoMap.quantizeDft(0.5))
		=> Ppar(_)
		=> _.play
});
[ "See? (to Chapel) Take the hypo from him. And inject him with it. " ,[1,5,5,12,12,6,6].dm(\a,octave:4) ++ [5.5,6,7,5,3,1].dm(\c,scale:\mixolydian)].addLine;
P.still(\henochToChapel, timecode: 4829.566.seconds, music: { |p b e|
	 e.still.( 
		wait: b[0..6].sum,
		text: ["see?","take the hypo from him"],
	).sequenceText2(
			b.parse([7]), [ 
			["and inject","him with it"],
			],
	)
});
Song.durs.filter( _ * [1.5,1,1,1,1,1,1,1,1,1,1,1,1] );
P.tune( _ <> (instrument: \sparkTriangle) );
P.synthVs(role: \henoch, take: [ \lead, \double ],
		filter: (midinote:  { |i| i - 12 + [12, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0]}),
		params: {|p b| [
		lyrics: "See Take the hypo + from him. And inject + him with it. ",
		legato: [ [0.6, 1,1,1,1,1,0.4, 1,1,1,1,1,0.7] ],
		lag: [ [0.1, 0,0,0,0,0,0,0,0,0,0,0,0] ],
		pitchTake: [1,3]
	] }, music:{|p b e|
		{
			e.playbuf
			// => {|i|  PitchShift.ar(i,[0.03, 1 ],0.5,0.01,timeDispersion:0.7) + ( i * 0.8 )}
			=> p.synthVTracks.at(e.key).()
			// /6
			// /3
		}.play
});
	// P.tune('Take the hypo');
P.still(\chapelMoves,syl:6, timecode: 4835.04.seconds, music: { |p b e|
		 e.still.( 
			wait: b.drop(1).sum,
			text: ["and inject","him with it"],
		)
});
["move move","e- e"].addLine;
Song.durs('move move',{|i| i/4});
P.still(\chapelMoves2,timecode: 4840.05.seconds, music: { |p b e|
		 e.still.( 
			wait: b.sum,
			text: ["",""],
		)
});
P.tune( _ <> (instrument: \stringyy, amp:0.4 ) );
[ "(But she injects Spock/Henoch instead! He leaps from his seat.) /*SPOCK*/ Fools. I'll simply transfer to another place, another body. " ,[-6,6.5,11.5,3,4,11,7,11, 7, 6, 5, 11, 7, 2, 6,6.5,2,4,3].dm(\e,octave:4)].addLine;
P(\pad, music: { |p b e|
	[
		freq: [
			\r,
			[3, 5, 11.5],
			[4, 5, 11.5],
			[4, 5, 11],
			[4, 5, 7],
			[4, 5, 11],
			[4, 5, 7],
		].df(\e).q,
		amp: 0.015,
		att: b[1],
		dur: b.parse([1, 3, 1, 1, 1, 1, 1]).q,
		instrument: \sparkTriangle, depth:0,
		out: (2..4)
		// out: Effect.bus( { |i|  [i,0] + ([0,1] * CombN.ar(i, b[1],b[1])) }, out: 2 )
	].ppm
});
// P.tune();
P(\gliss, music: { |p b e|
	{
		var freq = [-6, 6.5].df(\e).dq;
		Hasher.ar(Sweep.ar(Impulse.ar( freq.demand(b[..1]).lag2([0,1].dq.demand(b[..1])) )))
		/50
		* EnvGen.cutoff(wait:b[..1], release:2, curve:nil, doneAction:2)
	}.play
});
P.still(\stab, timecode:
	// 4842.20.seconds,
	4842.45.seconds, music: { |p b e|
		 e.still.( 
			wait: b[0..1].sum, 
			text: ["",""],
		)
});
P.still(\smiles,syl:0, timecode: 4845.seconds, music: { |p b e|
		 e.still.( 
			wait: b[0].sum,
			// fadeIn:1,
			fade:1,
			text: ["",""],
		)
});
P.still(\spockFools,syl:1, timecode: 4849.seconds, music: { |p b e|
		 e.still.( 
			wait: b.drop(1).[..12].sum,
			fade:2,
			// fadeIn:1,
			text: ["Fools","I'll simply transfer"],
		).sequenceText2(
				b.drop(1).parse([7, 5]), [ 
				["to another","place"],
				["",""]
				// ["another","body"]
				],
		)
});
P.still(\clear, syl:13, timecode: 0.seconds, music: { |p b e|
	 e.still.( 
		wait: b.drop(1).sum,
		text: ["another","body"],
	)
});
	// P.tune(\leaps);
P.synthVs(role: \henoch, take: [\lead, \double], params: {|p b| [
		lyrics:" r r Fools. r I'll simply + trance fur to another + + place, another + + body +" ,
		legato: [[1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1,1, 1, 0.6, 1, 1, 1, 1, 0.8 , ]],
		pitchTake:[1, 3],
		loudness: Env([3, 3, 0, 0], b.parse([3, 1,15])),
		vocalMode: \Theatrical
	] }, music:{|p b e|
		{
			e.playbuf
			// => {|i|  PitchShift.ar(i,[0.03, 1 ],0.5,0.01,timeDispersion:0.7) + ( i * 0.8 )}
			=> p.synthVTracks.at(e.key).()
			/2
		}.play
});
P(\line,start:\leaps,syl:12,music:{|p b e| 
		MegaBind(
				[
					[2,1.5,2,\r,\r],
					[\r,\r,\r,-7,-5],
					[-17,\_,\_,1,\_]
				].df(\e,scale:\mixolydian),
				b.drop(1).parse([1,2,1,2/3,[1/3,1]]),
				[
					azimuth: [-pi/2, pi/2, -pi], //l,r,r
					cutoff: [8000,5000,2000],
					q:[1,2,1]
				],
				{|i|
					Saw.ar( i.freqSeq.lag(0.1)/2 )
					* Env.asr(1,1,3).kr(0,gate:i.gateSeq)
					//=> MoogFF.ar(_,i.cutoff)
					=> FoaEncode.ar(_,Song.encoders.omni)
					//=>FoaTransform.ar(_,'push',i.azimuth,i.azimuth,i.azimuth)
					=>FoaPushX.ar(_,pi/2)
					=> FoaRTT.ar(_,i.azimuth)
				},
				{|i|
					Mix.ar(i)
					=> Monitors.ambi(_)
					*0.05
				}
			).play;
		
});

P(\stab,start:\leaps,music:{|p b e| 
		var amb = { |i| FoaEncode.ar(i,Song.encoders.spread)	=> FoaRTT.ar(_,SinOsc.ar(0.15).range(-pi,pi))=> Monitors.ambi(_) };
		var g = Group.before(s.defaultGroup);
		amb = {|i| i};
		Synth(\cymbalsDS,[out:Effect({|i| i=> PitchShift.ar(_,0.1)=> CrossoverDistortion.ar(_) *0.065 * Env.linen(0,3,5).kr(2,gate:1) => amb }).bus.index],target:g);
		Synth(\default,[\freq,[1,-1].df('c#',octave:[3]),out:Effect({|i| i=> CrossoverDistortion.ar(_) *0.065 * Env.linen(0,3,5).kr(2,gate:1) => amb }).bus.index],target:g);
		fork{8.wait;g.free}
});
//(He whirls around.) 
["SPOCK: Sargon! No, Sargon, please. Let me. Let me transfer. ",[11,1].dm('f')++[5,3,1].dm('b-',scale:\whole) ++ [5,5,4,3,2].dm(\d,octave:6) ++ [3,1].dm('f#',octave:6)].addLine;
Song.durs.filter( _ + [0, 0.5, 0, 0, 0, 0.25, 0, 0, 0, 0, 0, 0, 0,] );
P.still(\ohno, timecode: 4900.25.seconds, music: { |p b e|
		 e.still.( 
			wait: b[..2].sum,
			fade: b[3..].sum,
			text: ["",""],
		)
	});
P.still(\clear,lag: 0.01, timecode: 0.seconds, music: { |p b e|
		 e.still.( 
			wait: b.sum,
			text: ["Sargon!",""],
		).sequenceText2(
				b.parse([2,4, 2, ]), [ 
				["no, Sargon","please"],
				["let", "me"],
				["let me", "transfer"]
				],
		)
});
P.synthV(role: \henoch,
		filter: (midinote: _ - 12), 
		params: {|p b| [
		lyrics: "Sargon! + No Sargon + please! let me let me transfer +",
		paramTension: 0.9,
		legato: [1, 0.7, 0.7, 1, 1, 0.7, 1, 0.7, 1, 1, 1, 0.4],
		vocalMode: \Theatrical
	] }, music:{|p b e|
		{
			e.playbuf
			// => {|i|  PitchShift.ar(i,[0.03, 1 ],0.5,0.01,timeDispersion:0.7) + ( i * 0.8 )}
			=> p.synthVTracks.at(e.key).()
			// /2
		}.play
});
P(\rising, music: { |p b e|
		{
			SinOsc.ar( Line.kr(400 * ({Rand(1.0,2.0)}!4),900,30) )
			+ SinOsc.ar(3000 + [7,11,13],0,0.1)
			/8
			=> SineShaper.ar(
				_, 0.1
			) => _.tanh
			* Env([0,0,1,0], b.parse([11,1,1]) + [0,0,e.bNext]).kr(2,gate:1)
			=> FreeVerb.ar(_,0.3,1)
			/8
		}.play
});
// P.tune(\please,Pmul(\freq,0.5,_));
P(\alarum,start:\please,music:{|p b e| 
	MegaBind(
			[
				[1].df(\f),
				[1.5].df(\f),
				[1].df(\f),
				[1.5].df(\f),
			],
			b.sum,
			[width:[0.5,12,0.5,12]],
			{|i|

				Gendy1.arWidth(freq:i.freqSeq,width:i.width.midiratio)
* Env.asr().kr(gate:i.gateSeq)
			},
			{|i|
			 i/10 //Mix.ar(i)
			 * Env.perc(0,b.sum,curve:\cub).kr(2,gate:1)
			}
		).play;
		{
			Impulse.ar([3,5,7,11,13],{3.0.rand}!5)
			* Env.linen(0,b.sum,8).kr(2)
			=>Mix.ar(_)
			=>FoaEncode.ar(_, Song.encoders.omni)
			=> FoaTransform.ar(_,'press',pi/2,pi,WhiteNoise.ar().range(pi,-pi),WhiteNoise.kr().range(0,pi/2))
			=>Monitors.ambi(_)
		}.play
});
P(\chord,start:\please,syl:1,music:{|p b e| 
	var bus = Bus.audio(s,1);
	[ 
		freq:[[1,3,5].df('b-',octave:4),[1,3,5].df(\d)].q/4,
		instrument: \stringyy,
		amp:2,
		dur: b.drop(1).parse([3,1]).q,
		sustain:[0.9,0.5].q,
		out:Effect({|i| i=>CrossoverDistortion.ar(_,smooth:0.96)*2 
		* Env.linen(0,b.sum,3).kr(2,gate:1)
		=>FoaEncode.ar(_,Song.encoders.omni)=>FoaRTT.ar(_,SinOsc.ar(0.1))=>Monitors.ambi(_)}).bus.index
		//addAction:\addToHead

	].pp;

	//{In.ar(bus.index)=>FoaEncode.ar(_,p.encoders.spread)=> FoaRTT.ar(_,SinOsc.ar(0.1))=> Monitors.ambi(_) }.play(addAction:\addToTail);
});
P(\trem,start:\please,syl:1,music:{|p b e| 
	[
		freq:[1,3,[11,4.5],[2,4.5,5.5]].df('b-').q/[4,8],
		amp:0.1,
		dur:b.drop(1).parse([3,1,4,2]).q,
		instrument:\sawSynth
	].pp;
	[
		freq:[1,3,4.5,2].df('b-').q/[4,8],
		amp:0.2,
		dur:b.drop(1).parse([3,1,4,2]).q,
		instrument:\trem2,scale:1
	].p//p
});
["(He falls to the floor and his victims are freed from their pain.) " ,[1].dm(\c),[10]].addLine;
P.still(\henochDown, timecode: 4914.seconds, music: { |p b e|
	 e.still.( 
		wait: 0.2,
		fade: b.sum,
		text: ["",""],
	)
});
P(\piano,start:\freed,music:{|p b e| 
		(
			amp:1,
			freq:[-21,-11].df(\b),
			out:Effect.bus(
				{ |i|
					FreeVerb.ar(i,1,[ 1,0.9 ])
					+ PinkNoise.ar(0.0002)
					* EnvGen.cutoff(wait:b.sum, release:4, curve:nil, doneAction:2)
				}
				)
		).play
});
P.still( \friend,lag:Song.secDur[\victim] - 5, timecode:4926.seconds, music: { |p b e|
		e.still.value(
			fadeIn: 5 , //same as section duration - lag
			wait: 2 + e.bNext.sum -1,
			fade: 1
			// text:["Spock","my friend Spock"]
		);
});
["KIRK: Spock. My friend Spock. If there'd only been another way. ",[5,3,11,7, 5,6,7,5,13, 7,11,3,12].dm(\e)].addLine;
P.still(\clear, timecode: 0.seconds, music: { |p b e|
	 e.still.( 
		wait: b.sum,
		text:["Spock","my friend Spock"]
	).sequenceText2(
			b.parse([4]), [ 
			["if there'd only been","another way"],
			],
	)
});
P.synthV(role: \kirk, lag: -0.3,
		filter: (midinote: _ - 12), 
		params: {|p b| [
		lyrics: "spock my friend spock if there'd only + been another + + way",
		legato: [0.9, 1,1,0.75, 1 ,1,1,1,1,1,1,1,1],
		lag: 
		[ 0.3 ] ++ 0.3.dup(12)
		
	] }, music:{|p b e|
		{
			e.playbuf
			=> p.synthVTracks.at(e.key).()
			/2
		}.play
});
P(\chords,start:\friend,music:{|p b e| 
		[
			freq: [3,\r,[2,5]].df(\e).q,
			dur: b.parse([1,2,1]).q,
			instrument:\wash
		].pp
});
P(\bass,start:\friend,music:{|p b e| 
		[
			freq: [[5,-5],11,-6,-2].df(\e,octave:[4]).q,
			dur: b.parse([8,2,2,1]).q,
			instrument:\stringyy
		].pp
});
["SARGON [OC]: (boom) I could not allow your sacrifice of one so close to you. ",[1,13,12,14,13,12,11,7,6,5,4,3,2,4,3,2].dm(\c)].addLine;
Song.durs.filter( _ * [0.1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1]); //try lazy list
	// Song.voxSacrifice=VocalRPP(\sacrifice,\test);
	//{ BufRd.ar(2,b,Phasor.ar(1,BufRateScale.kr(b.bufnum),0,BufFrames.kr(b.bufnum)*~len))*0.1 };
P.still( \kirk, start: \sacrifice, timecode:4942.582.seconds, music: { |p b e|
		{ BufRd.ar(2,Song.laMer,Phasor.ar(1,BufRateScale.kr(Song.laMer.bufnum),0,BufFrames.kr(Song.laMer.bufnum)*0.185))*0.1 }.play(s,Song.carrierBus);
		e.still.value(
			wait: b.sum,
			// fadeIn: 2
		);
});
P(\boom,start:\sacrifice,music:{|p b e| 
		(instrument:\cymbalsDS,amp:0.003,att:1).play
});
/* 
P(\vox,start:\sacrifice, rpp:VocalRPP(\sacrifice,\test),lag:-1,music:{|p b e| 
		// TODO now make the relevant guide check to see if they should mute this!!
		p.vocodeTune.(p,b,e,
			e.rpp,
			amp:0.1,
			out:4,
			dur:b.sum+5,
		att:3,
		sus:b.sum-5,
			rel:4,
			modGain:2
		)
}); */
P.synthV( role: \vocoder, take: \lead, params: {|p b| [
	lyrics: "r I could not allow + your sacrifice + + of one so close to you. ",
	filter: (midinote: _ - 24), 
	pitchTake:1,
	defaultVibratoDepth: 0.1
	]
},
	music: {|p b e|
		// TODO now make the relevant guide check to see if they should mute this!!
		p.vocodeTune.(p,b,e,e.rpp, amp:0.1, out:4, dur:b.sum+5, att:3, sus:b.sum-5, rel:4, modGain:3, modGain:6, mix:0.51, chord:#[0.5,1,2,4,6,8], durRel: 2);
		MegaBind(
			[
				p.tune[e.start].list.midicps /1,
				p.tune[e.start].list.midicps /2,

			],
			b[0]+1 =>_.bubble ++ b.drop(1),
			[],
			{|i|
				Saw.ar(i.freqSeq,0.1)
				* Env.asr().kr(0,gate:i.gateSeq)
			},
			{|i|
				// Mix.ar(i)
				Silent.ar
				+ BufRd.ar( 1, p.laMer, Phasor.ar(
					trig: 1,
					rate: BufRateScale.kr(p.laMer.bufnum),
					start: 0,
					end: BufFrames.kr(p.laMer.bufnum)*0.185)
				) * 0.7 / 8  
				// => LPF.ar(_,200) 
				=> Out.ar(Song.carrierBus.index,_);
				// => Out.ar(_);
			}
		).play;
		{
			p.laMer.bufnum
			=> PlayBuf.auto(2, _, rate:
				[0, -5, -5].midiratio.dq.demand(b.parse([6,4,5])) 
				// * 4 / 3
				, trigger:1.0, startPos:0.0, loop:0.0, doneAction:0)
				* Env([1, 1, 0],b.parse([6,9])).kr(2,gate:1)
			=> Out.ar(p.carrierBus.index,_)
		}.play
});
P(\bassline,syl:0, music: { |p b e|
	{
		var freq = [1, 2, 5, 12, 15].df(\c, 3).dq.demand(b.drop(1).parse([2, 2, 2, 4, 5]));
		// Hasher.ar( Sweep.ar( Impulse.ar(freq) ) ) / 10
		Gendy1.arWidth(freq: freq.lag(0.01))
		/ 20
		=> LPF.ar(_)
		* Env([0,1,1,0],[0.1,b.sum-0.1,1]).kr(2,gate:1)
		=> {|i| [i, DelayN.ar(i,0.1,Line.kr(0.1,0,b.sum))]}
	}.play
});
/* P(\lagTest,start:\sacrifice,lag:-1,music:{|p b e| 
		(note:[1,2,3])//.play
}); */
P(\addlVox,start:\sacrifice,lag:-1,music:{|p b e| 
		MegaBind(
			[
				p.tune[e.start].list.midicps/.t[4,8].flatten
			],
			b[0]+1 =>_.bubble ++ b.drop(1),
			[],
			{|i|
				Saw.ar(i.freqSeq,40)
				* Env.asr().kr(0,gate:i.gateSeq)
				//* 0.2
			}
			,
			{|i|
				Mix.ar(i)*8=>Out.ar(p.carrierBus.index,_)
			}
		).play
});
	

/* P(\oldSkool,start:\sacrifice,rpp:VocalRPP(\sacrifice,\test),lag:-1,music:{ |p b e|
		var carrier = Bus.audio;
		var modulator = Bus.audio;
		{e.rpp.buffer.().bufnum => PlayBuf.ar(1,_)}.play(s,modulator.index);
		MegaBind(
			[
				p.tune[e.start].list.midicps /1,
				p.tune[e.start].list.midicps /2,

			],
			b[0]+1 =>_.bubble ++ b.drop(1),
			[],
			{|i|
				Saw.ar(i.freqSeq,0.1)
				* Env.asr().kr(0,gate:i.gateSeq)
			},
			{|i|
				Mix.ar(i)
				+ BufRd.ar( 1, p.laMer, Phasor.ar(
					trig: 1,
					rate: BufRateScale.kr(p.laMer.bufnum),
					start: 0,
					end: BufFrames.kr(p.laMer.bufnum)*0.185)
				) * 0.7 
				=> LPF.ar(_,200) 
				// => Out.ar(carrier.index,_);
			}
		).play.onFree({[carrier,modulator].do(_.free)});
		Song.oldSkool = Synth( 'vocoder16bands-bus',
			[
				carrier:carrier.index,
				modulator:modulator.index,
				amp:0.3
			 ]P,
			addAction:\addToTail,
		)//.dur(b.sum+2);
});
	 */
P(\bass,start:\sacrifice,music:{|p b e| 
		[
			instrument:\stringyy,
			freq: [11,6,4,2,5].df(\c,octave:3).q,
			dur: b.parse([[ 1,1/3 ],[2/3,1,1,1],2,4,2,1,1]).q,
			out:2,amp:0.2
		].pp

});
["(Lights dim and glow, then Chapel wobbles., MCCOY: Jim. ) ","r",[8]].addLine;
P(\release,start:\wobbles,music:{|p b e| 
	p.oldskool.free;
});
P.still( \spock, start: \wobbles, lag:2, timecode:4948.seconds, music: { |p b e|
			e.still.value(
				wait: b.sum-e.lag,
				fadeIn:0.5
			);
});
P(\transform,start:\wobbles,music:{ |p b e| 
		Synths(\transLinen,\sustain,b.sum,\freq,[1,3,11,13].df(\c),\amp,0.1,\out,1);
			Synths(\transLinen,\sustain,b.sum,\freq,[1,3,11,13].df(\g,scale:\minor),\amp,0.1,\out,2);
			Synths(\transLinen,\sustain,b.sum,\freq,[1,3,11,13].df('c#',scale:\minor),\amp,0.1,\out,3);
			Synths(\transLinen,\sustain,b.sum,\freq,[1,3,11,13].df('f#'),\amp,0.1,\out,4);
			//////////strings
			p.synful1.patch(\violas,\tremsulpont,0);
			p.synful2.patch(\violins2,\tremsulpont,0);
			(expression:100,freq:[3,5,6.5,11,13].df(\c),type:\synful,instance:p.synful1,dur:b.sum,legato:1,amp:1).play;
			[ 
				expression:100,
				freq:[1,1].df(\c).q,
				type:\synful,
				instance:p.synful1,
				dur:[ b.sum, p.durs[e.start+1].list.sum ].q,
				legato:1,amp:1 
			].p.play;
			(expression:200,note:[3,5,6.5,11,13].df('f#'),type:\synful,instance:p.synful2,
			dur:b.sum,
			legato:1,amp:2).play;
			[ expression:100,freq:[[ 1 ],[ -7,-17 ]].df('f#').q,type:\synful,instance:p.synful1,
				dur:[ b.sum, p.durs[e.start+1].list.sum ].q,
			legato:1,amp:1 ].p.play;
			p.synful1.syn.set(\out,Effect(FreeVerb.ar(_,0.75,0.55)).bus.index);
			p.synful2.syn.set(\out,Effect(PlateReverb.ar(_,mix:0.55),out:0).bus.index);
			////////timpani
			s.bind{{ |pitchScale=1.15 loss=0.99998 |
				var env=Env.linen(0,b.sum-5,8).kr(2,gate:1)*0.175;
				var numChannels=4;
				var exc = Dust.ar(2!numChannels)+Impulse.ar(0);
				var sig;
				exc = Decay.ar(exc,0.02);
				exc=Integrator.ar(exc,0.8,0.1);
				exc=PinkNoise.ar(exc);
				sig=MembraneCircle.ar(exc,[0.007,0.0073]*pitchScale,loss)*env;
				sig
			}.play;}

});
["(Spock stands up.) KIRK: You're alive.  ",[-1,1,1,7].dm(\f,scale:\mixolydian)].addLine;
P.synthV(role: \kirk, take: \lead, params: {|p b| [
			lyrics: " r you're alive +",
			filter: (midinote: _ - 12), 
			legato: [1, 0.6, 1, 0.6, ],
			pitchExpression: 1,
			paramTension:1,
			pitchTake: 1
		] }, music:{|p b e|
			{
				e.playbuf
				=> p.synthVTracks.at(e.key).()

			}.play

});
P.still( \wideAlive, start: \stands, timecode:4957.2.seconds, music: { |p b e|
			e.still.value(
				wait: b.sum,
				fade:4,
				//text:["you're","alive!"]
			);
			fork{
				b[0].wait;
				e.still.setText( ["you're","alive!"])
			}
});
P(\bassPad,start:'stands up',music:{|p b e| 
			[
				dur:[b.sum, p.durs[e.start+1].list.parse([8,3])].flat.q,
				amp:0.2,
				freqLag:1,
				instrument:\stringyy,
				freq:[[1,11],[-7,7]].df(\f).q,
				octave:[3,2]
				,legato:1
			].pm(\stringyy).play;
});
P(\sparkle,start:'stands up',music:{|p b e| 
			//p.synful1.syn.set(\out,Effect(FreeVerb.ar(_,0.75,0.55)).bus.index);
			MegaBind(
				[

					[-1,  1, 3,  5,  7,  11, 13, 15, 17].df(\f, scale:\mixolydian),
					[ -1, 1, \r, \r, 11, 11, \r, \r, \_ ].df(\e),
					[ -1, 1, \r, \r, 11, 11, \r, \r, \r ].df('d#'),
				].flop,
				//b.parse([3,1])+[1,0.5],
				[b.sum-0.1, p.durs[e.start+1].list.parse([8,3])].flat,
				[lag:{[0,b[3]+0.1].dq.demand(i.dur)}],
				{|i|
					Impulse.ar( i.freqSeq.lag({[0,b[3]+0.1].dq.demand(i.dur)}) )
				},
				{ |i v|
					Convolution.ar(i,Dust.ar((LFBrownNoise2.kr({2.0.rand}!9).range(10,100)))=>FreeVerb.ar(_,0.5,0.5),2048)
					=> SplayAz.ar(2,_)
					* Env.linen(3,b.sum-6,p.secDur[ e.start+1 ]).kr(0,gate:1)
					=> {|i| DWGReverbC1C3.ar(i,c1:Line.kr(0.2,1,b.sum+2))/2 + i }
					* 0.4
				}

			).play
});
["MCCOY: There was enough poison in that hypo to kill ten Vulcans. ", [4,3,4,2,1,-7,1,2].dm(\b,octave:4) ++ [3,2,3,4, 6.5,5,2].dm('e-') ].addLine;
			//[3,2,1,-7].dm(\c,scale:\mixolydian) ++ [5,3,2,1,4,3,4,5,12,5,4].dm('e-')
P.synthVs(role: \mccoy, take: [ \lead, \double ], params: {|p b| [
		lyrics: "there was enough + poison + in that hypo + to kill ten vulcans +",
		filter: (midinote: _ ), 
		paramGender: 0.2,
		pitchTake: [ 1, 3 ],
		vocalMode: \Open,
		tension: Env([0,1,0.5],b.parse([12,2])),
		legato: [ [1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 0.85, 0.85, 1, 1, ] ],
	] }, music:{|p b e|
		{
			e.playbuf
			=> p.synthVTracks.at(e.key).()
			/2
		}.play

});
P(\bass,start:\poison,music:{|p b e| 
			MegaBind(
				[
					[4,3,\r]
				].df(\b),
				b.parse([8,4,3]),
				[],
				//{|i| 
				//	Gendy1.arWidth(freq:i.freqSeq/[ 2,3,4 ])
				//	/2
				//	+ Gendy2.arWidth(freq:i.freqSeq/[ 2,3,4 ])
				//	*0.1
				//	* Env.asr(1,1,4).kr(0,gate:i.gateSeq)
				//},
				{|i|
					VarSaw.ar(i.freqSeq/4,0,0.1)
					=> Convolution.ar(_,Dust.ar((LFBrownNoise2.kr({2.0.rand}!9).range(10,100)))=>FreeVerb.ar(_,0.5,0.5),2048)
					=> Splay.ar(_)
					//* Env.linen(3,b.sum-3,5).kr(0,gate:1)
					* Env.asr(3,1,3).kr(0,gate:i.gateSeq)
					//=> {|i| DWGReverbC1C3.ar(i,1000,c1:0.9) + i }
				},
				{|i v|
					Splay.ar(i)
					* 0.1
					/3
					//=>DWGReverbC1C3.ar(_,2000,1,5)
					//*0.1
				}

			).play
});
P.still( \mccoy, start: \poison, timecode:5001.5.seconds, music: { |p b e|
			e.still.value(
				wait: b.sum,
				text: ["There was enough poison","in that hypo"]
			);
			e.still.sequenceText([
				b.parse([10]).sum,[ "to kill ten","Vulcans!" ]
			])
});
P(\chord,start:\poison,music:{|p b e| 
			//Muted
			MegaBind(
				[
					[1,\_,1.5,2,2.5,\_]
				].df(\c,octave:3),
				b,
				[],
				{|i|
					Saw.ar( i.freqSeq, 0.1)
					* Env.asr(0.2,1,4).kr(0,gate: i.gateSeq)
				}
			)
			//.play
});
["SARGON [OC]: No, Doctor. (Boom)",[1,-5,-3, -17].dm(\a,scale:\minor,octave:4)].addLine;
P.tune('No, Doc');
P.synthV(role: \vocoder, take: \lead,
	filter: (midinote: [50,50,50,50]), 
	params: {|p b| [
	lag: [0.1, 0.00,0],
	lyrics: "No Doctor + r",
	legato: [0.8, 1, 1 ],
	pitchTake: 1
] }, music:{|p b e|
	p.vocodeTune.( p, b, e, e.rpp,
		verb:0,
		// mix:0.1,
		amp:0.12,
		modGain:3,
		dur:b.sum+1,
		att:1,
		sus:b.sum-1,
		rel:2,
		chord:#[1, 2, 4],
	);
});
P(\bass,start:'No, Doc',music:{|p b e| 
			MegaBind(
				[
					[1,\_,\_,2.5],
					[1,-5,-3,-17]
				].df(\a,octave:3,scale:\minor),
				b,//.parse([3,1]),
				[
					lag: { [0,0.4].dq.demand(b.parse([3,1])) }
				],
				{|i|
Pulse.ar( i.freqSeq.lag2(i.lag) 
					//*.t [1,2,3].reciprocal
					, 
					0.3,0.1)
					=> Mix.ar(_)
					* Env.asr(0.2,1,2).kr(0,gate:i.gateSeq)
				},
				{|i v|

					 TwoTube.ar(i, 0.1, 0.99, [ 1111, 1222 ],[ 762, 674 ],  mul: 1.0,  add: 0.0)
					*0.2
					//=> {|i| Out.ar(carrier.index,i[1]); 
					//Out.ar(1,i[0])
				//}

				}
			).play
});
P.still( \wide, start: 'No, Doctor', timecode:5006.seconds, music: { |p b e|
			e.still.value(
				wait: 1,
				fade:5,
				text:[ "No Doctor!","" ]
			);
});

[" I allowed you to believe that to be true so that ",[3,2,4,3,1,-5,-7,-6,-4,-1,2,-6,-5].dm(\c,scale:\mixolydian,octave:6)].addLine;
		//Song.voxAllow=VocalRPP(\allowed,\tune);
P.synthV(role: \vocoder, take: \lead,
	pbind:Song.enlarge(3),
	filter: (midinote: _ - (24!13 ++ 12.dup(3))), 
	paramBreathiness: 1,
	params: {|p b| [
	lyrics: "I allowed + you to believe + that to be true so that Henoch + would ",
	legato: [1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 0.65,  1, 1, 1, 1, 1, ],
	pitchTake: 1,
	defaultVibratoDepth: 0.1
] }, music:{|p b e|
	p.vocodeTune.( p, b, e, e.rpp,
		tune: p.tune[e.start].list ++ p.tune[e.start + 1].list[..3],
		chord: #[0.5,0.66,1,2],
		enlarge:3,
		verb:0.1,
		amp:0.15,
		att:2,
		sus:b.sum + e.bNext[..2].sum -1,
		rel:1.2,
		dur:b.sum+1 * e.bNext[..2].sum,
		// durRel:3,
		modGain:3
	);
	{
		p.laMer =>
		PlayBuf.auto(2, _, rate:

				 ([1,4,2,5].dm(\c) - 1.dm(\c)).midiratio.dq.demand(e.bAll.parse([6,4,3,3])) * 2,
			trigger: TDuty.kr( e.bAll.parse([6,4,3,3]).dq, reset:0.0, level:1.0, doneAction:0, gapFirst:0), startPos:0.0, loop:1.0, doneAction:0
		)
			=> {|i| Out.ar(p.carrierBus,i / 1)}
	}.play
});
P.still( \clear, start: \allowed, timecode:0, music: { |p b e|
			e.still.value(
				wait: b.sum,
				text:["I allowed you to","believe that to be"]
			);
			e.still.sequenceText(
				[b[(0..9)].sum,[ "true","so that" ]]
			)
});
		//P.tune(\allowed);
		Song.allowedInner= {|i x| 
			Saw.ar( i.freqSeq.lag(0.01) + i.width, 0.1)
			//* Env.perc(0.05,3).kr(0,gate:i.trigSeq * i.gateSeq)
			* Env.asr(0,1,3).kr(0,gate:i.gateSeq)
		};
		Song.allowedFx = {|i v|
			i[[1,0,2]]	
			* 0.4
			=>Splay.ar(_)
		};
P(\keys,start:\allowed,music:{|p b e| 
			MegaBind(
				[
					[3,  2,  4, 3,  1,  -5, -7, -6, -4, -1, 2,    -6, -5],
					[\r, \r, 1, \_, \r, \r, -4, \_, \r, \r, -4.5, \_, \r ],
					[\r, \r, 5, \_, \_, \r, 1, \_, \_, \r, -6,   \r, \r]
				].df(\c,scale:\mixolydian),
				b,
				[
					width: [0,{SinOsc.ar(3,0,3/2)},{ SinOsc.ar(5,0.2,2) }],
				],
				p.allowedInner,
				p.allowedFx
			).play
});
P(\bass,start:\allowed,music:{|p b e| 
			[
				freq: [\r,1,4,2,5,4,3,6,5].df(\c,octave:[3,4]).q,
				dur: b ++ Song.durs[\read].list => _.parse([2,4,4,3,3,3,3,2,2]) => _.q,
				amp: 0.1
			].pp
});
["Henoch would (boom) read your thoughts and believe it also. ",[11,7,5,-4,13,12,15,13,12,11,7,14,13].dm(\c,octave:4)].addLine;
		//Song.voxRead=VocalRPP(\read,\tune);
/*
P(\vox,start:\read,lag:-1, rpp:VocalRPP(\read,\tune),music:{|p b e|
	p.vocodeTune.(p,b,e,e.rpp,
		amp:0.18,
		att:1,
		sus:b.sum,
		rel:2,
		dur:b.sum+2,
		chord:#[1,2,4,6,8],
		modGain:1
	)
});	//P.tune(\read); */
P.synthV(role: \vocoder, take: nil, params: {|p b| [
			filter: (midinote: _ - 12), 
			lyrics: "r r r r reed your thoughts and believe + it also +",
			legato: [1, 1, 1, 1,  1, 1, 1, 1, 1, 1, 1, 1, 1, ],
			// pitchTake: 1
		] }, music:{|p b e|
			p.vocodeTune.(p,b,e,e.rpp,
				amp:0.18,
		verb:0.1,
		// amp:0.15,
				att:1,
				sus:b.sum,
				rel:2,
				dur:b.sum+2,
				chord:#[1,2,4,6,8],
		chord: #[0.5,0.66,1,2],
				modGain:3
			);
			
	{
		p.laMer =>
		PlayBuf.auto(2, _, rate:

				 ([4, 3, 6, 5].dm(\c) - 1.dm(\c)).midiratio.dq.demand(e.bAll.parse([6, 3, 2, 2])) * 2,
			trigger: TDuty.kr( e.bAll.parse([6,4,3,3]).dq, reset:0.0, level:1.0, doneAction:0, gapFirst:0), startPos:0.0, loop:1.0, doneAction:0
		)
			=> {|i| Out.ar(p.carrierBus,i / 1)}
	}.play

});
P.still( \clear, start: \read, timecode:0, music: { |p b e|
			e.still.value(
				wait: b.sum,
				text:["Henoch would","read your thoughts"]
			);
			fork{
				b[(0..5)].sum.wait;
				e.still.setText(["and believe it ","also"])
			}
});
P(\line,start:\read,music:{|p b e| 
			MegaBind(
				[
					[11, 7,  5,  \r, 13, 12, 15, 13, 12, 11, 7, 14, 13],
					[\r, \r, \r, -4, -5, -6, -7,\r,\r,-6,\_,-5],

				].df(\c,octave:4),
				b,
				[

					width:[0],

				],
				p.allowedInner,
				{|i| i * 0.4
					=> Splay.ar(_)
				}

			).play
});

		Trek.cast.mccoy=\mo;
[ "MCCOY: Sargon. ",[5.5, 1].dm(\g)].addLine;
P.tune('MCCOY: Sargon',Pbindf(_,\instrument,\sawSynthSustain));
P.synthV(role: \mccoy, take: \lead, params: {|p b| [
	lyrics: "sargone +",
	filter: (midinote: _ - 12), 
	pitchTake: 1,
	paramGender: 0.2,
	vocalMode: \Soft,
	paramTension: -0.5
] }, music:{|p b e|
	{
		e.playbuf
		=> p.synthVTracks.at(e.key).()
	}.play

});
P(\chord,start:'MCCOY: S',music:{|p b e| 
			[
				freq: [1,3,5.5].df(\g),
				dur:b.sum.q,
				strum:0.05,
				out: Effect( { |i| 
					EchoCubic.ar(
						i,
						0.5,
						Array.fill(4,{rrand(0.2,0.4) })
						=>{|i| LFBrownNoise2.kr({rrand(1.0,2)}!4).range(i,i*0.9) }
						 ,
						5
					)+i/2} ,inputChannels:1).bus.index
			].pp

});
["SPOCK: It seems, Doctor, the injection was (boom) only enough to cause unconsciousness. ",[5,11,5,3,11,7,6,4,1,-3,4,3,2,5,6,5,6,5.5,6,5.5].dm('b-',octave:4)].addLine;
P(\chords, music: { |p b e|
	[
		freq: [
			\r,
			[3, 5, 11],
			[4, 6, 11],
			\r,
			// [4, 6, 11],
			[2, 5, 7],
			[3, 5.5, 7]
	].df('b-',4).q,
	dur:b.parse([1, 5, 3, 4, 4, 3]).q,
	instrument: \reedy,amp:0.01,out: [2,3],
	legato: [1, 1, 0.99, 1, 1, 1, 1, ].q,
	].ppma
});
P.still(\spockSargon, timecode: 5012.8.seconds, music: { |p b e|
	 e.still.( 
		wait: b.sum,
		text: ["it seems","Doctor"],
	).sequenceText2(
			b.parse([4, 12]), [ 
			["the injection was","only enough to cause"],
			["unconsciousness",""]
			],
	)
});
P(\answer,syl:17, music: { |p b e|
	[
		freq: [6, 5.5, 6, 5.5].df('b-',[4]).q,
		instrument:\sparkTriangle,
		dur: b.drop(1)[[0,1]].dup.flat => _.q,
		out: Effect.bus({|i| i => Pan2.ar(_, SinOsc.kr(1))=> {|i| i + CombN.ar(i, 0.6,0.6,6)}}),
		amp:0.05
	].pp
});
P.synthVs(role: \spock, take: [ \lead, \double ], params: {|p b| [
	lyrics: "It seems, Doctor + the injection + + was r only + enough + to cause unconsciousness + + + ",
	legato: [ [1, 0.8, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 0.7, 1, 1, 1, 1,  ] ],
	pitchTake: [ 1, 3 ],
	filter: (midinote: _ - 12), 
	vocalMode: \Warm
] }, music:{|p b e|
	{
		e.playbuf
		// => p.synthVTracks.at(\default).()
		=> HPF.ar(_,225)
		/4
		=> Pan2.ar(_,0)
	}.play

});
Song.quarters[\injection]= Song.durs[\injection].list.asArray.parseBeats([1,2,1,1,1,1, 2,1,1,1, 2,1,1, 1,1,2,1,1,1,2]);
P(\phrase1,start:\injection,music:{|p b e| 
	MegaBind(
		[
			[\r, 1,  1,  1,  1,  1,  1,  4,  4,  4,  4,  \r, 4,  4,  4,  4,  5, 5, 5, 5, 5, 3, 3, 3],
			[\r, \r, \r, \r, \r, \r, \r, \r, \r, \r, \r, \r, \r, \r, \r, \r, 5, 4, 3, 3, 2, 3, 2, 1.5 ]
		].df('b-',octave:2),
		//b,
		p.quarters[e.start],
		[cutoff: { Dwhite(800,8000).demand(i.trigSeq) }],
		{|i x|
			case {x < 1}{Blip.ar( i.freqSeq,30 )
			=> MoogFF.ar(_,Demand.kr(i.trigSeq,1,Dwhite(400,4000)),3)
			* Env.perc().kr(0,gate:i.trigSeq*i.gateSeq)
			* Env.asr().kr(0,gate:i.gateSeq)
			//			=> EchoNone.ar(_,1,p.durs[e.start].list[0]/2,5)
		}		{
			Impulse.ar( i.freqSeq )
			* Env.asr().kr(0,gate:i.gateSeq)
		}
	},
		{ |i v|
			i * 0.2
		}
	).play
});
// P.tune(\unconsciousness);
["SARGON [OC]: But Henoch believed and fled the body. ",[5,11,5,3,6.5].dm('c#',scale:\dorian)++[5,11,5,4,3].dm('e-')].addLine;
//P.tune(\believed);
//Song.voxBelieve = VocalRPP(\believed,\vox);
P.still( \clear, start: \believed, timecode:0, music: { |p b e|
			e.still.value(
				wait: b.sum,
				text:["but Henoch","believed"]
			);
			fork{
				b[(0..4)].sum.wait;
				e.still.setText(["and fled","the body"])
			}
});
/*
P(\vox,start:\believed, rpp:VocalRPP(\believed,\tune),lag:-1,music:{|p b e| 
		//|p b e rpp amp=0.2 att=3 sus=1 rel=5 dur=10 chord=#[1,2,4,5,6,8] tune out=0 modGain=1|
			p.vocodeTune.(p,b,e,e.rpp,0.2,1,b.sum-2,2)
}); */
P.synthV(role: \vocoder, take:\lead, params: {|p b| [
	lyrics: "but henoch + believed + and fled the body +",
	filter: (midinote: _ - 12), 
	defaultVibratoDepth: 0.1
	// pitchTake: 1
] }, music:{|p b e|
	// {
	// 	e.playbuf
	// 	=> p.synthVTracks.at(e.key).()
	// }.play
	//
			p.vocodeTune.(p,b,e,e.rpp,0.2,1,b.sum-2,2,
				chord:#[1,2,3,4],
				mix: 0.9,
				modGain:8.dbamp)

});
P(\bass,start:\believed,music:{|p b e| 
	MegaBind(
		[
			[\r,1,2]
		].df('c#'),
		b.parse([1,5,4]),
		[
			lag: {[0,1,1,1,1,1,1,1,1,1,1].dq.demand(b)}
		],
		{|i|
			Saw.ar( 
				i.freqSeq.lag2( i.lag ) / 2 
				* [1,0.5]
				* LFBrownNoise2.kr([2,2.2,2.3,2.4]).range(0.99,1.01),
				0.03
			)
			* Env.asr(0.1,1,4).kr(2,gate:i.gateSeq)
		},
		{|i|
			Splay.ar(i)
			=> FreeVerb.ar(_,0.7,0.7)
		}

	).play
});
["(boom) He is (boom) destroyed. ",[-5,5,5,-5,5,5].dm(\g)].addLine;
P.still(\clear,syl: 0, timecode: 0.seconds, music: { |p b e|
	 e.still.( 
		wait: b.drop(1).sum,
		text: ["he","is"],
	).sequenceText2(
			b.drop(1).parse([2,1]), [ 
			["",""],
			["destroyed",""]
			],
	)
});
P.synthV(role: \vocoder, take: \lead, params: {|p b| [
	lyrics: "r he is r destroyed +",
	filter: (midinote: _ - 24), 
	pitchTake: 1
] }, music:{|p b e|
	p.vocodeTune.(p,b,e,e.rpp,modGain:10.dbamp)
});
P(\chord,start:'He is (boom)',music:{|p b e| 
	MegaBind(
		[5,\_,\_,\r,\r,-1].bubble ++ 
		[\r,\r,\r,5,\r,[1,3,5]].flop 
		=> _.df(\c,scale:\minor)
		,b ,
		[],
		{|i|
			Saw.ar( 
				Gendy1.krWidth(freq:5)*10+
				i.freqSeq / [2,4] 
				, 0.1
			)
			* Env.asr(release:4).kr(0,gate:i.gateSeq)
		},
		{|i v|
			Env([0.5,1,1],b.parse([5,1])).kr(0,gate:1) *
			Splay.ar(i)
			=>FreeVerb.ar(_,0.7,1) * 1.3
		}
	).play
});
["KIRK: But your vessel was destroyed, too. Where was your consciousness kept? ",[7,13,11,7,5,4,3,4,5,-7].dm(\g,scale:\mixolydian)++[7,11,14,13,11,7,5].dm(\d,scale:\mixolydian)].addLine;
P(\tamboura, music: { |p b e|
	{
		Gendy1.arWidth(
			ampdist:1,
			durdist:1,
			adparam:1.0,
			ddparam:1.0,
			freq:[[-1,1, 5],[-2, 2, 5]].df(\g,\mixolydian).dq.demand(b.parse([10, 7])),
			width:1.021,
			ampscale:0.5,
			durscale:0.5,
			initCPs:12,
			knum:12,
		)
		/40
		* Env.linen(*(b.parse([1, 16]) ++ 2)).kr(2,gate:1)
		// => Klang.ar(specificationsArrayRef:, freqscale:1.0, freqoffset:0.0)
	}.play

});
P.still(\clear, timecode: 0.seconds, music: { |p b e|
	 e.still.( 
		wait: b.sum,
		text: ["but your","vessel"],
	).sequenceText2(
			b.parse([6, 4]), [ 
			["was destroyed","too"],
			["where was your", "consciousness kept?"]
			],
	)
});
P.still(\kirkVessel, timecode: 5019.66.seconds, music: { |p b e|
	 e.still.( 
		wait: b.sum,
		text: ["",""],
	)
});
P.synthV(role: \kirk, take: nil, params: {|p b| [
			filter: (midinote: _ - 12), 
			lyrics: "But your vessel - + - was destroyed + too. Where was your consciousness + +  kept? ",
			// legato: [1, 1, 1, 1, 1, 1, 1, 0.8, 1, 1, 1, 1, 1, 1, 1, ],
			pitchTake: 1
		] }, music:{|p b e|
			{
				e.playbuf
				=> p.synthVTracks.at(e.key).()
			}.play

});
["SPOCK: The place Henoch would least suspect, Captain. ",[2,3,4,3,1,5,4,6, 4,3].dm(\e,scale:\whole)].addLine;
P.still(\spockPlace, timecode: 5025.4.seconds, music: { |p b e|
	 e.still.( 
		wait: b.sum,
		text: ["",""],
	)
});
P.synthV(role: \spock, take: \lead, params: {|p b| [
			filter: (midinote: _ - 12), 
			lyrics: "The place Henoch + would least suspect +, Captain + ",
			legato: [1, 0.8, 1, 1, 1, 1, 1, 0.8, 1, 1, ],
			pitchTake: 1,
			vocalMode: \Closed,
			defaultVibratoDepth: 0.1
		] }, music:{|p b e|
			{
				e.playbuf
				// => p.synthVTracks.at(\default).()
				=> HPF.ar(_,200)
				/4
				=> Pan2.ar(_,0)
			}.play

});
		Song.suspectInner_(
			{|i|
				Gendy1.arWidth(freq:i.freqSeq+[1,2,3,4])//Dust.ar(50)
				=> { 
					|j| Convolution.ar(
						Saw.ar(i.freqSeq.lag(0.5)*[1,2]/8 ),
						j => FreeVerb.ar(_,0.8,0.9)
					)
					* Env.asr(release:6).kr(2,gate:i.gateSeq)
					*0.005
					*  i.amp 

				} 			
			}
		);
P(\bass,start:\suspect,music:{|p b e| 
			MegaBind(
				[
					//[2,  3,  4,  3,  1,  5,  4,  6, 4, 3],
					[\r, 3, 4, \_, \_, 5, \_, 6,\_,\_,\_]
				].df(\e,scale:\whole),
				b[(0..(b.size-2))]++( b.last+p.durs[e.start+1].list[(0..8)].sum ),
				[
					amp:[
						{ Env([1,1,0.5],b.parse([6,3])).kr(0,gate:1) }		
					]
				],
				p.suspectInner,
			).play
});
["CHAPEL: (boom) That is why I was summoned into Sickbay, Doctor. ",[-5,5,4,3,2,1, 1,-7,1,2, 1,-7,-6,-5].dm(\a,scale:\melodicMinor)].addLine;
P.synthV(role: \chapel, take: \lead, params: {|p b| [
			lyrics: " r that is why I was summoned + into + sick bay doctor +",
			pitchTake: 1
		] }, music:{|p b e|
			{
				e.playbuf
				=> p.synthVTracks.at(e.key).()
			}.play

});
P.tune(\summoned);
P(\bass,start:\summoned,music:{|p b e| 
			MegaBind(

				[
					[4,5]
				].df(\a) ,
				b.parse([10,4]),
				[
					amp:[{ Env([0,1],b.parse([10])).kr(0,gate:1)}]
				],
				p.suspectInner,
				{|i| i};

			).play

});
P.still( \chapel1, start: \placed, timecode:5030.5.seconds, music: { |p b e|
	e.still.value(
		wait: b.sum,
		text: ["that is why I was summoned", "into sickbay, Doctor"]
	);
});
["Mister Spock's consciousness was placed in me. ",[1,2,3,4,3,2,1,6,6,5].dm(\g,octave:4)].addLine;
P.still(\clear, timecode: 0.seconds, music: { |p b e|
	 e.still.( 
		wait: b.sum,
		text: ["Mister Spock's","consciousness was"],
	).sequenceText2(
			b.parse([7]), [ 
			["placed in","me"],
			],
	)
});
Song.setTempoMap(\placed,"e e ee e e e e ee e eeeee");
// P.tune(\placed);
P.synthVs(role: \chapel, take: [ \lead, \double ], params: {|p b| [
	lyrics: "mister + spocks consciousness + + was placed in me",
	pitchTake: [ 1,3 ]
] }, music:{|p b e|
	{
		e.playbuf
		* Env([3, 3, 1], b.parse([7, 1])).kr(0,gate:1).dbamp
		=> p.synthVTracks.at(e.key).()
		// *2
	}.play
});
P(\bassTwo, music: { |p b e|
	
	[
		out:2,
		freq: [1,4,5,1, 6,5,4,1, 4,1,4,3].df(\g,3).q,
		dur:b.parse([
			1,1,0.5,0.5,
			1,1,1,1,
			0.5,0.5,1,1
		]).q,
		instrument:\sawSynth
	].pp
});
P(\bassThree, music: { |p b e|
	[
		dur: "e e e e e e e e e e e e e e e e".asBeats.warpTo( e.tempoMap ).q,
		freq: [1, 1, 1, 1, 1, 1, 1, 1, -4, -4, -4, 1, 1, 1, 1, 1].df(\g,3).q,
		instrument: \stab,

		amp:2
	].pp
});
P(\bass,start:\placed,music:{|p b e|
	MegaBind(
		[
			[1,4,5,1, 6,5,4,1, 4,1,4,3]
		].df(\g),
		b.parse([
			1,1,0.5,0.5,
			1,1,1,1,
			0.5,0.5,1,1
		]),
		[
			amp:0.06,
		],
		{|i|
			var sig=Formant.ar(
				i.freqSeq * [1,0.491],  
				//formfreq: Line.kr(3060,00,i.dur),  
				formfreq: Env.perc(level:3600).kr(0,gate:i.trigSeq),
				bwfreq: 880
			).distort;
			var env=Env.asr(0,1,1,1.5).kr(0,gate:i.gateSeq);
			sig*env*i.amp //=> DelayN.ar(_,1,0.2)
		},
		{|i v| FreeVerb.ar(i,0.5,1) => Out.ar(3,_)}
	).play
});
["(boom boom) We shared consciousness (we shared consciousness... ) to",[-5,-5,3,2,4,3,2,1].dm('e-')++[3,2,4,3,2,1].dm( 'a-' )++[3,2,4,3,2,1].dm('e-') ].addLine;
P.synthVs(role:\chapel, take: [ \lead, \double ],
	// pbind:[ Song.enlarge(2), Song.enlarge(2) ],
	pbind:Song.enlarge(2),
	params: {|p b| [
		lyrics: "r r we shared consciousness + + - r r r r r r we shared consciousness + + together + + ",
		pitchTake: [ 1,3 ]
	]}, music:[ 
		{|p b e|
		{
			e.playbuf

			=> Pan2.ar(_,0)
			*0 //MUTE
			// => p.synthVTracks.at(e.key).()
		}.play
	},{|p b e|
		{
			e.playbuf
			* -3.dbamp
			=> BHiShelf.ar(_, freq:6000, rs:1.0, db:6, mul:1.0, add:0.0)
			=> Pan2.ar(_,0)
			// => p.synthVTracks.at(e.key).()
		}.play
	}
]
);
P.synthVs(role: \chapel, take: [ \answer,\answer2 ], params: {|p b| [
	lyrics: "r r r r r r r r we shared consciousness + + - r r r r r r",
	pitchTake: [ 2,3 ]
] }, music:{|p b e|
	{
		e.playbuf
		=> p.synthVTracks.at(e.key).()
		/2
	}.play
});
Song.quarters[\shared]=Song.parseBeats(\shared,[1,1,1,1,1,1,1,3,1,1,1,1,1,3,1,1,1,1,1,1]/2);
P.tune(\shared,Pset(\dur,Song.quarters[\shared].mean/2 * [1,1,1,1,1,1,1,3,1,1,1,1,1,3,1,1,1,1,1,1].q,_));
Song.sharedClock=TempoClock.new().permanent_(true);
P(\newVersion,start:\shared,music:{|p b e| 
	var tracks;
	var group = p.sharedGroup=Group.new;
	var clock = p.sharedClock.tempo_(p.quarters[\shared].mean.reciprocal/2);
	var shaker =	[time:[0.05,1,0.1].q(inf),amp:0.2,resonantFreq:60,dur:1/8,up:[1,0].q(inf),down:[0,1],q(inf),inst:13.rand].pm(\shakeEnv);
	var bd =[instrument:\bd_808,amp:0.15].p;
	var hat =[instrument:\hat_808,amp:[[1].q([3,5,6].q(1)),0].q(inf)/10,dur:1/16,out:Pwhite(0,5,inf)].p;
	var bass = [
		freq:[1,4,6.5,12.5].df(\c,octave:[3]).q(inf).stutter(4),
		dur:0.25,
		legato:0.3,
		// amp:0.15,
		instrument: \stab,amp:2,
		// out:Effect(DelayC.ar(_,0.1,SinOsc.ar(6).range(0,0.001)).tanh).bus.index
	].p;
	var yow = [instrument:\yowbass,freq:[1,4,6.5,12.5].df(\c,octave:[3,2]).q(inf).stutter(4),dur:0.25,legato:0.3,amp:0.015,out:2].p;
	var stringyy1 = [freq:[\r,3,2,4,3,2,1].df([\c,\f])++[3,2,4,3,2,1].df([\f,'b-'],octave:6)=>_.q(inf),dur:[2,1,1,1,1,1,3,1,1,1,1,1,1].q(inf)/4,instrument:\stringyy,out:[0,2]].p;
	var saw1 = [amp:0.05,freq:[\r,5,13,12,\r].df(\c).q(inf),dur:[15,1,3,6,7].q(inf)/4,instrument:\sawSynthSustain,legato:1.1].p;
	//there's a better way to write these echoing lines!
	//var saw2 = [freq:[\r,12,11,\r].df(\c).q(inf),out:3,amp:0.07,dur:[24,3,6,7].q(inf)/4,instrument:\sawSynthSustain,legato:1.1].p;
	//var saw3 = [freq:[\r,11,6.5,\r].df(\c).q(inf),out:2,amp:0.06,dur:[32,3,6,7].q(inf)/4,instrument:\sawSynthSustain,legato:1.1].p;
	//var saw4 = [freq:[\r,6.5,6,\r].df(\c).q(inf),out:2,amp:0.05,dur:[40,3,6,7].q(inf)/4,instrument:\sawSynthSustain,legato:1.1].p;
	var sn = [dur:"..xx..x.".asDrumPat(4,inf),amp:0.1,instrument:\sn_808].p;

	[shaker,bd,hat,yow,bass].par.findur(6)
	+= saw1.fin(4) 
	=> Pmul(\freq,midiratio(-2),_) 
	+= [6,[ shaker,bd,hat,yow=>Pmul(\freq,(midiratio(9)),_) ].par.findur(4)]
	=> _.postln
	=> Pbindf(_,\group,p.sharedGroup) 
	=> _.play(p.sharedClock);

	//fork{ 
	//	b.sum*4 => _.wait;
	//	p.sharedClock.clear(releaseNodes:true);
	//	0.01.wait;
	//	p.sharedGroup.release;
	//	1.wait;
	//	p.sharedClock.clear()}
});
/*
P(\lick,start:\shared,music:{|p b e| 
	[2,1, 6.5,5].dm(\c)
});
P(\kick,start:\shared,music:{|p b e| 
	{
		AnalogBassDrum.ar(
			trig: TDuty.kr(Song.quarters[\shared].mean/2*[1,1,1,1,1,1,1,1].dq(inf),0,[1,1,0,1,1,1,0,1].dq(2)) ,  
			infsustain: 0.0,  
			accent: Demand.kr(Impulse.kr(Song.quarters[\shared].mean/2),0,[0,1,0].dq(inf)),
			freq: 40,  
			tone: 0.2,  
			decay: 0.5,  
			attackfm: 0.5,  
			selffm: 0.25
		)
		=> {|i| [i,CombC.ar(i,1,Song.quarters[\shared].mean/4.02,3)] }
		*10
		++ ( AnalogSnareDrum.ar(

			trig: TDuty.kr(Song.quarters[\shared].mean/2*[1,1,1,1,1,1,1,1].dq(inf),0,[0,0,1,1,0,0,1,0].dq(2),0) ,  
			infsustain:0,
			freq:166,
			decay:0.3,
			snappy:0.8
		) => FreeVerb.ar(_,0.5,0.8) )

		=> Splay.ar(_)
		/2
	}.play;
	fork{
		var a;
		0.2.wait;
		a = Synth(\shake,[\out,2]);
		b.sum.wait;
		a.free
	}

});
( SynthDef(\shake,{
	StkInst.ar(Stk.at("Shakers"),3.midicps,
	VarSaw.ar(Song.quarters[\shared].mean.reciprocal*4,iphase:pi/2) => Decay.ar(_,0.5),1,0.5)
	=> Out.ar(\out.kr(0),_)
}
					 ).add;
);
P(\bass,start:\shared,lag:-0.01,music:{|p b e| 
	[
		dur:p.quarters[e.start].mean/2,
		freq:[-5,1,4,6.5].df('e-',octave:3).stutter(4).q,
		instrument:\sawSynth

	].//pm(\sawSynthSustain).play
	pp
});
*/
["gether.(1) ",[12,11,11,7,7,6].dm(\d)].addLine;
( Song.getherLines=
	[
		[12, 11, \_,  \r, \r, \r],
		[\r, \r, 11,  7,  \_, \r],
		[\r, \r, \r,  \r, 7,  6],
		[6,  5,  \_,  \_, 3,  \_],
		[4,  3,  2.5, 2,  1,  \_],
	].df(\d);
);
P(\echos,start:'gether.(1) ',music:{|p b e| 
				MegaBind(
					p.getherLines[(0..2)],
					b,
					[
						out:[0,1,0]
					],
					{|i| 
						Saw.ar(i.freqSeq) 
						* Env.asr(0.01,1.0,4.0,  curve: -4.0).kr(2,gate:i.gateSeq)
						*0.1
						*0.5
						* Env([1,1,0.3],b.sum*[0.4,0.6]).kr(0,gate:1)
						=> Out.ar(i.out,_)
					}
				).play	;
				MegaBind(
					p.getherLines[(3..4)],
					b,
					[
						width:[0.1,0.5]
					],
					{|i|
						//Pulse.ar(i.freqSeq/[1,2],i.width,0.1)
						Impulse.ar(i.freqSeq/[1,2])
						* Env.asr(0,1,2).kr(0,gate:i.gateSeq)
						* 0.4
						*0.5
					},
					{|i v|
						FreeVerb.ar(i,0.5,1)
						* Env([1,1,0.3],b.sum*[0.4,0.6]).kr(0,gate:1)
					}
				).play
	});
P(\bassPad,start:'gether.(1)',music:{|p b e| 
				MegaBind(
					[
						[1,2],
						[-1,-2]
					].df(\a,octave:[3,4]),
					[ b.sum+Song.durs[\cannot].list[[0,1]].sum,5 ],
					[a:9],
					{|i|
						Saw.ar(i.freqSeq*[0.995,1,1.0031],0.03)
						//* Env.asr(0.1,1,6).kr(0,gate:i.gateSeq)
						* Env.asr(1,2).kr(0,gate:1)
						=>Splay.ar(_)
						* Env.perc(0.1,12).kr(0,gate:i.trigSeq)
					},
					{ |i|
						FreeVerb.ar(i,0.5,0.8)
					}
				).play
	});
["SARGON [OC]: We now know we cannot permit ourselves (boom) to exist in your world, my children. ",[5,4,3,-7,4,3,2,1,-7,-5,-3,-7,1].dm(\b,scale:\mixolydian) ++ [2.5,2,6,5,1,4,3].dm(\g)].addLine;
P.still(\listeningAgain, timecode: 5043.5.seconds, music: { |p b e|
	 e.still.( 
		wait: b.sum,
		text: ["We now","know"],
		
	).sequenceText2(
			b.parse([3, 7, 1, 3,]), [ 
			["we cannot permit","ourselves"],
			["",""],
			["to", "exist"],
			["in your world","my children"]
			],
	)
});
( Song.weNowKnowLines= [
		[6, 5, 4.5, 1,  5,  4.5, 3,  2,  1,  -6, \_],
		[3, 3, 2,   \_, \_, \_,  \_, \r, \r, \r, -4.5],
		[1, 1, -6,  \_, \_, \_,  \_, \r, \r, \r, -14.5],
		[6, 5, 4.5, 1,  5,  4.5, 3,  2,  1,  16, \_]*(-1)
	].df(\a);
);
P(\bass,start:\cannot,syl:12,music:{|p b e| 
				[
					freq: [2,1.5,-5,-4.5,-1,-13].df(\f,octave:[3,4]).q,
					dur:b.drop(1).parse([2/3,[ 1/3,1 ],[1,2/3],[1/3,1],1,1, ])++3 =>_.q,
					legato:1
				].pp

	});
P(\lines,start:\cannot,music:{|p b e| 
a=MegaBind(
	p.weNowKnowLines,
	b[ 0..9 ],
	[amp:[1,1,1,1]],
	{|i x| Pulse.ar(i.freqDq.demand(i.dur + Array.fill( i.size,{0.04.rand} ))
	//*[rrand(0.995,1.005),1]
	,width:0.1) 
	* (
		Env.asr(0.5,1,4).kr(0,gate:i.gateSeq)
		+ {0.1*Env.perc(0.2,1).kr(0,gate:i.trigSeq)} 
	)
	* 0.1
},
{|i| 
	Splay.ar(i)
	=>FreeVerb.ar(_,0.5,1)}
	=> Out.ar(p.carrierBus.index,_)

).play
});
P(\bassFirstPart, music: { |p b e|
	[
		freq: [7, 11].df(\b, [1,2], \mixolydian).q,
		dur: b.parse([2, 5]).q,
		out: Effect.bus( DWGReverbC1C3.ar(_, mix:0.9) )
	].pp
});
P.synthV(role: \vocoder, take: \lead, params: {|p b| [
	lyrics: "We now know we cannot + permit + our - selves   to exist + in your world, my children. + ",
	filter: (midinote: _ - 24), 
	paramBreathiness: 0.8,
	defaultVibratoDepth:0.2,
	// legato: [1, 1, 0.8, 1, 1, 1, 1, 1, 1, 1.5, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, ],
	pitchTake: 1
] }, music:{|p b e|
	a = [
		[6, 5, 4.5, 1,  5,  4.5, 3,  2,  1,  -6, \_],
		[3, 3, 2,   \_, \_, \_,  \_, \r, \r, \r, -4.5],
		[1, 1, -6,  \_, \_, \_,  \_, \r, \r, \r, -14.5],
		[6, 5, 4.5, 1,  5,  4.5, 3,  2,  1,  16, \_]*(-1)
	].df(\a)
	+++ [
		[2,3,  2.5, 2,  6,  5,  1,  4, 3],
		[\_, \r,  \r, \r, \r, \r, \r,\r ],
		[\_, \r,  \r, \r, \r, \r, \r,\r ],
		[2,3,  2.5, 2,  6,  5,  1,  4, 3] * -1,
	].df(\g)
	=> VoiceLeading(_,b);
	a.pbinds.collect( { |i| i <> [instrument: \stringyy,
		out: p.carrierBus.index
	].pma} ) => Ppar(_) 
	// => _.findur(b.parse([11]).unbubble) 
	=> _.play;
	// {PinkNoise.ar(1)}.play(s,p.carrierBus.index);
	// {
	// 	e.playbuf
	// 	=> p.synthVTracks.at(e.key).()
	// }.play
	p.vocodeTune.( p, b, e, e.rpp,
		chord:#[1,2],
		dur: b.sum +2,
		sus:b.sum,
		amp: 0.1,
		modGain:3.5,
		carrierGain:0.0,
		durRel: 2
	);
	// { e.playbuf }.play
}
);
["(boom) Thalassa and I must now (boom) also depart",[-1,1,2,3,1,4,2,5, 5,4.5, 4.5,7].dm(\d)].addLine;
P.still(\clear,syl:0, timecode: 0.seconds, music: { |p b e|
	 e.still.( 
		wait: b.drop(1).sum,
		text: ["Thalassa and I","must now also depart"],
	)
});
//Song.voxDepart= VocalRPP(\depart,\vox);
//Song.voxDepart= VocalRPP(\depart,\newTest);
P.synthV(role: \vocoder, take: \lead, params: {|p b| [
	lyrics: "r thalassa + + and I must now also + depart +",
	filter: (midinote: _ - 12), 
	pitchTake: 1
] }, music:{|p b e|
	p.vocodeTune.( p, b, e, e.rpp,
		0.1,
		durRel:1,
		verb:0.5,
		modGain:3
	);
	fork{
		1.wait;
		MegaBind(
			[
				p.tune[e.start].list.midicps/.t[2,4].flatten
			],
			b[0]+1 =>_.bubble ++ b.drop(1),
			[],
			{|i|
				Saw.ar(i.freqSeq,40)
				* Env.asr().kr(0,gate:i.gateSeq)
				//* 0.2
			},
			{|i|
				Mix.ar(i)=>Out.ar(p.carrierBus.index,_)
			}
		).play
	}

});
P(\bass,start:\depart,music:{|p b e| 
				MegaBind(
					[
						[1,2,\r],
						[\r,12,11.5]
					].df(\d),
					b.parse([8,4])++1,
					[
						amp:[0.5,0.3],
						attack:[1,2.5]
					],
					{|i|
						var freq=i.freqSeq/[2,4];	
						var width=6;
						//var gate=\gate.kr(0);
						Gendy2.ar(minfreq:freq-width,maxfreq:freq+width)
						=>Mix.ar(_) *0.5
						+Gendy1.ar(minfreq:freq-width,maxfreq:freq+width)
						* 0.1 * i.amp
						=> PlateReverb.ar(_,10,mix:0.5) 
						* Env.asr(i.attack,1,8).kr(0,gate:i.gateSeq)
						//=>Out.ar(\out.kr(0),_)
				},
				{|i| 
					Mix.ar(i)
					 /
					 2
					},
					release:b.sum+3
				).play
	});
// P.tune(\depart,Pset(\out,Song.carrierBus.index,_));
["(boom) into oblivion. ",[-2,-7,1,2,1,-5,-4].dm('c#',octave:6)].addLine;
P.still(\clear,syl: 0, timecode: 0.seconds, music: { |p b e|
	 e.still.( 
		wait: b.sum,
		text: ["into","oblivion"],
	)
});
P.tune('into oblivion',Pbindf(_,\amp,0.06,\out,Effect.bus( { |i| EchoNone.ar(i,2,[1.3, 2 ]*0.6,9)*0.6=> { |i| i+( 0.5*PitchShift.ar(i,pitchRatio:[1.5,2]) ) }  } , inputChannels:2, out:2)));
P.synthV(role: \vocoder, take: \lead, params: {|p b| [
	lyrics: "r into + oblivion + + +",
	filter: (midinote: _ - 12), 
	pitchTake: 1
] }, music:{|p b e|
fork{
		// 1.wait;
		MegaBind(
			[
				p.tune[e.start].list.midicps/.t[2,4].flatten
			],
			b[0]+1 =>_.bubble ++ b.drop(1),
			[],
			{|i|
				Saw.ar(i.freqSeq,40)
				* Env.asr().kr(0,gate:i.gateSeq)
				//* 0.2
			},
			{|i|
				Mix.ar(i)=>Out.ar(p.carrierBus.index,_)
			}
		).play
	};

	p.vocodeTune.( p, b, e, e.rpp,
		0.15,
		durRel:3,
		chord:#[1,2,0.5,4],
		mix:0.2,
		sus: b.sum,
		rel:1,
		modGain: 4.dbamp
	);

});
P(\counter,start:'into oblivion',music:{|p b e| 
				[
					freq: [5,4,3,2,1].df('a-',octave:4).q,
					dur: b.parse([2,1,1,[ 2,0.5 ],0.5]) => _.q,
					legato:1.1,
					amp:0.07
					//out:Effect(EchoNone.ar(_,b.sum+b.last,b.sum+b.last,9)).bus.index
				].pp

	});

["(echo)","r", Song.durs['into oblivion'].list.asArray ].addLine;
P(\counterEcho,start:'echo',music:{|p b e| 
				[
					instrument:\stringyy,
					freq: [5,4,3,2,1].df('a-',octave:4).q,
					dur: b.parse([2,1,1,[ 2,0.5 ],0.5]) => _.q,
					amp:0.2,
					legato:1,
					//out:Effect(EchoNone.ar(_,b.sum+b.last,b.sum+b.last,9)).bus.index
				].pp

	});

P(\echo,start:'echo',music:{|p b e| 
				[
					freq:[\r,-7,1,2,1,-5,-4].df('c#',octave:6).q,
					dur:b.q,
					instrument:\sawSynthSustain,amp:0.02,
				].pp
	});
["KIRK: Is there any way we can help you, Sargon? ",[12,11,13,11,7,6,5,11,7,7,6].dm(\c)].addLine;
P.still(\kirkHelp, timecode: 5051.6.seconds, music: { |p b e|
	 e.still.( 
		wait: b.sum,
		text: ["is there","any way"],
	).sequenceText2(
			b.parse([5]), [ 
			["we can help you","Sargon?"],
			],
	)
});
P.synthV(role: \kirk, take: \lead, params: {|p b| [
	lyrics: "Is there any + way we can help you Sargon + ",
	filter: (midinote: _ - 12), 
	legato: [1, 1, 1, 1, 0.9, 1, 1, 1, 0.9, 1, 1, ],
	pitchTake: 1
] }, music:{|p b e|
	{
		e.playbuf
		* -4.dbamp
		=> p.synthVTracks.at(e.key).()
	}.play

});
P.tune(\help,Pbindf(_,\legato,1.5, \instrument, \visual_pad, \amp,0.2,\rel,0.1) <> Pmul(\freq,0.5,_));
	Song.sawWaves = "~/tank/super/waveforms/AKWF/AKWF-1024/AKWF_oboe/*".pathMatch.collect(SoundFile.openRead(_))[[1,3,12,12]];
( Song.akSaws.isNil.if {
	Song.akSaws = Song.sawWaves.size.collect({ FloatArray.newClear(Song.sawWaves[0].numFrames) }) ;
	4.do({ |i| Song.sawWaves[i].readData( Song.akSaws[i])});
	Song.sawBuffers = Song.akSaws.collect({|i| i.as(Signal)})
	.collect({|i| i.asWavetable})
	.collect{|i|Buffer.loadCollection(s, i)};
}
);

P(\line,start:\help,music:{|p b e| 
	var encoder = FoaEncoderMatrix.newOmni;
	MegaBind(
		[
			p.tune[e.start].list.midicps/4,
			p.tune[e.start].list.midicps/2
		],
		b,
		[ 
			pan: [35,-35].degrad,
			delay: [0,0.1]

		],
		{|i|
			Osc.ar( p.sawBuffers.choose.bufnum, i.freqSeq => Vibrato.kr(
				_,5,
				depth:0.01,
				delay:0.3,onset:0.3
			), 0.1 )
			//Saw.ar(  i.freqSeq, 0.1 )
			* Env.asr().kr(0,gate:i.gateSeq)
			=> DelayN.ar(_,0.2,i.delay)
			=> FoaEncode.ar(_,encoder)
			=> FoaTransform.ar(_, 'press',pi/2,i.pan)
		},
		{|i|

			Mix.ar(i) => FreeVerb.ar(_,0.7,0.5) 
			* 0.2
			=> Monitors.ambi(_)
			//=> FoaDecode.ar(_,Monitors.decoder) //=> Out.ar(3,_)
			//=> {|i|i[[0,1,3,4,2]]}
			//* 0.2
			//s.meter
			//Monitors.ar(Dust.ar(100))
		}
	).play
});
["SARGON: Yes, my son. ",[1,-7,-5].dm('a-',scale:\mixolydian)].addLine;
P.still(\clear, timecode: 0.seconds, music: { |p b e|
	 e.still.( 
		wait: b.sum,
		text: ["yes","my son"],
	)
});
P.synthV(role: \vocoder, take: \lead, params: {|p b| [
	lyrics: "yes my son",
	legato: [0.9,1,0.9, ],
	pitchTake: 1,
	filter: (midinote: _ - 12), 
] }, music:{|p b e|
	p.vocodeTune.( p, b, e, e.rpp,
		verb:0.1,
		att: 2,
		rel:1,
		sus: b.sum - 3,
		dur: b.sum  ,
		modGain:3
	)
});
P(\bass,start:'my son',music:{|p b e| 
				(
					instrument:\sawSynthSustain,
					dur:b.sum,
					rel:5,
					amp:0.03,
					freq:[1,-1,-11].df('a-')).play
	});
["You can allow Thalassa and me to ",[1,2,4,5,6,5,6,4,12,11].dm('a-')].addLine;
P.still(\clear, timecode: 0.seconds, music: { |p b e|
	 e.still.( 
		wait: b.sum,
		text: ["you can allow","Thalassa and me to"],
	)
});
P.synthV(role: \vocoder, take: \lead, params: {|p b| [
	lyrics: "You can allow + Thalassa + + and me to ",
	pitchTake: 1,
	// filter: (midinote: _ - 12), 
	filter: (midinote: 50!10),
	defaultVibratoDepth: 0.1
] }, music:{|p b e|
	p.vocodeTune.( p, b, e, e.rpp,
		chord: #[0.66,1,2,4,8],
		verb:0.8,
		att:0.1,
		modGain:3,
		durRel:2
	);
	{
		p.laMer => PlayBuf.auto(2,_, 1.midiratio)
		/18
		=> Out.ar(p.carrierBus,_)
	}.play
});
P(\harpy,start:'Thalassa and me',music:{|p b e| 
				MegaBind(
					[
						[1,  \_, \_, \_, \_, \_, \_, \_, \_],
						[\r, 2,  \_, \_, \_, \_, \_, \_, \_],
						[\r, \r, 4,  \_, \_, \_, \r, 4,  \_],
						[\r, \r, \r, 5,  \r, 5,  \_, \_, \_],
						[\r, \r, \r, \r, 6,  \r, 6,  \_, 12],
					].df('a-'),
					b,
					[],
					{|i| 
Pulse.ar( i.freqSeq , 0.2)
						* Env.asr(0,1,2).kr(0,gate: i.gateSeq)
						* 0.1
					},
					{ |i| 
						Splay.ar(i) 
						*0.2
						=> Phaser2.ar(_,rate:0.15)
					} 


				).play;
	});
P(\bass,start:'Thalassa and me',music:{|p b e| 
				[
					freq: [11,7,5].df('a-',octave:3,scale:\mixolydian).q,
					dur: b.parse([3,5,2]).q,
					legato:[1,0.90,1.3].q
				].pma(\sawSynthSustain).play

	});
["(boom boom) share your bodies again. ",[1,1,13,12, 13,14,13,12,11].dm(\f)].addLine;
P.still(\clear,syl: 1, timecode: 0.seconds, music: { |p b e|
	 e.still.( 
		wait: b.sum,
		text: ["share your bodies","again"],
	)
});
// Song.durs[\bodies] = Song.durs[\bodies].list + [0,0,0,0,0,0,0,0,-1.2] => _.q;
Song.durs.filter(\bodies, {|i| i.dropLast ++ ( 0.996 +0.2 ) });
// Song.durs[\bodies].list.last;
// 1.996 (+ 0.2)
//P.tune(\bodies,_.drop(2),syl:1);
Song.shareVox=VocalRPP(\bodies,\share);
P.tune(\bodies);
P.synthV(role: \vocoder, take: \lead, params: {|p b| [
	lyrics: "r r share your bodies - + again +",
	filter: (midinote: _ - 12), 
	pitchTake: 1
] }, music:{|p b e|
	p.vocodeTune.(p,b,e,e.rpp,0.1,0,b.sum,2,dur:b.sum+1)
});
Song.setQuarters(\bodies,[1,1,1,1/4,1/4,1,1/2,1/2,1/2]);
P(\drums,start:\bodies,music:{|p b e| 
				[
					freq:[\r,\r,1].q,
					dur:p.quarters[\bodies],
					instrument:\sn_808,
					out: Effect(EchoNone.ar(_,0.5,[ b[0]/3,b[0]/4 ],3)).bus.index
				].pp
	});
P(\shake,start:\bodies,music:{|p b e| 
				[
					time:[0.05,0.1].q(inf),
					amp:0.2,
					resonantFreq:60,
					//dur:b[[0,1]].stutter(4)/4 => _.q(3),
					dur:p.quarters[\bodies].list.stutter(4).q/4,
					//dur:p.quarters[\bodies],
					up:[1,0].q(inf),
					down:[0,1],q(inf),
					inst:13.rand
				].pm(\shakeEnv).play
	});
P(\chord,start:\bodies,music:{|p b e| 
				[
					freq:[\r,[-5,1,3].df(\f),[1,3].df('b-')].q,
					dur:b.parse([2,5,2]).q	,out:2
				].pp;
				[
					freq: [
						[-5,1,3].df(\f),
						[-5,1,3].df('b-')
					].q,
					dur:b.parse([4,3]).q,
					instrument:\stringyy,out:1
				].pp
	});
P(\boomboom,start:\bodies,music:{|p b e| 
				[
					instrument:\bd_808,
					dur:b.q.fin(2)
				].pp;

				[
					instrument:\harp,
					amp:0.03,
					freq: [-7,1,-5,-2.5,-4,-1].df(\f,octave:[3,4],scale:\mixolydian).q,
					dur:b.parse([1/2,1/2,[2, 2, 1/2 ], 1/2,1 ,1]).q,
					out: Effect({|i| MoogVCF.ar(i,2000,0.5)*2 },out:2).bus.index
				].pp;
				[
					instrument:\sawSynth,
					freq: [1,1,-7,-4,-4].df(\f,octave:[3,4]).q,
					dur:b.parse([1,2,[ 2, 1/2 ],[ 1/2,1 ],1]).q
				].p//p
	});
["A last moment together. ",[1,11,7,6,4,3,-7].dm('f#')].addLine;
P.tune(\last);
P.still( \clear, start: \last, timecode:0, music: { |p b e|
	e.still.value(
		wait: b.sum-3,
		fade:3,
		text: ["a last moment","together"]
	);
});
//Song.lastMoment=VocalRPP(\last,\tune);
P(\vox,start:\last, rpp:VocalRPP(\last,\tune),lag:-1+0.2,music:{|p b e|
	p.vocodeTune.(p,b,e,e.rpp,0.1,1,b.sum+5,2,dur:b.sum+2,chord:#[1,2,0.33])
});
P(\chord,start:\last,music:{|p b e| 
	MegaBind(
			[
				[\r,  11,  7, 6, 4, 3, -7],
				[\r,  3,  \_, \_,\r],
				[\r,  5,  \_, \_,\r],
				[1, \_, -7, -6,\_],
				[\r,-11,-14,\_,\_,-11,\_],
				[\r,-11,-24,\_,\_,-22,\_],
			].df('f#')
			,
			b.dropLast ++ (b.last * 1/2),
			//b.drop(1).parse([1,3,2]),
			[ 
				finalRel: [10,1,1,1,1,1],
				amp: ( [1,1,1,1,2,2]/2 )
			],
			{|i x|

				Saw.ar(i.freqSeq*({rrand(1.01,0.99)}!4),0.1)  
				* Env.asr(releaseTime:i.finalRel).kr(0,gate:i.gateSeq)
				* 0.05
				* i.amp
				
			},
			{|i|
				i.collect(Mix.ar(i))
				=> DWGReverbC1C3.ar(_)
			
			},
			release:12
		).play
});
["(Mulhall nods, and they go over to the science station for the light trick and voice change.) ","g r r" ].addLine;
Song.durs.filter(\nods,_ + [1,0,0]);
// P.tune(\nods);
Song.durs.filter( _ + [0,0,5] );
P(\nod,start:\nods,music:{|p b e| 
	[
		freq:[ [1,3,5].df(\g),\r ].q,
		// dur:b.parse([2,1]) + [5,0] =>_.q ,
		dur:5,
		rel:4,
		amp:0.05,
		out: Effect(EchoNone.ar(_,1,0.35,5,mul:0.2)).bus.index,

		instrument:\wash,
	].p.play;
	(
		lag:b[0] - 0.2,
		instrument:\wash,
		// freq: [1.5,3,5].df(\g)
		freq: [5.5,7].df(\g),
		amp:0.05
	).play
});
P.still(\kirkNod, timecode: 5105.8.seconds, music: { |p b e|
	 e.still.( 
		wait: b[0]/2,
		text: ["",""],
	)
});
P.still( \chapel, start: \nods, timecode:5105.58.seconds, music: { |p b e|
	{
		e.still.value(
			wait: 1,
			fade:1
		);
	}.defer(b[0]/2)
});
P.still( \walking, start: \nods, syl:0, timecode:5108.7.seconds, music: { |p b e|
	e.still.value(
		wait: 1,
		fade:2
	);
});
P(\transform,start:\nods,syl:1,music:{|p b e| 
	//(
	//	dur:b.sum,
	//	freq:[1,3,4,6].df(\e,scale:\whole),
	//	instrument:\stringyy,
	//	width:13,
	//	wet:0.2
	//).play;
	var synths,bus;
	Synths(\transLinen,\sustain,b.sum,\freq,[1,3,4,6].df(\e,scale:\whole),\amp,0.1,\out,1);
	Synths(\transLinen,\sustain,b.sum,\freq,[1,3,4,6].df(\e,scale:\whole),\amp,0.1,\out,2);

	synths= 
	Synths(\trem2 ,\amp,0.05,\scale,2,\freq,[1,3,4,6,11,13,14,16,21,23].df(\e,scale:\whole),\out,[0,1,2,3,0,1,2,3,0,1])
	;
	bus = Bus.control;
	{Env.linen(0,b.sum-9,9).kr(2,gate:1)*0.05}.play(s,bus.index);
	synths.map(\amp,bus);

	s.bind{{ |pitchScale=1.15 loss=0.99998 |
		var env=Env.linen(0,b.sum-8,8).kr(2,gate:1)*0.175;
		var numChannels=4;
		var exc = Dust.ar(2!numChannels)+Impulse.ar(0);
		var sig;
		exc = Decay.ar(exc,0.02);
		exc=Integrator.ar(exc,0.8,0.1);
		exc=PinkNoise.ar(exc);
		sig=MembraneCircle.ar(exc,[0.007,0.0073]*pitchScale,loss)*env;
		sig * 0.5
	}.play};
	fork{b.sum+5=>_.wait;synths.free}
});
P.still( \purple, start: \nods,syl:1, timecode:5116.5.seconds, music: { |p b e|
	e.still.value(
		wait: 6,
		fadeIn: 2,
		fade:3
	);
});
["MULHALL: Oblivion together does not",[2,1,2,1].dm(\c) ++ [4,4, 3, 1, -5,-3,-6,1,3,3,2,-7,-4.5,-2,-5,-7,2,2,1,-6,-3,-1,-4,-6,2,1,-7,2,1 ].dm(\a)].addLine;
P.tune( { |i|  i.drop(5) <> (instrument: \harp, decaytime:10,coef:0.1, out: Effect.bus( { |i| DWGReverbC1C3.ar(i) => Phaser2.ar(_,rate:0.11) /7} )) }, syl:4 );
P.synthV(role: \thalassa, take: \lead, params: {|p b| [
	lyrics: "Oblivion + + + together + + r r r r r r r r r r r r",
	filter: (midinote: _ + (12 * [1.dup(4) ++ 0.dup(17)])), 
	phonemes:[ "@","p l \i","w i"," A n", "th @","k e ","t a \r" ], 
	/* "oblivion together".xsampa
	"among".xsampa
	"blood".xsampa
	"give".xsampa
	"beyond".xsampa
	"be".xsampa */
	legato: [1, 1, 1, 0.5, 1, 1,  2, 1 ],
	pitchTake: 1
] }, music:{|p b e|
	{
		e.playbuf
		=> p.synthVTracks.at(e.key).()
	}.play
});
P.synthV(role: \thalassa,syl: 27, take: \continuation,
	// pbind: Song.enlarge2(0),
	pbind: {|p b |
		[
			midinote: 
			Song.tune[Song.section('Oblivion')].list.drop(28) ++ Song.tune[ Song.section('Oblivion') + 1 ].list 
			=> _.q, 
			dur: Song.durs[\Oblivion].list.parse([28, 1, 1, 1, 1,1 ]).drop(1) ++ Song.durs[Song.section('Oblivion' )+1].list 
			=> _.q
		].p
	},
	params: {|p b| [
	// lyrics: "together + + does not frighten - + me r r beloved + + r r",
	lyrics: "r r r does not frighten  + me - r r beloved + + r r",
	phonemes: ["th @","k e ","t a \r", "t A ts","n A th", "f r\\` a :\\i", "th A n", "m i","","","","b i", "l A w","e t"],
	pitchTake: 1
] }, music:{|p b e|
	{
		e.playbuf
		=> p.synthVTracks.at(e.key).()
	}.play

});
P(\tune,start:'Oblivion together',music:{|p b e| 
	MegaBind(
			[
				[2,1,2,1].df(\c) ++ [4,4,3].df(\a,octave:4)
			],
			b,
			[],
			{|i|
				Blip.ar(i.freqSeq * [1,1.01],20)
				* Env.asr().kr(0,gate: i.gateSeq)
			},
			{|i|
				Mix.ar(i)
				=> EchoCubic.ar(_,1,0.3,9)
				=> Phaser2.ar(_,rate:0.1)
				//=>PlateReverb.ar(_,  size: 0.8,  decayTime: 2,  damping: 0.6,  diffusion: 1.0,  mix: 1)
				*0.05
			
			}
		).play
});
P.still( \oblivion, start: 'Oblivion together', timecode:5125.5.seconds, music: { |p b e|
	e.still.value(
		wait: b.sum+6 ,
		fadeIn:8,
		text: [ "","" ]
	);
	fork{
		6.wait;
		e.still.setText(["oblivion",""])
	}
});
P.synthVs(\kevin, take: [ \bg, \bg2 ],
	pbind: {|p b| 
		[
			dur: b.parse([4, 1, 2, 2, 3,  1, 2, 2, 3,  1, 2, 2, 3, 1,  1, 3 ]).q,
			midinote:   [-1, 4, 4, 3, -1, 3, 3, 2, -1, 2, 2, 1, -1, 2, 1, -7].dm(\a)
		].p
	},
	params: {|p b| [
	lyrics: "  r together + + r together + + r together + + r together + +",
	pitchTake: [1, 3],
	paramTension: -0.5,
	paramBreathiness: 0.5,
	vocalMode: \Soft
] }, music:{|p b e|
	{
		e.playbuf
		=> p.synthVTracks.at(e.key).()
		=>DWGReverbC1C3.ar(_,c1:20,c3:1)
	}.play
});
P.synthVs(\kevin, take: [ \longerBg, \longerBg2 ],
	pbind: {|p b| 
		[
			dur: b.parse([8, 1, 1, 1, 2,  3,  1,   1, 1, 2, 3,  1, 1, 1, 2, 3]).q,
			midinote:   [-1, 5, 3, 6, 11, -1, 4.5, 2, 5, 7, -1, 3, 1, 4, 6].dm(\a)
		].p
	},
	params: {|p b| [
	lyrics: "r oblivion + + + r oblivion + + + r oblivion + + + r",
	filter: (midinote: _ - 12), 
	pitchTake: [1, 3],
	paramTension: -0.5,
	paramBreathiness: 0.5,
	vocalMode: \Soft
] }, music:{|p b e|
	{
		e.playbuf
		=> p.synthVTracks.at(e.key).()
		=>DWGReverbC1C3.ar(_,c1:20,c3:1)
	}.play
});
P(\arp,start:'Oblivion together',syl:4,music:{|p b e| 
	var score = VoiceLeading([
		[4, 3,  1,  -5, -3, -6, 1,  3,  3,  2,  -7, -4.5, -2, -5, -7, 2,  2,  1,  -6, -3, -1, -4, -6, 1,  -5, \_, \_, \_, ],
		[4, \_, 3,  \_, \r, \r, \r, \r, 3,  \_, 2,  \_,   \r, \r, \r, 2,  2,  \_, 1,  \_, \r, \r, \r, 2,  1,  -7, 2,  1,  ],
		[1, \_, \_, \_, 6,  \_, \_, \_, -7, \_, \_, \_,   5,  \_, \_, \_, -6, \_, \_, \_, 4,  \_, \_, \_, -5, \_, \_, \_, ]
	].df(\a),b.drop(1)=>_.flat);
	[	
	//freq: 	[4,3,1,-5,-3,-5,1,3,  3,2,-7,-5,-4,-5,-7,2].df(\a).q,
		//freq: 	[4,3,1,-5,-3,-6,1,3,  3,2,-7,-5,-2,-5,-7,2].df(\a).q,
		freq:score.lines(0),
		amp:0.02,
		dur:score.voice(0).durs.q,
		legato:3,
		pan:-1,
		out:2

	].pp;
	[
	//	freq:[4,3,\r,\r, 3,2,\r,\r, 2,1, \r, \r, 1,-7,2,1].df(\a).q,
		freq:score.lines(1),
		dur:score.voice(1).durs.q,
		instrument:\stringyy,
		amp:0.31,
		legato:1,
		out:4
	].pp;
	[
		freq:[1,6,-7,5, -6,4, -5,3].df(\a,octave:4).q,
		instrument:\sawSynthSustain,
		amp:0.06,att:2,
		dur:b.drop(1).clump(4).collect(_.sum).q(4),
		freq:score.lines(2)/2,
		dur:score.voice(2).durs.q,
		legato:[2,1,2,1,2,1,1,1].q
	].pp
	
});
{
[" frighten me (b b ), beloved(b b).",[-7,-6,-3,-4, -17, -2, -7, -6, -5, -17, -1].dm(\a)].addLine;
P.tune();
P(\arp2,start:'frighten',music:{|p b e| 
	var score = VoiceLeading([
		[-7, -6, -3, -4, -17, -2, -7, -6, -5, -17, -1, -1.5],
		[-7, -6, -3, \_, \_,  \r, -7, -6, -5, \_,  \_, \_ ],
		[1,  \_, \_, \_, \_,  \_, \_, -7, \_, \_,  \_, -6.5], //  5, \_, \_, \_, -6, \_, \_, \_, 4, \_, \_, \_, -5, \_, \_, \_, -4, \_, \_]
		[]
	].df(\a),b.drop(1)!4=>_.flat);
	[
	//freq: 	[4,3,1,-5,-3,-5,1,3,  3,2,-7,-5,-4,-5,-7,2].df(\a).q,
		//freq: 	[4,3,1,-5,-3,-6,1,3,  3,2,-7,-5,-2,-5,-7,2].df(\a).q,
		freq:score.lines(0),
		amp:0.02,
		dur:score.voice(0).durs.q,
		legato:3,
		pan:1

	].pp;
	[
	//	freq:[4,3,\r,\r, 3,2,\r,\r, 2,1, \r, \r, 1,-7,2,1].df(\a).q,
		freq:score.lines(1),
		dur:score.voice(1).durs.q,
		instrument:\stringyy,
		amp:0.31,
		legato:1,
		pan:-1
	].pp;
	[
		instrument:\sawSynthSustain,
		amp:0.06,att:2,
		freq:score.lines(2)/2,
		dur:score.voice(2).durs.q,
		//legato:[2,1,2,1,2,1,1,1].q
	].pp
	
});
[" Promise we'll be together. ",[6,5,3,5,6,11,7,6].dm('b-')].addLine;
P(\line, music: { |p b e|
	[
		freq: [6, 5, 3, 2, 1].df('b-').q,
		dur: b.q,
		instrument: \wash, freqLag:0.2
	].pp//m
});
P.synthV(role: \thalassa, take: \lead, params: {|p b| [
	filter: (midinote: _ - 12), 
	lyrics: "Promise + r we'll be together + +",
	phonemes:["ph r\\` A","m @ s","","w i l", "b i","th @ ","k e","t a r\\`" ],
	lag: [0.05,0,0,0,0,0,0,0],
	legato:[ 1, 1.5, 1, 1, 0.7, 1, 1, 1 ],
	pitchTake: 1
] }, music:{|p b e|
	{
		e.playbuf
		=> p.synthVTracks.at(e.key).()
	}.play

});
P.tune('Promise',Pset(\instrument,\stringyy,_));
P.tune('se we',{ |i| i  => i.fin(5)<> [instrument: \harp, coef:0.1, amp:0.03].p});
P(\harpTwo, music: { |p b e|
	[
		freq: [\r, 3, 2, 1].df('b-').q,
		dur: b.parse([2,1,1,1]).q,
		out: Effect.bus({|i| Pan2.ar(i, 0.8) },),
		coef:0.2,amp:0.02,
		instrument:\harp

	].pp
});	
P(\chords, music: { |p b e|
	[
		freq: [
			[ 3, 5, 7, 11].df(\g,\minor),
			\r,
			[ 3, 5, 7, 11].df(\a,\minor)
		].q, 
		dur: b.parse([3, 3, 2]).q,
		out: Effect.bus({|i| 
			i
			=> {|i| CombN.ar(i, maxdelaytime:0.2, delaytime:0.2, decaytime:3, mul:1.0, add:0.0) * 0.9 + i}
			=> Phaser2.ar(_, depth:0.5, rate:0.1, fb:-0.69, cfb:0.1, rot:1.5707963267949, rq:0.3)
		},)

	].pp
});
["KIRK: I promise, beloved. ","3 11 7/d/mixolydian 6 11 7/c".dm2].addLine;
P(\chords, music: { |p b e|
	[
		freq: [ \r, [1, 3, 5, 11], [2, 4, 7] ].df(\d, [4,5],\mixolydian).q,
		dur: b.parse([1,3,2]).q,
		out: [0,1],
		instrument:\default
	].ppm
});
P(\lines, music: { |p b e|
	MegaBind(
		[
			[\r, 1, 2],
			[\r, 3, 4]
		].df(\d)
		,
		b.parse([1, 3, 2]),
		[pan: [0.5,0.8]],
		{|i|  
			Gendy3.ar(
				ampdist:1,
				durdist:1,
				adparam:1.0,
				ddparam:1.0,
				freq:i.freqSeq.lag(0.4) * [0.5,1],
				ampscale:0.1,
				durscale:0.1,
				initCPs:12,
				knum:3,
				mul:1.0,
				add:0.0
			)//(i.freqSeq,0,0.1)
			* Env.asr(0.3,1,3).kr(0,gate:i.gateSeq)
			=> LPF.ar(_,950) / 10
			=> Pan2.ar(_, i.pan)
		},
		{|i|  Mix.ar(i)}
	).play
});
P(\line, music: { |p b e|
	[
		freq: [\r, 11, 7, 5, 4].df(\d, \mixolydian).q,
		dur: b.q,
		amp: 0.04,
		instrument:  \sparkTriangle , depth: 0.01,
		out: Effect.bus({|i| Pan2.ar(i,-0.3) => DWGReverbC1C3.ar(_,mix:0.2) },)
	].ppm;
	[
		freq: [\r, 11, 7, 5, 4].df(\d,[ 4, 5 ], \mixolydian).q,
		lag: Ptuple( [0, Pwhite(0.01,0.03,inf)] ),
		dur: b.q,
		instrument:  \harp, depth: 0.01,coef:0.1,amp:0.02,

		out: Effect.bus({|i| Pan2.ar(i,0.3) },)
	].pp
});
P.synthV(role: \sargon, take: \lead, params: {|p b| [
	lyrics: "I promise + belove + ed",
	filter: (midinote: _ - 12), 
	phonemes: ["a e i","p r a","m e s","b i","l a v","e d" ],
	legato: [1, 1, 0.9, 1, 1, 1, ],
	paramTension: -0.0, paramLoudness: 3,
	pitchTake: 1
] }, music:{|p b e|
	{
		e.playbuf
		=> p.synthVTracks.at(e.key).()
	}.play

});
P.tune();
P.still(\kirkPromise, timecode: 5132.4.seconds, music: { |p b e|
	 e.still.( 
		wait: b.sum,
		text: ["I promise","beloved"],
	)
});
["MULHALL: Together forever. "," 3 4 5 7 13 12".dm(\d)].addLine;
P.synthV(role: \thalassa, take: \lead, params: {|p b| [
	phonemes:["th @ ","k e","t a r\\`","f a r\\`","e","w a r\\`"],
	lyrics: "together + + forever + +",
	pitchTake: 1
] }, music:{|p b e|
	{
		e.playbuf
		=> p.synthVTracks.at(e.key).()
	}.play

});
P.tune( Pbindf(_,\instrument,\stringyy, \amp,0.3) <> Pmul(\freq,0.5,_) );
P.still(\herAgain, timecode: 5135.6.seconds, music: { |p b e|
	 e.still.( 
		wait: b.sum,
		text: ["together","forever?"],
	)
});
["KIRK: Forever beloved. Forever. ","5 4 3 4 3 2/c# 5 4 3/c".dm2].addLine;
// Song.durs.filter('ver be',{|i| var last = i.last; i.dropLast ++ (i.last * 1.5)});
P.tune(_ <> [instrument: \stringyy, amp: 0.5].pm);
P.synthV(role: \sargon, take: \lead, params: {|p b| [
	lyrics: "Forever + + beloved + + forever + +",
	legato: [1, 1, 1, 1, 1, 0.7, 1, 1, 1],
	paramTension:0,
	pitchTake: 1
] }, music:{|p b e|
	{
		e.playbuf
		=> p.synthVTracks.at(e.key).()
	}.play

});
P(\lick,syl:5, music: { |p b e|
	[
		freq: [3, 2, 1].df(\c).q,
		dur: b.drop(1).q,
		instrument: \sparkTriangle, depth:0.01
	].ppm;
	[
		freq: [5, 7, 3].df(\c,\mixolydian).q,
		dur: b.drop(1).q,
		instrument: \sawSynthSustain

	].ppm
});
P(\bassline, music: { |p b e|
	[
		// freq: [[ 1, 16,14,21 ], [ 5, 12, 15, 17 ], 6, 7, 12, 11, 1.5, 1.5, 7].df('a-',3,\mixolydian).q,
		freq: [[ 1, 16,14,21 ], [ 5, 12, 15, 17 ], 6, 7, 12, 11, 1.5, 1.5, 7].df('a-',3,\mixolydian).q,
		dur: b.q,
		amp:0.4, instrument: \sawSynthSustain,
		pulse: 0.6
	]//.pp
});
P(\voices, music: { |p b e|
	MegaBind(
		[
			[11, 7,  6,  7,  6,  5, \r].df('a-',6,\mixolydian) ++ [5, 4, 3].df(\c,7) ,
			[-1, -5, -6, -7, 2,  1, \r  ].df('a-',\mixolydian) ++ [1, 5, \_].df(\c,3),
			[14, 12, 11, 12, 13, 14, \r ].df('a-', \mixolydian) ++ [13, 12, 11].df(\c),
			[16, 14, 14, 14, 11, \r, \r].df('a-', \mixolydian) ++ [7, 17, 16].df(\c,\mixolydian)
		]
		,
		b.parse([1, 1, 1, 1, 1, 0.9,0.1,1,1,1]),
		[],
		{ |i| 
			Saw.ar(i.freqSeq /2,0.05)
			* Env.asr(attackTime:0.01, sustainLevel:1.0, releaseTime:1.0, curve:-4.0).kr(0,gate:i.gateSeq)
		},
		{|i|  Mix.ar(i)}
	).play
});
P(\chords,syl: 5, music: { |p b e|
	[
		freq: [[7,11, 13, 15], [7, 11, 14],[7, 11, 13] ].df(\c,\mixolydian).q,
		instrument: \stringyy, amp:0.3
	].ppm
});
P.still(\himAgain, timecode: 5137.7.seconds, music: { |p b e|
	 e.still.( 
		wait: b.sum,
		text: ["forever beloved","forever"],
	)
});
["(They embrace and kiss, and the light thing happens again during it.) ",[11, 7, 5, 3, 2, 1, 6, 5, 5].dm(\b, \minor),].addLine;
P.tune();
// P.tune();
Song.durs.filter(\kiss, {|i| var last = i.last; i.dropLast ++ (last * 4)});
P(\transform, syl: 7, music:{ |p b e| 
	// Synths(\transLinen,\sustain,b.sum,\freq,[1,3,11,13].df(\c),\amp,0.1,\out,1);
	// Synths(\transLinen,\sustain,b.sum,\freq,[1,3,11,13].df(\g,scale:\minor),\amp,0.1,\out,2);
	// Synths(\transLinen,\sustain,b.sum,\freq,[1,3,11,13].df('c#',scale:\minor),\amp,0.1,\out,3);
	// Synths(\transLinen,\sustain,b.sum,\freq,[1,3,11,13].df('f#'),\amp,0.1,\out,4);
	//////////strings
	p.synful1.patch(\violas,\tremsulpont,0);
	p.synful2.patch(\violins2,\tremsulpont,0);
	(
		expression:100,
		freq:[3,5,6.5,11,13].df(\c),
		type:\synful,
		instance:p.synful1,
		dur:b.sum,
		legato:1,
		amp:1
	).play;
	[ 
		expression:100,
		freq:[1,1].df(\c).q,
		type:\synful,
		instance:p.synful1,
		// dur:[ b.sum, p.durs[e.start+1].list.sum ].q,
		dur: b.sum.q(1),
		legato:1,amp:1 
	].pp;
	(
		expression:200,
		note:[3,5,6.5,11,13].df('f#'),
		type:\synful,
		instance:p.synful2,
		dur:b.sum,
		// dur: b.sum.q,
		legato:1,
		amp:2
	).play;
	[
		expression:100,
		freq:[[ 1 ],[ -7,-17 ]].df('f#').q,
		type:\synful,
		instance:p.synful1,
		// dur:[ b.sum, p.durs[e.start+1].list.sum ].q,
		dur: b.sum.q(1),
		legato:1,
		amp:1
	].pp;
	p.synful1.syn.set(\out,Effect(FreeVerb.ar(_,0.75,0.55)).bus.index);
	p.synful2.syn.set(\out,Effect(PlateReverb.ar(_,mix:0.55),out:0).bus.index);
	////////timpani
	{ |pitchScale=1.15 loss=0.99998 |
		var env=Env.linen(0,b.sum-5,8).kr(2,gate:1)*0.175;
		var numChannels=4;
		var exc = Dust.ar(2!numChannels)+Impulse.ar(0);
		var sig;
		exc = Decay.ar(exc,0.02);
		exc=Integrator.ar(exc,0.8,0.1);
		exc=PinkNoise.ar(exc);
		sig=MembraneCircle.ar(exc,[0.007,0.0073]*pitchScale,loss)*env;
		sig
	}.play;

});
P(\chords, music: { |p b e|
	[
		freq:[
			[3, 5, 11].df(\b,\minor),
			[1, 3, 6, ].df(\d,6,\whole)
		].q,
		dur: b.parse([8,1]).q,
		instrument: \stringyy, amp:0.4,
		freqLag:3

	].ppm
	;
	[
		freq:[ -3, -16.5 ].df(\b,\minor).q,
		dur: b.parse([8,1]).q,
		instrument: \stringyy, amp:0.2,
		freqLag:0.3
	].ppm
});
P(\bassnote, music: { |p b e|
	(
		freq: [1, 4, 6, 12].df(\a,2),
		out: Effect.bus({|i|i/2 + Fverb.ar(i[0], i[1], predelay:0, input_amount:100, input_lowpass_cutoff:10000, input_highpass_cutoff:100, input_diffusion_1:75, input_diffusion_2:62.5, tail_density:70, decay:70, damping:5500, modulator_frequency:1, modulator_depth:0.5) }, inputChannels: 2),
		dur: b.dropLast.sum
	)//.play
});
P(\line, music: { |p b e|
	[
		freq: [11, 7, 5, 3, 2, 1, 6, 5, ].df(\b, \minor).q,
		dur: b.q
	].pp
});
Song.kissXfade = 1;
P.still(\kiss, timecode: 5150.25.seconds, music: { |p b e|
	 e.still.( 
		wait: b[..7].sum + b[8] - p.kissXfade ,
		text: ["",""],
	)
});
P.still(\kissBlue, syl: 7, timecode: 5156.seconds, music: { |p b e|
	 e.still.( 
		wait: b.drop(1).sum + 1,
		fadeIn: b.drop(1) / 2,
		text: ["",""],
		// fade: 1
	)
});
// ["alt end", "r", [30]].addLine;
/* P(\clip,lag:1.2, music: { |p b e|
	// "open -a QuickTime\\ Player.app ~/tan~k/super/ending-clip.mov".unixCmd;
	"PlayQTVid.sh".unixCmd
}); */
["(beat) Well, I'm sure that Sargon appreciated your co-operation, Doctor Mulhall. ","-1 5 3 4 5 4 3 2 4 3 2 1 2/c# 1 2 3 2 1 -7 -6 -6 -5/d".dm2].addLine;
Song.endingGroup = Group.after(s.defaultGroup);
P.synthV(role: \kirk, take: \lead, params: {|p b| [
	lyrics: "r Well, I'm sure that Sargon +  appreciated + + + + your co-operation + + + + doctor + mulhall +",
	filter: (midinote: _ - 12), 
	legato: [1, 0.8, 1, 1, 1, 1, 0.8, 1, 1, 1, 1, 1, 0.6, 1, 1, 1, 1, 1, 1, 1, 1, 1],
	pitchTake: 1
] }, music:{|p b e|
	{
		e.playbuf
		// => p.synthVTracks.at(e.key).()
		/4
	}.play(target: p.endingGroup)

});
P(\bassline, music: { |p b e|
	[
		freq: [1, -4, -2,].df('c#') ++ [1, 2, 3, 6, 5, 4, 3].df(\d) / 4 => _.q,
		dur: b.parse([5, 3, 5, 1, 1, 1, 1, 1, 2, 2 ]).q,
		amp: 0.2, 
		group: p.endingGroup
	].pp
});
P(\cut,  music: { |p b e|
	{
		ReplaceOut.ar((0..4), {
			PinkNoise.ar(0.005)
			+ (
				Saw.ar(1.df('c#',3), 0.1)
				* Env.perc(0.05, b[ ..12 ].sum).kr()
			)
			* EnvGen.cutoff(wait:b.sum, release:0, curve:nil, doneAction:2)
		})

	}.play(addAction:\addToTail);
	(freq: 1.df('c#',[2,3]), lag:0.01).play
});
P.still(\kirkBack, timecode: 5211.5.seconds, music: { |p b e|
	 e.still.( 
		wait: b.sum,
		text: ["",""],
	).sequenceText2(
			b.parse([1,5, 6]), [ 
				["well I'm sure","that Sargon"],
				["appreciated","your"],
				["cooperation","Doctor Mulhall"]
			],
	)
});
["MULHALL: Yes. I was happy to co-operate, Captain. ","4 2 3 4 3 1/d 7 11 5 3 5 4/a/4".dm2].addLine;
P(\chord, music: { |p b e|
	[
		freq: [1, 3, 5, 7].df(\a,\mixolydian).bubble ++ [5, 11].df(\d).bubble ++ [1,3,5,7].df('f#',\minor).bubble ++ [5, 11].df(\b,4).bubble
		=> _.q,
		dur: b.parse([3, 4, 3, 2]).q
	].pp
});
P(\bassline, music: { |p b e|
	[
		freq: [1, 4, -6, 2].df(\a,3).q,
		dur: b.parse([3, 4, 3, 2]).q,
		amp:0.3
	].pp
});
P.synthV(role: \mulhall, take: \lead, params: {|p b| [
	lyrics: "Yes. I was happy + to co-operate + + + Captain + ",
	legato: [0.8, 1, 1, 1, 1, 0.6, 1, 1, 1, 1, 1, 1, ],
	pitchTake: 1
] }, music:{|p b e|
	{
		e.playbuf
		// => p.synthVTracks.at(e.key).()
		/4
	}.play(p.endingGroup)

});
P.still(\mulhallBack, timecode: 5218.35.seconds, music: { |p b e|
	 e.still.( 
		wait: b.sum,
		text: ["Yes","I was happy to"],
	).sequenceText2(
			b.parse([6]), [ 
			["cooperate","Captain"],
			],
	)
});
["CHAPEL: (boom) It (boom) was beautiful.","-5 6.5 -4.5 7 12 13 11 5 4 3 2 1 -5 1".dm2].addLine;
P(\chords, music: { |p b e|
	[
		freq: [5, 4.5, 4, 1].df(\c,3).q,
		dur: b.parse([2, 1, 2, 3]).q,
		instrument: \sawSynthSustain,
		// group: p.endingGroup
	].ppm;
	[
		freq: [\r, [-5, 1, 3].df(\g,\minor), [3, 5, 11].df(\b,4,\minor), [2, 4, 5, 7].df(\c)].q,
		dur:b.q,
		instrument: \sawSynthSustain,
		pulse:0.5
		// group: p.endingGroup
	].ppm
});

P(\sparkle, music: { |p b e|
	MegaBind(
		[ [-5, 1, 3, 13].df(\g,\minor), [3, 5, 11, 13].df(\b,4,\minor), [2, 4, 5, 7].df(\c), [-1, -5, 3, 11].df(\c) ].flop
		,
		b.parse([2,1,1]),
		[],
		{|i|  
			// SinOsc.ar(i.freqSeq,0,0.1)
			Gendy2.ar(
				ampdist:1,
				durdist:1,
				adparam:1,
				ddparam:1,
				minfreq:i.freqSeq-5.lag,
				maxfreq:i.freqSeq+5.lag,
				ampscale:0.9,
				durscale:0.9,
				initCPs:3,
				knum:nil,
				a:1.17,
				c:0.31,
			)
			/15
			* Env.asr(1, 1.0, 2.0, curve:-4.0).kr(0,gate:i.gateSeq)
		},
		{|i|  Mix.ar(i)}
	).play
});
P(\beautifulSparkle,syl:4, music: { |p b e|
	{
		Gendy3.ar(
			ampdist:0.1,
			durdist:0.1,
			adparam:0.1,
			ddparam:0.1,
			freq: [1,3].df(\c,[6,7,8]),
			ampscale:0.5,
			durscale:0.5,
			initCPs:2,
			knum:9,
			mul:1.0,
			add:0.0
		) /50
		* Env.linen(attackTime:1, sustainLevel:1.0, releaseTime:6, curve:-4.0).kr(2,gate:1)
	}.play
});
P(\line,syl:6, music: { |p b e|
	[
		freq: [13, 12, 11].df(\c).q,
		dur: b.drop(1).q,
		instrument: \sparkTriangle,
		amp:0.03
	].ppm;
	[
		freq: [ 5,4,3,2,1 ].df(\c,[ 4,5 ]).q,
		dur: b.drop(1).q,
		instrument: \harp, lag: Ptuple([0, Pwhite(-0.05,0.05,inf)]),
		coef:0.15,amp:0.02
	].pp;
	[
		freq: [ 5,4,3,2,1 ].df(\c,[ 6 ]).q,
		dur: b.drop(1).q,
		instrument: \wash, 
		freqLag:0,
		amp:0.02
	].ppm;
	[
		freq: [11, 5, 3, 2, 1, -5, -3].df(\c).q,
		instrument: \wash, amp: 0.02,
		dur: b.q
	].pp
});
P.synthV( \cheng, take: \lead, params: {|p b| [
	lyrics: "r it r was beautiful - + + r ",
	legato:[ 1,1,1,0.8,1,1,1,3 ],
	language: \english,
	pitchTake: 1
] }, music:{|p b e|
	{
		e.playbuf
		=> p.synthVTracks.at(e.key).()
	}.play

});
P(\fiveOne, syl:11, music: { |p b e|
	[
		freq: [[-5, 2,14,5,17],[1,13,5,21]].df(\c,4).q,
		legato: [ 0.5,1 ].q,
		release: [2,8].q,
		dur: b.drop(1).q,
		instrument: \stringyy , wet:0,mix:0,amp:0.03,width:16
	].ppma;
	[
		freq: [[-5, 2,14,5,17],[1,13,5,21]].df(\c,4).q,
		dur: b.drop(1).q,
		instrument: \harp,coef:0.5,amp:0.01
	].pp
});
P.still(\chapelEnd, timecode: 5223.9.seconds, music: { |p b e|
	 e.still.( 
		wait: b.sum,
		fade: 2,
		text: ["",""]
	).sequenceText2(
			b.parse([1, 4]), [ 
				["it","was"],
				["beautiful",""],
			],
	)
});
}.()
	})
)

