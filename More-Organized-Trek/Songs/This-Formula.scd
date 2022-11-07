(
s.waitForBoot{ 
	Song('this formnula',[]).current;
	Song.currentSong.infrastructure=FunctionList.new.array_([
		{ 
			~synthsLoaded.isNil.if{"/Users/michael/tank/super/song-Synthdefs.scd".load};
			"/Users/michael/tank/super/808-mod.scd".load 
		}
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
	[" /*[Pharmacy] SPOCK:*/ Now.  ","r"].addLine;
	["(boom) this formula -- -- will reduce the ", [11,13,13,12,11,12,11, 7,11, 12, 13].dm('d',octave:4 )].addLine;
	Song.quarters['this formula']= Song.parseBeats('this formula', [1,1,1/2,1/4,11/4,1/4,1/4,1/2,1/4,3/4,1/2]);
	Song.setTempoMap('this formula', [1,1,1/2,1/4,11/4,1/4,1/4,1/2,1/4,3/4,1/2]);
	//		~clock=TempoClock.new;
	//P.tune('this formula');
	P.tune( 'formula --',Pset(\dur, Song.tempoMap[ 'this for' ] .beats.warpTo(Song.tempoMap[ 'this for' ].quantizeDft).q,_));
	P(\drumz,'this formula',music:
		{|p b e|
			var map = e.tempoMap.quantizeDft(0.78).postln;
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
	P(\bassFormula,'this formula',music:
		{|p b e|
			[
				//			out: Effect.new(
				//				{|i| i +
				//					TwoTube.ar(i,0.5,0.8,9000,12100,mul:0.4)
				//				}
				//			).bus.index,
				instrument:\sawSynth,
				freq:
				[1,-7,-6,-5].collect{|i x| i.dup([2,3,2,2][x])}.flat
			.df('d',tuning:\sept1,octave:[3,4]).q
				,
				dur: [3,1, 1,2,1, 3,1, 3,1]/2=>_.warpTo(e.tempoMap.quantizeDft) =>_.q,
			].pp
			//=>_.play(TempoClock.newFromQuarters(Song.quarters[e.start].quantizeWindow));
		});

( Song.resources.hatPattern={ | map | 
		(1/4).dup(64)
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
			e.tempoMap.quantizeDft(0.78)
		)
		.play
		//.patternpairs[1].list.postln
		//=>_.play( Song.quarters[e.start].quantizeWindow.asTempoClock)
	});
	["(boom )heart action and the bodily ",[6, 14,13,11, 7,11,12,13,11,].dm('d',octave:4 )].addLine;
	Song.setTempoMap('and the bodily', [1,7/4,2/4,7/4, 1/2,1/2, 2/3,2/3,2/3 ]);
	//P.tune('and the bodily');

	P.tune( 'the bodily',Pset(\dur, Song.tempoMap[ 'the bodily' ] .beats.warpTo(Song.tempoMap[ 'the bodily' ].quantizeDft).q,_));
	P(\highHat,start:'and the bodil',music:{|p b e|
		p.hatPattern.(
			e.tempoMap.quantizeDft(0.78)
		)
		.play
		//.patternpairs[1].list.postln
		//=>_.play( Song.quarters[e.start].quantizeWindow.asTempoClock)
	});
	P(\drumz,'and the bodily',music:
		{|p b e|
			var map = e.tempoMap.quantizeDft(0.78).postln;
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
	P(\bassBodily,'bodily',music:
		{|p b e|
			[
				instrument:\sawSynth,
				freq: [-4,-5,-6,-7,1,1,4,4,3,3].df('d',tuning:\sept1,octave:[3,4]).q,
				dur: 
				0.5!4 ++ ( "ex x".asBeats *2 !3 ).flatten=>_.q
				,
			].p
			=>_.play(TempoClock.newFromQuarters(Song.quarters['bodily'].quantizeWindow),
		);
	});

["functions to normal. ",[7,6, 12,11,7 ].dm('d',octave:4 )].addLine;
	P(\drumz,'functions to normal',music:
		{|p b e|
			var map = e.tempoMap.quantizeDft(0.78).postln;
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
P(\bassNormal,'to normal',music:
	{|p b e|
		[
			instrument:\sawSynth,
			freq: [6,6,5,5].df('d',tuning:\sept1,octave:[3,4]-1).q,
			dur: "ex x e e".asBeats.warpTo(e.tempoMap.quantizeDft).q*2,
		].pp
		//=>_.play(TempoClock.newFromQuarters(Song.quarters['to normal'].quantizeWindow),
	//);
});
P(\highHatNormal,start:'to normal',music:{|p b e|
	p.hatPattern.(e.tempoMap.quantizeDft)// => Pfin(8,_)
	=>_.play
	//=>_.play(Song.quarters[e.start].quantize.asTempoClock);
});
P.tune('to normal');
["(boom) While the bodies are occupied, ",[-15,-5,-6,-7,1,2,4,3,1].dm('c')].addLine;
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
P.tune('administer one',Pmul(\freq,0.5,_));
["ten cc's each hour.",[-7,1,-7,1,-6].dm('g',octave:4 )].addLine;
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
P.tune('understand',Pmul(\freq,0.5,_));
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
P.tune('hypo you will',Pmul(\freq,0.5,_));
Song.quarters['hypo you will'] = Song.parseBeats('hypo you will',[1, 1,1,1,1, 1,1,3/2,1/2, 1,1,5, 1]);
P(\hypoBase,'hypo you will', music:{|p b e|
	[
		//	instrument:\pluckD,
		freq: [ \r ] ++ [ 1 ].stutter(8) ++ [ -5 ].stutter(8) 
		=> _.df('d',octave:3) =>_.q,
		amp:0.01,
	].pm(\pluckD)
	.play
	(
		Song.quarters['hypo you will']
		//	.quantizeWindow
		.asTempoClock
	)
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
P.tune('for --'
	,Pmul(\freq,0.25,_)
);
Song.quarters['for --'] = Song.parseBeats('for --',[1,1,1,1, 3/2,3/2,1/2,1/2]);
P(\forBase,'for --', music:{|p b e|
	[
		//	instrument:\pluckD,
		freq: [ -5 ].stutter(8) 
		=> _.df('d',octave:3) =>_.q,
		amp:0.01,
	].pm(\pluckD).play (
		Song.quarters['for --']
		//	.quantizeWindow
		.asTempoClock)
	});
	["me.  /*CHAPEL:*/ Yes, sir. ",[-2,7,11].dm('c')].addLine;
	P.tune('Yes, sir');
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
Song.quarters['This one']=Song.parseBeats('This one',"q qe e e e e e e e e e e e".asBeats);
P.tune('This one');
P(\baseThisOne,start:'This one',music:{|p b e|
	[
		freq:[1,2,3, 1.5,3,4,4.5,5].df('f#',scale:\minor,octave:3 ).q,
		dur:"qq qq qe e e e e e".asBeats.q,
	].p.play(Song.quarters[e.start].asTempoClock)
}
);
["Sargon is in his body. ",[11,5,3,2,-7,2,1].dm('d',octave:5,scale:\harmonicMinor, )].addLine;
P.tune('in his body');
P(\strumBody,start:'in his body',lag:-0.03,music:{|p b e|
	(
		freq:[1,3,5,11,13,15,21].df('d',octave:4,scale:\minor, ),
		amp:0.06,
		strum:0.06	
	).play
}

);
["/*CHAPEL:*/ This hypo does not contain the same formula. ",[5,4,3,1,2,3,5,4,5].dm('g',scale:\whole)++[7,5,1.5].dm('g',scale:\mixolydian)].addLine;
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
P.tune('correct');
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
P.tune('administer each');
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
P.tune('notice');
["/*CHAPEL:*/ Without the same formula, Captain Kirk will die. ",[3,1,2,3,5,4,3,1,2,3,5,6].dm('g',scale:\whole,)].addLine;
P.tune('Without');
["(He touches her fosehead.) /*SPOCK:*/ What were you saying? ",[3,  3,4,2,4,3].dm('c')].addLine;
P.tune('touches her');
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
P.tune('I was.',{|i| Pbindf(i,\amp,[1,0,1,1,0]/10=>_.q)});
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
P.tune('something');
["gotten what it was. ",[3,4,5,6,7].dm('b')].addLine;
P.tune('gotten');
["/*SPOCK:*/ Yes. Well, you were about to say that ",[5,12, 5,6,7,11,6, 12, 11,].dm('d',scale:\major)].addLine;
P.tune('about to say');
["you watched me prepare the formula and fill each of the hypos. ",[13,13,12,13,14,15,14,13,12,11,7,5,6,7,12,11].dm('d',octave:5 )].addLine;
P.tune('me prepare');
P(\harmonyWatched,start:'me prepare',music:
	{|p b e|
		[
			instrument:\sawSynth,
			freq:[11,11,7,11,12,13,12,11,7,6,5,3,4,5,6,6].df('d',octave:[4,5],).q,
			out: 1,
			dur:b.q,
		].pp
	}
);
["/*CHAPEL:*/ Yes, that, that was it. ",[7, 7, 12,11,3].dm('f#')].addLine;
P.tune('that was it');
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
P.tune('inform');
["properly filled for each patient. ",[5,4,3,2,-6,-7,2,1].dm('f#')].addLine;
P.tune('properly');

["/*SPOCK:*/ Very good. ",[5,5,11].dm('b-',octave:4)].addLine;
P.tune('Very');
P(\chord,start:'Very',music:{|p, b, e|
	[
		//		freq:[[2,4],[1,3]].df('b-',octave:3 ).q,
		freq:[5,4,1].df('b-',octave:3 ).q,
		dur:b.parse([2/3,[1/3,1],1]).q,

	].pp
}

);
["You see, Sargon would not let me keep this body",[5,6,12,11,5,6,11,12, 13,14,14,13].dm('b-',octave:4 )].addLine;
//P.tune('keep this');
SynthDef(\whiteNoise,{WhiteNoise.ar(\amp.kr(0.1))=>LPF.ar(_,2000)* Env.cutoff(1).kr(2,gate:\gate.kr(1)) => Out.ar(\out.kr(0),_)}).add;
P.tune('keep this');
P(\vocoder,start:'keep this',music:{|p b e|
	\b++b =>_.postln;
	Song.pbind['keep this']
	=>Pbindf(_,\legato,1,
		//		\instrument,\sawSynth,
	)
	=>Pmul(\freq,[0.25, 0.5 ],_)
	+= [amp:0.0002, instrument: \whiteNoise, dur:[ 2 ].q(inf) ].p
	//	=>{|i| VocoderPattern(i,'keep this body').play }
	=> VocoderPattern(_,'keep this body',
		warp:0,
		durs:Song.durs['keep this'].list.asArray,
		dry:0.0,
		//		inputEffect:(EchoNone.ar(_,0.4,0.3,1.5))
		//		fftSize:4096,
		out:1
	)
}.value
);
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
//P.tune('necessary');
P(\vocoder,start:'necessary',music:{|p b e|
	Song.pbind['necessary']
	=>Pbindf(_,\legato,1,
		//		\instrument,\sawSynth,
	)
	=>Pmul(\freq,[0.25, 0.5 ],_)
	+= [amp:0.0002, instrument: \whiteNoise, dur:[ 2 ].q(inf) ].p
	=>VocoderPattern(_, 'necessary',
		out:1,
		warp:1,
		ry:0.0,
		//		inputEffect:(EchoNone.ar(_,0.4,0.3,1.5))
	)
}// .value
);
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
P.tune('kill');
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
//MUTEDP(\sargonLowerBase,start:'with him',music:{|p b e|
//MUTED[
//MUTEDfreq: [\r,5.5,6,7,11].df('b-',octave:[ 1,2 ] ).q,
//MUTEDamp:0.2,
//MUTEDdur:b.parse([2,2,2,1,1]).q,
//MUTED].pp
//MUTED
//MUTED}
//MUTED);
// This item is the version from reaper which is probably better 
P(\sargonBaseline,start:'with him',music:{|p b e|
	[
		freq: [\r,4.5,12,4].df('f',octave:[2,3] ).q,
		legato:1.1,
		[ \instrument,\amp,\mix,\release ]:[ \stringyy,0.15 ,0,4 ],

		dur:b.parse([2,2,2,2]).q,
	].pp
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
