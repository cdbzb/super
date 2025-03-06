( // Song version
TempoClock.tempo_(1);
~tempo = 1.08;
~tempo = 0.97;
~tempo = 1.015; //adjusted to match other version!!!
~swing = 0.01;
// ~tempo = 0.96;
		
MicroKeys(\foo).synth_(\default)
// .monitor
;
MicroKeys(\foo).add(\quiet, {|e| e.vel.notNil.if{e.vel = e.vel / 4}; e}, \addBefore, \synth);
Song(\neon2, []).current;

Song.root= \B;
Song.root= \c;
Song.keySig = {|transpose|
	NoteNames.names[Song.root]
	+ ( transpose ? 0 ) 
	=> NoteNames.names.findKeyForValue(_) 
};
["Verse A", "r", [~tempo * 7]].addLine;
P(\bassShort,resources:(transpose:0), music: { |p b e |
	[
		midinote: [ 11, 7, 4, 5, 5, 5, 5  ].dm( p.keySig.(e.transpose).(e.transpose), 3)  => _.q,
		dur: "q*16".beats * ~tempo => _.q,
		instrument: [\harp, \sawSynth ], 
		coef:0.8, amp:[0.03, 0.1],
		out: Effect.bus({|i| i + DelayN.ar(
			i, 
			"e".beats.warpTo(e.tempoMap) /2, 
			"e".beats.warpTo(e.tempoMap) /2, 
		)}),
		rel:0, att:0.1
	].pp
});
P.synthV(\an, take: if(~tempo == 1.015) { \leadSlow } { \lead }, 
	pbind: {
		[
			midinote: [1, 3, -7, 1, 2, 3, 2].dm(Song.keySig.()),
			dur: "q q q q q Q E qq".beats / 2 *  ~tempo 
		].p
	},
	params: {|p b| [
		lyrics: " 霓 虹 灯 照 亮 我 的 脸",
		pitchTake: 1,
		language: \Mandarin,
] }, music:{|p b e|
	{
		e.playbuf
		// => p.synthVTracks.at(e.key).()
		/4
	}.play
});
P(\bass, music: { |p b e|
	[
		freq: [1, -7, -4, [-4, -5], [-4, -5], [-4, -5], [-4, -5]].df(p.keySig.(e.transpose).(), 3).dupEach(4).q,
		dur: ~tempo/4,
		legato: 0.7
	].pp
});
["Verse B", "r", [~tempo * 5]].addLine;
P(\bassShort, music: { |p b e|
	[
		midinote: [ 11, 6.5, 4, 2, 2  ].dm(p.keySig.(e.transpose).(), 3)  => _.q,
		dur: "q*16".beats * ~tempo => _.q,
		instrument: [\harp, \sawSynth ], 
		coef:0.8, amp:[0.03, 0.1],
		out: Effect.bus({|i| i + DelayN.ar(
			i, 
			"e".beats.warpTo(e.tempoMap) /2, 
			"e".beats.warpTo(e.tempoMap) /2, 
		)}),
		rel:0, att:0.1
	].pp
});
P.synthV(\an, take: \lead, 
	pbind: {
		[
			midinote: [3, 5, 2, 3, 4, 6, -7, -7].dm(Song.keySig.()).q,
			dur: "e e e e e E X q".beats * ~tempo
		].p
	},
	params: {|p b| [
	lyrics: "手 机 屏 幕 又 暗 又 冷",
	pitchTake: 1, 
	language: \Mandarin
] }, music:{|p b e|
	{
		e.playbuf
		/4
		// => p.synthVTracks.at(e.key).()
	}.play
});
P(\bass, music: { |p b e|
	[
		freq: [1, -6.5, -4, -2, -2].df(p.keySig.(e.transpose).(), 3).dupEach(4).q,
		dur: ~tempo/4
	].pp
});
["VerseC", "r",[~tempo * 10]].addLine;
P(\bass, music: { |p b e|
	[
		midinote: [ 11, 7, 6, 5, 4.5, 2, -7, -7, 3, 13  ].dm(p.keySig.(e.transpose).(), [2]) + 3 => _.dupEach(4) => _.q,
		dur: ~tempo/4,
		legato: 0.7
	].pp
});
P(\click, music: { |p b e|
	[
		instrument: \hat_808,
		dur: ~tempo /2
	].pp
});
P(\bassShort, music: { |p b e|
	[
		midinote: [ 11, 7, 6, 5, 4.5, 2, -7, -7, 3, 13  ].dm(p.keySig.(e.transpose).(), [2,3]) + 3 => _.q,
		dur: "q*16".beats * ~tempo => _.q,
		instrument: [\harp, \sawSynth ], 
		coef:0.8, amp:[0.03, 0.1] ,
		out: Effect.bus({|i| i + DelayN.ar(
			i, 
			"e".beats.warpTo(e.tempoMap) /2, 
			"e".beats.warpTo(e.tempoMap) /2, 
		)}),
		rel:0, att:0.1,
	].pp
});
P.synthV(\an, take: \lead, 
	pbind: {
		[
			// midinote: "-1 5 2 3 1/f 7.5 3 4 5 11 1 3 4/b/minor/4 4 3 -5/d".dm2,
			midinote: ([-1, 5, 2, 3, 1].dm(Song.keySig.()) + 3) ++ ([7.5, 3, 4, 5, 11, 1, 3, 4].dm(Song.keySig.(), \minor) - 3) ++ ([4, 3, -5].dm(Song.keySig.())) => _.flat ,
			dur: "e x xe x xe x xe x xe x xe x xeqqe e x xe".beats * ~tempo
		].p
	},
	params: {|p b| [
	lyrics: "r 万 家 灯 火 像 星 星    但 我 依 然 感 觉 好 孤 寂 ",
	pitchTake: 1,
	language: \Mandarin
] }, music:{|p b e|
	{
		e.playbuf
		=> {|i| CombN.ar(i, 0.4, 0.4)/3 + i}
		/5
		// => p.synthVTracks.at(e.key).()
	}.play
});
["chorusA","r",[16*~tempo]].addLine;
( //synthDef \bar
{ |gate=1 out=0 freq = 400|
	var in=PinkNoise.ar(1);
	var sig=Pluck.ar(in: in,  gate: gate,  maxdelaytime: 0.02,  delaytime: 1/freq,  decaytime: \decaytime.kr(10),  coef: \coef.kr(0.5),  mul: 0.7,  add: 0);
	sig = sig * \amp.kr(0.1) * 10;
	sig = LeakDC.ar(sig);
	sig = sig * Env.asr.kr(2,gate:gate);
	Out.ar(out,sig);
	DetectSilence.ar(sig,doneAction:2);
} => SynthDef(\bar, _) => _.add;
);
P.synthVs(\an, take: [ \lead, \dbl ], 
	 pbind: {
		 [
			 dur: [ 0.968550166, 0.981686875, 0.931762042, 0.402953125, 0.31382825, 0.352575917, 0.927995083, 0.915147292, 0.822114291, 0.177609834, 0.661958125, 0.831168875, 1.395617541, 0.484949792, 0.258637125, 0.752724667, 0.245841166, 1.136198042, 1.001960917, 0.991963666, 1 ],
			 midinote: 
			 [\r, 64, 67, 72, 74, 72, 69, 65, 72, 76, 77, 76, 76, 79, 77, 76, 74, 72, 67, 65, 64 ]
		 ].p
	 }
	 ,
	 params: {|p b| [
		 lyrics: "r 滑 动 屏- - - 幕 寻 找 共 - - 鸣 数 据 海 洋 中 迷 失 自 己",
		 pitchTake: [ 1, 3 ],
		 language: \Mandarin
	 ]}, music:{|p b e|
		 {
			 e.playbuf
			 // => p.synthVTracks.at(e.key).()
			 /6
		 }.play
 });

P(\bassline, music: { |p b e|
	[
		freq: [11, 7, 6, 5, 4, 3, 2, 1, -7, -7, 4, 3, 2, 2, 5, 5].df(p.keySig.(e.transpose).(),[3, 3]).dupEach(4).q,
		dur: ~tempo/4,
		instrument: [
			\bar , \sawSynth],
		coef: 0.15, amp:[0.01, 0.04],
		// rest: [1, \r].q(inf),
		rel:0.1,
		legato: 0.6,
	].pp
});
P(\bassFigure,  music: {|p b e|
	MIDIItem("bassFigure_250116_161952").take(18)
	// .filter{|i| i.collect{|e| e.sustain.notNil.if{ e.sustain_(e.sustain/2) }}}
	// .filter({|i| i.collect{|e|e.midinote.notNil.if{e.midinote = e.midinote - 24}; e}})
	// .play(\foo, clock: TempoClock(~tempo.reciprocal, queueSize:(2**12)))
	// .record(\foo)
}
);
P(\figureTranscribed, music: { |p b e|
	[
		midinote: [ 
			\r,
			60, 62, 64, 59,
			57, 60, 62, 64, 60, 
			53, 60, 62, 64, 60, 
			50, 60, 62, 64, 50,//60, 
			55, 59, 60, 62, 59,// 53,
			// 53, 60, 62, 64, 60, 
			53, 57, 59, 60, 57,
			50, 60, 62, 64, 60,
			55, 59, 60, 64, 55, 
			48 
		].q - 24,
		legato: [
			1,
			[1, 1, 1, 1, 0.8].q(8)
		].q,
		dur: "qq e e e e".beats.dup(10) / 2 * ~tempo =>_.flat => _.q,
		out: Effect.bus({|i| i.tanh ! 2 => {|i| CrossoverDistortion.ar(i, smooth: 0.995)/3 + i} },),
		instrument: \sawSynthSustain,
		pulse: 0.5,
		out: 3
	].ppma
});
P(\keys, music: { |p b e|
	
		MicroKeys(\stringyy).synth_(\stringyy, [mix:0, release: 1])
		// .monitor
		;
		MicroKeys(\stringyy).add(\quiet, {|e| e.vel.notNil.if{e.vel = e.vel / 4}; e}, \addBefore, \synth);
		MIDIItem("_250116_165156").take(9)
		.fromNoteTo(0, 13)
		.play(\stringyy);
		// .record(\stringyy)

});
P(\lead, music: { |p b e|

 /* a = MIDIItem("_250116_170054").midiEvents.select{|e| e.type == \mk}
 a.collect(_.timestamp).differentiate.registerD
 a.collect(_.midinote).registerD
.play(\stringyy); */
});
P(\tamb, music: { |p b e|
	
	{
		var levels = [3,1,2,1] /3 => _.dq(inf);
		var durs =  
		1/8 ! 16 
		* ~tempo
		// + ( [1, -1] /80 => _.dup(8) ) //swing amt
		+ ([1, -1] * ~swing)
		=> _.flat 
		// => _.warpTo(e.tempoMap.quantizeWindow(0.3))
		=> _.dq(8);
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
P(\drum, music: { |p b e|
	// ~swing = 0.01;
[
	inst: [0, 1, 1, 0, 0, 1, 0, 1, 1, 0, 1, 0, 1].q(8),
	instrument: Pfunc({|e| [\bd_808, \JWSnare][e.inst]}),
	accent: 
	[1, 1, 0.5, 1, 1, 1]
	++ [1, 1, 0.5, 1, 0.5, 1, 1]
	=>_
	.q(inf),
	amp: Pfunc({|e| [0.1, 0.1][e.inst] * e.accent}),
	dur: 
	[1, 0.75 + ~swing, 0.25-~swing, 0.5, 0.5, 1]

	++ [1, 0.75 + 0.03, 0.25-0.03, 0.25, 0.25,  0.5, 1]
	* ~tempo
	/2
	
	=>_
	.q(inf),
	// transientFreq: [0, 200, 200, 0, 0, 200].q(inf),
	// resonanceLength: 0.0905, 
	// resonanceFreq: 86,
].pp;

});
["chorus repeat", "r"].addLine;
Song.cloneDursAndTempoMap("chorusA");
P.clone("chorusA", \figureTranscribed);
P.clone("chorusA", \bassline);
P.clone("chorusA", \lead);
P.clone("chorusA", \keys);
P.synthVs(\an, take: [ \lead, \dbl ], 
	 pbind: {
		 [
			 dur: [ 0.968550166, 0.981686875, 0.931762042, 0.402953125, 0.31382825, 0.352575917, 0.927995083, 0.915147292, 0.822114291, 0.177609834, 0.661958125, 0.831168875, 1.395617541, 0.484949792, 0.258637125, 0.752724667, 0.245841166, 1.136198042, 1.001960917, 0.991963666, 1 ],
			 midinote: 
			 [\r, 64, 67, 72, 74, 72, 69, 65, 72, 76, 77, 76, 76, 79, 77, 76, 74, 72, 67, 65, 64 ]
		 ].p
	 }
	 ,
	 params: {|p b| [
		 lyrics: "r 滑 动 屏- - - 幕 寻 找 共 - - 鸣 数 据 海 洋 中 迷 失 自 己",
		 pitchTake: [ 1, 3 ],
		 language: \Mandarin
	 ]}, music:{|p b e|
		 {
			 e.playbuf
			 // => p.synthVTracks.at(e.key).()
			 /6
		 }.play
});
["VerseA in D", "r"].addLine;
Song.v2Transpose_(2);
Song.cloneDursAndTempoMap("Verse A");
P.clone("Verse A", \bass, (transpose:Song.v2Transpose));
P.clone("Verse A", \bassShort, (transpose:Song.v2Transpose)) ;
P.synthV(\mo,resources:(transpose:Song.v2Transpose), take: \lead, 
	pbind: {
		[
			midinote: [1, 3, -7, 1, 2, 3, 2].dm(Song.keySig.(transpose: 2)),
			dur: "q q q q q Q E qq".beats / 2 *  ~tempo 
		].p
	},
	params: {|p b| [
		lyrics: " 霓 虹 灯 照 亮 我 的 脸",
		pitchTake: 1,
		language: \Mandarin,
] }, music:{|p b e|
	{
		e.playbuf
		// => p.synthVTracks.at(e.key).()
		/4
	}.play
});
)
