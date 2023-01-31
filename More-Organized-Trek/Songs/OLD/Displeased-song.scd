( // trill{{{1
	~trill={ |instrument=\default amp=0.1 len=5 |
		Pfindur(len,
			Pbind(*[
				instrument:instrument,
				note:Pseq([6,8],100),
				dur:Pwhite(0.1,0.12)*0.8,
				amp:Pwhite(0.1,0.11)*amp,
				pan:rrand(-1,1)
			])
		).play
	};
	//~trill.value(\test);
	//~trill.value;

		~synTrill=
		{|chan=1 amp=0.3 transpose=0 len=6|
			Pfindur(len,
				Pbind(*[
					type:\vsti,controller:~syn1.controller,
					note:Pseq([6,8],inf)+transpose,
					dur:Pwhite(0.1,0.12)*0.8,
					amp:Pwhite(0.1,0.11)*amp,
					legato:Prand([0.95,1,1,1,1],inf),
					pan:rrand(-1,1),
					//amp:amp,
					chan:chan
				]));
			};

			~trl=(dur:6,play: 
				topEnvironment.use{
					Routine{var len=6;
						~syn1.expression(64,1);
						~syn1.expression(64,2);
						~syn1.patch(\violins,\arco,1); //put these into the Pbind
						~syn1.patch(\clarinet,\none,0); //put these into the Pbind
						~syn1.monitor.free;
						~syn1.monitor.play(~syn1.bus.index,2,0);
						Synth(\tromboneVerb,[mix:0.4]); //change??
						//~trill.value(\test,len:len);
						~trill.value(len:len);
						~synTrill.value(0,3.0).play;
						~synTrill.value(1,3.9,4).play;
					};
				}
			);
);
//.play

//trill with preroll {{{2
//	{
//		~complete.parts.ply;
//		~complete.durTillEnd.wait;
//		~trill.value;
//			~synTrill.value(0,2.9).play;
//			~synTrill.value(1,1.9,4).play;
//	}.fork;
//);
(// ~displeased lyric and tune {{{1
~displeased=Song(
	\displeased, [
		"trill","r",//0
		"I am not displeased my husband- ","d#5 c# c a#4 g# f# f d# c# " ,//1
		"r your body is r r  not unlike ","c#3 f4 d# c# g#3 f#2 f# f#4 f d#",//2
		"that which was your own (dum dum dum)","d-4 c d- b-3  g-3 f g- a-",//3
		"and i too am pleased beloved","f# e g f# f# e d c#",//4 -or Bb!
		" boom after so- long... ","d3 a b e4 d f",//5
		"(boom)...so very long... Kiss","g3 b c4 a3 e4 r",//6
		"r r r r r r r r ..","g#5 f# d# b4 a# g# e5 d# ",//7
		" r","f#4",//8
	]
)
);

//( //after so long piano sketch{{{
//	~afterSoLong=[4,5,8,7,9]++[5,6,4,7] + [ 2,2,2,2,2,2,2,2,3 ].collect{|i| [0,i]};
//	(degree:1,octave:4,dur:6).play;
//	Pbind(*[legato:1.05,degree:Pseq(~afterSoLong)-1,dur:Pseq( 0.5!4++[2.5]++(0.5!3)++[2])]).play;
//	Pbind(*[degree:Pseq([1,-3]),dur:Pseq([4,5])]).play;
//)//}}}

(
	~displeased.condition=Condition.new;

	 ~displeased.infrastructure={
		FunctionList.new.array_([
			~synthsLoaded.isNil.if{"/Users/michael/tank/super/song-Synthdefs.scd".load},
			{fork{
				try{~syn1.controller.loaded.not.if{~syn1=~synful2.()}}{~syn1=~synful2.()};
				~syn1.condition.wait;
				~displeased.condition.test_(true).signal;
				SynthDef(\syn1_Bus,{|out=0| 
					Env.linen(0,~displeased.durTillEnd).kr(2,gate:1);
					Out.ar(out,In.ar(~syn1.bus.index,2))
				}).add;
			}},
		]).value
	}.inEnvir;
	 
		~synTrill= //{{{2
		{|chan=1 amp=0.3 transpose=0 len=6|
			Pfindur(len,
				Pbind(*[
					type:\midi,midiout:~syn1.controller.midi,
					note:Pseq([6,8],inf)+transpose,
					dur:Pwhite(0.1,0.12)*0.8,
					amp:Pwhite(0.1,0.11),
					pan:rrand(-1,1),
					amp:amp,
					chan:chan
				]));
			}; //}}}

			SynthDef(\plate_phaser_insert,{|inBus=0 gate=1| //{{{
				var env= Env.cutoff(15,curve:\cub).kr(2,gate:gate);
				var sig = In.ar(inBus,2);
					sig=PlateReverb.ar(sig,mix:0.5,decayTime:0.55);
					sig=Phaser2.ar(sig,rate:0.1,fb:0.5)*2;
					ReplaceOut.ar(inBus,sig*env)
			}).add;//}}}


			~displeased.setupTrill=(start:0,music://{{{2
					p{	
						try{~syn1.controller.loaded.not.if{~syn1.init}}{~syn1=~synful2.()};
						~syn1.expression(40,1);
						~syn1.expression(30,0);
						~syn1.monitor=Synth(\syn1_Bus);
						~syn1.insert=Synth(\plate_phaser_insert,[\inBus,~syn1.bus.index],addAction:\addBefore,target:~syn1.monitor);
					}
				
			); //}}}

			~displeased.fadeoutPlate=(start:2,music://{{{2
				{
					{
						~syn1.insert.release;
					}.fork
					//{~syn1.node[1]=nil}.value
				}
			); //}}}

			~displeased.trill=(start:0,lag:0.1,music://{{{2
				p{
						var trillLength = ~displeased.secDur[0..1].sum;
						TempoClock.tempo=1;  //hmmm
						~synTrill.value(0,0.9,12,len:trillLength).play;
						~synTrill.value(1,1.9,4,len:trillLength).play;
				}
			); //}}}
		//}.value;
		~displeased.bassNotes54=(start:5,music: //{{{2
			[
				dur: Pseq(~displeased.secDur[5..6]) ,
				degree: Pseq([1,4],2) ,
				legato:[1.1,0.9].q,
				octave:3,
				amp:1
			].p
		);//}}}
	//TempoClock.tempo=1.5.reciprocal;
	SynthDef(\trem2,{| rate=12 freq=499 scale=1 gate=1 out=0| //		{{{3
		//var force =LFBrownNoise1.kr(1).range(-0.20,8.8);
		var force=0.9;
		//var scale=SinOsc.ar(0.01).range(0.2,1.2);
		//var vel=1;
		var vel=SinOsc.kr(rate+LFBrownNoise1.kr(1)).range(0,1);//rate
		//var pos=0.2;
		var pos = LFBrownNoise1.kr(2).range(0.3,0.2);
		var env = Env.asr(0,1,0.5).kr(2,gate:gate);
		var sig = DWGBowed.ar(
			freq: freq,// + LFBrownNoise0.kr(2).range(0,10),  
			velb: vel,  
			force: force,  
			gate: 1,  
			pos: pos,  
			release: 0.5,  
			c1: 5,  //inverse of DC decaytime
			c3: 30, // hi freq decay 
			//impZ: 0.55*LFBrownNoise1.kr(0.5).range(0.02,1),  
			fB: 2 //inharmonicity
		); 
		sig= DWGSoundBoard.ar(sig,  c1: 20,  c3: 100,  mix: 0.8,  d1: 199*scale,  d2: 211*scale,  d3: 223*scale,  d4: 227*scale,  d5: 229*scale,  d6: 233*scale,  d7: 239*scale,  d8: 241*scale);
		sig=HPF.ar(sig,300)*0.05;
		//sig =PlateReverb.ar(sig,mix:0.8);
		Out.ar(out, Splay.ar(sig*env));
	}).add; //}}}
	SynthDef(\verb,{|out wet=1 | //{{{
		var in=In.ar(out);
		var sig =PlateReverb.ar(in);
		XOut.ar(out, wet, sig*2)}
	).add; //}}}
	~displeased.bowed7=(start:7,music:Pfx([ //{{{
		tempo:0.8,
		instrument:\trem2,
		rate:Pbrown(2,0,0.3),
		degree:Pseq([6,5,3,1,7-7,6-7,4,3,5-7]-1),
		root:-1,
		octave:[6,4],
		scale:Scale.major,
		dur:~displeased.durs[7]++Pseq([2.5]),
		legato:1,
		mtranspose:Pseq([ [0,2,4,7],[0,3,5,7],[0,2,5,7],[0,2,4,7],[0,3,5,7],[0,4,6,7],[0,2,4,7],[0,3,5,7],[0,7] ].collect(_-7)),
	].p.pad,
	\verb,\wet,0.3)  //}}}
);

	~displeased.bass7=(start:7,music:
		(instrument:\sawSynth,rel:15,att:1,octave:2,amp:0.17,degree:4,root:-1,mtranspose:[0,4,7],dur:10)
	);	
	//}.fork
)

//([(song:~transform,type:\player,dur:13)].q++ [~complete,~displeased].collect((song:_,type:\player)).q).play
//or, better 
//[~transform,~complete,~displeased].q.play(TempoClock,~funs);
//

//easy to write function will work like this:
// [~displeased, [~complete,{TempoClock.tempo_(1)}], {vlad.postln} ]
