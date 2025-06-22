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
			* 2.dbamp
			=> Pan2.ar(_, 0)
			// => p.synthVTracks.at(e.key).()
		}.play
});
[ "V1L1", "r", Song.quarter.dup(64)].addLine;
P(\keys,music: {|p b e|
	MicroKeys(\yow).synth_(\yowbass);
	MicroKeys(\harp).synth_(\harp, params: [coef: 0.1]);
	MIDIItem("_250119_105441").take(11)
	.filter{|e| e.collect{|i| i.amp.notNil.if{i.amp = i.amp / 8}; i}}
	.recalcSustains
	.play([\yow, \harp], clock: TempoClock.new(0.52 / Song.quarter, queueSize: 2**12  ))
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
P(\bgVox, music: { |p b e|
	MIDIItem("250122_113217").take(2)
	//.play(\vocaline)
});
P(\arrangement, music: { |p b e|
	(instrument: \cymbalsDS, amp: 0.02).play;
	[
		[
			instrument: \JWSnare,
			dur: "q e eq q".beats.q(inf) * Song.quarter,
			rest: [\r, 1, 1, 1].q(inf),
			amp: 0.25
			// dur: 
		].p,
		[
			instrument: \bd_808,
			dur: "e eq qq".beats * Song.quarter => _.q(inf),
			amp: 0.6,
			lag: -0.005
		].p,
		// Song.quarter = 0.46;
		[
			freq: [1, 4, 5, 6 ,4, 5, 1, 4, 5, 6 , 4, 5].df(\c, [3]).q(8),
			dur: "eee e ex x e e".beats * Song.quarter * 2 => _.q(16),
			amp: 0.3
		].p
	]
	=> Ppar(_)
	=> _.findur( Song.quarter * 64 )
	=> _.play
});
P(\altGuit, music: { |p b e|
	PluckMaker(
				notes: 
		 [1, 1, 1, 1, 1, 1, 1, 1, 5, 5, 5, 6, 4, 4, 5, 5, ].df(\c, [3, 4]).dup(8).flatten,
		// Song.quarters.dup(16),
		noteDurs: {[Song.quarter].dq(inf) / 2},
		triggers: 
		{ Song.quarter.bubble.dq(inf) / 2 => TDuty.ar(_, 0) 
		// => HPF.ar(_, 200)
	}
	).play

});
P(\bassGuit, music: {|p b e|
	[
		// instrument: [\harpRelease, \sawSynth],
		instrument: [\harp, \sawSynth],
		freq: [1, 1, 1, 1, 1, 1, 1, 1, 5, 5, 5, 6, 4, 4, 5, 5, ].df(\c, [3, 4]).q(8),
		dur: Song.quarter / 2,
		legato: 0.4,
		att: 0, rel: 0.5,
		amp: [0.05, 0.2],
		out: [Effect.bus({|i| Phaser2.ar(i, rate: 0.1) },) , 0]
	].pp
});
// Song(\Wind, []);
["newBridge", "r", Song.quarter.dup(24)].addLine;
P(\tempo, music: { |p b e|
	TempoClock.tempo_(1)
});
P(\chords, music: { |p b e|
	{
		[
			[7, 11, 4],
			[6, 11, 4],
			[5, 11, 4],
			[5, 11, 3],
			[7, 11, 4],
			[7, 12, 5],
			[6, 13, 11],
			[6, 11, 13],
		].df('b-', \mixolydian).dq(1)[[0,1, 2]].demand( [1, 1,  0.5, 0.5].dup.flat * Song.quarter * 4)	
		=> Saw.ar(_, 0.1, 0.1)
		/3
		=> RLPF.ar(_, SinOsc.ar([0.2, 0.22, 0.31]).range(800, 7000), 0.5)
		* Env.perc(0.006, 0.4).kr(0,gate: Impulse.kr(Song.quarter.reciprocal * 4))
		* EnvGen.cutoff(Song.quarter * 16, 12)
	}.play
});
P(\line, music: { |p b e|
	var echo = Effect.bus({|i|  CombN.ar (i, [0.5, 0.45], 0.5, 5) / 4 + i * -2.dbamp },);
	var m = MicroKeys.mono( \sawSynthSustain);

	MIDIItem("_250204_161748")
	// .midiEvents.select{|i| i.midicmd == \noteOn}.collect{|i| i.midinote}
	.filter({|e| e.collect{|i| i.amp.notNil.if{i.amp_(i.amp/2)}; i.timestamp_(i.timestamp * Song.quarter / 0.52)}})
	.filter{|e| e.collect{|i| i.params_((out: echo))}}
	// .save
	.play(
		\sawSynthSustain,
		// \default
		// \test,
		overdub: true
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
		rest: [\r, 1].q(24),
		amp: 1
	].pp
});
P(\bassline, music: { |p b e|
			 PluckMaker( notes: 
				 [7, 7,7, 11, 4, 4, 4, 3, 1, 1, 1, 3, 7, 7,7, 11, 5,5,5, 4, 6, 6, 6, 5] +.x [0, 10] => _.df('b-',[1, 2], \mixolydian)
				 ,
				 
				 noteDurs: {[Song.quarter].dq(47) / 2},
				 triggers: { Song.quarter.bubble.dq(47) / 2 => TDuty.ar(_, 0) 
				 // => LPF.ar(_, 400)
			 } ,
				 amp: 0.1,
				 decay: 1.7
				 // noiseFilterFunc:  LPF.ar(_, 1800, 0.4) 
			 ).play
});
// third section
//
["G chorus line 1", "3 -7 -6 4 3 4  6 4 2 7 6 5".dm(\g, \mixolydian), "e e x x e qq  e e x x e qq".beats * (Song.quarter * 2 ? (0.52 * 2))].addLine;
P.tune();
P(\tempoChange, music: { |p b e|
	TempoClock.tempo= 2;
});
Song.chorusVocGain = -5.dbamp;
Song.chorusVocPan = #[-1, 0, 0, 1];
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
( Song.makeLine = { |connector=false|
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
		].pm.fin(connector.if { 5 }{ 6 }).play;
		[
			freq: [\r, 2, 3, -7, 1, 3 ].df(\g, \mixolydian).q,
			dur: b.parse([8, [3, 1/4], 1/4, 1/4, 1/4, 1]).q ,
			instrument: \harp,
			out: Effect.bus({|i| Splay.ar(i, spread:0.5, center:-1 ) }),
			wet: 0,
			coef:0.15,
			amp: 0.05,
		].p.fin(connector.if { 5 }{ 6 }).play;

	});
};
Song.makeLine.();
);
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
		* p.chorusVocGain
		=> Pan2.ar(_, p.chorusVocPan[1])
	}.play
});
P(\bass, music: { |p b e|
	[
		freq: [11, 7].df(\g,[3, 2], \mixolydian).q(4),
		dur: "qe e".beats.q(4)* Song.quarter
	].pp
});
["repeat", "3 -7 -6 4 3 4  6 4 2 7 6 5".dm(\g, \mixolydian) ,"e e x x e qq  e e x x e q qq".beats * (Song.quarter)].addLine;
Song.cloneDursAndTempoMap('G chorus line 1');
P.clone('G chorus line 1', [\bass]);
Song.makeLine.(connector: true);
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
			* p.chorusVocGain
			=> Pan2.ar(_, p.chorusVocPan[3])
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
			* p.chorusVocGain
		=> Pan2.ar(_, p.chorusVocPan[3])
		// => p.synthVTracks.at(e.key).()
	}.play
});
P.synthV(\an, take: \leadQwen, lag: (16 * Song.quarter - ( 1 * 2 ) -0.08), pbind: 
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
		pitchTake: 2,
		legato: [1, 1, 1, 1, 1, 0.9, 1, 1, 1, 1, 1, 1, 0.5, 1, 1, 1, 1, 1, 1, 1, 0.5]
		,
		language: \Mandarin
	]}, 
	music:{|p b e|
		{
			e.playbuf
			/3
			* 2.dbamp
			=> Pan2.ar(_, 0)
			// => p.synthVTracks.at(e.key).()
		}.play
});
[ "V1L12", "r", Song.quarter.dup(64)].addLine;
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
P(\tempo, music: { |p b e|
	TempoClock.tempo= 1;
});
P(\keys,music: {|p b e|
	MicroKeys(\yow).synth_(\yowbass);
	MicroKeys(\harp).synth_(\harp, params: [coef: 0.1]);
	MIDIItem("_250119_105441").take(11)
	.filter{|e| e.collect{|i| i.amp.notNil.if{i.amp = i.amp / 8}; i}}
	.recalcSustains
	.play([\yow, \harp], clock: TempoClock.new(0.52 / Song.quarter, queueSize: 2**12  ))
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
	var len = 12;
	(instrument: \cymbalsDS, amp: 0.02).play;
	[
		[
			instrument: \JWSnare,
			dur: "q e eq q".beats.q(inf) * Song.quarter,
			rest: [\r, 1, 1, 1].q(inf),
			amp: 0.25
			// dur: 
		].p,
		[
			instrument: \bd_808,
			dur: "e eq qq".beats * Song.quarter => _.q(inf),
			amp: 0.6

		].p,
		[

			freq: [1, 1, 1, 1, 1, 1, 4, 4, 5, 5, 5, 6, 4, 4, 5, 5, ].df(\c, [2 ]).q(8),
			dur: Song.quarter / 2,
			instrument: \harpRelease,
			legato: 0.2,
			out: Effect.bus({|i| CrossoverDistortion.ar(i, smooth:0.95)}, out:1)
		].p,
		// Song.quarter = 0.46;
		[
			instrument: [\harp, \sawSynth],
			freq: [1, 1, 1, 1, 1, 1, 1, 1, 5, 5, 5, 6, 4, 4, 5, 5, ].df(\c, [3, 4]).q(8),
			dur: Song.quarter / 2,
			legato: 0.4,
			att: 0, rel: 0.5,
			amp: [0.05, 0.2]
		].p,
		[
			freq: [1, 4, 5, 6 ,4, 5, 1, 4, 5, 6 , 4, 5].df(\c, [3]).q(8),
			dur: "eee e ex x e e".beats * Song.quarter * 2 => _.q(16),
			amp: 0.3
		].p
	] => Ppar(_) => _.findur(Song.quarter * len * 8) => _.play

});
)
