(
Song(\littleSketch, []).current;
Song.quarter= 0.6;
Song.language = [language: \mandarin, phoneset: \xsampa];
["line1", "3 5 1 3 4 3 5 1 3 4".dm(\c), "e e e e qq e e e e qq".beats * Song.quarter].addLine;
P.synthVVST(\xuan2,lag:0.00, take: \lead, params: {|p b k| [
	lyrics: "你 的 香 - 水  太 遥 不 可 及",
	// pitchTake: [3, 1],
	legato: [1, 1, 1, 1, 0.6, 1, 1, 1, 1, 0.6],
	singers:2,
	pitchTake:3,
	// lag:0.05!10,
	lag: [0.05,0],
	// tension:1!10,
	midinote: "3 5 1 3 4 3 5 1 3 4".dm(\c),
	dur: b,
] }, music:{|p b e|
	{
		e.bus.() =>Mix.ar(_) => Pan2.ar(_,-1)
		/2
	}.play
});
P(\line, music: { |p b e|
	[
		freq: [\r] ++ ("3 2 3 4 3 2 1  6 5 11 6  3 2 3 4 5 2 3 1 ".df(\c)) =>_.q(2),
		dur: "e e e e e e e ee e e e qqe e e e e e e e qqqq".beats.q(3) * Song.quarter,
		amp:2,
		instrument:\reedy
	].ppm
});
// P.synthVs(\xuan, take: [\lead, \dbl], params: {|p b| p.language ++ [
// 	lyrics: "你 的 香 - 水  太 遥 不 可 及",
// 	pitchTake: [3, 1],
// 	legato: [[1, 1, 1, 1, 0.6, 1, 1, 1, 1, 0.6]],
// ] }, music:{|p b e|
// 	{
// 		e.playbuf
// 	}.play
// });
P(\line, music: { |p b e|
	[
		freq: [\r, 2, 4, 6, 2, 4, 1].df(\c).q,
		dur: "qq q q qq q q qq".beats * p.quarter => _.q,
		legato:[1,1, 1, 0.9, 1, 1, 1].q,
		   instrument: \sparkTriangle,
		      amp:0.6
		      /2

	].ppma
});

P(\bassNote, music: { |p b e|
	[
		instrument: \defaultPiano,
		freq: [1, 7, 6, 7].df(\c,3, \mixolydian).q(2),
		dur: Song.quarter * 2,
		amp:1.5
	].p.play
});
P.synthVVST(\feng2, take: \descant2, params: {|p b| p.language ++ [
	lyrics: "r 可 我 靠 不 到 你",
	midinote: [\r] ++ [2, 4, 6, 2, 4, 1].dm(\c),
	lyrics: "r 可 我 靠- 不 到 你 可 我 靠- - - 不 到 你 - ",
	midinote: [\r] ++ [2, 4, 5, 6, 2, 1, 4, 5, 2, 4, 5, 6, 7, 6, 5, 4, 5].dm(\c, \mixolydian),
	// pitchDelta: Env([0,0,0,20,0,0,0],"qq q q qq q q qq".beats*p.quarter, \step),
	dur: "qq q q qq q q qq".beats * p.quarter,
	dur: "qq q q E Qq q q E Qq q q E Qe e e e q q q".beats  * p.quarter,
	pitchTake: 3,
	singers: 3,
]}, music: {|p b e|
	{
		e.bus.() => Mix.ar(_) => Pan2.ar(_, 1)
		=> 
{|i|
JPverb.ar(i, t60:3.0, damp:0.0, size:1.0, earlyDiff:0.707, modDepth:0.1, modFreq:2.0, low:1.0, mid:1.0, high:1.0, lowcut:500.0, highcut:2000.0) + i
}
		/2
	}.play
});
P(\midikey, music: { |p b e|
   MicroKeys(\defaultPiano);
   MIDIItem("_250510_151349").play(\defaultPiano);
   MIDIItem("_250510_151349").fromNote(3,5).play(\defaultPiano)
});
["line2", "3 5 1 3 4 7 6 1".dm(\c, \mixolydian), "e e e e q q qq qq".beats * Song.quarter].addLine;
P.synthVVST(\xuan2, lag:-0.05, take:\lead, params: {|p b| p.language ++ [
	lyrics: "我 的 情 - 话 像 过 期 糖 衣",
	pitchTake: 3,
	lag: [ 0.05 ],
	singers: 2,
	dur: b,
	// legato: [[1, 1, 1, 1, 1, 1, 1, 0.6]],
] }, music:{|p b e|
	{
		e.bus.() =>Mix.ar(_) => Pan2.ar(_,-1)
	}.play
});
["line3", "3 5 1 3 4 3 5 1 3 4".dm(\c), "e e e e qq e e e e qq".beats * Song.quarter].addLine;
P.synthVVST(\feng2, take: \descant3, params: {|p b| p.language ++ [
	lyrics: "r 可 我 靠 不 到 你",
	midinote: [\r] ++ [2, 4, 6, 2, 4, 1].dm(\c),
	lyrics: "r 可 我 靠- 不 到 你 可 我 靠- - - 不 到 你 - ",
	midinote: [\r] ++ [2, 4, 5, 6, 2, 1, 4, 5, 2, 4, 5, 6, 7, 6, 5, 4, 5].dm(\c, \mixolydian),
	// pitchDelta: Env([0,0,0,20,0,0,0],"qq q q qq q q qq".beats*p.quarter, \step),
	dur: "qq q q qq q q qq".beats * p.quarter,
	dur: "qq q q E Qq q q E Qq q q E Qe e e e q q q".beats  * p.quarter,
	pitchTake: 2,
	singers: 3,
]}, music: {|p b e|
	{
		e.bus.() => Mix.ar(_) => Pan2.ar(_, 1)
		=> 
{|i|
JPverb.ar(i, t60:3.0, damp:0.0, size:1.0, earlyDiff:0.707, modDepth:0.1, modFreq:2.0, low:1.0, mid:1.0, high:1.0, lowcut:500.0, highcut:2000.0) + i
}
		/2
	}.play
});
P.synthVVST(\xuan2,lag:-0.10, take: \lead, params: {|p b k| [
	lyrics: "努 力 练 - 习  优 雅 的 呼 吸",
	legato: [1, 1, 1, 1, 0.6, 1, 1, 1, 1, 0.6],
	singers:2,
	pitchTake:3,
	lag: [0.10],
	midinote: "3 5 1 3 4 3 5 1 3 4".dm(\c),
	dur: b,
] }, music:{|p b e|
	{
		e.bus.() =>Mix.ar(_) => Pan2.ar(_,-1)
	}.play
});
P(\line, music: { |p b e|
	[
		freq: [\r, 2, 4, 6, 2, 4, 1].df(\c).q,
		dur: "qq q q qq q q qq".beats * p.quarter => _.q,
		legato:[1,1, 1, 0.9, 1, 1, 1].q,
		   instrument: \sparkTriangle,
		      amp:0.6

	].ppma
});
P(\midikey, music: { |p b e|
   MicroKeys(\defaultPiano);
   MIDIItem("_250510_151349").play(\defaultPiano);
   MIDIItem("_250510_151349").fromNote(3,5).play(\defaultPiano)
});
["line4", "3 5 1 3 4 7 6 1".dm(\c, \mixolydian), "e e e e q q qq qq".beats * Song.quarter].addLine;
Song.language = [language: \mandarin, phoneset: \xsampa];
P.synthVVST(\xuan2,lag:-0.1, take:\lead, params: {|p b| p.language ++ [
	lyrics: "却 窒 息 在 你 眼 眸 中  ",
	pitchTake: 3,
	midinote: "3 5 1 3 4 7 6 1 ".dm(\c, \mixolydian),
	dur: 
	"e e e e q q qq qq ".beats * Song.quarter
	,
	singers: 2,
	lag:[ 0.1 ],
] }, music:{|p b e|
	{
		e.bus.() =>Mix.ar(_) => Pan2.ar(_,-1)
	}.play
});
Song.ch1Key = \c;
["chorus1", [\r] ++ "5 5 4 3 1 3 2".dm(Song.ch1Key, 5), "q q q ex xq q q q".beats * Song.quarter].addLine;
P(\traps, music: { |p b e|
	[
		instrument: \hat_808,
		dur: "e".beats.q(24) * Song.quarter * 2,
		out: Effect.bus( Phaser2.ar(_,depth:0.9,fb:-0.999,rate:0.13) )
	].pp
});
P.tune();
P.synthVVST(\xuan2, take: \lead, params:{|p b| [
    lyrics: "r 我 永 远 配 不 上 你",
    midinote:
    [\r] ++ "5 5 4 3 1 3 2".dm(\c, [ 5, 6 ]) => _ .flop
    ,
    singers:2
] },music: { |p b e|
{
		e.bus.() => Mix.ar(_) => Pan2.ar(_,-1)
		=> FreeVerb.ar(_,0.2,1)
}.play
});
P(\guitar, music: { |p b e|
	[
	    freq:

	    (Song.ch1Key == \c or: (Song.ch1Key == \cc)).if
{
[
[1, -5, 11, 13, ].df(\g, 4),
[1, -5, 11, 13, ].df(\f, 4),
[1, -5, 11, 13, ].df(\c, 4),
[1, -5, 11, 13, ].df(\f, 4),
]
}


{
[
[1, -5, 11, 13, ].df(\d, 5),
[1, -5, 11, 13, ].df(\c, 5),
[1, -5, 11, 13, ].df(\g, 4),
[1, -5, 11, 13, ].df(\c, 4),
]
} .q,
dur: "qq qq qq qq".beats * p.quarter => _.q,
	    instrument: \harp,
	    instrument: \harpRelease, release:0.05, 
		instrument: Pfunc{( Song.oldGuit.debug("old?") ? false ).if{\harp}{\harpRelease.postln}},
		legato:Pfunc{( Song.oldGuit ? false ).if{0.9}{1}},

	    out: Effect.bus({|i| CrossoverDistortion.ar(i) /2  => Pan2.ar(_, 1)})
].pp
});
P(\bass, music: { |p b e|
	[
	    freq: "5 12 5 4 5 6 7 11 12 13 11 4 11 4".df(

	    (Song.ch1Key == \c or: (Song.ch1Key == \cc)).if{\c}{Song.ch1Key}
		, 3).q,
	    instrument: \sawSynth,
	    dur: "e q e e e e e e e e e e q e".beats * p.quarter => _.q,
	    amp: 1
	].pp
});
["chorus2", [\r] ++ "5 5 4 3 1 3 2".dm(Song.ch1Key, 5), "q q q ex xq q q q".beats * Song.quarter].addLine;
P.tune();
P.synthVVST(\xuan2, take: \lead2, params:{|p b| [
    lyrics: "r 我 只 能 远 远 看 你",
    midinote: 
    // [\r] ++ "5 5 4 3 1 3 2".dm(\c, [ 5, 6 ]) => _ .flop
    [\r] ++ "5 5 4 3 1 3 2".dm(\c,  5 ) => _.bubble ++
	[

    [\r] ++ "5 5 4 3 1 -6 -5 ".dm(\c,  6 ) 
	]
    ,
    singers:2
] },music: { |p b e|
{
		e.bus.() => Mix.ar(_) => Pan2.ar(_,-1)
		=> FreeVerb.ar(_,0.2,1)
}.play
});
P(\guitar, music: { |p b e|
	[
	    freq: 

	    (Song.ch1Key == \c or: (Song.ch1Key == \cc)).if
{
[
[1, -5, 11, 13, ].df(\g, 4),
[1, -5, 11, 13, ].df(\f, 4),
[1, -5, 11, 13, ].df(\c, 4),
[1, -5, 11, 13, ].df(\f, 4),
]
}


{
[
[1, -5, 11, 13, ].df(\d, 5),
[1, -5, 11, 13, ].df(\c, 5),
[1, -5, 11, 13, ].df(\g, 4),
[1, -5, 11, 13, ].df(\c, 4),
]
} .q,
dur: "qq qq qq qq".beats * p.quarter => _.q,
	    instrument: \harp,
	    out: Effect.bus({|i| CrossoverDistortion.ar(i) /2  => Pan2.ar(_, 1)})
].pp
});
P(\bass, music: { |p b e|
	[
	    freq: "5 12 5 4 5 6 7 11 12 13 11 4 11 4".df(

	    (Song.ch1Key == \c or: (Song.ch1Key == \cc)).if{\c}{Song.ch1Key}
		, 3).q,
	    instrument: \sawSynth,
	    dur: "e q e e e e e e e e e e q e".beats * p.quarter => _.q,
	    amp: 1
	].pp
});
["chorus3", [\r] ++ "5 5 4 3 1 3 2".dm(Song.ch1Key, 5), "q q q ex xq q q q".beats * Song.quarter].addLine;
P.tune();
P.synthVVST(\xuan2, take: \lead3, params:{|p b| [
    lyrics: "r 我 隔 着 银 河 望 你",
    midinote: 
    // [\r] ++ "5 5 4 3 1 3 2".dm(\c, [ 5, 6 ]) => _ .flop
    [\r] ++ "5 4 3 2 1 -6 -7".dm(\c,  5 ) => _.bubble ++
	[

    [\r] ++ "5 4 3 2 1 -6 -7 ".dm(\c,  6 ) 
	]
    ,
    singers:2
] },music: { |p b e|
{
		e.bus.() => Mix.ar(_) => Pan2.ar(_,-1)
		=> FreeVerb.ar(_,0.2,1)
}.play
});
P(\guitar, music: { |p b e|
	[
	    freq: 

	    (Song.ch1Key == \c or: (Song.ch1Key == \cc)).if
{
[
[1, -5, 11, 13, ].df(\g, 4),
[1, -5, 11, 13, ].df(\f, 4),
[1, -5, 11, 13, ].df(\c, 4),
[1, -5, 11, 13, ].df(\f, 4),
]
}


{
[
[1, -5, 11, 13, ].df(\d, 5),
[1, -5, 11, 13, ].df(\c, 5),
[1, -5, 11, 13, ].df(\g, 4),
[1, -5, 11, 13, ].df(\c, 4),
]
} .q,
dur: "qq qq qq qq".beats * p.quarter => _.q,
	    instrument: \harp,
	    out: Effect.bus({|i| CrossoverDistortion.ar(i) /2  => Pan2.ar(_, 1)})
].pp
});
P(\bass, music: { |p b e|
	[
	    freq: "5 12 5 4 5 6 7 11 12 13 11 4 11 5 12".df(

	    (Song.ch1Key == \c or: (Song.ch1Key == \cc)).if{\c}{Song.ch1Key}
		, 3).q,
	    instrument: \sawSynth,
	    dur: "e q e e e e e e e e e e e e e".beats * p.quarter => _.q,
	    amp: 1
	].pp
});
["lineB1", "3 5 1 3 4 3 5 1 3 4".dm(\c), "e e e e qq e e e e qq".beats * Song.quarter].addLine;
P(\linelet, music: { |p b e|
	(instrument:\cymbalsDS).play;
	[
		freq: [\r] ++ ("3 2 3 4 3 2 1  6 5 11 6  3 2 3 4 5 2 3 1 ".df(\c, 6)) =>_.q(2),
		dur: "e e e e e e e ee e e e qqe e e e e e e e qqqq".beats.q(3) * Song.quarter,
		legato: 1.dup(19) ++ 0.95 => _.q(2), 
		amp:0.5,
		instrument:\reedy,
		out: Effect.bus({|i| Pan2.ar(i,0) },)
	].ppma
});
P.synthVVST(\xuan2,lag:0.00, take: \lead, params: {|p b k| [
	lyrics: "你 的 项 - 链  是 银 河 标 本",
	// pitchTake: [3, 1],
	legato: [1, 1, 1, 1, 0.6, 1, 1, 1, 1, 0.6],
	singers:2,
	pitchTake:3,
	// lag:0.05!10,
	lag: [0.05,0],
	// tension:1!10,
	midinote: "3 5 1 3 4 3 5 1 3 4".dm(\c),
	dur: b,
] }, music:{|p b e|
	{
		e.bus.() =>Mix.ar(_) => Pan2.ar(_,-1)
		/2
	}.play
});

P(\line, music: { |p b e|
	[
		freq: [\r, 2, 4, 6, 2, 4, 1].df(\c).q,
		dur: "qq q q qq q q qq".beats * p.quarter => _.q,
		legato:[1,1, 1, 0.9, 1, 1, 1].q,
		   instrument: \sparkTriangle,
		      amp:0.6
		      /2

	].ppma
});

P.synthVVST(\feng2, take: \descant2, params: {|p b| p.language ++ [
	lyrics: "r 可 我 靠 不 到 你",
	midinote: [\r] ++ [2, 4, 6, 2, 4, 1].dm(\c),
	lyrics: "r 可 我 靠- 不 到 你 可 我 靠- - - 不 到 你 - ",
	midinote: [\r] ++ [2, 4, 5, 6, 2, 1, 4, 5, 2, 4, 5, 6, 7, 6, 5, 4, 5].dm(\c, \mixolydian),
	// pitchDelta: Env([0,0,0,20,0,0,0],"qq q q qq q q qq".beats*p.quarter, \step),
	dur: "qq q q qq q q qq".beats * p.quarter,
	dur: "qq q q E Qq q q E Qq q q E Qe e e e q q q".beats  * p.quarter,
	pitchTake: 3,
	singers: 3,
]}, music: {|p b e|
	{
		e.bus.() => Mix.ar(_) => Pan2.ar(_, 1)
		=>
{|i|
JPverb.ar(i, t60:3.0, damp:0.0, size:1.0, earlyDiff:0.707, modDepth:0.1, modFreq:2.0, low:1.0, mid:1.0, high:1.0, lowcut:500.0, highcut:2000.0) + i
}
		/2
	}.play
});
P(\midikey, music: { |p b e|
   MicroKeys(\defaultPiano);
   MIDIItem("_250510_151349").play(\defaultPiano);
   MIDIItem("_250510_151349").fromNote(3,5).play(\defaultPiano)
});
["lineB2", "3 5 1 3 4 7 6 1".dm(\c, \mixolydian), "e e e e q q qq qq".beats * Song.quarter].addLine;
P.synthVVST(\xuan2, lag:-0.05, take:\lead, params: {|p b| p.language ++ [
	lyrics: "我 的 真 - 心 是 便 利 店 灯",
	pitchTake: 3,
	lag: [ 0.05 ],
	singers: 2,
	dur: b,
	// legato: [[1, 1, 1, 1, 1, 1, 1, 0.6]],
] }, music:{|p b e|
	{
		e.bus.() =>Mix.ar(_) => Pan2.ar(_,-1)
	}.play
});
["lineB3", "3 5 1 3 4 3 5 1 3 4".dm(\c), "e e e e qq e e e e qq".beats * Song.quarter].addLine;
P.synthVVST(\feng2, take: \descant3, params: {|p b| p.language ++ [
	lyrics: "r 可 我 靠 不 到 你",
	midinote: [\r] ++ [2, 4, 6, 2, 4, 1].dm(\c),
	lyrics: "r 可 我 靠- 不 到 你 可 我 靠- - - 不 到 你 - ",
	midinote: [\r] ++ [2, 4, 5, 6, 2, 1, 4, 5, 2, 4, 5, 6, 7, 6, 5, 4, 4.5].dm(\c, \mixolydian),
	// pitchDelta: Env([0,0,0,20,0,0,0],"qq q q qq q q qq".beats*p.quarter, \step),
	dur: "qq q q qq q q qq".beats * p.quarter,
	dur: "qq q q E Qq q q E Qq q q E Qe e e e q q q".beats  * p.quarter,
	pitchTake: 2,
	singers: 3,
]}, music: {|p b e|
	{
		e.bus.() => Mix.ar(_) => Pan2.ar(_, 1)
		=>
{|i|
JPverb.ar(i, t60:3.0, damp:0.0, size:1.0, earlyDiff:0.707, modDepth:0.1, modFreq:2.0, low:1.0, mid:1.0, high:1.0, lowcut:500.0, highcut:2000.0) + i
}
		/2
	}.play
});
P.synthVVST(\xuan2,lag:-0.10, take: \lead, params: {|p b k| [
	lyrics: "明 明 靠 - 近  又 故 意 转 身",
	legato: [1, 1, 1, 1, 0.6, 1, 1, 1, 1, 0.6],
	singers:2,
	pitchTake:3,
	lag: [0.10],
	midinote: "3 5 1 3 4 3 5 1 3 4".dm(\c),
	dur: b,
] }, music:{|p b e|
	{
		e.bus.() =>Mix.ar(_) => Pan2.ar(_,-1)
	}.play
});
P(\line, music: { |p b e|
	[
		freq: [\r, 2, 4, 6, 2, 4, 1].df(\c).q,
		dur: "qq q q qq q q qq".beats * p.quarter => _.q,
		legato:[1,1, 1, 0.9, 1, 1, 1].q,
		   instrument: \sparkTriangle,
		      amp:0.6

	].ppma
});
P(\midikey, music: { |p b e|
   MicroKeys(\defaultPiano);
   MIDIItem("_250510_151349").play(\defaultPiano);
   MIDIItem("_250510_151349").fromNote(3,5).play(\defaultPiano)
});
["lineB4", "3 5 1 3 4 7 6 1".dm(\c, \mixolydian), "e e e e q q qq qq".beats * Song.quarter].addLine;
Song.language = [language: \mandarin, phoneset: \xsampa];
P.synthVVST(\xuan2,lag:-0.1, take:\lead, params: {|p b| p.language ++ [
	lyrics: "流 星 撞 不 进 大 气 层",
	pitchTake: 3,
	midinote: "3 5 1 3 4 7 6 1 ".dm(\c, \mixolydian),
	dur:
	"e e e e q q qq qq ".beats * Song.quarter
	,
	singers: 2,
	lag:[ 0.1 ],
] }, music:{|p b e|
	{
		e.bus.() =>Mix.ar(_) => Pan2.ar(_,-1)
	}.play
});
// --- end Verse B ---
Song.ch2Key = \G;
["chorusB1", [\r] ++ "5 5 4 3 1 3 2".dm(Song.ch2Key, 5), "q q q ex xq q q q".beats * Song.quarter].addLine;
P(\tamb, music: { |p b e|
	{
		var levels = [3,1,2,1] /3 => _.dq(inf);
		var durs =  
		1/8 ! 16 
		* Song.quarter *2
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
		/4
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
P(\traps, music: { |p b e|
	[
		instrument: \hat_808,
		dur: "x x e e e x x x x e e".beats.q(24) * Song.quarter,
		out: Effect.bus( Phaser2.ar(_,depth:0.9,fb:-0.999,rate:0.13) ),
		amp:0.2,
	].pp;
	[
		instrument:\JWSnare,
		dur:Song.quarter,
		amp:1,
	].pp;
	[
		instrument:\bd_808,
		dur:Song.quarter * "eee x xx x xx  e e".beats.q(3) ,
		dur:Song.quarter * "qq e ee e".beats.q(3) ,
		amp:2,
	].pp;
	
});
P.tune();
P.synthVVST(\xuan2, take: \lead, params:{|p b| [
    lyrics: "r 我 永 远 配 不 上 你",
    midinote:
    [\r] ++ "5 5 4 3 1 3 2".dm(\G, [ 5, 6 ]) => _ .flop
    ,
    singers:2
] },music: { |p b e|
{
		e.bus.() => Mix.ar(_) => Pan2.ar(_,-1)
		=> FreeVerb.ar(_,0.2,1)
}.play
});
P(\guitar, music: { |p b e|
	[
	    freq:

	    (Song.ch2Key == \c or: (Song.ch2Key == \cc)).if
{
[
[1, -5, 11, 13, ].df(\g, 4),
[1, -5, 11, 13, ].df(\f, 4),
[1, -5, 11, 13, ].df(\c, 4),
[1, -5, 11, 13, ].df(\f, 4),
]
}


{
[
[1, -5, 11, 13, ].df(\d, 5),
[1, -5, 11, 13, ].df(\c, 5),
[1, -5, 11, 13, ].df(\g, 4),
[1, -5, 11, 13, ].df(\c, 4),
]
} .q,
dur: "qq qq qq qq".beats * p.quarter => _.q,
	    instrument: \harp,
	    out: Effect.bus({|i| CrossoverDistortion.ar(i) /2  => Pan2.ar(_, 1)})
].pp
});
P(\bass, music: { |p b e|
	[
	    freq: "5 12 5 4 5 6 7 11 12 13 11 4 11 4".df(

	    (Song.ch2Key == \c or: (Song.ch2Key == \cc)).if{\c}{Song.ch2Key}
		, 3).q,
	    instrument: \sawSynthSustain,
		lagTime:0,
		pulse:0.9,
	    dur: "e q e e e e e e e e e e q e".beats * p.quarter => _.q,
	    amp: 1
	].ppm
});
["chorusB2", [\r] ++ "5 5 4 3 1 3 2".dm(Song.ch2Key, 5), "q q q ex xq q q q".beats * Song.quarter].addLine;
P.tune();
P.synthVVST(\xuan2, take: \lead2, params:{|p b| [
    lyrics: "r 我 只 能 远 远 看 你",
    midinote:
    // [\r] ++ "5 5 4 3 1 3 2".dm(\g, [ 5, 6 ]) => _ .flop
    [\r] ++ "5 5 4 3 1 3 2".dm(\G,  5 ) => _.bubble ++
	[

    [\r] ++ "5 5 4 3 1 -6 -5 ".dm(\G,  6 )
	]
    ,
    singers:2
] },music: { |p b e|
{
		e.bus.() => Mix.ar(_) => Pan2.ar(_,-1)
		=> FreeVerb.ar(_,0.2,1)
}.play
});
P(\guitar, music: { |p b e|
	[
	    freq:

	    (Song.ch2Key == \c or: (Song.ch2Key == \cc)).if
{
[
[1, -5, 11, 13, ].df(\g, 4),
[1, -5, 11, 13, ].df(\f, 4),
[1, -5, 11, 13, ].df(\c, 4),
[1, -5, 11, 13, ].df(\f, 4),
]
}


{
[
[1, -5, 11, 13, ].df(\d, 5),
[1, -5, 11, 13, ].df(\c, 5),
[1, -5, 11, 13, ].df(\g, 4),
[1, -5, 11, 13, ].df(\c, 4),
]
} .q,
dur: "qq qq qq qq".beats * p.quarter => _.q,
	    instrument: \harp,
	    out: Effect.bus({|i| CrossoverDistortion.ar(i) /2  => Pan2.ar(_, 1)})
].pp
});
P(\bass, music: { |p b e|
	[
	    freq: "5 12 5 4 5 6 7 11 12 13 11 4 11 4".df(

	    (Song.ch2Key == \c or: (Song.ch2Key == \cc)).if{\c}{Song.ch2Key}
		, 3).q,
	    instrument: \sawSynth,
	    dur: "e q e e e e e e e e e e q e".beats * p.quarter => _.q,
	    amp: 1
	].pp
});
["chorusB3", [\r] ++ "5 5 4 3 1 3 2".dm(Song.ch2Key, 5), "q q q ex xq q q q".beats * Song.quarter].addLine;
P.tune();
P.synthVVST(\xuan2, take: \lead3, params:{|p b| [
    lyrics: "r 我 隔 着 银 河 望 你",
    midinote:
    // [\r] ++ "5 5 4 3 1 3 2".dm(\g, [ 5, 6 ]) => _ .flop
    [\r] ++ "5 4 3 2 1 -6 -7".dm(\g,  5 ) => _.bubble ++
	[

    [\r] ++ "5 4 3 2 1 -6 -7 ".dm(\g,  6 )
	]
    ,
    singers:2
] },music: { |p b e|
{
		e.bus.() => Mix.ar(_) => Pan2.ar(_,-1)
		=> FreeVerb.ar(_,0.2,1)
}.play
});
P(\guitar, music: { |p b e|
	[
	    freq:

	    (Song.ch2Key == \c or: (Song.ch2Key == \cc)).if
{
[
[1, -5, 11, 13, ].df(\g, 4),
[1, -5, 11, 13, ].df(\f, 4),
[1, -5, 11, 13, ].df(\c, 4),
[1, -5, 11, 13, ].df(\f, 4),
]
}


{
[
[1, -5, 11, 13, ].df(\d, 5),
[1, -5, 11, 13, ].df(\c, 5),
[1, -5, 11, 13, ].df(\g, 4),
[1, -5, 11, 13, ].df(\c, 4),
]
} .q,
dur: "qq qq qq qq".beats * p.quarter => _.q,
	    instrument: \harp,
	    out: Effect.bus({|i| CrossoverDistortion.ar(i) /2  => Pan2.ar(_, 1)})
].pp
});
P(\bass, music: { |p b e|
	[
	    freq: "5 12 5 4 5 6 7 11 12 13 11 4 11 5 12".df(

	    (Song.ch2Key == \c or: (Song.ch2Key == \cc)).if{\c}{Song.ch2Key}
		, 3).q,
	    instrument: \sawSynth,
	    dur: "e q e e e e e e e e e e e e e".beats * p.quarter => _.q,
	    amp: 1
	].pp
});
// --- end chorusB ---
)
