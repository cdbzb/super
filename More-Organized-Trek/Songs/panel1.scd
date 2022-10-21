(
s.waitForBoot{ 
Song(\panel1,[]).current
;
"~/tank/super/More-Organized-Trek/Songs/boilerplate.scd".standardizePath.load;
//(A panel slides back to reveal a much larger area, with rock walls, and a glowing sphere elegantly poised on an angled support.) 
/*SARGON: (the glowing sphere)*/[" Welcome. I am Sargon. ","r",].addLine; 
/*SPOCK:*/[" Sargon, would it harm you if I ","4 5 7 11 12 6 5 4".dm(\d)].addLine; 
P.tune('harm');
/*SARGON:*/[" You may use your tricorder, Mister Spock.","r"].addLine;
["Your readings will show","r"].addLine;
["energy but no substance. ","3 2 3 2 1 -7 1 -7 -6 -5 4 3 3 1 2 -7".dm(\e)].addLine;

P.tune(\substance);
P('bassline',start:\substance,music: {|p b e|
	[
		freq:[1, 5, 2, 4].stutter(2).df(\e,3).q,
		dur:[3,1] => _.dup(4) => _.flat=> _.warpTo(b) => _.q
	].pp
});
P('chord',start:\energy,music: {|p b e|
	var one = [1,3,5], six = [-6,3,1],two = [2,4,6], four = [-4,-6,1], five = [-5,-7,2];
	//progression = [one, six, four, five];
	var progression = [one, five, two, four];
	[
		freq: progression.stutter(2).df(\e).q,
		dur: "h h h h h h h h".asBeats.warpTo(b).q,
		instrument:\sawSynth,amp:0.04

	].pp
});
["Sealed in this receptacle is the ",[5, 4,3,2,3,4,3,-5,-6,-7].dm(\c,6)].addLine;
P.rpp('vox',start:\Sealed,lag:-1,music: {|p b e|
	{ Song.laMer => PlayBuf.ar(2,_,rate: [5,0].midiratio.dq.demand(b.parse([5,3])+[1,0]).poll)/2 * 0.1=> Out.ar(Song.carrierBus,_) }.play;
	p.vocodeTune.(p,b,e,
		modGain:9,
		chord:#[1,0.5,2,8],
		echo:0.5,
		mix:0.8
	)
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
		instrument:\wash
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
["essence of my mind. ",[7,7,6,7,6,5,6, 5].dm(\g)].addLine; 
Song.durs[\essence]=Song.durs[\essence].list.dup(2).flat[(0..15)].q(); //only 15
P('cymbal',start:\essence,music: {|p b e|
	(
		instrument:\cymbalsDS,
		amp:0.02
	).play
});
Song.setTempoMap(\essence,"q qe ee e e e qqe e");
P(\click,start:\essence,music: { |p b e|
	[
		dur:1.dup(8).warpTo(e.tempoMap
			.quantizeDft
		).q(2),
		instrument:\hihat
	].pp
});
P.tune(\essence,_ => {|i| [i,Pmul(\freq,midiratio(2),i)].q});
P(\chord,start:\essence,music: { |p b e|
	[
		freq:[ [1,3,5,7], [ 1,3,4,6 ] ].df(\g).q,
		instrument: \stringyy,
		dur: "qqqq qqqq".asBeats.warpTo(e.tempoMap).q
	].p
	=> {|i| [i,Pmul(\freq,midiratio(2),i)].q}
	=> _.play
});
P(\bass,start:\essence,music: { |p b e|
	[
		freq:[1,-7,-4,-3].df(\g,[3,4]).q,
		dur: "qq qq qq qq".asBeats.warpTo(e.tempoMap).q

	].p
	=> {|i| [i,Pmul(\freq,midiratio(-10),i)].q}
	=> _.play
});
["my mind outtro",[1, 11,7,6,6,5,6,7,7,6,5,5 ].dm(\b,\mixolydian) ].addLine;
Song.setTempoMap(\outtro, "q qe ee e qq q q q qe ee e q" );
P.tune(\outtro);
P('bass',start:\outtro,music: {|p b e|
	
[ [1, -7, -4, -3, -5, -4, -1],[2,3,2,2, 2,2, 1] ].flop.collect({ |i| i[0].dup(i[1]) }).flat .df(\b,\mixolydian)
=> {|i| 
	[
		freq: i.q/[8,4],
		dur: "qe e| e ee e| qe e| q q| qe e| qe e| q".asBeats.warpTo(1!16=>_.warpTo(e .tempoMap.quantizeDft)).q
	].pp
}
});

P('chords',start:\outtro,music: {|p b e|
	
	[
		freq:[ [1,3,5,11], [ -7,3,5,7 ], [-6,1, 4,6],[-5,5],[-6,6],[2,5,7],[1,4,6],5,[1,3,5] ].df(\b,\mixolydian).q,
		instrument: \stringyy,
		dur: "qq qq qq q q qqe ee e q".asBeats.warpTo(e.tempoMap).q
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
		rest:[\r,0,0,0,0,0,0].q
	].pp;
	[
		dur: "e eqe ee e qq e ee e e eqe ee e qq ".asBeats-[0.01,0,0,0,0,0,0,0,0,0] =>_.warpTo(e.tempoMap
			.quantizeDft
		//.quantizeWindow
		)=>_.q,
		vol:0.08,
		instrument: \kick_gentle
	].pp
});
/*SPOCK:*/[" Pure energy. Matter without form. ","r",].addLine; 
P('arpeggio',start:\Pure,music: {|p b e|
	[-1,-3,-5,-7,2,4,6,11, 13,15,17,22,17,15,13,11].dm	 
		 => _.q(1)
		 => {|i| [midinote:i,ctranspose:[0,-2].stutter(32).q(2),dur:0.1,lagTime:0].pm(\sawSynthSustain) => Pn(_,3) => _.play}

	
});
/*KIRK:*/[" Impossible. ","r",].addLine; 
/*MCCOY:*/[" But you once had a body of some type? ","r",].addLine; 
/*SARGON:*/[" A body much as yours, my children, although our minds were infinitely greater. ","-5 1 2 2 1 3".dm(\g) ++ "4 3 2 -6 -7 1 ".dm('a-') ++ "11 7 12 11 7 6 6 5".dm(\e)].addLine; 
P.tune(\much);
P.tune('much ', { |i| Pmul(\freq,0.5,i) => Pbindf(_,\instrument, \sawSynthSustain,\amp,0.04)});

P('dyad',start:\much,syl:17,music: {|p b e|
	(
		freq: [ -1,1, 3 ].df(\a),
		instrument:\sawSynthSustain,
		att:1.5,
		amp:0.05,
		rel:3
	).play
});
P('chords',start:\much,syl:5,music: {|p b e|
	v = VoiceLeading(
		[
			[ 4,  3,  \_, 2 ],
			[ 1,  1,  -7, \_ ],
			[ -6, -5, \_, \_ ]
		],
		b.drop(1).parse([1, 0.66,0.34,1  ])
	).df('a-').p
	=> {|i| i<> (instrument: \visual_pad,amp:0.2) => _.play; i<>(instrument:\harp, amp:0.03) => _.play}
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
P.tune('(infinitely)', Pmul(\freq, [1,0.5],_));
/*KIRK:*/[" That's twice you've referred to us as my children. ","1 6 2 3 2 3 7 6 6 7.5 2".dm(\f,\mixolydian) ].addLine; 
P.tune(\That);

/*SARGON:*/[" Because it is possible you are our descendants, Captain Kirk. ","1 3 5 7 12 7 5 3 ".dm(\f,4) ++ "1 3 5 7 12 11 13 11 7 6".dm(\g,4)].addLine;
P.tune(\Because,_ <> [instrument:\defaultPiano].p);
["(boom) Six thousand centuries ago, our vessels were ","-1 3 3 3 3 2 2 1 2 2 3 -4".dm('a-',\minor) ++ "11 5 6 3".dm(\c,5)].addLine;
Song.setTempoMap(\Six,"e e e e e x e x e x x");
P('dmx',start:\Six,music: {|p b e|
	[
		"....x..x....x... .....x.",\snare,\amp,Pseg([0.05,0.05,0.02],b.parse([12,3]).q),
		"x.......x.x..... x......",\kick_gentle,\vol,0.1,
	].dmx(4)
	=> Ppar(_) => Pfindur(b.sum,_)
	=> _.play(clock:TempoClock.newFromQuarters(1!4=>_.warpTo(e.tempoMap)))
});
P('chords',start:\Six,music: {|p b e|
	[
		freq:[ [5,11],[4,7],[4,1] ].df('a-',4,\minor).q,
		att: 2,
		rel:[6,6,5].q,
		amp:[1,1,0.4].q/10 /2,
		dur: b.parse([4,7,1]) - [0.05,-0.05,0] => _.q,
		instrument:\sawSynthSustain
	].pm(\sawSynthSustain).play
});
P.tune(\Six, Pset(\amp, Pfunc({ |e|(e.midinote < -5.dm('a-')).if{0}{0.1}}), _ ));
P.tune('x th', { |i| Pbindf(i, \amp,[1,0,0,0,0,0,0,0,0,0,0,0,1,1,1,1].q/15, \instrument, \defaultPiano) => Pmul (\freq,0.5,_)});
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
		"x..",\kick_gentle,\vol,\amp,0.02,
		"x..",\cymbalsDS,\amp,0.008
	].dmx
	=> Ppar(_)=> Pfin(3,_) => _.play
});
P.tune(\colonising,Pbindf(_,\amp,[1,1,1,1,1,1,1,1,0,0,0].q/10,\instrument,\defaultPiano));
P('bassnote',start:\colonising,music: {|p b e|
	[
		freq:[1,2,4,5,6,6.5 ].df('e-',4,\mixolydian).q, 
		//freq:[[-6],  [-1,-5,1] ].df('f#',4).q, 
		out: Effect.bus(DWGReverbC1C3.ar(_,mix:0.3)) ,
		dur: b.parse([1,1,1,1,1,3]).q
	].p.play;
});

["just as your own starships have ",[1,4,7,6,6,5].dm(\e,\mixolydian) ++ [1].dm('a-')].addLine;
P.tune(\just);
P('line',start:\just,music: {|p b e|
	[
		freq: [1,4,7,6,5,5.5].df(\e,\mixolydian).q * [1,0.5],
		dur: b.parse([1,1,1,2,2,1]) + [0,0,0,0,0,0.1] => _.q,
		instrument: \stringyy,
		freqLag: [1,1,1,1,10,10]/20=>_.q
	].pm(\stringyy).play
});
P('bass',start:\just,music: {|p b e|
	
	[
		freq:[1].df('e',[4,  3 ]).q,
		dur: b.parse([4]).q,
		instrument:\defaultPiano
	].pp
});
["now begun to explore that",[2,5,3,2,1,7,6].dm('a-',\mixolydian)].addLine;
P.tune(\begun);
P('bass',start:\begun,music: {|p b e|
	[
		freq:[1,7].df('a-',[4,  3 ],\mixolydian).q,
		dur: b.parse([5,2]).q,
		instrument:\defaultPiano
	].pp
});
[" vastness... ",[6,5].dm('a-')].addLine;// illustrate the dots
P.tune(\vastness);
P('bassNote',start:\vastness,music: {|p b e|
(freq:[-7].df(\b,3,\mixolydian) / [1,2],out:Effect.bus(DWGReverbC1C3.ar(_))).play;
(freq:[11,5].df(\b,3),instrument:\defaultPiano,dur:b.sum).play
});
["As you now leave your own seed on distant planets, ",[1,3,1,4,3,1,3,4,5,3,7,6].dm(\d,\dorian)].addLine;
P('line',start:\As,syl:5,music: {|p b e|
	[
		freq:[4,5,6,7,11,12,13].df(\c).q,
		instrument: \stringyy,
		dur: b.drop(1).parse([1/3,1/3,1/3,1,1,1,1]).q
	]
	//.pp
});
P('montuno',start:\As,music: {|p b e|
	[
		freq:[1, [3,5], 1, [4,6], [3,5],1, 3,4, 5, 3].df(\d,4,\dorian).q,
		dur:b.q,
		//instrument:\defaultPiano
		instrument:\default
	].pp
});
P('bassNote',start:\seed,syl:9,music: {|p b e|
(freq:[1].df(\g,3,\mixolydian) / [1,2],out:Effect.bus(DWGReverbC1C3.ar(_))).play;
(freq:[11,6].df(\g,3),instrument:\defaultPiano,dur:b.sum).play
});
P.tune(\As);
["(boom) so we left our seed behind us.",[1,11,7,6,5,4,3,2,1,3,3,4].dm(\g,4,\mixolydian)].addLine; 

P('boom',start:\left,music: {|p b e|
	(
		freq:[1,-11,-21].df(\g,3),
		out: Effect.bus({|i| i * 1.5 => FreeVerb.ar(_,0.5,1) => SineShaper.ar(_,0.2,2)},inputChannels:2),
		dur:b.parse([6]).unbubble
	).play;
	(
		instrument:\cymbalsDS,amp:0.01,
		out: Effect.bus(_ * Env([0,1,1],[0.1,1]).kr(0,gate:1))
	).play
});
P('chords', start:\left, music: {|p b e|
	[\r,11,[11,7],[11,6],[11,5],[11,6,4],3,2,1,[7,11,11],[7,11,11],[6,11]].df(\g,5,\mixolydian)
	=> _.flop => _.do
	{|i x|
		[
			freq:i.q/2 ,
			dur: b.q,
			instrument:\pluckD,
			amp:0.06,
			out: Effect.bus({|i| FreeVerb.ar(i,0.5,0.9) * [x, (1-x)] /3 })
		].pm(\pluckD).play
	}
});
P.tune(\left,_ <> [amp:[0,1,1,1,1,1,0,0,0,1,1,1].q/10, legato:[1,1,1,1,1,3,1,1,1,1,1,1].q*0.9].p);

///*MULHALL:*/[" Our studies indicate that life on our planet, Earth, evolved independently. ","r",].addLine; 
/*SPOCK:*/[" That would tend, however, to explain certain elements of Vulcan prehistory. ","r",[5]].addLine; 

/*SARGON:*/[" In any case, I do not know. (baby) It was","5 11 5 3  7 6 5 5 6 5 4 3 4  ".dm(\d,\mixolydian)].addLine;
Song.durs[\In].list.do(_.postln);
Song.setTempoMap(\In,"e | e e qe e e e e eq e e e e ");
P.tune(\In);
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
Song.setTempoMap(\long,"qq q e eqe x x x x x x x xe e ");
P.tune(\long);
P('bass',start:\long,music: {|p b e|
	[
		freq: [1, -7, -6, -5, -4, -2].df(\d,4).q,
		dur: "h h h h ".asBeats.warpTo(e.tempoMap).q,
	].pp
});
["(boom) lost in the cataclysm which we unleashed upon ourselves. ","-7.5 5 6.5 7.5 11 5 3 1 -7 7 6.6 4 1 -7.5 6.5 6".dm('c#',\minor),].addLine; 
P.tune(\cataclysm);
/*KIRK:*/[" A war? ","1 7".dm(\a,4,\mixolydian),].addLine; 
P('arpeggio',start:\war,syl:0,music: {|p b e|
	(freq:[-1,-3,-5,-7,1,3,5,7].df(\a,4,\mixolydian),strum:0.03).play
});
P.tune(\war);
/*SARGON:*/["A struggle for such goals and the unleashing of such ","5 6 1 6 5 5 4".dm('a-',4,\minor)].addLine;
P('chords',start:\struggle,music: {|p b e|
	[
		freq: [[1,3,5], [1,4,6],1,[1,4,6],[1,3,5],[-7,2,5],4].df('a-',[3,4],\minor).q,
		dur:b.q,
		out:Effect({ |i|  SineShaper.ar(i,0.2,5) => FreeVerb.ar(_,1,0.6) * [0.6,0.6]}).bus.index
	].pp
});
P('bass',start:\struggle,music: {|p b e|
	[
		freq:[-5, 1,-5,-4].df('c#',3).q,
		dur: b.parse([1,3,1,2]).q,
		instrument:\sawSynth
	].pp
});
P.tune(\struggle);
["power that you could not comprehend. ","r",].addLine; 

///*KIRK:*/[" Then perhaps your intelligence wasn't so great, Sargon. We faced a similar crisis in our early nuclear age. We found the wisdom not to destroy ourselves. ","r",].addLine; 
///*SARGON:*/[" And we survived our primitive nuclear era, my son. But there comes to all races an ultimate crisis which you have yet to face.","r",].addLine; 
///*KIRK:*/[" I don't understand. ","r",].addLine; 

/*SARGON:*/[" One day our minds became so powerful, we dared think of ourselves as gods. ","r",].addLine; 
/*KIRK:*/[" You said you wanted our help. What is it you wish? ","r",].addLine; 
})
