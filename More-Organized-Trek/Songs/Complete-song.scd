( // ~complete lyric and tune	{{{1
	// line 246

	/*
	Song.dursFile_("/Users/michael/tank/super/theExtreme3-legacy");
	*/

	~complete=Song(\complete, []).current;

	~complete.resources=();
	~complete.addGuides.("xxx.xxxxxxx");
	~complete.condition=Condition.new;
	~complete.infrastructure={ //bass patch lasts as long as end (durTillEnd){{{ ~xtreme.condition.test_(false);
		FunctionList.new.array_([
			~synthsLoaded.isNil.if{"/Users/michael/tank/super/song-Synthdefs.scd".load},
			{fork{
				try{~syn1.controller.loaded.not.if{~syn1=~synful2.()}}{~syn1=~synful2.()};
				~syn1.condition.wait;
				~complete.condition.test_(true).signal;
			}},
		]).value
	}.inEnvir;
	//~syn1.isNil.if({~syn1=~synful2.()},{~syn1.controller.loaded.not.if{~syn1.init}});
//	~complete.cursor_(0); //	{{{2
	//"/Users/michael/tank/super/song-hello-beet.scd".load;
	TempoClock.tempo=1;
["the tran - fer is com-"," f5 c a-4 e c#"].addLine;  //0
P(\bassnotes,start:0,syl:3,music:
			Pseq([
				(note:1-24,amp:0.5,dur:~complete.durs[0].list[4]),
				(note:1-24,amp:0.6,dur:5,sustain:2)
			])
);
P(\chord0,start:0,syl:3,music://{{{
	Pfx(
		Pseq([
			(note:[1,8,13]-24,instrument:\sawSynth,release:4,strum:0.03,dur:~complete.durs[0].list[4]),
			(note:[1,8,13]-24,instrument:\sawSynth,release:5,strum:0.03,dur:11),
			(note:\r,dur:12),
		]),\phase_verb
	)
);//}}}
P(\pad0,start:0,music:
	Pbind(\midinote,Pseq(~complete.tune[0].list[0..3])-[0,12],\instrument,\sawSynth,\dur,~complete.durs[0]);
);
			   ["plete. metabolic rate is","c#4 c5 b-4 c5 a-4 d4 c5"].addLine; //1
["double and rising, Doctor...r  Hel- ", "d5 b-4 c#5 g c# a-4 g r b"].addLine; //2
P(\bassnotes3,start:2,music:
	(note:-2-12,amp:0.1)
);
P(\bassnotes4,start:2,syl:2,music:
	(note:[7,-5],amp:0.1,sustain:2)
);
			["lo. r r r"," c#5 d2 d d"].addLine; //3
P(\helloImage,start:3,music:
	p{
		{
			a=Image.open("/Users/michael/tank/super/Spock.png");
			w=a.plot(freeOnClose:true).alwaysOnTop_(true);
			//w.alwaysOnTop_(true);
		}.defer(s.latency);
		{
			5.wait;
			{w.close}.defer;
		}.fork
	}
);
P(\helloChord,start:3,music:
	(instrument:\test,midinote:~panNotes.("<d4 f# a c#>").flatten,strum:0.03,amp:0.4)
);
~helloTempo=1/~complete.durs[3].list.mean;
~helloTemp2=1/(~complete.durs[4].list[0..6].sum/5*2);
P(\helloSequence,start:3,music:
	p{
		{
			var bus,clock,monitor,
			kickPatterns,kickBar,snarePatterns,snareBar,synth,helloBass2,helloBass1,helloBeat;
			bus=Bus.audio;clock=TempoClock.new;
			//}}}
			kickPatterns=[[3/4,1/4],1];//{{{
			p=[0,0,0,0,1,1,1,0]++[1,0,1];   ///XTENDED
			kickBar=Pseq(p.collect{|i|kickPatterns[i]}.flatten);
			//}}}
			snarePatterns=[[Rest(3/4),1/4],[Rest(1)],[Rest(1/2),1/2],[Rest(1/2),1/4,1/4],[Rest(1/4),1/4,1/2]];//{{{
			p=[0,1,2,0, 0,3,0,4]++[0,4,4];   ///XTENDED
			snareBar=Pseq(p.collect{|i|snarePatterns[i]}.flatten);
			//}}}
			synth= Pbind( //{{{
				\note,Pseq([2-24,2-12,-1-12,9-12])-12,
				\instrument,\sawSynth,
				\dur,2,\rel,5,
				\amp,0.2) ;
				//}}}
				helloBass1=Pbind(//{{{
					\note, Pseq([2,4],4)-24,
					\legato,Pseq([1,Pwhite(0.25,0.55,1)],4),
					\amp,0.5
				) ;
				//}}}
				helloBass2=Pbind(//{{{
					\note,Pseq([\r,2,0],8),
					\dur,Pseq([1/2,1/4,1/4],inf),
					\amp,0.04
				) ;
				//}}}
				helloBeat= { |synthamp=0.3 drumsamp=1 tempo1=(52/60) tempo2=(50/60)|
				Ppar([
					Pbind(
						\tempo,Pseq([tempo1,tempo2]),\dur,4,\note,\r),
						Pbind(
							\instrument,\kick1,
							\dur,kickBar,
							\amp,drumsamp*0.1
						),
						Pfin(
							42, Pn( ///XTENDED
								Pbind(\instrument,\hihat, //ffreq rel
									//\dur,Pseq([0.245,0.255],32),
									\dur,Pseq([0.245,0.255],32),
									\amp,Pseq([Pwhite(0.3,0.4,1),Pwhite(0.2,0.3,1)],32)*0.4*drumsamp,
									\lag, Pseq(
										(1!16++(-1!16)).scramble*0.003),
										\ffreq, Pwhite(6000,6500),
										\rel,0.15
									) ,2
								)
							),
							Pbind(
								\instrument,\snare,
								\dur,snareBar,
								\amp,drumsamp*0.1
							),
							Pfx(
								Pbind( \instrument,\sawSynth,
									\note,Pser(~panNotes.("d f# a c#5 e5").flatten-60,16),
									\dur,1/2,
									\att,0.5,
									\octave,Pser(4!5++(5!5)++(6!5)++(7!5),42),
									\amp, Pseq(( 0.1!5 )++(0.09!5)++(0.08!5)++Pseries(0.07,-0.005))
								).pad,
								\phase_verb2
							),
							//~helloBass1,
							//~helloBass2,
							Pset(\amp,synthamp,synth),
							//Pseq([(\type:\rest,dur:4),~complete.pbind[4]]);//remove
							//	Ptpar([
							//		0.15,~helloGtr1,
							//		0.15,~helloGtr2
							//	])
						],1   /// repeats!!
					)<>(out:bus)};

					'self bus '.post;bus.postln;
					~complete.helloSequenceBus=bus;
					~complete.helloSequenceMonitor=Monitor.new.play(bus.index,2,0);
					{s.bind {helloBeat.(synthamp:0.1,drumsamp:0.7,tempo1:~helloTempo,tempo2:~helloTemp2).play(clock)}};
				}.play
			}
);
["you are a lovely female, r a","e5 d c# b4 a f# e e2 c#4"].addLine;//4
P(\drumPan4,start:4,music:
p{
	~complete.helloSequenceMonitor.play(
		~complete.helloSequenceBus.index,2,1,1,
		fadeTime:~complete.secDur[4..5].sum,
		volume:0.2);

	}
);
P(\bass4,start:4,syl:6,music:
	(instrument:\sawSynth,note:[7,-5]-12,amp:0.2,sustain:2,att:1.0,rel:3)
);
["pleasant sight to wake up to after","e4 d c# d e b a f# a "].addLine; //5
P(\bass5,start:5,syl:4,music:
	(instrument:\sawSynth,note:[7,-5]-13,amp:0.2,sustain:2,att:1.0,rel:3)
);
["half a million years- r r ","f5 g f e  e d c# c#"].addLine;//6
~phrase6quarter=~complete.durs[6].list.[0..6].sum/6;
P(\bass6,start:6,music:
	Pseq([
		(note:5-24,dur:~phrase6quarter*3,amp:0.5),
		(note:4-24,dur:~phrase6quarter,amp:0.5),
		(note:7-24,dur:~phrase6quarter*4,amp:0.5),
	])
);
~durs6=~complete.durs[6].list;
P(\yow6,start:6,music:
	Pbind(\instrument,\yowbass,
		\note,Pseq([[-3,0],[-3,0],[-5,-1]]),
		\dur,Pseq( [~durs6[0..2].sum,~durs6[3],~durs6[4..8].sum]),
		\amp,0.03,
	),
);
P(\keys6,start:6,music:
	Pbind(
		\instrument,\harp,
		\midinote,Pseq(~panNotes.("f5 a4 c5")-[0,12]),
		\dur,//Pseq(
			~
			complete.durs[6].list.[0..1]
			.sum/4
		//) //make a function for this
	)
);
P(\keys62,start:6,syl:5,music://{{{
	Pbind(
		\instrument,\stab,
		\note,Pseq([ [7,9,13],[7,9,13],[5,9,14] ]),
		\dur, Pseq(~complete.durs[6].list.[6..7]++[1]) ,
		\amp,Pseq([1,1.3,1])*0.8,
		\out, [1,1,1].q
	)
);//}}}
["r r you're welcome","d5 f4  g5 f "].addLine;//7
P(\bass7,start:7,syl:0,music://{{{
	Pseq([
		(note:5-24,dur:~phrase6quarter*3,amp:0.5),
		//(note:4-24,dur:~phrase6quarter,amp:0.5),
		//(note:7-24,dur:~phrase6quarter*2,amp:0.5),
	])
);
P(\keys7,start:7,syl:0,music://{{{
	Pbind(
		\instrument,\harp,
		\midinote,Pseq(~panNotes.("f5 a4 c5")-[0,12]),
		\dur,//Pseq(
			~
			complete.durs[7].list.[1..2]
			.sum/4
		//) //make a function for this
	)
);
P(\yow7,start:7,syl:0,music:
	(instrument:\yowbass,note:[-3,0,5],dur:3,amp:0.05)
);
["I've forgotten what it fee-","g#4 e b f# a# b c#5"].addLine;//8
SynthDef(\tromboneVerb,{ |room=0.8 mix=0.7| //{{{
var sig=In.ar(111,2);
sig=FreeVerb.ar(sig,room:room,mix:mix)*3;
Out.ar([0,2],sig);
//ReplaceOut.ar(~syn1.bus,sig);
DetectSilence.ar(sig,time:2,doneAction:2) 
}
).add;
P(\pad8,start:8,music://{{{
		p{
			var du=~complete.durs[8].list;
			var dv=~complete.durs[9].list;
			var a=(instrument:\sawSynth,out:[[0,2],[2,0],1],midinote:[4,8,11]+60,att:4.5,rel:5,amp:0.05,lagTime:0.3).play;
			Pbind.new(*[
				type:\set,
				id:a[\id],
				freq: Pseq([ [4,8,11],[3,6,11],[3,6,10],[1,6,10],[1,4,10],[-1,4,8] ]+72).midicps ,
				dur:Pseq([du[0..1].sum,du[2..3].sum,du[4..6].sum,dv[0..1].sum,dv[2..5].sum,1 ])
			]).play;
		}
);
P(\trombone8,start:8,music: //{{{
	p{ | amp=0.9 exp=80|
		~syn1.monitor.clear;
		//Synth(\tromboneVerb);\verb.postln;
		~syn1.patch(\trombone,\none,3);
		~syn1.expression(84,3);
		Ppar([
			Pbind(*[
				type:\vst_midi,
				vst:~syn1.controller,
				chan:3,
				midinote: Pseq(~noteList.(["g#","c#","b3"]))-[12,36] ,
				dur:Pseq([~complete.secDur[8],~complete.secDur[9],3]),
				\amp:0.55 ])
				,
				[instrument:\tromboneVerb,dur:[5].q,addAction:\addToTail].p
			]).play;
			~syn1.monitor.play(~syn1.bus.index,2,111,2,fadeTime:0.05,volume:0.6);

		}
);
               ["ls like even to brea-","d#5 a#4 c#5 d# e f# "].addLine;//9
["th again, Sargon?"," g#5 f# b4 g g"].addLine;//10
P(\sargon10,start:10,syl:2,music://{{{
	Pseq([
		(note:[4,7,10],dur:~complete.durs[10].list[3],\amp:0.3),
		(note:[4,7,10],dur:~complete.durs[10].list[4],\amp:0.3)
	])
);
               ["Here, in this body","f e g f c"].addLine;//11
P(\pf11,start:11,music:
	Ppar([
		//(instrument:\cymbal,dur:13)
		//,
		Pbind(*[
			midinote:Pseq(
				~noteList.(["<a c5 f>","<g c5 e>","<b- d5 g>","<a c5 f>"])-12),
				dur:~complete.durs[11],
				strum:Pseq([0.01,0.01,0.02,0.01])
			]),
			Pbind(*[
				instrument:\test,
				amp:0.5,
				midinote:Pseq(
					~panList.("c g3 f c4"))-[ 12,24 ]-7,
				dur:~complete.durs[11],
			])
	])
);
//}}}
//~complete.pbind.do({|i x| var label = ("guide"++x).asSymbol; ~complete.label]=(start:x,music:i);label.postln});
//"xxx.xxxxxxx".do({|i n| var label="guide"++n.asSymbol; (i==$x).if {~complete.label]=(start:n,music:~complete.pbind[n])} });
~complete.loaded=1;

)
