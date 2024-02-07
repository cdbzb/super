(
Song(\transporter,[]).current;
/* 	
Song.renderDirty; 
Song.refreshSynthV
.writeRawProject
*/

"~/tank/super/Trek/Songs/boilerplate.scd".standardizePath.load;

// Trek.cast.mccoy=\mo;
// Trek.presets.put(\mccoy,\mo,[paramGender:0.25]);
//  Trek.presets.put(\mccoy,\an, [
// 	vocalMode: \Power,
// 	paramGender: 0.15,
// 	paramToneShift: 150,
// 	paramTension: -0.1
// ]
// 	);
// Trek.cast.mccoy = \an;
Trek.presets.put(\mccoy,\jun,[ paramGender: 0.25, paramToneShift:150, paramTension: 0.1 ]);
Trek.cast.mccoy = \mo;
Song.synthVTracks = EventWithDefault(
	\default,{
		{|i|
			-10.dbamp * i
		}
	}, \an,{
		{|i|
			// 0.2 *CombN.ar(i,0.15,0.25) + i
			FreeVerb.ar(i,0.05,1)
			* -10.dbamp
			=> Pan2.ar(_)
		}
	}
);
[ "MCCOY: Jim, why no briefing on this? I'd at least like to kno-o-ow what we're getting into. ",[3,4,2,5,3,1, -7, -6, -7, 1, 2, 3, 4,5, 4, 3, 4, 5, 6, 6, -7].dm(\g) ].addLine;
Song.setTempoMap('kno-o-ow', "q e e  e e e ee x x E E E e x x   x x x x  ex x");
P.still(\wideShot, timecode: 642.8.seconds, music: { |p b e|
		 e.still.( 
			wait: b.sum,
			text: ["Jim, why no briefing","on this?"],
		).sequenceText2(
				b.parse([7,1,8,6]), [ 
				["",""],
				["I'd at least","like to know"],
				["what we're getting","in to"]
				],
		)
});
( SynthDef(\pluckGendy, {
	Pluck.ar( PinkNoise.ar(\amp.kr(0.1)), 1, 0.1, \freq.kr(400) * Gendy1.kr(minfreq:0.2,maxfreq:[5,10]).range(0.992,1.008) =>_.reciprocal, decaytime:\decay.kr(4))
	=> Out.ar(\out.kr(0),_)
}).add;
);
P(\chords, music: { |p b e|
	[
		freq: [1, 2, 3, 5, 1, -7, -6, [-2, 2, 6, 2, 4], [-7, 12, 14, 16] ].df(\g,3).q,
		instrument: \pluckGendy,
		dur: "q q q q q q q qex x".asBeats.warpTo( e.tempoMap ).q,
		out: (0..4).q(inf),
		strum: 0.06
	].pp
});
P.synthVs(role:\mccoy, take: [ \lead, \double ], params: [
		lyrics: "Jim why no briefing + on this I'd at least like to know - - what we're getting + into +",
		pitchTake:  [ 1,3 ],
		lag: [ [0.05] ++ ( 0!16 ) ],
		legato: [[0.5, 1, 1, 1, 1, 1, 0.7, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1]],
		paramTension: 0.9,
		vocalMode: \Open,
		filter: [12,12].collect{|i| (midinote: _ - i)}, 
	] 
	, music:[
		{|p b e|
			{
				e.playbuf
				=> p.synthVTracks.at(e.key).()
				=> Pan2.ar(_,1	)
			}.play
		}, {|p b e|
			{
				e.playbuf
				=> p.synthVTracks.at(e.key).()
				=> Pan2.ar(_,1)
			}.play
		}
	];
);
P(\keys,start:'kno-o-ow',music:{|p b e| 
		[
			dur: "q q q q q q q q ex x".asBeats.warpTo(e.tempoMap).q,
			freq:[3, 4, 5, 1, [ -17, -7 ], [-16, -6 ], [ -12, -22, -6, 2, 4 ], [ -11,-1 ], [-17, -7, 2,4,6 ], -7,6].df(\g, 4).q,
			legato:[1,1,1,1, 1, 1, 1, 1, [2,0,1,1,1.2],1,1].q * 0.8,
			att:0.01,
			amp:0.15,
			sus:0.5,
			dec:0.2,
			strum:[0,0,0,0,0,0,0.05,0,0.05].q(inf),
			lag:(-1)*[0,0,0,0,0,0,0.05,0,0.05].q(inf),
			instrument:\sawSynthAdsr,
			hiFreq:9000
		].pp;
		[
			instrument: \sparkTriangle,
			freq: [1, 2, 3].df(\g, 4).q,
			dur: "q q q".asBeats.warpTo( e.tempoMap ).q,
			out: 3,
			amp: 0.03
		].ppm

});
[ "KIRK: Easy, Bones. ","7 5 3".dm(\c,5,\mixolydian)].addLine;
P.still(\wideTwo, timecode: 647.seconds, music: { |p b e|
		 e.still.( 
			wait: b.sum + e.bNext.sum,
			text: ["easy","bones"],
		).sequenceText2(
				b.parse([3]) ++ [1], [ 
					["",""]
				],
		)
});
P.synthVs(role: \kirk, take: [\lead, \double], params: {|p b| [
		lyrics: "Easy + Bones",
		legato: [[1, 1, 0.85, ]],
		pitchTake: [1, 3]
	] }, music:{|p b e|
		{
			e.playbuf
			=> {|i| DelayN.ar(i, 0.3,0.25) *0.3 +i}
			=> p.synthVTracks.at(e.key).()
			=> Pan2.ar(_,0)
		}.play
});
P('answer',start:\Easy,music: {|p b e|
		[
			freq:[1.5,-6.5,-3].df.q,
			dur:RecOnsets('answer','Easy')
			//.arm
			.play.q
		]//.p//p
});
P('wash',start:\Easy,music: {|p b e|
		[
			freq: [[5,7]].df(\c,[4,5],\mixolydian).q,
			dur: b.sum,
			att:b.sum,
			amp:0.02,
			instrument:\reedy,
			sustain:0,
			release:3
		].pp
});
["As long as you know there's somethi--ng down there, you know as much as we do."," 1 2 3 3 2  -5 -6 -7 1 2 1 -4 4 3 2 1 -7 2 1".dm(\c) ].addLine;
Song.setTempoMap('down there',"e e e eee ee e e x x eee e ee ee eee x xe e eee");
P.still(\clear, timecode: 0.seconds, music: { |p b e|
	 e.still.( 
		wait: b.sum,
		text: ["as long as","you know"],
	).sequenceText2(
			b.parse([5,6,1, 6]), [ 
			["there's something","down there"],
			["",""],
			["you know","as much as we do"]
			],
	)
});
P.synthVs(role: \kirk, take: [ \lead, \double ], params:  [
		lyrics: "As long as you know there's something + - down there, r you know as much as we do.",
		legato: [ [1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 0.6, ] ],

		pitchTake: [ 1, 3 ]
	] , music:[ {|p b e|
		{
			e.playbuf
			=> {|i| DelayN.ar(i, 0.3,0.25) *0.2 +i}
			=> p.synthVTracks.at(e.key).()
			=> Pan2.ar(_,0)
		}.play
	}]
);
P(\guitarTwo, music: { |p b e|
	var durs = "eee eee ee eee eee e ee ee eeeeee e e e".asBeats.warpTo( e.tempoMap );
	MegaBind(

		[
			[\r, 4, 3, \r, 2,  2,  \r, 4, 4, 4, 6.5, 3, 4],
			[\r, 1, 1, \r, -6, -6, -6.5, 2, 1, -6, \r,\_,\_],
		]
		.df(\g,4)
		,
		durs,
		[],
	{|i| Pluck.ar(
		ClipNoise.ar(0.2),
		trig: TDuty.kr(
			durs
			.dq,
			reset:0.0,
			level:[1, 1, 0, 1, 1, 0, 1, 1, 1].dq,
			doneAction:0,
			gapFirst:1
		),
		delaytime:i.freqSeq.reciprocal.demand(durs) *  Gendy1.kr(minfreq: 0.3, maxfreq: 3).range(0.995,1.005),
		decaytime: 5
	)
		* Env.asr(0.5).kr(0,gate:i.gateSeq )
},
		{|i|  Mix.ar(i)
		=> CrossoverDistortion.ar(_, amp:0.5, smooth:0.1) /40
		=> Phaser2.ar(_, rate: 0.2)
		=> Out.ar(2,_);
		EnvGen.cutoff(b.sum,0.5)
	}
	).play
});
P('wash',start:\somethi,music: {|p b e|
		[
			freq: [\r,[11, 13],[7.5, 12],\r,3,\r,\r,[6,11],5].df(\c,4,\mixolydian).q,
			dur: b.parse([3,1,1,4, 1,1,1, 1,1]).q,
			legato:[1,1,1,1,1,1,1,[1,2]].q(2),
	//		att:b.sum,
			amp:0.02,
			//instrument:\wash,
			instrument:\pulse, amp:0.1,
	//		sustain:0,
			release:3,
			// out: 3
		].pp
});
P(\xtra_notes,start:'down there',syl:11,music:{|p b e| 
		[
			freq: [-6, 1, -11, -4, -7, 1].df(\c).q,
			legato: [1, 1/3, 3,2,1,1].q,
			dur: b.drop(1).parse([1,4, 1/3, 1/3, [1/3],1]).q,
			instrument: \sawSynthSustain,
			amp: 0.08
			// pulse: 0.5
		].pp;//ma;
		[
			instrument: \harp,
			freq: [-6, 1, -11, -4, -7, 1, [-11.5, -21.5, -6.5]].df(\c).q,
			// legato: [1, 1/3, 3,2,1,1].q,
			dur: e.bAll.drop(1).parse([1,4, 1/3, 1/3, [1/3],2, 4]).q,
			coef: 0.15,
			strum: [0, 0, 0, 0, 0, 0, 0.05].q,
			amp: 0.02, out:3
		].pp
});
P(\bass,start:'down there',music:{|p b e| 
		[
			freq: [\r, -5, 5, -5, \r, -6, 6, 5, 4, -4, -4.5, -5, 5, -7, 1].df(\c,3).q,
			dur: "eee q q q q q e e q qe e q e e q  ".asBeats.warpTo(e.tempoMap).q,
			instrument:\sawSynthSustain,
			legato:[0.9!14,2].flat.q,
			rel: 0.9
		].pp;
});
P(\click,start:'down there',music:{|p b e| 
		[
			dur: ([ 1.5 ] ++ 1.dup(12) =>_.warpTo(e.tempoMap)) =>_.q,
			freq: 
			[ \r  ]++ 1.dup(12) => _.flat
			=> _.q,
			instrument: \hat_808
		].pp;
});
	// P.tune('down there', Pset(\dev, [1,1,1,1,1,1,1,1,1,1,1,\r].q(2),_));
["The rest is only guesses. ","5 11 5 3 5 7 11".dm('c#',4,\harmonicMinor) ].addLine;
P(\chord,syl:0, music: { |p b e|
	{
		var freq = [3, 5, 11].df('c#',[3,5],\minor);
		Gendy1.ar(
			ampdist:0.5,
			durdist:1,
			adparam:1.0,
			ddparam:1.0,
			minfreq:freq* 0.99,
			maxfreq:freq*1.01,
			ampscale:0.5,
			durscale:0.5,
			initCPs:2,
			knum:nil,
			a:1.17,
			c:[0.31, 0.2, 0.11],
			mul:1.0,
			add:0.0
		)
		* [1, 0.03]
		* Env.perc(0.2,b.sum).kr(2,gate:1)
		=> DelayN.ar(_, 0.1, [0, 0.08, 0.037])
		/30

	}.play
});
P.still(\clear, timecode: 0.seconds, music: { |p b e|
	 e.still.( 
		wait: b.sum,
		text: ["the rest is","only guesses"],
	)
});
P.tune(\rest, {|i| Pmul(\freq, 4, i) <> [instrument: \stringyy, out: 4, amp: 0.1].pm} );
P.synthVs(role: \kirk, take: [ \lead, \double ], params: [
		lyrics: "the rest is only + guesses +",
		pitchTake: [ 1, 3 ]
	] , music:[ {|p b e|
		{
			e.playbuf
			=> {|i| DelayN.ar(i, 0.3,0.3) * 0.2 +i}
			=> p.synthVTracks.at(e.key).()
			=> Pan2.ar(_)
		}.play
	} ]);
P(\bass,start:\guesses,music:{|p b e| 
		MegaBind(
			[
				[5,-1].df('c#',4),
				[5,1].df('c#',4)
			],
			b.parse([1,6]),
			[],
			{|i|
				Saw.ar( i.freqSeq + ChaosGen.subclasses.choose.ar(2).wrap(1) )
				*(
					 Env.asr(1).kr(gate:i.gateSeq)
				)
					* 0.08
				
					=> MoogFF.ar(_, XLine.kr(6000,300,b[1..6].sum*[2,1.5]))
			},
			{|i|
				Splay.ar(i)
				=> DWGReverbC1C3.ar(_,500,mix:0.15)
			}
		)//.play
		;
		[
			freq:[-15,[-21]].df('c#').q,
			dur:b.parse([1,6]).q,
			instrument:\sawSynthSustain
		].pp;
});
	Trek.cast.scott=\an;
[ "SCOTT: I don't like it, sir. The trans-- ","1 -7 3 1 -5".dm(\c,5,\mixolydian)++" 1 -7 ".dm(\d,5,\mixolydian) ].addLine;
P(\cymbal,syl:1, music: { |p b e|
	(instrument: \cymbalsDS, amp: 0.01, att:0.03).play
});
P.still(\mediumScott, timecode: 651.470.seconds, music: { |p b e|
		 e.still.( 
			wait: b.sum + e.bNext.sum,
			fade: p.secDur[e.start + 2],
			text: ["I don't like it sir",""],
		).sequenceText2(
				e.bAll.parse([5, 12]), [ 
				["the transporter coordinates","preset by an"],
				["",""]
				],
		)
});
P.synthVs(role: \scott, take: [\lead, \double],
		pbind: Song.enlarge(6),
		tension:1,
		vocalMode: \Power,
		params: {|p b| [
		lyrics: " I don't like it, sir. The transporter + + coordinates + + + ",
		legato: [ [1, 1, 1, 1, 0.6, 1, 1, 1, 1, 1, 1, 1, 0.8, ] ],
		pitchTake: [1, 3]
	] }, music:{|p b e|
		{
			e.playbuf
			=> p.synthVTracks.at(e.key).()
		}.play
});
P(\zzz
		,start:\pointqa,music:{|p b e| 
		1
});
P(\spazzPad,start:'like it',music:{|p b e| 
		MegaBind(
			
				[
					\r,
					[5,7,1,3].df(\c,4,\mixolydian), 
					[-5,-6.5,1,3].df(\d),\r,
					[-7,2,4,5].df(\d,5), \r, 
					[1,5,11,13].df(\e,4),
					[-5,5,12,13].df(\c,4,\minor),
					[1,1.5, 5, 11, 15].df(\b,4)
				].flop
			,
			b.parse([2,5]) 
			++ p.durs[e.next].list.parse([5,2,3]) 
			++ p.durs[e.start+2].list.parse([2, 3, 3] 
			++ ( p.durs[e.start+3].list.sum + 1 )) => _.flat 
			+ [0,0,0.5,-0.5,0,0,0,0]
			,
			[],
			{|i|
				var a = Saw.ar( i.freqSeq * [1,2,3, 4, 8]=>_.lag([0,0,0.8,0,0,0,0,0.5,0.5].dq.demand( i.dur )) )
				* (
					Env.asr(0.2).kr(gate:i.gateSeq)
					* 0.1
					/3
				);
				a => Convolution.ar(_, Dust.ar(36)=> Decay.ar(_,0.1) * WhiteNoise.ar(0.1) =>FreeVerb.ar(_,0.6,1))
				+ ( a/8 )
			}	,
			{
				|i| i
				=> Splay.ar(_)
				=> {|i| EchoNone.ar(i,0.3,0.3,3) + i * -3.dbamp}
			}
		).play
		
		
});
[ "porter co-ordinates preset by an","3 1 -6.5 -5 -5.5 -5 -7 4 3 4".dm(\d)].addLine;
P(\crash, music: { |p b e|
	(
		instrument: \cymbalsDS,
		out: Effect.bus({|i| i => FreqShift.ar(_, freq:-399, phase:0.0, mul:1.0, add:0.0) / 10 },out: 1)
	).play
});
P.synthV(role: \scott, take:\lead, params: {|p b| [
		lyrics: "r r r r r r preset + by an",
		pitchTake: 1,
		paramTension:1,
		vocalMode: \Power
	] }, music:{|p b e|
		{
			e.playbuf
			=> p.synthVTracks.at(e.key).()
		}.play
});
P.double(role: \scott, params: {|p b| [
			
		] }, music:{|p b e|
			{
				e.playbuf
				=> p.synthVTracks.at(e.key).()
			}.play
		});
P(\bass,start:'ordinates',syl:6,music:{|p b e| 
		
		[
			freq:[1,-5, -5].df(\a,[3,4]).q,
			instrument:\sawSynth,
			att: [1,0.1,0.1].q,
			dur: b.drop(1).sum.bubble ++ p.durs[e.next].list.parse([1,1]) => _.flat => _.q
		].pp
});
["(boom boom) alien of some sort. ","-1 -1 3 2 1".dm(\e) ++ "3 2 -5".dm(\c,5,\minor)].addLine;
P(\boomboom, music: { |p b e|
	var k = \bd_808;
	var sn = \sn_808;
	[
		instrument: [k, k, sn].q,
		dur: b[..2].q,
		amp: 0.2,
		out: [0, 0, Effect.bus({|i| CombN.ar(i)/3 + i },)].q
	].pp
});
P.still(\clear, timecode: 0.seconds, music: { |p b e|
	 e.still.( 
		wait: b.sum,
		text: ["",""],
	).sequenceText2(
			b.parse([2]), [ 
			["alien","of some sort"],
			],
	)
});
P.synthV(role: \scott, take:\lead, params: {|p b| [
		lyrics: "r r alien + + of some sort",
		pitchTake: 1,
		legato: [1, 1, 1, 1, 0.7, 1, 1, 1, ],
		paramTension:1,
		vocalMode: \Power
	] }, music:{|p b e|
		{
			e.playbuf
			=> p.synthVTracks.at(e.key).()
		}.play
});
P.double(role: \scott, params: {|p b| [
			
		] }, music:{|p b e|
			{
				e.playbuf
				=> p.synthVTracks.at(e.key).()
			}.play
		});
P(\bass,start:'some sort',music:{|p b e| 
		var t;
		MegaBind(
			[[ 1, 1, -3, -5, -4.5 ].df(\e,3,\whole) ],
			t = b.parse([1,1,[1,1,0.5],[0.5,1,1,1]]++p.durs[e.next].list.sum),
			[
				rel:{ [0.3,  0.3,  1,    1,    3].dq.demand(t) },
				att:{ [0.02, 0.02, 0.05, 0.05, 0.5].dq.demand(t) },
				amp:{ [0.07,    0.09,    0.1,    0.1,    0.08].dq.demand(t) }
			],
			{|i|

				//[lag:{[0,b[3]+0.1].dq.demand(i.dur)}],
				Saw.ar( i.freqSeq / [1,2] + ChaosGen.subclasses.choose.ar(12).range(0,1!3) )
				=>RLPF.ar(_,5000)
				* (
				EnvGen.kr(Env([0,1,0.7,0],[i.att,1.5,i.rel]),gate:(i.gateSeq*i.trigSeq))
					* i.amp
				)
			}

		).play
});
		
["(boom) You could materiali--se inside ","-1 4 3 2 4 3 2 1.5 2 ".dm(\b,4) ].addLine;
P.still(\clear, timecode: 0.seconds, music: { |p b e|
	 e.still.( 
		wait: b.sum,
		text: ["",""],
	).sequenceText2(
			b.parse([1]), [ 
			["you could materialise","inside"],
			],
	)
});
P.synthV(role: \scott, take:\lead, params: {|p b| [
	filter: (
		dur: _.parse([1,1,1,1,1,0.5,0.5,1,1,1]),
		midinote: {|i| i[0..4] ++ i[5].dup ++ i[6..] => _.flat}
	), 
		lyrics: "r You could material + + + eyes inside + ",
		legato: [1, 1, 1, 1, 1, 1, 1, 0.8, 1, 1, ],
		pitchTake: 1,
		vocalMode: \Power,
		paramTension:1
	]}, music:{|p b e|
		{
			e.playbuf
			=> p.synthVTracks.at(e.key).()
		}.play
});
P.double(role: \scott, params: {|p b| [

		]}, music:{|p b e|
			{
				e.playbuf
				=> p.synthVTracks.at(e.key).()
			}.play
		});
P(\bass,start:\material,music:{|p b e| 
		{
			VarSaw.ar(1.df(\b,[3,4]))
			* Line.kr(0.1,0,b.sum)
		}.play
});
		
	// ["solid rock. ",[7, 6, 6, 11, 7, 7].dm(\c) ].addLine;
// P.tune('rock.');
	// Song.setTempoMap('rock.', "qe e qq qe e qq");
// in hook Bones-Scotty.RPP
P(\chords,start:'rock.',music:{|p b e| 
		[
			freq: 
			[[1, 3, 5, 7],[1, 3,5, 6],[1, 3, 5, 6]].df(\c).q
			++[[1, 3, 5, 7],[1, 3,5, 6],[1, 3, 5, 6]].df(\d,5,\mixolydian).q
			,
			dur: "q ex xqq".asBeats.warpTo(e.tempoMap).dup.flatten.q,
		].pp
		
});
P(\bass,start:'rock.',music:{|p b e| 
		[
			freq: [[1, 11],[1,11],11, -7,1,-7,1, 5,6] => {|i| [ i.df(\c,3).q, i.df(\d,3,scale:\mixolydian).q ].q},
			dur: 
			"e ee e x x x x e e".asBeats.dup.flat.warpTo(Song.tempoMap['rock.']) => _.q,
			instrument:\sawSynth

			//.warpTo(e.tempoMap).q
		].pp
});
["(boom boom) solid rock2. ",[1,1, 7, 6, 7, 11 ].dm(\f) ].addLine;
P.still(\clear, timecode: 0.seconds, music: { |p b e|
	 e.still.( 
		wait: b.sum,
		text: ["",""],
	).sequenceText2(
			b.parse([2]), [ 
			["solid","rock"],
			],
	)
});
P.tune(\rock2);
	Song.setTempoMap(\rock2,"q q q e e qqqq");
P(\chord,start:\rock2,syl:1,music:{|p b e| 
		[
			freq: [ [1,3,5,7],[2,4.5,6,11.5] ].df(\f,[4,5]).q,
		instrument: \wash,
		dur: [b.drop(1).sum, e.bNext.sum].q
	].p.play;
});
		
P(\bass,start:'rock2.',music:{|p b e| 
		[
			freq: [[1, 11],[1,11],11, -7,1,-7,1, 5,6].df(\f,[2,3]).q,
			dur: 
			//[0, 0.03,-0.03,0,0,0,0,0,0] +
			//"q qq q e e e e q q".asBeats.flat.warpTo(e.tempoMap.quantize(0.4)) => _.q,
			
			//recorded!!
			[ 0.536, 0.805, 0.767, 0.22, 0.301, 0.239, 0.302, 0.556, 0.558, 2.157 ]
			//=> _.remap("q qe eq e e e e e e q q".asBeats,"e e e e e e e e".asBeats)
			=> _.warpRecordedTo(e.tempoMap)
			=>_.q,
			// instrument:\sawSynth,
			instrument: \pluckD,
			amp:[1,1,0.7,1,1,0.9,1,0.9,1,1].q/12
			/3

			//.warpTo(e.tempoMap).q
	].pm.play
});
P(\chord,start:\rock2,music:{|p b e| 
		[
			freq: [1,3,5,7].df(\f),
			//dur: "qq qe eq q q qe".asBeats.warpTo(e.tempoMap).q,
			dur:[ 0.536, 0.805, 0.767, 0.22, 0.301, 0.239, 0.302, 0.556, 0.5587 ]
			=> _.remap("q qe eq e e e e  q q".asBeats,"qq qe e|qq qe e".asBeats) + [0,0,0,-0.07,0] => _.warpTo(e.tempomap) => _.q,
			//dur:"e e e e e e e e e e e e e e e e e e ".asBeats.warpTo(e.tempoMap).q,
			amp: [0.01] ++ (0.1!22) => _.flat =>_.q,
			instrument:\pulse
		].pp
});
	
P(\drums, music: { |p b e|
	var k = \bd_808, sn = \sn_808;
	[
		instrument: [k,k,sn].q(4),
		dur: "q q qq q q qq q q q q".asBeats.warpTo( e.tempoMap ).q,
		amp:0.15
	].pp
});
P(\crashing,start:'rock2',music:{|p b e| 
		//(instrument:\cymbalsDS).play
{ //Dan Stowall Cymbals
		var lodriver, locutoffenv, hidriver, hicutoffenv, freqs, res, thwack;
		locutoffenv = EnvGen.ar(Env.perc(0.5, 5)) * 20000 + 10;
		lodriver = LPF.ar(WhiteNoise.ar(0.1), locutoffenv);
		hicutoffenv = (EnvGen.ar(Env.perc(1, 3))).range(10000,1);
		hidriver = HPF.ar(WhiteNoise.ar(0.1), hicutoffenv)
		* EnvGen.ar(Env.perc(1, 1, 0.25));
		thwack = EnvGen.ar(Env.perc(\att.kr(0.001),0.0001,1), TDuty.ar(
		"q q q q q q q q q q q ".asBeats .warpTo( p.tempoMap[\rock2]).quantize 
		. dq
	));
		freqs  = {ExpRand(300, 20000)}.dup(30);
		res	= Ringz.ar(lodriver + hidriver + thwack, freqs).mean;
		((res * 1) + (lodriver * 2) + thwack).dup * 0.01
		* Env.linen(0,1,b.sum).kr(2,gate:1)
		=>  Out.ar(0,_)
	}.play
});
P.synthV(role: \scott, take: \lead, params: {|p b| [
		lyrics: "r r solid + rock -",
		pitchTake: 1
	] }, music:{|p b e|
		{
			e.playbuf
			=> p.synthVTracks.at(e.key).()
		}.play
});
P.synthV(\ninezero, take: \harm,
			filter: (midinote: [1, 1, 5, 5, 3].dm(\f)), 
			params: {|p b| [
			lyrics: "r r solid + rock -",
			pitchTake: 1,
			vocalMode: \Muted
		] }, music:{|p b e|
			{
				e.playbuf
				=> p.synthVTracks.at(e.key).()
			}.play
});
P.double(\ninezero, take: \harm, params: {|p b| [
	
] }, music:{|p b e|
	{
		e.playbuf
		=> p.synthVTracks.at(e.key).()
	}.play
});
P.synthV(\kevin, take: \harm, params: {|p b| [
	lyrics: "r r solid + rock -",
	filter: (midinote: _ - 12), 
	pitchTake: 1
] }, music:{|p b e|
	{
		e.playbuf
		=> p.synthVTracks.at(e.key).()
	}.play
});
P.double(\kevin, take: \harm, params: {|p b| [
	
] }, music:{|p b e|
	{
		e.playbuf
		=> p.synthVTracks.at(e.key).()
	}.play
});
[ "MCCOY: Inside solid rock? "," 1 1 7 5 13".dm(\g) ].addLine;
P.still(\clear, timecode: 0.seconds, music: { |p b e|
	 e.still.( 
		wait: b.sum,
		text: ["Inside","solid rock?"],
	)
});
P(\bass,music:{|p b e| 
		[
			freq: [[1, 11],[1,11]].df(\g,[2,3]).q,
			dur: 
			//[0, 0.03,-0.03,0,0,0,0,0,0] +
			//"q qq q e e e e q q".asBeats.flat.warpTo(e.tempoMap.quantize(0.4)) => _.q,
			
			//recorded!!
			// [ 0.536, 0.805,  ]
			//=> _.remap("q qe eq e e e e e e q q".asBeats,"e e e e e e e e".asBeats)
			// => _.warpRecordedTo(e.tempoMap)
			// =>_.q,
			b.parse([1, 4]).q,
			// instrument:\sawSynth,
			instrument: \pluckD,
			amp:[1,1,0.7,1,1,0.9,1,0.9,1,1].q/12
			/3

			//.warpTo(e.tempoMap).q
		].pm.play
});
P.synthV(role: \mccoy, take: \lead,pbind:{|p b|
	[
		midinote: [3, 4, 7 , 5, 13].dm(\g).q,
		dur: b
	].p
}, params: {|p b| [
		lyrics: "inside + solid + rock",
		legato: [1, 1, 1, 1, 0.8, ],
		vocalMode: \Open,
		tension: Env([0,1],b.sum),
		filter: (midinote: _ - 12), 
		pitchTake: 1
	] }, music:{|p b e|
		{
			e.playbuf
			=> p.synthVTracks.at(e.key).()
		}.play
});
[ "SPOCK: Unlikely. These co-ordinates correspond with the location of the","5 11 5  7 5 4 3 2 6 4 3 2 1 -7 4 2 -6 -5".dm('c#')].addLine;
Song.setTempoMap(\correspond,"e e e XX X X X XXX X X X X X X e e e e".asBeats * 2);
P.still(\mediumSpock, timecode: 707.733.seconds, music: { |p b e|
		 e.still.( 
			wait: b.sum,
			text: ["Unlikely",""],
		).sequenceText2(
				b.parse([3, 5, 5,]), [ 
				["these","coordinates"],
				["correspond to","the"],
				["location","of the"]
				],
		)
});
P.synthVs(role: \spock, take: [\lead, \dbl], params: {|p b| [
		lyrics: "Unlikely + + These co-ordinates + + + correspond + + with the location + + of the",
		filter: [ (midinote: _ - 12), (midinote: _) ], 
		legato: [[1, 1, 0.5, 1, 1, 1, 1, 0.8, 1, 1, 1, 1, 1, 1, 1, 1, 1, 0.7, ]],
		vocalMode: \Rough,
		pitchTake: [1, 3]
	] }, music:[0.5,0.5].collect{|pan| {|p b e|
		{
			e.playbuf
			=> p.synthVTracks.at(e.key).()
			=> Pan2.ar(_,pan)
		}.play
	} });
P(\bass,start:\correspond,syl:0,music:{|p b e| 
		[
			dur: [ 1.052, 2.037, 1.895, 2.101 ]
			//.warpRecordedTo(e.tempoMap)
			.q,
			freq: 1.df('c#',3) ,
			amp:1,
			out: Effect( { |i| SineShaper.ar(i,0.1) => FreeVerb.ar(i,0.01,1)} ).bus.index
		].pp
});
P(\chords, music: { |p b e|
	[
		freq:[
			\r,
			[3, 5, 7],
			[2, 5, 7],
			[2, 4, 6],
			[1, 4, 6],
			[-7, 4, 6],
			[-7, 3, 5],
		].df('c#').q,
		dur: b.drop(1).parse([3, 5,1,  4,1, 1, 4]).q,
		instrument: \visual_pad, amp: 0.25,
		out: 2

	].ppm
});
P(\line,start:\correspond,music:{|p b e| 
		[
			freq: [\r, 1, 7, 6, 5].df('c#',3).q,
			dur: b.parse([1,2,5,6,4,]).q,
			instrument:\sawSynthSustain,
			att: 1,
			legato: [4,4,1,1,1].q,
			rel: 1,
			amp: [0, 10, 6, 6, 6].q/100,

		].pp;
});
[" (boom) subterranean chamber. ", "-1 1 2 3 4 3 2 1".dm(\d,5,\minor) ].addLine;
P.still(\clear, timecode: 0.seconds, music: { |p b e|
	 e.still.( 
		wait: b.sum,
		text: ["subterranean","chamber"],
	)									
});
Song.setTempoMap(\subter,"q e e Q Q Q q q");
P.synthV(role: \spock, take:\lead, params: {|p b| [
		lyrics: "r subterranean + + + + chamber +",
		pitchTake: 1,
		vocalMode: \Soft
	] }, music:{|p b e|
		{
			e.playbuf
			=> p.synthVTracks.at(e.key).()
		}.play
});
P.double(role: \spock, params: {|p b| [
			
		] }, music:{|p b e|
			{
				e.playbuf
				=> p.synthVTracks.at(e.key).()
				=> Pan2.ar(_,1)
			}.play
		});
P.tune(\subterranean);
P(\figure, music: { |p b e|
	[
		freq: [-5, 1, 4, 1, 4, 1].df(\d).q,
		dur: "q q q q q q".asBeats.warpTo( e.tempoMap ).q,
		instrument: \harp,
		amp: 0.04,
		out: Effect.bus({|i| CrossoverDistortion.ar(i) /50 => RHPF.ar(_, 300, 0.2) * EnvGen.cutoff(b.sum, 0.1)}, out: 2)
	].pp;
	[
		freq: [[-7, 2],[1, 3]].df(\g,3,\mixolydian).q,
		dur: "qqqq qq".asBeats.warpTo( e.tempoMap ).q,
		out: Effect.bus({|i| CrossoverDistortion.ar(i) /50 => RHPF.ar(_, 300, 0.2) * EnvGen.cutoff(b.sum - 1,1) }, out: 2)
	].pp;
	[
		freq: [[-7, 2],[1, 3]].df(\g,3,\mixolydian).q,
		dur: "qqqq qq".asBeats.warpTo( e.tempoMap ).q,
		out: Effect.bus({|i| Phaser1.ar(i,rate: 0.2) => HPF.ar(_, 175) }, 1)
		// out: Effect.bus({|i| CrossoverDistortion.ar(i) /50 => RHPF.ar(_, 300, 0.2) }, out: 2)
	].pp
});
P(\bassnotes,start:\subterranean,music:{|p b e| 
		[
			instrument:\stringyy,
			freq: [ [-1,1],[-14,4] ].df(\d).q,
			dur: b.parse([6,2]).q
		].pp	
});
P(\bassConnector, music: { |p b e|
	[
		freq: [\r, 4, 2, 3, 4, 6].df(\d,4,\minor).q,
		dur: b.parse([6, 2]) ++ e.bNext.parse([1, 1, 1, 3]) =>_.q,
		out:Effect.bus({|i| i * 3 => SineShaper.ar(_,0.1) },inputChannels:2),
		instrument: \default
	]//.ppm
});
[ "KIRK: I have a feeling that they or it could destroy us just standing here if they or it wanted to. ","3.5 4 5 7 6 5".dm(\g,5,\minor,transpose: 7) ++ "3 1 2 -7 1 4 3 1 6 5 3 1 3 1 2 1 -7 -5".dm('e-',6,transpose: 7) ].addLine;
P(\chords, music: { |p b e|
	[
		freq: [3, 1].df(\g,4).q,
		dur: b.parse([3, 3]).q,
		instrument: \stringyy,
		release: 1,
		freqLag: 0.5,
		amp: 0.3
	].ppm
});
P.still(\twoShotKirk, timecode: 709.745.seconds, music: { |p b e|
		 e.still.( 
			wait: b.sum,
			text: ["I have a","feeling that"],
		).sequenceText2(
				b.parse([6, 3, 4, 4, 4]), [ 
				["they","or it"],
				["could","destroy us"],
				["just","standing here"],
				["if they","or it"],
				["wanted","to"]
				],
		)
});
P(\theyChords, music: { |p b e|
		[
			freq: [/*[-6,-6,4]*/ \r,[-5, 1, 3], [-5, -7, 2], [-6, 1, 4],[-6,1, 3 ],[1,3,6],[1,3, 5 ],[-5, 1, 3], [-5,1, 2 ], [1,2,5],[ -7, 2, 5 ]].df('e-').q,
			// legato: [1, 1, [2,2,1],1,[2,2,1],1,[2,2,1],1,[2,2,1],1, ].q,
			dur: b.parse([6,2, 3, 1, 2, 1, 3, 2, 1, 1, 2]).q,
			amp:0.05, instrument: \sawSynthSustain, pulse:0.50
		].ppm
});
P.synthV(role: \kirk, take: \lead, params: {|p b| [
		lyrics: "I have a feeling + that they or it could destroy + us just standing + here if they or it wanted + to. ",
		filter: (midinote: _ - 12), 
		legato: [1, 1, 1, 1, 0.8, 0.8, 0.8, 1, 0.8, 1, 1, 1, 1, 1, 1, 1, 1, 1, 0.8, 1, 0.8, 1, 1, 1, ],
		pitchTake: 1
	] }, music:{|p b e|
		{
			e.playbuf
			=> p.synthVTracks.at(e.key).()
			=> Pan2.ar(_,-0.5)
		}.play
});
// P.tune(\feeling);
P(\bass,start:\feeling,syl:5,music:{|p b e| 
		[
			freq: [11, 5, 6, 4, 5, -5].df('e-',[3,4]).q,
			dur: b.drop(1).parse([2,3,3,4,3,3]).q
		].pp;
});
[ "MULHALL: They or it? "," 3 1 5.5".dm(\c) ].addLine;
P.still(\revealMul, timecode: 719.294.seconds, music: { |p b e|
		 e.still.( 
			wait: b.sum,
			text: ["they","or it?"],
		)
});
	/* P.still(\turnedHeads, timecode: 719.693.seconds, music: { |p b e|
		 e.still.( 
			wait: b.sum,
			text: ["",""],
		)
}); */
P.synthV(role: \mulhall, take: \lead, params: {|p b| [
		lyrics: "they or it",
		legato: [0.8, 1, 0.5, ],
		pitchTake: 1
	] }, music:{|p b e|
		{
			e.playbuf
			=> p.synthVTracks.at(e.key).()
			=> EarlyRef.ar(_, [3,0,0],[0,0,0],[3.5,4,5])
			* 4.dbamp

			
		}.play
});
	Song.mulhallTune=Pbindf(_,\amp,0.08,\out,Effect(EchoNone.ar(_,0.3,0.3,4)*0.5).bus.index);
P.tune('it?',Song.mulhallTune);

P(\pad, music: { |p b e|
	(
		instrument:\stringyy,wet:0,
		dur: b.sum,
		midinote: p.tune[e.start].list.postln,
		out: Effect.bus({|i| i=> BPF.ar(_, XLine.kr(1000,300, b.sum + 3), 0.2,mul:8.dbamp) },)
	).play
});
[ "KIRK: Who are you? (boom) ","3 1 7 -6".dm(\f,5,\mixolydian) ].addLine;
P(\pad, music: { |p b e|
	(
		instrument:\stringyy,wet:0,
		dur: b.sum,
		midinote: p.tune[e.start].list[0..2],
		out: Effect.bus({|i| i
			=> BPF.ar(_, XLine.kr(1000,300, b.sum), 0.2, mul:8.dbamp)
			=> Pan2.ar(_,1)
		},)
	).play
});
/* P.still(\mulhallFace, timecode: 720.756.seconds, music: { |p b e|
	 e.still.( 
		wait: b.parse([3]).sum,
		// wait: b.sum,
		fade: b[3] ,
		text: ["who","are you?"],
	)
}); */
	/* P.still(\kirk, timecode: 725.255.seconds, music: { |p b e|
		 e.still.( 
			wait: b.sum,
			text: ["",""],
		)
}); */
P.still(\clear, timecode: 0.seconds, music: { |p b e|
		 e.still.( 
			wait: b.sum,
			text: ["who","are you?"],
		)
});
P.synthV(role: \kirk, take: \lead, params: {|p b| [
		lyrics: "who are you r",
		filter: (midinote: _ - 12), 
		legato: [0.8, 1, 0.5, ],
		pitchTake: 1
	] }, music:{|p b e|
		{
			e.playbuf
			=> p.synthVTracks.at(e.key).()
			=> Pan2.ar(_,-0.5)
			// => EarlyRef.ar(_, [0,0,0],[3,0,0],[3.5,4,5])
		}.play
});
P.tune('you?', Pfin(3,_));
P(\chord,start:'you?',syl:2,music:{|p b e| 
		[\stringyy,\sawSynthSustain].do
		{ |i| (
			(
				freq: [1,3,5,11].df(\d,[3,4,5]),
				instrument:i,
				dur: b+p.durs[e.start+1].list[0..5].sum,
				att: 6,
				amp:0.05,
				rel:8
			).play
		) } 
});
/* P.still(\walking,syl:2, timecode: 729.444.seconds, music: { |p b e|
	 e.still.( 
		wait: b.sum,
		text: ["",""],
	)
}); */

P.still(\mulhallFace,syl:2, timecode: 720.756.seconds, music: { |p b e|
	 e.still.( 
		// wait: b.parse([3]).sum,
		// wait: b.sum,
		wait: b.drop(1)[0] + e.bNext.sum,
		fade: b.drop(1)[0] ,
		text: ["",""],
	).sequenceText2(
			b.drop(1).sum.bubble ++ e.bNext.sum, [ 
			["Doctor Ann Mulhall,","astro-biology"],
			["",""]
			],
	)
});
[ "MULHALL: Doctor Ann Mulhall, Astro-biology.",[7, 11, 3, 5, 4.5, 6, 6.5, 2, 4, 3, -5].dm(\d,6  , /* tuning:\sept1 */) ].addLine;
/* P.still(\overTheShoulder, timecode: 
	734.830.seconds //over The Shoulder
	// 720.65.seconds // face
	, music: { |p b e|
		 e.still.( 
			wait: b.sum,
			text: ["Doctor Ann Mulhall","astro-biology"],
		)
});s */
P.synthV(role:\mulhall, take: \lead, params: {|p b| [
	lyrics: "doctor + ann mull hall astro + biology + + +",
	filter: (midinote: _ - 12), 
	legato: [1, 1, 1, 1, 0.6, 1, 1, 1, 1, 1, 0.5, ],
	vocalMode: \Airy,
	pitchTake: 2
] }, music:{|p b e|
		{
			e.playbuf
			=> p.synthVTracks.at(e.key).()
			=> DWGReverbC1C3.ar(_,mix:0.1)
		}.play
});
P(\chord,start:\biology,syl:4,music:{|p b e| 
		(
			freq: [1,11].df(\c,3),
			dur:b.sum,
			instrument:\stringyy,
			attack:2,
			amp:0.25

		).play
});
P.tune(\biology,Song.mulhallTune );
[ "Well, I was ordered to report here for landing party duty. ", [3, 2, 3, 6, 5.5].dm('c#',6) ++ [4, 5, 6, 7, 5, 11, 5, 4, 3, 2, 1].dm(\c,6) ].addLine;
P.still(\clear, timecode: 0.seconds, music: { |p b e|
	 e.still.( 
		wait: b.sum,
		text: ["well...",""],
	).sequenceText2(
			b.parse([1, 4, 4]), [ 
			["I was","ordered"],
			["to report","here"],
			["for landing party","duty"]
			],
	)
});
P.tune(\landing,Song.mulhallTune );
P.synthV(role: \mulhall, take: \lead, params: {|p b| [
	lyrics: "Well, I was ordered + to report + here for landing + party + duty + ",
	legato: [0.5, 1, 1, 1, 0.5, 1, 1, 1, 0.4, 1, 1, 1, 1, 1, 1, 1, ],
	lag: [0.06,   0, 0, 0, 0,   0, 0, 0, 0,   0, 0, 0, 0, 0, 0, 0, ],
	filter: (midinote: _ - 12), 
	pitchTake: 1
] }, music:{|p b e|
	{
		e.playbuf
		=> p.synthVTracks.at(e.key).()
		=> DWGReverbC1C3.ar(_,mix:0.1)
	}.play
});
P(\bassnotes,start:\landing,syl:9,music:{|p b e| 
		[
			freq: [11,4,5].df(\c,3).q,
			dur: b.drop(1).parse([2,2,2]) + [0,0,p.durs[e.start+1].list.sum] => _.q,
		].pp
		
});

P(\bass,start:\landing,music:{|p b e| 
		(
			freq: [1 ].df('c#',[5,4,3]),
			dur:b.parse([4]).sum
		).play
});
[ "KIRK: By whom? ",[7, 13].dm(\c,4,\mixolydian) ].addLine;
P.still(\clear, timecode: 0.seconds, music: { |p b e|
	 e.still.( 
		wait: b.sum,
		text: ["by","whom?"],
	)
});
P.synthV(role: \kirk, take: \lead, params: {|p b| [
		lyrics: "by whom",
		legato: [0.6, 0.6, ],
		pitchTake: 1
	] }, music:{|p b e|
		{
			e.playbuf
			=> p.synthVTracks.at(e.key).()
			=> Pan2.ar(_,-0.5)
		}.play
});
P.tune( _ <> [instrument: \wash, amp: 0.02,freqLag:1, out: Effect.bus({|i| i + DelayN.ar(i,0.25,0.25) },inputChannels:2)].pm );
P(\strum1,start:'whom?',syl:0,music:{|p b e| 
fork{
	var inst = Barrier.collect(
		{
			var freq = \freq.kr(300);
			Pluck.ar(
				SinOsc.ar( Env.perc(0.001,0.1).kr(0,gate:1).range(500,4000) ),
				\trig.kr(1),
				freq.reciprocal,
				freq.reciprocal,
				5,
				coef: 0.01,
			).tanh
			=> Pan2.ar(_,rrand(-1.0,1))
			=> MoogFF.ar(_,2800,1.5 )
			=> LPF.ar(_,500)
			* 2
			}.asDefName
		);
		inst=inst.()[0].postln;
		(
			instrument: inst ,
			freq:[5,7,11,13].df(\c,3,\mixolydian),
			strum:0.05,
			dur:b.sum
		).play
	}
});
[ "MULHALL: Strange, I'm not sure. Well, I'm not a liar, Captain. i"," 2 1 2 4 2 3 4 5 6 4 3 2".dm('e-',6,\whole) ++ [5].dm(\d,6)].addLine; 
P.still(\clear, timecode: 0.seconds, music: { |p b e|
	 e.still.( 
		wait: b.sum + e.bNext.sum,
		text: ["strange...",""],
	).sequenceText2(
			e.bAll.parse([1, 3, 8, 4, 7]), [ 
			["I'm not","sure"],
			["well I'm not a","liar, Captain"],
			["I", "did receive"],
			["an order","to report here"],
			["for","duty"]
			],
	)
});
P.synthV(role: \mulhall, take: \lead,
		pbind: Song.enlarge(13),
		params: {|p b| [
			filter: (midinote: _ - 12), 
		lyrics: "Strange, I'm not sure. Well, I'm not a liar +, Captain + I did receive + an order + to report + here for duty +",
		legato: [0.6, 1, 1, 0.5, 0.7, 1, 1, 1, 1, 1, 1, 0.6, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, ],
		pitchTake: 1
	] }, music:{|p b e|
		{
			e.playbuf
			=> p.synthVTracks.at(e.key).()
			=> DWGReverbC1C3.ar(_,mix:0.1)
		}.play
});
P(\chord,start:'Strange',music:{|p b e| 
		[ instrument:\wash,
			freq:[[1,3,4.5].df(\b,3), [3,4.5,6.5].df(\b,3)].q,
			dur: b.parse([3,2]).q

		].p.play
});
P.tune('Strange',Song.mulhallTune);
["did receive an order to report here for duty. "," 11 5 4 3 7 6 4 2 6 5 4 3 1".dm(\d,6,\mixolydian) ].addLine;
P(\bass,start:'did receive',music:{|p b e| 
		[
			freq: [1,4,2,5].df(\d,[3,4]).q,
			dur: b.parse([4,4,3,2]).q,
			legato:1
		].pp;
});
P.tune(\receive,Song.mulhallTune);
[ "SPOCK:(boom) I'm sure she did, Captain, Just as you received an order to bring me along. ",[1,5, 5, 6, 5, 4, 3].dm('e-') ++ [5, 6, 5, 3, 4, 5].dm(\e) ++ [5, 4, 5, 6, 6, 7, 5, 2].dm(\f) ].addLine;
Song.setTempoMap(\along,"e e ex x q e eq ex x e e e e e e e e e e e e");
P.still(\twoShotSpocksure, timecode: 755.7.seconds, music: { |p b e|
		 e.still.( 
			wait: b.sum,
			text: ["",""],
		)
});
P(\chords, music: { |p b e|
		[
			freq: [\r,[1,3, 5], [1,3,5],[-7,2,4], [1,4,-6,1]].df('b-',5,\mixolydian)
			++ [[1,3, 5], [-7,2,4], [1,4,-6,6]].df('b',5,\mixolydian)
			++ [[1,3, 5], [-7,2,4], [1,4,-6,4]].df('c',5,\mixolydian)
			=> _.q,
			// dur: b.parse([1, 1, 1,1, 1,2]).q,
			// dur: "e e Q E qqq ex x ee ee  ".asBeats.warpTo( e.tempoMap.quantizeDft(0) ).q,
			dur: b.parse([1, 1, 1, 1, 3,   1, 1, 4, 3,1,4 ]).q,
			instrument: \sawSynthSustain,pulse:0.3,amp:0.03
		].pp
});
P(\lastChord,syl:16, music: { |p b e|
	(
		freq: [1,2,5,7].df(\f),
		instrument: \stringyy,
		strum: 0.05,
		dur: b.drop(1).sum
	).play
});
P.still(\clear,lag:0.01, timecode: 0.seconds, music: { |p b e|
	 e.still.( 
		wait: b.sum,
		text: ["",""]
	).sequenceText2(
			b.parse([1,6,1]), [ 
				["I'm sure she did","captain"],
				["",""],
				["just as you received","an order to bring me along"],
			],
	)
});
	Song.setQuarters(\along,"e e ex x q e ee  ex x e e e e  e e e e x e x q");
P.synthV(role: \spock, take:\lead, params: {|p b| [
		lyrics: "r I'm sure she did captain + just as you received + an order + to bring me - along +",
		legato: [1, 1, 1, 1, 0.7, 1, 0.7, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1,],
		filter: (midinote: _ - 12), 
		pitchTake: 1
	] }, music:{|p b e|
		{
			e.playbuf
			=> p.synthVTracks.at(e.key).()
		}.play
});
P.double(role: \spock, params: {|p b| [
			
		] }, music:{|p b e|
			{
				e.playbuf
				=> p.synthVTracks.at(e.key).()
			}.play
		});
	//Song.quarters[\along]=Song.quarters[\along].list.reject{|i| i.isPositive.not}.q;
P(\click,start:\along,music:{|p b e| 
		e.quarters.postln;
		[
			dur: e.quarters,
			instrument:\hat_808
		].p;
});
P(\bass,start:\along,music:{|p b e| 
		var lick = [5, 4, 1];
		MegaBind(
			[
				lick.df('e-') ++ lick.df(\e,4) ++ [5,4,11].df(\f,4) => _.flat
			],
			"qe e qq| q e qq| qe e ".asBeats.warpTo(e.quarters),
			{|i|
				VarSaw.ar( i.freqSeq/[2,4]*[0.994,1,1.013],0,0.3 )
				* (
					//Env([0,1,0.7,0],[0.02,0.7,0.3]).kr(0,gate:(i.gateSeq*i.trigSeq))
					Env.asr().kr(gate:i.gateSeq)
					* 0.1
				)
			}
		).play
});
[ "KIRK: Oh, yes. ","5 11".dm(\g) ].addLine;

P.still(\kirkToSpock, timecode: 759.seconds, music: { |p b e|
		 e.still.( 
			wait: b.sum,
			text: ["oh..","yes.."],
		)
});
P.synthV(role: \kirk, take: \lead, params: {|p b| [
		lyrics: "oh yes",
		filter: (midinote: _ - 12), 
		legato: 0.5,
		pitchTake: 1
	] }, music:{|p b e|
		{
			e.playbuf
			=> p.synthVTracks.at(e.key).()
		}.play
});
P(\slide,start:'Oh, yes',music:{|p b e| 
		{
			Env([5,5,11].dm(\g),b[0]/2!2,curve:2.2).kr(0,gate:1)
			=> { |i| VarSaw.ar(i.lag( [0,2].dq.demand([1,1])   ).floor.midicps /[2,4],0,0.4) } 
			* 0.04
			=> EchoNone.ar(_)
			* Env.linen(0,b.sum,1).kr(2,gate:1)
				
		}.play
});
[ "MCCOY: Let's (boom boom) get back to this ","1 -7 -5 -7 3 2 1 ".dm(\c,5,\mixolydian) ].addLine;
Song.setTempoMap('get back',"e ee ee q q e e");
// Song.setTempoMap('get back',"e ee ex q q e e");
P(\hat, music: { |p b e|
	[
		dur:"x*22".beats.warpTo( e.tempoMap.quantizeDft(0.1) ) + [-0.01,0.01] =>_.q,
		amp: [4,2,3,2]/40 => _.q(inf),
		instrument: \hihat
	].pp
});
P.still(\wideMcCoy, timecode: 805.752.seconds, music: { |p b e|
		 e.still.( 
			wait: b.sum,
			text: ["let's get back","to this"],
		)
});
P.synthV(role: \mccoy, take: \lead, params: {|p b| [
		lyrics: "lets r r get back to this",
		legato: [1.5, 1, 1, 1, 0.8, 1, 1, ],
		pitchTake: 1
	] }, music:{|p b e|
		{
			e.playbuf
			=> p.synthVTracks.at(e.key).()
		}.play

});
P.tune('get back',Pset(\amp,[1,0,0,1,1,1,1]/10=>_.q,_));
Song.setQuarters('get back',"x e ex e | e x x");
P(\comping, music: { |p b e|
	{ 
		var freq = [3, 5, 7, 11, 12.5].df(\c,\mixolydian);
		var tr;
		VarSaw.ar(
			freq + Gendy1.arWidth(1).range(-5, 5),
			width: 0.5
		)
		/10
		=> Mix.ar(_)
		// * Env.perc(releaseTime: 4).kr(0,gate: tr = TDuty.ar( "x xx xxxxxxq".asBeats / 2 => _.warpTo( e.tempoMap.quantizeDft(0.1) ) => _.dq(1), 0 ))
		// + Pluck.ar(WhiteNoise.ar(0.1),tr, delaytime: freq.reciprocal, coef: 0.2 , decaytime: 5)
		* EnvGen.cutoff(wait:b.sum, release:0.2, curve:nil, doneAction:2)
		/18
		=> Out.ar(3,_)
	}.play
});
P(\bass,start:'get back',music:{|p b e| 
		[
			freq: [1, -7, -5, -17, -1].df(\c, 4, \mixolydian).q,
			dur: b.q,
			amp: 0.2,
			out: Effect.bus({|i| SoftKneeCompressor.ar(i) }, inputChannels:2)
		].pp	
		
		
});
P(\kick, music: { |p b e|
	[
		dur: "q q q q q ".asBeats.warpTo( e.tempoMap ).q,
		instrument: \kick, amp:0.2
	].pp
});
[ "( boom boom ) solid rock business...","1 1 7 6 7 11 7 6".dm('f#')].addLine;
P.still(\clear,syl:1, timecode: 0.seconds, music: { |p b e|
	 e.still.( 
		wait: b.drop(1).sum,
		text: ["solid rock","business"],
	)
});
P(\bassNotes, music: { |p b e|
	fork{
		var inst = Barrier.collect({
			Env.adsr(0.005,0.2,0.8,1).kr(0,gate:\gate.kr(1))
			* Saw.ar( \freq.kr(300),\amp.kr(0.1))
			=> HPF.ar(_, 400 )
		}.asDefName);
		inst.()[0] =>
		[
			freq: "1 1 ".df('f#',3).q,
			dur: b.q,
			instrument:_
		] =>_.pp
	}
});
P(\kick, music: { |p b e|
	// var tm = e.tempoMap.quantizeDft(0.3);
	[
		[
			dur: b[0..1].q,
			instrument: \kick_gentle,
			vol: 0.3
		].p,
		[
			dur: b.parse([2,3,1]).q,
			instrument: \snare,
			rest: [\r,1,1,1,1,1,1].q
		].p,
	] => Ppar(_)
	=> Pset(\out, Effect.bus({|i| SineShaper.ar(i,0.09) /3 }, out: 3),_)
	=> _.play

});
P.synthV(role: \spock, take: \lead, params: {|p b| [
	lyrics: "r r solid + rock - r r r",
	legato: [1, 1, 1, 1, 1, 0.5,  1, 1, ],
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
//idea: NineZero here?
P.synthV(role: \spock,take: \harmony,
	pbind: {|p b|
		[
		midinote: "1 11 11 6 5 6".dm(\c),
		dur: 0.5 * "qq q e eqq q q".asBeats warpTo: p.tempoMap[\solid] ,
		].p
	},
	 params: {|p b| [
	lyrics: "r r solid + rock r r",
	legato: [1, 1, 1, 1, 1, 0.5, ],
	pitchTake: 1
] }, music:{|p b e|
	{
		e.playbuf
		=> p.synthVTracks.at(e.key).()
	}//.play
});
P(\harmony, music: { |p b e|
	[
		freq:"r 11 11 6 5 6".df('c#').q,
		// dur: 0.5 * "qq q e eqq q q".asBeats warpTo: e.tempoMap q: 1,
		dur: b.parse([2, 1, 1, 2, 1, 1]).q,
		rest: [\r,1,1,1,1,1].q,

instrument: \reedy, freqLag:0.05, rel:8, out: Effect.bus( {|i| CombN.ar(i, 0.3, 0.3, 3)/2 + i},out: 3) ;
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
	}.play

});
P(\bass, music: { |p b e|
	[
		freq: "3 4 7 11 3 4 3 4 7 11 12 5 2 2".df(\c,[2,3]).q,
		dur: "e e e e x x x x e x x ex x q".asBeats  =>_.warpTo(e.tempoMap) =>_.q,
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
			* EnvGen.cutoff(b.sum-1,1)
			
		}, )

	].ppm
});
P(\chords,syl:1, music: { |p b e|
	[
		freq: [[4,6,11, 14,16,21], [5, 7,12, 13, 15, 17]].df('c#',3).q,
		dur: b.drop(1).parse([4, 2]).q
	].pp
});
P.synthV(role: \mccoy, take: \lead, params: {|p b| [
		filter: (midinote: _ - 12), 
		lyrics: "r r solid + rock - business +",
		legato: [1, 1, 1, 1, 1, 0.9, 1, 1, ],
		pitchTake: 1
	] }, music:{|p b e|
		{
			e.playbuf
			=> p.synthVTracks.at(e.key).()
		}.play

});
// P.tune(\business);
P(\bass,start:\business,music:{|p b e| 
		[
			freq: [1, 1, 2].df('f#',[3,4]).q,
			dur: b.parse([1,5,2]).q
		].pp
});
	//add pickup bassnote to line following?
[" (boom) Just how much rock are we going to go through? ","1 5 5 5 5 3 4 5 4 3 2 1 5 6 5".dm('b-') ].addLine;
P(\pad, music: { |p b e|
	[
		freq: [[1,3],[1,4], [2,4]].df('b-',[ 6,7 ]).q,
		dur:b.parse([11,4,1]).q,
		dur: [8, 2, 1].warpTo(e.quarters.list ++ 1) ++ e.bNext[0] => _.q,
		instrument: \stringyy,amp:0.3,freqLag:1, out:2
	].ppm
});
P.still(\clear, timecode: 0.seconds, music: { |p b e|
		 e.still.( 
			wait: b.sum,
			text: ["just how much rock","are we going to go through"],
		)
});
P.synthVs(role: \mccoy, take: [ \lead, \double ], params: [
		lyrics: "r Just how much rock are we going +  to go - through - - ",
		filter: [0,0].collect{|i| (midinote: _ - i)},
	pitchTake: [ 1,3 ],
		paramTension: 1,
		legato: [ [1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1.5, ] ],
		vocalMode: \Open,
		paramToneShift: 300
	], music:[ {|p b e|
		{
			e.playbuf
			=> p.synthVTracks.at(e.key).()
			=> FreeVerb.ar(_,0.2,1) * 2.dbamp
			=> Pan2.ar(_,-1)
		}.play
	},
	{|p b e|
		{
			e.playbuf
			=> p.synthVTracks.at(e.key).()
			=> FreeVerb.ar(_,0.2,1) * 2.dbamp
			=> Pan2.ar(_,1)
		}.play
	}
]);
	Song.setQuarters(\through,"q q q| q q e e| Q Q Q| Q Q E Eq q");
	Song.quarters[\through] = Song.quarters[\through].list
	.quantizeWindow
	.q;
P.tune(\through,Pset(
		\dur,
		"q q q| q q e e| Q Q Q| Q Q E Eq ex ".asBeats.warpTo(Song.quarters[\through]).q
		,_
	)
);
P(\drums,start:\through,music:{|p b e| 
	var compBus = Bus.audio(s, 2);
	(instrument:\cymbalsDS,amp:0.05, out: compBus.index ).play;
	e.quarters.postln;
	[
		instrument:\sn_808,
		dur:e.quarters,
		amp: 0.3,
		out: compBus
	].pp;
	[
		dur:"x....x.x".asDrumPat(2,4),
		instrument:\bd_808,
		amp:1,
		out: compBus
	].p.fin(25).play(e.quarters.asTempoClock);
	{
		Line.kr(0,0,b.sum+0.1, doneAction:2);
		In.ar(compBus, 2)
		=> DCompressor.ar(_, sidechainIn:0, sidechain:0, ratio:40, threshold:-40, attack:0.0, release:100.1, makeup:10.0, automakeup:1)
		// => SoftKneeCompressor.ar(_, control:nil, thresh:-10, ratio:8, knee:6, attack:0.01, release:0.5, makeUp:0, rms:0, )
		/3;
	}.play(s, addAction:\addToTail).onFree({compBus.free})
});
P(\bass,start:\through,music:{|p b e| 
		[3,1]/2=>_.dup(6)=>_.flat => _.warpTo( Song.quarters[\through].list ++ 1) => _.postln;
		MegaBind(
			[
				[11, 11, 7,  7,  6,  6,  5,  5,  4,  4,  3,  3,  2],
				[1,  \r, -7, \r, -6, \r, -5, \r, -4, \r, -3, \r, -2]
			].df('b-',3),
			[3,1]/2=>_.dup(6)=>_.flat => _.warpTo(e.quarters.list ++ 1 ) ++ p.durs[e.next].list[0]	,
			[],
			{|i|
		Pulse.ar( i.freqSeq/[1,2] )
				* (
					Env([0,1,0.7,0],[0.02,0.7,0.3]).kr(0,gate:(i.gateSeq*i.trigSeq))
					* 0.1
				)
			}
		).play
});
[ "SPOCK: (boom) Approximately one hundred twelve point three five two se-- ven miles, Doctor. ","-2 6 5 4 3 4 5 3 1 6 4 ".dm(\d) ++  "5 3 1 6 4 2".dm(\a,4) ].addLine; // point three se-ven five two miles....
P(\crash, music: { |p b e|
	(
		instrument: \cymbalsDS,
		out: Effect.bus({|i| FreqShift.ar(i, -599 + Gendy1.arWidth(freq:1).range(0, 20)) => {|i| CrossoverDistortion.ar(i)/20 + i /3} * EnvGen.cutoff(b.sum, 1) },inputChannels:2, out:2)
	).play
});
P.still(\spockTwoApprox, timecode: 808.354.seconds, music: { |p b e|
		 e.still.( 
			wait: b.sum,
			text: ["approximately 112.3527","miles"],
		)
});
P.synthVs(role: \spock, take: [ \lead, \double ], params: {|p b k| [
		lyrics: "r Approximately + + + + one hundred +  twelve point three five two seven + miles, Doctor + ",
		filter: (midinote: _ - 12), 
		vocalMode: \Passionate,
		pitchTake: [ 1, 3 ]
	] } , music:[ {|p b e|
		{
			e.playbuf
			=> p.synthVTracks.at(e.key).()
		}.play
	},{|p b e|
		{
			e.playbuf
			=> p.synthVTracks.at(e.key).()
			=> Pan2.ar(_,1)
		}.play
	}
]);
P(\more, music: { |p b e|
	[
		dur:b.parse([6, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1]).q,
		freq: [\r, 7, 5, 3, 1 ].df(\e,4,\minor).q,
		legato: [1,4, 3, 2, 1, ] + 4 =>_.q,
		pan: -1
	].pp;
	[
		dur:b.parse([11, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1]).q,
		freq: [\r, 7, 5, 3, 1 ].df('b',4,\minor).q,
		legato: [1,4, 3, 2, 1, ] + 4 =>_.q,
		pan:1
	].pp;
});
P(\fifths,start:\Approximately,syl:5,music:{|p b e| 
		MegaBind(
			[
				"5 3 1 6 4".df(\d) ++ [5, 3, 1, 6, \_, 4, 2].df(\a,4),
				"5 3 1 6 4".df(\g,4) ++ [5, 3, 1, 6, 4, \_, 2].df(\d,4)
			],
			[1,1,1,1,1,1,1,1,2/3,1/3,1].warpTo(b.drop(1)),
			[],
			{|i|
				Saw.ar( i.freqSeq  )
				* (
					Env([0,1,0.7,0],[0.02,0.7,0.3]).kr(0,gate:(i.gateSeq*i.trigSeq))
					* 0.1
				)
				=> MoogFF.ar(_, i.freqSeq*6 +1500)
			},
			{|i| i
				=> DWGReverbC1C3.ar(_,4000,mix:0.2)
				//=> Phaser2.ar(_,rate:0.1)
			}
		).play
});
[ "MCCOY: Miles? Are you joking? ",[7,4.5,5,11,5].dm('a-') ].addLine;
Song.durs.filter(\joki, {|i| i.drop(-1)++(i.last-0.15)});
P(\cymbals, music: { |p b e|
	(
		instrument: \cymbalsDS,
		lag:0.06,
		amp:0.03
	).play
});
P.still(\twoShot, timecode: 813.863.seconds, music: { |p b e|
		 e.still.( 
			wait: b.sum,
			text: ["miles?",""],
		).sequenceText2(
				b.parse([1]), [ 
				["are you","joking?"],
				],
		)
});
P.synthV(role: \mccoy, take: \lead, params: {|p b| [
		lyrics: "Miles are you joking +",
		filter: (midinote: _ - 12), 
		legato: [0.65, 1, 1, 1, 0.8, ],
		lag: [0.1,0,0,-0.1,-0.1],
		tension: Env( [1, 0, 0.2, 1, 0.5],b ),
		pitchTake: 1,
		vocalMode: \Open,
		paramGender: 0.15
	] }, music:{|p b e|
		{
			e.playbuf
			=> p.synthVTracks.at(e.key).()
			=> Pan2.ar(_,0)
		}.play
});
P('chord',start:'Miles?',music: {|p b e|
		[
			freq: [ [1,3,5].df(\b,\whole),[1,5,7,11].df('a-',\mixolydian)] .q,
			lag:0.06,
			attack:0,
			release:4,
			dur: b.parse([3,2]).q,
			instrument:\stringyy, wet:0.2,amp:0.3
		].ppm
});
[ "KIRK: No, we're not. Let's go. ",[-5, -5, 1].dm(\f) ++ [ -5, 1].dm(\a) ].addLine;
P.still(\kirkReplyNo, timecode: 817.532.seconds, music: { |p b e|
		 e.still.( 
			wait: b.sum,
			text: ["no","we're not"],
		).sequenceText2(
				b.parse([3]), [ 
				["let's","go"],
				],
		)
});
P.synthVs(role: \kirk, take: [ \lead,\double ], params: {|p b| [
		lyrics: "no we're not, lets go",
		filter: (midinote: _ - 12), 
		legato: [ [0.8, 1, 0.5, 0.8, 1, ] ],
		lag: [ [0.05,0,0,0,0,] ],
		pitchTake: [ 1,3 ]
	] }, music:{|p b e|
		{
			e.playbuf
			=> p.synthVTracks.at(e.key).()
		}.play
});
P.tune('No,');
P('chords',start:'No,',music: {|p b e|
		[
			freq: [-1,1,5,13,21] => {|i| [\r, i.df(\f),i.df(\a) ]} => _.q /2,
			dur:b.parse([2,2, 1]).q,
			strum:0.04,
		].pp
});
[ "SARGON [OC]: Please stand ready. I will operate your controls. ","12 11 7 6  11 7 6 5 4 3 2 11".dm('a-') ].addLine;
P.still(\sargonStandReady, timecode: 825.114.seconds, music: { |p b e|
		 e.still.( 
			wait: b.sum,
			fadeIn: b.parse([4]).sum,
			text: ["Please stand ready","I will operate"],
		).sequenceText2(
				b.parse([9]), [ 
				["your","controls"],
				],
		)
});
P.synthV(role: \vocoder, take: \lead, params: {|p b| [
		lyrics: "Please stand ready + I will operate + + your controls +",
		lag: [0.05,0,0,0,0,0,0,0,0,0,0,0],
		legato: [1, 1, 1, 0.8, 1, 1, 1, 1, 1, 1, 1, 1, ],
		filter: (midinote: _ - 24), 
		pitchTake: 1,
		defaultVibratoDepth: 0
	] }, music:{|p b e|
		// {
			// e.playbuf
			p.vocodeTune.( p, b, e, e.rpp,
				modGain:4,
				chord: #[1, 2, 4, 8],
				durRel:2
			);
			// => p.synthVTracks.at(e.key).()
		// }.play
		play{
			p.laMer => PlayBuf.auto(2, _, rate: ([-4,4, 5, 4, 5, 4].dm('a-') - 1.dm('c')).midiratio.dq.demand(b.parse([2,[1,0.5],[0.5,1,1],[1,1,0.6],[0.4,1,1],1])))
			/7
			=> Out.ar(p.carrierBus,_)
			
		}

});
P('bass',start:\operate,music: {|p b e|
		[
			freq:
			[\r, -4,-5, -2, -3, [ -1,1,2.4,5.5 ]].df('a-',[3,4]).q
			,
			dur: b.parse([2,[1,0.5],[0.5,1,1],[1,1,0.6],[0.4,1,1],1]).q,
			amp: 0.26
		].pp
});
P.tune('stand ready', _ <> (instrument: \stringyy));
["( transporter! )","r",[8]].addLine;
P.still(\transporting, timecode: 845.028.seconds, music: { |p b e|
		 e.still.( 
			wait: b.sum,
			text: ["",""],
		)
});
P('transporter',start:'transporter!',music: {|p b e|
	{
	var beam_envelope, phasor, beam, feedback, transporter, reverb, activateEnv, percEnv, activate, buffer;

	buffer = LocalBuf(SampleRate.ir * 0.12);

	// feedback has to be 0 at the beginning, to avoid input
	// nil before sound has been produced
	feedback = 0;


	// Activate Sound (fig 56.3)

	activateEnv = EnvGen.ar(Env.new([0, 1, 1, 0], [0.01, 0.01, 5]));
	percEnv = EnvGen.ar(Env.new([1, 1, 0], [0.01, 0.12]));

	activate = (1 - activateEnv * 120 + 775) + (WhiteNoise.ar(0.1) + SinOsc.ar(30, mul:40));
	activate = OnePole.ar(activateEnv, exp(-2pi * (30 * SampleDur.ir))) * LFSaw.ar(activate, 1, 0.5, 0.5 );

	// adding a percussive shape at the beginning of the sound
	activate = (activate + (WhiteNoise.ar * percEnv)) * 3;

	activate = Clip.ar(activate, -1, 1);
	activate = BPF.ar(activate, [775,1550,2325], 13.reciprocal).sum * 0.5;


	// Beam Sound

	beam = LFSaw.ar(467.1, 1, 0.5, 0.5 ) - 0.5;
	beam = beam - (Wrap.ar(beam) - 0.5);
	// two stage FM process
	phasor = LFSaw.ar( beam * 6500 + 277, 1, 0.5, 0.5) - 0.5;
	beam = beam * (phasor - (Wrap.ar(phasor) - 0.5));
	beam = DelTapWr.ar(buffer, beam + (feedback * 0.7));

	beam_envelope = Line.ar(0,1,12);

	feedback = DelTapRd.ar(buffer, beam,
		(1 - beam_envelope * 12 + 1
			// flanger effect w/ variable delays spaced 12ms apart [0,12,24]
			+ 12 * (0..2))
		// DelTapRd requires delaytime in seconds (the equivalence in pd [vd~]
		// calculates with miliseconds, for it the division by 1000)
	 	/ 1000,
		interp: 4).sum * 0.3;

	transporter = (beam_envelope * (-1) + 1).min(beam_envelope) * 4 * feedback;
	transporter = (transporter - OnePole.ar(transporter, exp(-2pi * (100 * SampleDur.ir))));
	transporter = BPF.ar(transporter,
		// whole tone scale
		Array.geom(12, 466.164, 1.12247),
		[1200, 1100, 930, 910, 880, 840, 800, 760, 720, 680, 640, 620].reciprocal).sum * 12;
	reverb = GVerb.ar(transporter + (activate * 0.1), 100, 8, 0.1, 0.9)
	+ (activate * 0.5)!2
	/4

}.play
});
)
/* [ "KIRK: Doctor, if you prefer to stay behind? ","r" ].addLine;
[ "MCCOY: No. No, if I'd be useful, as long as you're going down, I might as well take a medical look at whatever this is. ","r" ].addLine;
(The landing party and two guards gather on the pads, Scotty stands sulking with arms crossed as the transporter activates, and just sends the four officers somewhere.) */
