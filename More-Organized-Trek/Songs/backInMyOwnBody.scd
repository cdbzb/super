(
	Song('MandT',[]).current;
	Song.synthVTracks=EventWithDefault();
	Song.synthVTracks.aiko = { |preGain=1 ratio=2 amp = (1/8) len=2000 mix=0.1 c1=2 | //c1=1
	{ |i|
		i.() * preGain
		=> SoftKneeCompressor.rms(_,  thresh:-10, ratio: ratio, knee:6, attack:0, release:0.05, makeUp:0, rms:40) 
		* amp
		=> DWGReverbC1C3.ar(_,c1:c1,len:len,mix:mix)
		=>.first DetectSilence.ar(_,doneAction:2, time: 0.25)
	}
};
	Song.synthVTracks.default = Song.synthVTracks.aiko;
	"/Users/michael/tank/super/More-Organized-Trek/Songs/boilerplate.scd" => Require(_);

	// Require("McCoyAndThalassa.scd");
	// "./McCoyAndThalassa.scd".standardizePath.load;
["McCoy leaves the room-1, and the door shuts-2 and locks-3 behind him.","1 2 3".dm(\c)].addLine;
P.still(\leavingReverse, timecode: 4612.1.seconds, music: { |p b e|
	 e.still.( 
		wait: b[0],
		text: ["",""],
	);
});
P(\doorcloseLock,syl:0, music: { |p b e|
	
	(
		instrument: \door, amp:0.2, \len:1
	).play
	;
	{
		Impulse.ar(0) => Decay.ar(_,0.3) * WhiteNoise.ar(0.1)
		=> DWGReverbC1C3.ar(_,mix:1,c1:0.3,len:500)
		=> DelayN.ar(_,1,1)
	}.play
});
P.still(\lookBackDoor,syl:1, timecode: 4613.2.seconds, music: { |p b e|
	 e.still.( 
		wait: b.drop(1).sum,
		// wait:1,
		text: ["",""],
	)
});
//this one ends previous
/* P.still(\mccoyLeaves, timecode: 4606.7.seconds, music: { |p b e|
	 e.still.( 
		wait: b.sum,
		text: ["",""],
	)
}); */
P(\arrange, music: { |p b e|
	{
		VarSaw.ar(
			[1,3,5,7,12,14,16].df(\d),
			width: SinOsc.ar( { 0.1.rrand( 0.2 ) }!7, {1.0.rand}!7 ).range(0,1)
		)
		=> Splay.ar(_)
		/20
		* EnvGen.cutoff(b.sum,1)
	}.play;
});
[" --The ship shakes as he activates his desk monitor.-- MCCOY: This is Sickbay. Get me ","-1 -5 5 5 11 4.5 7 11.5".dm(\g)].addLine;
P(\bassnote, music: { |p b e|
	[
		freq: [\r, 1].df(\g,3).q,
		dur: b.parse([4, 4]).q,
		instrument: \sawSynthSustain, amp: 0.08,att:0.5
	].pp
});
P(\otherNote,syl:4, music: { |p b e|
	(
		freq: 1.df('c#',4),
		out:Effect.bus({|i| DWGReverbC1C3.ar(i) }),
	).play
});
P(\shaking, music: { |p b e|
	{
		Gendy2.arWidth(freq: 050,width:{ 1.1.rrand(2) }!4)
		* SinOsc.kr({ 2.rrand(3.0)}!4,{pi.rand}!4 ).range(0.2,1)
		=> Splay.ar(_)
		=> DWGReverbC1C3.ar(_,c1:0,len:623,mix:0.2)
		* EnvGen.cutoff(b[0],6,-5)
		/10
	}.play
});
P.still(\atDesk,syl:1, timecode: 4627.3.seconds, music: { |p b e|
	 e.still.( 
		wait: b.sum,
		text: ["",""],
	)
});
P.synthV(role: \mccoy, take:\lead, params: {|p b| [
	lyrics: "r r  this is sick bay get me",
	filter: (midinote: _ - 24), 
	legato: [1, 1, 1, 1, 1, 0.7, 1, 0.6, ],
	pitchTake: 1
] }, music:{|p b e|
	{
		e.playbuf
		=> p.synthVTracks.at(e.key).()
	}.play
});
P(\door, syl: 6, music: { |p b e|
	(instrument:\door,amp:0.3).play;
	(instrument:\stringyy,amp:0.2,rel:8,freq:1.df('a-',[4,5])).play;
});
[ "(The door opens, and Chapel walks out, staring blankly ahead.) ","r",[5] ].addLine;
P(\chord, music: { |p b e|
	{
		VarSaw.ar(
			[1,3,11,13,].df(\c),
			width: SinOsc.ar( { 0.1.rrand( 0.2 ) }!7, {1.0.rand}!7 ).range(0,1)
		)
		=> Splay.ar(_)
		=> Convolution.ar(_, Dust.ar(300!5) => Decay.ar(_,0.03) => FreeVerb.ar(_,mix: Line.kr(1,0.3,5)))
		/200
		* EnvGen.cutoff(b.sum,1)
		=> Splay.ar(_)
	}.play
});

P.still(\chapelZombie, timecode: 4630.0.seconds, music: { |p b e|
	 e.still.( 
		wait: b.sum,
		text: ["",""],
	)
});
[ "MCCOY: Nurse Chapel, what in the devil?","11 13 6.5 6 6.5 7.5 11 3.5".dm(\g,4,\minor) ].addLine;
P.tune();
P.synthV(role: \mccoy, take: \lead, params: {|p b| [
	lyrics: "Nurse Chapel + what in the devil +",
	legato: [1, 1, 0.6, 1, 1, 1, 1, 0.8, ],
	filter: (midinote: _ - 12), 
	pitchTake: 1
] }, music:{|p b e|
	{
		e.playbuf
		=> p.synthVTracks.at(e.key).()
	}.play
});
//Sickbay
["//[Sickbay]","r"].addLine;
P.still(\surpriseLook, timecode: 4642.seconds, music: { |p b e|
	 e.still.( 
		wait: b.sum,
		text: ["",""],
	)
});
P.still(\aliveKirk, timecode: 4643.8.seconds, music: { |p b e|
	 e.still.( 
		wait: b.sum,
		text: ["",""],
	)
});
["(He goes back into the ward.) MCCOY: Jim? Are you all right? ","2.5 5 4 3 4 11".dm(\d)].addLine;
P(\bassnote, music: { |p b e|
	[
		freq: [ 1, -5 ].df(\f,3).q,
		dur: b.parse([1, 4]).q,
	].p.play
});
P.tune(_ <> [amp: [0,1,1,1,1, 1]/10=>_.q].p);
P(\chords, music: { |p b e|
	[
		freq: [\r, [1, 3, 6].df(\c), [5,7,11,13].df('b-',4,\mixolydian) ].q,
		dur: b.parse([1,4,1]) + [0,0,1] =>_.q,
		instrument: \stringyy, amp:0.2
	].pp
});
P.still(\toKirk, timecode: 4649.3.seconds, music: { |p b e|
	 e.still.( 
		wait: b.sum,
		text: ["",""],
	)
});
["KIRK: Yes, I'm fine, Bones. ","5 4 3 -7".dm('f#',\mixolydian)].addLine;
P.tune();
P.synthV(role: \kirk, take: \lead, params: {|p b| [
	filter: (midinote: _ - 12), 
	lyrics: "yes I'm fine bones",
	legato: [0.8, 0.8, 0.7, 1, ],
	pitchTake: 1
] }, music:{|p b e|
	{
		e.playbuf
		=> p.synthVTracks.at(e.key).()
	}.play

});
P(\bassnotes, music: { |p b e|
	[
		freq: [5, 1].df('f#',3).q,
		dur: b.parse([2,2]).q
	].pp
});
P.still(\kirkTalk, timecode: 4655.4.seconds, music: { |p b e|
	 e.still.( 
		wait: b.sum,
		text: ["",""],
	)
});
["MCCOY: -boom- Thalassa? ","-1 7 15 13".dm(\e,\mixolydian)].addLine;
P.still(\thallassa, timecode: 4659.5.seconds, music: { |p b e|
	 e.still.( 
		wait: b.sum,
		text: ["",""],
	)
});
P.still(\toThal, syl:0, timecode: 4702.6.seconds, music: { |p b e|
	 e.still.( 
		wait: b.drop(1).sum,
		text: ["",""],
	)
});
P(\thinPad, music: { |p b e|
	
	[
		// instrument: \wash,
		freq: [\r, 1].df(\e,3).q,
		amp:0.1,
		dur: b.drop(1).parse([2,2]).q
	].p.play
});
P(\notes, music: { |p b e|
	[
		freq: [\r,7, [ 13, 15 ]].df(\e,\mixolydian).q,
		dur: b.parse([1, 1, 2]).q,
		instrument: \wash
	].pp
});
P.synthV(role: \mccoy, take: \lead, params: {|p b| [
	filter: (midinote: _ - 24), 
	lyrics: "r thalassa + +",
	pitchTake: 1
] }, music:{|p b e|
	{
		e.playbuf
		=> p.synthVTracks.at(e.key).()
	}.play
});
["MULHALL: (boom) She is now with Sargon, Doctor. ","-6 1 2 3 6 5 3".dm(\c)].addLine;
P.still(\Mulhall,syl:0, timecode: 4709.seconds, music: { |p b e|
	 e.still.( 
		wait: b.drop(1).sum,
		text: 
				["she is with Sargon","now"],
		fade: e.bNext.sum
	).sequenceText2(
			b.drop(1).parse([6]), [ 
			["",""],
			],
	)
});

P(\bass, music: { |p b e|
		[
			freq: [-6, 2].df(\c,[3,4]).q,
			dur: b.parse([4,3]).q
		].pp
	});
P.synthV(role: \mulhall, take: \lead, params: {|p b| [
		lyrics: "r she is with sargon + now",
		pitchTake: 1
	] }, music:{|p b e|
		{
			e.playbuf
			=> p.synthVTracks.at(e.key).()
		}.play

	});
P(\pad, music: { |p b e|
		[
			freq: [[1,3,5,7], [-4,3,5,7]].df(\a,\minor).q,
			amp:0.02,
			dur: b.parse([4, 3]).q,
			legato: 1,
			instrument: \wash,
			freqLag: 0.05
		].ppm
});
	["I`m Ann Mulhall, back in my own body. ",[-5, 3, 3, 2, 3, 2, 3, 4, 3, 2].dm(\g), ].addLine; // a= Song.durs['back in my'].list
	P.still(\clear, timecode: 0.seconds, music: { |p b e|
		 e.still.( 
			wait: b.sum,
			text: ["I'm Ann Mulhall","back in my own body"],
		)
	});
	Song.setTempoMap('back in my own',"q q q q e e e e q q");
	Song.quarters['own body']=Song.parseBeats('own body',[2,2,2,2,1,1, 1, 1, 2, 2]);
P.synthVs(role:\mulhall, take: [\lead, \double], 
	pbind:{|p b|
		[
			dur: Song.durs['back in my'],
			midinote: Song.tune[Song.section('back in my')]
		].p
	},
	params: {|p b| [
		lyrics:"I'm Ann Mulhall + back in my own body +",
		// lyrics: "aim jain mul hal bak in mai on ba dy" ,
		//lag: [0,0,0,0,-0.06,0,0,0,-0.05,-0.05],
		lag:[[ 0, 0, 0, 0, 0, 0, 0, 0, 0, 0 ]],
		legato: [[1,1,1,0.9, 1,1,1,1,1,1]],
		pitchTake: [1, 3],
		vocalMode: 
		\Power, //Chest Opera
		// \Opera
	] }, music:{|p b e|
		{
			e.playbuf 
			// => FreeVerb.ar(_,0.5,[0.8,0.9])
			=> p.synthVTracks.at(e.key).(mix:0)
		}.play
	});
P(\bass,start:'own body',music:{|p b e| 
		Synth(\cymbalsDS,[out:Effect(_*Line.kr(1,0,5)).bus.index,amp:0.01]);
		[instrument:\hihat,dur:1!15=>_.warpTo(Song.quarters['own body'].quantizeWindow)=>_.q].pp;
		MegaBind(
			[
				[11, 3, 4, 7, 11, 4.5, 7]
			].df(\g, octave:3),
			[3,1,3,1,3,1,3]=>_.warpTo(p.quarters[e.start]);
			,
			[],
			{|i|
				Saw.ar( i.freqSeq,  0.1 )
				+
				Saw.ar( i.freqSeq/2.01,  0.1 )

				* 
				(
					Env.asr().kr(gate:i.gateSeq)
					+
					Env.perc().kr(0,gate:i.trigSeq, levelScale: 0.1)
					/2
				)
			},
			{|i|
				Mix.ar(i) /18
				=> EchoNone.ar(_,0.3,[ b.sum/8,b.sum/6 ],2) 
			}
		).play;
		[dur:"..x...xx..x...xx".asDrumPat(1),instrument:\sn_808].p.play(TempoClock.newFromQuarters(p.quarters[e.start]));
		[dur:"x...x...x...x...".asDrumPat(1),instrument:\bd_808].p.play(TempoClock.newFromQuarters(p.quarters[e.start]))

	});
P.synthVs(\feng, take: [\descant, \descant2],
	pbind: [{|p e|
		[
			midinote: [0,  3, 2, 3, 4].dm(\b) ++ "12 13 11 5".dm(\e), 
			dur: "qqqqqq e e e e".asBeats.warpTo(p.tempoMap['back in my own']) ++ Song.durs['back-in'].list[0..3] => _.flat 
		].p
	},{|p e|
		[
			midinote: [0,  3, 2, 3, 4].dm(\b) ++ "12 13 11 5".dm(\e), 
			dur: "qqqqqq e e e e".asBeats.warpTo(p.tempoMap['back in my own']) ++ Song.durs['back-in'].list[0..3] => _.flat 
		].p
	}],
	params: {|p b| [
		lyrics: "r back in my own body - - + ",
		pitchTake: [1,3]
	] }, music:{|p b e|
		{
			e.playbuf
			=> p.synthVTracks.at(e.key).(mix: 0.05)
		}.play
});
P(\chord, music: { |p b e|
		[
			freq: [
				[-5,1,3].df(\g,4),
				[1,3,5].df(\c,4),
				[-5,1,3].df(\g,4)
			].q,

			dur: b.parse([2, 2, 4]).q,
			out: Effect.bus({|i| BPF.ar(i,[ 1100, 1000 ],0.15) * 4  },)
		].pp
	});
P(\answer,start:'own body',syl:7,music:{|p b e| 
		MegaBind(
			[
				[3, 2, 3, 4].df(\b)
			],
			[1,1,1,1]/2 => _.warpTo(p.quarters[e.start][[5,6,7]]) 
			* 2,
			[],
			{|i|
				LFTri.ar( i.freqSeq ) 
				* Env.asr().kr(gate:i.gateSeq)
			},
			{|i|
				Mix.ar(i) /30 
				=> EchoNone.ar(_,0.2,0.2,5)
				=> Pan2.ar(_,SinOsc.kr(0.7))
				//		=> CrossoverDistortion.ar(_).wet(0.09) / 3
				* Env.linen(0,2,3).kr(2,gate:1)
			}
		).play
	});
	["body back-in-my-own body","12 13 11 5 3 2 3 4".dm(\e) ++ "7 6 7 11 7 6 5".dm(\f)].addLine;
	Song.setTempoMap('back-in',"g Q Q Q e e e e e e e e q e e");
P.synthVs(\kevin, take: [\lead, \double], params: {|p b k| [
		lyrics: "r r r r back in my own bo r r r r r r r r",
		filter: (
			midinote: [-1,-1,-1,-1, 3, 2, 3, 4, 5.5, 5, 4].dm(\e),
			dur: b.parse([1, 1, 1, 1, 1, 1, 1, 1, 5, 1, 1])
		), 
		loudness: Env([0,0,-30],b.parse([8,9])),
		legato: [[1, 1, 1, 1, 1, 1, 1, 1, 2, ]],
		pitchTake: [1, 3],
		lag:[[ 0,0,0,0,-0.03, -0.01,0,0,0,0,0,0,0,0,0,0,0,0,0 ]]

	] }, music:[-1,1].collect{|pan| {|p b e|
		{
			e.playbuf
			=> p.synthVTracks.at(e.key).(mix:0.05)
			=> Pan2.ar(_, pan)
		}.play
	}});

P.synthV(\mo, take: \lower, params: {|p b| [
		lyrics: "r r r r r r r r back in my own body + -",
		filter: (midinote: [1, 1, 1, 1, 1, 1, 1, 1, 2, 2, 2, 2, 1, 1].dm(\g,4)), 
		pitchTake: 1
	] }, music:{|p b e|
		{
			e.playbuf
			=> p.synthVTracks.at(e.key).(mix: 0.1/2)
		}.play
	});
P.synthV(\mo, take: \lead, params: {|p b| [
		lyrics: "r r r r r r r r back in my own body + -",
		filter: (midinote: _ - 12), 
		pitchTake: 1
	] }, music:{|p b e|
		{
			e.playbuf
			=> p.synthVTracks.at(e.key).(mix: 0.1/2)
		}.play
	});
P(\bass, music: { |p b e|
		Synth(\cymbalsDS,[out:Effect(_*Line.kr(1,0,5)).bus.index,amp:0.015]);
		[instrument:\hihat,dur:0.5!15=>_.warpTo(e.tempoMap.quantizeDft(0.99))=>_.q].pp;
		MegaBind(
			[
				[6, 12, 6.5, 11 ]
			].df(\g, octave:3),
			"qee qq qq".asBeats.warpTo( e.tempoMap.quantizeWindow )
			,
			[],
			{|i|
				Saw.ar( i.freqSeq,  0.1 )
				+
				Saw.ar( i.freqSeq/2.01,  0.1 )
				* 
				(
					Env.asr().kr(gate:i.gateSeq)
					+
					Env.perc().kr(0,gate:i.trigSeq, levelScale: 0.1)
					/2
				)
			},
			{|i|
				Mix.ar(i) /18
				=> EchoNone.ar(_,0.3,[ b.sum/8,b.sum/6 ],2) 
			}
		).play;
		// [dur:"..x...xx..x...xx".asDrumPat(1),instrument:\sn_808].p.play;
		[dur: "e q x xe q x x".asBeats.warpTo( e.tempoMap.quantizeDft(0.9)) * 2 => _.q,instrument:\sn_808, rest:[\r, 1, 1, 1, 1, 1, 1, 1].q].pp;
		[dur: "q q q q".asBeats.warpTo( e.tempoMap.quantizeDft(0.99)) * 2 => _.q,instrument:\bd_808 ].pp;
		// [dur:"x...x...x...x...".asDrumPat(1),instrument:\bd_808].p.play(TempoClock.newFromQuarters(p.quarters[e.start]))

	});
	["(Then we see the three blackened and broken spheres.) ",[1,2,3].dm(\f),[3,1.5,3]].addLine;
	P(\cymbal, music: { |p b e|
		(
			instrument: \cymbalsDSStereo,
			amp:0.001,
		).play;
		(
			instrument: \cymbalsDS,
			att:1,
			amp:0.02
		).play
	});
P(\clang,start:'broken',music:{|p b e| 
			[
				freq: [\f,\g,\A].collect{|i| [-21,-11].df(i)} => _.q,
				out: Effect( { |i| PlateReverb.ar(i)  * Env.linen(0,b.sum,4).kr(gate:1) * 3}).bus.index,
				dur: b ++ [1] => _.q
			].pp;
			{
				
				VarSaw.ar(
					Gendy2.ar(
						minfreq:Gendy2.ar(minfreq:0.2,maxfreq:0.3).range(3,4),
						maxfreq:Gendy2.ar(minfreq:0.1,maxfreq:0.2).range(1,2) + { 1.0.rand }!5
					).range(200,400 + Line.kr(0,300,5)),
					
				)
				/100
				=> CrossoverDistortion.ar(_)
				/200
				* Env([0,1,0],[ b.sum ] ++ 0.1 ).kr(2,gate:1)
			}.play
	});
P(\sizzle,syl:1, music: { |p b e|
		{
		PinkNoise.ar(
				Line.kr(0,0.1!4,b.drop(1)[0])
			)
			* EnvGen.cutoff(b.drop(1)[0],0)
			=> HPF.ar(_,70)
			* -3.dbamp

		}.play
	});
P.still(\one, timecode: 4713.66.seconds, music: { |p b e|
		e.still.( 
			wait: b[0],
			text: ["",""],
		)
	});
P.still(\two,syl:0, timecode: 4717.seconds, music: { |p b e|
		e.still.( 
			wait: b.drop(1)[0],
			text: ["",""],
		)
	});
P.still(\three,syl:1, timecode: 4721.seconds, music: { |p b e|
		e.still.( 
			wait: b.drop(1)[0],
			text: ["",""],
		)
	});
	["MCCOY: Jim, the receptacles. Spock's consciousness was in one of them. ",[3,2,1,5,4,3].dm(\g) ++ [2, 5, 4, 3, 1].dm('a-',scale:\whole) ++ [11, 6, 4, 2].dm(\f,scale:\minor)].addLine;
	P.still(\MccoyHorrified, timecode: 4724.seconds, music: { |p b e|
		 e.still.( 
			wait: b.sum,
			text: ["Jim","the receptacles"],
		)
	});
	P(\dyads, music: { |p b e|
		[
			freq: [\r, 1, 5, 3, 6, 1.5, 7, 1].df(\g,3,\dorian).q,
			dur: b.parse([2,1, 3, 1, 3, 1, 3,1]).q,
			legato: [1, 4, 1, 4, 1, 4, 3, 2].q,
			amp:0.1,
			pan: [-1,1].q(inf),
			out: Effect.bus({|i| i=> SineShaper.ar(i,0.04)=>FreeVerb.ar(_, 0.3,0.9) * 2 
			=> HPF.ar(_,400,1.5)
		},inputChannels:2)
		].pp
	});
P(\bassNotesOne, music: { |p b e|
		{
			var freq = [3.df(\g),[2,1].df('a-',scale: \whole),2.df(\f)].flat.dq.demand(b.parse([6,4,4,1])) /4;
			Gendy2.ar(minfreq:freq * 0.9,maxfreq:freq * 1.1)
			* Env.perc(0.05,b.sum).kr(0,gate:1)
			=> CrossoverDistortion.ar(_,amp: Line.kr(1,0,b.sum -1))
			/20
			* EnvGen.cutoff(b.sum-1,2)
		}//.play(s,3)
		;
		[
			instrument: \harp,
			freq: [3.df(\g),[2,1].df('a-',scale: \whole),2.df(\f)].flat.q / 4,
			dur: b.parse([6,4,4,1]).q,
			decaytime: b.sum,
			legato: 1,
			out: Effect.bus({|i| CrossoverDistortion.ar(i, gain: 0.2) / 15 => FreeVerb.ar(_,1,1)  },)
		].pp
	});
	( Trek.presets.put(\mccoy, \xuan, [
		\paramTension,1,
		\paramGender, 0.1,
		\paramToneShift, 200

	] );
);
P.synthVs(role: \mccoy, take: [\lead, \double], params: {|p b| [
	lyrics: "Jim, the receptacles + + + Spock's consciousness + + was in one of them. ",
	filter: (midinote: _ - 12), 
	legato: [[0.5, 1, 1, 1, 1, 0.5, 1, 1, 1, 1, 1, 0.8, 1, 1, 1, ]],
	pitchTake: [1,3],
	vocalMode: \Solid,

] }, music:{|p b e|
	{
		e.playbuf
		=> p.synthVTracks.at(e.key).(mix:0.05)
	}.play

});
P(\noise, music: { |p b e|
	{
		Dust.ar(50!5)
		* EnvGen.cutoff(b.sum,0.1)
		/3
	}.play
});
["KIRK: (boom) It was necessary. ",[-2, 5, 5, 11, 5, 3, 1].dm(\c,scale:\minor)].addLine;
P.still(\kirkNecessary, timecode: 4728.35.seconds, music: { |p b e|
	 e.still.( 
		wait: b.sum,
		text: ["",""],
	)
});
P.synthV(role: \kirk, take: \lead, params: {|p b| [
	lyrics: "r it was necessary + + +",
	filter: (midinote: _ - 12), 
	pitchTake: 1
]}, music:{|p b e|
	{
		e.playbuf
		=> p.synthVTracks.at(e.key).()
	}.play

});
P(\bassnote, music: { |p b e|
	(
		instrument: \pluckD,
		freq: [-12, -22].df(\c),
		amp: 0.01,
		out: Effect.bus({|i| FreeVerb.ar(i,1,[0.8,0.9,1],mix:0.5) * EnvGen.cutoff(0,8!3) },)
	).play
});
P(\chord, syl:2, music: { |p b e|
	{ |gate=1 out=0 |
		var in=PinkNoise.ar(1);
		var sig=Pluck.ar(in: in,  gate: gate,  maxdelaytime: 0.02,  delaytime: 1/[-1,1,3,5,11].df(\c,\minor) + Gendy1.arWidth(2).range(-0.0002, 0.0002),  decaytime: \decaytime.kr(10),  coef: \coef.kr(0.2),  mul: 0.7,  add: 0);
		sig = sig * \amp.kr(0.1) ;
		sig = DelayN.ar(sig,0.5, 
			Array.fill(5,{0.2.rand}).sort
		);
		// sig =AnalogVintageDistortion.ar(sig, 0.2,0.91) ;
		sig = LeakDC.ar(sig);
		Out.ar(out,sig);
		// DetectSilence.ar(sig,doneAction:2);
	}.play
});
["MCCOY: What are you talking about? There is no Spock to return to his body. (boom) You've ",[-7, -7, 1, 2, 3, 2, -6, -7,  2, 1, 5, 6, 5, 4, 3, 4, 5, 5, 4].dm(\d, scale:\mixolydian) ++ [-5, 5].dm('b-',octave:4)].addLine;
P.still(\mccoyTalkingAbout, timecode: 4732.6.seconds, music: { |p b e|
	 e.still.( 
		wait: b.sum,
		text: ["",""],
	)
});
P.synthV(role: \mccoy, take: \leadTest,
	pbind: Song.enlarge(13),
	params: {|p b| [
		lyrics: "r What are you talking + about? + There is no Spock to return + to his body + r  you've killed a loyal + office + er - r your r best friend!",
		filter: (midinote: {|i| var sections = [20,10,4], transpose = [0, -12, 0]; sections.size.collect{|x| transpose[x].dup(sections[x])}.flat  + i}), 
		legato: [1, 1, 1, 1, 1, 1, 1, 0.7, 1, 1, 1, 0.7, 1, 1, 1, 1, 1, 1, 1, ],
		pitchTake: 1
	] }, music:{|p b e|
		{
			e.playbuf
			=> p.synthVTracks.at(e.key).(mix: 0.1)
		}.play

	});
	// P.tune(\talking);
P(\dyad,start:\talking,music:{|p b e| 
		[
			freq:[\r, [3,5],\r, [1,3, 6],\r, [2,6] ].df(\d, scale:\mixolydian).q,
			instrument: \sparkTriangle,
			dur: b.parse([4,3,4,3, 3,2]).q,
			amp: 0.05,
			depth: 0.01,
			out: Effect({|i| 
				FoaEncode.ar(i,Song.encoders.omni) 
				=> FoaPush.ar(_,0.8,-pi/4)
				=> FoaDecode.ar(_,Monitors.decoder)}
			).bus.index
		].pp
	});
	SynthDef( \gendyPluck, { |gate=1 out=0 freq= 400 |
		var in=PinkNoise.ar(1);
		var sig=Pluck.ar(in: in,  gate: gate,  maxdelaytime: 0.02,  delaytime: 1/ freq + Gendy1.arWidth(\rate.kr(2)).range(-0.0002, 0.0002),  decaytime: \decaytime.kr(10),  coef: \coef.kr(0.2),  mul: 0.7,  add: 0);
		sig = sig * \amp.kr(0.1) ;
		sig = DelayN.ar(sig,0.5, 
			Array.fill(5,{0.2.rand}).sort
		);
		// sig =AnalogVintageDistortion.ar(sig, 0.2,0.91) ;
		sig = LeakDC.ar(sig);
		Out.ar(out,sig);
		// DetectSilence.ar(sig,doneAction:2);
	}).add;
P(\bass,start:\talking,lag: -0.1,music:{|p b e| 
		[
			freq: [-7, 3, 1, 2, 2.5].df(\d,scale:\mixolydian, octave:[3,4]).q,
			dur: b.parse([4, 7, 6, 2]).q,
			instrument:\stringyy,
			release:2,
			legato:1,
			amp:0.25

		].ppm;
		[
			freq: [-7, 3, 1, 2, 2.5].df(\d,scale:\mixolydian, octave:[3,4]).q,
			dur: b.parse([4, 7, 6, 2]).q,
			instrument: \gendyPluck,
			amp: 0.05
		].pp

	});
	["killed a loyal officer,(boom) your (boom) best friend. ",[11,5,11,12,13,12,11,7].dm('b-',octave:4) ++ [-1,5,-4,6,7].dm(\a,scale:\mixolydian, octave:4)].addLine;
	P(\line, music: { |p b e|
		[
			freq: [ 11, 5, 11, 7, 11, 5, 3, 2].df('b-',[3,5]).q,
			dur: b.q,
			rel:[2, 2, 2, 2, 2, 2, 1.5, 1].q,
			instrument: \sawSynth,
			amp:0.03
			// amp:0.3
		].pp
	});
P(\bassMirror,start:\loyal,music:{|p b e| 
		[
			freq: [1, -7, -6, -7, 1].df('b-', octave:[3,4]).q,
			dur: b.parse([3, 1, 1, 1, 2]).q,
			instrument:\sawSynthSustain,
			amp:0.07,
			lagTime:0.1,
			rel:0.5
		].pm(\sawSynthSustain).play

	});
P(\bass2,start:\loyal,syl:7,music:{|p b e| 
		[
			freq: [2,\r, 5,\r, 1].df(\g,octave:3).q ,
			dur:b.drop(1) ++ [ p.durs[e.start+1].list[0] ] => _.q,
			instrument:\sawSynth
		].pp

	});
P(\chord,start:\loyal,syl:11,lag:-0.05, music:{|p b e| 
		(
			strum:0.06,
			freq: [1,3,5,11].df(\g,scale:\minor)
		).play
	});
["KIRK: (boom ba boom ba) Bones, prepare a hypo. The fastest, deadliest poison to Vulcans. ",[-5, -5, -5, -5, 5, 5, 5, 5, 11, 5, 12,  ].dm(\b,octave:4) ++ [12,13,12,5, 13,14,13,6, 14,15,14,5,11,7].dm(\c)].addLine;
P.still(\kirk, timecode: 4739.3.seconds, music: { |p b e|
	 e.still.( 
		wait: b.sum,
		text: ["",""],
	)
});
/*
"ffmpeg /Users/michael/Library/Mobile\\ Documents/QNM6AGD8YW~com~atlantia~SimpleMic/Documents/1649971442.m4a  /tmp/hypo.wav".unixCmd;
~hypo = Buffer.read(s,"/tmp/hypo.wav");
{PlayBuf.ar(1,~hypo) * 0.1}.play


a = "zsxdcvgbhnjm,l.;".asArray
a.indexOf($d)
*/
P.tune(_.fin(4));
P(\bassline, music: { |p b e|
	[
		// freq: [\r, 7, 6, 5, 4, 3, 2, 5].df(\c,3).q,
		// dur: b.parse([8,  [1, 0.5], [0.5, 1],]).q
		freq: [ \r, 7,6, 5, 4, 3,2, 4, 5, 7 ].df(\c,3) ++ 1.df(\a,3) *.t [0.5,1] => _.q,
		dur: b.parse([8, [1,2/3],[1/3,2] ,4, [1,1/3],[2/3,2],[1, 0.5],[0.5,1],2/3,[1/3,1] ]) ++ e.bNext[0..3].sum => _.q,
		amp:[0.05,0.1],
		instrument: \sawSynthSustain,
		pulse: 0.7,
		pulseRel: 2,
		lagTime: 0.1
	].ppm
});
P.synthVs(role: \kirk, take: [\lead, \double], params: {|p b| [
	lyrics: "r r r r Bones, prepare + a hypo + The fastest - + - deadliest - + +  poison - + to Vulcans + ",
	legato: [[1, 1, 1, 1, 0.7, 1, 1, 1, 1, 0.8, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1 , 0.7, 1, 1 ]],
	filter: (midinote: _ - 12), 
	pitchTake: [1, 3]
] }, music:{|p b e|
	{
		e.playbuf
		=> p.synthVTracks.at(e.key).()
	}.play

});
P(\figure, music: { |p b e|
	[
		// midinote: p.tune[e.start]-12, 
		freq: [ 4.5, 4.5, 4.5, 4.5, 4.5, 4.5, 4.5, 4.5,
			7,6, 5, 4, 3,2, 4, 5, 7 ].df(\c,3) ++ 1.df(\a,3)  => _.q,
		dur: b.parse([1, 1, 1, 1, 1, 1, 1, 1, [1,2/3],[1/3,2] ,4, [1,1/3],[2/3,2],[1, 0.5],[0.5,1],2/3,[1/3,1] ]) ++ e.bNext[0..3].sum => _.q,
		instrument: \harp,
		amp: 0.05,coef:0.8,
		// out: Effect.bus({|i| CrossoverDistortion.ar(i,mul:0.1) * EnvGen.cutoff(b[0..7].sum,0) },)
		out: Effect.bus({|i| CrossoverDistortion.ar(i,mul:0.1) * EnvGen.cutoff(b.sum,0) /2 => Pan2.ar(_,-0.7) },)

	].pma => _.play
});
P.tune(\prepare);
P(\lick,start:\fastest,syl:10,music:{|p b e| 
		[
			freq: [\f,'f#',\g].collect( [2,4,7].df(_) ) => _.flat => _.q / 2,
			dur: b.drop(1).q,
			instrument: \sparkTriangle,
			depth:0,
			amp: 0.04
		].ppm()
	});
["(boom boom) Spock's consciousness is-- gone. We must kill his body, the thing in it.",[-1, -3, 3, 4, 4, 4, 3, 2, 2].dm(\a) ++ [2, 3, 6, 7, 11, 5, 11, 12, 11, 5].dm(\e)].addLine;
P.synthVs(role: \kirk, take: [\lead, \double], params: {|p b| [
	lyrics: "r r Spock's consciousness + + is - gone. We must kill his body, + the thing in it.",
	legato: [[1, 1, 1, 1, 1, 1, 1, 1, 0.7,  1, 1, 1, 1, 1, 0.7, 1, 1, 1, 1, ]],
	filter: (midinote: _ - 12), 
	pitchTake: [1, 3]
] }, music:{|p b e|
	{
		e.playbuf
		=> p.synthVTracks.at(e.key).()
	}.play

});
P(\figure,start:'kill his body',music:{|p b e| 
		[
			freq: [1, 3, 5, 1, 4, 6, 11, 3, -7].df(\a).q / [1,2,4],
			dur: b.parse([1, 1, 0.5, 0.5, 1, 1, 1, 2, 1, 1]).q,
			instrument:\sawSynth,
			amp:  [2,2,1] * 0.03
		].pp
});
P(\bassline, music: { |p b e|
	[ 
		freq: [1, 1, 4, 6, 11, 3, -7].df(\a,2).q,
		dur: b.parse([[1, 1, 0.5],0.5, 1, 1, 1,  2, 1]).q
	].pp
});
P.synthV(\kevin, take: \lead, 
	pbind: {|p b|
		[
			midinote: [0, 0, 0,  5, 5, 5, 5, 4.5].dm(\a,4),
			dur: b
		].p
	},
	params: {|p b| [
	lyrics: "r r r consciousness + + is - gone r r r r r r r r r r",
	pitchTake: 1
] }, music:{|p b e|
	{
		e.playbuf
		/6
		// => p.synthVTracks.at(e.key).()
		=> HPF.ar(_,200)
		=> Pan2.ar(_,-0.7)
	}.play
});
P.synthV(\kevin, take: \harmonyTwo, 
	pbind: {|p b|
		[
			midinote: [0, 0, 0,  1, 1, 1, 1,1, -7].dm(\a,4),
			dur: b
		].p
	},
	params: {|p b| [
	lyrics: "r r r consciousness + + is - gone r r r r r r r r r r",
	pitchTake: 1
] }, music:{|p b e|
	{
		e.playbuf
		/6
		=> HPF.ar(_,300)
		=> Pan2.ar(_,0.7)
		// => p.synthVTracks.at(e.key).()
	}.play
});
	
P(\bass,start:'kill his body',syl:12,music:{|p b e| 
		[
			freq: [1, 11, 1].df(\e).q /[ 4],
			dur: b.drop(1).parse([ [1, 1/2],[1/2, 1], 1 ]).q,
		].pma(\default).play;
	});
P(\chords,start:'kill his body',syl:1,music:{|p b e| 
		[
			freq:[[1,3, 5],[1,4, 5],[1,4, 5],[1,4, 5],[1,3, 5],[-7,4.5]].df(\a,4).q,
			dur:b.drop(1).parse([1,1,1,1,2,1]).postln.q
		].pp
	});
P(\guiro,start:'kill his body',syl:11,music:{|p b e| 
		//FIXME!!!!!
		{Shakers.ar(19, 1, 1, 1, 32, 60, Env([0,0.5],1,\sin).kr(0,1))}.play
});
P(\cymbal,syl:7, music: { |p b e|
	{
		{ 300.pareto } ! 40
		// => _.linexp(200,1000,100,10000)
		=> { |i| SinOsc.ar(i,0,10/i)}
		* Env([0,1,0],[ 0.1,6 ]).kr(doneAction:2)
		=> Splay.ar(_)
	}.play
});
P(\chords2,start:'kill his body',syl:12,music:{|p b e| 
		[
			freq: [
				[1,3,5,11],
				[1,3,5,11],
				[2,4,6,12],
				[1,3,5,11],
			].df(\e,scale:\minor).q,
			dur: b.drop(1).parse([2,1,1,2]).q,
			strum: [5, 0.5, 2, 1]/100 => _.q
		]//.pp
		;
	MegaBind(
		[
				[1,3,5,11],
				[1,3,5,11],
				[2,4,6,12],
				[1,3,5,11],
		].df(\e,scale:\minor).flop
		,
		b.drop(1).parse([2,1,1,2]),
		[],
		{
			|i|  
			VarSaw.ar(i.freqSeq/2,0,0.08,0.07)
			* Env.asr().kr(2,gate:i.gateSeq)
			* Env.perc(0.01,2).kr(2,gate:i.trigSeq)
			=> DelayN.ar(_,0.1,{0.1.rand}!4)
			=> {|i| i + Convolution.ar(i=>FreeVerb.ar(_,0.3,1), Dust.ar(20) => Decay.ar(_,0.01),mul:0.1)}
			/4
		},
		{|i|  Mix.ar(i)}
	).play
	});
)

