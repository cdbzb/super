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
			=>Out.ar(\out.kr(0),_)
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
		dur: Song.currentSong.parse(14,[1,2/3,[1/3,1],1/2,1/2]).q,
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
		dur:Song.currentSong.parse(14,[1,1,1,1]).q,
	].p );
	P(\bassKnow, start:14, music:
		[
			freq:[Rest()].q++[4,4,4,5,11,11,7,7].df('a-',octave:1).q,
			dur: Song.currentSong.parse(14,[1,1/3,1/3,1/3,1,1/4,1/4,1/4,1/4]).q ,
			amp:0.02,
		].pm(\pluckD)
	);
	P(\temp,start:14,music:Song.currentSong.pbind[14]=>Pbindf(_,\amp,0.3,\instrument,\stringyy));
	['I know what he is and what he wants, ',[15,14,13,12,14,13,7,11,12.5].dm('a-')].addLine; //15
	P(\tune15,start:15,music:Song.currentSong.pbind[15]=>Pbindf(_,\instrument,\stringyy,\amp,0.3)
	);
	P(\bass,start:15,music:[
		amp:0.02,
		freq:[6,6,6,6,5,5,5,5].df('a-',octave:1).q,
		dur:Song.currentSong.parse(15,1!8).q,
	].pm(\pluckD);
	);
	P(\figure15,start:15,music:[
		out:3,
		freq:[13,11,7,6].df('a-',octave:3).q,
		dur: Song.currentSong.parse(15,2!4).q,
		instrument:\sawSynth,
		amp:0.05,
	].p
	);
	['and I don`t fear him. ',"r"].addLine; //16
	['/*MCCOY:*/ That`s the most ridiculous statement I`ve ever heard. An alien practically hijacks your body and then corks you into a bottle and',"r"].addLine;
	['/*MULHALL:*/ I`m afraid that I must agree with Doctor McCoy. You could be suffering from a form of false euphoria. ',"r"].addLine;
	['/*KIRK:*/ Sargon. ',"r"].addLine;
	['/*SARGON [OC]:*/ I understand, my son. Go to your vessel. All who are involved must agree to this. After all these centuries, we can wait a few more hours. '].addLine;


	// (see ../vocoder2.scd for voice of Sargon)
	['/*MCCOY:*/ And what if we should decide against you? '].addLine;
	['/*SARGON [OC]:*/ Then you may go as freely as you came.'].addLine;
)
