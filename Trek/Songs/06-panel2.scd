(
	{
		Song.new(\panel2,[]).current;
		// Stills("/Users/michael/tank/Trek/video for stills etc/media/return to tomorrow.mov").current;
		Stills.new().current;
		Song.resources.infrastructure=FunctionList.new.array_([]);
		// Song.synful1=Synful();
		Trek.synful;
		Song.resources.infrastructure.addFunc({TempoClock.tempo_(1).postln});
		Song.resources.condition=Condition.new;
		Song.resources.infrastructure.addFunc({Song.resources.condition.test_(true)});
		Song.synthVTracks = EventWithDefault(
			\kevin, { arg pan = 0;
				{|i|
					i
					=> EarlyRef.ar(_,[2,2,0],[pan * 2 + 2,2,1], [4,5,7])
					=> DWGReverbC1C3.ar(_, mix:0.05)
					* -7.dbamp

				}
			},
			\mo, { arg pan = 0, mix = 0.1;
				{|i|
					i
					=> EarlyRef.ar(_,[2,2,0],[pan * 2 + 2,2,1], [4,5,7])
					=> DWGReverbC1C3.ar(_, mix:mix)
					* -9.dbamp

				}
			},
			\teto, { arg pan = 0, mix = 0.1;
				{|i|
					i
					// => EarlyRef.ar(_,[2,2,0],[pan * -2 + 2,2,1], [4,5,7])
					// => DWGReverbC1C3.ar(_, mix:mix)
					=> Song.verb.(_,mix:0.1)
					* -9.dbamp

				}
			},
			\default, { |mix = 0.1|
				{|i|
					i
					=> DWGReverbC1C3.ar(_, mix:mix)
					* -9.dbamp
				}
			},
			\genbu, { |mix = 0.1|
				{|i|
					i
					=> DWGReverbC1C3.ar(_, mix:mix)
					* -13.dbamp
				}
			}


		);
	}.();
Song.early={|in pan distance= 1.5 rearWall = 1| 
	var room = #[6, 5.11, 4.37] ;
	var mic = #[3, 1, 1.6]; // centered horizontally 1.6 m high and 1.5 away
	var panToRad = {|i| i * pi / 2 };
	var earlyRefFunc = {|i| i = panToRad.(i);[3 + (i.sin * distance), rearWall + (i.cos * distance) , 1.6]};
	EarlyRef.ar(in,earlyRefFunc.(pan), mic, room)
};	
Song.verb= {|in pan=0 distance=1.5	 rearWall=1.1 mix=0.5 c1=1 c3=10|var early = Song.early.(in, pan, distance, rearWall); DWGReverbC1C3.ar(early, c1:c1,c3:c3) * mix+ early};

	[ "(Kirk staggers back slightly, then there is a high-pitched sound as his head is flung back.)" ,"r",[6]].addLine;
P.still('high pitched noise',start:'staggers',timecode:[1235.seconds,1236.seconds],music: { |p b e|
		{
			Impulse.ar(Gendy1.kr(minfreq:2,maxfreq:10!4).range(1,[800,1700,3440,8000]))
			*  EnvGen.kr(Env.linen(0,3,15,0.2,-6),doneAction:2)
			=> {|i| (i * 2).sin.tan}
			=> FreqShift.ar(_, Env([0, -500, -1000], b[0] ).kr(0))
			/5
		}.play;
		e.still[1].value(wait:4,fade:2); //listed first because behind
		e.still[0].value(wait:1,fade:1);
});
/*SPOCK:*/[" Just a moment, Doctor. ", [12,11,13,11,5.5,5].dm('a-')].addLine; 
P.synthV( role: \spock, take: \lead,
	filter: (midinote: _ - 24), 
	params: {|p b| [
	lyrics: "just a moment + doctor +",
	lag: [0.05,0.04,0.03,0.02,0.01,0],
	legato: [1, 1, 1, 1, 1, 0.8, ],
	pitchTake: 1,
	paramGender: 0.2,
	paramToneShift: 181,
	paramBreathiness: 0.28,
	paramTension: 0.5,
	vocalMode: \Rough

] }, music:{|p b e|
	{
		e.playbuf
		=> p.verb.(_, pan:-0.3,mix: 0.1)
		* -11.dbamp
		// => p.synthVTracks.at(e.key).()
	}.play
});
P.still(\spock,\moment,timecode:1238.seconds,music:{|p b e|
	e.still.(
		wait: b.sum,
		text: ["just a moment","Doctor"]
	)
});
/*KIRK:*/[" (boom) I am Sargon. ",[6,6,5,11,1].dm('c#',scale:\minor)].addLine; 
P.tune('I am Sargon',{|i|i=>_.drop(1)},syl:0);
P.still(\kirkNewVoice, timecode: 1247.8.seconds, music: { |p b e|
	 e.still.( 
		wait: b.sum,
		text: ["",""],
	).sequenceText2(
			b.parse([1]), [ 
				["I am","Sargon"]
			],
	)
});
P.synthV(role: \sargon, take: \lead,
	filter: (midinote: _ - 12), 
	params: {|p b| [
	lyrics: "r ai am sa gan",
	legato: [1, 0.8, 1, 1, 1, ],
	pitchTake: 1
] }, music:{|p b e|
	{
		e.playbuf
		=> {|i| CombN.ar(i,0.3,0.3,4) /5.5 + i}
		=> p.early.(_,pan:0.5)
		* -6.dbamp
	}.play
});
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
P.still(\mccoy,syl:1, timecode: 1251.8.seconds, music: { |p b e|
	 e.still.( 
		wait: b.drop(1).sum,
		text: ["where's our captain","where's Jim Kirk?"],
	)
});
// P.tune('our captain');
P.synthVs(role: \mccoy, take:[\lead, \dbl],
	filter: (midinote: _ - 12), 
	params: {|p b| [
	lyrics: "r r Where's our captain? + Where's Jim Kirk? ",
	vocalMode: \Open,
	paramTension:1,
	legato: [[1, 1, 1, 0.7, 1, 0.8,0.8]],
	pitchTake: [1, 3]
] }, music:{|p b e|
	{
		e.playbuf
		// => p.synthVTracks.at(e.key).()
		=> EarlyRef.ar(_,[0,0,0],[1,2,3])
		=> DWGReverbC1C3.ar(_, mix:0.05)
		* -7.dbamp
	}.play
});
P(\chordCaptain,start:'our captain',music:{ |p b|
	[ 
		freq:[[1,13,5],[1,13,5]].df('c',octave:4 ).q
		++[ [3,13,15] ].df('f',octave:3 ).q
		,
		dur:[ b[0],b[1..3].sum,b[4..5].sum ].q,
	].p.play;
	[
		freq: [\r, [3, 11], [3, 11], [6, 11]].df(\c,4).q,
		dur: b.parse([2, 1, 1, 1]).q,
		instrument: \default,
		legato: [1, 0.9,1,1,1 ].q,
		instrument: \sawSynthSustain
	].ppma
});
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
	a=VoiceLeading([[5,4.5,5],[3,\_,3],[1,\_,1],[\r,\r,7.5]] , b.drop(1)[0..2]);
	a=a.dm('f',scale:\minor);
	//	a.pbind.do{|i|i => Pset(\midinote,Pkey(\val)) => _.play };
	a.lines.do{|h i| [amp:0.06,out:i,lag:Pwhite(0,0.1,inf),legato:1,midinote:a.voice(i).line.q,dur:a.voice(i).durs.q].pm(\sparkTriangle).play};
	//	[midinote:a.voice(0).line.q,dur:a.voice(0).durs.q].pp;
	//	[midinote:a.voice(1).line.q,dur:a.voice(1).durs.q].pp;
	//	[midinote:a.voice(2).line.q,dur:a.voice(2).durs.q].pp;
}
);
["He is unharmed. I have taken his body to demonstrate ", [7,11,12,13, 12,13,14,11,7,7,6, 5,15,14,12.5].dm('a',scale:\mixolydian), ].addLine; 
~quarters3= Song.parseBeats(\demonstrate,[2/3,2/3,2/3, 8/3,2/3,2/3, 2/3,2/3,2/3, ]);
Song.setTempoMap(\demonstrate,"Q Q Q QQQQ Q Q Q Q Q QQ Qq q q q q");
P(\ride, music: { |p b e|
	[
		dur: "qq*5".beats .warpTo(e.tempoMap).q,
		instrument: \cymbal_808, amp: 0.2,
		rest: MuteFirst()

	].pp
});
P.still(\sargonKirk, timecode: 1255.48.seconds, music: { |p b e|
	 e.still.( 
		wait: b.sum,
		text: ["he is","unharmed"],
	).sequenceText2(
			b.parse([4, 7]), [ 
			["I have","taken his body"],
			["to","demonstrate"]
			],
	)
});
P.tune(\He, _ <> [instrument: \sparkTriangle, width: 1.03, amp: 0.02].pm);
P.synthV(role: \sargon, take: \lead,
	filter: (midinote: _ - 24), 
	start: Song.section( \unharmed ), params: {|p b| [
	lyrics: "Hi iz an hand  ai hav te ken  hiz bo di  tu deman + stret + + ",
	phonemes: ["h i","i z", "@ a n", "h a r m d", "a i", "h a v", "t e i ","k e n","h i z","b a","d i ","t u","d e","m o n","ch t r e t"],
	legato: [1, 1, 1, 0.8, 1, 1, 1, 1, 1, 1, 0.8, 1, 1, 1, 1],
	lag: [0.05, 0, 0, 0,   0, 0, 0, 0, 0, 0, 0,   0, 0, 0, 0],
	pitchTake: 1
] }, music:{|p b e|
	{
		e.playbuf
		=> {|i| CombN.ar(i,0.3,0.3,4) /5 + i}
		// => p.synthVTracks.at(e.key).()
		=> p.early.(_,pan:0.5)
		* -6.dbamp
	}.play
});
P(\line, music: { |p b e|
	[
		freq: "7 7 6 5".df(\a,4,\mixolydian).q,
		dur: b.parse([1,1, 1, 1]).q,
		instrument: \wash, amp: 0.06, freqLag: 0.1
	].ppm
});
// P(\tune3,start:\unharmed,music:
// 	Song.currentSong.pbind[\unharmed]
// );
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
			[5,7,12.5,5]
		].df('a',octave: 4,scale:\mixolydian).q,
		out:(1..4),
		amp: 0.08,
		mix: 0.15,
		width: 10,
		freqLag:0.5,
		dur: Song.parse(\unharmed,[3,3,3,3],3).q,
	].pm(\stringyy)
);
[/*MCCOY:*/" (drawing his phaser) I won't go along with this. Back to where you were, Sargon, or whatever you are. ", [4,3,2,1].dm('b-',scale:\whole) ++[13,11,5].dm('d-') ++[1,2,3,4,5].dm('g',scale:\whole) ++ [15,14,13,12,14,12,11,7].dm('d',octave: 4) ].addLine; 
Song.durs[\along].list.do(_.postln);
Song.durs.filter(\along,{|i| var last = i.last; i.dropLast ++ (last * 0.8)});
P.still(\mccoy, timecode: 1310.7.seconds, music: { |p b e|
	 e.still.( 
		wait: b.sum,
		text: ["I won't go","along with this"],
	).sequenceText2(
			b.parse([7, 5]), [ 
			["back to","where you were"],
			["Sargon or", "whatever you are"]
			],
	)
});
P.synthVs( role: \mccoy, start:5, take: [\lead, \dbl],
	filter: (midinote: _ - 12), 
	params: {|p b| [
		lyrics: "I won't go along + with this. Back to where you were, Sargon +, or whatever + + you are. ",
		legato: [[1, 1, 1, 1, 1, 1, 0.6,  1, 1, 1, 1, 0.6, 1, 0.8, 1, 1, 1, 1, 1, 1, ]],
		pitchTake: [1, 3],
		paramTension: 1,
		vocalMode: \Open
	]}, music:{|p b e|
		{
			e.playbuf
			// => p.synthVTracks.at(e.key).()
			=> p.verb.(_,pan:0, mix: 0.1)
			* -14.dbamp
		}.play
});
P(\note, music: { |p b e|
	[
		freq: [\r, [1, 5].df('b-',4)] => _.flat => _.q,
		dur: b.parse([3, 1, 1]).q
	].pp
});
P('trem',start:\drawing,music: {|p b e|
		[
			freq: [4,4.5].df('b-',[4,5],\whole).q,
			instrument:\stringyy,
			att:0.01,
			amp:0.3,
			dur:b.parse([4,5]).q,
			instrument:\trem2,amp:0.02,
			rel:2,
			scale:1,
			freqLag:1
		].pm(\trem2).play
});
P(\bongbong, music: { |p b e|
	[
			freq: [4,4.5,5.5].df('b-',[4,3],\whole).q,
			dur: b.parse([4,7,1]).q,
			instrument: \harp, amp: 0.05
	].pp
});
P(\connector,syl:15, music: { |p b e|
	[
		freq: "14 12 11 7 6.5".df('d',4).q,
		dur: b.drop(1) ++ e.bNext[..3].sum =>_.q,
		instrument: \wash, freqLag: 0.1
	].ppm
});
P('trem2',start:\drawing,music: {|p b e|
		[
			freq: [\r,1,-6.6].df('b-',[4,5],\whole).q,
			instrument:\stringyy,
			att:0.01,
			amp:0.3,
			dur:b.parse([3,2,5]).q,
			instrument:\trem2,amp:0.02,
			rel:2,
			scale:1,
			freqLag:1
		].pm(\trem2).play;
		(freq:[1,2].df(\d,\minor,dur:b.parse([7])),instrument:\stringyy).play
});
P('answer',start:\drawing,music: {|p b e|
		[
		freq:[\r,1,2,3,4,5].df(\g,[4,5],\whole).q,
		dur:b.parse([7, 1,1,1,1,1]).q,
			legato:[1, 5,4,3,2,2].q,
			instrument:\sparkTriangle,
			//instrument:\harp,
			depth:0.001,
			amp:0.02
		].pm(\sparkTriangle).play
});
P('cymbal',start:\drawing,music: {|p b e|
		[ instrument: \cymbalsDS,
			amp:0.01,
			att:[ 0,0.01 ].q,
			dur:b.parse([11,1]).q
		].p.play
});
/*SPOCK:*/[" And if he refuses, Doctor, (dum) what do you propose to do with your phaser?", [13,12,11,13,15,13,11,6, 6.5].dm('c',scale:\whole )++ [5,7,11, 5,6,7,11,7,11, 4,3,2].dm('e')].addLine; //5
Song.setTempoMap(\refuses,"e e e e q q q q qq q e ee e e e Q Q Q q qq e e q q q q");
P(\click, music: { |p b e|
	[
		dur: "q*16".beats.warpTo(e.tempoMap).q
	]//.pp
});
P.still(\spock, timecode: 1318.3.seconds, music: { |p b e|
	 e.still.( 
		wait: b.sum,
		text: ["and","if he refuses, Doctor"],
	).sequenceText2(
		b.parse([8, 1, 7]), [ 
			["",""],
			["what do you","propose to do"],
			["with your","phaser"]
			],
	)
});
P.synthV(role:\spock, take: \lead,
	params: {|p b| [
	filter: (midinote: _ - 12), 
	lyrics: " And if he refuses + + Doctor + r what do you propose + to do with your fay zer? +",
	legato: [0.6, 1, 1, 1, 1, 1, 1, 1, 1,  1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, ],
	pitchTake: 1,
	 // paramGender: 0.2,
	// paramToneShift: 181,
	paramBreathiness: 0.28,
	paramTension: 0.5,
	// vocalMode: \Soft 
	vocalMode: \Rough

] }, music:{|p b e|
	{
		e.playbuf
		// => p.synthVTracks.at(e.key).()
		=> p.verb.(_,pan:-0.3,mix:0.1)
		* -10.dbamp
	}.play
});
P(\strum5,syl:3,start:'if he refuses',music: {|p b e|
		(
			midinote: [1,3,5,11,13,15,21].dm('c',scale:\whole,octave:4),
			strum:0.04,
		).play;
		(
			lag:b.drop(1)[0..1].sum,
			dur:b.drop(1)[2..3].sum,
			freq: [-7, 1, 3, 7, 11, 13, 15,21].df(\c,4,\mixolydian),
			strum:0.04,
			amp: 0.03,
			out:2

		).play
	}
);
P(\tune5,start:'if he refuses',music:
		Song.currentSong.pbind['if he refuses'].fin(8) <> [ instrument:\wash, freqLag: 0.05, amp: 0.02 ].pm
);
P.tune('he refuses', {|i| i.drop(9) <> [instrument: \sawSynthSustain, amp: 0.05, out: 4].pm}, syl: 8 );
P(\connector,syl: 17, music: { |p b e|
	[
		freq: [4,3,2].df(\e, [4,5]).q,
		instrument: \stringyy,
		dur: b.drop(1).q,
		out: 2,3

	].ppm
});
	~eighths5= Song.parseBeats('if he refuses',
		(
			[1/2,1/2,1/2,1/2,1,1,1,1, 1,1/2,1/4,2/4,1/4,1/4,1/4, 1/3,1/3,1/3, 1/2,1/2]
			//*[1,1,1,1,1,1,1,1,1,1,1,1, 0.5,0.5,0.5,0.5,0.5,0.5,0.5,0.5]
		)
);
P(\whatDoYouChord, music: { |p b e|
	[
		freq: [\r, [1, 1, 1], [1, -7, 3.5], [-6,1,4],[-6,-7,1] ].df(\b,4,\minor).q,
		dur: "qqqqqq qq qq qq qq".beats.warpTo(e.tempoMap).q,
		instrument: \sawSynthSustain, amp: 0.01, hifreq: 9000,
		att: 2
	].ppm
});
P(\bassLine5,music:{|p b e|
	[
		freq: (\r!12++[11,11,7,7,6,6,5,5]).flatten.df('b',octave:2,scale:\minor ).q,
		//	dur:Song.parse(5,[1/2,1/2,[1,1,1/3],[2/3,1] ],8).q,
		dur:~eighths5.q.stutter(2)/2,
		out: Effect.bus({|i| i => FreeVerb.ar(_,0.05,0.9)   => SineShaper.ar(_,0.1) => _.tanh  },inputChannels:2)
	].pp
});

P(\bassNote5,start:'if he refuses',music:
	[ 
		freq: [\r,1,5].df('e',octave:3).q,
		dur:Song.parse('if he refuses',[18,2,1],).q,
		instrument:\sawSynth,att:1 
	].p
);
["That is still Jim's body. ", [2,3,4,6,4,1].dm('a',scale:\dorian,octave:5)].addLine; 
P.still(\clear, timecode: 0.seconds, music: { |p b e|
	 e.still.( 
		wait: b.sum,
		text: ["that is still","Jim's body"],
	)
});
P.synthV( role: \spock, take:\lead, 
	filter: (midinote: _ - 12), 
	params: {|p b| [
	lyrics: "that is still Jim's body +",
	legato: [1, 1, 0.8, 1, 1, 1, ],
	pitchTake: 1,
	// paramGender: 0.3,
	// paramToneShift: 181,
	paramBreathiness: 0.28,
	paramTension: 0.5,
	vocalMode: \Rough

] }, music:{|p b e|
	{
		e.playbuf
		=> p.verb.(_,pan:-0.3,mix:0.1)
		* -10.dbamp
	}.play
});
P(\bassNote6,start:'still Jim',syl:1,music:
	(freq:[1].df('f#',octave:2),instrument:\sawSynth,att:2)
);
[/* Insert */"(lungs intro - 4 eights)","1 1 1 1 1 1".dm('a-'), ].addLine;
Song.durs.filter(\intro, {
	Song.lyricsToDurs.at("(dum dum dum dum) Lungs filled with air again.(dum dum dum)").list
});
Song.setTempoMap('intro',"e e e e q e e qe e e e e e");
P(\bassTest, music: { |p b e|
	[
		dur: "e*15".beats.warpTo(e.tempoMap
			.quantizeWindow(0.3)
		).reverse.q(2).fin(16),
		freq: -11.df('a-'),
		freq: Pseg([-17,-1].df('a-', [4,5]),b.sum),
		amp: Pseg( [0.1,0.02],b.sum ),
		instrument: \sawSynth 
	].pp
});
//Song.durs[Song.section('lungs intro')].list.asArray.quantize(0.2)

//MUTEDP(\tempo7,start:'lungs intro',music:{
//MUTEDTempoClock.tempo_(0.89)}
//MUTED);
P(\dumx4,start:'lungs intro',timecode:1257.5.seconds, music:{
	|p b e| [
		dur:b,
		instrument:\stringyy,
		freq:1.df('a-',octave:3),
		width:Pwhite(10,100),
		attack:0,
		out:Pxrand((0..2),inf),
		amp:0.7
	].p.fin(6).play;
	//{~stills.preview(\lungs1)}.defer
});
P.still(\kirkmore, timecode: 1325.seconds, music: { |p b e|
	 e.still.( 
		wait: b.sum,
		wait:0.01,
		fade: b.sum,
		text: ["",""],
	)
});
//(Kirk convulses briefly, and the sphere has dimmed a lot.) 
/*KIRK:*/["(dum dum dum dum) Lungs filled with air again.(dum dum dum)",[1,1,1,1,3,3,3,3,2,2,2,2,2].dm('a-')].addLine;
Song.setTempoMap('with air',"e e e e q e e qe e e e e e");
P.still(\clear,syl:3, timecode: 0.seconds, lag:0.01, music: { |p b e|
	 e.still.( 
		wait: b.sum,
		text: ["lungs full of air","again"],
	)
});
P.still(\kirk, timecode: 1334.2.seconds, music: { |p b e|
	 e.still.( 
		 fadeIn: b.sum,
		// wait: b.sum + e.bNext,
		// wait: 0.1,
		// wait:0,
		wait:b.sum,
		fade: e.bNext.sum,
		text: ["",""],
	)
});
P(\crash, music: { |p b e|
	(
		instrument: \cymbalsDS,
		amp:0.005

	).play
});
( // Trek.cast.kirkLungs = \kevin;
	// Trek.cast.kirkLungs = \mo;
	// Trek.cast.kirkLungs = \teto;
	// Trek.cast.kirkLungs = \genbu;
	Trek.presets.put(\kirkLungs,\mo,
		[
			pitchExpression: 0.5,
			paramGender: 0.3,
			paramBreathiness:0.5,
			paramToneShift: 300,
			vocalMode:\Soft
		]
	);
	Trek.presets.put(\kirkLungs,\teto,
		[
			paramGender: 0.625,
			// paramBreathiness:0.5,
			paramToneShift: 200,
			vocalMode:\Power
		]
	);
	Trek.presets.put(\kirkLungs,\kevin,
		[
			pitchExpression: 0.5,
			paramGender: 0.3,
			paramBreathiness:0.5,
			paramToneShift: 300,
			vocalMode:\Soft
		]
	);
	Trek.presets.put(\kirkLungs,\genbu,
		[
			paramBreathiness: 0.3,
			paramLoudness: 2,

		]
	)
);
Trek.cast.kirkLungs = \genbu;
P.synthV(role: \kirkLungs, take:\lead, start: Song.section(\filled),
	filter: (
		midinote: _ - 12,
		dur: Song.durs[\filled].list.parse([1,1,1,1,1,1,1,1,1,3])
	), 
	params: {|p b key| [
	// lyrics: "r r r r lanz ful af er a gen r r r",
	lyrics: "r r r r lungs full of air again + r r r",
	phonemes: ( key == \genbu ).if{ ["","","","","r a N z","f u l","a v","e r","e","g e n"] },
/* 	
"full".romaji
*/
	pitchTake: 1,
	pitchExpression:1.3
] }, music:{|p b e|
	{
		e.playbuf
		// => p.synthVTracks.at(e.key).() 
		=> {|i| i + FreqShift.ar(i,LFNoise2.ar(1) * 10) * -3.dbamp}
		=> {|i| CombN.ar(i,0.3,0.3,4) /5.5 + i}
		=> p.early.(_,pan:0.0)
		* -4.dbamp
	}.play
});
( ~eighths7 = Song.parse(\Lungs,[1,1,1,1, 
	//	1,1,1,1,
	//	1,1,1,1,
	1/2,1/2,1,1,1/3,1/3,1/3,1,1,1,1,1]).q;
);
( SynthDef(\pulser,{
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
);
//MUTEDP(\tempo7,start:\Lungs,music:{{TempoClock.tempo_(0.9)}.value}
//MUTED);
P(\bass,music:
	{|p b e|
		Pproto({
			~a=(type:\on,instrument:\pulser,out:[0,1]).yield;
			~aid=~a[\id];
			// ~durr=~quarters;
		}, [
			type:\set,
			args:#[\decay,\pulse,\freq,\flag,\out,\amp],
			flag:[0.1,0.2],
			out:[0,1],
			freq: [1,4].stutter(8)
			=>_.df('a-',scale:\mixolydian,octave:2)=>_.q,
			decay:0.70,
			amp:0.2,
			pulse:1,
			//		dur:Pkey(\durr),
			// dur:~eighths7.quantizeWindow(0.5),
			dur: "e*16".beats.warpTo( e.tempoMap.quantizeDft(0.3) ).q,
			id:Pkey(\aid)
		].p
		//+= Song.pbind[7]
		//=>Pn(_,2)
		,{}).play
	}
);
P(\trapsLungs,start:\Lungs,music: {|p b e|
		[
			instrument:\bd_808,
			//		instrument:\hihat,
			dur: "e*72".beats.warpTo( e.tempoMap.quantizeDft(0.9) 
			++ p.tempoMap[e.start+1].quantizeDft(0.9) 
			++ p.tempoMap[e.start+2].quantizeDft(0.9) 
		).q,
			//		.list.quantize.q
			//		/2=>_.stutter(2),
			amp:0.3,
			instrument: \kick_gentle,vol:0.2,
		].pp;
	[
		instrument: \openhihat_808,
		// lag:0.1,
		dur: //"e q*32"
		"x*128"
		.beats.warpTo( e.tempoMap.quantizeDft(0.9) ).q,
		rests: MuteFirst(),
		restsTwo: [\r, 1].q(inf),amp: 0.3
	]//.pp
	};
);
P(\tremoloSwell,start:\Lungs,music:
		{

			(type:\vst_midi,vst:Song.synful1.controller,midicmd:\allNotesOff).play;
			Song.synful1.patch(\violas,\trem,0);
			Song.synful1.syn.set(\out,~verbchannels=Effect(FreeVerb.ar(_,1,1),out:0,inputChannels:4).bus.index) ;
			Song.synful1.expression(100,0);
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
			type:\vst_midi,vst:Song.synful1.controller,
			//verb:{ Song.synful1.setOut( ~verbchannels=Effect(FreeVerb.ar(_,1,1),out:0,inputChannels:4).bus.index) } ;
			//chords: [[5,7,11,15],[4,11,13,14]].stutter(8).q(16) ,
			//chords: Pstep([[5,7,11,15],[4,11,13,14]],4)=>Pn(_,3),
			chords: Pdefn(\swellChord),
			midinote: 
		Pfunc({|e|Prand(e.chords).asStream})
			+Prand([12,0,2,4,0,0,0],inf),
			//		\midinote: Prand([1,3,5,11].dm('f',scale:\minor,octave: 4),inf)+Prand([12,0,2,4,0,0,0],inf),
			dur:0.1,
			legato:Pwhite(3,9,inf),
			amp:0.2,
			panning:Pfunc({Song.synful1.syn.set(\out,(4.rand+~verbchannels))})

		].p=>Pfin(290,_)
		=>_.play;
	}
);
// P(\tune7,start:\Lungs,syl:3,music:
// 	Song.currentSong.pbind[ \Lungs ]
// 	=>Pmul(\freq,[1/2,1],_)
// 	=>Pset(\dur,Song.durs[\Lungs]+[0,0,0,0,0,0,0,0,0,2].q,_)
// 	=>_.drop(4)=>_.fin(6)
// ); 
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
		//		Song.synful1.setOut(0);
		Song.synful1.patch(\horn,\none,8);
		Song.synful1.expression(64,8);

		Song.currentSong.pbind[ \Lungs ]
		//=>Pset(\freq, [1,3].df('f',octave:4,scale:\minor), _)
		//	=>Pset(\dur,Song.durs[\Lungs]+[0,0,0,0,0,0,0,0,0,2].q,_)
		=>Pset(\out,Pwhite(0,3),_)
		=>Pbindf(_,\channel,8,\midinote,[1,3].dm('f',octave:4,scale:\minor ),\type,\vst_midi,\vst,Song.synful1.controller,\amp,0.1,\legato,3,\rel,5)
		=>_.drop(4)=>_.fin(6)=>_.trace=>_.play
	}
);
P(\subBass,music:{ |p b e|
	var roots = [1,4,2,5].dm('c#',octave: 2);
	var bars = [2,2,2,1];
	var notes = roots.collect({|i x| [i].q(bars[x]*4)}).q;

	[
		dur: 0.42,
		midinote:notes,
	].pp
}
);
["(dum *7) To see again. Heart,",[2,2,2,2, 2,2,2,4, 4,3, 3,2,2,2, 2,2,2,2,  2,2,5].dm('a-')].addLine; //8
Song.setTempoMap('see again',"e e e e e e e e eee e e e e e e e e e e e ee");
~eighths8= Song.parse(\Heart,1!8++[1/3,1/3,1/3,1,1,1,1,1,1,1,1,1,1,1,1/2,1/2],) .q;
P.still(\clear, timecode: 0.seconds, syl:6, music: { |p b e|
	 var a= e.still.( 
		wait: b.drop(1).sum + e.bNext[..1].sum,
		text: ["to see","again"],
	).sequenceText2(
			b.parse([13]), [ 
			["heart","pumping"],
			],
	);
	{
		a.window.alwaysOnTop_(true)
	}.defer(b.drop(1).drop(-1).sum)
});
P.still(\moreKirk, timecode: 1341.0.seconds,syl:11, music: { |p b e|
	 e.still.( 
		wait: b.drop(1).sum,
		fadeIn: b.drop(1).sum,
		fade: e.bNext.sum,
		text: ["",""],
	)
});
P.synthV(role: \kirkLungs, take: \lead,
	filter: (
		midinote: _ -12,
		dur: Song.durs[\see].list.parse([1,1,1,1,1,1,1,1,1,1,3, 7,1])
	), 
	take:\lead, params: {|p b key| [
	lyrics: "r r r r r r r to see again +  r  r",
	phonemes: (key == \genbu).if{ ["","","","","","","","t u","s i","a","g e n"] },
	pitchTake: 2,
	pitchExpression:1.3
] }, music:{|p b e|
	{
		e.playbuf
		// => p.synthVTracks.at(e.key).() 
		=> {|i| i + FreqShift.ar(i,LFNoise2.ar(1) * 10) * -3.dbamp}
		=> {|i| CombN.ar(i,0.3,0.3,4) /5.5 + i}
		=> p.early.(_,pan:0.0)
		* -4.dbamp
	}.play
});
P.synthV(role:\kirkLungs, take: \continuation,
	pbind: Song.enlarge(2),
	filter: (
		midinote: _ - 12,
		dur: Song.durs[\see].list ++ Song.durs[Song.section(\see)+1].list[0..1] => _.flat * [1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,0.3]
	), 
	params: {|p b k| [
	lyrics: "r r r r r r r r r r r r r r r r r r r r heart pumping +",
	phonemes: (k == \genbu).if { ["","","","","","","","","","","","","","","","","","","","","h a r t","p a m ","p i N" ] } ,
	pitchTake: 1
/* 	"pump".romaji */
] }, music:{|p b e|
	{
		e.playbuf
		// => p.synthVTracks.at(e.key).() 
		=> {|i| i + FreqShift.ar(i,LFNoise2.ar(1) * 10) * -3.dbamp}
		=> {|i| CombN.ar(i,0.3,0.3,4) /5.5 + i}
		=> p.early.(_,pan:0.0)
		* -4.dbamp
	}.play
});
P.double(role: \kirkLungs, params: {|p b| [
		
	] }, music:{|p b e|
		{
			e.playbuf
			=> p.synthVTracks.at(e.key).(pan:1)
		}//.play
});
//~eighths8=~eighths8.list.quantize(1).q;
// P(\tune8,start:\Heart,music:
// 	Song.currentSong.pbind[ \Heart ].collect({|e|(e.midinote==([2].dm('a-')[0])).if{e.midinote=\};e})
// 	=> Pset(\legato,[1!10,5,1!12].flatten=>_.q,_)=>_.trace
// );
P(\innerChordHeart,start:\Heart,syl:6,music:
	Song.currentSong.pbind[ \Heart ]
	=>Pset(\freq, [1,3].df('f',octave:4,scale:\minor), _)
	=>Pbindf(_,\instrument,\sawSynth,\amp,0.03,\legato,3,\rel,5)
	=>Pset(\out,Pwhite(0,3),_)
	//=>Pset(\dur,Song.durs[\Heart]+[0,0,0,0,0,0,0,0,0,0].q,_)
	=>_.drop(7)=>_.fin(4)
);
P(\bass,music: {|p b e|
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
				dur: "e*24".beats.warpTo( e.tempoMap.quantizeDft(0.3) ).q,
			].pm(\pulser).play
		}
);
["pumping, arteries surging with blood again. A", [13,5].dm('c') ++ [3,2,1].dm('f',scale:\minor ) ++ [3,4,5].dm('g') ++ [13,12,5, 7].dm('e')].addLine;  
Song.setTempoMap(\arteries,"ee qqqqq ex ex eqq ex ex e qqqe e qe e");
P.still(\clear,syl:1, timecode: 0.seconds, music: { |p b e|
	 var a = e.still.( 
		wait: b.drop(1) ++ e.bNext  => _.sum => _.postln,
		text: ["arteries",""]
	).sequenceText2(
			e.bAll.drop(1).parse([3,4,2]), [ 
				["surging with","blood"],
				["again...",""],
				["a half a million","years..."],
				
			],
	);
	{
		a.window.alwaysOnTop_(true)
	}.defer(0.2)
});
P.still(\yetMoreKirk,syl:7,lag:-3, timecode: 1343.3.seconds, music: { |p b e|
	 e.still.( 
		 fadeIn:b.drop(1).sum,
		 wait: b.sum,
		 fade:3,
	)
});
P.synthV(role: \kirkLungs, start:Song.section(\arteries),
	pbind: Song.enlarge(6, Song.section(\arteries)),
	filter: (midinote: _ - 12), 
	take: \lead, params: {|p b| [
		lyrics: "r r  arteries + + surging + with blood again + a half a million + years -",
		phonemes: ["","", "a r t","a r","i z","s a r", "j i N","w i s", "b l a d", "a", "g e n", "a","h a f","a", "m i r","y e n", "y i r z" ],
/* 	
"million".romaji
*/
		legato: [1, 1, 1, 1, 0.5, 1, 1, 1, 1, 1, 0.9,  1,1,1, 1, 1, 1, 1 ],
		pitchTake: 1,
		loudness: Env([4, 2, 7, 2],b.parse([5, 3, 2, 8]))
	] }, music:{|p b e |
		{
			e.playbuf
			=> p.synthVTracks.at(e.key).()
			=> {|i| i + FreqShift.ar(i,LFNoise2.ar(0.1) * 10) * -3.dbamp}
			=> {|i| CombN.ar(i,0.3,0.3,4) /5.5 + i}
			=> p.early.(_,pan:0.0)
			* -4.dbamp

		}.play
});
~quarters9=Song.parseBeats(\pumping,[1,5,2/3,2/3,2/3+2,2/3,2/3,2/3,3.5,0.5,1.5,0.5]);
~eighths9=~quarters9.stutter(2)/2=>_.quantizeWindow;
P(\pumping,start:\pumping,lag:-0.152,music:
	(width:8,release:13,instrument:'defaultPorto',attack:7,freq:[1,3,5,7,11,13,15].df('c'),dur:3)
); 
// P(\tune9,start:\pumping,music:Song.currentSong.pbind[\pumping]);
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
//Song.synful1.allNotesOff
// "/Users/michael/tank/super/808-mod.scd".load;
P(\bass,music: {|p b e|
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
			dur: "e*36".beats.warpTo( e.tempoMap.quantizeDft(0.33,3) ).q,
		].pm(\pulser).play
});
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
			out: Effect.bus( {|i| 
				HPF.ar(i.tanh,1300)
			},  ),
			amp:0.3,
		].p
		//		<> ~parent.value
		=>_.trace => _.play
	}
);
["half a million years -- ", [4,1,3,4,5,4.5].dm('b') ].addLine; 
~quarters10=Song.parseBeats(\million,[0.5,0.5,0.5,0.5,3/2, 1/2]);
~eighths10=( ~quarters10.stutter(2).quantizeWindow(0.2,2)/2 ); 
P(\bass,music: {|b p e|
		[
			flag:[0.1,0.2],
			//effect:Effect({|i| i*Line.kr(1,0,3)},inputChannels:2).bus.index,
			//	out:Pkey(\effect)+[0,1],
			// out:[0,1],
			freq:  {
				var c=List.new;
				[5,8].pairsDo({|a b|  c.add(a!b) });
				c.flatten.asArray.df(octave:1)
				.q
			}.value ,
			freq: 5.df(\c,1),
			decay:0.70,
			out:[0,1],
			// out: Effect.bus({|i| i * EnvGen.cutoff(0.02,8,curve:-4)   }, inputChannels:2, time: 2),
			pulse:1,
			// fadeout:[1,0,0,0,0,0].q,
			amp:0.20 * -6.dbamp,
			time:3,
			//fade:9,
			dur: ~eighths10.q,
		].pm(\pulser).play
		// =>_.fin(9)
		=>_.play;
	}

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
["(boom boom boom boom )To be again.", [11,11,7,7,15,15,13,13].dm('c#',octave:4) ].addLine;
Song.setTempoMap('To be',"q q q e e qqqe e q");
P.still(\kirk, timecode: 1350.9.seconds, music: { |p b e|
	 e.still.( 
		wait: b.sum,
		fadeIn: 2,
		text: ["",""],
	).sequenceText2(
			b.parse([4]), [ 
			["to be","again"],
			],
	)
});
P.synthV(role: \kirkLungs, take:\lead, params: {|p b| [
	lyrics: "r r r r to be again +",
	legato: [1,1,1,1,  1, 0.66, 1, 0.9],
	pitchTake: 1,
	phonemes: ["","","","","t u","b i","a","g e n"],
	vocalMode: \Mellow,
	paramTension: -0.2,
	paramLoudness: 0
] }, music:{|p b e|
	{
		e.playbuf
		=> p.synthVTracks.at(e.key).(pan:1)
		// * Line.kr(0.7,0.1,b.sum+2)
		* Line.kr(1.2,0.3,b.sum+2)
	}.play
});
// P(\tune11,start:'To be',music: Song.currentSong.pbind['To be']);
P(\bass11,start:'To be',music:{|p b e|
	[
		freq: [11,7,6,5,4,3,2].df('d-',octave:2).stutter(2).q,
		dur: "q q q q q q q q e".asBeats.warpTo( e.tempoMap ).q
	].pp 
});
P(\finalChord,syl:6, music: { |p b e|
	(
		instrument:\wash,
		freq: [1,3, 5,7].df('f#',4),
		amp: 0.02

	).play
});
//	["Your captain has an excellent body, Doctor McCoy. I ","r"].addLine; 
//	["compliment you both on the condition in which you maintained it. ","r",].addLine;
///*SPOCK:*/[" What are your plans for it? Can you exchange places again when you wish? ","r",].addLine; 
["what are your plans for Kirks body? ","4 5 6 11 7 6 13 12 7.5 4".dm(\d,\minor)].addLine;
P.still(\spock, timecode: 1421.seconds, music: { |p b e|
	 e.still.( 
		wait: b.sum,
		text: ["what are","your plans"],
		fade: e.bNext.sum - 1
	).sequenceText2(
			b.parse([4, 6]), [ 
			["for Kirk's","body, Sargon"],
			["",""]
			],
	)
});
P.synthV(role: \spock, take: \lead, params: {|p b| [
	lyrics: "what are your plans for Kirks body + sargon +",
	filter: (midinote: _ - 12), 
	legato: [1, 1, 1, 0.8, 1, 1, 1, 0.7,1, 0.7 ],
	lag: [0.1, 0.05,0,0,0,0,0,0,0,0,],
	pitchTake: 1
] }, music:{|p b e|
	{
		e.playbuf
		// => p.synthVTracks.at(e.key).()
		=> p.verb.(_,distance: 2,mix:0.1)
		* -12.dbamp
	}.play

});
P.tune(_ <> [instrument: \stringyy, mix: 0,amp:0.05, out:3 ].pm);
P(\chords, music: { |p b e|
	MegaBind(
		[\r, [3, 7, 12].df(\c,\mixolydian), [4, 7,1.5, 14, 16].df('a-',4),[4, 7, 1.5, 14, 15.5].df('a-',4)].flop ,
		b.parse([3,3, 1, 4]),
		[],
		{|i|  SinOsc.ar(
			i.freqSeq * Gendy2.arWidth(
				ampdist:1,
				durdist:1,
				adparam:1.0,
				ddparam:1.0,
				freq:[140, 4, 222, 215],
				width:1.015,
				ampscale:0.5,
				durscale:0.5,
				initCPs:12,
				knum:nil,
				a:1.17,
				c:0.31,
				mul:1.0,
				add:0.0
			).linlin(0,1,0.9,1.1)
		)
		* -38.dbamp
		* Env.perc(releaseTime:5).kr(0,gate:i.trigSeq) 
		* Env.asr().kr(2, i.gateSeq)
	},
		{|i|  Mix.ar(i)}
	).play
});
[" Can you exchange places again when you wish? ","1 2 3 5 4".dm(\f,\whole) ++ "1 2 5 4 3  4.5 ".dm('a-',\minor)].addLine; 
P.synthV(role: \spock, take: \lead, params: {|p b| [
	lyrics: " Can you exchange + places + again + when you wish? ",
	filter: (midinote: _ - 12), 
	legato: [1, 0.66, 1, 1, 1, 1, 1, 1, 1, 1, 1, ],
	lag: [0.06, 0,0,0,0,0,0,0,0,0,0,],
	pitchTake: 1
] }, music:{|p b e|
	{
		e.playbuf
		// => p.synthVTracks.at(e.key).()
		=> p.verb.(_,distance: 2,mix:0.1)
		* -12.dbamp
	}.play

});
P.tune(_ <> [instrument: \visual_pad, amp: 0.2, out: 2].pm);
P.still(\clear, timecode: 1421.seconds, music: { |p b e|
	 e.still.( 
		wait: b.sum,
		text: ["can you exchange places","again when you wish"],
	)
});
P(\chords, music: { |p b e|
	MegaBind(
			[
				[1, 3, \r].df(\f,\whole),
				[1, 3, 5].df(\f,\whole),
				[1, 3, \r].df('a-', \minor),
				[1, 2, \r].df('a-', \minor),
				[1, 2, 5].df('a-', \minor),
				[\_, 3, \_].df('a-',\minor),
				[1, 3, 4.5].df('a-', \minor)
			].flop
		,
		b.parse([3, 1, 2, 1, 1,2,1]),
		[],
		{|i|  SinOsc.ar(
			i.freqSeq * Gendy2.arWidth(
				ampdist:1,
				durdist:1,
				adparam:1.0,
				ddparam:1.0,
				freq:[14, 4, 222, 215],
				width:1.015,
				ampscale:0.5,
				durscale:0.5,
				initCPs:12,
				knum:nil,
				a:1.17,
				c:0.31,
			).linlin(0,1,0.95,1.05)
		)
		* -38.dbamp
		* Env.perc(releaseTime:5).kr(0,gate:i.trigSeq) 
		* Env.asr().kr(0, i.gateSeq)
	},
		{|i|  Line.kr(0,0,b.sum + 1,doneAction:2);Mix.ar(i)}
	).play
});
P(\bass, music: { |p b e|
	[
		freq: [2.5, 1, -7, -5, -6, 2, 5].df(\d,[3,4]).q,
		dur: b.parse([3, 1, 1, 1, 1, 3, 1]).q,
		instrument: \sawSynthSustain,
		pulse: 0.5
	].ppm
});
// /*KIRK:*/[" Have no fear. Your captain is quite unharmed, although his mind generates insufficient energy for him to speak from there as I do.","r",].addLine; 
/*KIRK:*/[" Have no fear. Your captain is (boom) quite unharmed,","11 5 6 4 3 2 1 -7 5 2 2.5".dm(\c)].addLine; 
P.synthV(role: \sargon, take: \lead, params: {|p b| [
	filter: (midinote: _ - 12), 
	lyrics: "have no fear, your captain + is r quite unharmed +",
phonemes: [ "h a v", "n o w", "f i r", "y o r", "k a p"," t e n", "i z", "","k w a e i t","a n" , "h a r m d" ],
	pitchTake: 1,
	legato: [1, 1, 0.7, 1, 1, 1, 1, 1, 1, 1, 0.7  ],
] }, music:{|p b e|
	{
		e.playbuf
		// => p.synthVTracks.at(e.key).()
		=> {|i| CombN.ar(i,0.3,0.3,4) /5.5 + i}
		=> p.early.(_,pan:0.5)
		* -6.dbamp
	}.play

});
P(\readings, syl:10, music: { |p b e|
	{
		Gendy4.ar(initCPs:[5,2,8])
		/10
		* Env.triangle(b.drop(1).sum + e.bNext.sum).kr(2,gate:1)
	}.play
});
P(\bassBend, syl:7, music: { |p b e|
	[
		freq: [7, 6.5].df(\c).q,
		instrument: \wash,
		dur: b.drop(1).parse([1, 3]).q,
		freqLag: b.drop(1).sum  
	].ppm
});
P(\bassline, music: { |p b e|
	[
		freq: "1 3 4 5 -7 -6.5".df(\c,[3,4]).q,
		dur: b.parse([1, 1, 2, 3, 3, 1]).q,
		instrument: \stringyy,mix:0,amp:0.15
	].ppm
});
P.still(\sargonAnswer, timecode: 1426.seconds, music: { |p b e|
	 e.still.( 
		wait: b.sum,
		text: ["have no fear",""],
	).sequenceText2(
			b.parse([3, 4, 1]), [ 
			["your captain","is"],
			["",""],
			["quite","unharmed"]
			],
	)
});
/*SPOCK:*/[" Doctor? ","d4 a-3",].addLine; 
{
P(\connector, music: { |p b e|
	[
		instrument: \harp,
		freq: [1,2,3, 5 ].df(\d,[5,3,1]).q,
		dur: [b.sum] ++ e.bNext.parse([5, 2]) + ([0,0,  p.durs[e.start+2].list[0..2].sum  ]) ++ 1  => _.postln=>_.q,
		out: Effect.bus({|i| i => RLPF.ar(_, Line.kr(133,277,b.sum + e.bNext.sum) )
		=> {|i| i/100 + Monitors.az(i, Line.kr(0,4,b.sum + e.bNext.sum)) 
	}		},time: 8),
		amp:0.03
	].pp
});
P.synthV(role: \spock, take: \lead, params: {|p b| [
	lyrics: "Doctor",
	pitchTake: 1
] }, music:{|p b e|
	{
		e.playbuf
		=> p.synthVTracks.at(e.key).()
	}.play

});
P.still(\wide, timecode: 1435.8.seconds, music: { |p b e|
	e.still.( 
		wait: b.sum,
		text: ["Doctor?",""],
	)
});
P.tune('Doctor?');
P(\tremDoctor,start:'Doctor?',music:
	(instrument:\stringyy,
		freq:[1,11,1,11].df('d',octave:3),
		width:[6,20,5,100],
		mix:0,amp: 0.08,
		out:(0..3),
		attack:0
	)
);
}.();
/*MULHALL:*/[" Yes, I have the same readings. ","e5 b-4 c5 d b-4 f#5 d"].addLine; 
P.still(\mulhall, timecode: 1438.seconds, music: { |p b e|
	 e.still.( 
		wait: b.sum,
		text: ["yes I have","the same readings"],
	)
});
P.synthV(role: \mulhall, take: \lead,
	filter: (midinote: _ - 12), 
	params: {|p b| [
	lyrics: " Yes, I have the same readings +",
	pitchTake: 1
] }, music:{|p b e|
	{
		e.playbuf
		=> p.synthVTracks.at(e.key).()
	}.play
});
P( \foo , music:{|p b e|
		[
			instrument:\stringyy,
			freq: ([0,1] +.t [1,11,1,11] ) => _.df('e',octave:3) *  midiratio(0) => _.postln => _.q,
			width:[6,20,5,100],
			out:(0..3).scramble,
			attack:0.1,
			dur: b.parse([5,2]).q
		].pp;
		// [
		// 	instrument:\harp,
		// 	freq: [ 1,2 ].df(\e,4).q,
		// 	dur: b.parse([5,2]).q,
		// 	out: Pwhite(0,1,inf)
		// ].pp
	}
);
// P.tune('the same readings');
//Song.durs[ 'Doctor?' ].list

/*MCCOY:*/[" Are you aware of what's happening to his body? ",[7,11,5,13,12,11,7,11,5, 7,11,14,13].dm('f',scale:\mixolydian),[ 0.295, 0.347, 0.315, 0.566, 0.3, 0.322, 0.291, 0.313, 0.6065, 0.278, 0.361, 0.62, 0.633 ]].addLine; 
Song.setTempoMap(\aware,"e e e q e e e e q e e q q");
P(\strings, music: { |p b e|
	[
		instrument: \stringyy,
		freq: [\r] ++ [-7, 3, 6].df(\f, \mixolydian).bubble => _.q,
		out: Effect.bus({|i| i  
			* (TDuty.ar("x x x x x x x x x x x x x x x x x x x x x x x x x x x x x".asBeats.warpTo(e.tempoMap).dq(inf),0) => Decay.ar(_,0.2) )
			* 2
		},out:3),
		dur: b.parse([3,10]).q
	].pp
});
P(\tremReadings,syl:2,music: {|p b e|
		[
			instrument:\stringyy,
			freq: ([1] +.t [1,13,1,11] ) => _.df('e-',octave:4) * midiratio( -2 ) => _.q,
			width:[6,20,5,100],
			out:(0..3).scramble,
			attack:0.1,
			dur:Song.parse('same readings',[5,2]).q,
			mix:0
		].pp;
		// (
		// 	instrument:\harp,
		// 	freq: 1.df(\a,4)
		// ).play
	}
);
P.still(\mccoy, timecode: 1439.8.seconds, music: { |p b e|
	 e.still.( 
		wait: b.sum,
		text: ["are you aware","of what's happening"],
	).sequenceText2(
			b.parse([9]), [ 
			["to his","body"],
			],
	)
});
( Trek.presets.put(\mccoy,\an, [
	vocalMode: \Power,
	paramGender: 0.15,
	paramToneShift: 150,
	paramTension: -0.1
]
	);
	Trek.presets.put(\mccoy,\jun,[

	vocalMode: \Soul,
	paramGender: 0.25,
	paramToneShift: 150,
	paramTension: 0.1
	]);
	// Trek.cast.mccoy = \an;
	// Trek.cast.mccoy = \jun;
	Trek.presets.put(\mccoy,\mo,[paramGender:0.25]);
	Trek.cast.mccoy = \mo;
);
P.synthVs(role: \mccoy, take:[\lead, \dbl], params: {|p b| [
	lyrics: " Are you aware + of what's happening + + to his body? + ",
	filter: (midinote: _ - 12), 
	pitchTake: [ 1,3 ]
] }, music:
{|p b e|
	{
		e.playbuf
		// => p.synthVTracks.at(e.key).()
		=> HPF.ar(_,120)
		=> BPF.ar(_,1900,2)
		* -5.dbamp
		=> Pan2.ar(_,0)
	}.play
});
P.synthV(\default, take: \lead, params: {|p b| [
		
	legato: [1, 1, 1, 0.8, 1, 1, 1, 1, 0.8, 1, 1, 1, 1, ],
	lyrics: " Are you aware + of what's happening + + to his body? + ",
	] }, music:{|p b e|
		{
			e.playbuf
			// => Pan2.ar(_,0.5)
			* -15.dbamp
			=> FreeVerb.ar(_,0.1,0.9)
			=> SineShaper.ar(_,0.03)
			=> DelayN.ar(_, 0.05, [0,0.02])
			* [0.2,0.8]
			=> _.tanh

			// => p.synthVTracks.at(e.key).()
		}.play
});
P(\tremAware,start:'aware',music: {|p b e|
		(instrument:\stringyy,
			freq:[1,11,1,11].df('d',octave:3),
			width:[6,20,5,100],
			out:(0..3).rotate,
			attack:0
		)
	}
);
//	Song.durs[14]=[ 0.295, 0.347, 0.315, 0.566, 0.3, 0.322, 0.291, 0.313, 1.213/2, 0.278, 0.361, 0.62, 0.633, /*3.236*/ ].q;
P(\accent14,start:\aware,syl:2,music:
	{
		(
			instrument:\cymbal_808,
			amp:0.35,
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
P(\kick14,music: {|p b e|
		[
			instrument:\bd_808, decay: 20,
			dur: Song.parse(\aware,[3,1,2,2,1/2,1/2,2,1,1],).q ,
			dur: "qe q q q e e q q q q".asBeats.warpTo( e.tempoMap.quantizeDft(0.3) ).q,
			amp:0.15 * 4.dbamp,
			note:[\].q++[1].q(inf),
		].pp;
		[
			instrument:\hat_808,
			// dur:Song.parse(\aware,[1,1,1,1/2,1/2,1,1,1,1,1/2,1/2,1,1,1/2,1/2,1/2,1/2]).q.quantize(0.8),
			dur: "e e e e e e e e e e e e e e e e e ".asBeats.warpTo( e.tempoMap.quantizeDft(0.2) ).q,
			amp:[0.05,0.1].q(inf)  * 0.dbamp,
			pan:-1,
			out:Effect.bus( { |i| Phaser2.ar(i)[0] }, out: 0 ),
			// out:Pkey(\effect),
			note:[\].q(3)++[1].q(inf),
		].pp
	
}
);
["Heart action (almost) doubled, ",[13,12,11,7,11,7,11,16,15].dm('e',scale:\mixolydian)].addLine; 
Song.setTempoMap(\doubled,"q e e e e e e eee e");
P.still(\clear, timecode: 0.seconds, music: { |p b e|
	 e.still.( 
		wait: b.sum,
		text: ["heart action","almost..."],
	).sequenceText2(
			b.parse([5, 2]), [ 
			["",""],
			["doubled",""]
			],
	)
});
//Song.durs.put(14,[ 0.545, 0.304, 0.31, 0.302, 0.327, 0.311, 0.332, 0.555, 0.429, 2.165 ].q);
P.synthVs(role: \mccoy, take:[\lead, \double],
	filter: [(midinote: _ - 24 ),(midinote: _ - 12)], 
	params: {|p b| [
	lyrics: "Heart action + almost + r r doubled, + ",
	pitchTake: [1, 3]
] }, music:{|p b e|
	{
		e.playbuf
		=> HPF.ar(_,120)
		=> BPF.ar(_,1900,2)
		* -5.dbamp
		=> Pan2.ar(_,0)
		// => p.synthVTracks.at(e.key).()
	}.play
});
// P(\tune15,start:\doubled,music: Song.currentSong.pbind[\doubled]);
P(\bass15,start:\doubled,music:
	Song.currentSong.pbind[\doubled]
	<>
	[
		amp:0.3,
		lag:Pwhite(-0.005,0.005),
		instrument: \sawSynthSustain,
		// legato: [9,10,9,9,9,9,9,10,9].q /10
		rel: 0.3, pulse:0.8
	].pm
=>Pmul(\freq,1/8,_);
);
P(\kick15,music:{|p b e|
	var q = 0.3;
	[
		instrument:\bd_808, decay: 20,
		// dur: Song.parse(\doubled,[1,2,2,2,2/3,[1/3,1]]).q
		dur: "q q q q q q".asBeats.warpTo( e.tempoMap.quantizeDft(q / 2) ).q
		,
		//		note:[\].q++[1].q(inf),
		out:3,
		amp:0.15
	].pp;
	[
		instrument:\hat_808,
		// dur:Song.parse(\aware,[1,1,1,1/2,1/2,1,1,1,1,1/2,1/2,1,1,1/2,1/2,1/2,1/2]).q.quantize(q),
		dur: "e e e e e e e e e e e e e e e e e ".asBeats.warpTo( e.tempoMap.quantizeDft(q) ).q,
		amp:[0.05,0.1].q(inf) * 0.dbamp,
		pan:-1,
		out:Effect.bus( { |i| Phaser2.ar(i)[0] }, out: 0 ),
		// out:Pkey(\effect),
		// note:[\].q(3)++[1].q(inf),
	].pp
}
);
["temperature a hundred and four degrees? ",[13,12,11,7,11,12,7,13,13,16].dm('f#',scale:\mixolydian)].addLine;
P.still(\clear, timecode: 0.seconds, music: { |p b e|
	 e.still.( 
		wait: b.sum,
		text: ["temperature 104","degrees"],
	)
});
// P.tune();
Song.setTempoMap(\hundred,"e e e e Q Q Q qe e qe");
P.synthVs(role: \mccoy, take: [\lead, \dbl],
	filter: (midinote: _ - 12), 
	params: {|p b| [
	lyrics: "temperature + + a hundred +  and four degrees? +  ",
	pitchTake: [1,3]
] }, music:{|p b e|
	{
		e.playbuf
		// => p.synthVTracks.at(e.key).()
		=> HPF.ar(_,120)
		=> BPF.ar(_,1900,2)
		* -5.dbamp
		=> Pan2.ar(_,0)
	}.play
});
P.synthV(\default, params: {|p b| [
	lyrics: "temperature + + a hundred + + and four degrees? +  ",
	] }, music:{|p b e|
		{
			e.playbuf
			=> p.synthVTracks.at(e.key).()
		}.play
});
P(\bassline, music: { |p b e|
	[
		freq: [1,11,7,11,7,11,5, 5, 3].df('f#',3,\mixolydian).q,
		dur: "e e e e e e eqe q q".beats.warpTo(e.tempoMap).q ,
		instrument: \sawSynth
	].pp
});
P(\kick, music: { |p b e|
	[
		instrument: \kick_gentle,
		dur: "q q q q q q q e".beats.warpTo(e.tempoMap).q
	].pp;
	[
		instrument:\hat_808,
		// dur:Song.parse(\aware,[1,1,1,1/2,1/2,1,1,1,1,1/2,1/2,1,1,1/2,1/2,1/2,1/2]).q.quantize(q),
		dur: "e e e e e e e e e e e e e e e  ".asBeats.warpTo( e.tempoMap.quantizeDft(0.3) ).q,
		amp:[0.1, 0.05].q(inf) * 0.dbamp,
		pan:-1,
		out:Effect.bus( { |i| Phaser2.ar(i)[0] }, out: 0 ),
		// out:Pkey(\effect),
		// note:[\].q(3)++[1].q(inf),
	].pp
});
P(\tune16,start:\temperature,music:Song.currentSong.pbind[\temperature]

);
/*MULHALL:*/[" He'll die if you don't leave his body. Soon! ", [15,21,15,13,12,11, 7.5,12,11, 11.5].dm('a-',scale:\minor) ].addLine; 
P(\traps, music: { |p b e|
	( 
		instrument: \cymbalsDS, amp: 0.01, out: 2
	).play; 
	(

		instrument:\hat_808,
		amp: 0.15,
		// dur:Song.parse(\aware,[1,1,1,1/2,1/2,1,1,1,1,1/2,1/2,1,1,1/2,1/2,1/2,1/2]).q.quantize(q),
		out:Effect.bus( { |i| Phaser2.ar(i)[0] }, out: 0 ),
	).play
});

{
P.still(\mulhallWide, timecode: 1446.0.seconds, music: { |p b e|
	e.still.( 
		wait: b.sum,
		text: ["he'll die if you don't","leave his body"],
	).sequenceText2(
			b.parse([9]), [ 
			["soon!",""],
			],
	)
});
	P.synthV(role: \mulhall, start:Song.section(\Soon),
	filter: (midinote: _ - 24), 
	take: \lead, params: {|p b| [
		lyrics: " He'll die if you don't leave his body + Soon! ",
		pitchTake: 1
	] }, music:{|p b e|
		{
			e.playbuf
			=> p.synthVTracks.at(e.key).(0.05)
		}.play
	});
	P(\dieChord,start:'die if',syl:0,music:
		{|o d| (
			instrument:\stringyy,
			freq:[1,11].df('a-',octave:2),
			attack:0.001,
			amp:0.3,
			mix: 0.1,
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
}.();
// P(\tuneSoon,start:\Soon,music: Song.currentSong.pbind[\Soon]);
P(\chordSoon,start:\Soon,syl:8,music: { |p b e|
		(
			freq:
			[2,4.5,6.5,11.5].df('a-',octave:3,),
			strum: 0.04,
			instrument:\sawSynthSustain,
			dur:b.drop(1).sum,
			amp:0.03,
			// rel:9
		).play
	}
);
/*SPOCK:*/[" What is it you want of us? ",[11,11.5,7,11.5,11,5,3].dm('e-',scale:\mixolydian)].addLine; 
P(\chords, music: { |p b e|
	{
		var freq = [[1, 3, 5], [1.5, 3, 5], [1, 3, 5]].df('e-').flop.collect({|i| i.dq.demand(b.parse([2,2,3]))});
		SinOsc.ar(freq * Gendy1.ar(minfreq: 5,maxfreq:13).range(0.98,1.02), 0,0.05)
		=> Splay.ar(_)
		=> CrossoverDistortion.ar(_, smooth: 0.998)
		/2
		* EnvGen.cutoff(b.drop(-2).sum , 2)
		=> Out.ar(2, _)
	}.play
});
P.synthV(role: \spock, take:\lead,
	filter: (
		midinote: _ - 12,
		dur: _ * [1, 1, 1, 1, 1, 1, 0.3]
	), 
	params: {|p b| [
	lyrics: " What is it you want of us? ",
	pitchTake: 1,
	lag: 0.05 ! 7,
	// paramGender: 0.3,
	// paramToneShift: 181,
	paramBreathiness: 0.28,
	paramTension: 0.5,
	vocalMode: \Rough

] }, music:{|p b e|
	{
		e.playbuf
		// => p.synthVTracks.at(e.key).()
		=> p.verb.(_,mix:0.0, pan:0.1)
		* -10.dbamp
	}.play
});
P.still(\mediumShot, timecode: 1448.seconds, music: { |p b e|
		 e.still.( 
			wait: b.drop(-1).sum ,
			fade: b.last,
			text: ["what is it you","want of us?"],
		).sequenceText2(
				b.drop(-1) ++ (b.last * 0.3) => _.sum => _.bubble, [ 
				["",""],
				],
		)
});
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
/*KIRK:*/[" In the ne-- xt room, there are /*other*/ two receptacles. ", [1,2, 3,2 ,2, 2,3, 4,3,3,2,1, ].dm(\a) ].addLine;
P.still(\kirkAndOrb, timecode: 1453.4.seconds, music: { |p b e|
	 e.still.( 
		wait: b.sum,
		text: ["in the","next room"],
		fade: 3
	).sequenceText([
		b.parse([5]).unbubble, ["there are","two receptacles"],
		b.parse([5,7])[1],["",""]
	])
});
P.synthV(\genbu, take:\lead,
	filter: (midinote: _ - 12), 
	params: {|p b key| [
	lyrics: " In the next - room, there are two receptacles. + + + ",
	legato: [1, 1, 1, 1, 0.8, 1, 1, 1, 1, 1, 1, 1, ],
	phonemes: (key == \genbu).if{ ["","z a","n e k s t","","r u m","z e r","a r","","r i","s e p","t a k", "r u z"] },
	pitchTake: 1
] }, music:{|p b e|
	{
		e.playbuf
		=> p.synthVTracks.at(e.key).()
	}.play
});
P.tune('two receptacles',{|i|Pbindf(i,\amp,0.15,\instrument,\stringyy)});
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
	[
		dur:  ~receptaclesQuarters * [1,[1/2,1/2]]  
		=> _.flatten => _.q ,
		freq: [\].q
		++ [ 1,5,13 ].df(\a,octave:3).q
		++ [ 1,5,13 ].df('a-',scale:\minor,octave:3).q
		++[ 1,5,13 ].df('b',scale:\minor,octave:3).q
		++ [ 1,5,13 ].df(\a,octave:3).q
		,
		legato:[\].q++[3,2,1].q(inf),
		out:[1, 2, 3].q(5),
		instrument:\harpGendy, amp:0.02, modWidth:0.01,gendyfreq:5,coef:0.5
	].pp;
}
);
P(\stillReceptacles,start:'two receptacles',music:
	{ |p b|
		//Still(~stills,'next room',5,b.sum-5,nil,["in tne next room...",""]).add(14*60+51).play
	}
);

["(boom) The other two of us that survived. ", [6,6,14,15,13,12,11,13,12.5,12].dm(\a,octave:4) ].addLine; 
P.still(\clear,syl:0, timecode: 0.seconds, music: { |p b e|
	 e.still.( 
		wait: b.sum,
		text: ["the other two","of us that"],
	).sequenceText([
		b.drop(1).parse([7]).unbubble,["survived", ""]
	])
});
P.synthV(\genbu, take: \lead,
	filter: (midinote: _ - 12), 
	params: {|p b key| [
	lyrics: "r the other + two of us that survived +",
	phonemes: (key == \genbu).if{ ["","z i", "a"," z a", "t u "," a v", "a s", "z a t", "s a", "v a i vy d" ] },
	legato: [1, 1, 1, 1, 1, 1, 0.9, 1, 1, 0.8 ],
	pitchTake: 1
] }, music:{|p b e|
	{
		e.playbuf
		=> p.synthVTracks.at(e.key).()
	}.play
});
P.tune('that survived',{|i|Pbindf(i,\amp,0.25,\instrument,\stringyy).drop(1)},syl:0);
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
P.still(\mulhall, timecode: 1501.8.seconds, music: { |p b e|
	 e.still.( 
		wait: b.sum,
		text: ["",""],
		text: ["you","Dr. Ann Mulhall"],
	)
});
P.synthV(\genbu,pbind: Song.enlarge(5), take: \lead,
	filter: (midinote: _ - 12), 
	params: {|p b key| [
	lyrics: "you doctor + ann - mulhall + and you - mister + spock",
	lag: [0.1, 0,0,0,0,0,0,0,0,0,0,0,0],
	legato: [1, 1, 1, 1, 1, 1, 0.9, 1, 1, 1, 1, 1, 1, ],
	phonemes: (key == \genbu).if{ ["y u","d o k k","t a","a n n","","m a l","h o l", "a n dd","y u","","m i sy ","t a","s p o kk"] },
	pitchTake: 1
] }, music:{|p b e|
	{
		e.playbuf
		=> p.synthVTracks.at(e.key).()
	}.play
});
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
			Song.synful1.expression(127,0);
			Song.synful1.setOut(verb);
			(freq:[1,11].df('c',scale:\minor,octave:3),amp:[0.7,0.32],width:[5,10],instrument:\stringyy,dur:b.sum).play;
			(dur:b.sum,type:\vst_midi,vst:Song.synful1.controller,strum:0.04,instrument:\tremoloSwell,midinote:[1,3,5,11].dm(\c,scale:\minor,octave:4)).play;
			b.sum.postln;
		}
);
	P.tune('A-- nn');
	["you --, Mister Spock, ",[11,7,6,5,7].dm('c',octave: 5,scale:\minor)].addLine;
P.still(\spock, timecode: 1505.21.seconds, music: { |p b e|
		 e.still.( 
			wait: b.sum,
			text: ["you","Mister Spock"],
		)
});
	P.tune('Mister Spock');
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
				var synful=topEnvironment.use{Song.synful1};
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
P.still(\clear, timecode: 0.seconds, music: { |p b e|
		 e.still.( 
			wait: b.sum,
			text: ["we need","your bodies also"],
		)
});
	P.tune('your bodies also',{|i|Ppar([i,i=>Pbindf(_,\amp,0.3,\instrument,\stringyy)=>Pmul(\freq,0.5,_)])});
P.synthV(\genbu, take: \lead,
		filter: (midinote: _ - 12), 
		params: {|p b key| [
		lyrics: "we need your bodies + also +",
		phonemes: (key == \genbu).if{ ["u i","n i d","y o r","b a","d i s", "o ry", "s o"] },
		pitchTake: 1
	] }, music:{|p b e|
		{
			e.playbuf
			=> p.synthVTracks.at(e.key).()
		}.play
});
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
P.still(\clear, timecode: 0.seconds, music: { |p b e|
	 e.still.( 
		wait: b.sum,
		text: ["we need","Captain Kirk"],
	).sequenceText([
		b.parse([5]).unbubble, ["and you"," so that we may live"],
		b.parse([5,7])[1], ["again"]
	])
});
P.synthV(\genbu, take: \lead,start:Song.section('live again'),
filter: (midinote: _ - 12), 
params: {|p b key| [
	lyrics: "we need captain + kirk and you so that we may live again +",
	phonemes: (key == \genbu).if{["u i","n i d", "ky a p","t e n", "k a r k", "a n d","y u","s o","z a t","u i","m e i","l i v","a","g e n"]},
	pitchTake: 1
] }, music:{|p b e|
	{
		e.playbuf
		=> p.synthVTracks.at(e.key).()
	}.play
});
P.tune('live again');

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
["transition","r r",[1, 3]].addLine;

P.still(\walking,syl:0, timecode: 1626.0.seconds, music: { |p b e|
	 e.still.( 
		wait: b.sum + 3,
		fade: 4,
		fadeIn: 2,
		text: [""],
	) 
});
P(\chord, syl:0, music: { |p b e|
	(
		instrument: [\stringyy, \wash ],
		att: 3, rel:4,
		freq: [1, 4, 5, 11, 13, 15].df(\g, \whole),
		amp:0.07, out:(0..4)
	).play
});
)
