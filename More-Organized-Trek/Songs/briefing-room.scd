

//Briefing Room
(
s.waitForBoot { 
	Song(\briefing,[]).current;

[ "SCOTT: You're going to what?","r" ].addLine;
[ "Are they all right in the head, Doctor? ","r" ].addLine;
[ "MCCOY: No comment. ","r" ].addLine;
[ "KIRK: A simple transference. Their minds and ours. ","r" ].addLine;
[ "MCCOY: Quite simple. Happens every day. ","r" ].addLine;
[ "KIRK: Scotty, I need your approval, too. Since you'll","r" ].addLine;
[ "work with them, furnishing them all they need to make the android robots. ","r" ].addLine;
[ "You won't be working with them, you'll be working with us, our bodies.","r" ].addLine;
[ "They'll be inside us, and we'll be ...","r" ].addLine;
[ "MCCOY: It all seems rather indecent to me. ","r" ].addLine;
[ "MULHALL: I'm not so certain of that, Doctor. It is scientifically fascinating. ","r" ].addLine;
[ "SPOCK: Once inside their mechanical bodies, engineer, they can leave this planet, travel back with us.","r" ].addLine;
[ "With their knowledge, mankind could leap ahead ten thousand years. ","r" ].addLine;
[ "KIRK: Bones, they'll show us medical advances,","r" ].addLine;
[ "miracles you never dreamed possible.","r" ].addLine;
[ "Scotty, engineering advances.","r" ].addLine;
P(\test,start:\engine,music:{|p b e| 
	{
		RecEnv("20220515_092222", length:4, durs:[1,1,1,1]).playbuf.().lag(0.1)  * Saw.ar(400 * [1,2.5,4.5,1.135,6,12])
	}.play
});
[ "Vessels this size with engines the size of walnuts. ","r" ].addLine;
[ "SCOTT: Ach! You're joking. ","r" ].addLine;
[ "SPOCK: No, he's not. ","r" ].addLine;
[ "MCCOY: They're giants, and we're insects beside them. ","r" ].addLine;
[ "They could destroy us without meaning to. ","r" ].addLine;
[ "And all he wants is the body of our captain and our second in command, too. Coincidence? ","r" ].addLine;
[ "KIRK: They selected us as the most compatible bodies. ","1 2 3 4 5 4 3 7 11 6 5 4 6 5".dm(\d,5,\mixolydian) ].addLine;
//// add a boom before "Most"
P.tune(\selected);
P(\bass,start:\selected,music:{|p b e| 
	[
		freq: [1, 5, -7, -5, -6, -6.5, -4, 2, ].df(\d,[3,4]).q,
		dur: b.parse([ 2/3, [1/3,1], 2, 1, 2, 2, 3, 2  ]).q
	].pp
	
});
P(\chords,start:\selected,syl:6,music:{|p b e| 
	[		
		midinote: 
		[ 
			"3 5 11".dm(\c), "2 5 7".dm(\c),"1 3 6".dm(\d)  ].q
		,
		dur: b.drop(1).parse([2,3,2]).q, 
	out: Effect(FreeVerb.ar(_,0.6,[0.9, 1 ])).bus.index,
	strum:0.054
].pp
});
[ "MCCOY:(boom boom boom boom) What's your attitude on that, Doctor? ", [ -1, -1, -17, -17, -5, 3, -7, 1, -7, -5, 3, 2, 1 ].dm(\a,5,\mixolydian) ].addLine;
P.tune(\attitude);
// ["MULHALL: Well, if we all agree, I'm willing to host Thalassa's mind.","r"].addLine;
//[" ( boom x 7 ) I'm a scientist.  ( boom x 7 ) and I'm","3 4 6 5 7 3 4 11 12 13 14 13 5 3 4 6 5 7 3 4 5 15  ".dm(\b)].addLine;
[" ( boom x 7 ) I'm a scientist.  ( boom x 7 ) and I'm","3 4 6 5 7 3 4 11 7 11 12 11 3 3 4 6 5 7 3 4 5 15  ".dm(\b)].addLine;
Song.setQuarters(\scientist,"q q q q qqqq q q q e e ee e eqq q q q q qqqq q q q q".asBeats);
P.click(\scientist);
P.tune(\scientist);
P(\jank,start:\scientist,music:{|p b e| 
	
	[
		freq: [\r,7, 11, 7].df(\b,[2,3]).q,
		dur: "qqqq qqqqqqqq qqqqqqqq qqqq".asBeats.warpTo(Song.quarters[ \scientist ].list).q ,
		amp:0.4,
		coef:0.8,
		del:0.7,
		smooth:0.25,
		instrument:\pluckD,
		out: Effect(
			(CombN.ar(_,1,(t.tempo).reciprocal/1,4)
			+Gain.ar(_,1!2))
			*0.1*0.4
			//* Env.linen(0,1.3,1, 0.05).kr(0,gate:1)
		).bus.index
	].pp
});
P(\lead,start:\scientist,music:{ |p b e|
MegaBind(
		[
			[3,  4,  6,  5,  7,  \r, \r, \r, \r, \r] .dup(2).flat,
			[\r, \r, \r, \r, \r, 3,  4,  6,  5,  11].dup(2).flat
		].df(\b,3),
		p.quarters[e.start].list.parse([1,1,1,1,4].dup(3).flat),
		[ 
			lag: { 0.5.dup(8)
			.put(0,0)
			.dq }
		],
		{|i|
		Saw.ar( i.freqSeq.lag( i.lag.demand(i.dur)) ,0.1 )	
		*( Env.asr(0.1, 1, 2).kr(0,gate: i.gateSeq)
		   + Env.perc(0.01, 0.23).kr(0,gate: i.trigSeq * i.gateSeq)
		)
		=> ( CombC.ar(_,1,
			//envelope of delay mod
			Env([0, 0, 1, 1], i.dur.parse([4],2)).kr(gate:1)
			* SinOsc.kr(2).range(-0.002,0.002)+0.2,
			10
		) *0.4 + Gain.ar(_,0.8) 
	)	},
		{|i|
			Splay.ar(i).distort
			=> Mix.ar(_) => Pan2.ar(_,0)
		}
	).play
});
[" willing I'm willin I'm willing", "14 13 11 13 12 5 14 13 ".dm(\b)].addLine;
Song.setQuarters('willin ', "qe eqe e qe eqe e qe eqe  ");
//P.click('willin ');
P.tune(\willing);
Song.mindKey = 'f#';
["to host Thalassa's mind",[4,3,5,4,3,7, 2, 3, 4,5, 6].dm( Song.mindKey, 5, \mixolydian)].addLine;
P.tune('to host');
P(\chords,start:'to host',music:{|p b e| 
	[
		freq: [\r, [-6,1],-2, [-15, 2, 4, 7], [-1, 1, 4, 6]  ].df(p.mindKey, 5, \mixolydian).q,
		dur: b.parse([1,2,2,5,1]).q,
		instrument:\sawSynthSustain,
		strum:[0,0,0,0.05, 0.05].q

	].pp;
});

["The opportunity is an extraordinary one ","-1 3 3 3 3 2 2 1 2 3 5 4.5 2 1 -7.5".dm('f#',5,\minor)].addLine;//p14
Song.setQuarters(\extraordinary,"e x xe x xe xqe xe xe xe xe".asBeats)	;
P(\bass,start:\extraordinary,music:{|p b e| 
	[
		freq: [11, 7, 6.5, 6].df('f#', 2).q,
		dur: p.quarters[e.start].list.parse([2,2,2,2]).q,
		legato: [1,1,1,3].q
	].pp
});
P.tune(\extraordinary);
//P.click(\extraordinary);
Song.setQuarters(\extraordinary, "e x xe x xe x xqe x xe x xe x xe x xe");
[" for experimentation, observation. ","2 3 4 5 -6 1 1 -7 5 5 4 3 3 2  1".dm('c#')].addLine;//p14ngyy
P.tune(\experimentation);
["SCOTT: A starship engine the size of a walnut? Thats impossible! "," 2 3 1 -7 -6 -5.5 4 3 4 5 -7".dm(\a) ++ "5 5 11 5 1".dm('a-',5)].addLine;
P.tune(\impossible);
P(\chord,start:\impossible,syl:0,music:{|p b e| 
	(
		freq:[1,3,5.5,7].df(\f),
		instrument:\stringyy
	).play
});
P(\bass,start:\impossible,music:{|p b e| 
	[
		freq: [\r] ++ "5 4 3 2".df(\a,3) ++ "5 1".df('a-',3) =>_.q,
		dur: b.parse([1,5,3,2,0.75,[0.25,1],2]).q
	].pp
});
//["But I don't suppose there'd be any harm in looking over diagrams on it. ","r"].addLine;
["KIRK: Bones? You could stop all this by saying no. ",[7].dm(\b,4,\mixolydian) ++ [3,4,7,4,3,2,3,4].dm(\c,5,\mixolydian) ++ [5].dm(\a,4)].addLine;
P.tune('stop all this');
P(\double,start:'stop all this',syl:0,music:{|p b e| 
	p.tune[e.start].list[1..].dropLast
	=> { |i| [
		midinote: i.q - [ 12, 24 ],
		dur: b.drop(1).q,
		rel: [2,2,2,2,2,2,2,4].q,
		legato: [1,1,1,1,1,1,1.1,1.1] - 0.1 =>_.q,
		instrument:\sawSynthSustain,
		amp:0.065


	].pma(\sawSynthSustain).play } 

});
P(\chord,start:'stop all this',music:{|p b e| 
	[
		//freq: [1,3,5,7].df(\b,4,\mixolydian),
		//freq: [ [1,3,4.5,7].df(\b,4,\mixolydian), \r, [1,3,5,11].df(\a,4,\minor) ].q,
		freq: [ [-1 ,1,3,5,7].df(\b,4,\mixolydian), \r, [-1, -7, 1,3,5].df(\a,4,\minor) ].q,
		dur: b.parse([1, 8, 1]).q,
		strum: [ 0.055, 0, 0.04 ].q
	].pp
});
["That's why-- I called you all here together. ","2  2 3  -6  3 4  4 5 2 5  5 6 6 7 6".dm('e-',5,\lydian)].addLine;
P.tune('here together');
P(\bass,start:'here together',music:{
	|p b e| 
	[
		freq: [ \r, 1, 2, 3, -7, 1 ].df('e-',[3,4],\lydian).q,
		dur: b.parse([1, 3, 2, 2, 1, 6]).q
	].pp
}
);	
["(boom) We'll all be deeply involved. It must be unanimous. ","-1 12 13 12 12 11 7 6".dm(\c) ++ "2 6 5 4 3 4 1 -6".dm('f#')].addLine; //p11
P.tune(\involved, Pmul(\freq,[1,2],_));
Song.quarters[\involved] = Song.parseBeats(\involved,[1, 1/2, 1, 1/2, 2/3, 2/3, 1/3, 1/3, 3/2, 1/2, 2/3, 2/3, 2/3, 1/2,1/2,1]);
P.click(\involved);
P(\bass,start:\involved,music:{|p b e|  // passing tone right before end please
	[
		freq: [1, 1, 1.5, 2.5, 4.5].df(\c,3).q,
		dur: b.parse([ [1, 1, 0.5],[0.5, 1, 1,1,1,1],  [1,1,1, 2/3],[1/3,1], 3 ]).q,
		out: Effect({ |i| SineShaper.ar(i, 0.2) *5 }, out:[0,1]).bus.index 
	].pp; 
	
});


SynthDef(\defaultRetrig,{ | out=0 freq=400 amp=0.1 gate=1 t_trig=1 pan=0 curve=( -8 ),fatness=0.3 | 
			var z;
			var damper = Env.asr(0,1,0.3).kr(2,gate:gate);
			var decay = Env.perc(0.005, freq/440 => _.reciprocal * 4, curve:curve).kr(0,gate:t_trig);
			var envelope = damper * decay;
			z = LPF.ar(
				Mix.new(VarSaw.ar(freq + [0, Rand(-0.4,0.0), Rand(0.0,0.4)], 0,fatness, 0.3)),
				XLine.kr(Rand(4000,5000), Rand(2500,3200), 1)
			//) * Linen.kr(gate, 0.01, 0.7, 0.3, 0);
			) * envelope;
			OffsetOut.ar(out, Pan2.ar(z, pan, amp));
		}).add;

P(\chords,start:\involved,music:{|p b e| 
	var oneM7 = [3,5,7];
	var four6 = [-6, 1, 4];
	var six = [-6, 1, 3];
	[
		freq: [\r, oneM7, oneM7, oneM7, \r, oneM7, four6, six].df(\c) ++ 
		[ [1,3,5,7], [ -7,2,4,7 ]].df('c#',5,\mixolydian) => _.q,
		curve:-9,
		t_trig:1,
		legato: [1,1,1,1,0,1,1,0.9,1].q(inf),
		//dur: b.parse([1, [1, 1/2], [1/2, 1], 4, 5,3]).q,
		dur: p.quarters[e.start].parse([1,1,1,1, 1,1, 2, 2, 8, 3]/2).q,
		out: Effect(PlateReverb.ar(_,mix:0.5,decayTime: 0.3,damping:0.7)).bus.index
	].pma(\defaultRetrig).play
	
});
["MCCOY: Then I'll still want one question answered to my satisfaction.", "1 2 -8 1 3 4 2 5 1".dm(\f, 5, \diminished) ++ "3 4 5 1 6.5 6".dm(\c, 5, \mixolydian) ].addLine;//p13
P(\dimchords,start:\answered,music:{|p b e| 
	[
		freq: [ [1,3,5,7].df(\d,5,\diminished),[1,3,5,7].df('c#',5,\diminished) ].q,
		dur: b.parse([9,5]).q,
		legato:1,
		instrument:\wash,
		att:b[0..8].sum,
		rel:b[9..14].sum * 4,
		freqLag:1,
		amp:0.05

	].pm(\wash).play
});
P.tune(\answered);
P.tune('answered to', {|i| Pbindf(i,\legato,0.9, \instrument,\stringyy,\wet,0.3,\release,2,\amp,0.2) => Pmul(\freq,1/[2,4],_)});
["Why? Not a list of possible miracles, (boom) but a ","6 3 1 5 3".dm(\f) ++ "6.5 6 3 5 4 -7".dm('c#',5) ++ "-5 3 4".dm('e-')].addLine;
P.tune('possible miracles');
P(\bass,start:'possible miracles',music:{|p b e| 
	[
		//freq: [1, 2, 1.5, 4, 1, -5].df('e-',3,\mixolydian).q,
		freq: [1, 2, 1.5, 2.5, 1, -5].df('e-',3,\mixolydian).q,
		dur: b.parse([1,2,2,3,3,3]).q,
		//instrument:\sawSynthSustain
		out: Effect( { |i|  SineShaper.ar(i*10,limit:0.1) => FreeVerb.ar(_,0.5,0.9) }  ).bus.index
	].pp
});
P(\strum,start:'possible miracles',music:{|p b e| 
	(
		freq: "-1 1 3 5 7".df('e-'),
		strum: 0.06
	).play
});
["simple basic understandable","5 5 6 6 7 11 7 6 4".dm('e-',5,\mixolydian)].addLine;
Song.setQuarters(\understandable,"q q q q q e q e e ".asBeats);
//Song.quarters[\understandable].list
	P(\chords,start:\understandable,music:{|p b e| 
		var one, four, seven;
		# one, four, seven = [[1,3,5],[1,4,6],[2,4,7]].df('e-',scale:\mixolydian);
		\one.post;one.postln;
		MegaBind(
			[one, one, four, four, seven, seven, four, four ].flop,
			p.quarters[e.start].list.gaussian(dev:0.005),
			//1,
			[
				pan:[ -1,0,1 ],
				limit:[ 0.5,0.1,0.005 ],
				lag: { 0.01 dup: 8 => _.put(0,0) => _.dq => _.demand(p.quarters[e.start].list) }
			],
			{|i|
				SinOsc.ar( i.freqSeq.lag(i.lag), 0, 0.1 )
				* 
				(
					Env.asr(0.01,1,0.001).kr(gate:i.gateSeq)
					+
					Env.perc(0.05,1).kr(0,gate: i.trigSeq)
				)
				=> SineShaper.ar(_, i.limit)
				=> Pan2.ar(_,i.pan).fold2(0.01)
				=> AnalogPhaser.ar(_, SinOsc.ar(rrand(0.2,0.3)), feedback: 0.8)
				=> LPF.ar(_,6000)
			},
			{|i|
				Mix.ar(i)
				=>HPF.ar(_,200)
				/2
				=> PlateReverb.ar(_,decayTime:0.2, mix:0.25)
				/2

			}
		).play

	});
P.tune(\understandable);
P(\bass,start:\understandable,music:{|p b e| 
	[
		freq: "1 1 4 4 7 7 4 4".df('e-',3,\mixolydian).q,
		dur: p.quarters[\understandable],
		//instrument:\sawSynth

		out: Effect( { |i|  SineShaper.ar(i*10,limit:0.1) => FreeVerb.ar(_,0.5,0.9) }  ).bus.index
	].pp
});
[" why that overrides all danger. And let's not ", "6 5 12 11 7.5 6.5  12 13 11 3 4 5".dm(\d,5,\minor)].addLine;
P(\bass,start:\override,music:{|p b e| 
	[
		freq: [1, 1.5, 2, -5, -4].df(\g,3,\minor).q,
		dur: b.parse([3,1,3,4, 1]).q,
		instrument: \sawSynthSustain
	].pp
});
P.tune(\overrides);
["kid ourselves that there is no potential danger in this. ", "5 4 2 -6 -7 1 1.5 1.5 2 3 4 2 -7 -5".dm(\f)].addLine;
P(\bass,start:\kid,music:{|p b e| 
	[
		freq: [1, 6, -6].df('b-',2).q,
		dur: b.parse([6,4, 3]).q,
		instrument:\sawSynthSustain
	].pp
});
P.tune(\kid);
}
)
