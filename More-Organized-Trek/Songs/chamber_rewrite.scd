( //line 178 ~/tank/Trek/return-to-tomorrow.txt
	
	
	Song.chamber.isNil.not.if{ Song.chamber.resources.do(_.free) };	//this should be a method
	Song(\chamber,[]).current;
	Song.currentSong.resources.infrastructure=FunctionList([ {
			~synthsLoaded.isNil.if{"/Users/michael/tank/super/song-Synthdefs.scd".load};
	} ]);
	['Kirk briefly convulses with pain', "c" ].addLine;//0
	P(\pains0, start:0, music: { 
		Song.chamber.painSynth={
			Impulse.ar(
				LFBrownNoise0.ar( 5 +1.0.rand!4) *100
			)
			* 0.5
			=>Out.ar(\out.kr(0),_)
		}.play 
	});
	['then the sphere glows bright again' , "c"].addLine;//1
	Song.chamber.durs[0]=[3].q; Song.chamber.durs[1]=[8].q; 
	Song.chamber.durs[2]=[ 7 ].q;
	P(\sphere1, start:1, music: {
		{
			{ Song.chamber.painSynth.free }.sched(Song.chamber.secDur[1]);
			Saw.ar( LFBrownNoise2.ar(0.1,3!4)*1300+20, 0.1 )
			*  Env.asr(16,1,5).kr(0,gate:\gate.kr(1))
			=> CombC.ar(_,0.5,\delayTime.kr(0.2,0.1,3))
		}.play.dur(Song.chamber.secDur[1],5)
	});
	['and he falls to his knees.' ,"r" ].addLine;//2
	P(\knee,start:2,music:[ 
		strum:0.05,
		note:Arpeggio([0,3,7,11],20),
		dur:3,
		effect:{ Effect(FreeVerb.ar(_,0.6,1),inputChannels:2).dur(Song.secDur[2]+5).bus.index},

		//		out:[0,1,2,3],
		out:Pkey(\effect),
	].p.fin);
	[ /*MCCOY*/ 'Is it you, Jim? (a nod)', [3,4,7,5, 5.5].dm('d')  ].addLine; //3
	P(\nod3,start:3,syl:3,music:[
		strum:[ 0.06 ].q,
		freq:[1,3,5,11].df('e-',octave: 4),
		effect:
		{ Effect({|i| EchoNone.ar(i,1,0.3,5) => DetectSilenceDry.ar(_,doneAction:2)=> MoogFF.ar(_,6000,3) },inputChannels:2).dur(Song.secDur[3]+5).bus.index  }, 
//		out:Pkey(\effect), 
	].p
	);
	P(\tune3,start:3,music:Song.currentSong.pbind[3]
);
	['Good, his metabolic rate is back to normal.',[15,14,15,16.5,15,14,13,12,15,12,11,7].dm('a',scale:\harmonicMinor,octave:4)].addLine;//4
	P(\bassLine4,start:4,music:[
		dur:
		Song.currentSong.parse(4,[3,1,2,1,3,2]).q
		,
		freq:[11,7,5,4,3,2].df('e',octave: 3,scale:\mixolydian).q,
	].p
	);
	P(\tune4,start:4,music:Song.currentSong.pbind[4]
	);
	['/*SPOCK:*/ Captain, do you know what happened? Do you remember any part of it? ',[13,11,7,11,12,13,14,13 ].dm('g',octave:4,scale:\mixolydian)++[7,11,12,14,13,12,11,13,11,5].dm('a',octave:4,scale:\mixolydian)].addLine; //5
	P(\bassNote5,start:5,music:(instrument:\stringyy,freq:[4].df('c',octave: [4,3]),amp:0.2,)
	);
	P(\tune5,start:5,music:Song.currentSong.pbind[5]
	);
	['/*KIRK:*/ Yes. ',[1].dm('a-')].addLine; //6
	P(\tune6,start:6,music:Song.currentSong.pbind[6]
	);
	P(\chord6,start:6,music:(
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
	['Sargon borrowed my body. ',[7,6,5,6,7,4,3].dm('b',scale:\dorian)].addLine; //7
	P(\tune7,start:7,music:Song.currentSong.pbind[7]
	);
	P(\bass7,start:7,music:[
		freq: [7,6,5,6,7,11].df('b',scale:\dorian,octave:2).q ,
		legato:2,
		dur: Song.currentSong.parse(7,[1,1,1,1,1,2]).q ,

	].p
	);
	['I was floating (boom) in time and space. ',[3,4,13,11,4.5,13].dm('a')++ [13,11,6].dm('a-')++ [16,15,13,7].dm('d') ].addLine; //8
	P(\tune8,start:8,music:Song.currentSong.pbind[8]
		=>Pbindf(_,
			\effect,{Effect(FreeVerb.ar(_,1,1),inputChannels:2).dur(Song.secDur[8]+3).bus.index},
			\out,Pkey(\effect)
		)
	);
	P(\bass8b,start:8,syl:1,music:[
//		instrument:\stringyy,
		freqLag:[0,0,0].q,
		freq:[11,7,4].df('a',octave: [2,3]).q,
		dur:Song.parse(8,[4,4,3],2).q,
	].pm(\stringyy)
	);
	P(\bass8,start:8,syl:1,music:[
//		instrument:\stringyy,
		freqLag:[0,14,95].q,
		freq:[11,7,4].df('a',octave: 3).q,
		dur:Song.parse(8,[4,4,3],2).q,
	].pm(\stringyy)
	);
	['/*MCCOY:*/ He doesnt appear to be harmed - -. Physically, anyway. ',[4,5,6,5,4,5,6, 7,11,7].dm('e' )++[13,11,7,5,4,3].dm('e-',scale:\mixolydian)].addLine; //9
	P(\bass9,start:9,syl:9,music:Song.currentSong.pbind[9]
		=>Pbindf(_,\instrument,\sawSynth,\amp,0.03)
		=>Padd(\midinote,(-24),_)
		=>Pdrop(10,_)
	);
	P(\tune9,start:9,music:Song.currentSong.pbind[9]
	);
	P(\baseline9,start:9,syl:0,music:[ 
		freq:
		[1,11].df('b',octave: 2).q
		,
		dur:Song.parse(9,[9],1).q,
].p

	);
	['/*KIRK:*/ Spock, I remember. ',[13,13,13,13.5,5].dm('b-',octave:3,scale:\minor )].addLine; //10
	P(\cello,start:10,music:(
		instrument:\stringyy,
		freq:[1].df('b-',octave: 3),
	)
	);
	P(\tune10,start:10,music:Song.currentSong.pbind[10]
	);
	P(\chord10,start:10,music:(
		strum:0.06,
		freq:[5,11,13].df('b-',octave: 4,scale:\minor),
		amp:0.05,
	)
	);
	['When Sargon and I exchanged, ',[6,5,4,5,6,7,11].dm('e-',octave:4)].addLine; //11
	P(\tune11,start:11,music:Song.currentSong.pbind[11]
);
	P(\chord11,start:11,syl:5,music:[ 
		strum:0.06,
		instrument:\sawSynthSustain,
		freq: [3,5,11].df('f#',octave: 4) ,
		amp:0.02,
		dur:Song.parse(12,[3],2).q,
	].p
	);
	P(\bass11,start:11,syl:5,music:(
		instrument:\sawSynth,
		freq:[1].df('a-',octave: 4),
//		freq:[1].df('c',octave: 4),
		amp:0.01,
	)
	);	
	['as we passed each other, for an instant...',[5.5,6].dm('f#',octave:4)++[3,2,2,1].dm('c',octave:5)++[3,2,2,1].dm('c#',octave:5)].addLine; //12
	P(\tune12,start:12,music:Song.currentSong.pbind[12]
);
	P(\bass12,start:12,syl:1,music:(
		instrument:\sawSynth,
		freq:[1,4].df('g',octave: 4),
//		freq:[1].df('c',octave: 4),
		amp:0.01,
	)
	);	
	P(\chord12,start:12,syl:1,music:[ 
		strum:0.06,
		instrument:\sawSynthSustain,
		freq: [5,7,13].df('c',octave: 5) ,
		amp:0.02,
		dur:Song.parse(12,[3],2).q,
	].p
	);
	P(\bassNote12,start:12,music:[
		freq: [Rest(),[1].df('f#',octave:3)].q ,
		dur: 
		Song.parse(12,[[ 5,0.5 ],[ 0.5,4 ]]) + [0,Song.parse(13,[2]) ]=>_.flatten=>_.q
		,
		instrument: \stringyy ,
	].p=>{|i|Ppar([\stringyy,\default].collect{|k x|Pbindf(i,\instrument,k,\amp,{0.1-(x/20)},\out,x)})}
	);
	['we were one. ',[4,4,5].dm('c')].addLine; //13

	P(\bend13,start:13,music:{{
		var line=Line.kr(1.degreescps('a-'),1.degreescps('g'),Song.parse(13,[3]),[0.5,1]);
		var saturation=Line.kr(0.3,0.8,Song.parse(13,[3]));
		SinOscFB.ar(line,saturation,0.004)
		* Env.linen(1,1,3).kr(2,gate:1)
		=> EchoCubic.ar(_,1,0.3,6)
	}.play;(instrument:\stringyy,note:-2,dur:2).play} 
	);
	P(\tune13,start:13,music:Song.currentSong.pbind[13]
);
	//idea: maybe this convergence can be done with phase instead of frequency! 
	//try this with a recording of say water or something 
	//MUTEDP(\convergenceTest,start:13,music:{
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
['I know him now. ',[7,11,5,13].dm('a-')].addLine; //14
	P(\figure14,start:14,music:[
		out:3,
		dur: Song.parse(14,[1,2/3,[1/3,1],1/2,1/2]).q,
//		freq:[Rest()].q++[6,11,5,7].df('a-',octave:3).q,
		freq:[Rest()].q++[6,11,5,11].df('a-',octave:3).q,
		instrument:\sawSynth,
		amp:0.05,
		].p
	);
	P(\lick14, start:14,music:[
		out:2,
		amp:0.02,
		rel:3,
		freq:[Rest()].q++[6,7,11].df('a-',octave:4).q,
		instrument:\sawSynth,
		dur:Song.parse(14,[1,1,1,1]).q,
	].p );
	P(\bassKnow, start:14, music:
		[
			freq:[Rest()].q++[4,4,4,5,11,11,7,7].df('a-',octave:1).q,
			dur: Song.parse(14,[1,1/3,1/3,1/3,1,1/4,1/4,1/4,1/4]).q ,
			amp:0.02,
		].pm(\pluckD)
	);
	P(\temp,start:14,music:Song.currentSong.pbind[14]=>Pbindf(_,\amp,0.3,\instrument,\stringyy));
['I know what he is and what he wants, ',[15,14,13,12,14,13,7,11,12.5].dm('a-')].addLine; //15
	P(\cymbal15,start:15,music:[
		instrument:\cymbalsDS,
		dur: Song.parse(15,[1,4,1]).q ,
		amp:0.01,
		note:[ Rest(),1,1 ].q,
	].p);
	P(\snare15,start:15,music:[
		note:"..x.".asDrumPat(reps:2),
		amp:0.05,
		instrument:\snare,
//		dur: Song.parse(15,1!8).q,
		dur: Song.currentSong.durs[15].list[..7].sum/8
	].p);
	P(\kick15,start:15,music:[
		note:"xx.x".asDrumPat(reps:2),
		instrument:\kick,
//		dur: Song.parse(15,1!8).q,
		dur: 
		Song.currentSong.durs[15].list[..7].sum/8
		,
	].p
	);
	P(\tune15,start:15,music:Song.currentSong.pbind[15]=>Pbindf(_,\instrument,\stringyy,\amp,0.3)
	);
	P(\bass,start:15,music:[
		amp:0.02,
		freq:[6,6,6,6,5,5,5,5].df('a-',octave:1).q,
		dur:Song.parse(15,1!8).q,
	].pm(\pluckD);
	);
	P(\finalBaseNote15,start:15,syl:7,music: (
		release:4,instrument:\pluckDEnv,freq:[4.5].df('a-',octave:1),amp:0.03,
		addAction:\addToHead,
		dur: Song.currentSong.durs[15].list[8],
		out:{ Effect(
			FreeVerb.ar(_,0.5,1),out:[0,1],inputChannels:2).dur(Song.secDur[15]+5).bus.index 
			 => DetectSilenceDry.ar(_,doneAction:2)
		}

	));
	P(\figure15,start:15,music:[
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
		effect:{ Effect({|i|
			MoogFF.ar(i,2000,2)
			* 1.3
			=>( CombC.ar(_,0.5,SinOsc.kr(0.3).range(0.4,0.405),decaytime:4)+Gain.ar(_,3) )
			=> DetectSilenceDry.ar(_,doneAction:2)
		},out:2,inputChannels:2).dur(Song.secDur[15]+3).bus.index },
		out:Pkey(\effect),
	].p
); 
//MUTEDP(\figure15,start:15,music:[
//MUTEDout:3,
//MUTEDfreq:[13,11,7,5,4.5].df('a-',octave:3).q,
//MUTEDdur: Song.parse(15,2!4++[1]).q,
//MUTEDinstrument:\sawSynth,
//MUTEDamp:0.05,
//MUTED].p
//MUTED);
['and I don`t fear him. ',[4,5,6,7,11].dm(\c)].addLine; //16
P(\tune16,start:16,music:Song.currentSong.pbind[16]=>Pbindf(_,\instrument,\stringyy,\amp,0.3)
	);		
	//MUTEDP(\bassNote16,syl:0,start:16,music:
	//MUTED(
	//MUTEDfreq:[5].df(octave:2),
	//MUTEDdur:2,
	//MUTEDamp:0.2,
	//MUTED)
	//MUTED);
	P(\chord16,start:16,syl:2,music:
		[
			instrument:\sawSynthSustain,
			att:1.4,
			rel:3,
			lofreq:5000,
			hifreq:6000,
			effect:{ Effect(MoogFF.ar(_,5000,3),out:2,inputChannels:2).dur(Song.secDur[16]).bus.index },
			addAction:\addToHead,
			out:Pkey(\effect),
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
['/*MCCOY:*/ That`s the most ri (boom) ',"c#4 a3 d#4 b3 r "].addLine; //17
	P(\tune17,start:17,music:Song.pbind[17] 
);
P(\boom17,start:17,syl:3,syl:3,music:
		(instrument:\membrane,out:2).play 
);
P(\line17,start:17,music:{
	[
		instrument:\twang,
		amp:0.03,
		freq:[4,6,7,11.5].df(\e,octave:3).q,
		//			dur: Song.parse(17,[1,[1,1/2],[1/2,1],1]).q,
		dur: Song.parse(17,[1,[1,1/2],[1/2,1,1]]).q++[1].q,
	].p 
}.value);
P(\bassnote17,start:17,syl:3,music:(degree:3,octave:[3,2],amp:0.4,dur:2,)
	);
['diculous statement I`ve ever heard. An ',[5,2,1,4,3,1,2,3,4.5,].dm('b-')++[5].dm(\d)].addLine; //18
	P(\chord18,start:18,music:[ 
		strum:0.05,
		effect:{ Effect(
			{ |in|
				EchoCubic.ar(in,1,SinOsc.kr(1/[22, 20 ],[0,pi]).range(0.2,0.3),5)
				=> MoogFF.ar(_,SinOsc.kr(10).range(800,2000))
				=> DetectSilenceDry.ar(_,doneAction:2)
			}
			,inputChannels:2
		).dur(Song.secDur[18]+3).bus.index },
		out:Pkey(\effect),
		freq:[11,13,15,17,1].df(\f,octave:4),
		dur:
		//			Song.parse(18,[3]).q
		1
		,
	].p.fin
);
P(\bassNote18,start:18,syl:7,music:[ 
	amp:0.3,
	effect:{ Effect({|i| FreeVerb.ar(i,0.5,1)  =>  DetectSilenceDry.ar(_,doneAction:2) },inputChannels:2).dur(Song.secDur[18]+5).bus.index },
	out:Pkey(\effect),
	freq:[1,11].df(\g,octave:2),
	dur: Song.parse(18,[2],8).q,
].p.fin
	);		
	P(\tune18,start:18,music:Song.currentSong.pbind[18]
);
['alien practically hijacks your body and ', [11,7,5,6,7,11,14,12,13,14,13,11].dm('d')].addLine; //19
P(\bass19,start:19,music: [ 
	freq: [5,6,11].df('d',octave: 2).q,  
	dur: Song.parse(19,[6,3,3]).q,
].p );
P(\tune19,start:19,music:Song.currentSong.pbind[19]);
['corks you into a bo -- ttle  and', [1,2,3,4,5,6,7,1,6].dm('c',octave:6)].addLine; //20
P(\tune20,music:Song.currentSong.pbind[20]);
//	P(\tune20,start:20,music:Song.currentSong.pbind[20]);
P('swell20',lag: -0.1,start:20,music:{|p b e|
	(
		curve:'sin',instrument:\swell20,attack:2,release:5,amp:0.04,freq: [1,11].df('c',octave: 3)).play
});
//['/*MULHALL:*/ I`m afraid that I must agree with Doctor McCoy. You could be suffering from a form of false euphoria. ',"r"].addLine; //21
['/*MULHALL:*/ I`m afraid I agree with Doctor McCoy. You could be suffering from a form of false euphoria.(ooh -- --) ',
	[ 3,4,2,3,1, 5,3,4,5,3,6, 4,5,6,11,7,2 ].dm('e',scale:\dorian)
	++ [4,5,6,7].dm('c')
	++ [13,14,13,12,11, 12,11,7].dm('f#',octave: 5)
].addLine; //21
P(\bassline21,start:21,music:[
	dur:Song.parse(21,[2,2,5,5],).q,
	freq:[3,2,1,13].df('e',octave: 3,scale:\minor).q,
	legato:[0.95,0.95,2,1].q,
].p
);
P(\arpeggio21,start:21,syl:9,music:[
	amp:0.6,
	dur:3,
	effect:{ Effect({|i|Pan2.ar(i,SinOsc.kr(2))=>EchoNone.ar(_,0.9,[0.3, 0.21 ],4)=>Phaser2.ar(_,0.5,1/4)},inputChannels:2,out:1).dur(6).bus.index},
	out:Pkey(\effect),
	instrument:\cleanPluck,
	strum:0.08,
	freq:[7,13,15,20,23].df('a',octave:3,scale:\mixolydian ),
].p.fin
);
P(\bassNote21,start:21,syl:13,music:
	[ 
	dur:Song.currentSong.parse(21,[3,4],14).q ,
	freq:[7,4].df('c',octave: 3).q,
//	octave:3,
].p
);
//17,21
P(\euphoriaChords21,start:21,syl:20,music:{|parent durations|
	[
		freq:[[ 1,3,5 ]].df('f#',octave: 4).q(2)
		++ [[5,11,13]].df('b-',octave: 3).q(2)
		++ [[3,5,11]].df('e-',scale:\minor,octave: 4).q(2)
		++ [[5,11]].df('c#',scale:\minor,octave: 4).q(2)
		,
		dur:parent.parse(21,[2/3,[1/3,1,1/7],4/7,[2/7,1,1/7],4/7,[2/7,1,1/5],4/5
		,1
	],21).q,
		effect:Effect(EchoCubic.ar(_,0.3,0.25,4)).dur(Song.secDur[21]+3).bus.index,
		out:Pkey(\effect),
	].p.play
}
);
P(\tune21,start:21,music:Song.currentSong.pbind[21]
);
['/*KIRK:*/ Sargon. ',[3,2].dm('a')].addLine; //22
P(\tune22,start:22,music:Song.currentSong.pbind[22]
);
P(\bas122,start:22,music:(
	strum:0.04,
	out:[0,2],
	amp:0.03,
	instrument:\sawSynthSustain,
	freq:[1,5,11,16.5].df('a',octave: 2),
	rel:5,
)
);
P(\arpeggio22,start:22,music: [ 
	amp:0.02,
	freq: [7,11,13,15]+.x [0,10,20] => _.sort
	=>_.df('a',octave:3),
	strum:0.07,
//	lag:-0.1,
	effect: { Effect(EchoCubic.ar(_,rrand(0.2,0.6!4),1,7!4),inputChannels:4).dur(Song.secDur[22]+7).bus.index },
	scale:Scale.mixolydian,root:-3,
	out:Pkey(\effect)+[0,2],
].p.fin
);
['/*SARGON [OC]:*/ I understand, my son. Go to your vessel.', [11,11,11,11,7,7,7,11,12,14,13].dm('c')].addLine; //23
P(\drone,start:23,music:{|parent| 
	[ instrument:\sawSynthSustain,
	amp:0.012,
	freq: [ [2,12],[1,11] ] =>_.df('c',octave: 3)=>_.q ,
	legato: 1,
	dur: Song.parse(23,[9,2],).q
	,
	//		out:parent.carrier.index,
].p.play }
	);
	// make this infrastructure
//	~unnecessary.infrastructure={
//		~synthsLoaded.isNil.if{"/Users/michael/tank/super/song-Synthdefs.scd".load};
//		~unnecessary.condition.test_(true).signal;
//	};
Song.resources.infrastructure.addFunc({
		Song.currentSong.carrier=Bus.audio(numChannels:2);
		Song.currentSong.modulator=Bus.audio(numChannels:2);

		Song.currentSong.vocoderGroup=Group(addAction:\addToTail);
		Song.currentSong.vocoder={
			Vocoder.ar(In.ar(Song.currentSong.carrier),In.ar(Song.currentSong.modulator),20,100,5000,0.02,
//			hpfscal:4
		)}
		.play(Song.currentSong.vocoderGroup);
});
	//MUTEDP(\vocoder23,start:23,music:{ |parent durs|
		//MUTED{
			//MUTED//cleanup
			//MUTEDparent.vocoder.free;
			//MUTEDparent.modulator.free;
			//MUTEDparent.carrier.free;
			//MUTEDparent.vocoderGroup.free;
		//MUTED}//.sched(20)
	//MUTED});
	P(\tuneSargon,music:{|parent| 
		Song.pbind[23] 
		=> Pbindf(_,\instrument,\stringyy,\amp,0.3,
			\out,parent.carrier.index
		)=> _.play
}	);
	P(\chordsSargon,start:23,lag:-0.0,music:{|parent durs| 

		parent.carrier.index.postln;
		defer{Server.default.scope(4,parent.carrier.index)};
		[
			instrument:\sawSynthSustain,
			effect:{var a=Bus.audio;
//				Synth(\phaser,[\in,a.index],addAction:\addToTail);
				{In.ar(\in.kr(0)) 
				=> Phaser2.ar(_) 
				=> FreeVerb.ar(_,0.5,1)
				=> DetectSilenceDry.ar(_,doneAction:2,time:3) 
				=> Decimator.ar(_,8000,8)
//				=> Out.ar(\out.kr(0),_)}.asSynthDef(name:\test, fadeTime:0.09)
				=> Out.ar(\out.kr(parent.carrier.index),_)}.asSynthDef(name:\test, fadeTime:0.09)
				.play(parent.vocoderGroup,[\in,a.index],addAction:\addBefore);
				a.index}.value,
			out:Pkey(\effect),
			legato:0.95,
			amp:1.4,
			dur:durs.q,
			freq: [2,4,6,11].dup(4) ++ [2,4,5,7].dup(2) 
			=> _.df('c',octave:5)
//			*[1,3]	=>_.flatten
			=>_.q ,
		].p.play
	});
	//example vocoder idea
//{ Vocode.ar(Item(\iUnderstand).playbuf,Pulse.ar([100,200,350,500]+SinOsc.kr(0.2).range(0,30),0.05,1)=>FreeVerb.ar(_),PinkNoise.ar(1))*6=>EchoNone.ar(_,0.3,[0.26, 0.3 ]) }.play(s,2); { Vocoder.ar(Impulse.ar([100,200,350,500],1)=>Mix.ar(_),Item(\iUnderstand).playbuf=>EchoNone.ar(_),20) }.play
	P(\vocal,start:23,music:{|parent|
		Item(\iUnderstand).play(out:parent.modulator.index)
	}
	);
	P(\bass23,syl:8,start:23,music:
		{ |parent durs| 
			[
				amp:0.3,
				effect:{ var a=Bus.audio;Synth(\test,[\in,a.index,
//					\out,0
				],
				target: parent.vocoderGroup,
				addAction:\addBefore);a.index }.value,
				amp:2,
				freq: [1].df('c',octave: 2).q(1),
				dur: durs.sum,
				out:Pkey(\effect),
//out:0,
			].pp
		}
	);
['all that are invo -- -- lved must agree',[15,14,13,12, 11,12,11,7,11,11.5].dm('g',octave:3)].addLine; //24
P(\descant,start:24,music:[
		freq:[[7, 12 ],[ 13,11 ],[ 11,5 ],[11,5.5]].df('g',octave: 5).q,
		dur: Song.parse(24,[2,2,5,1]).q,
		effect: { Effect(EchoNone.ar(_,1,[0.2, 0.3 ],3),inputChannels:2).dur(Song.secDur[24]+4).bus.index },
		amp:0.01,
		out:Pkey(\effect),
].pm(\sawSynthSustain)
);
P(\vocal24,start:24,music:{|parent|
		Item(\allThatAreInvolved)
		.play(out:parent.modulator.index)
//.play
	}
);
//~bypass=nil;
~bypassState=~toggle.isNil.if{~toggle=[false,true].q(inf).asStream;~toggle.next}{~toggle.next;~toggle.next};
~toggleBypass={
		~bypassState=~toggle.isNil.if{~toggle=[true,false].q(inf).asStream;~toggle.next}{~toggle.next};
		\bypass_state.post;~bypassState.postln;
 };
~refreshVocoderBypass={//|bool=true|
		~toggle.isNil.if{~toggle=[true,false].q(inf).asStream};
		~bypassMonitor.isNil.if{~bypassMonitor=Monitor()};
		 'vocoder bypass state'.post;~bypassState.postln;
		Song.currentSong.vocoder.run(~bypassState.not);
		~bypassState.if{ 
				~bypassMonitor.play( 
				Song.currentSong.carrier.index
				,1,1,1 ) 
		}{
		~bypassMonitor.stop;
		};
};
Song.currentSong.resources.infrastructure.addFunc(~refreshVocoderBypass);
MIDIdef.noteOn(\f1, {~toggleBypass.();~refreshVocoderBypass.()},54, srcID:XTouch.id);
//MUTEDP(\bypass,start:24,music:{~refreshVocoderBypass.(
		//MUTEDfalse
//MUTED)});
P('tune24',start:24,music:{|parent| 
		parent.pbind[24]=>Pbindf(_,
				//		\instrument,\stringyy,
				\instrument,\sawSynth,
				//		\amp,2.8,
				\out,parent.carrier.index,
				\addAction,\addBefore,\group,parent.vocoderGroup
		)
		=>Pmul(\freq,0.5,_)
//		=>Pmul(\freq,[5/3,1,2.1, 1/2 ],_)
		=>_.play 
});
['after all these centuries ', [7,11,16,15, 15,16,14].dm('e',scale:\harmonicMinor) ].addLine;
P(\chord25,start:25,syl:3,music:(
		amp:0.03,
		    strum:0.06,
			instrument:\sawSynthSustain,
			freq:[1,3,5,7].df('c',octave: 4),
//			effect:{var bus=Bus.audio;Synth(\test,[\in,bus.index]);bus.index},
//			out:Pkey(\effect),
		)				
);
P(\bassnote25,syl:3,start:25,music:[ 
		dur: 
		( Song.parse(25,[3],4)++Song.parse(26,[2,4,1]) ++ Song.secDur[27]) 
		.clumps([ 2,1,1 ]).collect(_.sum).q
		,
		amp:0.25,
		instrument:\stringyy,
		freq:[11,12,5].df('c',octave: 2).q, 
].p
);
P(\wobble25,start:25,music: [
//		instrument:\sawSynth,
		amp:0.05,
//		instrument:\tri,
		freq:[3,4].df('b',octave:4 ).q(inf),
		effect:{ Effect(EchoNone.ar(_,1,0.3,decaytime:5)).dur(Song.secDur[25]+6).bus.index },
		dur: Song.parse(25,1!4).q,
		out:Pkey(\effect),
].pm(\sawSynth)

);
P(\wobble26,start:26,music: [
//		instrument:\sawSynth,
		amp:0.05,
//		instrument:\tri,
		freq:[1,2].df('d',octave:4 ).q(inf),
		effect:{ Effect(EchoNone.ar(_,1,0.3,decaytime:5),out:1).dur(Song.secDur[26]+5).bus.index },
		dur: Song.parse(25,1!4).q,
		out:Pkey(\effect),
].pm(\sawSynth)

);
P('tune25',start:25,music:Song.currentSong.pbind[25]
);
['we can wait a few more hours',[1,2,3,4,5,6,5].dm('d')].addLine;
P(\resolution26,start:26,syl:5,music:{ |parent durs|
		[
				freq:[2,1].df('g',octave: 4).q,
//				dur:durs.q,
				dur:parent.parse(26,[1],6).q++[2].q,
		].pp
}
);
P('tune26',start:26,music:Song.currentSong.pbind[26]
);
//	// (see ../vocoder2.scd for voice of Sargon)	
//	['/*MCCOY:*/ And what if we should decide against you? '].addLine;
['/*MCCOY:*/ And what if we decide against you? ', [7,6,5,4,5,6,7,12,11.5].dm('e')].addLine;
P(\resolution27,start:27,syl:6,music:{ |parent durs|
		[
				freq:[3,2].df('e-',octave: 5,scale:\minor).q,
//				dur:durs.q,
				dur:parent.parse(27,[1,1],7).q,
				stretch:[1.1,1].q,
		].pp
}
);
P('tune27',start:27,music:Song.currentSong.pbind[27]
);
['/*SARGON [OC]:*/ (beat) Then you may',[1,5,5,4].dm('c#')].addLine;
P('tune28',start:28,music:Song.currentSong.pbind[28]
		=>Pbindf(_,\amp,[0].q++[0.1].q(inf))
);
P('extra-note28',start:28,music: (
		amp:0.04,
		freq:[1].df('a-',octave: [3, 4 ]),
		instrument:\sawSynth,
		)
);
[' go as free -- ly as you came.',[13,12,13,14,13,12,7,11].dm('c#')].addLine;
P('tune29',start:29,music:Song.currentSong.pbind[29]
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
P(\bass29,start:29,music:
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
//MUTEDP(\machine30,start:30,music:
	//MUTED{ 6.do{{ SinOscFB.ar(100.rand+300+SinOscFB.kr(1/5,3,mul:5),SinOscFB.kr(1/2,3).unipolar*3,0.1) =>LPF.ar(_,6000)=>Pan4.ar(_,rrand(-1,1),rrand(-1,1))
	//MUTED=>EchoNone.ar(_,1,0.6,3)
	//MUTED* 0.04
//MUTED}.play(s)} }
//MUTED);
Song.current
)
