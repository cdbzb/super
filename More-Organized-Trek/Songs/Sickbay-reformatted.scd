(
/// line 326
Monitor.new().play(2,2,0,2);
~stills=Stills("/Users/michael/trek/BySection/media/return to tomorrow.mov").current;
~speaker ? ~speaker=Library.at(\functions,\prep).("/Users/michael/tank/IR/Saane/Speakers_&_Telephones/Very_small_speaker_mono.wav");
Song.dursFile_("/Users/michael/tank/super/theExtreme_Sep18");
~sickBay=Song(\sickBay,[]).current;
["Sick Bay.. Sick Bay, Mc- Coy","e c f# d e g#"].addLine; //0
P(\guide0,start:0,music:~sickBay.pbind[0]=>Pfin(2,_));
P(\kirkFace,start:0,music:{
		{~stills.preview('kirk-face',~sickBay.secLoc[2],monitor:0)}.defer
});

P(\mcCoy0,start:0,syl:1,music: {
		[
				amp:0.03,
				instrument:\mcCoy,
				//out:~sickBay.mcCoyBus,
				out:Effect({|i| PartConv.ar(i,2048,~speaker)},out:0).bus.index,
				midinote: ~sickBay.tune[0].list [ 2..5 ].q,dur:~sickBay.durs[0].list[ 2..5 ].q
		].pp;
}); 
["Sar- gon here, i'm in your deck six brief- ing room","b- g- c  e- f g- a- b- b g# d "].addLine; //1
~justTheTune.('Sar- gon here');
["(enter Thalassa)","e5"].addLine; //f maj 7 //2
~justTheTune.('enter Thalassa');
P(\plucks5,start:5,music:{ 
		[ 
				degree:[Rest(),3,1,5-7,[3,6]-7].q-1,
				root:6,
				dur: ~sickBay.parse(5,[[1,1,1,1],1,0.66,[0.34,1],[1,1]]).q,
				octave:4,
				amp:0.3
		].pp 
});
P(\padBass5,start:5,music: 
		[
				degree:[\r,[1,5+7,3+14],[6-7,6,6+4,6+7]].q-1, //idea write 1 5' 3''
				root:6,
				octave:[2,3],
				instrument:\wash,
				out:[1,1,2].q,
				amp:0.2,
				att:2,
				dur:~sickBay.parse(5,[[1,1,1,1],[1,1,1],[1,1]]).q
		].p
);
P(\gliss,start:5,syl:6,music:{
		var a= (
				octave:4,q:2,cutoff:1900,
				degree:[6-7,3,6,8,9]-1,freqLag:10,root:6,
				instrument:\glissChord,
				out:2,dur:7,\rel:5,\att:9
		) .play;
		Song.durs[5].list[6..9].sum.wait;
		(type:\set,id:a[\id],degree:[1,5,8,11,12]-1,octave:4,root:2)
		=>Prout(_) => _.play
});
//glissChord
{Saw.ar(
		(\freq.kr(400,\freqLag.kr(2))
		+(LFBrownNoise1.ar(2!5))*rrand(0.99,1.01!5)
		=> Vibrato.kr(_,3,depth:0.004,delay:4,onset:4)))
		+ WhiteNoise.ar(0.001)
		* Env.asr(\att.kr(1),\amp.kr(1),\rel.kr(3)).kr(0,gate:\gate.kr(1))
		//=>MoogFF.ar(_,2800)
		=>RHPF.ar(_,Line.kr(0.1,2,17)*\cutoff.kr(1000),\q.kr(1))
		=>MoogFF.ar(_,6666,1,mul:2)
		=>Splay.ar(_)
		//=>FreeVerb.ar(_,1,\wet.kr(0.7)) *3
		=>( JPverb.ar(_,3,mix:\wet.kr(0.7))<!DetectSilence.ar(_,time:1,doneAction:2) ) 
		=>Out.ar(\out.ir(2),_)
}=>SynthDef(\glissChord,_)=>_.add; 
["You sound ter- ri- ble wait there for me","c4 d e c g3 e-4 d b-3 f"].addLine;  //3
~justTheTune.('ter- ri');

P(\mcCoy3,start:3,music: {
		Song.currentSong.pbind[3]<>(instrument:\mcCoy,
				//out:~sickBay.mcCoyBus,
				out:Effect({|i| PartConv.ar(i,2048,~speaker)},out:0).bus.index,
				amp:0.03
		) => _.play  
});
P(\static3,start:3,music: 
		(instrument:\crackle,dur:5,out:~sickBay.mcCoyBus,amp:0.3)
);
["Sar- gon what's wrong?","b4 g b e5"].addLine;  //4
P(\image,start:4,music:{{
		~stills.preview('whatsWrong?')
}.defer(0.01)});
P(\whatsWrong4,start:4,music:
		Ppar([
				Song.currentSong.tune[4]<>(instrument:\sawTw,\amp:0.5)

				,
				[		instrument:\sawTw,
						dur:~sickBay.parse(4,[[1,0.5],[0.5,1,1]]).q,
						spread:3,
						degree:[\r,4].q,
						out:[0,1,2],
						root:0,
						octave:[3,2],
						amp:0.5
				].p,
				Pseq([(degree: [5,7,10]+[0,0,0,7,7,7]-1 ,octave:4,strum:0.1,amp:0.1,sustain:1)])
		])
); 
P(\verbFade4,start:4,music:{~sickBay.thalassaVerb.release(5)});
["no- thing of im- portance, Fa- tigue per- haps","f g- a- g- b- g- b- a- g- e-"].addLine;  //5
~justTheTune.('Fa- tigue');
P(\padBass5,start:5,music: 
		Prout({
				var b, p = (out:2,root:6, instrument:\wash, amp:0.2, att:2,); //proto
				var a=~sickBay.parse(5,[[1,1,1,1],[1,1,1],[1,1,1]]);
				a[0].wait;
				(dur:a[0],octave:[2,3],degree:[1,5+7,3+14]-1,proto:p).play;//chord1
				a[1].wait;
				b=(proto:p,type:\note,octave:[2,3],degree:[6-7,6,6+4,6+7]-1,freqLag:10).play;//chord2
				b.postln;
				a[2].wait;
				(type:\set,id:b[\id],degree:[5.1-7,5.1,5.1+4,5.1+7]-1,root:6,octave:[2,3]).play//bend
		});
); 
P(\doorOpen,start:2,music: 
		//~stills.set('enter-Thalassa',(37*60+54.30));

		Prout({
				var vol=0.5;
				var thalassaBus=Bus.audio(s,1).index;
				~sickBay.thalassaVerb=Synth(\verbb,[\in,thalassaBus]);
				s.bind{Synth(\door,[\amp,vol])};
				1.05.wait;
				{~stills.preview('enter-Thalassa')}.defer(0.01);
				0.01.wait;
				(
						out:thalassaBus,
						amp:vol,
						instrument:\sawTw,
						degree:[4-7,6-7,8-7,10-7,4,6,8,10]-1,
						strum:0.1,octave:[5],sustain:4
				).play;
		})

); 
["(beat) (formula) Sar- gon's for- mu- la...","d d5 e f# a f# c"].addLine;  //6
~justTheTune.('(formula)');

["yes, I wan- ted to be cer- tain there was no","f4 c#4 c c# f c# c b-3 a- b- e-4"].addLine;  //7
P.tune('cer- tain');
["er- ror. For- mu- la is co- ","d4 f3 g a b g b "].addLine; //8
P.tune('For- mu- la');
["rrect. Don't be concer -- ned, this is an","d4 c# e d f# g f# d e f# "].addLine;  //9
P.tune('rrect.');
P(\lick,start:\rrect,music:{|p b e| 
		[
				freq:[5,4,3,2,1].df(\e,scale:\minor,octave:[3,4]).q,
				dur:b.parse([1,1,1,1,3]).q,
				legato:1!4++5 =>_.q
		].pp;
});
["ex- cel- lent bo- dy. "," g#4 e d d c#"].addLine; //10
P.tune('ex- cel');
P(\strum,start:'ex- cel',music:{|p b e| 
		(
				strum:0.055,
				freq:[-5,-7,1,3,5,7,11,13].df(\e,scale:\mixolydian),
				dur:{rrand(2,4)}.dup(4),
				out:Effect(MoogFF.ar(_,SinOsc.ar({ 2.0.rand }.dup(4)).range(580,2000)*0.5),inputChannels:2).bus.index
		).play
});
P.tune('bo- dy');
["There I feel be- tter al- rea- dy","c4 g3 a b c4 b3 a b d4 c"].addLine; //11
P.tune('be- tter');
//in Time
["in Time a host  -- body will become... (cis)  ",[-1,1,-7,1,2,1,-7,-6,-7,1,-2].dm(\b,scale:\minor)].addLine; //12
P(\chords,start:\Time,syl:0,music:{|p b e| 
		[
				instrument:\sawSynthSustain,
				freq:[[1,11,13,15],[-7,12,14,17],[-6,11,13,16]].df(\b,scale:\minor).q,
				strum:0.05,
				dur:b.drop(1).parse([3,3,4]).q
		].pp;
});
P.tune(\Time);
["(d a fis) accustomed to us (fis)",[1,2,3,7,12,11,7,11,3].dm(\d)].addLine;
P.tune(\accustomed);
["injections will no longer be necessary",[6,5,4,3,4,5,6,2,4,3,2,1].dm(\d)].addLine;
P.tune(\injections);
["/*KIRK:*/ That will take months, perhaps years. We haven't that choice, Thalassa. ",[1,-7,1,3, 2,1,5,2,5,4.5,5,6,11,7,6,5].dm(\c)].addLine;
P.tune(\months);
P(\bass,start:\months,music:{|p b e| 
		[
				freq:[11,7,6,5.5,11.5,12,[6]].df(\c,octave:3).q,
				dur:b.parse([1,1,1,3,1,5,2]).q,
				legato: [1,1,1,0.9, 1,0.1, 1].q
		].pma(\sawSynthSustain).play
});
["/*MULHALL:*/ Husband. Feel the touch of my hand, husband. ", [3,2, 7,6,6,5,4,6, 5,4].dm('a-',scale:\minor)].addLine;
P.tune(\Feel);
Song.setQuarters(\Feel,[3/8,7/8,1/8,1/8,1/4,1/8,1/8,1,1/4,1/4]);
P(\click,start:\Feel,music:{|p b e| 
		[
				instrument:\stringyy,
				amp:0.34,
				freq:[1,-7,-4].df('a-',scale:\minor,octave:[3,4]).q,
				dur:Song.quarters[\Feel],
				amp:1
		].pp;
});

["/*KIRK:*/ No, beloved. (boom) If we torment ourselves ",[6,5,3,1,-1, 4,5,11,7,6,5].dm(\f)].addLine;
P.tune(\torment);
P(\dyads,start:\torment,music:{|p b e| 
		VoiceLeading([
				[2,3, -6,-7],
				[7,\_, -4,-5]
		],b.parse([0.5,[0.5,1],2,4])).df(\c,scale:\mixolydian).pp
});
["/*MULHALL:*/ Beloved. What will that word mean to a machine? ","r"].addLine;
["/*KIRK:*/ Our thoughts will intertwine. ","r"].addLine;
["/*MULHALL:*/ Will they, husband? ","r"].addLine;
[ "Will they intertwine like this? ","r" ].addLine;
P.still(\embrace,start:'Will they',timecode:3914.542.seconds,music:{|p b e| 
		e.still.value()
});
[ "Can two minds press close like this?","r"].addLine; 
P.still(\embrace,start:'press close',timecode:3915.542.seconds,music:{|p b e| e.still.value()});
["Can robot lips do this?" ,"r" ].addLine;
P.still(\embrace,start:'robot lips',timecode:3920.5.seconds,music:{|p b e| e.still.value()});
[ "(they kiss, then Kirk falls gently to the floor) Sargon, what is it? ","r"].addLine;
P.still(\kiss,start:'kiss',timecode:3924.seconds,music:{|p b e| e.still.value()});
["(McCoy and Chapel enter.) ","r"].addLine;
["hypo","r"].addLine;
["/*MULHALL:*/ Doctor, help him! ","r"].addLine;
["/*MCCOY:*/ He's dead.","r"].addLine;
)
(


~speakerSt.isNil.if {Library.at(\functions,\prepStereo).("/Users/michael/tank/IR/Saane/Speakers_&_Telephones/Small_speaker_stereo.wav")};

//Stills   ! {{{
~stills.isNil.if{~stills=Stills("/Users/michael/tank/Trek/video for stills etc/media/return to tomorrow.mov")}; 
~stills.set('whatsWrong?',2288.6);
~stills.set('kirk-face',(38*60+2.81));
~stills.set('enter-Thalassa',(37*60+54.30));     
~stills.set('sargonsFormula',2291.43); 
	//sections
	//P(\guide1,start:1,music:~sickBay.pbind[1]);
	//should this be done as an event?	

