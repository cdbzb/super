( //line 178 ~/tank/Trek/return-to-tomorrow.txt
	
	~synthsLoaded.isNil.if{"/Users/michael/tank/super/song-Synthdefs.scd".load};
	Song(\chamber,[]).current;
	['Kirk briefly convulses with pain', "c" ].addLine;//0
	P(\pains0, start:0, music: { 
		Song.chamber.painSynth={
			Impulse.ar(
				LFBrownNoise0.ar( 5 +1.0.rand!4) *100
			)
			* 0.5
			=>Out.ar(\eut.kr(0),_)
		}.play 
	});
	['then the sphere glows bright again' , "c"].addLine;//1
	Song.chamber.durs[0]=[3].q; Song.chamber.durs[1]=[8].q;
	P(\sphere1, start:1, music: {
		{
			{ Song.chamber.painSynth.free }.sched(Song.chamber.secDur[1]);
			Saw.ar( LFBrownNoise2.ar(0.1,3!4)*1300+20, 0.1 )
			*  Env.asr(16,1,5).kr(0,gate:\gate.kr(1))
			=> CombC.ar(_,0.5,\delayTime.kr(0.2,0.1,3))
		}.play.dur(Song.chamber.secDur[1],5)
	});
	['and he falls to his knees.' ,"r" ].addLine;//2
	P(\knee,start:2,music:(
		out:[0,1,2,3],
		strum:0.05,
		note:Arpeggio([0,3,7,11],20),
		dur:3,
	));
	Song.chamber.addLine ( [ /*MCCOY*/ 'Is it you, Jim? (a nod)', "c"  ] );//3
	Song.chamber.addLine ( ['Good, his metabolic rate is back to normal.',"r"] );//4
	['/*SPOCK:*/ Captain, do you know what happened? Do you remember any part of it? ',"r"].addLine; //5
	['/*KIRK:*/ Yes. ',"r"].addLine; //6
	['Sargon borrowed my body. ',"r"].addLine; //7
	['I was floating in time and space. ',"r"].addLine; //8
	['/*MCCOY:*/ He doesnt appear to be harmed. Physically, anyway. ',"r"].addLine; //9
	['/*KIRK:*/ Spock, I remember. ',"r"].addLine; //10
	['When Sargon and I exchanged, ',"r"].addLine; //11
	['as we passed each other, for an instant...',"r"].addLine; //12
	['we were one. ',"r"].addLine; //13
	P(\convergenceTest,start:13,music:{
		{ // we are one idea
			var divergence = Bus.control(s,4);
			{ { LFBrownNoise2.kr(90) }!4 => Out.kr(divergence,_) }.play;
			{ 
				Saw.ar( In.kr(divergence.index,4)
				*  Line.kr(40,0,dur:6)
				+ [5,10].df() 
				+ LFBrownNoise2.kr(20,mul: Line.kr(30,0,dur:6))
				,0.1)
				*  Env.linen(1,5,3).kr(2)
			}.play;
			(dur:10,freq:[1,3,5,7].df(octave:3),out:[0,1,2,3],amp:0.3).play;
		}.value;
	});
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
			FreeVerb.ar(_,0.5,1),out:[0,1],inputChannels:2).bus.index 
			 => DetectSilenceDry.ar(_,doneAction:2)
		}

	));
	P(\figure15,start:15,music:[
		rel:4,
		strum:0.02,
		instrument:\sawSynth,
		amp:0.05,
		freq:
		[  [1,3,5,7].df('c#') ,[1,3,5,7].df(\c,scale:\minor),[3,5,7, 11].df(\g,scale:\mixolydian,octave:3) ].q
		//		[  [1,3,5,7].df(\f,scale:\minor),[1,3,5,7].df('e-'),[3,5,7, 11].df(\g,scale:\mixolydian,octave:3) ].q
		,
		dur: Song.parse(15,[4, 4,1]).q,
		hifreq:8000,
		effect:{ Effect({|i|
			MoogFF.ar(i,2000,2)
			* 1.3
			=>( CombC.ar(_,0.5,SinOsc.kr(0.3).range(0.4,0.405),decaytime:4)+Gain.ar(_,3) )
			=> DetectSilenceDry.ar(_,doneAction:2)
			//			 =>Mix.ar(_)
		},out:2,inputChannels:2).bus.index },
		out:Pkey(\effect),
		//		 out:2,
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
			effect:{ Effect(MoogFF.ar(_,5000,3),out:2,inputChannels:2).bus.index },
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
	{
		{ 
			Impulse.ar(0)
			=>Decay.ar(_,0.05)
			* ClipNoise.ar(0.1)
			=>MembraneHexagon.ar(_,tension:0.008,loss: 0.99996) 
			=>Out.ar(\out.kr(0),_)
		}
		=>SynthDef(\membrane,_)=>_.add; 
		(instrument:\membrane,out:2) 
	}.value
);
P(\line17,start:17,music:{
	{Pulse.ar(\freq.kr(300),0.1,\amp.kr(0.1))* Env.perc(0.01,1).kr(2,gate:\gate.kr(1))=>Out.ar(\out.kr(0),_)}
	=>SynthDef(\twang,_)=>_.add;
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
		).bus.index },
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
	effect:{ Effect({|i| FreeVerb.ar(i,0.5,1)  =>  DetectSilenceDry.ar(_,doneAction:2) },inputChannels:2).bus.index },
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
P('swell20',lag: -0.1,start:20,music:{
	SynthDef(\swell20,{
		var freq = \freq.kr(300);
		//			var width = 4;
		var width = [4,5];
		Env.perc(\attack.kr(1),\release.kr(1),\amp.kr(0.1),\curve.ir()).kr(2,gate:\gate.kr(1))
		* Gendy1.ar(minfreq:freq-width,maxfreq:freq+width)
		/ 2
		=>Out.ar(\bus.kr(0),_)
	}).add;
	(curve:'sin',instrument:\swell20,attack:2,release:5,amp:0.04,freq: [1,11].df('c',octave: 3)).play
}
	);
	['/*MULHALL:*/ I`m afraid that I must agree with Doctor McCoy. You could be suffering from a form of false euphoria. ',"r"].addLine; //21
	['/*KIRK:*/ Sargon. ',"r"].addLine; //22
	['/*SARGON [OC]:*/ I understand, my son. Go to your vessel.', [11,11,11,11,7,7,7,11,12,14,13].dm('c')].addLine; //23
	P(\tuneSargon,music:Song.pbind[23]
	);
	P(\bass23,syl:8,start:23,music:
		{ |parent durs| 
			[
				freq: [1].df('c',octave: 2).q(1),
				dur: durs.sum,
			].pp
		}
	);
	P(\chordsSargon,lag:-0.0,music:{|parent durs| 
		[
//			effect:{var a=Bus.audio;Synth(\phaser,[\in,a.index],addAction:\addToTail);a.index}.value,
			effect:{var a=Bus.audio;
//				Synth(\phaser,[\in,a.index],addAction:\addToTail);
				{In.ar(a.index) => DetectSilenceDry.ar(_,doneAction:2,time:3) => Phaser2.ar(_) => Out.ar(0,_)}.play(addAction:\addToTail);
				a.index}.value,
//			effect:Effect({ |i| 
//				DetectSilenceDry.ar(i,doneAction:2,time:3)
////				=> Phaser2.ar(_,rate:1/5) 
//				=> LeakDC.ar(_)
//				=> Decimator.ar(_,8000,8)
//				//				=>PlateReverb.ar(_,mix:0.5) 
//			},inputChannels:2).bus.index,
			out:Pkey(\effect),
			legato:0.95,
			dur:durs.q,
			freq: [2,4,6,11].dup(4) ++ [2,4,5,7].dup(2) => _.df('c',octave:3)=>_.q ,
		].p.play
	});
//	['All who are involved must agree to this. After all these centuries, we can wait a few more hours. '].addLine;
//
//
//	// (see ../vocoder2.scd for voice of Sargon)	
//	['/*MCCOY:*/ And what if we should decide against you? '].addLine;
//	['/*SARGON [OC]:*/ Then you may go as freely as you came.'].addLine;
)
