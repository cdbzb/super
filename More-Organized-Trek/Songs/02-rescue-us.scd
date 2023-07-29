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
P.still(\enterprise, timecode: 413.2.seconds, music: { |p b e|
	 e.still.( 
		wait: b.sum,
		text: ["",""],
	)
});
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
P.still(\bridge, timecode: 425.401.seconds, music: { |p b e|
	 e.still.( 
		wait: b.sum,
		text: ["",""],
	)
});
["/*UHURA:*/ Over three weeks at this distance, sir.","r"].addLine;
P.still(\uhuruclose, timecode: 452.451.seconds, music: { |p b e|
	 e.still.( 
		wait: b.sum,
		text: ["",""],
	)
});
["/*SPOCK:*/ Captain.","r"].addLine;
P.still(\spockClose, timecode: 453.106.seconds, music: { |p b e|
	 e.still.( 
		wait: b.sum,
		text: ["",""],
	)
});
["/*KIRK:*/ Got something?","r"].addLine;
P.still(\kirkGot, timecode: 456.385.seconds, music: { |p b e|
	 e.still.( 
		wait: b.sum,
		text: ["",""],
	)
});
["(boom boom) Sensors registering some form of energy deep inside the planet.","-1 -1 3 1 4 3 1 3 4 5 7 6 4  2 1 -7 -6 -6 -5".dm(\e,\mixolydian)].addLine; /*SPOCK:*/ 
P.still(\spockSensors, timecode: 500.974.seconds, music: { |p b e|
	 e.still.( 
		wait: b.sum,
		text: ["",""],
	)
});
Song.setTempoMap(\Sensors, "e e e e | E E E E E E | e x xq | Q E Q E e e");
P(\chords, music: { |p b e|
	[
		freq: [\r, [-5, 1, 3], [-5, 1, 4],[-5, 1, 3],[1,4,7],6, 4].df(\e,\mixolydian).q,
		legato: [1, 1, 1, 1, [2,2,1],1,1 ].q * 0.3,
		dur: b.parse([2, 2, 3, 3, 1, 1,1]).q,
		instrument: \defaultPiano,
		out: Effect.bus({|i| i=> SineShaper.ar(_,0.2,4) => AnalogPhaser.ar(_,SinOsc.ar(0.2),feedback: 0.8,skew:0.8) => HPF.ar(_,600) * -20.dbamp },inputChannels:2)
	].pp
});
P.synthVs(role: \spock, take: [\lead,\double], params: {|p b| [
	lyrics: "r r sensors + regist + ring  some kind of energy + + deep inside +  the planet + ",
	filter: (midinote: _ - 12), 
	pitchTake: [1,3]
] }, music:[-0.2,0.2].collect{|pan|{|p b e|
	{
		e.playbuf
		/ 10 
		=> Pan2.ar(_, pan)
		// => p.synthVTracks.at(e.key).()
	}.play

}});
P.synthVs(role: \spock, take: [\harmony, \harnmony2],
	pbind: {|p b|
		[
			dur: 
			p.durs[\deep].list.parse([13,1,1,1,1,1,1])
			,
			midinote: [1,7,6,5,4,2.5,2.5].dm(\e,3,\mixolydian)
		].p
	},
	params: {|p b| [
	lyrics: "r deep inside + the planet +",
	pitchTake: [1,3]
] }, music:[-1,1].collect{|pan|{|p b e|
	{
		e.playbuf
		// /10
		=> HPF.ar(_,200)
		=> Pan2.ar(_,pan)
		/10
		// => p.synthVTracks.at(e.key).()
	}.play
}});
P(\bass, music: { |p b e| //check last note
		var quant = "e e q | e e e e | e e q | e e e e | e".asBeats.warpTo(e.tempoMap.quantizeWindow(0.5));
		var raw = "e e q | e e e e | e e q | e e e e | e".asBeats.warpTo(e.tempoMap);
		var both = quant[0..9] ++ raw[10..];
		// var quantHat = 0.25.dup(31).asBeats.warpTo( e.tempoMap.quantizeWindow(0.5) );
		// var rawHat = 0.25.dup(31).asBeats.warpTo( e.tempoMap );
		// var bothHat = quantHat[0..22] ++ rawHat[23..];
	[
		freq: [ 1,1,\r,1,1,\r,1,4,4,\r, 7, 6, 5, 4, 2.5 ].df(\e,[ 2 ],\mixolydian).q,
		// dur: "e e q | e e e e | e e q | e e e e | e".asBeats.warpTo(e.tempoMap.quantizeWindow(0.5)).q
		dur: both.q,
		instrument: \bl,rel:1, amp: 0.1,
		rel: 0.5
	].pp;
	[
		dur: 0.25.dup(31).asBeats.warpTo( e.tempoMap.quantizeWindow(0.5) ) => _.q(2),
		// dur: bothHat.q,
		instrument: \hihat,
		amp: [ [0.1,0.05].q(12),Pseries(0.1,0.1/9*(-1),9) * [1,0.5].q(inf) ].q /2
	].pp
});
P(\snare, music: { |p b e|
	[
		instrument: \sn_808,
		dur: "q ex xq qq ex xq ex".asBeats.warpTo( e.tempoMap.quantizeWindow(0.5) ).q,
		amp: [0,3, 2, 3, 3, 2, 3]/50 => _.q,
		rest: [\r,1, 1, 1, 1, 1, 1 ].q
	].pp;
	[
		instrument:\bd_808,
		dur: "qqqq qqqq qqqq qqqq".asBeats.warpTo( e.tempoMap.quantizeWindow(0.5) ).q

	].pp
});
P(\planetCrash,  music: { |p b e|
	[
		// lag:0.1,
		instrument: \cymbalsDS,
		amp:0.01,
		rest: [\r, 1].q,
		dur: "qqqqqqqq q".asBeats.warpTo( e.tempoMap.quantizeWindow(0.5) ) => _.q
	].p.play
});
["/*SARGON [OC]*/(boom) Your probes have touched me, Mister Spock.",[-1, 4, 4, 4, 4, 3, 2, 1, 2, 3].dm(\c,\minor)].addLine;
P.still(\sargonSpeaks, timecode: 503.269.seconds, music: { |p b e|
	 e.still.( 
		wait: b.sum,
		text: ["",""],
	)
});
P.synthV(role: \vocoder, take: \lead, params: {|p b| [
	lyrics: "r your probes have touched me mister + spock -",
	pitchTake: 1
] }, music:{|p b e|
	{
		e.playbuf
	};
	p.vocodeTune.valueEnvir(p, b, e, e.rpp)

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
P.still(\spockAnswers, timecode: 506.3.seconds, music: { |p b e|
	 e.still.( 
		wait: b.sum,
		text: ["",""],
	)
});
P(\arp, music: { |p b e|
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
P.still(\sargonlocked, timecode: 511.464.seconds, music: { |p b e|
	 e.still.( 
		wait: b.sum,
		text: ["",""],
	)
});
P.synthV(role: \vocoder, take: \lead, params: {|p b| [
	lyrics: "I have locked your transporter + +  device + on my co-ordinates + + +",
	phonemes: ["","","","","","","","","","","","","","","n eh th s",],
	pitchTake: 1
] }, music:{|p b e|
	p.vocodeTune.valueEnvir(p, b, e, e.rpp)

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
	p.vocodeTune.valueEnvir(p, b, e, e.rpp,
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
P.still(\spockDeep, timecode: 525.8.seconds, music: { |p b e|
	 e.still.( 
		wait: b.sum,
		text: ["",""],
	)
});
Song.setTempoMap(\Coming,"Q Q Q qq Q Q Q q e eq q q q");
P(\arp, music: { |p b e|
	var dur = 0.125;
	[
		instrument: \sawSynthSustain,
		degree: [0,8,15].q(inf),

		root: [0!( dur.reciprocal*5/3 ),-2!( dur.reciprocal *7/3),10!(dur.reciprocal*2)]=> _.flat => _.q,
		// dur: "Q q q q q q".asBeats.warpTo( e.tempoMap ).q,
		dur: (0.25).dup(24).asBeats.warpTo( e.tempoMap.quantizeDft(0.6) ).q,
		octave:4,
		lagTime:0,
		amp:0.03
	].ppm
});
P(\click, music: { |p b e|
	[
		dur: [1, 1, 2, 1, 1, 1, 1, 1, 1, 1, 1].warpTo(e.tempoMap.quantizeWindow(0.3)) ++ e.bNext => _.q,
		instrument: \harp, coef: 0.9,
		amp:0.05,
		freq: [1 ! 3, -7 ! 4,-5 ! 4, -4] =>_.flat =>_.df(\c,4,\mixolydian) => _.q

	].pp
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
Song.setTempoMap(\hundred,"Q Q Q Q Q Q Q Q Q e e e e");
P(\arp, music: { |p b e|
	var dur = 0.125;
	[
		instrument: \sawSynthSustain,
		degree: [0,8,15].q(inf),

		root: [0!( dur.reciprocal*5/3 ),-2!( dur.reciprocal *7/3),10!(dur.reciprocal*2)]=> _.flat => _.q,
		// dur: "Q q q q q q".asBeats.warpTo( e.tempoMap ).q,
		dur: (0.25).dup(24).asBeats.warpTo( e.tempoMap.quantizeDft(0.6) ).q,
		octave:4,
		lagTime:0,
		amp:0.03
	].ppm
});
P(\click, music: { |p b e|
	[
		instrument: \harp, coef: 0.9,
		freq: [1, -7, -6, -6, -5.5,-6,-5.5,-4.5].df(\f,4).q,
		// freq: 400,
		amp:0.05,
		dur: "QQ QQ QQ q  ".asBeats.asBeats.warpTo( e.tempoMap.quantize(0.2) ).q
	].pp
});
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
P.tune( _ <> [instrument: \reedy, freqLag:0.05, rel:8, out: Effect.bus( {|i| i +CombN.ar(i, 0.3, 0.3, 3)},) ].pm );
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
		rest: [\r,1,1,1,1,1].q,

instrument: \reedy, freqLag:0.05, rel:8, out: Effect.bus( {|i| i +CombN.ar(i, 0.3, 0.3, 3)},) ;
	].ppm
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
Song.durs.filter( _ * 1.05 );
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
			["for your transporter beam","to send you"],
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
Song.setTempoMap(\possible,"q e eq e eq e eqqq q q q q q qqq q q q");
Song.vocoderPreset = (
		width: 0.93,
		mix: 0.3,
		modGain:1
);
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
	Song.vocoderPreset.push;
	p.vocodeTune.valueEnvir(p, b, e, e.rpp,

		chord: #[1,2],
		dur:b.sum + 3 => _.postln,
		att: 0.1,
		rel: 5,
		sus:b.sum,
	);
	Environment.pop
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
["(boom) that deep (that deep that deep) beneath the surface. Have no fear."," -5 3 2 2 3 2 2 3 2 2 1 2 3 2 1 -7 1".dm(\d)].addLine;
Song.setTempoMap(\fear,"q e e qqq e e qqq  e e e x xe x xe e e e");
P.still(\clear,syl:0, timecode: 0.seconds, music: { |p b e|
	 e.still.( 
		wait: b.sum,
		text: ["that","deep"],
		fade:1
	).sequenceText2(
			b.drop(1).parse([10,5]), [ 
			["beneath","the surface"],
			["",""]
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
P.synthV(role: \vocoder, take: \lead, params: {|p b| [
	lyrics: "r that - deep that - deep that - deep beneath + the surface + baby +",
	legato: [1, 1, 1, 0.9, 1,1, 0.9, 1,1, 1, 1, 1, 1, 1, 1, 1, 1, ],
	filter: (midinote: _ - 12), 
	pitchTake: 1
] }, music:{|p b e|
	{
		var chords = (five: -3 , four: -5, one: -10);
		var progression = [\one, \four, \one, \four, \one,\five,\one, \four].collect{|i| chords.at(i).midiratio}.dq;

		Song.laMer => PlayBuf.auto(1,_,rate: progression.demand( "qq qq qq qq qq qq qq".asBeats.warpTo( e.tempoMap ) ).lag(0.1))   
		// * EnvGen.cutoff(b.parse([5]).unbubble,b[5])
		// *2
	}.play(s,p.carrierBus);
	[
		freq: [\r, [ [ 5, 7, 13 ],[5,7, 12 ], [4, 6, 12], [4,6,11] ].df(\d).q(inf)].q,
		// legato: [1,[ [2,2,1],1,1] .q(inf)].q,
		instrument: \sawSynthSustain,
		out: p.carrierBus,
		amp:0.1,
		dur: "q e e qe eq e e qe eq  e e qq".asBeats.warpTo( e.tempoMap ).q
	].ppm;
	p.vocodeTune.valueEnvir(p, b, e, e.rpp,
		chord: #[1,2]/2,
		width: 1.03,
		mix: 0.3,
		dur: b.sum + 1,
		att: 0.2,
		sus: b.sum - 0.2,
		rel: 1
	)

});
P(\deep, music: { |p b e|
	{
		var durations = b.parse([3,3,3,2]);
		var pitch = [[4,6,12],[4,6,11],[4,6,12],[4,6,11],[5,2,12]].df(\d, 3).dq.demand(  b.parse([[3,1/2],[1/2,2],[1/2],[1/2,2],3]) );
		SawBL.ar(
			freq: pitch * Gendy1.arWidth(width:2,freq:[ 1/2, 1,0.52 ]).range(0.985,1.015) ,
			mul: 0.1
		)
		+ SawOS.ar( pitch, 0,mul:0.1 )
		* Env([0,1,0],[b[3]/2 ,b[3]/2 ]).kr(0,gate: TDuty.kr(durations.dq,0,gapFirst:1))

		// => LPF.ar(_,400)
		/3
		=> Phaser2.ar(_,rate:0.1)
		=> DWGReverbC1C3.ar(_,mix: 0.5)
		/ 3
	}.play
});
P(\bass, music: { |p b e|
	[
		// freq: [1, 4, 5,  1, 4, 5].df(\d,3).q(2),
		freq: [1,3, 4, 5,  1,3, 4, 5,1,3,5,-5, 1, 3].df(\d,3).q(2),
		// dur: "qq qe e qq qe e qq qe e q".asBeats.warpTo( e.tempoMap ).q
		dur: "qe e qe e qe e qe e qe e q q qe e ".asBeats.warpTo( e.tempoMap ).q
		// dur: b.parse([2, 3/6,1/6,[2/6,1],3/6,1/6,[ 2/6,1 ]]).q
	].pp
});
P(\keys, music: { |p b e|
	[
		freq: [\r,2, -7, 1, 3, 1, -4].df(\d,4).q,
		dur: "qqqqqqqqqqq e e q e e".asBeats.warpTo( e.tempoMap ).q,
		instrument:  \sawSynth

	].pp
});
P(\lick, music: { |p b e| //
	[
		freq: [-5,1, -5, \r, 1, -5, ].df(\d).q,
		att: [0.2,0.2,0.3,0.4,0.5,0.5].q,
		amp: [0.1,0.1,0.06, 0, 0.05,0.05].q /2,
		rel: [5,2,4, 0, 2,2].q,
		
		legato: [0.3,1,1,1,1,1].q,
		// instrument: "defaultPorto",
		instrument: \sawSynth ! 3 ++ (\pulse!3) => _.flat =>  _.q,
		dur: "qqqe e q qqe e q qqe e".asBeats.warpTo( e.tempoMap ).q,

	].pp
});
["la la la la",[ -4, 4, 14, 12, 13, 5, 13, 12, ].dm(\d)].addLine;
Song.setTempoMap('la la',"e e e e e e e e ");
P(\bass, music: { |p b e|
	[
		
		freq: [ 4, 5,  1,3, 4, ].df(\d,3).q,
		dur: "qe e qe e ".asBeats.warpTo( e.tempoMap ) ++ e.bNext[0..3].sum =>_.q
	].pp
});
P(\keys, music: { |p b e|
	[
		// freq: [ -4, 4, [6, 14], [7, 12], [1,11,13],5, [11,13],[12,-13 ] ,[ -14, 6 ], [ 11,-4 ],[6, 14], [7, 12], [1,11,13]].df(\d).q,
		freq: [ -4, 4, [6, 14], [7, 12], [1,11,13],5, [11,13],[12,-13 ] ,[ -14,  6 ]].df(\d).q,
		dur: 0.5.dup(8).asBeats.warpTo( e.tempoMap ) ++ e.bNext[0..3].sum => _.q ,
		instrument:  \sawSynth
	].pp
});


["/*SPOCK:*/ Reading a chamber now. Oxygen-nitrogen atmosphere, suitable for human life support.","3 4.5 5.5 7 5.5  2".dm(\g) ++ "1 2 3 4 5 3 11 7 2  4 3 2 3 5 3 -6.5".dm('b-')].addLine;
P.still(\spockReading, timecode: 541.seconds, music: { |p b e|
	 e.still.( 
		wait: b.sum,
		text: ["",""],
	)
});

Song.setTempoMap(\nitrogen,"e x x e x xe  E E E E E E E E Ee e e e e ex x q");

P(\click, music: { |p b e|
	[
		instrument: \harp, coef: 0.9,
		freq: [ 1, 13 ].df(\g)!4 ++ ([1, -5].df('b-')!4) ++ [1].df('a-')  => _.q /[ 2 ],
		// freq: 400,
		amp:0.05,
		dur: "q e  ee Q Q Q Q Ee q q q e".beats.warpTo( e.tempoMap.quantize(0.2) ).q
	].pp
});
P.synthVs(role: \spock, take: [\lead,\double], params: {|p b| [
	lyrics: "Reading + a chamber + now. Nitrogen + + oxygen + + atmosphere + + suitable + + for life support. +",
	filter: (midinote: _ - 24), 
	legato: [ [1, 1, 1, 1, 1, 0.7,1,1,1,1,1,1,1,1,0.7,1, 1, 1, 1, 0.7, 1, 0.5 ] ],
	pitchTake: [1, 3]
] }, music:{|p b e|
	{
		e.playbuf
		=> p.synthVTracks.at(e.key).()
	}.play

});
P(\chords, music: { |p b e|
	[
		freq: [
			[1,3,5.5, 7].df(\g,4),
			[-7,1,3,5].df('b-',4,\mixolydian),
			[1, 4, 5, 11].df(\f,4),
			[1,3,5,11].df('a-',4),
			[1,4.5,6.5, 11].df('a-',4)
		].collect{ |i| i[0..1] }.q,
		legato: 0.7,
		freqLag: 1,
		instrument: \sawSynthSustain,
		attack:0,
		dur: b.parse([6, 6,3,4, 3]).q,
		// out: Effect.bus({|i| i* ( Impulse.ar(5) => Decay.ar(_,2)  )}, )
		out: Effect.bus({|i| i* ( TDuty.ar( "x*82".beats.warpTo( e.tempoMap.quantize ).dq ) => Decay.ar(_,1)  )}, )

	].ppm
});
P.tune( _ <> [instrument: \stringyy,mix: 0.8, amp: 0.09].pm );
P(\bass, music: { |p b e|
	[
		freq: [[ 1, 13 ]].df(\g) ++ [1, -5].df('b-') ++ [1].df('a-') => _.q /[ 4 ],
		dur: b.parse([6, 6, 3, 7]).q,
		out: Effect.bus({|i| FreeVerb.ar(i,0.5,[ 1,0.9 ]) => SineShaper.ar(_,0.2, mul:4) },)
	].pp
});
["/*KIRK:*/ Lieutenant Uhura, have Doctor McCoy report to the transporter room in ten minutes",[1, 1, -5, 1, 2, -5, 2, 3, 1, 3, 4, 5,4, 3,4,   5, 4, 3, 2, -6, -7, 2, 1].dm(\c)].addLine;
P.still(\kirkReport, timecode: 548.7.seconds, music: { |p b e|
	 e.still.( 
		wait: b.sum,
		text: ["",""],
	)
});
// Song.durs.filter({|i| i[0..13]++i[15..]});
P(\line, music: { |p b e|
	[
		freq: [ 1, 1, 1, -7,  -7, 1, 1, [1,-6]].df(\c).q,
		dur: b.parse([1,2,1, 2, 1, 2, 1, 2]).q,
		instrument: \visual_pad,
		amp:0.25
		
	].pp
});
P(\bass, music: { |p b e|
	[
		freq: [1, 1, 1, -5, -5, 1, 1, -4, -5,-5, 1 ].df(\c,4).q,
		dur: b.parse([1,2,1, 2, 1, 2, 1, 2,3, 6, 2]).q,
		instrument: \sawSynth,
		out: Effect.bus({|i| HPF.ar(i,60) },),
		amp: 0.08
	].pp;
	[
		
		freq: [1, 1, 1, 2, 2, 3, 3, 4, 5, -5, 1].df(\c,3).q,
		dur: b.parse([1,2,1, 2, 1, 2, 1, 2,3, 6, 2]).q,
		instrument: \sawSynth,
		out: Effect.bus({|i| i=> BPF.ar(i,800,19.5) => Pan2.ar(_,1) },),
	].pp
});
P.synthV(role: \kirk, take: \lead, params: {|p b| [
	lyrics: "Lieutenant + + Uhura + +, have Doctor + McCoy + report + to the transporter + + room in ten minutes +",
	pitchTake: 1,
	legato: [1, 1, 1, 1, 1, 0.8, 1, 1, 1, 1, 0.8, 1, 0.7, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1   ],
] }, music:{|p b e|
	{
		e.playbuf
		=> p.synthVTracks.at(e.key).()
		=> Pan2.ar(_,0)
	}.play

});
// ["with standard landing party equipment.","r"].addLine;
["/*UHURA:*/ Yes, sir.","-7,1".dm(\c)].addLine;
Trek.cast.uhura = \cheng;
P.synthV(role: \uhura, take: \lead, params: {|p b| [
	lyrics: "yes sir",
	legato: [0.8, 0.3, ],
	pitchTake: 1
] }, music:{|p b e|
	{
		e.playbuf
		=> p.synthVTracks.at(e.key).()
		=> Pan2.ar(_,-0.4)
	}.play
});
/* P.still(\overTheShoulder, timecode: 536.335.seconds, music: { |p b e|
	 e.still.( 
		wait: b.sum,
		text: ["",""],
	)
}); */
P(\chords, music: { |p b e|
	[
		freq: [ [ 5,7,12 ],[5,11,13] ].df(\c,3).q,
		legato: [1, 0.3, ].q,
		dur: b.q
	].pp
});
P(\connector, music: { |p b e|
	fork{
		b[0] + s.latency => _.wait;
		{
			var amp = XLine.kr(0.001,0.1,b[1]);
			// b[0].wait;
			BrownNoise.ar(amp) 
			=>DynKlank.ar( `[[1,1.5].df(\c,[5,6,7]).dq.demand([b[1],2]),[1],[3]],_)
			=> Limiter.ar(_,0.3)
			* EnvGen.cutoff(b[1],0.4) 
			* -10.dbamp
		}.play(s,2);

	}
});
["/*KIRK:*/ Spock.","1".dm('c#')].addLine;
P.still(\captainLookingAtSpock, timecode: 551.9.seconds, music: { |p b e|
	 e.still.( 
		wait: b.sum,
		text: ["",""],
	)
});
P.synthV(role: \kirk, take: \lead, params: {|p b| [
	lyrics: "spock?",
	pitchDelta: Env([0,300],b),
	filter: (midinote: _ - 12), 
	legato: [0.3, ],
	lag: [0.2],
	pitchTake: 1
] }, music:{|p b e|
	{
		e.playbuf
		=> p.synthVTracks.at(e.key).()
		* 2 
		=> {|i| CombN.ar(i,0.2,0.2,3) / 2 + i}
		=> Pan2.ar(_,0)
	}.play
});
P(\connector, music: { |p b e|
	fork{
		s.latency => _.wait;
		{
			var amp = Line.kr(0.001,0.1,b[0]);
			// b[0].wait;
			BrownNoise.ar(0.1) 
			=>Ringz.ar(_, [1, 1.5].df('a-').dq.demand([b[0],1]), Line.kr(0,1,b[0]))
			// =>DynKlank.ar( `[[1,1.5].df('a-',[4,5,6,]).dq.demand([b[0],1]),[1],[3]],_)
			* amp

			* EnvGen.cutoff(b[0],2) 
			* -12.dbamp
		}.play(s,3);

	}
});
P(\note, music: { |p b e|
	(
		freq: [ 1, -6.5,3 ].df(\a,4)
	).play
});
["/*SPOCK:*/ Captain, I do wish to inspect whatever this is that lived that long ago.","7 4 7 7.5 5 6.5 7.5 11 5 3 4 2 3 5 11 12 11 7.5 7.5".dm('e',\minor)].addLine;
P.synthV(role: \spock, take: \lead, params: {|p b| [
	lyrics: "Captain + I do wish to inspect + whatever + + it is that lived so long ago + ",
	legato: [1, 0.6, 1, 0.8, 1, 1, 1, 1,  1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, ],
	filter: (midinote: _ - 12), 
	pitchTake: 1
] }, music:{|p b e|
	{
		e.playbuf
		=> p.synthVTracks.at(e.key).()
		* 3.dbamp
	}.play

});
P.still(\spockIDoWish, timecode: 555.0.seconds, music: { |p b e|
	 e.still.( 
		wait: b.sum,
		text: ["",""],
	)
});
P(\dyads, music: { |p b e|
	[
		freq: [[4,6],[5,7],[4.5,7],[5,7],[6,7]].df(\c).q,
		dur: b.parse([7,4,1, 4,1,]).q,
		// release:[8,8,8,8,4].q, 
		instrument: \stringyy,mix:0,amp:0.03,
		out: [0,1]
	].ppm
});
P(\bass, music: { |p b e|
	[
		freq: [-1.5,-7,-7.5,-1.5,1,-3,-2,-3, [-4,-5]] .df(\e,[5],\minor).postln.q,
		rest: [\r,1].q(inf),
		dur:b.parse([[1, 0.34], [0.66,1], [1,0.34], [0.66,1,  1], 2, 2, 1, 4, 3]).postln.q,
		legato: [2,1,2,1,1,1,1,1,1].q,
		// instrument: \sawSynth,
		out: Effect.bus({|i| DWGReverbC1C3.ar(i => BPF.ar(_,900,10),c1:2,mix: 0.5)  },out:2)
		

	].p.play;
	[
		freq: [-1.5,-7,-7.5,-1.5,1,-3,-2,-3, [-4,-5]] .df(\e,[5],\minor).postln.q,
		rest: [1,\r].q(inf),
		dur:b.parse([[1, 0.34], [0.66,1], [1,0.34], [0.66,1,  1], 2, 2, 1, 4, 3]).postln.q,
		legato: [2,1,2,1,1,1,1,1,1].q,
		instrument: \sawSynth,
		out: Effect.bus({|i| DWGReverbC1C3.ar(i => BPF.ar(_,900,10),c1:2,mix: 0.5)  },)

	].p.play

});
["/*KIRK:*/ And I would like to have my--","-7 3 2 3 1 4 5 4".dm(\g)].addLine;
P.still(\kirkUnusual, timecode: 558.491.seconds, music: { |p b e|
	 e.still.( 
		wait: b.sum,
		text: ["",""],
	)
});
P.synthVs(role: \kirk, take: [\lead, \double], params: {|p b| [
	lyrics: "And I would like to have my -",
	legato: [[1, 1, 1, 1, 1, 1, 1, 2]],
	pitchTake: [1, 3]
] }, music:{|p b e|
	{
		e.playbuf
		=> p.synthVTracks.at(e.key).()
		=> Pan2.ar(_,0)
	}.play

});
P(\chords, music: { |p b e|
	[
		freq: [[-3, 1], [-2, -7]].df(\d,\mixolydian).q,
		dur: b.parse([3, 6]).q,
		instrument: \visual_pad
	].pp
});
P(\bass, music: { |p b e|
	[
		freq: [-7, 1].df(\g,[ 3,4 ]).q,
		dur: b.parse([4,4]).q
	].pp
});
["(boom) science officer with me on something as unusual as this, but it i--s","-1 3 2 3 2 3 2 1 -7 1 -6  2 3 4 5 4 3 2 -7 1 2 1".dm(\c,6)].addLine;
P(\lick, music: { |p b e|
	[
		freq: [11, 7,6,5,4,3,2,1, -7, -6,-5,-4, -3].df(\c,6).q,
		dur: b[0]/7,
		instrument: \harp, coef:0.1, amp: 0.01,
		out: Effect.bus({|i| Phaser2.ar(i,rate: 0.01,fb:0.95) => {|i| [CombN.ar(i,0.2,b[0]/3,5) ,i] } => BPF.ar(_,800) })
	].pp
});
P.synthVs( \jun, take: [\harm1, \harm2],
pbind: ~t = [0,1].collect{|voice|
	{|p b|
		var vl=
		VoiceLeading( 
			[
				[5, 6,  6, 4, 7],
				[3, \_, 4, 2, 5]
			], b.parse([6,3, 4, 4, 5])
		).dm(\c);
		[
			dur: vl.voice(voice).durs,
			midinote: vl.voice(voice).line
		].p
	}
} => _.postln,
params: {|p b| [
	lyrics: "oooh - ooh - -",
	legato: [[1, 0.9, 1, 1, 1, ]],
	lag: [[0,0,0,0,0.2]],
	pitchTake: 1
] }, music: [-0.2,0.2].collect
{|pan|
	{|p b e|
		{
			e.playbuf
			=> p.synthVTracks.at(e.key).()
			=> Pan2.ar(_,pan)
		}.play

	}
});
Song.setTempoMap(\unusual,"q %x x x x x% e ee e e e e e e x xe x xe e e x xq".rhythm);
Song.guitar = AAS_Strum();
P(\strum, music: { |p b e|
	p.guitar.setPlayMode(\strum );
	[
		type: \strum,
		instance: p.guitar,
		freq: [ [1,3], [-6,1],[-4, -6],[2,4],[5, 7] ].df(\c).q,
		dur: b.parse([6,3,4,[ 1,1,1,1,1/3 ],[2/3,1,1,1,1],4]).q,
		legato:1
	].pp ;
	[
		type: \strum,
		instance: p.guitar,
		switch: [ \down, \muffleD, \d, \d, \d, \d ].q,
		lag: [0,0.1,0,0,0,0].q,
		legato:1,
		// dur: 10
		lag:0.01,
		dur: b.parse([1, 5,3,4,[ 1,1,1,1,1/3 ],[2/3,1,1,1,1],4]).q,

		// lag:0.05
	].pp
	// => _.play
});
P.synthVs(role: \kirk, take: [\lead, \double], params: {|p b| [
	lyrics: "r science + officer + + with me on something + as un usual + + as this, but it is -",
	pitchTake: [1, 3]
] }, music:{|p b e|
	{
		e.playbuf
		=> p.synthVTracks.at(e.key).()
		=> Pan2.ar(_,0)
	}.play

});
P(\click, music: { |p b e|
	[instrument: \hihat,dur:1.dup(10).warpTo(e.tempoMap).q]//.pp
});
P(\bass, music: { |p b e|
	[
		freq: "11  6 13 11 4 14 6 2 12 2 5 15 5".df(\c,3).q,
		dur: b.parse([6, [1,0.5],0.5,1, 2, 1,1, [2,0.34],0.66,[1,0.34],[ 0.66,1 ],1,2]).q
		// dur: "qe e q e e q e e q e e".beats.warpTo(e.tempoMap).q
	].pp
});
["(boom) full of unknowns","-1 3 2 2 2".dm('f#',6,\minor)].addLine;
Song.setTempoMap(\unknowns,"q qq Q E q ");
P(\plink, music: { |p b e|
	{
		Pluck.ar( PinkNoise.ar(0.1), 1, 0.1, 1.df('f#',4) + Gendy1.kr(minfreq:0.2,maxfreq:[5,10]).range(-5,5) =>_.reciprocal, decaytime:4)
		+ Pluck.ar( PinkNoise.ar(0.1), Impulse.ar(0) => DelayN.ar(_,"qq".beats.warpTo(e.tempoMap),"qq".beats.warpTo(e.tempoMap)), 0.1, -7.df('f#',4,\minor) + Gendy1.kr(minfreq:0.2,maxfreq:[5,10]).range(-5,5) =>_.reciprocal, decaytime:4)
		+ Pluck.ar( PinkNoise.ar(0.1), Impulse.ar(0) => DelayN.ar(_,b[0..4].sum,b[0..3].sum), 0.1, -6.df('f#',4) + Gendy1.kr(minfreq:0.2,maxfreq:[5,10]).range(-5,5) =>_.reciprocal, decaytime:4)

		=> {|i| CrossoverDistortion.ar(i * EnvGen.cutoff(b.parse([6]).unbubble,0))/30 + i}
		=> FreeVerb.ar(_,0.5,1)
	}.play
});
P.synthVs(role: \kirk, take: [\lead, \double], params: {|p b| [
	lyrics: "r full of unknowns +",
	filter: (midinote: _ - 12), 
	pitchTake: [1, 3]
] }, music:{|p b e|
	{
		e.playbuf
		=> p.synthVTracks.at(e.key).()
		=> Pan2.ar(_,0)
	}.play

});
P(\click, music: { |p b e|
	[
		dur: 0.5.dup(9).warpTo(e.tempoMap).q,
		amp: [2,1].q(inf)/20,
		rest: [1,\r].q(inf),
		instrument:\hihat
	].pp
});
P(\bass, music: { |p b e|
	[
		freq: "1 1 -7 -7 -6".df('f#',[3,4],\mixolydian).q,
		dur: "qe e qe e ee".asBeats/1 warpTo: e.tempoMap q: 1
	].pp;
});
P(\middle, music: { |p b e|
	[
		freq: [\r, [1,3],[-7,3],[-7,3],[-6.5,3]].df('f#',\minor).q,
		dur: b.q,
		instrument: \pulse
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
Song.durs.filter({|i| var last = i.last; i.dropLast ++ (last * 4 )});
P(\line, music: { |p b e|
	[
		freq: "5 6 5 4 3 2 1 -5 -6 -5 -4 -3".df(\e,[3, 4, 5 ]).q,
		instrument: \stringyy,
		dur: b.q
	].ppm
});
P(\bassnotes, music: { |p b e|
	[
		freq: [\r, 1, 5, 6, 5, 4, 3].df(\e,3).q,
		instrument: \sparkTriangle,
		amp: 0.05,
		// out: [ 0,1 ],
		out: [ 12,13 ],
		dur: b.parse([4,3, 1, 1, 1, 1, 1]).q
	].ppm;
	
});
( SynthDef(\tapeStop,{
	arg bus = 12;
	var in = In.ar(12,2 );
	var a =LocalBuf(s.sampleRate * 2,2);
	BufWr.ar(in, a, Sweep.ar(1, 44100), 1.0 );
	BufRd.ar(2,a,Sweep.ar(2, Env([44099,44099,10],[4,1],-1).kr(2)) - 0.1, loop:1.0,interpolation:1)
	=> Out.ar(0,  _)
}).add;
);
P.synthVs(role: \kirk, take: [\lead, \double], params: {|p b| [
	lyrics: "and we can't risk both of us being + off the ship",
	pitchTake: [1, 3]
] }, music:{|p b e|
	{
		e.playbuf
		=> p.synthVTracks.at(e.key).()
		=> Pan2.ar(_,0)
		=> Out.ar(12,_)
		}.play;
		fork{
			// b[0..10].sum.wait;
			Synth(\tapeStop,12)
		}

});
P.still(\darkness,syl:10, timecode: 606.789.seconds, music: { |p b e|
	 e.still.( 
		wait: b.sum + e.bNext[0],
		fadeIn:1,
		text: ["",""],
	)
});
P(\chords, music: { |p b e|
	[ 
		freq: [\r,[-11,-5,1,3].df(\e),[-1,-5,1,3].df(\b,4),[-15,-5, 1, 3].df('c#',\minor)].q,
		dur: b.parse([4,3,4,1]).q,
		strum: [0, 0.04, 0.04,0.06].q,
		out: Effect.bus({|i| i => HPF.ar(_,300) },inputChannels:2),
		instrument: \defaultPiano
	].pp
});

P(\powerDown,syl: 10, music: { |p b e|
	[
		dur: b.drop(1)[0]/5 ! 5 ++ 1 => _.q,
		note: (1,0..-4).q,
		instrument: \stringyy
	].pp;
	[
		dur: b.drop(1)[0]/5 ! 5 ++ 1 => _.q,
		note: (1,0..-4).q,
		instrument: \sawSynthSustain,
		pulse: 0.5, amp:0.01,
		out: Effect.bus({|i| i => Pan2.ar(_,1) },)
	].ppm;
	
});
[ "dark","r",[2] ].addLine;
["SULU: All power gone, sir.","3 2 1 -7, -5".dm(\g,\minor)].addLine;
P(\gone,syl:2, music: { |p b e|
	{
		{ 1.df(\d,3).pareto(0.9)}!40 => SinOsc.ar(_,0,0.05)
		=>Splay.ar(_).sin
		* Env.perc(0.01,8).kr(2,gate:1)

	}.play
});
Trek.cast.sulu = \an;
Trek.presets.put(\sulu,\an,[
	paramGender: -0.35,
	paramToneShift: 200,
]);
P.synthV(role: \sulu, take: \lead, params: {|p b| [
	lyrics: "all power + gone sir",
	legato: [1, 1, 1, 0.8, 0.55, ],
	filter: (midinote: _ - 12), 
	pitchTake: 1
] }, music:{|p b e|
	{
		e.playbuf
		=> p.synthVTracks.at(e.key).()
	}.play

});
P.tune();
P(\chords, music: { |p b e|
	[
		strum: 0.05,
		freq: [-1, -5, 1, 3].df(\g,4,\minor).bubble ++ [-1,3,5,11].df(\d,4,\minor).bubble => _.q,
		dur: b.parse([3,2]).q,
		out: Effect.bus({|i| FreeVerb.ar(i,0.8,[0.9, 1 ]) => SineShaper.ar(_,0.05,) },)

	].pp
});
P.still(\suluSpeaks, timecode: 609.739.seconds, music: { |p b e|
	 e.still.( 
		wait: b.sum,
		text: ["",""],
	)
});
P(\bassnote,syl:2, music: { |p b e|
	[
		freq: 1.df(\d,3).bubble ++ ( p.tune[e.start+1].list[0..7] - 24 => _.midicps ) ++ 1.df('a-',3) => _.q,
		dur: b.drop(1).sum.bubble ++ e.bNext => _.q,
		instrument: \sawSynthSustain, amp: 0.06, out: Effect.bus({|i| FreeVerb.ar(i,0.1,1) },out: 2)
	].ppm
});
["KIRK: On the other hand, perhaps this Sargon would like you to come with","1 2 3 2 1 2 3 4.5".dm(\e) ++ "3 1".dm('a-',\minor) ++ "2 3 4 2 3 4.5 ".dm('a-')].addLine;
P(\bassnote,syl:7, music: { |p b e|
	[
		midinote: [1].dm('a-') ++ p.tune[e.start].list[10..] -.t [12, 24] => _.q,
		dur: b.drop(1).parse([2,1,1,1,1,1,1]).q,
		instrument: \washSus, freqLag:0.1,amp: 0.02
	].ppm
});
// P.tune( { |i|  i <> [instrument: \sawSynthSustain, amp: 0.06, out: Effect.bus({|i| FreeVerb.ar(i,0.1,1) },)].pm => Pmul(\freq, 0.25, _) => Pfin(8,_) } );
P.synthVs(role: \kirk, take: [\lead, \double],
	pbind: Song.enlarge(1),
	 params: {|p b| [
	filter: (midinote: _ - 12), 
	lyrics: "On the other + hand, perhaps +  this Sargon +  would like you to come with us",
	legato: [[1,1,1,1,0.6, 1,1,0.8, 1,0.7, 1, 1, 1, 1, 1, 1,1.3 ]],
	pitchTake: [1, 3]
] }, music:{|p b e|
	{
		e.playbuf
		=> p.synthVTracks.at(e.key).()
		=> Pan2.ar(_,0)
	}.play

});
P(\chords, music: { |p b e|
	[
		freq: [\r, [-3, 1, 3, 5].df(\e), [-11,-1, -5, 1, 3].df('a-',\minor), [-11,-1].df('a-'),[-1,1,3].df('a-'),[-3,-5,-7,3].df('b-',\mixolydian)] /2 => _.q,
		strum: 0.06,
		dur: b.parse([2, 6, 1, 2,4,2]).q,
		out: Effect.bus({|i| i.sin => HPF.ar(_,[ 300,400 ]) => FreeVerb.ar(_,0.5,1) },)
	].pp;
	[
		instrument: \help_oteypiano,
		rho:0.5,
		amp: 0.5,
		// midinote: p.tune[e.start] -24,
		midinote: "1 2 3 2 1 2 3 4.5".dm(\e) ++ "1 ".dm('a-',\minor) ++ "2 3 4 2 3 4.5 2".dm('a-') - 24 => _.q,
		legato: [ 3, 1, 1, 1,  1, 1, 1, 1,  1, 1, 1, 1, 1, 1, 1   ].q,
		dur: b.parse([1, 1, 1, 1, 1, 1, 1, 1, 2, 1, 1, 1, 1, 1, 2]).q,
		out: Effect.bus({|i| OteySoundBoard.ar(i).sin},inputChannels:2 ,)
	]//.pp
});
P.still(\kirkPerhaps, timecode: 614.55.seconds, music: { |p b e|
	 e.still.( 
		wait: b.sum,
		text: ["on the","other hand"],
	)
});
[ "us -Power is restored-","1 1.5 2 2.5 3 4 5".dm('a-') ].addLine;
// P.tune();
P(\connector, music: { |p b e|
	[
		midinote: p.tune[e.start].list -12 ++ 4.dm('a-',4) => _.q,
		dur: b ++ e.bNext[0] => _.flat => _.q,
		instrument: \stringyy, amp:0.2, release: 2
	].ppm;
	[
		midinote: p.tune[e.start].list -12 ++ 6.dm('a-',4) -12 => _.q,
		dur: b ++ e.bNext[0] => _.flat => _.q,
		instrument: \harp, amp:0.02
	].pp;
});
P.still(\dark, timecode: 619.5.seconds, music: { |p b e|
	 e.still.( 
		wait: b.sum,
		text: ["",""],
	)
});
P.still(\powerBack,lag:0.01, timecode: 620.5.seconds, music: { |p b e|
	 e.still.( 
		wait: b.sum + e.bNext.sum,
		fadeIn:b.sum,
		text: ["",""],
	)
});
["SPOCK: Fascinating.","11 5.5 3 1".dm('c#')].addLine;
P.still(\spockFascinating, timecode: 622.seconds, music: { |p b e|
	 e.still.( 
		wait: b.sum,
		text: ["",""],
	)
});
P.synthVs(role: \spock, take: [\lead,\double], params: {|p b| [
	filter: (midinote: _ - 12), 
	lyrics: "fascinating + + +",
	lag: [[0.1,0.05,0,0]],
	legato: [[1,1,1,0.6, ]],
	vocalMode: \Gentle,
	pitchTake: [1,3]
] }, music:{|p b e|
	{
		e.playbuf
		=> p.synthVTracks.at(e.key).()
		=> HPF.ar(_,250)
		=> BPF.ar(_,1100,3.5)
		=> {|i| i => CombN.ar(_) / 4 + i}
		=> Pan2.ar(_,-0.25)
	}.play

});
P(\chord, music: { |p b e|
	[
		freq: [[-4.5,1, 3, 5],[-5.5, 1, 3.5, 5.5]].df('c#',6,\whole).q ,
		instrument: \stringyy,amp: 0.05,
		dur: b.sum
	].pm.play
});
P(\connector, music: { |p b e|
	[
		freq: [11, 5.5, 3, 1, -4].df('c#',4).q,
		dur: b ++ e.bNext[0] => _.q,
		instrument: \sawSynthSustain, pulse: 0.5, amp: 0.05, out:Effect.bus({|i| i => HPF.ar(_,200) },out:3) 
	].ppm
});
P.tune();
// ["SULU: All normal. No damage at all.","r"].addLine;
// ["KIRK: I see.","r"].addLine;
[" Will you transport down with us, Mister Spo--ck?","1 -5 1 2 3 2 1 -5 -4 -4 -3".dm('f#')].addLine;
P.still(\kirkWillYou, timecode: 631.425.seconds, music: { |p b e|
	 e.still.( 
		wait: b.sum,
		text: ["",""],
	)
});
P.synthVs(role: \kirk, take: [\lead, \double], params: {|p b| [
	lyrics: "Will you transport + down with us, Mister + Spock -",
	legato: [[1, 1, 1, 1, 1, 1, 0.7,   1, 1, 1]],
	pitchTake: [1, 3]
] }, music:{|p b e|
	{
		e.playbuf
		=> p.synthVTracks.at(e.key).()
		=> Pan2.ar(_,0)
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
P.still(\walkingOut, timecode: 632.5.seconds, music: { |p b e|
	 e.still.( 
		wait: b.sum,
		text: ["",""],
	)
});
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
["KIRK: Mister Sulu, you have the conn.","3 2 1 -7 -6 -5 -5 -6 -7 1.5".dm('f#')].addLine;
// Song.setTempoMap(\Sulu,"qe e qe e qe ee e qe e q");
P.still(\kirkConn, timecode: 633.38.seconds, music: { |p b e|
	 e.still.( 
		wait: b.sum,
		text: ["",""],
	)
});

Song.setTempoMap(\Sulu,"QQ Q QQ Q QQ Qq q QQ Q qq ");
P.synthVs(role: \kirk, take: [\alt, \altDouble], params: {|p b| [
	lyrics: "r r Mister + Sulu + you have the conn.",
	legato: [[1, 1, 1, 1, 1, 0.5, 1, 1, 1, 0.66, ]],
	pitchTake: [1, 3]
] }, music:{|p b e|
	{
		e.playbuf
		=> p.synthVTracks.at(e.key).()
		=> Pan2.ar(_,0)
	}.play

});
P.synthVs(\kevin, take: [\lead, \double], params: {|p b| [
	lyrics: "Mister + Sulu - + - r r r r",
	legato: [[1, 1, 1, 1, 1, 0.5, 1, 1, 1, 0.66, ]],
	vocalMode: \Soft,
	pitchTake: [1, 3]
] }, music:{|p b e|
	{
		e.playbuf
		=> p.synthVTracks.at(e.key).()
		=> FreeVerb.ar(_,0.1,1)
		/2
		=> Pan2.ar(_,1)
	}.play

});
P(\bassnote, music: { |p b e|
	[
		freq: [\r, -5, -15].df('f#',4).q,
		dur:b.parse([2, [ 3, 0.5 ], [0.5, 5]]).q
	].pp
});
P(\chord, music: { |p b e|
	[
		strum: 0.05,
		freq: [\r, [-5, -7, 1, 3] ].df('e-',\mixolydian).q(1),
		dur: b.parse([9,1]).q,
		instrument: \harp,
		out: Effect.bus({|i| 
			i
			=> FreeVerb.ar(_,1,1)
			* SinOsc.ar([4.2,3],[0,0.3]).range(0.6,1.2)
		},)
	].pp;
	[
		strum: 0.05,
		freq: [\r, [-5, -7, 1, 3] ].df('e-',4,\mixolydian).q(1),
		dur: b.parse([9,1]).q,
		// instrument: \harp,
		out: Effect.bus({|i| 
			i
			=> FreeVerb.ar(_,1,1)
			* SinOsc.ar([3.3,4],[0,0.3]).range(0.6,1.2)
		},)
	].pp
});
P(\line, music: { |p b e|
	[
		freq: "3 2 1 -7 -6 -5".df('f#',4).q,
		dur: "q q q q q q q".asBeats.warpTo(e.tempoMap).q 
	].pp
});
P(\xtraBassnotes, music: { |p b e|
	[
		freq: [\r, -7,-7,  ].df('e-',3,\mixolydian).q,
		amp:0.2,
		dur: "qqqqqq qqq qq ".asBeats.warpTo( e.tempoMap ).q
	].pp
});
P.tune();

["final note","1".dm('a-'),[1]].addLine;
P.still(\walkingOut, timecode: 636.85.seconds, music: { |p b e|
	 e.still.( 
		wait: b.sum,
		text: ["",""],
	)
});
P.tune(_  => Padd(\midinote,[-24, -12 ],_));
P(\plink, music: { |p b e|
	
	{
		Pluck.ar( PinkNoise.ar(0.1), 1, 0.1, 1.df('a-',[2, 3 ]) + Gendy1.kr(minfreq:0.2,maxfreq:[5,10]).range(-5,5) =>_.reciprocal, decaytime:4)
		=> {|i| CrossoverDistortion.ar(i) /50 + i }		
		* [0.5,1]
		* EnvGen.cutoff(b[0],3)
		=> DWGReverbC1C3.ar(_,mix:0.4)
		}.play
});
)
