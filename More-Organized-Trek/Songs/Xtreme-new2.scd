(
//Line 239 The three volunteers are lying on beds, with the spheres on tables beside them. 
~xtreme=Song( \song,[]).current;



//// xtreme sections		{{{2

~xtreme.condition=Condition.new();
( ~syn1.isNil or: try{ ~syn1.syn.isPlaying.not } ).if
	{
		Song.currentSong.synful1 = ~syn1 = Synful();
		Song.currentSong.synful2 = ~syn2 = Synful();
	}{

		Song.currentSong.synful1 = ~syn1;
		Song.currentSong.synful2 = ~syn2;
	};

 Song.resources.infrastructure_( {
	FunctionList.new.array_([
		{
			( ~syn1.isNil or: try{ ~syn1.syn.isPlaying.not } ).if
			{
				Song.currentSong.synful1 = ~syn1 = Synful();
				Song.currentSong.synful2 = ~syn2 = Synful();
			} 
		},
		{ fork {
			while( {
				~syn2.controller.loaded.not;
			},{0.05.wait});
			Song.resources.condition.test_(true).signal
		}}
	]).value
}.inEnvir;
);

Song.bassBuss=Bus.audio;
//SynthDef(\plateReplace,{|in gate=1| 
//	var sig=In.ar(Song.bassBuss.index,2);
//	sig=sig* Env.asr(0,1,0.1).kr(2,gate:gate);
//	ReplaceOut.ar(Song.bassBuss.index,PlateReverb.ar(sig,mix:0.9));
//}).add;
//SynthDef(\xtremeBass,{|amp=1 decimate=0 out=0| 
//	var sig = In.ar(Song.bassBuss.index)!2;
//	Env.perc(~xtreme.durTillEnd+1).kr(2,gate:1);
//	sig= XFade2.ar(sig,Decimator.ar(sig,rate:8000,bits:4)*(-6.dbamp),Lag.kr(decimate,1));
//	Out.ar(out,sig*amp)
//}).add;

~xtreme.condition.test_(false);
~xtreme.infrastructure={ //bass patch lasts as long as end (durTillEnd) 
//~syn1.condition.test_(false);
FunctionList.new.array_([
	//~synthsLoaded.isNil.if{"/Users/michael/tank/super/song-Synthdefs.scd".load},
	{~bassDecimator=Synth(\xtremeBass,[\amp,0.6,\decimate,-1])},
	{ ~bassVerb=Synth(\plateReplace) },
	Song.sendBasstoBus;
	{"LOADED".postln},
	{ Song.condition.test_(true).signal },
]).value
	}.inEnvir;
	//~syn1.condition.test
	//~syn1.controller.loaded
	//s.plotTreeL
	//~xtreme.resources.condition.test
	//~syn1.controller.loaded

	


	
	//~xtreme.parts=();

//	P(\bassT2,start:2,lag:0,music:{ 
//
//		//~bassVerb.set(\mix,0);
//		~bassVerb.release(0.1);
//		(type:\set,id:~bassDecimator.nodeID,args:#[\decimate],decimate:1,lag:0.05).play;
//	});
	//P(\bassT3,start:4,music:p{~bassDecimator.set(\decimate,-1)});
["the extreme power of the","g a b- d5 b-4 a g", ].addLine; //0
	P(\strum1, start:0,syl:2, music:
		(\note:[-5,-3,-2,2,5,7],\strum:0.03,\sustain:2)
	);
		P(\bassnote, start:0, music: 
			{ |p b e|
				(
					note: -24-5,
					amp:3,
					sustain:0.5 + Song.secDur[0],
					dur:Song.secDur[0]+0.5,
					out:Effect({
						|i| 
						i * Env.asr(0.1,1,0).kr(0,gate:1)
						=> PlateReverb.ar(_,mix:0.9) 
						* 0.6  
						* Env.linen(0, p.secDur[0..1].sum, 0.02).kr(2,gate:1)
					}).bus.index
				).play
			}
		);
["alien mind will make the -","e5 d c f e f g f", ].addLine; //1
		P(\strum2, start:1,syl:2, music: (lag:~xtreme.durs[1].list[3]/2,note:[-5,-2,0,4,7],strum:0.03,sustain:2));
		P(\bassnote2, start:1, music: 
			{ |p b e|
				(
					note: -12-5,
					amp:3,
					sustain:Song.secDur[1],
					//out:Song.bassBuss.index
					out:Effect({
						|i| 
						i * Env.asr(0.1,1,0).kr(0,gate:1)
						=> PlateReverb.ar(_,mix:0.9) 
						* 0.6  
						* Env.linen(0,p.secDur[1], 0.02).kr(2,gate:1)
					}).bus.index
				).play
			}
				
		);
["r r r r heart action dan ger ous ly high- ", "r r r r  c6 a5 f b- a g f g ", ].addLine; //2
		P(\heartActionBass, start:2, music: 
			{ |p b e|
				Pbind(
					\dur, ~xtreme.durs[2]++Pseq([1.0]),
					\note, Pseq([-2,-2,-2,0,-7,\r,\r,-2,-2,-2, 0,\r,-10])-24,\amp,2,
					\legato,Pseq([1 ,1, 1,1, 1.5,1,1, 1, 1, 1, 2, 1, 1]),
					\out, Effect(
						{|i|
							Decimator.ar(i,rate:8000,bits:4)*(-6.dbamp)
						}
					).bus.index
				).play
			}

		);
		P(\weeeeuw,start:2,music:
			{{FreeVerb.ar(Ringz.ar(WhiteNoise.ar(0.01),XLine.kr(2500,240,6),1),room:8,mix:7)*EnvGen.kr(Env.perc(0,7),doneAction:2)}.play});
			//~xtreme.weeeeuw.music= Pfxb.new(Pbind(\midinote,Pseries(60+36,-0.99,100),\dur,0.1,\sustain,1,\amp,0.01),\two_tube);
			//~xtreme.weeeeuw.music.play}}}
			{   ///tempo map for drums{{{
				var d= ~xtreme.durs[2].list[0..3] ++ ((~xtreme.durs[2].list[4]/2)!2).asList ++ ~xtreme.durs[2].list[5..8];
				P(\drums,start:2,music:
					Pbind( \instrument, Pseq([\kick2, \rest, \snare, \rest, \kick2, \kick2, \snare,\rest]++
					[\kick2, \rest, \snare, \rest, \kick2,  \kick2, \snare,\rest]),
					\dur,Pseq(d,inf),
					\lag,Pseq([0,0,-0.01,0,0,0,0,0],inf),
					//\amp,0.5
					\amp,Pseg([0.5,0.5,0.3]*0.5,[d[0..4].sum,d.sum-d[0..4].sum+1])
				));
				SynthDef (\cymbal, {|amp=1 length=2| 
					var sig=PinkNoise.ar(EnvGen.kr(Env.perc(0,length)))!2;
					sig=TwoTube.ar(RHPF.ar(sig,500,9),d1length:502,d2length:777,loss:0.99)*0.5;
					DetectSilence.ar(sig,doneAction:2);
					Out.ar(0,sig*amp)}
				).add; 
				P(\cymbal,start:2,music:
					Pbind( \instrument, Pseq([\rest, \rest, \rest, \rest, \rest, \rest, \rest,\rest]++
					[\rest, \rest, \rest, \rest, \cymbal, \rest, \rest,\rest]),
					\dur,Pseq(d,2),\lag,-0.05,\amp,0.4)
				);
				P(\hat,start:2,music:
					Pbind(\instrument, \hihat,
						\ffreq,Pwhite(4000,10000),
						//\dur,(Pser(d,48)),
						\dur,(Pser(d/4,96)),
						\amp,Pseg([0.5,0.5,0]*0.15,[d[0..4].sum,d.sum-d[0..4].sum+4.2])
					)
				);
			}.value;
			[" - and the body functions will", "a5 c d a g a d a ", ].addLine; //3
			P(\andthe,start:3,
				music:Pbind(\dur,~xtreme.durs[3]++Pseq([1]), \instrument,\test,
				\amp,1,
				\lag,Pwhite(-0.01,0.01),
				\midinote,Pseq([\r]++~xtreme.tune[3].list.copyRange(1,~xtreme.tune[3].list.size)++[79])-24));
[" race r r many times their natural me-", "g5 r r  e5 g5 a4 g5 f e g ", ].addLine; //4
			P(\strum3,start:4,music:
				(\note: [4,16,19]-12,\dur:3,\strum: 0.03);
			);
			P(\bass3,start:4,
				music:Pbindf(Panola.new("r c#2 e a1\\pdur[2.2]").asPbind,\dur,~xtreme.durs[4],\tempo,1,\amp,0.8)
			);
["tabolism so we're going to have to", " f5 e d c r g#4 a b c5 d e ", ].addLine; //5
				P(\bass5,start:5, music:
					Pbind(
						\midinote,(Pser(~xtreme.tune[5].list,4)++Pseq([71,71-7]))-36,
						\dur,Pseq(~xtreme.durs[5].list[0..3]++~xtreme.durs[5].list[4..6].sum++1),
						\amp,0.8,
						\lag,Pwhite(-0.02,0.02)
					)
				);
				P(\drums5,start:5,music:
					Pbind( \instrument, Pseq([\kick2, \kick2, \snare, \kick2, \kick2,] ),
					\dur,Pseq(~xtreme.durs[5].list[0..3]++~xtreme.durs[5].list[4..6].sum++1),
					//\lag,Pseq([0,0,-0.01,0,0,0,0,0],inf),
					//\amp,0.5
					//\amp,Pseg([0.5,0.5,0.3]*0.5,[d[0..4].sum,d.sum-d[0..4].sum+1])
				)
			);
			P(\hat5,start:5,music:
				Pbind(
					\instrument, \hihat,
					\ffreq,Pwhite(4000,11000),
					//\dur,(Pser(d,48)),
					//\dur,(Pser(d/4,96)),
					\dur,Pseq(((~xtreme.durs[5].list[0..3]++~xtreme.durs[5].list[4..6].sum++1)/2).stutter(2)),
					\amp,Pseq([1,0.4]*0.1,4))
				);
	P(\bassnote6,start:6,music:
		{
			Pbindf(Panola(" a1 g f").asPbind,\dur,Pseq([~xtreme.durs[6].list[1..2].sum]++~xtreme.durs[6].list[3..4]),\tempo,1,\amp,0.8).play
		}
				);
[" mo- ni- tor this very", "d5 c4 a4 f f5 e ", ].addLine; //6
				P(\pad6,start:6,music:
					{
						{
							var a=(instrument:\sawSynth,
								//midinote:[69,72,75]
								degree:[5,8,9]
								,att:2,rel:3,amp:0.05,lagTime:0.2).play;
								//a.set(\freq,[69,74,77].midicps)
								(type:\set,id:a[\id],freq:[69,74,77].midicps,lag:1.1).play;
								(type:\set,id:a[\id],freq:[71,74,77].midicps,lag:2.25).play
							}.value
						}
					);
					P(\cymbal5,start:5,music: 
						(\instrument:\cymbal,\lag:~xtreme.durs[5].list[1..4].sum);); 
						P(\tremolo6,start:6,syl:5,music:
							Pbind(
								/*\instrument,  \pluck ,*/
								\note,[7-12,7]*[1,2],
								\dur,Pwhite(0.05,0.1),
								\strum,0.01 ,
								\amp,Pseg([0.2,0.5*Pwhite(0.8,1.2,inf)*0.0001]*0.3,[5.1,1.9], \exp, \offset,0)
							) //TODO set synth
						);
		["carefully","e5 d b4 r r r", ].addLine; //7
						["r r r well... I ", "r r r a g#", ].addLine; //8
						P(\bass8,start:8,music: 
							Pbind(\note,Pseq([5,4,2,1]-24),\dur,~xtreme.durs[8],\amp,0.5)
						);
						P(\bass8Alt,start:8,music:
							Pbind(\instrument,\test,\note,Pseq([5,4])-[0+rand(0.02),12],\lag,Pseq([0,0]),\amp,0.5)
						);
						P(\strum8,start:8,syl:1,music:
							(note:[1,4,9]-12++[1,4],strum:0.04,sustain:2,lag:0.52,amp:0.05)
						);
		["guess that's as read- y as I'm gon- na ","g e- f g e- d- e- f g ", ].addLine; //9
		P(\strum9,start:9,music:
			(midinote:~panNotes.(" <g b- e-5 g5>").flatten-12,strum:0.042)
		);
		P(\bass9,start:9,music: 
			(note:~panNotes.("e-2").flatten-60,dur:2,amp:0.3)
		);
		["be. Rea- dy Sar- gon","a d5 c a4 f#", ].addLine; //10
		P(\tremoChord,start:10,music:
			Pfxb(
				Pfindur(~xtreme.durs[10].list[0],
				Ppar(
					[-3,0,3,5].collect{|i|
						Pbind(
							\note,i,
							\dur,Pwhite(0.05,0.08),
							\amp,Pseg([0.02,0.13,0.15,0],[0.3,0.3,1.9]),
							\pan,0.5
						)
					}.value;
				)
			),\verb_fade,\time,2
		);
	);
		P(\tremoChord2,start:10,syl:0,music:
			Pfxb(
				Pfindur(~xtreme.durs[10].list[1..4].sum-0.1,
				Ppar(
					[-3,0,2,6].collect{|i|
						Pbind(
							\note,i,
							\dur,Pwhite(0.05,0.08),
							\amp,Pseg([0.02,0.17,0.15,0],[0.4,0.6,1.9]),
							\pan,-0.5
						)
					}.value;
				)
			),\verb_fade,\time,2
		);
	);
	["(transformation!)","r",[ 15 ]].addLine;
	P(\transform,start:'transformation!',music:{ |p b e| 
		var dur = b.sum; 
			var pitches=~panNotes.("f#3 b- c4 e")+[0,12];
		s.bind{
			var chord=pitches.collect({|item index|  Synth(\trans,[\freq,item.midicps,\amp,0.1])});
			var chord2=pitches.collect({|item index|  Synth(\trans,[\freq,item.midicps,\amp,0.1])});
			//~xtreme.init;
			try{~fadeO.stop};
			//try{~syn1.controller.loaded.not.if{~syn1.init}}{~syn1=~synful.()};
			//try{~syn1.controller.loaded.not.if{~syn1.init}}{~syn1=~synful2.()};
			{dur.wait;chord.do{|i|i.release}}.fork;
			{dur.wait;chord2.do{|i|i.release}}.fork;
		};
		////cymbal
		(instrument:\cymbal,length:8).play;
		////strings
		//try{~syn1.monitor.free;};~syn1.monitor=Monitor.new;~syn1.monitor.play(~syn1.bus.index,2,0,2,fadeTime:0.05);
		//try{~syn2.monitor.free;};~syn2.monitor=Monitor.new;~syn2.monitor.play(~syn2.bus.index,2,2,2,fadeTime:0.05);
		~syn1.syn.set(\out,2);
		~syn2.syn.set(\out,0);
		//TODO these need to turn themselves off with DoneActions rather than routines
		{
			var v,w;
			v={var sig=In.ar(~syn1.bus);sig=FreeVerb.ar(sig,room:0.75,mix:0.55)*3;ReplaceOut.ar(~syn1.bus,sig)};v=v.play;
			w={var sig=In.ar(~syn2.bus);sig=PlateReverb.ar(sig,mix:0.55)*2;ReplaceOut.ar(~syn2.bus,sig)};w=w.play;
			{20.wait;v.free}.fork;
			{20.wait;w.free}.fork;
		};

		
		~syn1.setprog(3,5,0); ~syn1.setprog(4,5,1);
		//~syn2.setprog(3,5,0); ~syn2.setprog(4,5,1);
		~syn2.patch(\violas,\tremsulpont,0);
		~syn2.patch(\violins2,\tremsulpont,1);
		//FADE Synful
		{
			8.wait;"now!".postln;
			127.do(
				{|i|
					[~syn1,~syn2].do(_.expression((127-i),0));
					[~syn1,~syn2].do(_.expression((127-i),1));
					0.18.wait
				}
				);
		}.fork;
		//~syn2.expression(0,0)
		//~fade0

		s.bind{
			//(type:\midi,midiout:~syn1.controller.midi,\midinote:~panNotes.("f#3 b- c4 e").flatten-[0,12],dur:20).play;
			(type:\vst_midi,vst:~syn1.controller,\midinote:~panNotes.("f#3 b- c4 e").flatten-[0,12],dur:20).play;
			//(type:\vst_midi,vst:~syn1.controller,\channel:2,\midinote:~panNotes.("f#3 b-4 c4 e").flatten-24,dur:20).play;
			(type:\vst_midi,vst:~syn2.controller,\channel:2,\midinote:~panNotes.("f#3 b-4 c4 e").flatten-24,dur:20).play;
			~syn1.expression(127,0);
			~syn1.expression(127,1);
			~syn2.expression(127,0);
			~syn2.expression(127,1);
		};
		//tympani

		s.bind{{ |pitchScale=1.15 loss=0.99998 |
			var env=Env.linen(0,dur-5,8).kr(2,gate:1)*0.175;
			var numChannels=4;
			var exc = Dust.ar(2!numChannels)+Impulse.ar(0);
			var sig;
			exc = Decay.ar(exc,0.02);
			exc=Integrator.ar(exc,0.8,0.1);
			exc=PinkNoise.ar(exc);
			sig=MembraneCircle.ar(exc,[0.007,0.0073]*pitchScale,loss)*env;
			sig
		}.play;}
		
	});
["the tran - fer is com-"," f5 c a-4 e c#"].addLine;  //0
P.tune('tran -');
P(\bassnotes,start:'tran - fer',syl:3,music:
			Pseq([
				(note:1-24,amp:0.5,dur:~complete.durs[0].list[4]),
				(note:1-24,amp:0.6,dur:5,sustain:2)
			])
);
P(\chord0,start:'tran - fer',syl:3,music://{{{
	Pfx(
		Pseq([
			(note:[1,8,13]-24,instrument:\sawSynth,release:4,strum:0.03,dur:~complete.durs[0].list[4]),
			(note:[1,8,13]-24,instrument:\sawSynth,release:5,strum:0.03,dur:11),
			(note:\r,dur:12),
		]),\phase_verb
	)
);//}}}
P(\pad0,start:'tran - fer',music:
	Pbind(\midinote,Pseq(Song.tune[Song.section( 'tran -' )].list[0..3])-[0,12],\instrument,\sawSynth,\dur,Song.durs['tran -']);
);
			   ["plete. metabolic rate is","c#4 c5 b-4 c5 a-4 d4 c5"].addLine; //1
			   P.tune('plete. m');
["double and rising, Doctor...r  Hel- ", "d5 b-4 c#5 g c# a-4 g r b"].addLine; //2
P.tune('Hel-');
P(\bassnotes3,start:'Hel-',music:
	(note:-2-12,amp:0.1)
);
P(\bassnotes4,start:'Hel-',syl:2,music:
	(note:[7,-5],amp:0.1,sustain:2)
);
			["lo. r r r"," c#5 d2 d d"].addLine; //3
P(\helloImage,start:'lo. ',music:
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
P(\helloChord,start:'lo. ',music:
	(instrument:\test,midinote:~panNotes.("<d4 f# a c#>").flatten,strum:0.03,amp:0.4)
);
~helloTempo={1/Song.durs['lo. r'].list.mean};
~helloTemp2={1/(Song.durs['lovely female'].list[0..6].sum/5*2)};
P(\helloSequence,start:'lo. ',music:
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
					{s.bind {helloBeat.(synthamp:0.1,drumsamp:0.7,tempo1:~helloTempo.(),tempo2:~helloTemp2.()).play(clock)}};
				}.play
			}
);
["you are a lovely female, r a","e5 d c# b4 a f# e e2 c#4"].addLine;//4
P.tune('lovely female');
P(\drumPan4,start:'lovely female',music:
p{
	~complete.helloSequenceMonitor.play(
		~complete.helloSequenceBus.index,2,1,1,
		fadeTime:~complete.secDur[4..5].sum,
		volume:0.2);

	}
);
P(\bass4,start:'lovely female',syl:6,music:
	(instrument:\sawSynth,note:[7,-5]-12,amp:0.2,sustain:2,att:1.0,rel:3)
);
["pleasant sight to wake up to after","e4 d c# d e b a f# a "].addLine; //5
P.tune('pleasant sight');
P(\bass5,start:\pleasant,syl:4,music:
	(instrument:\sawSynth,note:[7,-5]-13,amp:0.2,sustain:2,att:1.0,rel:3)
);
["half a million years- r r ","f5 g f e  e d c# c#"].addLine;//6
P.tune('half a million');
~phrase6quarter=Song.durs['half a million years-'].list.[0..6].sum/6;
P(\bass6,start:'half a million',music:
	Pseq([
		(note:5-24,dur:~phrase6quarter*3,amp:0.5),
		(note:4-24,dur:~phrase6quarter,amp:0.5),
		(note:7-24,dur:~phrase6quarter*4,amp:0.5),
	])
);
~durs6=~complete.durs[6].list;
P(\yow6,start:'half a million',music:
	Pbind(\instrument,\yowbass,
		\note,Pseq([[-3,0],[-3,0],[-5,-1]]),
		\dur,Pseq( [~durs6[0..2].sum,~durs6[3],~durs6[4..8].sum]),
		\amp,0.03,
	),
);
P(\keys6,start:'half a million',music:
	Pbind(
		\instrument,\harp,
		\midinote,Pseq(~panNotes.("f5 a4 c5")-[0,12]),
		\dur,//Pseq(
			
			Song.durs['half a million'].list.[0..1]
			.sum/4
		//) //make a function for this
	)
);
P(\keys62,start:'half a million',syl:5,music://{{{
	Pbind(
		\instrument,\stab,
		\note,Pseq([ [7,9,13],[7,9,13],[5,9,14] ]),
		\dur, Pseq(Song.durs['half a million'].list.[6..7]++[1]) ,
		\amp,Pseq([1,1.3,1])*0.8,
		\out, [1,1,1].q
	)
);//}}}
["r r you're welcome","d5 f4  g5 f "].addLine;//7
P.tune('r r you');
P(\bass7,start:'r r you',syl:0,music://{{{
	Pseq([
		(note:5-24,dur:~phrase6quarter*3,amp:0.5),
		//(note:4-24,dur:~phrase6quarter,amp:0.5),
		//(note:7-24,dur:~phrase6quarter*2,amp:0.5),
	])
);
P(\keys7,start:'r r you',syl:0,music://{{{
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
P(\yow7,start:'r r you',syl:0,music:
	(instrument:\yowbass,note:[-3,0,5],dur:3,amp:0.05)
);
["I've forgotten what it fee-","g#4 e b f# a# b c#5"].addLine;//8
P.tune('what it fee');
SynthDef(\tromboneVerb,{ |room=0.8 mix=0.7| //{{{
var sig=In.ar(111,2);
sig=FreeVerb.ar(sig,room:room,mix:mix)*3;
Out.ar([0,2],sig);
//ReplaceOut.ar(~syn1.bus,sig);
DetectSilence.ar(sig,time:2,doneAction:2) 
}
).add;
P(\pad8,start:'what it fee',music://{{{
		p{
			var du=Song.durs['what it fee'].list;
			var dv=Song.durs['even to br'].list;
			var a=(instrument:\sawSynth,out:[[0,2],[2,0],1],midinote:[4,8,11]+60,att:4.5,rel:5,amp:0.05,lagTime:0.3).play;
			Pbind.new(*[
				type:\set,
				id:a[\id],
				freq: Pseq([ [4,8,11],[3,6,11],[3,6,10],[1,6,10],[1,4,10],[-1,4,8] ]+72).midicps ,
				dur:Pseq([du[0..1].sum,du[2..3].sum,du[4..6].sum,dv[0..1].sum,dv[2..5].sum,1 ])
			]).play;
		}
);
P(\trombone8,start:'what it fee',music: //{{{
	p{ | amp=0.9 exp=80|
		//~syn1.monitor.clear;
		//Synth(\tromboneVerb);\verb.postln;
		~syn1.patch(\trombone,\none,3);
		~syn1.syn.set(\out,0);
		~syn1.expression(84,3);
		Ppar([
			Pbind(*[
				type:\vst_midi,
				vst:~syn1.controller,
				chan:3,
				midinote: Pseq(~noteList.(["g#","c#","b3"]))-[12,36] ,
				dur:Pseq([Song.secDur['what it fee'],Song.secDur['even to br'],3]),
				\amp:0.55 ])
				,
				[instrument:\tromboneVerb,dur:[5].q,addAction:\addToTail].p
			]).play;
			//~syn1.monitor.play(~syn1.bus.index,2,111,2,fadeTime:0.05,volume:0.6);

		}
);
               ["ls like even to brea-","d#5 a#4 c#5 d# e f# "].addLine;//9
	       P.tune('even to br');
["th again, Sargon?"," g#5 f# b4 g g"].addLine;//10
P(\sargon10,'th again, S',syl:2,music://{{{
	P.tune('th again');
	Pseq([
		(note:[4,7,10],dur:Song.durs['th again, S'].list[3],\amp:0.3),
		(note:[4,7,10],dur:~complete.durs['th again, S'].list[4],\amp:0.3)
	])
);
               ["Here, in this body","f e g f c"].addLine;//11
P(\pf11,start:'Here, in this',music:
	Ppar([
		//(instrument:\cymbal,dur:13)
		//,
		Pbind(*[
			midinote:Pseq(
				~noteList.(["<a c5 f>","<g c5 e>","<b- d5 g>","<a c5 f>"])-12),
				dur:Song.durs['Here, in this'],
				strum:Pseq([0.01,0.01,0.02,0.01])
			]),
			Pbind(*[
				instrument:\test,
				amp:0.5,
				midinote:Pseq(
					~panList.("c g3 f c4"))-[ 12,24 ]-7,
				dur:Song.durs['Here, in this'],
			])
	])
);
//}}}
//~complete.pbind.do({|i x| var label = ("guide"++x).asSymbol; ~complete.label]=(start:x,music:i);label.postln});
//"xxx.xxxxxxx".do({|i n| var label="guide"++n.asSymbol; (i==$x).if {~complete.label]=(start:n,music:~complete.pbind[n])} });
~complete.loaded=1;

)
