(
//(Kirk staggers back slightly, then there is a high-pitched sound as his head is flung back.) 

Song.new(\panel2,[]);
Song.panel2.current;
Song.resources.infrastructure=FunctionList.new.array_([]);
/*SPOCK:*/[" Just a moment, Doctor. ","r",].addLine; 
/*KIRK:*/[" I am Sargon. ","r",].addLine; 
/*MCCOY:*/[" Where's our captain? Where's Jim Kirk? ","r",].addLine; 
/*KIRK:*/[" He is unharmed. I have taken his body to demonstrate ","r",].addLine; 
/*MCCOY:*/[" (drawing his phaser) I won't go along with this. Back to where you were, Sargon, or whatever you are. ","r",].addLine; 
/*SPOCK:*/[" And if he refuses, Doctor, what do you propose to do with your phaser?", [13,12,11,13,15,13,11,6].dm('e-',scale:\whole )++ [5,7,11, 5,6,7,11,7,11, 4,3].dm('g')].addLine; 
	["That is still Jim's body. ", [3,4,5,11,5,4].dm('f#',scale:\minor)].addLine; 
//(Kirk convulses briefly, and the sphere has dimmed a lot.) 
Song.sections.postln;//7
/*KIRK:*/["(dum dum dum dum) Lungs filled with air again.(dum dum dum)",[1,1,1,1,3,3,3,3,2,2,2,2,2].dm('a-')].addLine;
//Song.durs[7]=[ 0.499, 0.461, 0.461, 0.529, 0.919, 0.506, 0.503, 1.374, 0.536, 4.69, 0.46, 1.18, 0.488, 3.426,0.411,1.08 ].q;
//~quarters7=Song.parse(7,[2,2,1,2,2/3,[1/3,1],2,2,2,
~eighths7 = Song.parse(7,[1,1,1,1, 1/2,1/2,1,1,1/3,1/3,1/3,1,1,1,1,1]).q;
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
			=> Out.ar(\out.kr(0),_) ;
		}).add;
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
		~syn1.patch(\violas,\trem,0);
		~syn1.setOut( ~verbchannels=Effect(FreeVerb.ar(_,1,1),out:0,inputChannels:4).bus.index) ;
		~syn1.expression(100,0);
		~stringChords=[12,10,2,14,20,20,10];
		~stringChords=[12,0,2,4,0,0,0]-1;
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
["(dum *7) To see again. Heart,",[2,2,2,2, 2,2,2,4, 4,3, 3,2,2,2, 2,2,2,2,  2,2,5].dm('a-')].addLine; //8
P(\tune8,start:8,music:
	Song.currentSong.pbind[8].collect({|e|(e.midinote==([2].dm('a-')[0])).if{e.midinote=\};e})
	=> Pset(\legato,[1!10,5,1!12].flatten=>_.q,_)=>_.trace
);
P(\lungsB8,music:
	Pproto({
		~a=(type:\on,instrument:\pulser,out:[0,1]).yield;
		~aid=~a[\id];
	}, [
		type:\set,
		args:#[\decay,\pulse,\freq,\flag,\out,\amp],
		flag:[0.1,0.2],
		out:[0,1],
		freq:  
		[2].stutter(8)++[5!5,7,7,11].flatten
			=>_.df('a-',scale:\mixolydian,octave:2)=>_.q
			++ 
			(
				[1!8,3!4,6!8].df('a-',octave:2).flatten
			=>_.q) 
			,
//		[11!8,[13,3]!4,6!8].flatten
//			=>_.df('a-',octave:1)=>_.q,
		decay:0.70,
		pulse:1,
//		dur:Pkey(\durr),
		dur:~eighths8,
		id:Pkey(\aid)
	].p
	//+= Song.pbind[7]
	//=>Pn(_,2)
	,{})
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
].addLine;  
~quarters9=Song.parseBeats(9,[1,5,2/3,2/3,2/3+2,2/3,2/3,2/3,3.5,0.5,1.5,0.5]);
~eighths9=~quarters9.stutter(2)/2=>_.quantizeWindow;
P(\pumping,start:9,music:
	(instrument:'defaultPorto',freq:[1,3,5,7,11,13,15].df('c'),dur:3)
); 
P(\tune9,start:9,music:Song.currentSong.pbind[9]
);
// Song.currentSong.play(\blood,\tune9,\pumping)
P(\blood,start:9,syl:7,music:
	(instrument:'defaultPorto.clean',freq:[1,3,5,7,11,13,15].df('e'),dur:3)
); 
P(\fallingSwell,start:9,syl:2,music:
		{ Pdefn(\swellChord, [5,7,11,15].dm('c')-Pseg([0,25],10)) }
);
//~syn1.allNotesOff
"/Users/michael/tank/super/808-mod.scd".load;
P(\lungsB9,music:
	Pproto({
		~a=(type:\on,instrument:\pulser,out:[0,1]).yield;
		~aid=~a[\id];
	}, [
		type:\set,
		args:#[\decay,\pulse,\freq,\flag,\out,\amp],
		flag:[0.1,0.2],
		out:[0,1],
		freq:  
		{
			var c=List.new;
			[11,8,14,16,13,4,12,4,6,4,5,4].pairsDo({|a b|  c.add(a!b) });
			c.flatten.asArray.df(octave:1).q
		}.value
			,
//		[11!8,[13,3]!4,6!8].flatten
//			=>_.df('a-',octave:1)=>_.q,
		decay:0.70,
		pulse:1,
//		dur:Pkey(\durr),
		dur:
//		~quarters9.stutter(2) .q/2,
		~eighths9.q,
			id:Pkey(\aid)
		].p
	//+= Song.pbind[7]
	//=>Pn(_,2)
	,{})
);
	["half a million years. To be again.","r"].addLine; 
//	["Your captain has an excellent body, Doctor McCoy. I ","r"].addLine; 
//	["compliment you both on the condition in which you maintained it. ","r",].addLine; 
///*SPOCK:*/[" What are your plans for it? Can you exchange places again when you wish? ","r",].addLine; 
///*KIRK:*/[" Have no fear. Your captain is quite unharmed, although his mind generates insufficient energy for him to speak from there as I do.","r",].addLine; 
/*SPOCK:*/[" Doctor? ","r",].addLine; 
/*MULHALL:*/[" Yes, I have the same readings. ","r",].addLine; 
\aware.post;Song.sections.postln;
/*MCCOY:*/[" Are you aware of what's happening to his body? ",[7,11,5,13,12,11,7,11,5, 7,11,14,13].dm('f',scale:\mixolydian)].addLine; 
	Song.durs.put(13,[ 0.295, 0.347, 0.315, 0.566, 0.3, 0.322, 0.291, 0.313, 1.213/2, 0.278, 0.361, 0.62, 0.633, /*3.236*/ ].q);
P(\tune13,start:13,music:Song.currentSong.pbind[13]
);
P(\accent13,start:13,syl:2,music:
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

P(\bass13,start:13,music:Song.currentSong.pbind[13]
	=>Pbindf(_,
		\amp,0.03,
		\lag,Pwhite(-0.005,0.005)
	)
	=>Pmul(\freq,1/4,_);
);
P(\kick13,start:13,music:1111.postln;{
	[
		instrument:\bd_808,
		dur:
		Song.parse(13,[3,1,2,2,1/2,1/2,2,1,1],).q
		,
		note:[\].q++[1].q(inf),
	].pp
}
);
	["Heart action (almost) doubled, ",[13,12,11,7,11,7,11,16,15].dm('e',scale:\mixolydian)].addLine; 
//Song.durs.put(13,[ 0.545, 0.304, 0.31, 0.302, 0.327, 0.311, 0.332, 0.555, 0.429, 2.165 ].q);
P(\tune14,start:14,music:Song.currentSong.pbind[14]
);
P(\bass14,start:14,music:Song.currentSong.pbind[14]
	=>Pbindf(_,
		\amp,0.03,
		\lag,Pwhite(-0.005,0.005)
	)
	=>Pmul(\freq,1/4,_);
);
P(\kick14,start:14,music:{
	[
		instrument:\bd_808,
		dur:
		Song.parse(14,[1,2,2,2,2/3,[1/3,1]]).q
		,
//		note:[\].q++[1].q(inf),
		out:3,
	].pp
}
);
	["temperature a hundred and four degrees? ",[13,12,11,7,11,12,7,13,13,16].dm('f#',scale:\mixolydian)].addLine;

P(\tune14,start:14,music:Song.currentSong.pbind[14]
);
/*MULHALL:*/[" He'll die if you don't leave his body. Soon! ", [15,21,15,13,12,11, 7.5,12,11, 11.5].dm('c#',scale:\minor) ].addLine; 
/*SPOCK:*/[" What is it you want of us? ","r",].addLine; 
/*KIRK:*/[" In the next room, there are other receptacles. ","r"].addLine;
	["The other two of us that survived. ","r"].addLine; 
	["You, Doctor Ann Mulhall, ","r"].addLine; 
	["and you, Mister Spock, ","r"].addLine;
	["we require your bodies also. ","r"].addLine; 
	["We must have Captain Kirk and you so that we may live again.","r",].addLine; 
)
(
	SynthDef(\quadBass,{
		Demand
	})
)
(

	{
		var sig,freq, a, b, t = Impulse.kr(9.rand);
//		var freq=\freq.kr(200);
		a = { Dseq([1,2,3,4,5,12,11,32],inf) } * 450*3.rand;//*30.rand;
		freq=Demand.kr(t,0,a) => Lag.kr(_,1.0.rand);
		sig=VOSIM.ar(Impulse.ar(freq+2.0.rand/4),200,2)*0.1
		//sig=VOSIM.ar(Impulse.ar(freq+2.0.rand/4),freq*2,1)*0.3
		=> Pan2.ar(_,Rand(-1,1.0))
		//=>MoogVCF.ar(_,SinOsc.kr(1/(20.rand)).range(200,8000),0.6)
		=> BMoog.ar(
			_,
			LFBrownNoise1.kr( LFBrownNoise1.kr(2).range(0.2,1)).range(200,8000),
			0.9,
			0
		)
    }.play
)

(
	//do it all in one synth?
	//or use busses to automate controls w/envs or..
	//\set type patterns with lags ??
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
		=> Out.ar(\out.kr(0),_)
		;
	}).add;
)
(
	[
		type:\set,
		args:#[\decay,\pulse,\freq,\flag,\out,\amp],
		flag:[0.1,0.2],
		out:[0,1],
		freq: [1,4,2,5].stutter(8).df('a-',octave:2 ).q ,
		decay:0.70,
		pulse:1,
		dur:Pkey(\durr),
		id:Pkey(\aid)
	].p
	=>Pn(_,2)
	//=> {|i| Ppar([
	//	[
	//		note:[8].q(1.5*32),
	//		dur:Pkey(\durr)/1.5,
	//		lag: Pwhite(0,0.02)+[3,0].q(inf)/100,
	//		instrument:Prand([\rimshot,\sn,\HC],inf),
	//		amp:Pwhite(0.02,0.025)*[3,2,4,2].q(48)/3,
	//	].p,
	//	i
	//])}
	=> Pchain([
		dur: Pseg([0.42,0.40,0.40],[5,50])
	//	Pseries(0.4,-0.001)
	].p,_)
	=> [_,[note:[\,\,1,1,\,\,1,\].q(inf),instrument:\sn,\amp:0.25,
		dur: Pseg([0.42,0.40,0.40],[5,50])
	].p] => Ppar(_)
	=> [_,[note:[1,\].q(inf),instrument:\cymbal,\amp:1.85,
		dur: Pseg([0.42,0.40,0.40],[5,50])
	].p] => Ppar(_)
	=>Pproto({
		~a=(type:\on,instrument:\pulser,out:[0,1]).yield;
		~aid=~a[\id];
		~durr=0.41;
	SynthDef(\pulser,{
		var env= Env.perc(0.01,\decay.kr(0.5)).kr(0,gate:\pulse.tr(0));
		var env2= Env.perc(0.01,1.5).kr(0,gate:\pulse.tr(0));
		var freq = \freq.kr(150,\flag.kr(0));
		var sig= 
		[
			Saw.ar(freq,0.1)
			=> BMoog.ar(_,env*2000+10,0.3)
			+ (PinkNoise.ar(0.5) * env => BMoog.ar(_,LFBrownNoise2.kr([1.01,1]).range(100,1000),0.9,2)=>FreeVerb.ar(_,0.3,0.5))
			//=> EchoNone.ar(_,0.5,0.456,3)
			//=> FreeVerb.ar(_,0.8,1)
			* Env.cutoff(5).kr(2,gate:\gate.kr(1))
			*\amp.kr(1) //*0
			,SinOsc.ar(100,0,0), (0.2*VOSIM.ar(Impulse.ar(freq*[0.5,1]),SinOsc.kr(1/7).range(140,130),2,0.8)*env2)
		]
		=> Out.ar(\out.kr(0),_)
		;
	}).add;

	},_,{})
	//=>Pset(\tempo,2.1,_)
	=>Pset(\tempo,1.01,_)
	//=>Pfindur(32,_)
	=>_.play;

)

