
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

["The rest is only guesses. ","r" ].addLine;
[ "SCOTT: I don't like it, sir. The transporter co-ordinates preset by an alien of some sort. You could materialise inside ","r" ].addLine;
["solid rock. ",[7, 6, 6, 11, 7, 7].dm(\c) ].addLine;
P.tune('rock.');
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
[ "SPOCK: Unlikely. These co-ordinates correspond with the location of the subterranean chamber. ","r" ].addLine;
[ "KIRK: I have a feeling that they or it could destroy us just standing here if they or it wanted to. ","r" ].addLine;
[ "MULHALL: They or it? ","r" ].addLine;
[ "KIRK: Who are you? ","r" ].addLine;
[ "MULHALL: Doctor Ann Mulhall, Astro-biology.","r" ].addLine;
[ "Well, I was ordered to report here for landing party duty. ","r" ].addLine;
[ "KIRK: By whom? ","r" ].addLine;
[ "MULHALL: Strange, I'm not sure. Well, I'm not a liar, Captain. I did receive an order to report here for duty. ","r" ].addLine;
[ "SPOCK: I'm sure she did, Captain, Just as you received an order to bring me along. ","r" ].addLine;
[ "KIRK: Oh, yes. ","r" ].addLine;
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
