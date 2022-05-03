(
	Song( \unnecessary,[]).current;

 //	unnecessary sections	{{{2
	//Song.resources=();
	Song.currentSong.condition=Condition.new;
	Song.currentSong.infrastructure={
		//~synthsLoaded.isNil.if{"/Users/michael/tank/super/song-Synthdefs.scd".load};
		Song.condition.test_(true).signal;
	};
	Song.currentSong.infrastructure = Song.infrastructure.addFunc( {
		Song.unnecessaryBass=NodeProxy.audio(s,2).play; //	bass setup	{{{3
		Song.unnecessaryBass[1]=\filterIn->{|in|in+CombN.ar(in,1,0.25/TempoClock.tempo,2,mul:0.8)/2};
		Song.unnecessaryBass.set(\wet1,0.8);
		Song.unnecessaryBass[2]=\filter->{|in| Phaser1.ar(in,  depth: 0.5,  rate: 0.2,  fb: 0.3,  cfb: 0.1,  rot: 1.5707963267949) };
	} );
//TODO CLEAN THIS UP!!!!!!

e = Environment.new.push;
	Song.notes=[1,3,6,4].collect{|i| i!4}.flatten;

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
( ~tk.add(\hat->
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

	SynthDef(\pulse,{|gate=1 freq=400 amp=1 ffreq=4500 rel=2 out=0 t_trig wiggle=500| //		{{{4
		var sig=Pulse.ar(freq,SinOsc.kr(8.55,0,0.6,0.4));
		var env= Env.perc(0,rel).kr(0,gate:t_trig)*amp;
		//var env=0.1;
		sig= MoogFF.ar(sig,SinOsc.kr(0.3,0,wiggle,1150));
		sig=HPF.ar(sig,500);
		Out.ar(0,sig*env!2)}
	).add;
( ~tk.add( \pulse-> //		{{{4
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
( ~tk.add(\saw-> //		{{{4
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

	Song.cursor_(0); //
	//{{{1
	//TempoClock.tempo=1;
["that will be unneccesary Doctor"," d# e f# d# g# f# e d# d# c#"].addLine;//0

	P(\unnecessary, start:0,music:Song.pbind[0]);
	P(\descant,start:0,music: //		{{{
		Pbind(*[
			instrument:\sawSynth,
			degree:Pseq([\r,8,7,6,5,5,4.1])-1,
			att:0.7,
			root:4,
			dur:Pseq(
				[Song.durTill(0,3)]++Song.durs[0].list [4..9]++[0.5,2]
			)
		])
	);//}}}
	P(\unnecBass,start:0,music: //		{{{
		Pbind(*[
			instrument:\sawSynth,
			degree:Pseq([5,2])-1,
			rel:4,
			dur:Song.durTill(0,7),
			//dur:Pseq([2.3,1]),
			root:4,
			octave:3
		])
	);//}}}
["(four bar intro)","r"].addLine;
	P(\leadIn,start:'four bar intro',music: //		{{{
		Pfindur(8,
			Ppar([
				//Pseq([Song.pbind[1]],4).play;
				~tk.at(\snare),
				~tk.at(\kick),
				~tk.at(\pulse),
				~tk.at(\saw),
				~tk.at(\hat)
			])
		)
	); //}}}

	Song.durs['four bar intro']=Pseq([1,1,1.5,0.25,0.25+0.5, 0.5,0.5,0.25,0.25+0.5,0.5,0.5,0.5]);
	P(\tempo1,start:'four bar intro',music:{{TempoClock.tempo=1.2}.fork});
["r this Vulcan body is adapted to the","r b b g# f# e f# g# f# e d# e"].addLine;//1
	Song.durs['is adapted']=Pseq([1,1,1.5,0.25,0.25+0.5, 0.5,0.5,0.25,0.25+0.5,0.5,0.5,0.5]);
//	Song.durs[1]=Pseq((Song.durs[1].list!2).flatten	);
	P(\tempo2,start:'adapted to',music:{{TempoClock.tempo=1.2}.fork});
	P(\bass1,start:'adapted to',music: {
		{
//			Song.unnecessaryBass[0]=Pseq([Rest(8),Pmono(\bl,\degree,Pseq(Song.notes,4)-1,\dur,0.5,\root,4,\octave,2,\trig,Pseq(1!16))])
			Song.unnecessaryBass[0]=Pseq([Pmono(\bl,\degree,Pseq(Song.notes,4)-1,\dur,0.5,\root,4,\octave,2,\trig,Pseq(1!16))]);
			Song.unnecessaryBass[1]=\filterIn->{|in|in+CombN.ar(in,1,0.25/TempoClock.tempo,2,mul:0.8)/2};
			Song.unnecessaryBass.set(\wet1,0.8);

		}.value
	});
	P.tune('is adapted',{|i|i=>Pbindf(_,\amp,0.3,\instrument,\stringyy)});
	P(\leadInB,start:'adapted to',music: //		{{{
		Pfindur(8,
			Ppar([
				//Pseq([Song.pbind[1]],4).play;
				~tk.at(\snare),
				~tk.at(\kick),
				~tk.at(\pulse),
				~tk.at(\saw),
				~tk.at(\hat)
			])
		)
	); //}}}
["r r higher metabolism"," f#3 f# a5 g# b a g# f# e "].addLine;//2
//	P(\tempo3,start:'higher metabolism',music:{{TempoClock.tempo=1}.fork});
	P(\bass3,start:'higher metabolism',music: //		{{{
				{Song.unnecessaryBass[0]=Pmono(
					\bl,
					\degree, Pseq([ 2,2,1,1 ])-1,
					//\dur,Pseq([0.5,1.5]*1.24,2),
					\dur,
					Pseq(
						[ Song.durs['higher metabolism'].list[0] ,Song.durs['higher metabolism'].list[1..4].sum  , Song.durs['higher metabolism'].list[5..6].sum,1])
					,
					\root,4,
					\octave,2,
					\trig,1);}
	); //}}}

	P.tune('higher metabolism',{|i| Pbindf(i,\instrument,\stringyy,\amp,0.3,\mix,1.0,\release,2)=>_.drop(2) },syl:1);

	P(\metabolism,start:'higher metabolism',music: //{{{
		//t=TempoClock.new.tempo_( 1.2 );
		//u=TempoClock.new.tempo_( t.tempo*0.666 );

		Pfindur(4,//12,
			Ppar([
				//Pseq(Song.pbind[1..2]),
				//a.[0]=Pmono(\bl,\degree,2-1,\dur,0.5,\root,4,\octave,2,\trig,1);
//				Song.pbind['higher metabolism'],
				~tk.at(\hat),
				Pbindf(~tk.at(\pulse), \degree,Pseq([\r,-2,4,-2],1),\dur,0.662 ),//.play
				Pbindf(~tk.at(\saw), \degree,Pseq([-1,4,-1,3]) ),//( ,\dur,0.331),
				~tk.at(\snare),
			])
		);
		//~tk.at(\hat).play(u)
	);//}}}
//~sections5.metabolism.p;//just making louder hmmm
//Song.play;

["it won't work, Sargon!","d#5 b4 g5 d# b4"].addLine;//3
	P.tune('work, Sargon');
	P(\tempoWork,start:'work',music:{
		{TempoClock.tempo=1}.fork}
	);
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
["til you can administer the ",[7,6,5,4,7,11,6,5].dm('d')].addLine;//6
P.tune('administer');
["(boom) metabolic reduction injection... a ",[11,15,14,15,12,14,12,11,14.5,11,7.5, 7].dm('a-',octave:4,scale:\mixolydian )].addLine;//7
P.tune('injection',Pbindf(_,\legato,1.5,\out,Effect(PlateReverb.ar(_,decayTime:0.4,mix:0.6)).bus.index));
P(\baseNoteMetabolic,start:'metabolic',music:{|p b|
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

e.pop;
)
asCompileString
a=Harmonics()
a.ramp(1,1).sizeS
c=SystemClock.seconds;Song.play
SystemClock.seconds-c

