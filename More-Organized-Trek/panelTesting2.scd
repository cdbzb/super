(
//(Kirk staggers back slightly, then there is a high-pitched sound as his head is flung back.) 

Song.new(\panel2,[],\dursAreInFile);
Song.panel2.current;
Song.resources.infrastructure=FunctionList.new.array_([]);
 Song.resources.infrastructure.addFunc({ //~syn1
	"/Users/michael/tank/super/song-Synthdefs.scd".load;
});
Song.resources.infrastructure.addFunc({TempoClock.tempo_(1)});
/*SPOCK:*/[" Just a moment, Doctor. ","r",[ 1 ]].addLine; 
/*KIRK:*/[" I am Sargon. ","r",[ 1 ]].addLine; 
/*MCCOY:*/[" Where's our captain? Where's Jim Kirk? ","r",[ 1 ]].addLine; 
[/*KIRK:*/" He is unharmed. I have taken his body to demonstrate ", [7,11,12,13, 12,13,14,11,7,7,6, 5,15,14,12.5].dm('a',scale:\mixolydian),[ 0.398, 0.372, 0.436, 1.5, 0.39, 0.376, 0.406, 0.376, 0.38, 0.528, 0.624, 0.385, 0.368, 0.324, 0.416 ]
].addLine; 
P(\tune3,start:3,music:
	Song.currentSong.pbind[3]
);
~quarters3= Song.parseBeats(3,[2/3,2/3,2/3, 8/3,2/3,2/3, 2/3,2/3,2/3, ]);
P(\bassLine3,start:3,syl:2,music:[
		freq:[11,11,7,7,6,6,5].df('a',octave: 2,scale:\mixolydian).q,
		dur:~quarters3.q,
	].p
);
P(\bassLine3b,start:3,syl:8,music:[
		freq:[3,7,11,7,11].df('c',octave: 3).q,
		dur:Song.parse(3,[ [1,0.5],[0.5,1],1,1,1 ],9).q,
	].p
);

//MUTEDP(\voices3,start:3,syl:2,music:
	//MUTED{
		//MUTEDvar a = VoiceLeading(
			//MUTED[
				//MUTED[13,14,\_ ],
				//MUTED[11,\_,\r ],
				//MUTED[7 , 6, 7 ],
				//MUTED[5 , 4,\_ ]
			//MUTED] 
			//MUTED,
			//MUTEDSong.parse(3,[ 3,3,3 ],3)
		//MUTED)
		//MUTED.df('a',scale:\mixolydian,octave:4);
		//MUTEDPpar(a.pbind) => Pbindf(
			//MUTED_,
			//MUTED\freq,Pkey(\val),
			//MUTED\instrument,\stringyy,
			//MUTED\legato,1
			//MUTEDPmono
		//MUTED) =>_.play;
	//MUTED}
//MUTED);
P(\chord3,start:3,syl:2,music:
	[ 
//		instrument:\stringyy ,
		freq:[ 
			[5,7,11,13],
			[4,6,11,14],
			[4,7,12,14],
			[5,7,12.5,15]
		].df('a',octave: 4,scale:\mixolydian).q,
		out:(0..3),
		dur: Song.parse(3,[3,3,3,3],3).q,
	].pm(\stringyy)
);
[/*MCCOY:*/" (drawing his phaser) I won't go along with this. Back to where you were, Sargon, or whatever you are. ",
	[4,3,2,1].dm('b-',scale:\whole)
	++[13,11,5].dm('d-')
//	[12,11,6,7,13,11,5].dm('a',scale:\mixolydian,octave:4)
	++[1,2,3,4,5].dm('g',scale:\whole)
	++ [15,14,13,12,14,12,11,7].dm('d',octave: 4) , [ 
		0.203, 0.245, 0.232, 0.248, 
		0.363, 0.341, 0.438, 
		0.218, 0.225, 0.211, 0.308, 0.53, 
		0.401, 0.24, 0.269, 0.271, 0.342, 0.354, 0.396, 0.558 ]
].addLine; 
P(\tune4,start:4,music:
	Song.currentSong.pbind[4]
);
/*SPOCK:*/[" And if he refuses, Doctor, (dum) what do you propose to do with your phaser?", [13,12,11,13,15,13,11,6, 6.5].dm('c',scale:\whole )++ [5,7,11, 5,6,7,11,7,11, 4,3,2].dm('e'),[ 0.216, 0.259, 0.221, 0.253, 0.436, 0.506, 0.514, 0.603, 1.097, 0.488, 0.326, 0.43, 0.266, 0.26, 0.304, 0.361, 0.398, 0.392, 0.592, 0.628, 0.62 ]].addLine; //5
P(\bassnote5,start:5,music:
	(note:0)
);
P(\strum5,syl:3,start:5,music:
	(midinote: 
		[1,3,5,11,13,15,21].dm('c',scale:\whole,octave:4),
		strum:0.04,)
);
P(\tune5,start:5,music:
	Song.currentSong.pbind[5].fin(8)
);
P(\tune5b,start:5,syl:8,music:
	Song.currentSong.pbind[5].drop(9)
);
~eighths5= Song.parseBeats(5,
	(
		[1/2,1/2,1/2,1/2,1,1,1,1, 1,1/2,1/4,2/4,1/4,1/4,1/4, 1/3,1/3,1/3, 1/2,1/2]
		//*[1,1,1,1,1,1,1,1,1,1,1,1, 0.5,0.5,0.5,0.5,0.5,0.5,0.5,0.5]
	)
);
P(\bassLine5,start:5,music:[
	freq: (\r!12++[11,11,7,7,6,6,5,5]).flatten.df('b',octave:2,scale:\minor ).q,
//	dur:Song.parse(5,[1/2,1/2,[1,1,1/3],[2/3,1] ],8).q,
	dur:~eighths5.q.stutter(2)/2,
	].p
);

P(\bassNote5,start:5,music:
	[ 
		freq: [\r,1,5].df('e',octave:3).q,
		dur:Song.parse(5,[18,2,1],).q,
		instrument:\sawSynth,att:1 
	].p
);
	["That is still Jim's body. ", [2,3,4,6,4,1].dm('a',scale:\dorian,octave:5),[ 0.326, 0.302, 0.531, 0.614, 0.662, 0.638 ]].addLine; 
	P(\bassNote6,start:6,syl:1,music:
		(freq:[1].df('f#',octave:2),instrument:\sawSynth,att:2)
	);
	P(\tune6,start:6,music:
		Song.currentSong.pbind[6]
	);

[/* Insert */"(lungs intro - 4 eights)","r",
	[0.482, 0.456, 0.47, 0.51, 0.867, 0.459, 0.515, 1.287, 0.518, 0.499, 0.489, 0.447, 0.496][0..3] 
].addLine;

//Song.durs[Song.section('lungs intro')].list.asArray.quantize(0.2)

P(\tempo7,start:'lungs intro',music:{
	TempoClock.tempo_(0.89)}
);
P(\dumx4,start:'lungs intro',music:{
	|p d| [
		durs:d,

].p
});

//(Kirk convulses briefly, and the sphere has dimmed a lot.) 
/*KIRK:*/["(dum dum dum dum) Lungs filled with air again.(dum dum dum)",[1,1,1,1,3,3,3,3,2,2,2,2,2].dm('a-'),[ 0.482, 0.456, 0.47, 0.51, 0.867, 0.459, 0.515, 1.287, 0.518, 0.499, 0.489, 0.447, 0.496 ]].addLine;
//Song.durs[7]=[ 0.499, 0.461, 0.461, 0.529, 0.919, 0.506, 0.503, 1.374, 0.536, 4.69, 0.46, 1.18, 0.488, 3.426,0.411,1.08 ].q;
//~quarters7=Song.parse(7,[2,2,1,2,2/3,[1/3,1],2,2,2,
//Song.durs[7]= Song.durs[7].list[0..3]!3=>_.flatten++Song.durs[7].list[4..]=>_.q;
~eighths7 = Song.parse(7,[1,1,1,1, 
//	1,1,1,1,
//	1,1,1,1,
	1/2,1/2,1,1,1/3,1/3,1/3,1,1,1,1,1]).q;



	SynthDef(\pulser,{
			var env= Env.perc(0.01,\decay.kr(0.5)).kr(0,gate:\pulse.tr(0));
			var freq = \freq.kr(150,\flag.kr(0));
			var sig= Saw.ar(freq,0.1)
			=> BMoog.ar(_,env*2000+10,0.3)
			+ (WhiteNoise.ar(0.5) * env => BMoog.ar(_,LFNoise2.kr([1.01,1]).range(100,1000),0.9,2)=>FreeVerb.ar(_,0.3,0.5))
			//=> EchoNone.ar(_,0.5,0.456,3)
			//=> FreeVerb.ar(_,0.8,1)
			* Env.cutoff(5).kr(2,gate:\gate.kr(1))
			*\amp.kr(1) //*0
			+ (0.3*VOSIM.ar(Impulse.ar(freq*[0.5,1]),120,2,0.8)*env)
			* Env.cutoff(\time.kr(5)).kr(2,gate:\fadeout.kr(1))
			=> LeakDC.ar(_)
			=> Out.ar(\out.kr(0),_) ;
		}).add;
		//MUTEDP(\tempo7,start:7,music:{{TempoClock.tempo_(0.9)}.value}
		//MUTED);
P(\lungsB,music:

	Pproto({
		~a=(type:\on,instrument:\pulser,out:[0,1]).yield;
		~aid=~a[\id];
		~durr=~quarters;
	}, [
		type:\set,
		args:#[\decay,\pulse,\freq,\flag,\out,\amp],
		flag:[0.1,0.2],
		out:[0,1],
		freq: [1,4].stutter(8)
			=>_.df('a-',scale:\mixolydian,octave:2)=>_.q,
		decay:0.70,
		pulse:1,
//		dur:Pkey(\durr),
		dur:~eighths7.quantize(0.2),
		id:Pkey(\aid)
	].p
	//+= Song.pbind[7]
	//=>Pn(_,2)
	,{})
);
P(\tremoloSwell,music:
	{

		(type:\vst_midi,vst:~syn1.controller,midicmd:\allNotesOff).play;
		~syn1.patch(\violas,\trem,0);
		~syn1.setOut( ~verbchannels=Effect(FreeVerb.ar(_,1,1),out:0,inputChannels:4).bus.index) ;
		~syn1.expression(100,0);
		~stringChords=[12,10,2,14,20,20,10];
		~stringChords=[12,0,2,4,0,0,0]-1;
		//Pdefn(\swellChord,nil);
		Pdefn(\swellChord,
			Pstep ([
				[5,11,13,15].dm('f',scale:\minor),
				[4,11,13,14].dm('f',scale:\minor),
				[6,11,13,16].dm('f',scale:\minor),
				[5,11,13,14,15].dm('f',scale:\minor),
				[5,11,13,15].dm('f',scale:\minor),

				[1,3,5,7,11,13,15].dm('c',octave:6)
			],
				~eighths7.list[0..8].sum!2
				++
				~eighths8.list[0..8].sum!3
				=>_.flatten
			,
			3
		)
		);
		[
			type:\vst_midi,vst:~syn1.controller,
			//verb:{ ~syn1.setOut( ~verbchannels=Effect(FreeVerb.ar(_,1,1),out:0,inputChannels:4).bus.index) } ;
			//chords: [[5,7,11,15],[4,11,13,14]].stutter(8).q(16) ,
			//chords: Pstep([[5,7,11,15],[4,11,13,14]],4)=>Pn(_,3),
			chords: Pdefn(\swellChord),
			midinote: 
			Pfunc({|e|Prand(e.chords).asStream})
			+Prand([12,0,2,4,0,0,0],inf),
			//		\midinote: Prand([1,3,5,11].dm('f',scale:\minor,octave: 4),inf)+Prand([12,0,2,4,0,0,0],inf),
			dur:0.1,
			legato:Pwhite(3,9,inf),
			panning:Pfunc({~syn1.setOut(4.rand+~verbchannels)})

		].p=>Pfin(290,_)
		=>_.play;
	}
);
P(\tune7,start:7,syl:3,music:
	Song.currentSong.pbind[7]=>Pmul(\freq,[1/2,1],_)
	=>Pset(\dur,Song.durs[7]+[0,0,0,0,0,0,0,0,0,2].q,_)
	=>_.drop(4)=>_.fin(6)
); 
P(\innerChord7,start:7,syl:3,music:
	Song.currentSong.pbind[7]
	=>Pset(\freq, [1,3].df('f',octave:4,scale:\minor), _)
	=>Pset(\dur,Song.durs[7]+[0,0,0,0,0,0,0,0,0,2].q,_)
	=>_.drop(4)=>_.fin(6)
);
P(\lungs,music:{
	var roots = [1,4,2,5].dm('c#',octave: 2);
	var bars = [2,2,2,1];
	var notes = roots.collect({|i x| [i].q(bars[x]*4)}).q;

	[
		dur: 0.42,
		midinote:notes,
		//transpose:12
	].pp
}
);
~eighths8= Song.parse(8,1!8++[1/3,1/3,1/3,1,1,1,1,1,1,1,1,1,1,1,1/2,1/2],) .q;
["(dum *7) To see again. Heart,",[2,2,2,2, 2,2,2,4, 4,3, 3,2,2,2, 2,2,2,2,  2,2,5].dm('a-'),[ 0.49, 0.484, 0.484, 0.484, 0.491, 0.482, 0.454, 0.509, 1.389, 0.492, 0.442, 0.469, 0.474, 0.479, 0.45, 0.468, 0.462, 0.468, 0.47, 0.485, 0.914 ]].addLine; //8
P(\tune8,start:8,music:
	Song.currentSong.pbind[8].collect({|e|(e.midinote==([2].dm('a-')[0])).if{e.midinote=\};e})
	=> Pset(\legato,[1!10,5,1!12].flatten=>_.q,_)=>_.trace
);
P(\lungsB8,music:
	 [
		flag:[0.1,0.2],
		out:[0,1],
		freq:  [2].stutter(8)++[5!5,7,7,11].flatten
			=>_.df('a-',scale:\mixolydian,octave:2)=>_.q
			++ 
			(
				[1!8,3!4,6!8].df('a-',octave:2).flatten
			=>_.q) ,
		decay:0.70,
		pulse:1,
		dur:~eighths8,
	].pm(\pulser)
);
//, 2/3,[1/3,1],1/5,1/5,1/5,1/5,1/5,1,1]).q;
//TempoClock.tempo=1
( Song.resources.infrastructure.addFunc({ //~syn1
	try{~syn1.controller.loaded.not.if{~syn1=~synful3.()}}{~syn1=~synful3.()};
});
);
["pumping, arteries surging with blood again. A", [13,5].dm('c') //9
		++ [3,2,1].dm('f',scale:\minor ) ++[3,4,5].dm('g')
		++ [13,12,5, 7].dm('e')
,[ 0.879, 4.798, 0.646, 0.62, 2.428, 0.686, 0.629, 0.657, 3.151, 0.498, 1.36, 0.499 ]
].addLine;  
~quarters9=Song.parseBeats(9,[1,5,2/3,2/3,2/3+2,2/3,2/3,2/3,3.5,0.5,1.5,0.5]);
~eighths9=~quarters9.stutter(2)/2=>_.quantizeWindow;
P(\pumping,start:9,lag:-0.152,music:
	(width:8,release:13,instrument:'defaultPorto',attack:7,freq:[1,3,5,7,11,13,15].df('c'),dur:3)
); 
P(\tune9,start:9,music:Song.currentSong.pbind[9]
);
// Song.currentSong.play(\blood,\tune9,\pumping)
P(\blood,start:9,syl:7,lag:-0.15,music:
	{
//		var distortion=Effect({|i|i.tanh});
		[1,3,5,7,11,13,15].df('e').do({|i|
			Synth('defaultPorto.clean',[
				\attack,5,
				\freq,i,
//				\out,distortion.bus.index
			]).dur(3,7)
		})
	}
); 
P(\fallingSwell,start:9,syl:2,music:
		{ Pdefn(\swellChord, [5,7,11,15].dm('c')-Pseg([0,25],10)) }
);
//~syn1.allNotesOff
"/Users/michael/tank/super/808-mod.scd".load;
P(\lungsB9pmono,music:
	[
		flag:[0.1,0.2],
		out:[0,1],
		freq:  {
			var c=List.new;
			[11,8,14,16,13,4,12,4,6,4,5,4].pairsDo({|a b|  c.add(a!b) });
			c.flatten.asArray.df(octave:1).q
		}.value ,
		decay:0.70,
		pulse:1,
		dur: ~eighths9.q,
		].pm(\pulser)
);
P(\piano9,start:9,syl:7,music:
	{
		 [
			 freq: [
				 [5,11,13],[5,11,13],
				 [4,7,12],[4,7,12],
				 [4,6,11],[3,6,11],
				 		[2.5,5,11,12],[2.5,5,7.5,12],
//				 [5,11,12],[5,7.5,12],
				 [4,5.5,7.5,12,13]
			 ].df('e',scale:\mixolydian).q,
			 dur:
			 //		~eighths9[21..].q,
			 ~quarters9[12..].q
			 ++ Song.parse(10,[[1,1],[1,1],2],).q
			 ,
			 effect: Effect( {|i| 
				 HPF.ar(i.tanh,1300)
			 } ).bus.index,
			 out: Pkey(\effect),
			 amp:0.3,
		].p
//		<> ~parent.value
		=>_.trace => _.play
	}
);
	["half a million years -- ", [4,1,3,4,5,4.5].dm('b') ,[ 0.561, 0.553, 0.571, 0.795, 2.88, 0.758 ]].addLine; 
	~quarters10=Song.parseBeats(10,[0.5,0.5,0.5,0.5,3/2]);
	~eighths10=~quarters10.stutter(2).quantizeWindow(0.2,2)/2;
P(\lungsB10,start:10,music:
	{
		  [
			flag:[0.1,0.2],
			//effect:Effect({|i| i*Line.kr(1,0,3)},inputChannels:2).bus.index,
		//	out:Pkey(\effect)+[0,1],
		out:[0,1],
			freq:  {
				var c=List.new;
				[5,8].pairsDo({|a b|  c.add(a!b) });
				c.flatten.asArray.df(octave:1).q
			}.value ,
			decay:0.70,
			out:[0,1],
			pulse:1,
			fadeout:[1,0,0,0,0,0].q,
//			amp:Pseries(0.3,-0.08),
			amp:0.20,
			time:2,
			//fade:9,
			dur: ~eighths10.q,
		].pm(\pulser)
		=>_.fin(6)
		=>_.play;
	}

);
	P(\tune10,start:10,music:
		Song.currentSong.pbind[10]
	);
//MUTEDP(\piano10 ,start:10,music:
	//MUTED{
		//MUTED[
			//MUTEDfreq: [
				//MUTED[2.5,5,11,12],[5,7.5,12],
				//MUTED[4,5.5,7.5,12,13]
			//MUTED].df('e',scale:\mixolydian).q,
			//MUTEDdur:Song.parse(10,[[1,1],[1,1],2],).q,
			//MUTEDstrum:[0, 0, 0.05].q,
			//MUTEDlegato:1.1,
			//MUTEDeffect: Effect( {|i| 
				//MUTEDHPF.ar(i.tanh,1300)
			//MUTED},inputChannels:1 ).bus.index,
			//MUTEDout: Pkey(\effect),
			//MUTEDamp:Pseries(0.30,-0.05),
//MUTED
		//MUTED].pp
	//MUTED}
 //MUTED
//MUTED);
P(\chord10,start:10,music:
	 [attack:15,dur:4,instrument:\stringyy,lag:2,freq:[4,5.5,7.5,12,13].df('e',scale:\mixolydian,octave:5)].p.fin(1)
);
P(\base10,start:10,
//	syl:3,
	music:(
		instrument:\sawSynthSustain,
		dur:5,
		att:7,
		amp:0.07,
		freq: [11].df('g',octave:2)
	)
);
["(boom boom boom boom )To be again.", [11,11,7,7,15,15,13,13].dm('c#',octave:4) ,[ 0.619, 0.616, 0.618, 0.356, 0.422, 2.622, 0.474, 3.428 ]].addLine;
~bassnotes11=[11,7,6,5,4,3,2];
~eighths11=Song.parseBeats(11,[1,1,1,0.5,0.5, 3.5,0.5, ]).q;
P(\tune11,start:11,music:
	Song.currentSong.pbind[11]
);
P(\bass11,start:11,music:[
	freq: ~bassnotes11.df('d-',octave:2).stutter(2).q,
	dur:~eighths11
	].p
);
//	["Your captain has an excellent body, Doctor McCoy. I ","r"].addLine; 
//	["compliment you both on the condition in which you maintained it. ","r",].addLine; 
///*SPOCK:*/[" What are your plans for it? Can you exchange places again when you wish? ","r",].addLine; 
///*KIRK:*/[" Have no fear. Your captain is quite unharmed, although his mind generates insufficient energy for him to speak from there as I do.","r",].addLine; 
/*SPOCK:*/[" Doctor? ","r",].addLine; 
/*MULHALL:*/[" Yes, I have the same readings. ","r",].addLine; 
\aware.post;Song.sections.postln;
/*MCCOY:*/[" Are you aware of what's happening to his body? ",[7,11,5,13,12,11,7,11,5, 7,11,14,13].dm('f',scale:\mixolydian),[ 0.295, 0.347, 0.315, 0.566, 0.3, 0.322, 0.291, 0.313, 0.6065, 0.278, 0.361, 0.62, 0.633 ]].addLine; 
	Song.durs.put(14,[ 0.295, 0.347, 0.315, 0.566, 0.3, 0.322, 0.291, 0.313, 1.213/2, 0.278, 0.361, 0.62, 0.633, /*3.236*/ ].q);
P(\tune14,start:14,music:Song.currentSong.pbind[14]
);
P(\accent14,start:14,syl:2,music:
	{
		(
			instrument:\cymbal_808,
			amp:0.25,
			tone:0.01,
			out:Effect({|i|TwoTube.ar(i,0.5,0.2,1300,1455)=>Decimator.ar(_,[9000,10000],8)*
			Env.linen(0,1,4).kr(2,gate:1)
			=> DetectSilenceDry.ar(_,doneAction:2)}).bus.index
		).play
	}
);
P(\bass14,start:14,music:Song.currentSong.pbind[14]
	=>Pbindf(_,
		\amp,0.03,
		\lag,Pwhite(-0.005,0.005)
	)
	=>Pmul(\freq,1/4,_);
);
P(\kick14,start:14,music:1111.postln;{
	[
		instrument:\bd_808,
		dur:
		Song.parse(14,[3,1,2,2,1/2,1/2,2,1,1],).q
		,
		note:[\].q++[1].q(inf),
	].pp
}
);

	["Heart action (almost) doubled, ",[13,12,11,7,11,7,11,16,15].dm('e',scale:\mixolydian),[ 0.406, 0.487, 0.472, 0.445, 0.398, 0.478, 0.487, 0.456, 0.509, 1.478 ]].addLine; 
//Song.durs.put(14,[ 0.545, 0.304, 0.31, 0.302, 0.327, 0.311, 0.332, 0.555, 0.429, 2.165 ].q);
P(\tune15,start:15,music:Song.currentSong.pbind[15]
);
P(\bass15,start:15,music:Song.currentSong.pbind[15]
	=>Pbindf(_,
		\amp,0.03,
		\lag,Pwhite(-0.005,0.005)
	)
	=>Pmul(\freq,1/4,_);
);
P(\kick15,start:15,music:{
	[
		instrument:\bd_808,
		dur:
		Song.parse(15,[1,2,2,2,2/3,[1/3,1]]).q
		,
//		note:[\].q++[1].q(inf),
		out:3,
	].pp
}
);
	["temperature a hundred and four degrees? ",[13,12,11,7,11,12,7,13,13,16].dm('f#',scale:\mixolydian),[ 0.406, 0.487, 0.472, 0.445, 0.398, 0.478, 0.487, 0.456, 0.509, 1.478 ]].addLine;

P(\tune16,start:16,music:Song.currentSong.pbind[16]

);
/*MULHALL:*/[" He'll die if you don't leave his body. Soon! ", [15,21,15,13,12,11, 7.5,12,11, 11.5].dm('c#',scale:\minor) ,[ 1 ]].addLine; 
/*SPOCK:*/[" What is it you want of us? ","r",].addLine; 
/*KIRK:*/[" In the next room, there are other receptacles. ","r"].addLine;
	["The other two of us that survived. ","r"].addLine; 
	["You, Doctor Ann Mulhall, ","r"].addLine; 
	["and you, Mister Spock, ","r"].addLine;
	["we require your bodies also. ","r"].addLine; 
	["We must have Captain Kirk and you so that we may live again.","r",].addLine; 
)
