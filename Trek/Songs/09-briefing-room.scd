(
s.waitForBoot { 
	Song(\briefing,[]).current;
	// Require("boilerplate.sc");
	"~/tank/super/Trek/Songs/boilerplate.scd".standardizePath.load;
Song.guitar= ~guitar ? AAS_Strum();
~guitar = Song.guitar;
	{
[ "You`re going to what?","1 2 -7.5 1 6".dm(\a, \minor) ].addLine;
P.synthV(role: \scott, take: \lead, params: {|p b| [
	lyrics: "you're going + to what?",
	filter: (midinote: _ - 12), 
	legato: [1, 1, 1, 1, 0.9, ],
	pitchTake: 1
] }, music:{|p b e|
	{
		e.playbuf
		=> p.synthVTracks.at(e.key).()
	}.play

});
P.tune();
P(\chord, syl:3, music: { |p b e|
			(
				freq: [1, 3, 4.5,6 ].df(\a, \minor),
				dur:0.2
			).play
});
P.still(\scott, timecode: 2044.2.seconds, music: { |p b e|
			e.still.( 
				wait: b.sum,
				text: ["you're going to","what?"],
			)
});
[ "Are they all right in the head, Doctor? ","2 3 1 2 3 4 5 4 2".dm('a-',\whole) ].addLine;
P.synthV(role: \scott, take: \lead, params: {|p b| [
	legato: [1, 0.7, 1, 1, 1, 1, 1, 1, 0.7, ],
	filter: (midinote: _ - 12), 
	lyrics: "Are they all right in the head, Doctor? + ",
	pitchTake: 1
] }, music:{|p b e|
	{
		e.playbuf
		=> p.synthVTracks.at(e.key).()
	}.play

});
P.still(\clear, timecode: 0.seconds, music: { |p b e|
	 e.still.( 
		wait: b.sum,
		text: ["are they alright","in the head, Doctor?"],
	)
});
[ "MCCOY: No comment. ","1 4 1".dm('a-') ].addLine;
Trek.presets.put(\mccoy,\an,[paramGender: 0.33]);
P.synthV(role: \mccoy, take: \lead, params: {|p b| [
	filter: (midinote: _ - 12), 
	lyrics: "no comment +",
	pitchTake: 1,
	paramToneShift: 0.4
] }, music:{|p b e|
	{
		e.playbuf
		=> p.synthVTracks.at(e.key).()
	}.play

});
P.still(\mccoy, timecode: 2048.45.seconds, music: { |p b e|
			e.still.( 
				wait: b.sum,
				text: ["no","comment"],
			)
});
[ "KIRK: A simple transference. Their minds and ours. ","2 3 1".dm('c#')++ "3 2.5 1".dm('e-') ++ "3 2 1 -7".dm(\f) ].addLine;
P.synthV(role: \kirk, take: 
	// \lead
	\high
	, params: {|p b| [
	// filter: (midinote: _ - 12), 
	lyrics: "A simple + transference + + Their minds and ours. ",
	legato: [1, 1, 1, 1, 1, 0.5, 1, 0.7, 1, 0.9, ],
	pitchTake: 1
] }, music:{|p b e|
	{
		e.playbuf
		=> p.synthVTracks.at(e.key).()
	}.play

});
P(\note,syl:6, music: { |p b e|
	(
		instrument: \stringyy,
		attack: 3,
		freq: 1.df(\c, [5]),
		dur: b.drop(1).sum,
		amp: 0.2,
		out:1
	).play
});
P(\chords, music: { |p b e|
	[
		freq: [\r,[5, 7, 11, 13], [4.5, 7, 11, 12.5]].df('e-',[4,5],\mixolydian) => _.q,
		dur: b.parse([3, 1, 2, 3, 1]).q,
		instrument: \stringyy, 
		freqLag:[0, 0.1, 2, 0.1, 0.1 ].q,
		out: (0..3)
	].ppm
});
P(\bassnote, syl:8, music: { |p b e|
	(
		instrument: \defaultPiano,
		freq: 1.df(\d,[2,3]),
		out: Effect.bus({|i| DWGReverbC1C3.ar(i.tanh.tanh) },)
	).play
});
P(\picked, music: { |p b e|
	[
		instrument: \harp,
		freq: [2, 3, 1, -6, -5.5, [5.5,-4]].df('c#', [4,5]).q,
		dur: b.parse([1, 1, 1, 1, 5, 1]).q
	].pp
});
P(\middleVoice, music: { |p b e|
	[
		freq: [\r, 1, -7].df('c#',[5, 6 ]).q,
		dur: b.parse([2, 2, 2]).q,
		instrument: \wash,
		att: 2,
		amp: 0.03
	].ppm;
	[
		freq: [\r, 1, 1.5].df('e-',[5, 6]).q,
		dur: b.parse([6, 3, 1]).q,
		instrument: \sparkTriangle,
		depth: 0.01,
		out:3,
		amp: 0.03

	].ppm

});
P(\line, music: { |p b e|
	fork{
		var vibes = Barrier.collect(
			{
				SinOsc.ar(\freq.kr(400), 0, 0.1)
				* SinOsc.ar(3)
				// * Env.asr(0.04,1,5).kr(2,gate:\gate.kr)
				* Env.perc(0.04,5).kr(2,gate:1)
			}.asDefName;
		);
		vibes = vibes.()[0];
		vibes.postln;
		[
			freq: [\r,1, -7, -5, -3].df(\f,\mixolydian).q,
			dur: b.parse([6, 1, 1, 1, 1]).q,
			instrument: vibes
		].p.trace.play 
	}
});
P.still(\kirk, timecode: 2050.8.seconds, music: { |p b e|
			e.still.( 
				wait: b.sum,
				text: ["a simple","transference"],
			).sequenceText2(
					b.parse([6]), [ 
					["their minds","and ours"],
					],
			)
});
[ "MCCOY: Quite simple. Happens every day. ","1 4 1 1 2 5 3 4".dm('a-') ].addLine;
P.still(\mccoy, timecode: 2048.5.seconds, music: { |p b e|
	 e.still.( 
		wait: b.sum,
		text: ["quite simple","happens every day"],
	)
});
P.synthV(role: \mccoy, take: \lead, params: {|p b| [
	lyrics: "Quite simple. + Happens + evry + day. ",
	filter: (midinote: _ - 12), 
	legato: [1, 1, 0.6, 1, 1, 1, 1, 0.9, ],
	pitchTake: 1
] }, music:{|p b e|
	{
		e.playbuf
		=> p.synthVTracks.at(e.key).()
	}.play

});
[ "KIRK: Scotty, I need your approval, too. Since you'll","3 1 4 3 3 2 1 -7 2 4.5 5".dm(\c) ].addLine;
Song.setTempoMap(\appro,"e e e e ex x e e q e e");
P.synthV(role: \kirk, take: \lead, params: {|p b| [
	lyrics: "Scotty + I need your approval + + too. Since you'll",
	legato: [1, 1, 1, 1, 1, 1, 1, 1, 0.7, 1, 1, ],
	lag: (0.2,0.18..0.02) ++ [0,0],
	pitchTake: 1
] }, music:{|p b e|
	{
		e.playbuf
		=> p.synthVTracks.at(e.key).()
	}.play

});
P(\chords, music: { |p b e|
	[
	lag: (0.2,0.16..0.02) => _.q,
		instrument: \defaultPiano,
		freq: [[-6, 1, 3],[-5, -7, 2],[-4,-6,2]].df(\c).stutter.q,
		// dur: b.parse([4, 4, 3]).q
		dur: "q q q q q q".asBeats.warpTo( e.tempoMap ).q,

		out: Effect.bus({|i| SineShaper.ar(i,0.1,2) => BPF.ar(_,1100, 0.1) * 9=> FreeVerb.ar(_,0.1,1) },inputChannels:2)
	].pp
});
P(\bassnotes, music: { |p b e|
	[
	lag: (0.2,0.12..0.02) ++ [0,0, 0] => _.q,
		freq: [6, 5, 4.5, 4.5, 5, 2].df(\c,3).q,
		dur: b.parse([4,4,1,1, 1, 3 ]).q,
		legato: [0.9,0.9, 1, 1, 0.9,1 ].q,
		instrument: \sawSynthSustain,
		pulse: 0.5
	].ppma
});
P(\doubling, music: { |p b e|
	[
		freq: [\r, [1, 3, 11], [2, 4, 12] ].df(\d,[4,5]).q,
		dur: b.parse([9, 1, 1]).q
	].pp;
	[
		freq: [\r, 5, 5].df(\d).q,
		dur: b.parse([9, 1, 1]).q
	].pp
});
P.still(\kirk, timecode: 2054.seconds, music: { |p b e|
			e.still.( 
				wait: b.sum,
				text: ["scotty","I need"],
			).sequenceText2(
					b.parse([4]), [ 
					["your approval","too"],
					],
			)
});
[ "work with them,(boom) furnishing them all they need to make the android robots. ","4 3 1 -5 4 3 1 -6 5 4.5 4.5 3 2 3 -2.5 -2.5 2.5 2 1 2 1".dm(\d) ].addLine;
Song.durs.filter(\furnish, {|i| var last = i.last; i.dropLast ++ (last * 2)});
P.synthV(role: \kirk, take: \lead, params: {|p b| [
	// filter: (midinote:  _ - 12), 
	lyrics: "work with them, r furnishing + + them all they need  to make the r r android + robots - +",
	legato: [1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 0.6 ],
	pitchTake: 1
] }, music:{|p b e|
	{
		e.playbuf
		=> p.synthVTracks.at(e.key).()
	}.play

});
P.tune();
P(\androidBass,syl:13, music: { |p b e|
	[
		freq: [11, 11, 7, 7, 4 ].df(\f,2).q,
		dur: b.drop(1).parse([ 1, 1, 1, 2, 1]).q
	].pp
});
[ "You won't be working with them, you'll be working with us, /*our bodies.*/","1 2 3 4 3 2 5 2 3 4 5 3 6".dm(\g,\whole) /*++ "4 3 2".dm(\c,6)*/ ].addLine;
P.synthV(role: \kirk, take: \lead, params: {|p b| [
	filter: (midinote: _ - 12), 
	lyrics: "You won't be working + with them, you'll be working + with us, our bodies +",
	legato: [1, 1, 1, 1, 1, 1, 0.8, 1, 1, 1, 1, 1, 0.8, 1, 1, 0.65, ],
	pitchTake: 1
] }, music:{|p b e|
	{
		e.playbuf
		=> p.synthVTracks.at(e.key).()
	}.play

});
P.tune();
[ "They'll be (boom) inside us, and we'll be ...","11 7 1.5 6 6 5.5 4.5 7 6".dm(\g) ].addLine;
P.still(\clear, timecode: 0.seconds, music: { |p b e|
	 e.still.( 
		wait: b.sum,
		text: ["they'll","be"],
	).sequenceText2(
			b.parse([2,1, 3]), [ 
				["",""],
				["inside","us"],
				["and we'll be...",""]
			],
	)
});
Song.insideGain = 8.dbamp;
P.synthV(role: \kirk, take: \lead,
	params: {|p b| [
	filter: (midinote: "11 7 7 3 3 2.5 4.5 7 6".dm(\g,4)), 
	lyrics: "they'll be r inside + us  and we'll be",
	pitchTake: 1
] }, music:{|p b e|
	{
		e.playbuf
		=> p.synthVTracks.at(e.key).()
	}.play

});
P(\tune, music: { |p b e|
	[
		freq: "11 7 3 3 2.5".df(\g).q,
		dur: b.parse([1, 2, 1, 1, 1]).q,
		instrument: \sawSynthSustain,
		pulse:0.6,amp: 0.05 * p.insideGain
	].ppm
});
P(\chords, music: { |p b e|
	[
		freq: [[3, 5, 11], [2, 4.5, 7], -1.5, [1, 3, 6], [1, 3, 6], [-7, 2.5, 5.5]].df(\g,[4,5]).q,
		dur: b.q,
		instrument: \stringyy,
		amp: 0.15 * p.insideGain,
		out: (0..3)
	].pp
});
[ "MCCOY: It all seems rather indecent to me. ","1 5 1 2 5 2 5.5 2 3 6".dm('c#') ].addLine;
P.synthV(role: \mccoy, take: \lead, params: {|p b| [
	lyrics: "it all seems rather + indecent + + to me",
	filter: (midinote: _ - 12), 
	pitchTake: 1
] }, music:{|p b e|
	{
		e.playbuf
		=> p.synthVTracks.at(e.key).()
	}.play

});
P.still(\mccoy, timecode: 2105.4.seconds, music: { |p b e|
			e.still.( 
				wait: b.sum,
				text: ["it all seems","rather"],
			).sequenceText2(
					b.parse([5]), [ 
					["indecent","to me"],
					],
			)
});
[ "MULHALL: I'm not so certain of that, Doctor.","11 7 11 7 6 5 7 5 4.5".dm(\f)].addLine;
P.still(\clear, timecode: 0.seconds, music: { |p b e|
	 e.still.( 
		wait: b.sum,
		text: ["I'm not so certain","of that, Doctor"],
	)
});
P(\chords, music: { |p b e|
	[
		freq: [[1, 3, 5, 11], [1, 3, 5, 7], [1, 3, 5, 11], [1, 3, 5,7]].df(\f).q,
		dur: b.q
	].pp
});
P(\bassnotes, music: { |p b e|
	[
		freq: [\r, 3,].df(\e, [ 3, 4],\minor).q,
		dur: b.parse([9,1]).q,
		instrument: \defaultPiano
	].pp
});
P.tune();
P.synthV(role: \mulhall, take: \lead, params: {|p b| [
	filter: (midinote: _ - 12), 
	lyrics: "I'm not so certain + of that Doctor +",
	pitchTake: 1
] }, music:{|p b e|
	{
		e.playbuf
		=> p.synthVTracks.at(e.key).()
	}.play

});
["(boom) It is scientifically fascinating. ","-5.5 1 2 3 4 3 2 1 7 6 5 4".dm(\b,\mixolydian) ].addLine;
P(\bassnotes, music: { |p b e|
	[
		freq: [5.5, 5, 4].df(\b,[2, 3 ]).q,
		dur: b.parse([3, 5, 4]).q,
		instrument: \defaultPiano
	].pp
});
P(\connectorChord,syl:7, music: { |p b e|
	(
		freq: [5, 1, 11].df(\e,6),
		instrument: \stringyy
	).play;
	[
		freq: [ 4, 3, 2, 1 ].df(\e,6).q,
		dur: b.drop(1).q,
		instrument: \sawSynthSustain
	].ppm

});
P.synthV(role: \mulhall, take: \lead, params: {|p b| [
	filter: (midinote: _ - 12), 
	lyrics: "r it is scientific + + + lee fascinating + + +",
	pitchTake: 1
] }, music:{|p b e|
	{
		e.playbuf
		=> p.synthVTracks.at(e.key).()
	}.play

});
P.still(\mulhall, timecode: 2110.1.seconds, music: { |p b e|
			e.still.( 
				wait: b.sum,
				text: ["",""],
			).sequenceText2(
					b.parse([1]), [ 
					["it is","scientifically fascinating"],
					],
			)
});
	}.();
[ "SPOCK: (boom) Once inside their mechanical bodies, engineer, they can leave this planet,"," -1 1 2 3 2 3 4 3 2 3 1 -5 -6 -5 5 4 3 2 4 3 ".dm('a-', octave:4)].addLine; 
P.still(\spock2,syl:0, timecode: 2117.3.seconds, music: { |p b e|
	 e.still.( 
		wait: b.sum,
		text: ["once inside their","mechanical bodies, engineer"],
	).sequenceText2(
			b.parse([13,6]), [ 
			["they can leave","this planet"],
			],
	)
});
P.tune();

Song.setTempoMap(\mechanical,"q e e q e e q e e e e e e ee e e Q E Q E ");
P(\click, music: { |p b e|
	[
		instrument: \hihat,
		dur: 1!32 warpTo: e.tempoMap => _.q
	]
	//.pp
});
Song.mechanicalBass = {
	|i|
Pulse.ar(i.freqSeq / [1,2] * SinOsc.ar(4).range(0.999,1.001),0.1,0.1) 
	* [0.3,1]
	=> Mix.ar(_)
	* Env.asr().kr(2,gate: i.gateSeq)
	+ Env.perc().kr(0,gate:i.gateSeq * i.trigSeq)
	=> MoogVCF.ar(_, fco:i.freqSeq*15 * i.gateSeq=>_.lag2(0.5), res:0.2, mul:1, add:0)
	=> {|i| [i,Silent.ar(numChannels:1),Silent.ar(numChannels:1),0.2 * DWGReverbC1C3.ar(i, len:2000, c1:1, c3:10, mix:1, coefs:nil, perm:nil, doprime:0)]}
	/ 2
};
P.synthV(role: \spock, take: \nil, params: {|p b| [
	lyrics: "r once inside + their mechanical + + + bodies + engineer + + they can leave this planet + ",
	legato: [1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 0.7, 1, 1, 1, 1, 1, 0.8, ],
	filter: (midinote: _ - 12), 
	vocalMode: \Rough
	// pitchTake: 1
] }, music:{|p b e|
	{
		e.playbuf
		=> p.synthVTracks.at(e.key).()
	}.play

});
P.double(role:\spock, take: \nil, params: {|p b| [
	pitchTake:2
] }, music:{|p b e|
	{
		e.playbuf
		=> p.synthVTracks.at(e.key).()
	}.play
});
P(\bass, music: { |p b e|
	MegaBind(
		[
			[1, 5, 1, 5, 1, 6, 1, 5, 1, -7, -6.5  ]
		].df('a-',3)
		,
		"e eq e eq e eq e eq qq qE Q".asBeats.warpTo(e.tempoMap),
		[ ],
		p.mechanicalBass
		,
		{|i|  Mix.ar(i)}
	).play
});
P(\figure, music: { |p b e|
	[
		freq: [1,5,11,12,11,12,13, 11, -5].df('a-').q,
		dur:"q*9".beats.warpTo( e.tempoMap ).q
	].pp
});
[" travel back with us.","3 4 4 5 3 2 1".dm(\c) ].addLine;
P.still(\clear, timecode: 0.seconds, music: { |p b e|
	 e.still.( 
		wait: b.sum,
		text: ["travel back","with us"],
	)
});
P.synthVs(role: \spock, take: [\lead, \double], params: {|p b| [
	lyrics: "travel + back - with - us",
	// filter: (midinote: _ - 12), 
	pitchTake: [nil, 3],
	legato: [[1, 1, 1, 1, 1, 1, 0.9, ]],
] }, music:{|p b e|
	{
		e.playbuf
		=> p.synthVTracks.at(e.key).()
	}.play

});
P.tune();
P(\bass, music: { |p b e|
	MegaBind(
		[
			[6, 3]
		].df('a-',2)
		,
		b.parse([ [ 3, 0.33 ],4 ]),
		[ ],
		p.mechanicalBass,
		{|i|  Mix.ar(i)}
	).play
});
[ "With their knowledge, mankind could leap ahead ten thousand years. ","1 5 4 3 r 5 5 4 ".dm(\f) ++ " 5 4 4 3 2 1 3".dm(\g) ].addLine;
Song.setTempoMap(\leap,"e | ee e e|e e ex xe ee e ee e ee e q");
P.still(\clear, timecode: 0.seconds, music: { |p b e|
	 e.still.( 
		wait: b.sum,
		text: ["with their","knowledge"],
	).sequenceText2(
			b.parse([4, 3, 3]), [ 
			// ["",""],
			["mankind", "could"],
			["lead ahead","ten thousand years"]
			],
	)
});
P(\click, music: { |p b e|
	e.tempoMap.postln;
	[0.5] ++ ( 1!8 ) warpTo: e.tempoMap 
	=> { |i| [
		dur:i.q,
		instrument:\hihat,
	]
	// .pp
}
});
// P.tune();
P(\line, music: { |p b e|
	[
		freq: [\r, [1,3],2, 2 ].df(\f,[4,5]).q,
		dur: b.parse([ 1, 3, 1, 2 ]).q,
		amp: 0.1
	].pp
});
P(\chord,syl:13,lag:-1, music: { |p b e|
	(
		instrument:\stringyy,
		freq: [-7,1, 3, 5, 7].df(\g,\mixolydian),
		att:2,
		dur:3,
		amp:[ 2, 1, 1, 1, 2 ]/10,
		wet:0.2

	).play
});
P(\chords,syl:6, music: { |p b e|
	MegaBind(
		[
			[5,  4,  4,  3,  2,  1,  3],
			[2,  2,  2,  -7, -7, \r, 1],
			[-7, -7, -7, -3, -2, \r, -3],
			[5,  4,  4,  3,  2,  1,  3].shiftOctaves(-1)
                        ,
		].df(\g),
		b.drop(1),
		[

		],
		{|i x|  
			[Saw,LFTri,Pulse,SinOsc][x].ar
			// SinOsc.ar
			(i.freqSeq * LFBrownNoise2.ar().range(0.99,1.01),0.1,0.1)
			* Env.asr().kr(0,gate:i.gateSeq)
			+ Env.perc().kr(0,gate:(i.trigSeq * i.gateSeq))
			 => 
			 {|i|
				 HPF.ar(i,490)
				 * Env([0,1],0.1).kr(0,gate:1)
				 => {|i| CombN.ar(i,delaytime:0.1.rrand(0.2),decaytime:2) }
				 => {|i| CombN.ar(i,delaytime:0.1.rrand(0.2),decaytime:2) }
				 + ( i => HPF.ar(_,90) )

			 }
			=> FoaEncode.ar(_,Song.encoders.omni)
			=> FoaTransform.ar(_, 'press',pi/2, LFBrownNoise2.ar(5).range(-pi,pi),LFBrownNoise2.ar(1)*pi)
			// => FoaTransform.ar(_,'pressZ',SinOsc.ar(1))
			
		},
		{|i|  
			Mix.ar(i)
			/2.5
			 => FoaDecode.ar(_,Monitors.decoder)
		}
	).play
});
P.synthVs(role: \spock, take:[ nil, 3 ], params: {|p b| [
	lyrics: "with their knowledge + mankind + could leap ahead + ten thousand + years",
	// vocalMode:\Open,
	legato: [[1, 1, 1, 0.9,  1, 1, 0.8, 1, 1, 1, 1, 1, 1, 1]]
] }, music:{|p b e|
	{
		e.playbuf
		=> LeakDC.ar(_)

		=> p.synthVTracks.at(e.key).()
	}.play
});
P(\moreChords, music: { |p b e|
	Song.guitar.setPlayMode(\strum);
	fork{ "eqqqq".asBeats.warpTo( e.tempoMap ).unbubble.wait;
	Song.guitar.setPlayMode(\pick);
};

	[
		freq: [\r,[-1, 5, 13,21, 25],[-7,2,5],-16].df(\f,\mixolydian).q,
		dur: "e qq qq e".asBeats.warpTo( e.tempoMap ).q,
	].p
	+= [
		switch: [\one].q(inf),
		dur: "e qq qq e".asBeats.warpTo( e.tempoMap ).q
	]
	<> (
		\out: Effect.bus( { |i| 
			FreeVerb.ar(i,0.4,1) 
			=> SineShaper.ar(_,0.02,1)
			* [0.5,2]
		}, inputChannels:2),
		type: \strum,
		instance: p.guitar
	) => _.play
});
P(\bass, music: { |p b e|
	[
		freq: [\r, 11, 7,  6,  6, 12, 6, 12 ].df(\f, [2,3], \mixolydian) =>_.q,
		dur:  "e,  qq, qq, qe, e, qe,  qe,  q".asBeats warpTo: e.tempoMap 
		=> _.q,
		amp:0.05,

		out: Effect.bus(DWGReverbC1C3.ar(_))
		// dur: b.parse([1,[2, 0.5], [0.5,2,0.5 ],[0.5, 2 ],1, 1,1, 1,1, 1]).postln.q
	].pp
});
[ "KIRK: Bones, they'll show us medical advances,","7 6 7 5 7 6 5 4 6 5".dm('f#',4,\mixolydian) ].addLine;
P.still(\kirkBonesShow, timecode: 2124.1.seconds, music: { |p b e|
	 e.still.( 
		wait: b.sum,
		text: ["Bones they'll show us","medical advances"],
	)
});
Song.makeBassNote = { |root = 'f#' release = 2 shorten = 0 out=0|
P(\bassnote, music: { |p b e|
		{
			[-11,1].df(root,3)
			=> { |i| Saw.ar( i + Gendy1.kr(minfreq:1,maxfreq:2) )}
			=> { |i| Convolution.ar(i,Dust.ar(1.df(root)) 
		) + i }
			// / 50
			=>DWGReverb3Band.ar(_,rtlow:5)
			=> LPF.ar(_,1200)
			/ 22
			* EnvGen.cutoff(b.sum - shorten, release)
			=> Out.ar(out,_)
		}.play
});
};
Song.makeBassNote.('f#', 4, shorten:3);
P(\chords, music: { |p b e|
	[
		freq: [ [1,3,5,7], [1,2,4,7],[1,3,6], [1,3,5]].df('f#',\mixolydian).q,
		dur: b.parse([4,4,1,1]).q,
		instrument: \visual_pad, amp:0.2
	].ppm
});
P.synthV(role: \kirk, take: \lead, params: {|p b| [
	lyrics: "  Bones, they'll show us medical + +  advances + + ,",
	pitchTake: 1,
	legato: [0.8, 1, 1, 1, 1, 1, 1, 1, 1, 0.5]
] }, music:{|p b e|
	{
		e.playbuf
		=> p.synthVTracks.at(e.key).()
	}.play
});
P.double(role: \kirk, take: \lead, params: {|p b| [
] }, music:{|p b e|
	{
		e.playbuf
		=> p.synthVTracks.at(e.key).()
	}.play

});
// P.tune();
P(\line, music: { |p b e|
	[
		freq: "3  2 3 ".df('f#').q/2,
		legato:1,
		dur: b.parse([[3,1],4,2]).q,
		instrument: \sparkTriangle,
		depth:0.01
	].pp
});
[ "miracles you never dreamed possible.","7.5 11 5  4 5 6 12 11 7 6".dm(\c,\mixolydian) ].addLine;
P.still(\clear, timecode: 0.seconds, music: { |p b e|
	 e.still.( 
		wait: b.sum,
		text: ["miracles you","never dreamed possible"],
	)
});
Song.makeBassNote.('c',3,shorten:4);
P.synthV(role:\kirk,take:\lead, params: {|p b| [
	lyrics: "miracles + + you never + dreamed possible + +",
	pitchTake:1,
] }, music:{|p b e|
	{
		e.playbuf
		=> p.synthVTracks.at(e.key).()
		=> {|i| 
			CombN.ar(i, b.parse([3]).unbubble, b.parse([2, 0.5]).sum)/2
			* EnvGen.cutoff(b.sum - 0.25,0.2,0)
			+ i 
		}
	}.play
});
P.double(role: \kirk,
	// pbind:{|p b| [ midinote: "1 5 4  3 2 2 2 ".dm(\f) ++ "5 4 4 3 2 1 3".dm(\g) => _.q, dur:b.q ].p},
	// filter: (midinote: _ - 12) ,
	music:{|p b e|
		{
		e.playbuf
		/2

		=> p.synthVTracks.at(e.key).()
	}.play
}
);


P.tune();
P(\bass, music: { |p b e|
	[
		freq: "1 4 7 11".df(\c,[2,3],\mixolydian).q,
		dur: b.parse([ [2,0.5],[0.5,3],1,3 ]).q
	].pp
});
P(\bassPulse, music: { |p b e|
	{
		// var pulse = "e e e e e e q e e e".asBeats.warpTo(e.tempoMap);
		var pulse = b.parse([1, 1, 0.5, 0.5, 1, 1, 1, 0.5, 0.5, 1, 1, 1]);
		var freq = [1, 2, 3, 4, 7, 11].df(\c,[4,5],\mixolydian).dq 
		.demand( b.parse([2, 0.5, 0.5, 3, 1, 3 ]) );

		Saw.ar( freq ) * 0.1
		* Env.perc(0.01,2).kr(0,gate: TDuty.kr(pulse.dropLast.dq,0,1))
		
	}.play
});
[ "Scotty, engineering advances.","1 -7 1 2 3 -7 -6 -6 -5".dm('a-',\mixolydian) ].addLine;
P(\chord2, music: { |p b e|
	[
		freq: [ [1,3,5,7] ].df('a-').q,
		dur: b.parse([4,4,1,1]).q,
		instrument: \visual_pad, amp:0.2
	].ppm
});
P.still(\kirkToScott, timecode: 2126.8.seconds, music: { |p b e|
	 e.still.( 
		wait: b.sum,
		text: ["Scotty,","engineering advances"],
	)
});
P.synthVs(role: \kirk, take: [\lead, \double], params: {|p b| [
	lyrics: "scotty + engineering + + + advances + +",
	legato: [[1, 0.7, 1, 1, 1, 1, 1, 1, 0.8, ]],
	pitchTake: [1,3]
] }, music:{|p b e|
	{
		e.playbuf
		=> p.synthVTracks.at(e.key).()
	}.play

});
P.double(role: \kirk, take: \lead, params: {|p b| [
	pitchTake: 1
] }, music:{|p b e|
	{
		e.playbuf
		=> p.synthVTracks.at(e.key).()
	}.play

});
Song.makeBassNote.('a-',release:3,shorten:2.5);
P(\chord, music: { |p b e|
	(
		instrument: \sawSynthSustain,
		freq: [-1,1,3,5,7].df('a-',4),
		strum:0.05,
		amp:0.06
	).play
});
P.tune();

[ "Vessels this size with engines the size of walnuts. ","3 1 4 3 1".dm(\d) ++ "4 3 1 2 3".dm(\e) ++ "4 3".dm('f#') ].addLine;
P.still(\clear, timecode: 0.seconds, music: { |p b e|
	 e.still.( 
		wait: b.sum,
		text: ["vessels","this size"],
	).sequenceText2(
			b.parse([4]), [ 
			["with engines","the size of walnuts"],
			],
	)
});
P(\lick, music: { |p b e|
	[
		freq: [ [-1,1,3], 1, [2, 4], [1, 3], \r, [-2,2],\r,  [-3,3] ].df(\d).q,
		dur: b.parse([ 1, 1, 1, 1, 1, 2, 3, 2 ]).q,
		legato: [ [4, 1, 1], 1, 1, 1, 1, 1, 1, 1 ].q
	].pp
});
P(\bassline, music: { |p b e|
		{
			var dur = b.parse([5,5,2]) ++ e.bNext.parse([ 2/3, [1/3,1], 2]) =>_.flat ;
			var sig = [1, 2, 3,3, 4.5, 7].df('d').dq.demand(dur) / [2,4]
			=> { |i| Saw.ar( i + Gendy1.kr(minfreq:1,maxfreq:2) )}
			=> { |i| Convolution.ar(i,Dust.ar(50) 
		) + i }
			// / 50
			=>DWGReverb3Band.ar(_,rtlow:5)
			=> LPF.ar(_,1200)
			/ 22
			* EnvGen.cutoff(b.sum / 2 ,b.sum / 2 + e.bNext.parse([3]) + 1);
			// Monitors.az(sig,)
			// sig.flat
			FoaEncode.ar(sig.flat, FoaEncoderMatrix.newQuad)
			=> FoaPush.ar(_,pi/4,[-pi,0,pi,3*pi/2].dq.demand(dur)/2)
			=> Monitors.ambi(_)
		}.play;
});
P.tune();
P.synthV(role: \kirk, take: \lead, params: {|p b| [
	lyrics: "Vessels + this size with engines + the size of walnuts + ",
	legato: [1, 1, 1, 0.8, 1, 1, 1, 1, 1, 1, 1, 1, ],
	pitchTake: 1
] }, music:{|p b e|
	{
		e.playbuf
		=> p.synthVTracks.at(e.key).()
	}.play

});
P.double(role: \kirk, take: \lead, params: {|p b| [
	pitchTake: 1
] }, music:{|p b e|
	{
		e.playbuf
		=> p.synthVTracks.at(e.key).()
	}.play

});
Trek.cast.scott = \an;
[ "SCOTT: Ach! You're joking. ","1 1 4 1".dm('a-') ].addLine;
Song.setTempoMap(\joking,"ex x e e");
P.still(\scott, timecode: 2134.9.seconds, music: { |p b e|
	 e.still.( 
		wait: b.sum,
		text: ["Ach","you're joking"],
	)
});
P(\chord, music: { |p b e|
	[
		freq: [-15,-15, [-5, 1,  5] ].df('c#').q,
		dur: b.parse([1,1,2]).q,
		decaytime: 5,
		strum: -0.05,
		out: Effect.bus({|i|
			i => Pan2.ar(i,0)
			=> SineShaper.ar(_,0.05,4) 
			* SinOsc.ar(3).range(0.5,1)
			/4
	}, inputChannels:2, out:[0,1]),
		instrument: \harp, coef: 0.2,
	].pp
});
P.synthVs(role: \scott, take: [\lead, \double], params: {|p b| [
	lyrics: "awk you're joking +",
	legato: [[0.6, 1, 1, 1, ]],
	pitchTake: [1,3],
	vocalMode:  \Open,
	paramGender:0.2,
	paramToneShift:300,
	paramTension:0.8,
	// paramGender: 0.8,
	filter: (midinote: _ - 12), 
] }, music:{|p b e|
	{
		e.playbuf
		// => p.synthVTracks.at(e.key).()
		/3
	}.play

});
P(\bass, music: { |p b e|
	[
		freq: [\r,[11,1], [-4,4] ].df('a-',3).q,
		dur: b.parse([ 2/3, [1/3,1], 2]).q,
		instrument: \sawSynth
	].pp
});
P(\chord, music: { |p b e|
	[
		freq: [-15,-15, [-5, 1,  5] ].df('c#').q,
		dur: b.parse([1,1,2]).q,
		decaytime: 5,
		strum: -0.05,
		out: Effect.bus({|i|
			i => Pan2.ar(i,0)
			=> SineShaper.ar(_,0.05,4) 
			* SinOsc.ar(3).range(0.5,1)
			/4
	}, inputChannels:2, out:[0,1]),
		instrument: \harp, coef: 0.2,
	].pp
});
P.tune();
[ "SPOCK: No, he's not. ","-5 -5 1".dm('a-') ].addLine;
P(\chord, music: { |p b e|
	[
		freq: [-15,-15, [-1, 1,  5] ].df('a-').q,
		dur: b.parse([1,1,2]).q,
		decaytime: 5,
		strum: -0.05,
		out: Effect.bus({|i|
			i => Pan2.ar(i,0)
			=> DWGReverbC1C3.ar(_,mix:0.2)
			=> SineShaper.ar(_,0.05,4) 
			* SinOsc.ar(3).range(0.5,1)
			/3
			=> Phaser2.ar(_,rate:0.21,fb:0.2)
	}, inputChannels:2, out:[0,1]),
		instrument: \harp, coef: 0.7,
	].pp
});
P.still(\spock, timecode: 2114.5.seconds, music: { |p b e|
	 e.still.( 
		wait: b.sum,
		text: ["no","he's not"],
	)
});
P.synthV(role: \spock, take: \lead, params: {|p b| [
	filter: (midinote: _ - 12), 
	lyrics: "no he's not",

	legato: [0.7,1,0.8 ],

	paramDefaultVibrtatoWidth:0.1,
	pitchTake: 1
] }, music:{|p b e|
	{
		e.playbuf
		// => p.synthVTracks.at(e.key).()
		/2
	}.play

});
P(\bassnote, music: { |p b e|
	[
		freq: [\r, [-5, 5], [1, 11]].df('a-',3).q,
		dur: b.parse([  2/3,[1/3, 1],1 ]).q,
		instrument: \sparkTriangle,width:0
	].pp
});
P.tune();
// idea big vibrato to indicate irony !!
[ "MCCOY: They're giants, and we're insects beside them. "," -5 3 2 1 3 4 3 1 3 2".dm(\e) ].addLine;
P(\cymbalSwell,syl:0, music: { |p b e|
	(
		instrument: \cymbalsDS, att:0.2,amp: 0.02
	).play
});
P.still(\mccoy, timecode: 2137.6.seconds, music: { |p b e|
	 e.still.( 
		wait: b.sum,
		text: ["they're","giants"],
	).sequenceText2(
			b.parse([3]), [ 
			["and we're insects","beside them"],
			],
	)
});
P(\pad, music: { |p b e| //or do this with klank on a cymbal
	[
		instrument: \visual_pad,amp:0.25,rel:9,
		freq: [\r, [-5, 1, 3, 5, 11, 13, 15],[-5, 1, 2, 5, 11, 12, 15], [-6, 1, 4],[-6,1,3],[-5,1,3],[-5,-7,2]  ].df(\e).q,
		dur: b.parse([1,1,3, 1, 2, 1, 1]).q

	].pm.play
});
P.synthV(role: \mccoy, take: \lead, params: {|p b| [
	lyrics: "They're giants + and we're insects + beside + them.",
	legato: [1, 1, 0.8, 1, 1, 1, 1, 1, 1, 1, 1, ],
	paramPitchExpression: 1.5,
	pitchTake: 1
] }, music:{|p b e|
	{
		e.playbuf
		=> p.synthVTracks.at(e.key).()
	}.play

});
// P.tune();
P(\bass, music: { |p b e|
	MegaBind(
		[
			[\r, 5,  6, 5, \_],
			[\r, 3,  1, \_,-7],
			[\r, -1, -4, -5, \_],
			[\r, -1, -4, -5, \_],

		].df(\e)
		,
		b.parse([1,4,3,1,1]),
		[oct:[1,1,1,2]],
		{|i|  
			VarSaw.ar(
				i.freqSeq / i.oct /[1, 2 ] * ( Gendy1.kr(minfreq:[ 1.1,1 ],maxfreq:2) / 50 + 1),0,SinOsc.kr({ 0.2.rrand(1) }!2).range(0.4,0.6))
			* Env.asr().kr(0,gate:i.gateSeq)
			/ 4
		},
		{|i|Splay.ar(i) * 0.1}
	).play
});
[ "They could destroy us without meaning to. "," 1 -7 -6 -6 -5 -6 -7 2 1 -3".dm(\e) ].addLine;
P.still(\clear, timecode: 0.seconds, music: { |p b e|
	 e.still.( 
		wait: b.sum,
		text: ["they could destroy us","without meaning to"],
	)
});
P.synthV(role: \mccoy, take: \lead, params: {|p b| [
	lyrics: "they could destroy + us without + meaning + to ",
	pitchTake: 1,
	paramPitchExpression: 1.5
] }, music:{|p b e|
	{
		e.playbuf
		=> p.synthVTracks.at(e.key).()
	}.play

});
[ "(boom) And all he wants is the body of our captain"," -5 5 6 4 5    6 7 5 6 7 11 13.5 7.5".dm(\c,\minor)].addLine; 
P.still(\clear, timecode: 0.seconds, music: { |p b e|
	 e.still.( 
		wait: b.sum,
		text: ["",""],
	).sequenceText2(
			b.parse([1]), [ 
			["and all he wants","is the body of our captain"],
			],
	)
});
P.synthV(role: \mccoy, take: \lead, params: {|p b| [
	lyrics: "r and all he wants is the body + of our captain +",
	filter: (midinote: _ - 12), 
	pitchTake: 1,
	paramPitchExpression: 1.5
] }, music:{|p b e|
	{
		e.playbuf
		=> p.synthVTracks.at(e.key).()
	}.play

});
P(\bassPad, music: { |p b e|
	[
		instrument:\stringyy,
		width: [0,3, 20,40 ],
		freq: [1,\r,2].df(\g,3) * [0.5,1,1,2] => _.q,
		dur: b.parse([5,8]) ++ e.bNext.parse([8]) => _.q,
		amp: 0.2,
		out: Effect.bus({|i| i},inputChannels:4,out:2)
	].p.play
});
[" (boom) and our second in command, too. Coincidence? "," -6 7 11 6 7 11 12 13 15.5 13 16 14.5 15.5 ".dm(\c,\mixolydian) ].addLine;
P.still(\clear, timecode: 0.seconds, music: { |p b e|
	 e.still.( 
		wait: b.sum,
		text: ["",""],
	).sequenceText2(
			b.parse([1, 8]), [ 
			["and our","second in command too?"],
			["coincidence?"]
			],
	)
});
P.synthV(role: \mccoy, take: \lead, params: {|p b| [
	lyrics: "r and our second + in command +, too. Coincidence? + + + ",
	legato: [1, 1, 1, 1, 1, 1, 1, 1, 0.8,  1, 1, 1, 1, ],
	filter: (midinote: _ - 12), 
	pitchTake: 2,
	paramPitchExpression:1.5
] }, music:{|p b e|
	{
		e.playbuf
		=> p.synthVTracks.at(e.key).()
	}.play

});
P(\bassnote, music: { |p b e|
	(
		instrument:\sawSynthSustain,
		freq:-6.df(\c,3)
	)//.play
});
[ "KIRK: They selected us as the most compatible bodies. ","1 2 3 4 5 4 3 7 11 6 5 4 6 5".dm(\d,5,\mixolydian) ].addLine;
P.still(\kirk, timecode: 2149.95.seconds, music: { |p b e|
	 e.still.( 
		wait: b.sum,
		text: ["they selected","us"],
	).sequenceText2(
			b.parse([5]), [ 
			["as the most compatible","bodies"],
			],
	)
});
P.synthV(role: \kirk, take: \lead, params: {|p b| [
	lyrics: "They selected + +  us as the most compatible + + + bodies + ",
	pitchTake: 1
] }, music:{|p b e|
	{
		e.playbuf
		=> p.synthVTracks.at(e.key).()
	}.play

});
P.double(role: \kirk, take: \lead, params: {|p b| [
	pitchTake: 1
] }, music:{|p b e|
	{
		e.playbuf
		=> p.synthVTracks.at(e.key).()
	}.play

});
//// add a boom before "Most"
P.tune(\selected);
P(\bass,start:\selected,music:{|p b e| 
	[
		freq: [1, 5, -7, -5, -6, -6.5, -4, 2, ].df(\d,[3,4]).q,
		dur: b.parse([ 2/3, [1/3,1], 2, 1, 2, 2, 3, 2  ]).q
	].pp
	
});
P(\chords,start:\selected,syl:6,music:{|p b e| 
	[		
		midinote: 
		[ 
			"3 5 11".dm(\c), "2 5 7".dm(\c),"1 3 6".dm(\d)  ].q
		,
		dur: b.drop(1).parse([2,3,2]).q, 
	out: Effect(FreeVerb.ar(_,0.6,[0.9, 1 ])).bus.index,
	strum:0.054
].pp
});
[ "MCCOY:(boom boom boom boom) What's your attitude on that, Doctor? ", [ -1, -1, -17, -17, -5, 3, -7, 1, -7, -5, 3, 2, 1 ].dm(\a,5,\mixolydian) ].addLine;
P.still(\mccoy,syl:3, timecode: 2154.7.seconds, music: { |p b e|
	 e.still.( 
		wait: b.drop(1).sum,
		text: ["what's your attitude","on that, Doctor"],
	)
});
P(\bass,start:\attitude,music:{|p b e| 
	MegaBind(
			[
				[11, 11, 7, 7, 11, 1].df(\a,3,\mixolydian)
			],
			b.parse([1,1,1,1,5,4]),
			[],
			{|i|
Pulse.ar( i.freqSeq * [1,2.01,3.0201] /4 )
				* (
					Env.asr().kr(gate:i.gateSeq)
					//+ Env.perc().kr(0,gate:(i.trigSeq*i.gateSeq))
				)
				=>MoogFF.ar(_,Env.perc(0.01,0.5).kr(0,gate:(i.trigSeq*i.gateSeq))*4000+1000,0.4)
				* 0.06
			},
			{|i|
				Splay.ar(i) 
				*2
				=> FreeVerb.ar(_,0.3,1)
				=> _.tanh
				/2
			}
		).play
});
P.tune(\attitude,_ <> [rest:[\,\,\,\,1,1,1,1,1,1,1,1,1].q].p);
P.synthV(role: \mccoy, take: \lead, params: {|p b| [
	lyrics: "r r r r What's your attitude + + on that, Doctor +",
	legato: [1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 0.7, 1, 1, ],
	filter: (midinote: _ - 12), 
	pitchTake: 1
] }, music:{|p b e|
	{
		e.playbuf
		=> p.synthVTracks.at(e.key).()
	}.play

});
// ["MULHALL: Well, if we all agree, I'm willing to host Thalassa's mind.","r"].addLine;
//[" ( boom x 7 ) I'm a scientist.  ( boom x 7 ) and I'm","3 4 6 5 7 3 4 11 12 13 14 13 5 3 4 6 5 7 3 4 5 15  ".dm(\b)].addLine;g
[" ( boom x 7 ) I'm a scientist.  ( boom x 7 ) and I'm","3 4 6 5 7 3 4 11 7 11 12 11 3 3 4 6 5 7 3 4 5 15  ".dm(\b)].addLine;
P.still(\mulhall, timecode: 2202.45.seconds, music: { |p b e|
	 e.still.( 
		wait: b[..6].sum,
		fadeIn: b.parse([7]),
		text: ["",""],
	)
});
P.still(\mulhall2,syl:6, timecode: 2208.35.seconds, music: { |p b e|
	 e.still.( 
		wait: b[..6].sum,
		text: ["I'm a scientist",""],
	)
});
P.still(\clear, timecode: 0.seconds, music: { |p b e|
	 e.still.( 
		wait: b.sum + e.bNext,
		text: ["and I'm","willing"],
	)
});
Song.durs.scaleEnv(
	Env([1,0.75],1,curve: 2)//.plot
);
Song.setTempoMap(\scientist,"e e e e eeee e e e x x e x xee e e e e eeee e e e e".asBeats);
// P.tune();
// Song.quarters[\scientist].list.sum;

//Song.durs[\scientist] = Song.durs[\scientist].list 
//* ( 1!13 ++ Array.series(13,1,( 0.25 / 13 * -1)) => _.flat )
//// * 0.75
//=> _.q;
( Song.synthVTracks=EventWithDefault(
	\default, {
		{
			|i|
			var early = 0.5; //early/late mix
			var dryAmount = 1;
			// var wet = 1; //total verb vs dry
			var wet = 0.3; //total verb vs dry
			EarlyRef.ar(i, source:[2,3,2], receiver:[0,0,0], roomsize:[4,5,6], hw:0.2, b:0.97, n:0, p:0, allp_lens:nil, allp_c:0.7)

			=> DWGReverbC1C3.ar(_, len:2000, c1:1, c3:10, mix:1-early * wet,)
			+ ( i * dryAmount )
			 * -15.dbamp
			=> HPF.ar(_,100)
			=> DCompressor.ar(_, sidechainIn:0, sidechain:0, ratio:4, threshold:-40, attack:0.1, release:100.1, makeup:0.5, automakeup:1)
		}
	}, \feng, {

		{
			|i|
			var early = 0.5;
			var dryAmount = 1;
			EarlyRef.ar(i, source:[2,3,2], receiver:[0,0,0], roomsize:[4,5,6], hw:0.2, b:0.97, n:0, p:0, allp_lens:nil, allp_c:0.7)

			=> DWGReverbC1C3.ar(_, len:2000, c1:1, c3:10, mix:1-early,)
			+ ( i * dryAmount )
			/ 6 
			*0.7
			=> HPF.ar(_,100)
			=> DCompressor.ar(_, sidechainIn:0, sidechain:0, ratio:4, threshold:-40, attack:0.1, release:100.1, makeup:0.5, automakeup:1)
		}
	}, \an, {
		{|i| 
			i 
			=> BPF.ar(_,1200,rq:0.3.reciprocal)
			=> FreeVerb.ar(_,0.05,1)
			* -6.dbamp
		}
	}
));
Song.preroll_(1);
Song.setQuarters(\scientist,"q q q q qqqq q q q e e ee e eqq q q q q qqqq q q q q".asBeats);
P.synthV(\feng,  filter: (midinote: _ - 12),  params: {|p b| [
	lyrics: "r r r r r r r I'm a sigh - entist + r r r r r r r and I'm",
	vocalMode: \Opera
] }, music:{|p b e|
	{
		e.playbuf
		  => p.synthVTracks.at(e.key.postln).()
		  // /2
	}.play
});
P.double(\feng, filter: (midinote: _ - 12), music:{|p b e|
	{
		e.playbuf
		=> p.synthVTracks.at(e.key).()
	}
	// .play
});
//P.click(\scientist);
// P.tune(\scientist, _ <> [rest:[\,\,\,\,\,\,\,1,1,1,1,1,1,\,\,\,\,\,\,\,1,1].q].p);
P(\jank,start:\scientist,music:{|p b e| 
	
	[
		freq: [\r,7, 11, 7].df(\b,[2,3]).q,
		dur: "qqqq qqqqqqqq qqqqqqqq qqqq".asBeats.warpTo(p.quarters[e.start]).q ,
		amp:0.4,
		// lag:0.1,
		coef:0.8,
		del:0.7,
		smooth:0.25,
		instrument:\pluckDEnvPan,
		pan: Prand([-1,1],inf),
		legato: 0.125,
		release:1.3,
		out: Effect(
			{ |i| CombN.ar(i,1,(p.quarters[e.start].list.mean),4)
			      + i
			      *0.1
			      // *0.4
		      } ,
		      inputChannels:2
		).bus.index
	].pp
});
P(\lead,start:\scientist,music:{ |p b e|
	MegaBind(
		[
			[3,  4,  6,  5,  7,  \r, \r, \r, \r, \r] .dup(2).flat,
			[\r, \r, \r, \r, \r, 3,  4,  6,  5,  11].dup(2).flat
		].df(\b,3),
		// p.quarters[e.start].list.parse([1,1,1,1,4].dup(3).flat),
		b.parse([1,1,1,1,1, 1,1,1, 2, 3, 1, 1, 1, 1, 1, 1, 1, 1, 1]),
		[ 
			// lag: { 0.5.dup(8) .put(0,0) .dq }
			lag: {[0] ++ 0.5.dup(4) => _.flat => _.dq(inf)}
		],
		{|i|
			Saw.ar( i.freqSeq.lag( i.lag.demand(i.dur)) ,0.1 )	
			*( Env.asr(0.1, 1, 2).kr(0,gate: i.gateSeq)
			+ Env.perc(0.01, 0.23).kr(0,gate: i.trigSeq * i.gateSeq)
		)
		=> ( CombC.ar(_,1,
			//envelope of delay mod
			Env([0, 0, 1, 1], i.dur.parse([4],2)).kr(gate:1)
			* SinOsc.kr(2).range(-0.002,0.002)+0.2,
			10
		) *0.4  + MulAdd(_,0.8)
	)},
	{|i|
		Splay.ar(i).distort
		// => Mix.ar(_) 
		=> Pan2.ar(_,0)
	}
).play
});
[" willing I'm willin I'm willing I'm", "14 13 11 13 12 5 14 13 11".dm(\b)].addLine;
// Song.durs.filter( _ * 0.75 );
Song.setQuarters('willin ', "qe eqe e qe eqe e qe eqe e ".asBeats 	);
Song.setTempoMap('willin ', "qe eqe e qe eqe e qe eqe e " 	);
P(\cymbal, music: { |p b e|
	(
		instrument: \cymbalsDS,
		amp:0.06

	).play
});
P.synthV(\feng, filter: (midinote: _ - 12),take:nil,  params: {|p b| [
	lyrics: "willing + I'm willing + I'm willing + I'm ",
	lag: [0.06,0,0,0,0,0,0,0,0],
	legato:[1,0.9,1,1,0.9,1,1,0.9,1],
	vocalMode: "Opera",
	defaultVibratoDepth: 0.2
] }, music:{|p b e|
	{
		e.playbuf
		=> {|i|
			i
			// =>  PitchShift.ar(i, windowSize:0.2, pitchRatio:[3/4, 1.0 ], pitchDispersion:0.0, timeDispersion:0.0, mul:1.0, add:0.0) * [0.5,1]
		=> CrossoverDistortion.ar(_, amp:0.2, smooth:0.2, mul:1.0, add:0)
		+ i 
		/2
		}
		=> p.synthVTracks.at(e.key).()
	}.play
});
P.double(\feng, take:nil, music:{|p b e|
	{
		e.playbuf
		=> p.synthVTracks.at(e.key).()
	}
	.play
});
//Song.durs['willin ']=Song.durs['willin '].list * 0.9 => _.q;
//Song.vocalWill=VocalRPP(\willin,\vocal1);
// //P('vocal',start:\willin,rpp:VocalRPP(\willin,\vocal1),lag:-1,music: {|p b e|
// //)
// P('vocal',start:\willin,rpp:VocalRPP(\willin,\vocal1),lag:-1,music: {|p b e|
// 	e.rpp.buffer.() =>
// 	{ |i|
// 		{
// 			PlayBuf.ar(numChannels:2, bufnum:i.bufnum, rate:1.0, trigger:1.0, startPos:0.0, loop:0.0, doneAction:0)
// 			* Env([0,0,1,1],[0.8,0.1,10]).kr(2,gate:1)
// 			=> HPF.ar(_,200)
// 			=> SoftKneeCompressor.rms(_, control:nil, thresh:-5, ratio:8, knee:6, attack:0, release:0.05, makeUp:0, rms:40)
// 			=> BPeakEQ.ar(_, freq:1200.0, rq:1.0, db:16.0, mul:1.0, add:0.0)
// 			=> SineShaper.ar(_,0.2,2)
// 			=> BHiShelf.ar(_, freq:1800.0, rs:1.0, db:6.0, mul:1.0, add:0.0)
// 			=> DWGReverbC1C3_16.ar(_, len:2000, c1:1, c3:10, mix:0.15, coefs:nil, perm:nil, doprime:0)
// 			//=> Decimator.ar(_, rate:44100.0, bits:6, mul:1.0, add:0)
// 			* [0.5,0.3]
// 			*[0.3,1] /1.4 //make room for feng!!
// 			/4.5
// 		}
// 		// .play
// 	} 
// });
P(\cymbal,start:'willin ',music:{|p b e| 
(instrument:\cymbal,amp:1,length:4).play	
});
//P.click('willin ');
P.tune('willin ', _ <> [instrument:\stringyy,amp:0.7].p);
( Song.willingDrum = { |p b e length|
	var dur = length ? b.sum;
	[
		"q q q q e ee e e e e e ".wrapExtend(100), \kick, \amp, 0.5,
		"q qq qq ex xq qq qq q ".wrapExtend(100),\snare, \amp,0.4, \rest, [[Rest()].q,[1].q(inf)].q,
		"x ".wrapExtend(2 * 50),\hihat, \amp,[0.1,0.2].q(inf)*Pwhite(1,1.2,inf) ,
	].dmx2(2, e.tempoMap) => Ppar(_) =>_.findur(dur) 
};
);
P(\newDrums,music: { |p b e|
	p.willingDrum.(p, b, e).play
	}
);
P(\bass,start:'willin ',music:{|p b e| 
	[

		root:-1,
		degree: 8.dup(8)++2.1.dup(4)++5.dup(4)=>_.flatten=>_.q(inf)-1,
		octave:2,
		out:[0,1],
		smooth:Pwhite(0.2,0.3,inf),
		del:Pwhite(0.5,1,inf),
		dur:0.25,
		coef:Pbrown(0.1,0.9,0.03),
		lag:Pwhite(-0.01,0.01),
		dur: 0.5,
		amp:0.05
	].pm(\pluckD).fin(24).play(TempoClock.newFromQuarters(p.quarters[e.start]))
});
P(\bassDouble, music: { |p b e|
	
	[

					root:-1,
					// amp: 0.06,
					dur: 0.5,
					degree: 8.dup(8)++2.1.dup(4)++5.dup(4)=>_.flatten=>_.q(inf)-1,
					octave:2,
					out:[0,1],
					instrument: \sawSynth
	].p.fin(24).play(TempoClock.newFromQuarters(p.quarters[e.start]))
});
P(\oldArr,start:\willing,music:{|p b e| 
	
	//b=Pdef(\m,Pfxb(a,\phaserr,\fb,-0.99));
	c=Pseq([a,b],inf);

				// 'guitar-ish' //		

				//~synthsLoaded ?? {"~/tank/super/song-Synthdefs.scd".standardizePath.load};

			

				[
					degree:[3,4,6,5,7,3,4,6,5,8].q-1,
					root:-1,
					dur: [1.dup(4)++4].flatten.q(12)/4,
					octave:4,
					amp:0.3
				].p
				=> Pdef (\lick,_);

				//.play;

Pdef(\boodoo,Pbind(*[
					//instrument:\sawSynth,
					att:0,
					degree:Pseq([1,2,3,5,4,2,1],inf)-1,
					dur:Pseq([1,1,1,1,8,8,12]/4,inf),
					root:7,
					octave:2,
					amp:0.6
				])).quant([16,7])
				;
Pdef(\boodoo);//.play;
				//t=TempoClock.new.tempo_(88.bpm).permanent_(true);
				//t.tempo_(45.bpm);

				//p=PF.new;
				t=(Song.quarters[\scientist].list/2 =>_.asTempoClock);
				//t.tempo
Ptpar([ //		
					0,Pdef(\m),
					//2,Pdef(\lick),
					0,Pdef(\q),
					0,c,
					0,Pdef(\f),
					0,Pwrand([Pdef(\a),(note:Rest,dur:8)],[0.7,0.3],inf), //guitar
					//Pseq([(note:Rest,dur:7+16),Pdef(\boodoo)]),
				]
			)
			//.play(t)

});
["willing la laaa la", " 13 12 11 7 6".dm(\b,5)].addLine;
// Song.durs.filter( { |i|  i * 0.75  // * [1,1,1,0.5] 
// });
// Song.durs.filter( _.dropLast );
Song.setQuarters('la laaa', "qe eqe e qe qq".asBeats );
P.tune( _ <> [instrument:\stringyy,amp:0.7].p);
Song.setTempoMap('la laaa', "qe eqe e qe qq" );
P.synthV(\feng, filter: (midinote: _ - 12),  params: {|p b| [
	// lyrics: "willing + I'm willing +",
	lyrics: " willing + I'm willing +",
	vocalMode: \Opera,
	defaultVibratoDepth: 0.2
] }, music:{|p b e|
	{
		e.playbuf
		=> p.synthVTracks.at(e.key).()
	}.play
});
P.double(\feng, 
	// filter:(midinote:_),
	music:{ |p b e| 
	{
		e.playbuf
		=> p.synthVTracks.at(e.key).()
	}
	.play
});
P(\drums,start:'la laaa',music:{|p b e| 
		p.willingDrum.( p, b, e, length: b.sum + 0.2 ).play
});
P(\setClock,start:'la laaa',music:{|p b e| 
});
P.click('la laaa');
P.tune('la laaa');
P(\bass,start:'la laaa la',music:{|p b e| 
	[

		freq: [-2.5,-2.5,-2.5,-2.5,-5,-5,-5,-5, -6, -6, -6, -6, -6, -6, -6, -6].df('b',2).q,
					outs:[0,1],
					smooth:Pwhite(0.2,0.3,inf),
					del:Pwhite(0.5,1,inf),
					dur:0.25,
					coef:[ Pbrown(0.1,0.9,0.03),0.9 ] //muting
					lag:Pwhite(-0.01,0.01),
					dur: 0.5,
					amp:0.05
	].pm(\pluckD).fin(24).play(TempoClock.newFromQuarters(p.quarters[e.start]))
});
Song.mindKey = 'e-';
["to host Thalassa's mind",[4,3,5,4,3,7, 2, 3, 4,5, 6].dm( Song.mindKey, 6, \mixolydian)].addLine;
P.still(\clear, timecode: 0.seconds, music: { |p b e|
	 e.still.( 
		wait: b.sum,
		text: ["to host","Thalassa's mind"],
	)
});
// Song.durs.filter( {|i| var a = i.last; i.dropLast ++ (a/100) => _.flat } );
Song.setQuarters('to host',"E Q E Q E Qqe e e x x ".asBeats);
P.tune('to host', _.fin(6));
P.synthV(\feng, params: {|p b| [
	lyrics: "to host thalassas + + mind r r r r r",
	vocalMode: \Opera
] }, music:{|p b e|
	{
		e.playbuf
		=> p.synthVTracks.at(e.key).()
	}.play
});
P.double(\feng, filter: (midinote:_-12), music: {|p b e|
	{
		e.playbuf
		=> p.synthVTracks.at(e.key).()
	}.play
}
);
P.synthV(\kevin, filter: (midinote: _ - 12), 
pbind: {|p b| [dur:p.durs[\host].list.dropLast.add(1).q,midinote:p.tune[ p.section(\host) ]].p},
params: {|p b| [
	lyrics: " r r r r r r thalassas + - + mind ",
] }, music:{|p b e|
	{
		e.playbuf
		=> p.synthVTracks.at(e.key).()
	}.play
});
P.double(\kevin,
pbind: {|p b| [dur:p.durs[\host].list.dropLast.add(1).q,midinote:p.tune[ p.section(\host) ]].p},
	filter: (midinote: _ - 12), music:{|p b e|
	{
		e.playbuf
		=> p.synthVTracks.at(e.key).()
	}.play
});
// Song.durs['to host']= Song.durs['to host'].list.dropLast(1).q;
P(\lick,start:'to host',syl:5,music:{|p b e| 
	[
		freq: [2,3,4,5,6].df(p.mindKey, [5,6]).q,
		dur: b.drop(1) ++ 1 =>_.q,
		amp:0.4,
		instrument:\stringyy
	].pp
});
P(\drumFade,start:'to host',lag:0.35,music:{|p b e| 
	var clock;
	p.willingDrum.( p, b, e, 4) => Pmul(\amp, Pgeom(0.8,0.9,32),_) 
	 => Pset(\out,Effect.bus(FreeVerb.ar(_,XLine.kr(0.1,1,4),[1,0.81])),_)  
	 => _.play(clock: clock = TempoClock.new(1.5)) ;
	 fork{
		 8.do{|i|
			 clock.tempo_(1.5 * (8-( i /4 ) / 8).reciprocal);
			 0.15.wait
		 }
	 }

});
P(\chords,start:'to host',music:{|p b e| 
	[
		freq: [\r, [-6,1],-2, [-15, 2, 4, 7], [-11, 1, 3, 6]  ].df(p.mindKey, 5, \mixolydian).q,
		dur: b.parse([1,2,2,5]) ++ e.bNext.parse([3]) => _.flat => _.q,
		instrument:\sawSynthSustain,
		strum:[0,0,0,0.05, 0.05].q,
		legato:[1,1,1,1,1].q

	].pp;
});

Song.opportunityKey='b';
["The opportunity is an extraordinary one ","-1 3.5 3.5 3.5 3.5 2 2 1 2 3 5 4.5 2 1 -7.5".dm(Song.opportunityKey,6,\minor)].addLine;//p14
P.still(\mulhall, timecode: 2212.15.seconds, music: { |p b e|
	 e.still.( 
		wait: b.sum,
		text: ["",""],
	).sequenceText2(
			b.parse([1]), [ 
			["the opportunity","is an extraordinary one"]
			],
	)
});
Song.durs.filter( _ * [1,1,1,1,1,1,5/7, 1,1,1,1,1,1,1,1 ] );
Song.setTempoMap(\opportunity,"e x xe x xe x xeee x xe x xe x xe x xe");
P.synthV(\feng, filter: (midinote: _ - 12),  params: {|p b| [
	lyrics: "r the opportunity + + + + is an extrordinary + + + + one",
	legato: [1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 0.9, ],
	vocalMode: \Opera
] }, music:{|p b e|
	{
		e.playbuf
		=> p.synthVTracks.at(e.key).()
	}.play
});
P(\chords,start:\extraordinary,music:{|p b e| 
	MegaBind(
			[
				[\r, 1,  1,  1,  1,  -7, -7, -6.5, -6.5, -6.5, -2,  -2,  -2,  -2, -2],
				[\r, -5, -5, -5, -5, -5, -5, -4,   -4,   -4,   -6, -6, -6, -6, -7].flat
			].df(p.opportunityKey),
			"e x xe x xe x xeee x xe x xe x xe x xe".asBeats.warpTo( e.tempoMap ),
			[],
			{|i|
				Saw.ar( i.freqSeq  ) 
				* 
				(
					Env.perc().kr(gate: i.trigSeq * i.gateSeq)
					+ Env.asr().kr(gate:i.gateSeq)
				)
			},
			{|i|
				Splay.ar(i)
				*0.1
			}
		).play
});
P(\chord,start:\extraordinary,syl:13,music:{|p b e| 
	(
		freq: [-5,1,3].df(p.opportunityKey,4) * (-5).midiratio,
		instrument:\sawSynthSustain,
		dur:b.parse([6]),
		att:0.5
	).play
});
Song.setQuarters(\extraordinary, "e x xe x xe x xqe x xe x xe x xe x xe");
P.click(\extraordinary);
P(\bass,start:\extraordinary,music:{|p b e| 
	[
		freq: [ 11, 7, 6.5, 6].df(p.opportunityKey, [ 3,4 ]).q,
	dur: e.quarters.list.parse([2,2,2,2]) 
		+ [ 0,0,0, p.durs[e.start +1].list.parse([5])] => _.q,
		legato: [1,1,1,1].q,
		instrument: \sawSynthSustain
	].pp
});
[" for experimentation, observation. ","2 3 4 5 -6 1 1 -7 5 5 4 3 3 2  1".dm('f#',6)].addLine;//p14ngyy
P.still(\clear, timecode: 0.seconds, music: { |p b e|
	 e.still.( 
		wait: b.sum,
		text: ["for experimentation","...observation"],
	)
});
P.synthV(\feng,filter: (midinote: _ - 12),  params: {|p b| [
	lyrics: "for experimentation + + + + + - obser + - vation + - -",
	vocalMode: \Opera
] }, music:{|p b e|
	{
		e.playbuf
		=> p.synthVTracks.at(e.key).()
	}.play
});
P.synthV(\kevin, take: \lead,
	pbind: {|p b|
		[
			dur: b.parse([5, 1, 2, 1, 2, 1, [1, 0.5],[0.5,1]]),
			midinote: [-5,-5,-5, 2, 2, 1, 1, -5].dm('f#')
		].p
	},
	params: {|p b| [
	lyrics: "r tay shun ob zer vay shun -",
	pitchTake: 1
] }, music:{|p b e|
	{
		e.playbuf
		=> p.synthVTracks.at(e.key).()
		=> FreeVerb.ar(_,0.1,0.85)
		/3
	}.play

});
P(\bass,start:\experimentation,music:{|p b e| 
	[
		freq: [\r, 12, 15, 12].df(p.opportunityKey,2).q,
		dur: b.parse([5,6, [1,1,0.5], [0.5,1]]).q,
		instrument:\sawSynthSustain
	].pp;	
});
P.tune(\experimentation);

////Split it  here instead !!!
["SCOTT: A starship engine the size of a walnut? Thats impossible! "," 2 3 1 -7 -6 -5.5 4 3 4 5 -7".dm(\a) ++ "5 5 11 5 1".dm('a-',5)].addLine;
Song.durs.filter( _ *0.9 );
P.still(\scott, timecode: 2220.seconds, music: { |p b e|
	 e.still.( 
		wait: b.sum,
		text: ["a starship engine","the size of a walnut"],
	).sequenceText2(
			b.parse([11, 1, 4]), [ 
			["thats",""],
			["thats","impossible"]
			],
	)
});
Song.impossibleCurve=TempoMap("e e e E E E e x x e e qe e E E E q".asBeats,Song.durs[\impossible].list);
P.tune();
// P.tune(\impossible);
P.synthVs(role: \scott, take: [\lead, \double], params: {|p b| [
	filter: (midinote: _ - 12), 
	lyrics: " A starship + engine + the size of a walnut? + Thats impossible! + + + ",
	legato: [[1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 0.7, 0.6, 1, 1, 1, 1, ]],
	pitchTake: [1,3]
] }, music:{|p b e|
	{
		e.playbuf
		=> p.synthVTracks.at(e.key).()
	}.play

});
P(\chord,start:\impossible,syl:0,music:{|p b e| 
	(
		freq:[1,3,5.5,7].df(\f),
		instrument:\stringyy
	).play
});
P(\bass,start:\impossible,music:{|p b e| 
	[
		freq: [\r] ++ "5 -5 4  3 -3 2".df(\a,3) ++ "5 1".df('a-',3) =>_.q,
	dur:p.impossibleCurve.mapBeats(  "e eee e exx e e q ee e ".asBeats).q,
	out: Effect( SineShaper.ar(_,limit:0.05) * 2, inputChannels:2).bus.index,
	legato: [1,1,1,1,1,1,1,1,1.5].q
	].pp//.findur(b.sum)
	//.play
});
//["But I don't suppose there'd be any harm in looking over diagrams on it. ","r"].addLine;
{
["KIRK: Bones? You could stop all this by saying no. ",[7].dm(\b,4,\mixolydian) ++ [3,4,7,4,3,2,3,4].dm(\c,5,\mixolydian) ++ [5].dm(\a,4)].addLine;

P.still(\kirkStop, timecode: 2242.8.seconds, music: { |p b e|
	e.still.( 
		wait: b.sum,
		text: ["Bones?","you could stop all this"],
	).sequenceText2(
			b.parse([6]), [ 
			["by saying","''no'"],
			],
	)
});
P.synthV(role: \kirk, take: \lead, params: {|p b| [
	filter: (midinote: _ - 12), 
	lyrics: " Bones? You could stop all this by saying + no. ",
	legato: [0.8, 1, 1, 1, 1, 1, 1, 1, 1, 1, ],
	vocalMode: \Soft,
	paramTension: 0.6,
	pitchTake: 1
] }, music:{|p b e|
	{
		e.playbuf
		=> p.synthVTracks.at(e.key).()

	}.play

});
P.double(role: \kirk, take: \lead, params: {|p b| [
	pitchTake: 1
] }, music:{|p b e|
	{
		e.playbuf
		=> p.synthVTracks.at(e.key).()
		// /2
		* [0.1,0.8]
	}.play

});
P.tune('stop all this');
P(\tune,start:'stop all this',syl:0,music:{|p b e| 
	p.tune[e.start].list[1..].dropLast
	=> { |i| [
		midinote: i.q - [ 12, 24 ],
		dur: b.drop(1).q,
		rel: [2,2,2,2,2,2,2,4].q,
		legato: [1,1,1,1,1,1,1.1,1.1] - 0.1 =>_.q,
		instrument:\sawSynthSustain,
		amp:0.065


	].pma(\sawSynthSustain).play } 

});
P(\chord,start:'stop all this',music:{|p b e| 
	[
		//freq: [1,3,5,7].df(\b,4,\mixolydian),
		//freq: [ [1,3,4.5,7].df(\b,4,\mixolydian), \r, [1,3,5,11].df(\a,4,\minor) ].q,
		freq: [ [-1 ,1,3,5,7].df(\b,4,\mixolydian), \r, [-1, -7, 1,3,5].df(\a,4,\minor) ].q,
		dur: b.parse([1, 8, 1]).q,
		strum: [ 0.055, 0, 0.04 ].q
	].pp
});
["Thats why-- I called you all here together. ","5  2 3  -6  3 4  4 5 2 5  5 6 6 7 6".dm('e-',5,\lydian)].addLine;
P.tune('here together');
P.still(\clear, timecode: 0.seconds, music: { |p b e|
	 e.still.( 
		wait: b.sum,
		text: ["that's why ","I"],
	).sequenceText2(
			b.parse([6,4]), [ 
			["called you","all"],
			["here","together"]
			],
	)
});
P.synthV(role: \kirk,start: 'here together', take: \lead, params: {|p b| [
	filter: (midinote: _ - 12), 
	lyrics: "That's why - r I - called -  you all here together. + - + ",
	pitchTake: 1,
	vocalMode: \Passionate
] }, music:{|p b e|
	{
		e.playbuf
		=> p.synthVTracks.at(e.key).()
	}.play

});
P.double(role: \kirk, take: \lead, params: {|p b| [
] }, music:{|p b e|
	{
		e.playbuf
		=> p.synthVTracks.at(e.key).()
	}.play

});
P(\bass,start:'here together',music:{
	|p b e| 
	[
		freq: [ \r, 1, 2, 3, -7, 1, -1 ].df('e-',[3,4],\lydian).q,
		dur: b.parse([1, 3, 2, 2, 1, [ 4,0.67 ], [0.33, 1 ]]).q
	].pp
}
);	
["(boom) We'll all be deeply involved. It must be unanimous. ","-1 12 13 12 12 11 7 6".dm(\c) ++ "2 6 5 4 3 4 1 -6".dm('f#')].addLine; //p11
P.still(\clear, syl:0, timecode:0.seconds, music: { |p b e|
	 e.still.( 
		wait: b.sum,
		text: ["we'll all be","deeply involved"],
	).sequenceText2(
			b.drop(1).parse([8]), [ 
			["it must be","unanimous"],
			],
	)
});
Song.quarters[\involved] = Song.parseBeats(\involved,[1, 1/2, 1, 1/2, 2/3, 2/3, 1/3, 1/3, 3/2, 1/2, 2/3, 2/3, 2/3, 1/2,1/2,1]);
Song.setTempoMap(\involved,[1, 1/2, 1, 1/2, 2/3, 2/3, 1/3, 1/3, 3/2, 1/2, 2/3, 2/3, 2/3, 1/2,1/2,1] );
P.synthV(role: \kirk, take: \lead, params: {|p b| [
filter: (midinote: _ - 12), 
lyrics: " r We'll all be deeply + involved - +  It must be unanimous + + + ",
legato: [1, 1, 1, 1, 1, 1, 1, 1, 0.6,  1, 1, 1, 1, 1, 1, 1, ],
pitchTake: 1,
vocalMode: \Soft
] }, music:{|p b e|
{
	e.playbuf
	=> p.synthVTracks.at(e.key).()
}.play

});
P.double(role: \kirk, take: \lead, params: {|p b| [
] }, music:{|p b e|
{
	e.playbuf
	// => p.synthVTracks.at(e.key).()
	=> Pan2.ar(_,1)
	/4
}.play

});
// P.tune(\involved, Pmul(\freq,[1,2],_));
//P.click(\involved);
P(\hat,start:\involved,music:{|p b e| 
[
	dur: e.tempoMap.mapBeats("ee e x x q e e x x x x q q q e x x ee e".asBeats).q,
	instrument: \hat_808,
	out: Effect.bus({|i|  EchoNone.ar(i,1, delaytime:0.5) + WhiteNoise.ar(0.00011)	})
].pp;
});
P(\bass,start:\involved,music:{|p b e|  // passing tone right before end please
b.postln;
[
	freq: [1, 1,1, 1.5, 2.5, 4.5].df(\c,3).q,
	dur: b.parse([ [1, 1, 0.5],[0.5, 1],[ 1,1,1,1],  [1,1,1, 1/3],[2/3,1], 3 ]).postln.q,
	out: Effect({ |i| SineShaper.ar(i, 0.2) * 5 => FreeVerb.ar(_,0.05,1) * Env.linen(0.001,b.sum,1).kr(2,gate:1) }, out:[0,1]).bus.index ,
].pp; 

});
( Song.involvedHarmpnies = [
[0, 7, 7, 5, 6, 6, 4, 4, 4].dm(\c),
[0, 5, 5, 3, 4, 4, 1, 1, -7].dm(\c)
];
);
P.synthV(role: \kirk, take: \harmony1,
	pbind: {|p b| 
		[
			midinote: p.involvedHarmpnies[0],
			// dur: b[0.. p.involvedHarmpnies[0].size - 1]
			dur: b
		].p
	},
	params: {|p b| [
		lyrics: "r we'll all be deeply + involved - + r r r r r r r",
		pitchTake: 1
	] }, music:{|p b e|
		{
			e.playbuf
			=> p.synthVTracks.at(e.key).()
			/2
		}.play
});

P.synthV(role: \kirk, take: \harmony2,
	pbind: {|p b| 
		[
			midinote: p.involvedHarmpnies[1],
			dur: b,
		].p
	},
	params: {|p b| [
		lyrics: "r we'll all be deeply + involved - + r r r r r r r",
		pitchTake: 1
	] }, music:{|p b e|
		{
			e.playbuf
			=> p.synthVTracks.at(e.key).()
			/2
		}.play
});
P(\chords,start:\involved,music:{|p b e| 
		var oneM7 = [3,5,7];
		var four6 = [-6, 1, 4];
		var six = [-6, 1, 3];
		[
			freq: [\r, oneM7, oneM7, oneM7, \r, oneM7, four6, six].df(\c) ++ 
			[ [1,3,5,-7], [ -7,2,4,7 ]].df('c#',5,\mixolydian) => _.q,
			curve:-9,
			t_trig:1,
			legato: [1,1,1,1,0,1,1,0.9,1].q(inf),
			//dur: b.parse([1, [1, 1/2], [1/2, 1], 4, 5,3]).q,
			dur: p.quarters[e.start].parse([1,1,1,1, 1,1, 2, 2, 8, 3]/2).q,
			out: Effect(PlateReverb.ar(_,mix:0.5,decayTime: 0.3,damping:0.7)).bus.index
		].pma(\defaultRetrig).play

});
["MCCOY: (boom) Then I'll still want one question answered to my satisfaction.", "-1 1 2 -8 1 3 4 2 5 1".dm(\f, 5, \diminished) ++ "3 4 5 1 6.5 6".dm(\c, 5, \mixolydian) ].addLine;//p13
P.still(\mccoy, timecode: 2255.25.seconds, music: { |p b e|
		e.still.( 
			wait: b.sum + e.bNext.sum + p.durs[e.start+2].list.sum,
			fade:2,
			text: ["",""],
		).sequenceText2(
				b.parse([1,9,6]), [ 
					["then I'll still want","one question answered"],
					["to my","satisfaction"],
					["",""]
				],
		)
});
Trek.cast.mccoy = \an;
Trek.presets.put(\mccoy,\mo,[paramTension:0.8, paramGender:0.1]);
Trek.presets.put(\mccoy,\an,[paramTension:0.4, paramGender:0.12]);
P.synthV(role: \mccoy, take: \lead, params: {|p b| [
		lyrics: "r Then I'll still want one question + answered + to my satisfaction + + +",
		legato: [1, 1, 1, 1, 1, 1, 1, 1,1, 1, 1, 1, 1, 1, 1, 0.8, ],
		filter: (midinote: _ - 12), 
		pitchTake: 1,
		vocalMode: \Open,
		paramTension: -0.5,
		paramExpression:1.5
	] }, music:{|p b e|
		{
			e.playbuf
			=> p.synthVTracks.at(e.key).()
			* 4.dbamp
		}.play

});
P.double(role: \mccoy, take: \lead, params: {|p b| [
		pitchTake: 1
	] }, music:{|p b e|
		{
			e.playbuf
			=> p.synthVTracks.at(e.key).()
			* 4.dbamp
		}.play

});
P(\dimchords,start:\answered,music:{|p b e| 
		[
			freq: [ [1,3,5,7].df(\d,5,\diminished),[1,3,5,7].df('c#',5,\diminished) ].q,
			dur: b.parse([10,5]).q,
			legato:1,
			instrument:\wash,
			att:b[0..8].sum,
			rel:b[9..14].sum * 4,
			freqLag:1,
			amp:0.05

		].pm(\wash).play
});
	// P.tune(\answered);
P.tune('answered to', {|i| Pbindf(i,\legato,0.9, \instrument,\stringyy,\wet,0.3,\release,2,\amp,0.2) => Pmul(\freq,1/[2,4],_)});
["Why? Not a list of possible miracles, (boom) but a ","6 3 1 5 3".dm(\f) ++ "6.5 6 3 5 4 -7".dm('c#',5) ++ "-5 3 4".dm('e-')].addLine;
P.still(\clear, timecode: 0.seconds, music: { |p b e|
	 e.still.( 
		wait: b.sum + e.bNext[..8].sum,
		text: ["Why?",""],
	).sequenceText2(
			e.bAll.parse([1, 10, 1]), [ 
			["not a list of","possible miracles"],
			["",""],
			["but a simple basic", "understandable"]
			],
	)
});
P.synthV(role: \mccoy, take: \lead,
		pbind: Song.enlarge2(0),
		filter: (midinote: _ - 12), 
		params: {|p b| [
			lyrics: "Why? Not a list of possible + + miracles + + r but a simple + basic + understandable + + + + ",
			legato: [0.6, 1, 1, 1, 0.7, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 0.8, 1, 0.8, 1, 1, 1,1, 1 ],
			pitchTake: 1,
			vocalMode: \Solid
		] }, music:{|p b e|
			{
				e.playbuf
				=> p.synthVTracks.at(e.key).()
			}.play

});
P.double(role: \mccoy, take: \lead, params: {|p b| [
		] }, music:{|p b e|
			{
				e.playbuf
				=> p.synthVTracks.at(e.key).()
			}.play

});
P(\bass,start:'possible miracles',music:{|p b e| 
			[
				//freq: [1, 2, 1.5, 4, 1, -5].df('e-',3,\mixolydian).q,
				freq: [1, 2, 1.5, 2.5, 1, -5].df('e-',3,\mixolydian).q,
				dur: b.parse([1,2,2,3,3,3]).q,
				//instrument:\sawSynthSustain
				out: Effect( { |i|  SineShaper.ar(i*10,limit:0.1) => FreeVerb.ar(_,0.5,0.9) }  ).bus.index
			].pp
});
P(\strum,start:'possible miracles',music:{|p b e| 
			(
				freq: "-1 1 3 5 7".df('e-'),
				strum: 0.06
			).play
});
["simple basic understandable","5 5 6 6 7 11 7 6 4".dm('e-',5,\mixolydian)].addLine;
		Song.setQuarters(\understandable,"q q q q q e q e e ".asBeats);
		//Song.quarters[\understandable].list
P(\chords,start:\understandable,music:{|p b e| 
			var one, four, seven;
			# one, four, seven = [[1,3,5],[1,4,6],[2,4,7]].df('e-',scale:\mixolydian);
			\one.post;one.postln;
			MegaBind(
				[one, one, four, four, seven, seven, four, four ].flop,
				p.quarters[e.start].list.gaussian(dev:0.005),
				//1,
				[
					pan:[ -1,0,1 ],
					limit:[ 0.5,0.1,0.005 ],
					lag: { 0.01 dup: 8 => _.put(0,0) => _.dq => _.demand(p.quarters[e.start].list) }
				],
				{|i|
					SinOsc.ar( i.freqSeq.lag(i.lag), 0, 0.1 )
					* 
					(
						Env.asr(0.01,1,0.001).kr(gate:i.gateSeq)
						+
						Env.perc(0.05,1).kr(0,gate: i.trigSeq)
					)
					=> SineShaper.ar(_, i.limit)
					=> Pan2.ar(_,i.pan).fold2(0.01)
					=> AnalogPhaser.ar(_, SinOsc.ar(rrand(0.2,0.3)), feedback: 0.8)
					=> LPF.ar(_,6000)
				},
				{|i|
					Mix.ar(i)
					=>HPF.ar(_,200)
					/2
					=> PlateReverb.ar(_,decayTime:0.2, mix:0.25)
					/2

				}
			).play

});
P(\bass,start:\understandable,music:{|p b e| 
			[
				freq: "1 1 4 4 7 7 4 4".df('e-',3,\mixolydian).q,
				dur: p.quarters[\understandable],
				//instrument:\sawSynth

				out: Effect( { |i|  SineShaper.ar(i*10,limit:0.1) => FreeVerb.ar(_,0.5,0.9) }  ).bus.index
			].pp
});
[" why that overrides all danger. And let's not ", "6 5 12 11 7.5 6.5  12 13 11 3 4 5".dm(\d,5,\minor)].addLine;
P.still(\bonesClose, timecode: 2302.8.seconds, music: { |p b e|
			e.still.( 
				wait: b.sum + e.bNext[..5].sum,
				text: ["'Why' that","overrides all danger"],
			).sequenceText2(
					e.bAll.parse([9]), [ 
					["and let's not kid ","ourselves that there is no"],
					],
			)
});
P.synthV(role: \mccoy, take: \lead,
			pbind: Song.enlarge(7),
			filter: (midinote: _ - 12), 
			params: {|p b| [
				lyrics: " why that overrides + + all danger - + And let's not kid our selves that there is no ",
				legato: [0.8, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 0.8, 1  ],
				lag: [0,0.05, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0,0,0,0],
				pitchTake: 1
			] }, music:{|p b e|
				{
					e.playbuf
					=> p.synthVTracks.at(e.key).()
				}.play

});
P.double(role: \mccoy, take: \lead, params: {|p b| [
			] }, music:{|p b e|
				{
					e.playbuf
					=> p.synthVTracks.at(e.key).()
				}.play

});
P(\bass,start:\override,music:{|p b e| 
				[
					freq: [1, 1.5, 2, -5, -4].df(\g,3,\minor).q,
					dur: b.parse([3,1,3,4, 1]).q,
					instrument: \sawSynthSustain
				].pp
});
		}.();
["kid ourselves that there is no potential danger in this. ", "5 4 2 -6 -7 1 1.5 1.5 2 3 4 2 -7 -5".dm(\f)].addLine;
P.still(\clear, timecode: 0.seconds,syl:6, music: { |p b e|
	 e.still.( 
		wait: b.drop(1).sum,
		text: ["potential danger","in this"],
	)
});
P.synthV(role: \mccoy, take: \lead, params: {|p b| [
	lyrics: "r r r r r r r potential + +  danger + in this. ",
	filter: (midinote: _ - 12), 
	legato: [1, 1, 1, 1, 1, 1,   0.7, 1, 1, 1, 1, 1, 1, 1, ],
	pitchTake: 1
] }, music:{|p b e|
	{
		e.playbuf
		=> p.synthVTracks.at(e.key).()
	}.play

});
P.double(role: \mccoy, take: \lead, params: {|p b| [
] }, music:{|p b e|
	{
		e.playbuf
		=> p.synthVTracks.at(e.key).()
	}.play

});
P(\bass,start:\kid,music:{|p b e| 
	[
		freq: [1, 6, -6].df('b-',2).q,
		dur: b.parse([6,4, 3]).q,
		instrument:\sawSynthSustain
	].pp
});
P.tune(\kid);
}
)
Song.secDur
Song.sections.collect(Song.secDur[ _ ]).sum 
Song.sections
Song.secDur[0]

