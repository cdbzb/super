
(
Song('this formnula',[]).current;
Song.resources.quarters_(());
Song.infrastructure=FunctionList.new.array_([

		~synthsLoaded.isNil.if{"/Users/michael/tank/super/song-Synthdefs.scd".load};
]);
//This Formula (REAPER?) 
[" /*[Pharmacy] SPOCK:*/ Now.  ","r"].addLine;
["(boom) this formula -- -- will reduce the ",[11,13,13,12,11,12,11, 7,11, 12, 13].dm('d',octave:4 )].addLine;
P(\drumz,'this formula',music:
{|p b|
	//p.quarters.put('this formula',p.parseBeats('this formula',
		//[1,1,1/2,1/4,1/4+2+1/2, 1/4,1/4]));
	[
	"x.x.x.x.".asDrumPat(4,4) => [dur:_,instrument:\snare]=>_ .p,
	"x.x..x.x".asDrumPat(4,4) => [dur:_,instrument:\kick2]=>_ .pp
	] => Ppar(_) => Pmul(\dur,p.quarters.at('this formula')).play
}
);
~justTheTune.('formula --');
["(boom )heart action and the bodily ",[6, 14,13,11, 7,11,12,13,11,].dm('d',octave:4 )].addLine;
~justTheTune.('and the bodily');
["functions to normal. ",[7,6, 2,11,7 ].dm('d',octave:4 )].addLine;
~justTheTune.('to normal');
["(boom) While the bodies are occupied, ","r"].addLine;
["you will administer one injection of ten cc's each hour. ","r"].addLine;
["/*CHAPEL:*/ I understand. ","r"].addLine;
["/*SPOCK:*/ This hypo you will code mark for Tha lassa. And ",[5,4,3,2,1,3,2,3,4,3,2,2].dm('d')].addLine;
~justTheTune.('hypo you will');
["this one you will code mark for -- ",[5,4,3,2,1,3,3,4,3].dm('a')].addLine;
~justTheTune.('for --');
["me.  /*CHAPEL:*/ Yes, sir. ","r"].addLine;
["/*SPOCK:*/ This one you will administer to Captain Kirk while ","r"].addLine;
["Sargon is in his body. ","r"].addLine;
["/*CHAPEL:*/ This hypo does not contain the same formula. ","r"].addLine;
["/*SPOCK:*/ No, that's correct. But since I will arrange for ","r"].addLine;
["you to administer each of the injections, ","r"].addLine;
["no one else will notice. ","r"].addLine;
["/*CHAPEL:*/ Without the same formula, Captain Kirk will die. ","r"].addLine;
["(He touches her forehead.) /*SPOCK:*/ What were you saying? ",[3,  3,4,2,4,3].dm('c')].addLine;
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
		freq:[11,11,7,11,12,13,12,11,7,6,5,3,4,5,6,6].df('d').q,
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
["I will inform Doctor McCoy that each is ",[1,-5,1,2 ,3,1,3,4, 5,4,3,5,4,3,2,-6,-7,2,1].dm('f#')].addLine;
~justTheTune.('inform');
["properly filled for each patient. ","r"].addLine;
["/*SPOCK:*/ Very good. ","r"].addLine;
["You see, Sargon ","r"].addLine;
["would not permit me ","r"].addLine;
["to keep this body. ","r"].addLine;
["It is therefore necessary for you to kill your captain ","r"].addLine;
["so that Sargon will die with him.","r"].addLine;
)
