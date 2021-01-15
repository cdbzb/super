
( // {{{1
	~unnecessary = Song( \unnecessary,[]); 
	Song.unnecessary.current;
		
["that will be unneccesary Doctor"," d# e f# d# g# f# e d# d# c#"].addLine;//0
["r this Vulcan body is adapted to the","r b b g# f# e f# g# f# e d# e"].addLine;//1
["r r higher metabolism"," f#3 f# a5 g# b a g# f# e "].addLine;//2
["it won't work, Sargon!","d#5 b4 g5 d# b4"].addLine;//3
["you have to get out before you","f d- e- f a f g a"].addLine;//4
["kill them! we will transfer at once un-","r"].addLine;//5
["til you can administer the ","r"].addLine;//6
["metabolic reduction injection... a ","r"].addLine;//7
["what? I'll prepare the formula Sargon","r"].addLine;//8
["Henoch, your condition","r"].addLine;//9
["r I can continue in this body r for several hours","d3 f#4 d f# e c# d e d g3 a2 e d c# c# b"].addLine;//10
["fortunate we will vacate at once...","c5 a4 e a3 b c a2 e4 f# g# e g# a#"].addLine;//11
["/*SPOCK*/ This woman will assist me. (to Chapel) You will take me to your pharmacology laboratory. ","r"].addLine;
["(They leave.) ","r"].addLine;
["/*KIRK*/ Bones, what? ","r"].addLine;
["/*MCCOY*/ It was close, Jim. You ","r"].addLine;
["both barely got back alive. ","r"].addLine;
["Unless the formula works, we can't risk it again.","r"].addLine;
		

	~unnecessary.durs[1]=Pseq([1,1,1.5,0.25,0.25+0.5, 0.5,0.5,0.25,0.25+0.5,0.5,0.5,0.5]);
	~unnecessary.durs[1]=Pseq((~unnecessary.durs[1].list!2).flatten	);
	'!!!'.postln;


 //	unnecessary sections	{{{2
	//~unnecessary.resources=();
	~unnecessary.condition=Condition.new;
	~unnecessary.infrastructure={
		~synthsLoaded.isNil.if{"/Users/michael/tank/super/song-Synthdefs.scd".load};
		~unnecessary.condition.test_(true).signal;
	};
	~unnecessary.bass=NodeProxy.audio(s,2).play; //	bass setup	{{{3
	~unnecessary.bass[1]=\filterIn->{|in|in+CombN.ar(in,1,0.25/TempoClock.tempo,2,mul:0.8)/2};
	~unnecessary.bass.set(\wet1,0.8);
	~unnecessary.bass[2]=\filter->{|in| Phaser1.ar(in,  depth: 0.5,  rate: 0.2,  fb: 0.3,  cfb: 0.1,  rot: 1.5707963267949) };

	~notes=[1,3,6,4].collect{|i| i!4}.flatten;
	
	SynthDef(\bl,{|gate=1 out=0 freq=400 t_trig=0  | //{{{ 
		var sig= SawDPW.ar(freq*[1,2],0,0.04 );  // add these octaves better
		//var env=Decay.kr(t_trig,0.4) ;
		var env= Env.perc(0.00,0.3,curve:\sin).kr(0,gate:t_trig) ;
		sig= sig+CombN.ar(sig, 1, 0.35,  decaytime: 3,  mul: 0.5,  add: 0);
		sig=DFM1.ar(sig,1800,0,5.9);//.distort;
		Out.ar(out,sig*env!2);
	}).add;
//}}}
	//	drums	{{{3
~kpat2=([1,1,0,1]!4).flatten;
~spat2=([0,0,0,0,1,0,0,0.6]!4).flatten;
~tk=();
~tk.add(\kick->Pbind(*[
	instrument:\kick2,
	amp:Pseq(~kpat2,3)/6,
	dur:0.5	,
	out:[0,1]
]));

~tk.add(\snare->
	Pbind(*[
		instrument:\snare,
		amp:
		Pseq(~spat2.flatten,3)/7
		,
		dur:0.25,
		out:[0,1]
	]);
);


~tk.add(\hat->
	Pbind(*[
		instrument:\hihat,
		dur:Pwrand([1/4,Pseq([1/16],4)],[0.95,0.05],inf),
		//offset:-0.35,
		att:Pwhite(0,0.01),
		pan:0.4,
		amp:0.04])
	);
//;
//h[1]=\filterIn->{|in| Klank.ar(`[[1100,1200,2500],nil,0.04],in)};h.set(\wet1,0.5);
//h
//.play;

//	synths	{{{3
~octaveWrap={|i a=7| (i>a).if({i-8},i)};

SynthDef(\pulse,{|gate=1 freq=400 amp=1 ffreq=4500 rel=2 out=0 t_trig wiggle=500| //		{{{4
	var sig=Pulse.ar(freq,SinOsc.kr(8.55,0,0.6,0.4));
	var env= Env.perc(0,rel).kr(0,gate:t_trig)*amp;
	//var env=0.1;
	sig= MoogFF.ar(sig,SinOsc.kr(0.3,0,wiggle,1150));
	sig=HPF.ar(sig,500);
	Out.ar(0,sig*env!2)}).add;


~tk.add(\pulse-> //		{{{4
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

//	h=NodeProxy.audio;

~tk.add(\saw-> //		{{{4
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
	~unnecessary.cursor_(0); //		{{{1
	//TempoClock.tempo=1;
	~unnecessary.unnecessary=(start:0,music:~unnecessary.pbind[0]);
	~unnecessary.tempo1=(start:0,music:{{TempoClock.tempo=1}.fork});
	~unnecessary.tempo2=(start:1,music:{{TempoClock.tempo=1.2}.fork});
	~unnecessary.descant=(start:0,music: //		{{{
		Pbind(*[ 
			instrument:\sawSynth,
			degree:Pseq([\r,8,7,6,5,5,4.1])-1,
			att:0.7,
			root:4,
			dur:Pseq(
				[~unnecessary.durTill(0,3)]++~unnecessary.durs[0].list [4..9]++[0.5,2]
			)
		])
	);//}}}
	~unnecessary.unnecBass=(start:0,music: //		{{{
		Pbind(*[
			instrument:\sawSynth,
			degree:Pseq([5,2])-1,
			rel:4,
			dur:~unnecessary.durTill(0,7),
			//dur:Pseq([2.3,1]),
			root:4,
			octave:3
		])
	);//}}}
	//TempoClock.tempo;
	~unnecessary.bass1=(start:1,music: {~unnecessary.bass[0]=Pseq([Rest(8),Pmono(\bl,\degree,Pseq(~notes,4)-1,\dur,0.5,\root,4,\octave,2,\trig,Pseq(1!16))])});

	~unnecessary.leadIn=(start:1,music: //		{{{
		Pfindur(16,
			Ppar([
				//Pseq([~unnecessary.pbind[1]],4).play; 
				~tk.at(\snare),
				~tk.at(\kick),
				~tk.at(\pulse),
				~tk.at(\saw),
				~tk.at(\hat)
			])
		)
	); //}}}
	~unnecessary.bass2=(start:2,music: //		{{{
				{~unnecessary.bass[0]=Pmono(
					\bl,
					\degree, Pseq([ 2,2,1,1 ])-1,
					//\dur,Pseq([0.5,1.5]*1.24,2),
					\dur,
					Pseq(
						[ ~unnecessary.durs[2].list[0] ,~unnecessary.durs[2].list[1..4].sum  , ~unnecessary.durs[2].list[5..6].sum,1])
					,
					\root,4,
					\octave,2,
					\trig,1);}
	); //}}}
	~unnecessary.metabolism=(start:2,music: //{{{ 
		//t=TempoClock.new.tempo_( 1.2 );
		//u=TempoClock.new.tempo_( t.tempo*0.666 );

		Pfindur(4,//12,
			Ppar([
				//Pseq(~unnecessary.pbind[1..2]),
				//a.[0]=Pmono(\bl,\degree,2-1,\dur,0.5,\root,4,\octave,2,\trig,1);
				~unnecessary.pbind[2],
				~tk.at(\hat),
				Pbindf(~tk.at(\pulse), \degree,Pseq([\r,-2,4,-2],1),\dur,0.662 ),//.play
				Pbindf(~tk.at(\saw), \degree,Pseq([-1,4,-1,3]) ),//( ,\dur,0.331),
				~tk.at(\snare),
			])
		);
		//~tk.at(\hat).play(u)
	);//}}}
//~sections5.metabolism.p;//just making louder hmmm
//~unnecessary.play;
);


