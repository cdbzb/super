(
//[Bridge]
Song(\rescue,[]).current;
{
	// "~/tank/super/Trek/Songs/boilerplate.scd".standardizePath.load;
	Require('/Users/michael/tank/super/Trek/Songs/boilerplate.scd');
	( Song.synthVTracks = EventWithDefault(
		\default, {
			{
				|i|
				i 
				/ 7
			}
		}
	);
);
["Captain's Log. Stardate 4768.3.","4 3 2/a 5 3 /b-/minor 2 7 11 6 12 4 3/f#".dm2].addLine;
P.still(\clear, timecode: 0.seconds, music: { |p b e|
	 e.still.( 
		wait: b.sum,
		text: ["captain's","log"],
		onTop: true
	).sequenceText2(
			b.parse([3]), [ 
			["stardate","4768.3"],
			],
	)
});
P.still(\enterprise, timecode: 413.2.seconds, music: { |p b e|
	e.still.( 
		wait: b.sum,
		text: ["",""],
		fadeIn: b.sum,
		// fade: e.bNext.sum + p.secDur[e.start+2]
	)
});
P.synthVs(role: \kirk, take: [\lead, \dbl], params: {|p b| [
	lyrics: "Captain's +  Log. Stardate + four seven + six eight point three",
	filter: (midinote: _ - 12), 
	legato: [[1, 1, 0.6, 1, 1, 1, 1, 1, 1, 1, 1, 0.6]],
	pitchTake: [1, 3]
] }, music:[-0.1,0.1].collect{|pan|
	{|p b e|
		{
			e.playbuf
			=> p.synthVTracks.at(e.key).()
			=> Pan2.ar(_,pan)
		}.play

}
});
P.tune(_ <> [instrument: \stringyy, out: Effect.bus({|i| i => Mix.ar(_)  => Monitors.az(_, -0.6) },inputChannels:2)].pm);
P(\eightPointThree, syl:8, music: { |p b e|
	var a = [
		freq: [12, 4, 3].df('f#', [4,5]).q,
		amp:0.15,rel:3,
		dur: b.drop(1).q,
		out: Phaser2.ar(_, rate: 0.3) => Effect.bus(_, out: 3, inputChannels:2)
	].p;
		[instrument: \visual_pad,].pm <> a => _.play;
		[
			instrument: \harp,
			coef: 0.12,
			amp: 0.02
		].p <> a => _.play
});
P(\bass, music: { |p b e|
	var a = [
		freq: [\r, 13, 11, 5].df('c#', [4, 5]).q,
		dur: b.parse([3, 1, 1, 1]).q,
		// dur: b.parse([5, 5,,  ]).q,
		out: 2,
		amp: 0.03,
		out: Phaser2.ar(_, rate: 0.1) => Effect.bus(_, out: 2, inputChannels:2)
	].p;
	[
		instrument: \sawSynthSustain,
		hifreq: 2000,
		att: 1.5,
		amp: 0.04,
	].pm <> a => _.play;
	a <> [ instrument: \harp,  ].p => _.play
});
P(\chords, music: { |p b e|
	[
		freq: [
			[-4, -5, 1, 4, 5],
			[-3, -5, 1, 3, 5],
			[-2, 5, 1, 2, 5],
		].df(\a)
		++ [-1, -3, -5, 1, 3, 5].df('b-',\minor).bubble
		++ [-1, 1].df('a-').bubble
		++ [ 12, 4, 3 ].df('f#', 4)
		=> _.q
		,
		dur: b.parse([1, 1, 1, 2, /*4, 1, 1, 1*/]).q,
		strum: [ 0.02,0.01,0.01, 0.01, 0, 0,0,0 ].q,
		lag: 0.02,
		amp:0.05,
		pan: Array.series(5, -0.3, 0.065),
		// out: Effect.bus( {|i|Monitors.az(i, 1.8)} ),
		out: Effect.bus({|i| HPF.ar(i,80) => FreeVerb.ar(_,0.2,1) }, inputChannels:2)
	].pp
});
P(\line, music: { |p b e|
	[
		freq: [\r, 1, 3].df('a-',[3,4]).q,
		dur: b.parse([4, 1, 1]).q,
		amp:0.05,
		instrument: \sawSynth
	]//.pp
});
["The Enterprise is in orbit above a planet whose ","3 2 3 1 2 3 3 2 1.5 2 3/a 5 6 7/e- ".dm2].addLine;
P(\cymbal, syl: 0, music: { |p b e|
	(
		instrument: \cymbalsDS,
		amp: 0.02,
		att:0.5 ,
		out: Effect.bus({|i| PitchShift.ar(i, pitchRatio: 0.5) }, inputChannels: 2, out: 1)
	).play
});
P.still(\clear, timecode: 0.seconds, music: { |p b e|
	 e.still.( 
		wait: b.sum,
		text: ["the","Enterprise"],
		monitor:2,
		onTop: true
	).sequenceText2(
			b.parse([4, 4]), [ 
			["is","in orbit"],
			["above a planet","whose"]
			],
	)
});
P.still(\clear2, timecode: 0.seconds, music: { |p b e|
	 e.still.( 
		wait: b.sum,
		text: ["the","Enterprise"],
		monitor:0,
		onTop: true
	).sequenceText2(
			b.parse([4, 4]), [ 
			["is","in orbit"],
			["above a planet","whose"]
			],
	)
});
Song.setTempoMap(\Enterprise,"e | e e ee e e ee e e e e ee e e");
// P.tune();
P.synthVs(role: \kirk, take: [\lead, \dbl], pbind: Song.enlarge(8),
params: {|p b| [
	filter: (midinote: _ - 12), 
	lyrics: "The Enterprise + + is in orbit + above + a planet + whose surface + is devoid + of all life, ",
	legato: [[1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 0.65 ]],
	pitchTake: [1, 3]
] }, music:{|p b e|
	{
		e.playbuf
		=> p.synthVTracks.at(e.key).()
		=> Pan2.ar(_, 0)
	}.play

});
P(\bassline, music: { |p b e|
	[
		freq: [\r, 1, 5, -2, -6, ].df(\a,3) ++ [5, 1].df('e-', 3).bubble => _.q,
		dur: "e | eee eee eee eee eee".asBeats.warpTo( e.tempoMap ).q,
		out: Effect.bus({|i| i.tanh.tanh => Pan2.ar(_,0) * -3.dbamp }, inputChannels:2)
	].pp
});
Trek.strum;
P(\orbit,syl: 5, music: { |p b e|
	{
		Line.kr(4000, 3000, 1)
		* Env.perc(0.1, 5).kr
		=> SinOsc.ar(_, 0, 0.01)
		* -8.dbamp
		=>  { |i| CombC.ar(i, 0.4, Gendy1.ar(minfreq:1, maxfreq: 1.01).range(0.1, 0.101))/2 + i}
		=>  { |i| CombC.ar(i, 0.4, Gendy1.ar(minfreq:1, maxfreq: 3.01).range(0.3, 0.301))/2 + i}
		// =>  { |i| CombC.ar(i, 0.4, Gendy1.ar(minfreq:1, maxfreq: 2).range(0.1, 0.101) / 2 + i)}

	}.play
});
P(\keys, music: { |p b e|
	[
		freq: [[3, 5], [2, 5], 3, 1, [2, 5], 3	 ].df(\a).q,
		legato: [1, [1, 3], 2, 1, [1, 2],1].q,
		dur: "e e e ee e e ee".asBeats.warpTo( e.tempoMap ).q,
		instrument: \defaultPiano, amp: 0.05, fatness: 0.45, out: 2
	].pp
});
P.tune(_ <> [instrument: \sparkTriangle, width: 0.005, amp:0.03, out:2].pm);
P(\strum1, music: { |p b e|
	p.strum1.setPlayMode(\strum );
	p.strum1.controller.set('Global: Volume',0.4);
	[
		type: \strum,
		instance: p.strum1,
		freq: [\r] ++ [ 1, 5 ].bubble ++ [2, 4, 6].bubble => _.df(\a) => _.q, 
		dur: "e qqq qqq".asBeats.warpTo( e.tempoMap ).q,
		legato:1,
	].pp ;
	[
		type: \strum,
		instance: p.strum1,
		switch: [\d, \down, \d].q,
		legato:1,
		// dur: 10
		lag:0.01,
		dur: "e qqq qqq".asBeats.warpTo( e.tempoMap ).q,
		// lag:0.05
	].pp
	// => _.play
});
P(\connector, syl: 10, music: { |p b e|
	[
		freq: [ 5, 6.5, 7.5, 11, 12, 11, 7.5, 7 ].df('e-',3, \minor).q ,
		dur: e.bAll.drop(1).parse([1, 1, 1, 4, 1, 1, 1, 1]).q,
		pan: [-1, -1, -1 ,-1, -1, 1, 1, 1, 1].q,
		instrument: \sawSynth,
		out: Effect.bus({|i| i => Pan2.ar(_, [-0.9, 0.9 ].dq.demand(e.bAll.drop(1).parse([7,4])).lag(1) ) },)
	].pp
});
["surface is devoid of all life, ","11 5 3 4 2 1 -7 2/e-/harmonicMinor".dm2].addLine;
P.still(\clear, timecode: 0.seconds, music: { |p b e|
	 e.still.( 
		wait: b.sum,
		text: ["surface","is"],
	).sequenceText2(
			b.parse([3]), [ 
			["devoid","of all life"],
			],
	)
});
P(\bass, music: { |p b e|
	[
		freq: [11, 5, 3, 4, 2, 1, -7.5, -7].df('e-', 3, \minor).q,
		dur: b.q,
	].pp
});
P.tune( _ <> [instrument:\stringyy].pm );
["a world destroyed and dead for at least a half million years. ","1 1 2 2 3 3 2 1 -7 2 5 5 4.5 4 3/g".dm2].addLine;
P.still(\clear, timecode: 0.seconds, music: { |p b e|
	 e.still.( 
		wait: b.sum,
		text: ["a world destroyed","and dead"],
		ontTop:true
	).sequenceText2(
			b.parse([6, 3]), [ 
			["for","at least"],
			["a half million", "years"]
			],
	)
});
P.still(\bridge, timecode: 425.401.seconds, music: { |p b e|
	e.still.( 
		wait: b.sum + e.bNext.sum,
		fadeIn: b.sum,
		text:["",""]
		// text: ["yet from it comes","a voice"],
	)
});
P(\bassnotes, music: { |p b e|
	{
		Gendy2.arWidth(
			ampdist:1,
			durdist:1,
			adparam:1.0,
			ddparam:1.0,
			freq: [1, 3, 2.5, 2].df('c#',4).dq.demand(b.parse([10, 2, 4])),
			width:1.015,
			ampscale:0.5,
			durscale:0.5,
			initCPs:[12, 11, 12, 11],
			knum:nil,
			mul:1.0,
			add:0.0
		)
		* Env([0.1, 0.4, 0.4, 0.4, 0.4],b.parse([5, 3, 2, 4])).kr(0,gate:1)
		* EnvGen.cutoff(wait:b.sum, release:1, curve:nil, doneAction:2)
		/25
		// => PanAz.ar(5, _, [-0.5, 0.5] )
	}.play;

});
P.synthVs(role: \kirk, take: [\lead, \dbl], params: {|p b| [
	lyrics: "a world destroyed + and dead for at least a half million + years r",
	filter: (midinote: _ - 12), 
	legato: [[1, 0.8, 1, 0.8, 1, 0.8, 1, 1, 1, 1, 1, 1, 1,1, 0.8, ]],
	pitchTake: [1, 3]
] }, music:{|p b e|
	{
		e.playbuf
		=> p.synthVTracks.at(e.key).()
		=> Pan2.ar(_,0)
	}.play

});
P(\chords, music: { |p b e|
	[
		freq: [1, 3].dup(4).df('c#') 
			++ [1, 2, 4.5].dup.df('c#')
			++ [3, 5 ].dup(2).df(\d, \minor)
			++ [5, 11].df(\a,4).bubble
			=> _.q,
		dur: b.parse([1, 1, 1, 1, 1, 5, 1, 2, 1]).q,
		instrument: \defaultPiano

	].pp
});
P(\connector, syl: 12, music: { |p b e|
	[
		instrument: \sawSynthSustain,
		freq: [3, 2, 1.5].df(\a, 4, \minor).q,
		dur: b.drop(1).parse([1, 1]) ++ e.bNext[0] => _.q,
		amp: [3, 3, 1 ]/50 => _.q,
		legato: [1, 1, 0.1, ].q,

	].pp
});
P.tune( _ <> [amp: 0.05,instrument: \sparkTriangle, depth: 0.005].p );
["Yet from it comes a voice, ","1 2 3 1 3 4.5/e-/6".dm2].addLine;
P.still(\clear, timecode: 0.seconds, music: { |p b e|
	 e.still.( 
		wait: b.sum + e.bNext[..2],
		text: ["yet from it","comes a"],
		fade:1
	).sequenceText2(
			e.bAll.parse([5, 3]), [ 
				["voice","telling us"],
				["",""]
			],
	)
});
P.synthVs(role: \kirk, take: [\lead, \dbl], params: {|p b| [
	filter: (midinote: _ - 12), 
	lyrics: "Yet from it comes a voice ",
	pitchTake: [ 1, 3 ]
] }, music:{|p b e|
	{
		e.playbuf
		=> p.synthVTracks.at(e.key).()
		=> Pan2.ar(_,0)
	}.play

});
P(\bass, music: { |p b e|
	[[instrument:\stringyy, amp:0.1],[instrument:\defaultPiano,amp:0.02]].do
	{|array|
		array ++
		[
			freq: [[5,11], [5,11], [5,11], [5,11], [5,11], [4.5, 7 ]].df('e-',[ 4],\mixolydian).q,
			dur: b.q,
			out: Effect.bus({|i| Phaser2.ar(i, rate:0.2, cfb:0.5) }, inputChannels: 4)
		]
		=>_.pp
	}
});
P(\voiceChord,syl:4, music: { |p b e|
	{
		var freqs = [-3, -5, 1, 3, 5, 11].df(\a);
		var onsets = 
		(0..5) + {0.rrand(0.01)}.dup(6) /10;

		VarSaw.ar(freqs *.t [2, 1]) 
		* Env.perc(0.01,6).kr(0,1)
		* SinOsc.ar( Rand(1,5!6) )
		=> DelayN.ar(_,0.6, onsets)
		/35
		=> Out.ar((0..4),_)

	}.play
});
P.tune(_ => Pmul(\freq, 0.5, _));
// ["the energy of pure thought, ","r"].addLine;
["telling us something has survived here ","11 7 5 4 3 4 5 4 3/g".dm2].addLine;
P.still(\clear, syl:2, timecode: 0.seconds, music: { |p b e|
	 e.still.( 
		wait: b.sum,
		text: ["something has","survived here"],
	)
});
P.tune( _ <> [instrument: \stringyy].pm );
P.synthVs(role: \kirk, take: [\lead, \dbl], params: {|p b| [
	lyrics: "telling + us something + has survived + here ",
	filter: (midinote: _ - 12), 
	legato: [ [1, 1, 1, 1, 1, 1, 1, 1, 0.8, ] ],
	pitchTake: [1, 3]
] }, music:{|p b e|
	{
		e.playbuf
		=> p.synthVTracks.at(e.key).()
		=> Pan2.ar(_,0)
	}.play

});
P(\basslinelet, music: { |p b e|
	[
		freq: [1, -7, -6, -7, 1, -4].df(\d,4,\mixolydian).q,
		dur: b.parse([3, 1, 1, 1, 1, 2]).q
	].pp
});
P(\chordAndBassnote, music: { |p b e|
	[
		freq: [[5, 11].df(\d), 1.df(\g, [ 4, 5 ]) ].q / 2,
		dur: b.parse([7, 2]).q,
		instrument: [\sawSynthSustain, \default].q,
		att: 1,
		out: [0, Effect.bus({|i| FreeVerb.ar(i,0.9,1) },)].q,
		amp: [0.05, 0.17].q

	].pp
});
// ["for those thousands of centuries.","r"].addLine;
["(dictating log) Since exploration and contact /* with alien intelligences */ is our primary mission,","1 11 7 11 7 6 5 7 6 4 5 4 3 4 3 2/f#".dm2].addLine;
Song.setTempoMap(\Since,"x x x x E E E x x x x E E E e e");
P.synthVs(role: \kirk, take: [\lead, \dbl], params: {|p b| [
	lyrics: "r Since exploration + + + and contact + is our primary + + mission +",
	pitchTake: [1, 3],
	filter: (midinote: _ - 12), 
] }, music:{|p b e|
	{
		e.playbuf
		=> p.synthVTracks.at(e.key).()
		=> Pan2.ar(_, 0)
	}.play

});

P.still(\exploration, timecode: 437.5.seconds, music: { |p b e|
	 e.still.( 
		wait: b.sum,
		text: ["",""]
	).sequenceText2(
			b.parse([1,8]), [ 
				["since exploration","and contact"],
				["is our primary","mission"],
			],
	)
});
P.tune( _ <> [ instrument: \sparkTriangle, out: 1, rest: MuteFirst(), freqLag:0.04, amp:0.03 ].pm );
P(\boom, music: { |p b e|
	(
		out: Effect.bus({|i| DWGReverbC1C3.ar(i, c3: [10, 11]) }, inputChannels: 2, out: 2),
		lag: 0.02,
		freq: 1.df('f#', 3)
	).play
});
P(\chord, music: { |p b e|
	[
		freq: [
			[1, 3, 5],
			[1, 4, 6],
			[1, 3, 5],
			[1, 4, 5],
			[1, 4, 6],
			[6, 11],
			[6, 11],
			[6, 11],
			[6, 11],
			[5, 11, 13],
			[5, 7, 12],
		].df('f#', 4).q,
		dur: b.parse([5, 1, 1, 1, 2, 1, 1, 1, 1, 1, 1, 1]).q,
		instrument: \defaultPiano,
		lag: 0.02,
		amp: 0.04,
		out: Effect.bus({|i| i => HPF.ar(_, 220) => BPeakEQ.ar(_, 1200, 0.5, 8)},inputChannels: 2)
		lag: 0.025,
		legato: [0.9,0.9,0.9,1, 1, ].q ++ [0.9].q(inf),
	].ppma
});
P(\bassline, music: { |p b e|
	var a = [
		freq: [1,  2, 3, 4, -4, -5].df('f#', 3).q,
		lag: 0.02,
		dur: "qE E E qe e q".asBeats.warpTo( e.tempoMap ).q,
		out: Effect.bus({|i| i => SineShaper.ar(_, 0.1) * 3 },),
		lofreq: 1200, hifreq: 3000,
		freqLag: 0.1, pulse:0.0, amp:0.1,
		out: Effect.bus({|i| i=>Pan2.ar(_,0) }, inputChannels:2)
	];
	a ++ [ instrument: \sawSynthSustain, out: Effect.bus({|i| i=> Pan2.ar(_,-0.8) }), att: 0.5, amp: 0.05 ] => _.ppm;
	a ++ [ instrument: \default, pan:-1, out: Effect.bus({|i| i => Pan2.ar(_,-0.2) },), amp: 0.07 ] => _.pp
});
["I've decided to risk the potential dangers and ","5 6.5 7.5 11 12 13 12 11 7.5 12 7.5 6.5 6/d/minor".dm2].addLine;
P.still(\clear, lag: Song.durs[\risk].list[0]/2, timecode: 0.seconds, music: { |p b e|
	 e.still.( 
		wait: b.sum - (b[0]/2),
		text: ["I've decided","to"],
	).sequenceText2(
			b.parse([5]), [ 
			["risk","the potential dangers and"],
			],
	)
});
P(\line, music: { |p b e|
	[
		freq: [\r, 5, 4, 3, 2, 1, 5.5].df(\a).q,
		dur: b.parse([0.5, 0.5, 1, 1, 1, 1, 1 ]).q,
		instrument: \sparkTriangle,
		out: 4,
		out: Effect.bus({|i| FreeVerb.ar(i, 0.1, 1) * -18.dbamp },inputChannels: 2, out: 4)
	].ppm
});
P(\line, music: { |p b e|
	[
		freq:[ 1, 2, 3, 4].df(\a, 4).q,
		amp: 0.02,
		dur: b.parse([3, 1, 1, 1, 1]).q,
		instrument: \wash,
		freqLag: 0.1
	].ppm
});
P(\pad, music: { |p b e|
	(
		instrument: \sawSynthSustain,
		freq: [-11,-1].df(\a),
		att: 3,
		dur: b[..5].sum,
		rel: 2,
		amp: 0.02
	).play
});
P(\twang, music: { |p b e|
	[
		instrument: \pluckD,
		freq: [-5, 1].df(\d, [3,4]).q,
		amp: 0.02,
		dur: b.parse([5, 4]).q,
		out: Effect.bus({|i| i * Env.perc(0, 9).kr(2) => LPF.ar(_, 4000) => FreeVerb.ar(_, 0.2, 0.9) }, inputChannels:2, out: 1)
	].pm.play
});
P.synthVs(role: \kirk, take: [\lead, \dbl], params: {|p b| [
	lyrics: "I've decided + + to risk the potential + + dangers + and ",
	filter: (midinote: _ - 12), 

	lag: [[b[0]/2, 0, 0, 0, 0,   0, 0, 0, 0, 0, 0, 0, 0   ]],
	legato: [[1,  1, 1, 1, 0.7, 1, 1, 1, 1, 1, 1, 0.7, 0.7 ]],
	pitchTake: [1, 3]
] }, music:{|p b e|
	{
		e.playbuf
		=> p.synthVTracks.at(e.key).()
		=> Pan2.ar(_, 0)
	}.play
});
P(\strum,syl: 4, music: { |p b e|
	(
		freq: [1, 5, 11, 13].df(\d, 4, \minor),
		strum: 0.05,
		lag: 0.02,
		dur: b.drop(1)[..2].sum,
		instrument: \defaultPiano,
		out: Effect.bus({|i|  CombN.ar(i,0.3,0.2,5)/2 => Pan2.ar(_,0.8) + i => BPeakEQ.ar(_, 2200, rq:1.0, db:7.0 ) => BLowCut.ar(_, 300) },inputChannels:2),
		amp: 0.04,
	).play
});
P.tune(_ <> [instrument: \harp, coef: 0.25, out: Effect.bus({|i| i=> LPF.ar(_,1000) / 20 => Pan2.ar(_,SinOsc.ar(0.2)) },)].p);
P(\appog, syl: 9, music: { |p b e|
	[
		freq: [5.5, 6, 7].df(\d, 4).q,
		out: 4,
		out: 4,
		instrument: \wash,
		dur: b.drop(1).q,
		freqLag:0.5 ,
		amp: 0.04
	].ppm
});
P(\dangersChord,syl: 9, music: { |p b e|
	{
		b.drop(1).postln;
		VarSaw.ar(
			[
				[1, 4.5, 5],
				[1, 3, 5],
				[1, 2.5, 5],
			].df(\g,4).flop .collect{|i| i.asArray.dq.demand( b.drop(1).asArray[..2])}
			* Gendy2.ar(ampdist:[1, 0.8,0.9], durdist:1, adparam:1.0, ddparam:1.0, minfreq:440, maxfreq:660, ampscale:0.5, durscale:0.5, initCPs:12, knum:nil, a:1.17, c:0.31, mul:1.0, add:0.0).range(0.97,[11, 12, 13, 14, 15, 16] + 400 / 400)
			=> _.lag3( [0,0.2].dq.demand([b[0]-0.01]) ),
			width: 0.1
		)
		/40
		* LFSaw.ar(Line.kr(5, 20, b.sum)).range(0.3,1.2)
		=> SplayAz.ar(5,_)
		* Env.linen(0.05, b.drop(1)[..1].sum, b[2]).kr(2)
		=> Out.ar(1, _)
		// * EnvGen.cutoff(wait:b.drop(1)[..1].sum, release:b[2], curve:nil, doneAction:2)
	}.play
});
P.still(\kirkLog, timecode: 446.8.seconds, music: { |p b e|
	 e.still.( 
		wait: b.sum,
		// text: ["log Entry","out"],
	)
});
["(boom) resume contact Log entry out","-1 4 5 11 1/f# 3 4 5 11/b/4".dm2].addLine;
P.still(\clear,syl:0, timecode: 0.seconds, music: { |p b e|
	 e.still.( 
		wait: b.drop(1).sum,
		text: ["resume","contact"],
	).sequenceText2(
			b.drop(1).parse([4]), [ 
			["log entry", "out"],
			],
	)
});
P.still(\clears,syl:0, timecode: 0.seconds, music: { |p b e|
	 [e.still.monitor_(0), e.still.copy.monitor_(1)].do{|i x|i.postln;i.monitor.postln; i.( 
		wait: b.drop(1).sum,
		// monitor:x,
		// monitor: e.monitor,
		text: ["resume","contact"],
	).sequenceText2(
			b.drop(1).parse([4]), [ 
			["log entry", "out"],
			],
	)
	}	
});
Song.setTempoMap(\resume,"eeeee e ee ee ee ee e e e");
P(\chord, syl: 4, music: { |p b e|
	(
		freq:[3, 5, 7, 12].df('c#',4,  \minor),
		dur: 3,
		instrument: \defaultPiano,
		strum: 0.05,
		out: Effect.bus({|i| 
			i * SinOsc.ar(4)
			=> Monitors.az(_, SinOsc.ar(0.2))
			/2
		},time:3)
	).play
});
P(\line, music: { |p b e|
	[
		freq: 
		[1, 3, 6, [5, 7], [5,12]].flop.collect({ |i| i.df('c#', \mixolydian).q})
		,
		dur: "h h h h ".asBeats.warpTo( e.tempoMap ) ++ 1 => _.q,
		instrument: \stringyy, 
		amp: 0.03,
		mix: 0.4, out: 3
	].flop.collect(_.ppm)
});
P(\bassnotesOne, music: { |p b e|
	[
		freq: [1, -7, -4, -2.5, -16.5].df('c#',4,\mixolydian).q,
		dur: "qq qq qq qq e".asBeats.warpTo( e.tempoMap ).q,
		lag: 0.02,
		amp: 0.05,
		out: Effect.bus({|i| i => SineShaper.ar(_,0.1,2) => Pan2.ar(_,0) }, inputChannels: 2)
	].pp;

});
P(\tamb, music: { |p b e|
	{
	var levels = [5,1,2,1] /5 => _.dq(inf);
	var durs =  
	1/3 !14 
	+ ( [1, -1] /80 => _.dup(8) ) //swing amt
	=> _.flat 
	=> _.warpTo(e.tempoMap.quantizeWindow(0.3))
	=> _.dq(2);
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
	=> DWGReverbC1C3.ar(_,mix:0.05)
	/12
	=> Pan2.ar(_,0.75)
	=> Out.ar(1, _)

}.play;
});
P(\chords, music: { |p b e|
	[
		freq: [
			[1, 5 ],
			[1, 4],
			[-6.5, 3.5]
		].df('c#', \mixolydian).q,
		lag: 0.02,
		dur: "qqqq qqqq e".asBeats.warpTo( e.tempoMap ).q,
		pan: [-1, 1], 
		out: Effect.bus({|i| 
			CrossoverDistortion.ar(i, amp:0.1, smooth:0.95)
			=> LeakDC.ar(_)
		}, inputChannels: 2, out: [1, 3])
	].pp
});
P.synthVs(role: \kirk, take: [\lead, \dbl], params: {|p b| [

	lyrics: "r resume + contact + log entry + out",
	filter: (midinote: _ - 12), 
	legato: [[1, 1, 1, 1, 0.7, 1, 1, 1, 0.6 ]],
	pitchTake: [1, 3]
] }, music:{|p b e|
	{
		e.playbuf
		=> p.synthVTracks.at(e.key).()
		=> Pan2.ar(_, 0)
	}.play

});
P(\connector,syl:7, music: { |p b e|
	b.postln;e.bAll.drop(1).postln;
	[
		freq: [
			[-5, 1, 3],
			[-5, 1, 2.5]
		].df(\b).q,
		dur: e.bAll.drop(1).parse([2,1]).q ,
		amp:0.1,
		instrument: \sawSynthSustain, amp:0.05,
		out: Effect.bus({|i| i=>BPF.ar(_,[1600, 1100]) },),
		freqLag:2, 
		release: 3
	].ppm;

});

// [" How long before Starfleet receives that?","r"].addLine;
/* ["/*UHURA:*/ Over three weeks at this distance, sir.","r"].addLine;
P.still(\uhuruclose, timecode: 452.451.seconds, music: { |p b e|
	 e.still.( 
		wait: b.sum,
		text: ["",""],
	)
}); */
["/*SPOCK:*/ Captain.","3 -5".dm(\b,\minor)].addLine;
P.still(\clear, timecode: 0.seconds, music: { |p b e|
	 e.still.( 
		wait: b.sum,
		text: ["Captain!",""],
		monitor: 2,
		onTop: true
	)
});
P.synthV(role: \spock, take: \lead, params: {|p b| [
	lyrics: "Captain + ",
	filter: (midinote: _ - 12), 
	legato: [1, 0.6, ],
	pitchTake: 1
] }, music:{|p b e|
	{
		e.playbuf
		=> p.synthVTracks.at(e.key).()
		=> Pan2.ar(_, -0.25)
	}.play

});
P.still(\spockClose, timecode: 453.106.seconds, music: { |p b e|
	 e.still.( 
		wait: b.sum,
		monitor:2, 
		text: ["",""],
	)
});
P.tune(_ <> [instrument: \stringyy].p);
P(\trem, music: { |p b e|
	{
		Gendy2.arWidth(
			ampdist:1,
			durdist:1,
			adparam:1.0,
			ddparam:1.0,
			freq:[[3, 5, 11,11, 13, 15, 21, 21].df(\b,4,\minor),
			[3, 5, 7, 11.5, 13, 15, 17, 21.5].df(\b,4,\minor)
		].dq.demand([b.sum, e.bNext.sum+0.2]).lag([0,1].dq.demand([1])),
			width:{ 1.015.rrand(1.1) },
			ampscale:0.5,
			durscale:0.5,
			initCPs:12,
			knum:nil,
			a:1.17,
			c:0.31,
			mul:1.0,
			add:0.0
		)
		* Env.linen(attackTime:0.5, sustainTime:b.sum, releaseTime:e.bNext.sum, level:1.0 ).kr(2,gate:1)
		/100
	}.play
});
}.();
["/*KIRK:*/ Got something?","7 11 5/d/mixolydian".dm2].addLine;
P.still(\clear, timecode: 0.seconds, music: { |p b e|
	 e.still.( 
		wait: b.sum/2,
		fade: b.sum/2 -0.1,
		text: ["got","something?"],
		onTop: true
	)
});
P(\chord, music: { |p b e|
	(
		freq: [-11,-1,-5, -7, 11, 13].df(\d, \mixolydian),
		dur: b.sum,
		strum: 0.05,
		amp: 0.01,
		instrument: \harp, coef: 0.15,
		out: Effect.bus({|i| i => HPF.ar(_, 250) => {|i| CombC.ar(i,0.2,SinOsc.ar([0.34, 0.25]).range(0.13,0.15))/2 + i} },)
	).play
});
P.tune( _ <> [instrument: \wash, amp: 0.01].p );
P.synthV(role: \kirk, take: \lead, params: {|p b| [
	lyrics: "got something +",
	legato: [0.6,1,0.4],
	filter: (midinote: _ - 12), 
	pitchTake: 1
] }, music:{|p b e|
	{
		e.playbuf
		=> p.synthVTracks.at(e.key).()
		=> Pan2.ar(_,0)
	}.play

});
P.still(\kirkGot, timecode: 456.385.seconds, music: { |p b e|
	 e.still.( 
		wait: b.sum,
		text: ["",""],
	)
});
["(boom boom) Sensors registering some form of energy deep inside the planet.","-1 -1 3 1 4 3 1 3 4 5 7 6 4  2 1 -7 -6 -6 -5".dm(\e,\mixolydian)].addLine; /*SPOCK:*/ 
P(\arp, music: { |p b e|
	var busses = 3.collect{ Bus.audio(s, 2) };
	var dur = 0.125;
		[
			instrument: \visual_pad,
		freq: [
			\r,
			[-5, 1, 3],
			[-5, 1, 4],
			[-5, 1, 3],
			[1,4,7],
			6,
			4
		].df(\e,\mixolydian).q,
		legato: [1, 1, 1, 1, [2,2,1],1,1 ].q * 0.3,
		dur: b.parse([2, 2, 3, 3, 1, 1,1]).q,
			out: busses.collect(_.index).postln,
			pan: -1
		].ppm;
	{
		busses.collect(In.ar(_, 1))
		=> Select.ar( LFSaw.ar(3).range(0,3), _ )
		=> Pan2.ar( _, LFSaw.ar(3) )
		*3
		* EnvGen.cutoff(b.sum,0.1)
	}.play(s, 1, addAction: \addAfter).onFree(busses.do(_.free))
	

});
P(\cymbal, music: { |p b e|
	(
		instrument: \cymbalsDS,
		amp: 0.01 * -2.dbamp
	).play;
	(
		instrument: \cymbalsDS,
		out: Effect.bus({|i| PitchShift.ar(i, pitchRatio: 0.6) }, out: 2, inputChannels: 2),
		amp: 0.01 * 3.dbamp
	).play
});
P.still(
	// \spockSensors
	\clear
	, timecode: 500.974.seconds, music: { |p b e|
	 e.still.( 
		wait: b.sum,
		text: ["",""],
	).sequenceText2(
		b.parse([2,5, 6]), [ 
			["sensors","registering" ],
			["some kind of","energy"],
			["deep inside","the planet"]
			],
	)
});
P.still(
	// \spockSensors
	\clear
	, timecode: 500.974.seconds, music: { |p b e|
	 e.still.( 
		wait: b.sum,
		text: ["",""],
		monitor: 2
	).sequenceText2(
		b.parse([2,5, 6]), [ 
			["sensors","registering" ],
			["some kind of","energy"],
			["deep inside","the planet"]
			],
	)
});
Song.setTempoMap(\Sensors, "e e e e | E E E E E E | e x xq | Q E Q E e e");
P(\line, music: { |p b e|
	[
		freq: [\r,[ 2, -5 ], [ 3, -5 ], [1, -4]].df(\e,6, \mixolydian).q,
		dur: "qqqqqq q q q".asBeats.warpTo( e.tempoMap ).q,
		instrument: \stringyy
	].ppm
});
P(\chords, music: { |p b e|
	[
		freq: [\r, [-5, 1, 3], [-5, 1, 4],[-5, 1, 3],[1,4,7],6, 4].df(\e,\mixolydian).q,
		legato: [1, 1, 1, 1, [2,2,1],1,1 ].q * 0.3,
		dur: b.parse([2, 2, 3, 3, 1, 1,1]).q,
		instrument: \defaultPiano,
		out: Effect.bus({|i| i=>
			SineShaper.ar(_,0.2,4) 
			=> AnalogPhaser.ar(_,SinOsc.ar(0.2),feedback: 0.8,skew:0.8) 
			=> HPF.ar(_,900) * -20.dbamp
		},inputChannels:2)
	].pp
});
P.synthVs(role: \spock, take: [\lead,\double], params: {|p b| [
	lyrics: "r r sensors + regist + ring  some kind of energy + + deep inside +  the planet + ",
	legato: [[1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 0.7, 1, 1, 1, 1, 1, 1, ]],
	filter: (midinote: _ - 12), 
	pitchTake: [1,3]
] }, music:[-0.4,0.0].collect{|pan|{|p b e|
	{
		e.playbuf
		/ 10 
		=> Pan2.ar(_, pan)
		// => p.synthVTracks.at(e.key).()
	}.play

}});
P.synthVs(role: \spock, take: [\harmony, \harnmony2],
	pbind: {|p b|
		[
			dur: 
			p.durs[\deep].list.parse([13,1,1,1,1,1,1])
			,
			midinote: [1,7,6,5,4,2.5,2.5].dm(\e,3,\mixolydian)
		].p
	},
	params: {|p b| [
	lyrics: "r deep inside + the planet +",
	pitchTake: [1,3],
	paramTension: -0.03,
	// vocalMode: \Theatrical

] }, music:[-1,1].collect{|pan|{|p b e|
	{
		e.playbuf
		// /10
		=> HPF.ar(_,200)
		=> Pan2.ar(_,pan)
		/12
		// => p.synthVTracks.at(e.key).()
	}.play
}});
P(\bass, music: { |p b e| //check last note
		var quant = "e e q | e e e e | e e q | e e e e | e".asBeats.warpTo(e.tempoMap.quantizeWindow(0.5));
		var raw = "e e q | e e e e | e e q | e e e e | e".asBeats.warpTo(e.tempoMap);
		var both = quant[0..9] ++ raw[10..];
		// var quantHat = 0.25.dup(31).asBeats.warpTo( e.tempoMap.quantizeWindow(0.5) );
		// var rawHat = 0.25.dup(31).asBeats.warpTo( e.tempoMap );
		// var bothHat = quantHat[0..22] ++ rawHat[23..];
	[
		freq: [ 1,1,\r,1,1,\r,1,4,4,\r, 7, 6, 5, 4, 2.5 ].df(\e,[ 2 ],\mixolydian).q,
		// dur: "e e q | e e e e | e e q | e e e e | e".asBeats.warpTo(e.tempoMap.quantizeWindow(0.5)).q
		dur: both.q,
		instrument: \bl,rel:1, amp: 0.1,
		rel: 0.5
	].pp;
	[
		dur: 0.25.dup(31).asBeats.warpTo( e.tempoMap.quantizeWindow(0.5) ) => _.q(2),
		// dur: bothHat.q,
		instrument: \hat_808,
		amp: [ [0.1,0.05].q(12),Pseries(0.1,0.1/9*(-1),9) * [1,0.5].q(inf) ].q /2,
	].pp
});
P(\traps, music: { |p b e|
	[
		instrument: \sn_808,
		dur: "q ex xq qq ex xq ex".asBeats.warpTo( e.tempoMap.quantizeWindow(0.5) ).q,
		amp: [0,3, 2, 3, 3, 2, 3]/50 * 3.dbamp => _.q,
		rest: [\r,1, 1, 1, 1, 1, 1 ].q
	].pp;
	[
		instrument:\bd_808,
		dur: "qqqq qqqq qqqq qqqq".asBeats.warpTo( e.tempoMap.quantizeWindow(0.5) ).q

	].pp
});
P(\planetCrash,  music: { |p b e|
	[
		// lag:0.1,
		instrument: \cymbalsDS,
		amp:0.01,
		rest: [\r, 1].q,
		dur: "qqqqqqqq q".asBeats.warpTo( e.tempoMap.quantizeWindow(0.5) ) => _.q
	].p.play
});
["/*SARGON [OC]*/(boom) Your probes have touched me, Mister Spock.",[-1, 4, 4, 4, 4, 3, 2, 1, 2, 3].dm(\c,\minor)].addLine;
P(\alert, music: { |p b e|
	{
		SinOsc.ar((1111,1112..1115) * 2,0,0.02)
		* -5.dbamp
		* Env.perc(0,8).kr(2,gate:1)
	}.play

});
P.still(\sargonSpeaks, timecode: 503.269.seconds, music: { |p b e|
	 e.still.( 
		wait: b.sum,
		text: ["",""],
	).sequenceText2(
			b.parse([1,5]), [ 
			["your probes have","touched me"],
			["Mister","Spock"]
			],
	)
});
P.synthV(role: \vocoder, frozen: true, take: \lead, params: {|p b| [
	lyrics: "r your probes have touched me mister + spock -",
	// filter: (midinote: _ - 12), 
	pitchTake: 1
] }, music:{|p b e|
	p.vocodeTune.( p, b, e, e.rpp,
		durRel: 1,
		mix:0.01,
		chord: #[1, 2, 4, 8],
		verb:0.2,
		modGain:1.5,
		mix: p.vocoderMix, width: p.vocoderWidth,
	);
	{
		p.laMer => PlayBuf.auto(2, _, rate: ( [1,-7,4].dm('f',\mixolydian)-1.dm(\c) ).midiratio.dq.demand(b.parse([4, 4, 2]))) 
	}.play(s, p.carrierBus)
});
P(\chord, music: { |p b e|
	[
		freq: [-1, 1, 3, 5].df(\f).bubble.q,
		strum: 0.05,
		instrument: \sawSynth,
		out: Effect.bus( FreeVerb.ar(_, mix:1, room:1, damp:[ 0.5,0.6 ]) )
	].pp
});
P(\bass, music: { |p b e|
	[
		freq:[1, 7, 4].df(\f, [2,3],\mixolydian).q,
		dur:b.parse([4,4,2]).q
	].pp
});
["/*SPOCK:*/ Reading energy only, Captain. No life forms.", "1 2 3 2 1 4 2 1 -6 4 5.5 2".dm('f#',\lydian)].addLine;
Song.setTempoMap(\Reading,"E E E E E e e e ee e e e");
/*
"open '/Users/michael/trek/BySection/media/11-Spock&Sargon-181021_1557.rpp'".unixCmd
*/
P(\bassOffbeats, music: { |p b e|
	[
		dur: "Q e e e e e e e e e e e e".asBeats.warpTo( e.tempoMap.quantizeDft(0.6) ).q,
		rest: [\r,1, 1, 1, 1, 1, 1, 1, 1, 1, 1].q(inf),
		rest: [\r,1].q(inf),
		instrument: \bl,amp:0.05,
		freq: [1,2 ,3].df('f#',3) =>Pstep(_,b.parse([5,5,2]))
	].pp
});
P(\kick, music: { |p b e|
});
P.still(\spockAnswers, timecode: 506.3.seconds, music: { |p b e|
	 e.still.( 
		wait: b.sum,
		text: ["",""],
	)
});
P.still(\clear, timecode: 0.seconds, lag:0.01, music: { |p b e|
	 e.still.( 
		wait: b.sum,
		text: ["reading energy only","captain"],
	).sequenceText2(
			b.parse([9]), [ 
			["no","life forms"],
			],
	)
});
P(\arp, music: { |p b e|
	var dur = 0.125;
	[
		instrument: \sawSynthSustain,
		degree: [0,8,15].q(inf),
		root: [6!( dur.reciprocal*5/3 ),8!( dur.reciprocal *7/3),10!(dur.reciprocal*2)]=> _.flat => _.q,
		// dur: "Q q q q q q".asBeats.warpTo( e.tempoMap ).q,
		dur: (0.125).dup(48).asBeats.warpTo( e.tempoMap.quantizeDft(0.6) ).q,
		octave:4,
		lagTime:0,
		amp:0.03
	].ppm
});
P(\click2, music: { |p b e|
	var dur = 0.25;
	[
		instrument: \stab,
		degree: [0,8,15].q(inf),
		root: [6!( dur.reciprocal*5/3 ),8!( dur.reciprocal *7/3),10!(dur.reciprocal*2)]=> _.flat => _.q,
		// dur: "Q q q q q q".asBeats.warpTo( e.tempoMap ).q,
		dur: (dur).dup(24).asBeats.warpTo( e.tempoMap.quantizeDft(0.6) ).q,
		octave:3,
		lagTime:0,
		amp:Pseries(0.1,-0.005,inf),
		pan:1
	].pp
});
P(\traps, music: { |p b e|
	[
		dur: 32.collect{ [4,[ 8, 8 ],[ 16, 8, 16 ]].choose.reciprocal * 2  }.flat.warpTo( e.tempoMap.quantizeDft(0.6) ).q(1)// => _.findur(b[..10].sum)
		,
		instrument: \hat_808,
		pan:-1,
		out: Effect.bus({|i| CombN.ar(i,0.05,0.005,0.31)+i /4
		* Line.kr(1,0,b.sum+1)
		=> FreeVerb.ar(_,0.4,1) 
	},)
	].pp;
	[
		dur: 32.collect{ [4,[ 8, 8 ],[ 16, 8, 16 ]].choose.reciprocal * 2  }.flat.warpTo( e.tempoMap.quantizeDft(0.6) ).q(1)// => _.findur(b[..10].sum)
		,
		instrument: \hihat,
		pan:1,
		out: Effect.bus({|i| 
			i =>
			 CombN.ar(_,0.05,0.004,0.3) + i 
		=> DWGReverbC1C3.ar(_,mix:0.2)
		* Line.kr(1,0,b.sum+1)
		=> FreeVerb.ar(_,0.2,1)
		/10 * 3.dbamp
	},inputChannels:2, out: 2)
	].pp;
	[
		dur: "Q e e e e e e e e e e e e".asBeats.warpTo( e.tempoMap.quantizeDft(0.6) ).q,
		rest: [1,1, 1, 1, 1, 1, 1, 1, 1, 1, 1].q(inf),
		instrument: \kick,amp:0.05,
		instrument: \bd_808,
		lag: 0.02,
		freq: [1,2 ,3].df('f#',3) =>Pstep(_,b.parse([5,5,2])),
		out: Effect.bus({|i| i => DWGReverbC1C3.ar(i,mix:0.05)  }, inputChannels:2, out: 1)
	].pp
});
P(\bassline, music: { |p b e|
	[
		
		freq: [1,2,3].df('f#',3).q,
		dur: "EEEEE qqq q".asBeats.warpTo( e.tempoMap.quantizeDft(0.6) ).q,
		instrument: \sawSynthSustain,pulse:0.9,amp:0.05
		// dur: b.parse([5,3+2,2]).q
	].ppm
});
P.synthVs(role: \spock, take: [\lead, \double], params: {|p b| [
	lyrics: "Reading + energy + + only + captain + no life forms",
	filter: (midinote: _ - 12), 
	pitchTake: [1, 3]
] }, music:{|p b e|
	{
		e.playbuf
		// => p.synthVTracks.at(e.key).()
		/10
	}.play

});
[" I have locked your transporter device on my co-ordinates.","5 5 5 6 5 4 3 2 4 3 2 1 3 2 2".dm(\a,4)].addLine;/*SARGON [OC]*/
P.still(\clear, timecode: 0.seconds,lag: 0.01, music: { |p b e|
	 e.still.( 
		wait: b.sum,
		text: ["I have locked","your"],
	).sequenceText2(
			b.parse([4, 5]), [ 
			["transporter","device"],
			["on my", "on my coordinates"]
			],
	)
});
P(\alert, music: { |p b e|
	{
		SinOsc.ar((1111,1112..1115) * 2.5,0,0.02)
		* -17.dbamp
		* Env.perc(0,8).kr(2,gate:1)
	}.play

});
Song.durs.filter(_ * 1.15);
P.still(\sargonlocked, timecode: 511.464.seconds, music: { |p b e|
	 e.still.( 
		wait: b.sum,
		fade: b.sum, wait:0,
		text: ["",""],
	)
});
P.synthV(role: \vocoder, frozen: true, take: \lead, params: {|p b| [
	lyrics: "I have locked your transporter + +  device + on my co-ordinates + + +",
	phonemes: ["","","","","","","","","","","","","","","n eh th s",],
	pitchTake: 1
] }, music:{|p b e|
	p.vocodeTune.(p, b, e, e.rpp,
		mix:0.5,
		chord: #[1, 2, 3, 4, 8] * 2,
		verb:0.7,
		modGain:2.dbamp,
		mix: p.vocoderMix, width: p.vocoderWidth,
		durRel:0.5
	);
	// Environment.pop;
	{
		p.laMer => PlayBuf.auto(
			2, _,
			rate: [1, -7,  -4].dm(\e, \mixolydian) - 1.dm(\c) => _.midiratio => _.dq => _.demand(b.parse([4, 8, 3]))
		)
		/8
	}.play(s, p.carrierBus)
});
Song.setTempoMap('co-ordinates',"q e eq e eq e eq e eq e eq e eq e eq");
P(\bass, music: { |p b e|
	[
		freq: [6, 5, 4, 5, 6, 7, 11, 5].df(\a,2).q,
		dur: [4,4,1,1,1,1,2,2].warpTo(e.tempoMap).q
	].pp
});
P(\chords, music: { |p b e|
	[
		freq: [ -12,-2,1,3,5,11 ].dup(4) ++ [ -1,1,3,5,11 ].dup(3)=>_.df(\e) =>_.q,
		dur: "q e eq e eq e q".asBeats.warpTo(e.tempoMap).q,
		instrument:\sawSynth,
		out: Effect.bus( 
			{|i|
				i * Env([1,0.3,0.1],b.parse([4,8])).kr(2,gate:1)
				=> DWGReverbC1C3.ar(_)
				=> LPF.ar(_,800)
				/6
			}
		)
	].pp
});
// P.tune();
["Please come to us. Rescue us from oblivion."," 3 3 2 2 4 3 -6 1".dm('f#',\minor) ++ "4 4 3 1".dm(\f)].addLine;
P.still(\clear, timecode: 0.seconds, music: { |p b e|
	 e.still.( 
		wait: b.sum,
		text: ["please come","to us"],
	).sequenceText2(
			b.parse([4, 4]), [ 
			["rescue us","from"],
			["oblivion",""]
			],
	)
});
P.synthV(role: \vocoder, frozen: true, resources:(tail: 3), take: \lead, params: {|p b| [
	lyrics: "please come to us rescue + us from  oblivion + +",
	legato: [1, 1, 1, 0.8, 1, 1, 0.8, 0.8, 1, 1, 1, 1, ],
	filter: (midinote: _ - 12), 
	pitchTake: 1
] }, music:{|p b e|
	p.vocodeTune.(p, b, e, e.rpp,
		dur: b.sum +0.5,
		att: 0.2,
		sus: b.sum - 0.2,
		rel: 1,
		modGain: 1.5,
		mix: p.vocoderMix, width: p.vocoderWidth,
		durRel:1
	);
	[\A, \c].collect{|i| [1,3,5,6].df(i)}
	=> {|i| 
		[
			freq: [\r] ++ i => _.q,
			dur: b.parse([1, 3, 3]).q,
			instrument:\sawSynth,
			out: p.carrierBus
		].pp
	};
	// Environment.pop;

});
P.tune( _ <> [instrument: \sparkTriangle, depth: 0.01, amp:0.05].p );
P(\laMerChords, music: { |p b e|
	[\A, \c].collect{|i| [1,3,5,6].df(i)}
	=> {|i| 
		[
			freq: [\r] ++ i => _.q,
			dur: b.parse([1, 3, 4]).q,
			instrument:\stringyy
		].pp
	}
});
P(\bass, music: { |p b e|
	[
		freq: [\r,1,-7,6,].df('f#',[3,2],\minor) ++ [5,11].dup.df('f',[3,2]) =>_.q,
		dur: b.parse([1,3, 2,2,  1,3]).q
	].pp
});
P(\answer, syl: 10, music: { |p b e|
	[
		freq: [4,3,1,-6,1,2,3].df(\f).q,
		dur:0.5,
		instrument:\ooh,
		amp: 0.2,
		amp:Pseries(0.1,-0.018,inf) / 6,
		out: [3, 4, 2].q(inf),

	].pp
});
["/*SPOCK:*/ Coming from deep under the planet's surface, Captain. ","11 12 13 7 12 11 7 5 7 5 4 3 2".dm(\c,\mixolydian)].addLine;
P.still(\spockDeep, timecode: 525.8.seconds, music: { |p b e|
	 e.still.( 
		wait: b.sum,
		fade: b.sum,
		text: ["",""],
	)
});
P.still(\clear, timecode: 0.seconds, lag:0.1, music: { |p b e|
	 e.still.( 
		wait: b.sum,
		text: ["coming from","deep"],
	).sequenceText2(
			b.parse([4]), [ 
			["under the planets","surface, Captain"],
			],
	)
});
Song.setTempoMap(\Coming,"Q Q Q qq Q Q Q q e eq q q q");
P(\arp, music: { |p b e|
	var dur = 0.125;
	[
		instrument: \sawSynthSustain,
		degree: [0,8,15].q(inf),

		root: [0!( dur.reciprocal*5/3 ),-2!( dur.reciprocal *7/3),10!(dur.reciprocal*2)]=> _.flat => _.q,
		// dur: "Q q q q q q".asBeats.warpTo( e.tempoMap ).q,
		dur: (0.25).dup(24).asBeats.warpTo( e.tempoMap.quantizeDft(0.6) ).q,
		octave:4,
		lagTime:0,
		amp:0.035,
		out: 1
	].ppm
});

P(\traps, music: { |p b e|
	[
		dur: 32.collect{ [4,[ 8, 8 ],[ 16, 8, 16 ]].choose.reciprocal * 2  }.flat.warpTo( e.tempoMap.quantizeDft(0.6) ).q(1)// => _.findur(b[..10].sum)
		,
		instrument: \hat_808,
		pan:-1,
		out: Effect.bus({|i| CombN.ar(i,0.05,0.005,0.31)+i /4
		* Line.kr(1,0,b.sum+1)
		=> FreeVerb.ar(_,0.4,1) 
		/2
	},)
	].pp;
	[
		dur: 32.collect{ [4,[ 8, 8 ],[ 16, 8, 16 ]].choose.reciprocal * 2  }.flat.warpTo( e.tempoMap.quantizeDft(0.6) ).q(1)// => _.findur(b[..10].sum)
		,
		instrument: \hihat,
		pan:1,
		out: Effect.bus({|i| 
			i =>
			 CombN.ar(_,0.05,0.004,0.3) + i 
		=> DWGReverbC1C3.ar(_,mix:0.2)
		* Line.kr(1,0,b.sum+1)
		=> FreeVerb.ar(_,0.2,1)
		/20 
	},inputChannels:2, out: 2)
	].pp;
	[
		dur: "Q e e e e e e e e e e e e".asBeats.warpTo( e.tempoMap.quantizeDft(0.6) ).q,
		dur: " q h hh h".beats.warpTo( e.tempoMap.quantizeDft(0.6) ).q,
		rest: [\r,1, 1, 1, 1, 1, 1, 1, 1, 1, 1].q(inf),
		instrument: \kick,amp:0.04,
		instrument: \sn_808,
		lag: 0.02,
		freq: [1,2 ,3].df('f#',3) =>Pstep(_,b.parse([5,5,2])),
		out: Effect.bus({|i| i => DWGReverbC1C3.ar(i,mix:0.05) * Line.kr(1, 0, b.sum)  }, inputChannels:2, out: 1)
	].pp
});
P(\click, music: { |p b e|
	[
		dur: [1, 1, 2, 1, 1, 1, 1, 1, 1, 1, 1].warpTo(e.tempoMap.quantizeWindow(0.3)) ++ e.bNext => _.q,
		instrument: \harp, coef: 0.9,
		amp:0.05,
		freq: [1 ! 3, -7 ! 4,-5 ! 4, -4] =>_.flat =>_.df(\c,4,\mixolydian) => _.q

	].pp
});
P(\drum, music: { |p b e|
	[
		
	].pp
});
P(\chords, music: { |p b e|
	[
		freq: [[5, 7, 11, 13], [3, 5, 7, 11], [2,4,7], [-7,2,5]].df(\c,4,\mixolydian).q,
		dur: "qqqq qqqq qq qq".asBeats.warpTo( e.tempoMap ).q,
		strum: 0.05,
		instrument: \stringyy, amp: 0.1,
		out: (1..4)
	].ppm
});
P.synthV(role: \spock, take: \lead, params: {|p b| [
	lyrics: "Coming + from deep under + the planet's + surface + Captain + ",
	filter: (midinote: _ - 12), 
	pitchTake: 1
] }, music:{|p b e|
	{
		e.playbuf
		// => p.synthVTracks.at(e.key).()
		/8
		=> Pan2.ar(_, 0)
	}.play

});
P.double(role: \spock,
	filter: (midinote: _ ), 
	take: \lead, params: {|p b| [
	pitchTake: 1
] }, music:{|p b e|
	{
		e.playbuf
		// => p.synthVTracks.at(e.key).()
		/ 5
		=> Pan2.ar(_, 0)
	}.play

});
["Under at least one hundred miles of "," 1 2 3 4 5 4".dm(\f,\lydian) ++ "1 2 3 4 5 4 3".dm(\g,\lydian)].addLine;
Song.setTempoMap(\hundred,"Q Q Q Q Q Q Q Q Q e e e e");
P.still(\clear,lag:0.01, timecode: 0.seconds, music: { |p b e|
	 e.still.( 
		wait: b.sum,
		text: ["under at least","one hundred miles of"],
	)
});
P(\arp, music: { |p b e|
	var dur = 0.125;
	[
		instrument: \sawSynthSustain,
		degree: [0,8,15].q(inf),

		root: [0!( dur.reciprocal*5/3 ),-2!( dur.reciprocal *7/3),10!(dur.reciprocal*2)]=> _.flat => _.q,
		// dur: "Q q q q q q".asBeats.warpTo( e.tempoMap ).q,
		dur: (0.25).dup(24).asBeats.warpTo( e.tempoMap.quantizeDft(0.6) ).q,
		octave:4,
		lagTime:0,
		amp:0.035
	].ppm
});
P(\click, music: { |p b e|
	[
		instrument: \harp, coef: 0.9,
		freq: [1, -7, -6, -6, -5.5,-6,-5.5,-4.5].df(\f,4).q,
		// freq: 400,
		amp:0.05,
		dur: "QQ QQ QQ q  ".asBeats.asBeats.warpTo( e.tempoMap.quantize(0.2) ).q
	].pp
});
P(\line, music: { |p b e|
	{
		SinOsc.ar(
			[5, 6, 7].df(\f).dq.demand(e.bAll.parse([6,7,2])).lag(0.1) /2,
			Gendy4.ar(
				minfreq: [1, 2, 5].df(\f).dq.demand(e.bAll.parse([6,7,2])),

				maxfreq: [1, 2, 5].df(\f).dq.demand(e.bAll.parse([6,7,2]))
			), 
			0.01
		)
		* Env([0, 0.5, 1, 0], e.bAll.parse([3, 9, 3]), [0, 0, -5]).kr(2)
	}.play(s, 4)
});
P(\bassnotes, music: { |p b e|
	[
		freq: [[-1, 1],-7, -6, -5.5, -6, -5.5, -4.5].df(\f,4).q,
		dur: b.parse([2, 1, 6, 1, 1, 1, 1]).q,
		out: Effect.bus({|i| 
			i * 3
			=> FreeVerb.ar(_,0.1,1) => SineShaper.ar(_,0.05,mul:3)
			++ CrossoverDistortion.ar(i,mul:0.05)
			/5
			* EnvGen.cutoff(b.sum,1)
		},)
	].pp
});
P.synthVs(role: \spock, take: [\lead, \double], params: {|p b| [
	lyrics: "Under + at least - -  one hundred + miles - - of ",
	filter: [(midinote:_),(midinote: _ - 12)], 
	pitchTake: [1, 3]
] }, music:{|p b e|
	{
		e.playbuf
		// => p.synthVTracks.at(e.key).()
		/ 5 
		=> Pan2.ar(_, 0)

	}.play

});
P.tune( _ <> [instrument: \reedy, freqLag:0.05, rel:8, out: Effect.bus( {|i| CombN.ar(i, 0.3, 0.3, 3)/2 ++ i * -3.dbamp},out: 0) ].pm );
["(boom boom) solid rock.","-7 1 7 6 7 11  12 12 7".dm(\f)].addLine;
P.still(\clear,syl:1, timecode: 0.seconds, music: { |p b e|
	 e.still.( 
		wait: b.sum,
		text: ["solid","rock"],
	)
});
Song.setTempoMap(\solid,"e e e x x qqq e x xq".asBeats);
Song.durs.filter(\solid,{|i| var last = i.last; i.dropLast ++ (last - 0.1)});
P(\kick, music: { |p b e|
	var tm = e.tempoMap.quantizeDft(0.3);
	[
		[
			dur: "x x x xq x x x xq x x x xq E E E ".asBeats.warpTo( tm ).q,
			instrument: \kick_gentle,
			vol: [1,1,1,1,1,1,1,1,1,1,1,1,0.7,0.4,0.2] * 0.3 => _.q


		].p,
		[
			dur: "q ex xq ex x".asBeats.warpTo( tm ).q,
			instrument: \snare,
			rest: [\r,1,1,1,1,1,1].q
		].p,
		[
			dur: "q qq qq qq".asBeats.warpTo( tm ).q,
			instrument: \cymbalsDS,
			amp: 0.03,
			rest: [\r,1,1,1,1,1,1].q
		].p
	] => Ppar(_)
	=> Pset(\out, Effect.bus({|i| i/2 + SineShaper.ar(i,0.09) /3 }, out: 2, inputChannels:2),_)
	=> _.play

});
P.synthVs(role: \spock, take: [\lead, \dbl], params: {|p b| [
	lyrics: "r r solid + rock - r r r",
	legato: [[1, 1, 1, 1, 1, 0.5,  1, 1, ]],
	pitchTake: [1, 3]
] }, music:{|p b e|
	{
		e.playbuf
		=> p.synthVTracks.at(e.key).()
		=> Pan2.ar(_,0.2)
	}.play

});
//idea: NineZero here?
P.synthV(role: \spock,take: \harmony,
	pbind: {|p b|
		[
		midinote: "1 11 11 6 5 6".dm(\c),
		dur: 0.5 * "qq q e eqq q q".asBeats warpTo: p.tempoMap[\solid] ,
		].p
	},
	 params: {|p b| [
	lyrics: "r solid + rock baby +",
	legato: [1, 1, 1, 1, 1, 0.5, ],
	pitchTake: 1
] }, music:{|p b e|
	{
		e.playbuf
		=> p.synthVTracks.at(e.key).()
	}.play
});
P.synthVs(\feng, take: [\bg, \bg1], params: {|p b| [
	lyrics: "r r r r r r solid + rock",
	pitchTake: [1,3]
] }, music:{|p b e|
	{
		e.playbuf
		=> p.synthVTracks.at(e.key).()
		=> Pan2.ar(_,0.9)
	}.play
});
P(\harmony, music: { |p b e|
	[
		freq:"r 11 11 6 5 6".df(\c).q,
		dur: 0.5 * "qq q e eqq q q".asBeats warpTo: e.tempoMap q: 1,
		rest: [\r,1,1,1,1,1].q,

instrument: \reedy, freqLag:0.05, rel:8, out: Effect.bus( {|i| i +CombN.ar(i, 0.3, 0.3, 3)}, out:3) ;
	].ppm
});
P.synthVs(\kevin, take: [\lead, \double], 
	pbind: {|p b|
		[
			midinote: "1 -4 1 -7 -5 2 3".dm(\c),
			dur: "qq q q qq q q ".asBeats.warpTo( p.tempoMap[\solid] ) ++ 1
		].p
	},
	params: {|p b| [
	lyrics: "r solid + rock  r r r ",
	pitchTake: [1, 3]
] }, music:{|p b e|
	{
		e.playbuf
		=> p.synthVTracks.at(e.key).()
		* EnvGen.cutoff(b.sum,0.5)
		=> BPF.ar(_,1000)
		=> Pan2.ar(_,0)
	}.play

});
P(\bass, music: { |p b e|
	[
		freq: "3 4 7 11 3 4 3 4 7 11 12 5 2 2".df(\c,[2,3]).q,
		dur: "e e e e x x x x e x x ex x q".asBeats  =>_.warpTo(e.tempoMap.quantizeDft) =>_.q,
		instrument:\pluckDEnv, //try also without the effect
		amp:0.006,
		out: Effect.bus({|i| 
			i * 3
			=> FreeVerb.ar(_,0.0,1) => SineShaper.ar(_,0.05,mul:3)
			++ 
			(
				CrossoverDistortion.ar(i,mul:0.05)
				// /6
				*3
			)
			/4.5
			* EnvGen.cutoff(b.drop(-1).sum,0.0)
			/2
			
		}, inputChannels:2 )

	].ppm
});
// Song.durs.filter(\olid,{|i| i.drop(-1)++( i.last + 1 )});
P(\connector,syl: 7, music: { |p b e|
	[
		freq: [\r, 1, 2, 6].df(\g).q,
		instrument: \stringyy,
		dur: e.bAll.drop(1).parse([0.2,0.8,1]).q,
		amp:0.5,attack:2
	].pp
});
["I will make it possible for your transporter to beam you"," 5 5 5 6 5 4 3 2 3 4 4 3 3 1 2 3".dm(\d)].addLine;/*SARGON [OC]*/
Song.durs.filter( _ * 1.05 );
Song.setTempoMap(\possible,"q e eq e eq e eqqq q q q q q qqq q q q");
P.still(\lookingAway, timecode: 530.seconds, music: { |p b e| //muted
	 e.still.( 
		wait: 0.1,
		fadeIn:2,
		fade:b.sum + e.bNext.sum -0.1,
		text: ["",""],
	)
});
P.still(\clear,lag:0.01, timecode: 0.seconds, music: { |p b e|
	 e.still.( 
		wait: b.sum,
		text: ["I will make it ","possible"],
	).sequenceText2(
			b.parse([7,9]), [ 
			["for your transporter beam","to send you"],
			],
	)
});
P.still(\clear,lag:0.01, timecode: 0.seconds, music: { |p b e|
	 e.still.( 
		wait: b.sum,
		text: ["I will make it ","possible"],
		monitor: 2,
	).sequenceText2(
			b.parse([7,9]), [ 
			["for your transporter beam","to send you"],
			],
	)
});
P(\crash, music: { |p b e|
	(
		instrument: \cymbalsDS,
		att:0.5,
		amp: 0.01 * -3.dbamp
	).play;
	(
		instrument: \cymbalsDS,
		att:0.5,
		out: Effect.bus({|i| PitchShift.ar(i, pitchRatio: 3.6) }, out: 2, inputChannels: 2),
		amp: 0.01 * -3.dbamp
	).play
});
Song.vocoderWidth=0.93;
Song.vocoderMix=0.3;
( Song.vocoderPreset = (
	width: 0.93,
	mix: 0.3,
	// modGain:1.5
);
);
P.synthV(role: \vocoder, frozen: true, take: \lead, params: {|p b| [
	lyrics: "I will make it possible + + for your transporter + + beam to send you",
	filter: (midinote: _ - 12), 
	pitchTake: 1
] }, music:{|p b e|
	{
		var chords = (five: -3, four: -5, one: -10);
		var progression = [\five, \four, \one, \four, \five].collect{|i| chords.at(i).midiratio}.dq;
		Song.laMer => PlayBuf.auto(1,_,rate: progression.demand( "qqqq qqqq qqqq qqqq qq".asBeats.warpTo( e.tempoMap ) ).lag(0.1))   
		// *2
	}.play(s,p.carrierBus);
	p.vocodeTune.(p, b, e, e.rpp,
		chord: #[1,2],
		dur:b.sum + 3 => _.postln,
		att: 2,
		rel: 5,
		gain: 1.dbamp,
		sus:b.sum,
		durRel: 1,
		mix: p.vocoderMix, width: p.vocoderWidth,
	);
});
( SynthDef(\rescueTamb,{
	Shakers.ar(3,resonantFreq:\resonantFreq.kr(1),energy:\energy.kr(1))
	* \amp.kr(0.1) * 10
	=> Out.ar(\out.kr(0),_);
	Env.asr().kr(2,gate:\gate.kr(1))
}).add;
);
P(\tambo, music: { |p b e|
	[
		dur: "qq qqqq qqqq qqqq qqqq qqqq qqqq".asBeats.warpTo( e.tempoMap ).q,	
		instrument: \rescueTamb, amp: 0.3,
		rest: [\r, 1, 1, 1, 1, 1, 1, 1, 1].q,
		out: Effect.bus({|i| FreeVerb.ar(i,0.5,1) },)
	].pp
});
Song.setTempoMap(\possible,"q e eq e eq e eqqq e eq q q q qqq q q q");
P(\chord, music: { |p b e|
	[
		instrument: \sawSynth,
		freq: [-1,1,3,5].df(\a, [4,5]).bubble.q,
		strum:0.05,out: [1, 4],
		out: Effect.bus( FreeVerb.ar(_, mix:1, room:1, damp:0.5), out:0, inputChannels:2, target:nil)
	].pp
});
P(\bass, music: { |p b e|
	[
		freq: "1 1 -7 -7 1 -4 -6 -7 -17 -1 -1".df(\a,[3,4],\mixolydian).q,
		dur: "qe e q e e qe e qe e qe e".asBeats *2 =>_.warpTo(e.tempoMap)=>_.q,
		out: [4,p.carrierBus],
		amp: [0.05, 0.1]
	].pp

});
["(boom) that deep (that deep that deep) beneath the surface. Have no fear."," -5 3 2 2 3 2 2 3 2 2 1 2 3 2 1 -7 1".dm(\d)].addLine;
Song.setTempoMap(\fear,"q e e qqq e e qqq  e e e x xe x xe e e e");
P.still(\clear,syl:0, timecode: 0.seconds, music: { |p b e|
	 e.still.( 
		wait: b.sum,
		text: ["that","deep"],
		fade:1
	).sequenceText2(
			b.drop(1).parse([10,5]), [ 
			["beneath","the surface"],
			["",""]
			],
	)
});
P.still(\clear2,syl:0, timecode: 0.seconds, music: { |p b e|
	 e.still.( 
		wait: b.sum,
		text: ["that","deep"],
		fade:1,
		monitor: 2
	).sequenceText2(
			b.drop(1).parse([10,5]), [ 
			["beneath","the surface"],
			["",""]
			],
	)
});
P(\tambo, music: { |p b e|
	[
		dur: "q qq qq qq qq qq qq".asBeats.warpTo( e.tempoMap ).q,	
		instrument: \rescueTamb, amp: 0.3,
		rest: [\r, 1, 1, 1, 1, 1, 1, 1, 1].q,
		out: Effect.bus({|i| FreeVerb.ar(i,0.5,1) },)
	].pp
});
P.synthV(role: \vocoder, frozen: true, take: \lead, params: {|p b| [
	lyrics: "r that - deep that - deep that - deep beneath + the surface + baby +",
	legato: [1, 1, 1, 0.9, 1,1, 0.9, 1,1, 1, 1, 1, 1, 1, 1, 1, 1, ],
	filter: (midinote: _ - 12), 
	pitchTake: 1
] }, music:{|p b e|
	{
		var chords = (five: -3 , four: -5, one: -10);
		var progression = [\one, \four, \one, \four, \one,\five,\one, \four].collect{|i| chords.at(i).midiratio}.dq;

		Song.laMer => PlayBuf.auto(1,_,rate: progression.demand( "qq qq qq qq qq qq qq".asBeats.warpTo( e.tempoMap ) ).lag(0.1))   
		// * EnvGen.cutoff(b.parse([5]).unbubble,b[5])
		// *2
	}.play(s,p.carrierBus);
	[
		freq: [\r, [ [ 5, 7, 13 ],[5,7, 12 ], [4, 6, 12], [4,6,11] ].df(\d).q(inf)].q,
		// legato: [1,[ [2,2,1],1,1] .q(inf)].q,
		instrument: \sawSynthSustain,
		out: p.carrierBus,
		gain: 1.dbamp,
		amp:0.1,
		dur: "q e e qe eq e e qe eq  e e qq".asBeats.warpTo( e.tempoMap ).q
	].ppm;
	p.vocodeTune.(p, b, e, e.rpp,
		chord: #[1,2]/2,
		dur: b.sum + 1,
		att: 0.2,
		sus: b.sum - 0.2,
		rel: 1,
		durRel:3,
		mix: p.vocoderMix, width: p.vocoderWidth,
	);
	// Environment.pop;

});
P(\deep, music: { |p b e|
	{
		var durations = b.parse([3,3,3,2]);
		var pitch = [[4,6,12],[4,6,11],[4,6,12],[4,6,11],[5,2,12]].df(\d, 3).dq.demand(  b.parse([[3,1/2],[1/2,2],[1/2],[1/2,2],3]) );
		SawBL.ar(
			freq: pitch * Gendy1.arWidth(width:2,freq:[ 1/2, 1,0.52 ]).range(0.985,1.015) ,
			mul: 0.1
		)
		+ SawOS.ar( pitch, 0,mul:0.1 )
		* Env([0,1,0],[b[3]/2 ,b[3]/2 ]).kr(0,gate: TDuty.kr(durations.dq,0,gapFirst:1))

		// => LPF.ar(_,400)
		/3
		=> Phaser2.ar(_,rate:0.1)
		=> DWGReverbC1C3.ar(_,mix: 0.5)
		/ 3
	}.play
});
P(\bass, music: { |p b e|
	[
		// freq: [1, 4, 5,  1, 4, 5].df(\d,3).q(2),
		freq: [1,3, 4, 5,  1,3, 4, 5,1,3,5,-5, 1, 3].df(\d,3).q(2),
		// dur: "qq qe e qq qe e qq qe e q".asBeats.warpTo( e.tempoMap ).q
		dur: "qe e qe e qe e qe e qe e q q qe e ".asBeats.warpTo( e.tempoMap ).q
		// dur: b.parse([2, 3/6,1/6,[2/6,1],3/6,1/6,[ 2/6,1 ]]).q
	].pp
});
P(\keys, music: { |p b e|
	[
		freq: [\r,2, -7, 1, 3, 1, -4].df(\d,4).q,
		dur: "qqqqqqqqqqq e e q e e".asBeats.warpTo( e.tempoMap ).q,
		instrument:  \sawSynth

	].pp
});
P(\lick, music: { |p b e| //
	[
		freq: [-5,1, -5, \r, 1, -5, ].df(\d).q,
		att: [0.2,0.2,0.3,0.4,0.5,0.5].q,
		amp: [0.1,0.1,0.06, 0, 0.05,0.05].q /2,
		rel: [5,2,4, 0, 2,2].q,
		
		legato: [0.3,1,1,1,1,1].q,
		// instrument: "defaultPorto",
		instrument: \sawSynth ! 3 ++ (\pulse!3) => _.flat =>  _.q,
		dur: "qqqe e q qqe e q qqe e".asBeats.warpTo( e.tempoMap ).q,

	].pp
});
["la la la la",[ -4, 4, 14, 12, 13, 5, 13, 12, ].dm(\d)].addLine;
Song.setTempoMap('la la',"e e e e e e e e ");
P(\bass, music: { |p b e|
	[
		
		freq: [ 4, 5,  1,3, 4, ].df(\d,3).q,
		dur: "qe e qe e ".asBeats.warpTo( e.tempoMap ) ++ e.bNext[0..3].sum =>_.q
	].pp
});
P(\keys, music: { |p b e|
	[
		// freq: [ -4, 4, [6, 14], [7, 12], [1,11,13],5, [11,13],[12,-13 ] ,[ -14, 6 ], [ 11,-4 ],[6, 14], [7, 12], [1,11,13]].df(\d).q,
		freq: [ -4, 4, [6, 14], [7, 12], [1,11,13],5, [11,13],[12,-13 ] ,[ -14,  6 ]].df(\d).q,
		dur: 0.5.dup(8).asBeats.warpTo( e.tempoMap ) ++ e.bNext[0..3].sum => _.q ,
		instrument:  \sawSynth
	].pp
});
["/*SPOCK:*/ Reading a chamber now. Oxygen-nitrogen atmosphere, suitable for human life support.","3 4.5 5.5 7 5.5  2".dm(\g) ++ "1 2 3 4 5 3 11 7 2  4 3 2 3 5 3 -6.5".dm('b-')].addLine;
Song.setTempoMap(\nitrogen,"e x x e x xe  E E E E E E E E Ee e e e e ex x q");
P(\arp, music: { |p b e|
	var busses = 4.collect{ Bus.audio(s, 1) };
	var dur = 0.125;
		[
			amp:0.07,
			instrument: \default,
			freq:[
				[1,3,5.5, 7].df(\g,4),
				[-7,1,3,5].df('b-',4,\mixolydian),
				[1, 4, 5, 11].df(\f,4),
				[1,3,5,11].df('a-',4),
				[1,4.5,6.5, 11].df('a-',4)
			].q,
			dur: b.parse([6, 6,3,4, 3]).q,
			out: busses.collect(_.index).postln,
			pan: -1
		].ppm;
	{
		busses.collect(In.ar(_, 1))
		=> Select.ar( LFSaw.ar(3).range(0,4), _ )
		=> LeakDC.ar(_)
		=> Pan2.ar( _, LFSaw.ar(3) )
		* EnvGen.cutoff(b.sum,0.1)
	}.play(addAction: \addAfter).onFree(busses.do(_.free))
	

});
P.still(\spockReading, timecode: 541.seconds, music: { |p b e|
	 e.still.( 
		wait: b.sum,
		text: ["reading a","chamber now"],
	).sequenceText2(
			b.parse([6,9]), [ 
			["nitrogen-oxygen","atmosphere"],
			["suitable for","life support"]
			],
	)
});
P(\click, music: { |p b e|
	[
		instrument: \harp, coef: 0.9,
		freq: [ 1, 13 ].df(\g)!4 ++ ([1, -5].df('b-')!4) ++ [1].df('a-')  => _.q /[ 2 ],
		// freq: 400,
		amp:0.05,
		dur: "q e  ee Q Q Q Q Ee q q q e".beats.warpTo( e.tempoMap.quantize(0.2) ).q
	].pp
});
P.synthVs(role: \spock, take: [\lead,\double], params: {|p b| [
	lyrics: "Reading + a chamber + now. Nitrogen + + oxygen + + atmosphere + + suitable + + for life support. +",
	filter: (midinote: _ - 24), 
	legato: [ [1, 1, 1, 1, 1, 0.7,1,1,1,1,1,1,1,1,0.7,1, 1, 1, 1, 0.7, 1, 0.5 ] ],
	pitchTake: [1, 3]
] }, music:{|p b e|
	{
		e.playbuf
		=> p.synthVTracks.at(e.key).()
		=> Pan2.ar(_, -0.25)
	}.play

});
P(\chords, music: { |p b e|
	[
		amp:0.07,
		freq: [
			[1,3,5.5, 7].df(\g,4),
			[-7,1,3,5].df('b-',4,\mixolydian),
			[1, 4, 5, 11].df(\f,4),
			[1,3,5,11].df('a-',4),
			[1,4.5,6.5, 11].df('a-',4)
		].collect{ |i| i[0..1] }.q,
		amp: 0.05,
		legato: 0.7,
		freqLag: 1,
		instrument: \sawSynthSustain,
		attack:0,
		dur: b.parse([6, 6,3,4, 3]).q,
		// out: Effect.bus({|i| i* ( Impulse.ar(5) => Decay.ar(_,2)  )}, )
		out: Effect.bus({|i| i* ( TDuty.ar( "x*82".beats.warpTo( e.tempoMap.quantize ).dq ) => Decay.ar(_,1)  )},inputChannels: 2, out:1 )

	].ppm
});
P.tune( _ <> [instrument: \stringyy,mix: 0.8, amp: 0.09].pm );
P(\bass, music: { |p b e|
	[
		freq: [[ 1, 13 ]].df(\g) ++ [1, -5].df('b-') ++ [1].df('a-') => _.q /[ 4 ],
		dur: b.parse([6, 6, 3, 7]).q,
		amp: 0.05,
		out: Effect.bus({|i| FreeVerb.ar(i,0.5,[ 1,0.8 ]) => SineShaper.ar(_,0.2, mul:4) => BPeakEQ.ar(_, 275, rq:1, db: -19.dbamp) },inputChannels:2, out: 2)
	].pp
});
["/*KIRK:*/ Lieutenant Uhura, have Doctor McCoy report to the transporter room in ten minutes",[1, 1, -5, 1, 2, -5, 2, 3, 1, 3, 4, 5,4, 3,4,   5, 4, 3, 2, -6, -7, 2, 1].dm(\c)].addLine;
P.still(\kirkReport, timecode: 548.7.seconds, music: { |p b e|
	 e.still.( 
		wait: b.sum,
		text: ["Lieutenant","Uhura"],
	).sequenceText2(
			b.parse([6, 5, 7]), [ 
			["have Doctor","McCoy"],
			["report to the","transporter room"],
			["in ten","minutes"]
			],
	)
});
// Song.durs.filter({|i| i[0..13]++i[15..]});
P(\line, music: { |p b e|
	[
		freq: [ 1, 1, 1, -7,  -7, 1, 1, [1,-6]].df(\c).q,
		dur: b.parse([1,2,1, 2, 1, 2, 1, 2]).q,
		instrument: \visual_pad,
		amp:0.25
		
	].pp
});
P(\bass, music: { |p b e|
	[
		freq: [1, 1, 1, -5, -5, 1, 1, -4, -5,-5, 1 ].df(\c,4).q,
		dur: b.parse([1,2,1, 2, 1, 2, 1, 2,3, 6, 2]).q,
		instrument: \sawSynth,
		out: Effect.bus({|i| HPF.ar(i,60) },),
		amp: 0.08
	].pp;
	[
		
		freq: [1, 1, 1, 2, 2, 3, 3, 4, 5, -5, 1].df(\c,3).q,
		dur: b.parse([1,2,1, 2, 1, 2, 1, 2,3, 6, 2]).q,
		instrument: \sawSynth,
		out: Effect.bus({|i| i=> BPF.ar(i,800,19.5) => Pan2.ar(_,1) },),
	].pp
});
P.synthV(role: \kirk, take: \lead, params: {|p b| [
	lyrics: "Lieutenant + + Uhura + +, have Doctor + McCoy + report + to the transporter + + room in ten minutes +",
	pitchTake: 1,
	legato: [1, 1, 1, 1, 1, 0.8, 1, 1, 1, 1, 0.8, 1, 0.7, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1   ],
] }, music:{|p b e|
	{
		e.playbuf
		=> p.synthVTracks.at(e.key).()
		=> Pan2.ar(_,0)
	}.play

});
// ["with standard landing party equipment.","r"].addLine;
["/*UHURA:*/ Yes, sir.","-7,1".dm(\c)].addLine;
// Song.durs.filter('Yes, s', {|i| i.drop(-1) ++ (i.last -0.1)});
P.still(\clear, timecode: 0.seconds, music: { |p b e|
	 e.still.( 
		wait: b.sum,
		text: ["yes","sir"],
	)
});
Trek.cast.uhura = \cheng;
P.synthV(role: \uhura, take: \lead, params: {|p b| [
	lyrics: "yes sir",
	legato: [0.8, 0.3, ],
	pitchTake: 1
] }, music:{|p b e|
	{
		e.playbuf
		=> p.synthVTracks.at(e.key).()
		=> Pan2.ar(_,-0.4)
	}.play
});
/* P.still(\overTheShoulder, timecode: 536.335.seconds, music: { |p b e|
	 e.still.( 
		wait: b.sum,
		text: ["",""],
	)
}); */
P(\chords, music: { |p b e|
	[
		freq: [ [ 5,7,12 ],[5,11,13] ].df(\c,3).q,
		legato: [1, 0.3, ].q,
		dur: b.q
	].pp
});
P(\connector, music: { |p b e|
	fork{
		b[0] + s.latency => _.wait;
		{
			var amp = XLine.kr(0.001,0.1,b[1]);
			// b[0].wait;
			BrownNoise.ar(amp) 
			=>DynKlank.ar( `[[1,1.5].df(\c,[5,6,7]).dq.demand([b[1],2]),[1],[3]],_)
			=> Limiter.ar(_,0.3)
			* EnvGen.cutoff(b[1],0.4) 
			* -10.dbamp
			* -10.dbamp
		}.play(s,2);

	}
});
["/*KIRK:*/ Spock.","1".dm('c#')].addLine;
P.still(\captainLookingAtSpock, timecode: 551.9.seconds, music: { |p b e|
	 e.still.( 
		wait: b.sum,
		text: ["Spock?",""],
	)
});
P.synthV(role: \kirk, take: \lead, params: {|p b| [
	lyrics: "spock?",
	pitchDelta: Env([0,300],b),
	filter: (midinote: _ - 12), 
	legato: [0.3, ],
	lag: [0.2],
	pitchTake: 1
] }, music:{|p b e|
	{
		e.playbuf
		=> p.synthVTracks.at(e.key).()
		* 2 
		=> {|i| CombN.ar(i,0.2,0.2,3) / 2 + i}
		=> Pan2.ar(_,0)
	}.play
});
P(\connector, music: { |p b e|
	fork{
		s.latency => _.wait;
		{
			var amp = Line.kr(0.001,0.1,b[0]);
			// b[0].wait;
			BrownNoise.ar(0.1) 
			=>Ringz.ar(_, [1, 1.5].df('a-').dq.demand([b[0],1]), Line.kr(0,1,b[0]))
			// =>DynKlank.ar( `[[1,1.5].df('a-',[4,5,6,]).dq.demand([b[0],1]),[1],[3]],_)
			* amp

			* EnvGen.cutoff(b[0],2) 
			* -12.dbamp
			* -10.dbamp
		}.play(s,3);

	}
});
P(\note, music: { |p b e|
	(
		freq: [ 1, -6.5,3 ].df(\a,4),
		lag: 0.2,
	).play
});
["/*SPOCK:*/ Captain, I do wish to inspect whatever this is that lived that long ago.","7 4 7 7.5 5 6.5 7.5 11 5 3 4 2 3 5 11 12 11 7.5 7.5".dm('e',\minor)].addLine;
Song.durs.filter(\inspect, _ + [0,0,0,0, 0.1 ,0,0,0,0,0,0,0,0,0,0,0,0,0,0]);
P.synthV(role: \spock, take: \lead, params: {|p b| [
	lyrics: "Captain + I do wish to inspect + whatever + + this is that lived so long ago + ",
	// legato: [1, 0.6, 1, 0.8, 1, 1, 1, 1,  1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, ],
	legato: [1, 0.5, 1, 1, 0.6, 1, 1, 1,  1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, ],
	filter: (midinote: _ - 12), 
	pitchTake: 1
] }, music:{|p b e|
	{
		e.playbuf
		=> p.synthVTracks.at(e.key).()
		* 3.dbamp
		=> Pan2.ar(_, -0.25)
	}.play

});
P.still(\spockIDoWish, timecode: 555.0.seconds, music: { |p b e|
	 e.still.( 
		wait: b.sum,
		text: ["captain","I do wish"],
	).sequenceText2(
			b.parse([5, 8]), [ 
			["to inspect","whatever this is"],
			["that lived so","long ago"]
			],
	)
});
P(\dyads, music: { |p b e|
	[
		freq: [[4,6],[5,7],[4.5,7],[5,7],[6,7]].df(\c).q,
		dur: b.parse([7,4,1, 4,1,]).q,
		// release:[8,8,8,8,4].q, 
		instrument: \stringyy,mix:0,amp:0.03,
		out: [0,1]
	].ppm
});
P(\bass, music: { |p b e|
	[
		freq: [-1.5,-7,-7.5,-1.5,1,-3,-2,-3, [-4,-5]] .df(\e,[5],\minor).postln.q,
		rest: [\r,1].q(inf),
		dur:b.parse([[1, 0.34], [0.66,1], [1,0.34], [0.66,1,  1], 2, 2, 1, 4, 3]).postln.q,
		legato: [2,1,2,1,1,1,1,1,1].q,
		// instrument: \sawSynth,
		out: Effect.bus({|i| DWGReverbC1C3.ar(i => BPF.ar(_,900,10),c1:2,mix: 0.5)  },out:2)
		

	].p.play;
	[
		freq: [-1.5,-7,-7.5,-1.5,1,-3,-2,-3, [-4,-5]] .df(\e,[5],\minor).postln.q,
		rest: [1,\r].q(inf),
		dur:b.parse([[1, 0.34], [0.66,1], [1,0.34], [0.66,1,  1], 2, 2, 1, 4, 3]).postln.q,
		legato: [2,1,2,1,1,1,1,1,1].q,
		instrument: \sawSynth,
		out: Effect.bus({|i| DWGReverbC1C3.ar(i => BPF.ar(_,900,10),c1:2,mix: 0.5)  },)

	].p.play

});
["/*KIRK:*/ And I would like to have my--","-7 3 2 3 1 4 5 4".dm(\g)].addLine;
P.still(\kirkUnusual, timecode: 558.491.seconds, music: { |p b e|
	 e.still.( 
		wait: b.sum,
		text: ["and I would like","to have my"],
	)
});
P.synthVs(role: \kirk, take: [\lead, \double], params: {|p b| [
	lyrics: "And I would like to have my -",
	legato: [[1, 1, 1, 1, 1, 1, 1, 2]],
	pitchTake: [1, 3]
] }, music:{|p b e|
	{
		e.playbuf
		=> p.synthVTracks.at(e.key).()
		=> Pan2.ar(_,0)
	}.play

});
P(\chords, music: { |p b e|
	[
		freq: [
			[-3, 1],
			[-2, 1],
			[-2, -7]
		].df(\d,\mixolydian).q,
		dur: b.parse([3, 1, 5]).q,
		instrument: \visual_pad
	].ppm
});
P(\bass, music: { |p b e|
	[
		freq: [-7, 1].df(\g,[ 3,4 ]).q,
		dur: b.parse([4,4]).q
	].pp
});
["(boom) science officer with me on something as unusual as this, but it i--s","-1 3 2 3 2 3 2 1 -7 1 -6  2 3 4 5 4 3 2 -7 1 2 1".dm(\c,6)].addLine;
P.still(\clear, timecode: 0.seconds, music: { |p b e|
	 e.still.( 
		wait: b.sum,
		text: ["",""],
	).sequenceText2(
			b.parse([1, 7]), [ 
			["science officer","with me"],
			["on something as unusual","as this but it is"]
			],
	)
});
P(\lick, music: { |p b e|
	[
		freq: [11, 7,6,5,4,3,2,1, -7, -6,-5,-4, -3].df(\c,6).q,
		dur: b[0]/7,
		instrument: \harp, coef:0.1, amp: 0.01,
		out: Effect.bus({|i| Phaser2.ar(i,rate: 0.01,fb:0.95) => {|i| [CombN.ar(i,0.2,b[0]/3,5) ,i] } => BPF.ar(_,800) })
	].pp
});
P.synthVs( \jun, take: [\harm1, \harm2],
pbind: ~t = [0,1].collect{|voice|
	{|p b|
		var vl=
		VoiceLeading( 
			[
				[5, 6,  6, 4, 7],
				[3, \_, 4, 2, 5]
			], b.parse([6,3, 4, 4, 5])
		).dm(\c);
		[
			dur: vl.voice(voice).durs,
			midinote: vl.voice(voice).line
		].p
	}
} => _.postln,
params: {|p b| [
	lyrics: "oooh - ooh - -",
	legato: [[1, 0.9, 1, 1, 1, ]],
	lag: [[0,0,0,0,0.2]],
	pitchTake: 1
] }, music: [-0.2,0.2].collect
{|pan|
	{|p b e|
		{
			e.playbuf
			=> p.synthVTracks.at(e.key).()
			=> Pan2.ar(_,pan)
		}.play

	}
});
Song.setTempoMap(\unusual,"q %x x x x x% e ee e e e e e e x xe x xe e e x xq".rhythm);
// Song.strum1 = AAS_Strum();
P(\strum, music: { |p b e|
	p.strum1.syn.run(true);
	p.strum1.setPlayMode(\strum );
	fork{ b.sum + 1 => _.wait; 
		p.strum1.syn.run(false)
	};
	[
		type: \strum,
		instance: p.strum1,
		freq: [ [1,3], [-6,1],[-4, -6],[2,4],[5, 7] ].df(\c).q,
		dur: b.parse([6,3,4,[ 1,1,1,1,1/3 ],[2/3,1,1,1,1],4]).q,
		legato:1
	].pp;
	[
		type: \strum,
		instance: p.strum1,
		switch: [ \down, \muffleD, \d, \d, \d, \d ].q,
		lag: [0,0.1,0,0,0,0].q,
		legato:1,
		// dur: 10
		lag:0.01,
		dur: b.parse([1, 5,3,4,[ 1,1,1,1,1/3 ],[2/3,1,1,1,1],4]).q,

		// lag:0.05
	].pp
	// => _.play
});
P.synthVs(role: \kirk, take: [\lead, \double], params: {|p b| [
	lyrics: "r science + officer + + with me on something + as un usual + + as this, but it is -",
	pitchTake: [1, 3]
] }, music:{|p b e|
	{
		e.playbuf
		=> p.synthVTracks.at(e.key).()
		=> Pan2.ar(_,0)
	}.play

});
P(\click, music: { |p b e|
	[instrument: \hihat,dur:1.dup(10).warpTo(e.tempoMap).q]//.pp
});
P(\bass, music: { |p b e|
	[
		freq: "11  6 13 11 4 14 6 2 12 2 5 15 5".df(\c,3).q,
		dur: b.parse([6, [1,0.5],0.5,1, 2, 1,1, [2,0.34],0.66,[1,0.34],[ 0.66,1 ],1,2]).q
		// dur: "qe e q e e q e e q e e".beats.warpTo(e.tempoMap).q
	].pp
});
["(boom) full of unknowns","-1 3 2 2 2".dm('f#',6,\minor)].addLine;
P.still(\clear, timecode: 0.seconds, music: { |p b e|
	 e.still.( 
		wait: b.sum,
		text: ["",""],
	).sequenceText2(
			b.parse([1]), [ 
			["full","of unknowns"],
			],
	)
});
Song.setTempoMap(\unknowns,"q qq Q E q ");
P(\plink, music: { |p b e|
	{
		Pluck.ar( PinkNoise.ar(0.1), 1, 0.1, 1.df('f#',4) + Gendy1.kr(minfreq:0.2,maxfreq:[5,10]).range(-5,5) =>_.reciprocal, decaytime:4)
		+ Pluck.ar( PinkNoise.ar(0.1), Impulse.ar(0) => DelayN.ar(_,"qq".beats.warpTo(e.tempoMap),"qq".beats.warpTo(e.tempoMap)), 0.1, -7.df('f#',4,\minor) + Gendy1.kr(minfreq:0.2,maxfreq:[5,10]).range(-5,5) =>_.reciprocal, decaytime:4)
		+ Pluck.ar( PinkNoise.ar(0.1), Impulse.ar(0) => DelayN.ar(_,b[0..4].sum,b[0..3].sum), 0.1, -6.df('f#',4) + Gendy1.kr(minfreq:0.2,maxfreq:[5,10]).range(-5,5) =>_.reciprocal, decaytime:4)

		=> {|i| CrossoverDistortion.ar(i * EnvGen.cutoff(b.parse([6]).unbubble,0))/30 + i}
		=> LeakDC.ar(_)
		=> FreeVerb.ar(_,0.5,1)
	}.play
});
P.synthVs(role: \kirk, take: [\lead, \double], params: {|p b| [
	lyrics: "r full of unknowns +",
	filter: (midinote: _ - 12), 
	pitchTake: [1, 3]
] }, music:{|p b e|
	{
		e.playbuf
		=> p.synthVTracks.at(e.key).()
		=> Pan2.ar(_,0)
	}.play

});
P(\click, music: { |p b e|
	[
		dur: 0.5.dup(9).warpTo(e.tempoMap).q,
		amp: [2,1].q(inf)/20,
		rest: [1,\r].q(inf),
		instrument:\hihat
	].pp
});
P(\bass, music: { |p b e|
	[
		freq: "1 1 -7 -7 -6".df('f#',[3,4],\mixolydian).q,
		dur: "qe e qe e ee".asBeats/1 warpTo: e.tempoMap q: 1
	].pp;
});
P(\middle, music: { |p b e|
	[
		freq: [\r, [1,3],[-7,3],[-7,3],[-6.5,3]].df('f#',\minor).q,
		dur: b.q,
		instrument: \pulse
	].pp
});


P(\dyad, music: { |p b e|
	(
		instrument: \stringyy,
		freq: [5,1].df('f#',4),
		dur: b.parse([4])
	).play
});
["and we can't risk both of us being off the ship.","5 6 5 4 3 2 1 -7 -6 -7 -5 1".dm(\e)].addLine;
P.still(\clear, timecode: 0.seconds, music: { |p b e|
	 e.still.( 
		wait: b.sum,
		text: ["and we can't risk","both of us"],
	).sequenceText2(
			b.parse([7]), [ 
			["being off the","ship"],
			],
	)
});
Song.durs.filter({|i| var last = i.last; i.dropLast ++ (last * 4 )});
P(\line, music: { |p b e|
	[
		freq: "5 6 5 4 3 2 1 -5 -6 -5 -4 -3".df(\e,[3, 4, 5 ]).q,
		instrument: \stringyy,
		dur: b.q
	].ppm
});
P(\bassnotes, music: { |p b e|
	[
		freq: [\r, 1, 5, 6, 5, 4, 3].df(\e,3).q,
		instrument: \sparkTriangle,
		amp: 0.05,
		// out: [ 0,1 ],
		out: [ 12,13 ],
		dur: b.parse([4,3, 1, 1, 1, 1, 1]).q
	].ppm;
	
});
( SynthDef(\tapeStop,{
	arg bus = 12;
	var in = In.ar(12,2 );
	var a =LocalBuf(s.sampleRate * 2,2);
	BufWr.ar(in, a, Sweep.ar(1, 44100), 1.0 );
	BufRd.ar(2,a,Sweep.ar(2, Env([44099,44099,10],[4,1],-1).kr(2)) - 0.1, loop:1.0,interpolation:1)
	=> Out.ar(0,  _)
}).add;
);
P.synthVs(role: \kirk, take: [\lead, \double], params: {|p b| [
	lyrics: "and we can't risk both of us being + off the ship",
	pitchTake: [1, 3]
] }, music:{|p b e|
	{
		e.playbuf
		=> p.synthVTracks.at(e.key).()
		=> Pan2.ar(_,0)
		=> Out.ar(12,_)
		}.play;
		fork{
			// b[0..10].sum.wait;
			Synth(\tapeStop,12)
		}

});
P.still(\darkness,syl:10, timecode: 606.789.seconds, music: { |p b e|
	 e.still.( 
		wait: b.sum + e.bNext[0],
		fadeIn:1,
		text: ["",""],
	)
});
P(\chords, music: { |p b e|
	[ 
		freq: [\r,[-11,-5,1,3].df(\e),[-1,-5,1,3].df(\b,4),[-15,-5, 1, 3].df('c#',\minor)].q,
		dur: b.parse([4,3,4,1]).q,
		strum: [0, 0.04, 0.04,0.06].q,
		out: Effect.bus({|i| i => HPF.ar(_,300) },inputChannels:2),
		instrument: \defaultPiano
	].pp
});

P(\powerDown,syl: 10, music: { |p b e|
	[
		dur: b.drop(1)[0]/5 ! 5 ++ 1 => _.q,
		note: (1,0..-4).q,
		instrument: \stringyy
	].pp;
	[
		dur: b.drop(1)[0]/5 ! 5 ++ 1 => _.q,
		note: (1,0..-4).q,
		instrument: \sawSynthSustain,
		pulse: 0.5, amp:0.01,
		out: Effect.bus({|i| i => Pan2.ar(_,1) },)
	].ppm;
	
});
[ "dark","r",[2] ].addLine;
["SULU: All power gone, sir.","3 2 1 -7, -5".dm(\g,\minor)].addLine;
P(\gone,syl:2, music: { |p b e|
	{
		{ 1.df(\d,3).pareto(0.9)}!40 => SinOsc.ar(_,0,0.05)
		=>Splay.ar(_).sin
		* Env.perc(0.01,8).kr(2,gate:1)

	}.play
});
Trek.cast.sulu = \an;
Trek.presets.put(\sulu,\an,[
	paramGender: -0.35,
	paramToneShift: 200,
]);
P.synthV(role: \sulu, take: \lead, params: {|p b| [
	lyrics: "all power + gone sir",
	legato: [1, 1, 1, 0.8, 0.55, ],
	filter: (midinote: _ - 12), 
	pitchTake: 1
] }, music:{|p b e|
	{
		e.playbuf
		=> p.synthVTracks.at(e.key).()
		=> Pan2.ar(_,0.7)
	}.play

});
P.tune();
P(\chords, music: { |p b e|
	[
		strum: 0.05,
		freq: [-1, -5, 1, 3].df(\g,4,\minor).bubble ++ [-1,3,5,11].df(\d,4,\minor).bubble => _.q,
		dur: b.parse([3,2]).q,
		out: Effect.bus({|i| FreeVerb.ar(i,0.8,[0.9, 1 ]) => SineShaper.ar(_,0.05,) },)

	].pp
});
P.still(\suluSpeaks, timecode: 609.739.seconds, music: { |p b e|
	 e.still.( 
		wait: b.sum,
		text: ["all power","gone, sir"],
	)
});
P(\bassnote,syl:2, music: { |p b e|
	[
		freq: 1.df(\d,3).bubble ++ ( p.tune[e.start+1].list[0..7] - 24 => _.midicps ) ++ 1.df('a-',3) => _.q,
		dur: b.drop(1).sum.bubble ++ e.bNext => _.q,
		instrument: \sawSynthSustain, amp: 0.06, out: Effect.bus({|i| FreeVerb.ar(i,0.1,1) },out: 2)
	].ppm
});
["KIRK: On the other hand, perhaps this Sargon would like you to come with","1 2 3 2 1 2 3 4.5".dm(\e) ++ "3 1".dm('a-',\minor) ++ "2 3 4 2 3 4.5 ".dm('a-')].addLine;
P(\bassnote,syl:7, music: { |p b e|
	[
		midinote: [1].dm('a-') ++ p.tune[e.start].list[10..] -.t [24,36] => _.q,
		dur: b.drop(1).parse([2,1,1,1,1,1,1]).q,
		instrument: \washSus, freqLag:0.1,amp: 0.04
	].ppm
});
// P.tune( { |i|  i <> [instrument: \sawSynthSustain, amp: 0.06, out: Effect.bus({|i| FreeVerb.ar(i,0.1,1) },)].pm => Pmul(\freq, 0.25, _) => Pfin(8,_) } );
P.synthVs(role: \kirk, take: [\lead, \double],
	pbind: Song.enlarge(1),
	 params: {|p b| [
	filter: (midinote: _ - 12), 
	lyrics: "On the other + hand, perhaps +  this Sargon +  would like you to come with us",
	legato: [[1,1,1,1,0.6, 1,1,0.8, 1,0.7, 1, 1, 1, 1, 1, 1,1.3 ]],
	pitchTake: [1, 3]
] }, music:{|p b e|
	{
		e.playbuf
		=> p.synthVTracks.at(e.key).()
		=> Pan2.ar(_,0)
	}.play

});
P(\chords, music: { |p b e|
	[
		freq: [\r, [-3, 1, 3, 5].df(\e), [-11,-1, -5, 1, 3].df('a-',\minor), [-11,-1].df('a-'),[-1,1,3].df('a-'),[-3,-5,-7,3].df('b-',\mixolydian)] /2 => _.q,
		strum: 0.06,
		dur: b.parse([2, 6, 1, 2,4,2]).q,
		out: Effect.bus({|i| i.sin => HPF.ar(_,[ 300,400 ]) => FreeVerb.ar(_,0.5,1) },)
	].pp;
	[
		instrument: \help_oteypiano,
		rho:0.5,
		amp: 0.5,
		// midinote: p.tune[e.start] -24,
		midinote: "1 2 3 2 1 2 3 4.5".dm(\e) ++ "1 ".dm('a-',\minor) ++ "2 3 4 2 3 4.5 2".dm('a-') - 24 => _.q,
		legato: [ 3, 1, 1, 1,  1, 1, 1, 1,  1, 1, 1, 1, 1, 1, 1   ].q,
		dur: b.parse([1, 1, 1, 1, 1, 1, 1, 1, 2, 1, 1, 1, 1, 1, 2]).q,
		out: Effect.bus({|i| OteySoundBoard.ar(i).sin},inputChannels:2 ,)
	]//.pp
});
P.still(\kirkPerhaps, timecode: 614.55.seconds, music: { |p b e|
	 e.still.( 
		wait: b.sum + e.bNext[0],
		text: ["on the","other hand"],
	).sequenceText2(
			b.parse([5, 5]), [ 
			["perhaps this","Sargon"],
			["would like you","to come with us"]
			],
	)
});
[ "us -Power is restored-","1 1.5 2 2.5 3 4 5".dm('a-') ].addLine;
// P.tune();
P(\connector, music: { |p b e|
	[
		midinote: p.tune[e.start].list -12 ++ 4.dm('a-',4) => _.q,
		dur: b ++ e.bNext[0] => _.flat => _.q,
		instrument: \stringyy, amp:0.2, release: 2
	].ppm;
	[
		midinote: p.tune[e.start].list -12 ++ 6.dm('a-',4) -12 => _.q,
		dur: b ++ e.bNext[0] => _.flat => _.q,
		instrument: \harp, amp:0.02
	].pp;
});
P.still(\dark, timecode: 619.5.seconds, music: { |p b e|
	 e.still.( 
		wait: b.sum,
		fadeIn: b[0],
		text: ["",""],
	)
});
P.still(\powerBack,lag:0.01, timecode: 620.5.seconds, music: { |p b e|
	 e.still.( 
		wait: b.sum + e.bNext.sum,
		fadeIn:b.sum,
		text: ["",""],
	)
});
["SPOCK: Fascinating.","11 5.5 3 1".dm('c#')].addLine;
P.still(\spockFascinating, timecode: 622.seconds, music: { |p b e|
	 e.still.( 
		wait: b.sum,
		text: ["fascinating",""],
	)
});
P.synthVs(role: \spock, take: [\lead,\double], params: {|p b| [
	filter: (midinote: _ - 12), 
	lyrics: "fascinating + + +",
	lag: [[0.1,0.05,0,0]],
	legato: [[1,1,1,0.6, ]],
	vocalMode: \Gentle,
	pitchTake: [1,3]
] }, music:{|p b e|
	{
		e.playbuf
		=> p.synthVTracks.at(e.key).()
		=> HPF.ar(_,250)
		=> BPF.ar(_,1100,3.5)
		=> {|i| i => CombN.ar(_) / 4 + i}
		=> Pan2.ar(_,-0.25)
	}.play

});
P(\chord, music: { |p b e|
	[
		freq: [[-4.5,1, 3, 5],[-5.5, 1, 3.5, 5.5]].df('c#',6,\whole).q ,
		instrument: \stringyy,amp: 0.05,
		dur: b.sum
	].pm.play
});
P(\connector, music: { |p b e|
	[
		freq: [11, 5.5, 3, 1, -4].df('c#',4).q,
		dur: b ++ e.bNext[0] => _.q,
		instrument: \sawSynthSustain, pulse: 0.5, amp: 0.05, out:Effect.bus({|i| i => HPF.ar(_,200) },out:3) 
	].ppm
});
P.tune();
// ["SULU: All normal. No damage at all.","r"].addLine;
// ["KIRK: I see.","r"].addLine;
[" Will you transport down with us, Mister Spo--ck?","1 -5 1 2 3 2 1 -5 -4 -4 -3".dm('f#')].addLine;
Song.setTempoMap(\Will,"e e e e| e e qq ex x | e e");
P(\tremolo, music: { |p b e|
	e.bNext.postln;
	{
		var freq = [3,4,5, 3].df('f#',6).dq.
		demand(
			"qqqq qq q".asBeats.warpTo(e.tempoMap) 
			+ [0,0,e.bNext[..1].sum]
			++ e.bNext[2] 
			 => _.postln
		);
		var upper = [5, 6, 7, 11].df('f#',6).dq.
		demand("qqqq qq q".asBeats.warpTo(e.tempoMap) + [0,0,e.bNext[..1].sum] ++ e.bNext[2]);
		var modulated = [freq,upper].dq(inf) ;
		SinOsc.ar(
			Demand.ar( Impulse.ar(14),1, modulated )
		)
		/30 => Monitors.az(_, SinOsc.ar(0.1))
		* EnvGen.cutoff(b.sum,1)
	}.play
});
P(\strum, music: { |p b e|
	[ 
		freq: "1 5 11 13 15 21".df('f#',3).dup ++ "1 4 11 14 16".df('f#',3).bubble ++ "2 5 12 15 17".df('f#',3).bubble => _.q,
		strum: [0.05, 0.01, 0.03, 0.025].q,
		dur: "qqq q qq q".asBeats.warpTo( e.tempoMap ).q,
		instrument: \harp,coef:0.3,amp:0.03
	].p.play
});
P(\line, music: { |p b e|
	[
		freq: "3 5 3 5 3 5 3 5 5 4 3  2 1 ".df('f#').q,
		dur: 0.5.dup(15).warpTo( e.tempoMap ).q
	].pp;
	[
		freq: "1 -7 1 -7 1 -7 1- -7 -6 -6 -6 -6 -5".df('f#').q,
		dur: 0.5.dup(15).warpTo( e.tempoMap ).q
	].pp
});
P.still(\kirkWillYou, timecode: 631.425.seconds, music: { |p b e|
	 e.still.( 
		wait: b.sum,
		text: ["will you transport","down with us"],
	).sequenceText2(
			b.parse([7]), [ 
			["Mister","Spock"],
			],
	)
});
P.synthVs(role: \kirk, take: [\lead, \double], params: {|p b| [
	lyrics: "Will you transport + down with us, Mister + Spock -",
	legato: [[1, 1, 1, 1, 1, 1, 0.7,   1, 1, 1]],
	pitchTake: [1, 3]
] }, music:{|p b e|
	{
		e.playbuf
		=> p.synthVTracks.at(e.key).()
		=> Pan2.ar(_,0)
	}.play

});
P.tune();
P(\horns, music: { |p b e|
	[
		[
			freq: [\r] ++ "13 12 11 7 7 6 5 4 4 3 2 -7".df('f#',4) q: 1,
			dur: "qq e e e e  e e e e  e e e e".asBeats.warpTo(e.tempoMap).q,
		].p 
		, [
			freq: [\r] ++ "11 7 6 5 4 3 2 1 -7 -5 ".df('f#',4) q: 1,
			dur: "qq e e e e ee e e  ee e e".asBeats.warpTo(e.tempoMap).q,
		].p
	]
	=> Ppar(_)
	<> [ instrument: \sawSynth,amp:0.05 ].p
	=> _.play
});
P(\bass, music: { |p b e|
	[
		freq: "1 -4 -5 -5".df('f#',[3,4]).q,
		dur: "qqqq qq q ".asBeats.warpTo(e.tempoMap).q
	].pp
});
["SPOCK: Evidently, Captain."," 4 3 2 1 -7 1".dm('f#')].addLine;
P.still(\walkingOut, timecode: 632.5.seconds, music: { |p b e|
	 e.still.( 
		wait: b.sum,
		text: ["evidently","Captain"],
	)
});
P.synthV(role: \spock, take: \lead, params: {|p b| 
	[
		lyrics: "Evidently + + + Captain +",
		filter: (midinote: _ - 12), 
		pitchTake: 1
	
	]}, music:{|p b e|
		{
			e.playbuf
			=> p.synthVTracks.at(e.key).()
			=> Pan2.ar(_,-0.2)
		}.play
});
P.tune();
Song.setTempoMap(\Evidently, "qe e qe e qe e");
P(\line, music: { |p b e|
	[
		freq: "4 3 2 1 -7 1".df('f#',4).q,
		dur: "q q q q q q q".asBeats.warpTo(e.tempoMap).q 
	].pp
});
P(\bass, music: { |p b e|
	[
		freq: [\r, [-6,6] ].df('f#',3) q: 1,
		dur: b.parse([ 2, 4 ]).q
	].pp
});
P(\line, music: { |p b e|
	fork{
		var inst = Barrier.collect(
			{
				Pulse.ar(\freq.kr(400) * [0.99,1,1.011],0.2)
				* Env.perc(0.005,2).kr(2,gate:1)
				* \amp.kr(0.1)
				=> Phaser2.ar(_,rate: 0.1)
			}.asDefName
		);
		inst.()[0] => 

		[
			instrument: _,
			amp:0.02,
		freq: "4 3 2 1 -7 1".df('f#',4).q,
			dur: "q q q q q q q".asBeats.warpTo(e.tempoMap).q ,
		] => _.pp;
		[
			instrument: \harp, coef: 0.3,
			// midinote: p.tune[e.start],
		freq: "4 3 2 1 -7 1".df('f#',4).q,
			dur: b.q,
			amp:0.03
		].p.fin(6).play
	}
});
["KIRK: Mister Sulu, you have the conn.","3 2 1 -7 -6 -5 -5 -6 -7 1.5".dm('f#')].addLine;
Song.setTempoMap(\Sulu,"QQ Q QQ Q QQ Qq q QQ Q qq ");
// Song.setTempoMap(\Sulu,"qe e qe e qe ee e qe e q");
P.still(\kirkConn, timecode: 633.38.seconds, music: { |p b e|
	 e.still.( 
		wait: b.sum,
		text: ["Mister Sulu","you have the conn"],
	)
});
P.synthVs(role: \kirk, take: [\alt, \altDouble], params: {|p b| [
	lyrics: "r r Mister + Sulu + you have the conn.",
	legato: [[1, 1, 1, 1, 1, 0.5, 1, 1, 1, 0.66, ]],
	pitchTake: [1, 3]
] }, music:{|p b e|
	{
		e.playbuf
		=> p.synthVTracks.at(e.key).()
		=> Pan2.ar(_,0)
	}.play

});
P.synthVs(
	\kevin,
	 // nil,
	take: [\lead, \double], params: {|p b| [
	lyrics: "Mister + Sulu - + - r r r r",
	legato: [[1, 1, 1, 1, 1, 0.5, 1, 1, 1, 0.66, ]],
	vocalMode: \Soft,
	pitchTake: [1, 3]
] }, music:{|p b e|
	{
		e.playbuf
		=> p.synthVTracks.at(e.key).()
		=> FreeVerb.ar(_,0.1,1)
		=> DCompressor.ar(_,ratio:20)
		/2
		=> Pan2.ar(_,1)
	}.play

});
P(\boom, music: { |p b e|
	fork{
		var inst = Barrier.collect({
			Saw.ar( \freq.kr(300) * [0.995,1,1.0031], 0.1 )
			=> RLPF.ar(_, Env([0,1,1,0],[\att.kr(5),\len.kr(1) ,\rel.kr(3)]).kr(0,gate:1)* \hi.kr(1500) + \low.kr(200),0.3)
			* Env.asr(0,1,2).kr(2,gate:\gate.kr(1))
			/3
		}.asDefName);
		inst.()[0]=>
		[
			instrument:_,
			freq: [\r, [-5,5,11], [-5,5]].df('f#',3).q,
			att: 40,len: 0,rel:5, length: 5,
			dur: "qqqqqq qqqq".asBeats.warpTo( e.tempoMap ).q,
			group: Trek.transitionGroup
			// instrument: \wash,att:0.1
		] => _.pp
	}
});
P(\bassnote, music: { |p b e|
	[
		freq: [\r, -5, -15].df('f#',4).q,
		dur:b.parse([2, [ 3, 0.5 ], [0.5, 5]]).q
	].pp
});
P(\chord, music: { |p b e|
	[
		strum: 0.05,
		freq: [\r, [-5, -7, 1, 3] ].df('e-',\mixolydian).q(1),
		dur: b.parse([9,1]).q,
		instrument: \harp,
		out: Effect.bus({|i| 
			i
			=> FreeVerb.ar(_,1,1)
			* SinOsc.ar([4.2,3],[0,0.3]).range(0.6,1.2)
		},)
	].pp;
	[
		strum: 0.05,
		freq: [\r, [-5, -7, 1, 3] ].df('e-',4,\mixolydian).q(1),
		dur: b.parse([9,1]).q,
		// instrument: \harp,
		out: Effect.bus({|i| 
			i
			=> FreeVerb.ar(_,1,1)
			* SinOsc.ar([3.3,4],[0,0.3]).range(0.6,1.2)
		},)
	].pp
});
P(\line, music: { |p b e|
	fork{
		var inst = Barrier.collect(
			{
				Pulse.ar(\freq.kr(400) * [0.99,1,1.011],0.2)
				* Env.perc(0.005,2).kr(2,gate:1)
				* \amp.kr(0.1)
				=> Phaser2.ar(_,rate: 0.1)
			}.asDefName
		);
		inst.()[0] => 

		[
			instrument: _,
			amp:0.02,
			freq: "3 2 1 -7 -6 -5".df('f#',5).q,
			dur: "q q q q q q q".asBeats.warpTo(e.tempoMap).q ,
		] => _.pp;
		[
			instrument: \harp, coef: 0.3,
			midinote: p.tune[e.start],
			dur: b.q,
			amp:0.03
		].p.fin(6).play
	}
});
P(\xtraBassnotes, music: { |p b e|
	[
		freq: [\r, -7,-7,  ].df('e-',3,\mixolydian).q,
		amp:0.2,
		dur: "qqqqqq qqq qq ".asBeats.warpTo( e.tempoMap ).q,
		group: Trek.transitionGroup
	].pp
});
// P.tune();
["final note","1".dm('a-'),[1]].addLine;
P.still(\walkingOut, timecode: 636.85.seconds, music: { |p b e|
	 e.still.( 
		wait: b.sum,
		text: ["",""],
		fade:2
	)
});
P(\lastBassnote, music: { |p b e|
	(
		midinote: p.tune[e.start].list[0] - [12,24],
		dur: 10,
		out: Effect.bus({ |i|  i * Env.linen(0,b.sum,4).kr(2,gate:1) => Pan2.ar(_,0)}),
		group: Trek.transitionGroup
	).play
});
P(\plink, music: { |p b e|
	{
		Pluck.ar( PinkNoise.ar(0.1), 1, 0.1, 1.df('a-',[2, 3 ]) + Gendy1.kr(minfreq:0.2,maxfreq:[5,10]).range(-5,5) =>_.reciprocal, decaytime:4)
		=> {|i| CrossoverDistortion.ar(i) /50 + i }		
		=> LeakDC.ar(_)
		* [0.5,1] * 3.dbamp
		=> DWGReverbC1C3.ar(_,mix:0.4)
		* EnvGen.cutoff(b[0],9,-1)
	}.play(Trek.transitionGroup)
});
)
