
( //three alien minds  {{{2
	~three = Song( \three, [
		"r three alien minds","d3 f5 f e e e", //0
		"now inhabit the bodies of", "d5 c b4 a g f g a", //1
		"Captain Kirk,science officer Spock and", "b c5 f4 c5 d c b4 a a g", //2
		"Doctor Jane Mulhall. As -- ","b c5 d d c c f",//3
		"Planned the con- struc- tion of an- droid","f5 c d c a4 c5 g f",//4
		"ro- bots is un- der- way","e5 d c d  e g4",//5
		"All is pro- cee- ding as ex- pect- ed and as pro- mised (ba- by)","f g a c5 d b-4 c5 d e- b-4 d5 e- d b-4 c5 d",//6
		"I can see no rea- son for con-","e-5 d c b-4 g b- c5 d",//7
		"cern. And yet, I am filled with fore- bo- ding...","d5 c b4 a b c5 e4 a g f#" //8
	])
);
//}}}

( //~three sections {{{2
	~three.infrastructure={'no infra!'.postln};
	//~three.cursor_(0);
	//~three.parts=();
	~three.addGuides("xxxxx..xx");
	//~a=nil;
	~three.piano.isNil.if({~three.piano=~vsti.('Pianoteq 5')},{~three.piano.synth.isPlaying.not.if({~three.piano=~vsti.('Pianoteq 5')})});
	~bass0quarters=~three.parse(0,[ [1,1],[1,1,1],1 ]);
	//setup guitars now //		{{{
	try{~g.controller.loaded.not.if{~g=~guitar.()}}{~g=~guitar.()};
	~g.node[1]=\filter->{|in|PlateReverb.ar(in,mix:0.5)};
	~g.node[2]=\filter->{|in|Phaser2.ar(in,rate:0.1,mix:0.5).distort(0.95)};
	~g.node.play(vol:1);
//}}}
//	~three.chords= Part(start:0,lag:0.18,music:Pbind(*[ //		{{{
//	degree:Pseq([[5,8],[5,7],[4,6]])-1,
//	dur: Pseq(~three.parse(0,[[1,1],[1,1,1],[1]])) ,
//	octave:4,
//	type:\vsti,
//	controller:~g.controller,
//	legato:0.9,
//	root:2,
//	scale:Scale.dorian
//	]));// 	}}}
	~three.guit0 = Part(start:0,music: //		{{{
		Ppar([
		[
			type:\strum,controller:~g.controller,
			switch:Pseq([\down,\down,\up],3)++Pseq([\down]),
			
			dur:Pseq( 
					~bass0quarters[0]*[2,1,1]/4 ++ (~bass0quarters[1]*[1.9,1,1.1]/4)//moved with bass
				,3 ),
			amp:Pseq([4,3,3]/10,3),
			'Play Mode: Play Mode':0.6,
		].p,
		[
			type:\vsti,controller:~g.controller,
			legato:0.95,
			note:Pseq([ [2,5],0,-5 ]),
			dur:Pseq(
				~bass0quarters+[0,0,3]
			),
		].p
		])
	);//}}}

	~three.lick = Part(start:0,music:[ //		{{{
		degree:Pseq([6,5,7]-1),
		dur:Pseq(~bass0quarters),//Pseq([2,2,4]),
		instrument:\sawSynth,
		att:1,
		rel:4,
		amp:0.05].p);//}}}
	~three.bass0 = Part(start:0,music: //		{{{
		[
			degree:Pseq([2,2,1,1,1,-2])-1,
			dur: Pseq(
				[~bass0quarters[0]*[3,1]/4 , ~bass0quarters[1]*[1,1.4,1.6]/4, 2].flatten
		//		[~bass0quarters[0]*[3,1]/4 , ~bass0quarters[1]*[1,2,1]/4, 2].flatten
			),
			octave:4
	].p
	); //}}}
		~three.guit1 = Part(start:1,music:[ //		{{{
			type:\vsti,controller:~g.controller,
			degree:Pseq([5,[4,6,8],[3,5,8],[2,4],[2.1,4.1,6,8],[3,6,7],[3,5,7]]-1),
			octave:4,
			dur:Pseq(
				~three.parse(1,[[1,1,1,1,1],[1,1],1])
				++
				~three.parse(2,[[1,1,1],[1,1,1,1,1],1,1])
			),
			legato:0.96,
			'Play Mode: Play Mode':0.6,
			//lag:0.18
		].p
	);//}}}
		~three.strum1 = Part(start:1,music:[ //		{{{
		
			type:\strum,controller:~g.controller,
			dur:
			Pseq(
				~three.parse(1,[1,1,[1,1],1,[1,1],1])
				++ 
				~three.parse(2,[1,1,1,[1,1,1,1,1],1,1])
			)
			,
			//dur:~three.durs[1],
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
	);//}}}
	~three.connectorBass = Part(start:1,music: //		{{{
		[
			degree:Pseq([Rest(),3,2,1,1.1,2,3,4,4-7,0,7,0])-1,
			dur:Pseq(~three.parse(1,[[1,1,1,1,1],[1,1],1])++~three.parse(2,[[1,1,1],[1,1,1,1,1],1,1])++
			~three.parse(3,[[1,1],1,[1,1],1,1])),
			octave:3, root:2, scale:Scale.dorian
		].p
	); //}}}
	~three.chords1 = Part(start:2,syl:2,music: //		{{{
		[
			type:\vsti,
			note:Pseq([6,[4,-1],5]),
			dur: Pseq( ~three.parse(2,[[1,1,1,1,1],[1,1]],3)++2),
			controller:~three.piano,
			octave:4
		].p
	);//}}}
	~three.guitarSetup = Part(start:3,syl:3,music: //		{{{
		{ 
			{ ~g.node.fadeTime_(0.5);//make this right
				~g.node.play(vol:1);
				~g.node[1]=\filter->{|in|SmoothClipQ.ar(in*6,lo:-0.1,hi:0.1,foldRange:0.5)*0.6};
			}.value;
		}
	);//}}}
	~three.slide = Part(start:3,syl:4,music:[ //		{{{
				note:Pseries(0,1,6)+[0,4],
				dur:Pseq([(1.1*0.882),0.1,0.1,0.1,0.1,1]*0.9),
				legato:Pseq([1.5,1.5,1.5,1.5,0.9,2]),
				controller:~g.controller,
				type:\vsti,'Play Mode: Play Mode',0,'Effect 1: On':0].p;
	);   //}}}
	~three.guitar4 = Part( //		{{{
		start:3,syl:4,
		music:
		Pmono(
			//\degree,Pseq([5,5,5,5,4,4,4,4,8,8,8,8,6,6,6,6],inf)+[0,5]-21,
			\pluckD,
			\degree,Pseq([ [1,3,5],[1,4,6] ])-1,
			\amp,0.025,
			\out,[0,1],
			\smooth,Pwhite(0.2,0.3,inf),
			\del,Pwhite(0.5,1,inf),
			\dur,Pseq(
				~three.parse(3,[ [1,1] ]) ++2
			)
				,
			\coef,0.1,//Pbrown(0.1,0.9,0.03),
			\lag,Pwhite(-0.01,0.01)
		);
	);//}}}
		//"Planned the con- struc- tion of an- droid","f5 c d c a4 c5 g f",//4
	~quarters4=~three.parse(4,[1, [1,1], [1,1,1], [1,1] ]);
	~three.bass4 = Part(start:4,music: //fold	{{{
		[
			dur:Pseq( 
				[~quarters4[0]+(~quarters4[1]*0.5),
				~quarters4[1]*0.5,
				~quarters4[2]+(~quarters4[3]*0.5),
				~quarters4[3]*0.5].flatten,   2),
			amp:0.5,
			degree:Pseq([4,3,2,2,5-7,5-7,5-7]-1),
			octave:3
		].p
	);//}}}
	~three.guit4 = Part (start:4,music: //		{{{
		 { //do these with an event instead??
				var roots=[
					//lag:0.19,
					note:Pseq([-7,[2,5],-5]),
					type:\vsti,
					controller:~g.controller,
					dur:Pseq([2,2,4]*~quarters4.sum/4),
					legato:0.94].p;
				var strums=[
					
					type:\strum, switch:Pseq([Rest(),\down,\up])++Pseq([\down,\down,[Rest(),\up].choose],3),
					controller:~g.controller,
					dur:Pseq([2,1,1]/2,4)*~quarters4.sum/4,
					'Play Mode: Play Mode':0.6].p;
				~g.node.play(vol:0.5);
				Ppar([roots,strums]);
				}.value
			
		);//}}}
	try{~h.controller.loaded.not.if{~h=~guitar.()}}{~h=~guitar.()};
	~three.guitarPatches5 = Part(start:5,lag:-1,music: //		{{{
		{
			{
				~h.node[1]=\filter->{|in| in*2*0.5};
				~g.node[1]=\filter->{|in|SmoothClipQ.ar(in*8,lo:-0.1,hi:0.1,foldRange:0.5)*0.5};
			}.value
		}
);//}}}
	~three.guitarh5 = Part(start:6,music: //		{{{
	[
		degree:Pseq([1,2,3,5,4]-1),
		//dur:Pseq(1!4++[4]/2),
		dur: Pseq(~three.durs[6].list[0..3]++~three.durs[6].list[4..7].sum),
		legato:0.96,
		root:5,
		octave:3,
		type:\vsti, controller:~h.controller,
		'Play Mode: Play Mode':0
	].p;
	); //}}}
	~quarters6= ~three.parse(6,1!4!4);
	~three.guitarh6II = Part(start:6,syl:7,lag:0.10,music:[ //		{{{
		degree:Pseq([6.1,4]-1),
		dur: Pseq(~quarters6[2..3]) ,
		legato:0.96,
		root:5,
		octave:3,
		type:\vsti, controller:~h.controller,
	].p;
); //}}}
	~three.guitarh5Strum = Part(start:6,syl:5,music:[ //		{{{
	//var b2s=[
		type:\strum,
		controller:~h.controller,
		switch:Pseq([\down, \up, \down,],3),
		//dur:Pseq([1,1,2]/2,3),
		dur:Pseq(~three.durs[6].list[6..7]++~three.durs[6].list[8..9].sum,3),
		'Play Mode: Play Mode':0.6
	].p;
); //}}}
	q=0.9; ~gr=0.2; 
	~three.guit6 = Part(start:6,music:[ //		{{{
		degree:Pseq([1,2,3,5,5.1,6]-1),
		//dur:Pseq([1,1,1, (1-~gr),~gr,4 ]/2*0.98),
		dur:Pseq(~three.durs[6].list[0..2]++[~three.durs[6].list[3]-~gr,~gr,3.5]),
		legato:Pseq([q,q,q,1.4,1.4,1]),
		root:5,
		octave:3,
		type:\vsti,
		controller:~g.controller,
		'Play Mode: Play Mode':0
	].p;
);//}}}

~three.bass6 = Part(start:6,music:[ //		{{{
	degree:Pseq([Rest(),1,4,1,2]-1),
	root:10,
	octave:2,
	amp:0.4,
	dur:Pseq( ~three.parse(6, 1!4!4))
].p);//}}}
	~three.saw6 = Part(start:6,music:[ //		{{{
		degree:Pseq([Rest(),1,4,1]-1),
		//dur:Pseq([5,4,4,2 ,3])/2,
		dur:Pseq( ~three.parse( 6, [1!5,1!4,1!4,1!2])++[3]) ,
		//type:\vsti,
		//controller:p.controller
		instrument:\sawSynth,
		rel:3,att:0.2,
		//amp:0.35,
		amp:0.1,
		root:5,octave:[4,5]
	].p;
);//}}}
	~three.pf6 = Part(start:6,syl:7,music:[ //		{{{
		degree:Pseq([2,4,6,6.1,1,4,5,6])-1,
		root:5,
		instrument:\default,
		octave:[6,5],
		//dur:0.5,
		dur:Pseq(~three.durs[6].list[8..]),
		legato:3,
		amp:0.10
	].p;
);//}}}

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
	).add; //}}}
	SynthDef(\tritri,{//{{{
		|freq=400 gate=1|
		var sig=DPW3Tri.ar(freq,\amp.kr(0.1));
		var env= Env.asr(\att.kr(0.1),\sus.kr(1),\rel.kr(2)).kr(2,gate:gate);
		Out.ar(\out.ir(0),sig*env);

	}).add; //}}}
	~three.forboding8 = Part(start:8,music://{{{
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
			dur:Pseq(~three.parse(8,[1!3,1!5,1!2])),
		].p,
		Pmono(
			*[
				\avsd,
				degree:Pseq([ [1,3],[0,2],[6-7,1.1]]-1),//thicken chord?
				//degree:Pseq([ [1,3],[0,2],[5-7,1]]-1),
				att:2,
				scale:Scale.mixolydian,
				dur:Pseq(~three.parse(8,[1!3,1!5,1!2])),
				root:2,
			]
		),
		~three.pbind[8],
		[
			degree:Pseq([[1,1-7],6-7,7-7,[6-7,1.1],5-7-7]-1),
			//degree:Pseq([1,6-7,7-7,[5-7,1]]-1),
			root:2,
			octave:4,
			dur:Pseq(~three.parse(8,[[1,1],1,1!5,1!2]))++Pseq([8]),
			scale:Scale.mixolydian
		].p,

		[ //final chord
			instrument:\avsd,att:8,amp:0.018,degree:Pseq([\r,[5,7,9,11.1]-1]),dur:Pseq([8,12]),octave:4,root:2,
		].p
	])
);//}}}
);

