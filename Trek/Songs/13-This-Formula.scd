(
s.waitForBoot{ 
	Song('this formnula',[]).current;
	// Stills("/Users/michael/trek/BySection/media/return to tomorrow.mov").current;
	Stills().current;
	Song.currentSong.infrastructure=FunctionList.new.array_([
	]);
	~clocks=SongArray.new(size:64);
	~clock={|tempi| 
		var clock;
		clock = TempoClock.new();
		tempi.do{|i x| clock.sched( x , { clock.tempo_(i.reciprocal) } )};
		\makingAClock.postln;
		clock
	};
	//This Formula (REAPER?) 
	Song.preroll_(1);
( Trek.cast.formulaLead = (\ninezero);
	Trek.presets.put(\formulaLead,\ninezero,
		[
			paramTension:-0.2,
			paramBreathiness:0.2,
			vocalMode: \Muted
		]
	);
);
["Now...","3".dm(\a)].addLine;
P.still(\henoch, timecode: 3005.4.seconds, music: { |p b e|
	 e.still.( 
		wait: b.sum,
		text: ["",""],
	)
});
P.synthVs(role: \formulaLead, take:[\lead, \double],
		filter: (midinote: _ - 12), 
		params: {|p b| [
		lyrics: "now",
		pitchTake: [1, 3]
	] }, music:{|p b e|
		{
			e.playbuf
			=> p.synthVTracks.at(e.key).()
			=> Pan2.ar(_,0)
		}.play
});
P(\chord, music: { |p b e|
		(
			freq: [1,3,5,7].df(\a,3,\mixolydian),
			dur:b.sum-0.1
		).play
});
["(boom) this formula -- -- will reduce the ", [11,13,13,12,11,12,11, 7,11, 12, 13].dm('d',octave:4 )].addLine;
Song.setTempoMap(\reduce,"q q e x xqqe x x e x xe e");
P.still(\henoch, timecode: 3009.seconds, music: { |p b e|
	 e.still.( 
		wait: b.sum,
		text: ["",""],
	).sequenceText2(
			b.parse([1]), [ 
				["this formula","will reduce the"],
			],
	)
});
Song.formulaQuantAmount = 0.78;
// P.tune( 'formula --',Pset(\dur, Song.tempoMap[ 'this for' ] .beats.warpTo(Song.tempoMap[ 'this for' ].quantizeDft).q,_));
P(\drumz,'this formula',music:
	{|p b e|
		//move this out to apply to whole section??
		var map = e.tempoMap.quantizeDft(p.formulaQuantAmount).postln;
		[
			"q q q q".asBeats
			.dup.flat
			.warpTo(map)
			.q
			=> [dur:_, instrument:\sn_808 ]=>_ .p
			,
			"q qe ee e".asBeats
			.dup.flat
			.warpTo(map)
			.q
			=> [dur:_, instrument:\kick2, ] =>_ .p
		] => Ppar(_)
		=> _.play
	}
);
P.synthV(role: \formulaLead,lag: -0.02, take: \lead, params: {|p b| [
	lyrics: "r this formula + + - - will reduce + the ",
	lag:[0,0,0,0,0,0,0,0.1,0,0],
	pitchTake: 1,
] }, music:{|p b e|
	{
		e.playbuf
		// => p.synthVTracks.at(e.key).()
		=> Pan2.ar(_)
	}.play
});
P.synthVs(\mo, take:[\lead, \double], lag: -0.03, params: {|p b| [
	lyrics: "r this formula + + - - will reduce + the ",
	lag:[[0,0,0,0,0,0,0,0.1,0,0]],
	pitchTake: [1, 3],
	paramTension:-0.2,
	paramBreathiness:0.2,
	vocalMode: \Muted
] }, music:
[-1,1].collect{|pan|
	{|p b e|
		{
			e.playbuf
			// => p.synthVTracks.at(e.key).()
			/4
			=> HPF.ar(_,170)
			* -2.dbamp
			=> Pan2.ar(_)
		}.play
	}
});
P.synthV(\kevin, take:\harmony,
	filter: (midinote: [-1, 1, 1, -7, -6].dm(\d)), 
	params: {|p b| [
	lyrics: "r this formula + + r r r r r r",
	pitchTake: 1,
	vocalMode: \Soft
] }, music:{|p b e|
	{
		e.playbuf
		/8
		=> Pan2.ar(_,1)
		// => p.synthVTracks.at(e.key).()
	}.play
});
P.double(\kevin, take: \harmony, params: {|p b| [
	
] }, music:{|p b e|
	{
		e.playbuf
		/8
		=> Pan2.ar(_,1)
		// => p.synthVTracks.at(e.key).()
	}.play
});
P.synthVs(\an, take: [\ooh, \ooh2],
	pbind: {|p b|
		[
			midinote: [5, 6, 4].dm(\d).q,
			dur: "qqqq qqqq ".asBeats.warpTo( Song.tempoMap[ \reduce ].quantizeDft ) 
			++ [1] => _.q
			// dur: b.parse( [4,6, 3] ).q
		].p
	},
	params: {|p b| [
	lyrics: "ooh - -",
	pitchTake: [1, 3],
	 // vocalMode: \Open,
	// pitchExpression: 1.5
	paramBreathiness: 0.25
] }, music:[-1, 0.6].collect{|pan| {|p b e|
	{
		e.playbuf
		=> FreeVerb.ar(_,0.2,1)
		/3
		// * -2.dbamp
		=> Pan2.ar(_,pan)
		// => p.synthVTracks.at(e.key).()
	}.play
} });
( Song.formulaBass = [

	instrument:\sawSynth,
	// instrument: \bl, amp:0.13,
	// instrument: \pulse, amp:0.03


	amp: 0.08
];
);
Song.chankSwitch = \u;
P(\chank, music: { |p b e|
	var out = Effect.bus({|i|
		AnalogVintageDistortion.ar(i,drivegain: 1.8,bias:0.18,shelvingfreq:600,lowgain:0.00,highgain:0.8) / 15 
		* -6.dbamp
		// => Pan2.ar(_, Env([1, -1, 1, -1, 1, -1, 1, -1],"q q q q q q q q".asBeats.warpTo( e.tempoMap )).kr(2, gate:1))
	});
	[
		freq: [[5, 11, 13],[5, 7, 13],[6, 11, 13],[5, 7, 12, 13]].df(\d,4).q,
		instrument: \defaultPiano,
		dur: "qq qq qq qq".asBeats.warpTo( e.tempoMap ).q,
		// type: \strum,
		// instance: p.guitar,

		out:  out
	].pp;
	[
		freq: [[5, 11, 13],[5, 7, 13],[6, 11, 13],[5, 7, 12, 13]].df(\d,4).q,
		instrument: \defaultPiano,
		dur: "qq qq qq qq".asBeats.warpTo( e.tempoMap.quantizeDft ).q,
		type: \strum,
		instance: p.guitar,

		out:  out
	].pp;
	[
		type: \strum,
		rest: [\r,1].q(inf),
		instance: p.guitar,
		dur: "q q q q q q q q".asBeats.warpTo( e.tempoMap.quantizeDft ).q,
		lag: 0.01,
		// switch:\muted,
		// switch:\alt,
		switch: p.chankSwitch,
		out:  out
	].pp

});
Song.guitar = ~guitar ? AAS_Strum(); ~guitar = Song.guitar;
Song.guitar.setPlayMode(\strum);
P(\bass,'this formula',music: {|p b e|
		[ 
			freq: [1,-7,-6,-5].collect{|i x| i.dup([2,3,2,2][x])}.flat
			.df('d',tuning:\sept1,octave:[3,4]).q ,
			dur: [3,1, 1,2,1, 3,1, 3,1]/2=>_.warpTo(e.tempoMap.quantizeDft) =>_.q,
		] ++ Song.formulaBass => _.ppma
	});

( Song.hatPattern={ | map num=64 | 
	(1/4).dup(num)
	.warpTo(map)
	.q
	=> [
		dur:_,
		stretch:[10,9].reverse.q(inf)/9.5,
		instrument:\hihat,
		amp:[12,5,10,5].q(inf)/100
	] =>_.pp 
}
);
P(\highHat,start:'this formula',music:{|p b e|
p.hatPattern.(
	e.tempoMap.quantizeDft(p.formulaQuantAmount)
)
.play
//.patternpairs[1].list.postln
//=>_.play( Song.quarters[e.start].quantizeWindow.asTempoClock)
});
["(boom )heart action and the bodily " , [6, 14,13,11, 7,11,12,13,11].dm('d',octave:4 )].addLine ;
P.still(\clear,syl:0, timecode: 0.seconds, music: { |p b e|
	 e.still.( 
		wait: b.drop(1).sum,
		text: ["heart action","and the bodily"],
	)
});
P.synthV(role: \formulaLead, take:\lead,
	pbind: Song.enlarge(5,2) ,
	params: {|p b| [
		lyrics: "r heart action +  and the bodily + + functions + to normal +",
		pitchTake: 1,
		legato: [ 1,  1, 1, 0.6, 1, 1, 1 ]
	] }, music:{|p b e|
	{
		e.playbuf
		=> Pan2.ar(_)
		// => p.synthVTracks.at(e.key).()
	}.play
});
P.synthV(\mo, take:\lead,
	pbind: 
	Song.enlarge(5,2)
	,
	params: {|p b| [
	lyrics: "r heart action +  and the bodily + + functions + to normal +",
	legato: [ 1,  1, 1, 0.6, 1, 1, 1 ],
	pitchTake: 1
] }, music:{|p b e|
	{
		e.playbuf
		/4
		// => p.synthVTracks.at(e.key).()
	}.play
});
P.double(\mo, params: {|p b| [
		
	] }, music:{|p b e|
		{
			e.playbuf
			// => p.synthVTracks.at(e.key).()
			/4
		}.play
	});
	P.synthV(\kevin, take: \harmony,
		pbind: {|p b|
			[
				midinote: [-1, 6, 5, 5, 5].dm(\d).q,
				dur: b.parse( [1, 0.66,  0.33, 1 , 1 ] ).q
			].p
		},
		legato: [ 1, 1, 0.6, 0.7 , 0.6 ],
		params: {|p b| [
		lyrics: "r heart - action +",
		pitchTake: 1,
		vocalMode: \Soft
	] }, music:{|p b e|
		{
			e.playbuf
			// => p.synthVTracks.at(e.key).()
			/8
		}.play
	});
	P.double(\mo, take: \harmony, params: {|p b| [
		
	] }, music:{|p b e|
		{
			e.playbuf
			// => p.synthVTracks.at(e.key).()
			/8
		}.play
	});
Song.setTempoMap('and the bodily', [1,7/4,2/4,7/4, 1/2,1/2, 2/3,2/3,2/3 ]);
//P.tune('and the bodily');

P.tune( 'the bodily',Pset(\dur, Song.tempoMap[ 'the bodily' ] .beats.warpTo(Song.tempoMap[ 'the bodily' ].quantizeDft).q,_));
P(\highHat,start:'and the bodil',music:{|p b e|
	p.hatPattern.(
		e.tempoMap.quantizeDft(p.formulaQuantAmount)
	)
	.play
	//.patternpairs[1].list.postln
	//=>_.play( Song.quarters[e.start].quantizeWindow.asTempoClock)
});
P(\drumz,'and the bodily',music:
	{|p b e|
		var map = e.tempoMap.quantizeDft(p.formulaQuantAmount).postln;
		[
			//"x.x.x.x.".asDrumPat(2,2,).list 
			"q q q q".asBeats
			.dup.flat
			.warpTo(map)
			.q
			=> [dur:_,
				//instrument:\snare
				instrument:\sn_808
			]=>_ .p
			,
			//"x.x..x.x".asDrumPat(2,2) 
			"q qe ee e".asBeats
			.dup.flat
			.warpTo(map)
			.q
			=> [dur:_,
				//instrument:\bd_808,
				//lag:-0.04,
				instrument:\kick2,
			] =>_ .p
		] => Ppar(_)
		=> _.play
		//=>_.play(Song.quarters['this formula'].quantizeWindow.asTempoClock)
	}
);
Song.quarters['bodily']=Song.parseBeats('bodily', [1,7/4,2/4,7/4, 1/2,1/2, 2/3,2/3,2/3 ]);
P(\bass,'bodily',music: {|p b e|
		[
			freq: [-4,-5,-6,-7,1,1,4,4,3,3].df('d',tuning:\sept1,octave:[3,4]).q,
			dur: 0.5!4 ++ ( "ex x".asBeats *2 !3 ).flatten
			=> _.warpTo(e.tempoMap.quantizeDft(p.formulaQuantAmount))
			=>_.q
		] ++ p.formulaBass => _.ppma
});
P(\chank, music: { |p b e|
	var out = Effect.bus({|i|
		AnalogVintageDistortion.ar(i,drivegain: 1.8,bias:0.18,shelvingfreq:600,lowgain:0.00,highgain:0.8) / 15 
		* -6.dbamp
		// => Pan2.ar(_, Env([1, -1, 1, -1, 1, -1, 1, -1],"q q q q q q q q".asBeats.warpTo( e.tempoMap )).kr(2, gate:1))
	});
	var tempoMap = e.tempoMap.quantizeDft;
	[
		freq: [[6, 11, 4], [6, 11, 14],[15, 11, 14],[ 13], [14, 5, 11], [4, 5, 11],[3, 5, 12], [3, 5, 13]].df(\d,4).q,
		instrument: \defaultPiano,
		dur: "q q q q q q q q ".asBeats.warpTo( tempoMap ).q,
		rest: [1,\r, ].q(inf),
		instance: p.guitar,

		out:  out
	].pp;
	[
		type: \strum,
		freq: [[6, 11, 4], [6, 11, 14],[15, 11, 14],[ 15, 11, 14], [14, 5, 11], [4, 5, 11],[3, 5, 12], [3, 5, 13]].df(\d,4).q,
		// rest: [\r,1].q(inf),
		instance: p.guitar,
		dur: "q q q q  q q q q".asBeats.warpTo( tempoMap ).q,
		// rest: [\r, 1].q,
		lag: [0, 0,0,-0.06,0,0,0,0].q,
		// switch:\down,
		out:  out
	].pp;

	[
		type: \strum,
		rest: [\r,1].q(inf),
		instance: p.guitar,
		dur: "q q q q  q q q q".asBeats.warpTo( tempoMap ).q,
		lag: [0, 0,0,-0.06,0,0,0,0].q + 0.01,
		rest: [\r, 1].q(inf),
		// lag: 0.01,
		switch: p.chankSwitch,
		out:  out
	].pp
});
["functions to normal. ",[7,6, 12,11,7 ].dm('d',octave:4 )].addLine;
P.synthV(\mo, take: \harmony, 
filter: (midinote: [1, 1, 1, 5, 5].dm(\d)), 
params: {|p b| [
lyrics: "r r r normal +",
pitchTake: 1
] }, music:{|p b e|
{
	e.playbuf
	// => p.synthVTracks.at(e.key).()
	/8
}.play
});
P.double(\mo, take: \harmony, params: {|p b| [

] }, music:{|p b e|
{
	e.playbuf
	/8
	// => p.synthVTracks.at(e.key).()
}.play
});
P(\drumz,'functions to normal',music:
	{|p b e|
		var map = e.tempoMap.quantizeDft(p.formulaQuantAmount).postln;
		[
			//"x.x.x.x.".asDrumPat(2,2,).list 
			"q q q q".asBeats
			.warpTo(map)
			.q
			=> [dur:_,
				//instrument:\snare
				instrument:\sn_808
			]=>_ .p
			,
			//"x.x..x.x".asDrumPat(2,2) 
			"q qe ee e".asBeats
			.warpTo(map)
			.q
			=> [dur:_,
				//instrument:\bd_808,
				//lag:-0.04,
				instrument:\kick2,
			] =>_ .p
		] => Ppar(_)
		=> _.play
		//=>_.play(Song.quarters['this formula'].quantizeWindow.asTempoClock)
	}
);
Song.setTempoMap('and the bodily', [1,7/4,2/4,7/4, 1/2,1/2, 2/3,2/3,2/3 ]);
Song.quarters['bodily']=Song.parseBeats('bodily', [1,7/4,2/4,7/4, 1/2,1/2, 2/3,2/3,2/3 ]);
Song.quarters['to normal']= Song.parseBeats('to normal',[2/3, 2/3, 2/3,  1,1]);
Song.setTempoMap('to normal', [2/3, 2/3, 2/3,  1,1]);
P(\bass,'to normal',music: {|p b e|
	[
		freq: [6,6,5,5].df('d',tuning:\sept1,octave:[3,4]-1).q,
		dur: "ex x e e".asBeats.warpTo(e.tempoMap.quantizeDft(p.formulaQuantAmount)).q*2,
	] ++ p.formulaBass => _.pp
});
P(\highHatNormal,start:'to normal',music:{|p b e|
p.hatPattern.(e.tempoMap.quantizeDft(p.formulaQuantAmount), 16)// => Pfin(8,_)
=>_.play
//=>_.play(Song.quarters[e.start].quantize.asTempoClock);
});
//P.tune('to normal',);
// P.tune( 'to normal',Pset(\dur, Song.tempoMap[ 'to normal' ] .beats.warpTo(Song.tempoMap[ 'to normal' ].quantizeDft).q,_));
P.tune('to normal',  _ <> [instrument: \harp].p.fin(3)  ); 
P(\chank, music: { |p b e|
	var out = Effect.bus({|i|
		AnalogVintageDistortion.ar(i,drivegain: 1.8,bias:0.18,shelvingfreq:600,lowgain:0.00,highgain:0.8) / 15 
		* -6.dbamp
		// => Pan2.ar(_, Env([1, -1, 1, -1, 1, -1, 1, -1],"q q q q q q q q".asBeats.warpTo( e.tempoMap )).kr(2, gate:1))
	});
	var tempoMap = e.quantizeDft();
	[
		freq: [[-6,3,7],[-6,3,6],[2,5,11],[2,5,7]].df(\d,4).q,
		instrument: \defaultPiano,
		dur: " q q q q ".asBeats.warpTo( e.tempoMap ).q,
		rest: [1,\r, 1, 1 ].q(inf),
		instance: p.guitar,

		out:  out
	].pp;
	[
		type: \strum,
		freq: [[-6,3,7],[-6,3,6],[2,5,11],[2,5,7]].df(\d,4).q,
		rest: [\r,1].q(inf),
		instance: p.guitar,
		dur: "q q q q  ".asBeats.warpTo( e.tempoMap ).q,
		rest: [\r, 1].q(2),
		lag: [0, 0,0,-0.06,0,0,0,0].q,
		// switch:\down,
		out:  out
	].pp;

	[
		type: \strum,
		rest: [\r,1].q(inf),
		instance: p.guitar,
		dur: "q q q q ".asBeats.warpTo( e.tempoMap ).q,
		rest: [\r, 1].q(2),
		lag: 0.01,
		switch:p.chankSwitch,
		out:  out
	].pp
});
["(boom) While the bodies are occupied, ",[-15,-5,-6,-7,1,2,4,3,1].dm('c')].addLine;
P.still(\withSyringe, timecode: 3013.8.seconds, music: { |p b e|
	 e.still.( 
		wait: b.sum,
		text: ["",""],
	)
});
P.synthVs(role: \formulaLead, take:[\lead, \double], params: {|p b| [
	lyrics: "r while the bodies + are occupied + +",
	pitchTake: [1, 3]
] }, music:[0,0].collect{|pan|
	{|p b e|
		{
			e.playbuf
			// => p.synthVTracks.at(e.key).()
			=> Pan2.ar(_,pan)
		}.play
	}
});
P('cymbal',start:\While,music: {|p b e|
(instrument:\cymbalsDS,amp:0.01).play
});
P.tune('occupied',{|i| i.drop(1)},syl:0);
Song.quarters[\occupied]=Song.parseBeats('occupied',(1/3)!6 ++ ( (2/3)!3 ));
//Song.quarters[\occupied]

P(\chordsOccupied,start:\occupied,music:{|p b e|
	[
		freq:[[1,3,5],[1,4,6]].df('g',octave:4 ).stutter(2).q*[1,1.01],
		//		out:1,
		pan:0,
		out:Effect({|i| MoogLadder.ar(i,1200,1) => EchoNone.ar(_, 0.2,  delaytime: 0.1,  decaytime: 2.0)},out:1).bus.index,
		amp:0.2,
		//		out:Effect(FreeVerb.ar(_,0.51,0.5),out:1).bus.index,
		dur:"e e e e".asBeats.q*2,
	].p.trace.play(Song.quarters[e.start].asTempoClock)
}
);

["you will administer one injection of  ",[3,4,1,3,2,1, -7,1,2,-7,-5].dm('a',scale:\harmonicMinor)].addLine;
P.synthVs(role: \formulaLead, take:[\lead, \double],
filter: (midinote: _ - (12.dup(11) ++ 0.dup(5) => _.flat)), 
pbind: Song.enlarge(5),
params: {|p b| [
lyrics: "you will administer + + + one injection + + of ten see sees each hour ",
pitchTake: [1, 3]
] }, music:[0,0].collect{|pan|
	{|p b e|
		{
			e.playbuf
			// => p.synthVTracks.at(e.key).()
			=> Pan2.ar(_,pan)
		}.play
	}
});
P.tune('administer one',Pmul(\freq,0.5,_));
Song.setTempoMap('administer one',"E E E E E E EE E E E E");
P(\chords,start:\administer,music:{|p b e|
[
freq:[[1,3,5],[-7,2,5]].df('a',4,\harmonicMinor ).stutter(2).q*[1,1.01],
//		out:1,
pan:0,
out:Effect({|i| MoogLadder.ar(i,1200,1) => EchoNone.ar(_, 0.2,  delaytime: 0.1,  decaytime: 2.0)},out:1).bus.index,
amp:0.2,
//		out:Effect(FreeVerb.ar(_,0.51,0.5),out:1).bus.index,
//dur:"e e e e".asBeats.q*2,
dur:"q q qq ".asBeats.warpTo(e.tempoMap).q
].pp//.p.trace.play(Song.quarters[e.start].asTempoClock)
}
);
["ten cc's each hour.",[-7,1,-7,1,-6].dm('g',octave:4 )].addLine;
P.synthVs(\kevin, take: [\lead, \double],
filter: (midinote: _ - 12), 
	pbind: {|p b|
		[
			midinote: [3, 3, 3, 3, 4].dm(\g).q	,
			dur: b.q
		].p
	},
	params: {|p b| [
	lyrics: "ten see sees each hour",
	pitchTake: [1, 3]
] }, music:{|p b e|
	{
		e.playbuf
		* -20.dbamp
		=> p.synthVTracks.at(e.key).()
	}.play
});
P.synthV(\mo, take: \lead, params: {|p b| [
	// filter: (midinote: _ + 12), 
	lyrics: "ten see sees each hour",
	pitchTake: 1
] }, music:{|p b e|
	{
		e.playbuf
		/4
		// => p.synthVTracks.at(e.key).()
		=> Pan2.ar(_,0.3)
	}.play
});
P.synthVs(\an, take: [\lead, \double],
filter: (midinote: _ - 12), 
	pbind: {|p b|
		[
			midinote: [5, 5, 5, 5, 6].dm(\g).q	,
			dur: b.q
		].p
	},
	params: {|p b| [
	lyrics: "ten see sees each hour",
	pitchTake: [1, 3]
] }, music:{|p b e|
	{
		e.playbuf
		* -20.dbamp
		=> p.synthVTracks.at(e.key).()
	}.play
});
P.tune('each hour');
Song.quarters['each hour']= Song.parse('each hour',[2,2,1]);
P(\chordsHour,start:'each hour',music:{|p b e|
	[
		midinote: [0,-2]+.t[1,3,5,7].dm('d',octave:4 ) =>_.q,
		dur:"qq q".asBeats.q,
		instrument:\sawSynthSustain,
		att:1
	].p.trace.play(Song.quarters[e.start].asTempoClock)
}
);
["/*CHAPEL:*/ I understand. ",[5,6,7,11].dm('a-')].addLine;
P.still(\chapelUnderstand, timecode: 3017.2.seconds, music: { |p b e|
	 e.still.( 
		wait: b.sum,
		text: ["I","understand"],
	)
});
P.synthV(role: \chapel, take: \lead,
	filter: (midinote: _ - 12), 
	params: {|p b| [
	lyrics: "I understand + +",
	pitchTake: 1,
	pitchExpression:0.2
] }, music:{|p b e|
	{
		e.playbuf
		=> p.synthVTracks.at(e.key).()
		// => Pan2.ar(_,0.5)
		// => {|i|  CombN.ar(i,0.5,0.3,4) / 2 + i}
		* -3.dbamp
		// => PitchShift.ar(_,pitchRatio: 441/480)
	}.play
});
P(\line, music: { |p b e|
	[
		freq: [[ 2,4,5,7 ],[ 1,3,5, 11 ]].df('a-',4, tuning:\just).q,

		dur: b.parse([3,1]).q,
		instrument: \stringyy
	].ppm;
	[
		midinote: p.tune[e.start],
		dur: b.q,
		instrument: \bl
	].pp
});
// P.tune('understand', { |i| Pmul(\freq,0.5,i) => Pbindf(_,\instrument,\stringyy,\amp,0.2)});
Song.quarters[\understand]=Song.parseBeats('understand',"e x x q".asBeats);
P(\chordsUnderstand,start:\understand,music:{|p b e|
[
	freq: [[-5,5],[-5,4],[1,3]].df('a-',octave:4 ).q,
	//		instrument:\sparkTriangle,
	release:1.5,
	dur:"ex x e".asBeats.q,
	amp:0.045,
	out:[0,3],
].pm(\sparkTriangle).play(
	Song.quarters[\understand]
	.asTempoClock
)
}
);
["/*SPOCK:*/ This hypo you will code mark for Tha lassa. And ",[5,4,3,2,1,3,2,3,4,3,2,2, 2].dm('d')].addLine;
P.still(\spockAndHypo, timecode: 3020.seconds, music: { |p b e|
	 e.still.( 
		wait: b.sum,
		text: ["",""],
	)
});
P.synthV(role: \formulaLead, take:\lead,
	filter: (midinote: _ - (0.dup(13) ++ 12.dup(8) ++ -12 => _.flat )), 
	pbind: Song.enlarge2(1),
	params: {|p b| [
	lyrics: "this hypo + you will code mark for Thalassa + - + and this one you will code mark for - me",
	legato: [1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 0.6, 1, 1, 1, 1, 1, 1, 1],
	pitchTake: 1
] }, music:{|p b e|
	{
		e.playbuf
		// => p.synthVTracks.at(e.key).()
	}.play
});
P.double(role: \formulaLead, params: {|p b| [
		
	] }, music:{|p b e|
		{
			e.playbuf
			// => p.synthVTracks.at(e.key).()
			=> Pan2.ar(_,1)
			
		}.play
	});
P.tune('hypo you will',  { |i| i
	<>[
		instrument: \sparkTriangle,
		depth:0.01,
		out: Effect.bus({|i| i=>Pan2.ar(_,1) })

	].pm
	=> Pmul(\freq,0.5,_)
});
Song.quarters['hypo you will'] = Song.parseBeats('hypo you will',[1, 1,1,1,1, 1,1,3/2,1/2, 1,1,5, 1]);
P(\hypoBase,'hypo you will', music:{|p b e|
	[
		//	instrument:\pluckD,
		freq: [ \r ] ++ [ 1 ].stutter(8) ++ [ -5 ].stutter(8) 
		=> _.df('d',octave:3) =>_.q,
		amp:0.03,
		smooth:0.1,
		coef: 0.9,
		drive: 0.94,
		// out: Effect.bus({|i| AnalogTape.ar(i,drive:[ 0.5,0.5 ]) },)
	].pm(\pluckD)
	.play
	(
		Song.quarters['hypo you will']
		//	.quantizeWindow
		.asTempoClock
	)
});
P(\drumz, music: { |p b e|
	[
		dur: "q q qqq q qq q q qq q q qq q".asBeats.warpTo( Song.quarters['hypo you will'] ).q,
		instrument: \kick_gentle,
		decay: 20,
		tone: 44,
		rest: MuteFirst(),
		vol: 0.2
	].pp;
	(
		instrument: \cymbalsDS,
		amp: 0.03,
		lag: b[0]
	).play
	
});

P(\hypoAnswer,start:'hypo you will',music:{|p b e|
[
	freq:\r!12 ++ [5,4,3,2,1] =>_.df('a',octave:5 ) =>_.q,

	detune:[1,2,2.8,-2]*2,
	att:0.3,
	amp:0.03,
	instrument:\sawSynthSustain,
	lofreq:4000,
	rel:4
].p.play(Song.quarters['hypo you will'].asTempoClock)
}
);
["this one you will code mark for -- ",[4,3,2,1,3,3,4,3].dm('a')].addLine;
Song.setTempoMap('this one you',"q q q q qe eq e e ");
P(\drumz, music: { |p b e|
	[
		dur: "q qqq q qq q q ".asBeats.warpTo(e.tempoMap ++ p.tempoMap[e.start + 1]).q,
		instrument: \kick_gentle,
		decay: 20,
		tone: 44,
		vol: 0.2
	].pp;
	(
		instrument: \cymbalsDS,
		amp: 0.03,
		// lag: b[0]
	).play
	
});
P.still(\twoShopHypos, timecode: 3024.1.seconds, music: { |p b e|
	 e.still.( 
		wait: b.sum,
		text: ["",""],
	)
});
P.still(\twoShot, timecode: 3026.seconds, music: { |p b e|
	 e.still.( 
		wait: b.sum,
		text: ["this one you will codemark","for me"],
	)
});
P.tune(  { |i| i
	<>[
		instrument: \sparkTriangle,
		depth:0.01,

	].p
	=> Pmul(\freq,0.25,_)
});

Song.quarters['for --'] = Song.parseBeats('for --',[1,1,1,1, 3/2,3/2,1/2,1/2]);
P(\forBase,'for --', music:{|p b e|
[
	//	instrument:\pluckD,
	freq: [ -5 ].stutter(8) 
	=> _.df('d',octave:3) =>_.q,
	amp:0.03,
	smooth:0.1,
	coef: 0.9,
	drive: 0.94,
].pm(\pluckD).play (
	Song.quarters['for --']
	//	.quantizeWindow
	.asTempoClock)
});
["me.  /*CHAPEL:*/ Yes, sir. ",[-2,7,11].dm('c')].addLine;
Song.setTempoMap('me. ',"qq q q");
P.still(\chapelAnswer,syl:0, timecode: 3029.seconds, music: { |p b e|
	 e.still.( 
		wait: b.sum,
		text: ["",""],
	)
});
P.tune('Yes, sir');
Song.synthVTracks = EventWithDefault(
	\default, {{|i| 
		i
	}},
	Trek.cast.chapel, { |mix = 0.5|
		{|i|
		Pan2.ar(i,0.5)
		=> {|j|  CombN.ar(i,0.5,0.3,4) * mix + j}
		/2
	}
});
P.synthV(role: \chapel, take:\lead,
	filter: (midinote: _ - 12), 
	params: {|p b| [
	lyrics: " r yes sir",
	legato:[0.6,0.6],
	pitchTake: 1
] }, music:{|p b e|
	{
		e.playbuf
		=> p.synthVTracks.at(e.key).(mix:0.25)
		* 6.dbamp
	}.play
});
P(\chordSir,start:'Yes, sir',syl:0,music:{|p b e|
	b=b.drop(1);
	[
		freq:[[-5,7,2],[1,11,11]].df('c',octave:5,tuning:\sept1,).q,
		dur: "q q".asBeats.q,
		amp:0.05,
	].p.play(b.asArray.asTempoClock)
}
);
["/*SPOCK:*/ This one you will administer to Captain Kirk while ",[3,2,-7,7,6,5,4,3,1.5,3,4,4.5,5].dm('f#',scale:\minor,)].addLine;
Song.setTempoMap(\while,"q qe e e e e e e e e e e e");
P.still(\henochReKirk, timecode: 3036.3.seconds, music: { |p b e|
	 e.still.( 
		wait: b.sum,
		text: ["",""],
	)
});
P(\chords, music: { |p b e|
	[
		freq: [ [1, 5], [2, 5],[3, 5] ].df('f#',\minor).q,
		dur: "qq qq qq".asBeats.warpTo( e.tempoMap ).q,
		instrument: \washSus, freqLag: 0.1
	].ppm
});
P.synthVs(role:\formulaLead, take:[\lead, \double],
	pbind: Song.enlarge2(0),
	params: {|p b| [
	lyrics: "this one you will administer + + + to captain + kirk while Sargon + is in his body +",
	// legato: [1, 0.8, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 0.8, 1, 1, 1, 1 , ],
	pitchTake: [1, 3],
	filter: [(midinote: _), (midinote: _ - 12) ], 
] }, music:{|p b e|
	{
		e.playbuf
		// => p.synthVTracks.at(e.key).()
		=> Pan2.ar(_,0)
	}.play
});
// P.tune('This one');
P(\baseThisOne,start:'This one',music:{|p b e|
	[
		freq:[1,2,3, 1.5,3,4,4.5,5].df('f#',scale:\minor,octave:3 ).q,
		dur:"qq qq qe e e e e e".asBeats.warpTo( e.tempoMap ).q
		// .asBeats.q,
	].p.play;
}
);
["Sargon is in his body. ",[11,5,3,2,-7,2,1].dm('d',octave:5,scale:\harmonicMinor, )].addLine;
P.tune('in his body');
P(\strumBody,start:'in his body',lag:-0.01,music:{|p b e|
(
	freq:[1,3,5,11,13,15,21].df('d',octave:4,scale:\minor, ),
	amp:0.06,
	strum:0.06	
).play
}

);
["/*CHAPEL:*/ This hypo does not contain the same formula. ",[5,4,3,1,2,3,5,4,5].dm('g',scale:\whole)++[7,5,1.5].dm('g',scale:\mixolydian)].addLine;
P.still(\chapelObjects, timecode: 3041.8.seconds, music: { |p b e|
	 e.still.( 
		wait: b.sum,
		text: ["this","hypo"],
	).sequenceText2(
			b.parse([3]), [ 
			["does not contain","the same formula"],
			],
	)
});
P.synthV(role: \chapel, take: \lead, params: {|p b| [
	lyrics: "this hypo + does not contain + the same formula + +",
	legato: [0.8, 1, 0.8, 1, 1, 1, 1, 1, 1, 1, 1, 1, ],
	pitchTake: 1
] }, music:{|p b e|
	{
		e.playbuf
		=> p.synthVTracks.at(e.key).(mix: 0.1)
	}.play
});
P(\swellContain,start:'does not contain',music:{|p b e|
(
	instrument:\stringyy,
	mix:0,
	freq:1.df('e-',octave:3),
	out:(0..3),
).play
}
);
P.tune('does not contain');
// TODO
["/*SPOCK:*/ No, that's correct. But since I will arrange for ",[1, 1.5,1,1].dm('b-')++[4,2,4, 3,2,1,-7].dm('f#')].addLine;
P.still(\spockClose, timecode: 3049.5.seconds, music: { |p b e|
	 e.still.( 
		wait: b.sum,
		text: ["no","that's correct"],
		fade:1
	).sequenceText2(
			b.parse([4]), [ 
			["",""],
			],
	)
});
P.still(\clear,syl:3, timecode: 0.seconds, music: { |p b e|
	 e.still.( 
		wait: b.drop(1).sum,
		text: ["but since","I will arrange for"],
	)
});
// P.tune('correct');
P.synthVs(role: \formulaLead, take:[ \lead, \double ],
	filter: (midinote: _ - 12), 
	pbind: Song.enlarge(12),
	params: {|p b| [
	lyrics: "No, that's correct + but since I will arrange + for you to administer + + + each of the injections + +",
	legato: [ [0.25, 1,1,0.3, 1,1,1,1,1,1,0.8 ,0.8,1,1,1,1,0.8,1,1,1,1,1,1] ],
	pitchTake: [ 1, 3 ],
	pitchExpression: 1
] }, music:{|p b e|
	{
		e.playbuf
		=> p.synthVTracks.at(e.key).()
		=> Pan2.ar(_,0)
	}.play
});
P(\correctBase,start:'correct',music:{|p b e|
( freq:1.df('b-',octave:2), ).play
}
);
Song.quarters['correct'] = Song.parseBeats('correct',"qq Q E qe e e e e Q E".asBeats);

P(\correctBaseLine,start:'correct',music:{|p b e|
[
	freq:[1,-5, -5,-3].df('b-',octave:3 ).q,
	dur:[1,2,1,1] + [-1/10,1/10,0,0] =>_.q,
	instrument:\sawSynthSustain,
	att:0.6,
	amp:0.1,
	legato:[1,0.9, 1,0.9].q,
].p=>
{|i| Ppar([Pset(\instrument,\default,i),Pbindf(i,\amp,0.04,\out,2)])}
=>_.play(Song.quarters[e.start].asTempoClock)
}
);
P(\correctBaselineSecondHalf,start:'correct',syl:3,music:{|p b e|
b=b.drop(1);
[
	freq:[4,2,4, 3,2,1,-7, -6.5].df('f#',octave:3).q,
	instrument:\sparkTriangle,
	//		dur:b * [1,1,1,1,1,2/3,4/3] ++ 1 =>_.q,
	dur: b.asArray.parse([ 1,1,1,1,1,2/3,[1/3,1] ]) ++ 1 =>_.q,
].pp
}
);
["you to administer each of the injections, ",[5, 4,3,2,3,1, 5.5, 4.5, 1,2,3,2].dm('f#')].addLine;
P.still(\clear, timecode: 0.seconds, music: { |p b e|
	 e.still.( 
		wait: b.sum,
		text: ["you","to administer"],
	).sequenceText2(
			b.parse([6]), [ 
			["each of the","injections"],
			],
	)
});
P(\administerBaseNotes,start:'administer each',music:{|p b e|
[
	freq: [4,3,2.5,2].df('b',octave:2 ).q,
	dur: b.asArray.parse([3,3,4,2]).q,
	legato: 1,
].pp;
[
	freq: [3].df('e',octave:4 ).q,
	instrument: \stringyy,
	out:1,
].pp;

}
);
P(\administerMiddleVoice,syl:9,start:'administer each',music:{|p b e|
[
	freq: [4,3].df('c#',octave:4 ).q,
	dur: b.asArray.drop(1).parse([2/3,[1/3,1]]).q,
	legato:1,
	instrument:\stringyy,
	out:1,
	//		dur: b.drop(1).q
].pp
}
);
["no one else will notice. ",[1,2,3.5,-7,-7,-6].dm('b-',scale:\minor)].addLine;
P.synthV(role: \formulaLead, take: \lead,
	filter: (midinote: _ - 12), 
	params: {|p b| [
	lyrics: "no one  else will notice +",
	pitchTake: 1
] }, music:{|p b e|
	{
		e.playbuf
		=> p.synthVTracks.at(e.key).()
	}.play
});
P.double(role: \formulaLead, take: \lead, params: {|p b| [
	
] }, music:{|p b e|
	{
		e.playbuf
		=> p.synthVTracks.at(e.key).()
		=> FreeVerb.ar(_,0.2,1)
		=>Pan2.ar(_,1)
	}.play
});
// P.tune('notice');
["/*CHAPEL:*/ Without the same formula, Captain Kirk will die. ",[3,1,2,3,5,4,3,1,2,3,5,6].dm('g',scale:\whole,)].addLine;
P.still(\chapelConcerned, timecode: 3053.4.seconds, music: { |p b e|
	 e.still.( 
		wait: b.sum,
		text: ["",""],
	)
});
P(\notes, music: { |p b e|
	[
		freq: [\r, 1, 5, \r, 6].df(\g,4, \whole).q,
		dur: b.parse([1, 3, 3, 4, 1]).q,
		instrument: \harp, coef: 0.05, amp: 0.03
	].pp
});
P.synthV(role: \chapel, take: \lead, params: {|p b| [
	lyrics: "without + the same formula + + captain + kirk will die",
	pitchTake: 1,
	pitchExpression: 1.5
] }, music:{|p b e|
	{
		e.playbuf
		=> p.synthVTracks.at(e.key).(mix:0.1)
		/2
	}.play
});
P.tune('Without', _ <> [instrument: \wash, amp: 0.02, rel:1].p);
["(He touches her fosehead.) /*SPOCK:*/ What were you saying? ",[3,  3,4,2,4,3].dm('c')].addLine;
P.still(\henochTouches, timecode: 3100.seconds, music: { |p b e|
	 e.still.( 
		wait: b[0],
		text: ["",""],
	)
});
P.still(\henochClose,
	timecode: 3108.seconds,//close
	timecode: 3058.2.seconds, //twoDhot
	syl:0, music: { |p b e|
	 e.still.( 
		wait: b.drop(1).sum,
		text: ["what were you","saying?"],
	)
});
// P.tune('touches her');
P.synthV(role: \formulaLead, take: \lead, params: {|p b| [
	lyrics: "r what were you saying +",
	pitchTake: 1
] }, music:{|p b e|
	{
		e.playbuf
		=> p.synthVTracks.at(e.key).()
	}.play
});
P.double(role: \formulaLead, take: \lead,  params: {|p b| [
		
	] }, music:{|p b e|
		{
			e.playbuf
			=> p.synthVTracks.at(e.key).()
		}.play
	});
P(\touchBaseNote,start:'touches her',music:{|p b e|
(
	instrument:\stringyy,
	out:(0..3),
	mix:0,
	width:10,
	freq:1.df('e',octave:[3, 2 ]),
).play;
(
	instrument:\sawSynthSustain,
	dur:3,
	att:3,
	freq:1.df('e',octave:[3,]),
).play

}
);
["/*CHAPEL:*/ I (breath). I was. (breath) ",[7,1, 6,7,1].dm('b')].addLine;
P.still(\chapel, timecode: 3106.seconds, music: { |p b e|
	 e.still.( 
		wait: b.sum,
		text: ["",""],
	)
});
P.still(\clear, timecode: 0.seconds, music: { |p b e|
	 e.still.( 
		wait: 0,
		lag:0.01,
		text: ["I",""],
		fade: b[0..1].sum
	)
});
P.still(\clear2,syl:2, timecode: 1.seconds, music: { |p b e|
	 e.still.( 
		wait: 0,
		text: ["I","was"],
		fade: b.drop(1)[0..2].sum
	)
});
// P.tune('I was.',{|i| Pbindf(i,\amp,[1,0,1,1,0]/10=>_.q)});
P.synthV(role: \chapel,
	filter: (midinote: _ - 12), 
	take: \lead, params: {|p b| [
	lyrics: "I r I was r",
	pitchTake: 1,

	vocalMode: \Soft, // Airy
	pitchExpression: 0.1
] }, music:{|p b e|
	{
		e.playbuf
		=> p.synthVTracks.at(e.key).(mix:0.1)
	}.play
});
P(\forgettingPad ,start:'I was.',music:{|p b e|
//should pulsate
(instrument:\stringyy,
	dur: p.durs[e.start..(e.start+2)].collect(_.list).flat.sum.postln ,
	mix:0,
	amp:0.01,
	out:(0..3),
	freq:[1,3,5].df('b',octave:4,tuning:\sept1,scale:\major )).play

}
);
P(\forgetting,start:'I was.',music:{|p b e|
var a=[1,3,5,7].df('b',tuning:\sept1,octave:4)*.x(1..100).select(_<(s.sampleRate/2));
var group=Group.new(s);
var clock=TempoClock.new(1);
var dur=p.durs[e.start..(e.start+2)].collect(_.list).flat.sum.postln;
a=a.itemsHisto.keys.asArray.sort;
{a[1..180].collect{|i|
	var x = i**1.6;
	SinOsc.ar(
		i,
		//0,
		LFBrownNoise2.kr(2)*pi*4.rand,
		FSinOsc.kr(Rand(0.01,0.1)).unipolar 
		/ x * 19
	)=>Pan4.ar(_,2.rand*2-2/2,2.rand*2-2/2).tanh
}=>Mix.ar(_)
* Env.asr(3,1,10).kr(2,gate:\gate.kr(1))
}.play(group,0) ;

{
{
	var n=Array.fill(30,SinOsc.ar(200.gaussian(1000).abs+LFBrownNoise2.kr(1000).range(1,10),0,0.001))=>Mix.ar(_) *Env.perc(Rand(0,10),Rand(4,15)).kr(2,gate:\gate.kr(1));
	n=Array.fill(30,SinOsc.ar(400.pareto(1).abs+LFBrownNoise2.kr(1000).range(1,10),0,0.001))=>Mix.ar(_) *Env.perc(Rand(0,10),Rand(4,15)).kr(0,gate:\gate.kr(1));
	Env.cutoff(16).kr(2,gate:\gate.kr(1));
	//200.gaussian(1000)
	DynKlank.ar(`[[1,3,4,6,11,13,14,16].df('c',tuning:\sept),0.001,Array.rand(8,7,16)!2],n)
	=> Limiter.ar(_,0.01)
}.play(s,4.rand);
//}.play(g,4.rand);
rrand(2.5,6.0);
}.sched(rrand(1,5.0),clock);

// cleanup
fork{
dur.wait;
clock.clear;group.release;
}

});
["I wanted to say-- something. I've for",[7,11,7,6, 6,12,7,5, 3,4].dm('b')].addLine;
P.still(\clear,lag:0.1, timecode: 0.seconds, music: { |p b e|
	 e.still.( 
		wait: e.bAll[0..14].sum,
		fade:0.5,
		text: ["I wanted to","say something"],
	).sequenceText2(
			b.parse([8]), [ 
			["I've forgotten","what it was"],
			],
	)
});
P.synthV(role: \chapel, take: \lead,
	filter: (midinote: _ - 12), 
	pbind: Song.enlarge2(0),
	params: {|p b| [
	lyrics: "I wanted + to say - something + I've forgotten + + what it was r ",
	legato: [1, 1, 1, 1, 1, 1, 1, 0.4,   1, 1, 1, 1, 1, 1, 0.7],
	pitchTake: 1,
	vocalMode: \Soft, // Airy
	pitchExpression: 0.1
] }, music:{|p b e|
	{
		e.playbuf
		=> p.synthVTracks.at(e.key).(mix:0.1)
	}.play
});
// P.tune('something');
["gotten what it was. ",[3,4,5,6,7].dm('b')].addLine;
["/*SPOCK:*/ Yes. Well, you were about to say that ",[5,12, 5,6,7,11,6, 12, 11,].dm('d',scale:\major)].addLine;
P.synthV(role: \formulaLead, take:\lead, 
	filter: (midinote: _ - 12), 
	params: {|p b| [
	lyrics: "yes well you were about + to say that",
	legato: [0.7,0.7, 1, 1, 1, 1, 1, 0.7],
	pitchTake: 1
] }, music:{|p b e|
	{
		e.playbuf
		=> p.synthVTracks.at(e.key).()
	}.play
});
P(\keys, music: { |p b e|
	[
		freq: [1, 5, [1, 11], [5, 15]].df(\a,4).q,
		dur: b.parse([1,1, 5, 2]).q,
		instrument: \wash,
	].pp
});
P.double(role: \formulaLead,  params: {|p b| [
		
	] }, music:{|p b e|
		{
			e.playbuf
			=> p.synthVTracks.at(e.key).()
			=> Pan2.ar(_)
		}.play
	});
["you watched me prepare the formula and fill each of the hypos. ",[13,13,12,13,14,15,14,13,12,11,7,5,6,7,12,11].dm('d',octave:5 )].addLine;
P.still(\henochYouWatched, timecode: 3115.9.seconds, music: { |p b e|
	 e.still.( 
		wait: b.sum,
		text: ["",""],
	)
});
P.synthV(role: \formulaLead,
	filter: (midinote: _ - 12), 
	take:\lead, params: {|p b| [
	lyrics: "you watched me prepare + the formula + + and fill  each of the hypos +",
	pitchTake: 1
] }, music:{|p b e|
	{
		e.playbuf
		=> p.synthVTracks.at(e.key).()
	}.play
});
P.double(role: \formulaLead, params: {|p b| [
		
	] }, music:{|p b e|
		{
			e.playbuf
			=> p.synthVTracks.at(e.key).()
			=> {|i|
				 DWGReverbC1C3.ar(i, mix:0.1)
				* -2.dbamp
			}
		}.play
	});
P(\harmonyWatched,start:'me prepare',music:
{|p b e|
	[
		instrument:\sawSynth,
		freq:[11,11,7,11,12,13,12,11,7,6,5,3,4,5,6,6].df('d',octave:[3,4,5],).q,
		amp: [0.5,1,2]/20,
		out: 1,
		dur:b.q,
	].pp
}
);
P(\extraNotes, music: { |p b e|
	[
		freq: [\r, 1, -5, -2].df(\d).q,
		dur: b.parse([1, 9, 4, 2]).q,
		legato: [0.7, 1, 1, 1, ].q,
		// instrument: \visual_pad,
		amp: 0.3,
		instrument: \sparkTriangle, width: 0.001, amp: 0.05, out: 1
	].pp
});
["/*CHAPEL:*/ Yes, that, that was it. ",[7, 7, 12,11,3].dm('f#')].addLine;
Song.setTempoMap('that was it',"qq qq Q E q");
P.still(\ChapelYes, timecode: 
// 3120.5 //mouth closed
3119.2
.seconds, music: { |p b e|
	 e.still.( 
		wait: b.sum,
		text: ["",""]
	).sequenceText2(
			b.parse([1]), [ 
				["yes","that was it"],
			],
	)
});
P.synthV(role: \chapel, take: \lead, params: {|p b| [
	lyrics: "r yes!  that was it",
	legato: [0.8,   0.7, 1, 0.6],
	pitchTake: 1,
	vocalMode: \Open
] }, music:{|p b e|
	{
		e.playbuf
		=> p.synthVTracks.at(e.key).(mix: 0.1)
	}.play
});
P(\line, music: { |p b e|
	[
		midinote: [\r] ++ ( 1.dm(\b)  + (0..7) ) => _.q,
		dur: "e e e e e e e e e" .asBeats.warpTo( e.tempoMap ).q,
		legato: 3,
		instrument: \harp, coef: 0.1, amp: 0.02,
		out: Effect.bus({|i| Phaser2.ar(i,rate:0.2) }, out: 2)
	].pp
});
P(\tremoloYes,start:'that was it',music:{|p b e|
	[
		freq:[[11,14,16],[11,14,15],[13,15,17]].df('f#',octave:3,scale:\mixolydian,).q,
		instrument:\stringyy,
		width:20,
		mix:0.3,
		release:3,
		out:(0..3),
		dur:b.asArray.parse([1,1,3]).q,
	].pp
}
);
P(\basedNotesYes,start:'that was it',music:{|p b e|
[
	freq:[5,11].df('f#',octave:[1, 2 ] ).q,
	legato:1.5,
	dur:b.asArray.parse([2,3]).q,
].pp

}
);
["I will inform Doctor McCoy that each is ",[1,-5,1,2 ,3,1,3,4, 5,4,3,].dm('f#')].addLine;
P.still(\moreChappel, timecode: 3125.seconds, music: { |p b e|
	 e.still.( 
		wait: b.sum,
		text: ["",""],
	)
});
Song.durs.filter( _ / 0.95 );
Song.setTempoMap(\inform,"q Q E q   q Q E Q E Q E ");
// Song.setTempoMap(\inform,"eee ee e eee eee ee e ee e ee e e e e e e e ee e e");
P(\bassline, music: { |p b e|
	var chords = (
		I: [-5,1,3],
		IV: [-6,1,4],
		V: [-5,-7,2],
		
	);
	[
		freq: [1, -5, 1, -4, -5, 5, 1].df('f#', 3).q,
		// dur: b.parse([3, 1, 3, 2, 2 ]) ++ e.bNext.parse([5, 3, 2]) => _.q,
		dur: 
		"qq q qq q q qq q".asBeats.warpTo( e.tempoMap ++ Song.tempoMap[e.start + 1] )
		=> _.q
		,
		out: Effect.bus({|i| FreeVerb.ar(i,0.1,1) => SineShaper.ar(i,0.2)  }),
		amp:0.6
	].pp;
	[
		freq: [\I,\V,\I,\IV,\I].collect( chords.at(_) ) => _.df('f#') => _.q, 
		amp:0.2 ,
		dur: 
		"qq q qq q q ".asBeats.warpTo( e.tempoMap ) 
		++ "qqq".asBeats.warpTo( Song.tempoMap[e.start + 1] )
		=> _.q
		,
	].pp
});
P(\dyads, music: { |p b e|
	[
		freq: [\r,[5, 11], [5, 7], [5, 6], [4, 6], [4, 5], [3, 5], ].df('f#', 4) ++ [[ 3, 6.5]].df(\f, 4)  => _.q,
		dur: e.bAll.parse([9, 5, 1, 1, 1, 1, 1, 1]) + [0, 0, 0, 0, 0, 0, 0, 3] => _.q,
		instrument: \sawSynth,
		att: 3, 
		rel: 4
	].ppm
});
P.synthV(role: \chapel, take: \lead,
	pbind: Song.enlarge(8),
	params: {|p b| [
	lyrics: "I will inform + doctor + mccoy + that each is properly + + filled for each patient +",
	legato: [1, 1, 1, 0.8, 1, 1, 1, 0.8, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, ],

	pitchTake: 1,
	pitchExpression: 1.25
] }, music:{|p b e|
	{
		e.playbuf
		=> p.synthVTracks.at(e.key).(mix: 0.1)
	}.play
});
["properly filled for each patient. ",[5,4,3,2,-6,-7,2,1].dm('f#')].addLine;
Song.setTempoMap(\properly,"E E E E E E Q E");
P.tune('properly');

["/*SPOCK:*/ Very good. ",[5,5,11].dm('b-',octave:4)].addLine;
P.still(\henochClose, timecode: 3129.4.seconds, music: { |p b e|
	 e.still.( 
		wait: b.sum,
		text: ["",""],
	)
});
P.synthVs(role: \formulaLead, take:[ \lead, \double ], params: {|p b| [
	lyrics: "very + good",
	legato: [[1, 1, 0.7, ]],
	pitchTake: [ 1, 3 ]
] }, music:{|p b e|
	{
		e.playbuf
		=> p.synthVTracks.at(e.key).()
			=> {|i| DWGReverbC1C3.ar(i, mix:0.0) * -2.5.dbamp}
		=> Pan2.ar(_,0)
	}.play
});
P(\chordTwo, music: { |p b e|
	[
		freq: [[5, 7, 11, 13], [4, 6, 11, 14]].df('f',4, \mixolydian).q * [1,1.333],
		dur: b.parse([2,1]).q,
		instrument: \stringyy,
		attack: [1,0.5].q,
		mix:0,
		amp:[ 0.06, 0.04 ] * 1.3
	].ppm
});
P(\chord,start:'Very',music:{|p, b, e|
[
	//		freq:[[2,4],[1,3]].df('b-',octave:3 ).q,
	freq:[5,4,1].df('b-',octave:3 ).q,
	dur:b.parse([2/3,[1/3,1],1]).q,

].pp
}

);
["You see, Sargon would not let me keep this body",[5,6,12,11,5,6,11,12, 13,14,14,13].dm('b-',octave:4 )].addLine;
P.still(\henochCloseAlt, timecode: 3136.95.seconds, music: { |p b e|
	 e.still.( 
		wait: b.sum,
		text: ["",""],
	)
});
//P.tune('keep this');
SynthDef(\whiteNoise,{WhiteNoise.ar(\amp.kr(0.1))=>LPF.ar(_,2000)* Env.cutoff(1).kr(2,gate:\gate.kr(1)) => Out.ar(\out.kr(0),_)}).add;
P(\pad,syl: 1, music: { |p b e|
	(
		freq: 1.df(\f),
		instrument: \stringyy,
		dur: b.sum
	).play
});

P(\dyads, syl: 7,  music: { |p b e|
	[
		freq: [[1, 3], [1, 4],[1, 4],[1, 3]].df('b-').q,
		dur: b.drop(1).q
	].pp
});
P(\chords, music: { |p b e|
	[
		freq: [\r, [1, 3, 5],[-6, 1, 3],[-5, 1, 3]].df('b-',4, tuning: \just, ).q,
		dur: b.parse([2, 4, 2, 4]).q, 
		strum: 0.03, 
		instrument: \harp, amp: 0.1, coef: 0.9
	].pp
});
P.synthVs(role: \formulaLead,
	filter: (midinote: _ - 12), 
	take: [ \lead, \double ], params: {|p b| [
	lyrics: "You see, Sargon + would not let me keep this body +",
	legato: [ [1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 0.8  ] ],
	pitchTake: [ 1, 3 ],
	paramBreathiness:0
] }, music:{
	var pan = [-1,1];
	pan.collect{ |i|
		{|p b e|
			{
				e.playbuf
				=> p.synthVTracks.at(e.key).()
				=> Pan2.ar(_,i)
			}.play
		}
	}
}.()
);
// P(\vocoder,start:'keep this',music:{|p b e|
// 	\b++b =>_.postln;
// 	Song.pbind['keep this']
// 	=>Pbindf(_,\legato,1,
// 		//		\instrument,\sawSynth,
// 	)
// 	=>Pmul(\freq,[0.25, 0.5 ],_)
// 	+= [amp:0.0002, instrument: \whiteNoise, dur:[ 2 ].q(inf) ].p
// 	//	=>{|i| VocoderPattern(i,'keep this body').play }
// 	=> VocoderPattern(_,'keep this body',
// 		warp:0,
// 		durs:Song.durs['keep this'].list.asArray,
// 		dry:0.0,
// 		//		inputEffect:(EchoNone.ar(_,0.4,0.3,1.5))
// 		//		fftSize:4096,
// 		out:1
// 	)
// }.value
// );
P(\keepThisOctaves,start:'keep this',music:{|p b e|
[
	freq: [\r,1,-6,-5].df('b-',octave:[2,3,1] ).q,
	dur: b.parse([2, 4,2,4]) + [0,0,0,1] =>_.q,
	legato:1,
	out:[ 0 ]++Effect(
		{|i|

			var chain = FFT({ LocalBuf(2048) }!2,i);
			chain = PV_MagSmear.new(chain,  bins: 10.0);
			chain = PV_MagSmooth.new(chain,  factor: 0.9);
			IFFT(chain)
		},
		out:0,inputChannels:2
	).bus.index,

].p.play
}
);
//["would not permit me to keep this body","r"].addLine;
["It is therefore necessary for", [-7,1,2,3,2,1,-7,1,-6].dm('b-',octave:5)].addLine;
P.synthVs(role: \formulaLead, take:[\lead, \double],
	pbind: Song.enlarge2(8),
	filter: (midinote: _ - 12), 
	params: {|p b| [
	lyrics: "It is therefore + necessary + + + for you to kill your captain + so that sar gone will die with him",
	legato: [[1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 0.8, 1, 1, 1, 1, 1, 1, 1, 1, ]],
	pitchTake: [1, 3]
] }, music:{|p b e|
	{
		e.playbuf
		=> p.synthVTracks.at(e.key).()
		=> Pan2.ar(_,0)
	}.play
});

//P.tune('necessary');
// P(\vocoder,start:'necessary',music:{|p b e|
// Song.pbind['necessary']
// =>Pbindf(_,\legato,1,
// 	//		\instrument,\sawSynth,
// )
// =>Pmul(\freq,[0.25, 0.5 ],_)
// += [amp:0.0002, instrument: \whiteNoise, dur:[ 2 ].q(inf) ].p
// =>VocoderPattern(_, 'necessary',
// 	out:1,
// 	warp:1,
// 	// ry:0.0,
// 	//		inputEffect:(EchoNone.ar(_,0.4,0.3,1.5))
// )
// }.value
// );
P.tune('therefore',{|i| i.fin(4)=> Pmul(\freq,[ 0.5 , 0.25 ],_)=>Pbindf(_,\instrument,\sparkTriangle,\amp,0.06)});
P(\necessaryBaseNote,start:'necessary',music:{|p b e|
[out:
	[ 0 ]++
	Effect(
		{|i|

			var chain = FFT({ LocalBuf(2048) }!2,i);
			chain = PV_MagSmear.new(chain,  bins: 10.0);
			chain = PV_MagSmooth.new(chain,  factor: 0.9);
			IFFT(chain)
			=> EchoNone.ar(_,1,0.2,2)
		},
		out:0,inputChannels:2
	).bus.index,
	freq:[\r,6].df('b-',octave:[2,3] ).q,
	amp:0.25,
	[ \instrument,\amp,\mix,\release ]:[ \stringyy,0.15 ,0,4 ],
	legato:1,
	dur:b.parse([4,5]).q,
].pp
}
);
["you to kill your captain ", [4,3,5,4,3,2].dm('b-',octave:5)].addLine;
P.tune('kill', _ <> [instrument: \stringyy].pm);
P(\vocoder,start:'kill',music:{|p b e|
Song.pbind['kill']
=>Pbindf(_,\legato,1,
	//		\instrument,\sawSynth,
)
=>Pmul(\freq,[0.25, 0.5 ],_)
+= [amp:0.0002, instrument: \whiteNoise, dur:[ 2 ].q(inf) ].p
=>VocoderPattern(_, 'kill',
	out:1,
	warp:0,
	dry:0.0,
	//		inputEffect:(EchoNone.ar(_,0.4,0.3,1.5))
)
}.value
);
P(\killBaseNote,start:'kill',music:{|p b e|
[out:[ 0 ]++Effect(
	{|i|

		var chain = FFT({ LocalBuf(2048) }!2,i);
		chain = PV_MagSmear.new(chain,  bins: 10.0);
		chain = PV_MagSmooth.new(chain,  factor: 0.9);
		IFFT(chain)
	},
	out:0,inputChannels:2
).bus.index,
freq:[5.5,5].df('b-',octave:[2,3] ).q,
amp:0.25,
legato:1,
[ \instrument,\amp,\mix,\release ]:[ \stringyy,0.15 ,0,4 ],
dur:b.parse([4,2]).q,
].pp
}
);
["so that Sargon will die with him.",[-7,1,3,2.5,-6,-7,2,1].dm('b-')].addLine;
P.tune('with him');
P(\sargonLowerBase,start:'with him',music:{|p b e|
[
freq: [\r,5.5,6,7,11].df('b-',octave:[ 1,2 ] ).q,
amp:0.2,
dur:b.parse([2,2,2,1,1]).q,
	legato:1.1,
	[ \instrument,\amp,\mix,\release ]:[ \stringyy,0.15 ,0,4 ],
].pp

}
);
// This item is the version from reaper which is probably better 
P(\sargonBaseline,start:'with him',music:{|p b e|
[
	freq: [\r,4.5,12,4].df('f',octave:[2,3] ).q,
	legato:1.1,
	[ \instrument,\amp,\mix,\release ]:[ \stringyy,0.15 ,0,4 ],

	dur:b.parse([2,2,2,2]).q,
].p//p
}
);
P(\sargonNote,start:'with him',syl:5,music:{|p b e|
[ 
	instrument:\sawSynthSustain, 
	att:13, 
	dur:b.q,
	amp:[ 0.3,0.1 ].q/3,
	rel:5,
	lag:[ b[0]/3,b[0]/5 ].q, 
	freq: [6,5].df('b-',octave:5 ).q ,
	out:[0,1].q,
].p.play
}
);
P(\sargonMiddleVoice,start:'with him',music:{|p b e|
[
	freq: [\r,1.5,6,5,4,3].df('b-',octave:3 ).q,
	//		instrument:\stringyy,
	amp:0.3,

	lag:-64/44100*3,
	mix:0,
	out:
	//		[ 3 ]++
	Effect(
		{|i|

			var chain = FFT({ LocalBuf(2048) }!2,i);
			chain = PV_MagSmear.new(chain,  bins: 10.0);
			chain = PV_MagSmooth.new(chain,  factor: 0.9);
			IFFT(chain)
			=>MoogFF.ar(_,2800,2)
		},
		out:2,inputChannels:2
	).bus.index,
	//		out: 3,
	dur:b.parse([2,2,1,1,1,1]).q,
	legato:[1,1,1,1,1,1,1].q,
].pm(\sawSynthSustain).play
}
);
P(\sargonTuningGong,start:'with him',syl:1,music:{|p b e|
(type:\tuningGong,
	amp:0.005,
	sustain:0,
	release:6,
	freq:
	[1].df('f#',octave:5).unbubble
).play
}
);
P(\sargonStrum,start:'with him',music:{|p b e|
[

	freq: [\r,[5,11,13,15,21]].df('b',octave:4,scale:\minor,tuning:\sept1,).q,
	lfo: Effect.lfo({ SinOsc.kr(3.5).range(0.02 , 0.1) }),
	amp:Pfunc({|e|e.lfo}) ,
	out:Effect({|i|i.distort => EarlyRef.ar(_,[1,1,1],[2,3,1],[5,6,4])=> DWGReverbC1C3.ar(_,2000,1,30,mix:0.5)},inputChannels:2,out:2,).bus.index,
	strum:0.06,
	dur:b.parse([2,3]).q,

].pp;
}
);
 })
