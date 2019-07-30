
(	SynthDef(\phaser,{|out=5 depth=0.5 fb=0.3 rate=0.03| 
		ReplaceOut.ar(
			out,Phaser2.ar(In.ar(out,1)+
				PlateReverb.ar( In.ar(out,1),mix:Env.linen(0,2.5,6).kr)
				,rate:rate,fb:fb,depth:depth))}
			).add;
	TempoClock.tempo=(52/60);
	~kickPatterns=[[3/4,1/4],1];
	p=[0,0,0,0,1,1,1,0];
	~kickBar=Pseq(p.collect{|i|~kickPatterns[i]}.flatten);

	~snarePatterns=[[Rest(3/4),1/4],[Rest(1)],[Rest(1/2),1/2],[Rest(1/2),1/4,1/4],[Rest(1/4),1/4,1/2]];
	p=[0,1,2,0, 0,3,0,4];
	~snareBar=Pseq(p.collect{|i|~snarePatterns[i]}.flatten);

	~helloBeat= Ppar([
		Pbind(\instrument,\kick1,
			\dur,~kickBar
		),
		//Pbus(
			Pbind(\instrument,\hihat, //ffreq rel
				\dur,Pseq([0.245,0.255],32),
				\amp,Pseq([Pwhite(0.3,0.4,1),Pwhite(0.2,0.3,1)],32)*0.4,
				\lag, Pseq(
					(1!16++(-1!16)).scramble*0.003),
					\ffreq, Pwhite(6000,6500),
					\rel,0.15
				),
		//	),
		Pbind(\instrument,\snare,
			\dur,~snareBar
		),
	
		Pfx(
			Pbind( \instrument,\sawSynth,
			\note,Pser(~panNotes.("d f# a c#5 e5").flatten-60,16),
			\dur,1/2,
			\att,0.5,
			\octave,Pser(4!5++(5!5)++(6!5)++(7!5),32),
		),
		\phaser),
		~helloBass1,
		//~helloBass2,
		~synth
		],4);
	
	~helloBeat.play;
)

(
~helloBass1=Pbind(
	\note, Pseq([2,4],4)-24,
	\legato,Pseq([1,Pwhite(0.25,0.55,1)],8),
	\amp,0.5
)
//.play	
;
~helloBass2=Pbind(
	\note,Pseq([\r,2,0],8),
	\dur,Pseq([1/2,1/4,1/4],inf),
	\amp,0.04
)
//.play
;
)

(//bass synth
~synth=
	Pbind(\note,Pseq([2-24,2-12,-1-12,9])-12,
		\instrument,\sawSynth,\dur,2,\rel,5,\amp,0.5)
		//.play
;
)


