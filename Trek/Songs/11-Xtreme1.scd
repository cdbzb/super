(
	// Stills("/Users/michael/trek/BySection/media/return to tomorrow.mov").current;
	Stills().current;
	Trek.cast.mccoy = \xuan;
//Line 239 The three volunteers are lying on beds, with the spheres on tables beside them. 
// try{ Song.transitionGroup.free };
// try{ Song.fader.free };
Song(\song,[]).current;

// Song.gain = -12.dbamp;

// Song.gainControl = Bus.control(server:s, numChannels:2).set(Song.gain, 1);

// Song.gainControl.scope;

// Song.transitionGroup = Group.before(s.defaultGroup );
// Song.transitionItems = Group.head(Song.transitionGroup);
// Song.transitionFX = Group.tail(Song.transitionGroup);
// Song.gainGroup = Group.tail(Song.transitionGroup);

Song.faderFunc = { |target|
	target = target ? RootNode(s);
	Song.fader.isPlaying.not.if { 
		Song.fader = {
			In.ar(0, Monitors.channels) *
			In.kr(Song.gainControl.index, 1).lag(1)
			// Env([Song.gain, 1], 0.5).kr(0, gate: \gate.kr(0))
			=> ReplaceOut.ar(0, _);
		}.play(target, addAction: \addToTail).register 
	};
	Song.innerFader.isPlaying.not.if {
		Song.innerFader = {
			In.ar(0,5)
			* In.kr(Song.gainControl.index + 1, 1).lag(1)
			// * Env([1, Song.gain], 0.5).kr(0, gate: \gate.kr(0))
			=> ReplaceOut.ar(0,_)
		}.play(s, target: Song.gainGroup).register
	};
};

// Song.fader.isPlaying.not.if{ Song.faderFunc.() };

Song.preroll = 0.5;

// Song.addLineFunc = { |sec|
// 	case {sec <= 30}{
// 		P(\gain, start:sec, lag: -0.21, music:{ |p b e| 
// 			Song.gainControl.set(Song.gain, 1);
// 			Song.fader.isPlaying.not.if{
// 				Song.fader.free; Song.innerFader.free;
// 				Song.faderFunc.()
// 			};
// 		})
// 	}{sec == 31}{
// 		P(\gain, start:sec, lag: 0, music:{ |p b e| 
// 			Song.gainControl.set(1, Song.gain);
// 			Song.fader.isPlaying.not.if{
// 				Song.fader.free; Song.innerFader.free;
// 				Song.faderFunc.()
// 			};
// 		})
// 	}
// };

Song.xtremeBassFX = (s.options.outDevice == "MacBook Pro Speakers").if{
	{
		Effect.bus( {|i| 
			Decimator.ar(i,rate:8000,bits:4)*(-6.dbamp)
			=> LeakDC.ar(_)
			=>.first DetectSilence.ar(_, time:1, doneAction:2)
			=> Pan2.ar(_,-0.4)})
	}
}{
	{
		Effect.bus( {|i| Decimator.ar(i,rate:8000,bits:4)*(-6.dbamp) 
		=> HPF.ar(_, 100)
		=> LeakDC.ar(_)
		=>.first DetectSilence.ar(_, time:1, doneAction:2)
		=> Pan2.ar(_,-0.4)})
	}

};

		// Song.gain = -14.dbamp;
		// Song.fader = Song.fader ? { In.ar(0, Monitors.channels) * Song.gain => ReplaceOut.ar(0, _) }.play(RootNode(s),addAction:\addToTail );

	// Song.resources.at(\infrastucture).()
Trek.synful; // puts a Synful in Song.synful1 and Song.synful2 and makes them persist using ~synful1 ~synful2 -- these should ACTUALLY be in Synful instead! is this what I am doing in AAS Strum?
( Song.synthVTracks = EventWithDefault( 
	\default, { |mix = 0.1|
		{|i|
			i=> DWGReverbC1C3.ar(_,mix:mix)
			/3
		}
	}
);
);
{
["space","r",[0.2]].addLine;
P(\bassnote,   music: 
	{ |p b e|
		(
			note: -24-5,
			amp:3,
			sustain:0.5 + Song.secDur[0..1].sum,
			dur:Song.secDur[1]+0.5,
			out:Effect({
				|i| 
				i * Env.asr(0.1,1,0).kr(0,gate:1)
				=> PlateReverb.ar(_,mix:0.9) 
				* 0.6  
				* Env.linen(0, p.secDur[0..1].sum, 0.02).kr(2,gate:1)
			}).bus.index
		).play
	}
);
["the extreme power of the","g a b- d5 b-4 a g", ].addLine; 
P.still(\wide, timecode: 2508.seconds, music: { |p b e|
	 e.still.( 
		wait: b.sum,
		fade:3,
		text: ["the extreme power","of the"],
	).sequenceText2(
			b.parse([7]), [ 
			["",""],
			],
	)
});
Song.strum= {
		 Formant.ar(fundfreq:\freq.kr + Gendy1.arWidth(freq: 1).range(-2,2), formfreq:\formfreq.ir(2016), bwfreq:880.0, mul:1.0, add:0.0) 
		 * Env.adsr(attackTime:0.01, decayTime:1.9, sustainLevel:0.5, releaseTime:1.0, peakLevel:1.0, curve:-4.0, bias:0.0).kr(2,gate:\gate.kr(1))
		 * \amp.kr(0.1)
		 => Out.ar(\out.kr(), _)
	}.asDefName;
P(\strum1, syl:2, music: {|p b e|

		(
			note:[-5,-3,-2,2,5,7],
			strum:0.03,
			instrument: [\harpS, Song.strum],
			formfreq: 7502,

			amp: [0.02, 0.02], coef: 0.1,
			sustain:2,
		out: Effect.bus({|i| i => Phaser2.ar(i, depth:0.5, rate:0.177, fb:0.3, cfb:0.1, rot:1.5707963267949, rq:1) * SinOsc.ar(3.6).range(0.7,1.1) }, inputChannels: 2)
		).play
	}
);
P.synthVs(role: \mccoy , take: [\lead, \double],
	pbind: [ Song.enlarge(8), Song.enlarge(8) ],
	params: {|p b k| [
	filter: (midinote: _ - 12).dup, 
	lyrics: "the extreme + power + of the alien + + mind will make the -",
	pitchTake: [1, 3],
	vocalMode: [ [ \Light, \Open ] ] ,// Chest and Power are available
	vmLight: Env( [0, 0, -100 ], b.parse([6, 1] ++ p.secDur[p.section(k) + 1])),
	vmOpen: Env( [-100, -100, 0 ], b.parse([6, 1] ++ p.secDur[p.section(k) + 1] )),
	// paramBreathiness: 1.5,
	breathiness: Env( [1.5, 1, 0, 0],b.parse([6, 1] ++ p.secDur[p.section(k) + 1])),
	pitchExpression:1.5, // or does this sound bad in second half
	paramGender: 0.1, //or change this midway?
	paramToneShift: 100 //or...
] }, music:{|p b e|
	{
		e.playbuf
		=> p.synthVTracks.at(e.key).()
	}.play
});
["alien mind will make the -","e5 d c f e f g f", ].addLine; 
P.still(\clear, timecode: 0.seconds, music: { |p b e|
	 e.still.( 
		wait: b.sum,
		text: ["alien mind","will make the"],
	)
});
P.synthV(role: \mccoy , take: \lead,
	filter: (midinote: _ - 12), 
	params: {|p b| [
	lyrics: "alien + + mind will make the -",
	pitchTake: 1,
	vocalMode: \Open,
	paramGender: 0.1,
	paramToneShift: 100

] }, music:{|p b e|
	{
		e.playbuf
		=> p.synthVTracks.at(e.key).()
	}//.play
});
P.double(role: \mccoy , take: \lead, params: {|p b| [
		
	] }, music:{|p b e|
		{
			e.playbuf
			=> p.synthVTracks.at(e.key).()
		}//.play
});
P(\strumTwo, syl:2, music: {|p b e |
	(
		lag:b[3]/2,
		note:[-5,-2,0,4,7],
		strum:0.03,
		sustain:2,
		instrument: [\harpS, Song.strum],
		formfreq: 7502,
		amp: [0.02, 0.02], coef: 0.1,
		out: Effect.bus({|i| i => Phaser2.ar(i, depth:0.5, rate:0.177, fb:0.3, cfb:0.1, rot:1.5707963267949, rq:1) * SinOsc.ar(3.6).range(0.7,1.1) }, inputChannels: 2)
	).play
});

P(\bassnote2,  music: { |p b e|
		(
			note: -12-5,
			amp:3,
			sustain:Song.secDur[e.start],
			//out:Song.bassBuss.index
			out:Effect({
				|i| 
				i * Env.asr(0.1,1,0).kr(0,gate:1)
				=> PlateReverb.ar(_,mix:0.9) 
				* 0.6  
				* Env.linen(0,p.secDur[1], 0.02).kr(2,gate:1)
			}).bus.index
		).play
	}

);
["r r r r heart action dan ger ous ly high- ", [ \r, \r, \r, \r, 5, 3, 1, 4, 3, 2, 1, 2 ].dm(\f) , ].addLine; 
P.synthVs(\kevin, take: [ \bg, \bg2],
	pbind: Song.enlarge(1),
	params: {|p b| [
		filter: (midinote: [-1,-1,-1,-1, 1, 5, 5, 6, 6, 6, 6, 4, 5].dm(\f)),
	lyrics: "r r r r heart action + dangerously + + + high - ",
	pitchTake: [1, 3]
] }, music:{|p b e|
	{
		e.playbuf
		=> p.synthVTracks.at(e.key).()
		/2
	}.play
});
P.still(\clear, syl:3, timecode: 0.seconds, music: { |p b e|
	 e.still.( 
		wait: b.sum,
		text: ["heart action","dangerously high"],
	)
});
P(\chord, music: { |p b e|
	[
		freq: 
		[[\r, \r, \r]] ++ [ 1, [5, 3, 1, 4, 3, 2, 1, 3], 5].flop => _ .df(\f) =>_.q
		,
		// legato: [8,1, 8],
		wet: 0, 
		amp: 0.3,
		// out: [2, 5, 3],
		out: 2,
		attack: 0,
		// dur: b.parse([4, 3]).q,
		dur: b.parse([4, 1, 1, 1, 1, 1, 1, 2, 1]).q,
		rests: MuteFirst(),

		instrument: \stringyy
	].ppm
});
P(\heartActionBass,  music: { |p b e|
	[
		\dur, b.q ++ [1.0].q,
		\note, Pseq([-2,-2,-2,0,-7,\r,\r,-2,-2,-2, 0,\r,-10])-24,\amp,2,
		\legato,Pseq([1 ,1, 1,1, 1.5,1,1, 1, 1, 1, 2, 1, 1]),
		\out, p.xtremeBassFX.()
	].pp
});
P(\guit, music: { |p b e|
	[
		freq: [4, 4, 4, 5, 1, 4, 4, 4, 5, -6].df([\F, \c], 4).q,
		instrument: \pluckD,
		dur: e.bAll.parse([1, 1, 1, 1, 3, 1, 1, 1, 2, 3]).q,
		amp: 0.02
	].ppm
});
P(\weeeeuw,music: {|p b e| 
		{
			FreeVerb.ar(Ringz.ar(WhiteNoise.ar(0.01),XLine.kr(2500,240,6),1),room:8,mix:7)
			* EnvGen.kr(Env.perc(0,7),doneAction:2)
		}.play
	}
);
P(\drums,music: {|p b e|
	var d= Song.durs[\action].list[0..3] ++ ((Song.durs[\action].list[4]/2)!2).asList ++ Song.durs[\action].list[5..8];
	var k = \kick2;
	k = \bd_808;
		Pbind( \instrument, Pseq([k, \rest, \snare, \rest, k, k, \snare,\rest]++
		[k, \rest, \snare, \rest, k,  k, \snare,\rest]),
		\dur, Pseq(d,inf),
		\lag, Pseq([0,0,-0.01,0,0,0,0,0],inf),
		//\amp,0.5
		\env, Pseg([0.5,0.5,0.3] * 0.5,[d[0..4].sum,d.sum-d[0..4].sum+1]),
		\amp, Pfunc({|e| (e.instrument == k).if{2}{1} * e.env})
	).play
});
P(\cymbal,music: {|p b e|
		Pbind(
			\instrument, Pseq([\rest, \rest, \rest, \rest, \rest, \rest, \rest,\rest]++ [\rest, \rest, \rest, \rest, \cymbal, \rest, \rest,\rest]),
			\dur,Pseq(d,2),\lag,-0.05,\amp,0.4
		)
});
P(\hat,music: {|p b e|
		Pbind(\instrument, \hihat,
			\ffreq,Pwhite(4000,10000),
			//\dur,(Pser(d,48)),
			\dur,(Pser(d/4,96)),
			\amp,Pseg([0.5,0.5,0]*0.15,[d[0..4].sum,d.sum-d[0..4].sum+4.2])
		).play
});
}.value;
P.synthVs(role: \mccoy , start:P.calcStart(), take: [\lead, \double],//wait:1,
	pbind:Song.enlarge(1),
	filter: (midinote: _ - 12), 
	params: {|p b| [
		lyrics: "r r r r heart action + dangerously + + + high -",
		pitchTake: [1, 3],
		vocalMode: \Open,
		paramGender: 0.1,
		paramToneShift: 100
	] }, music:{|p b e|
		{
			e.playbuf
			=> p.synthVTracks.at(e.key).()
		}.play
});
// ;
// P.calcStart;
//
//
[" - and the body functions will", "a5 c d a g a d a ", ].addLine; 
P.still(\turned, timecode: 2509.seconds, music: { |p b e|
	 e.still.( 
		wait: b.sum + e.bNext[0],
		fadeIn: b[0],
		fade: 1,
		text: ["",""],
	).sequenceText2(
			b.parse([1]), [ 
			["and the body functions","will race"],
			],
	)
});
P.synthVs(role: \mccoy,start: P.calcStart(\functions), take:[\lead, \double],
	wait:1,
	filter: (midinote: _ - 12), 
	pbind: Song.enlarge(1),
	params: {|p b| [
		lyrics: "r and the body + functions + will race",
		pitchTake: [1, 3]
	] }, music:{|p b e|
		{
			e.playbuf
			=> p.synthVTracks.at(e.key).()
		}.play
	}
);
P(\racing, music: { |p b e|
	// var bus = Bus.audio(2);
	{
		WhiteNoise.ar(0.1)
		// => LPF.ar(_, Impulse(10) => Decay.ar(_,0.1) => _.range(60, 3000) )
		* (
			Impulse.ar(10) => Decay.ar(_,0.1)
			=> HPF.ar(_,200)
			=> Pan2.ar(_,SinOsc.ar(0.3))
			*4
		)
		+ (
			PinkNoise.ar(0.8)
			* (Impulse.ar(2.5) => Decay.ar(_,0.1) )
			=> LPF.ar(_,Impulse.kr(2.5).range(60,100) => Decay.kr(_,0.1) )
			=> Ringz.ar(_,30,0.05)
			=> Pan2.ar(_,-0.5)
		)
		+ ( 
			BrownNoise.ar(0.1)
			* (Impulse.ar(2.5) => Decay.ar(_,0.1) )
			=> LPF.ar(_,Impulse.kr(2.5).range(60,100) => Decay.kr(_,0.1) )
			=> DelayN.ar(_,1/5,1/5)
			=> HPF.ar(_,200)
			=> Ringz.ar(_,120,0.1)
			=> Pan2.ar(_,0.5)
	).clip(0.1)
	=> HPF.ar(_,500)
	* Env([0,0,1,0],e.bAll.parse([2, 5,4])).kr(2,gate:1)
	/4
		
	}.play
});
P(\keys, music:{|p b e|
		[
			\dur, b.q ++ [1].q,
			\instrument,\test,
			\amp,1,
			\lag,Pwhite(-0.01,0.01),
			\midinote,Pseq([\r]++p.tune[e.start].list.copyRange(1,p.tune[e.start].list.size)++[79])-24,
			\lagTime: 0.2
		].ppma
});
[" race r r many times their natural me-", "g5 r r  e5 g5 a4 g5 f e g ", ].addLine; 
Song.setTempoMap(\natural,"q e e e e ex x E E E ");
P(\guit, music: { |p b e|
	[
		freq: [\r, 3, 5, 1].df(\a,3, ).q,
		dur: b.parse([1, 1, 1, 5]).q,
		instrument: \pluckD,
		out: Effect.bus({|i| Phaser1.ar(i,rate: 0.17) => Splay.ar(_, 0.5, 1,0.5 ) },),
		amp: 0.01
	].ppm
});
P(\skank, music: { |p b e|
	[
		freq: [1, 3, 5].df(\e, \minor),
		dur: "qe ee ee ee ee".asBeats.warpTo( e.tempoMapAll ).q,
		rests: MuteFirst(),
		instrument: \harp, amp: 0.03
	].pp
});
P(\chord, music: { |p b e|
	[
		freq: [
			\r,
			[3, 6, 11],
			[4, 11, 12],
			[7, 12, 13],
			[6, 11, 12]
		].df(\c,4).q,
		dur: e.bAll.parse([5,  5, 4, 7, 4]).q,
		instrument: \stringyy, mix: 0.0,
		amp: 0.07 * 3.dbamp, out: (1..3), freqLag: 0.5
	].ppm
});
P.still(\clear,syl:2,  timecode: 0.seconds, music: { |p b e|
	 e.still.( 
		wait: b.drop(1).sum + e.bNext[..3].sum,
		text: ["many times their","natural metabolism"],
	)
});
P.synthVs(role: \mccoy, take:[\lead, \dbl],
		pbind: Song.enlarge(4),
		params: {|p b| [
			filter: (midinote: _ - 12), 
			lyrics: "r r r many + times their natural + metabolism + + + + ",
			pitchTake: 2
		] }, music:{|p b e|
			{
				e.playbuf
				=> p.synthVTracks.at(e.key).()
			}.play
});
P(\strum3,music:
			(\note: [4,16,19]-12,\dur:3,\strum: 0.03);
		);
P(\bass3, music: {|p b e|
		[
			freq: "r 3 5 1".df(\a, 2).q,
			dur: b.q,
			amp: 0.8,
			rest: MuteFirst(),
			out: Effect.bus({|i| HPF.ar(i, 100) },inputChannels: 2)
		].pp
});
["tabolism so we're going to have to", " f5 e d c r g#4 a b c5 d e ", ].addLine; 
Song.setTempoMap(\tabolism,"e e e ee x x x x x x");
P.still(\clear, syl:4, timecode: 0.seconds, music: { |p b e|
	 e.still.( 
		wait: b.drop(1).sum,
		text: ["so we're going to","have to"],
	)
});
P.synthV(role:\kirk,wait:1,start:P.calcStart(),take:\lead,
		filter: (midinote: _ - 12), 
		pbind: {|p b| 
			var here = P.calcStart(\tabolism);
			[
				dur: b ++ Song.durs[here + 1].list[0..3] => _.flat => _.q,
				midinote: p.tune[here].list ++ p.tune[here+1].list[0..3] =>_.flat => _.q
			].p
		},
		params: {|p b| [
			lyrics: "r r r r r so we're gonna +  have to monitor + + this",
			pitchTake: 1
		] }, music:{|p b e|
			{
				e.playbuf
				=> p.synthVTracks.at(e.key).()
			}.play
		});
P.double(role:\kirk,start:P.calcStart,wait:1,take:\lead,
			filter: (midinote: _ - 12), 
			pbind: {|p b| 
				var here = P.calcStart(\tabolism);
				[
					dur: b ++ Song.durs[here + 1].list[0..3] => _.flat => _.q,
					midinote: p.tune[here].list ++ p.tune[here+1].list[0..3] =>_.flat => _.q
				].p
			},
			params: {|p b| [

			] }, music:{|p b e|
				{
					e.playbuf
					=> p.synthVTracks.at(e.key).()
				}.play
			});
P(\bass5, music: {|p b e|
		Pbind(
			\midinote,(Pser(p.tune[e.start].list,4)++Pseq([71,71-7]))-36,
			\dur,Pseq(b[0..3]++b[4..6].sum++1),
			\amp,0.8,
			\lag,Pwhite(-0.02,0.02),
			\out, Effect.bus({|i| HPF.ar(i, 120) },inputChannels: 2)
		).play
});
P(\drums5,music: {|p b e|
		Pbind( \instrument, Pseq([\kick2, \kick2, \snare, \kick2, \kick2,] ),
		\dur,Pseq(b[0..3]++b[4..6].sum++1),
		//\lag,Pseq([0,0,-0.01,0,0,0,0,0],inf),
		//\amp,0.5
		//\amp,Pseg([0.5,0.5,0.3]*0.5,[d[0..4].sum,d.sum-d[0..4].sum+1])
	).play
}
	);
P(\hat5,music: {|p b e|
		Pbind(
			\instrument, \hihat,
			\ffreq,Pwhite(4000,11000),
			//\dur,(Pser(d,48)),
			//\dur,(Pser(d/4,96)),
			\dur,Pseq(((b[0..3]++b[4..6].sum++1)/2).stutter(2)),
			\amp,Pseq([1,0.4]*0.1,4)
		).play
});
[" mo- ni- tor this very", "d5 c4 a4 f f5 e ", ].addLine; 
P(\bassnote6,music: {|p b e|
			[
				freq: "3 2 1".df(\f, 2).q,
				dur: b.parse([2, 1, 1]).q,
				amp:0.8,
				out: Effect.bus({|i| HPF.ar(i, 100) },inputChannels: 2)
			].pp
});
P.still(\mccoy, timecode: 2509.seconds, music: { |p b e|
		 e.still.( 
			wait: b.sum + e.bNext.sum,
			text: ["monitor this","very carefully"],
		)
});
P.synthV(role: \mccoy,wait:1, take:\lead,start:P.calcStart('mo- ni'),  
	filter: (midinote: _ - 12), 
	pbind: {|p b| 
		var here = P.calcStart('mo- ni');
		[
			dur: b ++ Song.durs[here + 1].list[0..3] => _.flat => _.q,
			midinote: p.tune[here].list ++ p.tune[here+1].list[0..3] =>_.flat => _.q
		].p
	},
	params: {|p b| [
		lyrics: "r r r r very + carefully + +",
		pitchTake: 2
	] }, music:{|p b e|
		{
			e.playbuf
			=> p.synthVTracks.at(e.key).()
		}.play
});
P.double(role: \mccoy,wait:1, take:\lead,start:P.calcStart('mo- ni'), params: {|p b| [

	] }, music:{|p b e|
		{
			e.playbuf
			=> p.synthVTracks.at(e.key).()
		}.play
});
P(\pad6,music:
		{
			{
				var a = (
					instrument:\sawSynth,
					hifreq: 8000, lofreq: 2000,

					//midinote:[69,72,75]
					degree:[5,8,9]
					,att:2,rel:3,amp:0.05,lagTime:0.2
				).play;
				//a.set(\freq,[69,74,77].midicps)
				(type:\set,id:a[\id],freq:[69,74,77].midicps,lag:1.1).play;
				(type:\set,id:a[\id],freq:[71,74,77].midicps,lag:2.25).play
			}.value
		}
	);
P(\cymbal5,music: 
		(\instrument:\cymbal,\lag:Song.durs[5].list[1..4].sum)
	); 
P(\tremolo6,syl:5,music: {|p b e|
		Pbind(
			/*\instrument,  \pluck ,*/
			\note,[7-12,7]*[1,2],
			\dur,Pwhite(0.05,0.1),
			\strum,0.01 ,
			\amp,Pseg([0.2,0.5*Pwhite(0.8,1.2,inf)*0.0001]*0.3,[5.1,1.9], \exp, \offset,0)
		).play //TODO set synth
});
["carefully","e5 d b4 r r r", ].addLine; 
["r r r well... I ", "r r r a g#", ].addLine; 
P.still(\clear, timecode: 0.seconds, music: { |p b e|
	 e.still.( 
		wait: b.sum+e.bNext.sum+p.durs[e.start+2].list[0],
		text: ["",""],
	).sequenceText2(
			e.bAll.parse([3, 2, 5]), [ 
			["Well","I"],
			["guess","that's as ready"],
			["as we're going to","be"]
			],
	)
});
P.synthVs(role: \mccoy, take: [\lead, \double],
		start:Song.section(\well), 
		pbind: Song.enlarge2(1),
		params: {|p b| [
			lyrics: "r r r well I guess that's as ready + as we're going to be",
			legato: [[1, 1, 1, 0.7, 1, 0.9, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1 ]],
			pitchTake: [1, 3],
			parmGender:0.1,
		] }, music:{|p b e|
			{
				e.playbuf
				=> p.synthVTracks.at(e.key).()
			}.play
		});
P(\bass8,music: {|p b e|
		Pbind(
			\note, Pseq([5,4,2,1]-24),
			\dur, b.q,
			\amp, 0.5,
			\out, Effect.bus({|i| HPF.ar(i, 100) },inputChannels: 2)
		).play
	}
		);
P(\bass8Alt,music:
Pbind(\instrument,\test,\note,Pseq([5,4])-[0+rand(0.02),12],\lag,Pseq([0,0]),\amp,0.5)
		);
P(\strum8,syl:1,music:
			(note:[1,4,9]-12++[1,4],strum:0.04,sustain:2,lag:0.52,amp:0.05)
		);
["guess that's as read- y as I'm gon- na ","g e- f g e- d- e- f g ", ].addLine; 
P(\strum9,start:'read- y',music:
			(midinote:~panNotes.(" <g b- e-5 g5>").flatten-12,strum:0.042)
);
P(\bass9,start:'read- y',music: 
			(note:~panNotes.("e-2").flatten-60,dur:2,amp:0.3)
);
["be. Rea- dy Sar- gon","a d5 c a4 f#", ].addLine; 
P.synthV(role:\kirk, take: \lead, params: {|p b| [
			filter: (midinote: _ - 12), 
			lyrics: "r ready + sar gone",
			pitchTake: 1
		] }, music:{|p b e|
			{
				e.playbuf
				// => p.synthVTracks.at(e.key).()
				/4
				=> {|i| Fverb.ar(i,i)/5+i}
			}.play
		});
P.still(\kirkOnBed,syl:0, timecode: 2519.8.seconds, music: { |p b e|
			 e.still.( 
				wait: b.drop(1).sum,
				text: ["Ready","Sargon"],
			)
		});
P(\tremoChord,music: {|p b e|
		Pfxb(
			Pfindur(b[0],
			Ppar(
				[-3,0,3,5].collect{|i|
					Pbind(
						\note,i,
						\dur,Pwhite(0.05,0.08),
						\amp,Pseg([0.02,0.13,0.15,0],[0.3,0.3,1.9]),
						\pan,0.5
					)
				}.value;
			)
		),\verb_fade,\time,2
	).play
});
	
P(\tremoChord2,syl:0,music:
Pfxb(
Pfindur(Song.durs[P.calcStart()].list[1..4].sum-0.1,
Ppar(
				[-3,0,2,6].collect{|i|
		Pbind(
						\note,i,
						\dur,Pwhite(0.05,0.08),
						\amp,Pseg([0.02,0.17,0.15,0],[0.4,0.6,1.9]),
						\pan,-0.5
					)
				}.value;
			)
		),\verb_fade,\time,2
	);
);
["(transformation!)","r",[ 15 ]].addLine;
P.still(\transformation, timecode: 2530.seconds, music: { |p b e|
	 e.still.( 
		wait: b.sum,
		text: ["",""],
		wait:3,
	)
});
P.still(\mulhallTrans,lag:3, timecode: 2532.seconds, music: { |p b e|
	 e.still.( 
		wait: b.sum,
		text: ["",""],
		wait:3,
	)
});
P.still(\scpockTrans,lag:6, timecode: 2536.seconds, music: { |p b e|
	 e.still.( 
		// wait: b.sum - 6,
		wait:3,
		fade:2,
		text: ["",""],
	)
});
P.still(\sargonNow,lag:9, timecode: 2556.1.seconds, music: { |p b e|
	 e.still.( 
		wait: b.sum - 9 + e.bNext.sum,
		fadeIn:6,
		text: ["",""]
	).sequenceText2(
			b.sum - 9, [ 
				["the transfer is","complete"],
			],
	)
});
P(\transform,start:'transformation!',music:{ |p b e| 
	var dur = b.sum; 
	var gain = 2;  //TODO try an envelope here!!
	var transGain = 0.8;
	var pitches=~panNotes.("f#3 b- c4 e")+[0,12]; //TODO remove this function
	s.bind{
		var chord=pitches.collect({|item index|  Synth(\trans,[\freq,item.midicps,\amp,0.1 * gain * transGain])});
		var chord2=pitches.collect({|item index|  Synth(\trans,[\freq,item.midicps,\amp,0.1 * gain * transGain])});
		//Song.init;
		try{~fadeO.stop};
		//try{Song.synful1.controller.loaded.not.if{Song.synful1.init}}{Song.synful1=~synful.()};
		//try{Song.synful1.controller.loaded.not.if{Song.synful1.init}}{Song.synful1=~synful2.()};
		{dur.wait;chord.do{|i|i.release}}.fork;
		{dur.wait;chord2.do{|i|i.release}}.fork;
	};
	////cymbal
	(instrument:\cymbal,length:8, amp: 0.1 * gain).play;
	////strings
	//try{Song.synful1.monitor.free;};Song.synful1.monitor=Monitor.new;Song.synful1.monitor.play(Song.synful1.bus.index,2,0,2,fadeTime:0.05);
	//try{Song.synful2.monitor.free;};Song.synful2.monitor=Monitor.new;Song.synful2.monitor.play(Song.synful2.bus.index,2,2,2,fadeTime:0.05);
	Song.synful1.syn.set(\out,Effect(FreeVerb.ar(_,0.75,0.55)*3* gain).bus.index);
	Song.synful2.syn.set(\out,Effect( { |i| PlateReverb.ar(i,mix:0.55)*2 * gain * Env.linen(0,b.sum,5).kr(doneAction:2,gate:1) } ,out:2).bus.index);
	//TODO these need to turn themselves off with DoneActions rather than routines

	Song.synful1.setprog(3,5,0); Song.synful1.setprog(4,5,1);
	//Song.synful2.setprog(3,5,0); Song.synful2.setprog(4,5,1);
	Song.synful2.patch(\violas,\tremsulpont,0);
	Song.synful2.patch(\violins2,\tremsulpont,1);
	//FADE Synful
	{
		8.wait;"now!".postln;
		127.do(
			{|i|
				[Song.synful1,Song.synful2].do(_.expression((127-i),0));
				[Song.synful1,Song.synful2].do(_.expression((127-i),1));
				0.18.wait;
				//'---->'.post;i.postln;

			}
		);
	}.fork;
	//Song.synful2.expression(0,0)
	//~fade0

	s.bind{
		//(type:\midi,midiout:Song.synful1.controller.midi,\midinote:~panNotes.("f#3 b- c4 e").flatten-[0,12],dur:20).play;
		(type:\vst_midi,vst:Song.synful1.controller,\midinote:~panNotes.("f#3 b- c4 e").flatten-[0,12],dur:20).play;
		//(type:\vst_midi,vst:Song.synful1.controller,\channel:2,\midinote:~panNotes.("f#3 b-4 c4 e").flatten-24,dur:20).play;
		(type:\vst_midi,vst:Song.synful2.controller,\channel:2,\midinote:~panNotes.("f#3 b-4 c4 e").flatten-24,dur:20).play;
		Song.synful1.expression(127,0);
		Song.synful1.expression(127,1);
		Song.synful2.expression(127,0);
		Song.synful2.expression(127,1);
	};
	//tympani

	s.bind{{ |pitchScale=1.15 loss=0.99998 |
		var env=Env.linen(0,dur-5,8).kr(2,gate:1)*0.175;
		var numChannels=4;
		var exc = Dust.ar(2!numChannels)+Impulse.ar(0);
		var sig;
		exc = Decay.ar(exc,0.02);
		exc=Integrator.ar(exc,0.8,0.1);
		exc=PinkNoise.ar(exc);
		sig=MembraneCircle.ar(exc,[0.007,0.0073]*pitchScale,loss)*env;
		sig * gain
	}.play;}

});
["the tran - fer is com-"," f5 c a-4 e c#"].addLine;  
// P.tune('tran -');
P.synthV(\genbu, take: \lead,
	filter: (midinote: _ - 12), 
	pbind: {|p b| 
		var here = Song.section('com-');
		[
			dur: b ++ p.durs[here + 1].list[0] => _.flat =>_.q,
			midinote: p.tune[here].list ++ p.tune[here + 1].list[0].postln => _.flat => _.q,
		].p
	},
	params: {|p b| [
		lyrics: "the transfer + is complete +",
		phonemes: ["z i","ch w a n s","f a r"," i z"," k o m","p l i t" ],
		legato: [1, 1, 1, 0.6, 1, 1, ],
		pitchTake: 1
	] }, music:{|p b e|
		{
			e.playbuf
			=> p.synthVTracks.at(e.key).()
		}.play
});
P(\bassnotes,start:'tran - fer',syl:3,music:
Pseq([
			(note:1-24,amp:0.5,dur:Song.durs['tran - fer'].list[4]),
			(note:1-24,amp:0.6,dur:5,sustain:2)
		])
	);
P(\chord0,start:'tran - fer',syl:3,music:
Pfx(
Pseq([
				(note:[1,8,13]-24,instrument:\sawSynth,release:4,strum:0.03,dur:Song.durs['tran - fer'].list[4]),
				(note:[1,8,13]-24,instrument:\sawSynth,release:5,strum:0.03,dur:11),
				(note:\r,dur:12),
			]),\phase_verb
		)
	);
P(\pad0,start:'tran - fer',music:
Pbind(\midinote,Pseq(Song.tune[Song.section( 'tran -' )].list[0..3])-[0,12],\instrument,\sawSynth,\dur,Song.durs['tran -']);
	);
["plete. metabolic rate is","c#4 c5 b-4 c5 a-4 d4 c5"].addLine; 
P.still(\chapelMetabolic, timecode: 2608.8.seconds,syl:0, music: { |p b e|
	 e.still.( 
		wait: b.drop(1).sum + e.bNext[..6].sum,
		text: ["metabolic rate is","double and rising, Doctor"],
	)
});
P.synthV(role: \chapel , take: \lead,
	pbind: Song.enlarge(7),
	params: {|p b| [
	lyrics: "r metabolic + + + rate is double + and rising + doctor +",
	legato: [1, 1, 1, 1, 1, 1, 1, 1, 0.7, 1, 1, 0.7, 1, 1, ],
	pitchTake: 1,
	// vocalMode: \Power
] }, music:{|p b e|
	{
		e.playbuf
		=> p.synthVTracks.at(e.key).()
	}.play
});
P.tune('plete. m');
P(\chords,syl:0, music: { |p b e|
[
	freq: [
			[3, 7, 12],
			[13, 7, 11],
			[12.5, 7, 11],
			[12.5, 6, 11],
		].df('b-',4,\mixolydian).q,
		dur: e.bAll.drop(1).parse([6, 1, 2, 2]).q,
		instrument:\sawSynthSustain,
		lofreq:5000,
		amp:0.03, att:2,
		out:2
	].ppm
});
["double and rising, Doctor...r  Hel- ", "d5 b-4 c#5 g c# a-4 g r b"].addLine; 
P.still(\clear,syl:7, timecode: 0.seconds,lag: 0.01, music: { |p b e|
	 e.still.( 
		wait: e.drop(1) ++ e.bNext.sum,
		text: ["",""],
	)
});
P.synthVs(role: \henoch, take: [\lead, \double],
		pbind: Song.enlarge(1),
		filter: (midinote: _ - 12), 
		params: {|p b| [
			lyrics: "r r r r r r r r Hell oh",
			phonemes: ["","","","","","","","hh eh l","l ow"],
			pitchTake: [1, 3]
		] }, music:{|p b e|
			{
				e.playbuf
				=> p.synthVTracks.at(e.key).(mix:0.02)
			}.play
		});
P(\bassnotes3,start:'Hel-',music: //TODO change this instrument??
			(note:-2-12,amp:0.1)
		);
P(\bassnotes4,start:'Hel-',syl:2,music:  //TODO change this instrument??
			(note:[7,-5],amp:0.1,sustain:2)
		);
["lo. r r r"," c#5 d2 d d"].addLine; 
Song.helloGain = 3.dbamp;
P.still(\henochRude,syl:nil, timecode: 
	// 2613
	2620.3
	.seconds, music: { |p b e|
		 e.still.( 
			wait: b.sum + e.bNext.sum,
			text: ["Hello",""],
		).sequenceText2(
				b.sum, [ 
				["",""],
				],
		)
});
P(\helloChord,start:'lo. ',music: {|p b e|
		(instrument:\test,midinote:~panNotes.("<d4 f# a c#>").flatten,strum:0.03,amp:0.4 * p.helloGain).play
});
~helloTempo={1/Song.durs['lo. r'].list.mean};
~helloTemp2={1/(Song.durs['lovely female'].list[0..6].sum/5*2)};
P(\helloSequence,start:'lo. ',music: {|pp bb ee|
		var bus, clock, p,
		length = bb.sum + ee.bNext.sum + pp.secDur[ee.start + 2].sum,
		kickPatterns,kickBar,snarePatterns,snareBar,synth,helloBass2,helloBass1,helloBeat;
		bus=Bus.audio;clock=TempoClock.new;
		kickPatterns=[[3/4,1/4],1];
		p=[0,0,0,0,1,1,1,0]++[1,0,1];   ///XTENDED
		kickBar=Pseq(p.collect{|i|kickPatterns[i]}.flatten);

		snarePatterns=[[Rest(3/4),1/4],[Rest(1)],[Rest(1/2),1/2],[Rest(1/2),1/4,1/4],[Rest(1/4),1/4,1/2]];
		p=[0,1,2,0, 0,3,0,4]++[0,4,4];   ///XTENDED
		snareBar=Pseq(p.collect{|i|snarePatterns[i]}.flatten.drop(-1));

		synth= Pbind( 
			\note,Pseq([2-24,2-12,-1-12,9-12])-12,
			\instrument,\sawSynth,
			\dur,2,\rel,5,
			\amp,0.2
		) ;

		helloBass1=Pbind(
			\note, Pseq([2,4],4)-24,
			\legato,Pseq([1,Pwhite(0.25,0.55,1)],4),
			\amp,0.5
		) ;

		helloBass2=Pbind(
			\note,Pseq([\r,2,0],8),
			\dur,Pseq([1/2,1/4,1/4],inf),
			\amp,0.04
		) ;

		helloBeat = {
			|synthamp=0.3 drumsamp=1 lineAmp=1 tempo1=(52/60) tempo2=(50/60)|
			Ppar([
				Pbind(
					\tempo,Pseq([tempo1,tempo2]),\dur,4,\note,\r
				),
				Pbind(
					\instrument,\kick1,
					\dur,kickBar,
					\amp,drumsamp*0.1
				),
				Pfin(
					42, Pn( ///XTENDED
						Pbind(
							\instrument,\hihat, //ffreq rel
							//\dur,Pseq([0.245,0.255],32),
							\dur,Pseq([0.245,0.255],32),
							\amp,Pseq([Pwhite(0.3,0.4,1),Pwhite(0.2,0.3,1)],32)*0.4*drumsamp,
							\lag, Pseq( (1!16++(-1!16)).scramble*0.003),
							\ffreq, Pwhite(6000,6500),
							\rel,0.15
						) ,2
					)
				),
				Pbind(
					\instrument,\snare,
					\instrument,\sn_808,
					\dur,snareBar,
					\amp,drumsamp*0.1
				),
				Pfx(
					Pbind( \instrument,\sawSynth,
						\note,Pser(~panNotes.("d f# a c#5 e5").flatten-60,16),
						\dur,1/2,
						\att,0.5,
						\octave,Pser(4!5++(5!5)++(6!5)++(7!5),42),
						\amp, Pseq(( 0.1!5 )++(0.09!5)++(0.08!5)++Pseries(0.07,-0.005)) * lineAmp
					).pad,
					\phase_verb2
				),
				//~helloBass1,
				//~helloBass2,
				Pset(\amp,synthamp,synth),
				//Pseq([(\type:\rest,dur:4),~complete.pbind[4]]);//remove
				//Ptpar([
				//		0.15,~helloGtr1,
				//		0.15,~helloGtr2
				//	])
			],1   /// repeats!!
		)<>(out: bus)};
		Song.helloSequenceBus = bus;
		Song.helloSequenceMonitor = Monitor.new.play(bus.index,2,0);
		fork{
			bb.sum.wait;
			Song.helloSequenceMonitor.play(
				Song.helloSequenceBus.index,2,1,1,
				fadeTime:Song.secDur[4..5].sum,
				volume:0.2
			);
			Song.secDur[4..5].sum + 0.1 => _.wait;
			Song.helloSequenceMonitor.clear;
			Song.helloSequenceBus.free;
			// clock.free
		};
		s.bind{
			helloBeat.(
				synthamp:0.1 * Song.helloGain,
				drumsamp:0.7 * Song.helloGain,
				lineAmp:1 * Song.helloGain,
				tempo1:~helloTempo.(),
				tempo2:~helloTemp2.()
			).play(clock)
		};
});
["you are a lovely female, r a","e5 d c# b4 a f# e e2 c#4"].addLine;
P.still(\clear, timecode: 0.seconds, music: { |p b e|
		 e.still.( 
			wait: b.sum + e.bNext.sum ,
			text: ["you are a","lovely female"],
		).sequenceText2(
				b.parse([7, 1]), [ 
					[ "","" ],
				["a pleasant sight","to wake up to after"],
				],
		)
});
P.synthVs(role: \henoch, take: [ \lead, \double ],
			params: {|p b| [
			filter: (midinote: _ - 12).dup, 
			lyrics: "you are a lovely + female + r",
			lag:[[0.05, 0.025, 0, 0, 0, 0, 0]],
			legato: [[1, 1, 1, 1, 1, 1, 1.7]], 
			pitchTake: [1, 3]
		] }, music:{|p b e|
			{
				e.playbuf
				=> p.synthVTracks.at(e.key).(mix: 0.05)
			}.play
		});
P(\bass4,start:'lovely female',syl:6,music:
			(instrument:\sawSynth,note:[7,-5]-12,amp:0.2,sustain:2,att:1.0,rel:3)
		);
P.synthVs(role: \henoch, take: [\lead2, \bg2 ],
			pbind: Song.enlarge2(6),
			params: {|p b| [
			filter: (midinote: _ - 12), 
			lyrics: " r r r r r r r r a pleasant + sight to wake up to after + half a million + years -",
			legato: [[1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 0.8, 1, 1, 1, 1, 1, 1, 1, 1.3, ]],
			lag: [[0,    0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0,   0, 0, 0, 0, 0, 0, 0, 0.06, ]],
			pitchTake: [ 1, 3 ]
		] }, music:{|p b e|
			{
				e.playbuf
				=> p.synthVTracks.at(e.key).()
				* p.helloGain
			}.play
});
["pleasant sight to wake up to after","e4 d c# d e b a f# a "].addLine; 
P(\xtraChord, music: { |p b e|
	[
		freq: [
			[3, 5].df(\a),
			[3, 5].df(\d)
		].q /2,
		dur: b.parse([5, 4]).q,
		freqLag:2,
		detune: 4,
		instrument: \visual_pad, amp: 0.7, mix: 0, out: 2
	].ppm
});
P.tune( [mix:0.2,instrument: \stringyy, amp:0.1, out: 4].pm <> _ );
P(\bass5,start:\pleasant,syl:4,music:
			(instrument:\sawSynth,note:[7,-5]-13,amp:0.2,sustain:2,att:1.0,rel:3)
		);
["half a million years- r r ","f5 g f e  e d c# c#"].addLine;
Song.setTempoMap(\half,"eee e e ee ee ee e ee");
P.still(\clear, timecode: 0.seconds, music: { |p b e|
		 e.still.( 
			wait: b.sum,
			text: ["half a million","years"],
		)
});
P.tune('half a million',_<>  [instrument: \harp,coef:0.8, out:1].p);
P(\bass6,start:'half a million',music: {|p b e|
		[
			note: [5,4,7].q,
			octave: 3 ,
			amp:0.5,
			dur: "eeeeee ee ee ".asBeats.warpTo( e.tempoMap ).q
		].pp
});
~durs6=Song.durs['half a million'].list;
P(\yow6,start:'half a million',music: {|p b e|
		[\instrument,\yowbass,
			\note,Pseq([[-3,0],[-3,0],[-5,-1]]),
			\dur,Pseq( [~durs6[0..2].sum,~durs6[3],~durs6[4..8].sum]),
			\amp,0.1,
		].pp
});
P(\keys6,start:'half a million',music: {|p b e|
		[
			\instrument,\harp,
			\midinote, [11, 3, 5].dm(\f).q,
			\dur,//Pseq(
			Song.durs['half a million'].list.[0..1]
			.sum/4
			//) //make a function for this
		].pp
	}
);
P(\keys62,start:'half a million',syl:5,music:
Pbind(
				\instrument,\stab,
				\note,Pseq([ [7,9,13],[7,9,13],[5,9,14] ]),
				\dur, Pseq(Song.durs['half a million'].list.[6..7]++[1]) ,
				\amp,Pseq([1,1.3,1])*0.8,
				\out, [1,1,1].q
			)
		);
P.synthV(role: \chapel, take: \lead,
	pbind: Song.enlarge(1),
	params: {|p b| [
	lyrics: "r r r r r r r thank you",
	pitchTake: 1
] }, music:{|p b e|
	{
		e.playbuf
		=> p.synthVTracks.at(e.key).()
	}.play
});
P.still(\mouthClosed,syl:6, timecode: 2624.5.seconds, music: { |p b e|
	 e.still.( 
		wait: b.drop(1).sum + e.bNext[0].sum,
		text: ["thank","you"],
	)
});
["r r you're welcome","d5 f4  g5 f "].addLine;
P.still(\HenochWelcome,syl:0, timecode: 2626.65.seconds, music: { |p b e|
		 e.still.( 
			wait: b.drop(1).sum,
			text: ["you're","welcome"],
		)
});
P.tune('r r you');
P.synthVs(role: \henoch, take: [\lead, \double],
			filter: [(midinote: _ - 12),(midinote: _ - 24)], 
			params: {|p b| [
			// lyrics: " r yoh uel kam r",
			lyrics: " r you're welcome +",
			// lag: [[0, Song.durs[\elcome].list[1]/2,0,0]],
			pitchTake: [1, 3]
		] }, music:{|p b e|
			{
				e.playbuf
				=> p.synthVTracks.at(e.key).()
				* p.helloGain
			}.play
});
P(\bass7,start:'r r you',syl:0,music: {|p b e|
		(
			note:5-24,
			dur:b[..2].sum,
			amp:0.5
		).play
});
P(\keys7,start:'r r you',syl:0,music:
Pbind(
				\instrument,\harp,
				\midinote,Pseq(~panNotes.("f5 a4 c5")-[0,12]),
				\dur,//Pseq(
				Song.durs['r r you'].list.[1..2]
				.sum/4
				//) //make a function for this
			)
		);
P(\yow7,start:'r r you',syl:0,music:
			(instrument:\yowbass,note:[-3,0,5],dur:3,amp:0.05)
		);
P.tune(_<>  [instrument: \harp,coef:0.8,out:1].p.fin(1));
["I've forgotten what it fee-","g#4 e b f# a# b c#5"].addLine;
P.still(\thalassaForgotten, timecode: 2647.9.seconds, music: { |p b e|
			 e.still.( 
				wait: b.sum + e.bNext.sum,
				fade: p.durs[e.start + 2].list[..2].sum,
				text: ["I've forgotten","what it feels like"],
			).sequenceText2(
					b++p.durs[e.start + 1].list =>_.parse([9]), [ 
					["even to breathe","again"],
					],
			)
		});
P.synthV(role: \thalassa, start: Song.section(\forgotten), take: \lead, 
	// filter: (midinote: _ - 12), 
	filter: (midinote: _ + [0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 12, 12]),
	pbind: Song.enlarge2(5,Song.section(\forgotten)),
	params: {|p b| [
		lyrics: "aiv fo ga ten wat it filz - laik iven + tu briz - a gen, so gon? ",
		phonemes: ["","","","","","","f i l ts","", "", "", "", "", " p r` i t ", "","a","k e n", "s a","g o n"],
		legato: [1, 1, 1, 1, 1, 1, 1, 1, 0.8, 1, 1, 1, 1, 1, 1, 0.66, 1, 1, ],
		pitchTake: 1,
	]}, music:{|p b e|
		{
			e.playbuf
			=> p.synthVTracks.at(e.key).()
			* Env([3, 2, 1, 0, -2], b.parse([2,5,11,  1,])).kr(0,gate:1).dbamp
			/2
		}.play
});
		// P.tune('what it fee');
P(\pad8,start:'what it fee',music:
			p{
				var du=Song.durs['what it fee'].list;
				var dv=Song.durs['even to br'].list;
				var a=(
					instrument:\sawSynth,
					lofreq: 5000,
					out:[[0,2],[2,0],1],
					midinote:[4,8,11]+60,
					att:4.5,
					rel:5,
					amp:0.15,
					lagTime:0.3,
					pan: [-0.6, -0.3, 0.6],
					out: 2
				).play;
				[
					type:\set,
					id:a[\id],
					freq: Pseq([ [4,8,11],[3,6,11],[3,6,10],[1,6,10],[1,4,10],[-1,4,8] ]+72).midicps ,
					dur:Pseq([du[0..1].sum,du[2..3].sum,du[4..6].sum,dv[0..1].sum,dv[2..5].sum,1 ]),
				].pp;
			}
		);
P(\trombone,start:'what it fee',music: 
			{ |p b e|
				'NOWWWWWW'.postln;
				[
					type:\synful,
					expression: 90,
					instance:Song.synful1,
					chan:1,
					patch: \trombone,
					midinote: [5,1,-7].dm('c#',[2,4],\mixolydian).q,
					out: Effect.bus( { |i| DWGReverbC1C3.ar(i,mix:0.9,c1:2)  } ),
					// - [12,36]
					// Pseq(~noteList.(["g#","c#","b3"]))-[12,36] ,
					// dur:[Song.secDur['what it fee'],Song.secDur['even to br'],3].q,
					dur: [b.sum, e.bNext.sum, p.durs[ e.start + 3 ].list.drop(2).sum].q,
					amp:0.2,
				].pp
				//Song.synful1.monitor.play(Song.synful1.bus.index,2,111,2,fadeTime:0.05,volume:0.6);

});
["ls like even to brea-","d#5 a#4 c#5 d# e f# "].addLine;
["th again, Sargon?"," g#5 f# b4 g4 g"].addLine;
P.still(\looking, timecode: 2658.6.seconds,syl:2, music: { |p b e|
			 e.still.( 
				wait: b.sum,
				text: ["Sargon?",""],
			)
		});
P(\sargon10,'th again, S',syl:2,music:
Pseq([
				(note:[4,7,10],dur:Song.durs['th again, S'].list[3],\amp:0.3),
				(note:[4,7,10],dur:Song.durs['th again, S'].list[4],\amp:0.3)
			])
		);
["Here, in this body","f e g f c"].addLine;
P.still(\sargon, timecode: 2710.3.seconds, music: { |p b e|
			 e.still.( 
				wait: b.sum,
				text: ["Here","in this body"],
			)
		});
P.synthV(\genbu, take:\lead, params: {|p b| [
			lyrics: "hie in zisu ba di",
			phonemes: ["","","z i t s ","","",""],
			lag: [0.05, 0, 0, 0, 0, ],
			legato: [0.6,1,0.8,1,1],
			pitchTake: 1
		] }, music:{|p b e|
			{
				e.playbuf
				=> p.synthVTracks.at(e.key).()
			}.play
		});
P(\pf11,music: {|p b e|
					[
						midinote:Pseq( ~noteList.(["<a c5 f>","<g c5 e>","<b- d5 g>","<a c5 f>"])-12),
						dur:Song.durs['Here, in this'],
						strum:Pseq([0.01,0.01,0.02,0.01]),
						instrument: \defaultRetrig,
						legato: [1, 1, 1, 2, ].q,
						pan: -0.8,
						amp: 0.08,
						out: [0,2]
					].pp;
					[
						instrument:\testSustain,
						amp:0.5,
						midinote:Pseq( ~panList.("c g3 f c4"))-[ 12,24 ]-7,
						dur:Song.durs['Here, in this'],
						legato: [0.9, 1, 0.9,2, ].q,
						out: [1, 3]
					].ppma
				}
		);

		// Song.addGuides("xxxxxxxxxxx");

~quarters=SongArray.new();
[ "trill","r",[2] ].addLine; 
P(\trill,start:'trill',lag:0.1,music: { |p b e| 
		var trillLength = b.sum + e.bNext.sum;
		var synTrill={ |chan=1 amp=0.3 transpose=0 len=6|
			[
					type:\synful,
					instance:Song.synful1,
					note:Pseq([6,8],inf)+transpose,
					dur:Pwhite(0.1,0.12)*0.8,
					amp:Pwhite(0.1,0.11),
					pan:rrand(-1,1),
					amp:amp,
					chan:chan,
					patch:\clarinet,
					// patch:\flute,
					legato:1,
					out: Effect.bus( { |i| PlateReverb.ar(i,mix:0.5,decayTime:0.55)  * Env.linen(0,trillLength,5).kr(2)})
				].p.findur(len).play;
		//var reverbBus = Bus.audio(s,1);
		//var reverb = Synth(\plate_phaser_insert,[\inBus,reverbBus.index,\gate,1]);
		//Song.synful1.syn.set(\out,reverbBus.index);
	};
	fork{
		Song.synful1.expression(40 + 15,1);
		Song.synful1.expression(30 + 15,0);
		0.1.wait;
		synTrill.value(0,0.9,12,len:trillLength).play;
		synTrill.value(1,1.9,4,len:trillLength).play;
	}
}); 
[ "I am not displeased my husband- ","d#5 c# c a#4 g# f# f d# c# " ].addLine; 
P(\chords, music: { |p b e|
		var freq = [
			[12, 14, 6],
			[12, 15, 7],
			// [12, 15, 11]
		].df('c#',3);
		{
			VarSaw.ar(
				freq: freq.dq.demand(b.parse([4, 2, 3])) .lag3([0, 0.7].dq.demand([0.1,1])),
				width:0.2,
			)
			* 0.016
			* Env.linen(2, b.sum-2.5, 1).kr(2,gate:1)
			=> Out.ar(2,_)
		}.play
});
		//~justTheTune.('husband');
P.still(\twoShot, timecode: 2743.5.seconds, music: { |p b e|
	 e.still.( 
		wait: b.sum,
		text: ["I am not displeased","my husband"],
	)
});
P.tune(\displeased);
P.synthV(role: \thalassa, take:\lead,
			// filter: (midinote: _ - 12), 
			params: {|p b| [
			lyrics: "ai am not dis plizd mai haz band -",
			phonemes: ["","","","","ph l i s t","","","",""],
			pitchTake: 1
		] }, music:{|p b e|
			{
				e.playbuf
				=> p.synthVTracks.at(e.key).()
			}.play
		});
P.double(role: \thalassa, params: {|p b| [
				
			] }, music:{|p b e|
				{
					e.playbuf
					=> p.synthVTracks.at(e.key).()
					/2
				}.play
			});

[ "r your body is r r  not unlike ","c#3 f4 d# c# g#3 f#2 f# f#4 f d#" ].addLine; 
P(\chords, music: { |p b e|
	[
		freq: [
			[1, 3, 5],
			[1, 3, 5],
			[1, 4, 6],
			[1, 4, 6],
			[2, 5, 11],
			[2, 5, 11],
			[4,  6, 12 ],
			[4,  6, 12 ],
			[4, 5.5, 11.5],
			[4, 5.5, 11.5],
			// [4, 5.5, 11.5],
		].df('c#').q,
		dur: e.bAll.parse([1, 4, 1, 4, 2, 2, 2, 2, 2, 2, 2, 1]).q,
		instrument: \default,
		amp: 0.2,
		out: Effect.bus({|i| BPF.ar(i,1900) => Pan2.ar(_, SinOsc.ar(0.1)) },)
		// legato: [0.9, 0.9, 0.9, 0.9, 1, 1, 1, ].q,
	].pp
});
P.still(\clear, timecode: 0.seconds,syl:0, music: { |p b e|
		 e.still.( 
			wait: b.drop(1).sum,
			text: ["your body is","not unlike"],
		)
});
P.synthV(role: \thalassa, take: \lead,
		pbind: Song.enlarge(5),
		filter: (midinote: _ + [0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 9]), 
		params: {|p b| [
		lyrics: "r your body + is r r not unlike + that which was your own ",
		phonemes: ["", "","p A" , "t i", "","","",""," @ n ","l a :\i kh","t a th","w i\ ts`h","","j o r\`","@U n"],
		legato: [1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 2, ],
		pitchTake: 1
	] }, music:{|p b e|
		{
			e.playbuf
			=> p.synthVTracks.at(e.key).()
		}.play

});
P.tune(\unlike, Pset(\amp,Pfunc({|e| ( e.midinote<56 ).if{0}{0.1}}),_));
P('bass',start:\unlike,music: {|p b e|
			[
				freq:[1,\r,\r,-4,-4,\r,5].df('c#',[3,4]).q,
				dur:b.parse([1,1,3, 1,1,3]) ++ e.bNext.sum => _.q,
				out: Effect.bus({|i| 
					Amplitude.kr(i) * 50 
					*  CrossoverDistortion.ar(i,amp:0.1,smooth:0.9) 
					=> DWGReverbC1C3.ar(_,mix:0.1)  
					* Env([1,1,0.06,0.5,0.01],b.parse([7,3])++e.bNext.sum,2).kr
				})
			].pp
		});
[ "that which was your own (dum dum dum)","d-4 c d- b-3  g-3 f g- a-" ].addLine; 
P(\line, music: { |p b e|
	[
		freq: [\r,1, -7, 1, 2, 2.5].df('f#',4).q,
		dur: e.bAll.parse([4, 1, 1, 1, 1, 1]).q,
		instrument: \wash, freqLag: 0.1
	].ppm
});
P.still(\clear, timecode: 0.seconds, music: { |p b e|
		 e.still.( 
			wait: b.sum,
			text: ["that which was","your own"],
		)
});
P('pad',start:\which,music: {|p b e|
			(
				instrument: \reedy,
				release: b.sum,
				dur:1,
				freq: [1].df('a-',[ 3,4 ]),
				amp:0.02
			).play
		});
~justTheTune.('your own');
[ "and i too am pleased beloved", [3,2,4,3,3,2,1,-7].dm('d' ) ].addLine;//  -or Bb!
P.synthV(role: \sargon, take: \lead, params: {|p b| [
		lyrics: "and I too am pleased, beloved + +",
		filter: (midinote: _ - 12), 
		phonemes: ["a n d","a i","","","p r i z d", "b i","r a v","e d"],
		legato: [1, 1, 1, 1, 0.8, 1, 1, 1, ],
		pitchTake: 1
	] }, music:{|p b e|
		{
			e.playbuf
			=> p.synthVTracks.at(e.key).()
			* 1.4
		}.play

});
P.still(\kirkAnswers, timecode: 2748.9.seconds, music: { |p b e|
			 e.still.( 
				wait: b.sum,
				text: ["and I too am pleased","beloved"],
				fade: 0.5
			).sequenceText2(
					b.sum, [ 
					["",""],
					],
			)
});
P('pad',start:\beloved,music: {|p b e|
	(
		instrument: \wash,
		freq: [-7,1,5].df(\d),
		dur: b.sum,
		att: b.parse([3]),
		rel: b.sum - b.parse([3]),
		amp:0.03

	).play
});
P(\strum, music: { |p b e|
	[
		freq: [
			[1, 3, 5, 7],
			[-5, 4, 5, 7],
			// [\r, 3, \r, \r],
			[-5, 1, 5, 7],
			[-5, 2, 2, 5]
		].df(\d, tuning: \sept7).q,
		strum: 0.05, 
		instrument: \harp,
		coef: 0.03,
		dur: b.parse([2, 2, 2, 2]).q,
		out: 2,

		amp: 0.015
	].p.play
});
P(\innerTwo,syl:5, music: { |p b e|
	[
		freq: [ [5, 11], 7, [1, 5, 7] ].df(\d,4).q,
		legato: [[2, 1], 1, 1].q,
		strum: [0, 0, 0.05].q,
		dur: e.bAll.drop(1).q,
		amp: 0.15,
		instrument: \sparkTriangle,depth: 0.002,amp: 0.05,
		out: Effect.bus({|i| HPF.ar(i,250) => Pan2.ar(_,0.2) }, )

	].pp
});
// P.tune('i too',{|i| Pmul(\freq,0.5,i) => Pbindf(_,\amp,0.2,\mix,0.5,\instrument,\stringyy,\legato,1) });
P.tune( { |i| i <>[instrument: \stringyy].pm => Pmul(\freq, 0.5, _)} );
		//P.tune('too am', {|i| Pbindf(i,\amp,0.01,\freq,1.df(\d,[4,5]))});
[ " boom after so- long... (boom) so very long... Kiss ","d3 a b e4 d f g3 b c4 a3 e4 r" ].addLine; 
P.tune( _ <> [group: Song.transitionItems, instrument: \sparkTriangle, depth: 0.004, amp: 0.05, rest: [\r, 1, 1, 1, 1, 1, \r, 1, 1, 1, 1].q].pm );
P.synthV(role: \sargon, take: 
		// \lead
		\lower
		, params: {|p b| [
			filter: (midinote: [1, 4, 5, 11, 7, 12, 1, 5, 6, 4, 7].dm(\c,4)), 
		lyrics: "r after + so - long r so very + long r",
		pitchTake: 1,
		paramTension: -0.1
	] }, music:{|p b e|
		{
			e.playbuf
			=> p.synthVTracks.at(e.key).()
			* 2.dbamp
		}.play(s,target: p.transitionItems)

});
P.synthV(role: \thalassa, take: \lead, params: {|p b| [
		filter: (midinote: _ + 12), 
		lyrics: "r after + so - long r so very + long r",
		phonemes: ["","a f ","th a r\`", "","","l o N", "",  "","w e","r\` i",""],
		pitchTake: 2,
		paramTension: -0.1
	] }, music:{|p b e|
		{
			e.playbuf
			=> p.synthVTracks.at(e.key).()
			* 2.dbamp
		}.play(s, target: p.transitionItems)

});
P.still(\kirklooksDown,syl:0, timecode: 2806.26.seconds, music: { |p b e|
			 e.still.( 
				wait: b.drop(1).sum,
				text: ["after","so long"],
			).sequenceText2(
					b.drop(1).parse([5,1,4]), [ 
						["",""],
					["so very","long"],
					["",""]
					],
			)
});
P.tune();
P(\afterSoLongSketch,start:'very long',music: {|p b e|
			var afterSoLong=[\r,4,5,8,7,9]++[\r,5,6,4,7] + [ 2,2,2,2,2,2,2,2,2,2,3 ].collect{|i| [0,i]};
			(degree:1,octave:4,dur:6, group: Trek.transitionGroup).play;
			[
				legato:1.05,
				instrument:\sawSynthSustain,
				degree:Pseq(afterSoLong)-1,
				dur:b.q,
				out: Effect.bus(PlateReverb.ar(_,mix:0.1),out:3, target:Trek.transitionGroup),
				amp: 0.08,
				group: Trek.transitionGroup
			] => {|i| i.p => Pset(\amp,0.04,_);//=>_.play; 
			i.ppm
		}
			;
			[
				degree:Pseq([1,-3]),
				instrument:\reedy,
				release:3,
				dur:b.parse([6,5]).q,
				out: Effect.bus(PlateReverb.ar(_,mix:0.2),out:1, target: Trek.transitionGroup),
				amp: 0.08,
				group: Trek.transitionGroup
			].pp
		}
	);
P(\bassNotes54,start:'very long',music: { |p b| 
			[
				dur: b.parse([6,5]).q,
				degree: Pseq([1,4],2) ,
				legato:[1.1,0.9].q,
				octave:3,
				amp:0.5,
				group: Trek.transitionGroup,
				out: Effect.bus( {|i| SineShaper.ar(i,0.2) * Env([0,1,1],[0.05]).kr}, target: Trek.transitionGroup)
			].pp
		}
	);
	//TempoClock.tempo=1.5.reciprocal;
//[ "(boom)...so very long... Kiss","g3 b c4 a3 e4 r" ].addLine; 
	//~justTheTune.('so very long');
[ "(kissing) r r r r r r r r ..","g#5 f# d# b4 a# g# e5 d# " ].addLine; 
P.still(\kiss, timecode: 2810.1.seconds, music: { |p b e|
		 e.still.( 
			wait: b.sum,
			text: ["",""],
			fade:3
		)
});
P(\bowedKissing, lag: 0.0,music: { |p b e|
	[ 
		instrument:\trem2,
		rate:Pbrown(2,0,0.3),
		degree:Pseq([6,5,3,1,7-7,6-7,4,3,5-7]-1),
		root:-1,
		octave:[6,4],
		dur:b++[2.5] => _.q,
		legato:1,
		// group: p.transitionItems,
		group: Trek.transitionGroup,
		out: Effect.bus({|i| PlateReverb.ar(i,mix:0.5)  * EnvGen.cutoff(b.sum,10, curve: -2) * 2 * 2.dbamp },inputChannels:2, target: Trek.transitionGroup),
		mtranspose:Pseq([ [0,2,4,7],[0,3,5,7],[0,2,5,7],[0,2,4,7],[0,3,5,7],[0,4,6,7],[0,2,4,7],[0,3,5,7],[0,7] ].collect(_-7)),
	].pp;
});
P(\bassKissing, lag:0.0,start:'kissing',music: {|p b e|
	(
		instrument:\sawSynth,
		rel:15,
		att:1,
		octave:2,
		amp:0.17 * 2.dbamp,
		degree:4,
		root:-1,
		mtranspose:[0,4,7],
		dur:10,
		group:Trek.transitionGroup,
		out: Effect.bus({|i| PlateReverb.ar(i, mix:1) * 2 },target: Trek.transitionGroup),
	).play
});	
[ "final rest","f#4",[5] ].addLine; 

)

