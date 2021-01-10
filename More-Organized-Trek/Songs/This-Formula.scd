(

Song('this formnula',[]).current;
Song.resources.quarters_(());
Song.currentSong.infrastructure=FunctionList.new.array_([
	{ 
		~synthsLoaded.isNil.if{"/Users/michael/tank/super/song-Synthdefs.scd".load};
		"/Users/michael/tank/super/808-mod.scd".load 
	}
]);
~quarters=SongArray.new(size:64);
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
["(boom) this formula -- -- will reduce the ",[11,13,13,12,11,12,11, 7,11, 12, 13].dm('d',octave:4 )].addLine;
	~quarters['this formula']= Song.parseBeats('this formula', [1,1,1/2,1/4,11/4,1/4,1/4,1/2,1/4,3/4,1/2]);
//		~clock=TempoClock.new;
//~justTheTune.('this formula');
~justTheTune.( 'formula --');
P(\drumz,'this formula',music:
	{|p b e|
		[
			"x.x.x.x.".asDrumPat(2,2,) 
			=> [dur:_,
				//instrument:\snare
				instrument:\sn_808
			]=>_ .p
			,
			"x.x..x.x".asDrumPat(2,2
			) 
			=> [dur:_,
				//instrument:\bd_808,
				//lag:-0.04,
				instrument:\kick2,
			] =>_ .p
		] => Ppar(_)
		=>_.play(~quarters['this formula'].quantizeWindow.asTempoClock)
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
			dur: [3,1, 1,2,1, 3,1, 3,1].q/2,
		].p
	=>_.play(TempoClock.newFromQuarters(~quarters[e.start].quantizeWindow));
});

( Song.resources.hatPattern="xxxx".asDrumPat(4,8)
=> [
	dur:_,
	stretch:[10,9].reverse.q(inf)/9.5,
	instrument:\hihat,
	amp:[12,5,10,5].q(inf)/100
] =>_.p 
);
P(\highHat,start:'this formula',music:{|p b e|
	p.hatPattern
	=>_.play( ~quarters[e.start].quantizeWindow.asTempoClock)
});
["(boom )heart action and the bodily ",[6, 14,13,11, 7,11,12,13,11,].dm('d',octave:4 )].addLine;
~justTheTune.('and the bodily');
~quarters['bodily']=Song.parseBeats('bodily', [1,7/4,2/4,7/4, 1/2,1/2, 2/3,2/3,2/3 ]);
P(\bassBodily,'bodily',music:
	{|p b e|
		[
			instrument:\sawSynth,
			freq: [-4,-5,-6,-7,1,1,4,4,3,3].df('d',tuning:\sept1,octave:[3,4]).q,
			dur: 
			0.5!4 ++ ( "ex x".asBeats *2 !3 ).flatten=>_.q
			,
		].p
	=>_.play(TempoClock.newFromQuarters(~quarters['bodily'].quantizeWindow),
);
});

P(\drumzBodily,'bodily',music: {|p b e|
	
	(
		"x.x.x.x.".asDrumPat(2,2) 
		=> [dur:_,instrument:\snare]=>_ .p
	)
	+=
	(
		"x.x..x.x".asDrumPat(2,2)
		=> [dur:_,
			instrument:\bd_808,
			instrument:\kick3,
			//		lag:-0.04,
		] =>_ .p
	)
	+=
		p.hatPattern
	=>_.play(~quarters[e.start]
	.quantizeWindow
//	.quantize
	.asTempoClock);
}
);
["functions to normal. ",[7,6, 12,11,7 ].dm('d',octave:4 )].addLine;
~quarters['to normal']= Song.parseBeats('to normal',[2/3, 2/3, 2/3,  1,1]);
P(\bassNormal,'to normal',music:
	{|p b e|
		[
			instrument:\sawSynth,
			freq: [6,6,5,5].df('d',tuning:\sept1,octave:[3,4]-1).q,
			dur: "ex x e e".asBeats.q*2,
		].p
	=>_.play(TempoClock.newFromQuarters(~quarters['to normal'].quantizeWindow),
);
});
P(\highHatNormal,start:'to normal',music:{|p b e|
	p.hatPattern => Pfin(16,_)
	=>_.play(~quarters[e.start].quantize.asTempoClock);
});
P(\drumzNormal,'to normal',music: {|p b e|
	(
		"x.x.x.x.".asDrumPat(2,1) 
		=> [dur:_,instrument:\snare]=>_ .p
	)
	+=
	(
		"x.x..x.x".asDrumPat(2,1)
		=> [dur:_,
			instrument:\bd_808,
			instrument:\kick3,
			//		lag:-0.04,
		] =>_ .p
	)
	=>_.play(~quarters[e.start].quantizeWindow.asTempoClock);
}
);
~justTheTune.('to normal');
["(boom) While the bodies are occupied, ",[-15,-5,-6,-7,1,2,4,3,1].dm('c')].addLine;
~justTheTune.('occupied',{|i| i.drop(1)},syl:0);
~quarters[\occupied]=Song.parseBeats('occupied',(1/3)!6 ++ ( (2/3)!3 ));
//~quarters[\occupied]

P(\chordsOccupied,start:\occupied,music:{|p b e|
	[
		freq:[[1,3,5],[1,4,6]].df('g',octave:4 ).stutter(2).q*[1,1.01],
//		out:1,
		pan:0,
		out:Effect({|i| MoogLadder.ar(i,1200,1) => EchoNone.ar(_, 0.2,  delaytime: 0.1,  decaytime: 2.0)},out:1).bus.index,
		amp:0.2,
//		out:Effect(FreeVerb.ar(_,0.51,0.5),out:1).bus.index,
		dur:"e e e e".asBeats.q*2,
	].p.trace.play(~quarters[e.start].asTempoClock)
}
);
["you will administer one injection of  ",[3,4,1,3,2,1, -7,1,2,-7,-5].dm('a',scale:\harmonicMinor)].addLine;
~justTheTune.('administer one',Pmul(\freq,0.5,_));
["ten cc's each hour.",[-7,1,-7,1,-6].dm('g',octave:4 )].addLine;
~justTheTune.('each hour');
~quarters['each hour']= Song.parse('each hour',[2,2,1]);
P(\chordsHour,start:'each hour',music:{|p b e|
	[
		midinote: [0,-2]+.t[1,3,5,7].dm('d',octave:4 ) =>_.q,
		dur:"qq q".asBeats.q,
		instrument:\sawSynthSustain,
		att:1
	].p.trace.play(~quarters[e.start].asTempoClock)
}
);
["/*CHAPEL:*/ I understand. ",[5,6,7,11].dm('a-')].addLine;
~justTheTune.('understand',Pmul(\freq,0.5,_));
~quarters[\understand]=Song.parseBeats('understand',"e x x q".asBeats);
P(\chordsUnderstand,start:\understand,music:{|p b e|
	[
		freq: [[-5,5],[-5,4],[1,3]].df('a-',octave:4 ).q,
//		instrument:\sparkTriangle,
		release:1.5,
		dur:"ex x e".asBeats.q,
		amp:0.045,
		out:[0,3],
	].pm(\sparkTriangle).play(
		~quarters[\understand]
		.asTempoClock
	)
}
);
["/*SPOCK:*/ This hypo you will code mark for Tha lassa. And ",[5,4,3,2,1,3,2,3,4,3,2,2, 2].dm('d')].addLine;
~justTheTune.('hypo you will',Pmul(\freq,0.5,_));
~quarters['hypo you will'] = Song.parseBeats('hypo you will',[1, 1,1,1,1, 1,1,3/2,1/2, 1,1,5, 1]);
P(\hypoBase,'hypo you will', music:{|p b e|
	[
		//	instrument:\pluckD,
		freq: [ \r ] ++ [ 1 ].stutter(8) ++ [ -5 ].stutter(8) 
		=> _.df('d',octave:3) =>_.q,
		amp:0.01,
	].pm(\pluckD)
	.play
	(
		~quarters['hypo you will']
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
	].p.play(~quarters['hypo you will'].asTempoClock)
}
);
["this one you will code mark for -- ",[4,3,2,1,3,3,4,3].dm('a')].addLine;
~justTheTune.('for --'
	,Pmul(\freq,0.25,_)
);
~quarters['for --'] = Song.parseBeats('for --',[1,1,1,1, 3/2,3/2,1/2,1/2]);
P(\forBase,'for --', music:{|p b e|
	[
		//	instrument:\pluckD,
		freq: [ -5 ].stutter(8) 
		=> _.df('d',octave:3) =>_.q,
		amp:0.01,
	].pm(\pluckD).play (
		~quarters['for --']
//	.quantizeWindow
	.asTempoClock)
});
["me.  /*CHAPEL:*/ Yes, sir. ",[-2,7,11].dm('c')].addLine;
~justTheTune.('Yes, sir');
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
~quarters['This one']=Song.parseBeats('This one',"q qe e e e e e e e e e e e".asBeats);
~justTheTune.('This one');
P(\baseThisOne,start:'This one',music:{|p b e|
	[
		freq:[1,2,3, 1.5,3,4,4.5,5].df('f#',scale:\minor,octave:3 ).q,
		dur:"qq qq qe e e e e e".asBeats.q,
	].p.play(~quarters[e.start].asTempoClock)
}
);
["Sargon is in his body. ",[11,5,3,2,-7,2,1].dm('d',octave:5,scale:\harmonicMinor, )].addLine;
~justTheTune.('in his body');
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
~justTheTune.('does not contain');
// TODO
["/*SPOCK:*/ No, that's correct. But since I will arrange for ",[1, 1.5,1,1].dm('b-')++[4,2,4, 3,2,1,-7].dm('f#')].addLine;
~justTheTune.('correct');
P(\correctBase,start:'correct',music:{|p b e|
	( freq:1.df('b-',octave:2), ).play
}
);
~quarters['correct'] = Song.parseBeats('correct',"qq Q E qe e e e e Q E".asBeats);

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
	=>_.play(~quarters[e.start].asTempoClock)
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
~justTheTune.('administer each');
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
~justTheTune.('notice');
["/*CHAPEL:*/ Without the same formula, Captain Kirk will die. ",[3,1,2,3,5,4,3,1,2,3,5,6].dm('g',scale:\whole,)].addLine;
~justTheTune.('Without');
["(He touches her fosehead.) /*SPOCK:*/ What were you saying? ",[3,  3,4,2,4,3].dm('c')].addLine;
~justTheTune.('touches her');
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
~justTheTune.('I was.',{|i| Pbindf(i,\amp,[1,0,1,1,0]/10=>_.q)});
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
~justTheTune.('something');
["gotten what it was. ",[3,4,5,6,7].dm('b')].addLine;
~justTheTune.('gotten');
["/*SPOCK:*/ Yes. Well, you were about to say that ",[5,12, 5,6,7,11,6, 12, 11,].dm('d',scale:\major)].addLine;
~justTheTune.('about to say');
["you watched me prepare the formula and fill each of the hypos. ",[13,13,12,13,14,15,14,13,12,11,7,5,6,7,12,11].dm('d',octave:5 )].addLine;
~justTheTune.('me prepare');
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
~justTheTune.('that was it');
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
~justTheTune.('inform');
["properly filled for each patient. ",[5,4,3,2,-6,-7,2,1].dm('f#')].addLine;
~justTheTune.('properly');

["/*SPOCK:*/ Very good. ",[5,5,11].dm('b-',octave:4)].addLine;
~justTheTune.('Very');
["You see, Sargon would not let me keep this body",[5,6,12,11,5,6,11,12, 13,14,14,13].dm('b-',octave:4 )].addLine;
~justTheTune.('keep this');
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
["It is therefore necessary for", [3,4,5,6,5,4,3,4,2].dm('f',octave:5)].addLine;
~justTheTune.('necessary');
["you to kill your captain ", [11,7,12,11,7,6].dm('e-',octave:5)].addLine;
~justTheTune.('kill');
["so that Sargon will die with him.","r"].addLine

)
