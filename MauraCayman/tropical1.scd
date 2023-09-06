(
Song.new(\mauraTropical,[]).current;
Song.resources.infrastructure= {Song.setupGuitPart.(Song.currentSong)} ;
Song.root= \c;
// ["record","r",[0.1]].addLine;
// P(\recorder, music:{|p b e| 
// 	var r = Recorder.new(s);
//
//     // record into a flac file
//     r.recHeaderFormat = "wav";
//
//     // default 'float' is incompatible with flac. set to 24bit:
//     r.recSampleFormat = "int24";
//
//     // set very obvious prefix for files
//     r.filePrefix = "Tropical_";
//
//     // start recording:
// 	r.record
// });
["arpeggios1","11 7 6 5 4 3 2 1".dm(Song.root)].addLine;
Song.setTempoMap(\arpeggios,"qe e qe e qe e q q");
P(\claves, music: { |p b e|
	[
		instrument: \claves_808,
		dur: "ex ex q e ee ex ex q e ex ".asBeats.warpTo( e.tempoMap ).q
	].pp
});
P(\shaker, music: { |p b e|
	
	{
	var levels = [5,1,2,1] /5 => _.dq(inf);
	var durs =  
	1/4 ! 32
	+ ( [1, -1] /40 => _.dup(8) )
	=> _.flat 
	=> _.warpTo(e.tempoMap.quantizeDft(0.2) ++ p.tempoMap[e.start + 1].quantizeDft(0.2))
	=> _.dq();
	var triggers = TDuty.kr( durs, 0,1,gapFirst:0 );
	var energy = EnvGen.ar( Env.linen(0, 0.00, 0.015), triggers, doneAction:0   ) 
		* Demand.kr(triggers,0,levels 
			// * 40
			// *8
		);
	Shakers.ar(6, energy:energy/2   , decay: 1).tanh
	
	// /5
	* 2
	=> Pan2.ar(_, 0.8)
	* EnvGen.cutoff(b.sum + e.bNext.sum - 2,3)
	/ 10
	// + SinOsc.ar(300,0,0.05)
	// => DelayN.ar(_,0.2 -0.03 )

}.play;

});
P(\counterMelody, music: { |p b e|
	[
		freq: [1, 2, -6].df(\c,7).q,
		instrument: \sawSynthSustain,
		dur: "qe e qq".asBeats.warpTo( e.tempoMap ).q
	]//.pp
});
P(\thruTune, music: { |p b e|
	[
		freq: "11 7 6 5 4 3 2 1".df(\c) ++ "11 7 6 5 4 ".df(\b,3,\phrygian) ++ "4 3 1 12 11".df(\f,3) => _.q,
		dur: "qe e qe e qe e qe e   qe e qe e qe e e e e e".asBeats.warpTo( e.tempoMap++p.tempoMap[e.start+1]).q,
		instrument: [\harp, \sawSynthSustain], amp:[0.05, 0.03], wiggle:300 
	].pp
});
P(\arr, music:{|p b e|
	var ob, main;
	var arpeggios = [11, 5, 3, 7, 6, 4, 1, 5, 4, 2, -6, 3, 2, -7, -5, 1];
	arpeggios => {|i| [ freq:i.df(\c) =>_.q, 
	dur: "e*16".beats.warpTo( e.tempoMap ).q
] 
// => _.pp
};
	main = [1, 4, 5, 8, 9, 12, 13, 16] -1 
	=> {|i| arpeggios[i].df(\c) => {|i| [freq: i.q, dur: "qe e qe e qe e qe e".asBeats.warpTo( e.tempoMap ).q, instrument:\stringyy].ppm}};
	ob = arpeggios[[1, 2, 5, 6, 9, 10, 13, 14 ]];
	ob => {|i| [ freq: [\r] ++ i => _.df(\c,[3,4])=> _.q, dur: "e e qe e qe e qe e q".asBeats.warpTo( e.tempoMap ).q ].pp};
});
( Song.steelDef = {
	SinOsc.ar(\freq.kr(400).lag2(2) +
	(SinOsc.ar(3.5).range(-3,3) * Env([0,1,1,0],[ 0.5,2,2 ]).kr(0,gate:1))
	* [1,2]) * \amp.kr(0.1) =>_.tanh / 4
	* Env.linen(0.05,\sus.kr(2),3).kr(2,gate:1)
	// => {|i| CombN.ar(i)/2 + i}
	=> Out.ar(\out.kr(0),_)
}.asDefName ;
);
P(\steel, music: { |p b e|
		[ 
			freq: [[3, 5],[4, 6]].df(\c).q,dur: "qe eqe".asBeats.warpTo( e.tempoMap ) + [0,8] =>_.q,
			instrument:p.steelDef,
			sus: b[..1].sum
		].ppm;
		[ 
			freq: [\r,[14, 6],[15, 7]].df(\c).q,dur: "qeeqq qe e".asBeats.warpTo( e.tempoMap ).q,
			lagTime:0.35 * 15, 
			instrument:\washVarLag
		].ppm;
});
["arpeggiosTwo","11 7 6 5 4 3 2 1".dm(Song.root)].addLine;
Song.durs.filter(\arpeggiosTwo, {Song.durs[\arpeggios1].list});
P(\claves, music: { |p b e|
	[
		instrument: \claves_808,
		dur: "ex ex q e ee ex ex q e ex ".asBeats.warpTo( e.tempoMap ).q
	].pp
});
Song.setTempoMap(\arpeggiosTwo,"qe e qe e qe e q q");
P(\fiveOne, music: { |p b e|
	[
		freq: [-7, 3, 4, 5].df(\c,[3,4]).q,
		dur: "qq qqqq q q".asBeats.warpTo( e.tempoMap ).q,
		instrument:\defaultPiano,wet:0,amp:0.15
	].ppm
});
P(\arr, music:{|p b e|
	var ob, main;
	var arpeggios = [11, 5, 3, 7, 6, 4, 1, 5, 4, 2,-6 ].df('B',\phrygian) ++ [4, 3, 1, 12,11].df(\f,4);
	arpeggios => {|i| [ freq:i.q, 
	dur: "e*16".beats.warpTo( e.tempoMap ).q
] => _.pp};
	main = [1, 4, 5, 8, 9, 12, 13, 16] -1 
	=> {|i| arpeggios[i] => {|i| [freq: i.q, dur: "qe e qe e qe e qe e".asBeats.warpTo( e.tempoMap ).q, instrument:\stringyy].ppm}};
	ob = arpeggios[[1, 2, 5, 6, 9, 10, 13, 14 ]];
	ob => {|i| [ freq: [\r] ++ i /.t [2,4] => _.q, dur: "e e qe e qe e qe e q".asBeats.warpTo( e.tempoMap ).q ].p.trace.play};
});
P(\steel, music: { |p b e|
	[ 
		freq: [[11, 5],[11, 6]].df(\B,\phrygian).q,
		dur: "qe eqqe".asBeats.warpTo( e.tempoMap ).q,
		lagTime:0.35 * 10, 
		instrument:p.steelDef,
		sus: b[..2].sum
	].ppm;
	[ 
		freq: [\r,[3,5],[4,6]].df(\c).q,dur: "qeeqq qe e".asBeats.warpTo( e.tempoMap ).q,
		lagTime:0.35 * 15, 
		instrument:\washVarLag
	].ppm;
});
["Verse1","-1 1 2 3 4 3 2 1 3 2 1 -7 1 2 -7 2 1 -5 5 5".dm(\c)].addLine;
Song.setTempoMap(\Verse1,"q E E E e x e e xeee x x e x e e e e xE E E");
P(\offbeat, music: { |p b e|
	[
		freq: [\r, [1, 5, 11, 13] ].df(\c).q(inf),
		dur: "e*16".beats.warpTo(e.tempoMap).q,
		instrument:  \harp, 
		out: Effect.bus({|i|  },)
		// amp: [ 0.03,0.1 ]
		
	].pp
});
P(\bassline, music: { |p b e|
	[ 
		freq: [1, 5, 1, 4, 6, 4, 5, 2, 5, 4, -7, 4, 1, 3, 5].df(\c,3).q,
		dur: "ex xe e ex xe e ex xe e ex xe e ex xe e ".asBeats.warpTo( e.tempoMap ).q,
		legato: [0.5, 0.8, 0.9, ].q(inf),
		amp: [1, 1.2, 0.8].q(inf) /10,
		instrument: \default,
		out: Effect.bus({|i| i * 2.5 => _.tanh.tanh /2 },inputChannels:2)
	].ppma
});
	// Song.guitarFx = {Effect.bus({|i| i/2.5 => BPF.ar(_,900,8) },out:3)};
Song.guitar = ( ~guitar = ~guitar.isNil.if{ AAS_Strum() }{~guitar} );
( Song.guitarFx = Bus.audio(s,1);
	Song.guitarFXSynthFunc = { In.ar(Song.guitarFx,1) / 2 => Out.ar(1,_)};
);
	Song.setupGuitPart = { 
		~guitarFXSynth.free;
		Song.guitarFXSynth.isPlaying.not.if{
			fork{
				Song.guitarFXSynth = Song.guitarFXSynthFunc.play;
				~guitarFXSynth = Song.guitarFXSynth;

				// 0.005.wait;
				Song.guitarFXSynth.register
			}
		};
		Song.guitar.setPlayMode(\strum );
		Song.guitar.setVoicingMode(\moveableLow);
	};
P(\guitar, music: { |p b e|
	var tm = e.tempoMap ++ p.tempoMap[e.start + 1];
	p.setupGuitPart.(p);
	[
		[
			type: \strum,
			instance: p.guitar,
			freq: [
				[3,1,5], [1, 14, 16], [5,21], [4,15,17],
				[3,1,5], [1, 14, 16], [15,17, 22],
				[13, 15.5 ]

			].df(\c,4).q(),
			dur: "qq qq qq qq qq qq qq qq ".asBeats.warpTo( tm.quantizeWindow(0.5) ).q(inf),
			// dur: 10,
			legato:1,
		].p ,
		[
			type: \strum,
			instance: p.guitar,
			switch: [ \down, \muffleU, \d, \u, ].q(inf),
			amp: [0.01,0.5].q(inf)  ,
			// lag: [0,0.1,0,0,0,0].q,
			legato:1,
			// dur: 10
			// lag:Pwhite( 0.01,0.02,inf ) + [-0.005,0.005].q(inf),

			dur: "x*65  ".beats.warpTo( tm.quantizeWindow(0.5) ).q,
			out: p.guitarFx
			// lag:0.05
		].p
	] => Ppar(_) 
	// => Pset(\out,fx,_) 
	=> _.trace
	=> _.play
});
P.tune(_<>[instrument:\defaultLinen,rel:0, rests:MuteFirst(), amp:0.13,t_trig:1,len:0.5, fatness:0.35].p.trace);
P(\thirds, music: { |p b e|
	[
		freq: [\r, 3, 4, 5, 6, 5, 4, 3, 5 ].df(\c,4).q,
		dur: b.q, amp:0.03, pan: -0.25
	].pp
});
P(\hat, music: { |p b e|
	[
		dur: "q*12".beats.warpTo( e.tempoMap ).q,
		instrument:\hihat,
		pan: -0.5,
		out: Effect.bus({|i| i=> Pan2.ar(_,-0.6) * -3.dbamp },)
		// out: Effect.bus({|i| CombN.ar( i, 0.5,"E".asBeats.warpTo( e.tempoMap ) + 0.05, 2 ) /4 + i * [0.7,0.3] },inputChannels:2)
	].pp
});
["VerseTwo","5 6 5 4 3 3 2 1 2 ".dm(\c)].addLine;
P(\bassline, music: { |p b e|
	[ 
		freq: [ 4, 6, 4, 5, 2, 5, 4, -7, 4, 1, 3, 5].df(\c,3).q,
		dur: "ex xe e ex xe e ex xe e ex xe e ex xe e ".asBeats.warpTo( e.tempoMap ).q,
		legato: [0.5, 0.8, 0.9, ].q(inf),
		amp: [1, 1.2, 0.8].q(inf) /10,
		instrument: \default,
		out: Effect.bus({|i| i.tanh.tanh },inputChannels:2)
	].ppma
});
Song.setTempoMap(\VerseTwo,"g Q Q E E Q Ee x x");
P(\click, music: { |p b e|
	[
		dur: "q*4".beats.warpTo( e.tempoMap ).q,
		instrument:\hihat,
		pan: -0.5,
		out: Effect.bus({|i| CombN.ar( i, 0.5,"x".asBeats.warpTo( e.tempoMap ), 2 ) /4 + i * [0.7,0.3] },inputChannels:2)
	].pp
});
// P.tune(_ <> [instrument:\defaultPiano].p);
P(\TUNEAndConnector, music: { |p b e|
	[
		midinote: p.tune[e.start].list ++ ( [p.tune[e.start + 1] - [24,12] ]) => _.q,
		dur: e.bAll[..11].q,
		instrument: \defaultPiano,
		amp:0.13

	].pp
});
P(\thirds, music: { |p b e|
	[
		freq: [ 3, 4, 3, 2, 1, -7  ].df(\c).q,
		dur: b.parse([1, 1, 1, 1, 1, 2]).q
	].pp
});
["Bridge","11 7 6 ".dm(\e) ++ "5 2 4 3 -5 5 2 4 3 2 3 4".dm('f#') ++ "11 12 7 6 12 11 7 11".dm(\d,\mixolydian) ].addLine;
P(\lastchord, music: { |p b e|
	[
		instrument: \visual_vowel,
		instrument: \ooh,amp:0.015,
		freq: [\r,[1,3,5,7].df('c#'),\r, [1,3,5,7] .df(\f,4)].q ,
		dur: "qqqqqqqq qq qqqq qq ".asBeats.warpTo( e.tempoMap ).q
	].pp
});
P(\shaker, music: { |p b e|
	
	{
		var levels = [5,1,2,1] /5 => _.dq(inf);
		var durs =  1/4 ! 32 + ( [1, -1] /40 => _.dup(8) ) => _.flat 
		=> _.warpTo(e.tempoMap.quantizeDft(0.2) ++ p.tempoMap[e.start + 1].quantizeDft(0.2))
		=> _.dq();
		var triggers = TDuty.kr( durs, 0,1,gapFirst:0 );
		var energy = EnvGen.ar( Env.linen(0, 0.00, 0.015), triggers, doneAction:0   ) 
		* Demand.kr(triggers,0,levels 
		);
		Shakers.ar(6, energy:energy/2   , decay: 1).tanh

		// /5
		* 2
		=> Pan2.ar(_, 0.8)
		* EnvGen.cutoff(b[..1].sum ,0.1)
		/ 10
		// + SinOsc.ar(300,0,0.05)
		// => DelayN.ar(_,0.2 -0.03 )

}.play;

});
P(\claves, music: { |p b e|
	[
		instrument: \claves_808,
		dur: "ex ex q ".asBeats.warpTo( e.tempoMap ).q
	].pp
});
P(\chordsTwo, music: { |p b e|
	[
		freq: [\r,[1, 3],[1, 4], [1, 3], [1, 4]].df('c#') ++ [[1, 3], [1,4]].df(\d) =>_.q => _.dupEach(2),
		dur: "q q q q q q q q q q q q q q".asBeats.warpTo( e.tempoMap ).q,
	].pp
});
Song.setTempoMap(\Bridge,"qe e q   e e q q q e e e e e e q e e qe e e e e e");
P.tune();
P.synthVs(\feng, take: [ \lead, \double ], params: {|p b| [
	lyrics: "r r r ahh - - - r r r r r r r r r r r r r r r r ",
	pitchTake: [ 1, 3 ]
] }, music:{|p b e|
	{
		e.playbuf
		/6
	}.play
});
P.synthVs(\feng, take: [ \leadTwo, \doubleTwo ], params: {|p b| [
	lyrics: "r r r r r r r r ah - - - - - r r r r r r r r ",
	pitchTake: [ 1, 3 ]
] }, music:{|p b e|
	{
		e.playbuf
		=> Pan2.ar(_,1)
		/6
	}.play
});
P.synthVs(\feng, take: [ \leadThree, \doubleThree ], params: {|p b| [
	lyrics: "r r r r r r r r r r r r r r r r r r r ah - - - - - - - ",
	pitchTake: [ 1, 3 ]
] }, music:{|p b e|
	{
		e.playbuf
		=> Pan2.ar(_,0)
		/6
	}.play
});
P(\arr, music:{|p b e|
	var ob, main ;
	var arpeggios = [11, 5, 3, 7, 6 ];
	arpeggios => {|i| [ freq:i.df(\e) =>_.q, 
	dur: "e*8".beats.warpTo( e.tempoMap ).q
] 
// => _.pp
};
	main = [1, 4, 5, ] -1 
	=> {|i| arpeggios[i].df(\e) => {|i| [freq: i.q, dur: "qe e q ".asBeats.warpTo( e.tempoMap ).q, instrument:\stringyy].ppm}};
	ob = arpeggios[[1, 2,   ]];
	ob => {|i| [ freq: [\r] ++ i => _.df(\e,[3,4])=> _.q, dur: "e e qe ".asBeats.warpTo( e.tempoMap ).q ].pp};
}
);
P.tune(_ <> [instrument: \washVarLag, rest: [\r,\r,\r,1,1,1,1].q].p);
P.tune(\two, start:P.calcStart(),function: _ <> [instrument: \washVarLag, rest: \r.dup(15) ++ [1, 1, 1, 1] =>_.q].p);
Song.bridgeTempoMap = Song.tempoMap[ \Bridge ].quantizeDft(0.5);
P(\beat, music: { |p b e|
	var s = \sn_808, k = \bd_808;
	[
		instrument: [\r] ++ [ k, s, k, k, s, k].dup(3).flat  => _.q,
		dur: "qq q q e e e e q q e e e e q q e e e e".asBeats.warpTo(Song.bridgeTempoMap).q,
		decay: 20,
		tone: 20, amp: Pfunc({|e| ( e.instrument == \bd_808 ).if{0.2}{0.1}})
	].pp;	
	(instrument: \cymbalsDS,amp:0.02, lag: "qq".asBeats.warpTo(Song.bridgeTempoMap)).play;
	[
		instrument:\hat_808,
		dur: "qq x*48".beats.warpTo(Song.bridgeTempoMap).q,
		amp: [0.03,0.1].q(inf),
		rests: MuteFirst()
	].pp
});
P(\washVarLag, music: { |p b e|
	[
		midinote: p.tune[e.start],
		dur: b.q,
		rest: [\r,\r,\r,1,1,1,1, \r ,\r,\r,\r,\r,\r,\r,\r, 1, 1, 1, 1].q,
		instrument: \washVarLag
	].pp
});
P(\bassPartTwo, music: { |p b e|
	[
		freq: [2.5, 2,[-1, 1 ], -4, -5, -1, -4, -5 ].df('c#', 4) ++ "1 5 4 2.5".df(\d, 3) =>_.q,

		// dur: b.parse([1,1, 3, 2, 3, 4, 3, 2]).q,
		dur:  "qe e   qq qe e qq qe e  qq qe e qq".asBeats.warpTo( 
			// e.tempoMap
			p.bridgeTempoMap
		).q,
		instrument: \sawSynth
	].pp
});
P(\steel, music: { |p b e|
	[ 
		freq: [[3, 5],[4, 6]].df(\e).q,dur: "qe e".asBeats.warpTo( e.tempoMap ).q,
		lagTime:0.35 * 10, amp: 0.02,
		instrument:\sawSynthSustain
	].ppm;
});
["EndinAlt", "2 1 5 4 3 2 1 5 4 ".dm(Song.root),].addLine;
Song.durs.filter(\EndinAlt,{ List[ 0.426, 0.413, 0.39, 0.406, 1.536, 0.39, 0.4, 0.407, 0.435,  ]
});
Song.setTempoMap(\EndinAlt,"e e e e eeee e e e e ");
P(\bass, music: { |p b e|
	[
		freq: [-5, 1, -6, -5, 1].df(\c,4).q,
		dur: "qq qq qe e q".asBeats.warpTo( e.tempoMap ).q,
		instrument: \sawSynthSustain,
		pulse:0.6

	].ppm
});
P.synthVs(\mo, take: [\lead, \doubleAlt],
	pbind: Song.enlarge(1),
	params: {|p b| [
		filter: [
			(midinote: "2 1 5 4 3 2 1 5 4 3".dm(\c,4)),
			(midinote: "2 1 5 4 3 2 1 5 4 3".dm(\c,4)),
		], 
		lyrics: "r da - da da r da - da da",
		pitchTake: [1, 2],
		legato: [[1, 1, 1, 1, 0.4, 1, 1, 1, 1, ]],
		vocalMode: \Soft
	] }, music:{|p b e|
	{
		e.playbuf
		=> HPF.ar(_,300)
		=> BPF.ar(_,1900)
		=> Pan2.ar(_,0.7)
		*0.8
		=> PlateReverb.ar(_,mix:0.3)
		// => p.synthVTracks.at(e.key).()
	}.play
});
P.synthVs(\kevin, take: [\lead, \doubleAlt],
	pbind: Song.enlarge(1),
	params: {|p b| [
		filter: [
			(midinote: "2 1 5 4 3 2 1 5 4 3".dm(\c)),
			(midinote: "2 1 5 4 3 2 1 5 4 3".dm(\c)),
		], 
		lyrics: "bah - dah dah dah  bah - dah dah ",
		pitchTake: [1, 2],
		legato: [[1, 1, 1, 1, 0.4, 1, 1, 1, 1, ]],
		vocalMode: \Soft
	] }, music:{|p b e|
	{
		e.playbuf
		=> HPF.ar(_,300)
		=> BPF.ar(_,3400,1.5) /3
		=> Pan2.ar(_,-7)
		=> PlateReverb.ar(_,mix:0.3, damping:0.9)
		// => p.synthVTracks.at(e.key).()
	}.play
});
P(\bassline, music: { |p b e|
	[
		freq: "2 1 5 4 3 -5".df(\c,4).q(2),
		dur: "e e e e q q e e e e".asBeats.warpTo( e.tempoMap ).q,
		instrument: \sparkTriangle, depth:0
	].ppm
});
P(\trip, music: { |p b e|
	[
		freq: [\r, 1, 2, 3].df(p.root).q,
		dur: "qqq E E E qq ".asBeats.warpTo( e.tempoMap ).q,
		legato: [1, 1, 1, 3, 1,  1, 1, 3, ].q,
		instrument: \harp, coef:0.3, amp: 0.03,
		out: 1
	].pp
});
["VerseB","-1 1 2 3 4 3 2 1 3 2 1 -7 1 2 -7 2 1 -5 5 5".dm(\c)].addLine;
Song.durs[\VerseB] = Song.durs[\Verse1];
Song.setTempoMap(\VerseB,"q E E E e x e e xeee x x e x e e e e xE E E");
P(\offbeat, music: { |p b e|
	[
		freq: [\r, [1, 5, 11, 13] ].df(\c).q(inf),
		dur: "e*16".beats.warpTo(e.tempoMap).q,
		instrument:  \harp, 
		out: Effect.bus({|i| i },)
		// amp: [ 0.03,0.1 ]
		
	]//.pp
});
P(\bassline, music: { |p b e|
	[ 
		freq: [1, 5, 1, 4, 6, 4, 5, 2, 5, 4, -7, 4, 1, 3, 5].df(\c,3).q,
		dur: "ex xe e ex xe e ex xe e ex xe e ex xe e ".asBeats.warpTo( e.tempoMap ).q,
		legato: [0.5, 0.8, 0.9, ].q(inf),
		amp: [1, 1.2, 0.8].q(inf) /10,
		instrument: \default,
		out: Effect.bus({|i| i.tanh.tanh },inputChannels:2)
	].ppma
});
P(\guitar, music: { |p b e|
	var tm = e.tempoMap ++ p.tempoMap[e.start + 1];
	p.setupGuitPart.(p);
	[
		[
			type: \strum,
			instance: p.guitar,
			freq: [
				[3,1,5], [1, 14, 16], [5,21], [4,15,17],
				[3,1,5], [1, 14, 16], [15,17, 22],
				[-5, 1, 15 ]

			].df(\c,4).q(),
			dur: "qq qq qq qq qq qq qq qq ".asBeats.warpTo( tm.quantizeWindow(0.5) ).q(inf),
			// dur: 10,
			legato:1,
		].p ,
		[
			type: \strum,
			instance: p.guitar,
			switch: [ \down, \muffleU, \d, \u, ].q(inf),
			amp: [0.01,0.5].q(inf)  ,
			// lag: [0,0.1,0,0,0,0].q,
			legato:1,
			// dur: 10
			// lag:Pwhite( 0.01,0.02,inf ) + [-0.005,0.005].q(inf),

			dur: "x*65  ".beats.warpTo( tm.quantizeWindow(0.5) ).q,
			out: p.guitarFx
			// lag:0.05
		].p
	] => Ppar(_) 
	// => Pset(\out,fx,_) 
	=> _.trace
	=> _.play
});
P.tune(_<>[instrument:\defaultLinen,
		fatness:0.8, amp:0.1,
	rests:MuteFirst(), ].p);
P(\thirds, music: { |p b e|
	[
		freq: [\r, 3, 4, 5, 6, 5, 4, 3, 5, 4, 3, 2, 3, 4, 2, 4, 3, 1 ].df(\c,4).q,
		dur: b.q, amp:0.05, pan: 0.5
	].pp
});
P(\click, music: { |p b e|
	[
		dur: "q*12".beats.warpTo( e.tempoMap ).q,
		instrument:\hihat,
		pan:-0.5
	].pp
});
["VersBTwo","5 6 5 4 3 3 2 1 2 ".dm(\c)].addLine;
Song.durs[\VersBTwo] = Song.durs[\VerseTwo];
Song.setTempoMap(\VersBTwo,"g Q Q E E Q Ee x x");
P(\bassline, music: { |p b e|
	[ 
		freq: [ 4, 6, 4, 5, 2, 5, 4, -7, 4, 1, 3, 5].df(\c,3).q,
		dur: "ex xe e ex xe e ex xe e ex xe e ex xe e ".asBeats.warpTo( e.tempoMap ).q,
		legato: [0.5, 0.8, 0.9, ].q(inf),
		amp: [1, 1.2, 0.8].q(inf) /10,
		instrument: \default,
		out: Effect.bus({|i| i.tanh.tanh },inputChannels:2)
	].ppma
});
Song.setTempoMap(\VerseTwo,"g Q Q E E Q Ee x x");
P(\click, music: { |p b e|
	[
		dur: "q*4".beats.warpTo( e.tempoMap ).q,
		instrument:\hihat,

		pan: -0.5,
	].pp
});
// P.tune(_ <> [instrument:\defaultPiano].p);
P(\TUNEAndConnector, music: { |p b e|
	[
		midinote: p.tune[e.start].list ++ ( [p.tune[e.start + 1]  ]) => _.q,
		// dur: e.bAll[..13].q,
		dur: e.bAll[..8].q,
		fatness:0.87, amp:0.1,
		instrument: \defaultLinen
	].pp
});
P(\thirds, music: { |p b e|
	[
		freq: [ 3, 4, 3, 2, 1,  -7 ].df(\c).q,
		dur: b.parse([1, 1, 1, 1, 1, 2]).q
	].pp
});
["Ending", "2 1 5 4 3 2 1 5 4 3".dm(Song.root)].addLine;
P(\cymbal, music: { |p b e|
	(instrument: \cymbalsDS, amp:0.01).play
});
P(\bass, music: { |p b e|
	[
		freq: [-5, 1, -6, -5, 1].df(\c,4).q,
		dur: "qq qq qe e q".asBeats.warpTo( e.tempoMap ).q,
		instrument: \sawSynthSustain,
		pulse:0.6,
		out:Effect.bus({|i| i=> Pan2.ar(_,0) },)
	].ppm
});
Song.setTempoMap(\Ending,"e e e e eeee e e e e eeee");
P(\bassline, music: { |p b e|
	[
		freq: "2 1 5 4 3 -5".df(p.root,4).q(2),
		dur: "e e e e q q e e e e q ".asBeats.warpTo( e.tempoMap ).q,
		instrument: \sparkTriangle, depth:0
	].ppm
});
P(\trip, music: { |p b e|
	[
		freq: [\r, 1, 2, 3].df(p.root).q(2),
		dur: "qqq E E E qqq ".asBeats.warpTo( e.tempoMap ).q,
		legato: [1, 1, 1, 3, 1,  1, 1, 3, ].q,
		instrument: \harp, coef:0.3, amp: 0.03,
		out: 1
	].pp
});
["Verse3",copyTuneFrom("Verse1")].addLine;
Song.cloneDursAndTempoMap(\Verse1);
P.clone(\Verse1,\guitar);
P.tune();
P.clone(\Verse1,\hat);
["VerseB3",copyTuneFrom(\VerseTwo.asString)].addLine;
Song.cloneDursAndTempoMap(\VerseTwo);
// P.tune();

["AmbientIntro",copyTuneFrom("arpeggios1")].addLine;
Song.cloneDursAndTempoMap(\arpeggios1);
P.clone(\arpeggios1,[
	\claves, \shaker, 
	// \thruTune,
	\arr,\steel, \counterMelody  
]);
P(\arr, music: { |p b e|
	// Message( Song, "arr_" ++ Song.section(\arpeggios1) => _.asSymbol).() .music.cs
	var ob, main;
	var arpeggios = [11, 5, 3, 7, 6, 4, 1, 5, 4, 2, -6, 3, 2, -7, -5, 1];
	arpeggios => {|i| [ freq:i.df(\c) =>_.q, 
	dur: "e*16".beats.warpTo( e.tempoMap ).q
] 
// => _.pp
};
	main = [1, 4, 5, 8, 9, 12, 13, 16] -1 
	=> {|i| arpeggios[i].df(\c) => {|i| [freq: i.q, dur: "qe e qe e qe e qe e".asBeats.warpTo( e.tempoMap ).q, instrument:\stringyy].ppm}};
	ob = arpeggios[[1, 2, 5, 6, 9, 10, 13, 14 ]];
	ob => {|i| [ freq: [\r] ++ i => _.df(\c,[3,4])=> _.q, dur: "e e qe e qe e qe e q".asBeats.warpTo( e.tempoMap ).q ].pp};
	
});
["LoopA",copyTuneFrom("arpeggios1")].addLine;
Song.harpsiPan = [-1,1,1].q(inf).asStream;
P(\longNote, music: { |p b e|
	var ob, main;
	var arpeggios = [11, 5, 3, 7, 6, 4, 1, 5, 4, 2, -6, 3, 2, -7, -5, 1];
	arpeggios => {|i| [
		freq:i.df(\c) =>_.q, 
		dur: "e*16".beats.warpTo( e.tempoMap ).q,
		instrument: \harp, coef:0.1,amp:0.02,
		out: Effect.bus({|i| i=> Pan2.ar(_, -1) },)
	] => _.pp
};
	main = [1, 4, 5, 8, 9, 12, 13, 16] -1 
	=> {|i| arpeggios[i].df(\c) => {|i| [freq: i.q, dur: "qqqqqqqqqe e qe e qe e qe e".asBeats.warpTo( e.tempoMap ++ p.tempoMap[e.start + 1] ).q, instrument:\stringyy].ppm}};
});
Song.cloneDursAndTempoMap(\arpeggios1);
P.clone(\arpeggios1,[
	\claves, \shaker, 
	// \arr,
	// \steel, 
	\counterMelody  

]);
P(\steel, music: { |p b e|
		[ 
			freq: [[3, 5],[4, 6]].df(\c).q,dur: "qe eqe".asBeats.warpTo( e.tempoMap ) + [0,8] =>_.q,
			instrument:p.steelDef,
			sus: b[..1].sum,
			amp: 0.02,
		].ppm;
		[ 
			freq: [\r,[14, 6],[15, 7]].df(\c).q,dur: "qeeqq qe e".asBeats.warpTo( e.tempoMap ).q,
			lagTime:0.35 * 15, 
			instrument:\washVarLag,
			amp: 0.02
		].ppm;
});
/* P(\newChords, music: { |p b e|
	[
		freq: [5, 6, 6, 7, [5,13]].df(\c).q,
		dur: "qq qq qq qq q".asBeats.warpTo( e.tempoMap ++ p.tempoMap[e.start + 1] ).q
	].pp
}); */
["LoopAA",copyTuneFrom("arpeggios1")].addLine;
Song.cloneDursAndTempoMap(\arpeggios1);
P.clone(\arpeggios1,[
	\claves, \shaker, 
	// \thruTune,
	// \arr,
	// \steel, 
	\counterMelody  
]);
P(\longNote, music: { |p b e|
	var ob, main;
	var arpeggios = [11, 5, 3, 7, 6, 4, 1, 5, 4, 2, -6, 3, 2, -7, -5, 1];
	arpeggios => {|i| [
		freq:i.df(\c) =>_.q, 
		dur: "e*16".beats.warpTo( e.tempoMap ).q,
		instrument: \harp, coef:0.1,amp:0.02,
		out: Effect.bus({|i| i=> Pan2.ar(_, 1) },)
	] => _.pp
};
	main = [1, 4, 5, 8, 9, 12, 13, 16] -1 
	=> {|i| arpeggios[i].df(\c) => {|i| [freq: i.q, dur: "qqqqqqqqqe e qe e qe e qe e".asBeats.warpTo( e.tempoMap ++ p.tempoMap[e.start + 1] ).q, instrument:\stringyy].ppm}};
});
/*
Song.getMusicFunction(\arpeggios1, \thruTune,)
*/
// P(\thruTune, music: { |p b e|
// 	[
// 		freq: "11 7 6 5 4 3 2 1".df(\c) ++ "11 7 6 5 4 ".df(\b,3,\phrygian) ++ "4 3 1 12 11 7".df(\f,3) => _.q,
// 		dur: "qe e qe e qe e qe e   qe e qe e qe e e e e e ".asBeats.warpTo( e.tempoMap++p.tempoMap[e.start+1]) ++ 1 =>_.q,
// 		instrument: [\harp, \sawSynthSustain], amp:[0.05, 0.03], wiggle:300 
// 	].pp
// });
["LoopB",copyTuneFrom("arpeggiosTwo")].addLine;
Song.cloneDursAndTempoMap(\arpeggiosTwo);
P.clone(\arpeggiosTwo,[
	\claves, \fiveOne,
	\arr, 
	\steel  
]);
["LoopA2",copyTuneFrom("arpeggios1")].addLine;
Song.cloneDursAndTempoMap(\arpeggios1);
P.clone(\arpeggios1,[ \claves, \shaker, 
	// \thruTune,
	\arr,
	\steel, 
	\counterMelody  ]);

["LoopB2",copyTuneFrom("arpeggiosTwo")].addLine;
Song.cloneDursAndTempoMap(\arpeggiosTwo);
P.clone(\arpeggios1,[ \claves, \shaker, \thru, \arr, \steel  ]);
["VerseLoop","-1 1 2 3 4 3 2 1 3 2 1 -7 1 2 -7 2 1 -5 5 5".dm(\c)].addLine;
Song.cloneDursAndTempoMap(\Verse1);
Song.setTempoMap(\Verse1,"q E E E e x e e xeee x x e x e e e e xE E E");
P(\offbeat, music: { |p b e|
	[
		freq: [\r, [1, 5, 11, 13] ].df(\c).q(inf),
		dur: "e*16".beats.warpTo(e.tempoMap).q,
		instrument:  \harp, 
		out: Effect.bus({|i|  },)
		// amp: [ 0.03,0.1 ]
		
	].pp
});
P(\bassline, music: { |p b e|
	[ 
		freq: [1, 5, 1, 4, 6, 4, 5, 2, 5, 4, -7, 4, 1, 3, 5].df(\c,3).q,
		dur: "ex xe e ex xe e ex xe e ex xe e ex xe e ".asBeats.warpTo( e.tempoMap ).q,
		legato: [0.5, 0.8, 0.9, ].q(inf),
		amp: [1, 1.2, 0.8].q(inf) /10,
		instrument: \default,
		out: Effect.bus({|i| i * 2.5 => _.tanh.tanh /2 },inputChannels:2)
	].ppma
});
	// Song.guitarFx = {Effect.bus({|i| i/2.5 => BPF.ar(_,900,8) },out:3)};
P(\guitar, music: { |p b e|
	var tm = e.tempoMap ++ p.tempoMap[e.start + 1];
	p.setupGuitPart.(p);
	[
		[
			type: \strum,
			instance: p.guitar,
			freq: [
				[3,1,5], [1, 14, 16], [5,21], [4,15,17],
				[3,1,5], [1, 14, 16], [15,17, 22],
				// [13, 15.5 ]

			].df(\c,4).q(),
			dur: "qq qq qq qq qq qq qq qq ".asBeats.warpTo( tm.quantizeWindow(0.5) ).q(inf),
			// dur: 10,
			legato:1,
		].p ,
		[
			type: \strum,
			instance: p.guitar,
			switch: [ \down, \muffleU, \d, \u, ].q(inf),
			amp: [0.01,0.5].q(inf)  ,
			// lag: [0,0.1,0,0,0,0].q,
			legato:1,
			// dur: 10
			// lag:Pwhite( 0.01,0.02,inf ) + [-0.005,0.005].q(inf),

			dur: "x*65  ".beats.warpTo( tm.quantizeWindow(0.5) ).q,
			out: p.guitarFx
			// lag:0.05
		].p
	] => Ppar(_) 
	// => Pset(\out,fx,_) 
	=> _.play
});
P.tune(_<>[instrument:\defaultPiano,rel:0, rests:MuteFirst(), amp:0.1,t_trig:1,len:0.5, fatness:0.35, 
out: Effect.bus({|i| i * SinOsc.ar(4.3) + (i/3) },)
].p);
P(\thirds, music: { |p b e|
	[
		freq: [\r, 3, 4, 5, 6, 5, 4, 3, 5 ].df(\c,4).q,
		dur: b.q, amp:0.03, pan: -0.25
	].pp
});
P(\hat, music: { |p b e|
	[
		dur: "q*12".beats.warpTo( e.tempoMap ).q,
		instrument:\hihat,
		pan: -0.5,
		out: Effect.bus({|i| i=> Pan2.ar(_,-0.6) * -3.dbamp },)
		// out: Effect.bus({|i| CombN.ar( i, 0.5,"E".asBeats.warpTo( e.tempoMap ) + 0.05, 2 ) /4 + i * [0.7,0.3] },inputChannels:2)
	].pp
});
["VersTwoLoop","5 6 5 4 3 3 2 1 2 ".dm(\c)].addLine;
Song.cloneDursAndTempoMap(\VerseTwo);
P(\bassline, music: { |p b e|
	[ 
		freq: [ 4, 6, 4, 5, 2, 5, 4, -7, 4, 1, 3, 5].df(\c,3).q,
		dur: "ex xe e ex xe e ex xe e ex xe e ex xe e ".asBeats.warpTo( e.tempoMap ).q,
		legato: [0.5, 0.8, 0.9, ].q(inf),
		amp: [1, 1.2, 0.8].q(inf) /10,
		instrument: \default,
		out: Effect.bus({|i| i.tanh.tanh },inputChannels:2)
	].ppma
});
Song.setTempoMap(\VerseTwo,"g Q Q E E Q Ee x x");
P(\click, music: { |p b e|
	[
		dur: "q*4".beats.warpTo( e.tempoMap ).q,
		instrument:\hihat,
		pan: -0.5,
		out: Effect.bus({|i| CombN.ar( i, 0.5,"x".asBeats.warpTo( e.tempoMap ), 2 ) /4 + i * [0.7,0.3] },inputChannels:2)
	].pp
});
// P.tune(_ <> [instrument:\defaultPiano].p);
P(\TUNEAndConnector, music: { |p b e|
	[
		midinote: p.tune[e.start].list ++ ( [p.tune[e.start + 1] - [24,12] ]) => _.q,
		dur: e.bAll[..11].q,
		instrument: \defaultPiano,
		amp:0.1,
		out: Effect.bus({|i| i * SinOsc.ar(4.3) + (i/3) },)

	].pp
});
P(\thirds, music: { |p b e|
	[
		freq: [ 3, 4, 3, 2, 1, -7  ].df(\c).q,
		dur: b.parse([1, 1, 1, 1, 1, 2]).q
	].pp
});
["VersLoopConnecter","r"].addLine;
Song.cloneDursAndTempoMap(\VerseLoop);
P.clone(\VerseLoop,[\guitar, \bassline,\click, ]);
P(\bassline, music: { |p b e|
	[ 
		freq: [1, 5, 1, 4, 6, 4, 5, 2, 5, 4, -7, 4, 1, 3, 5].df(\c,3).q,
		dur: "ex xe e ex xe e ex xe e ex xe e ".asBeats.warpTo( e.tempoMap ).q,
		legato: [0.5, 0.8, 0.9, ].q(inf),
		amp: [1, 1.2, 0.8].q(inf) /10,
		instrument: \default,
		out: Effect.bus({|i| i * 2.5 => _.tanh.tanh /2 },inputChannels:2)
	].ppma
});
P(\guitar, music: { |p b e|
	var tm = e.tempoMap ++ p.tempoMap[e.start + 1];
	p.setupGuitPart.(p);
	[
		[
			type: \strum,
			instance: p.guitar,
			freq: [
				[3,1,5], [1, 14, 16], [5,21], [4,15,17],
				// [3,1,5], [1, 14, 16], [15,17, 22],
				// [13, 15.5 ]

			].df(\c,4).q(),
			dur: "qq qq qq qq qq qq qq qq ".asBeats.warpTo( tm.quantizeWindow(0.5) ).q(inf),
			// dur: 10,
			legato:1,
		].p ,
		[
			type: \strum,
			instance: p.guitar,
			switch: [ \down, \muffleU, \d, \u, ].q(inf),
			amp: [0.01,0.5].q(inf)  ,
			// lag: [0,0.1,0,0,0,0].q,
			legato:1,
			// dur: 10
			// lag:Pwhite( 0.01,0.02,inf ) + [-0.005,0.005].q(inf),

			dur: "x*32  ".beats.warpTo( tm.quantizeWindow(0.5) ).q,
			out: p.guitarFx
			// lag:0.05
		].p
	] => Ppar(_) 
	// => Pset(\out,fx,_) 
	=> _.play
});
P(\TUNEAndConnector, music: { |p b e|
	var tm = e.tempoMap ++ p.tempoMap[e.start + 1];
	[
		freq: [\r, 1,2, 3, 4, 3, 2, 1, 3, [-7,2], [-3,-5], ].df(\c).q,
		dur: "q E E E e x xx xx xqq qq q".asBeats.warpTo(tm).q,
		instrument: \stringyy,
		amp:0.25, wet: 0.1,release:3,out: Effect.bus({|i| i=> Pan2.ar(_,0.5) },)

	].p.play
});
["VersTwoLoopConnect","r"].addLine;
Song.cloneDursAndTempoMap(\VerseTwo);
)
Song.pts.select{|i| i.key == \steel}.select{|i| i.start == Song.section(\arpeggios1)}

(
var sections = [13,12].q(inf).asStream;
	var r = Recorder.new(s);
    r.recHeaderFormat = "wav";
    r.recSampleFormat = "int24";
    r.filePrefix = "ArpeggiosLoop_";
fork{
	0.1.wait;
	r.record;
	6.do{
		var thisSec = sections.next;
		Song.playSection(thisSec);
		Song.secDur[thisSec].wait;
	};
	Song.secDur[12] + 3 => _.wait; 
	r.stopRecording
}

)
(
var durs = [Song.secDur[\VerseLoop],Song.secDur['VersTwoLoop'],"qqqqqqqq".asBeats.warpTo(Song.tempoMap[\VersLoopConnecter]).unbubble];
	var r = Recorder.new(s);
    r.recHeaderFormat = "wav";
    r.recSampleFormat = "int24";
    r.filePrefix = "CalypsoLoop_";
	Song.guitarFXSynthFunc = {
		In.ar(Song.guitarFx,1) / 4 
		=> HPF.ar(_,150)
=> Out.ar(1,_)
	};
fork{
	r.record;0.1.wait;
	6.do{
		[\VerseLoop,\VersTwoLoop,\VersLoopConnecter].do { |x i|
			x.postln;
			Song.playSection(x);
			// Song.secDur[x].wait
			durs[i].wait

		};
	};
		3.wait;
		r.stopRecording

}
)
