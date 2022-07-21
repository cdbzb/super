(
s.waitForBoot{ Song(\chamber1,[]).current;
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
Pdefn(\lower,7.df.bubble.q(inf)); ///NOW WHAT?
( Song.trillStart = { |lowerNoteDegree p b e octave=5 amp=0.03|
	Song.trillFreq=lowerNoteDegree;
	3.do{
		[
			freq:Pswitch1([ Pdefn(\lower),11.df],[0,1].q(inf)),
			dur: Pwhite(0.05,0.16,inf),
			legato:Prand([0.8,1.1],inf),
			pan:(-1).rrand(1.0),
			amp:amp*3,
			out: 
			Effect({|i| i =>FreeVerb.ar(_,0.8,0.8)}).bus.index// * Env.linen(0,[9,8].sum,4).kr(2,gate:1) },inputChannels:2).bus.index

		].pm(\default) //=> 
		//Pfindur(b.sum,_) 
		=> _.play
	}
};
);
( Song.trillFunc={|freq, time|
	Pdefn(\lower, Penv([Song.trillFreq,freq,freq],[ time, inf ]));
	Song.trillFreq=freq;
};
);
(
Song.triller = { 
	VarSaw.ar( LFPulse.ar(
		LFBrownNoise1.kr(1).range(5.5,7)
	).range(\lower.kr(7.df,Rand(1,3)),\higher.kr(11.df)
	),0,0.5.rand, 0.05 )
	=> Pan2.ar(_,Rand(-1,1.0))
	=> LPF.ar(_,8000)
	//=> TwoTube.ar(_, k:0.01, loss:0.997, d1length:[333,456], d2length:[543,611], mul:1.0, add:0.0)
	=> { |i| DWGReverbC1C3.ar(i, len:100, c1:1, c3:10, mix:0.1, coefs:nil, perm:nil, doprime:0) => Pan2.ar(_,0.9)+i}
	* \amp.kr(0.1)
}.asSynthDef.add.name;
Song.trillSynthFunc = {|note| (1..3).collect{Synth(Song.triller,[\lower,note.df]).register}};
Song.changeTrill = { |note|
	( try{ Song.trillSynth[0].isRunning }==true ).if{
		fork{ Song.trillSynth.do( { |i| i.set(\lower,note.df);0.4.rand.wait} )}
	}{Song.trillSynth = Song.trillSynthFunc.(note)}
};
);
P(\trill,start:\Atmos,music:{|p b e| 
	Song.trillSynth = Song.trillSynthFunc.(7)
});


["A fraction richer in oxygen than usual for us, but otherwise normal. "," 3 4 5 7 11 6 13 12 5 6 12 11.5 6, 4.5 5.5 4 5 6 7 12 11".dm(\c)].addLine;
P.tune(\oxygen,{|i| Pmul(\freq,[1,0.5],i) => Pset(\legato,4,_) });
["SPOCK: This vault was constructed about a half a million years ago.", "5 7 6 5 4 3 2 3 4 6 5 4 3 2 1".dm(\c,5,\mixolydian)].addLine;
P.tune(\vault);
P(\trill,start:\vault,music:{|p b e| 
	p.changeTrill.(6.5)
});
["About the same time the planet surface was destroyed, if our sensor readings are accurate. ","5 6 7 11 3".dm(\f,4,\minor) ++ "6 7 11 13 12 11 7 6".dm('f#',4) ++ [ 1,2,3,4,-5,4,3,2 ].dm(\d,5,\diminished)].addLine;
P.tune(\surface);
P(\bass,start:\surface,music:{|p b e| 
	[
		freq: 
		\r.bubble ++ [1,-7].df('a-',3,\mixolydian) => _.flat => _.q,
		dur: b.parse([4,4,5]).q,
		instrument:\sawSynthSustain,
		att:2,
		amp:0.07
	].pp;
});
["KIRK:(boom) Composition of walls? ","-4 4 5 4 3 4 7".dm(\c)].addLine;
P.tune(\Composition,Pdrop(1,_),syl:0);
P(\triller,start:\Composition,music:{|p b e| 
	p.changeTrill.(6);
});
["SPOCK: They're an alloy or substance completely unknown to me.","5 6 11 6 5 11.5 6 4 12 11.5 12 12 13 11.5 6".dm('e-',4)].addLine;
P.tune(\alloy);
P(\triller,start:\alloy,music:{|p b e| 
	p.changeTrill.(6.5,2, p,b/0.8,e);
});
["Much stronger and harder than-- ","2 6 5 4 3 7 6 5 4".dm('c#',5)].addLine;
P.tune(\harder);
P(\bass,start:\harder,music:{|p b e| 
	[
		freq: "2 5 1 5".df('c#',[3,4]).q,
		dur: b.parse([1,2,2,4]).q
	].pp

});
["anything I've measured before. ","3 2 1 -7 -6 -5 -4 1 2 ".dm('b-',5,\mixolydian)].addLine;
P.tune(\measured);
Song.setTempoMap(\measured, 
	"e e ee|q e | e x x x xeq".asBeats
);
P(\crash,start:\measured,music:{|p b e| 
	(
		instrument:\cymbalsDS,
		amp:0.05,
		out: Effect.new(Decimator.ar(_,20000),  out: 0,  inputChannels: 1,  target: nil).bus.index
	).play
});
P(\measured,start:\measured,music:{|p b e| 
	[
		instrument:\hihat,
		dur: 1.dup(6)=>_.warpTo(e.tempoMap) => _.q
	].p//p;
});
P(\bass,start:\measured,music:{|p b e| 
	[
		freq: "1 3 4  ".df('f',4,\mixolydian) ++ "1 3 4".df('e-',4,\mixolydian) =>_.q * [1,3/2],
		dur: 
		//"qe ex xq  |ex x q".asBeats.warpTo(Song.tempoMap[\measured]).reject{ |i| i>1024 }
		[ 1.675, 0.838, 0.989, 0.686,	0.345,	 1.388 ]
		+ [0,     0,     0,     (0.25-0.188) + 0.05, -0.7 * (0.25-0.188), 0]
		=> _.warpTo(e.tempoMap)=>_.q,
		out:Effect( { |i| SineShaper.ar(i,0.02).tanh !2 *0.6 },inputChannels:4  ).bus.index
	].pp;
	[
		freq: "1 3 4  ".df('b-',3,\mixolydian) ++ "1 3 4".df('a-',3,\mixolydian) =>_.q * [1,3/2],
		dur: 
		//"qe ex xq  |ex x q".asBeats.warpTo(Song.tempoMap[\measured]).reject{ |i| i>1024 }
		[ 1.675, 0.838, 0.989, 0.686,	0.345,	 1.388 ]
		+ [0,     0,     0,     (0.25-0.188) + 0.05, -0.7 * (0.25-0.188), 0]
		=> _.warpTo(e.tempoMap)=>_.q,
		out:Effect( { |i| SineShaper.ar(i,0.02).tanh !2 *0.6 },inputChannels:4  ).bus.index
	].pp

});
["MULHALL: All readings are off the scale, Captain. (ooh) "," 6 5 4 3 2 1 7 6 5 4.5".dm(\d,5,\mixolydian)].addLine;
Song.setTempoMap(\scale,"q Q Q Qq Q E q e e q".asBeats);
P(\chords,start:\scale,music:{|p b e| 
	[
		instrument:\pluckDVerb,
		freq: [[1,3],[1,3], -7,1,1,1].df(\d,5,\mixolydian).q,
		//dur:b.parse([1,3]).q
		dur: "q qq x x x xq".asBeats.warpTo(e.tempoMap).q,
		amp:0.03
	].pp
});
P.tune(\scale, { |i| Pmul(\freq,[1,2],i).fin(9)  } );
P(\triller,start:\scale,syl:8,music:{|p b e| 
	p.changeTrill.(5.5,p,b,e,octave:4);
	(
		instrument:\stringyy,
		attack:5,
		freq:[1,3].df('a-',[4,5]),
		dur:b.sum+e.bNext.sum,
		amp:0.2
	).play
});
["MCCOY: The air seems fresh. It must be re-circulated somehow. ","4 3 2 5 ".dm(\c) ++ "4 5 6 7 6 5 4 2 4 3.5".dm(\c,5,\minor)].addLine;
P(\triller,start:\circulated, music:{ |p b e|
	p.changeTrill.(5.5,p,b,e,octave:4);
});
P(\chord,start:\circulated,music:{|p b e| 
	[
		freq:"16 15 14 13 12 11 5.5 4 5.5 11 12 14 16 21".df(\c,3).q,
		dur:b.q
	].pp;
	[
		freq:"1 1 1 1".df(\c,4).q,
		dur:b.q
	].pp;
});
P.tune(\circulated);
["KIRK: Is that for us, or does it need fresh air? ","1 2 3 5 4 5 6 4 3 1.5 ".dm(\g,4,\whole)].addLine;
P.tune('Is that for us');
P(\pad,start:'fresh air',music:{|p b e| 
	(
		freq: [-1,1,3,5].df(\g,5,\whole),
		instrument: \wash,
		att: 3,
		rel:7,
		amp:0.03
	).play;
	fork{
		b.parse([6]).unbubble.wait;
		(
			freq:[1,11].df(\f,4),
			instrument:\sawSynthSustain,
			att:5,
			rel:7,
			dur: b.parse([6,4]).tail.unbubble,
			amp:0.03
		).play
	}
});
["(door opens and...)","f#"].addLine;
P(\door,start:\opens,music:{|p b e| 

	(instrument:\stringyy,dur:b.sum,amp:0.4,freq:[-1,-11].df('f#'),attack:5).play;

});
P(\crunch,start:\opens,music: { |p b e|

	{
		SinOsc.ar(
			0,
			LFBrownNoise2.ar(
				Env([100,2000,2000,100],[4,b-8,6],\sin).kr(2,gate:1)
			), 
			0.1
		) 
		=> {|i| i + BPF.ar(i, freq:[-1,-11].df('f#'), rq:0.15)}

	}.play
});
["I am Sargon!","1 2 1 -7 -7".dm('b',5,\harmonicMinor)].addLine;
P.tune(\Sargon);
P(\chords,start:\Sargon,music: { |p b e|
	[
		freq: [[1, 2, 1, -7, -7],[11, 12, 11, 7, 7], 3, 5].flop.df(\b,\harmonicMinor) *.t [0.5,1] => _.q,
		dur: b.q,
		out: Effect( TwoTube.ar(_, k:0.01, loss:0.98, d1length:666, d2length:[ 412, 513 ], mul:1.0, add:0.0), inputChannels:4 ).bus.index
	].pp
});
}
)
