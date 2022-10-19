(
s.waitForBoot{ Stills("/Users/michael/trek/BySection/media/return to tomorrow.mov").current;
//Line 239 The three volunteers are lying on beds, with the spheres on tables beside them. 
~xtreme=Song( \song,[]).current;
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
		}},

		{
			Song.unnecessaryBass=NodeProxy.audio(s,2).play; //	bass setup	
			Song.unnecessaryBass[1]=\filterIn->{|in|in+CombN.ar(in,1,0.25/TempoClock.tempo,2,mul:0.8)/2};
			Song.unnecessaryBass.set(\wet1,0.8);
			Song.unnecessaryBass[2]=\filter->{|in| Phaser1.ar(in,  depth: 0.5,  rate: 0.2,  fb: 0.3,  cfb: 0.1,  rot: 1.5707963267949) };
		},
		{TempoClock.tempo_(1)  }
	]).value
}.inEnvir.value;
);

Song.bassBuss=Bus.audio;
SynthDef(\plateReplace,{|in gate=1 bus| 
	//var sig=In.ar(Song.bassBuss.index,2);
	var sig=In.ar(bus,2);
	sig=sig* Env.asr(0,1,0.1).kr(2,gate:gate);
	ReplaceOut.ar(bus,PlateReverb.ar(sig,mix:0.9));
}).add;
SynthDef(\xtremeBass,{|amp=1 decimate=0 out=0 dur=1 bus| 
	var sig = In.ar(bus)!2;
	//Env.perc(~xtreme.durTillEnd+1).kr(2,gate:1);
	Env.perc(dur+1).kr(2,gate:1);
	sig= XFade2.ar(sig,Decimator.ar(sig,rate:8000,bits:4)*(-6.dbamp),Lag.kr(decimate,1));
	Out.ar(out,sig*amp)
}).add;

~xtreme.condition.test_(false);
~xtreme.infrastructure={
	//bass patch lasts as long as end (durTillEnd) 
	//~syn1.condition.test_(false);
	FunctionList.new.array_([
		//~synthsLoaded.isNil.if{"/Users/michael/tank/super/song-Synthdefs.scd".load},
		{~bassDecimator=Synth(\xtremeBass,[\amp,0.6,\decimate,-1, \bus,Song.bassBuss.index,\dur,Song.durTill(10)])},
		{ ~bassVerb=Synth(\plateReplace,[\bus,Song.bassBuss.index]) },
		Song.sendBasstoBus;
		{"LOADED".postln},
		{ Song.condition.test_(true).signal },
	]).value
}.inEnvir;
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
	{{FreeVerb.ar(Ringz.ar(WhiteNoise.ar(0.01),XLine.kr(2500,240,6),1),room:8,mix:7)*EnvGen.kr(Env.perc(0,7),doneAction:2)}.play}
);
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
	\midinote,Pseq([\r]++~xtreme.tune[3].list.copyRange(1,~xtreme.tune[3].list.size)++[79])-24)
);
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
		\amp,Pseq([1,0.4]*0.1,4)
	)
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
			var a = (
				instrument:\sawSynth,
				//midinote:[69,72,75]
				degree:[5,8,9]
				,att:2,rel:3,amp:0.05,lagTime:0.2
			).play;
			//a.set(\freq,[69,74,77].midicps)
			(type:\set,id:a[\id],freq:[69,74,77].midicps,lag:1.1).play;
			(type:\set,id:a[\id],freq:[71,74,77].midicps,lag:2.25).play
		}.value
	}
);
P(\cymbal5,start:5,music: 
	(\instrument:\cymbal,\lag:~xtreme.durs[5].list[1..4].sum)
); 
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
P(\strum9,start:'read- y',music:
	(midinote:~panNotes.(" <g b- e-5 g5>").flatten-12,strum:0.042)
);
P(\bass9,start:'read- y',music: 
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
	~syn1.syn.set(\out,Effect(FreeVerb.ar(_,0.75,0.55)*3).bus.index);
	~syn2.syn.set(\out,Effect( { |i| PlateReverb.ar(i,mix:0.55)*2 * Env.linen(0,b.sum,5).kr(doneAction:2,gate:1) } ,out:2).bus.index);
	//TODO these need to turn themselves off with DoneActions rather than routines

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
				0.18.wait;
				//'---->'.post;i.postln;

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
		(note:1-24,amp:0.5,dur:Song.durs['tran - fer'].list[4]),
		(note:1-24,amp:0.6,dur:5,sustain:2)
	])
);
P(\chord0,start:'tran - fer',syl:3,music:
	Pfx(
		Pseq([
			(note:[1,8,13]-24,instrument:\sawSynth,release:4,strum:0.03,dur:Song.durs['tran - fer'].list[4]),
			(note:[1,8,13]-24,instrument:\sawSynth,release:5,strum:0.03,dur:11),
			(note:\r,dur:12),
		]),\phase_verb
	)
);
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
P(\helloSequence,start:'lo. ',music: {
	{
		var bus,clock,monitor,
		kickPatterns,kickBar,snarePatterns,snareBar,synth,helloBass2,helloBass1,helloBeat;
		bus=Bus.audio;clock=TempoClock.new;

		kickPatterns=[[3/4,1/4],1];
		p=[0,0,0,0,1,1,1,0]++[1,0,1];   ///XTENDED
		kickBar=Pseq(p.collect{|i|kickPatterns[i]}.flatten);

		snarePatterns=[[Rest(3/4),1/4],[Rest(1)],[Rest(1/2),1/2],[Rest(1/2),1/4,1/4],[Rest(1/4),1/4,1/2]];
		p=[0,1,2,0, 0,3,0,4]++[0,4,4];   ///XTENDED
		snareBar=Pseq(p.collect{|i|snarePatterns[i]}.flatten);

		synth= Pbind( 
			\note,Pseq([2-24,2-12,-1-12,9-12])-12,
			\instrument,\sawSynth,
			\dur,2,\rel,5,
			\amp,0.2) ;

			helloBass1=Pbind(
				\note, Pseq([2,4],4)-24,
				\legato,Pseq([1,Pwhite(0.25,0.55,1)],4),
				\amp,0.5
			) ;

			helloBass2=Pbind(
				\note,Pseq([\r,2,0],8),
				\dur,Pseq([1/2,1/4,1/4],inf),
				\amp,0.04
			) ;

			helloBeat= {
				|synthamp=0.3 drumsamp=1 tempo1=(52/60) tempo2=(50/60)|
				Ppar([
					Pbind(
						\tempo,Pseq([tempo1,tempo2]),\dur,4,\note,\r
					),
					Pbind(
						\instrument,\kick1,
						\dur,kickBar,
						\amp,drumsamp*0.1
					),
					Pfin(
						42, Pn( ///XTENDED
							Pbind(
								\instrument,\hihat, //ffreq rel
								//\dur,Pseq([0.245,0.255],32),
								\dur,Pseq([0.245,0.255],32),
								\amp,Pseq([Pwhite(0.3,0.4,1),Pwhite(0.2,0.3,1)],32)*0.4*drumsamp,
								\lag, Pseq( (1!16++(-1!16)).scramble*0.003),
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
			)<>(out:bus)
		};
		'self bus '.post;bus.postln;
		Song.helloSequenceBus = bus;
		Song.helloSequenceMonitor = Monitor.new.play(bus.index,2,0);
		{ s.bind {helloBeat.(synthamp:0.1,drumsamp:0.7,tempo1:~helloTempo.(),tempo2:~helloTemp2.()).play(clock)} };
	}.play
});
["you are a lovely female, r a","e5 d c# b4 a f# e e2 c#4"].addLine;//4
P.tune('lovely female');
P(\drumPan4,start:'lovely female',music:
	p{
		Song.helloSequenceMonitor.play(
			Song.helloSequenceBus.index,2,1,1,
			fadeTime:Song.secDur[4..5].sum,
			volume:0.2
		);
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
~durs6=Song.durs['half a million'].list;
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
P(\keys62,start:'half a million',syl:5,music:
	Pbind(
		\instrument,\stab,
		\note,Pseq([ [7,9,13],[7,9,13],[5,9,14] ]),
		\dur, Pseq(Song.durs['half a million'].list.[6..7]++[1]) ,
		\amp,Pseq([1,1.3,1])*0.8,
		\out, [1,1,1].q
	)
);
["r r you're welcome","d5 f4  g5 f "].addLine;//7
P.tune('r r you');
P(\bass7,start:'r r you',syl:0,music:
	Pseq([
		(note:5-24,dur:~phrase6quarter*3,amp:0.5),
		//(note:4-24,dur:~phrase6quarter,amp:0.5),
		//(note:7-24,dur:~phrase6quarter*2,amp:0.5),
	])
);
P(\keys7,start:'r r you',syl:0,music:
	Pbind(
		\instrument,\harp,
		\midinote,Pseq(~panNotes.("f5 a4 c5")-[0,12]),
		\dur,//Pseq(
		Song.durs['r r you'].list.[1..2]
		.sum/4
		//) //make a function for this
	)
);
P(\yow7,start:'r r you',syl:0,music:
	(instrument:\yowbass,note:[-3,0,5],dur:3,amp:0.05)
);
["I've forgotten what it fee-","g#4 e b f# a# b c#5"].addLine;//8
P.tune('what it fee');
P(\pad8,start:'what it fee',music:
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
P(\trombone8,start:'what it fee',music: 
	{ | amp=0.9 exp=80|
		'NOWWWWWW'.postln;
		//~syn1.monitor.clear;
		//Synth(\tromboneVerb);\verb.postln;
		~syn1.patch(\trombone,\none,3);
		//~syn1.syn.set(\out,Effect( { |i| FreeVerb.ar(i,0.8,0.7) * 3 },out:2  ).bus.index);
		~syn1.syn.set(\out,Effect( { |i| DWGReverbC1C3.ar(i,mix:0.2,c1:2) * 0.4 } ,out:2).bus.index);
		//~syn1.syn.set(\out,Effect( { |i| FreeVerb.ar(i,0.8,0.7) * 3 => Out.ar([0,2],_) }  ).bus.index);
		~syn1.expression(84,3);
		Pbind(*[
			type:\vst_midi,
			vst:~syn1.controller,
			chan:3,
			midinote: Pseq(~noteList.(["g#","c#","b3"]))-[12,36] ,
			dur:Pseq([Song.secDur['what it fee'],Song.secDur['even to br'],3]),
			\amp:0.55,
		]).play
		//~syn1.monitor.play(~syn1.bus.index,2,111,2,fadeTime:0.05,volume:0.6);

	}
);
["ls like even to brea-","d#5 a#4 c#5 d# e f# "].addLine;//9
P.tune('even to br');
["th again, Sargon?"," g#5 f# b4 g g"].addLine;//10
P.tune('th again');
P(\sargon10,'th again, S',syl:2,music:
	Pseq([
		(note:[4,7,10],dur:Song.durs['th again, S'].list[3],\amp:0.3),
		(note:[4,7,10],dur:Song.durs['th again, S'].list[4],\amp:0.3)
	])
);
["Here, in this body","f e g f c"].addLine;//11
~panList={|string| Panola.new(string).midinotePattern.list.flatten};
~noteList={|list| list.collect({|x|~panNotes.(x)}).flatten };
P(\pf11,start:'Here, in this',music:
	Ppar([
		//(instrument:\cymbal,dur:13)
		//,
		Pbind(*[
			midinote:Pseq( ~noteList.(["<a c5 f>","<g c5 e>","<b- d5 g>","<a c5 f>"])-12),
			dur:Song.durs['Here, in this'],
			strum:Pseq([0.01,0.01,0.02,0.01])
		]),
		Pbind(*[
			instrument:\test,
			amp:0.5,
			midinote:Pseq( ~panList.("c g3 f c4"))-[ 12,24 ]-7,
			dur:Song.durs['Here, in this'],
		])
	])
);

//~complete.pbind.do({|i x| var label = ("guide"++x).asSymbol; ~complete.label]=(start:x,music:i);label.postln});
//"xxx.xxxxxxx".do({|i n| var label="guide"++n.asSymbol; (i==$x).if {~complete.label]=(start:n,music:~complete.pbind[n])} });
Song.addGuides("xxx.xxxxxxx");

~quarters=SongArray.new();
[ "trill","r",[5] ].addLine; //0
(
~synTrill={ 
	|chan=1 amp=0.3 transpose=0 len=6|
	Pfindur(
		len,
		Pbind(*[
			type:\synful,
			instance:~syn1,
			note:Pseq([6,8],inf)+transpose,
			dur:Pwhite(0.1,0.12)*0.8,
			amp:Pwhite(0.1,0.11),
			pan:rrand(-1,1),
			amp:amp,
			chan:chan,
			legato:1
		])
	);
}
);

SynthDef(\plate_phaser_insert,{
	|inBus=0 gate=1|      
	var env= Env.cutoff(15,curve:\cub).kr(2,gate:gate);
	var sig = In.ar(inBus,2);
	sig=PlateReverb.ar(sig,mix:0.5,decayTime:0.55);
}).add;

P(\trill,start:'trill',lag:0.1,music:
	{ |p b e| 
		//var reverbBus = Bus.audio(s,1);
		//var reverb = Synth(\plate_phaser_insert,[\inBus,reverbBus.index,\gate,1]);
		var trillLength = b.sum +( Song.durs[e.start+1].list.sum );
		~syn1.syn.set(\out,
			Effect( { |i| PlateReverb.ar(i,mix:0.5,decayTime:0.55)  * Env.linen(0,trillLength,5).kr(2  )}).bus.index
		);
		//~syn1.syn.set(\out,reverbBus.index);
		fork{
			~syn1.expression(40,1);
			~syn1.expression(30,0);
			0.05.wait;
			~synTrill.value(0,0.9,12,len:trillLength).play;
			~synTrill.value(1,1.9,4,len:trillLength).play;
		} 
	}
); 
[ "I am not displeased my husband- ","d#5 c# c a#4 g# f# f d# c# " ].addLine; //1
~justTheTune.('husband');
[ "r your body is r r  not unlike ","c#3 f4 d# c# g#3 f#2 f# f#4 f d#" ].addLine; //2
~justTheTune.('unlike');
[ "that which was your own (dum dum dum)","d-4 c d- b-3  g-3 f g- a-" ].addLine; //3
~justTheTune.('your own');
[ "and i too am pleased beloved", [3,2,4,3,3,2,1,-7].dm('d' ) ].addLine; //4 -or Bb!
~justTheTune.('beloved');
[ " boom after so- long... (boom) so very long... Kiss ","d3 a b e4 d f g3 b c4 a3 e4 r" ].addLine; //5
~justTheTune.('very long');
P(\afterSoLongSketch,start:'very long',music: {|p b e|
	var afterSoLong=[\r,4,5,8,7,9]++[\r,5,6,4,7] + [ 2,2,2,2,2,2,2,2,2,2,3 ].collect{|i| [0,i]};
	(degree:1,octave:4,dur:6).play;
	[
		legato:1.05,
		degree:Pseq(afterSoLong)-1,
		dur:b.q,
		out: Effect(PlateReverb.ar(_,mix:0.1),out:3).bus.index,
		amp: 0.08
	].pp;
	[
		degree:Pseq([1,-3]),
		dur:b.parse([6,5]).q,
		out: Effect(PlateReverb.ar(_,mix:0.2),out:1).bus.index,
		amp: 0.08
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
			amp:0.5,
			out: Effect( SineShaper.ar(_,0.2) ).bus.index
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
//get this from reaper (HOOK) "/Users/michael/Trek/Vulcan's worship peace/Vulcan's worship peace.RPP" => {|i| ( "open "+i ).unixCmd }
["/*MCCOY*/ Vulcans worship peace above a-- ll, Henoch. ",[5,5,4,4,3, 2,1,2,3, -6,-5].dm('d')].addLine;
~justTheTune.('worship');
~quarters[\worship] = Song.parseBeats('worship',"e e e e qqq e e e eq q q".asBeats);
Song.setTempoMap(\worship,"e e e e qqq e e e eq q q");
//Song.tempoMap[\worship]=Song.tempoMap[\worship].quantize;
P(\harmonyPart,start:'worship',music:{|p b e|
	[
		freq:[2,2,2,2,1].df('a',octave:5 ).q,
		dur:b.parse([1,1,1,1,1]).q,
	].pp
});
P('key',start:\worship,music: {|p b e|
	[
		freq: [\r,3,1, 3, 2, 2, 1, 2, 3, 2, 1].df(\d,octave:6).q,
		dur: [4,2,1,1,2,1,1, 1,1,1,1]/2 =>_.warpTo(e.tempoMap) =>_.q,
		out: 
		Effect.bus({|i| CombC.ar(i,1,b[0]) * 0.5 + i})
	].pp
});
P(\bass,start:'worship',music:{|p b e|
	[
		freq:[4,4,5,5,11,11,5,5,5,6,7].df('d',octave:3 ).q(2),
		dur: "e e e e qe e e q e qe e".asBeats.warpTo(e.tempoMap).q(2),
		instrument: \sawSynth
	].p => _.fin(15) => _.play
});
P('drum',start:\worship,music: {|p b e|
	var volScale = 0.7;
	[
		dur:0.5.dup(20).warpTo(e.tempoMap).q ,
		rest:[1,1,\r,1,1,\r,\r,\r].q(inf),
		//instrument:\bd_808,
		instrument:\kick_gentle,
		vol:0.15 * volScale
	].pp;
	[
		dur:1.dup(16).warpTo(e.tempoMap).q,
		rest:[\r,1].q(8),
		instrument:\sn_808,
		amp:0.08  * volScale
	].pp;
	[
		dur:0.5.dup(19).warpTo(e.tempoMap).q,
		instrument:\hihat,
		ffreq:[4400,6600].q(inf),
		amp:[\r,\r,\r,\r].q++[0.1,0.07].q(inf) /3

	].pp;
	[ instrument:\cymbalsDS,amp:0.01,rest:[\r,1].q,dur:[2,1].warpTo(e.tempoMap).q ].p.play
});
P(\pianoWorship,start:'worship',music:{|p b e|
	[
		freq:[-6,-6, -5,1,3,2,-5].df('d',octave:5 ).q,
		pan:3/4,
		dur:~quarters['worship']
		//		.quantizeWindow
		.parse("e eqe e e e e e".asBeats).q
	].pp

});
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
});
["(Mulhall/Thalassa collapses and they help her back onto the bed.) ","r",[5]].addLine;

P(\collapseTremolo,start:'collapses',music:{|p b e|
	~syn1.expression(127,0);
	~syn1.expression(127,1);
	//	~syn1.monitor.isRunning.not.if{~syn1.monitor=Synth(\syn1_Bus)};
	~syn1.patch(\violas,\trem,0);
	~syn1.syn.set(\out, (Effect(FreeVerb.ar(_,0.8,0.8)).bus.index) );
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
});
// irregular harp glissandi
["/*MCCOY*/ Nurse! ","r"].addLine;
["(Then Kirk/Sargon gets dizzy.) ","r"].addLine;
["/*CHAPEL*/ Doctor? ","r"].addLine;
["/*MCCOY*/ Henoch, you'd better get back to bed too. ","r"].addLine;

/// Unnecessary

// drums
Song.kpat=([1,1,0,1]!4).flatten;
Song.spat2=([0,0,0,0,1,0,0,0.6]!4).flatten;
Song.tk=();
Song.tk.add(\kick->Pbind(*[
	instrument:\kick2,
	amp:Pseq(Song.kpat,3)/6,
	dur:0.5	,
	out:[0,1]
]));

Song.tk.add(\snare->
	Pbind(*[
		instrument:\snare,
		amp:
		Pseq(Song.spat2.flatten,3)/7
		,
		dur:0.25,
		out:[0,1]
	]);
);
( Song.tk.add(\hat->
	Pbind(*[
		instrument:\hihat,
		dur:Pwrand([1/4,Pseq([1/16],4)],[0.95,0.05],inf),
		//offset:-0.35,
		att:Pwhite(0,0.01),
		pan:0.4,
		amp:0.04])
	);
);
//;
//h[1]=\filterIn->{|in| Klank.ar(`[[1100,1200,2500],nil,0.04],in)};h.set(\wet1,0.5);
//h
//.play;

//	synths	{{{3
~octaveWrap={|i a=7| (i>a).if({i-8},i)};

( Song.tk.add( \pulse-> //		{{{4
	Pbind(*[
		instrument:\pulse,
		degree:Pseq(([\r,1,5,1,\r,0,5,0,\r,1,5,1]++[\r,1,6,1]).flatten,3)-1,
		dur:0.5,
		root:4,
		sustain:2,
		octave:6,
		amp:0.17
	]);
);
	);
	( Song.tk.add(\saw-> //		{{{4
		Pbind(*[
			instrument:\sawSynth,
			att:0.05,
			rel:5,
			degree:Pseq(
				[1,3,0,3,7,3,7,4].collect{|i|~octaveWrap.(i,6)}-1
				,4
			),
			//degree:Pseq([[1,3],5,[2,0],5,[1,-1],5,[1,-1],6]-1,4),
			root:4,
			octave:6,
		]);
	);
);

["that will be unnecessary Doctor"," d# e f# d# g# f# e d# d# c#"].addLine;//

P.tune(\unnecessary);
P(\descant,start:'unnecessary',music: {|p b e|
	[
		instrument:\sawSynth,
		degree:Pseq([\r,8,7,6,5,5,4.1])-1,
		att:0.7,
		root:4,
		dur:Pseq( [Song.durTill(Song.section( 'unnecessary' ),3)]++Song.durs['unnecessary'].list [4..9]++[0.5,2]),
		dur: b.parse([4,1,1,1,1,1,1]).q,
	].pp
});
P(\unnecBass,start:'unnecessary',music: //		{{{
	{|p b e|
		[
			instrument:\sawSynth,
			degree:Pseq([5,2])-1,
			rel:4,
			dur: b.parse([8,2]).q,
			//dur:Pseq([2.3,1]),
			root:4,
			octave:3
		].pp
	}
);
["(four bar intro)" , "r",[16]].addLine;
Song.vulcanBodyTempo = 1.2;
Song.tk.asPairs.pairsDo{|name pattern| Song.tk.put(name, Song.tk.at(name) => Pmul(\dur,Song.vulcanBodyTempo.reciprocal,_))}; //scale pattern
Song.durs['four bar intro']=Pseq([1,1,1.5,0.25,0.25+0.5, 0.5,0.5,0.25,0.25+0.5,0.5,0.5,0.5]);
Song.durs.scale('four bar intro',Song.vulcanBodyTempo.reciprocal);
P(\leadIn,start:'four bar intro',music: { |p b e|
	Pfindur(8/p.vulcanBodyTempo,
		Ppar([
			//Pseq([Song.pbind[1]],4).play;
			Song.tk.at(\snare),
			Song.tk.at(\kick),
			Song.tk.at(\pulse),
			Song.tk.at(\saw),
			Song.tk.at(\hat)
		])
	).play
}); 
["r this Vulcan body is adapted to the","r b b g# f# e f# g# f# e d# e"].addLine;//1
P.still( \clear, start: 'adapted to', timecode:0 ,syl:0, music: { |p b e|
	e.still.value(
		wait: b.drop(1).sum,
		text: ["this Vulcan body",""]
	);
	fork{
		b[1..4].sum.wait;
		defer{
			e.still.setText(["this Vulcan body","is adapted to the"])
		}
	}

});
Song.durs['is adapted']=Pseq([1,1,1.5,0.25,0.25+0.5, 0.5,0.5,0.25,0.25+0.5,0.5,0.5,0.5]);
Song.durs.scale('is adapted',Song.vulcanBodyTempo.reciprocal);
//	Song.durs[1]=Pseq((Song.durs[1].list!2).flatten	);
P(\bass1,start:'adapted to',music: {
	var notes=[1,3,6,4].collect{|i| i!4}.flatten;
	[
		degree:Pseq(notes,4)-1,
		dur:0.5/Song.vulcanBodyTempo,
		root:4,
		octave:2,
		trig:Pseq(1!16),
		out: Effect(
			{|i| i + CombN.ar( i, 1, 0.25/Song.vulcanBodyTempo,2,mul:( 0.8*0.8 ) )/2
			=> Phaser1.ar(_,  depth: 0.5,  rate: 0.2,  fb: 0.3,  cfb: 0.1,  rot: 1.5707963267949)
		}
	).bus.index
].pm(\bl).play;
});
P.tune('is adapted',{|i|i=>Pbindf(_,\amp,0.3,\instrument,\stringyy)});
P(\leadInB,start:'adapted to',music: //		{{{
	Pfindur(8,
		Ppar([
			//Pseq([Song.pbind[1]],4).play;
			Song.tk.at(\snare),
			Song.tk.at(\kick),
			Song.tk.at(\pulse),
			Song.tk.at(\saw),
			Song.tk.at(\hat)
		])
	)
); 
["r r higher metabolism"," f#3 f# a5 g# b a g# f# e "].addLine;//2
P.still( \clear , start:\higher , timecode:0, syl:1, music: { |p b e|
	e.still.value(
		wait: b.drop(1).sum ,
		text:["higher","metabolism"]
	);
});
P(\bass3,start:'higher metabolism',music: //		{{{
	{|p b e|
		[
			degree: Pseq([ 2,2,1,1 ])-1,
			//dur: [ Song.durs['higher metabolism'].list[0] ,Song.durs['higher metabolism'].list[1..4].sum  , Song.durs['higher metabolism'].list[5..6].sum,1].q ,
			dur: b.parse( [1,4,2] ) ++ [1] => _.q,
			root:4,
			octave:2,
			out: Effect({|i| 
				i + CombN.ar( i, 1, 0.25/Song.vulcanBodyTempo,2,mul:( 0.8*0.8 ) )/2
				=> Phaser1.ar(_,  depth: 0.5,  rate: 0.2,  fb: 0.3,  cfb: 0.1,  rot: 1.5707963267949)
			}).bus.index,
			trig:1
		].pm(\bl).play
	}
); 

P.tune('higher metabolism',{|i| Pbindf(i,\instrument,\stringyy,\amp,0.3,\mix,1.0,\release,2)=>_.drop(2) },syl:1);

P(\metabolism,start:'higher metabolism',music: 
	//t=TempoClock.new.tempo_( 1.2 );
	//u=TempoClock.new.tempo_( t.tempo*0.666 );

	Pfindur(4,//12,
		Ppar([
			//Pseq(Song.pbind[1..2]),
			//a.[0]=Pmono(\bl,\degree,2-1,\dur,0.5,\root,4,\octave,2,\trig,1);
			//				Song.pbind['higher metabolism'],
			Song.tk.at(\hat),
			Pbindf(Song.tk.at(\pulse), \degree,Pseq([\r,-2,4,-2],1),\dur,0.662 ),//.play
			Pbindf(Song.tk.at(\saw), \degree,Pseq([-1,4,-1,3]) ),//( ,\dur,0.331),
			Song.tk.at(\snare),
		])
	);
	//Song.tk.at(\hat).play(u)
);
["it won't work, Sargon!","d#5 b4 g5 d# b4"].addLine;//3
P.tune('work, Sargon');
P(\workChord,syl:1,start:'work, Sargon',music:{|p d|

	var a=Scale.new((0..8),pitchesPerOctave:9);

	//b=Effect(FreeVerb.ar(_,0.9,1),out:1).bus.index;
	var b=Effect({|i|PlateReverb.ar(i,0.8,mix:Line.kr(0.5,1,30),decayTime:0.7*Gendy1.kr(minfreq:1/10,maxfreq:2).unipolar)[0]},inputChannels:2).bus.index;
	var length = 2;
	[
		degree:
		Ptuple([
			( 40..57 ).q(inf) + 5.rand
			,( 40..56 ).q(inf) + 5.rand, (40..60).q(inf) ])
			,
			root:[0,3,6]-1,scale:a,dur:0.05,legato:1,
			out:b+Pwhite(0,1)
		] .p
		=>Pfindur(length+0.5,_)
		=>_.play;
		[dur:0.3,root:-1,scale:a,out:b,amp:Pseries(0.1,-0.01),degree:( 0..9 ).q(inf),legato:[3,0.5,0.5].q(inf)*2.2].p
		=>Pfindur(length+0.3,_)
		=>_.play;
		(strum:0.04,degree:[0,2,4]-1,scale:Scale.whole,root:9,dur:length).play;
		(release:5,type:\tuningGong,amp:0.02,freq:1.dm('g')).play
	}
);
P(\baseNoteWork,syl:1,start:'work, Sargon',music:{|p b|
	(
		freq:[1 ,11 ].df('g',octave:2 ),
		instrument:\sawSynthSustain,
	).play;
	(freq:[1,3,5,11,13,15].df('g',scale:\whole),strum:0.05).play
}
);
["(boom) you have to get out before you","f4 f5 d- e- f a f g a"].addLine;//4
P.tune('get out',(_.drop(1)),syl:0);
P(\baseNoteOut,syl:4,start:'get out',music:{|p b|
	(
		freq:[1 ,11 ].df('a',octave:2 ),
		instrument:\sawSynthSustain,
	).play;
	(freq:[1,3,5,11,13,15].df('g',scale:\whole),strum:0.05).play;
	(release:5,type:\tuningGong,amp:0.02,freq:1.dm('a')).play

}
);
P(\outChord,syl:4,start:'get out',music:{|p d|
	//b=Effect(FreeVerb.ar(_,0.9,1),out:1).bus.index;
	var a=Scale.new((0..8),pitchesPerOctave:9);
	var b=Effect({|i|PlateReverb.ar(i,0.8,mix:Line.kr(0.5,1,30),decayTime:0.7*Gendy1.kr(minfreq:1/10,maxfreq:2).unipolar)[0]},
	out:2,
	inputChannels:2).bus.index;
	var length = 2;

	[
		degree:
		Ptuple([
			( 40..57 ).q(inf) + 5.rand
			,( 40..56 ).q(inf) + 5.rand, (40..60).q(inf) ])
			,
			root:[0,3,6]+2,scale:a,dur:0.05,legato:1,
			//			out:b+Pwhite(0,1)
		] .p
		=>Pfindur(length+0.5,_)
		=>_.play;
		[dur:0.3,root:2,scale:a,out:b,amp:Pseries(0.1,-0.01),degree:( 0..9 ).q(inf),legato:[3,0.5,0.5].q(inf)*2.2].p
		=>Pfindur(length+0.3,_)
		=>_.play;
		//(out:2,strum:0.04,degree:[0,2,4]+2,scale:Scale.whole,root:9,dur:length).play
	}
);
["kill them! /*SARGON*/  we will transfer at once un-",[11,7,5,6,7,5,7,7,7].dm('c')].addLine;//5
P.tune('we will transfer');
P('bass',start:\kill,music: {|p b e|
	[
		freq: [\r,5,5].df(\c,[2,3,4]).q,
		dur: b.parse([5,[1,1,0.5],[0.5,1]]).q,
		out:[1,4],
		instrument: \pulse,amp:0.25

	].pp;
	[
		freq:[\r,7,7].df(\c,[3,4,5]).q,
		dur:b.parse([4,3,3]).q,
		out:Effect.bus(TwoTube.ar(_,loss:0.99,d1length:992) * 0.4,inputChannels:2,out:[2,3]),
		instrument:\twang

	].pp
});
["til you can administer the ",[7,6,5,4,7,11,6,5].dm('d')].addLine;//6
P.tune('administer');
["(boom) metabolic reduction injection... a ",[11,15,14,15,12,14,12,11,14.5,11,7.5, 7].dm('a-',octave:4,scale:\mixolydian )].addLine;//7
P.tune('injection',Pbindf(_,\legato,1.5,\out,Effect(PlateReverb.ar(_,decayTime:0.4,mix:0.6)).bus.index));
P(\baseNoteMetabolic,start:'injection',music:{|p b|
	var length=b[0..(b.size-1)].sum;
	var freq=[1,11].df('a-',octave:2 );
	{Saw.ar(freq + {3.0.rand} dup: 4 ) * Env.perc(0.4,length).kr(2,gate:1)*0.07 }.play;
	(instrument:\stringyy,freq:freq,dur:length,\wet:0,\amp:0.3).play;
}
);
["what? I'll prepare the formula Sargon",[14, 13,14,15,13,14,13,12,11,3].dm('b',octave:4)].addLine;//8
P.tune('prepare the formula');
P(\whatChord,start:'prepare the formula',music:{|p b|
	(
		midinote:[1,3,5,7].dm('f#',octave:4,scale:\mixolydian),
		strum:0.05,
		out:(0..3),
	).play
}
);
["Henoch, your condition",[4.5,1,3,4.5,6.5,5.5].dm('e',scale:\minor)].addLine;//9
P.tune('your condition');
P(\baselineCondition,start:'your condition',music:{|p b|
	[
		freq:[ [1,11],[2,12] ].df('g',octave:3 ).q,
		instrument:\stringyy,
		out:(0..3),
		dur:
		//		[ b[0..4].sum , b[5..6].sum].q(1),
		Song.parse('your condition',[[1,1,1,1,2/3],[1/3,1]]).q,
	].pp
}
);
["r I can continue in this body for for several hours","d3 f#4 d f# e c# d e d g3 e2 e4 d c#  b3 a"].addLine;//10
P.tune('several hours');
~continueQuarters = Song.parseBeats('several hours',[1/4,1/4,1/4,1/4,1/4,1/4,1/4,1/4,1/2,1/2]);
P(\continueSnare,start:'continue',music:
	{
		var a="....x..x".asDrumPat(4).list * ~continueQuarters.stutter(8) => _.q;
		var b="x.x...x.".asDrumPat(4).list * ~continueQuarters.stutter(8) => _.q;
		[instrument:\snare,dur:a,amp:0.03].p.fin(8).play;
		[instrument:\kick,dur:b].p.fin(4).play;
	}
);
P(\reedHours,start:'several hours',music:{ |p b|
	(instrument:\reedy,freq: 1.df('a') ).play
}
);
P(\baselineHours,start:'several hours',music:{|p b|
	[
		freq:[ 11,7,4,2,3,4,5 ].df('d',octave:3).q,
		dur:Song.parse('several hours',[4,4,2,2,1,1,1,1]).q,
	].pp
}
);
["fortunate (dum dum dum dum) we will vacate at once...",[14,12,7,5,6,7, 1,11,12,13,11,13,13].dm('g',octave:4,scale:\mixolydian,)].addLine;//11
P.tune('fortunate');
P(\baseNoteFortunate,start:'fortunate',syl:5,music:{ |p b|
	(instrument:\sawSynthSustain,freq:[1,11].df('g',octave:2),att:0.6,dur:b[6..].sum).play
}
);
P(\reedChordFortunate,lag:-0.15,start:'fortunate',music:{ |p b|
	(freq:[1,3,5,7].df('d',scale:\minor),out:{4.rand}!4, instrument:\reedy,sustain:1,release:4,amp:0.08 ).play 
}
);
["/*SPOCK*/ This woman will assist me. (boom boom)",[11,5,6,7,5,11,5, 2,2].dm('c')].addLine;
P.tune('woman',_.fin(7));
P(\baseNoteWoman,start:'woman',music:{ |p b|
	[
		instrument:\sawSynthSustain,
		freq:[1,2,2,3].df('c',octave:2,scale:\minor).q,
		dur:p.parse('woman',[7,1,1]).q,
	].pp
}
);
["(to Chapel) (boom) /*You will*/ take me to your",[1,11,7,6,5].dm('e-')].addLine;
P.tune('take me');
P(\baseNoteTake,start:'take me',music:{|p b|
	[
		instrument:\sawSynthSustain,
		freq:[3,13].df('c',octave:2,scale:\minor).q,
		dur:p.parse('take me',[[1,1,2/5],[3/5,1,1]]).q,
	].pp
}
);
["(boom) pharmacology laboratory. ",[1,11,7,11,5,7,4,5,4,3].dm('f',scale:\mixolydian)].addLine;
P.tune('pharmacology',{|i|i.drop(1)},syl:0);
P(\soundEffectPharmacology,lag:0.26,start:'pharmacology',music:{|p b|
	(type:\tuneUp,freq:1.df('c',octave:4),amp:0.01).play
}
);
P(\basedNotePharmacology,start:'pharmacology',music:{|p b|
	(instrument:\sawSynthSustain,\freq:[1].df('f',octave:2 )).play;
}
);
["(They leave.) ","r",[4]].addLine;
P(\door,start:'They leave',music:{|p b|
	var line= Line.kr(0,1,b.sum);
	var panBus=Bus.audio(s,1);
	{WhiteNoise.ar(0.03)}.play.dur(b.sum);
	(instrument:\stringyy,freq:[1,11].df('b-',octave:2 ),
	out:panBus.index,
	amp:0.4,
	dur:b.sum).play;
	{In.ar(panBus.index,1)=>Pan2.ar(_,Line.kr(-1,1,b.sum))}.play(addAction:\addToTail);
	[
		freq:[7,11,7,6,5,4,3,2].df('b-',octave:4, ).q,
		dur:b.sum/8,
		legato:2,
	].pp
}
);
// idea  do the doors with  additive synthesis
["/*KIRK*/ (frown) Bones, what?, it was", [7,17,14,15,15].dm('c',octave:3)].addLine;
P.tune('frown',{|i| i.drop(1)},syl:0);
P(\frownFrown,start:'frown',music:{|p b|

	var function={|freq out| {
		Array.fill(30,{freq.pareto(3)})
		=>{|j| var i = \freq.kr(j,8);
		FSinOsc.ar(i,0,24*i.reciprocal**2
			*Env.linen(2.5,10, 14.rand).kr(2)
		)
	}
	=>Mix.ar(_)}.play(s,out) };
	function.(300,0);
	function.(900,3);
	function.(1900,1);
}
);
["/*MCCOY*/ close, Jim. You both barely got back a -- ",[13,5,6,12,11,7,11,12,7].dm('c',octave:4,scale:\melodicMinor )].addLine;
P.tune('close');
P.tune('barely',{|i| i.drop(2) => Pmul(\freq,[1/2,1],_) =>Pbindf(_,\instrument,\stringyy,\mix,0.1)},syl:1);
P(\barelyRead8,start:'barely',lag:0.1,syl:2,music:{|p b|
	(
		instrument:\reedy,
		freq:[1,3,11,13].df('f',octave:4),
		//lag:0.1,
		sustain:1,
		out:{4.rand}!4,
		release:4,
		amp:0.05
	).play 
});
P(\firstChord,start:'barely',music:{|p b|
	(
		freq:[1,3,5,11].df('c',scale:\minor),
		strum:0.05,
	).play;
	(att:0.8,instrument:\sawSynth,rel:3,freq:[1,11].df('c',octave:2 )).play
});
["live. Unless the formula works, we can't risk it again.", [11.5,11,5,3,11,7,6,7].dm('e-') ++ [5,5,11,5,3,1].dm('f#',scale:\minor) ].addLine;
P.tune('risk it');
P.tune('risk it ',{|i| i.drop(1) => Pbindf(_,\instrument,\sawSynth,)=>Pmul(\freq,0.5,_)},syl:0);
P(\reedPedalRisk,start:'risk it',music:{|p b|

	[release:5,sustain:1,amp:0.01!2,out:3, freqLag:1,instrument:\reedy,
		freq:[ \r,[6, 11 ],[5,11],[5.5,7] ].df('b-',3).q,
		dur:p.parse('risk it',[4,3,3,4])+[0,0,0,5]=>_.q ].pm(\reedy).play
	}
);
//MUTEDP(\dingRisk,start:'risk it',syl:0,music: {|p b|
//MUTED{Array.fill(50,{500.pareto(2)})=>FSinOsc.ar(_,0,0.01* Env.perc(0,3).kr(2,gate:1))=>Mix.ar(_)}.play
//MUTED}
//MUTED);
P(\highChords,start:'risk it',music:{|p b|
	[
		freq: [[5,11,13].df('e',tuning:\sept1),[5,11,13].df('e-',tuning:\sept1),[11,13,15].df('b-',octave:4,tuning:\sept1),[3,5,11].df('f#',scale:\minor,tuning:\sept1)] .q,
		amp:0.06,
		dur:p.parse('risk it',[1,6,3,4]).q,
		freqLag:1,
		width:40,
		mix:0,

	].pm(\stringyy)
	.play
});

 })

