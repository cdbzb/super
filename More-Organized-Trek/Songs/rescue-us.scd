(
//[Bridge]
Song(\rescue,[]).current;
"~/tank/super/More-Organized-Trek/Songs/boilerplate.scd".standardizePath.load;
Song.synthVTracks = EventWithDefault(
	\default, {
		{
			|i|
			i 
			/ 7
		}
	}
);
// Captain's Log. Stardate 4768.3.
// The Enterprise is in orbit above a planet whose 
// surface, our sensors tell us, 
// is devoid of all life, 
// a world destroyed and dead for at least a half million years. 
// Yet from it comes a voice, 
// the energy of pure thought, 
// telling us something has survived here 
// for those thousands of centuries.

["/*KIRK:*/ (dictating log) Since exploration and contact with alien intelligences is our primary mission, I've decided to risk the potential dangers and resume contact. Log entry out. How long before Starfleet receives that?","r"].addLine;
["/*UHURA:*/ Over three weeks at this distance, sir.","r"].addLine;
["/*SPOCK:*/ Captain.","r"].addLine;
["/*KIRK:*/ Got something?","r"].addLine;
["(boom boom) Sensors registering some form of energy deep inside the planet.","-1 -1 3 1 4 3 1 3 4 5 7 6 4  2 1 -7 -6 -6 -5".dm(\e,\mixolydian)].addLine; /*SPOCK:*/ 
P.synthV(role: \spock, take: \lead, params: {|p b| [
	lyrics: "r r sensors + regist + ring  some kind of energy + + deep inside +  the planet + ",
	filter: (midinote: _ - 12), 
	pitchTake: 1
] }, music:{|p b e|
	{
		e.playbuf
		/ 10 
		// => p.synthVTracks.at(e.key).()
	}.play

});
P.double(role: \spock, take: \lead, params: {|p b| [
	
] }, music:{|p b e|
	{
		e.playbuf
		// => p.synthVTracks.at(e.key).()
		/10
	}.play
});
Song.setTempoMap(\Sensors, "e e e e | E E E E E E | e x xq | Q E Q E e e");
P.tune();
P(\bass, music: { |p b e| //check last note
	[
		freq: [ 1,1,\r,1,1,\r,4,4,\r, 7, 6, 5, 4, 2.5 ].df(\e,[ 3,4 ],\mixolydian).q,
		dur: "e e q | e e q | e e q | e e e e | e".asBeats.warpTo(e.tempoMap).q
	].pp
});
["/*SARGON [OC]*/(boom) Your probes have touched me, Mister Spock.",[-1, 4, 4, 4, 4, 3, 2, 1, 2, 3].dm(\c,\minor)].addLine;
P.synthV(role: \vocoder, take: \lead, params: {|p b| [
	lyrics: "r your probes have touched me mister + spock -",
	pitchTake: 1
] }, music:{|p b e|
	{
		e.playbuf
	};
	p.vocodeTune.(p, b, e, e.rpp)

});
P(\chord, music: { |p b e|
	[
		freq: [-1, 1, 3, 5].df(\f).bubble.q,
		strum: 0.05,
		instrument: \sawSynth,
		out: Effect.bus( FreeVerb.ar(_, mix:1, room:1, damp:[ 0.5,0.6 ]) )
	].pp
});
P(\bass, music: { |p b e|
	[
		freq:[1, 7, 4].df(\f, [2,3],\mixolydian).q,
		dur:b.parse([4,4,2]).q
	].pp
});
["/*SPOCK:*/ Reading energy only, Captain. No life forms.", "1 2 3 2 1 4 2 1 -6 4 5.5 2".dm('f#',\lydian)].addLine;
/*
"open '/Users/michael/trek/BySection/media/11-Spock&Sargon-181021_1557.rpp'".unixCmd
*/
Song.setTempoMap(\Reading,"E E E E E e e e ee e e e");
P(\click, music: { |p b e|
	var dur = 0.125;
	[
		instrument: \sawSynthSustain,
		degree: [0,8,15].q(inf),
		root: [6!( dur.reciprocal*5/3 ),8!( dur.reciprocal *7/3),10!(dur.reciprocal*2)]=> _.flat => _.q,
		// dur: "Q q q q q q".asBeats.warpTo( e.tempoMap ).q,
		dur: (0.125).dup(48).asBeats.warpTo( e.tempoMap.quantizeDft(0.6) ).q,
		octave:4,
		lagTime:0,
		amp:0.03
	].ppm
});

P(\click2, music: { |p b e|
	var dur = 0.25;
	[
		instrument: \stab,
		degree: [0,8,15].q(inf),
		root: [6!( dur.reciprocal*5/3 ),8!( dur.reciprocal *7/3),10!(dur.reciprocal*2)]=> _.flat => _.q,
		// dur: "Q q q q q q".asBeats.warpTo( e.tempoMap ).q,
		dur: (dur).dup(24).asBeats.warpTo( e.tempoMap.quantizeDft(0.6) ).q,
		octave:3,
		lagTime:0,
		amp:Pseries(0.1,-0.005,inf),
		pan:1
	].pp
});
P(\bassline, music: { |p b e|
	[
		
		freq: [1,2,3].df('f#',3).q,
		dur: b.parse([5,3+2,2]).q
	].pp
});
P.synthVs(role: \spock, take: [\lead, \double], params: {|p b| [
	lyrics: "Reading + energy + + only + captain + no life forms",
	filter: (midinote: _ - 12), 
	pitchTake: [1, 3]
] }, music:{|p b e|
	{
		e.playbuf
		// => p.synthVTracks.at(e.key).()
		/10
	}.play

});
[" I have locked your transporter device on my co-ordinates.","5 5 5 6 5 4 3 2 4 3 2 1 3 2 2".dm(\a,4)].addLine;/*SARGON [OC]*/
Song.durs.filter(_ * 1.15);
P.synthV(role: \vocoder, take: \lead, params: {|p b| [
	lyrics: "I have locked your transporter + +  device + on my co-ordinates + + +",
	phonemes: ["","","","","","","","","","","","","","","n eh th s",],
	pitchTake: 1
] }, music:{|p b e|
	p.vocodeTune.(p, b, e, e.rpp)

});
Song.setTempoMap('co-ordinates',"q e eq e eq e eq e eq e eq e eq e eq");
P(\bass, music: { |p b e|
	[
		freq: [6, 5, 4, 5, 6, 7, 11, 5].df(\a,2).q,
		dur: [4,4,1,1,1,1,2,2].warpTo(e.tempoMap).q
	].pp
});
P(\chords, music: { |p b e|
	[
		freq: [ -12,-2,1,3,5,11 ].dup(4) ++ [ -1,1,3,5,11 ] =>_.df(\e) =>_.q,
		dur: "q e eq e eqq".asBeats.warpTo(e.tempoMap).q,
		instrument:\sawSynth,
		out: Effect.bus( 
			{|i|
				i * Env([1,0.3,0.1],b.parse([4,8])).kr(2,gate:1)
				=> DWGReverbC1C3.ar(_)
				=> LPF.ar(_,800)
				/6
			}
		)
	].pp
});
// P.tune();
["Please come to us. Rescue us from oblivion."," 3 3 2 2 4 3 -6 1".dm('f#',\minor) ++ "4 4 3 1".dm(\f)].addLine;
P.synthV(role: \vocoder, take: \lead, params: {|p b| [
	lyrics: "please come to us rescue + us from  oblivion + +",
	filter: (midinote: _ - 12), 
	pitchTake: 1
] }, music:{|p b e|
	p.vocodeTune.(p, b, e, e.rpp,
		dur: b.sum,
		att: 0.2,
		sus: b.sum - 0.2,
		rel: 1
	)

});
P.tune();
P(\laMerChords, music: { |p b e|
	[\A, \c].collect{|i| [1,3,5,6].df(i)}
	=> {|i| 
		[
			freq: [\r] ++ i => _.q,
			dur: b.parse([1, 3, 4]).q,
			instrument:\stringyy
		].pp
	}
});
P(\bass, music: { |p b e|
	[
		freq: [\r,1,-7,6,].df('f#',[3,2],\minor) ++ [5,11].dup.df('f',[3,2]) =>_.q,
		dur: b.parse([1,3, 2,2,  1,3]).q
	].pp
});
P(\answer, syl: 10, music: { |p b e|
	[
		freq: [4,3,1,-6,1,2,3].df(\f).q,
		dur:0.5,
		instrument:\ooh,
		amp:Pseries(0.1,-0.018,inf) / 6
	].pp
});
["/*SPOCK:*/ Coming from deep under the planet's surface, Captain. ","11 12 13 7 12 11 7 5 7 5 4 3 2".dm(\c,\mixolydian)].addLine;
Song.setTempoMap(\Coming,"Q Q Q qq Q Q Q q e eq q q q");
P(\click, music: { |p b e|
	[
		dur: 1!8.warpTo(e.tempoMap)

	].pp8ww
});
P(\chords, music: { |p b e|
	[
		freq: [[5, 7, 11, 13], [3, 5, 7, 11], [2,4,7], [-7,2,5]].df(\c,4,\mixolydian).q,
		dur: "qqqq qqqq qq qq".asBeats.warpTo( e.tempoMap ).q,
		strum: 0.05,
		instrument: \stringyy, amp: 0.1
	].ppm
});
P.synthV(role: \spock, take: \lead, params: {|p b| [
	lyrics: "Coming + from deep under + the planet's + surface + Captain + ",
	filter: (midinote: _ - 12), 
	pitchTake: 1
] }, music:{|p b e|
	{
		e.playbuf
		// => p.synthVTracks.at(e.key).()
		/10
	}.play

});
P.double(role: \spock,
	filter: (midinote: _ ), 
	take: \lead, params: {|p b| [
	pitchTake: 1
] }, music:{|p b e|
	{
		e.playbuf
		// => p.synthVTracks.at(e.key).()
		/ 5
	}.play

});
["Under at least one hundred miles of "," 1 2 3 4 5 4".dm(\f,\lydian) ++ "1 2 3 4 5 4 3".dm(\g,\lydian)].addLine;
P(\bassnotes, music: { |p b e|
	[
		freq: [[-1, 1],-7, -6, -5.5, -6, -5.5, -4.5].df(\f,4).q,
		dur: b.parse([2, 1, 6, 1, 1, 1, 1]).q,
		out: Effect.bus({|i| 
			i * 3
			=> FreeVerb.ar(_,0.5,1) => SineShaper.ar(_,0.05,mul:3)
			++ CrossoverDistortion.ar(i,mul:0.05)
			/5
			* EnvGen.cutoff(b.sum,1)
		},)
	].pp
});



P.synthVs(role: \spock, take: [\lead, \double], params: {|p b| [
	lyrics: "Under + at least - -  one hundred + miles - - of ",
	filter: [(midinote:_),(midinote: _ - 12)], 
	pitchTake: [1, 3]
] }, music:{|p b e|
	{
		e.playbuf
		// => p.synthVTracks.at(e.key).()
		/ 5 

	}.play

});
P.tune();
["(boom boom) solid rock.","-7 1 7 6 7 11  12 12 7".dm(\f)].addLine;
Song.setTempoMap(\solid,"e e e x x qqq e x xq".asBeats);
Song.durs.filter(\solid,{|i| var last = i.last; i.dropLast ++ (last - 0.1)});
P(\kick, music: { |p b e|
	var tm = e.tempoMap.quantizeDft(0.3);
	[
		[
			dur: "x x x xq x x x xq x x x xq E E E ".asBeats.warpTo( tm ).q,
			instrument: \kick_gentle,
			vol: [1,1,1,1,1,1,1,1,1,1,1,1,0.7,0.4,0.2] * 0.3 => _.q


		].p,
		[
			dur: "q ex xq ex x".asBeats.warpTo( tm ).q,
			instrument: \snare,
			rest: [\r,1,1,1,1,1,1].q
		].p,
		[
			dur: "q qq qq qq".asBeats.warpTo( tm ).q,
			instrument: \cymbalsDS,
			amp: 0.03,
			rest: [\r,1,1,1,1,1,1].q
		].p
	] => Ppar(_)
	=> Pset(\out, Effect.bus({|i| SineShaper.ar(i,0.09) /3 }, out: 2),_)
	=> _.play

});
P.synthV(role: \spock, take: \lead, params: {|p b| [
	lyrics: "r r solid + rock - r r r",
	legato: [1, 1, 1, 1, 1, 0.5,  1, 1, ],
	pitchTake: 1
] }, music:{|p b e|
	{
		e.playbuf
		=> p.synthVTracks.at(e.key).()
	}.play

});
P.double(role: \spock, take: \lead, params: {|p b| [
	pitchTake: 1
] }, music:{|p b e|
	{
		e.playbuf
		=> p.synthVTracks.at(e.key).()
	}.play

});
//idea: NineZero here?
P.synthV(role: \spock,take: \harmony,
	pbind: {|p b|
		[
		midinote: "1 11 11 6 5 6".dm(\c),
		dur: 0.5 * "qq q e eqq q q".asBeats warpTo: p.tempoMap[\solid] ,
		].p
	},
	 params: {|p b| [
	lyrics: "r solid + rock baby +",
	legato: [1, 1, 1, 1, 1, 0.5, ],
	pitchTake: 1
] }, music:{|p b e|
	{
		e.playbuf
		=> p.synthVTracks.at(e.key).()
	}.play
});
P.synthVs(\feng, take: [\bg, \bg1], params: {|p b| [
	lyrics: "r r r r r r solid + rock",
	pitchTake: [1,3]
] }, music:{|p b e|
	{
		e.playbuf
		=> p.synthVTracks.at(e.key).()
	}.play
});
P(\harmony, music: { |p b e|
	[
		freq:"r 11 11 6 5 6".df(\c).q,
		dur: 0.5 * "qq q e eqq q q".asBeats warpTo: e.tempoMap q: 1,
		rest: [\r,1,1,1,1,1].q
	].pp
});
P.synthVs(\kevin, take: [\lead, \double], 
	pbind: {|p b|
		[
			midinote: "1 -4 1 -7 -5 2 3".dm(\c),
			dur: "qq q q qq q q ".asBeats.warpTo( p.tempoMap[\solid] ) ++ 1
		].p
	},
	params: {|p b| [
	lyrics: "r solid + rock  r r r ",
	pitchTake: [1, 3]
] }, music:{|p b e|
	{
		e.playbuf
		=> p.synthVTracks.at(e.key).()
		* EnvGen.cutoff(b.sum,0.5)
		=> BPF.ar(_,1000)
	}.play

});
P(\bass, music: { |p b e|
	[
		freq: "3 4 7 11 3 4 3 4 7 11 12 5 2 2".df(\c,[2,3]).q,
		dur: "e e e e x x x x e x x ex x q".asBeats  =>_.warpTo(e.tempoMap) =>_.q,
		instrument:\pluckDEnv, //try also without the effect
		amp:0.006,
		out: Effect.bus({|i| 
			i * 3
			=> FreeVerb.ar(_,0.0,1) => SineShaper.ar(_,0.05,mul:3)
			++ 
			(
				CrossoverDistortion.ar(i,mul:0.05)
				// /6
				*3
			)
			/4.5
			* EnvGen.cutoff(b.sum-1,1)
			
		}, )

	].ppm
});
["I will make it possible for your transporter to beam you"," 5 5 5 6 5 4 3 2 3 4 4 3 3 1 2 3".dm(\d)].addLine;/*SARGON [OC]*/
P.still(\lookingAway, timecode: 530.seconds, music: { |p b e|
	 e.still.( 
		wait: 0.1,
		fade:b.sum + e.bNext.sum -0.1,
		text: ["",""],
	)
});
P.still(\clear,lag:0.01, timecode: 0.seconds, music: { |p b e|
	 e.still.( 
		wait: b.sum,
		text: ["I will make it ","possible"],
	).sequenceText2(
			b.parse([7,9]), [ 
			["for your transporter beam","to beam you"],
			],
	)
});
P(\crash, music: { |p b e|
	(
		instrument: \cymbalsDS,
		att:0.5,
		amp: 0.01


	).play
});
Song.durs.filter( _ * 1.05 );
Song.setTempoMap(\possible,"q e eq e eq e eqqq q q q q q qqq q q q");
P.synthV(role: \vocoder, take: \lead, params: {|p b| [
	lyrics: "I will make it possible + + for your transporter + + beam to send you",
	filter: (midinote: _ - 12), 
	pitchTake: 1
] }, music:{|p b e|
	{
		var chords = (five: -3, four: -5, one: -10);
		var progression = [\five, \four, \one, \four, \five].collect{|i| chords.at(i).midiratio}.dq;
		Song.laMer => PlayBuf.auto(1,_,rate: progression.demand( "qqqq qqqq qqqq qqqq qq".asBeats.warpTo( e.tempoMap ) ).lag(0.1))   
		// *2
	}.play(s,p.carrierBus);
	p.vocodeTune.(p, b, e, e.rpp,

		chord: #[1,2],
		width: 1.03,
		mix: 0.3,
		dur:b.sum + 3 => _.postln,
		att: 0.1,
		rel: 5,
		sus:b.sum
	);
	// { e.playbuf }.play

});
SynthDef(\singleTamb,{
	Shakers.ar(3,resonantFreq:\resonantFreq.kr(1),energy:\energy.kr(1))
	* \amp.kr(0.1) * 10
	=> Out.ar(\out.kr(0),_)
}).add;
P(\tambo, music: { |p b e|
	[
		dur: "qq qqqq qqqq qqqq qqqq qqqq qqqq".asBeats.warpTo( e.tempoMap ).q,	
		instrument: \singleTamb, amp: 0.3,
		rest: [\r, 1, 1, 1, 1, 1, 1, 1, 1].q,
		out: Effect.bus({|i| FreeVerb.ar(i,0.5,1) },)
	].pp
});
Song.setTempoMap(\possible,"q e eq e eq e eqqq e eq q q q qqq q q q");
P(\chord, music: { |p b e|
	[
		instrument: \sawSynth,
		freq: [-1,1,3,5].df(\a)
		.bubble
		.q
		,
		strum:0.05,
		out: Effect.bus( FreeVerb.ar(_, mix:1, room:1, damp:0.5), out:0, inputChannels:1, target:nil)
	].pp
});
P(\bass, music: { |p b e|
	[
		freq: "1 1 -7 -7 1 -4 -6 -7 -17 -1 -1".df(\a,[3,4],\mixolydian).q,
		dur: "qe e q e e qe e qe e qe e".asBeats *2 =>_.warpTo(e.tempoMap)=>_.q
	].pp

});
P.tune();
["(boom) that deep (that deep that deep) beneath the surface. Have no fear."," -5 3 2 3 2 3 2 1 2 3 2 1 -7 1".dm(\d)].addLine;
P.still(\clear,syl:0, timecode: 0.seconds, music: { |p b e|
	 e.still.( 
		wait: b.sum,
		text: ["that","deep"],
	).sequenceText2(
			b.drop(1).parse([4,9]), [ 
			["that deep","beneath the surface"],
			],
	)
});
P(\tambo, music: { |p b e|
	[
		dur: "q qq qq qq qq qq qq".asBeats.warpTo( e.tempoMap ).q,	
		instrument: \singleTamb, amp: 0.3,
		rest: [\r, 1, 1, 1, 1, 1, 1, 1, 1].q,
		out: Effect.bus({|i| FreeVerb.ar(i,0.5,1) },)
	].pp
});
Song.setTempoMap(\fear,"q q qqq q qqq q e x xe x xe e e e");

P.synthV(role: \vocoder, take: \lead, params: {|p b| [
	lyrics: "r that deep that deep that deep beneath + the surface + baby +",
	legato: [1, 1, 0.9, 1, 0.9, 1, 1, 1, 1, 1, 1, 1, 1, 1, ],
	filter: (midinote: _ - 12), 
	pitchTake: 1
] }, music:{|p b e|
	{
		var chords = (five: -3, four: -5, one: -10);
		var progression = [\one, \four, \one, \four, \one,\four,\one, \four].collect{|i| chords.at(i).midiratio}.dq;

		Song.laMer => PlayBuf.auto(1,_,rate: progression.demand( "qq qq qq qq qq qq qq".asBeats.warpTo( e.tempoMap ) ).lag(0.1))   
		// *2
	}.play(s,p.carrierBus);
	[
		freq: [\r, [ [ 5, 7, 13 ], [4, 6, 12] ].df(\d).q(inf)].q,
		instrument: \sawSynthSustain,
		out: p.carrierBus,
		amp:0.1,
		dur: "q q qqq q qqq q qq".asBeats.warpTo( e.tempoMap ).q
	].ppm;
	p.vocodeTune.(p, b, e, e.rpp,
		chord: #[1,2],
		width: 1.03,
		mix: 0.3,
		dur: b.sum + 1,
		att: 0.2,
		sus: b.sum - 0.2,
		rel: 1
	)

});
// P.tune();
// P(\chords, music: { |p b e|
// 	[
// 		freq: [\r, [ 5, 7, 13 ], [4, 6, 12]].df(\d).q,
// 		dur: b.q
// 	].pp
// });
P(\deep, music: { |p b e|
	{
		var durations = b.parse([2,2,2,2]);
		Saw.ar(
			freq: [4,6,12].df(\d,3)
			+ Gendy1.arWidth(freq:[ 1/2, 0.51,0.52 ]).range(-3,3)
			,
			mul: 0.1
		)
		* Env([0,1,0],[ 0.5,2 ]).kr(0,gate: TDuty.kr(durations.dq,0,gapFirst:1))
		// => LPF.ar(_,400)
		/3
		=> Phaser2.ar(_,rate:0.1)
		=> DWGReverbC1C3.ar(_)
		/ 2
	}.play
});
P(\bass, music: { |p b e|
	[
		freq: [1, 4, 5,  1, 4, 5].df(\d,3).q(2),
		dur: "qq qe e qq qe e qq qe e q".asBeats.warpTo( e.tempoMap ).q
		// dur: b.parse([2, 3/6,1/6,[2/6,1],3/6,1/6,[ 2/6,1 ]]).q
	].pp
});
["la la la la","5 7 11 12".dm(\d)].addLine;


["/*SPOCK:*/ Reading a chamber now. Oxygen-nitrogen atmosphere, suitable for human life support.","r"].addLine;
["/*KIRK:*/ Lieutenant Uhura, have Doctor McCoy report to the transporter room in ten minutes",[1, 1, -5, 1, 2, -5, 2, 3, 1, 3, 4, 5, 4, 3,  5, 4, 3, 2, -6, -7, 2, 1].dm(\c)].addLine;
P.synthV(role: \kirk, take: \lead, params: {|p b| [
	lyrics: "Lieutenant + + Uhura + +, have Doctor + McCoy + report + to transporter + + room in ten minutes +",
	pitchTake: 1
] }, music:{|p b e|
	{
		e.playbuf
		=> p.synthVTracks.at(e.key).()
	}.play

});
P.tune();
["with standard landing party equipment.","r"].addLine;
["/*UHURA:*/ Yes, sir.","r"].addLine;
["/*KIRK:*/ Spock.","r"].addLine;
["/*SPOCK:*/ Captain, I do wish to inspect whatever this is that lived that long ago.","7 4 7 7.5 5 6.5 7.5 11 5 3 4 2 3 5 11 12 11 7.5 7.5".dm('e',\minor)].addLine;
P.synthV(role: \spock, take: \lead, params: {|p b| [
	lyrics: "Captain + I do wish to inspect + whatever + + it is that lived so long ago + ",
	legato: [1, 0.6, 1, 1, 0.8, 1, 1, 1,  1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, ],
	filter: (midinote: _ - 12), 
	pitchTake: 1
] }, music:{|p b e|
	{
		e.playbuf
		=> p.synthVTracks.at(e.key).()
	}.play

});
P.tune();
P(\bass, music: { |p b e|
	[
		freq: [-1.5,-7,-7.5,-1.5,1,-3,-2,-3, [-4,-5]] .df(\e,[5],\minor).postln.q,
		dur:b.parse([[1, 0.34], [0.66,1], [1,0.34], [0.66,1,  1], 2, 2, 1, 4, 3]).postln.q,
		legato: [2,1,2,1,1,1,1,1,1].q
	].p.trace.play

});
["/*KIRK:*/ And I would like to have my--","-7 3 2 3 1 4 5 4".dm(\g)].addLine;
P.synthV(role: \kirk, take: \lead, params: {|p b| [
	lyrics: "And I would like to have my -",
	legato: [1, 1, 1, 1, 1, 1, 1, 2],
	pitchTake: 1
] }, music:{|p b e|
	{
		e.playbuf
		=> p.synthVTracks.at(e.key).()
	}.play

});
P.double(role: \kirk, take: \lead, params: {|p b| [
	pitchTake: 1
] }, music:{|p b e|
	{
		e.playbuf
		=> p.synthVTracks.at(e.key).()
	}.play

});
P.tune();
P(\bass, music: { |p b e|
	[
		freq: [-7, 1].df(\g,[ 3,4 ]).q,
		dur: b.parse([4,4]).q
	].pp
});
["(boom) science officer with me on something as unusual as this, but it i--s","-1 3 2 3 2 3 2 1 -7 1 -6  2 3 4 5 4 3 2 -7 1 2 1".dm(\c,6)].addLine;
P.synthV(role: \kirk, take: \lead, params: {|p b| [
	lyrics: "r science + officer + + with me on something + as un usual + + as this, but it is -",
	pitchTake: 1
] }, music:{|p b e|
	{
		e.playbuf
		=> p.synthVTracks.at(e.key).()
	}.play

});
P.double(role: \kirk, take: \lead, params: {|p b| [
	pitchTake: 1
] }, music:{|p b e|
	{
		e.playbuf
		=> p.synthVTracks.at(e.key).()
	}.play

});
Song.setTempoMap(\unusual,"q %x x x x x% e ee e e e e e e x xe x xe e e x xq".rhythm);
P(\click, music: { |p b e|
	[instrument: \hihat,dur:1.dup(10).warpTo(e.tempoMap).q]//.pp
});
P(\bass, music: { |p b e|
	[
		freq: "11 6 13 11 4 14 6 2 12 2 5 15 5".df(\c,3).q,
		dur: b.parse([6, [1,0.5],0.5,1, 2, 1,1, [2,0.34],0.66,[1,0.34],[ 0.66,1 ],1,2]).q
	].pp
});
P.tune();
["(boom) full of unknowns","-1 3 2 2 2".dm('f#',6,\minor)].addLine;
P.synthV(role: \kirk, take: \lead, params: {|p b| [
	lyrics: "r full of unknowns +",
	filter: (midinote: _ - 12), 
	pitchTake: 1
] }, music:{|p b e|
	{
		e.playbuf
		=> p.synthVTracks.at(e.key).()
	}.play

});
P.double(role: \kirk, take: \lead, params: {|p b| [
	pitchTake: 1
] }, music:{|p b e|
	{
		e.playbuf
		=> p.synthVTracks.at(e.key).()
	}.play

});
Song.setTempoMap(\unknowns,"q qq Q E q ");
P.tune();
P(\click, music: { |p b e|
	[dur: 1.dup(4).warpTo(e.tempoMap).q,instrument:\hihat].pp
});
P(\bass, music: { |p b e|
	[
		freq: "1 1 -7 -7 -6".df('f#',[3,4],\mixolydian).q,
		dur: "qe e qe e ee".asBeats/1 warpTo: e.tempoMap q: 1
	].pp
});
P(\dyad, music: { |p b e|
	(
		instrument: \stringyy,
		freq: [5,1].df('f#',4),
		dur: b.parse([4])
	).play
});
["and we can't risk both of us being off the ship.","5 6 5 4 3 2 1 -7 -6 -7 -5 1".dm(\e)].addLine;
P.synthV(role: \kirk, take: \lead, params: {|p b| [
	lyrics: "and we can't risk both of us being + off the ship",
	pitchTake: 1
] }, music:{|p b e|
	{
		e.playbuf
		=> p.synthVTracks.at(e.key).()
	}.play

});
P.double(role: \kirk, take: \lead, params: {|p b| [
	pitchTake: 1
] }, music:{|p b e|
	{
		e.playbuf
		=> p.synthVTracks.at(e.key).()
	}.play

});
P.tune();
// (The lights go out.)
["SULU: All power gone, sir.","r"].addLine;
["KIRK: On the other hand, perhaps this Sargon would like you to come with us.","r"].addLine;
// (Power is restored.)
["SPOCK: Fascinating.","r"].addLine;
["SULU: All normal. No damage at all.","r"].addLine;
["KIRK: I see.","r"].addLine;
[" Will you transport down with us, Mister Spo--ck?","1 -5 1 2 3 2 1 -5 -4 -4 -3".dm('f#')].addLine;
P.synthV(role: \kirk, take: \lead, params: {|p b| [
	lyrics: "Will you transport + down with us, Mister + Spock -",
	legato: [1, 1, 1, 1, 1, 1, 0.7,   1, 1, 1],
	pitchTake: 1
] }, music:{|p b e|
	{
		e.playbuf
		=> p.synthVTracks.at(e.key).()
	}.play

});
P.double(role: \kirk, take: \lead, params: {|p b| [
	pitchTake: 1
] }, music:{|p b e|
	{
		e.playbuf
		=> p.synthVTracks.at(e.key).()
	}.play

});
Song.setTempoMap(\Will," e e e e| e e q|q ex x | e e");
P.tune();
P(\horns, music: { |p b e|
	[
		[
			freq: [\r] ++ "13 12 11 7 7 6 5 4 4 3 2 -7".df('f#',4) q: 1,
			dur: "qq e e e e  e e e e  e e e e".asBeats.warpTo(e.tempoMap).q,
		].p 
		, [
			freq: [\r] ++ "11 7 6 5 4 3 2 1 -7 -5 ".df('f#',4) q: 1,
			dur: "qq e e e e ee e e  ee e e".asBeats.warpTo(e.tempoMap).q,
		].p
	]
	=> Ppar(_)
	<> [ instrument: \sawSynth,amp:0.05 ].p
	=> _.play
});
P(\bass, music: { |p b e|
	[
		freq: "1 -4 -5 -5".df('f#',[3,4]).q,
		dur: "qqqq qq q ".asBeats.warpTo(e.tempoMap).q
	].pp
});
["SPOCK: Evidently, Captain."," 4 3 2 1 -7 1".dm('f#')].addLine;
P.synthV(role: \spock, take: \lead, params: {|p b| [
	lyrics: "Evidently + + + Captain +",
	filter: (midinote: _ - 12), 
	pitchTake: 1
] }, music:{|p b e|
	{
		e.playbuf
		=> p.synthVTracks.at(e.key).()
	}.play

});
P.tune();
Song.setTempoMap(\Evidently, "qe e qe e qe e");
P(\line, music: { |p b e|
	[
		freq: "4 3 2 1 -7 1".df('f#',4).q,
		dur: "q q q q q q q".asBeats.warpTo(e.tempoMap).q 
	].pp
});
P(\bass, music: { |p b e|
	[
		freq: [\r, [-6,6] ].df('f#',3) q: 1,
		dur: b.parse([ 2, 4 ]).q
	].pp
});
["KIRK: Mister Sulu, you have the conn.","r"].addLine;
)
