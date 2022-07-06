(
Song(\chamber1,[]).current;
//[ Chamber ] 
["SPOCK: Captain, the security guards. ","r"].addLine;
["KIRK: Kirk here. ","r"].addLine;
["SCOTT [OC]: Can you read me, Captain? ","r"].addLine;
["KIRK: Yes, Scotty, and I shouldn't be able to this deep inside the planet, but perhaps this has been arranged for us, too. Is the security guard up there?","r"].addLine;
//[ Transporter Room ]
["SCOTT: They're fine. They Just didn't dematerialise.","r"].addLine;
//[ Chamber ]
["SCOTT [OC]: I don't like it, sir. ","r"].addLine;
["KIRK: No problem yet. Maintain alert. Kirk out. ","r"].addLine;
["MULHALL: Atmosphere report, Captain. ",[11,7,5,4,3,2,3].dm(\b,5,\mixolydian)].addLine;
P.tune(\Atmosphere, {|i| Pmul(\freq,[1,0.5],i) => Pset(\legato,4,_) });
( Song.trillFunc = {|lowerNoteDegree p b e|
	3.do{
		[
			freq:[lowerNoteDegree,11].df(\c).q(inf),
			dur: Pwhite(0.05,0.16,inf),
			legato:Prand([0.8,1.1],inf),
			pan:(-1).rrand(1.0),
			out: Effect({|i| i * Env.linen(0,b.sum,4).kr(2,gate:1) },inputChannels:2).bus.index
		].pm(\default).play
	}
};
);
P(\trill,start:\Atmos,music:{|p b e| 
	p.trillFunc.(7,p,b,e)
});
["A fraction richer in oxygen than usual for us, but otherwise normal. "," 3 4 5 7 11 6 13 12 5 6 12 11.5 7".dm(\c)].addLine;
P.tune(\oxygen,{|i| Pmul(\freq,[1,0.5],i) => Pset(\legato,4,_) });
["SPOCK: This vault was constructed about a half a million years ago.", "5 7 6 5 4 3 2 3 4 6 5 4 3 2 1".dm(\c,5,\mixolydian)].addLine;
P.tune(\vault);
P(\trill,start:\vault,music:{|p b e| 
	p.trillFunc.(6.5,p,b,e)
});
["About the same time the planet surface was destroyed, if our sensor readings are accurate. ","5 6 7 11 3".dm(\f,5,\minor) ++ "6 7 11 13 12 11 7 6".dm('f#',5) ++ [ 1,2,4,5,2,3,4,1 ].dm(\d,5,\minor)].addLine;
P.tune(\surface);
["KIRK: Composition of walls? ","r"].addLine;
["SPOCK: They're an alloy or substance completely unknown to me.","5 6 11 6 5 11.5 6 4 12 11.5 12 12 13 11.5 6".dm('e-',4)].addLine;
P.tune(\alloy);
["Much stronger and harder than-- ","2 6 5 4 3 7 6 5 4".dm('c#',5)].addLine;
P.tune(\harder);
P(\bass,start:\harder,music:{|p b e| 
	[
		freq: "2 5 1 5".df('c#',[3,4]).q,
		dur: b.parse([1,2,2,4]).q
	].pp
	
});
["anything I've measured before. ","3 2 1 -7 -6 -5 -4 1 2 ".dm('b-',5,\mixolydian)].addLine;
Song.setTempoMap(\measured, "E E qE e E E E x xee".asBeats);
P(\bass,start:\measured,music:{|p b e| 
	[
		freq: "1 1 3 4 4 ".df('b-',3,\mixolydian) ++ "1 1 3 4".df('a-',3,\mixolydian) =>_.q,
		dur: "q e e q q    q e e qq".asBeats.warpTo(e.tempoMap).q
	].pp
	
});
P.tune(\measured);
["MULHALL: All readings are off the scale, Captain. ","r"].addLine;
["MCCOY: The air seems fresh. It must be re-circulated somehow. ","4 3 2 5 ".dm(\c) ++ "4 5 6 7 6 5 4 2 4 3.5".dm(\c,5,\minor)].addLine;
P.tune(\circulated);
P(\triller,start:\circulated,music:{|p b e| 
	p.trillFunc.(5.5,p,b,e)
});
["KIRK: Is that for us, or does it need fresh air? ","1 2 3 5 4 5 6 4 3 1.5 ".dm(\g,4,\whole)].addLine;
P.tune('Is that for us');
["(door opens and...)","r",[10]].addLine;
P(\door,start:\opens,music:{|p b e| 
	
	(instrument:\stringyy,dur:b.sum,amp:0.4,freq:[-1,-11].df('f#'),attack:5).play
});

)
