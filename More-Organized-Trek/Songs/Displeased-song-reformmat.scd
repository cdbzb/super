(
Song.new(\displeased,[]).current;
	Song.currentSong.condition=Condition.new;
	Song.currentSong.infrastructure={
		FunctionList.new.array_([
			~synthsLoaded.isNil.if{"/Users/michael/tank/super/song-Synthdefs.scd".load},
			{fork{
				try{~syn1.controller.loaded.not.if{~syn1=~synful2.()}}{~syn1=~synful2.()};
				try{~syn1.controller.loaded.not.if{~syn1=~synful3.()}}{~syn1=~synful3.()};
				~syn1.condition.wait;
				Song.currentSong.condition.test_(true).signal;
				SynthDef(\syn1_Bus,{|out=0| 
					Env.linen(0,Song.currentSong.durTillEnd).kr(2,gate:1);
					Out.ar(out,In.ar(~syn1.bus.index,2))
				}).add;
			}},
		]).value
	}.inEnvir;

~quarters=SongArray.new();
[ "trill","r",[5] ].addLine; //0
( ~synTrill={ 
		|chan=1 amp=0.3 transpose=0 len=6|
		Pfindur(
			len,
			Pbind(*[
				type:\midi,midiout:~syn1.controller.midi,
				note:Pseq([6,8],inf)+transpose,
				dur:Pwhite(0.1,0.12)*0.8,
				amp:Pwhite(0.1,0.11),
				pan:rrand(-1,1),
				amp:amp,
				chan:chan
			])
		);
	}; 
);

SynthDef(\plate_phaser_insert,{
	|inBus=0 gate=1|      
	var env= Env.cutoff(15,curve:\cub).kr(2,gate:gate);
	var sig = In.ar(inBus,2);
	sig=PlateReverb.ar(sig,mix:0.5,decayTime:0.55);
}).add;

P(\trill,start:0,lag:0.1,music:
	{ |p b e| 
		var reverbBus = Bus.audio(s,1);
		var reverb = Synth(\plate_phaser_insert,[\inBus,reverbBus.index,\gate,1]);
		~syn1.syn.set(\out,reverbBus.index);
		fork{
			var trillLength = Song.currentSong.secDur[0..1].sum;
			~syn1.expression(40,1);
			~syn1.expression(30,0);
			0.05.wait;
			~synTrill.value(0,0.9,12,len:trillLength).play;
			~synTrill.value(1,1.9,4,len:trillLength).play;
			{
				Song.secDur[0..1].sum.wait;
				reverb.release;
				~syn1.syn.set(\out,0);
				reverbBus.free;
			}.fork
		} 
	}
); 
[ "I am not displeased my husband- ","d#5 c# c a#4 g# f# f d# c# " ].addLine; //1
~justTheTune.('husband');
[ "r your body is r r  not unlike ","c#3 f4 d# c# g#3 f#2 f# f#4 f d#" ].addLine; //2
~justTheTune.('unlike');
[ "that which was your own (dum dum dum)","d-4 c d- b-3  g-3 f g- a-" ].addLine; //3
~justTheTune.('your own');
[ "and I too am pleased beloved", [3,2,4,3,3,2,1,-7].dm('d' ) ].addLine; //4 -or Bb!
~justTheTune.('beloved');
[ " boom after so- long... (boom) so very long... Kiss ","d3 a b e4 d f g3 b c4 a3 e4 r" ].addLine; //5
~justTheTune.('very long');
P(\afterSoLongSketch,start:'very long',music: {|p b e|
		var afterSoLong=[\r,4,5,8,7,9]++[\r,5,6,4,7] + [ 2,2,2,2,2,2,2,2,2,2,3 ].collect{|i| [0,i]};
		(degree:1,octave:4,dur:6).play;
		[
			legato:1.05,
			degree:Pseq(afterSoLong)-1,
			dur:b.q
		].pp;
		[
			degree:Pseq([1,-3]),
			dur:b.parse([6,5]).q
		].pp
	}
);
P(\bassNotes54,start:'very long',music: 
	{ |p b| 
		[
			dur: b.parse([6,5]).q,
			degree: Pseq([1,4],2) ,
			legato:[1.1,0.9].q,
			octave:3,
			amp:1
		].pp
	}
);
//TempoClock.tempo=1.5.reciprocal;
//[ "(boom)...so very long... Kiss","g3 b c4 a3 e4 r" ].addLine; //6
//~justTheTune.('so very long');
[ "(kissing) r r r r r r r r ..","g#5 f# d# b4 a# g# e5 d# " ].addLine; //7
P(\bowedKissing,start:'kissing',music:
	{ |p b|
		Pfx(
			[ 
				//				tempo:0.8,
				instrument:\trem2,
				rate:Pbrown(2,0,0.3),
				degree:Pseq([6,5,3,1,7-7,6-7,4,3,5-7]-1),
				root:-1,
				octave:[6,4],
				scale:Scale.major,
//				dur:Song.currentSong.durs[7]++Pseq([2.5]),
				dur:b++[2.5] => _.q,
				legato:1,
				mtranspose:Pseq([ [0,2,4,7],[0,3,5,7],[0,2,5,7],[0,2,4,7],[0,3,5,7],[0,4,6,7],[0,2,4,7],[0,3,5,7],[0,7] ].collect(_-7)),
			].p.pad,
			\verb,\wet,0.3
		).play  
	}
);
P(\bassKissing,start:'kissing',music:
	(instrument:\sawSynth,rel:15,att:1,octave:2,amp:0.17,degree:4,root:-1,mtranspose:[0,4,7],dur:10)
);	
SynthDef(\verb,{|out wet=1 | 
	var in=In.ar(out);
	var sig =PlateReverb.ar(in);
	XOut.ar(out, wet, sig*2)}
).add; 
[ " r","f#4" ].addLine; //8
//}.fork

["/*SPOCK*/ This is an excellent body, Doctor." ,"r"].addLine;
["I seem to have received the best of the three. ","r"].addLine;
["Strength, hearing, eyesight, all far above your human norms. ","r"].addLine;
["I'm surprised the Vulcans never conquered your race. ","r"].addLine;
//get this from reaper
// /Users/michael/tank/Trek/Vulcan's worship peace/Vulcan's worship peace.RPP 
["/*MCCOY*/ Vulcans worship peace above a-- ll, Henoch. ",[5,5,4,4,3, 2,1,2,3, -6,-5].dm('d')].addLine;
~justTheTune.('worship');
~quarters[\worship] = Song.parseBeats('worship',"e e e e qqq e e e eq q q".asBeats);
P(\harmonyPart,start:'worship',music:{|p b e|
	[
		freq:[2,2,2,2,1].df('a',octave:5 ).q,
		dur:b.parse([1,1,1,1,1]).q,
	].pp
}
);
P(\worshipBase,start:'worship',music:{|p b e|
	[
		freq:[4,4,5,5,1,1,5,5,5,6,7].df('d',octave:3 ).q(2),
		dur:
		 "e e e e qe e e q e qe e".asBeats.q(2),
	].p => _.fin(16)=>_.play(~quarters[e.start].asTempoClock)
}
);
P(\pianoWorship,start:'worship',music:{|p b e|
	[
		freq:[-6,-6, -5,1,3,2,-5].df('d',octave:5 ).q,
		pan:3/4,
		dur:~quarters['worship']
		//		.quantizeWindow
		.parse("e eqe e e e e e".asBeats).q
	].pp

}
);
//["/*SPOCK*/ Yes, of course, Just as we do, Doctor. ",[7,5,4,5,7,12,11,5,3].dm('e',octave:5 )].addLine;
["/*SPOCK*/ (boom) Yes, (boom) of course, Just as we do, Doctor. ",[-7,7,-7,5,4,5,7,12,11,5,3].dm('e',octave:5 )].addLine;
~justTheTune.('of course');
P(\ofCourseBass,start:'of course',music:{|p b e|
	[
		freq:[\r,4,3,2].df('e',octave:[2, 3 ]).q,
		dur:b.parse([4,3,4])++[3] =>_.q,
		instrument:\stringyy,
		amp:0.2,
		wet:0.2,


	].pp
}
);
["(Mulhall/Thalassa collapses and they help her back onto the bed.) ","r",[5]].addLine;

P(\collapseTremolo,start:'collapses',music:{|p b e|
	~syn1.expression(127,0);
	~syn1.expression(127,1);
//	~syn1.monitor.isRunning.not.if{~syn1.monitor=Synth(\syn1_Bus)};
	~syn1.patch(\violas,\trem,0);
	~syn1.setOut(Effect(FreeVerb.ar(_,0.8,0.8)).bus.index);
//////////
//idea delays without interpolation in the four channels
//////////
	~syn1.patch(\violins,\trem,1);
	(
		type:\vst_midi,
		vst:~syn1.controller,
		freq:[-7,2,4,6].df(\e,scale:\minor,octave:4),
		amp:1,
		dur:b.sum,

//		instrument:\trem,
	).play

});
P(\tympanyCollapse,start:'collapses',music:{|p b e|

	(freq:[-2,2].df(\e,octave:3,),).play
}
);
// irregular harp glissandi
["/*MCCOY*/ Nurse! ","r"].addLine;
["(Then Kirk/Sargon gets dizzy.) ","r"].addLine;
["/*CHAPEL*/ Doctor? ","r"].addLine;
["/*MCCOY*/ Henoch, you'd better get back to bed too. ","r"].addLine;
)
// to Unnecessary
