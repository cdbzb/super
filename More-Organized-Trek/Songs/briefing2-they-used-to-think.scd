( //  Song(\theyUsed) {{{

	//~synthsLoaded.isNil.if{"/Users/michael/tank/super/song-Synthdefs.scd".load};
	Song(\theyUsed,[]).current;
	~moonChord="e- f a c#" => ~panNotes.(_);
	~marsChords=[0,2].collect{|root| [ freq:	[ [1,4,6].dup++[1,3,5] .dup ].flatten.degreescps(root:root).q ].p }.q;

	SynthDef( \sawzz,
		{Saw.ar(\freq.kr(400,\port.kr(0.5)),0.1)
		* Env.asr(0.1,1,2).kr(2,gate:\gate.kr(1))
		* \amp.kr(0.1)
		=>(CombN.ar(_,1)+Gain.ar(_,3))
		=>Out.ar(\out.kr(0),_)}
	).add;
	
	Song.resources=();
		["they used to think if man could ","f3 f g g a a b "].addLine; //0
		P.tune(\think);
		["fly, he`d have wings, but he","b3 a g c#4 b3 c#4"].addLine; //1
		P.tune(\wings);
		["did fly (boom boom)", "e4 d a3 f#"].addLine; //2


	P(\chord,start:'did fly',music: {|p b e|
		[
			//		dur:~tu.secDur[2..3].q,
			dur:p.secDur[e.start..(e.start+2)].q,
			freq:[[2,5,7],[1,4,6],[1,3,5]].df(\g,3).q,
			amp:0.04,
		].pp });
P(\wowowow,start:'did fly',syl:1,lag:0.05,music:
 		{|p b e| 
			{

 			var notes = [11,6,3].degreescps;
 			var durs = [0]++(p.durs[e.start].list[2..3]).integrate;// + ~tu.durs[2].list[2] ;

 			{a=Synth(\sawzz,[\freq,notes[0],\amp,0.1]).dur(4)}.sched(durs[0]);
 			[1,2].do{|i| {a.set(\freq,notes[i])}.sched(durs[i])}
 		}.play}
	);

		P.tune('did fly');
		["(boom) he discovered he ","c d4 c b3 a b"].addLine;//3
		P(\boomBass,start:\discovered,music:(note:0,octave:3,amp:0.5,dur:Song.secDur[3]));
		["had to.. do you wish that the first","c4 b3 g#3 e b g# a b"].addLine;//4
	P(\wowowow,start:\first,syl:1,music: {|p b e|
			[
				freq: [15,13,7].df(\e,4,\mixolydian).q,
				dur:p.parse(e.start,[1,1,3],2).q,
				instrument: \sawzz

			].ppm
		}
	);
	P(\bass,start:\first,music: {|p b e|
			( 
			freq:[5].df(\c,2),
			amp:0.5,
			dur:p.parse(e.start,[4]),
		).play
	});
	P(\bass,start:\first,syl:3,music:{|p b e| 
		[ 
			freq:[5,6,2].df(\e,2,\mixolydian).q,
			amp:0.5,
			dur: (p.parse(4,[[1,1,1,2/3],1/3],4) + ([0]++p.parse(5,[1,2]))).q ,
		].pp 
	});
		["Apollo mission hadn`t reached the","c#4 f# c# e d# b-3 a- b- b"].addLine;//5
		["moon... or that we hadnt  ","c#4 b3 a g a b  "].addLine;//6
P(\baas,start:\moon,music:(
	freq:[1].dm('e-',3),
	dur: Song.secDur[6],
	amp:0.5,
));
P(\ooh, start:\moon,music: {{ 
	var effect = Effect.bus(FreeVerb.ar(_,0.6,0.9));
		var choir=Synths(\ooh,
			\freq,~moonChord.midicps,
			\blend,0,
			\out,effect
		);
		fork{
			s.latency.wait;
			{choir.set(\blend,1,\lag,0.5)}.sched(1);
			choir.synths.do{|i|{ { i.set(\blend,1) }.sched(4.2.rand) }.value};
			fork{7.do{choir.set(\blend,[0,0,0,1].scramble) ;rrand(0.6,1.2).wait}};
			{choir.release(4)}.sched(1);
		}
		}.value}
) ;
								
//Song.pbind[7].play
		["gone on to" , "d4 e- b3"].addLine; //7
P(\bass,start:'gone on', music: {|p b e|
		[
		amp:0.5,
		freq:[3,3.5,1].df(\b,2,\minor).q,
		dur: p.parse(e.start,[[1,1/3],2/3,1]).q,
	].pp
});
//~recorder.(Song,7,2)
		["Mars, and then to the nearest","a4 g4 g e f g e"].addLine;//8
Song.quarters8=Song.parse(\Mars,[2/3,[1/3,1],3,2]);
P(\ooh,start:'Mars',music:{|p b e|
	( 
		instrument:\ooh,
		freq: [5,11,13].df(\f),
		blend:1,
		amp:0.01,
		dur:p.parse(8,[[1,1]]) ,
	).play 
});
P(\middleVoice, start:'Mars',music:(note:0,dur:2,instrument:\sawzz,));
P(\bass,start:'Mars',music: {|p b e|
		[ 
		amp:0.5,
		freq: [11,7,7].df(\f,2).q ,
		dur: p.parse(e.start,[1,1,1]).q,
	].pp 
});
P(\bass,start:'Mars',music:[ 
	amp:[0.5,0.4,0.1,0.5,0.5,0.1,0.1,0.5,0.5].q,
	freq:[4,4,4,2,3,3,3,3,2].df(octave:3,).q,
//	freq:[4,4,4,3,3,3,2].df(octave:3,).q,
	dur:
//	( Song.parse(8,[1/3,2/3,1,1,3,1])++1 ).q
		Song.quarters8.collect(0.5*_.dup).flatten.q ++ [1].q
	,
].p);
P(\guitar,start:'Mars',music: {|p b e|
	Pmono(\pluckDVerb, 
		\blend,[-1,-1,-1,-1,1].q,
		\amp,0.02,
		\freq, [[11,14],[11,13],[5,12]].collect{|i| i!2}.flatten.df(octave:3).q ,
		\octave,2,
		\out,[0,1],
		\smooth,Pwhite(0.2,0.3,inf),
		\del,Pwhite(0.5,1,inf),
		\dur,Song.quarters8.q++ ( p.parse(e.start,[1]).q +0) ,
		\coef,Pbrown(0.1,0.9,0.03),
		\lag,Pwhite(-0.01,0.01)
		//\lag,[0,1]

	).play
});
		["star (boom boom) ","b4"].addLine;//9
		P.tune('star (boo');
P(\highchord,start:'star',music:( 
	instrument: \stringyy,
	freq: [1,3].df(\a,6),
	dur: 1
));

		[ "thats like saying you ",[3,1,4,3,4].dm(\b) ].addLine; //10
		P.tune(\saying);
		P(\bassnote,start:'saying',music:{|p b e|
			[ 
				freq:[7,11,12,13,13.5,14.5,15.5].df(\e,3,scale:\harmonicMinor).q,
				dur:b.parse([2,3]).q 
				++ e.bNext.parse([4,5]).q
				++ e.bNext(2).parse([5,2,2]).q
				=> _.postln
				,
				instrument:\stringyy,
				out: [0,2].q(inf),
				amp:0.3
			].pp
		});
		[ "wish that you still operated with", [5,3,4,5].dm(\B)++[4,1,2,3,4].dm(\d) ].addLine;//11
		[ "scalpels and sewed your patients up with",[3,2,1,2,3,4.5,2].dm(\e)++[11,6].dm(root:0) ].addLine;//12
P(\sewed,start:'scalpels',syl:4,music:
	{|p b e|
		[ 
			attack:3,
			depth:0,
			freq:[5,11,11].df(\a,3).q,
			port:1.1,
			dur:p.parse(e.start,[4],5).q ++ e.bNext.parse([1,3]).q,
		].pm(\tri).play
	}
);

//Song.sewed12.p;Song.pbind[12].play
P(\patience,start:'scalpels',syl:5,music: {|p b e|
	[ 
		pan:1,
		amp:0.1,
		instrument: \sawzz,
		freq:[2,1,1].df(\d,5).q,
		dur:p.parse(e.start,[2,1],5).q++[1].q
	].pp
});
		[ "cat-gut like your great great great great", [4,3,4,5].dm(\d,scale:\minor) ++[3,4,2,3].dm(\B,scale:\harmonicMinor) ].addLine; //13
		P(\lick,start:'cat-gut',syl:3,music:{|p b e|
			[ 
				freq: [11,12,7,11,4].df(\b,3,\harmonicMinor).q,
				dur:p.parse(e.start,[1,1,1,1],4).q++[p.secDur[e.start+1]].q,
				out: 0,
				//	port:1,
			].pm(\sawzz).play }
);
P(\bassnote,start:'cat-gut',music:{|p b e|
	( 
		freq:[ 11,5 ].df(\d,2),
		dur:p.parse(e.start,[4])
	).play 
});

		SynthDef( \harpsichord, { Pulse.ar(\freq.kr(300),0.25,\amp.kr(0.1))* Env.perc().kr(2,gate:1) => Out.ar(\out.kr(0),_)} ).add; 
		P(\harpsichord,start:'cat-gut',syl:3,music: {|p b e|
				[
					drive:0,
					decaytime:50,
					strum:0.03,
					dur: p.parse(e.start,[1,1,1,1],4).q++[Song.secDur[e.start + 1]].q,
					//				amp:0.02,
					//				detune: [-3,10],
					//				instrument: \harpsichord,
					instrument:\pluckDVerb,
					coef:0.1,
					//		drive:0.1,
					freq:[[5,11,13],[5,12,14],[5,7,12],[5,11,13],[4,6.66,13]].df(\b,3,\harmonicMinor).q * [1,2],
				].pp
			});
P(\lickharmony,start:'cat-gut',syl:3,music: {|p b e| [ 
		\freq, [13,14,12,13,7].df(\b,3,\minor).q,
		dur:p.parse(e.start,[1,1,1,1],4).q++[p.secDur[e.start+1]].q,
		\out,1,
		//	port:1,
	].pm(\sawzz).play } 
);
		[ 'grandfather used to',[4,3,2,2,1].dm(root:\A) ].addLine;//14
P(\highchord,start:'grandfather', music:( 
	instrument:\stringyy,
	freq: [1,4].df(\e,5),
	dur: Song.secDur[14],
));
P(\chord,start:'grandfather',music:( 
	strum:0.06,
	freq:[5,11].df(\a,1) *.x [1,2],
	dur:Song.secDur[14],
	amp:0.2
));
P(\bell,start:'grandfather',syl:2,music:( 
	freq: [5,11].df(\e,5),
	amp:0.02,
	strum: 0.07,
	dur:2,
));

	Song.addGuides("xxx");
	//Song.pbind[2].play
	//Song.cursor_(2).play;
	);


	//// 2 ///// {{{

//	Song.durs[4].list
//	Song.pbind[4].psslay

