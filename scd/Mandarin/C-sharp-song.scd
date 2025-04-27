(
Song('c#', []).current;
Song.quarter = 0.687;
["夏雨薇", "3 4 5 4 3 2 4 ".dm(\c), "e e qqqe e e e qq".beats * Song.quarter].addLine;
P.synthV(\jun, take: \lead, params: {|p b| [
	lyrics: "夏 雨 薇 风 轻 轻 唱",
	pitchTake: 1,
	language: \mandarin,
	phoneset: \xsampa,
	vocalMode: \tsubaki
] }, music:{|p b e|
	{
		e.playbuf
		/4
		// => p.synthVTracks.at(e.key).()
	}.play
});
P.synthV(\kevin, take: \lead, params: {|p b| [
	lyrics: "夏 雨 薇 风 轻 轻 唱",
	pitchTake: 1,
	language: \mandarin,
	phoneset: \xsampa
] }, music:{|p b e|
	{
		e.playbuf
		/4
		// => p.synthVTracks.at(e.key).()
	}//.play
});
P(\bass, music: { |p b e|
	[ 
		freq: "1 1 1 1 1 2 2 3 4 4 4 4 4 5 5 6".df(\c, 3).q,
		instrument: \pluckD,
		dur: "e".beats * p.quarter => _.q(inf),
		out: Effect.bus({|i| i/4 },)
	].ppm

});
["花 瓣 落 如 诗- 一- 样-", "-1 2 3 4 3 2 1 2 3 2 1".dm(\c), "q e e qqe e e e e e e e".beats * Song.quarter].addLine;
P(\bass, music: { |p b e|
	[ 
		freq: "2 2 2 2 2 3 3 4 5 5 5 5 5 6 5 6 ".df(\c, 3).q,
		instrument: \pluckD,
		dur: "e".beats * p.quarter => _.q(inf),
		out: Effect.bus({|i| i/4 },)
	].ppm

});
P.synthV(\jun, take: \lead, params: {|p b| [夏雨薇
	// lyrics: " r 花 瓣 落 如 诗 - 一 - 样 -",
	lyrics: "r 月 光 下 她 的 泪 闪 着 光",
	pitchTake: 1,
	language: \mandarin,
	phoneset: \xsampa,
	vocalMode: \tsubaki
] }, music:{|p b e|
	{
		e.playbuf
		/4
		// => p.synthVTracks.at(e.key).()
	}.play
});
["verseRepeat", "3 4 5 4 3 2 4 ".dm(\c), "e e qqqe e e e qq".beats * Song.quarter].addLine;
P.synthV(\jun, take: \lead, params: {|p b| [
	lyrics: "夏 雨 薇 风 轻 轻 唱",
	pitchTake: 2,
	language: \mandarin,
	phoneset: \xsampa,
	vocalMode: \tsubaki
] }, music:{|p b e|
	{
		e.playbuf
		/4
		// => p.synthVTracks.at(e.key).()
	}.play
});
P.synthV(\kevin, take: \lead,
	pbind: {|p b|
		[
			dur: "e e qqq".beats * Song.quarter,
			midinote: "1 2 3".dm(\c)
		].p
	},
	params: {|p b| [
	lyrics: "夏 雨 薇 风 轻 轻 唱",
	pitchTake: 1,
	language: \mandarin,
	phoneset: \xsampa
] }, music:{|p b e|
	{
		e.playbuf
		/4
		// => p.synthVTracks.at(e.key).()
	}.play
});
P.clone('夏雨薇',\bass);
["verseRepeat2", "-1 2 3 4 3 2 1 2 3 2 r".dm(\c), "q e e qqe e e e e e e e".beats * Song.quarter].addLine;
P.synthV(\jun, take: \lead, params: {|p b| [
	lyrics: "r 月 光 下 她 的 泪 闪 着 光 r",
	pitchTake: 2,
	language: \mandarin,
	phoneset: \xsampa,
	vocalMode: \tsubaki
] }, music:{|p b e|
	{
		e.playbuf
		/4
		// => p.synthVTracks.at(e.key).()
	}.play
});
P.synthV(\kevin, take: \lead,
	pbind: {|p b|
		[
			dur: "e e qqq".beats * Song.quarter,
			midinote: "-6 1 2".dm(\c)
		].p
	},
	params: {|p b| [
	lyrics: "月 光 下",
	pitchTake: 1,
	language: \mandarin,
	phoneset: \xsampa
] }, music:{|p b e|
	{
		e.playbuf
		/4
		// => p.synthVTracks.at(e.key).()
	}.play
});
P.clone('花 瓣 落',\bass);
["chorus1", "r", Song.quarter * 16].addLine;
MicroKeys(\pluck).synth = { |gate=1 out=0 |
	var decaytime = \decaytime.kr(10);
	var in=PinkNoise.ar(1);
	var sig=Pluck.ar(
		in: in,
		gate: gate,
		maxdelaytime: 0.02,
		// delaytime: freq * (\poly.kr() / 127 + CC.bend(mk:MicroKeys(\pluck), rawScale: 16384).bus.kr => _.midiratio)   + [0.5, 0, -0.1]=> _.reciprocal,
		delaytime: MicroKeys.freq.() + [0.5, 0, -0.1] => _.reciprocal ,
		decaytime: decaytime,
		coef:  CC(24, mk: \pluck).bus.kr + [0, 0.1, 0.2],
	)
	=> Splay.ar(_)
	* \amp.kr(0.1) * 10
	* Env.asr().kr(2,gate:gate)
	* EnvGen.cutoff(decaytime - 0.1, 0.1)
	=> LeakDC.ar(_)
	/40;
	Out.ar(out,sig);
};
P(\pluck,lag: -0.08, music: { |p b e|
	MIDIItem("241217_102915").take(8).fromNote(218)//.gui
.start_(73)		
// .filter({|i| i.collect{|e| e.amp.notNil.if{e.amp_ (e.amp -30); e}{e}}})
.play(\pluck); // Rocking between c and c#
});
P(\lead, music: { |p b e|
MIDIItem("vox_250424_164001").take(2)
.filter{|i|i.collect{|e| e.amp.notNil.if{e.amp_(e.amp/10);e}{e}}}
.play(\sawSynthSustain);
MicroKeys.mono(\ld).synth_(\stringyy, [release: 3]);//.add(\quiet, {|e| e.vel.notNil.if{ e.vel = e.vel / 2 }; e}, \addBefore, \synth);
// .monitor
// .record
MIDIItem("241220_132623")
// .record(\ld) 
.filter({|i| i.collect{|e| e.amp.notNil.if{e.amp_ (e.amp * 2 ); e}{e}}})
.start_(3)
.play(\ld);
});
)

