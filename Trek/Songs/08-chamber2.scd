( //line 178 ~/tank/Trek/return-to-tomorrow.txt
	Song.currentSong.isNil.not.if{ Song.resources.do(_.free) };	//this should be a method
	Song(\chamber,[]).current;
	Song.currentSong.resources.infrastructure=FunctionList([ {
		//			~synthsLoaded.isNil.if{"/Users/michael/tank/super/song-Synthdefs.scd".load};
	} ]);
	"~/tank/super/Trek/Songs/boilerplate.scd".standardizePath.load;
	Song.synthVTracks = EventWithDefault(\default, { |wet=0.3|
		FreeVerb.ar(_,wet,0.9)
		/5
		// => Pan2.ar(_,0)
	});
	// Song.refreshDirty(12);
	// Trek.cast.kirk = \kevin;
	Trek.presets.put(\mccoy,\mo,[paramGender:0.25]);
	
['Kirk briefly convulses with pain', "c",[3] ].addLine;
P(\pains,  music: { 
	Song.painSynth={
		Impulse.ar(
			LFBrownNoise0.ar( 5 +1.0.rand!4) *100
		)
		* 0.5 => Convolution.ar( SinOsc.ar( { 100.pareto }.dup(20), 0, 0.05  ),_ )
		=>Out.ar(\out.kr(0),_)
	}.play 
});
P.still(\pain, timecode: 1911.2.seconds, music: { |p b e|
	 e.still.( 
		wait: b.sum +1,
		text: ["",""],
		fade:1
	)
});
['then the sphere glows bright again' , "c",[2,2,2, 2]].addLine;
// P.still(\reax, timecode: 1912.6.seconds,syl:0, music: { |p b e|
// 	 e.still.( 
// 		wait: b.drop(1).sum,
// 		text: ["",""],
// 	)
// });
/* P.still(\glow1, timecode: 1914.seconds,syl:1, music: { |p b e|
	 e.still.( 
		wait: b.drop(1).sum,
		text: ["",""],
	)
}); */
P.still(\glows, timecode: 1917.8.seconds,syl:0, music: { |p b e|
	 e.still.( 
		 fadeIn:2,
		wait: b.sum,
		text: ["",""],
	)
});
P(\sphere,  music: { |p b e|
	{
		{ Song.painSynth.free }.sched(p.secDur[e.start]);
		Saw.ar( LFBrownNoise2.ar(0.1,3!4)*1300+20, 0.1 )
		=> LeakDC.ar(_)
		*  Env.asr(16,1,5).kr(0,gate:\gate.kr(1))
		=> CombC.ar(_,0.5,\delayTime.kr(0.2,0.1,3))
	}.play.dur(p.secDur[e.start]-0.1,4)
});
P(\knee,syl:3,music:{ |p b e |
	[ 
		strum:0.05,
		note:Arpeggio([0,3,7,11],20),
		dur:3,
		instrument: \harpS,amp:0.03,coef:Pwhite(0.1,0.2,inf).asStream.nextN(20),pan:Pwhite(-1,1,inf).asStream.nextN(20),
		effect:{ Effect( { |i|  FreeVerb.ar(i,0.6,1) * Env.linen(0, b.sum + 0, 3).kr(2,gate:1)} ,inputChannels:2).bus.index},

		//		out:[0,1,2,3],
		out:Pkey(\effect),
	].p.fin.play
});
['and he falls to his knees.' ,"r" ].addLine;
[ /*MCCOY*/ 'Is it you, Jim? (a nod)', [3,4,7,5, 5.5].dm('d')  ].addLine; 
Song.durs.filter(\nod, {|i| i + [0,0,0,0,0.25]});
P.still(\sensor, timecode: 1926.66.seconds, music: { |p b e|
	 e.still.( 
		wait: b.sum,
		fadeIn:1,
		text: ["is it you,","Jim?"],
		fade: 1
	)
});
P.synthV(role: \mccoy, take: \lead, params: {|p b| [
	lyrics: "Is it you, Jim r",
	filter: (midinote: _ - 12), 
	vocalMode: \Open,
	paramTension: 0.9,
	pitchTake: 1
] }, music:{|p b e|
	{
		e.playbuf
		=> p.synthVTracks.at(e.key).()
		=> Pan2.ar(_, -0.4)
	}.play

});
P(\nod,syl:3,music:{ | p b e |
	[
		strum:[ 0.06 ].q,
		freq:[1,3,5,11].df('e-',octave: 4),
		out:
		{ Effect({|i| EchoNone.ar(i,1,0.3,5) =>.first DetectSilence.ar(_,doneAction:2)=> MoogFF.ar(_,6000,3) * Env.linen(0,b.sum,2).kr(2,gate:1) },inputChannels:2).bus.index  }, 
		//		out:Pkey(\effect), 
	].pp;
		{
			SinOsc.ar( LFSaw.ar({rrand(3.0,4)}!4,{rrand(0,1.0)}!5).range(400,1800),0,0.01 )=>Splay.ar(_)
			* Env.linen(0.2, b.drop(1).sum,  releaseTime: 2.0,  level: 1.0,  curve: \lin).kr(2)
		}.play;
});
P.still(\senser, timecode: 1928.1.seconds,syl:3, music: { |p b e|
	 e.still.( 
		wait: b.sum,
		text: ["",""],
	)
});
['Good, his metabolic rate is back to normal.',[15,14,15,16.5,15,14,13,12,15,12,11,7].dm('a',scale:\harmonicMinor,octave:4)].addLine;
P.still(\tricorder, timecode: 1929.2.seconds, music: { |p b e|
	 e.still.( 
		wait: b.sum,
		text: ["",""],
	)
});
P(\chords, music:{|p b e|
	[
		freq: [[3,5],[1, 4],[1,3],[-2,1]].df(\e,4,\mixolydian ).q,
		dur: b.parse([6, 1, 3, 2]).q,
		amp: 0.03
	].p.play
}
);
P.still(\clear, timecode: 0.seconds, music: { |p b e|
	 e.still.( 
		wait: b.sum,
		text: ["good",""],
		onTop: true
	).sequenceText2(
			b.parse([1]), [ 
			["his metabolic rate is","back to normal"],
			],
	)
});
P.synthV(role: \mccoy, take: \lead, params: {|p b| [
	lyrics: "Good, his metabolic + + + rate is back to normal +",
	filter: (midinote: _ - 12), 
	legato: [0.5, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, ],
	pitchTake: 1
] }, music:{|p b e|
	{
		e.playbuf
		=> p.synthVTracks.at(e.key).()
	}.play

});
P(\bassLine,music:{|p b e|
	[
	dur: b.parse([3,1,2,1,3,2]).q ,
	freq:[11,7,5,4,3,2].df('e',octave: 3,scale:\mixolydian).q,
].pp
});
['/*SPOCK:*/ Captain, do you know what happened? Do you remember any part of it? ',[13,11,7,11,12,13,14,13 ].dm('g',octave:4,scale:\mixolydian)++[7,11,12,14,13,12,11,13,11,5].dm('a',octave:4,scale:\mixolydian)].addLine; 
P(\basslinePhraseTwo, music: { |p b e|
	fork{
		var r = Barrier.collect({
				VarSaw.ar(\freq.kr(300,0.3),0,0.5) * \amp.kr(0.1) 
				* Env([0,1,1,0],[0.2,b.sum-4,\rel.kr(5)]).kr(0,gate:\gate.kr(1))
				=> Pan2.ar(_,\pan.kr(0))
				=> {|i| Convolution.ar(i, Dust.ar(50) => Decay.ar(_,0.0005) )
				=> {|i| CombN.ar(i, 0.2,0.11,5)}
			/8 + i => {|i| CombN.ar(i,0.2,0.2,4) / 1.5 + i } }
			=> HPF.ar(_,800)
		}.asDefName );
		[
			instrument: r.value[0].postln,
			// instrument: \default,
			freq: [[-7,1], [7,1 ], [6,2],[5.5,1.5]].df(\g,5,\mixolydian).q /[2],
			dur: e.bAll.parse([6,9, 3,2]) =>_.q,
			pan: [-0.5,0.5],
			amp: [0.06,0.1],
			rel: [5,4]
		] => _.ppm 
		}		
});
P.synthV( role: \spock, take: \lead,  
filter: (midinote: _ - 12),  params: {|p b| [
lyrics: "captain +  do you know what happened +  do you remember + +  any + part of it",
legato: [1,   0.7,    1, 1,  1,   1,    1,      1,  1, 1, 1, 1, 1,      1, 1,  1,  1,  1],
vocalMode: \Rough
] }, music:{|p b e|
{
	e.playbuf
	=> p.synthVTracks.at(e.key).()
	=> Pan2.ar(_,0.7)
}.play
});
P.still(\spockClose, timecode: 1932.7.seconds, music: { |p b e|
	 e.still.( 
		wait: b.sum,
		text: ["Captain, do you know","what happened"],
	).sequenceText2(
			b.parse([8,10]), [ 
			["do you remember","any part of it"],
			],
	)
});
P(\bassNote,music:(instrument:\stringyy,freq:[4].df('c',octave: [4,3]),amp:0.2,)
);
['/*KIRK:*/ Yes. ',[1].dm('a-')].addLine; 
P(\chord,music:{|p b e| [ 
	strum:0.02,
	dur: e.bAll.parse([6,4, 4, 4,3]).q,
	out:
	( 4!4 ).rand
	,
	//out:2,
	instrument:
	//			\cleanPluck,
	// \default,
	\harpS,coef: 0.3,amp:[0.01, 0.01, 0.005,0.005,0.005].q,
	freq:
	[ [1,5,3,11] +.x [0,10] =>_.df('a-',octave: 3),  ( [ 1, 4, 11, 15] +.x [0,10] =>_.df(\b,3,\dorian)  ) ] ++ [11,7,4].df(\a,2)
	=> _.q
	,
	// amp:0.05,
	pan: {1.rrand(-1)}!8,
	out: Effect.bus({|i| i/3 + Phaser1.ar(i,rate:0.21) },inputChannels:2)
].p.play }
);
P.synthV(role: \kirk, params: {|p b| [
	lyrics: "yes",
	legato: [0.90]
] }, music:{|p b e|
		{
			e.playbuf
			=> p.synthVTracks.at(e.key).()
			=> Pan2.ar(_,0)
		}.play
});
P.still(\kirk,
	// timecode: 1943.066.seconds, //group
	timecode: 1941.05.seconds, //close
	music: { |p b e|
	 e.still.( 
		wait: b.sum + e.bNext.sum,
		text: ["Yes",""],
		fade: p.secDur[e.start+2]
	).sequenceText2(
			[ b.sum, e.bNext.sum ], [ 
			["Sargon borrowed","my body"],
			["",""]
			],
	)
});
P(\chord2, music: { |p b e|
	var a =Effect.bus({|i| i/8 },inputChannels:5);
	(
		freq: 1.df('a-',3),
		dur: b.sum

	).play;
	[ 
		// freq: [5,6,-7,11,7,17].df(\b,\dorian),
		freq: [1, 3, 11, 13].df(\c,\minor),
		freq: [
			[3, 5, 11],
			[3, 5, 7],
			[2.5, 5.5, 7],
			[2.5, 4.5, 7],
			[2.5, 4, 7]
		].df('a-',\mixolydian).q,
		// dur:b[..4].sum,
		// dur:b.sum,
		instrument:  \stringyy ,
		rel:6,
		// att:3,
		out:a,
		dur: e.bAll.parse([3, 3, 1, 1, 2]).q,
		amp: 0.3
	].ppm;
	(
		instrument: \sawSynthSustain,
		freq: [ -1 ].df('a-',[6]),att:4,
		lag: b[..4].sum,
		out:a,
	).play;
});
['Sargon borrowed my body. ',[7,6,5,6,7,4,3].dm('b',scale:\dorian)].addLine; 
P.synthV(role: \kirk , filter: (midinote: _ - 12),  params: {|p b| [
	lyrics: "Sargon + borrowed + my body +",
	lag: [0.1, 0.05, 0, 0, 0, 0, 0 ],
	legato: [1, 1, 1, 1, 1, 1, 0.8, ],
] }, music:{|p b e|
	{
		e.playbuf
		=> p.synthVTracks.at(e.key).()
		=> Pan2.ar(_,0)
	}.play
});
// P(\tune,music:Song.currentSong.pbind[7]);
P(\bass,music:{|p b e| 
	[
		freq: [7,6,5,6,7,11].df('b',scale:\dorian,octave:[ 2 ]).q ,
		legato:1,
		dur: Song.currentSong.parse(7,[1,1,1,1,1,2]).q ,
	].pp }
	);
['I was floating (boom) in time and space. ',[3,4,13,11,4.5,13].dm('a')++ [13,11,6].dm('a-')++ [16,15,13,7].dm('d') ].addLine; 
P.synthV(role: \kirk, filter: (midinote: _ - 12),  params: {|p b| [
		lyrics: "I was floating + \r in time r r and space r r ",
		legato: [1,1,1,1,1,1,2,1, 1, 1,2]
	] }, music:{|p b e|
		{
			e.playbuf
			 => p.synthVTracks.at(e.key).()
			 => Pan2.ar(_,0)
			 // => {|i| i + PitchShift.ar(i,pitchRatio:0.5)}
		}.play
	});
P.tune( Pbindf(_, \out,Effect.bus(FreeVerb.ar(_,1,1),inputChannels:2)));
P.still(\clear,timecode:0,music:{|p b e|
		e.still.value(
			wait: b.sum,
			text: ["I was floating", "in time"]
		)
		.sequenceText(
			[
				b.parse([9]).unbubble,["and","space"]
			]
		)
});
P.synthV(\aiko, 
		pbind: {|p b| [midinote: [13, 4.5].dm('a') ++ [11,6].dm('a-') =>_.q, dur:b.parse([4, 3, 1, 2]).q].p },
		filter: (midinote: _ - 12), 
		params: {|p b| [
		lyrics: "r u - -",
	] }, music:{|p b e|
		{
			e.playbuf
			=> p.synthVTracks.at(e.key).()
			/2
			=> HPF.ar(_,600)
		}.play
	});
P(\bassb,syl:1,music:{|p b e|
	[
		instrument:\stringyy,
		freqLag:[0,0,0].q,
		freq:[11,7,4].df('a',octave: [2,3]).q,
		dur:Song.parse(8,[4,4,3],2).q,
		wet:0
	].ppm
});
P(\bassdouble,syl:1,music:{|p b e|
	[
	//		instrument:\stringyy,
	freqLag:[0,0,0].q,
	freq:[11,7,4].df('a',octave: [2]).q,
	dur:Song.parse(8,[4,4,3],2).q,
	wet:0
].pp
});
P(\bass,syl:1,music:{|p b e|
	 [
		 	instrument:\stringyy,
		 freqLag:[0,14,95].q,
		 freq:[11,7,4].df('a',octave: 3).q,
		 dur:Song.parse(8,[4,4,3],2).q,
 ].ppm
});
['/*MCCOY:*/ He doesnt appear to be harmed - -. Physically, anyway. ',[4,5,6,5,4,5,6, 7,11,7].dm('e' )++[13,11,7,5,4,3].dm('e-',scale:\mixolydian)].addLine; 
// speed up "physically anyway" !!
P(\basslinePhraseTwo,syl:0, music: { |p b e|
	fork{
		var r = Barrier.collect({
				VarSaw.ar(\freq.kr(300,0.3),0,0.5) * \amp.kr(0.1) 
				* Env([0,1,1,0],[0.2,b.drop(1).sum-4,5]).kr(0,gate:\gate.kr(1))
				=> Pan2.ar(_,\pan.kr(0))
				=> {|i| Convolution.ar(i, Dust.ar(50) => Decay.ar(_,0.0005) )
				=> {|i| CombN.ar(i, 0.2,0.11,5)}
			/8 + i => {|i| CombN.ar(i,0.2,0.2,4) / 1.5 + i } }
			=> HPF.ar(_,800)
		}.asDefName );
		[
			instrument: r.value[0].postln,
			// instrument: \default,
			freq: [[-7,1], [3,1 ]].df(\b,5,\mixolydian).q /[2],
			dur: b.drop(1).parse([6,3]) + [0,2] =>_.q,
			pan: [-0.5,0.5],
			amp: [0.06,0.1]
		] => _.ppm 
		}		
});
P.still(\mccoyWide, timecode: 1946.28.seconds, music: { |p b e|
	 e.still.( 
		wait: b.sum,
		text: ["he doesn't appear","to be harmed"],
	).sequenceText2(
			b.parse([10]), [ 
			["physically","anyway"],
			],
	)
});
P.synthV(role: \mccoy, 
	filter: (midinote: _ - 12),  params: {|p b| [
		lyrics: "he does n't a ppere to be harmed - -  physicly + + anyway + +",
		// language: "english",
		// phoneset: "arpabet"
		vocalMode: \Rough
	] }, music:{|p b e|
		{
			e.playbuf
			/5
			// => Vocoder.ar(Saw.ar([ 50,600.rand ]), _, num:12, low:100, high:5000, q:0.02, hpf:5000, hpfscal:0.05, outscal:25)
			// => p.synthVTracks.at(e.key).()
		}.play
	}
);
P(\bass,syl:9,music:Song.currentSong.pbind[9]
=>Pbindf(_,\instrument,\sawSynth,\amp,0.03)
=>Padd(\midinote,(-24),_)
=>Pdrop(10,_)
	);
// P(\tune,music:Song.currentSong.pbind[9]);
P(\baseline,syl:0,music:[ 
	freq:
	[1,11].df('b',octave: 2).q
	,
	dur:Song.parse(9,[9],1).q,
].p

);
['/*KIRK:*/ Spock, I remember. ',[13,13,13,13.5,5].dm('b-',octave:3,scale:\minor )].addLine; 
P.still(\kirk1,
	timecode: 1950.333.seconds, //group shot
	// timecode: 1519.000.seconds, //close
	music: { |p b e|
	 e.still.( 
		wait: b.sum,
		text: ["Spock","I remember!"],
	)
});
P.synthV(role: \kirk, lag: -0.2, params: {|p b| [
	lyrics: "Spock I remember + +",
	lag: 0.2 ! 5,
]}, music:{|p b e|
	{
		e.playbuf => p.synthVTracks.at(e.key).()
		=> Pan2.ar(_,0)
	}.play
});
P(\cello,music:(
instrument:\stringyy,
freq:[1].df('b-',octave: 3),
width:[10,12],
mix:0, amp: 0.035
)
	);
	// P.tune();
P(\pedal, music: { |p b e|
		(
			instrument:\stringyy,
			freq: [-1,1].df('b-',[4,]),
			amp:0.15,
			dur: b.parse([5]) + 3,
			release:8
		).play
	});
P(\chord,music:{ |p b e|
		b.postln;
		[
			strum:0.06,
			freq:[5,11,13].df('b-',octave:[3,4],scale:\minor),
			amp:0.02,
			instrument:\sawSynthSustain,
			dur:b.parse([3]).q
		].pp
	}
	);

P(\chord2,music:{|p b e| [ 
	strum:0.02,
	dur: e.bAll.parse([3, 8,3, 4]).q,
	//out:2,
	instrument:
	//			\cleanPluck,
	// \default,
	\harpS,coef: 0.3,amp:0.01,
	freq: [1, 11].df('b-',3) ++ [ -6.5, -7 ].df('a-',4) => _.q,
	// amp:0.05,
	pan: {1.rrand(-1)}!8,
	out: Effect.bus({|i| i/3 + Phaser1.ar(i,rate:0.21) },inputChannels:2)
].p.play }
);
['When Sargon and I exchanged, ',[6,5,4,5,6,7,11].dm('e-',octave:4)].addLine; 
P.still(\clear, timecode: 0.seconds, music: { |p b e|
	 e.still.( 
		wait: b.sum,
		text: ["when Sargon and I","exchanged"],
	)
});
P.synthV(role: \kirk, params: {|p b| [
		lyrics: "When Sargon + and I exchanged +",
		legato: [1, 1, 1, 1, 1, 1, 0.85, ],
	] }, music:{|p b e|
		{
			e.playbuf
			=> p.synthVTracks.at(e.key).()
			=> Pan2.ar(_,0)
		}.play
	});
	// P.tune()
P(\chord,syl:5,music:{|p b e|
		( 
			strum:0.09,
			instrument:\sawSynthSustain,
			freq: [1,3,5,6].df('f#',octave: 4) ,
			amp:0.02,
			//dur:Song.parse(12,[3],2).q,
			dur:b.drop(1).parse([1]) + e.bNext.parse([2]),// => _.q,
			rel:3,
			//att:1
		).play
	}
	);
P(\bass,syl:5,music:(
		instrument:\sawSynth,
		freq:[1].df('a-',octave: 4),
		//		freq:[1].df('c',octave: 4),
		amp:0.02, out:2
	)
);	
['as we passed each other, for an instant...',[5.5,6].dm('f#',octave:4)++[3,2,2,1].dm('c',octave:5)++[3,2,2,1].dm('c#',octave:5)].addLine; 
P.still(\clear, timecode: 0.seconds, music: { |p b e|
	 e.still.( 
		wait: b.sum,
		text: ["as we passed","each other"],
	).sequenceText2(
			b.parse([6]), [ 
			["for ","an instant"],
			],
	)
});
P.synthV(role: \kirk, params: {|p b| [
	lyrics: "as we passed each other + for an instant + " ,
	legato: [1, 1, 1, 1, 1, 0.8, 1, 1, 1, 1, ],
] }, music:{|p b e|
	{
		e.playbuf
		=> p.synthVTracks.at(e.key).()
		=> Pan2.ar(_,0)
	}.play
});
// P(\tune,music:Song.currentSong.pbind[12]);
P(\bass,syl:1,music:(
instrument:\sawSynthSustain,
freq:[5,17,11].df('c',[3],\minor),
//		freq:[1].df('c',octave: 4),
amp:0.01,
)
	);	
P(\chord,syl:1,music:{|p b e|
		( 
			strum:0.09,
			instrument:\sawSynthSustain,
			freq: [5,11].df('c',4) ,
			amp:0.02,
			dur:Song.parse(12,[3],2), 
		).play
}	);
P(\chordz,syl:1, music: { |p b e|
	[
		[
			freq:[[7,11].df(\c,4),[7,11].df('f#',4)].q,
			out:0,

		]
		,
		
		[
			freq:[[3,5].df(\c),[3,5].df('f#',4)].q,
			out:1,
		]
	].do
	{|i| i ++ 
		[
			dur: b.drop(1).parse([[3,0.5],[0.5,3]]).q,
			instrument:\sawSynthSustain,
			lagTime:1,freqLag:0.8,depth:0.01,amp:0.015,
			rel:[2,4].q,
		] =>_.pm => _.play
	}


});
P(\bassNote,music:[
	freq: [Rest(),[1].df('f#',octave:3)].q ,
	dur: 
	Song.parse(12,[[ 5,0.5 ],[ 0.5,4 ]]) + [0,Song.parse(13,[2]) ]=>_.flatten=>_.q
	,
	instrument: \stringyy ,
].p=>{|i|Ppar([\stringyy,\default].collect{|k x|Pbindf(i,\instrument,k,\amp,{0.1-(x/20)},\out,x)})}
);
['we were one. ',[4,4,5].dm('c')].addLine; 
P.still(\clear, timecode: 0.seconds, music: { |p b e|
	 e.still.( 
		wait: b.sum,
		text: ["we were","one"],
	)
});
P.synthV(role: \kirk, params: {|p b| [
lyrics: "we were one",
] }, music:{|p b e|
{
	e.playbuf
	=> p.synthVTracks.at(e.key).()
	=> Pan2.ar(_,0)
}.play
});
P(\bend,music:{{
var line=Line.kr(1.degreescps('a-'),1.degreescps('g'),Song.parse(13,[3]),[0.5,1]);
var saturation=Line.kr(0.3,0.8,Song.parse(13,[3]));
SinOscFB.ar(line 
	* [1,1.501,2.01]
	,
	saturation,0.004)
	* [1,0.1,0.2]
* Env.linen(1,1,3).kr(2,gate:1)
=> EchoCubic.ar(_,1,0.3,6)
* 3
}.play;
(instrument:\stringyy,note:-2,dur:2,amp:0.15,
//octave: [6,5]
).play
} 
);
P(\triangle,syl:1, music: { |p b e|
	{
		var num = 10;
		Klank.ar(
			`[
				Array.fill(num,{exprand(4000,9000)}),
				Array.series(num,0.1,-0.02),
				{8.0.rand}!num
			],
			Env.perc().kr(2,gate:1) + Impulse.ar(0) * WhiteNoise.ar(0.1)
			/ 60
		)
	}.play
});
P(\chord, music: { |p b e|
[
	freq: [\r, [3,4,6]].df(\a,4,\whole).q,
	dur: b.parse([2,1]).q,
	instrument:\wash,
	att:2,
	curve:3,
	amp:0.02

].pp
});
// P(\tune,music:Song.currentSong.pbind[13]);
//idea: maybe this convergence can be done with phase instead of frequency! 
//try this with a recording of say water or something 
/*
P(\convergenceTest,music:{
	{ // we are one idea
		var divergence = Bus.control(s,4);
		{ { LFBrownNoise2.kr(90) }!4 => Out.kr(divergence,_) }.play;
		{ 
			Saw.ar( In.kr(divergence.index,4)
			*  Line.kr(40,0,dur:6)
			+ [5,10].df() 
			+ LFBrownNoise2.kr(20,mul: Line.kr(30,0,dur:6))
			,0.1)
			*  Env.linen(1,5,3).kr(2)
		}
		.play;
		(dur:10,freq:[1,3,5,7].df(octave:3),out:[0,1,2,3],amp:0.3).play;
	}.value;
}); */
['I know him now. ',[7,11,5,13].dm('a-')].addLine; 
P.still(\kirk3, timecode: 2004.600.seconds, music: { |p b e|
	 e.still.( 
		wait: b.sum,
		text: ["I know","him now!"],
	)
});
P.synthVs(role: \kirk, take:[\lead, \double, \octaveDown],  params: {|p b| [
	lyrics: "I know him now",
	pitchTake: [2, 3, 1],
	filter: [(midinote:_ - 12),(midinote:_ - 12),(midinote: _ - 24)],
	// paramLoudness: [0,0,-8]
] }, music:[ {|p b e|
	{
		e.playbuf
		=> BHiShelf.ar(_, freq:6200.0, rs:1.0, db:4.0, mul:1.0, add:0.0)
		=> p.synthVTracks.at(e.key).(0.2)
	}.play
},{|p b e|
	{
		e.playbuf
		=> BHiShelf.ar(_, freq:6200.0, rs:1.0, db:4.0, mul:1.0, add:0.0)
		=> p.synthVTracks.at(e.key).(0.2)
		=> Pan2.ar(_,0)
	}.play
},{|p b e|
	{
		e.playbuf
		=> p.synthVTracks.at(e.key).(0.2)
		* 0.4
	}.play
} ]);
P(\figure,music:[
	out:3,
	dur: Song.parse(14,[1,2/3,[1/3,1],1/2,1/2]).q,
	//		freq:[Rest()].q++[6,11,5,7].df('a-',octave:3).q,
	freq:[Rest()].q++[6,11,5,11].df('a-',octave:3).q,
	instrument:\sawSynth,
	amp:0.05,
].p
);
P(\lick, music:[
out:2,
amp:0.02,
rel:3,
freq:[Rest()].q++[6,7,11].df('a-',octave:4).q,
instrument:\sawSynth,
dur:Song.parse(14,[1,1,1,1]).q,
].p );
P(\bassKnow,  music: {|p b e|
		[
			freq:[Rest()].q++[4,4,4,5,11,11,7,7].df('a-',octave:1).q,
			dur: Song.parse(14,[1,1/3,1/3,1/3,1,1/4,1/4,1/4,1/4]).q ,
			amp:0.02,
		].ppm(\pluckD);
		[

			freq:[Rest()].q++[4,4,4,5,11,11,7,7].df('a-',octave:2).q,
			dur: Song.parse(14,[1,1/3,1/3,1/3,1,1/4,1/4,1/4,1/4]).q ,
			out: Effect.bus({|i| i.tanh.tanh * -2.dbamp },)
		].pp
	}
);
P(\temp,music:Song.currentSong.pbind[14]=>Pbindf(_,\amp,0.3,\instrument,\stringyy));
['I know what he is and what he wants, ',[15,14,13,12,14,13,7,11,12.5].dm('a-')].addLine; 
Song.setTempoMap('what he is',"e e e e e e e e e");
P.still(\clear, timecode: 0.seconds, music: { |p b e|
	 e.still.( 
		wait: b.sum,
		text: ["I know what he is","and what he wants"],
	)
});
P.synthV(role: \kirk, take: \notNil,  filter: (midinote: _ - 24),  params: {|p b| [
lyrics: "I know what he is and what he wants, ",
lag: [0,0,0,0,-0.2,0,0,0,0],
pitchTake:1,
legato:[1,1,1,1,1,1,1,1,3]
] }, music:{|p b e|
{
	e.playbuf
	=> p.synthVTracks.at(e.key).(0.25)
	=> Pan2.ar(_,0)
}.play
});
//P(\cymbal,music:[
//	instrument:\cymbalsDS,
//	dur: Song.parse(15,[1,4,1]).q ,
//	amp:0.01,
//	note:[ Rest(),1,1 ].q,
//].p);
P(\snare, music: { |p b e|
	[
		dur: "q ex xq ex x".asBeats.warpTo(e.tempoMap).q,
		instrument: \sn_808,
		amp: [0,2,1,2,1]/20=>_.q
	].pp
});
P(\kick,music:{|p b e|
[
	note:"xx.x".asDrumPat(reps:2),
	instrument:\kick,
	//		dur: Song.parse(15,1!8).q,
	dur: 
	Song.currentSong.durs[e.start].list[..7].sum/8
	,
].pp }
);
P(\tune,music:Song.currentSong.pbind[15]=>Pbindf(_,\instrument,\stringyy,\amp,0.3)
);
P(\bass,music:{|p b e|
	[
		amp:0.02,
		freq:[6,6,6,6,5,5,5,5].df('a-',octave:1).q,
		dur:Song.parse(15,1!8).q,
	].pm(\pluckD).play;
	[
		freq:[6,6,6,6,5,5,5,5].df('a-',octave:2).q,
		out: Effect.bus({|i| i.tanh.tanh * -2.dbamp },),
		dur:Song.parse(15,1!8).q,
	].pp 
});
P(\finalBaseNote,syl:7,music: {|p b e|
	(
		release:4,instrument:\pluckDEnv,freq:[4.5].df('a-',octave:1),amp:0.03,
		//addAction:\addToHead,
		dur: b[8],
		out: Effect.bus(
			FreeVerb.ar(_,0.5,1),out:[0,1],inputChannels:2
			=>.first DetectSilence.ar(_,doneAction:2)
		)
	).play;
	(
		freq: 4.5.df('a-',2) ,
		out: Effect.bus({|i| i.tanh.tanh },)
	).play
});
P(\figure,music:{|p b e| [
	rel:4,
	strum:0.02,
	instrument:\sawSynth,
	amp:0.05,
	freq: [  
		[1,3,5,7].df('c#') ,
		[1,3,5,7].df(\c,scale:\minor),
		[3,5,7, 11].df(\g,scale:\mixolydian,octave:3) 
	].q ,
	dur: Song.parse(15,[4, 4,1]).q,
	hifreq:8000,
	out: Effect.bus({|i|
		MoogFF.ar(i,2000,2)
		* 1.3
		=>( CombC.ar(_,0.5,SinOsc.kr(0.3).range(0.4,0.405),decaytime:4)+Gain.ar(_,3) )
	},out:2,inputChannels:2)
].pp
}); 
/* 
P(\figure,music:[
out:3,
freq:[13,11,7,5,4.5].df('a-',octave:3).q,
dur: Song.parse(15,2!4++[1]).q,
instrument:\sawSynth,
amp:0.05, ].p
); */
['and I don`t fear him. ',[4,5,6,7,11].dm(\c)].addLine; 
P.still(\clear, timecode: 0.seconds, music: { |p b e|
	 e.still.( 
		wait: b.sum,
		text: ["and I don't","fear him"],
	)
});
P.synthVs(role: \kirk, take:[\lead, \double], filter: (midinote: _ - 12),  params: {|p b| [
	lyrics:"and I don't fear him" ,
] }, music:[-1,1].collect{|pan| {|p b e|
	{
		e.playbuf
		=> p.synthVTracks.at(e.key).()
		=> HPF.ar(_,500)
		=> Pan2.ar(_,pan)
	}.play
} });
P(\bassConnector, music: { |p b e|
	[
		midinote: Song.tune[e.start].list -12 ++ ( Song.tune[e.start +1].list[[ 0,2 ]] ) /*-12*/ => _.q ,
		dur: b ++ e.bNext.parse([2,2]) => _.q, instrument: \harp,coef:0.9, amp:0.08,
		out: Effect.bus({|i| i => Pan2.ar(_, 0.7) },)
	].pp
});
P(\bassNote,syl:2,music:
	(
		freq:[5].df(octave:2),
		dur:2,
		amp:0.1,
	)
);
// P.tune(_ => Pmul(\freq,0.25,_));
P(\chord,syl:2,music: {|p b e| [
	instrument:\sawSynthSustain,
	att:1.4,
	rel:3,
	lofreq:5000,
	hifreq:6000,
	out:Effect.bus(MoogFF.ar(_,5000,3),out:2,inputChannels:2),
	addAction:\addToHead,
	//			out:2,
	freq:[5,15,24,27].df(\c,octave:3),
	strum:0.02,
	dur: 
	b.drop(1).parse([2]).q
	,
	//			dur:2,
	amp:0.06,
].pp
});
['/*MCCOY:*/ That`s the most ri (boom) ',"c#4 a3 d#4 b3 r "].addLine; 
P.still(\mccoy, timecode: 
	// 1808.6.seconds, //close but not speaking
	1806.9.seconds,

	music: { |p b e|
	 e.still.( 
		wait: b.sum,
		text: ["thats the","most ri-"],
	)
});
P(\swell, music: { |p b e|
{
	Env([0,1],b.parse([4])).kr(2,gate:1)
	*WhiteNoise.ar(0.1)
	=> Allpass2.ar(_,400,0.2)
}.play;
(
	instrument: \cymbalsDS,
	amp:0.03,
	lag: b.parse([5]).unbubble
).play
});
Trek.cast.mccoy=\mo;
Trek.presets.put(\mccoy,\mo,[paramGender:0.25]);
P.synthV(role: \mccoy, take:\lead, params: {|p b| [
	lyrics: "That's the most ri r",
	paramTension: 1,
	paramGender: 0.2,
	loudness: Env([3, 0, 3, 0],b.parse([ 1,1,1,2 ])),

	// vocalMode: \Passionate
	vocalMode: \Clear
] }, music:{|p b e|
{
	e.playbuf
	=> p.synthVTracks.at(e.key).()
	=> Pan2.ar(_,0)
}.play
});
// P(\tune,music:Song.pbind[17] );
P(\boom,syl:3,syl:3,music: {|p b e|
	(instrument:\membrane,out:2,amp:0.05).play 
}
);
P(\line,music:{
[
	instrument:\twang,
	amp:0.03,
	freq:[4,6,7,11.5].df(\e,octave:3).q,
	//			dur: Song.parse(17,[1,[1,1/2],[1/2,1],1]).q,
	dur: Song.parse(17,[1,[1,1/2],[1/2,1,1]]).q++[1].q,
].p 
}.value);
P(\bassnote,syl:3,music:(degree:3,octave:[3,2],amp:0.4,dur:2,)
	);
['diculous statement I`ve ever heard. An ',[5,2,1,4,3,1,2,3,4.5,].dm('b-')++[5].dm(\d)].addLine; 
P.still(\clear, timecode: 0.seconds, music: { |p b e|
	 e.still.( 
		wait: b.sum + e.bNext.sum,
		text: ["diculous","statement"],
	).sequenceText2(
			b.parse([5, 4]), [ 
			["I've ever","heard"],
			["an alien practically","hijacks your body and"],
			],
		)
});
P.synthV(role: \mccoy,double:true, take:\double, filter: (midinote: _ - 12),  params: {|p b| [
	lyrics: "diculus + + statement + I've ever + heard An",
	legato: [1, 1, 1, 1, 1, 1, 1, 1, 0.7, 1],
	lag: [0, 0, 0, 0, 0, 0, 0, 0, 0, 0.05],
	// vocalMode: \Passionate
	vocalMode:\Clear,
	paramTension: 1,
	loudness: Env([3, 0, 3, 0, 3],b.parse([ 1,2,1,4,1 ])),
] }, music:{|p b e|
	{
		e.playbuf
		=> p.synthVTracks.at(e.key).()
		=> Pan2.ar(_,0)
	}.play
});
P(\chord,music:{|p b e| [ 
	strum:0.05,
	out: Effect.bus(
		{ |in|
			EchoCubic.ar(in,1,SinOsc.kr(1/[22, 20 ],[0,pi]).range(0.2,0.3),5)
			=> MoogFF.ar(_,SinOsc.kr(10).range(800,2000))

		}
		,inputChannels:2
	),
	freq:[11,13,15,17,1].df(\f,octave:4),
	dur:
	//			Song.parse(18,[3]).q
	1
	,
].p.fin.play
});
P(\bassNote,syl:7,music:{|p b e| [ 
	amp:0.3,
	out:Effect.bus({|i| FreeVerb.ar(i,0.5,1)})  ,
	freq:[1,11].df(\g,octave:2),
	dur: Song.parse(18,[2],8).q,
].pp }
);		
// P(\tune,music:Song.currentSong.pbind[18]);
['alien practically hijacks your body and ', [11,7,5,6,7,11,14,12,13,14,13,11].dm('d')].addLine; 
P.synthV(role: \mccoy, filter: (midinote: _ - 12), take:\lead,  params: {|p b| [
	lyrics: "alien + + practicly + + hijacks + your body + and",
	phonemes: ["","","","","t ih k","","","","","","",""],
	// vocalMode: \Passionate
	vocalMode:\Clear,
	paramTension: 1,
] }, music:{|p b e|
	{
		e.playbuf
		=> p.synthVTracks.at(e.key).()
		=> Pan2.ar(_, 0)
	}.play
});
P(\bass,music: [ 
	freq: [5,6,11].df('d',octave: 2).q,  
	dur: Song.parse(19,[6,3,3]).q,
].p );
// P.tune();
P(\chords, music: { |p b e|
	[
		freq: [ [5, 12], [6,11 ], [1, 5] ].df(\d, 4) ++ ( p.tune[e.start+1].list.midicps/4 ) => _.q,
		dur: b.parse([6,3,3 ]) ++ e.bNext =>_.q,
		// instrument: \harp, coef:0.2,
		out: Effect.bus({|i| 
			i => CrossoverDistortion.ar(_) /10 
			=> Phaser2.ar(_,rate:0.13) /2 
			* EnvGen.cutoff(b.sum,e.bNext.sum)
		},),
		instrument: \default

	].ppm
});
['corks you into a bo -- ttle  and', [1,2,3,4,5,6,7,1,6].dm('c',octave:6)].addLine; 
P.still(\clear, timecode: 0.seconds, music: { |p b e|
	 e.still.( 
		wait: b.sum,
		text: ["corks you","into a bottle and"],
	)
});
P(\cymbal, syl:4, music: { |p b e|
	(
		instrument: \cymbalsDSStereo,
		amp:0.0008
	).play
});
P.synthV(role: \mccoy, filter: (midinote: _ - 12), take:\lead,  params: {|p b| [
	lyrics: "corks you into + a bo - ttle and",
	legato:[1,1,1,1,1,1,1,0.5,0.6],
	// vocalMode: \Passionate
	vocalMode: \Open,
	paramTension: 1,
	loudness: Env([0,6,2],b.parse([5,2,2]))
] }, music:{|p b e|
	{
		e.playbuf
		=> p.synthVTracks.at(e.key).()
		=> Pan2.ar(_, 0)
	}.play
});
P.tune( _ <> [instrument:\stringyy, wet:0].pm );
//	P(\tune,music:Song.currentSong.pbind[20]);
P('swell20',lag: -0.1,music:{|p b e|
	(
		curve:'sin',instrument:\swell20,attack:2,release:5,amp:0.04,freq: [1,11].df('c',octave: 3)).play
	});
//['/*MULHALL:*/ I`m afraid that I must agree with Doctor McCoy. You could be suffering from a form of false euphoria. ',"r"].addLine; 
['/*MULHALL:*/ I`m afraid I agree with Doctor McCoy. You could be suffering from a form of false euphoria.(ooh -- --) ', [ 3,4,2,3,1, 5,3,4,5,3,6, 4,5,6,11,7,2 ].dm('e',scale:\dorian) ++ [4,5,6,7].dm('c') ++ [13,14,13,12,11, 12,11,7].dm('f#',octave: 5) ].addLine; 
Song.euphoriaTempoMap = TempoMap.new( Song.durs[\euphoria].list[(21..28)],"qe x xqe x xqe x xq q".asBeats );
P.still(\mulhallClose, timecode: 
	1503 //closeUp mouth closed
	// 2020.9


	.seconds, music: { |p b e|
	 e.still.( 
		wait: b[..21].sum,
		fade: b[22..].sum,
		text: ["I'm afraid I agree","with doctor McCoy"],
	).sequenceText2(
			b.parse([11,6, 4, 8]), [ 
			["you could be","suffering"],
			["from","a form of"],
			["",""],
			],
	)
});
P.still(\clear,syl:20, timecode: 0.seconds, music: { |p b e|
	 e.still.( 
		wait: b.sum,
		text: ["false","euphoria"],
	)
});
P(\shaker,syl:20, music: { |p b e|
	[
		dur: [10,11].dup(16).flat / 21 /2 
		warpTo: ( p.parse(e.start,[2/3,[1/3,1,1/7],4/7,[2/7,1,1/7],4/7,[2/7,1,1/5],4/5,1],21) 
		// => _.push(7,-0.02)
		// => _.push(6,-0.02)
		=> TempoMap(1!8,_) =>_.quantize(0.8) ) => _.q,
		instrument:\cymbalsDS,
		instrument:\hat_808,

		amp:[4,2,3,2] -0.5 /40 =>_.q(inf),
	].pp
});

P.synthVs(\feng, take: [nil,3],
params: {|p b| [
	lyrics: "I`m afraid + I agree + with Doctor + McCoy + You could be suffering + + from a form of false euphoria + + + - - -",
	filter: (midinote: _ - 12),
	loudness: [[10, 10, 12, 6, 6, 6, 6, 4, 4, 4, 4, 4, 4, 4, 0, 4, 4, 8, 6, 6, 6, 0, 0, 0, 0, 0, 0, 0, 0]] => Env(_,b),
	legato: [[1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 0.6, 1,   1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1 ]],
	lag: [[0,    0, 0, 0, 0, 0, 0, 0, 0, 0, 0,   0.1, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0]]

]}, music: [(pan:0,amp:0),(pan:0.9,amp:-1)].collect{|event| {|p b e|
	{
		e.playbuf
		=> p.synthVTracks.at(e.key).()
		=> HPF.ar(_,100)
		* event.amp.dbamp
		=> Pan2.ar(_,event.pan)
		/2

	}.play
}}
);
P(\bassline,music:[
	dur:Song.parse(21,[2,2,5,5],).q,
	freq:[3,2,1,13].df('e',octave: 3,scale:\minor).q,
	legato:[0.95,0.95,2,1].q,
	amp: [1, 1, 1, 0.5] /10 => _.q
].p
);
P(\arpeggio,syl:9,music:{|p b e| 
	[
		amp:0.6,
		dur:3,
		out:Effect.bus({|i|Pan2.ar(i,SinOsc.kr(2))=>EchoNone.ar(_,0.9,[0.3, 0.21 ],4)=>Phaser2.ar(_,0.5,1/4)},inputChannels:2,out:1),
		instrument:\cleanPluck,
		strum:0.08,
		freq:[7,13,15,20,23].df('a',octave:3,scale:\mixolydian ),
	].p.fin.play
});
P(\bassNote,syl:13,music:
	[ 
		dur:Song.currentSong.parse(21,[3,4],14).q ,
		freq:[7,4].df('c',octave: 3).q,
		//	octave:3,
	].p
);
P(\euphoriaLine, syl:20, music: { |p b e|
	[
		[
			freq: [5, 5.5, [ 3, 5, 6 ], [2,6]].df('f#').q,
			dur: "qq qq qq q".asBeats.warpTo(
				b.drop(1).parse([2/3,[1/3,1,1/7],4/7,[2/7,1,1/7],4/7,[2/7,1,1/5],4/5,1]) 
			)
			=> _.q
		].p;
		,
		[
			freq: [-7, -6].df('f#').q,
			dur: "qqqq qq".asBeats.warpTo(
				b.drop(1).parse([2/3,[1/3,1,1/7],4/7,[2/7,1,1/7],4/7,[2/7,1,1/5],4/5,1]) 
			)
			=> _.q
		].p
	]
	=> Ppar(_)
	<>
	( instrument: \visual_pad,
		amp: 0.3
	)
	=> _.play
});
P.synthV(\feng, take: \harm1,
	pbind: {|p b| [
		midinote: 1!21 ++ [ 11, 11, 7, 7, 6, 6, 6, 6 ] =>_.dm('f#') =>_.q,
		dur: p.durs[\euphoria]
	].p},
	params: {|p b| [
	lyrics: "r r r r r r r r r r r r r r r r r r r r r false euphoria + + - - r r",
	pitchTake: 1
] }, music:{|p b e|
	{
		e.playbuf
		=> p.synthVTracks.at(e.key).()
	}.play
});
P(\euphoriaChords,syl:20,music:{|p b e|
	[
		freq:[[ 1,3,5 ]].df('f#',octave: 4).q(2)
		++ [[5,11,13]].df('b-',octave: 3).q(2)
		++ [[3,5,11]].df('e-',scale:\minor,octave: 4).q(2)
		++ [[5,11]].df('c#',scale:\minor,octave: 4).q(2)
		,
		dur:p.parse(e.start,[2/3,[1/3,1,1/7],4/7,[2/7,1,1/7],4/7,[2/7,1,1/5],4/5
		,1
	],21).q,
	out:Effect.bus(EchoCubic.ar(_,0.3,0.25,4)),
].p.play
}
);
// P(\tune,music:Song.currentSong.pbind[21]);
["Sargon. (boom) ",[3,2,-5].dm('a')].addLine; 
P.still(\kirkClose, timecode: 2026.seconds, music: { |p b e|
	 e.still.( 
		wait: b[..1].sum,
		text: ["",""],
	).sequenceText2(
			b.parse([1]/2), [ 
			["Sargon!",""],
			],
	)
});
P.still(\sargon1,syl:1, timecode: 2028.seconds, music: { |p b e|
	 e.still.( 
		wait: 0,
		fade:e.bNext.sum,
		text: ["",""],
	)
});
// P(\tune,music:Song.currentSong.pbind[22]);
P.synthV(role: \kirk, take:\lead,
	pbind: {|p b|
		[
			dur: b.parse([0.5,[0.5,0.5],0.5,1]),
			midinote: [0, 61, 59, 0] +12
		].p
	},
	filter: (midinote: _ - 12),
		params: {|p b| [
		// lag: b.parse([0.5,[0.5,1],0]),
		// lag: [0.2,0,0]
	lyrics: "r Sargone + r",
] }, music:{|p b e|
	{
		e.playbuf
		=> p.synthVTracks.at(e.key).()
		=> Pan2.ar(_,0)
	}.play
});
P.tune( {|i| i.fin(2) <> [instrument: \stab, ctranspose: [0, -12 ]].p} );
P(\bassnote,syl: 1, music: { |p b e|
	(freq:[1,-1].df(\d,3), out: Effect.bus(DWGReverbC1C3.ar(_).tanh)).play;
	(instrument: \cymbalsDSStereo,amp:0.001).play
});
P(\bas,music:{|p b e |
	(
		strum:0.04,
		out:[0,2],
		amp:0.03,
		instrument:\sawSynthSustain,
		freq:[1,5,11,16.5].df('a',octave: 2),
		rel:5,
	).play 
});
P(\arpeggio,music: {|p b e|
	[ 
		amp:0.02,
		freq: [7,11,13,15]+.x [0,10,20] => _.sort
		=>_.df('a',octave:3),
		strum:0.07,
		//	lag:-0.1,
		effect:  Effect.bus(EchoCubic.ar(_,rrand(0.2,0.6!4),1,7!4),inputChannels:4),
		scale:Scale.mixolydian,root:-3,
	].p.fin.play
});
['/*SARGON [OC]:*/ I understand, my son. Go to your vessel.', [11,11,11,11,7,7,7,11,12,14,13].dm('c')].addLine; 
P.still(\clear, timecode: 0.seconds, music: { |p b e|
	 e.still.( 
		wait: b.sum,
		text: ["I understand","my son"],
		fade: 3.collect({|x| Song.secDur[e.start + x]}).sum
	).sequenceText2(
			b.parse([6,5]) , [ 
			["go to your","vessel"],
			["",""]
			],
	)
});
P(\drone,music:{ |p b e| 

	[ instrument:\sawSynthSustain,
		amp:0.02,
		att: 0.3,
		freq: [ [2,12  ],[2, ],[1] ] =>_.df('c',octave: 3)=>_.q ,
		legato: 1,
		dur: b.parse([4,5,2]).q
		,
		//		out:parent.carrier.index,
	].p.play }
);
( SynthDef("goToYourVessel", { arg out=0, freq = 440, amp = 0.1, att = 0.1, rel = 2, lofreq = 1000, hifreq = 3000, lagTime = 0.3, spread=1, center=0, pulse = 0, t_trig = 0;
		var env, snd;
		freq=Lag.kr(freq,lagTime);
		env = Env.asr(
			attackTime: att,
			sustainLevel: amp,
			releaseTime: rel,
		).kr(gate:\gate.kr(1),doneAction: 2);
		snd = Saw.ar(freq: freq * [0.99, 1, 1.001, 1.008]) * env;
		snd = snd * ( (1 - pulse) + (pulse * Env.perc(att,\pulseRel.kr(1) ).kr(0,gate:t_trig)) );
		snd = LPF.ar(
			in: snd,
			freq: LFNoise2.kr(1).range(lofreq, hifreq)
		)
			=> FreeVerb.ar(_,0.5,1)
			=> Decimator.ar(_,8000,8)
			// *100
			;
		snd = Splay.ar(snd,spread:spread,center:center);
		Out.ar(out, snd);
	}).add;
);
P.synthV(role: \vocoder, frozen: true,
	filter: (midinote: _ - 12),  params: {|p b| [ lyrics: "I, understand, +, +, my, sun, go, to, your, vessel, +, ",
legato: [1, 1,          1, 1, 1,  0.7,   1,  1,  1,    1,      0.8] ,
	defaultVibratoDepth:0.3,

] }, music:{|p b e|
 p.pbind[e.start].patternpairs ++[
	 freq: Pfunc({|e| e.midinote.midicps/[1, 2 ]}),
	 instrument:\sawSynthSustain,
	 att:4,
	 amp:0.1 /4,
	 freqLag:0.05,
	 out:p.carrierBus 
 ]// =>_.ppm; 
 ;
p.vocodeTune.( p, b, e, e.rpp,
	mix:0.1,
	chord:#[ 1,2, 4],
	modGain: 1.25,
	amp:0.32,
	// amp:0,
	dur:b.sum,
	sus:b.sum,
	verb:0,
	att:0,
	durRel:0.0,
	rel:0,
	// out:3
);
	{
		PlayBuf.auto(1,p.laMer,
		rate: midiratio( 
			// (5) +
			[-2 ,-5, 0].dq.demand(b.parse([4,5,2])) ),
			trigger: Impulse.ar(1) - 0.1
		) 
		// * Env([1,1,0],[b.sum-3,1]).kr(2,gate:1)
		* Env([0,0,1,1,0],b.parse([4,2,5])).kr(2)
		// / 2
		=> Out.ar(p.carrierBus,_)  
	}.play;
[
	freq: [2,4,6,11].dup(4) ++ [2,4,5,7].dup(2) => _.df('c',octave:4) =>_.q ,
	instrument:\goToYourVessel,
	legato:0.95,
	amp:0.2,
	dur:b.q,
	out:Song.carrierBus.index,
].pm.trace.play

});
P(\bass,syl:8,music:
	{ |p b e| 
		[
			amp:0.3,
			amp:2,
			instrument:\test,
			freq: [1].df('c',octave: 3).q(1),
			dur:b.sum,
			out: p.carrierBus.index
		].pp
	}
);
['all that are invo -- -- lved must agree',[15,14,13,12, 11,12,11,7,11,11.5].dm('g',octave:4)].addLine; 
P.still(\clear, timecode:0.seconds, music: { |p b e|
	 e.still.( 
		wait: b.sum,
		text: ["all that are involved","must agree"],
	)
});
P(\descant,music:{|p b e| [
	freq:[[7, 12 ],[ 13,11 ],[ 11,5 ],[11,5.5]].df('g',octave: 5).q,
	dur: Song.parse(24,[2,2,5,1]).q,
	out:  Effect.bus(EchoNone.ar(_,1,[0.2, 0.3 ],3),inputChannels:2),
	amp:0.01,
].ppm(\sawSynthSustain) }
);
P.synthV(role: \vocoder, frozen: true, filter: (midinote: _ -12 ),  params: {|p b| [
lyrics:"all that are involved + - -  must agree +",
defaultVibratoDepth:0.2,
legato:[1,1,1,1,1,1,1,0.8,1,0.90]
] }, music:{|p b e|
p.vocodeTune.(p,b,e,e.rpp,amp:0.22,dur:b.sum+1,att:0.2,sus:b.sum-0.1,rel:0.2,modGain: 1.25);
// p.tune[ e.start ]<> [instrument: \stringyy,depth: 0, out: Song.carrierBus ].p
[
	midinote: p.tune[e.start].list ++ p.tune[e.start + 1].list => _.flat => _.q
	, dur: p.durs[e.start].list ++ p.durs[e.start + 1].list => _.flat =>  _.q
].postln
++[
	 freq: Pfunc({|env| env.midinote.midicps / [2,4,8]}),
	 instrument:\sawSynthSustain,
	 att:4,
	 amp:0.1 /2 ,
	 freqLag:0.05,
	 out:p.carrierBus 
 ] =>_.pm 
 =>_.play; 

// e.buffer.().free
});
P.tune( { |i|  Pmul(\freq,0.25,i) => Pset(\out,Effect.bus(DWGReverbC1C3.ar(_) /4),_) } );
['after all these centuries ', [7,11,16,15, 15,16,14].dm('e',4,scale:\harmonicMinor) ].addLine;
P.still(\clear, timecode: 0.seconds, music: { |p b e|
	 e.still.( 
		wait: b.sum,
		text: ["after all these","centuries"],
	)
});
P.synthV(role: \vocoder, frozen: true,
// filter: (midinote: 50!7),
filter: (midinote: _ - 12), 
// pbind: {|p b| [ dur:p.durs[Song.section(\centuries)],midinote: 50!7 ].p},
params: {|p b| [
lyrics: "after + all these centuries + +",
legato: [1,1,1,1,1,1,0.95]
] }, music:{|p b e|
	p.vocodeTune.(p,b,e,e.rpp,amp:0.14,dur:b.sum+1,att:1,sus:b.sum-2,rel:2,chord:[0.5,1,2],modGain: 1.25,durRel:0.1);
	{
		PlayBuf.auto(1,p.laMer,rate:0.midiratio)
		* Env([0,0,1,0,0],b.parse([3,1,3]) ++ [2] -[0,0,0.3,0],curve:[-3,3,0]).kr(2,gate:1)
		* 10
		=> Out.ar(p.carrierBus,_)
	}.play

});
P(\orch_hit, music: { |p b e|
	{
		PlayBuf.auto(1,p.laMer,rate:0.midiratio)
		* Env([0,0,1,0,0],b.parse([3,1,3]) ++ [2],curve:[-3,3,0]).kr(2,gate:1)
		* 0.9
		// *15
		// => Out.ar(p.carrierBus,_)
	}.play
});
P(\chord,syl:3,music:{ |p b e|
(
	amp:0.02,
	strum:0.06,
	instrument:\sawSynthSustain,
	freq:[1,3,5,7].df('c',octave: 4),
).play
});
P(\bassnote,syl:3,music:{ |p b e| 
	[ 
		dur: ( Song.parse(25,[3],4)++Song.parse(26,[2,4,1]) ++ Song.secDur[27]) 
		.clumps([ 2,1,1 ]).collect(_.sum).q ,
		amp:0.25,
		instrument:\stringyy,
		freq:[11,12,5].df('c',octave: 2).q, 
	].pp 
});
P(\wobble,music: {|p b e|
	[
		//		instrument:\sawSynth,
		amp:0.05,
		//		instrument:\tri,
		freq:[3,4].df('b',octave:4 ).q(inf),
		out: Effect(EchoNone.ar(_,1,0.3,decaytime:5)).bus.index,
		dur: Song.parse(25,1!4).q,
	].ppm(\sawSynth)
});
P(\wobble2,music: {|p b e|
	[
		//		instrument:\sawSynth,
		amp:0.05,
		//		instrument:\tri,
		freq:[1.5,2].df('d',octave:4 ).q(inf),
		out: Effect.bus(EchoNone.ar(_,1,0.3,decaytime:5),out:1),
		dur: Song.parse(25,1!4).q,
	].ppm(\sawSynth)
 }
);
// P('tune25',music:Song.currentSong.pbind[25]);
['we can wait a few more hours',[1,2,3,4,5,6,5].dm('d')].addLine;
P.still(\clear, timecode: 0.seconds, music: { |p b e|
	 e.still.( 
		wait: b.sum,
		text: ["we can wait","a few more hours"],
	)
});
P.synthV(role: \vocoder, frozen: true, filter: (midinote: 50!6),  params: {|p b| [
	lyrics: "we can wait a few more hours",
	lag: [0.1, 0, 0, 0, 0, 0, 0]
] }, music:{|p b e|
p.vocodeTune.(p,b,e,mix:0.8,att:0,amp:0.14,dur:b.sum+1,chord:[1,2,0.3,0.2],modGain: 1.25,durRel:1);
});
P(\resolution,syl:5,music:{ |parent durs|
	[
		freq:[2,1].df('g',octave: 4).q,
		//				dur:durs.q,
		dur:parent.parse(26,[1],6).q++[2].q,
		instrument: \sawSynthSustain,
		amp: 0.05,
		out: Effect.bus{|i| RLPF.ar(i, Env.perc(0.5,2).kr(gate:1) * 1400 + 800,0.3) }
	].ppm
}
);
['/*MCCOY:*/ And what if we decide against you? ', [7,6,5,4,5,6,7,12,11.5].dm('e')].addLine;
P.still(\twoShot, timecode: 2039.seconds, music: { |p b e|
	 e.still.( 
		wait: b.sum,
		text: ["and what if we decide","against you?"],
		fade:2
	).sequenceText2(
		b.sum, [
			["",""],
			],
	)
});
P.synthV(role: \mccoy, filter: (midinote: _ - 12),  params: {|p b| [
	lyrics: "and what if we decide + against + you?",
	vocalMode: \Open,
	paramTension: 0.9
] }, music:{|p b e|
	{
		e.playbuf
		=> p.synthVTracks.at(e.key).()
		=> Pan2.ar(_, -0.5)
	}.play
});
P(\resolution,syl:6,music:{ |p b e|
	[
		freq:[3,2].df('e-',octave: 5,scale:\minor).q,
		//				dur:durs.q,
		dur:b.drop(1).parse([1,1]).q,
		instrument: \sawSynth,
		att:0.5,
		rel: b.drop(1).sum + 2,

		stretch:[1.1,1].q,
		out: Effect.bus({|i| RLPF.ar(i, Env.perc(0.5,b.drop(1).sum + 1).kr(gate:1,doneAction:2) * 1400 + 800,0.3)},out:4 )
	].ppm
}
);
['/*SARGON [OC]:*/ (beat) Then you may',[1,5,5,4].dm('c#')].addLine;
P.still(\clear,syl:0, timecode: 0.seconds, music: { |p b e|
	 e.still.( 
		wait: b.drop(1).sum + e.bNext.sum,
		text: ["then you may go","as freely as you came"],
	)
});
P.synthV( role:\vocoder, take:\lead, frozen: true,resources:(tail:9), 	pbind: Song.enlarge(8),
	params: {|p b| [
		filter: ( midinote: _ - [0, 0, 0, 0, 12, 12, 12, 12, 12, 12, 12, 12, 12] ),
		lag: [0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0.08],
		// filter: (midinote: 64!12),
		lyrics: "r then you may go as freely - + as you came",
		legato: [1, 1, 1, 1, 1, 1, 1, 1, 0.95, 1, 0.8, 1],
		defaultVibratoDepth:0.2
	] }, music:{|p b e|
	p.vocodeTune.( p, b, e,
		mix: 0.5,
		tune:  p.tune[e.start].list ++ p.tune[e.start+1].list ,
		amp:0.20,
		dur:b.sum + e.bNext.sum+1,
		sus:b.sum + e.bNext.sum+1,
		chord:[2,1,0.5,0.2],
		modGain: 1.25,
		enlarge:7,
		durRel:3,

	)
});
P('tune28',music:Song.currentSong.pbind[28] =>Pbindf(_,\amp,[0].q++[0.1].q(inf)));
P('extra-note28',music: {|p b e| 
(
	amp:0.04,
	freq:[1,11].df('a-',octave: [3, 4 ]),
	instrument:\sawSynth,
).play 
});
[' go as free -- ly as you came.',[13,12,13,14,13,12,7,11].dm('c#')].addLine;
// P.tune();
( SynthDef(\cleanPluck,{
DWGPlucked2.ar(
	\freq.kr(300),
	\amp.kr(0.1),
	\gate.kr(1),
	\position.kr(0.14),
	1/\decay.kr(10),
	\damping.kr(30),
	Impulse.ar(0)*\volume.kr(0.1),
	\detune.kr(1.08),
	\coupling.kr(0.01))
	=> Out.ar(\out.ir(0),_)
}
).add;
);
P(\accompaniment,music:
{|parent durs|
	[
		amp:0.07,
		coupling:0.001,
		midinote:[3,5,11,3,  4,6,11,3,  2,5,11,2,  4,6,11,2, [3,6]].dm('c#',octave:5 ).q,
		position:Pwhite(0.1,0.16),
		legato:1.55,
		effect: Effect(DWGSoundBoard.ar(_)++DelayN.ar(_,0.1,0.1),inputChannels:2).dur(Song.secDur[29]+1).bus.index,
		out:Pkey(\effect),
		dur:parent.parse(29,[1/7,1/7,1/7,1/7,1/7,1/7,1/7,
			1,1,1,
			1/4,1/4,1/4,1/4,
			1,1,
			1
		]).q,
		instrument:\cleanPluck,
	].pp;
}
);
P(\bass,music: {|p b e|
	[
		freq:[1,1,4,4,5,5,5,5,1].df('c#',octave: 3).q,
		dur:Song.parse(29,[1/7,1/7,1/7,1/7,1/7,1/7,1/7,
			1,1,1,
			1/4,1/4,1/4,1/4,
			1,1,
			1
		]).clumps([ 3,1 ]).collect(_.sum).q
	].pp; }

);
//MUTEDP(\machine,music:
//MUTED{ 6.do{{ SinOscFB.ar(100.rand+300+SinOscFB.kr(1/5,3,mul:5),SinOscFB.kr(1/2,3).unipolar*3,0.1) =>LPF.ar(_,6000)=>Pan4.ar(_,rrand(-1,1),rrand(-1,1))
//MUTED=>EchoNone.ar(_,1,0.6,3)
//MUTED* 0.04
//MUTED}.play(s)} }
//MUTED);





)


