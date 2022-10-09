(
s.waitForBoot{ 
Song(\panel1,[]).current;
//(A panel slides back to reveal a much larger area, with rock walls, and a glowing sphere elegantly poised on an angled support.) 
/*SARGON: (the glowing sphere)*/[" Welcome. I am Sargon. ","r",].addLine; 
/*SPOCK:*/[" Sargon, would it harm you if I ","r",].addLine; 
/*SARGON:*/[" You may use your tricorder, Mister Spock.","r"].addLine;
["Your readings will show energy but no substance. ","r"].addLine;
["Sealed in this receptacle is the essence of my mind. ","r",].addLine; 
/*SPOCK:*/[" Pure energy. Matter without form. ","r",].addLine; 
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
P.tune(\Six, Pset(\amp, Pfunc({ |e|(e.midinote < -5.dm('a-')).if{0}{0.1}}), _ ));
P('bass',start:\Six,music: {|p b e|
	[
		freq:[1,-7,-4].df('a-',3,\minor).q,
		dur: b.parse([4,7,1]).q
	].pp
});

["colonising this galaxy . . . ",[1,2,4,5,2,5.5,5,-7,-5.5,-5,-17].dm('e-')].addLine;
P.tune(\colonising,Pset(\amp,[1,1,1,1,1,1,1,1,0,0,0].q/10,_));

["just as your own starships have ",[1,4,7,6,6,5].dm(\e,\mixolydian) ++ [1].dm('a-')].addLine;
P.tune(\just);
["now begun to explore that",[2,5,3,2,1,7,6].dm('a-',4,\mixolydian)].addLine;
P.tune(\begun);
[" vastness... ",[6,5].dm('a-',4)].addLine;// illustrate the dots
P.tune(\vastness);
P('bassNote',start:\vastness,music: {|p b e|
(freq:[-7].df(\b,3,\mixolydian) / [1,2],out:Effect.bus(DWGReverbC1C3.ar(_))).play;
(freq:[11,5].df(\b,3),instrument:\defaultPiano,dur:b.sum).play
});
["As you now leave your own seed on distant planets, ",[1,3,1,4,3,1,3,4,5,3,7,6].dm(\d,\dorian)].addLine;
P('montuno',start:\As,music: {|p b e|
	[
		freq:[1, [3,5], 1, [4,6], [3,5],1, 3, 4, 5, 3].df(\d,4,\dorian).q,
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
P.tune(\left);

///*MULHALL:*/[" Our studies indicate that life on our planet, Earth, evolved independently. ","r",].addLine; 
///*SPOCK:*/[" That would tend, however, to explain certain elements of Vulcan prehistory. ","r",].addLine; 

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
