(
//Song.dursFile_("/Users/michael/tank/super/theExtreme_Sep18");
var guitar,guitar2,piano;

//re-connect if vst exists
try{ ( Song.currentSong == \three ).not.if{ 
	guitar = Song.guitar;
	guitar2 = Song.guitar2;
	piano = Song.piano;
} };

Song( \three, [] ).current;

Song.resources.condition=Condition.new;

// initialize if none
guitar.isNil.if{Song.guitar=AAS_Strum()}{Song.guitar=guitar}; 
guitar2.isNil.if{Song.guitar2=AAS_Strum()}{Song.guitar2=guitar2};
piano.isNil.if{Song.piano = PF()};

Song.resources.vstis = [Song.guitar, Song.guitar2, Song.piano];

Song.resources.infrastructure=FunctionList.new([
	{
		 fork {
			Song.guitar.condition.wait{Song.guitar.controller.loaded};
			Song.guitar2.condition.wait{Song.guitar2.controller.loaded};
			Song.piano.condition.wait{Song.piano.controller.loaded};
			Song.resources.condition.test_(true).signal;

			Song.guitar.setPlayMode(\strum);
			Song.allNotesOff;
			0.05.wait;
	}

	}
]);

//Song.guitar.node[1]=\filter->{|in|PlateReverb.ar(in,mix:0.5)};
//Song.guitar.node[2]=\filter->{|in|Phaser2.ar(in,rate:0.1,mix:0.5).distort(0.95)};
//Song.guitar.node.play(vol:1);
["r three alien minds","d3 f5 f e e e"].addLine; //0
~justTheTune.('minds');

~bass0quarters=Song.parse(0,[ [1,1],[1,1,1],1 ]);

Song.guitarFx={ |b|
	var e = Effect( { |i|  
		PlateReverb.ar(i,mix:0.5,decayTime:0.5)  
		=> Phaser2.ar(_,rate:0.1).distort(0.95) *0.3 
		* Env.linen(0,b.sum,3).kr(2,gate:1)
	},inputChannels:2 );
	e.synth.run(false);
	e
};

Song.guitarFx0= Song.guitarFx.(Song.durs[0].list.sum + 5);

P(\guit0,start:\minds,music: { |p b e|
	var out = Song.guitarFx0.synth.run(true);
		[
			legato:0.95,
			midinote: [ [2,4],1,-5 ].dm().q,
			dur: ~bass0quarters + [0,0,3] => _.q ,
		].p 
		+=
		[
			switch:[\down,\down,\up].q(2) ++ [\down].q,
			dur:Pseq( 
				~bass0quarters[0]*[2,1,1]/4 ++ (~bass0quarters[1]*[1.9,1,1.1]/4)//moved with bass
				,3 
			),
			amp:Pseq([4,3,3]/10,3),
		].p 
		<> (out: p.guitarFx.(b).bus.index, type:\strum, instance:p.guitar)
		 => _.play
});

P(\lick,start:0,music:[ 
	degree:Pseq([6,5,7]-1),
	dur:Pseq(~bass0quarters),//Pseq([2,2,4]),
	instrument:\sawSynth,
	att:1,
	rel:4,
	amp:0.05].p
);
P(\bass0,start:0,music: {
		[
		degree:Pseq([2,2,1,1,1,-2])-1,
		dur: Pseq(
			[~bass0quarters[0]*[3,1]/4 , ~bass0quarters[1]*[1,1.4,1.6]/4, 2].flatten
			//		[~bass0quarters[0]*[3,1]/4 , ~bass0quarters[1]*[1,2,1]/4, 2].flatten
		),
		octave:4
	].pp
}
); 
["now inhabit the bodies of", "d5 c b4 a g f g a"].addLine;  //1
//Song.gfx1.synth.run(false);
P(\guit1,start:1,music: { |p b e|
	var out = Song.guitarFx.(Song.durs[1].list.sum+5);
	out.synth.run(true);
	Song.guitar.setPlayMode(\strum);
	[
		degree: [5,[4,6,8],[3,5,8],[2,4],[2.1,4.1,6,8],[3,6,7],[3,5,7]].q - 1,
		octave: 4,
		dur: p.parse(1,[5,2,1]).q
		++ p.parse(2,[3,5,1,1]).q,
		legato: 0.96,
	].p
	+=
	[
		dur: p.parse(1, [1,1,2,1,2,1])
		++ p.parse(2, [1,1,1,5,1,1])
		=> _.q,
		switch: [\down,\up,\down].q(2)
		++ [\up,\four,\three,\down].q
		++ [\down,\five].q
		,
		amp:[0.2,0.01,0.2].q(2)
		++ [0.2,0.1,0.1,0.2].q
		++ [0.2,0.1].q
	].p 
	<> (\out:
		out.bus.index
		//p.guitarFx.(b ++ [5])
		, type:\strum, instance:p.guitar) 
	=> _.play
});
P(\connectorBass,start:1,music: //		{{{
	{
		[
			degree:Pseq([Rest(),3,2,1,1.1,2,3,4,4-7,0,7,0])-1,
			dur:Pseq(Song.parse(1,[[1,1,1,1,1],[1,1],1])++Song.parse(2,[[1,1,1],[1,1,1,1,1],1,1])++
			Song.parse(3,[[1,1],1,[1,1],1,1])),
			octave:3, root:2, scale:Scale.dorian
		].pp
	}
); 
["Captain Kirk,science officer Spock and", "b c5 f4 c5 d c b4 a a g"].addLine;  //2
P(\chords,start:2,syl:2,music:{|p b e|
	
		Song.piano.controller.synth.set(\out,
			Effect(SineShaper.ar(_, limit:0.03, mul:3.0, add:0) * [0.8,0.2], inputChannels:2).bus.index
	);
	
		[
		type:\vst_midi,
		//note:[6,[4,-1],5].q,
		freq: [4.5, [-7, 3], [4], [3,5]].df(octave:4).q,
		legato: [1, [2, 1],  1,      1 ].q,
		dur: p.parse(2,[[1,1,1,1,1],[1,1]],3)++[ e.bNext.parse([3]), 2 ] => _.flat => _.q,
		vst:p.piano.controller ,
		amp:0.2,
		octave:4,
		legato:1,
	].pp 
}
);
["Doctor Jane Mulhall. As -- ","b c5 d d c c f"].addLine; //3
P(\playMode,start:3,syl:4,music:  //////////////FFFFFFFIIIIIIIIXXXXXXXX
	{
		(
			type:\vst_set,
			instance:Song.guitar2,
			params:['Play Mode: Play Mode','Effect 1: On'],
			'Play Mode: Play Mode':0,'Effect 1: On':0
		)//.play
	}
);
P(\slide,start:3,syl:4,music: { |p b e|
	Song.guitar.setPlayMode(\pick);
	[
		type:\strum,
		note:Pseries(0,1,6)+[0,4],
		//amp:1,
		dur:Pseq([(1.1*0.882),0.1,0.1,0.1,0.1,1]*0.68),
		//dur:[b[0..1].sum]++((b[2]/7)!4)++2=>_.flat=>_.q,
		legato:Pseq([1.5,1.5,1.5,1.5,0.9,2]),
		instance:Song.guitar,
		out:Effect( { |i| 
			var env = Env.linen(0.5,b.drop(1).sum+3,1).kr(2,gate:1);
			SmoothClipQ.ar(i*(env*5+1),lo:-1+( env*0.9 ),hi:1-( env*0.9 )) 
			*0.6
	} ).bus.index
	].pp;
}) ;  
P(\guitar24,start:3,syl:4,
	music: { Pmono(
		//\degree,Pseq([5,5,5,5,4,4,4,4,8,8,8,8,6,6,6,6],inf)+[0,5]-21,
		\pluckD,
		\degree,Pseq([ [1,3,5],[1,4,6] ])-1,
		\amp,0.025,
		\out,[0,1],
		\smooth,Pwhite(0.2,0.3,inf),
		\del,Pwhite(0.5,1,inf),
		\dur,Pseq(
			Song.parse(3,[ [1,1] ]) ++2
		)
		,
		\coef,0.1,//Pbrown(0.1,0.9,0.03),
		\lag,Pwhite(-0.01,0.01)
	).play; }
);
["Planned the con- struc- tion of an- droid","f5 c d c a4 c5 g f"].addLine; //4
~quarters4=Song.parse(4,[1,2,3,2]);
P(\bass4,start:4,music: {|p b e|
		[
			dur:Pseq( 
				[
					~quarters4[0]+(~quarters4[1]*0.5),
					~quarters4[1]*0.5,
					~quarters4[2]+(~quarters4[3]*0.5),
					~quarters4[3]*0.5
				].flatten,   2
			),
			amp:0.5,
			degree:Pseq([4,3,2,2,5-7,5-7,5-7]-1),
			octave:3
		].pp
	}
);
P(\guit4,start:4,music: //		{{{
	{ //do these with an event instead??
		var roots=[
			//lag:0.19,
			note:[-7,[2,5],-5].q,
			type:\strum,
			instance:Song.guitar2,
			dur:Pseq([2,2,4]*~quarters4.sum/4),
			legato:0.94
		].p;
		var strums=[

			type:\strum, switch:Pseq([Rest(),\down,\up])++Pseq([\down,\down,[Rest(),\up].choose],3),
			instance:Song.guitar2,
			dur:[2,1,1]/2 => _.q(4) * ~quarters4.sum/4,
			amp:0.05
		].p;

			Song.guitar2.setPlayMode(\strum);
		Ppar([roots,strums]).play;
	}

);
["ro- bots is un- der- way","e5 d c d  e g4"].addLine; //5
["All is pro- cee- ding as ex- pect- ed and as pro- mised (ba- by)","f g a c5 d b-4 c5 d e- b-4 d5 e- d b-4 c5 d"].addLine; //6
~quarters6= Song.parse(6,1!4!4);
q=0.9; ~gr=0.2; 
P(\guitar2h5,start:6,music: {|p b e|
	var out;
	p.guitar2.setPlayMode(\pick);
	p.guitar2.controller.synth.set(\out,
		out = Effect( { |i| 
		SmoothClipQ.ar(i*8,lo:-0.1,hi:0.1) 
		*0.5
	}).bus.index);
	[
		degree:Pseq([1,2,3,5,4]-1),
		//dur:Pseq(1!4++[4]/2),
		dur: Pseq(Song.durs[6].list[0..3]++Song.durs[6].list[4..7].sum),
		legato:0.95,
		root:5,
		octave:3,
		type:\strum,instance:p.guitar2,
	 
	].p += 

		[ 
			degree:Pseq([1,2,3,5,5.1,6]-1),
			//dur:Pseq([1,1,1, (1-~gr),~gr,4 ]/2*0.98),
			dur:Pseq(Song.durs[6].list[0..2]++[Song.durs[6].list[3]-~gr,~gr,3.5]),
			legato:Pseq([q,q,q,1.4,1.4,1]),
			root:5,
			octave:3,
			type:\strum,
			instance:Song.guitar2,
		].p
	<> (out:out) =>_.play; 
}); 
P(\guitar2h6II,start:6,syl:7,music: {|p b e|
	[ 
		degree:Pseq([[4, 6.1, 2 ],4]-1),
		dur: Pseq(~quarters6[2..3]) ,
		legato:0.96,
		root:5,
		octave:3,
		type:\strum,instance:Song.guitar2,

	].pp; }
); 
P(\guitar2h5Strum,start:6,syl:5,music:{|p b e|
	p.guitar2.setPlayMode(\strum);
	[ //		{{{
		//var b2s=[
		type:\strum,
		instance:Song.guitar2,
		switch:Pseq([\down, \up, \down,],3),
		//dur:Pseq([1,1,2]/2,3),
		dur:Pseq(Song.durs[6].list[6..7]++Song.durs[6].list[8..9].sum,3),
	].pp;

}); 
P(\guit6,start:6,music: {
	}
);
P(\bass6,start:6,music:
	{
		[
			degree:Pseq([Rest(),1,4,1,2]-1),
			root:10,
			octave:2,
			amp:0.4,
			dur:Pseq( Song.parse(6, 1!4!4))
		].pp
	}
);
P(\saw6,start:6,music:
	{
		[ 
			degree:Pseq([Rest(),1,4,1]-1),
			//dur:Pseq([5,4,4,2 ,3])/2,
			dur:Pseq( Song.parse( 6, [1!5,1!4,1!4,1!2])++[3]) ,
			//type:\vsti,
			//controller:p.controller
			instrument:\sawSynth,
			rel:3,att:0.2,
			//amp:0.35,
			amp:0.1,
			root:5,octave:[4,5]
		].pp;
	}
);
P(\pf6,start:6,syl:7,music:
	{
		[
			degree:Pseq([2,4,6,6.1,1,4,5,6])-1,
			root:5,
			instrument:\default,
			octave:[6,5],
			//dur:0.5,
			dur:Pseq(Song.durs[6].list[8..]),
			legato:3,
			amp:0.10
		].pp;
	}
);
["I can see no rea- son for con-","e-5 d c b-4 g b- c5 d"].addLine; //7
["cern. And yet, I am filled with fore- bo- ding...", "d5 c b4 a b c5 e4 a g f#"].addLine; //8
SynthDef(\avsd, 
	{
		|freq=400 att=0.05 |
		var fenv= Env.perc(att,8.5).kr(gate:1);
		var env= Env.perc(att*2.2,8.5).kr(gate:1);
		var tail= Env.perc(att*2.2,11).kr(2,gate:1);
		var freqs= freq*rrand(0.99,1.01!2);//
		var sig= SawDPW.ar(freqs,mul:\amp.kr(0.05));
		sig=Formants.ar(freqs/2,Vowel())*0.1+sig;
		sig=MoogVCF.ar(sig,fenv*1500+(freq),0.9);
		sig=PlateReverb.ar(sig,mix:0.2);
		Out.ar(\out.ir(0),sig*env);
	},[0.3]
).add; 
SynthDef(\tritri,{
	|freq=400 gate=1|
	var sig=DPW3Tri.ar(freq,\amp.kr(0.1));
	var env= Env.asr(\att.kr(0.1),\sus.kr(1),\rel.kr(2)).kr(2,gate:gate);
	Out.ar(\out.ir(0),sig*env);

}).add; 
P(\forboding8,start:8,music:
	Ppar([
		[
			degree:Pseq([\r,[0,2,5],[-1,1.1]]-1),
			root:2,
			scale:Scale.mixolydian,
			octave:[4,5],
			instrument:\tritri,
			att:0.2,
			rel:3,
			amp:0.06,
			dur:Pseq(Song.parse(8,[1!3,1!5,1!2])),
		].p,
		Pmono(
			*[
				\avsd,
				degree:Pseq([ [1,3],[0,2],[6-7,1.1]]-1),//thicken chord?
				//degree:Pseq([ [1,3],[0,2],[5-7,1]]-1),
				att:2,
				scale:Scale.mixolydian,
				dur:Pseq(Song.parse(8,[1!3,1!5,1!2])),
				root:2,
			]
		),
		Song.pbind[8],
		[
			degree:Pseq([[1,1-7],6-7,7-7,[6-7,1.1],5-7-7]-1),
			//degree:Pseq([1,6-7,7-7,[5-7,1]]-1),
			root:2,
			octave:4,
			dur:Pseq(Song.parse(8,[[1,1],1,1!5,1!2]))++Pseq([8]),
			scale:Scale.mixolydian
		].p,

		[ //final chord
			instrument:\avsd,att:8,amp:0.018,degree:Pseq([\r,[5,7,9,11.1]-1]),dur:Pseq([8,12]),octave:4,root:2,
		].p
	])
);


//	Song.chords= Part(start:0,lag:0.18,music:Pbind(*[ //		{{{
//	degree:Pseq([[5,8],[5,7],[4,6]])-1,
//	dur: Pseq(Song.parse(0,[[1,1],[1,1,1],[1]])) ,
//	octave:4,
//	type:\vsti,
//	controller:Song.guitar2.controller,
//	legato:0.9,
//	root:2,
//	scale:Scale.dorian
//	]));// 	}}}

//"Planned the con- struc- tion of an- droid","f5 c d c a4 c5 g f",//4
//should be in infra
//????


Song.addGuides("xxxxxxxxx");
)
