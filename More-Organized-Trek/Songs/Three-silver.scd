(
//Song.dursFile_("/Users/michael/tank/super/theExtreme_Sep18");
"/Users/michael/tank/super/Library/synthdefs/AAS-strum.scd".load;
//note need to load song for guitar to play :(
Song( \three, []).current;

Song.infrastructure={'no infra!'.postln};
Song.piano.isNil.if({Song.piano=~vsti.('Pianoteq 5')},{Song.piano.synth.isPlaying.not.if({Song.piano=~vsti.('Pianoteq 5')})});
//setup guitars now //		
try{Song.guitar.controller.loaded.not.if{Song.guitar=~guitar.()}}{Song.guitar=~guitar.()};
fork{
	Song.guitar !? ( { |i| i.controller.loaded.not.if{Song.guitar=~guitar.()}} ) ?? {Song.guitar=~guitar.()};
	while {Song.guitar !? (_.node.isNil)} { 0.1.wait };
	Song.guitar.node[1]=\filter->{|in|PlateReverb.ar(in,mix:0.5)};
	Song.guitar.node[2]=\filter->{|in|Phaser2.ar(in,rate:0.1,mix:0.5).distort(0.95)};
};
Song.guitar.node.play(vol:1);
["r three alien minds","d3 f5 f e e e"].addLine; //0
~justTheTune.('minds');
~bass0quarters=Song.parse(0,[2, 3, 1]);
P(\guit0,start:\r,music: {
	Ppar([
		[
			type:\vst_set,
			vst:Song.guitar.controller,
			params:['Play Mode: Play Mode'],
			'Play Mode: Play Mode':0.6
		].p,
		[
			type:\strum,vst:Song.guitar.controller,
			switch:Pseq([\down,\down,\up],3)++Pseq([\down]),

			dur:Pseq( 
				~bass0quarters[0]*[2,1,1]/4 ++ (~bass0quarters[1]*[1.9,1,1.1]/4)//moved with bass
				,3 ),
				amp:Pseq([4,3,3]/10,3),
				'Play Mode: Play Mode':0.6,
			].p,
			[
				//type:\vsti,controller:Song.guitar.controller,
				type:\vst_midi,vst:Song.guitar.controller,
				legato:0.95,
				note:Pseq([ [2,5],0,-5 ]),
				dur:Pseq(
					~bass0quarters+[0,0,3]
				),
			].p
		]
	).play
});

P(\lick,start:\r,music:[ 
	degree:Pseq([6,5,7]-1),
	dur:Pseq(~bass0quarters),//Pseq([2,2,4]),
	instrument:\sawSynth,
	att:1,
	rel:4,
	amp:0.05].p
);
P(\bass0,start:\r,music: 
	[
		degree:Pseq([2,2,1,1,1,-2])-1,
		dur: Pseq(
			[~bass0quarters[0]*[3,1]/4 , ~bass0quarters[1]*[1,1.4,1.6]/4, 2].flatten
			//		[~bass0quarters[0]*[3,1]/4 , ~bass0quarters[1]*[1,2,1]/4, 2].flatten
		),
		octave:4
	].p
); 
["now inhabit the bodies of", "d5 c b4 a g f g a"].addLine;  //1
P(\guit1,start:\now,music: {
	[ //		{{{
		type:\vst_midi,vst:Song.guitar.controller,
		degree:Pseq([5,[4,6,8],[3,5,8],[2,4],[2.1,4.1,6,8],[3,6,7],[3,5,7]]-1),
		octave:4,
		dur:Pseq(
			Song.parse(1,[[1,1,1,1,1],[1,1],1])
			++
			Song.parse(2,[[1,1,1],[1,1,1,1,1],1,1])
		),
		legato:0.96,
		'Play Mode: Play Mode':0.6,
		//lag:0.18
	].pp;
	( type:\vst_set,
		vst:Song.guitar.controller,
		params:['Play Mode: Play Mode'],
		'Play Mode: Play Mode':0.6
	).play
}
);
P(\connectorBass,start:\now,music: //		{{{
	[
		degree:Pseq([Rest(),3,2,1,1.1,2,3,4,4-7,0,7,0])-1,
		dur:Pseq(Song.parse(1,[[1,1,1,1,1],[1,1],1])++Song.parse(2,[[1,1,1],[1,1,1,1,1],1,1])++
		Song.parse(3,[[1,1],1,[1,1],1,1])),
		octave:3, root:2, scale:Scale.dorian
	].p
); 
["Captain Kirk,science officer Spock and", "b c5 f4 c5 d c b4 a a g"].addLine;  //2
P(\strum1_2,start:\now,music:
	[

		type:\strum,vst:Song.guitar.controller,
		dur:
		Pseq(
			Song.parse(1,[1,1,[1,1],1,[1,1],1])
			++ 
			Song.parse(2,[1,1,1,[1,1,1,1,1],1,1])
		)
		,
		//dur:Song.durs[1],
		switch:Pseq([\down,\up,\down],2)
		++
		Pseq([\up,\four,\three,\down])
		++
		Pseq([\down,\five])
		,
		amp:Pseq([0.2,0.01,0.2],2)
		++
		Pseq([0.2,0.1,0.1,0.2],1)
		++
		Pseq([0.2,0.1])
		,
		//lag:0.2
	].p;
);
P(\chords1,start:\Captain,syl:2,music: //		{{{
	[
		type:\vst_midi,
		note:Pseq([6,[4,-1],5]),
		dur: Pseq( Song.parse(2,[[1,1,1,1,1],[1,1]],3)++2),
		vst: Song.piano ,

		octave:4
	].p
);
["Doctor Jane Mulhall. As -- ","b c5 d d c c f"].addLine; //3
P(\guitarSetup,start:\Doctor,syl:3,music: //		{{{
	{ 
		Song.guitar.node.fadeTime_(0.5);//make this right
		Song.guitar.node.play(vol:1);
		Song.guitar.node[1]=\filter->{|in|SmoothClipQ.ar(in*6,lo:-0.1,hi:0.1,foldRange:0.5)*0.6};
	};

);
P(\playMode,start:\Doctor,syl:4,music:
	(type:\vst_set,vst:Song.guitar.controller,params:['Play Mode: Play Mode','Effect 1: On'],
	'Play Mode: Play Mode':0,'Effect 1: On':0
)
);
P(\slide,start:\Doctor,syl:4,music: { |p b e|
	[
		type:\vst_midi,
		note:Pseries(0,1,6)+[0,4],
		//amp:1,
		dur:Pseq([(1.1*0.882),0.1,0.1,0.1,0.1,1]*0.68),
		//dur:[b[0..1].sum]++((b[2]/7)!4)++2=>_.flat=>_.q,
		legato:Pseq([1.5,1.5,1.5,1.5,0.9,2]),
		vst:Song.guitar.controller,
	].pp;
}) ;  
P(\guitar4,start:\Doctor,syl:4,
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
~quarters4=Song.parse(4,[1, [1,1], [1,1,1], [1,1] ]);
P(\bass4,start:\Planned,music:
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
	].p
);
P(\guit4,start:\Planned,music: //		{{{
	{ //do these with an event instead??
		var roots=[
			//lag:0.19,
			note:Pseq([-7,[2,5],-5]),
			type:\vst_midi,
			vst:Song.guitar.controller,
			dur:Pseq([2,2,4]*~quarters4.sum/4),
			legato:0.94
		].p;
		var strums=[

			type:\strum, switch:Pseq([Rest(),\down,\up])++Pseq([\down,\down,[Rest(),\up].choose],3),
			vst:Song.guitar.controller,
			dur:Pseq([2,1,1]/2,4)*~quarters4.sum/4,
		].p;
		( type:\vst_set,
			vst:Song.guitar.controller,
			params:['Play Mode: Play Mode'],
			'Play Mode: Play Mode':0.6
		).play;

		Song.guitar.node.play(vol:0.5);
		Ppar([roots,strums]).play;
	}

);
["ro- bots is un- der- way","e5 d c d  e g4"].addLine; //5
try{~h.controller.loaded.not.if{~h=~guitar.()}}{~h=~guitar.()};
P(\guitarPatches5,start:5,lag:-1,music: //		{{{
	{
		{
			~h.node[1]=\filter->{|in| in*2*0.5};
			Song.guitar.node[1]=\filter->{|in|SmoothClipQ.ar(in*8,lo:-0.1,hi:0.1,foldRange:0.5)*0.5};
		}.value
	}
);
["All is pro- cee- ding as ex- pect- ed and as pro- mised (ba- by)","f g a c5 d b-4 c5 d e- b-4 d5 e- d b-4 c5 d"].addLine; //6
~quarters6= Song.parse(6,1!4!4);
q=0.9; ~gr=0.2; 
P(\guitarh5,start:6,music: //		{{{
	[
		degree:Pseq([1,2,3,5,4]-1),
		//dur:Pseq(1!4++[4]/2),
		dur: Pseq(Song.durs[6].list[0..3]++Song.durs[6].list[4..7].sum),
		legato:0.96,
		root:5,
		octave:3,
		type:\vst_midi,vst:~h.controller,
		//'Play Mode: Play Mode':0
	].p;
); 
P(\guitarh6II,start:6,syl:7,lag:0.10,music:[ //		{{{
	degree:Pseq([6.1,4]-1),
	dur: Pseq(~quarters6[2..3]) ,
	legato:0.96,
	root:5,
	octave:3,
	type:\vst_midi,vst:~h.controller,
].p;
); 
P(\guitarh5Strum,start:6,syl:5,music:{
	[ //		{{{
		//var b2s=[
		type:\strum,
		vst:~h.controller,
		switch:Pseq([\down, \up, \down,],3),
		//dur:Pseq([1,1,2]/2,3),
		dur:Pseq(Song.durs[6].list[6..7]++Song.durs[6].list[8..9].sum,3),
	].pp;
	( type:\vst_set,
		vst:~h.controller,
		params:['Play Mode: Play Mode'],
		'Play Mode: Play Mode':0.6
	).play;

}); 
P(\guit6,start:6,music:[ //		{{{
	degree:Pseq([1,2,3,5,5.1,6]-1),
	//dur:Pseq([1,1,1, (1-~gr),~gr,4 ]/2*0.98),
	dur:Pseq(Song.durs[6].list[0..2]++[Song.durs[6].list[3]-~gr,~gr,3.5]),
	legato:Pseq([q,q,q,1.4,1.4,1]),
	root:5,
	octave:3,
	type:\vst_midi,
	vst:Song.guitar.controller,
	'Play Mode: Play Mode':0
].p;
);
P(\bass6,start:6,music:
	[ //		{{{
		degree:Pseq([Rest(),1,4,1,2]-1),
		root:10,
		octave:2,
		amp:0.4,
		dur:Pseq( Song.parse(6, 1!4!4))
	].p
);
P(\saw6,start:6,music:[ //		{{{
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
].p;
);
P(\pf6,start:6,syl:7,music:[ //		{{{
	degree:Pseq([2,4,6,6.1,1,4,5,6])-1,
	root:5,
	instrument:\default,
	octave:[6,5],
	//dur:0.5,
	dur:Pseq(Song.durs[6].list[8..]),
	legato:3,
	amp:0.10
].p;
);
["I can see no rea- son for con-","e-5 d c b-4 g b- c5 d"].addLine; //7
["cern. And yet, I am filled with fore- bo- ding...", "d5 c b4 a b c5 e4 a g f#"].addLine; //8
SynthDef(\avsd, //		{{{
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
P(\forboding8,start:\cern,music:
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


//	Song.chords= Part(start:\r,lag:0.18,music:Pbind(*[ //		{{{
//	degree:Pseq([[5,8],[5,7],[4,6]])-1,
//	dur: Pseq(Song.parse(0,[[1,1],[1,1,1],[1]])) ,
//	octave:4,
//	type:\vsti,
//	controller:Song.guitar.controller,
//	legato:0.9,
//	root:2,
//	scale:Scale.dorian
//	]));// 	}}}

//"Planned the con- struc- tion of an- droid","f5 c d c a4 c5 g f",//4
//should be in infra
//????


Song.addGuides("xxxxx..xx");
)
