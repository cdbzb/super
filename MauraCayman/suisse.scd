(
Song(\suisse,[]).current;
["record","r",[0.1]].addLine;
P(\recorder, music:{|p b e| 
	Song.r = Recorder.new(s);

    // record into a flac file
    Song.r.recHeaderFormat = "wav";

    // default 'float' is incompatible with flac. set to 24bit:
    Song.r.recSampleFormat = "int24";

    // set very obvious prefix for files
    Song.r.filePrefix = "Suisse_";

    // start recording:
	Song.r.record
});
["line","11 5 3 7 6 4 1 5 4 2 -6 3 2 -7 ".dm(\c)].addLine;
P(\tune, music:{ |p b e|
	[
		midinote: p.tune[e.start].list ++ -5.dm(\c) => _.q,
		dur: e.bAll.q,
		instrument: [\harp, \sparkTriangle, ],
		out: Effect.bus({|i|
			i
			// FreeVerb.ar(i,0.1,0.8) 
			=> BPF.ar(_,800) 
			=> Pan2.ar( _ , Line.kr(-1, 1, b.sum+0.5) )
		},),
		coef: 0.1,
		amp: [ 0.009, 0.03, ], 

	].pp
}
);
["Verse 1","-5 -5 1 2 3 3 1 1 4 3 3 2 -5 -5 1 2 3 3 1 1 4 3 3 2 1.5 2".dm(\c)].addLine;
Song.setTempoMap('Verse 1',"e e qe e e e e e qe e e e e e qe e e e e e qe e e e e e");
// P.tune();
~synful.isNil.if {Song.horn=Synful();~synful=Song.horn}{Song.horn = ~synful};
/* 
(type:\synful,instance:Song.horn,freq:350 ).play
Song.horn.patch(\horn,\none,2);
Song.horn.controller.editor
*/
P(\hornTwo, music: { |p b e|
	[
		freq: "2 2 3 5 11 11 5 5 6 5 4 4 2 2 3 5 11 11 5 5 6 5 7 7".df(\c,4).q,
		dur:b.q ,
		legato: [0.9,0.9, 1, 1, 0.9, 0.9, 0.9, 0.9, 1, 1, 0.9, 0.9, ].q(2),
		// type: \synful,
		instrument:p.hornDef,
		instance: Song.horn,
		patch: \horn,
		amp:0.1,
		out: Effect.bus({|i| DWGReverbC1C3.ar(i,mix:0.2) },)

	].p.trace.play
});
( Song.hornDef = {
		//add whiteNoise => Formant
		var gate = \gate.ar(1);
		var att = Env.perc(0.01, 0.1).kr(0,gate:1);
		var bright = Env.adsr(0.1,0.1,0.5,0.1).kr(0,gate:gate) 
		* (1+ Env.asr(0.5,1,0.1).kr(0,gate:gate) )
		;
		var pah = att * LFTri.kr(60) * 20;
		Saw.ar(\freq.kr(300) 
		+ pah 
		+ Gendy1.kr(minfreq:1,maxfreq:1).range(-1,1)
		, \amp.kr(0.1))
		=> LPF.ar(_,800
			* bright +60
		)
		* Env.adsr(0.05, 0.15, 0.5, 0.5).kr(2,gate:gate)
		=> LeakDC.ar(_)
		=> Pan2.ar(_,\pan.kr(0))
		=> Out.ar(\out.kr(0),_)
	}.asDefName;
);
P(\hornOne, music: { |p b e|
	[
		midinote: p.tune[e.start],
		legato: [0.9,0.9, 1, 1, 0.9, 0.9, 0.9, 0.9, 1, 0.9, 1, 0.9, ].q(2),
		dur:b.q,
		type: \synful,
		instance: Song.horn
		patch: \trombone,
		expression: [0.7,0.7, 1, 1, 1, 1, 1, 1,  0.7, 0.5, 0.7, 0.5].q(2) * 64 +30 //+20 if trombone
	].p.trace.play
});
P(\bassline, music: { |p b e|
	[
		type: \synful,
		instance: p.horn,
		patch: \bass,
		bank: \pizz,
		channel:5,
		freq: [\r, 11, 5, 11, 5, 4, 11, 5, 7,11, 5, 11, 5, 4, 11, 5].df(\c,3).q,
		dur: "q*17".beats.warpTo(e.tempoMap).q,
		amp:6,
		// expression: 64
	].pp
});
P(\clarinet, music: { |p b e|
	[
		freq: [\r, 3, 2, 1, \r, -6, -4, -1].df(\c,6 ).q(2),
		dur: "qe x x e eqqe x x e eqqe x x e eqqe x x e".asBeats.warpTo( e.tempoMap ).q,
		type: \synful,
		instance: p.horn,
		channel: 4,
		patch: \clarinet,
		legato:1,
		expression:90,
		out: Effect.bus({|i| i => FreeVerb.ar(_,0.2,1) * [0.1,1] },)
	].pp;
	[
		freq: [\r, 11, 5, 3, \r, 11, 6, 4].df(\c,5 ).q(2),
		dur: "qe x x e eqqe x x e eqqe x x e eqqe x x e".asBeats.warpTo( e.tempoMap ).q,
		type: \synful,
		instance: p.horn,
		channel: 2,
		patch: \clarinet,
		legato:1,
		expression:90,
		// out: Effect.bus({|i| i => FreeVerb.ar(_,0.2,1) * [0.1,1] },)
	].pp;
	[
		freq: [\r, 11, 5, 3, \r, 11, 6, 4].df(\c, 6 ).q(2),
		dur: "qe x x e eqqe x x e eqqe x x e eqqe x x e".asBeats.warpTo( e.tempoMap ).q,
		type: \synful,
		instance: p.horn,
		channel: 3,
		patch: \flute,
		legato:1,
		expression:120,
		// out: Effect.bus({|i| i => FreeVerb.ar(_,0.2,1) * [0.1,1] },)
	].pp;
	[
		freq: [\r, 11, 5, 3, \r, 11, 6, 4].df(\c, 5 ).q(2),
		dur: "qe x x e eqqe x x e eqqe x x e eqqe x x e".asBeats.warpTo( e.tempoMap ).q,
		instrument: \harp, amp:0.03
	].p//p
});
P(\triangle, music: { |p b e|
	[
		instrument: \percTriangle,
		trig: 1,
		dur: "q q q q q q q q q q q q q q q q ".asBeats.warpTo( e.tempoMap ).q,
		rest: MuteFirst(),
		out: Effect.bus({|i| i=> Pan2.ar(_,-0.75) },)
	].pp
});
P(\connector,syl:21, music: { |p b e|
	[
		channel:5,
		freq: "5 4 3 4 3".df(\a,5).q,
		/* type: \synful,
		patch: \violins,
		// bank: \arco, */
		dur: b.drop(0) ++ e.bNext(1) => _.q,
		instance: Song.horn,
		legato:1,
		amp:0.03,
		instrument: \wash,freqLag:0.05,
		expression:90
	].ppm
});
	["Bridge","5 4 4 3 2 3".dm(\d)++"5 2 4 3 11 7 7 6 5 7 6 4 2 5 4 3 1 -5".dm(\c,\mixolydian)].addLine;
( SynthDef( \percTriangle,{
var freqs= [4067,4039,3509,3250,2845,2509,1539,1517,1388.6,1349.6,892.5,724.6252,152];
	// SinOsc.ar( freqs,0,0.01 )
	Klank.ar(
		`[
			freqs.sort* 1.5,
			(freqs.size..1).reciprocal,
			(1..freqs.size) /3  
		],Env.perc(0,0.01).kr(0,gate:\trig.tr) * WhiteNoise.ar(0.01))
		* \amp.kr(0.1)
		=> Out.ar(\out.kr(0),_)
	}).add
);
Song.originalDurs = Song.durs[\Bridge];
Song.durs.filter(\Bridge,_.dropLast(2));
Song.setTempoMap(\Bridge,"ex x x x x x ex x e e ex x x x x x x x x x x x x x");
P(\tune, music: { |p b e|
	[
		midinote: p.tune[e.start].list.dropLast.q,
		dur: b ++ e.bNext => _.q,
		instrument: \stringyy,
		wet:0.02,
		release:4,
		amp:0.2 * [1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 0.6].q,
	].ppm
});
P(\chords, music: { |p b e|
	[
		freq: [3, 4].df(\a,4) ++ [-7, 1].df(\c) => _.q,
		dur: "q qex x qq".asBeats.warpTo( e.tempoMap ).q,
		instrument: Song.hornDef, amp:0.1,
		out: Effect.bus({|i| FreeVerb.ar(i,0.2,1) }),
		legato: [ 1, 0.9,1, 1 ].q

	].pp;
	[
		freq: [\r,11, 7, 6.5].df(\f,[3, 4 ]).q,
		amp: [0.02,0.2],
		dur: "qqq ex x q".asBeats.warpTo( e.tempoMap ).q,
		instrument: [\harp, \visual_pad]
	].pp
});
P(\bass, music: { |p b e|
	[
		freq: [-6, 2, -6.5, -5.5, -6, -5, -4, -2, -5].df(\c,4,\mixolydian).q,
		dur: "q q ex x qex x q q q".asBeats  => _.warpTo( e.tempoMap )=>_.q,
		instrument: \sawSynthSustain, amp: 0.04
	].ppm
});
P(\clarinet,syl:9, music: { |p b e|
	[
		freq: "6 5 5 4 3 5 4 2 -6 3 1 -5 -3 ".df(\c).q,
		dur: b.drop(1) ++ e.bNext => _.q ,
		type: \synful,
		instance: p.horn,
		channel: 2,
		patch: \clarinet,
		legato:1
	].pp
});
[ "Verse 2",copyTuneFrom("Verse 1") ].addLine;
Song.cloneDursAndTempoMap('Verse 1');
// P.tune();
P.clone('Verse 1',[\hornOne,\eHorn,\bassline,\clarinet,\triangle,\hornTwo]);
/*
Song.horn.controller.gui
*/ 
["Bridg 2","5 4 4 3 2 3".dm(\d)++"5 2 4 3 11 7 7 6 5 7 6 4 2 5 4 3 1 -5".dm(\c,\mixolydian)].addLine;
Song.cloneDursAndTempoMap("Bridge");
P(\tune, music: { |p b e|
	[
		midinote: p.tune[e.start].list ++ [-5].dm(\c) => _.q,
		dur: b ++ b.last.dup(2) => _.q,
		instrument: \stringyy,
		wet:0.02,
		release:4,
		amp:0.2 * [1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1,1, 1].q,
	].ppm
});
Song.durs['Bridg 2'] = Song.originalDurs;
P.clone(\Bridge,[ \chords,\bass,\clarinet]);
[ "Verse 3",copyTuneFrom("Verse 1") ].addLine;
Song.cloneDursAndTempoMap('Verse 1');
["StopRecording","r",[1]].addLine;
P(\stop, music: { |p b e|
	fork{
		3.wait;
		Song.r.stopRecording
	}
});
)
