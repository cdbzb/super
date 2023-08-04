(
s.waitForBoot{ Song(\chamber1,[]).current;
"~/tank/super/More-Organized-Trek/Songs/boilerplate.scd".standardizePath.load;
( Song.synthVTracks=EventWithDefault(
	\default, { |mix=0.1|
		{
			|i|
			// i => FreeVerb.ar(_,1,[0.4,0.5])
			i => DWGReverbC1C3.ar(i,c1:3,c3:10,mix:mix)
			/4
		}
	},
	\asterian,{ |mix= 0.1|
		{
			|i|
			// i => FreeVerb.ar(_,1,[0.4,0.5])
			i => BLowShelf.ar(_,200,db: -9)
			// /80
			=> DWGReverbC1C3.ar(i,mix:mix,c1:3)
			/8
		}
	}
)
);
( Song.trillStart = { |lowerNoteDegree p b e octave=5 amp=0.03|
	Song.trillFreq=lowerNoteDegree;
	3.do{
		[
			freq:Pswitch1([ Pdefn(\lower),11.df],[0,1].q(inf)),
			dur: Pwhite(0.05,0.16,inf),
			legato:Prand([0.8,1.1],inf),
			pan:(-1).rrand(1.0),
			amp:amp*3,
			out: 
			Effect({|i| i =>FreeVerb.ar(_,0.8,0.8)}).bus.index

		].pm(\default) //=> 
		//Pfindur(b.sum,_) 
		=> _.play
	}
};
);
( Song.trillFunc={|freq, time|
Pdefn(\lower, Penv([Song.trillFreq,freq,freq],[ time, inf ]));
	Song.trillFreq=freq;
};
);
(
Song.triller = { 
	VarSaw.ar( LFPulse.ar(
		LFBrownNoise1.kr([ 1, 1.01, 1.02 ]).range(5.5,7)  // for multi-chan
	).range(\lower.kr(7.df,\portamentoRate.kr(1)),\higher.kr(11.df,6))
	* [3, 2,1 ], //octaves
	0,0.5.rand, 0.05 )
	* 0.15 // amp
	=> Pan2.ar(_,Rand(-1,1.0))
	=> LPF.ar(_,4000)
	//=> TwoTube.ar(_, k:0.01, loss:0.997, d1length:[333,456], d2length:[543,611], mul:1.0, add:0.0)
	=> { |i| DWGReverbC1C3.ar(i, len:100, c1:1, c3:10, mix:0.1, coefs:nil, perm:nil, doprime:0) => Pan2.ar(_,0.9)+i}
	=> Disintegrator.ar(_, probability:\noise.kr(0), multiplier:WhiteNoise.kr().range(0,-1))
	* \amp.kr(0.1)
	* Env.asr(4).kr(2,gate:1)
}.asSynthDef.add.name;
Song.trillSynthFunc = {|note| 
	Song.trillBus = Song.trillBus ? Bus.control; 
	Song.trillBus.set(0.1);
	(1..3).collect{Synth(Song.triller,[\lower,note.df]).register.map(\amp,Song.trillBus)}
	
};
Song.changeTrill = { |note|
	( try{ Song.trillSynth[0].isRunning }==true ).if{
		fork{ Song.trillSynth.do( { |i| i.set(\lower,note.df);0.4.rand.wait} )}
	}{Song.trillSynth = Song.trillSynthFunc.(note)}
};
);
["transporter","r",[8]].addLine;
P.still(\transporting, timecode: 856.535.seconds, music: { |p b e|
	 e.still.( 
		wait: b.sum,
		text: ["",""],
	)
});
P('transporter',music: {|p b e|
	{
	var beam_envelope, phasor, beam, feedback, transporter, reverb, activateEnv, percEnv, activate, buffer;

	buffer = LocalBuf(SampleRate.ir * 0.12);

	// feedback has to be 0 at the beginning, to avoid input
	// nil before sound has been produced
	feedback = 0;


	// Activate Sound (fig 56.3)

	activateEnv = EnvGen.ar(Env.new([0, 1, 1, 0], [0.01, 0.01, 5]));
	percEnv = EnvGen.ar(Env.new([1, 1, 0], [0.01, 0.12]));

	activate = (1 - activateEnv * 120 + 775) + (WhiteNoise.ar(0.1) + SinOsc.ar(30, mul:40));
	activate = OnePole.ar(activateEnv, exp(-2pi * (30 * SampleDur.ir))) * LFSaw.ar(activate, 1, 0.5, 0.5 );

	// adding a percussive shape at the beginning of the sound
	activate = (activate + (WhiteNoise.ar * percEnv)) * 3;

	activate = Clip.ar(activate, -1, 1);
	activate = BPF.ar(activate, [775,1550,2325], 13.reciprocal).sum * 0.5;


	// Beam Sound

	beam = LFSaw.ar(467.1, 1, 0.5, 0.5 ) - 0.5;
	beam = beam - (Wrap.ar(beam) - 0.5);
	// two stage FM process
	phasor = LFSaw.ar( beam * 6500 + 277, 1, 0.5, 0.5) - 0.5;
beam = beam * (phasor - (Wrap.ar(phasor) - 0.5));
	beam = DelTapWr.ar(buffer, beam + (feedback * 0.7));

	beam_envelope = Line.ar(0,1,12);

	feedback = DelTapRd.ar(buffer, beam,
		(1 - beam_envelope * 12 + 1
			// flanger effect w/ variable delays spaced 12ms apart [0,12,24]
			+ 12 * (0..2))
		// DelTapRd requires delaytime in seconds (the equivalence in pd [vd~]
		// calculates with miliseconds, for it the division by 1000)
	 	/ 1000,
		interp: 4).sum * 0.3;

	transporter = (beam_envelope * (-1) + 1).min(beam_envelope) * 4 * feedback;
	transporter = (transporter - OnePole.ar(transporter, exp(-2pi * (100 * SampleDur.ir))));
	transporter = BPF.ar(transporter,
		// whole tone scale
		Array.geom(12, 466.164, 1.12247),
		[1200, 1100, 930, 910, 880, 840, 800, 760, 720, 680, 640, 620].reciprocal).sum * 12;
	reverb = GVerb.ar(transporter + (activate * 0.1), 100, 8, 0.1, 0.9);
	reverb = reverb + (activate * 0.5)!2;
	reverb / 12

}.play
});

/*[ Chamber ] */ ["SPOCK: Captain, the security guards. ","5 3 5 7 12 7 5 3".dm(\c,\mixolydian)].addLine;
Song.durs.filter(\guards,{|i| var last = i.last; i.dropLast ++ (last+1)});
P.still(\wide, timecode: 857.6.seconds, music: { |p b e|
	 e.still.( 
		wait: b.sum,
		text: ["",""],
	)
});
P('crash',start:\Captain,music: {|p b e|
	(
		freq: "3 5 7 12 13 15 17 22".df(\c,\mixolydian),
		strum: 0.05,
		out: Effect.bus({|i| i => FreeVerb.ar(_,1,1) * SinOsc.ar({3.rrand(5.0)}!6) => Splay.ar(_) => Phaser1.ar(_,rate:0.2) },)
	).play
});
P.synthV(role: \spock, take: nil, params: {|p b| [
		lyrics: "Captain + the security + + + guards ",
		filter: (midinote: _ - 12), 
		legato: [1, 0.5,  1, 1, 1, 1, 1, 1, ],
		lag: [0.05,0,0,0,0,0,0,0],
		pitchTake: 1
	] }, music:{|p b e|
		{
			e.playbuf
			=> EarlyRef.ar(_, [1,0,0],[0,0,0],[3,4,5.1])
			=> p.synthVTracks.at(e.key).(mix:0.05)
		}.play

	});


["KIRK: Kirk here. ",[11,3].dm('c#')].addLine;
Song.early={|sig az| EarlyRef.ar(sig, [az * pi / 2 => _.sin, 0, cos(az * pi / 2)],[0,0,0],[3,4,5.1])};
Song.durs.filter( _ * 0.7 );
P.still(\communicator, timecode: 902.seconds, music: { |p b e|
	 e.still.( 
		wait: b.sum + e.bNext.sum,
		fade: 7,
		text: ["",""]
	)
});
P.tune(_ <> [ out: Effect.bus({|i| DWGReverbC1C3.ar(i) },) ].p);
P(\tone, music: { |p b e|
	{
		SinOsc.ar( 11.df('c#')!20 => _.pareto() *.t [1,1.03] )
		=> Splay.ar(_)
		/90
		* Env([0,1,0],[2,3]).kr(2,gate:1)
	}.play
});
P.synthV(role: \kirk, take: \lead, params: {|p b| [
		filter: (midinote: _ - 12), 
		lag: [0.1,0.1],
		lyrics: "kirk here",
		legato: [1,0.8, ],
		pitchTake: 1
	] }, music:{|p b e|
		{
			e.playbuf
			=> p.early.(_,-1)
			=> p.synthVTracks.at(e.key).(mix:0.05)
		}.play

	});

	Song.smallSpeaker = [0,1].collect({ |i| IR("~/tank/IR/Saane/Speakers_&_Telephones/Small_speaker_stereo.wav".standardizePath,i)});

	Song.offCamEffect = { Effect.bus( { |i|  PartConv.ar(i => SineShaper.ar(_,0.03),4096,Song.smallSpeaker) * 0.15}) };
	Song.offCamFn = { |i|  PartConv.ar(i => SineShaper.ar(_,0.3),4096,Song.smallSpeaker) * 0.05};
["SCOTT [OC]: Can you read me, Captain? ","3 2 5 3 2 1".dm(\b,\whole)].addLine;
	Trek.cast.scott = \mo;
P.synthV(role: \scott, take: \lead, params: {|p b| [
		lyrics: "Can you reed me, Captain + ",
		lag: [0.07,0,0,0,0,0],
		filter: (midinote: _ - 12), 
		pitchTake: 1
	] }, music:{|p b e|
		{
			e.playbuf
			// => p.synthVTracks.at(e.key).()
			=> p.early.(_,-0.5)
			=> p.offCamFn.(_)
		}.play

	});
P(\connector, music: { |p b e|
	[
		freq: "3 2 2 1".df(\b,\whole) ++ "1 -5".df('e-',6) => _.q /2,
		dur:b.parse([1, 3, 1, 1]) + [0,0,0,e.bNext[0..1].sum] ++ e.bNext[2..3] => _.q
	].pp
});
["KIRK: Yes, Scotty (boom), and I shouldn't be able to this deep inside the planet", [11, 7, 5, 2,  6, 7, 11, 7, 6, 7, 5, 1, 6, 6, 5, 4, 3,3,2].dm('a-')].addLine;
Song.setTempoMap('Yes',"q e e e x x E E E e e e e Q E Q E Q Eq");
P(\dyads, music: { |p b e|
	[
		freq: [ [5, 1],[5, 1], \r, [-4, 1],[-4,1] ].df('e-',4).q,
		dur: b.parse([1,2, 6, 2, 1]).q,
		out: Effect.bus({|i| i * 2 => _.sin => FreeVerb.ar(_,0.01,1) /2 },out:3)
	].pp
});
P.still(\kirkClose, timecode: 916.9.seconds, music: { |p b e|
	 e.still.( 
		wait: b.sum,
		text: ["",""],
	)
});
P.synthV(role: \kirk, take: \lead, params: {|p b| [
		filter: (midinote: _ - 12), 
		lyrics: "Yes, Scotty + r and I shouldn't +  be able + to this deep inside + the plan et",
		// phonemes:["","","","","","","","","","","","","","","","","","","n ih t"]
		pitchTake: 1
	] }, music:{|p b e|
		{
			e.playbuf
			=> p.early.(_,0) * -3.dbamp
			=> p.synthVTracks.at(e.key).(mix: 0.1)
		}.play

});
P(\deepMiddleNote,syl: 12, music: { |p b e|
	(
		freq: 1.df('a-',4),
		instrument: \wash
	).play
});
P.synthV(role: \kirk, take: \bg,
		pbind: {|p b|
			[
			midinote:[-1,4,4,3,2,1,-7, -7].dm('a-',4,\mixolydian),
			dur: "qqqqqe e e e e e e eq".asBeats.warpTo(Song.tempoMap[\deep])
			 ].p
		},
		params: {|p b| [
		lyrics: "r this deep inside + the plan et",
		pitchTake: 1,
		paramGender: 0.2
	] }, music:{|p b e|
		{
			e.playbuf
			=> p.synthVTracks.at(e.key).()
		}.play
	});
P('click',start:\Yes,music: {|p b e|
		[
			dur: 1!10 => _.warpTo(e.tempoMap)=> _.postln => _.q,
			instrument:\hihat,
		].p
		//p
	});
P('bass',start:\Yes,music: {|p b e|
		[
			freq:[\r,2,1,4,4,3,2,1,-7].df('a-',[3],\mixolydian).q,
			//dur:b.parse([3, 8, 1, 1,1, 1,1 ,1 ,1]).q
			dur: "qq qqq e e e e e e qe".asBeats.warpTo(e.tempoMap).q,
			instrument:\sawSynthSustain,amp:0.06,
			out:Effect.bus( { |i| Monitors.az(i,SinOsc.ar(0.02))=> Reflector5.ar(i,20)   =>DWGReverbC1C3.ar(i,mix:0.5)} )
		].pp
	});
[ "but perhaps this has been arranged for us, too. ","5 6 1 3 4 5 6 7 7.5 4 12".dm(\a,\minor) ].addLine;
P(\basnote, music: { |p b e|
	fork{
		var inst = Barrier.collect(
			{ {|freq|
				Pulse.ar(freq, 0.24,0.1)
				/5
				// /10
				=> FreeVerb.ar(_,0.4,1) * 2
				=> Out.ar(\out.kr(0),_ )
			}.asDefName } 
		);
		inst.()[0] =>
		[
			// freq: [ [ 4.5,7 ], [1,6] ].df(\c,4,\mixolydian).q,
			freq: [-5,1, 4, ].df(\a,3).q,
			// instrument: channel.extract.postln,
			instrument: _,
			instrument: \stringyy, wet:0,amp:0.3,
			dur: b.parse([2,5, 3, 1]).q
		] =>_.ppm
	}
});	
/* P(\middleChord,syl:6, music: { |p b e|
	(
		freq: [-7, 1, 3, 5].df(\b,[3, 4 ],\minor),
		strum: 0.05
	).play
}); */
// P.tune(_ <> [rest:[1, 1, 1, \r,\r,\r,\r,1,1,1,\r].q, instrument: \harp,coef:0.05].p);
P.synthV(role: \kirk, take: \lead, params: {|p b| [
	filter: (midinote: _ - 12), 
	lyrics: "but perhaps + this has been arranged + for us, too. ",
	legato: [0.7, 1, 0.8, 1, 1, 1, 1, 1, 1, 1, 1, ],
	pitchTake: 1
] }, music:{|p b e|
	{
		e.playbuf
		=> p.synthVTracks.at(e.key).()
	}.play

});
P('chord',start:\perhaps,syl:9,music: {|p b e|
	[
		freq: 
		[ -7,1,5 ].df('e',\mixolydian) *.t [1,-1.midiratio] => _.flop
		=> _.q,
		instrument:\stringyy, freqLag:1,
		dur: b.drop(1) ++ e.bNext[0] =>_.q
	].ppm
	});
["Is the security guard up there?","1 2 3 4 3 2 1 3 5".dm('e-',\lydian)].addLine;
P.synthV(role: \kirk, take: \lead, params: {|p b| [
	lyrics: "Is the security + + + guard up there?",
	filter: (midinote: _ - 12), 
	pitchTake: 1
] }, music:{|p b e|
	{
		e.playbuf
		=> p.synthVTracks.at(e.key).()
	}.play

});
P(\bassnote, music: { |p b e|
	(
		instrument: \sawSynthSustain,
		att: 3,
		freq: 1.df(\g,3),amp:0.03
	).play
});
// P.tune(_ <> [instrument: \visual_pad, amp:0.3].pm);
P(\dyads, music: { |p b e|
	[
		freq: [\r,[1, 4.5],[3,11]].df('e-').q /2,
		dur: b.parse([3, 4, 2]).q,
		legato: 0.5,
		out: Effect.bus({|i| Phaser2.ar(i,rate: 0.2,fb:0.99) => FreeVerb.ar(_,1,1) },)
	].pp
});
/*[ Transporter Room ]*/ ["SCOTT: They're fine. They Just didn't dematerialise.","6 12 6 7 4 5 6 7 11 5 4 3".dm('e-',4)].addLine;
P(\bassnote,syl:0, music: { |p b e|
	(
		instrument: \sawSynthSustain,
		att: 1,
		freq: 1.df(\f,4),amp:0.03
	).play
});
Song.durs.filter(\dematerialise,{|i| var last = i.last; i.dropLast ++ (last * 0.45)});
P(\chord, music: { |p b e|
	[
		freq: [ \r,[-6,1, 4].df(\c), \r, [-6,2,4].df(\c),\r,[-7,1,3].df('b-',4,\mixolydian),[-6,1,4].df('b-',4) ].q,
		dur: b.parse([ 1,1,1, 1,1,3, 4 ]).q,
		legato: [0.9,0.8,0.9,0.8,1,1,1 ].q(),
		instrument: \sawSynthSustain, amp:0.03
	].ppma
});
P(\connector,syl:10, music: { |p b e|
	[
		instrument:\stringyy,wet:0,
		freq: [11.5, 6, 5, 11.5, 6, 4,4].df('f#',3).q,
		dur: b.drop(1) ++ e.bNext ++ 1 => _.q,
		out: 2,amp:0.2
	].ppm
});
P.still(\backMedium, timecode: 911.670.seconds, music: { |p b e|
	 e.still.( 
		wait: b.sum,
		text: ["",""],
	)
});
P.still(\transporterRoom, timecode: 913.333.seconds, music: { |p b e|
	 e.still.( 
		wait: b.sum,
		text: ["they're","fine"],
	).sequenceText2(
			b.parse([2]), [ 
			["they just didn't","dematerialise"],
			],
	)
});
P.synthV(role: \scott, take: \lead, params: {|p b| [
	lyrics: "They're fine. They Just didn't + dee materialise + + + +.",
	legato: [1, 0.5, 1, 0.7, 1, 1, 1, 1, 1, 1, 1, 0.8, ],
	pitchTake: 1
] }, music:{|p b e|
	{
		e.playbuf
		=> p.early.(_,0) / 2.5
		=> p.synthVTracks.at(e.key).(0.04)
	}.play

});
P.tune(\dematerialise, _ <> [instrument: \sawSynthSustain,amp:0.015].pm);
/*[ Chamber ]*/ ["SCOTT [OC]: I don't like it, sir. ","3 2 5 3 1".dm(\b,\whole)].addLine;
P(\sirNote,syl:3, music: { |p b e|
	(
		instrument: \harp,
		freq: 1.df(\b,3),coef:0.8,
		out: Effect.bus({|i| FreeVerb.ar(i,0.5,1) },)
	).play
});
P.still(\backInTheChamberScottOC, timecode: 916.251.seconds, music: { |p b e|
	 e.still.( 
		wait: b.sum,
		text: ["",""],
	)
});
P(\bassPad,syl:1, music: { |p b e|
	[
		instrument: \stringyy,
		freq: "-1 5 3 ".df(\b,4,\whole),
		dur:1.q
	].pp
});
P.still(\kirkOnWalkie, timecode: 914.833.seconds, music: { |p b e|
	 e.still.( 
		wait: b.sum,
		text: ["I don't like it","sir"],
	)
});

P.synthV(role: \scott,
		lag:-1 *(4096/2-s.options.blockSize/s.sampleRate),
		take: \lead, params: {|p b| [
		lyrics: "I don't like it sir",
		filter: (midinote: _ - 24), 
		pitchTake: 1
	] }, music:{|p b e|
		{
			e.playbuf
			// => p.synthVTracks.at(e.key).()
			=> p.offCamFn.(_)
			/2

		}.play

	});
P.tune('like it,', { |i| Pbindf(i,\legato,5,\instrument,\harp,\amp,0.02,\lag,Pwhite(-0.01,0.01),\instrument,\wash)=>Pmul(\freq,0.5,_)});
["KIRK: No problem yet. Maintain alert. Kirk out. ","1 5 3 4.5".dm('f#') ++ "3 4 5 1".dm(\e,\minor)++ "5 11".dm('c#')].addLine;
// Song.durs.filter(\problem,{|i| var last = i.last; i.dropLast ++ (last * 2)});
P(\passNote, music: { |p b e|
	// ( instrument: \stringyy,amp:0.3, freq: 1.df('f#', [ 4 ]),attack:3,dur: b.parse(3).unbubble ).play;
	(
		instrument: \harp,
		freq: [-1].df(\c),
		lag: b.parse([3]).unbubble,
		out: Effect.bus({|i| DWGReverbC1C3.ar(i, len: 1000, mix:0.2) /4 })
		// coef: 0.25
	).play;
	(
		lag: b.parse([ 4 ]).unbubble,
		freq: [1, 1, 5, 13].df(\e,\minor),
		instrument: \sawSynthSustain,
		dur:3,amp:0.01,
		att:5,rel:5

	).play;
	[
		freq: [\r, 3, 1].df(\e, 4, \minor).q,
		dur: b.parse([4,3,1]).q,
		amp:0.3,
		instrument: \stringyy
	].ppm

});
P(\outChord,  music: { |p b e|

	[
		freq: [\r, [4, -5, -7, 12],[-1,1,5,11]  ].df('c#').q ,
		// lagTime: [0,0.1,0.1].q,
		instrument: \sawSynthSustain,
		dur: b.parse([8,1,1]) * [1, 1, 0.3] => _.q,
		// dur: b.drop(1)  => _.q,
		att: 4, rel: 3, 
		amp:0.1
	].ppm
});
P.still(\kirkSpeaksWalkie, timecode: 917.333.seconds, music: { |p b e|
	 e.still.( 
		wait: b.sum,
		text: ["no problem yet","maintain alert"],
	).sequenceText2(
			b.parse([8]), [ 
			["Kirk","out"],
			],
	)
});
P.synthV(role: \kirk, take: \lead, params: {|p b| [
	filter: (midinote: _ - 12), 
	lyrics: "No problem + yet. Maintain + alert + Kirk out. ",
	legato: [1, 1, 1, 0.3, 1, 1, 1, 0.4, 1, 0.6, ],
	lag: [0.05,0,0,0,0,0,0,0,0,0],
	pitchTake: 1
] }, music:{|p b e|
	{
		e.playbuf
		=> p.synthVTracks.at(e.key).(0.02)
	}.play

});
P(\bassnote, music: { |p b e|
	(
		freq: 1.df('f#',4)
	).play
});
P(\fiveOne,syl:7, music: { |p b e|
	[
		freq: [5, 1].df('c#',3).q,
		dur: b.drop(1).q,
		legato: [1, 0.5].q
	].pp
});
P(\trill,syl:8,music:{|p b e| 
	// fork{
		// 1.wait;
		Song.trillSynth = Song.trillSynthFunc.(7)
	// }
});
["start trill","r",[2.5]].addLine;
["MULHALL: Atmosphere report, Captain. ",[11,7,5,4,3,2,3].dm(\b,5,\mixolydian)].addLine;
P.tune(\Atmosphere, {|i| Pmul(\freq,[1,0.5],i) <> [out: Effect(FreeVerb.ar(_,0.8,0.8), inputChannels:2).bus.index, \legato:[6,2,5,2,4,2,3].q ].p });
P.still(\kirk_and_mullhall, timecode: 925.04.seconds, music: { |p b e|
	 e.still.( 
		wait: b.sum,
		text: ["atmosphere report,","captain"],
		fade:3
	).sequenceText2(
			b.sum, [ 
			["",""],
			],
	)
});
P.synthVs(role: \mulhall, take: [nil, \double],
	filter: (midinote: _ - 12), 
	params: {|p b| [
	lyrics: "atmosphere + + report + captain +",
	legato: [[1, 1, 1, 1, 0.8, 1, 0.8, ]],

	// vocalMode: \Opera
] }, music:[
	{Silent.ar(2)},
	{|p b e|
		{
			e.playbuf
			=> p.synthVTracks.at(e.key).()
		}.play
	}
]);
Pdefn(\lower,7.df.bubble.q(inf)); ///NOW WHAT?


["A fraction richer in oxygen than usual for us, but otherwise normal. "," 3 4 5 7 11 6 13 12 5 6 12 11.5 6, 4.5 5.5 4 5 6 7 12 11".dm(\c)].addLine;
P.still(\clear, timecode: 925.04.seconds, music: { |p b e|
	 e.still.( 
		wait: b.sum,
		text: ["a fraction richer","in oxygen"],
		fade: 1
	) .sequenceText2(b.parse([9,6]),[
		 ["than usual","for us"],
		 ["but otherwise","normal"]
	])
});
// P.tune(\oxygen,{|i| Pmul(\freq,[1,0.5],i) => Pset(\legato,1,_) });
P.synthVs(role: \mulhall, take: [nil, \double],
	params: {|p b| [
	lyrics:"A fraction + richer + in oxygen + + than usual + + for us, but otherwise + + normal + " ,
	legato: [[1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 0.8, 1, 1, 1, 1, 1, 1, ]],
	loudness: Env([0,0,6,0],b.parse([13,1,1]) + [0.1,0,0]),
	// vocalMode: \Opera
] }, music:[
	{Silent.ar(2)},
	{|p b e|
		{
			e.playbuf
			=> p.synthVTracks.at(e.key).()
		}.play
	}
]);
P('testrec',start:\oxygen,music: {|p b e|
	RecOnsets(\test,\oxygen)
	//.armed_(true)
	//.play;
	.play
	.warpTo(b)
	.q
	=> [ dur: _, instrument:\cymbalsDS,amp:0.005,rests: MuteFirst() ] =>_.pp
	//a.list

});
P('chord',start:\oxygen,music: {|p b e|
	(
		oxygen: [13, 12, 5],
		usual: [12,11.5,6],
		otherwise: [5,12,11]
	) => {|i| 
		[
			freq: [\r,i.oxygen, i.usual, i.otherwise].df(\c,tuning:\just).q,
			dur: b.parse([6,4,6,4]).q,
			instrument: \wash,
			att:3, lag:-0.5,amp:0.03
			
		].pp
	}
});
["SPOCK: This vault was constructed about a half a million years ago.", "5 7 6 5 4 3 2 3 4 6 5 4 3 2 1".dm(\c,5,\mixolydian)].addLine;
P.still(\spock, timecode: 934.32.seconds, music: { |p b e|
	 e.still.( 
		wait: b.sum + e.bNext.sum,
		text: ["this vault","was constructed"],
	)

});
P(\line,syl:0,lag:-0.2, music: { |p b e|
	{
		var width = 0.00;
		[4, 3, 1, 2].df(\f, [4,5]).dq.demand(b.drop(1).parse([3,5,3,3]))
		=> Lag2.kr(_)
		=> { |i| 
			Gendy2.ar(minfreq: i-width ,maxfreq: i + width)
			+
			( SinOsc.ar(i) => AnalogVintageDistortion.ar(_))
		=> VALadder.ar(_,1.df(\f,[3, 4, 5]),2,0.4,0)
		* [3,2,1]/3
		=> CombC.ar(_,decaytime:5)
		/200
		}
	}.play
});
// P.tune(\vault, { |i| Pmul(\freq,[1,0.5],i) <> [amp:
// 	[4,5,4,4,5,4,4,4,4,5,4,4,5,4,4]
// 	.q/45,legato:[1,2,2,1,2,2,2,2,2,2,2,2,2,2,2]+18/20=>_.q].p});
P.synthV(role:\spock,
	filter: (midinote: _ - 12), 
	params: {|p b| [
	lyrics: "this vault was constructed + + about + a half million + years ago +",
	vocalMode: \Closed,
	loudness: Env( [4,5,4,4,5,4,4,4,4,5,4,4,5,4,4] - 4 * 4 - 1, b )
] }, music:{|p b e|
	{
		e.playbuf
		// => FreeVerb.ar(_,1,[ 0.4, 0.5 ])
		=> p.synthVTracks.at(e.key).()
	}.play
});
P(\trill,start:\vault,music:{|p b e| 
	p.changeTrill.(6.5)
});
["About the same time the planet surface was destroyed, if our sensor readings are accurate. ","5 6 7 11 3".dm(\f,4,\minor) ++ "6 7 11 13 12 11 7 6".dm('f#',4) ++ [ 1,2,3,4,-5,4,3,2 ].dm(\d,5,\diminished)].addLine;
P.synthV(Trek.cast.spock,
	filter: (midinote: _ - 12), 
	prepend: true,
	params: {|p b| [
	lyrics: "About + the same time the planet + surface + was destroyed + if our readings + are accurate + + " ,
	vocalMode: \Closed,
	legato:[1,1,1,1,1,1,1,1,1,1,1,1,0.8,1,1,1,1,1,1,1,1],
	loudness: Env([0,4,0,4,4,0,4,0, 4,0,0,0,4,4,0,4,0,0,4,0,0] - 2,b)
] }, music:{|p b e|
	{
		e.playbuf
		=> p.synthVTracks.at(e.key).()
	}.play
});
P(\bass,start:\surface,music:{|p b e| 
	[
		freq: 
		\r.bubble ++ [1,-7,3].df('a-',3,\mixolydian) => _.flat => _.q,
		dur: b.parse([4,4,4,4]).q,
		instrument:\sawSynthSustain,
		att:2,
		amp:0.07
	].pp;
});
["KIRK:(boom) Composition of walls? ","-4 4 5 4 3 4 7".dm(\c)].addLine;
P.still(\twoShot2, timecode: 935.559.seconds, music: { |p b e|
	 e.still.( 
		wait: b.sum,
		text: ["",""],
	)
});
P.synthV(role:\kirk,
	filter: (midinote: _ - 12), 
	params: {|p b| [
	lyrics: "r composition + + + of walls?",
	vocalMode: \Clear
] }, music:{|p b e|
	{
		e.playbuf
		=> p.synthVTracks.at(e.key).()
	}.play
});
// P.tune(\Composition,Pdrop(1,_),syl:0);
P('wall',start:'KIRK:(boom)',syl:5,music: {|p b e|
	{
		[3,3,5,7].df(\g,\mixolydian)
		=> Saw.ar(_,0.1)
		=>MoogFF.ar(_, 
			freq: Env.triangle(b[0] + 6, 9000).kr(0,gate:1) +100 ,
			rq:3.0
		)
	}.play
});
P(\triller,start:\Composition,music:{|p b e| 
	var envBus=Bus.control;
	var envBus2=Bus.control;

	p.changeTrill.(6);
	{Line.kr (0,0.5,9)}.play(s,envBus)
	{Line.kr (0.1,0,12)}.play(s,envBus2);


	fork{
		0.3.wait;
		p.trillSynth[0].register;
		p.trillSynth[0].onFree({envBus.free;envBus2.free});
		p.trillSynth.do({
			|i|
			i.map(\noise,envBus);
			i.map(\amp,envBus2);
		});
	}
});
["SPOCK: They're an alloy or substance completely unknown to me.","5 6 11 6 5 11.5 6 4 12 11.5 12 12 13 11.5 6".dm('e-',4)].addLine;
P.still(\twoShotAlloy, timecode: 937.116.seconds, music: { |p b e|
	 e.still.( 
		wait: b.sum,
		text: ["",""],
	)
});
P.synthV(role:\spock,
	filter: (midinote: _ - 12), 
	params: {|p b| [
	lyrics: "They're an alloy + or substance + completely + + unknown + - to me.",
	vocalMode: \Closed,
	loudness: Env([0, 1, 2 ,1, 0, 3, 1, 0, 4, 2, 1, 4, 2, 0], b),
	legato: [1,1,1,0.7, 1, 1, 0.8, 1, 1, 1, 1, 1, 1, 1, 0.7],
	lag: [0,0,0,0,0.1,0,0,0,0,0,0,0,0,0,0]
] }, music:{|p b e|
	{
		e.playbuf
		=> p.synthVTracks.at(e.key).()
	}.play
});
// P.tune(\alloy);
P('lick',start:\alloy,music: {|p b e|
	MegaBind(
		[
			[ 5, 6,  11, \_, \r, 11.5, \_, \_, 6, \_, \_, \r, 5 ],
			[-5, -6, 1,  -6, -5, -4,   \_, \_, -3, \_]
		].df('e-')
		,
		b,
		[
			amp:[0.7, { Env.linen(0,b.parse([5]),b[6..10].sum +3).kr(0,gate:1) }]
		],
		{|i| 
			Saw.ar(i.freqSeq * [1, LFBrownNoise1.kr([ 1,1.01 ]).range(0.99,1.005)] ,0.1)
			* Env.asr(0,1,8).kr(2,gate:i.gateSeq)
			/8
			* i.amp
		},
		{|i|  Mix.ar(i)
		=> DWGReverbC1C3.ar(_, len:3000, c1:1, c3:10, mix:1, coefs:nil, perm:nil, doprime:0)
		=> BPeakEQ.ar(_,1500,2,-9)
	}
	).play
});
P(\triller,start:\alloy,music:{|p b e| 
	p.changeTrill.(6.5,2, p,b/0.8,e);
	{ Env([0.1,0.1,0.0001],[1,9],\sin).kr(2) }.play(s,Song.trillBus)
});
["Much stronger and harder than-- ","2 6 5 4 3 7 6 5 4".dm('c#',5)].addLine;
P.synthVs(role:\spock, take:[\lead, \dbl],
	pbind:  Song.enlarge(3),
	filter: (midinote: _ - 12), 
	params: {|p b| [
	lyrics: "much stronger + and - harder + than - anything + +",
	pitchTake:[1, 3],
	lag: [[0.05,0,0,0,0,0,0,0,0, 0,0,0]],
	loudness: Env([0,4,2,2,1,4,2,2,1],b),
	legato: [[1, 1, 0.85, 1, 1, 1, 1, 1, 1, 1, 1, 0.8, 1, 1, 0.7 ]],
	paramTension:0.5
] }, music:{|p b e|
	{
		e.playbuf
		=> p.synthVTracks.at(e.key).()
	}.play
});
P.tune(\harder, _ <> [instrument:\default, out: Effect.bus({|i| CombN.ar(i)/2+i },)].pm);
P('guitar',start:\Much, music: {|p b e|
	MegaBind(
		[
			[5,5,5,5,5],
			[1,-5,1,-5,1],
			[2,\_,3,\_],
			[12,\_,13,\_],
		].df('c#')
		,
		b.parse([1,2,2,2,2]),
		[],
		{|i|  
			//SinOsc.ar(i.freqSeq,0,0.1)
			Gendy2.ar([ 3,2,1 ], [ 4,5,6 ], 1.0, 1.0, i.freqSeq *0.98, i.freqSeq * 1.02, ampscale:0.9, durscale:0.9, initCPs:[ 12,2 ], knum:[2,12])
			/2 + Gendy1.ar([ 3,2,1 ], [ 4,5,6 ], 1.0, 1.0, i.freqSeq *0.98, i.freqSeq * 1.02, ampscale:0.9, durscale:0.9, initCPs:[ 12,2 ], knum:[2,12])
			=> HPF.ar(_,150)
			* Env.asr(0,b.sum,2).kr(2,gate:i.gateSeq) /50
	},
		{|i|  Mix.ar(i) 
		/3 

		=> Out.ar(2,_) 
		
	}
	).play
});
P(\bass,start:\harder,music:{|p b e| 
	[
		freq: "2 5 1 5".df('c#',[3]).q,
		dur: b.parse([1,2,2,4]).q,
		instrument: \sawSynthSustain
	].pp

});
P('kerRecorde',start:\harder,music: {|p b e|
	[
		dur: [ 1.136, 1.005, 0.547, 2.382, 1.457, 2.081 ].push(1,0.85).push(4,0.93).push(5,0.95).warpTo( b ).q,
		amp: [0,5,4,3,5,4,3]/10 => _.q,
		rest: [\r,1,1,1,1,1,1].q,
		instrument:\cymbal_808,
		out:Effect( { |i| SineShaper.ar(i,0.2,5) * [0.8,0.2] =< CombN.ar(_,0.1,0.3,decaytime:2,mul:0.4) *0.7  } ).bus.index ,
		CombN.ar()
	].pp
});
["anything I've measured before. ","3 2 1 -7 -6 -5 -4 1 2 ".dm('b-',5,\mixolydian)].addLine;
P.synthVs( role: \spock, take: [\lead, \dbl],
	filter: (midinote: _ - 12), 
	params: {|p b| [
	lyrics: "r r r  I've measured + before + -",
	legato:[[1, 1, 1,  1, 1, 1, 1, 1, 2]],
	pitchTake:[[1, 3]],
	paramTension:0.5,
] }, music:{|p b e|
	{
		e.playbuf
		=> p.synthVTracks.a(e.key).()
	}.play
});
// Song.durs[\measured] =  Song.durs[\measured].list.dropLast ++ (Song.durs[\measured].list.last  * 0.66 ) => _.q;
Song.durs.filter(\measured, {|i| var last = i.last; i.dropLast ++ (last * 2.5)});
Song.setTempoMap(\measured, "e e ee|q e | e x x x xeq".asBeats);
P(\crash,start:\measured,music:{|p b e| 
	(
		instrument:\cymbalsDS,
		amp:0.05,
		out: Effect.new(Decimator.ar(_,20000),  out: 0,  inputChannels: 1,  target: nil).bus.index
	).play
});
P('guitar',start:\anything,music: {|p b e|
	MegaBind(
		[
			[5, 7, 11,12, 4, 6, 7].df('b-',\minor),
			[1,3,4,\_, -7, 1.5, 3].df('b-',\minor)
		]
		,
		[ 1.675, 0.838, ( 0.989 * [3,1]/4 ), 0.686,	0.345,	 1.388 ] => _.flat
		+ [0,     0,     0, 0,     (0.25-0.188) + 0.05, -0.7 * (0.25-0.188), 0]
		=> _.warpTo(e.tempoMap),
		[],
		{|i|  
			//SinOsc.ar(i.freqSeq,0,0.1)
		Pluck.ar( PinkNoise.ar(0.1),i.trigSeq,1,   ( i.freqSeq + 0.0001 ).reciprocal* [4,8] ,decaytime:10)
			=> CrossoverDistortion.ar(_,amp:0.20,smooth:0.9)
			+ (i==0).if { VarSaw.ar(i.freqSeq + SinOsc.ar([5,6]).range(0,5),0,0,mul:0.01) }{0}
			* ( Env.asr().kr(2,gate:(i.gateSeq))  
			//+ Env.perc(0.01,1).kr(0,gate:i.trigSeq)
		)
			//* Env.perc(i.gate).kr(2,gate:1)

		},
		{|i|  Mix.ar(i)
		=> BRF.ar(_,1200,1)
	}
	).play
});
P(\bass, music: { |p b e|
	[
		
			freq: [1,3,4,4, -7, 1.5, 3].df('b-',2,\minor).q,
			dur: [ 1.675, 0.838, ( 0.989 * [3,1]/4 ), 0.686,	0.345,	 1.388 ] => _.flat
			+ [0,     0,     0, 0,     (0.25-0.188) + 0.05, -0.7 * (0.25-0.188), 0]
			=> _.warpTo(e.tempoMap) => _.q,
	].pp
});
["MULHALL: All readings are off the scale, Captain. (ooh) "," 6 5 4 3 2 1 7 6 5 4.5".dm(\d,5,\mixolydian)].addLine;
P.still(\mulhall_and_mccoy, timecode: 944.87.seconds, music: { |p b e|
	 e.still.( 
		wait: b.sum,
		text: ["all readings are","off the scale, Captain"],
	)
});
Song.setTempoMap(\scale,"q Q Q Qq Q E q e e q".asBeats);
P.synthVs(role: \mulhall, take: [\lead, \dbl],
	pbind: {|p b| [ dur:p.tempoMap[\scale].quantize(1,0,7).durs.q, midinote:p.tune[p.section(\scale)]  ].p },
	params: {|p b| [
	lyrics: "all readings + are off the scale captain + r",
	legato: [[1, 1, 1, 0.9, 1, 1, 1, 1, 1, ]],
	vocalMode: \Opera,
	pitchTake:[1,3]
] }, music:{|p b e|
	{
		e.playbuf
		=> p.synthVTracks.at(e.key).()
		/2
	}.play
});
P('bass',start:\All,music: {|p b e|
	[
		instrument: \pulse_gentle,
		pw:Pwhite(0.1,0.4,inf),
		pitch:1.df(\d,octave:2),
		envAmount:2,
		filterfreq:Pwhite(400,1200,inf),
		dec:1,
		dur:0.25! 26 => _.warpTo(e.tempoMap.quantize(1,0,7)) => _.q(2) => _.fin(28),
		rest: \r!4 ++ (1!32) => _.flat => _.q,
		amp:0.15
		//vol:0.08
	].p.play
});
P(\chords,start:\scale,music:{|p b e| 
	[
		instrument:\pluckDVerb,
		freq: [[1,3],[1,3], -7,1,1,1].df(\d,5,\mixolydian).q,
		//dur:b.parse([1,3]).q
		dur: "q qq x x x xq".asBeats.warpTo(e.tempoMap.quantize(1,0,7)).q,
		amp:0.03,
		out: Effect.bus( _ * EnvGen.cutoff(b.sum,2), inputChannels:2 )
	].ppm
});
// P.tune(\scale, { |i| Pmul(\freq,[1,2],i).fin(9) => Pset(\dur, Song.tempoMap[\scale].quantize(1,0,7).durs.q ,_)  } );

P(\triller,start:\scale,syl:8,music:{|p b e| 
	p.changeTrill.(5.5,p,b,e,octave:4);
	(
		instrument:\stringyy,
		attack:5,
		freq:[1,3].df('a-',[4,5]),
		dur:b.sum+e.bNext.sum,
		amp:0.2
	).play;
	Song.trillBus.set(0.05)
});
P('click',start:\All,music: {|p b e|
	[
		instrument:\sn_808,
		dur:1.dup(7).warpTo(e.tempoMap.quantize(1,0,7)).q
	].p//p
	//=>  { |i| Ptpar( [ [1].warpTo(e.tempoMap.quantize(1,0,7)).unbubble, i ] ).play} 
});
P('cymbal',start:\All,music: {|p b e| 
	var dur,pat = "k k s ks ks kk s k k k s " ; 
	dur = pat.split(Char.space).collect{  // function to make "words" into subarrays
		|i| 
		( i.size == 1 ).if{
			i.asSymbol 
		}{
			i.asList.collect({|j|j.asSymbol})
		}
	}.deepCollect(2,{1}).subdivide;
	[ 
		inst: [1] ++ pat.replace(Char.space).asArray => _.q,
		instrument: [\r, Pfunc({|e| ( e.inst == $k ).if{\kick_gentle}{\sn_808}})].q(2),
		vol:0.1,
		dur:  [2] ++ dur /2 => _.warpTo(e.tempoMap.quantize(1,0,7)) => _.q(2) ,
	].p.play;
	[
		instrument:\cymbal,
		amp:0.7,
		dur: [1,1].warpTo(e.tempoMap.quantize(1,0,7)).q,
		rests: [\r,1].q].pp
});
["MCCOY: The air seems fresh. It must be re-circulated somehow. ","4 3 2 5 ".dm(\c) ++ "4 5 6 7 6 5 4 2 4 3.5".dm(\c,5,\minor)].addLine;
P.still(\mccoy_speaks, timecode: 949.01.seconds, music: { |p b e|
	 e.still.( 
		wait: b.sum,
		text: ["the air","seems fresh"],
	)
});
P.synthV(role: \mccoy, take: nil, params: {|p b| [
	lyrics: "the air seems fresh it must be recirculated + + + + somehow + ",
	legato: [1,  1,   1,     0.8, 1, 1, 1,   1,  1,  1,  1,  1,  1,  1],
	lag:[0.05, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0,]
	// language: \chinese,
	// phoneset: \xsampa
] }, music:{|p b e|
	{
		e.playbuf
		=> p.synthVTracks.at(e.key).(0.04)
	}.play
});
P('trill',start:\MCCOY,music: {|p b e|
	p.changeTrill(5.5,p,b,e);
	p.trillBus.set(0.05)
});
P(\chord,start:\circulated,music:{|p b e| 
	var a = [
		freq:"16 15 14 13 12 11 5.5 4 5.5 11 12 14 16 21".df(\c,3).q,
		dur:b.q,
		out:3
	].p;
	a <> [instrument:\sparkTriangle,amp:0.06].p => _.play;
	a <> [instrument:\wash,amp:0.02,out:1].p => _.play;
	a <> [instrument:\stringyy,amp:[0,0,0,0,1,1,1,1,1,1,1,0.8,0.7,0.4].q/2,out:1].pm(\stringyy) => _.play;
	[
		freq:"16 15 14 13 ".df(\c,3).q,
		dur:b.q,
		out:2
	].pp;
	[
		freq:"1 1 1 1".df(\c,4).q,
		dur:b.q,
		out:2
	].pp;
});
P.synthV("", 
	filter: (midinote:  "16 15 14 13 12 11 5.5 4 5.5 11 12 14 16 21".dm(\c,3) ), 
	params: {|p b| [
	lyrics: "r r r r oo - - - - - - - - - ",
] }, music:{|p b e|
	{
		e.playbuf
		=> AnalogVintageDistortion.ar(_)
		/ 8
		=> p.synthVTracks.at(e.key).()
	}.play
});
P.tune(\circulated);
["KIRK: Is that for us, or does it need fresh air? ","1 2 3 5 4 5 6 4 3 1.5 ".dm(\g,4,\whole)].addLine;
P.still(\twoShotKirkTalk, timecode: 952.7.seconds, music: { |p b e|
	 e.still.( 
		wait: b.sum,
		text: ["is that for","us"],
	).sequenceText2(
			b.parse([4]), [ 
			["or does it","need fresh air"],
			],
	)
});
P.synthV(role:\kirk,take: \lead, params: {|p b| [
	lyrics: "is that for us or does it need fresh air",
	legato:[1,1,1,0.7, 1, 1, 0.7, 1, 1, 1],
	loudness: Env([0,4,0,5,1],b.parse([3,1,2,3])),
	// paramGender: 0.3
	vocalMode:\Clear
]   
}, music:{|p b e|
	{
		e.playbuf
		=> p.synthVTracks.at(e.key).()
		/2
	}.play
});
P(\middleLine, music: { |p b e|
	[
		freq: [\r, 1, 1.5, \r].df(\g,4).q,
		dur: b.parse([3, 4, 2]) ++ e.bNext  => _.q,
		instrument: \stringyy, amp: 0.2,
		freqLag: 3.5
	].ppm;
	[
		freq: [\r, 1, \r, \r].df('e-',3).q,
		dur: b.parse([3, 3, 4]) ++ e.bNext  => _.q,
		lagTime: 2,
		att:4,
		instrument: \sawSynthSustain, amp: 0.05,
		// amp: 0.5,
		out:1
	]//.ppm
});
P('tril',start:\that,music: {|p b e|
	//p.changeTrill.(5);
	
	Song.trillSynth.do(_.set(\higher,7.df))
});
// P.tune('Is that for us');
P(\pad,start:'fresh air',music:{|p b e| 
	(
		freq: [-1,1,3,5].df(\g,5,\whole),
		instrument: \wash,
		curve:2,
		att: 2.5,
		rel:5,
		amp:0.03
	).play;
	fork{
		b.parse([6]).unbubble.wait;
		(
			freq:[1,11].df(\f,4),
			instrument:\sawSynthSustain,
			att:5,
			rel:7,
			dur: b.parse([6,4]).tail.unbubble,
			amp:0.03
		).play
	}
});
P(\itAccent, music: { |p b e|
	[
		freq: [\r,1.df('e-',4), 1.df(\f,[4])].q,
		instrument: \harp,
		out: Effect.bus({|i| FreeVerb.ar(i,0.5,1) => Pan2.ar(_, SinOsc.kr(2.5)) }/5,),
		dur: b.parse([3,3, 4]).q
	].pp
});
["(door opens and...)","f#"].addLine;
P.still(\door, timecode: 958.25.seconds, music: { |p b e|
	 e.still.( 
		 fadeIn:1,
		wait: b.sum + e.bNext.sum,
		text: ["",""],
	)
});
P.still(\closedd,lag:0.01, timecode: 957.29.seconds, music: { |p b e|
	 e.still.( 
		// wait: b.sum,
		wait: 1,
		fade: 3,
		text: ["",""],
	)
});
P(\door,start:\opens,music:{|p b e| 

	(instrument:\stringyy,dur:b.sum,amp:0.4,freq:[-1,-11].df('f#'),attack:5).play;

});
P(\crunch,start:\opens,music: { |p b e|

	{
		SinOsc.ar(
			0,
			LFBrownNoise2.ar(
				Env([100,2000,2000,100],[4,b-8,6],\sin).kr(2,gate:1)
			), 
			0.1
		) 
		=> {|i| i + BPF.ar(i, freq:[-1,-11].df('f#'), rq:0.15)}

	}.play
});
["I am Sargon!","1 2 1 -7 -7".dm('b',5,\harmonicMinor)].addLine;
P.still(\globe,lag:0.5, timecode: 1005.24.seconds, music: { |p b e|
	 e.still.( 
		 fadeIn:2,
		wait: b.sum,
		text: ["I","am Sargon"],
		fade:2
	)
});
P.still(\clear, timecode: 0.seconds, music: { |p b e|
	 e.still.( 
		wait: b.sum + 2,
		text: ["I","am Sargon"],
	)
});
P.synthV(role: \vocoder, params: {|p b| [
	filter: (midinote: 40), 
	lyrics: "ai am sar - gone",
	language: \english,
	phoneset: \arpabet,
	paramGender: 0.3
] }, music:{|p b e|
	p.vocodeTune.(p,b,e,e.rpp,
		chord:#[1,2,4,5,6,7,8]*2,
		width:1.03,
		mix:0.5,
		amp:0.8
	)
});
// P.tune(\Sargon);
P('tril',start:\Sargon,music: { |p b e|
	Song.changeTrill.(4.5);
	{Env([0.1,0],3).kr(2,gate:1)}.play(s,p.trillBus)
});
P(\chords,start:\Sargon,music: { |p b e|
	[
		freq: [[1, 2, 1, -7, -7],[11, 12, 11, 7, 7], 3, 5].flop.df(\b,\harmonicMinor) *.t [0.5,1] /[4,2] => _.q,
		dur: b.q,
		amp:0.05,
		out: Effect( TwoTube.ar(_, k:0.01, loss:0.98, d1length:666, d2length:[ 412, 513 ], mul:1.0, add:0.0), inputChannels:4, out: [0, p.carrierBus.ar ] ).bus.index
	].pp
});
}
)
