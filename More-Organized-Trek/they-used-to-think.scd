( //  Song(\theyUsed) {{{

	~synthsLoaded.isNil.if{"/Users/michael/tank/super/song-Synthdefs.scd".load};

	~tu=Song(\theyUsed,[]).current;
		["they used to think if man could ","f3 f g g a a b "].addLine; //0
		["fly, he`d have wings, but he","b3 a g c#4 b3 c#4"].addLine; //1
		["did fly (boom boom)", "e4 d a3 f#"].addLine; //2
		["(boom) he discovered he ","c d4 c b3 a b"].addLine;//3
		["had to.. do you wish that the first","c4 b3 g#3 e b g# a b"].addLine;//3
		["Apollo mission hadn`t reached the","c#4 f# c# e d# b-3 a- b- b"].addLine;//4
		["moon... or that we hadnt  ","c#4 b3 a g a b  "].addLine;//6
		["gone on to" , "d4 e- b3"].addLine; //7
		["Mars, and then to the nearest","a4 g4 g e f g e"].addLine;//8
		["star (boom boom) ","b4"].addLine;//9
		[ "thats like saying you ",[3,1,4,3,4].dm(\B) ].addLine; //10
		[ "wish that you still operated with", [5,3,4,5].dm(\B)++[4,1,2,3,4].dm(\d) ].addLine;//11
		[ "scalpels and sewed your patients up with",[3,2,1,2,3,4.5,2].dm(\e)++[11,6].dm(root:0) ].addLine;//12
		[ "cat-gut like your great great great great", [4,3,4,5].dm(\d,scale:\minor) ++[3,4,2,3].dm(\B,scale:\harmonicMinor) ].addLine; //13
		[ 'grandfather used to',[4,3,2,2,1].dm(root:\A) ].addLine;//14

	~moonChord="e- f a c#" => ~panNotes.(_);
	~marsChords=[0,2].collect{|root| [ freq:	[ [1,4,6].dup++[1,3,5] .dup ].flatten.degreescps(root:root).q ].p }.q;
	//	~recorder.(~tu,3,1);
	//	~tu.pbind.q.play;

	SynthDef( \sawzz,//{{{
		{Saw.ar(\freq.kr(400,\port.kr(0.5)),0.1)
		* Env.asr(0.1,1,2).kr(2,gate:\gate.kr(1))
		* \amp.kr(0.1)
		=>(CombN.ar(_,1)+Gain.ar(_,3))
		=>Out.ar(\out.kr(0),_)}
	).add;
	//}}}
	~tu.resources=();

	//// 2 ///// {{{

//	~tu.durs[4].list
//	~tu.pbind[4].psslay

	~tu.chordi2=(start:2,music:[
//		dur:~tu.secDur[2..3].q,
		dur:~tu.secDur[2..4].q,
		freq:[[2,5,7],[1,4,6],[1,3,5]].df(\g,3).q,
		amp:0.04,
	].p);
	~tu.wowowow=(start:2,syl:1,lag:0,music://{{{
		{{
			var notes = [11,6,3].degreescps;
			var durs = [0]++(~tu.durs[2].list[2..3]).integrate;// + ~tu.durs[2].list[2] ;
			var a;
			{a=Synth(\sawzz,[\freq,notes[0],\amp,0.1]).dur(4)}.sched(durs[0]+s.latency);
			[1,2].do{|i| {a.set(\freq,notes[i])}.sched(durs[i]+s.latency)}
		}.play}
	);//}}}
//}}}
//// 3 //// {{{
	~tu.boomBass=Part(3,music:(note:0,octave:3,amp:0.5,dur:~tu.secDur[3]));
//}}}
SynthDef(\ooh, {| out=0 gate=1| //{{{
	Formants.ar(
		Vibrato.kr(\freq.kr(400,13),\rate.kr(rrand(6,7.0!5)),\depth.kr(0.02)),
		Vowel(\u,\soprano).blend(Vowel(\a,\soprano),VarLag.kr(\blend.kr(0),\lag.kr(0.5)))
	)
	=>Splay.ar(_)
	* Env.cutoff(3).kr(2,gate:gate)
	* \amp.kr(0.1)
	=>Out.ar(out,_)
} ).add; 
								//}}}

	~tu.bass4a=(start:4,music:( //{{{
		freq:[5].df(\c,2),
		amp:0.5,
		dur:~tu.parse(4,[4]),
	));//}}}
	~tu.bass4=(start:4,syl:3,music:[ //{{{
		freq:[5,6,2].df(\e,2,\mixolydian).q,
		amp:0.5,
		dur: ( ~tu.parse(4,[[1,1,1,2/3],1/3],4) + ([0]++~tu.parse(5,[1,2]))).q ,
	].p);//}}}
	~tu.wowowow4=(start:4,syl:1,music:Pmono( //{{{
		\sawzz,
		\freq, [15,13,7].df(\e,4,\mixolydian).q,
		\dur, ~tu.parse(4,[1,1,3],2).q
	));//}}}
~tu.baas6=(start:6,music:(//{{{
	freq:[1].dm('e-',3),
	dur: ~tu.secDur[6],
	amp:0.5,
));//}}}
~tu.ooh=(start:6,music: {{ //{{{
		var choir=Synths(\ooh,
//			\freq,[500,600,660,750]/2,
			\freq,~moonChord.midicps,
			\blend,0,
			\out,{
				~verbBus ?? {~verbBus=Bus.audio(s,2).index};
				~verbBus.value
		}
			);
			~verb={In.ar(~verbBus,2)/2=>FreeVerb.ar(_,0.6,0.9)}.play(s,0,addAction:\addToTail).dur(35);
			{choir.set(\blend,1,\lag,0.5)}.sched(1);
			choir.synths.do{|i|{ { i.set(\blend,1) }.sched(4.2.rand) }.value};
			fork{7.do{choir.set(\blend,[0,0,0,1].scramble) ;rrand(0.6,1.2).wait}};
			{choir.release(4)}.sched(1);
		}.value}
) ;
								//}}}
//~tu.pbind[7].play
~tu.bass7=(start:7, music:[//{{{
	amp:0.5,
	freq:[3,3.5,1].df(\b,2,\minor).q,
	dur: ~tu.parse(7,[[1,1/3],2/3,1]).q,
].p,);//}}}
//~recorder.(~tu,7,2)
~tu.ooh8=(start:8,music:( //{{{
	instrument:\ooh,
	freq: [5,11,13].df(\f),
	blend:1,
	amp:0.01,
	dur: 
	~tu.parse(8,[[1,1]])
	,
));//}}}
~tu.middleVoice=(start:8,music:(note:0,dur:2,instrument:\sawzz,));
~tu.bass8=(start:8,music:[ //{{{
	amp:0.5,
	freq: [11,7,7].df(\f,2).q ,
	dur: ~tu.parse(8,[1,1,1]).q,
].p);//}}}
SynthDef(\pluckD,{|freq=400 amp=1| //{{{
	var sig= Pluck.ar(
		WhiteNoise.ar(0.1),
		trig: \trig.tr(1),
		maxdelaytime: 0.2,
		delaytime: freq.reciprocal,
		decaytime: \del.kr(5),
		coef: \coef.kr(0.6)
	) ;
	sig=CrossoverDistortion.ar(sig,\drive.kr(0.9),\smooth.kr(0.1));
	sig=Phaser2.ar(sig,0.5,0.15,rq:1);
	sig=[sig,sig* Env.asr(0,1,2).kr(0,gate:\gate.kr(1)) => FreeVerb.ar(_,0.6,0.9)];
	sig=XFade2.ar(sig[0],sig[1],\blend.kr(0));  
	sig=DelayN.ar(sig,0.01,Rand(0.01));
	Out.ar(\out.ir, sig*amp);
	DetectSilence.ar(sig,doneAction:2)
}).add;//}}}
~tu.highchord9=(start:9,music:( //{{{
	instrument: \stringyy,
	freq: [1,3].df(\a,6),
	dur: 1
));
//}}}
~tu.quarters8=~tu.parse(8,[2/3,[1/3,1],3,2]);
~tu.sewed12=(start:12,syl:4,music:Pmono(*[ //{{{
	//	instrument:
	\tri,
	attack:3,
	freq:[5,11,11].df(\a,3).q,
	port:1.1,
	dur: ~tu.parse(12,[4],5).q ++ ~tu.parse(13,[1,3]).q,
]));
//}}}
//~tu.sewed12.p;~tu.pbind[12].play
~tu.patience12=(start:12,syl:5,music:[ //{{{
	pan:1,
	amp:0.1,
	instrument: \sawzz,
	freq:[2,1,1].df(\d,5).q,
	dur:~tu.parse(12,[2,1],5).q++[1].q,
].p);//}}}
~tu.bass8=(start:8,music:[ //{{{
	amp:[0.5,0.4,0.1,0.5,0.5,0.1,0.1,0.5,0.5].q,
	freq:[4,4,4,2,3,3,3,3,2].df(octave:3,).q,
//	freq:[4,4,4,3,3,3,2].df(octave:3,).q,
	dur:
//	( ~tu.parse(8,[1/3,2/3,1,1,3,1])++1 ).q
		~tu.quarters8.collect(0.5*_.dup).flatten.q ++ [1].q
	,
].p);//}}}
~tu.guitar8=(start:8,music: Pmono(\pluckD, //{{{
	\blend,[-1,-1,-1,-1,1].q,
//	\gate,[1,1,1,1,-1],
	\amp,0.02,
	\freq, [[11,14],[11,13],[5,12]].collect{|i| i!2}.flatten.df(octave:3).q ,
	\octave,2,
	\out,[0,1],
	\smooth,Pwhite(0.2,0.3,inf),
	\del,Pwhite(0.5,1,inf),
	\dur,~tu.quarters8.q++ ( ~tu.parse(9,[1]).q +0) ,
//	~recorder.(~tu,9,1)
	\coef,Pbrown(0.1,0.9,0.03),
	\lag,Pwhite(-0.01,0.01)
//\lag,[0,1]

));//}}}
~tu.bassnote10=(start:10,music:[ //{{{
	freq:[7,11,12,13,13.5,14.5,15.5].df(\e,3,scale:\harmonicMinor).q,
	dur: ~tu.parse(10,[2,3]).q 
		++ ~tu.parse(11,[4,5]).q
		++ ~tu.parse(12,[5,2,2]).q,
	instrument:\stringyy,
	out: [0,2].q(inf),
	amp:0.3
].p);//}}}
~tu.lick13=(start:13,syl:3,music:Pmono(*[ //{{{
	//	instrument: 
	\sawzz,
	freq: [11,12,7,11,4].df(\b,3,\harmonicMinor).q,
	dur: ~tu.parse(13,[1,1,1,1],4).q++[~tu.secDur[14]].q,
	out: 0,
//	port:1,
] ));//}}}
~tu.bassnote13=(start:13,music:( //{{{
	freq:[ 11,5 ].df(\d,2),
	dur: ~tu.parse(13,[4])
));//}}}

		SynthDef( \harpsichord, { Pulse.ar(\freq.kr(300),0.25,\amp.kr(0.1))* Env.perc().kr(2,gate:1) => Out.ar(\out.kr(0),_)} ).add; 
		~tu.harpsichord13=(start:13,syl:3,music: //{{{
			[
				drive:0,
				decaytime:50,
				strum:0.03,
				dur: ~tu.parse(13,[1,1,1,1],4).q++[~tu.secDur[14]].q,
//				amp:0.02,
//				detune: [-3,10],
//				instrument: \harpsichord,
		  		instrument:\pluckD,
				coef:0.1,
				//		drive:0.1,
				freq:[[5,11,13],[5,12,14],[5,7,12],[5,11,13],[4,6.66,13]].df(\b,3,\harmonicMinor).q * [1,2],
			].p
);//}}}
~tu.lickharmony13=(start:13,syl:3,music:Pbindf( //{{{
	~tu.lick13.music ,
	\freq, [13,14,12,13,7].df(\b,3,\minor).q,
	\out,1,
));//}}}
~tu.bell14=(start:14,syl:2,music:( //{{{
	freq: [5,11].df(\e,5),
	amp:0.02,
	strum: 0.07,
	dur:2,
));//}}}
~tu.highchord14=(start:14, music:( //{{{
	instrument:\stringyy,
	freq: [1,4].df(\e,5),
	dur: ~tu.secDur[14],
));//}}}
~tu.chord14=(start:14,music:( //{{{
	strum:0.06,
	freq:[5,11].df(\a,1) *.x [1,2],
	dur:~tu.secDur[14],
	amp:0.2
));//}}}
	~tu.addGuides("xxx");
	//~tu.pbind[2].play
	//~tu.cursor_(2).play;
	);//}}}
