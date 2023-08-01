( s.waitForBoot{
Song(\laboratory,[]).current;
Require("boilerplate.scd");
Song.synthVTracks = EventWithDefault.new(
	\default, {
		{|i| Pan2.ar(i,0) /4}
	},
	\aiko, {
		{|i| Pan2.ar(i,0) /3}
	}
);
[ "/*[Laboratory]*/","1".dm(),[1] ].addLine;
P.still(\plasticPerson, timecode: 4150.seconds, music: { |p b e|
	 e.still.( 
		wait: 2.381 + 1,
		text: ["",""],
		fade:3
	)
});
P(\noise, music: { |p b e|
	{
		WhiteNoise.ar(0.1)
		// => BPF.ar(_, Gendy1.kr(minfreq:[ 1 , 1.55],maxFreq:2).range(400,800))
		/10
		=> Ringz.ar(_, 40 + Gendy1.kr(minfreq:[ 0.1, 10 ],maxfreq:40) * 10 ,0.1)
		* Env([0,1],3.381).kr(2)
		/19
	}.play
});
// [ "/*(There is a shiny plastic person on the table now.) */","r" ].addLine;
[ "/*MULHALL:*/ Why pretend to work on that thing, Henoch? ","1 2 3 5 6 -5 5 3 7 -6 6 4".dm(\c,\mixolydian) ].addLine;
Song.setTempoMap(\pretend,"E E E E ee E E E  ee E E E ");
P(\cymbal,syl: 3, music: { |p b e|
	(
		instrument: \cymbalsDS,amp:0.02,out: 3.rand
	).play
});
P(\tamb, music: { |p b e|
	{
	var levels = [5,1,2,1] /5 => _.dq(inf);
	var durs =  
	1/3 !4 ++ (1/4 ! 4) 
	+ ( [1, -1] /80 => _.dup(8) ) //swing amt
	=> _.flat 
	=> _.warpTo(e.tempoMap.quantizeWindow(0.3))
	=> _.dq(2);
	var triggers = TDuty.kr( durs, 0,1,gapFirst:0 );
	var energy = EnvGen.ar( Env.linen(0, 0.00, 0.015), triggers, doneAction:0   ) 
		* Demand.kr(triggers,0,levels 
			// * 40
			// *8
		);
	Shakers.ar(3, energy:energy   , decay: 1).tanh
	
	// /5
	* 2
	=> Pan2.ar(_, 0.8)
	* EnvGen.cutoff(b.parse([4]).unbubble,3)
	=> DWGReverbC1C3.ar(_,mix:0.05)
	/6
	=> Pan2.ar(_,0.75)

}.play;
});
P.still(\thalassaClose1, timecode:
	// 4151.833.seconds, //close
	4155.666.seconds, // twoShot
	music: { |p b e|
	 e.still.( 
		wait: b.sum,
		text: ["why pretend to work","on that thing, Henoch?"],
	)
});
P.tune( _ => Pset(\amp,Pfunc({|i| (i.midinote < 1.dm(\c)).if{0}{0.1} }),_) );
P(\dyads, music: { |p b e|
	[
		freq: [\r, [4,6],[3,5],  [2,4,7],[1,4,6], [-5,5,-15] ].df(\c,\mixolydian).q,
		dur: e.bAll.parse([4, 1, 3, 1, 3, 1]).q,
		instrument: \sawSynth,
		out: Effect.bus({|i| i =>Pan2.ar(i,0.8) },)
	].pp
});
P.synthV(role: \thalassa,lag:0, take: \lead, params: {|p b| [
	lyrics: "Why pretend + to work r on that thing, r Henock +",
	pitchTake: 1,
	lag: [0.05, 0.05, 0.05, 0.05, 0.05, 0.05, 0.05, 0.05, 0.05, 0.05, 0.05, 0.05, ],
	phonemes: [ "w a :\\i"," ph r\\` i"," th e n t"," th u"," w a r\\` kh",""," A n"," t a th"," s i\\ N","","","n A kh" ] ,
	// legato: [1, 1, 1, 1, 1, 1, 1,1, 1, 1, 1, ],
] }, music:{|p b e|
	{
		e.playbuf
		=> p.synthVTracks.at(e.key).()
	}.play

});
P(\bass, music: { |p b e|
	[
		freq: [1, 2, 3, 5, 4, 3, 2,1].df(\c,3).q,
		dur: b.parse([1,1,1,1,1,3,1,3]).q,
		amp: 0.15,
		instrument: \harp,
		coef:0.8,
		legato: [1, 1, 1, 0.9, 1, 0.8,1,1 ].q,
	].ppma
});
P(\horn, music: { |p b e|
	[
		freq: [\r, 4, 5].df(\c).q,
		dur: e.bAll.parse([8,4,1]).q,
		instrument: \defaultPorto
	].ppm
});
[ "-boom- You know you never intended to leave Spock's body. ","-5 5 12 11 7 6 5 4 5 6 2 5 4 3".dm(\c) ].addLine;
P(\cymbal,syl:1, music: { |p b e|
	(instrument: \cymbalsDS, amp:0.025).play
});
P.still(\clear, timecode: 0.seconds, syl:0, music: { |p b e|
	 e.still.( 
		wait: b.sum,
		text: ["you know","you never intended"],
	).sequenceText2(
			b.drop(1).parse([8,5]), [ 
			["to leave Spock's","body"],
			],
	)
});
P(\lowBass, music: { |p b e|
	[
		instrument: \sawSynthSustain,
		att: [1.5, 0.1, 0.1, 0.1, 0.1].q,
		freq: [-15, -5, -4,-2,-1].df(\c,4).q,
		dur: b.parse([2,5,3,2,2]).q
	].pp
});
P(\chord,syl:1, music: { |p b e|
	(
		instrument: "defaultPorto",
		freq: [3,5].df(\g),
		amp: 0.2
	).play
});
P.synthV(role: \thalassa, take: \lead, params: {|p b| [
	lyrics: "r You know you never intended + + to leave Spock's body. + ",
	pitchTake: 1,
	phonemes: [ "","j u"," n @U"," j u"," n e w"," a r\\`"," i\\ n ","th e n"," t i\\ t"," th u"," l i w","s ph A kh s"," p A "," t i" ],
] }, music:{|p b e|
	{
		e.playbuf
		=> p.synthVTracks.at(e.key).()
	}.play

});
P.tune(_ <> [instrument: \sawSynthSustain,amp:0.025,out:1.rrand( 4 )].pm);
[ "/*SPOCK:*/ This is your new home, Thalassa. "," 5 3 11 6.5 7 4 3 2".dm(\f,\minor) ].addLine;
P(\innerLines, music: { |p b e|
	var outs = [1,2,3].q.asStream;
	[
		freq: [4, 1].df('e-').q,
		dur: b.parse([6,2]).q,
		instrument: \sawSynthSustain, amp: 0.05,
		out: outs.next
	].ppm;
	[
		freq: [6,7,11].df('e-').q,
		dur: b.parse([2, 2, 4]).q,
		out: outs.next
	].pp;
	[
		freq: [11,\r].df('f'),
		dur: b.parse([6,2]),
		instrument: \stringyy,
		out: outs.next
	].pp
});
P.still(\henochClose, timecode: 4158.seconds, music: { |p b e|
	 e.still.( 
		wait: b.sum,
		text: ["this is","your new home"],
	).sequenceText2(
			b.parse([5]), [ 
			["Thalassa",""],
			],
	)
});
// P.tune();
P(\bassNote, music: { |p b e|
	[
		freq: [6, 4, 1].df('e-',3).q,
		dur: b.parse([1, 5,2]).q,
		instrument: "defaultPorto.clean"

	].pp
});
P(\bassline, music: { |p b e|
	[
		freq: [\r, 3, [ -7, 11, 13, 15, 17 ]].df(\f,3,\minor).q,
		dur: b.parse([2,2,2]).q,
		instrument: \stringyy,
		amp: 0.3

	].pp
});
P(\bassNotes,syl: 5, music: { |p b e|
	[
		freq: [ 1, -7, -6.5  ].df(\f,[3,4], \minor).q,
		dur: b.drop(1).sum.bubble ++ e.bNext.parse([2,5]) => _.flat => _.q,
		out: [0,0, Effect.bus({|i| DWGReverbC1C3.ar(i,mix:0.4) },)].q
	].p.trace.play
});
P.synthVs(role: \henoch, take: [\lead, \double], params: {|p b| [
	lyrics: "this is your new home, thalassa + +",
	filter: (midinote: _ - 12), 
		legato: [1, 1, 0.8 ,1, 0.9, 1, 1, 1 ],
	pitchTake: [1, 3]
] }, music:{|p b e|
	{
		e.playbuf
		=> p.synthVTracks.at(e.key).()
	}.play

});
P(\cymbal, syl: 3, music: { |p b e|
	( instrument: \cymbalsDS, amp: 0.01 , att: 0.3).play
});
P(\line, music: { |p b e|
	[
		freq:[1, 2, 3].df(\c, \minor).q,
		dur: b.parse([2,2,2]).q,
		// instrument: \visual_pad, amp: 0.2,
		instrument: \harp, amp: 0.03,
		out:[2,3,4].q, 


	].pp
});
[ "-boom- Once occupied","-1,5 11 5 3".dm(\d)].addLine;//boom=e-flat
//new List[ 0.471, 0.471, 0.461, 0.393, 0.407 ]
// List[ 0.382, 0.483, 0.492, 0.36, 0.426 ]
// P.tune();
P(\connector, music: { |p b e|
	[
		freq: [\r, 3,  4.5].df(\d,6).q,
		dur: b.parse([2,3]) ++ e.bNext[..1].sum => _.q,
		instrument: \sawSynthSustain,lagTime:0.7, att:1,
		out: Effect.bus({|i| BRF.ar(i,1100,1/2) => HPF.ar(_,2000) => FreeVerb.ar(_,0.2,1) },)
	].ppm;
	[
		freq: [\r, 3, 2,1,-6].df(\d,6).q,
		dur: b.parse([2,1, 1, 1]) ++ e.bNext[..1].sum => _.q,
		instrument: \sawSynthSustain,lagTime:0.7, att:1,
		out: Effect.bus({|i| BRF.ar(i,900,1/2) => HPF.ar(_,2000) => FreeVerb.ar(_,0.2,1) },out:3)
		
	].ppm
});
P.still(\twoShot, timecode: 4200.2.seconds, music: { |p b e|
	 e.still.( 
		wait: b.sum + e.bNext.sum,
		text: ["",""],
		fadeIn: b[0],
		fade: e.bNext.sum
	).sequenceText2(
			e.bAll.parse([1,5,10]), [ 
				["once occupied,","I'll add"],
			["female features","and some texturing"],
			["",""]
			],
	)
});
P(\xtraNote,syl:0, music: { |p b e|
	(
		instrument: "defaultPorto",
		freq: [-5, 1].df(\d)
	).play
});
P(\roll,syl:1, music: { |p b e|
	(
		freq: [1,3,5,11].df(\d,4),
		strum: 0.08,
		coef: 0.25,
		instrument: \harp,
		decayTime: 20,
		dur: b.drop(1).sum,


		out: Effect.bus({|i| CombC.ar(i, 0.7,[ 0.65, 0.41 ]+SinOsc.ar(0.13).range(0.01,-0.01), 5) /2 + i / 10 },)
	).play;
});
P.synthVs(role: \henoch, take: [\lead, \double],
	pbind: Song.enlarge2(1),
	params: {|p b| [
	lyrics: "r once occupied + + I'll add female + features + and some - texturing  + + you",
	legato: [[1, 1, 1, 1, 0.5, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 0.7, 1  ]],
	filter: (midinote: _ - 12), 
	pitchTake: [1, 3]
] }, music:{|p b e|
	{
		e.playbuf
		=> p.synthVTracks.at(e.key).()
	}.play

});
[" I'll add female features and some texturing. ","1 3 2 1 -7 1 -6 2 3 2 1 -5".dm(\e,6) ].addLine;
// Song.durs.filter({|i| i.dropLast ++ (0.489 * 1.5)});
P(\bassline, music: { |p b e|
	[
		freq:[1,3,2,1,-7,-6,-5].df(\e,[3,4,5,6]).q,
		dur:b.parse([1,1,1,1,2,3,3]).q,
		instrument: \stringyy, amp: 0.25
	].ppm;
	[
		freq:[1,3,2,1,-7,-6,-5].df(\e,[3,4]).q,
		dur:b.parse([1,1,1,1,2,3,3]).q,
		// instrument: \stringyy, amp: 0.25
	].pp
});
[ "You no doubt want the mechanism to at least appear to be a woman. ","3 -17 4 2 -11 3".dm('a-')++"2 3 2 1 -7 1".dm(\b)++"1 4".dm(\c,6)++"-7 3 2 1 3 -7 -6".dm(\d,6) ].addLine;
P(\moreAccents,syl:11, music: { |p b e|
	[
		freq: [6.5,[4.5,12.5],7,[5,13],[13,7],[3,5]].df(\d).q,
		dur: b.drop(1).parse([1,1,1,3,1,2]).q,
		instrument:\sawSynth,amp:0.03
		// instrument: \help_oteypiano,amp:0.3
	].pp
});
P(\accents, music: { |p b e|
fork{
	var inst = Barrier.collect({
			var freq = \freq.kr(300);
			Pluck.ar(
				SinOsc.ar( Env.perc(0.001,0.2).ar(0,1).linexp(0,1,8000 ,12000),),
				1,
				freq.reciprocal, freq.reciprocal,
				5,
				coef: 0.6
			)
			*50
			=> MoogFF.ar(_,3000)
			=> _.tanh
			=> Phaser2.ar(_,rate:0.15)
			* \amp.kr(0.1)
			* EnvGen.cutoff(\length.kr(1), 2)
			// => FreeVerb.ar(_,0.2,1)
			* -8.dbamp
			=> Out.ar(\out.kr(0),_)
	}.asDefName);
	inst = inst.()[0];
		[
			freq: [4.5,\r,3,\r,1, 1, 2, 3, 4, 4.5].df('f#',[4,5]).q,
			rel:[2, 2, 2, 2, 2, 2, 2, 2].q,
			att:[2, 2, 2, 2, 2, 2, 2, 2].q/20,
			dur: b.parse([1,2,1,3, 1, 1, 1, 1, 0.75, 1]).q,
			// instrument: \sawSynthSustain, pulse: 0.7, amp: 0.04,
			instrument: inst,
			out: [2,Effect.bus({|i|DelayN.ar(i,0.1,SinOsc.ar(0.2).range(0.01,0.02)) },out: 4.rand)],
			// lag: Ptuple([0, Pwhite(0,0.04, inf)])

		].pp;
		[
			freq: [4.5,\r,3,\r,1, 1, 2, 3, 4, 4.5].df('f#',[4,5]).q,
			rel:[2, 2, 2, 2, 2, 2, 2, 2].q,
			att:[2, 2, 2, 2, 2, 2, 2, 2].q/20,
			dur: b.parse([1,2,1,3, 1, 1, 1, 1, 0.75, 1]).q,
			instrument: \sawSynthSustain, pulse: 0.7, amp: 0.04,
			// instrumet: inst,
			out: [2,Effect.bus({|i|DelayN.ar(i,0.1,SinOsc.ar(0.2).range(0.01,0.02)) },out: 4.rand)],
			// lag: Ptuple([0, Pwhite(0,0.04, inf)])

		].pp;
	}
});
P.still(\clear, timecode: 0.seconds, music: { |p b e|
	 e.still.( 
		wait: b.sum,
		text: ["you","no doubt"],
	).sequenceText2(
			b.parse([5,9,7 ]), [ 
			["want the mechanism","to at least"],
			["appear to be","a woman"]
			],
	)
});
P(\bassnotes, music: { |p b e|
	[
		freq: [\r,1, -7].df('a-',4) ++ [-7,1, 4].df(\c) ++ [3,[ 1 ]].df('a',4) ++ [1].df(\d) => _.q /[ 2,4 ],
		amp: 0.2,
		instrument: \sawSynthSustain, amp: 0.07,
		dur: b.parse([1,3,3,5,1,1,1,4,3]).q,
		// lag: [0, 0, 0,    0, -0.1, 0, -0.1, 0,0,0,0,0,0].q
		lag: [0, 0, 0,    0, -0.1, 0, -0.05, 0,0,0,0,0,0].q
	].ppma
});
P(\womanChords,syl:18, music: { |p b e|
	[
		freq: [ [1,3,5,7],[ 1,3,5,6 ] ].df(\d).q,
		attack: [1,0.1].q,
		// dur: b.drop(1).q,
		instrument: \stringyy, amp:0.2,
	].ppm
});
P.synthVs(role: \henoch, take: [\lead, \double], params: {|p b| [
	lyrics: "r r no doubt r want the mechanism + + + to at least appear + to be a woman +",
	pitchTake: [1, 3],
	legato: [[1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 0.7,   1, 1, 1, 1, 1,  0.8, 1, 1, 1, ]],
	filter: (midinote: _ - 12), 
	lag: [[0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0,0, 0.05, 0]]
] }, music:{|p b e|
	{
		e.playbuf
		=> p.synthVTracks.at(e.key).()
	}.play

}); 
[ "(he tests its hand movement.) It is ready, Thalassa.  ","-5 5 5 11 5 3 2 1".dm('f#',\minor) ].addLine;
P.still(\handRises, timecode: 4218.666.seconds, music: { |p b e|
	 e.still.( 
		wait: b.sum,
		text: ["",""],
	).sequenceText2(
			b.parse([1]), [ 
				["it is","ready, Thalassa"],
			],
	)
});
P.still(\speaks, syl:0,timecode: 4221.7.seconds, music: { |p b e|
	 e.still.( 
		wait: b.sum,
		text: ["",""],
	)
});
P(\chord,syl:2, music: { |p b e|
	{
		var freq = [-1, 1, 11, 13, 15, 21].df('f#', \minor);
		var offset = freq.collect{ 0.22.rand }.sort;
		VarSaw.ar(freq,0,0.9)
		/15
		=> HPF.ar(_,300)
		* Env([0,0,1,0],[offset,0.05,( freq + 1800 ).reciprocal * 4000]).kr(0,gate:1)
	}.play
});
P(\test, music: { |p b e|
	{
		Saw.ar( 7.df('f#') * Pulse.ar(10 ).range(1, 1.midiratio) )
		* Env.perc(0.1,3).kr(2,gate:1)
		/10
		=> Pan2.ar(_, SinOsc.ar(2))
	}.play
});
P(\bassnote,syl:2, music: { |p b e|
	(
		instrument: \wash,
		freq: [-21,1].df('f#')
	).play
});
P.synthVs(role: \henoch, take: [\lead, \double], params: {|p b| [
	lyrics: "r It is ready + Thalassa + +  ",
	filter: (midinote: _ - 12), 
	pitchTake: [1, 3]
] }, music:{|p b e|
	{
		e.playbuf
		=> p.synthVTracks.at(e.key).()
		=> {|i| CombN.ar(i, 0.4,0.37,5) / 3 + i * 1.5.dbamp}
	}.play

});
[ "/*MULHALL:*/ No! ", "7".dm(\g,\diminished) ].addLine;
P(\cymbal, music: { |p b e|
	(
		instrument: \cymbalsDS, att:0, amp:0.025
	).play
});
Song.durs.filter(\No,_*1.25);
P.still(\thalassaClose, timecode: 4224.seconds, music: { |p b e|
	 e.still.( 
		wait: b.sum,
		text: ["NO",""],
	)
});
P.synthV(role: \thalassa, take: \lead, params: {|p b| [
	lyrics: "no",
	pitchTake: 1,
	legato:1,
	pitchDelta: Env([0,-100],1)
	// filter: (midinote: _ - 12), 
] }, music:{|p b e|
	{
		e.playbuf
		=> p.synthVTracks.at(e.key).()
		=> {|i| CombC.ar(i, 0.3,
			Line.ar(0.05,0.07,2),
			5 ) /5.5 +
			i}
			* 3.dbamp
	}.play

});
P(\chord, music: { |p b e|
	{
		var freq  = [1,-3,5,-7].df(\g,\diminished);
		Gendy1.arWidth(freq:freq,width:Line.kr(1.01,1.2,5))
		* Env([1,1,0],[1,4]).kr(2,gate:1)
		/30

	}.play
});
[ "/*SPOCK:*/ You have no excuse to keep the real body any longer. ","1 1 2 3 4 5 6 7".dm('a-') ++ "13 12 7 11 7 6 4".dm(\f) ].addLine;
P.still(\henochAgain, timecode: 4227.25.seconds, music: { |p b e|
	 e.still.( 
		wait: b.sum,
		text: ["",""],
	)
});
P.still(\clear, timecode: 0.seconds, music: { |p b e|
	 e.still.( 
		wait: b.sum,
		text: ["you have no excuse","to keep the real body"],
	).sequenceText2(
			b.parse([11,4]), [ 
			["any","longer"],
			],
	)
});
P.synthVs(role: \henoch, take: [\lead, \double], params: {|p b| [
	filter: (midinote: _ - 12), 
	lyrics: "You have no excuse + to keep the real body + any + longer + ",
	pitchTake: [1, 3]
] }, music:{|p b e|
	{
		e.playbuf
		=> p.synthVTracks.at(e.key).()
	}.play

});
P(\line, music: { |p b e|
	[
		freq: [11, 11, 7].df('a-',4,\mixolydian) ++ [ 4, 3, 1, 2, 1,-4.5,5].df(\c,6) =>  _.q /[8,4],
		dur: b.parse([1, 3, 4, 1, 1, 1,1, 1, 2]) ++ e.bNext[..4].sum => _.flat => _.q,
		legato:0.99, instrument: \help_oteypiano,amp:0.2,
		out: Effect.bus({|i|  i => FreeVerb.ar(_,0.2,1) =>CrossoverDistortion.ar(i,0.1,0.95 ) },out:3)
	].pp;
	[
		freq: [11, 11, 7].df('a-',4,\mixolydian) ++ [ 4, 3, 1, 2, 1,-4.5,5].df(\c,6) =>  _.q /[2,4],
		dur: b.parse([1, 3, 4, 1, 1, 1,1, 1, 2]) ++ e.bNext[..4].sum => _.flat => _.q,
		legato:0.99,
		// instrument: \help_oteypiano,amp:0.2,
		out: Effect.bus({|i|  i => FreeVerb.ar(_,0.2,1) =>SineShaper.ar(i,0.1,0.95 ) },out:2)
	].pp;
	[
		freq: "1 1 2 3 4".df('a-',4).q,
		instrument: \harp,coef:0.4,amp: 0.05,
		dur: b.parse([1, 1, 1, 1, 4]).q,

	].pp;
	[
		freq: [\r,5, 3, 1].df('b-',[3,5]).q,
		dur: b.parse([11,2,1,1]).q,
		rel: 5,
		instrument: \sawSynth,

	].pp
});

// [ "Sargon would've required that you enter the mechanism immediately. ","r" ].addLine;
[ "/*MULHALL:*/ -boom- I cannot live in that thing.","-1 1 3 5 7 5 3 4".dm(\g, \mixolydian) ].addLine;
P.still(\closeThall,syl:0, timecode: 4234.seconds, music: { |p b e|
	 e.still.( 
		wait: b.sum ,
		text: ["I cannot live","in that thing"],
		fade:e.bNext.sum
	)
});
P.synthV(role: \thalassa, take: \lead, params: {|p b| [
	lyrics: "r I cannot + live in that thing." ,
	phonemes: ["","a :\\i","kh a n ","n A th","l \\i w", "i\\ n","t a th","s i\\ N"],
	legato: [1,1, 1, 0.9, 0.9, 1, 0.7, 1.3, ],
	loudness: Env([0,0,0,0,0,0,0,5],b),
	pitchTake: 1
] }, music:{|p b e|
	{
		e.playbuf
		=> p.synthVTracks.at(e.key).()
		=> {|i| CombN.ar(i,0.4,0.23,4) /6 + i }
	}.play

});
P(\bassnote, music: { |p b e|
	(
		freq: 1.df(\g,[2,3]),
		dur: b.parse([7]).unbubble,
		instrument: \sawSynthSustain, amp: 0.05
	).play
});
P(\doubling, music: { |p b e|
	[
		freq: [\r] ++ "1 3 5 7 5 3 4".df(\g,\mixolydian) => _.q,
		instrument: \stringyy,
		attack: 0,
		amp: 0.3,
		release: 0.1,
		dur: b.q
	].pp
});
P(\chord, syl: 6, music: { |p b e|
	(
		freq: [1,3,5].df(\a, 4,\minor),
		out: Effect.bus({|i| CrossoverDistortion.ar(i)/10 + i => FreeVerb.ar(_,1,[ 1,0.8 ]) },)

	).play
});
[ "-boom-","1".dm(\c) ].addLine;
P(\boom, music: { |p b e|
	(
		freq: [-1,1,3].df(\c,3,\minor),
		out: Effect.bus({|i| DWGReverbC1C3.ar(i) },)
	).play
});
}
)
