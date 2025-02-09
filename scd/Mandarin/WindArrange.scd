"WindVerse.scd".load;
"WindShortBridge.scd".load;
Song.sections
Song.playRanges(0, 4, 1, 2)
( // song
/*
时代的风吹过长安街
人群像落叶随风飘
年轻的眼睛寻找答案
但真相藏在雾里逃
*/
Song(\Wind, []).current;
Song.keySig=\c;
Song.quarter = 0.52;
["countoff", "r", [1]].addLine;
P.synthV(\an, take: \leadQwen, lag: -0.08, pbind: 
	MIDIItem("_250119_105441").take(11)
	.collect({|i x| (x >= 1).if { i.timestamp = i.timestamp - (Song.quarter * 4) - 1 }; i })
	.synthVPbind
	,
// need to make Legato
	params: {|p b| [
		// lyrics: " r 时 代 的 风 吹 过 长 安 
		// 人 群 像 落 叶 随 风 飘 
		// 年  轻 的 眼 睛 寻 找 答 案
		// 但 真 相 藏 在 雾 里 逃
		// 时 代 的 风 吹 过 长 安
		// ",
		lyrics: "r 
		春 风 拂 面 来 
		花 开 满 园 香 飘 远 
		心 随 梦 飞 翔 
		爱 永 恒 
		星 夜 静 如 水 
		月 光 洒 落 思 乡 情 
		梦 回 故 乡 路 
		心 依 恋 
		",
		pitchTake: 1,
		legato: [1, 1, 1, 1, 1, 0.9, 1, 1, 1, 1, 1, 1, 0.5, 1, 1, 1, 1, 1, 1, 1, 0.5]
		,
		language: \Mandarin
	]}, 
	music:{|p b e|
		{
			e.playbuf
			/3
			* 2.5.dbamp
			=> Pan2.ar(_, 0)
			// => p.synthVTracks.at(e.key).()
		}.play
});
[ "V1L1", "r", Song.quarter.dup(64)].addLine;
P(\keys,music: {|p b e|
	MicroKeys(\sawSynthSustain).synth_(\yowbass);
	MicroKeys(\harp).synth_(\harp, params: [coef: 0.1]);
	MIDIItem("_250119_105441").take(11)
	.filter{|e| e.collect{|i| i.amp.notNil.if{i.amp = i.amp / 8}; i}}
	.recalcSustains
	.play([\sawSynthSustain, \harp], clock: TempoClock.new(0.52 / Song.quarter, queueSize: 2**12  ))
});
P.synthV(\jun, take: \lead, lag: 32*Song.quarter, resources: (startPos:32), pbind: 
	[
		dur: 
		MIDIItem("250122_113217").take(2)
		// .from(Song.quarter * 4)
		.synthVPbind.patternpairs.asEvent[\dur]
		[..21]
		,
		midinote: 
			[
				1,
				11, 6, 6, 7, 6,
				11, 6, 6, 7, 6,
				11, 6, 6, 7, 6,
				11, 6, 6, 7, 6,
				11,
			].dm(\c)
	].p,
	params: {|p b| [
	lyrics: "r aaah aah ah - ah ah ah ah - ah ah ah ah - ah ah",
	pitchTake: 1 //should this be nil  ??
] }, music:{|p b e|
	{
		e.playbuf.(startPos: e.lag)//.(32 * p.quarter)//(startPos: 8)
		/3
		=> Pan2.ar(_,SinOsc.ar(0.12))
		// => p.synthVTracks.at(e.key).()
	}.play
});
// {SinOsc.ar([15, 21].df(\c))/30}.play; // add drone
P.synthV(\jun, lag: 0 * Song.quarter, take: \lower,
	pbind: 
	[
		dur: 
		MIDIItem("250122_113217").take(2)
		.from(Song.quarter * 4)
		.synthVPbind.patternpairs.asEvent[\dur]
		[[0, 1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12, 13, 14, 15, 1, 2, 3, 4, 5, 6, 7, 8, 9 ]]
		,
		midinote: 
		"r 
		5 4 4 5 4 
		5 4 4 5 4 
		5 4 4 5 4 
		5 4 4 5 4
		5 4 4 5 2.5".dm(Song.keySig,6)
		,
	].p
	,
	params: {|p b| [
	lyrics: "r aaah aah ah - ah",
	pitchTake: 1
] }, music:{|p b e|
	{
		e.playbuf.(startPos: e.lag)
		/3
		=> Pan2.ar(_,SinOsc.ar(0.12))
		// => p.synthVTracks.at(e.key).()
	}.play
});
~quarter = Song.quarter;
P(\bgVox, music: { |p b e|
MIDIItem("250122_113217").take(2)
//.play(\vocaline)
});
P(\arrangement, music: { |p b e|
	(instrument: \cymbalsDS, amp: 0.02).play;
	[
		instrument: \JWSnare,
		dur: "q e eq q".beats.q(inf) * ~quarter,
		rest: [\r, 1, 1, 1].q(inf),
		amp: 0.25
		// dur: 
	].pp;
	[
		instrument: \bd_808,
		dur: "e eq qq".beats * ~quarter => _.q(inf),
		amp: 0.6

	].pp;
	// ~quarter = 0.46;
	[
		instrument: [\harp, \sawSynth],
		freq: [1, 1, 1, 1, 1, 1, 1, 1, 5, 5, 5, 6, 4, 4, 5, 5, ].df(\c, [3, 4]).q(8),
		dur: ~quarter / 2,
		legato: 0.4,
		att: 0, rel: 0.5,
		amp: [0.05, 0.2]
	].pp;
	[
		freq: [1, 4, 5, 6 ,4, 5, 1, 4, 5, 6 , 4, 5].df(\c, [3]).q(8),
		dur: "eee e ex x e e".beats * ~quarter * 2 => _.q(16),
		amp: 0.3
	].pp;

});
// Song(\Wind, []);
["newBridge", "r", Song.quarter.dup(24)].addLine;
P(\line, music: { |p b e|
	MIDIItem("_250204_161748")
	.filter({|e| e.collect{|i| i.amp.notNil.if{i.amp_(i.amp/2)}; i.timestamp_(i.timestamp * Song.quarter / 0.52)}})
	// .save
	.play(
		\sawSynth
	)
});
P(\traps, music: { |p b e|
	[
		instrument: \bd_808,
		dur: Song.quarter,
		amp: 0.5
	].pp;
	[
		instrument: \openhihat_808,
		dur: Song.quarter / 2,
		rest: [\r, 1].q(inf),
		amp: 1
	].pp
});
P(\bassline, music: { |p b e|
	[\pluckD, \default].do
	{ |instrument|
		[
			bass: [7, 7, 7, 11, 4, 4, 4, 3, 1, 1, 1, 3, 7, 7,7, 11, 5,5,5, 4, 6, 6, 6, 5].dupEach(2).q(1),
			oct: [2, 3].dupEach(1).q(inf),
			instrument: instrument,
			freq: Pfunc{|e| e.bass.df('b-',e.oct, \mixolydian) * (e.instrument == \default).if {0.5}{1}},
			dur: Song.quarter / 2,
			// instrument: [\pluckD, \default]
			out: Pfunc({|e| if (e.instrument == \pluckD) {Effect.bus({|i| i/2 => Pan2.ar(_) },)}{0}})
		].ppm
	}
});
// third section
//
["G chorus line 1", "3 -7 -6 4 3 4  6 4 2 7 6 5".dm(\g, \mixolydian), "e e x x e qq  e e x x e qq".beats * (Song.quarter * 2 ? (0.52 * 2))].addLine;
P.tune();
P.synthV(\jun, take: 
	// \lead_melisma
	\lead
	, params: {|p b| [
		lyrics: " 梦 在 风 中 破 碎 心 在 雾 中 徘 徊 ",
		// lyrics: " 梦 - - 中 - 碎 心 - - 中 - 徊 ",
		pitchTake: 1,
		language: \mandarin,
		phoneset: \xsampa
	] }, music:{|p b e|
		{
			e.playbuf
			// => p.synthVTracks.at(e.key).()
		}.play
	});
	P(\arrangement, music: { |p b e|
		// var div = 2;
		var div = 1;
		(instrument: \cymbalsDS, amp: 0.02).play;
		[
			instrument: \JWSnare,
			dur: "q ee q q".beats.q(inf) * Song.quarter / div,
			// rest: [\r, 1, 1, 1].q(inf),
			rest: [\r, 1, \r, 1].q(inf),
			amp: 0.25
			// dur: 
		].pp;
		[
			instrument: \bd_808,
			dur: "qe e qq".beats * Song.quarter / div => _.q(inf),
			// dur: "q eee q e".beats * Song.quarter / div => _.q(inf),
			amp: 0.6

		].pp;
		P(\tamb, music: { |p b e|
			{
				var levels = [3,1,2,1] /3 => _.dq(inf);
				var durs =  
				1/4 ! 16 
				* Song.quarter
				+ ( [1, -1] /80 => _.dup(8) ) //swing amt
				=> _.flat 
				// => _.warpTo(e.tempoMap.quantizeWindow(0.3))
				=> _.dq(8);
				var triggers = TDuty.kr( durs, 0,1,gapFirst:0 );
				var energy = EnvGen.ar( Env.linen(0, 0.00, 0.015), triggers, doneAction:0   ) 
				* Demand.kr(triggers,0,levels 
				);
				Shakers.ar(3, energy:energy   , decay: 1).tanh
				* 8
				=> Pan2.ar(_, 0.8)
				// * EnvGen.cutoff(b.parse([4]).unbubble,3)
				=> DWGReverbC1C3.ar(_,mix:0.05)
				/12
				=> Pan2.ar(_,0.75)
				=> Out.ar(1, _)

			}.play;
			[
				instrument: \hat_808, 
				dur: "x x e x x e  x x x x x x e".beats.q(16) * ~tempo / 2,
				pan:0.5,
				amp: 0.05
			].pp;
			(instrument: \cymbalsDS, amp:0.02).play

		});
		// Song.quarter = 0.46;
		// [
		//	 instrument: [\harp, \sawSynth],
		//	 freq: [1, 1, 1, 1, 1, 1, 1, 1, 5, 5, 5, 6, 4, 4, 5, 5, ].df(\c, [3, 4]).q(8),
		//	 dur: Song.quarter / 2,
		//	 legato: 0.4,
		//	 att: 0, rel: 0.5,
		//	 amp: [0.05, 0.2]
		// ].pp;
		[
			freq: [1, 4, 5, 6 ,4, 5, 1, 4, 5, 6 , 4, 5].df(\c, [3]).q(8),
			dur: "eee e ex x e e".beats * Song.quarter * 2 => _.q(16),
			amp: 0.3
		]//.pp;

	});
	P(\line, music: { |p b e|
		[
			freq: [\r, 4, 2, -6, -7, 6].df(\g, \mixolydian).q,
			dur: b.parse([5, 1/4, 1/4, 1/4, 1/4, 3]).q ,
			instrument: \stringyy,
			wet: 0,
			amp: 1,
			out: Effect.bus({|i| Splay.ar(i, spread:0.5, center:1 ) })
		].ppm;
		[
			freq: [\r, 4, 2, -6, -7, 6].df(\g, \mixolydian).q,
			dur: b.parse([5, 1/4, 1/4, 1/4, 1/4, 3]).q ,
			instrument: \harp,
			coef:0.15,
			amp: 0.05,
			out: Effect.bus({|i| Splay.ar(i, spread:0.5, center:1 ) })
		].pp;
		[
			freq: [\r, 2, 3, -7, 1, 3 ].df(\g, \mixolydian).q,
			dur: b.parse([8, [3, 1/4], 1/4, 1/4, 1/4, 1]).q ,
			instrument: \stringyy,
			out: Effect.bus({|i| Splay.ar(i, spread:0.5, center:-1 ) }),
			wet: 0,
			amp: 1
		].ppm;
		[
			freq: [\r, 2, 3, -7, 1, 3 ].df(\g, \mixolydian).q,
			dur: b.parse([8, [3, 1/4], 1/4, 1/4, 1/4, 1]).q ,
			instrument: \harp,
			out: Effect.bus({|i| Splay.ar(i, spread:0.5, center:-1 ) }),
			wet: 0,
			coef:0.15,
			amp: 0.05,
		].pp

	});
	P(\beat, music: { |p b e|
		var reps = 4;
		[
			dur: "e t t t t eeeee t t t t".beats.q(reps) * Song.quarter,
			instrument: 
			// \cp_808
			\MT_808
			,
			rest: [\r, 1, 1, 1, 1].q(reps * 2),
			amp: 0.2
		].pp
	});
	P.synthV(\jun, take: \lower, params: {|p b| [
		filter: (midinote: _ - 12),
		lyrics: " 梦 在 风 中 破 碎 心 在 雾 中 徘 徊 ",
		pitchTake: 2,
		language: \mandarin,
		phoneset: \xsampa
	] }, music:{|p b e|
		{
			e.playbuf
			// => p.synthVTracks.at(e.key).()
		}.play
	});
	P(\bass, music: { |p b e|
		[
			freq: [11, 7].df(\g,[3, 2], \mixolydian).q(4),
			dur: "qe e".beats.q(4)* Song.quarter
		].pp
	});
	["repeat", "3 -7 -6 4 3 4  6 4 2 7 6 5".dm(\g, \mixolydian) ,"e e x x e qq  e e x x e qq".beats * (Song.quarter)].addLine;
	Song.cloneDursAndTempoMap('G chorus line 1');
	P.clone('G chorus line 1', [\bass, \line]);

	P.synthV(\an, take: 
		// \lead_melisma
		\lead
		, params: {|p b| [
			lyrics: " 梦 在 风 中 破 碎 心 在 雾 中 徘 徊 ",
			// lyrics: " 梦 - - 中 - 碎 心 - - 中 - 徊 ",
			pitchTake: 2,
			language: \Mandarin
		] }, music:{|p b e|
			{
				e.playbuf
				// => p.synthVTracks.at(e.key).()
			}.play
		});

		P.synthV(\an, take: \lower, params: {|p b| [
			filter: (midinote: _ - 12),
			lyrics: " 梦 在 风 中 破 碎 心 在 雾 中 徘 徊 ",
			pitchTake: 3,
			language: \Mandarin
		] }, music:{|p b e|
			{
				e.playbuf
				// => p.synthVTracks.at(e.key).()
			}.play
		});
)

)
