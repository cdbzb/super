
(	//s.waitForBoot{

	SynthDef(\phaser,{|out=5 depth=0.5 fb=0.3 rate=0.03| 
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

	~synth=
		Pbind(\note,Pseq([2-24,2-12,-1-12,9-12])-12,
		//Pbind(\note,Pseq([2-24,2-12,[-1-12,-1,6],[1,4,9-12]])-12, //)
			\instrument,\sawSynth,\dur,2,\rel,5,\amp,0.2)
		//.play
;

~helloBass1=Pbind(
	\note, Pseq([2,4],4)-24,
	\legato,Pseq([1,Pwhite(0.25,0.55,1)],4),
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

	~helloBeat= {|synthamp=0.3 drumsamp=1 tempo1=(52/60) tempo2=(50/60)|
	
	Ppar([
		Pbind(\tempo,Pseq([tempo1,tempo2]),\dur,4,\note,\r),

		Pbind(\instrument,\kick1,
			\dur,~kickBar,
			\amp,drumsamp*0.1
		),
		//Pbus(
			Pbind(\instrument,\hihat, //ffreq rel
				\dur,Pseq([0.245,0.255],32),
				\amp,Pseq([Pwhite(0.3,0.4,1),Pwhite(0.2,0.3,1)],32)*0.4*drumsamp,
				\lag, Pseq(
					(1!16++(-1!16)).scramble*0.003),
					\ffreq, Pwhite(6000,6500),
					\rel,0.15
				),
		//	),
		Pbind(\instrument,\snare,
			\dur,~snareBar,
			\amp,drumsamp*0.1
		),
	
		Pfx(
			Pbind( \instrument,\sawSynth,
			\note,Pser(~panNotes.("d f# a c#5 e5").flatten-60,16),
			\dur,1/2,
			\att,0.5,
			\octave,Pser(4!5++(5!5)++(6!5)++(7!5),32),
		),
		\phaser),
//		~helloBass1,
		//~helloBass2,
		Pset(\amp,synthamp,~synth),
		//Pseq([(\type:\rest,dur:4),~complete.pbind[4]]);//remove
		
	//	Ptpar([
	//		0.15,~helloGtr1,
	//		0.15,~helloGtr2
	//	])
		],1   /// repeats!!
	)};
	
	~helloBeat.(synthamp:0.18,drumsamp:0.35).play;
//}.fork
)

(
)
Pbus


(//bass synth
)

s.boot;
(
	~strum=( // creates a nodeproxy playing on a private bus - .node and .bus respectively 
		bus: Bus.audio(s,2),
		controller: nil,
		node:nil,
		params:(expression:11),
		expression:{|self expression channel=0 | self.controller.sendMidi("B0".asHexIfPossible+channel,11,expression)},
		plugin: 'Strum GS-2',
		setprog:{|self program bank channel| 
			self.controller.sendMidi("B0".asHexIfPossible+channel,0,bank);//set bank then
			self.controller.sendMidi("C0".asHexIfPossible+channel,program); //set program
		},
		init: { |self| //create node and controller + load plug 
			self.controller=VSTPluginController(Synth(\vsti,[\out,self.bus]));
			self.node=NodeProxy.audio(s,2).play;
			self.node.source={In.ar(self.bus.index,2)};
			{
				s.sync;
				self.controller.open("/Library/Audio/Plug-Ins/VST/"++self.plugin,action:{self.controller.readProgram("/Users/michael/tank/super/SynfulTest.FXP"); });
			}.fork;
		},
		set:{|self args| self.controller.set(args)}
	)
)
tion - l
	~strum.init;
(
	~strum.controller.loaded;
	//~strum.controller.set(0,2); ///how to set????
	~strum.controller.numParameters;
	~strum.controller.gui;

		~helloGtr1=Pbind(
			\type,\midi,
			\midiout,~strum.controller.midi,
			\midinote, Pseq([50,52,57],4),
			\dur,Pseq([1/1,1/4,3/4],inf),
			\legato,Pseq([1,Pwhite(0.25,0.55,1)],8),
			\amp,0.5
		)
		;


	~helloGtr2=Pbind(
			\type,\midi,
			\midiout,~strum.controller.midi,
		\note,Pseq([127,74,72],8),
		\dur,Pseq([1/2,1/4,1/4],inf),
		//\amp,0.3
	)
	;

	Ppar([
		~helloGtr2,
		~helloGtr1
	]).play
)
s.boot;
~helloGtr2.play;
