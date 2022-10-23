(
s.waitForBoot{
	Song.new(\panel2,[]).current;
	Stills("/Users/michael/tank/Trek/video for stills etc/media/return to tomorrow.mov").current;
	Song.resources.infrastructure=FunctionList.new.array_([]);
	~syn1=Synful();
	Song.resources.infrastructure.addFunc({TempoClock.tempo_(1).postln});
	Song.resources.condition=Condition.new;
	Song.resources.infrastructure.addFunc({Song.resources.condition.test_(true)});
	[ "(Kirk staggers back slightly, then there is a high-pitched sound as his head is flung back.)" ,"r",[6]].addLine; 
	P.still('high pitched noise',start:'staggers',timecode:[1235.seconds,1236.seconds],music:
	{ |p b e|
		{Impulse.ar(Gendy1.kr(minfreq:2,maxfreq:10!4).range(1,[800,1700,3440,8000]))*0.2*EnvGen.kr(Env.linen(0,3,15,0.2,-6),doneAction:2)}.play;
		e.still[1].value(wait:4,fade:2);
		e.still[0].value(wait:1,fade:1);
	}
);
/*SPOCK:*/[" Just a moment, Doctor. ", [12,11,13,11,5.5,5].dm('a-')].addLine; 

//P(\JustTune,start:\Just,music:Song.currentSong.pbind[\Just]
//);
~justTheTune.(\Just,{|i|i=>Pset(\legato,2,_)});
P.still(\spock,\moment,timecode:1238.seconds,music:{|p b e|
	e.still.value
})
/*KIRK:*/[" (boom) I am Sargon. ",[6,6,5,11,1].dm('c#',scale:\minor)].addLine; 
~justTheTune.('I am Sargon',{|i|i=>_.drop(1)},syl:0);
P.still(\stillsGag,start:'I am Sargon',timecode:[633,633.04],music: { |p b e|

	fork{
		7.do{
			e.still[0].value;
			0.5.rand.wait;
			e.still[1].value;
			0.5.rand.wait;
		}
	}

}
);
P(\sargonBoom,start:'I am Sargon',music:{|p b|
	(
		instrument:\stringyy,
		freq:(30,40..190),
		out:(0..16)%4,
		amp:0.09,
		dur:3,
	).play;
	[ instrument:\sawSynth, freq: [6,1].df('c#',octave: [3,2]).q,dur:[b[0..2].sum,b[3..4].sum].q ].p.play;
	fork{
		b[0..2].sum.wait; 
		{
			var root=[1].df('c#',octave:2); 
			Gendy1.ar(minfreq:root-29,maxfreq:root+20)
			*0.4
			*Env.perc(0,4).kr(2,gate:1)
		}.play
	}
}
);
/*MCCOY:*/[" (boom boom) Where's our captain? Where's Jim Kirk? ",[11,11,15,15,14,13, 11,7,13].dm('c'),].addLine; 
~justTheTune.('our captain');
P(\chordCaptain,start:'our captain',music:{ |p b|
	[ 
		freq:[[1,3,5],[1,3,5]].df('c',octave:4 ).q
		++[ [3,13,15] ].df('f',octave:3 ).q
		,
		dur:[ b[0],b[1..3].sum,b[4..5].sum ].q,
	].p.play
}
);
P(\baseNotesCaptain,syl:5,start:'our captain',music:{ |p b|
	[
		freq:[4,2].df('c',octave:3 ).q,
		dur:[b[0..1].sum,b[2]].q,
		//		instrument:\sawSynth,
		lagTime:0.5
	].pm(\sawSynthSustain).play
}
);
P(\chordCaptainMore,syl:5,start:'our captain',music:{ |p b|
	b.postln;
	a=VoiceLeading([[5,4.5,5],[3,\_,3],[1,\_,1],[\r,\r,7.5]] , b[0..2]);
	a=a.dm('f',scale:\minor);
	//	a.pbind.do{|i|i => Pset(\midinote,Pkey(\val)) => _.play };
	a.lines.do{|h i| [amp:0.06,out:i,lag:Pwhite(0,0.2,inf),legato:1,midinote:a.voice(i).line.q,dur:a.voice(i).durs.q].pm(\sparkTriangle).play};
	//	[midinote:a.voice(0).line.q,dur:a.voice(0).durs.q].pp;
	//	[midinote:a.voice(1).line.q,dur:a.voice(1).durs.q].pp;
	//	[midinote:a.voice(2).line.q,dur:a.voice(2).durs.q].pp;
}
);
[/*KIRK:*/" He is unharmed. I have taken his body to demonstrate ", [7,11,12,13, 12,13,14,11,7,7,6, 5,15,14,12.5].dm('a',scale:\mixolydian),[ 0.398, 0.372, 0.436, 1.5, 0.39, 0.376, 0.406, 0.376, 0.38, 0.528, 0.624, 0.385, 0.368, 0.324, 0.416 ]
].addLine; 
P(\tune3,start:\unharmed,music:
	Song.currentSong.pbind[\unharmed]
);
~quarters3= Song.parseBeats(\unharmed,[2/3,2/3,2/3, 8/3,2/3,2/3, 2/3,2/3,2/3, ]);
P(\bassLine3,start:\unharmed,syl:2,music:[
	freq:[11,11,7,7,6,6,5].df('a',octave: 2,scale:\mixolydian).q,
	dur:~quarters3.q,
].p
);
P(\bassLine3b,start:\unharmed,syl:8,music:[
	freq:[3,7,11,7,11].df('c',octave: 3).q,
	dur:Song.parse(\unharmed,[ [1,0.5],[0.5,1],1,1,1 ],9).q,
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
P(\chord3,start:\unharmed,syl:2,music:
	[ 
		//		instrument:\stringyy ,
		freq:[ 
			[5,7,11,13],
			[4,6,11,14],
			[4,7,12,14],
			[5,7,12.5,15]
		].df('a',octave: 4,scale:\mixolydian).q,
		out:(0..3),
		dur: Song.parse(\unharmed,[3,3,3,3],3).q,
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
P(\tune4,start:'drawing his phaser',music:
	Song.currentSong.pbind['drawing his phaser']
);
/*SPOCK:*/[" And if he refuses, Doctor, (dum) what do you propose to do with your phaser?", [13,12,11,13,15,13,11,6, 6.5].dm('c',scale:\whole )++ [5,7,11, 5,6,7,11,7,11, 4,3,2].dm('e'),[ 0.216, 0.259, 0.221, 0.253, 0.436, 0.506, 0.514, 0.603, 1.097, 0.488, 0.326, 0.43, 0.266, 0.26, 0.304, 0.361, 0.398, 0.392, 0.592, 0.628, 0.62 ]].addLine; //5
P(\bassnote5,start:'if he refuses',music:
	(note:0)
);
P(\strum5,syl:3,start:'if he refuses',music:
	(midinote: 
		[1,3,5,11,13,15,21].dm('c',scale:\whole,octave:4),
		strum:0.04,)
	);
	P(\tune5,start:'if he refuses',music:
		Song.currentSong.pbind['if he refuses'].fin(8)
	);
	P(\tune5b,start:'if he refuses',syl:8,music:
		Song.currentSong.pbind['if he refuses'].drop(9)
	);
	~eighths5= Song.parseBeats('if he refuses',
		(
			[1/2,1/2,1/2,1/2,1,1,1,1, 1,1/2,1/4,2/4,1/4,1/4,1/4, 1/3,1/3,1/3, 1/2,1/2]
			//*[1,1,1,1,1,1,1,1,1,1,1,1, 0.5,0.5,0.5,0.5,0.5,0.5,0.5,0.5]
		)
	);
	P(\bassLine5,start:'if he refuses',music:[
		freq: (\r!12++[11,11,7,7,6,6,5,5]).flatten.df('b',octave:2,scale:\minor ).q,
		//	dur:Song.parse(5,[1/2,1/2,[1,1,1/3],[2/3,1] ],8).q,
		dur:~eighths5.q.stutter(2)/2,
	].p
);

P(\bassNote5,start:'if he refuses',music:
	[ 
		freq: [\r,1,5].df('e',octave:3).q,
		dur:Song.parse('if he refuses',[18,2,1],).q,
		instrument:\sawSynth,att:1 
	].p
);
["That is still Jim's body. ", [2,3,4,6,4,1].dm('a',scale:\dorian,octave:5),[ 0.326, 0.302, 0.531, 0.614, 0.662, 0.638 ]].addLine; 
P(\bassNote6,start:'still Jim',syl:1,music:
	(freq:[1].df('f#',octave:2),instrument:\sawSynth,att:2)
);
P(\tune6,start:'still Jim',music:
	Song.currentSong.pbind['still Jim']
);

[/* Insert */"(lungs intro - 4 eights)","r",
[0.482, 0.456, 0.47, 0.51, 0.867, 0.459, 0.515, 1.287, 0.518, 0.499, 0.489, 0.447, 0.496][0..5]*[2,2,1,1,1,1]
].addLine;

//Song.durs[Song.section('lungs intro')].list.asArray.quantize(0.2)

//MUTEDP(\tempo7,start:'lungs intro',music:{
//MUTEDTempoClock.tempo_(0.89)}
//MUTED);
P.still(\dumx4,start:'lungs intro',timecode:1257.5.seconds, music:{

	|p b e| [
		dur:b,
		instrument:\stringyy,
		freq:1.df('a-',octave:3),
		width:Pwhite(10,100),
		attack:0,
		out:Pxrand((0..2),inf),
		amp:1


	].p.fin(6).play;
	//{~stills.preview(\lungs1)}.defer
	e.still.value
});


//(Kirk convulses briefly, and the sphere has dimmed a lot.) 
/*KIRK:*/["(dum dum dum dum) Lungs filled with air again.(dum dum dum)",[1,1,1,1,3,3,3,3,2,2,2,2,2].dm('a-'),[ 0.482, 0.456, 0.47, 0.51, 0.867, 0.459, 0.515, 1.287, 0.518, 0.499, 0.489, 0.447, 0.496 ]].addLine;
//Song.durs[7]=[ 0.499, 0.461, 0.461, 0.529, 0.919, 0.506, 0.503, 1.374, 0.536, 4.69, 0.46, 1.18, 0.488, 3.426,0.411,1.08 ].q;
//~quarters7=Song.parse(7,[2,2,1,2,2/3,[1/3,1],2,2,2,
//Song.durs[7]= Song.durs[7].list[0..3]!3=>_.flatten++Song.durs[7].list[4..]=>_.q;
~eighths7 = Song.parse(\Lungs,[1,1,1,1, 
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
	//MUTEDP(\tempo7,start:\Lungs,music:{{TempoClock.tempo_(0.9)}.value}
	//MUTED);
	P(\lungsB,start:\Lungs,music:

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
	P(\trapsLungs,start:\Lungs,music:
		[
			instrument:\bd_808,
			//		instrument:\hihat,
			dur: ~eighths7
			//		.list.quantize.q
			,
			//		/2=>_.stutter(2),
			amp:0.3
		].p
	);
	P(\tremoloSwell,start:\Lungs,music:
		{

			(type:\vst_midi,vst:~syn1.controller,midicmd:\allNotesOff).play;
			~syn1.patch(\violas,\trem,0);
			~syn1.syn.set(\out,~verbchannels=Effect(FreeVerb.ar(_,1,1),out:0,inputChannels:4).bus.index) ;
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
			panning:Pfunc({~syn1.syn.set(\out,(4.rand+~verbchannels))})

		].p=>Pfin(290,_)
		=>_.play;
	}
);
P(\tune7,start:\Lungs,syl:3,music:
	Song.currentSong.pbind[ \Lungs ]
	=>Pmul(\freq,[1/2,1],_)
	=>Pset(\dur,Song.durs[\Lungs]+[0,0,0,0,0,0,0,0,0,2].q,_)
	=>_.drop(4)=>_.fin(6)
); 
P(\innerChord7,start:\Lungs,syl:3,music:
	Song.currentSong.pbind[ \Lungs ]
	=>Pset(\freq, [1,3].df('f',octave:4,scale:\minor), _)
	=>Pset(\dur,Song.durs[\Lungs]+[0,0,0,0,0,0,0,0,0,2].q,_)
	=>Pset(\out,Pwhite(0,3),_)
	=>Pbindf(_,\instrument,\sawSynth,\amp,0.03,\legato,3,\rel,5)
	=>_.drop(4)=>_.fin(6)
);
P(\innerChordLungsSyn,start:\Lungs,syl:3,music:
	{
		//		~syn1.setOut(0);
		~syn1.patch(\horn,\none,8);
		~syn1.expression(64,8);

		Song.currentSong.pbind[ \Lungs ]
		//=>Pset(\freq, [1,3].df('f',octave:4,scale:\minor), _)
		//	=>Pset(\dur,Song.durs[\Lungs]+[0,0,0,0,0,0,0,0,0,2].q,_)
		=>Pset(\out,Pwhite(0,3),_)
		=>Pbindf(_,\channel,8,\midinote,[1,3].dm('f',octave:4,scale:\minor ),\type,\vst_midi,\vst,~syn1.controller,\amp,0.1,\legato,3,\rel,5)
		=>_.drop(4)=>_.fin(6)=>_.trace=>_.play
	}
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
["(dum *7) To see again. Heart,",[2,2,2,2, 2,2,2,4, 4,3, 3,2,2,2, 2,2,2,2,  2,2,5].dm('a-'),[ 0.49, 0.484, 0.484, 0.484, 0.491, 0.482, 0.454, 0.509, 1.389, 0.492, 0.442, 0.469, 0.474, 0.479, 0.45, 0.468, 0.462, 0.468, 0.47, 0.485, 0.914 ]].addLine; //8
~eighths8= Song.parse(\Heart,1!8++[1/3,1/3,1/3,1,1,1,1,1,1,1,1,1,1,1,1/2,1/2],) .q;
//~eighths8=~eighths8.list.quantize(1).q;
P(\tune8,start:\Heart,music:
	Song.currentSong.pbind[ \Heart ].collect({|e|(e.midinote==([2].dm('a-')[0])).if{e.midinote=\};e})
	=> Pset(\legato,[1!10,5,1!12].flatten=>_.q,_)=>_.trace
);

P(\innerChordHeart,start:\Heart,syl:6,music:
	Song.currentSong.pbind[ \Heart ]
	=>Pset(\freq, [1,3].df('f',octave:4,scale:\minor), _)
	=>Pbindf(_,\instrument,\sawSynth,\amp,0.03,\legato,3,\rel,5)
	=>Pset(\out,Pwhite(0,3),_)
	//=>Pset(\dur,Song.durs[\Heart]+[0,0,0,0,0,0,0,0,0,0].q,_)
	=>_.drop(7)=>_.fin(4)
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
	["pumping, arteries surging with blood again. A", [13,5].dm('c') //9
	++ [3,2,1].dm('f',scale:\minor ) ++[3,4,5].dm('g')
	++ [13,12,5, 7].dm('e')
	,[ 0.879, 4.798, 0.646, 0.62, 2.428, 0.686, 0.629, 0.657, 3.151, 0.498, 1.36, 0.499 ]
].addLine;  
~quarters9=Song.parseBeats(\pumping,[1,5,2/3,2/3,2/3+2,2/3,2/3,2/3,3.5,0.5,1.5,0.5]);
~eighths9=~quarters9.stutter(2)/2=>_.quantizeWindow;
P(\pumping,start:\pumping,lag:-0.152,music:
	(width:8,release:13,instrument:'defaultPorto',attack:7,freq:[1,3,5,7,11,13,15].df('c'),dur:3)
); 
P(\tune9,start:\pumping,music:Song.currentSong.pbind[\pumping]

);
// Song.currentSong.play(\blood,\tune9,\pumping)
P(\blood,start:\pumping,syl:7,lag:-0.15,music:
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
P(\fallingSwell,start:\pumping,syl:2,music:
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
P(\piano9,syl:7,music:
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
			++ Song.parse(\million,[[1,1],[1,1],2],).q
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
~quarters10=Song.parseBeats(\million,[0.5,0.5,0.5,0.5,3/2]);
~eighths10=~quarters10.stutter(2).quantizeWindow(0.2,2)/2;
P(\lungsB10,start:\million,music:
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
P(\tune10,start:\million,music:
	Song.currentSong.pbind[\million]
);
//MUTEDP(\piano10 ,start:\million,music:
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
P(\chord10,start:\million,music:
	[attack:15,dur:4,instrument:\stringyy,lag:2,freq:[4,5.5,7.5,12,13].df('e',scale:\mixolydian,octave:5)].p.fin(1)
);
P(\base10,start:\million,
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
~eighths11=Song.parseBeats('To be',[1,1,1,0.5,0.5, 3.5,0.5, ]).q;

P(\tune11,start:'To be',music:
	Song.currentSong.pbind['To be']
);
P(\bass11,start:'To be',music:[
	freq: ~bassnotes11.df('d-',octave:2).stutter(2).q,
	dur:~eighths11
].p
);
//	["Your captain has an excellent body, Doctor McCoy. I ","r"].addLine; 
//	["compliment you both on the condition in which you maintained it. ","r",].addLine;
///*SPOCK:*/[" What are your plans for it? Can you exchange places again when you wish? ","r",].addLine; 
///*KIRK:*/[" Have no fear. Your captain is quite unharmed, although his mind generates insufficient energy for him to speak from there as I do.","r",].addLine; 
/*SPOCK:*/[" Doctor? ","d4 a-3",].addLine; 
~justTheTune.('Doctor?');
P(\tremDoctor,start:'Doctor?',music:
	(instrument:\stringyy,
		freq:[1,11,1,11].df('d',octave:3),
		width:[6,20,5,100],
		out:(0..3),
		attack:0
	)
);
/*MULHALL:*/[" Yes, I have the same readings. ","e5 b-4 c5 d b-4 f#5 d"].addLine; 
P(\tremReadings,start:'same reading',music:
	[
		instrument:\stringyy,
		freq: ([0,1] +.t [1,11,1,11] ) => _.df('e',octave:3) => _.q,
		width:[6,20,5,100],
		out:(0..3).scramble,
		attack:0.1,
		dur:Song.parse('same readings',[5,2]).q
	].p
);
~justTheTune.('the same readings');
//Song.durs[ 'Doctor?' ].list
/*MCCOY:*/[" Are you aware of what's happening to his body? ",[7,11,5,13,12,11,7,11,5, 7,11,14,13].dm('f',scale:\mixolydian),[ 0.295, 0.347, 0.315, 0.566, 0.3, 0.322, 0.291, 0.313, 0.6065, 0.278, 0.361, 0.62, 0.633 ]].addLine; 

//MUTEDP(\tremAware,start:'aware',music:
//MUTED(instrument:\stringyy,
//MUTEDfreq:[1,11,1,11].df('d',octave:3),
//MUTEDwidth:[6,20,5,100],
//MUTEDout:(0..3).rotate,
//MUTEDattack:0
//MUTED)
//MUTED);
//	Song.durs[14]=[ 0.295, 0.347, 0.315, 0.566, 0.3, 0.322, 0.291, 0.313, 1.213/2, 0.278, 0.361, 0.62, 0.633, /*3.236*/ ].q;
P(\tune14,start:\aware,music:Song.currentSong.pbind[\happening]
);
P(\accent14,start:\aware,syl:2,music:
	{
		(
			instrument:\cymbal_808,
			amp:0.25,
			tone:0.01,
			out:Effect({|i|
				TwoTube.ar(i,0.5,0.2,1300,1455)=>Decimator.ar(_,[9000,10000],8)*
				Env.linen(0,1,4).kr(2,gate:1)
				//	=> DetectSilenceDry.ar(_,doneAction:2)
			}).bus.index
		).play
	}
);
P(\bass14,start:\aware,music:Song.currentSong.pbind[\aware]
=>Pbindf(_,
	\amp,0.03,
	\lag,Pwhite(-0.005,0.005)
)
=>Pmul(\freq,1/4,_);
);
P(\baseAware,start:\aware,music:
	{|p d|
		var quarters= Song.parse(\aware,[3,1,2,2,1,2,1,1],);
		var quarterEighthEighth= quarters.drop(1) * [1,[0.5,0.5]] => _.flatten;
		var withRest = [quarters[0]]++quarterEighthEighth;
		[
			freq:[\r,\r,7,11,\r, 5,11,\r, 7,11,\r].df('f',octave: 2,scale:\mixolydian).q,
			dur:withRest.q,
		].pp;
		withRest.postln;

	}
);

P(\kick14,music:1111.postln;{
	[
		instrument:\bd_808,
		dur:
		Song.parse(\aware,[3,1,2,2,1/2,1/2,2,1,1],).q
		,
		note:[\].q++[1].q(inf),
	].pp;
	[
		instrument:\hat_808,
		dur:Song.parse(\aware,[1,1,1,1/2,1/2,1,1,1,1,1/2,1/2,1,1,1/2,1/2,1/2,1/2]).q.quantize(0.8),
		amp:[0.05,0.1].q(inf),
		effect:Effect(Phaser2.ar(_)).bus.index,
		out:Pkey(\effect),
		note:[\].q(3)++[1].q(inf),
	].pp
}
);

["Heart action (almost) doubled, ",[13,12,11,7,11,7,11,16,15].dm('e',scale:\mixolydian)].addLine; 
//Song.durs.put(14,[ 0.545, 0.304, 0.31, 0.302, 0.327, 0.311, 0.332, 0.555, 0.429, 2.165 ].q);
P(\tune15,start:\doubled,music:
	Song.currentSong.pbind[\doubled]
);
P(\bass15,start:\doubled,music:Song.currentSong.pbind[\doubled]
=>Pbindf(_,
	\amp,0.03,
	\lag,Pwhite(-0.005,0.005)
)
=>Pmul(\freq,1/4,_);
);
P(\kick15,music:{
	[
		instrument:\bd_808,
		dur:
		Song.parse(\doubled,[1,2,2,2,2/3,[1/3,1]]).q
		,
		//		note:[\].q++[1].q(inf),
		out:3,
	].pp
}
);
["temperature a hundred and four degrees? ",[13,12,11,7,11,12,7,13,13,16].dm('f#',scale:\mixolydian)].addLine;

P(\tune16,start:\temperature,music:Song.currentSong.pbind[\temperature]

);
/*MULHALL:*/[" He'll die if you don't leave his body. Soon! ", [15,21,15,13,12,11, 7.5,12,11, 11.5].dm('a-',scale:\minor) ].addLine; 
P(\dieChord,start:'die if',syl:0,music:
	{|o d| (
		instrument:\stringyy,
		freq:[1,11].df('a-',octave:2),
		attack:0.001,
		amp:0.6,
		dur:d[0..6].sum,
	).play ;

	[ 
		freq:Prand([1,3,5,11,13,15,21].df('a-',scale:\minor),inf)*2,
		dur:Pwhite(0.01,0.04,40),
		effect: Effect(EchoCubic.ar(_,0.4,SinOsc.kr(1/20).range(0.21,0.22),5)).bus.index,
		amp:0.02,
		out:Pkey(\effect),
	].pp
}
);
P(\tuneSoon,start:\Soon,music:
	Song.currentSong.pbind[\Soon]
);
P(\chordSoon,start:\Soon,syl:8,music:
	(
		freq:
		[2,4.5,6.5,11.5].df('a-',octave:3,),
		strum: 0.04,
		instrument:\sawSynthSustain,
		dur:0.6,
		amp:0.05
	)
);
/*SPOCK:*/[" What is it you want of us? ",[11,11.5,7,11.5,11,5,3].dm('e-',scale:\mixolydian)].addLine; 
P('want of us',start:'want of us',music:
	{|o d| [ 
		//		instrument:\stringyy,
		freq:[ [11,21],[7,17],[11,21] ].df('e-',scale:\mixolydian,octave:2).q,
		attack:0.001,
		amp:0.25,
		dur:d.sum-2,
		dur:[ d[0..1].sum,d[2..3].sum,d[4..5].sum ].q,
	].pm(\stringyy).play }
);
P(\tuneWhat,start:\What,music:
	Song.currentSong.pbind[\What]
);

P(\stillWhat,start:\What,music:{

	{
		~stills.preview('what is it you want',text:["what is it you want","x"])
	}.defer
}
);
/*KIRK:*/[" In the ne-- xt room, there are /*other*/ two receptacles. ", [1,2, 3,2 ,2, 2,3, 4,3,3,2,1, ].dm(\a) ].addLine;
~justTheTune.('two receptacles',{|i|Pbindf(i,\amp,0.25,\instrument,\stringyy)});
// last bar is five thirds!
~receptaclesQuarters = Song.parseBeats('two receptacles',[1/2, 3/2, 3/4,1/4,1,1/2,3/2,3/4,1/4,  1/3,1/3,4/3]);
P(\triadReceptacles,start:'two receptacles',music: { |p b|
	[
		//		instrument:\bd_808,
		//~receptaclesQuarters * [1,[1/2,1/2]] =>_.size
		dur:  ~receptaclesQuarters * [1,[1/2,1/2]]  
		=> _.flatten => _.q ,
		freq: [\].q
		++ [ 1,5,13 ].df(\a,octave:3).q
		++ [ 1,5,13 ].df('a-',scale:\minor,octave:3).q
		++[ 1,5,13 ].df('b',scale:\minor,octave:3).q
		++ [ 1,5,13 ].df(\a,octave:3).q
		,
		legato:[\].q++[3,2,1].q(inf),
		out:[1,2,3].q(5),
	].pp;
}
);
P(\stillReceptacles,start:'two receptacles',music:
	{ |p b|
		//Still(~stills,'next room',5,b.sum-5,nil,["in tne next room...",""]).add(14*60+51).play
	}
);
["(boom) The other two of us that survived. ", [6,6,14,15,13,12,11,13,12.5,12].dm(\a,octave:4) ].addLine; 
~justTheTune.('that survived',{|i|Pbindf(i,\amp,0.25,\instrument,\stringyy).drop(1)},syl:0);
~thatSurvivedQuarters = Song.parseBeats('that survived',([3/4,1/4,3/4,1/4, 1/3,1/3,4/3, 2/3,1/3, 1]));
P(\triadSurvived,start:'that survived',music:{ |p b|
	[
		dur: 
		~thatSurvivedQuarters * [[1/2,1/2],1]
		=> _.flatten => _.q => _.fin(6) 
		=> [_, 
			~thatSurvivedQuarters[4..5].q 
		]
		=> _.q
		,
		freq: 
		[3,15,23].df('d',octave:3 ).q
		++[1,11,24].df('e',octave:3 ).q
		++[\r,[1,6,12]].df('f#',octave:3).q
		,
		out:[1,2,3].q(5),
		legato:[3,2,1].q(inf),
	].p.trace.play
}
);
["You, Doctor A-- nn Mulhall, and ",[21,15,14,13,12,11,5,21].dm(\c,scale:\minor,octave:4)].addLine; 
P(\stillMulhall,start:'nn Mulhall',music:
	//Still(~stills,'Jane Mulhall',text:[ "You!","r" ],fade:2,wait:1).add(15*60+2.0)
	{}
);
P(\chordYouAnn,start:'nn Mulhall',music:
	{ |p b|
		var verb= Effect.new({|i | 
			FreeVerb.ar(i,0.7,0.9) 
			=>BPF.ar(_,
				Env.linen(8,level:4000).kr(gate:1)+300,
				//SinOsc.kr(5).range(200,4000),
				1/5)
				//				* 4
			}).bus.index;
			~syn1.expression(127,0);
			~syn1.setOut(verb);
			(freq:[1,11].df('c',scale:\minor,octave:3),amp:[0.7,0.32],width:[5,10],instrument:\stringyy,dur:b.sum).play;
			(dur:b.sum,type:\vst_midi,vst:~syn1.controller,strum:0.04,instrument:\tremoloSwell,midinote:[1,3,5,11].dm(\c,scale:\minor,octave:4)).play;
			b.sum.postln;
		}
	);
	~justTheTune.('A-- nn');
	["you --, Mister Spock, ",[11,7,6,5,7].dm('c',octave: 5,scale:\minor)].addLine;
	P(\stillYouSpark,start:'you --',music:
		//defer{~stills.preview('Mister Spock',text:[ "You!","r" ])}}
		//Still(~stills,'Mister Spock',5,0,text:["You!",""]).add(15*60+5)
		{}
	);
	~justTheTune.('Mister Spock');
	P(\continuedLineMisSpock,start:'you --',music:{|p b|
		~zz=LambdaEnvir( 
			[
				def: SynthDef(\sparkTriangle,{

					var vibrato=Vibrato.kr(\freq.kr(400,0.2),5);
					DPW3Tri.ar(vibrato)
					* Env.asr(1,\amp.kr(0.2),3).kr(2,gate:\gate.kr(1))
					=> Out.ar(\out.kr(0),_)
				}).add.name,
				pbind: 
				{
					var def = ~def; 
					[
						instrument:~def,
						freq:[11,7,6,5,4].df('c',scale:\minor,octave: [5]).q,
						amp:0.03,
						dur:b[0..3]++b[4..].sum => _.q,
					].p
				},
				play: {~pbind.play}
			]
		).play
	}
);
P(\sparkBassNote,start:'you --',music:
	{ |p b|
		LambdaEnvir((
			effect:  Effect.new(
				{ 
					| i | 
					FreeVerb.ar(i,0.7,\room.kr(0.9,0.5)) 
					=> BPF.ar(
						_,
						Env.linen(8,level:4000).kr(gate:1)+300,
						1/3
					)
					* 4
				},inputChannels:2
			) ,
			verb:{ ~effect.bus.index },
			bass: { (freq:[1.5,11].df('c',scale:\minor,octave:3),amp:[0.7,0.32],width:[5,10],instrument:\stringyy,dur:b.sum).play.id } ,
			tremolo:{ 
				var synful=topEnvironment.use{~syn1};
				synful.setOut(~verb);
				synful.expression(127,0);
				(
					type:\vst_midi,vst:synful.controller,
					strum:0.04,
					instrument:\tremoloSwell,
					midinote:[1.5,4,6,11].dm(\c,scale:\minor,octave:4),
				).play },
				cutoff:FunctionList.new.array_([
					{~effect.synth.set(\room,0.5)},
					{~bass.do{|i| Node.basicNew(s,*i).release}},
				]),
				play: {~tremolo;~bass;fork{4.wait;~cutoff}}
			)).play;
		}
	);
	["we /*require*/ need your bodies also. ",[5,6,4,6,5,4,3].dm('b-',octave: 4,scale:\minor)].addLine; 
	~justTheTune.('your bodies also',{|i|Ppar([i,i=>Pbindf(_,\amp,0.3,\instrument,\stringyy)=>Pmul(\freq,0.5,_)])});
	P(\basesNoteBodies,syl:4,start:'your bodies also',music:
		{ |p b| 
			(
				//instrument:\sawSynthSustain,
				instrument:\stringyy,
				dur:2,
				freq:[1,11].df('b-',octave: 2),
				att:0.7,
				amp:0.7
			).play 
		}
	);

	["We /*must have*/ need Captain Kirk and you so that we may live again.",[5,6,7,7,11].dm('b-',octave: 4,scale:\minor)
	++[7,13,12,11,5.5,7,5,4,4].dm('a',octave: 4,scale:\mixolydian)
].addLine; 

~justTheTune.('live again');

P(\youChord,start:'live again',syl:5,music:
	{ |p b|
		(
			freq: [5,7,11,13].df('a',octave: 3,scale:\mixolydian),
			strum: 0.08,
			instrument: \sawSynthSustain,
			amp:0.06,
			dur:b[0..2].sum,
		).play
	}

);
P(\weMayLive,start:'live again',syl:8,music:{ |p b|
	[
		freq: [4,5,3].df('c',octave: 3).q,
		dur: Song.parse('live again',[1,1,1],9).q,
		legato: ( 0..2 ) .collect{|i x| b[x..2].sum/b[i] } =>_.q ,
		amp:0.15,
	].pp
};
);
//MUTEDP(\fadeUpLive,start:'live again',music:
//MUTED{|p b|
//MUTEDLambdaEnvir((
//MUTEDfade:{{ Env([0,0,1,1,0]*0.5,
//MUTEDSong.parse('live again',[11,2,1])
//MUTED).kr(2,gate:1) }.play(s,~bus)},
//MUTED//				fade:{ {Line.kr(0,0.5,3,doneAction:2)}.play(s,~bus) },
//MUTEDbus:{Bus.control.index},
//MUTEDsynth:{ Synths(\stringyy,\freq,[1,11].df('d',octave:3)) },
//MUTEDmap:{~synth.map(\amp,~bus)},
//MUTEDplay:{~synth;~fade; ~map },
//MUTED)).play
//MUTED}
//MUTED);
P(\liveChord,syl:10,start:'live again',music:{ |p b| 
	[
		//			chord:Pxrand([7,12,14,16].df('c'),inf),
		chord:Pxrand([5,11,13,15,17,22].df('a',scale:\mixolydian),inf),
		freq:Pfunc({|e| e.chord * [1,2,0.5].choose }),
		dur:0.1,
		effect:Effect(FreeVerb.ar(_,0.9,1),inputChannels:4).bus.index,
		out:Pkey(\effect)+Pwhite(0,3),
	].p
	=> Pfindur(1,_)
	=> _.play
}
	);
	P(\againFinalChord,syl:12,start:'live again',music:
		(
			freq:[3,5,11].df('d',octave: 3,scale:\minor),
			duration:2,
			amp:0.1,
			out:(0..2),
			instrument:\sparkTriangle

		)

	);

	//MUTEDP(\vocalLiveAgain,start:'live again',lag:-0.2,music:
	//MUTED//Item('live again').arm(length:Song.secDur['live again'])
	//MUTED{
	//MUTED{Item('live again').playbuf=>{|i|i.distort+AllpassC.ar(i,1,LFBrownNoise2.kr(1!4).range(0.1,0.4))=>AllpassC.ar(_,1,rrand(0.1,0.15!4),4)/2}}.play;
	//MUTEDItem('live again double').play
	//MUTED}
	//MUTED);
	P(\finalBassNote,start:'live again',syl:12,music:
		(note:2,octave:[3,4,3,2],amp:0.3,attack:0,instrument:\stringyy)
	);
)}
