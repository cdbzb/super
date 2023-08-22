(

Song.new(\mauraTropical,[]).current;
Song.root= \c;
["arpeggios1","11 7 6 5 4 3 2 1".dm(Song.root)].addLine;
Song.setTempoMap(\arpeggios,"qe e qe e qe e q q");
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


Song.steelDef = {
		SinOsc.ar(\freq.kr(400).lag2(2) * [1,2]) * \amp.kr(0.1) =>_.tanh / 4
		* Env.linen(0.05,\sus.kr(2),3).kr(2,gate:1)
		=> {|i| CombN.ar(i) + i}
		=> Out.ar(\out.kr(0),_)
}.asDefName ;

P(\steel, music: { |p b e|
		[ 
			freq: [[3, 5],[4, 6]].df(\c).q,dur: "qe eqe".asBeats.warpTo( e.tempoMap ) + [0,8] =>_.q,
			instrument:p.steelDef,
			sus: b[..1].sum
		].ppm;
		[ 
			freq: [\r,[14, 6],[15, 7]].df(\c).q,dur: "qeeqq qe e".asBeats.warpTo( e.tempoMap ).q,
			lagTime:0.35 * 15, 
			instrument:\wash
		].ppm;
});
["arpeggiosTwo","11 7 6 5 4 3 2 1".dm(Song.root)].addLine;
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
		instrument:\wash
	].ppm;
});
["Verse","-1 1 2 3 4 3 2 1 3 2 1 -7 1 2 -7 2 1 -5 5 5".dm(\c)].addLine;
Song.setTempoMap(\Verse,"q E E E e x e e xeee x x e x e e e e xE E E");
P(\offbeat, music: { |p b e|
	[
		freq: [\r, [1, 5, 11, 13] ].df(\c).q(inf),
		dur: "e*16".beats.warpTo(e.tempoMap).q,
		instrument:  \harp, 
		out: Effect.bus({|i|  },)
		// amp: [ 0.03,0.1 ]
		
	].pp
});
Song.guitar = AAS_Strum();
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
	Song.guitarFx = {Effect.bus({|i| i/2.5 => BPF.ar(_,900,8) },out:3)};
	Song.guitarFx = {Effect.bus({|i| i },out:3)};
	Song.guitar.setPlayMode(\strum );
	Song.guitar.setVoicingMode(\moveableLow);
	P(\guitar, music: { |p b e|
	Song.guitar.setPlayMode(\strum );
	Song.guitar.setVoicingMode(\moveableLow);
	[
		[
			type: \strum,
			instance: p.guitar,
			freq: [ [3,1,5], [1, 14, 16], [5,21], [4,15,17]].df(\c,4).q(2),
			dur: "qq qq qq qq qq qq qq ".asBeats.warpTo( e.tempoMap.quantizeWindow(0.5)).q,
			// dur: 10,
			legato:1,
			out: p.guitarFx.(),
		].p ,
		[
			type: \strum,
			out: p.guitarFx.(),
			instance: p.guitar,
			switch: [ \down, \muffleU, \d, \u, ].q(inf),
			amp: [0.01,0.5].q(inf)  ,
			// lag: [0,0.1,0,0,0,0].q,
			legato:1,
			// dur: 10
			// lag:Pwhite( 0.01,0.02,inf ) + [-0.005,0.005].q(inf),

			dur: "x*48".beats.warpTo( e.tempoMap.quantizeWindow(0.5) ).q

			// lag:0.05
		].p
	] => Ppar(_) => _.play
});
P.tune(_<>[instrument:\defaultPiano].p);
P(\thirds, music: { |p b e|
	[
		freq: [\r, 3, 4, 5, 6, 5, 4, 3, 5 ].df(\c,4).q,
		dur: b.q, amp:0.03, pan: -0.25
	].pp
});
P(\click, music: { |p b e|
	[
		dur: "q*12".beats.warpTo( e.tempoMap ).q,
		instrument:\hihat
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
		instrument:\hihat
	].pp
});
// P.tune(_ <> [instrument:\defaultPiano].p);
P(\TUNEAndConnector, music: { |p b e|
	[
		midinote: p.tune[e.start].list ++ ( [p.tune[e.start + 1] - [24,12] ]) => _.q,
		dur: e.bAll.q,
		instrument: \defaultPiano
	].pp
});
P(\thirds, music: { |p b e|
	[
		freq: "3 4 3 2 1 -7".df(\c).q,
		dur: b.parse([1, 1, 1, 1, 1, 2]).q
	].pp
});
P(\guitar, music: { |p b e|
	Song.guitar.setPlayMode(\strum );
	Song.guitar.setVoicingMode(\moveableLow);
	[
		[
			type: \strum,
			instance: p.guitar,
			freq: [ [11, 14, 16], [15,22], [14,15,17]].df(\c,4).q(2),
			dur: "qq qq qq qq qq qq qq ".asBeats.warpTo( e.tempoMap ).q,
			// dur: 10,
			legato:1,
			out: p.guitarFx.(),
		].p ,
		[
			type: \strum,
			out: p.guitarFx.(),
			instance: p.guitar,
			switch: [ \down, \muffleU, \d, \u, ].q(inf),
			amp: [0.01,0.5, 0.01, 0.2].q(inf),
			// lag: [0,0.1,0,0,0,0].q,
			legato:1,
			// dur: 10
			lag:Pwhite( 0.01,0.02,inf ) + [-0.005,0.005].q(inf),

			dur: "x*36".beats.warpTo( e.tempoMap.quantizeDft(0.5) ).q

			// lag:0.05
		].p
	] => Ppar(_) => _.play
});
["Bridge","11 7 6 ".dm(\e) ++ "5 2 4 3 -5 5 2 4 3 2 3 4".dm('f#') ++ "11 12 7 6 12 11 7 11".dm(\d,\mixolydian) ].addLine;
P(\guitar, music: { |p b e|
	Song.guitar.setPlayMode(\strum );
	Song.guitar.setVoicingMode(\moveableLow);
	[
		[
			type: \strum,
			instance: p.guitar,
			freq: [11, 13 ].df(\e,4),
			dur: "qq ".asBeats.warpTo( e.tempoMap ).q,
			// dur: 10,
			legato:1,
			out: p.guitarFx.(),
		].p ,
		[
			type: \strum,
			// out: p.guitarFx.(),
			instance: p.guitar,
			switch:  \down,
			amp: 0.3,
			// lag: [0,0.1,0,0,0,0].q,
			legato:1,
			// dur: 10
			// lag:Pwhite( 0.01,0.02,inf ) + [-0.005,0.005].q(inf),

			dur: "qq ".asBeats.warpTo( e.tempoMap ).q,

			// lag:0.05
		].p
	] => Ppar(_) => _.play
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
P.tune(_ <> [instrument: \wash, rest: [\r,\r,\r,1,1,1,1].q].p);
P.tune(\two, start:P.calcStart(),function: _ <> [instrument: \wash, rest: \r.dup(15) ++ [1, 1, 1, 1] =>_.q].p);
P(\beat, music: { |p b e|
	var s = \sn_808, k = \bd_808;
	[
		instrument: [\r] ++ [ k, s, k, k, s, k].dup(3).flat  => _.q,
		dur: "qq q q e e e e q q e e e e q q e e e e".asBeats.warpTo( e.tempoMap.quantizeDft(0.99) ).q
	].pp;
	(instrument: \cymbalsDS,amp:0.02, lag: "qq".asBeats.warpTo( e.tempoMap )).play
});
P(\wash, music: { |p b e|
	[
		midinote: p.tune[e.start],
		dur: b.q,
		rest: [\r,\r,\r,1,1,1,1, \r ,\r,\r,\r,\r,\r,\r,\r, 1, 1, 1, 1].q,
		instrument: \wash
	].pp
});
P(\bassPartTwo, music: { |p b e|
	[
		freq: [2.5, 2,[-1, 1 ], -4, -5, -1, -4, -5 ].df('c#', 4) ++ "1 5 4 2.5".df(\d, 3) =>_.q,

		// dur: b.parse([1,1, 3, 2, 3, 4, 3, 2]).q,
		dur:  "qe e   qq qe e qq qe e  qq qe e qq".asBeats.warpTo( e.tempoMap ).q,
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
["VerseB","-1 1 2 3 4 3 2 1 3 2 1 -7 1 2 -7 2 1 -5 5 5".dm(\c)].addLine;
Song.durs[\VerseB] = Song.durs[\Verse];
Song.setTempoMap(\VerseB,"q E E E e x e e xeee x x e x e e e e xE E E");
P(\offbeat, music: { |p b e|
	[
		freq: [\r, [1, 5, 11, 13] ].df(\c).q(inf),
		dur: "e*16".beats.warpTo(e.tempoMap).q,
		instrument:  \harp, 
		out: Effect.bus({|i|  },)
		// amp: [ 0.03,0.1 ]
		
	].pp
});
Song.guitar = AAS_Strum();

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
	Song.guitarFx = {Effect.bus({|i| i/2.5 => BPF.ar(_,900,8) },out:3)};
	Song.guitarFx = {Effect.bus({|i| i },out:3)};
P(\guitar, music: { |p b e|
	Song.guitar.setPlayMode(\strum );
	Song.guitar.setVoicingMode(\moveableLow);
	[
		[
			type: \strum,
			instance: p.guitar,
			freq: [ [3,1,5], [1, 14, 16], [5,21], [4,15,17]].df(\c,4).q(2),
			dur: "qq qq qq qq qq qq qq ".asBeats.warpTo( e.tempoMap.quantizeWindow(0.5)).q,
			// dur: 10,
			legato:1,
			out: p.guitarFx.(),
		].p ,
		[
			type: \strum,
			out: p.guitarFx.(),
			instance: p.guitar,
			switch: [ \down, \muffleU, \d, \u, ].q(inf),
			amp: [0.01,0.5].q(inf)  ,
			// lag: [0,0.1,0,0,0,0].q,
			legato:1,
			// dur: 10
			// lag:Pwhite( 0.01,0.02,inf ) + [-0.005,0.005].q(inf),

			dur: "x*48".beats.warpTo( e.tempoMap.quantizeWindow(0.5) ).q

			// lag:0.05
		].p
	] => Ppar(_) => _.play
});
P.tune(_<>[instrument:\defaultPiano].p);
P(\thirds, music: { |p b e|
	[
		freq: [\r, 3, 4, 5, 6, 5, 4, 3, 5 ].df(\c,4).q,
		dur: b.q, amp:0.03, pan: -0.25
	].pp
});
P(\click, music: { |p b e|
	[
		dur: "q*12".beats.warpTo( e.tempoMap ).q,
		instrument:\hihat
	].pp
});
["Ending", "2 1 5 4 3 2 1 5 4 3".dm(Song.root)].addLine;
Song.setTempoMap(\Ending,"e e e e eeee e e e e eeee");
P(\bassline, music: { |p b e|
	[
		freq: "2 1 5 4 3 -5".df(p.root,4).q(2),
		dur: "e e e e q q e e e e q q".asBeats.warpTo( e.tempoMap ).q,
		instrument: \sparkTriangle, depth:0
	].pp
});
P(\trip, music: { |p b e|
	[
		freq: [\r, 1, 2, 3].df(p.root).q(2),
		dur: "qqq E E E qqq E E E ".asBeats.warpTo( e.tempoMap ).q,
		legato: [1, 1, 1, 3, 1,  1, 1, 3, ].q,
		instrument: \harp, coef:0.3, amp: 0.03,
		out: 1
	].pp
});
)
