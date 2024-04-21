// Sickbay
(
	Song(\chapelForgets,[]).current;

	//effort to "through perform"
	// Song(\chapelForgets2,[]).current; 

	Require("/Users/michael/tank/super/Trek/Songs/boilerplate.scd");
	Trek.cast.mccoy = \jun;
	Trek.presets.put(\mccoy,\jun,[ paramGender: 0.1, paramTension: 0.75 ]);
	["(Chapel is holding the hypos and trying to remember something very important.)","c",[6]].addLine;
P.still(\chapelClose, timecode: 3440.15.seconds, music: { |p b e|
		 e.still.( 
			wait: 1,
			fade:b.sum-1,
			text: ["",""],
		)
});
P(\pad, music: { |p b e|
		{
			Gendy2.arWidth(freq:[1,-1].df(\c)* Pulse.kr(4).range(1,1.midiratio),width:1.midiratio)
			* 0.02
			=> {|i|i + AllpassC.ar(i,0.1,[1].dm(\b,[3,5]).midicps.reciprocal,decaytime:SinOsc.ar(0.1).range(0.5,2),mul:0.45)}
			=> {|i|i + AllpassC.ar(i,0.1,[1].dm(\c,[3,5]).midicps.reciprocal,decaytime:SinOsc.ar([0.09,0.11,0.12,0.13]).range(0.5,2),mul:0.75)}
			* 
			Env([0.1,1,0],[2,9],curve:[0,-2])//.plot
			.kr(2,gate:1)
			=> HPF.ar(_,250)
		}.play
});
	["MCCOY: Nurse, how are the last metabolic readings on our patients?","4 5 4 3 4 5.5 5 4 3 3 2 3 4.5 4.5 5.5".dm(\c)].addLine;
Song.durs.filter(\Nurse,{|i| i * [0.6, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1]});
// Song.durs[\Nurse].list;
// P.tune(\Nurse);
P(\alternateNotes, music: { |p b e|
	[
		freq: " 4 5 5.5 4 3 3 4.5".df(\c,[4, 6 ]).q,
		rest: [\r,1,1, 1, 1, 1, 1].q,
		dur: b.parse([1, 4, 2, 2, 2, 2, 2, 2]).q,
		instrument: \washSus,freqLag:0.2,wet:0, amp:0.05, out: Effect.bus({|i| i=> Pan2.ar(i,0.7) 
		=> HPF.ar(_,200)
	},)

	].ppm;
	[
		freq: "4 3 4  5 3 2 4.5  5.5".df(\c,[4, 6 ]).q,
		dur: b.parse([3, 2, 2, 2, 2, 2, 2, 2]).q,
		instrument: \washSus,wet:0,freqLag:0.2, amp:0.05, out: Effect.bus({|i| i=> Pan2.ar(i,-0.7)
		=> HPF.ar(_,150) 
	},)

	].ppm
});
// P.tune();
P(\pad, music: { |p b e|
	(
		freq: [ -15, -11, -4 ].df(\c),
		instrument: \sawSynthSustain,
		att: 4, rel:b.sum
	).play
});
Song.synthVTracks = EventWithDefault(
	\default, { |mix=0.09|
		{|i|
			i => DWGReverbC1C3.ar(_,mix:mix)
			* -10.dbamp
		}
	}
);
P.still(\twoShot1, timecode: 3443.15.seconds, music: { |p b e|
		 e.still.( 
			wait: b.sum,
			text: ["Nurse, how are the last","metabolic readings"], 
		).sequenceText2(
				b.parse([11]), [ 
				["on our","patients?"]
				],
		)
});
P.synthV(role: \mccoy, take: \lead, params: {|p b| [
		lyrics: "Nurse how are the last metabolic + + + readings + on our patients +",
		pitchTake: 1,
		filter: (midinote: _ - 12), 
		legato:[ 0.7, 1, 1, 1, 0.7, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1 ],
		lag: [0.05, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0]
	] }, music:{|p b e|
		{
			e.playbuf
			=> p.synthVTracks.at(e.key).(mix:0.02)
		}.play
});
	["CHAPEL: You'll find them excellent, Doctor. Well within normal.","3 4 5 7 5 4 4 3".dm(\a,\mixolydian)].addLine;
P.still(\handing, timecode: 3446.1.seconds, music: { |p b e|
		 e.still.( 
			wait: b.sum,
			text: ["you'll find them","excellent, Doctor"],
		)
});
P(\tablas, music: { |p b e|
	// var dropLast = b.drop(1);
	var dropLast = b;
	var denominators = dropLast.collect(3.rand + 2);
	var durs = dropLast.collect{|i x| i / denominators[x] dup: denominators[x]}.flat;
	var pitch = durs.collect{ 
		// [500,200]
		[-5, 1].df('f#', \mixolydian)
		.choose };
	[
		dur: durs.q,
		instrument: \harp,
		freq: pitch.q,
		amp: 0.02,
		out: 2
	].pp
});
P.synthV(role: \chapel, take: \lead, params: {|p b| [
		lyrics: "you'll find them excellent + + Doctor + well within + normal +",
		legato: [1, 1, 1, 1, 1, 1, 1, 0.5, 1, 1, 1, 1, 1],
		pitchTake: 1
	] }, music:{|p b e|
		{
			e.playbuf
			=> p.synthVTracks.at(e.key).()
		}.play
});
P.tune(_ <> [out: Effect.bus({ |i|  i=> FreeVerb.ar(_,0.3,1) => SineShaper.ar(_,0.015,2) })].p);
	["MCCOY: Is something wrong, Miss Chapel?","-7 1 2 3 1 -7 -5".dm(\g,\mixolydian)].addLine;
/* P.still(\asking, timecode: 3452.1.seconds, music: { |p b e|
		 e.still.( 
			wait: b.sum,
			text: ["is something wrong","miss Chapel"],
		)
}); */
P.still(\clear, timecode: 0.seconds, music: { |p b e|
	 e.still.( 
		wait: b.sum,
		text: ["is something wrong","Miss Chapel?"],
	)
});
P.synthV(role: \mccoy, take: \lead, params: {|p b| [
		lyrics: "is something + wrong miss chapel +",
		filter: (midinote: _ - 12), 
		pitchTake: 1
	] }, music:{|p b e|
		{
			e.playbuf
			=> p.synthVTracks.at(e.key).()
		}.play
});
P(\doubling, music: { |p b e|
	[
		freq: [-7, 1, 2, 3].df(\g,[4,5],\mixolydian).q,
		dur:b.q,
		instrument: \washSus,
		out: Effect.bus({|i| i => LPF.ar(_,2100) * 1},inputChannels:2)
	].pp
});
P(\bassnote, music: { |p b e|
		[
			freq: [\r, [-1,1] ].df(\g).q,
			dur: b.parse([3,4]).q,
			out:Effect.bus(DWGReverbC1C3.ar(_))
		].pp
});
	["CHAPEL: Er, yes. I, er, I had something to say. I can't seem to remember.","3 4 3 2 3 4 5 4 3 7 11 6 7 5 6 4 3".dm('a-',\mixolydian)].addLine;
P.still(\closer, timecode: 3454.seconds, music: { |p b e|
		 e.still.( 
			wait: b[..4].sum,
			fade:2,
			text: ["uh yes","I uh"],
		).sequenceText2(
				b.parse([4]), [ 
				["",""],
				],
		)
});
P.still(\clear,syl:3, timecode: 0.seconds, music: { |p b e|
	 e.still.( 
		wait: b.drop(1).sum,
		text:["I had something","to say"],
).sequenceText2(
		b.drop(1).parse([6]), [ 
		["I can't seem","to remember"],
		],
	)
});
P.synthV(role: \chapel, take: \lead, params: {|p b| [
		lyrics: "uh yes I uh I had something + to say I can't seem to remember + +",
		legato: [0.8, 1, 1, 0.8] / 2 ++ [1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1],
		pitchTake: 1
	] }, music:{|p b e|
		{
			e.playbuf
			=> p.synthVTracks.at(e.key).()
		}.play
});
P(\bassnote, music: { |p b e|
		[
			freq: [1,\r, 6.5, 13].df(\c,[4,3]).q,
			dur:b.parse([5,4,6,2]).q,
			out: Effect.bus(DWGReverbC1C3.ar(_))
		].pp
});
P(\fadeNote, music: { |p b e|
		[
			freq:  [1,-1].df('a-',[4]),
			dur: b.sum.q,
			instrument:\sawSynthSustain,
			att:0,
			amp: 0.06,
			out: Effect.bus(_ *  Env([0,0,1,1,0.5], b.parse([2,7,1,7])).kr(2,gate:1) *3)
		].pp
});
P.tune(\Er,Pmul(\freq,[0.5,1],_));
P(\chords, music: { |p b e|
		[
			freq:[1,-5].df('a-'),
			dur:b.parse([1,1,1,1]).q

		].p.play
});
P(\tablas, music: { |p b e|
	// var dropLast = b.drop(1);
	var dropLast = b;
	var denominators = dropLast.collect(3.rand + 2);
	var durs = dropLast.collect{|i x| i / denominators[x] dup: denominators[x]}.flat;
	var pitch = durs.collect{ 
		// [500,200]
		[-5, 1].df('f#', \mixolydian)
		.choose };
	[
		dur: durs.q,
		instrument: \harp,
		freq: pitch.q,
		amp: 0.02,
		out: 3
	].pp
});
["MCCOY: Regarding our patients?","4 5 4 3 7 6".dm(\c,\mixolydian)].addLine;
P(\doubling, music: { |p b e|
	[
		freq: [4, [ 5,11 ], 4, 3, 7, 6  ] .df(\c,4,\mixolydian).q,
		dur:b.q,
		instrument: \washSus,
		legato: [9,9,9,9,10,9, ]/10=>_.q,
		freqLag:0.05,
		out: Effect.bus({|i| i => LPF.ar(_,2100) * 1},inputChannels:2)

	].ppma
});
	P.still(\clear, timecode: 0.seconds, music: { |p b e|
		 e.still.( 
			wait: b.sum,
			text: ["regarding","our patients?"],
		)
	});
P.still(\answer, timecode: 3502.85.seconds, music: { |p b e|
	 /* e.still.( 
		wait: b.sum,
		text: ["",""],
	) */
});
	// P.tune(\Regarding);
P.synthV(role: \mccoy, take: \lead, params: {|p b| [
		lyrics: "regarding + + our patients +",
		legato: [1,1,0.6, 1, 1, 0.5],
		filter: (midinote: _ - 12), 
		pitchTake: 1
	] }, music:{|p b e|
		{
			e.playbuf
			=> p.synthVTracks.at(e.key).()
		}.play
});
["CHAPEL: Yes. That must be it. ","7 11 5 3 1".dm(\f)].addLine;
P(\pluck, music: { |p b e|
	[
		freq: [\r] ++ ( "3 2 1 -5 -4" =>_.df(\f,4) ) =>_.q,
		instrument: \harpRelease,
		legato: 1,
		release: [1, 1, 1, 1, 1, 10].q,
		out: 2,
		coef:0.8,
		dur: b ++ e. bNext =>_.q
	].pp
});
P.still(\clear, timecode: 0.seconds, music: { |p b e|
	 e.still.( 
		wait: b.sum,
		text: ["yes","that must be it"],
	)
});
P.synthV(role: \chapel, take: \lead, params: {|p b| [
	lyrics: "yes, that must be it",
		legato: [0.5, 1, 1, 1, 0.5],
		pitchTake: 1
	] }, music:{|p b e|
		{
			e.playbuf
			=> p.synthVTracks.at(e.key).()
		}.play
});
P(\bassnote, music: { |p b e|
		[
			freq: [\r,1].df(\f,[4,3]).q,
			dur:b.parse([1,4]).q,
			out: Effect.bus(DWGReverbC1C3.ar(_))
		].pp
});
P.tune(\Yes);
["I am so plea -sed the way they are responding, Doctor.","5 4 3 5 6 5 4 3 2  5 4 3 1 -5".dm('b-') ].addLine;
Song.setTempoMap(\plea,"Q Q Q Q Eex x e x e x q q q q");
P(\pluck,syl:8, music: { |p b e|
	[
		freq:[\r,11,5,3,1,-3].df('b-',4).q,
		dur: b.drop(1) ++ e.bNext =>_.q,
		legato: 1,
		release: [1, 1, 1, 1, 1, 10].q,
		out: 3,
		instrument: \harpRelease,coef:0.6, amp:0.08
	].pp
});
P.still(\chapelYes, timecode: 
	// 3513.15 //Yes
	3524.3
	.seconds, music: { |p b e|
	 e.still.( 
		wait: b.sum,
		text: ["I am so pleased","the way they are responding"],
	)
});
P(\chords, music: { |p b e|
	[
		freq: [[-5, 1, -3],[-5, 1, -3],[-5, 1, -3],[-5, 1, -3],[-6, 1, -4], [-5, -7],[-6, 1]].df('b-').q, 
		dur: "Q Q Q Q QQ qq qqqq".asBeats.warpTo( e.tempoMap.quantize ).q,
		instrument: \default,
		// instrument: \harp,
		out: Effect.bus({|i|AnalogVintageDistortion.ar(i,drivegain:1,lowgain:0,highgain:1,smooth: 0.95) / 13 + i /5 },out: 2),
		legato: [0.9,0.9,0.9,1, 1,0.9, 0.9 ].q,

	].ppma
});
P.synthV(role: \chapel, take: \lead, params: {|p b| [
		lyrics: "I am so pleased - the way they are responding + + Doctor +",
		pitchTake: 1
	] }, music:{|p b e|
		{
			e.playbuf
			=> p.synthVTracks.at(e.key).()
		}.play
});
P(\bass, music: { |p b e|
		[
			freq:[1,2,3,4,-5,-6].df('b-',[4,3]).q,
			dur:b.parse([1,1,1,3,4,5,4]).q,
			out: Effect.bus(DWGReverbC1C3.ar(_, mix: Line.kr(1,0.2,b.sum)))
		].pp
});
P.tune(\am);
	["-boom boom- The formula's working perfectly.","3 2".dm(\b,4,\minor) ++ "1 5 4 3 ".dm(\e) ++ "7 11 13 14 13 5".dm(\d)].addLine;
P.still(\clear,syl:1, timecode: 0.seconds, music: { |p b e|
	 e.still.( 
		wait: b.drop(1).sum,
		text: ["the formula's","working perfectly"],
	)
});
P.tune();
P.synthV(role: \chapel, take: \lead, params: {|p b| [
		lyrics: "r r The formula's + + working + perfectly. - + +",
		legato: [1, 1, 1, 1, 1, 0.65, 1, 1, 1, 1, 1, ],
		pitchTake: 1
	] }, music:{|p b e|
		{
			e.playbuf
			=> p.synthVTracks.at(e.key).()
		}.play

});
P(\bass, music: { |p b e|
		[
			freq: [11, 7, 6, 2, 4, 1].df(\d,[2,3]).q,
			instrument: \sawSynthSustain,
			hifreq: 5000,
			amp: 0.09,
			dur: b.parse([1, 1, 1, [1, 1, 0.5],[0.5, 1, 1, 1],[1, 1, 1]]).q
		].ppm
});
P(\xtraNote, music: { |p b e|
	[
		freq: [\r, 5, 4].df(\e).q,
		instrument: \stringyy,
		dur: b.parse([1, 1, 1, [1, 1, 0.5],[0.5, 1, 1, 1],[1, 1, 1]]).parse([3,2,1 ]).q
	].ppm
});
P(\chords, music: { |p b e|
	[
		freq: [\r, [1, 3, 5].df(\e),[-5, 1, 3].df(\g),[1, 3, 5].df(\d)].q,
		dur: b.parse([1, 1, 1, [1, 1, 0.5],[0.5, 1, 1, 1],[1, 1, 1]]).parse([3,1,1, 1 ]).q,
		instrument: \defaultPiano,
		out: Effect.bus({|i| BPF.ar(i,1100) => SineShaper.ar(_, 0.05, 1.5.dbamp)  },inputChannels:2,out: 3)
	].pp
});
["MCCOY: You look tired, Miss Chapel.","6 4 5 3 2 1".dm('c#')].addLine;
P.tune();
Song.setTempoMap('look tired',"e e ex x e ex");
P.still(\mccoyTired, timecode: 3518.8.seconds, music: { |p b e|
	 e.still.( 
		wait: b.sum,
		text: ["you look tired","Miss Chapel"],
	)
});
P.synthV(role: \mccoy, take: \lead,
	pbind: Song.enlarge(11),
	params: {|p b| [
		lyrics: "You look tired, Miss Chapel + perhaps + you'd care for me to administer + + + ",
		lag:[ 0.1, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0 ],
		legato: [1, 1, 0.8, 1, 1, 0.8, 1, 1, 1, 1, 1, 0.8, 1, 1, 1, 1, 1 ],
		loudness: Env([ 0, 0, 3, 0, 0, 2, 1, 1, 2, 4, 1, 3, 1, 1, 2],b),
		tension: Env([ 0, 0, 0, 0, 0, 1, 1, 1, 0, 4, 1, 1, 1, 1, 2] / 10,b),
		filter: (midinote: _ - 12), 
		vocalMode: \Soft,
		pitchTake: 1
	] }, music:{|p b e|
		{
			e.playbuf
			=>DCompressor.ar(_, ratio:10)
			/2
			=> {|i| Fverb.ar(i,i)/8 + i}
			=> p.synthVTracks.at(e.key).(mix:0)
			// /2
		}.play
});
// P.tune();
P(\bendy, music: { |p b e|
	{
		[5, 3, 2].df('f#',\whole).dq.demand("e e q".asBeats.warpTo( e.tempoMap )).lag2([0,0.5].dq.demand(b.parse([1,3])))
		=> {
			|i|
			SinOsc.ar(i * [1, 3.midiratio /2],0,0.1 * -6.dbamp)
			// i * [1, 3.midiratio /2] => VarSaw.ar(_,0,0.5,0.1)
		}
		
		* Env.linen(0.1,b[..3].sum,1).kr(2,gate:1)
		=> Pan2.ar(_,-0.8)
	}.play;
	{
		[4, 2, 1].df('f#',\whole).dq.demand("e e q".asBeats.warpTo( e.tempoMap )).lag2([0,0.5].dq.demand(b.parse([1,3])))
		=> VarSaw.ar(_,0,0.3,0.1)
		=> DelayN.ar(_,b[..1].sum,b[..1].sum)
		* Env([0,0,1,1,0],b.parse([2,1,2,1])).kr(0,1)
		* -5.dbamp
		=> Pan2.ar(_,0.2)
	}.play
});
P(\connector, music: { |p b e|
	[
		freq: [ \r, 2, 1, -6 ] =>_.df('c#',[5 ]) =>_.q,
		rest: [\r,1,1,1].q,
		// amp: [10,10,5]/10=>_.q,
		dur: "eeee e e e".asBeats.warpTo( e.tempoMap ).q,
		// instrument: \visual_pad, amp:0.3
		instrument:\wash,freqLag:0,amp:0.061,
		// out: Effect.bus({|i| i * Env.linen(0,b.sum-1,2).kr(2,gate:1) }, inputChannels:2)
		legato: [1,1, 0.9, 1, ].q,
	].ppm
});
P(\chords, music: { |p b e|
		[
			freq: [[3,5],[2,4],[1,3]].df('f#',3,\whole).q,
			dur: b.parse([2, 2, 2]).q,
			instrument: \stringyy,wet:0,
			legato: [1, 1, 0.1, ].q,
			release: 2.5,
			amp: 0.5
		].ppm
});
	[" Perhaps you'd care for me to administer (boom) the last few injections.",[ 2,4,2.5,2,1,-7,-6,2,-7,-6,-5 ].dm(\c) ++ [ -4, 5,6,7,11,12,13,11].dm('e-',4) ].addLine;
P(\secondHalfDbl,syl:10,lag:0.1, music: { |p b e|
	[
		freq: [ -4, 5,6,7,11,12,13,11].df('e-').q,
		instrument: \sawSynthSustain,att:3,amp:0.06,
		dur:b.drop(1).q
	].ppm
});
P(\secondHalfDblDelayed,syl:11,lag:0.1, music: { |p b e|
	[
		freq: [ -4, 5,6,7,11,12,13,11].df('e-').q,
		instrument: \sawSynthSustain,att:3,amp:0.03,
		dur:b.drop(1).q,
		out: Effect.bus({|i| i * [0.8,0.2] },)
	].ppm
});
P(\linelet, music: { |p b e|
	[
		freq: [
			[\r, 7, 6, 5],
			[\r, 2, 2, 2 ],
			[\r, 5, 5, 2],
			[\r, 7, 6, 5] * (-1),
		].df(\c).flop .q,
		rest: [\r,1,1,1].q,
		dur: b.parse([8,1,1,1]) => _.q,
		instrument: \default
	].ppm
});
P(\alternateNotes, music: { |p b e|
	[
		freq: [\r,4,2,-7].df(\c,[4, 6 ]).q,
		dur: b.parse([1, 2, 2, 4]).q,
		instrument: \stringyy,wet:0, amp:0.2, out: Effect.bus({|i| i=> Pan2.ar(i,0.7) },)

	].ppm;
	[
		freq: "2  2.5 1 2".df(\c,[3, 6 ]).q,
		dur: b.parse([2, 2, 3, 2]).q,
		instrument: \stringyy,wet:0, amp:0.2, out: Effect.bus({|i| i=> Pan2.ar(i,-0.7) },)

	].ppm
});
P.still(\clear, timecode: 0.seconds, music: { |p b e|
	 e.still.( 
		wait: b.sum,
		text: ["perhaps you'd care for me","to administer"],
	).sequenceText2(
			b.parse([11]), [ 
			["the last few","injections"],
			],
	)
});
	// P.tune();
/* P.synthVs(role: \mccoy, take: [ \lead, \octave ], params: {|p b| [
		lyrics: "Perhaps + you'd care for me to administer + + + r the last few injections + - +",
		filter: [ (midinote: _ - 12), (midinote: _) ], 
		paramTension: 0.1,
		pitchTake: [ 1,3 ]
	] }, music:[(vol:0,hp:20),(vol:-3,hp:150)].collect{|ev| {|p b e|
		{
			e.playbuf
			=> p.synthVTracks.at(e.key).(mix: 0)
			*ev.vol.dbamp
			=> HPF.ar(_,ev.hp)
			// /2
		}.play

	} }); */
P.synthV(role: \mccoy, take: \lead, params: {|p b| 
	b.postln;
	[
	lyrics: "r r r r r r r r r r r r the last few injections + - +",
	lag: [0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0,0,0,0,0,0,0,0.07 ],
	// loudness: Env([5, 0],b.sum),
	loudness: Env( 
		[0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 2,4,2,2,4,2,2 ]
		,b ),
	filter: (midinote: _ - 12), 
	vocalMode: \Soft,
	pitchTake: 1
] }, music:{|p b e|
	{
		e.playbuf
			=>DCompressor.ar(_, ratio:10)
			=> {|i| Fverb.ar(i,i)/8 + i}
			/2
		=> p.synthVTracks.at(e.key).()
	}.play

});
P(\bassline, music: { |p b e|
		[
			freq: [\r,1,-7, 1, 1.5, 1, -6].df(\g,[3,4],\minor).q,
			dur: b.parse([5, 3, [1,0.5],[0.5,1], 2, 3, 4]).q,
			out: Effect.bus({ |i| i*5 
				=>FreeVerb.ar(_,0.4,1)
				=> SineShaper.ar(_,0.2)
				/ 2
			}, inputChannels:2)
		].pp
});
	["CHAPEL: Tired? Well, not at all, Doctor. Thank you for asking.","5 1 2 3 4 2 1".dm('b-',\whole) ++ "5 6 7 12 11".dm(\c)].addLine;
P.still(\chapelTired, timecode: 3523.75.seconds, music: { |p b e|
	 e.still.( 
		wait: b.parse([7]).unbubble,
		text: ["tired?","well not at all, Doctor"],
		// fade: 2
	)	
});
P.still(\clear, timecode: 0.seconds, music: { |p b e|
	 e.still.( 
		wait: b.sum,
		text: ["thank you","for asking"],
	)
});
P.tune();
P(\chords, music: { |p b e|
		[
			freq: [[1,3,5].df('b-',\whole), [5,7,11,13].df('b-',4,\mixolydian), [1,-1,-11,-7].df(\g,\mixolydian),[3,5,11].df(\c)].q,
			dur: b.parse([4,3,3,2]).q
		].pp
});
P.synthV(role: \chapel, take: \lead, params: {|p b| [
		lyrics: "Tired? Well, not at all, Doctor + Thank you for asking +",
		legato: [0.6, 0.8, 1, 1, 1, 1, 0.8, 1, 1, 1, 1, 1, ],
		pitchTake: 1
	] }, music:{|p b e|
		{
			e.playbuf
			=> p.synthVTracks.at(e.key).()
		}.play

});
P(\pad,syl:6, music: { |p b e|
		{
			Gendy2.arWidth(freq:[1,-1].df(\c)* Pulse.kr(4).range(1,1.midiratio),width:1.midiratio)
			* 0.02
			=> {|i|i + AllpassC.ar(i,0.1,[1].dm(\b,[3,5]).midicps.reciprocal,decaytime:SinOsc.ar(0.1).range(0.5,2),mul:0.45)}
			=> {|i|i + AllpassC.ar(i,0.1,[1].dm(\c,[3,5]).midicps.reciprocal,decaytime:SinOsc.ar([0.09,0.11,0.12,0.13]).range(0.5,2),mul:0.75)}
			* 
			Env([0.1,1,0],[2,9],curve:[0,-2])//.plot
			.kr(2,gate:1)
			=> HPF.ar(_,250)
		}.play
});
	["(Leaves a puzzled McCoy.)","r"].addLine;
	P.still(\puledMccoy, timecode: 3533.2.seconds, music: { |p b e|
		 e.still.( 
			 fadeIn:2,
			wait: b.sum,
			text: ["",""],
			fade: 3
		)
	});

)

