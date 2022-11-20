(
/// line 326
Monitor.new().play(2,2,0,2);
~stills.isNil.if{~stills=Stills("/Users/michael/trek/BySection/media/return to tomorrow.mov").current};
//Song.dursFile_("/Users/michael/tank/super/theExtreme_Sep18");
~sickBay=Song(\sickBay,[]).current;
Song.speaker =Library.at(\functions,\prep).("/Users/michael/tank/IR/Saane/Speakers_&_Telephones/Very_small_speaker_mono.wav");
SynthV.setRole(\Thalassa,\aiko);

P(\filter,start:0,music:{|p b e| 
		p.pts.select{|i| i.still.notNil}.select{|i| i.name.asString.contains("halass") }.do{|i|i.monitor.postln}
});

["Sick Bay.. Sick Bay, Mc- Coy","e c f# d e g#"].addLine; //0
P(\guide0,start:0,music:~sickBay.pbind[0]=>Pfin(2,_));
P.still( \kirk, start:0 , timecode:3802.81.seconds, music: { |p b e|
		e.still.value(
				wait: b.sum,
				monitor:0
		);
});
P(\mcCoy0,start:0,syl:1,music: { |p b e|
		[
				amp:0.03,
				instrument:\mcCoy,
				//out:~sickBay.mcCoyBus,
				out:Effect({|i| PartConv.ar(i,2048,p.speaker)},out:0).bus.index,
				midinote: ~sickBay.tune[0].list [ 2..5 ].q,dur:~sickBay.durs[0].list[ 2..5 ].q
		].pp;
}); 
//TODO Sargon should sound sick!
["Sar- gon here, i'm in your deck six brief- ing room","b- g- c  e- f g- a- b- b g# d "].addLine; //1
P.tune('Sar- gon here');
["(enter Thalassa)","e5"].addLine; //f maj 7 //2
P.tune('enter Thalassa');
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
		fork{
				var a= (
						octave:4,q:2,cutoff:1900,
						degree:[6-7,3,6,8,9]-1,freqLag:10,root:6,
						instrument:\glissChord,
						out:2,dur:7,\rel:5,\att:9
				) .play;
				Song.durs[5].list[6..9].sum.wait;
				(type:\set,id:a[\id],degree:[1,5,8,11,12]-1,octave:4,root:2).play
		}
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
P.tune('ter- ri');
P(\mcCoy3,start:3,music: { |p b e|
		Song.currentSong.pbind[3]<>(instrument:\mcCoy,
				//out:~sickBay.mcCoyBus,
				out:Effect({|i| PartConv.ar(i,2048,p.speaker)},out:0).bus.index,
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
P.tune('Fa- tigue');
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
P.tune('(formula)');
["yes, I wan- ted to be cer- tain there was no","f4 c#4 c c# f c# c b-3 a- b- e-4"].addLine;  //7
P.tune('cer- tain');
Song.quarters['cer- tain']=Song.parseBeats('cer- tain',[1.5,0.5,0.5,0.5,0.5,0.5,1,0.5,0.5,0.5,0.5,]);
P(\chords,start:'cer- tain',music:{|p b e| 
	[
		freq: [[1,3,5],[1,3,5],[-7,3,5],[-7,3,5],[-7,3,5],[-6,3,5],[-6,2,5]].df('c#') ++ [[1,3,5]].df('b-',octave:4) => _.q,
		dur: p.quarters[e.start] ++ Song.durs[\rrect].list[0..2] => _.q,
		out: Effect({|i|CrossoverDistortion.ar(i,0.01,0.9,0.4) => DelayC.ar(_,0.2,SinOsc.ar(5).range(0,0.001)) =>MoogVCF.ar(_,SinOsc.ar([0.11,0.1,0.13]).range(900,2000),0.8) * 2},inputChannels:3).bus.index

	].pp
	
});
P(\bass,start:'cer- tain',music:{|p b e| 
	[
		freq: [1,1,-7,-7,-4].df('c#',octave:3).q,
		dur:[3,1,3,1,4].q/2
	].p.play(p.quarters[e.start].asTempoClock);
});
["er- ror. For- mu- la is co- ","d4 f3 g a b g b "].addLine; //8
P.tune('For- mu- la');
P(\bass,syl:1,start:'For- mu- la',music:{|p b e| 
		{
			b.postln;
						[1,-7].df(\g).dq.demand 
						(b.parse([[1,1,1,1/2],[1/2,1]]))
//						,
				=> { |i| 
						Saw.ar(i * [0.99,1,1.013]/[4,8] , 0.1) 
						+SinOsc.ar(Vibrato.kr(i*[ 2,4 ] + [0,2]),0,0.005)
				} 
				=>MoogFF.ar(_,3000,1)
				=>Phaser2.ar(_,rate:0.09)
				* Env.perc(Line.kr(0.01,0.05,1),Line.kr(3,5,1)).kr(0,gate:TDuty.kr(b.parse([ [1,1,1,1/2],[1/2,1] ].dropLast).dq))
				=> EchoNone.ar(_,0.444,0.444,2.5) * 0.5
		}.play

});
["rrect. Don't be concer -- ned, this is an","d4 c# e d f# g f# d e f# "].addLine;  //9
P.tune('rrect.');
P(\lick,start:\rrect,music:{|p b e| 
		{|i|
				
				[5,4,3,2,1].df(\e,scale:\minor).dq.demand(b.parse([1,1,1,1,3]))
				=> {|freq|
						Pulse.ar( freq / [2,4], 0.2 ,0.1)
						// AAAARh
						* Env.perc( 0.3, [ [3,3,3,3,6].dq.demand(b),b[0..4].dq.demand(b),1 ]).kr(0,gate:b.parse([1,1,1,1,3]).dropLast.tduty)
                             //.kr( 0, gate:TDuty.kr(b[0..4].dq))
						*0.2
						=> FreeVerb.ar(_,0.2,1)

				}
		}.play
				//legato:1!4++5 =>_.q
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
["in Time a host  -- body will become...  ",[-1,1,-7,1,2,1,-7,-6,-7,1].dm(\b,scale:\minor)].addLine; //12
Song.synthVTracks=();
Song.synthVTracks.aiko= { |preGain=1 ratio=2 amp = (1/8) len=2000 mix=0.1 |
	{ |i|

		i.() * preGain
		=> SoftKneeCompressor.rms(_,  thresh:-10, ratio: ratio, knee:6, attack:0, release:0.05, makeUp:0, rms:40) 
		* amp
		=> DWGReverbC1C3.ar(_,len:len,mix:mix)
		=>.first DetectSilence.ar(_,doneAction:2)
	}
};
P.synthV(\aiko, \Time, [lyrics:"in taim a ho ost ba di will bi kum "], music:{ |p b e|
		{
			e.playbuf  =>
			p.synthVTracks.at(e.key).()   
		}.play
});
Song.quarters[ \Time ]=Song.parseBeats(\Time,[1,3,3/4,1/4,2,1,1,1.5,0.5,1]);
P(\chords,start:\Time,music:{|p b e| 
		[
				instrument:\sawSynthSustain,
				freq:[\r,[1,11,13,15],[-7,12,14,17],[-6,11,13,16]].df(\b,scale:\minor).q,
				strum:0.05,
				amp:0.04,
				legato:0.5,
			//	dur:b.drop(1).parse([3,3,3]).q
				dur:[ 3 ,4,4,2].q,
		].p.play(clock:p.quarters[\Time].asTempoClock);
});
P(\bass,start:\Time,music:{|p b e| 
	[
		freq: [\r,1,-7,-6,-7,1] ++ ([2,3,4,5]*.t[1,-1])
		++ [\r,\r,\r,[5,-5]]
		=>_ .df(\b,scale:\minor,octave:[3]) 
		=>_.q,
		instrument:\sawSynth,
		dur: [2,8,8,2,2,2,2,2,2,2, 2,2,2,2,2].q/2
	].p.play(clock:p.quarters[e.start] ++ p.quarters[\accustomed] =>_.asTempoClock)
});

["(cis d a fis) accustomed to us (fis)",[-7,1,2,3,7,12,11,7,11,3].dm(\d)].addLine;

P.synthV(\aiko, \accustomed,[lyrics:"u ku stum too us"],range:[4,8],syl:3, music: { |p b e|
		{
			e.playbuf  =>
			p.synthVTracks.at(e.key).()   
		}.play

});
Song.quarters[\accustomed]=Song.parseBeats(\accustomed,[1,1,1,1,1,0.5,0.5,0.5,0.5]);
P.tune(\accustomed);
P(\extraNote,start:\accustomed,syl:4,music:{|p b e| 
	(
		freq: [-12,-5,1].df(\a),
		dur:b[0..( b.size-2 )].sum
	).play
});
//P(\bass,start:\accustomed,music:{|p b e| 
//
//	[
//		freq: []		instrument:\sawSynth,
//		dur: [2,4,2,2,4,2,2,2,2,2,2,2,2,2].q/2
//	].p.play(clock:p.quarters[e.start] ++ p.quarters[\accustomed] =>_.asTempoClock)
//});
["injections will no longer be necessary",[6,5,4,3,4,5,6,2,5,3,2,1].dm(\d)].addLine;


//Song.injectVocaloid.writeProject
//Song.injectVocaloid.open

//"~/scripts/renderVocaloid.sh injections".unixCmd

P(\bass,start:\injections,syl:0,music:{|p b e| 
	[
		instrument:\sawSynthSustain,
		freq: [[-4,12,-2],-5,-1].df(\d,octave:[5]).q,
		amp:[[0.07,0.03,0.02],0.05,0.05].q,
		legato:0.8,
		dur:b.drop(1).parse([4,3,4]).q,
		out:(-1)+[[5,4,3],2,1].q
	].pp;
});
P(\lick,start:\injections,syl:1,music:{|p b e| 
	[
		freq: [6,5,4,3,4,\r,5,4,3].df(\d,octave:4).q,
		dur: b.drop(1).parse([1,1,1,1,1,2,1,1,1]).q,
		att:0.1,
		out:Effect(MoogFF.ar(_,1100,2.6),out:3).bus.index,
		freqLag:0.01,
		legato:[1,1,1,1,0.5,0,1,1,1].q
	].pma(\sawSynthSustain).play;
});
P.synthV(\aiko,\injections,
	[
		lyrics:"in jek shuns will no lan gur bi ne se sse ri"
	],
	// legato:,
	music:{|p b e|
	
		{
			e.playbuf  =>
			p.synthVTracks.at(e.key).()   
		}.play
});
P(\lick2,start:\injections,syl:0,music:{|p b e| 
	[
		freq: [5,4,3,2,1,2].df(\d).q,
		instrument:\sparkTriangle,
		out:Effect(MoogFF.ar(_,1100,2.6),out:2).bus.index,
		amp:0.04,
		dur:b.drop(1).q,
		legato:1,
		freqLag:0.05
	].pma(\sparkTriangle).play;
});
["/*KIRK:*/ That will take months, perhaps years. We haven't that choice, Thalassa. ",[1,-7,1,3, 2,1,5,2,5,4.5,5,6,11,7,6,5].dm(\c)].addLine;
P.tune(\months);
P(\extraNotes,start:\months,syl:2,music:{|p b e| 
	[
		freq: [[7,3].df(\e,scale:\mixolydian),[7,3].df(\a,scale:\mixolydian),[5,7].df(\d,scale:\mixolydian),[4,6,12].df(\d),[3,5].df(\d)].q,
		dur:b.drop(1).parse([3,6,1,1,1,1]).q,
		legato:[3,6,1,2,2].reciprocal.q,
		instrument:\wash,
		amp:0.05
		
	].pp;
});
P(\bass,start:\months,music:{|p b e| 
		[
				freq:[11,7,6,5.5,11.5,12,[6]].df(\c,octave:3).q,
				dur:b.parse([1,1,1,3,1,5,2]).q,
				legato: [1,1,1,0.9, 1,0.1, 1].q
		].pma(\sawSynthSustain).play
});
["/*MULHALL:*/ Husband. Feel the touch of my hand, husband. ", [3,2, 7,6,6,5,4,6, 5,4].dm('a-',scale:\minor)].addLine;
P.synthV(\aiko,\Husband,
	[
		lyrics:"Hus band feel the tuch of my hand hus band",
		legato:[1,0.95,1,1,1,1,1,0.9,1,1] 
	],
	music:{|p b e|
		
		{
			e.playbuf  =>
			p.synthVTracks.at(e.key).()   
		}.play
});
P.still( \thalassa, start: \Feel, timecode:3854.seconds, music: { |p b e|
		fork{
				e.still.text_(["husband..."]).wait_(b.sum).monitor_(0).fade_(2).play;
				b[0..1].sum.wait;
				e.still.setText(["feel the touch","of my hand"]);
				b[2..7].sum.wait;
				e.still.setText(["husband"])
		}
});
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

["/*KIRK:*/ No, beloved. (boom) If we torment ourselves ",[6,5,3,1,-1, 4,5,11,7,6,5].dm(\f,4)].addLine;
P.synthV(\genbu,\torment,[
	lyrics:"no bi la ved r if wi tar ment ar selvs"
],music: {|p b e|
	{
		e.playbuf.() 
		=> p.synthVTracks.at(\aiko).()   
	}.play
}
);
P.tune(\torment);

P.still( \kirk, start: \torment, timecode:3859.seconds, music: { |p b e|
		e.still.value(
				wait: b.sum ,
				text:["No, beloved","if we torment ourselves"]
		);
});

P(\dyads,start:\torment,music:{|p b e| 
		VoiceLeading([
				[2,3, -6,-7],
				[7,\_, -4,-5]
		],b.parse([0.5,[0.5,1],2,4])).df(\c,scale:\mixolydian).pp
});
// Idea C min or Ab ala Waldstein?
["/*MULHALL:*/ Beloved. What will that word mean to a machine? ",[1,6,5].dm(\a)++[-7,1,5,3,-7,1,2,4,6].dm('c#',octave:6)].addLine;
//P.tune('to a machine');
P.synthV(\aiko,'to a machine',
	[
		lyrics:" bi lu ved? wat will zat word min tu a ma xin"
	],
	music: { |p b e|

		{
			e.playbuf  =>
			p.synthVTracks.at(e.key).()   
		}.play
});
P.still( \thalassa, start: 'to a machine', timecode: 3903.5.seconds, music: { |p b e|
		fork{
				e.still.value(
						wait: b.sum ,
						text:["beloved!?"]
				);
				b[0..2].sum.wait;
				e.still.setText(["what would that word","mean to a machine?"])
		}
});
P(\bass,start:'to a machine',syl:2,music:{|p b e| 
	[ instrument:\sawSynthSustain,
		freq: [-7,1,5,3,-6,-2].df('c#',octave:[3,4]).q,
		legato:1,
		att:0.7!5++3 =>_.q,
		lag:(-0.03)!5++0,
		out:[1,3],
		rel:2!5++4 =>_.q,
		amp:0.05,
		dur:b.drop(1).parse([1,1,1,1,4,1]).q
	].p.play
});
P.tune(\mean,{|i|Pbindf(i,\out,Effect(EchoNone.ar(_,0.4,0.3,4)).bus.index)},range:[0,2]);
P(\chord,start:\machine,syl:10,lag:-0.05,music:{|p b e| 
	(
		freq:[1,3,4.5,7].df(\c,scale:\minor),
		//TODO
		instrument:\stringyy,amp:0.15,
		out:[2,4],
		strum:0.1,
		dur:b.last-0.3,
		out:Effect.bus( { |i| TwoTube.ar(i,0.1,0.95,345,930)
	//	* Env([1,1,0],[b.sum,0.5]).kr(2,gate:1)
	} ).post;\BUS.postln


	).play
});


["/*KIRK:*/ Our thoughts boom boom boom boom will intertwine. (boom boom boom boom) ",[1,7,-1,-2,-3,-4,6,7,11,3, 1,2,3,4].dm(\d,scale:\dorian)].addLine;
P.still(\clear,music: {|p b e|
		e.still.(

			wait:b.sum,
			test:["our thoughts","will intertwine"]
		)
	}
);
P(\chord,syl:0,start:\thoughts,music:{|p b e| 
	[
		freq: [[1,3,5,7],\r,[-4,1,3],[-4,-7,2]].df(\d,scale:\dorian,octave:4).q,
		legato:1,
		dur: b.parse([5,3,2,2]).q,
		out:3,
		attack:0.5,
		instrument:\visual_vowel,
		amp:0.05
	].pp;
});
P.tune(\thoughts,Pbindf(_,\amp,[1,1,0,0,0,0,1,1,1,1,0,0,0,0].q/10,\legato,[1,3,0,0,0,0,1,1,1,3,0,0,0,0].q));
//idea - Will they - Will they
P.tune('thoughts boom',{|i| Pmul(\freq,0.5,i) =>Pbindf(
	_,
	\instrument,
	\sawSynth,
	\rel,4,
	\att,0.1,
	\amp,0.5,
	\out, Effect.bus({|i| MoogLadder.ar(i,Line.kr(500,900,3),1)},inputChannels:2),
	//\addAction,\addToTail
)},range:[2,5],syl:1);
P(\lick1,start:\thoughts,syl:8,music:{|p b e| 
	[
		freq: [4,2,3,4,5].df(\c).q,
		dur:b.drop(1).q,
		instrument:\cleanPluck,
		legato:4
	].pp
	
});
P(\lick2,start:\thoughts,syl:10,music:{|p b e| 
	[
		freq: [1,-6,-7].df(\c).q,
		dur:b.drop(1).q,
		amp:0.01,
		out:1,
		instrument:\harp,
	].pp;
});
["/*MULHALL:*/ Will they, husband?  Will they intertwine like this? ",[4,1,3,2].dm(\b,octave:5) ++ [-7,1,4,2,5,5.5,5,4,7].dm('c#')].addLine;
//P.tune('Will they');
/*
Song.synthV1.writeProject;
Song.synthV1.open;
*/

P.synthV(\aiko, 'Will they',
	[
		lyrics: "wil they huz band wil they in ter twa a an laik zis"
	], music: { |p b e|
	e.synthV.buffer.() => 
	 {|i| 
		
		{
			e.playbuf  =>
			p.synthVTracks.at(e.key).()   
		}.play
.play
	}
});
P(\bass_stab,start:'Will they',music:{|p b e| 
		[ instrument:\sawTw,
				freq:[1].df('c#',octave:[5,6,7]) ++ [1,4].df('b-',octave:[3,4,5]) => _.q,
				amp:0.05,
				dur:b.parse([2,2]).q,
				wet:0,

		].p.play
});

P(\extra_notes,start:'Will they',syl:11,music:{|p b e| 
		[
				freq:[[1,3,7],[2,4,7],[3,5,7],[-7,2,4,7]].df(\d,scale:\mixolydian).q,
				dur: b.drop(1) ++ p.durs[\press].list[ 0..3 ] + [0,0,0,1] =>_.q,
				instrument:\sawSynth,
				rel:[3,3,3,6].q,
				att:[3,3,3,6]/10=>_.q,
				amp:0.08

		].pp;
});

//P.tune('Will they int', {|i| 
//		Pbindf(i,\instrument,\stringyy,\amp,0.2)
//		=>Pmul(\freq,0.5,_)},
//		//TODO Why is syl not set automagically??
//		syl:3,range:[4,13]
//);
P(\this,start:'Will they',syl:11,music:{|p b e| 
		(
				instrument:\wash,
				freq:[1,3,5,7].df(\d,scale:\mixolydian),
				dur:2
		).play
});
P.still(\thalassa,start:'Will they',syl:3,timecode:3914.542.seconds,music:{|p b e| 
		{e.still.value(
				wait:b.sum,
				text:["will they intertwine","like this?"]
		)}.defer
});
P(\bass,start:'Will they',syl:11,music:{|p b e| 
		[
				freq:[1,2,3,4].df(\d,octave:3).q,
				amp:0.05,
				instrument:\sawSynthSustain,
				dur: b.drop(1) ++ p.durs[\press].list[ 0..3 ] =>_.q,
				legato:1,
				lagTime:0.1
		].pma(\sawSynthSustain).play;
				
});
P(\xtraBassnote,start:'Will they',syl:7,music:{|p b e| 
	(
		freq: [1].df('a-',octave:[2,3])
	).play
});
[ "Can two minds press close like this?",[5,6,7,6.5,6.5,6,11.5].dm(\c)].addLine;
P.synthV(\aiko,\press,
	[
		lyrics:" kan tu maindz press klos laik zis"
	],music: { |p b e|
	
		{
			e.playbuf  =>
			p.synthVTracks.at(e.key).()   
		}.play
	}
);
P(\chord,start:\press,syl:2,music:{|p b e| 
	[
		freq: [[1,3,4,7],[1,3,4,7],[1,3,4,6.5]].df(\c,scale:\minor).q,
		dur:b.drop(1).q,
		//instrument:\visual_pad, amp:0.2,
		out:3
	].pp
});
//P.tune(\press);
P(\this,start:\press,syl:5,music:{|p b e| 
		(
				instrument:\wash,
				freq:[-5,1,5,3].df(\a),
				dur:2
		).play
});
P.still(\thalassa,start:'press close',timecode:3915.542.seconds,music:{|p b e| 
		e.still.value(
				wait: b.sum,
				text:["can two minds press close","like this?"]
		)});
["Can robot lips do this?" , [3,5,4,3,2,11].dm(\e) ].addLine;
//P.tune(\robot);
P.synthV(\aiko,\robot,
	[ lyrics: "kan ro bot lips do zis" ],
	music:{ |p b e|
		{
			e.playbuf  =>
			p.synthVTracks.at(e.key).()   
		}.play
	}
);
P(\this,start:\robot,syl:4,music:{|p b e| 
		(
				instrument:\wash,
				freq:[1,3,5,7].df(\f),
				dur:b.sum,
				legato:0.8
		).play
});
P.still(\thalassa,start:'robot lips',timecode:3920.5.seconds,music:{|p b e| 
		e.still.value(
				wait:b.sum-2,
				fade:2,
				text:["can robot lips","do this?"]
		)});
[ "(they kiss, then Kirk falls gently to the floor) (boooom boom boom boom boom boom boom boom) Sargon, /*what is it?*/ what's wrong? ",[11,7,6,5,4,3,2,1].dm('b-',scale:\minor)++[3,-7,1,4.5].dm(\f,scale:\mixolydian)].addLine;
P.synthV(\aiko,\kiss, [lyrics:"Sar gon wats rong"],syl:7,range:[8,11],music: { |p b e|
		{
			e.playbuf  =>
			p.synthVTracks.at(e.key).()   
		}.play
		
});
P.still(\kiss,start:'kiss',
		timecode:3926.seconds
		//timecode:3927.5.seconds
		,music:{|p b e| e.still.value(wait:b[0..4].sum)}
);
P(\chord,start:\kiss,music:{|p b e| 
	(
		freq: [-11,1,11,13,16,26].df('c#'),
		instrument:\wash,
		amp:0.15,
		rel: 8
	).play
});
P.tune(\kiss,range:[8,12],syl:7);
P(\trem,start:\kiss,music:{|p b e| 
		var verb=Effect(FreeVerb.ar(_,1,Line.kr(0.7,1,5)),inputChannels:2).bus.index;
		var a=Synth(\trem2,[\out,verb]);
		Synths(\trem2,\freq, [-11,1,11,13,16,26].df('c#'),\amp,0.04,\out,0).dur(3,8);
		[
				type:\set,
				freq:[16,15,14,13,12,11,7,6,5.5,5,4.5,4,3,2.5,2,1.5,1].df('c#',octave:[4,5]).q,
				rate:11,
				id:a.nodeID,
				amp:Pseries(1,(-1/16), 16)/10,
				//dur: [3] ++ (1!19) /2 => _.q
				//dur: b.parse([1,1,1,1,1,1,1,1, 1,2/3,[ 1/3,1 ],1]).q
				dur: b[0..7] ++ (b[8..10].mean ! 8) => _.q
		].pp
});
P.still(\falling, start:\kiss, syl:4,  timecode: 3937.5.seconds,  music: {|p b e|
		e.still.value(
				//b.sum.wait
				wait:b[1..3].sum,
		)
});
P.still( \thalassa, start: \kiss,syl:7, timecode:3939.46.seconds, music: { |p b e|
		e.still.value(
				wait: b[0..3].sum ,
				text:["Sargon!","What's wrong?!"]
		);
});

["(McCoy and Chapel enter.) ","r",[1,3]].addLine;
P(\trill,start:\Chapel,music:{|p b e| 
	
	var strings = Synths(\stringyy,\freq,[7,11,7,11].df(\d),\out,(0..3));
	var bus = Bus.control(s,3);
	var time = 10;
	
	{SinOsc.kr(time.reciprocal/4)}.play(s,bus.index);
	{LFNoise0.kr(0.4).unipolar*30}.play(s,bus.index+1);
	//{Line.kr(0,0.3,10,doneAction:2)}.play(s,bus.index+2);
	{Env([0,1,0]/10,[10,0.1]).kr(doneAction:1)}.play(s,bus.index+2);
	fork{
		0.2.wait;
		bus.postln;
		strings.map(\mix,bus.index);
		strings.map(\width,bus.index+1);
		strings.map(\amp,bus.index+2);
		
	};
	//d=Synths(\wash,\freq,[7,1,-7].df(\d),\out,[(0..3)])
});
P.still(\mcCoyEnters, start:\Chapel,timecode: 3940.5.seconds, music:{|p b e|
		e.still.value(wait:b.sum);
		Synth(\door,[\amp,0.3])
});
["(wibble) hypo (hypo)",[33,3,-6.5,-16.5].dm(\c)].addLine;
P.tune(\hypo,range:[1,2],syl:0);
P(\wibble,start:\hypo,music:{|p b e| 
		
	fork{
		{
			SinOsc.ar( LFSaw.ar({rrand(3.0,4)}!4,{rrand(0,1.0)}!5).range(400,1800),0,0.01 )=>Splay.ar(_)
			* Env.linen(0.2, b[0..2].sum-0.2-0.5,  releaseTime: 1.0,  level: 1.0,  curve: \lin).kr(2)
		}.play;
		b[0..2].sum.wait;
		Synth(\door,[\amp,0.05,\out,Effect( BPF.ar(_,1000,7.5),out:1).bus.index ])
	}
});
		
P.still(\sensor, start:\hypo, timecode:3947.seconds, music:{ |p b e|
		e.still.value(
				wait:b[0..2].sum,
				text:["",""]
		);
		fork{
				b[0].wait;
				e.still.value(text:["hypo!"])
		}
});
P.still(\hypo, start:\hypo,syl:2, timecode:3949.5.seconds, music:{ |p b e|
		var window = e.still.value(
				wait:b.drop(1).sum
		);
		//fork{
		//		1.wait;
		//		defer{ e.still.text = "hypo" }
		//}
});


["/*MULHALL:*/ Doctor, help him! ",[1,-7,3,-7].dm(\e,scale:\mixolydian)].addLine;
P.synthV(\aiko,\Doctor,[ lyrics:" dak tar help him" ], music:{|p b e |
		{
			e.playbuf  =>
			p.synthVTracks.at(e.key).()   
		}.play
});
//P.tune(\Doctor);
		
P.still(\mulhall, start:'help him', timecode:3953.0.seconds, music:{ |p b e|
		e.still.value(
				wait:b.sum,
				text:["Doctor","help him!"]
		)
});
["/*MCCOY:*/ (boom) He's dead.",[-7,-5,1].dm(\d)].addLine;
P.tune(\dead,range:[1,2],syl:0);

P.still(\mcCoy,syl:0, start:\dead, timecode:4003.0.seconds, music:{ |p b e|
		e.still.value(
				wait:b.sum,
				text:["He's","dead"]
		)
});
)
/*
(


//Stills   ! {{{
~stills.isNil.if{~stills=Stills("/Users/michael/tank/Trek/video for stills etc/media/return to tomorrow.mov")}; 
~stills.set('whatsWrong?',2288.6);
~stills.set('kirk-face',(38*60+2.81));
~stills.set('enter-Thalassa',(37*60+54.30));     
~stills.set('sargonsFormula',2291.43); 
	//sections
	//P(\guide1,start:1,music:~sickBay.pbind[1]);
	//should this be done as an event?	

