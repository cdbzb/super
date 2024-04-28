(
Song(\panel1,[]).current;
Song.energyDur = 0.1;
( Song.synthVTracks=EventWithDefault(
	\default, {|mix = 1 c1=1 c3=10|
		{
			|i|
			var early = 0.5;
			var dryAmount = 1;
			EarlyRef.ar(i, source:[2,3,2], receiver:[0,0,0], roomsize:[4,5,6], hw:0.2, b:0.97, n:0, p:0, allp_lens:nil, allp_c:0.7)

			=> DWGReverbC1C3.ar(_, len:2000, c1:1, c3:10, mix:1-early * mix)
			+ ( i * dryAmount )
			/ 6 
			=> HPF.ar(_,100)
			=> DCompressor.ar(_, sidechainIn:0, sidechain:0, ratio:4, threshold:-40, attack:0.1, release:100.1, makeup:0.5, automakeup:1)
		}
	}
));
"~/tank/super/Trek/Songs/boilerplate.scd".standardizePath.load;
Song.vocoderRatio.set(1);
//(A panel slides back to reveal a much larger area, with rock walls, and a glowing sphere elegantly poised on an angled support.) 

// /*SARGON: (the glowing sphere)*/[" Welcome. I am Sargon. ","r",[5]].addLine; 
{
	["I am Sargon!","1 2 1 -7 -7".dm('b',5,\harmonicMinor)].addLine;
// P.tune();
P.synthV(role: \vocoder, frozen: true, params: {|p b| [
		filter: (midinote: 40), 
		lyrics: "ai am sar - gone",
		language: \english,
		phoneset: \arpabet,
		paramGender: 0.3
	] }, music:{|p b e|
		p.vocodeTune.(p,b,e,e.rpp,
			chord:#[1,2,3,4],
			width:1.03,
			mix:0.5,
			amp:0.8,
			durRel:1,
			att:0, sus:b.sum, rel:e.bNext.sum-0.5,
			dur: b.sum+e.bNext.sum-0.5
		);
		// p.monitorCarrier.()
});
/* P.still(\sargonSpeaks, timecode: 1013.361.seconds, music: { |p b e|
		e.still.( 
			wait: b.sum,
			text: ["I","am Sargon"],
		)
}); */
	/*SPOCK:*/[" Sargon, would it harm you if I ","4 5 7 11 12 6 5 4".dm(\d)].addLine; 
P(\bassnotes, music: { |p b e|
		[
			freq: [1, -6].df(\g,[3,4]).q,
			instrument: \wash
		].pp
});
P.still(\wideHarm, timecode: 1021.256.seconds, music: { |p b e|
		e.still.( 
			wait: b.sum,
			text: ["Sargon would it harm you","if I.."],
		)
});
P.tune('harm',_<>[instrument:\wash,freqLag:0.05].pm);
P.synthVs(role: \spock, take: [\dbl, \lead ], params: {|p b| [
		lyrics: "Sargon +  would it harm you if I ",
		filter: (midinote: _ - 12), 
		legato: [ [1, 0.8, 1, 1, 1, 1, 1, 1, ] ],
		lag: [[ 0.08, 0.06, 0.04, 0.02, 0, 0, 0, 0 ]],
		pitchTake: [ 1, 3 ]
	] }, music:{|p b e|
		{
			e.playbuf
			=> p.synthVTracks.at(e.key).()
			/2
		}.play
});
	/*SARGON:*/[" You may use your tricorder, Mister Spock.","3 2 5 3 1 -7 -6 -6 -5 2".dm(\b,4)].addLine;
P.still(\illuminated, timecode: 1024.6.seconds, music: { |p b e|
		e.still.( 
			wait: b.sum,
			text: ["you may use","your tricorder"],
		).sequenceText2(
			b.parse([7]), [ 
				["Mister","Spock"],
			],
		)
});
P(\bassnotes, music: { |p b e|
		[
			freq: "5 -6 -4.5".df(\b,4).q,
			dur: b.parse([4,5,1]).q,
			instrument: \default,
			amp: 0.1,
			out: Effect.bus({|i| DWGReverbC1C3.ar(i) },out:1)
		].pp;
		[
			freq: "5 -6 -4.5".df(\b,4).q,
			dur: b.parse([4,5,1]).q,
			instrument: \wash,
			amp: 0.15,
			out: Effect.bus({|i| DWGReverbC1C3.ar(i) },)
		].pp
});
P.synthV(role: \vocoder, frozen: true, 
		// filter: (midinote: 48!16) ,
		filter: (midinote: _ - 12),
		params: [
			lyrics: "You may use your try corder + Mister + Spock",
			defaultVibratoDepth: 0.3,
			legato: [1, 1, 1, 1, 1, 1, 0.6, 1, 1, 0.7, ],
			lag: [0.1, 0, 0, 0, 0, 0, 0, 0, 0, 0],
			language: "english",
			phoneset: "arpabet"
		],music:{|p b e|
			//
			// Song.pbind[\substance].patternpairs ++ [att:5,instrument:\sawSynthSustain,out:Song.carrierBus,amp:0.005] => _.pm =>_.play;
			// { PlayBuf.ar(1,Song.laMer.bufnum,rate:-3.midiratio /2) }.play(s,p.carrierBus);

			p.vocodeTune.(p, b,e,e.rpp,
				modGain:2.7,
				chord:#[1,2,4]/2,
				// echo:0.1,
				mix:0.5,
				width:1.05,
				// amp:0.04,
				verb:0.5,
				att: 0,
				sus:b.sum,
				rel:0,
				dur:b.sum,
				// att:1,
				// sus:b.sum-0.1,
				// rel:0.2,
				// out:3
			);
	});
}.();
{
["Your readings will show","-5 1 -7 1 2".dm(\e)].addLine;
P.still(\clear, timecode: 0.seconds, music: { |p b e|
	 e.still.( 
		wait: b.sum,
		text: ["your readings","will show"],
	)
});
P(\bassline, music: { |p b e|
	[
		freq: "r 6 5 4 2".df(\e,3).q,
		instrument: \sawSynth,
		dur: b.q,
		rest: [\r, 1, 1, 1, 1].q
	].pp
});
P.synthV(role: \vocoder, frozen: true, 
	// filter: (midinote: 48!16) ,
	filter: (midinote: _ - 12),
	params: [
	lyrics: "your readings + will show",
	defaultVibratoDepth: 0.3,
	language: "english",
	phoneset: "arpabet"
],music:{|p b e|
//
		// Song.pbind[\substance].patternpairs ++ [att:5,instrument:\sawSynthSustain,out:Song.carrierBus,amp:0.005] => _.pm =>_.play;
		// { PlayBuf.ar(1,Song.laMer.bufnum,rate:-3.midiratio /2) }.play(s,p.carrierBus);

		p.vocodeTune.(p, b,e,e.rpp,

		modGain:2.5,
		carrierGain: 0.3,
		chord:#[1,2,4]/2,
		// echo:0.1,
		mix:0.9,
		width:1.05,
		// amp:0.04,
		verb:0.5,
		att: 0,
		sus:b.sum,
		rel:1
			// dur:b.sum+1,
			// att:1,
			// sus:b.sum-0.1,
			// rel:0.2,
			// out:3
		);
});
["energy but no substance. ","3 2 3 2 1 -7 1 -7 -6 -5 4 3 3 1 2 -7".dm(\e)].addLine;
/* 
P.still(\wideEnergy, timecode: 1030.85.seconds, music: { |p b e|
	 e.still.( 
		wait: b.sum,
		text: ["",""],
	)
});
*/
P.still(\clear, timecode: 0.seconds, music: { |p b e|
	 e.still.( 
		wait: b.sum,
		text: ["Energy",""],
	).sequenceText2(
			b.parse([10]), [ 
			["but no","substance"],
			],
	)
});
Song.setTempoMap(\substance,"e e e e e e e e e e e e e e e");
P(\licklet, syl: 11,music: { |p b e|
	[
		freq:[1, -7, [1,2.5]].df(\e).q,
		instrument: \visual_pad,
		amp:0.3,
		out:3,
		dur: b.drop(1).parse([2,2]) ++ e.bNext[0] => _.q
	].ppm
});
P(\tune, music: { |p b e|
	p.pbind[e.start] <> [
		instrument: \harp,
		coef:0.1,
		amp:0.02,
		dur: "e*15 x".beats.warpTo(e.tempoMap.quantizeWindow(0.5)).q,
		out: Effect.bus({|i| Phaser2.ar(i, rate:0.01) => Monitors.az(_,SinOsc.ar(0.2)) => FreeVerb.ar(_,0.2,1)  },time:5 )
	].p
=>_.play
});
P(\kick, music: { |p b e|
	
	[
		// freq: [\r].q ++ [1].q(inf) ,
		instrument: \bd_808,
		tone: 46,//56
		decay: 5, //30
		amp: 0.3,
		out: 2,
		dur: "qe e qq qe e q".asBeats.warpTo(e.tempoMap
			.quantizeDft(0.1)
		).q
	].pp
});
P(\claps, music: { |p b e|
	[
		freq: [\r].q ++ [1].q(inf) ,
		instrument: \cp_808,
		amp: 0.3,
		out: 2,
		dur: "q e eq qq e eq e".asBeats.warpTo(e.tempoMap
			.quantizeDft(0.3)
		).q
	].pp
});
// P.tune(\substance);
P('bassline',start:\substance,music: {|p b e|
	[
		freq:[1, 5, 2, 4].stutter(2).df(\e,3).q,
		dur:[3,1] => _.dup(4) => _.flat=> _.warpTo(b) => _.q
	].pp
});
P.synthV(role: \vocoder, frozen: true, 
	// filter: (midinote: 48!16) ,
	pbind: {|p b| [midinote: "3 2 3  4 3 3 2".dm(\e,4).q,dur:b.parse([1,1,8,1,1,2,2]).q ].p},
	params: [
	lyrics: "energy + +  but no substance  + ",
	legato: [1,1,1,1,1,1,0.7],
	defaultVibratoDepth: 0.3,
	language: "english",
	phoneset: "arpabet"
],music:{|p b e|
//
		Song.pbind[\substance].patternpairs ++ [rel:0,att:5,instrument:\sawSynthSustain,out:Song.carrierBus,amp:0.008] => _.pm =>_.play;
		// { PlayBuf.ar(1,Song.laMer.bufnum,rate:-3.midiratio /2) }.play(s,p.carrierBus);

		p.vocodeTune.(p, b.parse([1,1,4,4,1,1,2,2]),e,e.rpp,
		tune: [3, 2, 3, 3, 4, 3, 3, 2].dm(\e).asList,

		modGain:2.5,
		chord:#[1,2,4]/2,
		// echo:0.1,
		mix:0.9,
		width:1.05,
		// amp:0.04,
		verb:0.5,
		att: 0,
		sus:b.sum,
		rel:0.0
			// dur:b.sum+1,
			// att:1,
			// sus:b.sum-0.1,
			// rel:0.2,
			// out:3
		);
});
P('chords',start:\energy,music: {|p b e|
	var one = [1,3,5], six = [-6,3,1],two = [2,4,6], four = [-4,-6,1], five = [-5,-7,2];
	//progression = [one, six, four, five];
	var progression = [one, five, two, four];
	[
		freq: progression.stutter(2).df(\e).q,
		dur: "h h h h h h h h".asBeats.warpTo(b).q,
		instrument:\sawSynth,amp:0.05,
		hifreq: 7000,
		out: [2,3].stutter.q(inf),
		rel:1


	].pp
});
["Sealed in this receptacle is the ",[5, 4,3,2,3,4,3,-5,-6,-7].dm(\c,6)].addLine;
P.synthV( role: \vocoder, frozen: true,
		lag:-0.5,
	// double:true,
	// filter: (midinote: 48!10), 
	filter: (midinote: _ - 12), 
	params: {|p b| [
	lyrics: "sealed in this receptacle + - + + is the",
	lag: [0.0,0,0,0,0,0,0,0,0] + 0.5,
	defaultVibratoDepth:0.3
] }, music:{|p b e|
		// e.playbuf
		// => p.synthVTracks.at(e.key).()
		p.pbind[e.start].patternpairs 
		++ [\att,4, \instrument, \sawSynthSustain, \out,p.carrierBus, \freq,Pfunc({|i| i.midinote - [0,12 ]=>_.midicps}), \amp,0.006, \lagTimg, 0.005, \rel,0]
			=> _.pm
			=> _.findur(b.sum)
			// => _.play
			;
		p.vocodeTune.(p,b,e,e.rpp,
		modGain:4,
		dur: b.sum + 0.5,
		// sus: b.sum - 0.5 ,
		durRel: 0.7,
		rel:1.0,
		chord:#[1,2,4],
		// chord:#[1,0.5,2,8],
		echo:0.3,
		mix:0.5,
			amp:0.22,
			// dur:b.sum+1,
			// att:1,
			// sus:b.sum-0.1,
			// rel:0.2,
			// out:3
		durRel: 0.5
		);
});
P('cymbal',start:\Sealed,music: {|p b e|
	[ instrument:\cymbal_808,amp:0.5,decay:4,dur:2.dup(5).warpTo(e.tempoMap.quantizeDft).q ].p.play
});
Song.setTempoMap(\Sealed,"q e eq e x xq e e Q Q");
P.tune(\Sealed,Pbindf(_,\instrument,\sparkTriangle,\depth,0.001,amp:0.03));
P('chords',start:\Sealed,music: {|p b e|
	[
		freq: [[1,3,5,7],[-6,1,2,5]].df(\f).q,
		dur: "hh h".asBeats.warpTo(e.tempoMap).q,
		instrument:\wash,
		amp:0.06
	].pp
});
P('click',start:\Sealed,music: {|p b e|
	[
		dur: 2.dup(4).warpTo(e.tempoMap).q,
		instrument:\hat_808
	]//.pp
});
P('bass',start:\Sealed,music: {|p b e|
	[
		freq: [1,-6].df(\f,[3,4]).q,
		dur: [4,3].warpTo(e.tempoMap).q
	].pp;
	/*
	RecOnsets(\boom,\Sealed)
	//.arm
	.play - [0.12,0.00,0] ;
	*/
	 [2,3.75,1.5].push(1,1.05)=> {|i| [dur:i .warpTo(e.tempoMap) .q,instrument:\sn_808,rest:[\r,1,1,1].q,out:Effect.bus(EchoNone.ar(_,0.2,0.2,3)/1)].pp} ;


});
P.still(\receptacle, timecode: 1013.361.seconds, music: { |p b e|
	 e.still.( 
		wait: b.sum,
		text: ["",""],
	)
});
P.still(\clear, timecode: 0.seconds,lag:0.01, music: { |p b e|
	 e.still.( 
		wait: b.sum ,
		text: ["sealed in this","receptacle is the"],
	)
});
["essence of my mind. ",[7,7,6,7,6,5,6, 5].dm(\g)].addLine; 
Song.essenceGain = 4/3;
Song.durs[\essence]=Song.durs[\essence].list.dup(2).flat[(0..15)].q; //only 15
Song.setTempoMap(\essence,"q qe ee e e e qqe e ".wrapExtend(37));
P(\ep, music: { |p b e|
	[
		freq: [[-1, 3, 5, 7, 12], [-1, 3, 4, 6, 11]].df(\g).q,
		strum: 0.05,
		dur: b.parse([4, 3]).q,
		out: Effect.bus({|i| i * SinOsc.ar([3, 4]) },out: 2),
		amp: 0.07
	].pp
});
P.still(\clear, timecode: 0.seconds, music: { |p b e|
	 e.still.( 
		wait: b.parse([7]).unbubble,
		text: ["essence","of my mind"],
	)
});
P.synthV(role: \vocoder, frozen: true,
	lag: -0.2,
	// prepend: true,
	// filter: (midinote: 48!12), 
	filter: (midinote: _ - 12), 
	params: {|p b| [
	lyrics: "essence + of my mind - - r r r r r r r r r",
	lag: [0.05,0,0,0,0,0,0,0,0,0,0,0] + 0.2
] }, music:{|p b e|
	p.pbind[e.start].patternpairs 
		++ [
			\att,4,
			\instrument, \sawSynthSustain,
			\out,p.carrierBus,
			\freq,Pfunc({|i| i.midinote - [12,24 ]=>_.midicps}),
			\amp,0.015,
			\lag,0.1,
			\lagTime, 0.005
		]
			=> _.ppm;
			( freq: [3,5,7].df(\g,4),instrument: \sawSynthSustain,
			out: p.carrierBus ,
			amp:0.015,dur:2,rel:4,addAction:\addBefore).play;
		p.vocodeTune.(p,b,e,e.rpp,
			echo: 0.5,
			modGain:4,
		// chord:#[1,0.5,2,8],
		// echo:0.1,modGain:6,
		mix:0.8,
			amp:0.32,
			// dur:b.sum+1,
			// att:1,
			 sus:b.sum / 2,
			rel:0.2,
			// out:3
		);
});
P.synthV(\kevin, take: nil,  
	pbind: {|p b| [ dur:p.durs[\essence], midinote: "1 1 1 1 1 1 1 4 7 7 6 7 6 5 6 ".dm(\a) ].p },
	params: {|p b| [
	lyrics: "r r r r r r r the essence + of his mind - - r",
] }, music:{|p b e|
	{
		e.playbuf
		=> p.synthVTracks.at(e.key).()
		/ 2
		* p.essenceGain
	}.play
});
P.double(\kevin, take: nil,
	pbind: {|p b| [ dur:p.durs[\essence], midinote: "1 1 1 1 1 1 1 4 7 7 6 7 6 5 6 ".dm(\a) ].p },
	music:{|p b e|
	{
		e.playbuf
		=> p.synthVTracks.at(e.key).()
		/ 2

	}.play
});
P('cymbal',start:\essence,music: {|p b e|
	(
		instrument:\cymbalsDS,
		amp:[0.01,0.01],out:[1,3]
	).play
});
P(\click,start:\essence,music: { |p b e|
	[
		dur:1.dup(8).warpTo(e.tempoMap
			.quantizeDft
		).q(2),
		instrument:\hihat
	].pp
});
// P.tune(\essence,_ => {|i| [i,Pmul(\freq,midiratio(2),i)].q});
( Song.lala =
[
	dur: "q qe ee e e e qqe e q qe ee e e e e e e e e e  " .asBeats
	warpTo: Song.tempoMap[\essence].quantizeDft 
	=> _.q,
	// rests: [\r,\r,\r,\r,\r,\r,\r,\r,\r,\r,\r,\r,1,1,1,1,1,1,1,1].q,
	midinote: 1.dm('f#')!20// or is it e ??
].p
);
P.synthV(\xuan, frozen:true, take:\lala,
	pbind: {|p b| p.lala},
	filter: (midinote: _ + 0), 
	params: {|p b| [
	lyrics: "r r r r r r r r r r r r r 
	r r   la la la la la
	",
	// la la la la la la la
] }, music:{|p b e|
	// .play;
	p.vocodeTune.(p,b,e,e.rpp,
		modGain: 0.5,
		chord: #[0.5,1,2,3],
		dur: b.sum+ 2,
		sus: b.sum,
		rel: 4
	)
});
P(\chord,start:\essence,music: { |p b e|
	[
		freq:[ [1,3,5,7], [ 1,3,4,6 ] ].df(\g).q,
		instrument: \stringyy,
		dur: "qqqq qqqq".asBeats.warpTo(e.tempoMap).q,
		out:(0..3),
		release: 5,
		amp: p.essenceGain/10
	].p
	=> {|i| [i,Pmul(\freq,midiratio(2),i)].q}
	=> _.play
});
P(\bass,start:\essence,music: { |p b e|
	[
		freq:[1,-7,-4,-3].df(\g,[3,4]).q,
		dur: "qq qq qq qq".asBeats.warpTo(e.tempoMap).q,
		amp: p.essenceGain/10
	].p
	=> {|i| [i,Pmul(\freq,midiratio(-10),i)].q}
	=> _.play
});
["my mind outtro",[1, 11,7,6,6,5,6,7,7,6,5,5 ].dm(\b,\mixolydian) ].addLine;
Song.essenceGain= 4/3;
P.still(\spockClose, timecode: 1034.5.seconds, music: { |p b e|
	 e.still.( 
		 fadeIn: b.sum,
		wait: b.sum,
		text: ["",""],
	)
});
Song.setTempoMap(\outtro, "q qe ee e qq q q q qe ee e q" );
P.tune(\outtro, [ instrument:\sawSynthSustain, pulse:0.44, trigger:1,amp:0.15* Song.essenceGain ].pm <> _); //need to make it pulse
P('bass',start:\outtro,music: {|p b e|
	
[ [1, -7, -4, -3, -5, -4, -1],[2,3,2,2, 2,2, 1] ].flop.collect({ |i| i[0].dup(i[1]) }).flat .df(\b,\mixolydian)
=> {|i| 
	[
		freq: i.q/[8,4],
		dur: "qe e| e ee e| qe e| q q| qe e| qe e| q".asBeats.warpTo(1!16=>_.warpTo(e .tempoMap.quantizeDft)).q,
		amp: p.essenceGain/10
	].pp
}
});
P('chords',start:\outtro,music: {|p b e|
	
	[
		freq:[ [1,3,5,11], [ -7,3,5,7 ], [-6,1, 4,6],[-5,5],[-6,6],[2,5,7],[1,4,6],5,[1,3,5] ].df(\b,\mixolydian).q,
		instrument: \stringyy,
		dur: "qq qq qq q q qqe ee e q".asBeats.warpTo(e.tempoMap).q,
		amp: p.essenceGain/10,
		out: 2,
		release: [3,3, 4, 2, 2, 3, 3, 4 ].q,
	].pp
});
P('click',start:\outtro,music: {|p b e|
	1.dup(23)=>{|i| [dur:i.warpTo(e.tempoMap
		.quantizeDft
	).q,instrument:\hihat].pp };
	
	[
		dur: "q qq qq qq qq qq qq q ".asBeats.warpTo(e.tempoMap
			.quantizeDft
		//.quantizeWindow
		).q,
		//amp:0.05,
		//lag:0.005,
		instrument: \sn_808,
		rest:[\r,0,0,0,0,0,0].q,
		amp: p.essenceGain/10
	].pp;
	[
		dur: "e eqe ee e qq e ee e e eqe ee e qq ".asBeats-[0.01,0,0,0,0,0,0,0,0,0] =>_.warpTo(e.tempoMap
			.quantizeDft
		//.quantizeWindow
		)=>_.q,
		vol:0.08 * p.essenceGain,
		instrument: \kick_gentle,
	].pp
});
}.();
/*SPOCK:*/[" (boom) Pure energy. Matter without form. ","-4 11 7 6 5".dm(\c) ++ "7 6 5 4 11".dm(\e,\mixolydian)].addLine; 
Song.setTempoMap(\Pure,"qq qq Q Q Q QQ QQ Q Q qq");
Song.pureGain = 2.dbamp;
P.still(\tricorder,timecode: 1037.75.seconds,music:{ |p b e|
	e.still.(
		wait: b.sum,
		fade: 1.5,
		text:["",""] 
	).sequenceText2(
			b.parse([1]), [ 
				["pure energy","matter without form"],
			],
	)
});
Song.energyDur=0.1;
// Song.durs[\Pure] = "qq qq Q Q Q QQ QQ Q Q qq    qq qq qq qq".asBeats * Song.energyDur * 4  => _.q;
// P.tune();
//Song.secDur[\Pure];
P.synthVs(Trek.cast.spock, take: [nil, \bg1],
	filter: [
		(midinote: _ - 12),
		(midinote: "1 6 5 4 3 ".dm(\c) ++ "5 4 3 2 3".dm(\e,\mixolydian) - 12)
	], 
		// pbind:{ |p b| 
		// 	p.energyPbinds[0]
		// },
		params: {|p b key| [
				lyrics: "r Pure energy + + matter + without + form  ",
				// lag:[0, b[1]/2,0,0,0,0,0,0,0,0],
				legato: [[1, 1, 1, 1, 0.4, 1, 1, 1, 1, 1]],
				paramTension: 0.35,
				paramBreathiness: 0.65,
				tension: Env([0,0,1,1,1,1,1,1,1,0], b),
				loudness: Env([0,0,1,0,0,1,0,1,0,1] * 4, b),
				pitchTake: 1
		] }, music:{|p b e|
	{
			e.playbuf
			=> p.synthVTracks.at(e.key).(0.2)
			/4
			* p.pureGain
			* 4.dbamp
	}.play
});
P(\swell, music: { |p b e|
	{
		"-1 1 2 5 7".df('f#',[5],\mixolydian)
		=> Pulse.ar(_,0.05)
		* 0.1 /4 * p.pureGain
		* Env([0,0,1,0],b.parse([6,3,1] + [0,0,6]),[0,3,-3]).kr(2,gate:1)
	}.play
});
P.tune(\Pure, _ <> [rests:MuteFirst(), instrument: \stringyy].pm);
P(\chords, music: { |p b e|
		[
			freq: [[-1, 1,3,5,7], [-2, 2,4.5,6,11],[ -11.5,-1.5, 1.5,2.5, 5.5, 7, 11.5 ]].df(\f).q /2,
			// dur: [8, 8, 8].reciprocal * 2 * 4 => _.q,
			dur: "qqqqqq qqqq qq".asBeats.warpTo( e.tempoMap ).q,
			instrument: \visual_pad,
			amp: 0.07 * p.pureGain,
			legato: [1,1,0.9].q

		].pp

});
P(\tricorderArp, music: { |p b e|
		{
				var release = e.bNext.sum + 3;// + 3;
				var dur = p.energyDur;
				// var clock = Impulse.ar( dur.reciprocal );
				var clock = TDuty.ar( ( 1/6) ! 48 warpTo: e.tempoMap.quantizeDft => _.dq (3),0,1 );
				// var clock = Impulse.ar(10);
				var sequence =  [-1,-3,-5,-7,2,4,6,11, 13,15,17,22,17,15,13,11].df(\f).dq(inf);
				var sequence2 =  [-1,-3,-5,-7,2,4,6,11, 13,15,17,22,17,15,13,11].df(\g).dq(inf);
				var sequence3 = [-1,-2,-5,-7,2,4,6,11, 12,15,17,22,17,15,12,11].df('f#',\mixolydian).dq(inf);
				//arpeggia
				Saw.ar(
						Dswitch1(
								[sequence,sequence2,sequence3], 
								[0,1,2].dq.demand(b.parse([5,4,1]))
						) => Demand.ar(Impulse.ar(10),0,_ )
						* Line.ar(0,1,0.5)
				)
				/
				12  * p.essenceGain
				* ( clock => Decay2.ar(_,0.01,0.5) )
				=> {|i| [i, DelayN.ar(i,0.6,0.6)]}
				=>DWGReverbC1C3.ar(_,mix:0.14)
				=>Phaser2.ar(_,rate:0.12,fb:0.5)
				// hihat
				// firstArg:
				+
				(
						-2.dbamp *
						WhiteNoise.ar(0.1) * ( Impulse.ar(10)=> Decay.ar(_,0.3) )
						=> RLPF.ar(_, Demand.ar(Impulse.ar(10),0,Dwhite(300,8000).linexp(300,8000,300,8000)),0.3)
						=> 
						{ |i|
								Select.ar(
										SinOsc.ar(0.3).range(0,2),
										array:[
												i * 2,
												CombC.ar(i, 0.2, Demand.ar(Impulse.ar(10),0,Dwhite(0.01,0.02)))  
										].flat
								)
						}
						/7
						// Kick
						// firstArg:
				)
				+ (
								-14.dbamp *
								SinOsc.ar(Env([500 * \pitchBend.kr(1), 70, 50] / 50 * \freq.kr(50), [0.04, 0.05] * \bendTime.kr(0.5), \exp).ar)
								+ (HPF.ar(Hasher.ar(Sweep.ar), 1200) * Env.linen(0.001, 0.01, 0.001).ar * -5.dbamp)
								=> {|i| i + (i*2).tanh}
								* Env.perc(0.001, \release.kr(0.3)).ar(0, gate:
										[ "qqq".asBeats * dur * 8 => _.dq(1),
										"qq qq qq qq qq qq qx e x ".asBeats * dur * 8
										=> _.dq(inf) 
								].dq
								// (1).dq(inf) * dur
								=> TDuty.kr(_ ,0, gapFirst:1)
								// Impulse.ar(3.2.reciprocal)
						)
						* -5.dbamp
				)
				// Snare
				+ (
						{ var gate = Impulse.ar(1);
						LFTri.ar(Env([300, 230, 200] / 200 * \freqS.kr(220), [0.02, 0.03], \exp).ar) * Env.perc(0.001, 0.5).ar(gate:gate)
						* 3 => _.tanh
						+ (BPF.ar(Hasher.ar(Sweep.ar(gate-0.1)), \noiseFreq.kr(1200), 0.6) * Env.perc(0.1, 0.4).ar(gate:gate) * 5.dbamp)
						* 0.5 * \drive.kr(0.5) => _.tanh * 5.dbamp
						+ (SinOsc.ar( Env( [3000,100],0.02,\exp ).ar(0,gate)) * Env.perc(0.001, 0.02).ar( gate: gate ))
						* Env.perc(0.001, \decayS.kr(0.4)).ar(0, gate)
						/4
				})
		/3
		* EnvGen.cutoff(b.sum, release, -3 )
		=> Splay.ar(_)
				=> FoaEncode.ar(_, FoaEncoderMatrix.newStereo(0))
				=> FoaRotate.ar(_, SinOsc.ar(0.3))
				=> FoaDecode.ar(_, Monitors.decoder)
				* 3
				* p.pureGain
		}.play;
});
// P.tune();
// /*KIRK:*/[" Impossible. ","4 3 1 -5".dm('b-',\minor)].addLine; 
/*KIRK:*/[" Impossible. ","-5 3 1 -4.5".dm('b-',\minor)].addLine; 
/* P.still(\closeImpossible, timecode: 1041.380.seconds, music: { |p b e|
	 e.still.( 
		wait: b.sum,
		text: ["",""],
	)
}); */
P.still(\kirk, timecode: 1039.8.seconds, music: { |p b e|
	 e.still.( 
		wait: b.sum,
		text: ["Impossible",""],
	)
});
P.tune(\Impossible, { |i| Pmul(\freq,1,i) => Pbindf(_,\legato,4,\coef,0.3,\decaytime,8, \instrument, \harp, \out, Effect.bus( 
	{ |i| [Convolution.ar(i, Dust.ar(30) => FreeVerb.ar(_,1,1)) , PitchShift.ar(i,0.02,0.5) +i] * 0.2}, inputChannels:2
))} );
P(\dyad, music: { |p b e|
	[
		freq: 
		"-5 1 3".df('b-',\minor).bubble ++ " -4.5".df('b-',\minor)
		=>_.q,
		mix:0,
		amp:0.04,
		legato: [ [3,4,4],1 ].q,
		instrument: \pulse
	].p.play
});
P.synthV(role: \kirk,
	filter: (midinote: _ - 12), 
	params: {|p b key| [
		// vocalMode: "Power",
		pitchTake: [3],
		lyrics: "Impossible + + +",
		lag:[0,0,0.1,0],
		tension: Env([0,1,1,1,1],b,\step),
		paramTension:0.3 ,
		defaultVibratoDepth:0
	] }, music:{|p b e|
		{
			e.playbuf
			=> p.synthVTracks.at(e.key).()
			/2
			// => Out.ar(1,_)
			=> PanAz.ar(5,_,1)
		}.play
});
/*MCCOY:*/[" But you once had a body of some type? ","-5 3 2 1 -7 4.5 2 -6.5 5 4.5".dm(\d),].addLine; 
P(\strum, music: { |p b e|
	[
		freq: [\r,[-5,1,3,5,11,13],[-7,2,4.5,6,12,14.5],[-6.5, 2, 5, 6.5, 12, 14, 15]].df(\d).q,
		strum:0.06,
		amp: 0.05,
		dur: b.parse([1, 4, 3, 2]).q,
		legato:1.2,
		instrument: \harp,
		coef:0.3,
		out: Effect.bus({|i| i * SinOsc.ar(2.9) => PanAz.ar(4,_, SinOsc.ar(2) * pi) => FreeVerb.ar(_,0.4,1)}, inputChannels:4, out:0)
	].pp
});
P.still(\group_mccoy, timecode: 1042.39.seconds, music: { |p b e|
	 e.still.( 
		wait: b.sum,
		text: ["but you once","had a body"],
	).sequenceText([
		b.parse([7]).unbubble, ["of some type!",""]
	])
});
Trek.cast.mccoy = \mo; 
P.synthV(role: \mccoy, filter: (midinote: _ - 12), params: {|p b| [
	lyrics:" But you once had a body + of some type? " ,
	paramGender: 0.15,
	paramTension:0.8,
	pitchTake: 2,
	vocalMode: \Open
] }, music:{|p b e|
	{
		e.playbuf
		=> p.synthVTracks.at(e.key).(0.2)
		=> Pan2.ar(_,0.5)
		* 0.8
	}.play
});
P(\bassline, music: { |p b e|
	
	[
		freq: [\r, 1, [ 3,12,15, 17 ], 2.5].df(\a,[3,4]).q,
		dur: b.parse([1, 4, 3, 2]).q,
		legato:1
	].pp
});
// P.tune();
/*SARGON:*/[" A body much as yours, my children, although our minds were infinitely greater. ","-5 1 2 2 1 3".dm(\g) ++ "4 3 2 -6 -7 1 ".dm('a-') ++ "11 7 12 11 7 6 6 5".dm(\e)].addLine; 
P.still(\lit, timecode: 1045.5.seconds, music: { |p b e|
	 e.still.( 
		wait: b.parse([9]).unbubble,
		text: ["a body much as yours","my children"],
		fade: 4
	).sequenceText([
		b.parse([9]).unbubble, ["",""]
	])
});
P.still(\clear, syl:8, timecode: 0.seconds, music: { |p b e|
	 e.still.( 
		wait: b.drop(1).sum,
		text: ["although our","minds were"],
	).sequenceText([
		b.drop(1)[0..4].sum, ["infintely","greater"]
	])
});
P.synthV(role: \vocoder, frozen: true,
	filter: (midinote: _ - 12), 
	params: {|p b| [
	lyrics: " A body + much as yours my children + although + our minds were infinitely + + + greater + ",
] }, music:{|p b e|
	p.vocodeTune.( p, b, e, e.rpp,
		dur:b.sum+2,
		sus:b.sum,
		mix:0.8,
		modGain:1.5,
		rel:2,
		durRel:2
	);
		fork{
			b[..5].sum.wait;
			{
				p.laMer => PlayBuf.auto(2, _, rate: [4, 1, -5].dm('a-').dq - 1.dm('c') => _.midiratio => _.demand(b[6..8]))
				* Env([1, 1, 0], b[6..7].sum.bubble ++ b[8]).kr(2,gate:1)
			}.play(s,
				p.carrierBus,
			)
		}
});
// P.tune(\much);
P(\bassNote,syl:4, music: { |p b e|
	(
		freq:[1,-1, 5].df(\g,3),
		dur: b.drop(1)[0],
		lag:0.005,
		out: Effect.bus({|i| SineShaper.ar(i,0.2,2).bubble ++ FreeVerb.ar(i, 0.8, [0.9, 0.5, 0.7]) /2 },),
		amp: 0.1 * 1.5
	).play
});

P.tune('much ', { |i| Pmul(\freq,0.5,i) => Pbindf(_,\instrument, \sawSynthSustain,\out,Song.carrierBus,\amp,0.04)});
P('dyad',start:\much,syl:17,music: {|p b e|
	(
		freq: [ -1,1, 3 ].df(\a),
		instrument:\sawSynthSustain,
		att:1.5,
		amp:0.05 * 1.5,
		rel:3
	).play
});
P('chords',start:\much,syl:5,music: {|p b e|
	 VoiceLeading(
		[
			[ 4,  3,  \_, 2 ],
			[ 1,  1,  -7, \_ ],
			[ -6, -5, \_, \_ ]
		],
		b.drop(1).parse([1, 0.66,0.34,1  ])
	).df('a-').p
	=> {|i| i<> (instrument: \visual_pad,amp:0.2 * 1.5,
	) => _.play; i<>(instrument:\harp, amp:0.03 * 1.5) => _.play}
	//=> _.play
});
P('bass',start:\much,syl:8,music: {|p b e|
	[
		freq: [ [-6, 6 ], [-5.5, 5.5 ]  ].df('a-',3) ++ "7 12 11 7 6 4".df(\e,3) =>_.q,
		dur: b.drop(1).parse([3,1, 1, 1, 1, 1, 1, 2]).q,
		depth:0,
		freqLag:0.15,
		legato: [0.9,0.9,1,1,1,1,1,1].q
		
	].pma(\sparkTriangle).play
});
["(infinitely)","4 3 2 1".dm(\e,\whole)].addLine;
P.synthVs(\kevin, take:[\lead, \dbl], params: {|p b| [
	lyrics: "infinitely + + +",
	legato:[[1,1,1,2]],
	pitchTake:[1, 3],
	paramGender: -0.3,
	paramTension: -0.5,
	paramBreathiness: 0.5
] }, music:[-0.9,0.9].collect{|pan|{|p b e|
	{
		e.playbuf
		=> Pan2.ar(_,pan)
		/ 4
		* EnvGen.cutoff(b[0..2].sum,1,doneAction:0)
		=> FreeVerb.ar(_,0.4,0.9)


		// => p.synthVTracks.at(e.key).()
	}.play
}});
P.tune('(infinitely)', { |i| Pmul(\freq, [1,0.5],i) => Pbindf(_,\instrument,\harp,\amp,0.012,\out,(0..3).q)});
P(\vibes, music: { |p b e|
	"4 3 2 1".df(\e,\whole).do{|i x|
		fork{
			(b.integrate)[x].wait;
			{
				SinOsc.ar(i)
				* SinOsc.ar(3).range(0.1,1)
				* EnvGen.cutoff(1,3)
				* 0.1
				* 0.1
				/2
				* {4.rand}.dup(4)
			}.play
		}
	}
});
/*KIRK:*/[" That's twice you've referred to us as my children. ","1 6 2 3 2 3 7 6 6 7.5 2".dm(\f,\mixolydian) ].addLine; 
P.still(\kirk, timecode: 1051.1.seconds, music: { |p b e|
	e.still.( 
		wait: b.sum,
		text: ["that's twice",""],
	).sequenceText2(
			b.parse([2,[ 5, 0.5 ], 0.5]), [ 
			["you've referred","to us as"],
			["",""],
			["'my","children'"]
			],
	)
});
// P.tune(\That);
P(\chords,syl:0, music: { |p b e|
	[
		freq: [\g, 'a-', \g, 'a'].collect{|i| [3, 5].df(i,5)} =>_.q,
		dur: b.drop(1).parse([ 5, 1, 2, 2]).q,
		instrument: \visual_pad, amp: 0.25, rel: 1,
		rest: [\r, 1, 1, \r].q
	].ppm; 
});
P(\bass, music: { |p b e|
	[
		freq: [1, 2].df(\f,4).q,
		instrument: \wash,
		dur: b.parse([2,5]).q
	]//.p.play
});
P(\twice,syl:0, frozen:true, resources:(tail: 3), music: { |p b e|
	{
		var freq = [1, 4.5, 6.5].df(\f,[5, 6, 7]).flat;
		VarSaw.ar(freq,0, width: SinOsc.ar(0.5))
		/10
		* (Dust.ar((25..31)) => Decay.ar(_, 0.05))
		=> BPF.ar(_, Env([100, 5000, 100], [0.1, 6], [5, -5]).kr(0,gate:1) )
		=> FreeVerb.ar(_,0.6,1)
		=> OnePole.ar(_, 0.9)
		* EnvGen.cutoff(6, 2)
	}.play;
	{
		var freq = [1, 4.5, 6.5].df(\g,[5, 6, 7]).flat;
		VarSaw.ar(freq,0, width: SinOsc.ar(0.5))
		/10
		* (Dust.ar((25..31)) => Decay.ar(_, 0.05))
		=> BPF.ar(_, Env([100, 5000, 100], [0.1, 7], [5, -5]).kr(0,gate:1) )
		=> FreeVerb.ar(_,0.6,1)
		=> OnePole.ar(_, 0.9)
		=> DelayN.ar(_, b[..8].sum, b[..8].sum)
		* EnvGen.cutoff(7, 2)
		=> Out.ar(2,_)
	}.play;
	{
		{1000.pareto} ! 100
		=> SinOsc.ar(_,0,0.013)
		=> Splay.ar(_)
		* Env.perc(0.05,5).kr(2,gate:1)

		=> Out.ar(3,_)
	}.play
});
P(\bonk, syl:6, frozen:true, music: { |p b e|
	{

		MembraneHexagonV.ar(Impulse.ar(0)=>Decay.ar(_)*PinkNoise.ar(0.01),size:12, loss: 0.99995)
		=> DelayN.ar(_,delaytime:b.drop(1)[0]/2)
		=> Sanitize.ar(_)
		=> LeakDC.ar(_)
		// /2 
		=> Out.ar([1,2,4],_)
	}.play
});
P.synthV(Trek.cast.kirk,
	filter: (midinote: _ - 12), 
	params: {|p b key| [
	lyrics: " That's twice you've referred + to us as my children  + ",
	legato: [1, 0.9, 1,1,1,1,0.8, 0.8, 1, 1, 1],
	paramGender: case{
		key == \kevin }{ 0.3 }
		{true}{0.0}
] }, music:{|p b e|
	{
		e.playbuf
		=> p.synthVTracks.at(e.key).()
		/ 2
		* 2.dbamp
		
	}.play
});
/*SARGON:*/[" Because it is possible you are our descendants, Captain Kirk. ","1 3 5 7 12 7 5 3 ".dm(\f,4) ++ "1 3 5 7 12 11 13 11 7 6".dm(\g,4)].addLine;
P.still(\kirkSilent, timecode: 1053.7.seconds, music: { |p b e|
	 e.still.( 
		wait: b.sum,
		// fade: 8,
		text: ["because it is","possible"],
	).sequenceText2(
			b.parse([8,6,4]), [ 
			["you are our","descendants"],
			["Captain","Kirk"],
			["",""]
			],
	)
});
// P.still(\litAgain, timecode: 1045.seconds, music: { |p b e|
// 	 e.still.( 
// 		wait: b.sum,
// 		fade: 8,
// 		text: ["becuse it is","possible"],
// 	).sequenceText2(
// 			b.parse([8,6,4]), [ 
// 			["you are our","descendants"],
// 			["Captain","Kirk"],
// 			["",""]
// 			],
// 	)
// });
P.tune(\Because, { |i| i <> [instrument:\harp,\coef,0.2,amp:0.01 * (4/2),delaytime:-10,out:(0..4).q(inf)].p => Pmul(\freq,0.5,_)});
P(\bassnote, music: { |p b e|
	[
		freq: [1,2].df(\f,2).q,
		amp: [0.1,0.02].q * (4/2),
		dur: b.parse([8,10]).q,
		out: Effect.bus( { |i| DWGReverbC1C3.ar(i) * Env.linen([1,1,0],[b.sum,e.bNext.sum]).kr(2,gate:1)} )
	].p.play
});
P(\chord,lag:-0.1, music: { |p b e|
	[ 
		instrument: \sawSynth,
		att:4,
		freq: [[1,3,5,7,12].df(\f,4),[1,3,5,7,11].df(\g,4)].q,
		amp:0.02 * (4/2),
		dur: b.parse([8,12]) + [0.1,0] => _.q
	].pm.play
});
P.tune(\Becaus,_ <> [instrument:\sparkTriangle,\depth:0,amp:0.01 * 4/2,out:(0..4)].pm);
P.synthV(role: \vocoder, frozen: true,
	filter: (midinote: 55!18), 
	params: {|p b| [
	lyrics:" Because + it is possible + + - you are our descendants + +, Captain + Kirk - " ,
	legato: [1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 0.7, 1, 1, 1, 1, ],
	defaultVibratoDepth:0.3,
	vocalMode: \Soft
] }, music:{|p b e|
	{
		e.playbuf
		=> p.synthVTracks.at(e.key).()
	}//.play
	;
	// {|i| PlayBuf.auto(2,Song.laMer.bufnum,[-2,0].midiratio.dq.demand(b.parse([8,8])))/ 10}.play(s,p.carrierBus);
	p.vocodeTune.(p,b,e,e.rpp,
		att:0.1,
		modGain:2.5,
		// chord:#[2],
		amp:0.3,
		sus: b.sum - 0.4,
		rel:0.5,
		echo:0.5,
		verb:0.5,
	)
});
["(boom) Six thousand centuries ago, our vessels were ","-1 3 3 3 3 2 2 1 2 2 3 -4".dm('a-',\minor) ++ "11 5 6 3".dm(\c,5)].addLine;
Song.setTempoMap(\Six,"e e e e e x e x e x x");
P.still(\clear, timecode: 0.seconds, music: { |p b e|
	 e.still.( 
		wait: b.sum + e.bNext[..8].sum,
		text: ["",""]
	).sequenceText2(
			b.parse([1, 11,4]) + [0,0, e.bNext[..8].sum] => _.postln, [ 
				["six thousand","centuries ago"],
				["our vessels were", "colonizing this galaxy"]
			],
	)
});
P.tune('thousand', { |i| Pmul(\freq,0.5,i) => Pbindf(_,\instrument, \sawSynthSustain,\out,Song.carrierBus,\amp,0.04 * 2)});
P.synthV(role: \vocoder, frozen: true, enlarge: true, resources:(tail: 4), 
	filter: (midinote: _ - 24), 
	pbind: Song.enlarge(8),
	params: {|p b| [
	lyrics: "r Six thousand + centuries + +  ago + - - r our vessels + were Collin + eye zing this galaxy + +" ,
	defaultVibratoDepth:0.3,
] }, music:{|p b e|
	p.vocodeTune.(p,b,e,e.rpp,
		amp: 0.20,
		tune: "3 3 3 3 3 2 2 1 2 2 3 3".dm('a-',\minor) ++ "11 5 6 3".dm(\c,5) ++ [1,2,4,5,6,6,5,-7/*,-6,-5,-2*/].dm('e-'),
		dur: b.sum + e.bNext.sum,
		modGain: 2,
		amp: 0.285,
		verb:0.6,
		att:1,
		// dur:1,
		sus: b.sum + e.bNext.sum -0.25,
		rel:0.1,
		durRel: 0.5,
		enlarge: 8

	)
});
P.synthV(\xuan, take: \double,
	filter: (midinote: _ - 24), 
	params:{ |p b| [
		paramGender:0.4,
	lyrics: "r Six thousand + centuries + +  ago + - - r our vessels + were " ,
	] },
	music:{|p b e|
	
	{
		e.playbuf
		// => p.synthVTracks.at(e.key).()
		/10 * 2
	}.play(s,4)
}
);
// P.tune();
P('dmx',start:\Six,music: {|p b e|
	[
		"....x..x....x... .....x.",\snare,\amp,Pseg([0.05,0.05,0.02] * 2,b.parse([12,3]).q),
		"x.......x.x..... x......",\kick_gentle,\vol,0.1 * 2,
	].dmx(4)
	=> Ppar(_) => Pfindur(b.sum,_)
	=> _.play(clock:TempoClock.newFromQuarters(1!4=>_.warpTo(e.tempoMap)))
});
P('chords',start:\Six,music: {|p b e|
	[
		freq:[ [5,11],[4,7],[4,1] ].df('a-',4,\minor).q,
		att: 2,
		rel:[6,6,5].q,
		amp:[1,1,0.4].q/10 /2 *2,
		dur: b.parse([4,7,1]) - [0.05,-0.05,0] => _.q,
		instrument:\sawSynthSustain,
		// out: 2
	].pm(\sawSynthSustain).play
});
// P.tune(\Six, Pset(\amp, Pfunc({ |e|(e.midinote < -5.dm('a-')).if{0}{0.1}}), _ ));
P.tune('x th', { |i|
	{
	Pulse.ar(\freq.kr(100) * [1,1.01], 0.14)
		* Env.perc(0.01,3).kr(2,gate:1)
		* \amp.kr(0.1) * SinOsc.kr(3.3).range(0.4,1.2)
	}.asDefName =>
Pbindf(i, \amp,[1,0,0,0,0,0,0,0,0,0,0,0,1,1,1,1].q/45,
	\instrument, _) 
	=> Pmul (\freq,0.5,_)});
P('bass',start:\Six,music: {|p b e|
	[
		freq:[1,-7,-4].df('a-',3,\minor).q,
		dur: b.parse([4,7,1]).q
	].pp
});
//["colonising this galaxy . . . ",[1,2,4,5,2,5.5,5,-7,-5.5,-5,-17].dm('e-')].addLine;
["colonising this galaxy . . . ",[1,2,4,5,6,6,5,-7/*,-6,-5,-2*/].dm('e-')].addLine;
P('drumsNextPart',start:\colonising,music: {|p b e|
	[
		"x..",\kick_gentle,\vol,\amp,0.02 * 2,
		"x..",\cymbalsDS,\amp,0.008 * 2
	].dmx
	=> Ppar(_)=> Pfin(3,_) => _.play
});
P.tune(\colonising,Pbindf(_,
	\amp,[1,1,1,1,1,1,1,1,0,0,0].q/22 * 2 ,
	\instrument,\defaultPiano,
	\legato,4,
	
	\out, Effect.bus( {|i| i * SinOsc.kr(3.5).range(0.4,1) => _.tanh => LeakDC.ar(_)}, inputChannels:2, out: [1,Song.carrierBus] )
)

);
P.tune('colonising', { |i| Pmul(\freq,0.5,i) => Pbindf(_,\instrument, \sawSynthSustain,\out,Song.carrierBus,\amp,0.04 * 2)});
P('bassnote',start:\colonising,music: {|p b e|
	[
		freq:[1,2,4,5,6,6.5 ].df('e-',4,\mixolydian).q, 
		//freq:[[-6],  [-1,-5,1] ].df('f#',4).q, 
		out: Effect.bus(DWGReverbC1C3.ar(_,mix:0.2),inputChannels:2, out:[4]) ,
		amp: 0.07 * 2,
		dur: b.parse([1,1,1,1,1,3]).q,

	].p.play;
});
["just as your own starships have ",[1,4,7,6,6,5].dm(\e,\mixolydian) ++ [1].dm('a-')].addLine;
P.still(\clear, timecode: 0.seconds, music: { |p b e|
	 e.still.( 
		wait: b.sum,
		text: ["just as","your own"],
	).sequenceText2(
			b.parse([4]), [ 
			["starships","have"],
			],
	)
});
P.tune('starships', { |i| Pmul(\freq,0.5,i) => Pbindf(_,\instrument, \sawSynthSustain,\out,Song.carrierBus,\amp,0.04)});
P.synthV(role: \vocoder, frozen: true,
	filter: (midinote: _ - 24), params: {|p b| [
	lyrics: "just as your own starships + have ",
	legato: [1,1,1,1,1,1,0.9]
] }, music:{|p b e|
	{
		e.playbuf
		=> p.synthVTracks.at(e.key).()
	}//.play
	;
	p.vocodeTune.(p,b,e,e.rpp,
		// mix:0.5,
		chord: #[1,2,3,4,5],
		mix: 0.5,
		amp: 0.3,
		// amp: {SinOsc.ar(1)},
		// width: 1.05,
		sus:b.sum-2,
		verb:0.0,
		modGain:2,
		rel:2.1,
		att:0.5
		// smooth: -0.9

	);
});
// P.tune(\just);
P('line',start:\just,music: {|p b e|
	[
		freq: [1,4,7,6,5,5.5].df(\e,\mixolydian).q * [1,0.5],
		dur: b.parse([1,1,1,2,2,1]) + [0,0,0,0,0,0.1] => _.q,
		instrument: \stringyy,
		freqLag: [1,1,1,1,10,10]/20=>_.q,
		out: 2,
		amp: 0.1 * 2
	].pm(\stringyy).play
});
P('bass',start:\just,music: {|p b e|
	
	[
		freq:[1].df('e',[4,  3 ]).q,
		dur: b.parse([4]).q,
		instrument:\defaultPiano,
		amp: 0.1 * 2
	].pp
});
["now begun to explore that",[2,5,3,2,1,7,6].dm('a-',\mixolydian)].addLine;
P.still(\clear, timecode: 0.seconds, music: { |p b e|
	 e.still.( 
		wait: b.sum,
		text: ["now begun","to explore that"],
	)
});
P.synthV(role: \vocoder, frozen: true,
	lag: -0.1,
	filter: (midinote: _ - 24), 
	// prepend: true,
	params: {|p b| [
	lyrics: "now begun + to explore + that" ,
	lag: [0.1,0.1,0.1,0.1,0.1,0.1,0.1],
	legato: [1,1,1,1,1,1,0.9]
] }, music:{|p b e|
	{
		e.playbuf
		=> p.synthVTracks.at(e.key).()
	}//.play
	;
	p.vocodeTune.(p,b,e,e.rpp,
		width:1.02,
		modGain:2,
		amp: 0.5,
		echo:0.5,
		verb:0.5,
		dur: b.sum,
		// mix: 0.5,
		sus:b.sum ,
		rel: 0.1,
		att: 0.2


	)
});
// P.tune(\begun);
P('bass',start:\begun,music: {|p b e|
	[
		freq:[1,7].df('a-',[4,  3 ],\mixolydian).q,
		dur: b.parse([5,2]).q,
		instrument:\defaultPiano,
		amp: 0.2
	].pp
});
[" vastness... ",[6,5].dm('a-')].addLine;// illustrate the dots
P.still(\clear, timecode: 0.seconds, music: { |p b e|
	 e.still.( 
		wait: b.sum,
		text: ["vastness",""],
	)
});
P.synthV(role: \vocoder, frozen: true,
	lag: -0.1,
	filter: (midinote: _ - 24), 
	// prepend: true,
	params: {|p b| [
	lyrics: "vastness +",
	lag:[0.1,0.1],
	legato: [1,0.85],
	phonemes: ["","t n eh s"],
	defaultVibratoDepth: 0.1
] }, music:{|p b e|
{
		e.playbuf
		=> p.synthVTracks.at(e.key).()
	}//.play
	;
	p.vocodeTune.(p,b,e,e.rpp,
		// verb:0,
		width:1.02,
		modGain:2,
		amp: 0.3,
		echo:0.5,
		verb:0.0,
		att:0,
		sus:b.sum  ,
		dur: b.sum + 0.1,
		rel:0.2,
		durRel:0.5
		// rel:1.2

	)
});
P.tune([instrument: \stringyy,amp:0.05 * 2,out:4 ].p <> _ );
P('bassNote',start:\vastness,music: {|p b e|
	(freq:[-7].df(\b,3,\mixolydian) / [1,2],out:Effect.bus( { |i| DWGReverbC1C3.ar(i * 1.5)},inputChannels:2 )).play;
	(freq:[11,5].df(\b,3),instrument:\defaultPiano,dur:b.sum, amp: 0.1 * 1.5).play
});
["As you now leave your own seed on distant planets, ",[1,3,1,4,3,1,3,4,5,3,7,6].dm(\d,\dorian)].addLine;
P.still(\altWide, timecode: 1110.seconds, music: { |p b e|
	 e.still.( 
		wait: b.sum,
		text: ["",""]
	)
});
P.still(\clear, timecode: 0.seconds, lag:0.01, music: { |p b e|
	 e.still.( 
		wait: b.sum,
		text: ["as you now leave","your own seed on"],
	).sequenceText2(
			b.parse([8]), [ 
			["distant","planets"],
			],
	)
});
Song.setTempoMap(\planets, "q q q qq qq q e e q q qq qq");
P(\kick, music: { |p b e|
	[
		dur: "q qqqq qqqq qq qq".asBeats.warpTo( e.tempoMap ).q,
		instrument: \bd_808,
		amp:0.2 * 2
	].pp
});
P.synthV(role: \vocoder, take: \lead,frozen: true,
	filter: (midinote: _ - 12), 
	// prepend: true,
	params: {|p b| [
	lyrics: "As you now leave your own seed on distant + planets + " ,
] }, music:{|p b e|
	{
		e.playbuf
		=> p.synthVTracks.at(e.key).()
	}//.play
	;
	p.vocodeTune.(p,b,e,e.rpp,
		width:1.03,
		verb:1,
		modGain:1.7,
		// echo:0,modGain: 4,
		// mix:0.5,
		att:0.1,
		sus:b.sum,
		rel: 1,
		chord:#[1,2,4]/2,
		durRel:e.bNext[0]
	);
	{ PlayBuf.auto(2,Song.laMer, [-7,-7].midiratio.dq.demand(Song.durs[\planets].list.parse([10,2]))) / 2.3 * EnvGen.cutoff(b.sum-2, 2)}.play(s,
		Song.carrierBus
	);
	// (instrument: \wash,freq: [1,3,5,7].df(\d,\dorian),dur:b.sum,out:p.carrierBus.index,amp:0.02,addAction:\addBefore).play;
});
P(\pad,syl:0, music: { |p b e|
	( 
		instrument:\sparkTriangle,
		freq: 21.df(\g),
		amp:0.01 * 2,
		dur: b.sum
	).play
});
P(\guiro, music: { |p b e|
	{
		var tightness = 0.9;
		// var env = DemandEnvGen.ar([1,0,4,0,2,0,4,0].dq(inf)*10,1/4!16 warpTo: e.tempoMap.quantizeDft(0.3) => _.dq(inf));
		var env = DemandEnvGen.ar([1,0,0,1,0,0,1,0,0,1,0,0].dq(inf) + 0.01,1/4!16 warpTo: e.tempoMap.quantizeDft(0.3) *.x [1-tightness/2,tightness,1-tightness/2] => _.postln => _.flat => _.dq(inf));
		Shakers.ar([2],energy:env.min(0.99).max(0.0),
			resonantFreq:SinOsc.ar(0.2).unipolar,decay:SinOsc.ar(0.13).unipolar
		)
		// => DelayN.ar(_,delaytime:b[0]/( 6 ))
		// / 20 
		/8
		* EnvGen.cutoff(b.sum,0)
		* 2

	}.play(s,2)
});
P(\bass, music: { |p b e|
	[
		dur: "q q qq q q qq q q qq ".asBeats.warpTo(e.tempoMap).q,
		// freq: [\r].q(1) ++ [1,1, -6.5, 1, 1, 4, 2.5, 2.5, -6.5].df(\d,3).q(inf)
		 freq: [\r].q(1) ++ [1,1, -6.5,].df(\d,3).q(inf),
		// freq: [\r].q(1) ++ [1,1, -3, -4, -4, -7].df(\d,3,\dorian).q(inf)
		amp: 0.1 * 2
	].pp
});
P('line',start:\As,syl:5,music: {|p b e|
	[
		freq:[4,5,6,7,11,12,13].df(\c).q,
		instrument: \stringyy,
		dur: b.drop(1).parse([1/3,1/3,1/3,1,1,1,1]).q,
		amp: 0.1 * 2
	]
	//.pp
});
P('montuno',start:\As,music: {|p b e|
	[
		freq:[1, [3,5], 1, [4,6], [3,5],1, 3,4, 5, 3].df(\d,4,\dorian).q,
		dur:b.q,
		//instrument:\defaultPiano
		instrument:\stab,
		coef:0.8,
		amp: 0.1 * 2,
		out: 3
		// out: Effect.bus( {|i| CrossoverDistortion.ar(i,amp:0.01, smooth:0.8) /2} )
	].pp
});
P('bassNote',start:\seed,syl:9,music: {|p b e|
(freq:[1].df(\g,3,\mixolydian) / [1,2],out:Effect.bus(DWGReverbC1C3.ar(_),inputChannels:2)).play;
(freq:[11,6].df(\g,3),instrument:\defaultPiano,dur:b.sum).play;
});
P.tune(\As, _ <> (instrument: \sawSynth, amp:0.04, out: 4));
["(boom) so we left our seed behind us.",[1,11,7,6,5,4,3,2,1,3,3,4].dm(\g,4,\mixolydian)].addLine;
P.still(\clear, timecode: 0.seconds, music: { |p b e|
	 e.still.( 
		wait: b.sum,
		text: ["",""],
	).sequenceText2(
			b.parse([1, 8]), [ 
			["so we left","our seed"],
			["behind","us"]
			],
	)
});
// P.tune();
P(\connecter,syl: 10, music: { |p b e| //add to next sec
	[
		freq: [ 7, 11, 12, 13 ].df('c#',[4,5]).q,
		dur: [b.drop(1)[0],e.bNext.parse( [3,4] ),1].flat.q,
		instrument: \wash,
		amp:0.07,
		freqLag: 1

	].ppm
});
P.synthV(role: \vocoder, frozen: true,
	filter: (midinote: _ - 12), 
	pbind: {|p b| [ midinote: p.tune[p.section(\behind)].list[0,1,2,3,4,5, 9, 10,11].q,dur:b.parse([1,1,1,1,1,4,1,1,1]).q ].p},
	// prepend: true,
	params: {|p b| [
	lyrics: "r so we left our seed behind + us " ,
] }, music:{|p b e|
	{
		e.playbuf
		=> p.synthVTracks.at(e.key).()
	}//.play
	;
	{ PlayBuf.auto(2,Song.laMer, [0,-2].midiratio.dq.demand(Song.durs[\planets].list.parse([10,2]))) / 14}.play(s,Song.carrierBus,addAction:\addToHead);
	p.vocodeTune.(p,b,e,e.rpp,
		verb:1,
		// amp:0.28,
		mix:0.5,
		chord:#[1,2,4],
		amp: 0.25,
		modGain: 2.5,
		width:1.03,
		verb:1,
		// echo:0,modGain: 4,
		// mix:0.5,
		att:0.3,
		durRel:1,
		chord:#[1,2,4]/2
	);
});
P(\lick,syl:4, music: { |p b e|
	[
		[
			freq: [4,3,2,1].df(\g,4,\mixolydian).q,
			dur: b.drop(1).q,
			instrument: \sparkTriangle,
			amp:0.05,
			freqLag:0.1
		].pm ,
		[
			instrument: \sparkTriangle,
			out:1,
			amp:0.03 * 2,
			freq: [4].df(\g,4),
			dur: b.drop(1).sum.q(1)
		].p
	] => Ppar(_)  => Pmul(\amp,0.5,_) => _.play
});
P('boom',start:\left,music: {|p b e|
	(
		freq:[1,-11,-21].df(\g,3),
		out: Effect.bus({|i| i * 1.5 => FreeVerb.ar(_,0.5,1) => SineShaper.ar(_,0.2,2)},inputChannels:2),
		dur:b.parse([6]).unbubble
	).play;
	(
		instrument:\cymbalsDS,amp:0.01 * 2,
		out: Effect.bus(_ * Env([0,1,1],[0.1,1]).kr(0,gate:1)),
	).play
});
P('pluck', start:\left, music: {|p b e|
	[\r,11,[11,7],[11,6],[11,5],[11,6,4],3,2,1,[7,11,11],[7,11,11],[6,11]].df(\g,5,\mixolydian)
	=> _.flop => _.do
	{|i x|
		[
			freq:i.q/2 ,
			dur: b.q,
			instrument:\pluckD,
			amp:0.06 * 2,
			out: Effect.bus({|i| FreeVerb.ar(i,0.5,0.9)  
			=> Pan2.ar(_, x.linlin(0,1,-0.9,0.9) )
			* EnvGen.cutoff(b.sum,1)
			// [x min:0.1, (1-x): min: 0.1]
			/3 })
		].pm(\pluckD).play
	}
});
P.tune(\left,_ <> [
	amp:[0,1,1,1,1,1,0,0,0,1,1,1].q/10,
	legato:[1,1,1,1,1,3,1,1,1,1,1,1].q*0.9,
	instrument:\sawSynth,
	amp:0.05 * 2
].p);

// (1..500).do{|i| Bus.new(index:i).free}
P(\chords, music: { |p b e|
	[
		freq: [\r,[2,4,5,7],[2,4,5,7],[1,3,5,11]].df(\c).q,
		dur: b.parse([9,1,1,1]).q,
		out: [
			// 0,
			p.carrierBus.index],
	].pp
});
/*MULHALL:*/[" Our studies indicate that","1 -7 -6 2 -7 -5 -4".dm('c#')].addLine;
P.still(\wideAgainMulhall, timecode: 1121.35.seconds, music: { |p b e|
	 e.still.( 
		wait: b.sum,
		text: ["our studies","indicate that"],
	)
});
P(\bassnote, music: { |p b e| //connect this
	[ 
		freq: [ 1, -7, -6, -5, -4 ].df('c#',[  5 ]).q,
		instrument: \sparkTriangle,depth: 0 ,
		dur: b.parse([1, 1, 1, 3]) ++ 1 => _.q
	].pp;
	[ 
		freq: [ 1, -7, -6, -5, -4 ].df('c#',[  5 ]).q,
		freq: [1, 2, 5].df('c#',[  4,5 ]).q,
		instrument: \sparkTriangle,depth: 0 ,
		dur: b.parse([3, 4]) ++ 1 => _.q
	].pp;
	( freq: 1.df('c#',4),coef: 0.15, instrument: \harp,depth: 0,amp:0.01, out: Effect.bus( Pan2.ar(_,0,0.8) ) ).play;
});
P.synthVs(role: \chapel, take: [ \lead, \double ],
	pbind: Song.enlarge2(0),
	params: {|p b| [
	lyrics: "our studies + indicate + + that life on our planet + earth evolved + independantly + + + + r",
	pitchTake: [ 1, 3 ]
] }, music:{|p b e|
	{
		e.playbuf
		=> p.synthVTracks.at(e.key).()
	}.play

});
P.tune();
["life on our planet, Earth, evolved independently. ","3 2 4 3 1 -5 -6 2 1 -7 -6 1 -4".dm('c#'),].addLine; 
P.still(\clear, timecode: 0.seconds, music: { |p b e|
	 e.still.( 
		wait: b.sum,
		text: ["life on our planet,","Earth"],
	).sequenceText2(
			b.parse([6]), [ 
			["evolved","independantly"],
			],
	)
});
P.synthVs(\ninezero, take: [ \lead, \double ],  params: {|p b| [
	filter: (midinote: [5, 5, 6].dm('c#'), dur: b.parse([ 6, 1, 3 ])), 
	lyrics: "Life evolved +",
	pitchTake: [ 1, 3 ]
] }, music:{|p b e|
	{
		e.playbuf
		=> p.synthVTracks.at(e.key).()
		/4
	}.play
});
P.synthVs(role: \chapel, take: [ \lead, \double ], params: {|p b| [
	lyrics: "life on our planet + Earth, evolved + independently + + + +  ",
	pitchTake: [ 1, 3 ]
] }, music:{|p b e|
	{
		e.playbuf
		=> p.synthVTracks.at(e.key).()
		* -2.dbamp
	}.play

});
// P.tune();
P(\bass, music: { |p b e|
	[
		midinote: [ 11, 7, 6, 5, 4, 2 ].dm('c#',2).stutter(2).q,
		dur: b.parse([1, 2, 2, 2, 3, 2]).stutter(2).q /2 => _.drop(1),
		ctranspose: [0, 12].q(inf),
		instrument: \sawSynth
	].pp;
	(
		lag: b.parse([10]).sum,
		freq: [-11].df('e-'),
		dur:b.parse([10,3]).last + e.bNext[0..1].sum,
		instrument: \sparkTriangle,depth:0.01
	).play
});
/*SPOCK:*/[" That would tend, however, to explain ","3 2 4 2 -7 1 2 4 6".dm(\e)].addLine;
P.still(\wideButSpockSpeaks, timecode: 1126.775.seconds, music: { |p b e|
	 e.still.( 
		wait: b.sum + 2,
		fade: 2,
		text: ["that would tend","however"],
	).sequenceText2(
			b.parse([6, 3]), [ 
			["to","explain"],
			["",""]
			],
	)
});
P(\chords, music: { |p b e|
	[
		freq: [
			\r,
			[ 2, 4, 6, 11].df(\e),
			[-7, 2, 4, 5.5].df(\e),
			[3, 5, 7, 11].df(\c,\mixolydian)
		].q,
		attack:3,
		dur: [ b.parse([2,7]), 0, 0 ].flat + [0,e.bNext.parse([2,4,6])].flat => _.q,
		instrument: \stringyy
	].ppm
});
P.synthVs(role: \spock, take: [ nil, \bg ], params: {|p b| [
	lyrics: "that would tend, however + + to explain +",
	legato: [ [0.66, 1, 0.8, 1, 1, 0.6, 1, 1, 0.8, ] ],
	lag: [ [0.08, 0,0,0,00,0,0,0 ] ],
	loudness: Env([-2,4,0,0],b.parse([1, 1, 2])),
	filter: (midinote: _ - 12), 
	pitchTake: 1 
] }, music:{|p b e|
	{
		e.playbuf
		=> p.synthVTracks.at(e.key).()
		=> HPF.ar(_,200) * -2.dbamp
	}.play

});
P(\pedalTone, music: { |p b e|
	[
		freq: [[-27,-17], [-11, -1], [-12,-2],
		// [-12.5,-2.5]
		-1
	].df(\e).q,
		dur: [ b.parse([2,7]),0 ].flat + [0 , e.bNext.parse([2, 4, 6])].flat => _.q,
		instrument: \sparkTriangle,
		depth:0.005,
		out: Effect.bus( _ * Line.kr(0,1,2))
	].pp;
	[
		freq: [-27].df(\e).q,
		lag: b[0].sum,
		// dur: [ b.sum ].q,
		dur: b.q,
		coef:0.15,
		instrument: \harp,
		amp:0.02,
		out: Effect.bus( Pan2.ar(_,0.9) ),
		att:1
	].pp
});
[" certain elements of Vulcan prehistory. ","3 2 4 2 -7 1 2.5 1 -6 -4 -5 -6".dm(\g)].addLine; 
Song.durs.filter(\Vulcan,{|i| i.drop(-1) ++ (i.last + 0.05)});
P.still(\clear, timecode: 0.seconds, music: { |p b e|
	 e.still.( 
		wait: b.sum,
		text: ["certain","elements of"],
	).sequenceText2(
			b.parse([6]), [ 
			["Vulcan","prehistory"],
			],
	)
});
P(\bassnote, syl: 5, music: { |p b e|
	(
		freq: 1.df(\g,[2,3]),
		amp:0.3,
		instrument: \stringyy
	).play
});
P.synthVs(role: \spock, take: [ nil,\lead ],params: {|p b| [
	lyrics: "certain + elements + + of Vulcan + pre history  + +",
	filter: (midinote: _ - 12), 
	lag: [ [0.05,0, 0, 0, 0, 0, 0, 0, 0, 0, 0.05, 0, 0] ],
	legato: [ [1, 1, 1, 1, 1, 0.7, 1, 0.7, 1, 1, 1, 0.5, ] ],
	pitchTake: 1
] }, music:{|p b e|
	{
		e.playbuf
		=> p.synthVTracks.at(e.key).(0.2)
		=> HPF.ar(_,200) * -2.dbamp
	}.play

});
// P.tune();
/*SARGON:*/[" In any case, I do not know. (baby) It was","5 11 5 3  7 6 5 5 6 5 4 3 4  ".dm(\d,\mixolydian)].addLine;
P.still(\wide, timecode: 1139.9.seconds, music: { |p b e|
	 e.still.( 
		wait: b.sum,
		fade: e.bNext.sum,
		text: ["in any","case"],
	).sequenceText2(
		b.parse([4, 7, 2]), [ 
			["I do not","know"],
			["it","was"],
			["",""]
			],
	)
});
Song.durs[\In].list.do(_.postln);
Song.setTempoMap(\In,"e | e e qe e e e e eq e e e e ");
P(\cymbals, syl:0, music: { |p b e|
	(
		instrument: \cymbalsDS,
		amp:0.025
	).play
});
P(\chordz, music: { |p b e|
	[
		instrument: \sawSynthSustain,
		dur: b.q,
		midinote: p.tune[e.start],
		out: p.carrierBus.index
	].ppm;
	[
		freq: [\r] ++ [[1, 3, 5].df(\d),[1,3,5].df(\c),[-3,-5,1].df(\g),[-3,-5,1].df(\a)].stutter(4) => _.q,
		dur: "e e e e e e e e e e e e e e e e e  ".asBeats.warpTo( e.tempoMap ).q,
		out: p.carrierBus.index
		
	].pp
});
P.synthV(role: \vocoder, take: \lead, frozen: true, resources:(tail: 7),
	pbind: Song.enlarge2(0),
	params: {|p b| [
	lyrics: "In any + case, I do not know - baby + It was so long ago + and the records + of our travels + were ",
	filter: (midinote: _ - 24), 
	legato: [1, 1, 1, 0.5, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 0.75 ,1, 1, 1, 1, 1, 1, 1, 1, 1, 1],
	pitchTake: 1
] }, music:{|p b e|
	// {
	// 	e.playbuf
	// 	=> p.synthVTracks.at(e.key).()
	// }.play

	p.vocodeTune.(p,b,e,e.rpp,
		verb:0.5,
		tune: p.tune[e.start].list ++ p.tune[e.start + 1].list => _.postln ,
		// enlarge: nil,
		enlarge:12,
		// amp:0.28,
		mix:0.1,
		dur:b.sum + e.bNext.sum,
		chord:#[4]/2,

		width:1.03,
		// echo:0,modGain: 4,
		// mix:0.5,
		att:0.3,
		sus:b.sum + e.bNext.sum,
		modGain:2,
		// durRel:1.5
	);

});
P(\arpeggio, music: { |p b e|
	[
		freq: [\r] ++ [11, 5, 3, 1].df(\d) ++ [1, 5, 3, 1].df(\c) ++ [13, 11, 5, 3].df(\g,4) ++ [11, 5, 3, 1].df(\a,4) => _.q,
		dur: "e e e e e e e e e e e e e e e e e".asBeats.warpTo( e.tempoMap ).q,
		instrument: \harp,
		coef: 0.15,
		amp:0.01,
		out: Effect.bus( Phaser2.ar(_,rate: 0.16),  )
	].pp
});
P('bass',start:\In,music: {|p b e|
	[
		freq: 
		[\r] ++ "1 11 1 -7 7 -7 -4 4 -4 -5 5 -5".df(\d,3,\mixolydian) =>_.q
		,
		dur: [ 0.5 ] ++ "q e e ".asBeats.dup(4) =>_.flat 
		//=> _.q,
		=>_.warpTo(e.tempoMap.quantizeWindow()) =>_.q,
		instrument:\sawSynth
	].pp
});
P('click',start:\In,music: {|p b e|
	[
		dur: ( 0.5 ).dup(48) => _.warpTo(e.tempoMap.quantizeWindow()) =>_.q,
		freq:  [ \r ] ++ 440.dup(32) => _.q,
		instrument: \hihat
	].p//p
});
["so long ago, and the records of our travels were","3 2 1 1 -7 1 3 1 -7 1 4 1 -7".dm(\d)].addLine;
// P.still(\spockSilent, timecode: 1143.7.seconds, music: { |p b e|
// 	 e.still.( 
// 		wait: b.sum,
// 		text: ["",""],
// 	)
// });
P.still(\clear, timecode: 0.seconds, music: { |p b e|
	 e.still.( 
		wait: b.sum,
		text: ["so long","ago"],
	).sequenceText2(
			b.parse([4]), [ 
			["and the records","of our travels were"],
			],
	)
});
// Song.setTempoMap(\records,"qq q e eee e e e e e e Q E E");
P(\chors, music: { |p b e|
	[
		freq: [[ 5, 11 ],[5, 7],[6, 3]].df(\d).q,
		dur: "qq qq qq".asBeats.warpTo( e.tempoMap ).q,
		instrument: \sawSynthSustain,
		out: p.carrierBus.index
	].ppm

});
Song.setTempoMap(\long,"qq q e eqe x x x x x x x xe e ");
Song.setTempoMap(\long,"qq q e eqe e e e e e e e x xe ");
P.tune(\long);
P('bass',start:\long,music: {|p b e|
	[
		// freq: [1, -7, -6, -5, 4, -2].df(\d,4).q,
		freq: [1, -7, -6, -5, -17].df(\d,4).q,
		dur: "h h he hqe ".asBeats.warpTo(e.tempoMap) ++ e.bNext[..3].sum => _.q,
	].pp
});
["(boom) lost in the cataclysm which we unleashed upon ourselves. ","-7.5 5 6.5 7.5 11 5 3 1 -7 7 6.6 4 1 -7.5 6.5 6".dm('c#',\minor),].addLine; 
P.tune();
P(\chords,syl:3, music: { |p b e|
	{
		var freq = 
		[
			[1, 3, 5, 11],
			[-7, 3, 5, 7],
			[ -6.5, 1, 4, 6.5 ],
			[ -7, -7, 4, 6.5 ],
			[ -7, 2, 4, 6 ]
		].df('c#',\minor);
		freq.dq.demand(b.drop(1).parse([4, 2, 3, 2, 1]))
		=> { |i| SinOsc.ar(i + Gendy1.arWidth(freq:1, mul:5) * [0.5, 1] => _.lag(0.5), 0, 0.01)}
		=> Splay.ar(_)
		=> SineShaper.ar(_,0.004, 9)

		* EnvGen.cutoff(b.sum-2,1.4)
	}.play
});
P.still(\clear, timecode: 0.seconds, music: { |p b e|
	 e.still.( 
		wait: b.sum,
		text: ["",""],
	).sequenceText2(
			b.parse([1, 7]), [ 
			["lost in the","cataclysm"],
			["which we unleashed","upon ourselves"]
			],
	)
});
P(\cataclysm, syl:3, music: { |p b e|
	(
		instrument: \cymbalsDS,
		amp: 0.02
	).play
});
P(\bassnote, music: { |p b e|
	[		instrument:\stringyy,
		freq: [-17.5,-11].df('c#',\minor).q,
		rate:11,
		mix:0,
		dur: 5,
		amp:[ 0.2, 0.3 ].q,
		dur: b.parse([4, 1]).q,
		freqLag:0.3

	].ppm
});
P.synthV(role: \vocoder, take: \lead, frozen: true, params: {|p b| [
	lyrics: "r lost in the cataclysm + + + which we unleashed +  upon + our selves ",
	filter: (midinote: _ - 12), 
	pitchTake: 1
] }, music:{|p b e|

	p.vocodeTune.(p,b,e,e.rpp,
		// verb:0.5,
		// tune: p.tune[e.start].list ++ p.tune[e.start + 1].list => _.postln ,
		// enlarge: nil,
		// enlarge:12,
		// amp:0.28,
		mix:0.1,
		dur:b.sum + 1,
		// chord:#[4]/2,

		width:1.03,
		// echo:0,modGain: 4,
		// mix:0.5,
		att:0.3,
		sus:b.sum ,
		modGain:2,
		chord:#[8,2]/2,
		durRel: 1.5
	);
});
/*KIRK:*/[" A war? ","1 7".dm(\a,4,\mixolydian),].addLine; 
P.still(\kirkCloseWar, timecode: 1138.316.seconds, music: { |p b e|
	 e.still.( 
		wait: b.sum,
		text: ["a","war?"],
	)
});
P.synthVs(role: \kirk, take: [ \lead, \double ], params: {|p b| [
	lyrics: "a war",
	filter: (midinote: _ - 12), 
	legato: [0.5, 0.7 ],
	pitchTake: [ 1, 3 ]
] }, music:{|p b e|
	{
		e.playbuf
		=> p.synthVTracks.at(e.key).()
	}.play

});
P('arpeggio',start:\war,syl:0,music: {|p b e|
	(freq:[-1,-3,-5,-7,1,3,5,7].df(\a,4,\mixolydian),strum:0.03).play
});
P.tune(\war);
/*SARGON:*/["A struggle for such goals and the unleashing of such ","5 6 1 6 7 4 3.5 4 5  ".dm('a-',4,\minor) ++ [11, 3.5, 7, 6].dm(\f,4,\minor)].addLine;
// P.tune();
P.still(\litStruggle, timecode: 1104.4.seconds, music: { |p b e|
	 e.still.( 
		wait: b.sum,
		fade: 1.5,
		text: ["",""],
	)
});
P.still(\clear, timecode: 0.seconds,lag: 0.01, music: { |p b e|
	 e.still.( 
		wait: b.sum,
		text: ["a struggle","for such goals"],
	).sequenceText2(
			b.parse([6, 7]), [ 
			["and the unleashing","of such"],
			["",""]
			],
	)
});
P.synthV(role: \vocoder, take: \lead,resources:(tail: 4), frozen: true,
	pbind: Song.enlarge(9),
	params: {|p b| [
		filter: (midinote: _ - 12), 
	lyrics: "A struggle + for such goals and the unleashing + + of such power + that you could not comprehend + + ",
	legato: [1, 1, 0.8, 1,      1, 0.9, 1, 1, 1, 1, 0.7, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, ],
	lag: [0,    0, 0,   b[3] /3, 0, 0,   0, 0, 0, 0, 0,   0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, ],
	pitchTake: 1
] }, music:{|p b e|
	p.vocodeTune.(p,b,e,e.rpp,
		enlarge:9,
		// verb:0.5,
		tune: p.tune[e.start].list ++ p.tune[e.start + 1].list => _.postln ,
		// enlarge: nil,
		// enlarge:12,
		// amp:0.28,
		mix:0.5,
		chord:#[1,2,4],
		dur:b.sum + e.bNext.sum +4,
		// chord:#[4]/2,

		// width:1.03,
		// echo:0,modGain: 4,
		// mix:0.5,
		att:0.3,
		sus:b.sum + e.bNext.sum ,
		modGain:2,

	);
});
// P.tune();
P(\chord, music: { |p b e|
	[
		freq: [\r, [5, 11, 13, 15], [5,7.5,13,15] ].df('b-',4,\minor).q,
		dur: b.parse([9, 1, 1]).q,
		instrument: \wash,
		amp:0.05,
		freqLag:0.1,
		out: [ p.carrierBus.index, 0
		]	].ppm
});
P('chords2',start:\struggle,music: {|p b e|
	[
		freq: [[1,3,5], [1,4,6],1,[1,4,6],[3, 5, 7],[-7,2,4]].df('a-',[3,4],\minor).q,
		dur:b.q,
		out:Effect({ |i|  SineShaper.ar(i,0.2,5) => FreeVerb.ar(_,1,0.6) * [0.6,0.6]}, out: [0, p.carrierBus.index ]).bus.index
	].pp
});
P('bass',start:\struggle,music: {|p b e|
	[
		freq:[-5, 1,-6.5,-4,].df('c#',3) ++ [1].df(\f,2) =>_.q,
		dur: b.parse([1,3,1,5, 1]).q,
		instrument:\sawSynth
	].pp
});
P(\morebass,syl:8, music: { |p b e|
	(
		instrument: \stringyy,
		freq: [-1,1].df(\f,3),
		amp:0.5
	).play
});
P.tune(\struggle, _ <> [instrument:\wash, amp:0.01].p);
["power that you could not comprehend. ","13 12 11.5 7 12 11.5 7 6 5.5 ".dm(\e,4),].addLine; 
P.still(\clear, timecode: 0.seconds, music: { |p b e|
	 e.still.( 
		wait: b.sum,
		text: ["power that you","could not comprehend"]
	)
});
P.tune();
P(\bass, music: { |p b e|
	[
		freq: [1, 3, ].df(\b,[2,3]) ++ [1].df(\c,[3,4]) =>_.q,
		// dur: b.parse( [[1, 0.5],[0.5,1]] ).q,
		dur: b.parse([4,4,1]).q

	].pp
});
P.tune( _ <> [instrument:\wash, amp:0.01].p);
P(\chords, music: { |p b e|
	[
		freq: [
			[7, 11, 13, 16],
			[7, 11, 13, 15]
		].df(\b,\mixolydian).q,
		dur: b.q,
		instrument:\stringyy
	].ppm
});
P(\chord,syl:7, music: { |p b e|
	(
		freq:[1,3,5,7].df(\c,4,\mixolydian),
		strum: 0.05,
		instrument: \sawSynth,
		dur:0.1,
		rel:4,
		att:1,
		coef: 0.3,
		out: Effect.bus( {|i| CombN.ar(i,0.4,[ 0.33, 0.371 ],5)  + [i,i] /3} )
	).play
});

///*KIRK:*/[" Then perhaps your intelligence wasn't so great, Sargon. We faced a similar crisis in our early nuclear age. We found the wisdom not to destroy ourselves. ","r",].addLine; 
///*SARGON:*/[" And we survived our primitive nuclear era, my son. But there comes to all races an ultimate crisis which you have yet to face.","r",].addLine; 
///*KIRK:*/[" I don't understand. ","r",].addLine; 

// /*SARGON:*/[" One day our minds became so powerful, we dared think of ourselves as gods. ","r",].addLine; 
["I don't understand", "3 2 1 -7 4.5/f#".dm2].addLine;
P.still(\clear, timecode: 0.seconds, music: { |p b e|
	 e.still.( 
		wait: b.sum,
		text: ["I don't","understand"],
	)
});
P.tune('t understand');
P.synthV(role: \kirk, take: \lead, params: {|p b| [
	lyrics: "I don't understand + +",
	filter: (midinote: _ - 12), 
	legato: [1, 1, 1, 1, 0.65, ],
	pitchTake: 1
] }, music:{|p b e|
	{
		e.playbuf
		=> p.synthVTracks.at(e.key).()
	}.play

});
P(\cymbal,syl: 3, music: { |p b e|
	(
		att: 0.1,
		instrument: \cymbalsDS,
		amp: 0.01
	).play
});
P(\line, music: { |p b e|
	[
		freq: [3, 2, 1, -7, -6.5, -7].df('f#').q,
		dur: b ++ e.bNext[0] => _.q,
		instrument: \sawSynthSustain
	].ppm
});
/*KIRK:*/[" You said you wanted our help. What is it you wish? ","1,2,3,5,4,3,7".dm(\f,\mixolydian) ++ "1 2 3 5 7".dm(\g,\mixolydian),].addLine; 
P(\finalNote, music: { |p b e|
	(
		lag: b.parse([11]).unbubble,
		instrument: \wash,
		freq: [ 5,7 ].df(\g,5,\mixolydian),
		amp: 0.03
	).play
});
P(\accent, music: { |p b e|
	[ 
		dur: b.parse([3,6,2]).q,
		instrument: \sawSynthSustain,
		att: 1,amp:0.02, lagTime: 2,
		// legato: [4,3,2,1,1].q,
		freq: [\r, 5,4.5 ].df(\f,[4,5],\mixolydian).q
	].ppm
});
P(\note, music: { |p b e|
	{
		VarSaw.ar( [ 1, 5, 13, 7 ].df(\f,3, \mixolydian) + [-1,1] * Env([1,1,1.midiratio],b.parse([7,3])).kr(0,gate:1), [ 0, SinOsc.ar(1) ], [ 0.2, 0.3 ] )
		* 0.1

		* Env([0,1,1,0], b.parse([3, 3, 7])).kr(2,gate:1)
		=> RHPF.ar(_,600 + SinOsc.ar([ 2.5, 2.1 ]).range(0,600),0.8)
		// * -15.dbamp
	}.play
});
P.still(\kirkHelp, timecode: 1148.4.seconds, music: { |p b e|
	 e.still.( 
		wait: b.sum,
		text: ["you said you wanted","our help"],
	).sequenceText2(
			b.parse([7]), [ 
			["what is it","you wish?"],
			],
	)
});
// P.tune();
P.synthV(role: \kirk, take: \lead, params: {|p b| [
	lyrics: "You said you wanted + our help. What is it you wish? ",
	legato: [1, 1, 1, 1, 1, 1, 0.6, 1, 1, 1, 1, 1, ],
	filter: (midinote: _ - 12), 
	pitchTake: 1
] }, music:{|p b e|
	{
		e.playbuf
		=> p.synthVTracks.at(e.key).(0.15)
	}.play

});
P(\bassnotes, music: { |p b e|
	[
		freq: [\r,7, 6].df(\f,[3,4],\mixolydian).q,
		instrument: \stringyy,
		dur: b.parse([6, 4, 2]).q,
		freqLag: 2,
		mix:0,
		out: Effect.bus({|i| i + DelayC.ar(i,0.3,SinOsc.ar(0.1).range(0.2,0.25)) },)
	].ppm;
	[
		freq: [ 11,\r,[-2,2],\r ].df(\f,3,\mixolydian).q,
		dur: b.parse([6,1,3, 2]).q,
		// sustain: b.parse([7]) ++ b[6..9].sum ++ b[7..11].sum++ b[10..11].sum => _.flat => _.q ,
		instrument: [\default,\stringyy].q(2),
		amp:[0.1,0.2].q(2)
	].pp
});
)
