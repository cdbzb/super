
(
s.waitForBoot{
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
	P(\xtra_notes,start:'down there',syl:11,music:{|p b e| 
		[
			freq: [-6, 1, -11, -4, -7].df(\c).q,
			legato: [1, 1/3, 3,2,1].q,
			dur: b.drop(1).parse([1,4, 1/3, 1/3, [1/3,1]]).q
		].pp
	});
	Song.setTempoMap('down there',"e e e eee ee e e x x eee e ee ee eee x xe e eee");
	P(\bass,start:'down there',music:{|p b e| 
		[
			freq: [\r, -5, 5, -5, \r, -6, 6, 5, 4, -4, -4.5, -5, 5, -7, 1].df(\c,3).q,
			dur: "eee q q q q q e e q qe e q e e q  ".asBeats.warpTo(e.tempoMap).q,
			instrument:\sawSynthSustain,
			legato:[0.9!14,2].flat.q
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

	["The rest is only guesses. ","5 11 5 3 5 7 11".dm('c#',4,\harmonicMinor) ].addLine;
	P.tune(\guesses);
P(\bass,start:\guesses,music:{|p b e| 
		MegaBind(
			[
				[5,-1].df('c#',4),
				[5,1].df('c#',4)
			],
			b.parse([1,6]),
			[],
			{|i|
				Saw.ar( i.freqSeq + ChaosGen.subclasses.choose.ar(2).wrap(1) )
				*(
					 Env.asr(1).kr(gate:i.gateSeq)
				)
					* 0.08
				
					=> MoogFF.ar(_, XLine.kr(6000,300,b[1..6].sum*[2,1.5]))
			},
			{|i|
				Splay.ar(i)
				=> DWGReverbC1C3.ar(_,500,mix:0.15)
			}
		)//.play
		;
		[
			freq:[-15,[-21]].df('c#').q,
			dur:b.parse([1,6]).q,
			instrument:\sawSynthSustain
		].pp;
	});
	[ "SCOTT: I don't like it, sir. The trans-- ","1 -7 3 1 -5".dm(\c,5,\mixolydian)++" 1 -7 ".dm(\d,5,\mixolydian) ].addLine;
	P.tune('like it');
	P(\zzz
		,start:\pointqa,music:{|p b e| 
		1
	});
	P(\spazzPad,start:'like it',music:{|p b e| 
		MegaBind(
			
				[
					\r,
					[5,7,1,3].df(\c,4,\mixolydian), 
					[-5,-6.5,1,3].df(\d),\r,
					[-7,2,4,5].df(\d,5), \r, 
					[1,5,11,13].df(\e,4),
					[-5,5,12,13].df(\c,4,\minor),
					[1,1.5, 5, 11, 15].df(\b,4)
				].flop
			,
			b.parse([2,5]) 
			++ p.durs[e.next].list.parse([5,2,3]) 
			++ p.durs[e.start+2].list.parse([2, 3, 3] 
			++ ( p.durs[e.start+3].list.sum + 1 )) => _.flat 
			+ [0,0,0.5,-0.5,0,0,0,0]
			,
			[],
			{|i|
				var a = Saw.ar( i.freqSeq * [1,2,3]=>_.lag([0,0,0.8,0,0,0,0,0.5,0.5].dq.demand( i.dur )) )
				* (
					Env.asr(0.2).kr(gate:i.gateSeq)
					* 0.1
					/3
				);
				a => Convolution.ar(_, Dust.ar(36)=> Decay.ar(_,0.1) * WhiteNoise.ar(0.1) =>FreeVerb.ar(_,0.6,1))
				+ ( a/8 )
			}	,
			{
				|i| i
				=> Splay.ar(_)
				=> EchoNone.ar(_,0.3,0.3,3)
			}
		).play
		
		
	});
	[ "porter co-ordinates preset by an","3 1 -6.5 -5 -5.5 -5 -7 4 3 4".dm(\d)].addLine;
	P.tune('ordinates');
	P(\bass,start:'ordinates',syl:6,music:{|p b e| 
		
		[
			freq:[1,-5, -5].df(\a,[3,4]).q,
			instrument:\sawSynth,
			att: [1,0.1,0.1].q,
			dur: b.drop(1).sum.bubble ++ p.durs[e.next].list.parse([1,1]) => _.flat => _.q
		].pp
	});
	["(boom boom) alien of some sort. ","-1 -1 3 2 1".dm(\e) ++ "3 2 -5".dm(\c,5,\minor)].addLine;
	P.tune('some sort',_.drop(2),syl:1);
	P(\bass,start:'some sort',music:{|p b e| 
		var t;
		MegaBind(
			[[ 1, 1, -3, -5, -4.5 ].df(\e,3,\whole) ],
			t = b.parse([1,1,[1,1,0.5],[0.5,1,1,1]]++p.durs[e.next].list.sum),
			[
				rel:{ [0.3,  0.3,  1,    1,    3].dq.demand(t) },
				att:{ [0.02, 0.02, 0.05, 0.05, 0.5].dq.demand(t) },
				amp:{ [0.07,    0.09,    0.1,    0.1,    0.08].dq.demand(t) }
			],
			{|i|

				//[lag:{[0,b[3]+0.1].dq.demand(i.dur)}],
				Saw.ar( i.freqSeq / [1,2] + ChaosGen.subclasses.choose.ar(12).range(0,1!3) )
				=>RLPF.ar(_,5000)
				* (
				EnvGen.kr(Env([0,1,0.7,0],[i.att,1.5,i.rel]),gate:(i.gateSeq*i.trigSeq))
					* i.amp
				)
			}

		).play
	});
		
	P.tune('co-ordinates');
	["(boom) You could materiali--se inside ","-1 4 3 2 4 3 2 1.5 2 ".dm(\b,4) ].addLine;
	P.tune(\material, _.drop(1),syl:0);
	P(\bass,start:\material,music:{|p b e| 
		{
			VarSaw.ar(1.df(\b,[3,4]))
			* Line.kr(0.1,0,b.sum)
		}.play
	});
		
	//["solid rock. ",[7, 6, 6, 11, 7, 7].dm(\c) ].addLine;
	P.tune('rock.');
	Song.setTempoMap('rock.', "qe e qq qe e qq");
// in hook Bones-Scotty.RPP
	P(\chords,start:'rock.',music:{|p b e| 
		[
			freq: 
			[[1, 3, 5, 7],[1, 3,5, 6],[1, 3, 5, 6]].df(\c).q
			++[[1, 3, 5, 7],[1, 3,5, 6],[1, 3, 5, 6]].df(\d,5,\mixolydian).q
			,
			dur: "q ex xqq".asBeats.warpTo(e.tempoMap).dup.flatten.q,
		].pp
		
	});
		

	P(\bass,start:'rock.',music:{|p b e| 
		[
			freq: [[1, 11],[1,11],11, -7,1,-7,1, 5,6] => {|i| [ i.df(\c,3).q, i.df(\d,3,scale:\mixolydian).q ].q},
			dur: 
			"e ee e x x x x e e".asBeats.dup.flat.warpTo(Song.tempoMap['rock.']) => _.q,
			instrument:\sawSynth

			//.warpTo(e.tempoMap).q
		].pp
	});
	["(boom boom) solid rock2. ",[1,1, 7, 6, 7, 11 ].dm(\f) ].addLine;
	P.tune(\rock2);
	Song.setTempoMap(\rock2,"q q q e e qqqq");
	P(\chord,start:\rock2,syl:1,music:{|p b e| 
		[
			freq: [ [1,3,5,7],[2,4.5,6,11.5] ].df(\f,[4,5]).q,
		instrument: \wash,
		dur: [b.drop(1).sum, e.bNext.sum].q
	].p.play;
	});
		
P(\bass,start:'rock2.',music:{|p b e| 
		[
			freq: [[1, 11],[1,11],11, -7,1,-7,1, 5,6].df(\f,[2,3]).q,
			dur: 
			//[0, 0.03,-0.03,0,0,0,0,0,0] +
			//"q qq q e e e e q q".asBeats.flat.warpTo(e.tempoMap.quantize(0.4)) => _.q,
			
			//recorded!!
			[ 0.536, 0.805, 0.767, 0.22, 0.301, 0.239, 0.302, 0.556, 0.558, 2.157 ]
			//=> _.remap("q qe eq e e e e e e q q".asBeats,"e e e e e e e e".asBeats)
			=> _.warpRecordedTo(e.tempoMap)
			=>_.q,
			instrument:\sawSynth,
			amp:[1,1,0.7,1,1,0.9,1,0.9,1,1].q/12

			//.warpTo(e.tempoMap).q
		].pp
	});
	P(\chord,start:\rock2,music:{|p b e| 
		[
			freq: [1,3,5,7].df(\f),

			//dur: "qq qe eq q q qe".asBeats.warpTo(e.tempoMap).q,

			dur:[ 0.536, 0.805, 0.767, 0.22, 0.301, 0.239, 0.302, 0.556, 0.5587 ]
			=> _.remap("q qe eq e e e e  q q".asBeats,"qq qe e|qq qe e".asBeats) + [0,0,0,-0.07,0] => _.warpTo(e.tempomap) => _.q,
			//dur:"e e e e e e e e e e e e e e e e e e ".asBeats.warpTo(e.tempoMap).q,
			amp: [0.01] ++ (0.1!22) => _.flat =>_.q,
			instrument:\pulse

		].pp
	});
	
	P(\crashing,start:'rock2',music:{|p b e| 
		//(instrument:\cymbalsDS).play
{ //Dan Stowall Cymbals
		var lodriver, locutoffenv, hidriver, hicutoffenv, freqs, res, thwack;
		locutoffenv = EnvGen.ar(Env.perc(0.5, 5)) * 20000 + 10;
		lodriver = LPF.ar(WhiteNoise.ar(0.1), locutoffenv);
		hicutoffenv = (EnvGen.ar(Env.perc(1, 3))).range(10000,1);
		hidriver = HPF.ar(WhiteNoise.ar(0.1), hicutoffenv)
		* EnvGen.ar(Env.perc(1, 1, 0.25));
		thwack = EnvGen.ar(Env.perc(\att.kr(0.001),0.0001,1), TDuty.ar(
		"q q q q q q q q q q q ".asBeats .warpTo( p.tempoMap[\rock2]).quantize 
		. dq
	));
		freqs  = {ExpRand(300, 20000)}.dup(30);
		res	= Ringz.ar(lodriver + hidriver + thwack, freqs).mean;
		((res * 1) + (lodriver * 2) + thwack).dup * 0.01
		* Env.linen(0,1,b.sum).kr(2,gate:1)
		=>  Out.ar(0,_)
	}.play
	});
	[ "MCCOY: Inside solid rock? "," 1 1 7 5 13".dm(\g) ].addLine;
	P.tune('rock?');

	[ "SPOCK: Unlikely. These co-ordinates correspond with the location of the","5 11 5  7 5 4 3 2 6 4 3 2 1 -7 4 2 -6 -5".dm('c#')].addLine;
	P.tune(\correspond);
	Song.setTempoMap(\correspond,"e e e XX X X X XXX X X X X X X e e e e".asBeats * 2);
	P(\bass,start:\correspond,syl:0,music:{|p b e| 
		[
			dur: [ 1.052, 2.037, 1.895, 2.101 ]
			//.warpRecordedTo(e.tempoMap)
			.q,
			freq: 1.df('c#',3) ,
			amp:1,
			out: Effect(SineShaper.ar(_,0.1)).bus.index
		].pp
	});
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
	P(\bassnotes,start:\subterranean,music:{|p b e| 
		[
			instrument:\stringyy,
			freq: [ [-1,1],[-14,4] ].df(\d).q,
			dur: b.parse([6,2]).q
		].pp	
	});
	[ "KIRK: I have a feeling that they or it could destroy us just standing here if they or it wanted to. ","3.5 4 5 7 6 5".dm(\c,5,\minor) ++ "3 1 2 -7 1 4 3 1 6 5 3 1 3 1 2 1 -7 -5".dm('a-') ].addLine;
	P.tune(\feeling);
	P(\bass,start:\feeling,syl:5,music:{|p b e| 
		[
			freq: [11, 5, 6, 4, 5, -5].df('a-',[3,4]).q,
			dur: b.drop(1).parse([2,3,3,4,3,3]).q
		].pp;
	});
	[ "MULHALL: They or it? "," 3 1 5.5".dm(\c) ].addLine;
	Song.mulhallTune=Pset(\out,Effect(EchoNone.ar(_,0.3,0.3,4)*0.5).bus.index,_);
	P.tune('it?',Song.mulhallTune);
	[ "KIRK: Who are you? (boom) ","3 1 7 -6".dm(\f,5,\mixolydian) ].addLine;
	P.tune('you?', Pfin(3,_));
	P(\chord,start:'you?',syl:2,music:{|p b e| 
		[\stringyy,\sawSynthSustain].do
		{ |i| (
			(
				freq: [1,3,5,11].df(\d,[3,4,5]),
				instrument:i,
				dur: b+p.durs[e.start+1].list[0..5].sum,
				att: 6,
				amp:0.05,
				rel:8
			).play
		) } 
	});

	[ "MULHALL: Doctor Ann Mulhall, Astro-biology.",[7, 11, 3, 5, 4.5, 6, 6.5, 2, 4, 3, -5].dm(\d,6,tuning:\sept1) ].addLine;
	P(\chord,start:\biology,syl:4,music:{|p b e| 
		(
			freq: [1,11].df(\c,3),
			dur:b.sum,
			instrument:\stringyy,
			attack:2,
			amp:0.25

		).play
	});
	P.tune(\biology,Song.mulhallTune );
	[ "Well, I was ordered to report here for landing party duty. ", [3, 2, 3, 6, 5.5].dm('c#',6) ++ [4, 5, 6, 7, 5, 11, 5, 4, 3, 2, 1].dm(\c,6) ].addLine;
	P.tune(\landing,Song.mulhallTune);
	P(\bassnotes,start:\landing,syl:9,music:{|p b e| 
		[
			freq: [11,4,5].df(\c,3).q,
			dur: b.drop(1).parse([2,2,2]) + [0,0,p.durs[e.start+1].list.sum] => _.q,
		].pp
		
	});

	P(\bass,start:\landing,music:{|p b e| 
		(
			freq: [1 ].df('c#',[5,4,3]),
			dur:b.parse([4]).sum
		).play
	});
	[ "KIRK: By whom? ",[7, 13].dm(\c,4,\mixolydian) ].addLine;
	P.tune('whom?');
	P(\strum1,start:'whom?',syl:0,music:{|p b e| 
		(
			freq:[5,7,11,13].df(\c,4,\mixolydian),
			strum:0.05,
			dur:b.sum
		).play
	});


	[ "MULHALL: Strange, I'm not sure. Well, I'm not a liar, Captain. i"," 2 1 2 4 2 3 4 5 6 4 3 2".dm('e-',6,\whole) ++ [5].dm(\d,6)].addLine; 
	P(\chord,start:'Strange',music:{|p b e| 
		[ instrument:\wash,
			freq:[[1,3,4.5].df(\b,3), [3,4.5,6.5].df(\b,3)].q,
			dur: b.parse([3,2]).q

		].p.play
	});
	P.tune('Strange',Song.mulhallTune);
	["did receive an order to report here for duty. "," 11 5 4 3 7 6 4 2 6 5 4 3 1".dm(\d,6,\mixolydian) ].addLine;
	P(\bass,start:'did receive',music:{|p b e| 
		[
			freq: [1,4,2,5].df(\d,[3,4]).q,
			dur: b.parse([4,4,3,2]).q,
			legato:1
		].pp;
	});
	P.tune(\receive,Song.mulhallTune);
	[ "SPOCK:(boom) I'm sure she did, Captain, Just as you received an order to bring me along. ",[1,5, 5, 6, 5, 4, 3].dm('e-') ++ [5, 6, 5, 3, 4, 5].dm(\e) ++ [5, 4, 5, 6, 6, 7, 5, 2].dm(\f) ].addLine;
	P.tune(\along,Pdrop(1,_),syl:0);
	Song.setQuarters(\along,"e e ex x q e ee  ex x e e e e  e e e e x e x q");
	//Song.quarters[\along]=Song.quarters[\along].list.reject{|i| i.isPositive.not}.q;
	P(\click,start:\along,music:{|p b e| 
		e.quarters.postln;
		[
			dur: e.quarters,
			instrument:\hat_808
		].p;
	});

	P(\bass,start:\along,music:{|p b e| 
		var lick = [5, 4, 1];
		MegaBind(
			[
				lick.df('e-') ++ lick.df(\e,4) ++ [5,4,11].df(\f,4) => _.flat
			],
			"qe e qq| q e qq| qe e ".asBeats.warpTo(e.quarters),
			{|i|
				VarSaw.ar( i.freqSeq/[2,4]*[0.994,1,1.013],0,0.3 )
				* (
					//Env([0,1,0.7,0],[0.02,0.7,0.3]).kr(0,gate:(i.gateSeq*i.trigSeq))
					Env.asr().kr(gate:i.gateSeq)
					* 0.1
				)
			}
		).play
	});
	[ "KIRK: Oh, yes. ","5 11".dm(\g) ].addLine;
P(\slide,start:'Oh, yes',music:{|p b e| 
		{
			Env([5,5,11].dm(\g),b[0]/2!2,curve:2.2).kr(0,gate:1)
			=> { |i| VarSaw.ar(i.lag( [0,2].dq.demand([1,1])   ).floor.midicps /[2,4],0,0.4) } 
			* 0.04
			=> EchoNone.ar(_)
			* Env.linen(0,b.sum,1).kr(2,gate:1)
				
		}.play
	});
	[ "MCCOY: Let's (boom boom) get back to this ","1 -7 -5 -7 3 2 1 ".dm(\c,5,\mixolydian) ].addLine;
	P.tune('get back',Pset(\amp,[1,0,0,1,1,1,1]/10=>_.q,_));
	Song.setQuarters('get back',"x e ex e | e x x");
	P(\bass,start:'get back',music:{|p b e| 
		[
			freq: [1, -7, -5, -17, -1].df(\c, 4, \mixolydian).q,
			dur: b.q
		].pp	
		
		
	});
	[ "( boom boom ) solid rock business...","1 1 7 6 7 11 7 6".dm('f#')].addLine;
	P.tune(\business);
	P(\bass,start:\business,music:{|p b e| 
		[
			freq: [1, 1, 2].df('f#',[3,4]).q,
			dur: b.parse([1,5,2]).q
		].pp
	});
		
	//add pickup bassnote to line following?
	[" (boom) Just how much rock are we going to go through? ","1 5 5 5 5 3 4 5 4 3 2 1 5 6 5".dm('b-') ].addLine;
	Song.setQuarters(\through,"q q q| q q e e| Q Q Q| Q Q E Eq q");
	Song.quarters[\through] = Song.quarters[\through].list.quantizeWindow.q;
	P.tune(\through,Pset(
		\dur,
		"q q q| q q e e| Q Q Q| Q Q E Eq ex ".asBeats .warpTo(Song.quarters[\through]).q
		,_));
	
	P(\drums,start:\through,music:{|p b e| 
		(instrument:\cymbalsDS,amp:0.05).play;
		e.quarters.postln;
		[
			instrument:\sn_808,
			dur:e.quarters
		].pp;
		[
			dur:"x....x.x".asDrumPat(2,4),
			instrument:\bd_808,
			amp:1
		].p.fin(25).play(e.quarters.asTempoClock)
	});
	P(\bass,start:\through,music:{|p b e| 
		[3,1]/2=>_.dup(6)=>_.flat => _.warpTo( Song.quarters[\through].list ++ 1) => _.postln;
		MegaBind(
			[
				[11, 11, 7,  7,  6,  6,  5,  5,  4,  4,  3,  3,  2],
				[1,  \r, -7, \r, -6, \r, -5, \r, -4, \r, -3, \r, -2]
			].df('b-',3),
			[3,1]/2=>_.dup(6)=>_.flat => _.warpTo(e.quarters.list ++ 1 ) ++ p.durs[e.next].list[0]	,
			[],
			{|i|
				Pulse.ar( i.freqSeq/[1,2] )
				* (
					Env([0,1,0.7,0],[0.02,0.7,0.3]).kr(0,gate:(i.gateSeq*i.trigSeq))
					* 0.1
				)
			}
		).play
	});
	[ "SPOCK: (boom) Approximately one hundred twelve point three five two se-- ven miles, Doctor. ","-2 6 5 4 3 4 5 3 1 6 4 ".dm(\d) ++  "5 3 1 6 4 2".dm(\a,4) ].addLine; // point three se-ven five two miles....
	P.tune(\Approximately,Pfin(7,_));
	P(\fifths,start:\Approximately,syl:5,music:{|p b e| 
		MegaBind(
			[
				"5 3 1 6 4".df(\d) ++ [5, 3, 1, 6, \_, 4, 2].df(\a,4),
				"5 3 1 6 4".df(\g,4) ++ [5, 3, 1, 6, 4, \_, 2].df(\d,4)
			],
			[1,1,1,1,1,1,1,1,2/3,1/3,1].warpTo(b.drop(1)),
			[],
			{|i|
				Saw.ar( i.freqSeq  )
				* (
					Env([0,1,0.7,0],[0.02,0.7,0.3]).kr(0,gate:(i.gateSeq*i.trigSeq))
					* 0.1
				)
				=> MoogFF.ar(_, i.freqSeq*6 +1500)
			},
			{|i| i
				=> DWGReverbC1C3.ar(_,4000,mix:0.2)
				//=> Phaser2.ar(_,rate:0.1)
			}
		).play
	});
	[ "MCCOY: Miles? Are you joking? ","r" ].addLine;
	[ "KIRK: No, we're not. Let's go. ",[-5, -5, 1].dm(\f) ++ [-5, -5, 1].dm(\a) ].addLine;
	[ "SARGON [OC]: Please stand ready. I will operate your controls. ","r" ].addLine;
	//[ "KIRK: Doctor, if you prefer to stay behind? ","r" ].addLine;
}
//[ "MCCOY: No. No, if I'd be useful, as long as you're going down, I might as well take a medical look at whatever this is. ","r" ].addLine;
//(The landing party and two guards gather on the pads, Scotty stands sulking with arms crossed as the transporter activates, and just sends the four officers somewhere.)
)
