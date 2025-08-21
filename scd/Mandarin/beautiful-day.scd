(
Song(\beautiful,[]).current;
Song.pianoQuarters = 
MIDIItem(\foo).take(1)//.gui
.fromNote(0, 98)
// .gui
.filter({|e| e.select{|i| i.midicmd == \noteOn}[[0, 9, 13, 19, 22, 31, 39, 44, 48, 55, 62,  70, 72, 80, 85, 94]]})
// .gui
.notes.collect{|i| i.timestamp}.differentiate;
//OK the issue here is that the rest at the top of the MIDIItem got included as pianoQuarters[0] becuase I used "timestamp.differentiate" - should *always drop[0] when doing this!!!
["ch1", "r", Song.pianoQuarters[..8] ].addLine;
Song.setTempoMap("ch1", 1 ! 17);
P(\weeew,lag: Song.pianoQuarters[(..2)].sum + 0.2, music: { |p b e|
fork{
	5.do{|i|
		{
			Gendy1.arWidth(width:1.05 + (i /10),freq: Line.kr(400,100,3))
			/ (i + 1)
			* EnvGen.cutoff(2, 3)
			/5
			=> Pan2.ar(_, -1.rrand(1))
			=> HPF.ar(_, 100)
		}.play;
		0.5 => _.wait;
	}
}
});
P(\tamb,lag: Song.pianoQuarters[0], music: { |p b e|
	{
		var levels = [3,1,2,1] /3 => _.dq(inf);
		var durs =  
		1/4 ! 16 
		// * Song.quarter
		+ ( [1, -1] /80 => _.dup(8) ) //swing amt
		=> _.flat 
		=> _.warpTo(e.tempoMap.quantizeWindow(0.3, 8))
		=> _.dq(2);
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
		=> Out.ar(0, _)

	}.play;
	[
		instrument: \hat_808, 
		dur: "x x e x x e  x x x x x x e".beats.q(16) * ~tempo / 2,
		pan:0.5,
		amp: 0.05
	].pp;
	(instrument: \cymbalsDS, amp:0.02).play

});
P(\bd, music: { |p b e|
	[
		amp:0.5,
		rest: MuteFirst(),

		instrument: \kick_gentle, // make this a flam
		// amp:1.9,
		// strum: Pwhite(0.02, 0.04, inf),
		dur: [1] ++ [1, 1.5, 1, 0.5].dup(4).flat =>_.warpTo(e.tempoMap ++ e.tempoMap
			=>_.quantize()
			// .quantizeWindow(0.5, 8)
		) =>_.q
	].pp
});
P(\click, music: { |p b e|
	[
		amp: [ 0.4, 0.3 ] ,
		rest: MuteFirst(),

		instrument: \JWSnare, // make this a flam
		// amp:1.9,
		strum: Pwhite(0.02, 0.04, inf),
		dur: 1.dup(17).warpTo(e.tempoMap
			.quantize()
			++ e.tempoMap
			.quantize()
			// .quantizeWindow(0.5, 8)
		).q
	].pp
});
Song.quantizedKeysV1 = MIDIItem(\foo).take(1).fromNote(0, 100)
	.quantize(
		[ 0.57, 0.57 ].dup(9).flat, 
		nil, 
		{|notes| [(timestamp:0)] ++ notes[[0, 9, 13, 19, 22, 31, 39, 44, 48, 55, 62,  70, 72, 80, 85, 94 ]] }
	)
	 .removeNote(59);
P(\keys, lag: MIDIItem(\foo).take(1).initialRest, music: { |p b e|
	var keyFX = Effect.bus(BPF.ar(_, 1100, rq: 3.0));
	p.quantizedKeysV1
	 .collect{|i| i.params_((out: keyFX ))}
	 .recalcSustains
	 // .gui
  .play(\default)
});
P.synthV(\an, take: \lead, 
	pbind: 
	MIDIItem(\foo).take(1).filter({|e|e.select{|f| f.midinote == 5.dm(\c) or: (f.midinote == 6.dm(\c))}[(4..8)++(9..15)]}).start_(0)//.play(\default)//1.714
	.synthVPbind,
	params: {|p b| [
	lyrics: " r 美 好 天  回 忆 里 -",
 // 美好天 (měi hǎo tiān) - Beautiful day
	pitchTake: 1,
	language: \mandarin,
	phoneset: \xsampa

] }, music:{|p b e|
	{
		e.playbuf
		// => p.synthVTracks.at(e.key).()
	}.play
});
P.synthV(\an, take: \lower, 
	// offset: Song.pianoQuarters[..4].sum,
	pbind: 
	MIDIItem(\foo).take(1).filter({|e|e.select{|f| f.midinote == 4.dm(\c) or: (f.midinote == 3.dm(\c))}[(4..8)++(9..15)]})
	// .midiEvents[0] //1.398 714-398
	.start_(0).synthVPbind,
	params: {|p b| [
	lyrics: " r 美 好 天  回 忆 里 -",
	lag: [0, (0.714-0.39), 0, 0 , 0, 0, 0 ],
 // 美好天 (měi hǎo tiān) - Beautiful day
	pitchTake: 2,
	
	language: \Mandarin
] }, music:{|p b e|
	{
		e.playbuf
		// => p.synthVTracks.at(e.key).()
	}.play
});
P.synthV(\an, take: \endUpper, 
	pbind: 
	MIDIItem(\foo).take(1).fromNote(37, 50).filter{|e| e.select{|i| i.midicmd==\noteOn}[[2, 4, 7, 10]]}
	// MIDIItem(\foo).take(1).fromNote(1, 48).gui
	//.play(\default)//1.714
	.synthVPbind
	.patternpairs ++ [midinote: [1, 7, 7, 11 ].dm(\c)] => _.p,
	params: {|p b| [
	lyrics: " r   梦 不 停 r ",
	legato: [1, 1, 1,  3],
 // 美好天 (měi hǎo tiān) - Beautiful day
	pitchTake: 3,
	language: \Mandarin
] }, music:{|p b e|
	{
		e.playbuf
		// => p.synthVTracks.at(e.key).()
	}.play
});
P.synthV(\an, take: \end, 
	pbind: 
	MIDIItem(\foo).take(1).fromNote(37, 50).filter{|e| e.select{|i| i.midicmd==\noteOn}[[2, 4, 7, 10]]}
	// MIDIItem(\foo).take(1).fromNote(1, 48).gui
	//.play(\default)//1.714
	.synthVPbind,
	params: {|p b| [
	lyrics: " r   梦 不 停 -",
	legato: [1, 1, 1, 1, 4],
 // 美好天 (měi hǎo tiān) - Beautiful day
	pitchTake: 1,
	language: \Mandarin
] }, music:{|p b e|
	{
		e.playbuf
		// => p.synthVTracks.at(e.key).()
	}.play
});
["second halfCh1", "r", Song.pianoQuarters[8..15]].addLine;
P(\ktest, music: { |p b e|
	(instrument: \cymbalsDS).play
});
P.synthV(\xuan, take:  \lead ,  offset: Song.pianoQuarters[..8].sum, 
	pbind: 
	MIDIItem(\foo).take(1).fromNote(0, 75)
	.filter{|e| e.select{|i| i.midicmd==\noteOn}[[48, 51, 53, 58, 61, 62]]}
	// .gui
	.start_(Song.pianoQuarters[..7].sum)
	.synthVPbind
	.patternpairs
	++ [midinote: "-1 1 2 3 3 2 4".dm(\c)] => _.p
	,
	params: {|p b| [
	lyrics: "r 快 乐 的 日 子 像 -",// 流 水 不 停 歇",
	pitchTake: [ 1, 4 ],
	legato: [1, 1, 1, 1, 1,1,  9],
	language: \mandarin,
	phoneset: \xsampa
] }, music:{|p b e|
	{
		e.playbuf
		=> Pan2.ar(_,0)
		// => p.synthVTracks.at(e.key).()
	}.play
});
// MIDIItem(\foo).take(1).notes[50].timestamp;
P.synthV(\an,lag:0.0817, take: \lead2, //lag is fudge factor because of wrong timestamp
	pbind: 
	Song.quantizedKeysV1.fromNote(0, 200)//.gui // use 1 to compensate for removal of 59
	.notes[[63, 67, 69, 72, 76, 80, 83]]
	=> MIDIItemPlayer(_)
	=> _.collect({|e| e.timestamp = e.timestamp - 5.1953})
	=> _.synthVPbind
	,
	params: {|p b| [
		lyrics: " r 美 好 天  回 忆 里 -",
		pitchTake: 1,
		language: \Mandarin,
] }, music:{|p b e|
	{
		e.playbuf
		// => p.synthVTracks.at(e.key).()
	}.play
});
P.synthV(\an, lag:0.0817,take: \lower2, 
	pbind: 
	// MIDIItem(\foo).take(1).fromNote(0, 200)
	Song.quantizedKeysV1.fromNote(0, 200)//.gui // use 1 to compensate for removal of 59
	// .gui
	.notes[[64, 66, 70, 73, 75, 81, 84	] - 1]
	=> MIDIItemPlayer(_) 
	// =>_.gui
	// => _.start_(0)//.play(\default)//1.714
	=> _.collect({|e| e.timestamp = e.timestamp - 5.1953})
	=> _.synthVPbind
	,
	params: {|p b| [
	lyrics: " r 美 好 天  回 忆 里 -",
 // 美好天 (měi hǎo tiān) - Beautiful day
	pitchTake: 2,
	language: \Mandarin,
	// phoneset: \xsampa
] }, music:{|p b e|
	{
		e.playbuf
		// => p.synthVTracks.at(e.key).()
	}.play
});
Song.verseQuarters = Song.pianoQuarters[..7] * 0.99;
["verse1A", "1 5 4 4 4 4 3 2 1.5 -6 1 -7 -6".dm(\g), "e e e q e e q e e q e e e".beats * Song.verseQuarters.mean * 2].addLine;
( Song.verseLyrics = [
	[
		"阳 光 照",
		"微 风 绕",
		"花 香 正 飘 摇",
		"心 情 无 限 - - 好",

		"听 欢 笑",
		"看 飞 鸟",
		"世 界 多 美 妙",
		"真 逍 遥",
	],

	[
		"白云高",
		"彩虹桥",
		"音符在蹦跳",
		"把烦恼丢掉",

		"唱今朝",
		"舞曼妙",
		"时光轻闪耀",
		"乐陶陶",
	]
	//
	// ----------
	// English Translation:
	// Verse 1:
	// Sunshine glows
	// Gentle breeze flows
	// Floral scent sways
	// Mind in blissful phase
	//
	// Hear laughter ring
	// Watch birds take wing
	// World's magic thing
	// Pure joy it brings
	//
	// Verse 2:
	// White clouds high
	// Rainbow nearby
	// Music notes fly
	// Worries goodbye
	//
	// Sing today
	// Dance ballet
	// Time shines its ray
	// Love this display

];
);
// P.tune(_ <> [rest: MuteFirst()].p);
P.synthV(\jun, take: \lead, range: [0, 6],
	params: {|p b| [
	lyrics: 
	"r" + Song.verseLyrics[0][0] + Song.verseLyrics[0][1] 
	,
	
	pitchTake: 1,
	legato: [1,1, 1, 0.8, 1, 1, 0.8],
	language: \mandarin,
	// phoneset: \xsampa,
	vocalMode: \tsubaki
] }, music:{|p b e|
	{
		e.playbuf
		=> {|i|  JPverb.ar(i, t60:1.0, damp:0.0, size:1.0, earlyDiff:0.707, modDepth:0.1, modFreq:2.0, low:1.0, mid:1.0, high:1.0, lowcut:500.0, highcut:2000.0) / 2 + i }
		// => p.synthVTracks.at(e.key).()
	}.play
});
P.synthV(\jun, syl: 6, take: \lead2ndHalf, 
	pbind: {
		[
			midinote: [ 1, -7, -5, -6].dm(\a)
			 ++ [4, 3, 2, 2, 3, 2, 1, 1].dm(\d),
			dur: 
			"q q e eq".beats 
			++ "q q e x xe e q e".beats * Song.verseQuarters.mean
			=> _.flat
			,
		].p
	},
	params: {|p b| [
	lyrics: Song.verseLyrics[0][2] + Song.verseLyrics[0][3]  ,
	legato: [1, 1, 1, 0.8,  1, 1, 1, 1, 1, 1, 1],
	
	pitchTake: 1,
	// legato: [1,1, 1, 0.8, 1, 1, 0.8],
	language: \mandarin,
	// phoneset: \xsampa,
	vocalMode: \tsubaki
] }, music:{|p b e|
	{
		e.playbuf
		=> {|i|  JPverb.ar(i, t60:1.0, damp:0.0, size:1.0, earlyDiff:0.707, modDepth:0.1, modFreq:2.0, low:1.0, mid:1.0, high:1.0, lowcut:500.0, highcut:2000.0) / 2 + i }
		// => p.synthVTracks.at(e.key).()
	}.play
});
P(\keys, music: {|p b e|
	[
		[
			freq: [\r, 
				[3, 5, 11].df(\d),
				[3, 5, 7].df(\d, \mixolydian),
				[3, 5, 7].df(\d, \mixolydian),
				// [2, 5, 7].df(\d, \mixolydian),
				// [2, 5, 7].df(\d, \mixolydian),
				// [2, 5, 6].df(\d, \mixolydian),
				[2, 4, 6, 11].df(\d, \mixolydian),
				[2, 4, 6, 11].df(\d, \mixolydian),
				[2, 4, 5, 7].df(\d, \mixolydian),

			].q,
			dur: "e e e q e e e".beats.q * Song.verseQuarters.mean * 2	
		],
		[
			freq: [\r, 1, -7, -5, -6].df(\a).q,
			dur: "q q q e eq".beats.q * Song.verseQuarters.mean,
			rest: MuteFirst()
		],
		[
			freq: [4, 3, 2, 2, 3, 2, 1, 1].df(\d).q,
			dur: "q q e x xe e q e".beats.q * Song.verseQuarters.mean
		]
	].collect{|i| i ++ [instrument: (~keyInstrument ? \default)] => _.p}.drop(0).q.play;
});
P(\bass,start:2, music:{|p b e |
		var freq= [0,1, 2, 3, 4, 5].df(\d, 3);
		var freqDur= "w w w  h qq".beats - 0.001 * Song.verseQuarters.mean;
	[
		freq: Pseg.new(freq, freqDur,\step ),
		// dur:"qqqe e e eqqe e w hq q".beats.q(1) * Song.verseQuarters.mean,
		dur:"qqqe e e eqqe e e ee ee ee e  |e eqe ee e".beats.q(1) * Song.verseQuarters.mean,
		instrument: \sawSynthSustain
	].pp
});
P(\bassLick, music: { |p b e|
	[
		freq: [2, 2.5, 3, -7, -5, -3].df(\c,3).q,
		dur: "qqqe e e e e eq".beats.q * Song.verseQuarters.mean,
		amp:0.3
	].pp
});
["verse1B", "1 5 4 4 4 4 3 2 1.5 -6 3 4 4".dm(\g), "e e e q e e q e e q e e e".beats * Song.verseQuarters.mean * 2].addLine;
P(\bassLick, music: { |p b e|
	[
		freq: [2, 2.5, 3, -7, -5, -3].df(\c,3).q,
		dur: "qqqe e e e e eq".beats.q * Song.verseQuarters.mean,
		amp:0.3
	].pp
});
P(\bass,start:3, music:{|p b e |
		var freq= [0,1, 2, 3, 4].df(\d, 3);
		var freqDur= "w w w he qq".beats - 0.001 * Song.verseQuarters.mean;
	[
		freq: Pseg.new(freq, freqDur,\step ),
		// dur:"qqqe e e eqqe e w hq q".beats.q(1) * Song.verseQuarters.mean,
		dur:"qqqe e e eqqe e e ee ee ee e  |e eqe ee e".beats.q(1) * Song.verseQuarters.mean,
		instrument: \sawSynthSustain
	].pp
});
P(\keys,start:3, music: {|p b e|
	[
		[
			freq: [\r, 
				[3, 5, 11].df(\d),
				[3, 5, 7].df(\d, \mixolydian),
				[3, 5, 7].df(\d, \mixolydian),
				[2, 5, 7].df(\d, \mixolydian),
				[2, 5, 7].df(\d, \mixolydian),
				[2, 5, 6].df(\d, \mixolydian),
				// [2, 4, 6, 11].df(\d, \mixolydian),
				// [2, 4, 6, 11].df(\d, \mixolydian),
	a			// [2, 4, 5, 7].df(\d, \mixolydian),

			].q,
			dur: "e e e q e e e".beats.q * Song.verseQuarters.mean * 2	
		],
		[
			freq: [\r, 1, -7, -5, -6].df(\a).q,
			dur: "q q q e eq".beats.q * Song.verseQuarters.mean,
			rest: MuteFirst()
		],
		[
			freq: [ 
				[5, 7, 2].df(\c),
				[5, 7, 2].df(\c),
				[3, 5, 11].df(\c),
			].q,
			dur: "e e e e ".beats.q * Song.verseQuarters.mean * 2	
		]
	].collect{|i| i ++ [instrument: (~keyInstrument ? \default)] => _.p}.drop(0).q.play;
});
)

// (
//
//   MIDIItem(\foo).take(1).fromNote(0, 98)
//   .quantize( [ 0.57, 0.57 ].dup(8).flat, nil, {|notes| notes [[0, 9, 13, 19, 22, 31, 39, 44, 48, 55, 62,  70, 72, 80, 85, 94]]})
//    .filter{|e| 
// 	  var note =  e.select{ |i| i.midicmd == \noteOn }[59];
// 	  var off = e.select{|i| i.midicmd == \noteOff and: (i.timestamp >= note.timestamp)}.sort({|x y| x.timestamp < y.timestamp})[0];
// 	  e.remove(note); e.remove(off);e
// 	 }
// 	 // .gui
// 	.recalcSustains
//   .play(\sawSynth)
// )




P.synthV(\jun, take: \lead, range: [0, 6],
	params: {|p b| [
	lyrics: 
	"r" + Song.verseLyrics[0][4] + Song.verseLyrics[0][5] 
	,
	
	pitchTake: 1,
	legato: [1,1, 1, 0.8, 1, 1, 0.8],
	language: \mandarin,
	// phoneset: \xsampa,
	vocalMode: \tsubaki
] }, music:{|p b e|
	{
		e.playbuf
		=> {|i|  JPverb.ar(i, t60:1.0, damp:0.0, size:1.0, earlyDiff:0.707, modDepth:0.1, modFreq:2.0, low:1.0, mid:1.0, high:1.0, lowcut:500.0, highcut:2000.0) / 2 + i }
		// => p.synthVTracks.at(e.key).()
	}.play
});
P.synthV(\jun, syl: 6, take: \lead2ndHalf, 
	pbind: {
		[
			midinote: [ 1, -7, -5, -6].dm(\a)
			 ++ [3, 3, 4].dm(\g),
			dur: 
			"q q e eq".beats 
			++ "q q q".beats * Song.verseQuarters.mean
			=> _.flat
			,
		].p
	},
	params: {|p b| [
	lyrics: Song.verseLyrics[0][6] + Song.verseLyrics[0][7]  ,
	legato: [1, 1, 1, 0.8,  1, 1, 1, 1, 1, 1, 1],
	
	pitchTake: 1,
	// legato: [1,1, 1, 0.8, 1, 1, 0.8],
	language: \mandarin,
	// phoneset: \xsampa,
	vocalMode: \tsubaki
] }, music:{|p b e|
	{
		e.playbuf
		=> {|i|  JPverb.ar(i, t60:1.0, damp:0.0, size:1.0, earlyDiff:0.707, modDepth:0.1, modFreq:2.0, low:1.0, mid:1.0, high:1.0, lowcut:500.0, highcut:2000.0) / 2 + i }
		// => p.synthVTracks.at(e.key).()
	}.play
});
