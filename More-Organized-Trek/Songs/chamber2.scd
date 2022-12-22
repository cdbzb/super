( //line 178 ~/tank/Trek/return-to-tomorrow.txt
	
	s.waitForBoot{
		Song.currentSong.isNil.not.if{ Song.resources.do(_.free) };	//this should be a method
		Song(\chamber,[]).current;
		Song.currentSong.resources.infrastructure=FunctionList([ {
			//			~synthsLoaded.isNil.if{"/Users/michael/tank/super/song-Synthdefs.scd".load};
		} ]);
		"~/tank/super/More-Organized-Trek/Songs/boilerplate.scd".standardizePath.load;
		['Kirk briefly convulses with pain', "c" ].addLine;
		P(\pains,  music: { 
			Song.painSynth={
				Impulse.ar(
					LFBrownNoise0.ar( 5 +1.0.rand!4) *100
				)
				* 0.5
				=>Out.ar(\out.kr(0),_)
			}.play 
		});

		['then the sphere glows bright again' , "c"].addLine;
		Song.durs[0]=[3].q; Song.durs[1]=[8].q; 
		Song.durs[2]=[ 7 ].q;
		P(\sphere,  music: { |p b e|
			{
				{ Song.painSynth.free }.sched(p.secDur[e.start]);
				Saw.ar( LFBrownNoise2.ar(0.1,3!4)*1300+20, 0.1 )
				=> LeakDC.ar(_)
				*  Env.asr(16,1,5).kr(0,gate:\gate.kr(1))
				=> CombC.ar(_,0.5,\delayTime.kr(0.2,0.1,3))
			}.play.dur(p.secDur[e.start],5)
		});
		['and he falls to his knees.' ,"r" ].addLine;
		P(\knee,music:{ |p b e |
			[ 
				strum:0.05,
				note:Arpeggio([0,3,7,11],20),
				dur:3,
				effect:{ Effect( { |i|  FreeVerb.ar(i,0.6,1) * Env.linen(0, b.sum + 0, 3).kr(2,gate:1)} ,inputChannels:2).bus.index},

				//		out:[0,1,2,3],
				out:Pkey(\effect),
			].p.fin.play
		});
		[ /*MCCOY*/ 'Is it you, Jim? (a nod)', [3,4,7,5, 5.5].dm('d')  ].addLine; 
		P(\nod,syl:3,music:{ | p b e |
			[
				strum:[ 0.06 ].q,
				freq:[1,3,5,11].df('e-',octave: 4),
				out:
				{ Effect({|i| EchoNone.ar(i,1,0.3,5) =>.first DetectSilence.ar(_,doneAction:2)=> MoogFF.ar(_,6000,3) * Env.linen(0,b.sum,2).kr(2,gate:1) },inputChannels:2).bus.index  }, 
				//		out:Pkey(\effect), 
			].pp
		});
		P(\tune,music:Song.currentSong.pbind[3]
	);
	['Good, his metabolic rate is back to normal.',[15,14,15,16.5,15,14,13,12,15,12,11,7].dm('a',scale:\harmonicMinor,octave:4)].addLine;
	P(\bassLine,music:[
		dur:
		Song.currentSong.parse(4,[3,1,2,1,3,2]).q
		,
		freq:[11,7,5,4,3,2].df('e',octave: 3,scale:\mixolydian).q,
	].p
);
P(\tune,music:Song.currentSong.pbind[4]
		);
		['/*SPOCK:*/ Captain, do you know what happened? Do you remember any part of it? ',[13,11,7,11,12,13,14,13 ].dm('g',octave:4,scale:\mixolydian)++[7,11,12,14,13,12,11,13,11,5].dm('a',octave:4,scale:\mixolydian)].addLine; 
		P(\bassNote,music:(instrument:\stringyy,freq:[4].df('c',octave: [4,3]),amp:0.2,)
	);
	P(\tune,music:Song.currentSong.pbind[5]
);
['/*KIRK:*/ Yes. ',[1].dm('a-')].addLine; 
P(\tune,music:Song.currentSong.pbind[6]
		);
		P(\chord,music:(
			strum:0.02,
			dur:4,
			out:
			( 4!4 ).rand
			,
			//out:2,
			instrument:
			//			\cleanPluck,
			\default,
			freq:
			[1,5,3,11]+.x[0,10] =>_.df('a-',octave: 3),
			amp:0.05
		)
	);
	['Sargon borrowed my body. ',[7,6,5,6,7,4,3].dm('b',scale:\dorian)].addLine; 
	P(\tune,music:Song.currentSong.pbind[7]
);
P(\bass,music:[
	freq: [7,6,5,6,7,11].df('b',scale:\dorian,octave:2).q ,
	legato:2,
	dur: Song.currentSong.parse(7,[1,1,1,1,1,2]).q ,

].p
		);
		['I was floating (boom) in time and space. ',[3,4,13,11,4.5,13].dm('a')++ [13,11,6].dm('a-')++ [16,15,13,7].dm('d') ].addLine; 
		Song.synthVTracks = EventWithDefault(\default, {
			FreeVerb.ar(_,0.3,0.9)
			/5
		});
		P.synthV(\kevin, filter: (midinote: _ - 12),  params: {|p b| [
			lyrics: "I was floating + \r in time - r and space r r ",
			legato: [1,1,1,1,1,1,1,1, 1, 1,2]
		] }, music:{|p b e|
			{
				e.playbuf
				 => p.synthVTracks.at(e.key).()
				 => {|i| i + PitchShift.ar(i,pitchRatio:0.5)}
			}.play
		});
		P.tune( Pbindf(_, \out,Effect.bus(FreeVerb.ar(_,1,1),inputChannels:2)));
		P(\bassb,syl:1,music:[
			//		instrument:\stringyy,
			freqLag:[0,0,0].q,
			freq:[11,7,4].df('a',octave: [2,3]).q,
			dur:Song.parse(8,[4,4,3],2).q,
		].pm(\stringyy)
	);
	P(\bass,syl:1,music:[
		//		instrument:\stringyy,
		freqLag:[0,14,95].q,
		freq:[11,7,4].df('a',octave: 3).q,
		dur:Song.parse(8,[4,4,3],2).q,
	].pm(\stringyy)
);
['/*MCCOY:*/ He doesnt appear to be harmed - -. Physically, anyway. ',[4,5,6,5,4,5,6, 7,11,7].dm('e' )++[13,11,7,5,4,3].dm('e-',scale:\mixolydian)].addLine; 
P(\bass,syl:9,music:Song.currentSong.pbind[9]
=>Pbindf(_,\instrument,\sawSynth,\amp,0.03)
=>Padd(\midinote,(-24),_)
=>Pdrop(10,_)
		);
		P(\tune,music:Song.currentSong.pbind[9]
	);
	P(\baseline,syl:0,music:[ 
		freq:
		[1,11].df('b',octave: 2).q
		,
		dur:Song.parse(9,[9],1).q,
	].p

);
['/*KIRK:*/ Spock, I remember. ',[13,13,13,13.5,5].dm('b-',octave:3,scale:\minor )].addLine; 
P(\cello,music:(
	instrument:\stringyy,
	freq:[1].df('b-',octave: 3),
)
		);
		P.tune();
		P(\pedal, music: { |p b e|
			(
				instrument:\stringyy,
				freq: [-1,1].df('b-',[4,]),
				amp:0.15,
				dur: b.parse([5]) + 3,
				release:8
			).play
		});
		P(\chord,music:{ |p b e|
			b.postln;
			[
				strum:0.06,
				freq:[5,11,13].df('b-',octave:[3,4],scale:\minor),
				amp:0.02,
				instrument:\sawSynthSustain,
				dur:b.parse([3]).q
			].pp
		}
		);

		['When Sargon and I exchanged, ',[6,5,4,5,6,7,11].dm('e-',octave:4)].addLine; 
		P.tune();
		P(\chord,syl:5,music:{|p b e|
			( 
				strum:0.09,
				instrument:\sawSynthSustain,
				freq: [1,3,5,6].df('f#',octave: 4) ,
				amp:0.02,
				//dur:Song.parse(12,[3],2).q,
				dur:b.drop(1).parse([1]) + e.bNext.parse([2]),// => _.q,
				rel:3,
				//att:1
			).play
		}
		);
		P(\bass,syl:5,music:(
			instrument:\sawSynth,
			freq:[1].df('a-',octave: 4),
			//		freq:[1].df('c',octave: 4),
			amp:0.01,
		)
	);	
	['as we passed each other, for an instant...',[5.5,6].dm('f#',octave:4)++[3,2,2,1].dm('c',octave:5)++[3,2,2,1].dm('c#',octave:5)].addLine; 
	P(\tune,music:Song.currentSong.pbind[12]
);
P(\bass,syl:1,music:(
	instrument:\sawSynthSustain,
	freq:[5,17,11].df('c',[3],\minor),
	//		freq:[1].df('c',octave: 4),
	amp:0.01,
)
		);	
		P(\chord,syl:1,music:{|p b e|
			( 
				strum:0.09,
				instrument:\sawSynthSustain,
				freq: [5,11].df('c',4) ,
				amp:0.02,
				dur:Song.parse(12,[3],2), 
			).play
	}	);
	P(\chordz,syl:1, music: { |p b e|
		[
			[
				freq:[[7,11].df(\c,4),[7,11].df('f#',4)].q,
				out:0,

			]
			,
			
			[
				freq:[[3,5].df(\c),[3,5].df('f#',4)].q,
				out:1,
			]
		].do
		{|i| i ++ 
			[
				dur: b.drop(1).parse([[3,0.5],[0.5,3]]).q,
				instrument:\sawSynthSustain,
				lagTime:1,freqLag:0.8,depth:0.01,amp:0.015,
				rel:[2,4].q,
			] =>_.pm => _.play
		}


	});
	P(\bassNote,music:[
		freq: [Rest(),[1].df('f#',octave:3)].q ,
		dur: 
		Song.parse(12,[[ 5,0.5 ],[ 0.5,4 ]]) + [0,Song.parse(13,[2]) ]=>_.flatten=>_.q
		,
		instrument: \stringyy ,
	].p=>{|i|Ppar([\stringyy,\default].collect{|k x|Pbindf(i,\instrument,k,\amp,{0.1-(x/20)},\out,x)})}
);
['we were one. ',[4,4,5].dm('c')].addLine; 

P(\bend,music:{{
	var line=Line.kr(1.degreescps('a-'),1.degreescps('g'),Song.parse(13,[3]),[0.5,1]);
	var saturation=Line.kr(0.3,0.8,Song.parse(13,[3]));
	SinOscFB.ar(line 
		* [1,1.501,2.01]
		,
		saturation,0.004)
		* [1,0.1,0.2]
	* Env.linen(1,1,3).kr(2,gate:1)
	=> EchoCubic.ar(_,1,0.3,6)
	* 3
}.play;
(instrument:\stringyy,note:-2,dur:2,amp:0.15,
	//octave: [6,5]
).play
	} 
);
P(\triangle,syl:1, music: { |p b e|
		{
			var num = 10;
			Klank.ar(
				`[
					Array.fill(num,{exprand(4000,9000)}),
					Array.series(num,0.1,-0.02),
					{8.0.rand}!num
				],
				Env.perc().kr(0,gate:1) + Impulse.ar(0) * WhiteNoise.ar(0.1)
				/ 60
			)
		}.play
});
P(\chord, music: { |p b e|
	[
		freq: [\r, [3,4,6]].df(\a,4,\whole).q,
		dur: b.parse([2,1]).q,
		instrument:\wash,
		att:2,
		curve:3,
		amp:0.02

	].pp
});
P(\tune,music:Song.currentSong.pbind[13]
	);
	//idea: maybe this convergence can be done with phase instead of frequency! 
	//try this with a recording of say water or something 
	//MUTEDP(\convergenceTest,music:{
	//MUTED{ // we are one idea
	//MUTEDvar divergence = Bus.control(s,4);
	//MUTED{ { LFBrownNoise2.kr(90) }!4 => Out.kr(divergence,_) }.play;
	//MUTED{ 
	//MUTEDSaw.ar( In.kr(divergence.index,4)
	//MUTED*  Line.kr(40,0,dur:6)
	//MUTED+ [5,10].df() 
	//MUTED+ LFBrownNoise2.kr(20,mul: Line.kr(30,0,dur:6))
	//MUTED,0.1)
	//MUTED*  Env.linen(1,5,3).kr(2)
	//MUTED}
	//MUTED.play;
	//MUTED(dur:10,freq:[1,3,5,7].df(octave:3),out:[0,1,2,3],amp:0.3).play;
	//MUTED}.value;
	//MUTED});
	['I know him now. ',[7,11,5,13].dm('a-')].addLine; 
	P.synthV(\kevin, filter: (midinote: _ - 12),  params: {|p b| [
		lyrics: "I know him now",
	] }, music:{|p b e|
		{
			e.playbuf
			=> p.synthVTracks.at(e.key).()
		}.play
	});
	P.synthV(\kevin, take:2, filter: (midinote: _ - 24),  params: {|p b| [
		lyrics: "I know him now",
		lag: { 0.03.rand }!4
	] }, music:{|p b e|
		{
			e.playbuf
			=> p.synthVTracks.at(e.key).()
			* [0,1]
		}.play
	});
	P(\figure,music:[
		out:3,
		dur: Song.parse(14,[1,2/3,[1/3,1],1/2,1/2]).q,
		//		freq:[Rest()].q++[6,11,5,7].df('a-',octave:3).q,
		freq:[Rest()].q++[6,11,5,11].df('a-',octave:3).q,
		instrument:\sawSynth,
		amp:0.05,
	].p
);
P(\lick, music:[
	out:2,
	amp:0.02,
	rel:3,
	freq:[Rest()].q++[6,7,11].df('a-',octave:4).q,
	instrument:\sawSynth,
	dur:Song.parse(14,[1,1,1,1]).q,
].p );
P(\bassKnow,  music:
	[
		freq:[Rest()].q++[4,4,4,5,11,11,7,7].df('a-',octave:1).q,
		dur: Song.parse(14,[1,1/3,1/3,1/3,1,1/4,1/4,1/4,1/4]).q ,
		amp:0.02,
	].pm(\pluckD)
);
P(\temp,music:Song.currentSong.pbind[14]=>Pbindf(_,\amp,0.3,\instrument,\stringyy));
['I know what he is and what he wants, ',[15,14,13,12,14,13,7,11,12.5].dm('a-')].addLine; 
P.synthV(\kevin, filter: (midinote: _ - 24),  params: {|p b| [
	lyrics: "I know what he is and what he wants, ",
	lag: [0,0,0,0,-0.2,0,0,0,0],
	legato:[1,1,1,1,1,1,1,1,3]
] }, music:{|p b e|
	{
		e.playbuf
		=> p.synthVTracks.at(e.key).()
	}.play
});
//P(\cymbal,music:[
//	instrument:\cymbalsDS,
//	dur: Song.parse(15,[1,4,1]).q ,
//	amp:0.01,
//	note:[ Rest(),1,1 ].q,
//].p);
P(\snare,music:[
	note:"..x.".asDrumPat(reps:2),
	amp:0.05,
	instrument:\snare,
	//		dur: Song.parse(15,1!8).q,
	dur: Song.currentSong.durs[15].list[..7].sum/8
].p);
P(\kick,music:{|p b e|
	[
		note:"xx.x".asDrumPat(reps:2),
		instrument:\kick,
		//		dur: Song.parse(15,1!8).q,
		dur: 
		Song.currentSong.durs[e.start].list[..7].sum/8
		,
	].pp }
);
		P(\tune,music:Song.currentSong.pbind[15]=>Pbindf(_,\instrument,\stringyy,\amp,0.3)
	);
	P(\bass,music:[
		amp:0.02,
		freq:[6,6,6,6,5,5,5,5].df('a-',octave:1).q,
		dur:Song.parse(15,1!8).q,
	].pm(\pluckD);
);
P(\finalBaseNote,syl:7,music: (
	release:4,instrument:\pluckDEnv,freq:[4.5].df('a-',octave:1),amp:0.03,
	//addAction:\addToHead,
	dur: Song.currentSong.durs[15].list[8],
	out: Effect.bus(
		FreeVerb.ar(_,0.5,1),out:[0,1],inputChannels:2
		=>.first DetectSilence.ar(_,doneAction:2)
		)
		
	

));
P(\figure,music:[
	rel:4,
	strum:0.02,
	instrument:\sawSynth,
	amp:0.05,
	freq: [  
		[1,3,5,7].df('c#') ,
		[1,3,5,7].df(\c,scale:\minor),
		[3,5,7, 11].df(\g,scale:\mixolydian,octave:3) 
	].q ,
	dur: Song.parse(15,[4, 4,1]).q,
	hifreq:8000,
	out: Effect.bus({|i|
		MoogFF.ar(i,2000,2)
		* 1.3
		=>( CombC.ar(_,0.5,SinOsc.kr(0.3).range(0.4,0.405),decaytime:4)+Gain.ar(_,3) )
	},out:2,inputChannels:2)
].p
	); 
	//MUTEDP(\figure,music:[
	//MUTEDout:3,
	//MUTEDfreq:[13,11,7,5,4.5].df('a-',octave:3).q,
	//MUTEDdur: Song.parse(15,2!4++[1]).q,
	//MUTEDinstrument:\sawSynth,
	//MUTEDamp:0.05,
	//MUTED].p
	//MUTED);
	['and I don`t fear him. ',[4,5,6,7,11].dm(\c)].addLine; 
	P(\tune,music:Song.currentSong.pbind[16]=>Pbindf(_,\instrument,\stringyy,\amp,0.3)
);		
//MUTEDP(\bassNote,syl:0,music:
//MUTED(
//MUTEDfreq:[5].df(octave:2),
//MUTEDdur:2,
//MUTEDamp:0.2,
//MUTED)
//MUTED);
P(\chord,syl:2,music:
	[
		instrument:\sawSynthSustain,
		att:1.4,
		rel:3,
		lofreq:5000,
		hifreq:6000,
		out:Effect.bus(MoogFF.ar(_,5000,3),out:2,inputChannels:2),
		addAction:\addToHead,
		//			out:2,
		freq:[5,15,24,27].df(octave:3),
		strum:0.02,
		dur: 
		(Song.parse(16,[2],3)+1.3).q
		,
		//			dur:2,
		amp:0.06,
	].p.fin
);
['/*MCCOY:*/ That`s the most ri (boom) ',"c#4 a3 d#4 b3 r "].addLine; 
P(\tune,music:Song.pbind[17] 
	);
	P(\boom,syl:3,syl:3,music: {|p b e|
		(instrument:\membrane,out:2,amp:0.05).play 
	}
);
P(\line,music:{
	[
		instrument:\twang,
		amp:0.03,
		freq:[4,6,7,11.5].df(\e,octave:3).q,
		//			dur: Song.parse(17,[1,[1,1/2],[1/2,1],1]).q,
		dur: Song.parse(17,[1,[1,1/2],[1/2,1,1]]).q++[1].q,
	].p 
}.value);
P(\bassnote,syl:3,music:(degree:3,octave:[3,2],amp:0.4,dur:2,)
		);
		['diculous statement I`ve ever heard. An ',[5,2,1,4,3,1,2,3,4.5,].dm('b-')++[5].dm(\d)].addLine; 
		P(\chord,music:[ 
			strum:0.05,
			out: Effect.bus(
				{ |in|
					EchoCubic.ar(in,1,SinOsc.kr(1/[22, 20 ],[0,pi]).range(0.2,0.3),5)
					=> MoogFF.ar(_,SinOsc.kr(10).range(800,2000))
					
				}
				,inputChannels:2
			),
			freq:[11,13,15,17,1].df(\f,octave:4),
			dur:
			//			Song.parse(18,[3]).q
			1
			,
		].p.fin
	);
	P(\bassNote,syl:7,music:[ 
		amp:0.3,
		out:Effect.bus({|i| FreeVerb.ar(i,0.5,1)})  ,
		freq:[1,11].df(\g,octave:2),
		dur: Song.parse(18,[2],8).q,
	].p.fin
);		
P(\tune,music:Song.currentSong.pbind[18]
	);
	['alien practically hijacks your body and ', [11,7,5,6,7,11,14,12,13,14,13,11].dm('d')].addLine; 
	P(\bass,music: [ 
		freq: [5,6,11].df('d',octave: 2).q,  
		dur: Song.parse(19,[6,3,3]).q,
	].p );
	P.tune();
	['corks you into a bo -- ttle  and', [1,2,3,4,5,6,7,1,6].dm('c',octave:6)].addLine; 
	P.tune();
	//	P(\tune,music:Song.currentSong.pbind[20]);
	P('swell20',lag: -0.1,music:{|p b e|
		(
			curve:'sin',instrument:\swell20,attack:2,release:5,amp:0.04,freq: [1,11].df('c',octave: 3)).play
		});
		//['/*MULHALL:*/ I`m afraid that I must agree with Doctor McCoy. You could be suffering from a form of false euphoria. ',"r"].addLine; 
		['/*MULHALL:*/ I`m afraid I agree with Doctor McCoy. You could be suffering from a form of false euphoria.(ooh -- --) ', [ 3,4,2,3,1, 5,3,4,5,3,6, 4,5,6,11,7,2 ].dm('e',scale:\dorian) ++ [4,5,6,7].dm('c') ++ [13,14,13,12,11, 12,11,7].dm('f#',octave: 5) ].addLine; 
	P(\bassline,music:[
		dur:Song.parse(21,[2,2,5,5],).q,
		freq:[3,2,1,13].df('e',octave: 3,scale:\minor).q,
		legato:[0.95,0.95,2,1].q,
	].p
);
P(\arpeggio,syl:9,music:[
	amp:0.6,
	dur:3,
	out:Effect.bus({|i|Pan2.ar(i,SinOsc.kr(2))=>EchoNone.ar(_,0.9,[0.3, 0.21 ],4)=>Phaser2.ar(_,0.5,1/4)},inputChannels:2,out:1),
	instrument:\cleanPluck,
	strum:0.08,
	freq:[7,13,15,20,23].df('a',octave:3,scale:\mixolydian ),
].p.fin
	);
	P(\bassNote,syl:13,music:
		[ 
			dur:Song.currentSong.parse(21,[3,4],14).q ,
			freq:[7,4].df('c',octave: 3).q,
			//	octave:3,
		].p
	);
	P(\euphoriaChords,syl:20,music:{|p b e|
		[
			freq:[[ 1,3,5 ]].df('f#',octave: 4).q(2)
			++ [[5,11,13]].df('b-',octave: 3).q(2)
			++ [[3,5,11]].df('e-',scale:\minor,octave: 4).q(2)
			++ [[5,11]].df('c#',scale:\minor,octave: 4).q(2)
			,
			dur:p.parse(21,[2/3,[1/3,1,1/7],4/7,[2/7,1,1/7],4/7,[2/7,1,1/5],4/5
			,1
		],21).q,
		out:Effect.bus(EchoCubic.ar(_,0.3,0.25,4)),
	].p.play
}
	);
	P(\tune,music:Song.currentSong.pbind[21]
);
['/*KIRK:*/ Sargon. ',[3,2].dm('a')].addLine; 
P(\tune,music:Song.currentSong.pbind[22]
	);
	P(\bas,music:(
		strum:0.04,
		out:[0,2],
		amp:0.03,
		instrument:\sawSynthSustain,
		freq:[1,5,11,16.5].df('a',octave: 2),
		rel:5,
	)
);
P(\arpeggio,music: [ 
	amp:0.02,
	freq: [7,11,13,15]+.x [0,10,20] => _.sort
	=>_.df('a',octave:3),
	strum:0.07,
	//	lag:-0.1,
	effect:  Effect.bus(EchoCubic.ar(_,rrand(0.2,0.6!4),1,7!4),inputChannels:4),
	scale:Scale.mixolydian,root:-3,
].p.fin
	);
	['/*SARGON [OC]:*/ I understand, my son. Go to your vessel.', [11,11,11,11,7,7,7,11,12,14,13].dm('c')].addLine; 
	P(\drone,music:{|parent| 
		[ instrument:\sawSynthSustain,
			amp:0.012,
			freq: [ [2,12],[1,11] ] =>_.df('c',octave: 3)=>_.q ,
			legato: 1,
			dur: Song.parse(23,[9,2],).q
			,
			//		out:parent.carrier.index,
		].p.play }
	);
	P.tune(\understand, _ => Pbindf(_,\instrument,\stringyy,\amp,0.3, \out,Song.carrierBus)); 


	P(\chordsSargon,lag:-0.0,music:{|parent durs| 
		var effect = Effect( 
			{|i|
				Phaser2.ar(i) 
				=> FreeVerb.ar(_,0.5,1)
				=> Decimator.ar(_,8000,8)
			} ,
			out:Song.carrierBus,

		);
		[
			freq: [2,4,6,11].dup(4) ++ [2,4,5,7].dup(2) => _.df('c',octave:5) =>_.q ,
			instrument:\sawSynthSustain,
			legato:0.95,
			amp:1.4,
			dur:durs.q,
			out:effect.bus.index,
		].pp;
		//effect.synth.moveBefore()

	});

	P.rpp(\vocal,start:\understand,lag:-1,music:{|p b e|

		//p.vocodeTune(p,b,e,e.rpp)


		p.vocodeTune.(p,b,e,e.rpp,amp:0.12,dur:b.sum+1,att:1,sus:b.sum-1,rel:2,chord:[1],out:3);
	});
	P(\bass,syl:8,music:
		{ |p b e| 
			[
				amp:0.3,
				amp:2,
				indstrument:\test,
				freq: [1].df('c',octave: 3).q(1),
				dur:b.sum,
				out: p.carrierBus.index
			].pp
		}
	);
	['all that are invo -- -- lved must agree',[15,14,13,12, 11,12,11,7,11,11.5].dm('g',octave:3)].addLine; 
	P(\descant,music:[
		freq:[[7, 12 ],[ 13,11 ],[ 11,5 ],[11,5.5]].df('g',octave: 5).q,
		dur: Song.parse(24,[2,2,5,1]).q,
		out:  Effect.bus(EchoNone.ar(_,1,[0.2, 0.3 ],3),inputChannels:2),
		amp:0.01,
	].pm(\sawSynthSustain)
);
P.tune('must agree');
P.rpp(\vocal,'must agree',lag:-1,music:{|p b e|
	//	e.rpp.postln.key.postln
	p.vocodeTune.(p,b,e).postln;//(p,b,e,amp:0.12,dur:b.sum+1,chord:[1,2,3])
	p.postln;
});
P('tune24',music:{ |p| 
	p.pbind[24]=>Pbindf(_,
		//		\instrument,\stringyy,
		\instrument,\sawSynth,
		//		\amp,2.8,
		\out,p.carrierBus.index,
		\addAction,\addBefore,\group,p.vocoderGroup
	)
	=>Pmul(\freq,0.5,_)
	//		=>Pmul(\freq,[5/3,1,2.1, 1/2 ],_)
	=>_.play 
});
['after all these centuries ', [7,11,16,15, 15,16,14].dm('e',scale:\harmonicMinor) ].addLine;
P(\chord,syl:3,music:(
	amp:0.03,
	strum:0.06,
	instrument:\sawSynthSustain,
	freq:[1,3,5,7].df('c',octave: 4),
	//			effect:{var bus=Bus.audio;Synth(\test,[\in,bus.index]);bus.index},
	//			out:Pkey(\effect),
)				
	);
	P(\bassnote,syl:3,music:[ 
		dur: 
		( Song.parse(25,[3],4)++Song.parse(26,[2,4,1]) ++ Song.secDur[27]) 
		.clumps([ 2,1,1 ]).collect(_.sum).q
		,
		amp:0.25,
		instrument:\stringyy,
		freq:[11,12,5].df('c',octave: 2).q, 
	].p
);
P(\wobble,music: [
	//		instrument:\sawSynth,
	amp:0.05,
	//		instrument:\tri,
	freq:[3,4].df('b',octave:4 ).q(inf),
	effect:{ Effect(EchoNone.ar(_,1,0.3,decaytime:5)).dur(Song.secDur[25]+6).bus.index },
	dur: Song.parse(25,1!4).q,
	out:Pkey(\effect),
].pm(\sawSynth)

	);
	P(\wobble,music: [
		//		instrument:\sawSynth,
		amp:0.05,
		//		instrument:\tri,
		freq:[1,2].df('d',octave:4 ).q(inf),
		out: Effect.bus(EchoNone.ar(_,1,0.3,decaytime:5),out:1),
		dur: Song.parse(25,1!4).q,
	].pm(\sawSynth)

);
P('tune25',music:Song.currentSong.pbind[25]
	);
	['we can wait a few more hours',[1,2,3,4,5,6,5].dm('d')].addLine;
	P(\resolution,syl:5,music:{ |parent durs|
		[
			freq:[2,1].df('g',octave: 4).q,
			//				dur:durs.q,
			dur:parent.parse(26,[1],6).q++[2].q,
		].pp
	}
);
P('tune26',music:Song.currentSong.pbind[26]
	);
	//	// (see ../vocoder2.scd for voice of Sargon)	
	//	['/*MCCOY:*/ And what if we should decide against you? '].addLine;
	['/*MCCOY:*/ And what if we decide against you? ', [7,6,5,4,5,6,7,12,11.5].dm('e')].addLine;
	P(\resolution,syl:6,music:{ |parent durs|
		[
			freq:[3,2].df('e-',octave: 5,scale:\minor).q,
			//				dur:durs.q,
			dur:parent.parse(27,[1,1],7).q,
			stretch:[1.1,1].q,
		].pp
	}
);
P('tune27',music:Song.currentSong.pbind[27]
	);
	['/*SARGON [OC]:*/ (beat) Then you may',[1,5,5,4].dm('c#')].addLine;
	P('tune28',music:Song.currentSong.pbind[28]
	=>Pbindf(_,\amp,[0].q++[0.1].q(inf))
);
P('extra-note28',music: (
	amp:0.04,
	freq:[1].df('a-',octave: [3, 4 ]),
	instrument:\sawSynth,
)
	);
	[' go as free -- ly as you came.',[13,12,13,14,13,12,7,11].dm('c#')].addLine;
	P('tune29',music:Song.currentSong.pbind[29]
);
SynthDef(\cleanPluck,{
	DWGPlucked2.ar(
		\freq.kr(300),
		\amp.kr(0.1),
		\gate.kr(1),
		\position.kr(0.14),
		1/\decay.kr(10),
		\damping.kr(30),
		Impulse.ar(0)*\volume.kr(0.1),
		\detune.kr(1.08),
		\coupling.kr(0.01))
		=> Out.ar(\out.ir(0),_)
	}
).add;
P(\accompaniment,music:
	{|parent durs|
		[
			amp:0.07,
			coupling:0.001,
			midinote:[3,5,11,3,  4,6,11,3,  2,5,11,2,  4,6,11,2, [3,6]].dm('c#',octave:5 ).q,
			position:Pwhite(0.1,0.16),
			legato:1.55,
			effect: Effect(DWGSoundBoard.ar(_)++DelayN.ar(_,0.1,0.1),inputChannels:2).dur(Song.secDur[29]+1).bus.index,
			out:Pkey(\effect),
			dur:parent.parse(29,[1/7,1/7,1/7,1/7,1/7,1/7,1/7,
				1,1,1,
				1/4,1/4,1/4,1/4,
				1,1,
				1
			]).q,
			instrument:\cleanPluck,
		].pp;
	}
);
P(\bass,music:
	[
		freq:[1,1,4,4,5,5,5,5,1].df('c#',octave: 3).q,
		dur:Song.parse(29,[1/7,1/7,1/7,1/7,1/7,1/7,1/7,
			1,1,1,
			1/4,1/4,1/4,1/4,
			1,1,
			1
		]).clumps([ 3,1 ]).collect(_.sum).q
	].p;

);
//MUTEDP(\machine,music:
//MUTED{ 6.do{{ SinOscFB.ar(100.rand+300+SinOscFB.kr(1/5,3,mul:5),SinOscFB.kr(1/2,3).unipolar*3,0.1) =>LPF.ar(_,6000)=>Pan4.ar(_,rrand(-1,1),rrand(-1,1))
//MUTED=>EchoNone.ar(_,1,0.6,3)
//MUTED* 0.04
//MUTED}.play(s)} }
//MUTED);
	}
)
