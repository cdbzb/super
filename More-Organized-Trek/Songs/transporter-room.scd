
(
Song(\transporter,[]).current;
[ "MCCOY: Jim, why no briefing on this? I'd at least like to kno-o-ow what we're getting into. ",[3,4,2,5,3,1, -7, -6, -7, 1, 2, 3, 4,5, 4, 3, 4, 5, 6, 6, -7].dm(\g) ].addLine;
P.tune('kno-o-ow');//, Pset(\lag,[0,0,0,0,0,0,0,0,0,0,0,0,0.06, 0,0,0,0,0,0,0.06].q(2),_));
Song.setTempoMap('kno-o-ow',
	"q e e  e e e ee x x E E E e x x   x x x x  ex x"
);
P(\myClick,start:'kno-o-ow',music:{|p b e| 
	[
		dur: "q q q q q q q q e x x".asBeats.warpTo(e.tempoMap).q,
		freq:[3, 4, 5, 1, [ -17, -7 ], [-16, -6 ], [ -12, -22, -6, 2, 4 ], [ -11,-1 ], [-17, -7, 2,4,6 ], -7,-6,-5].df(\g, 4).q,
		legato:1.5,
		amp:0.15,
		strum:[0,0,0,0,0,0,0.05,0,0.05].q(inf),
		lag:(-1)*[0,0,0,0,0,0,0.05,0,0.05].q(inf),
		instrument:\sawSynth
	].pp;
});
[ "KIRK: Easy, Bones. ","7 5 3".dm(\c,5,\mixolydian)].addLine;
P.tune(\Easy);
["As long as you know there's somethi--ng down there, you know as much as we do."," 1 2 3 3 2  -5 -6 -7 1 2 1 -4 4 3 2 1 -7 2 1".dm(\c) ].addLine;
Song.setTempoMap('down there',"e e e eee ee e e x x eee e ee ee eee x xe e eee");
P(\bass,start:'down there',music:{|p b e| 
	[
		freq: [\r, -5, 5, -5, \r, -6, 6, 5, 4, -4, -4.5, -5, 5, -7, 1].df(\c,3).q,
		dur: "eee q q q q q e e q qe e q e e q  ".asBeats.warpTo(e.tempoMap).q,
		instrument:\sawSynth
	].pp;
});
P(\click,start:'down there',music:{|p b e| 
	[
	    dur: ([ 1.5 ] ++ 1.dup(12) =>_.warpTo(e.tempoMap)) =>_.q,
	    freq: 
	    [ \r  ]++ 1.dup(12) => _.flat
	    => _.q,
	    instrument: \hat_808
	].pp;
});
P.tune('down there', Pset(\dev, [1,1,1,1,1,1,1,1,1,1,1,\r].q(2),_));

["The rest is only guesses. ","5 11 5 3 5 7 11".dm(\f,5,\harmonicMinor) ].addLine;
P.tune(\guesses);
[ "SCOTT: I don't like it, sir. The trans-- ","1 -7 3 1 -5".dm(\c,5,\mixolydian)++" 1 -7 ".dm(\d,5,\mixolydian) ].addLine;
P.tune('like it');
[ "porter co-ordinates preset by an","3 1 -6.5 -5 -5.5 -5 -7 4 3 4".dm(\d)].addLine;
["(boom boom) alien of some sort. ","-1 -1 3 2 1".dm(\e) ++ "3 2 -5".dm(\c,5,\minor)].addLine;
P.tune('some sort');
P.tune('co-ordinates');
["You could materiali--se inside ","4 3 2 4 3 2 1.5 2 1.5 2".dm(\b,4) ].addLine;
P.tune(\material);
["solid rock. ",[7, 6, 6, 11, 7, 7].dm(\c) ].addLine;
//P.tune('rock.');
//Song.setTempoMap('rock.', "q ex xqq q ex xqq");
Song.setTempoMap('rock.', "q ex xqq q ex xqq");
P(\bass,start:'rock.',music:{|p b e| 
	[
		freq: [[1, 11],[1,11],11, -7,1,-7,1, 5,6] => {|i| [ i.df(\c,3).q, i.df(\d,3,scale:\mixolydian).q ].q},
		dur: 
		"e ee e x x x x e e".asBeats!2 => _.flat  => _.warpTo(Song.tempoMap['rock.']) => _.q,
		instrument:\sawSynth
		
		//.warpTo(e.tempoMap).q
	].pp
});
[ "MCCOY: Inside solid rock? ","r" ].addLine;
[ "SPOCK: Unlikely. These co-ordinates correspond with the location of the","5 11 5  7 5 4 3 2 6 4 3 2 1 -7 4 2 -6 -5".dm('c#')].addLine;
P.tune(\correspond);
P(\line,start:\correspond,music:{|p b e| 
	[
		freq: [\r, 1, 7, 6, 5].df('c#',3).q,
		dur: b.parse([1,2,5,6,4,]).q,
		instrument:\sawSynthSustain,
		att: 1,
		legato: [4,4,1,1,1].q
	].pp;
});
[" (boom) subterranean chamber. ", "-1 1 2 3 4 3 2 1".dm(\d,5,\minor) ].addLine;
P.tune(\subterranean);
P(\bassnote,start:\subterranean,music:{|p b e| 
	(
		instrument:\stringyy,
		freq: [-1,1].df(\d),
		dur: b.sum
	).play
});
[ "KIRK: I have a feeling that they or it could destroy us just standing here if they or it wanted to. ","3.5 4 5 7 6 5".dm(\c,5,\minor) ++ "3 1 2 -7 1 4 3 1 6 5 3 1 3 1 2 1 -7 -5".dm('a-') ].addLine;
P.tune(\feeling);
[ "MULHALL: They or it? "," 3 1 5.5".dm(\c) ].addLine;
P.tune('it?');
[ "KIRK: Who are you? (boom) ","3 1 7 -6".dm(\f,5,\mixolydian) ].addLine;
P.tune('you?', Pfin(3,_));
P(\chord,start:'you?',syl:2,music:{|p b e| 
	[\stringyy,\sawSynthSustain].do
	{ |i| (
	      	(
	      		freq: [1,3,5,11].df(\d,[2,4,5]),
	      		instrument:i,
	      		dur: b+p.durs[e.start+1].list[0..5].sum,
			att: 4,
			amp:0.05,
			rel:8
	      	).play
	      ) } 
});
[ "MULHALL: Doctor Ann Mulhall, Astro-biology.",[7, 11, 3, 5, 4.5, 6, 6.5, 2, 4, 3, -5].dm(\d,6) ].addLine;
P.tune(\biology);
[ "Well, I was ordered to report here for landing party duty. ", [3, 2, 3, 6, 5.5].dm('c#',6) ++ [4, 5, 6, 7, 5, 11, 5, 4, 3, 2, 1].dm(\c,6) ].addLine;
P.tune(\landing);
[ "KIRK: By whom? ",[7, 13].dm(\c,4,\mixolydian) ].addLine;
P.tune('whom?');
[ "MULHALL: Strange, I'm not sure. Well, I'm not a liar, Captain. i"," 2 1 2 4 2 3 4 5 6 4 3 2".dm('e-',6,\whole) ++ [5].dm(\d,6)].addLine; 
P.tune('Strange');
["did receive an order to report here for duty. "," 11 5 4 3 7 6 4 2 6 5 4 3 1".dm(\d,6,\mixolydian) ].addLine;
P.tune(\receive);
[ "SPOCK: I'm sure she did, Captain, Just as you received an order to bring me along. ","r" ].addLine;
[ "KIRK: Oh, yes. ","5 11".dm(\g) ].addLine;
[ "MCCOY: Let's get back to this solid rock business...","r" ].addLine;
["Just how much rock are we going to go through? ","r" ].addLine;
[ "SPOCK: Approximately one hundred twelve point three seven miles, Doctor. ","r" ].addLine;
[ "MCCOY: Miles? Are you joking? ","r" ].addLine;
[ "KIRK: No, we're not. Let's go. ","r" ].addLine;
[ "SARGON [OC]: Please stand ready. I will operate your controls. ","r" ].addLine;
//[ "KIRK: Doctor, if you prefer to stay behind? ","r" ].addLine;
//[ "MCCOY: No. No, if I'd be useful, as long as you're going down, I might as well take a medical look at whatever this is. ","r" ].addLine;
//(The landing party and two guards gather on the pads, Scotty stands sulking with arms crossed as the transporter activates, and just sends the four officers somewhere.)
)
