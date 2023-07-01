// Sickbay
(
s.waitForBoot{
	Song(\chapelForgets,[]).current;
	Require("./boilerplate.scd");
	["(Chapel is holding the hypos and trying to remember something very important.)","c",[6]].addLine;
P.still(\chapelClose, timecode: 3440.15.seconds, music: { |p b e|
		 e.still.( 
			wait: b.sum,
			text: ["",""],
		)
});
P(\pad, music: { |p b e|
		{
			Gendy2.arWidth(freq:[1,-1].df(\c)* Pulse.kr(4).range(1,1.midiratio),width:1.midiratio)
			* 0.02
			=> {|i|i + AllpassC.ar(i,0.1,[1].dm(\b,[3,5]).midicps.reciprocal,decaytime:SinOsc.ar(0.1).range(0.5,2),mul:0.45)}
			=> {|i|i + AllpassC.ar(i,0.1,[1].dm(\c,[3,5]).midicps.reciprocal,decaytime:SinOsc.ar([0.09,0.11,0.12,0.13]).range(0.5,2),mul:0.75)}
			* 
			Env([0.1,1,0],[2,9],curve:[0,-2])//.plot
			.kr(2,gate:1)
			=> HPF.ar(_,250)
		}.play
});
	["MCCOY: Nurse, how are the last metabolic readings on our patients?","4 5 4 3 4 5.5 5 4 3 3 2 3 4.5 4.5 5.5".dm(\c)].addLine;

P.tune(\Nurse);
	Song.synthVTracks = EventWithDefault(
		\default, { |mix=0.09|
			{|i|
				i => DWGReverbC1C3.ar(_,mix:mix)
				* -10.dbamp
			}
		}
	);
P.still(\twoShot1, timecode: 3443.15.seconds, music: { |p b e|
		 e.still.( 
			wait: b.sum,
			text: ["Nurse",""],
		).sequenceText2(
				b.parse([1,10]), [ 
				["how are the last","metabolic readings"],
				["on our","patients?"]
				],
		)
});
P.synthV(role: \mccoy, take: \lead, params: {|p b| [
		lyrics: "Nurse how are the last metabolic + + + readings + on our patients +",
		pitchTake: 1,
		filter: (midinote: _ - 12), 
		legato:[ 0.5, 1, 1, 1, 0.7, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1 ]
	] }, music:{|p b e|
		{
			e.playbuf
			=> p.synthVTracks.at(e.key).(mix:0.02)
		}.play
});
	["CHAPEL: You'll find them excellent, Doctor. Well within normal.","3 4 5 7 5 4 4 3".dm(\a,\mixolydian)].addLine;
P.still(\handing, timecode: 3446.1.seconds, music: { |p b e|
		 e.still.( 
			wait: b.sum,
			text: ["you'll find them","excellent, Doctor"],
		)
});
P.synthV(role: \chapel, take: \lead, params: {|p b| [
		lyrics: "you'll find them excellent + + Doctor + well within + normal +",
		legato: [1, 1, 1, 1, 1, 1, 1, 0.5, 1, 1, 1, 1, 1],
		pitchTake: 1
	] }, music:{|p b e|
		{
			e.playbuf
			=> p.synthVTracks.at(e.key).()
		}.play
});
P.tune(_ <> [out: Effect.bus({ |i|  i=> FreeVerb.ar(_,0.3,1) => SineShaper.ar(_,0.015,2) })].p);
	["MCCOY: Is something wrong, Miss Chapel?","-7 1 2 3 1 -7 -5".dm(\g,\mixolydian)].addLine;
P.still(\asking, timecode: 3452.1.seconds, music: { |p b e|
		 e.still.( 
			wait: b.sum,
			text: ["is something wrong","miss Chapel"],
		)
});
P.synthV(role: \mccoy, take: \lead, params: {|p b| [
		lyrics: "is something + wrong miss chapel +",
		filter: (midinote: _ - 12), 
		pitchTake: 1
	] }, music:{|p b e|
		{
			e.playbuf
			=> p.synthVTracks.at(e.key).()
		}.play
});
P.synthV(\kevin,\Miss, params: {|p b| [
		lyrics: "is something + wrong miss chapel +",
		
	] },filter:(midinote:_-12), music:{|p b e|
		{
			e.playbuf
			=> p.synthVTracks.at(e.key).()
		}.play
});
P.tune(\Is);
P(\bassnote, music: { |p b e|
		[
			freq: [\r, [-1,1] ].df(\g).q,
			dur: b.parse([3,4]).q,
			out:Effect.bus(DWGReverbC1C3.ar(_))
		].pp
});
	["CHAPEL: Er, yes. I, er, I had something to say. I can't seem to remember.","3 4 3 2 3 4 5 4 3 7 11 6 7 5 6 4 3".dm('a-',\mixolydian)].addLine;
P.still(\closer, timecode: 3454.seconds, music: { |p b e|
		 e.still.( 
			wait: b.sum + e.bNext.sum,
			fade:8,
			text: ["...yes ...I ...","I had something to say"],
		).sequenceText2(
				b.parse([10]), [ 
				["I can't seem","to remember"],
				],
		)
});
P.synthV(role: \chapel, take: \lead, params: {|p b| [
		lyrics: "uh yes I uh I had something + to say I can't seem to remember + +",
		legato: [0.8, 1, 1, 0.8] / 2 ++ [1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1],
		pitchTake: 1
	] }, music:{|p b e|
		{
			e.playbuf
			=> p.synthVTracks.at(e.key).()
		}.play
});
P(\bassnote, music: { |p b e|
		[
			freq: [1,\r, 6.5, 13].df(\c,[4,3]).q,
			dur:b.parse([5,4,6,2]).q,
			out: Effect.bus(DWGReverbC1C3.ar(_))
		].pp
});
P(\fadeNote, music: { |p b e|
		[
			freq:  [1,-1].df('a-',[4]),
			dur: b.sum.q,
			instrument:\sawSynthSustain,
			att:0,
			amp: 0.06,
			out: Effect.bus(_ *  Env([0,0,1,1,0.5], b.parse([2,7,1,7])).kr(2,gate:1) *3)
		].pp
});
P.tune(\Er,Pmul(\freq,[0.5,1],_));
P(\chords, music: { |p b e|
		[
			freq:[1,-5].df('a-'),
			dur:b.parse([1,1,1,1]).q

		].p.play
});
	["MCCOY: Regarding our patients?","4 5 4 3 7 6".dm(\c,\mixolydian)].addLine;
P.still(\answer, timecode: 3502.85.seconds, music: { |p b e|
	 e.still.( 
		wait: b.sum,
		text: ["",""],
	)
});
	// P.tune(\Regarding);
P.synthV(role: \mccoy, take: \lead, params: {|p b| [
		lyrics: "regarding + + our patients +",
		legato: [1,1,0.6, 0.5, 1, 0.5],
		filter: (midinote: _ - 12), 
		pitchTake: 1
	] }, music:{|p b e|
		{
			e.playbuf
			=> p.synthVTracks.at(e.key).()
		}.play
});
	["CHAPEL: Yes. That must be it. ","7 11 5 3 1".dm(\f)].addLine;
P.still(\chapelYes, timecode: 3513.15.seconds, music: { |p b e|
	 e.still.( 
		wait: b.sum,
		text: ["yes","that must be it"],
	)
});
P.synthV(role: \chapel, take: \lead, params: {|p b| [
	lyrics: "yes, that must be it",
		legato: [0.5, 1, 1, 1, 0.5],
		pitchTake: 1
	] }, music:{|p b e|
		{
			e.playbuf
			=> p.synthVTracks.at(e.key).()
		}.play
});
P(\bassnote, music: { |p b e|
		[
			freq: [\r,1].df(\f,[4,3]).q,
			dur:b.parse([1,4]).q,
			out: Effect.bus(DWGReverbC1C3.ar(_))
		].pp
});
P.tune(\Yes);
	["I am so plea -sed the way they are responding, Doctor.","5 4 3 5 6 5 4 3 2  5 4 3 1 -5".dm('b-') ].addLine;
P.synthV(role: \chapel, take: \lead, params: {|p b| [
		lyrics: "I am so pleased - the way they are responding + + Doctor +",
		pitchTake: 1
	] }, music:{|p b e|
		{
			e.playbuf
			=> p.synthVTracks.at(e.key).()
		}.play
});
P(\bass, music: { |p b e|
		[
			freq:[1,2,3,4,-5,-6].df('b-',[4,3]).q,
			dur:b.parse([1,1,1,3,4,5,4]).q,
			out: Effect.bus(DWGReverbC1C3.ar(_))
		].pp
});
P.tune(\am);
	["-boom boom- The formula's working perfectly.","3 2".dm(\b,4,\minor) ++ "1 5 4 3 ".dm(\e) ++ "7 11 13 14 13 5".dm(\d)].addLine;
P.tune();
P.synthV(role: \chapel, take: \lead, params: {|p b| [
		lyrics: "r r The formula's + + working + perfectly. - + +",
		legato: [1, 1, 1, 1, 1, 0.65, 1, 1, 1, 1, 1, ],
		pitchTake: 1
	] }, music:{|p b e|
		{
			e.playbuf
			=> p.synthVTracks.at(e.key).()
		}.play

});
P(\bass, music: { |p b e|
		[
			freq: [11, 7, 6, 2, 4, 1].df(\d,[2,3]).q,
			instrument: \sawSynthSustain,
			dur: b.parse([1, 1, 1, [1, 1, 0.5],[0.5, 1, 1, 1],[1, 1, 1]]).q
		].ppm
});
	["MCCOY: You look tired, Miss Chapel.","6 4 5 3 2 1".dm('c#')].addLine;
P.still(\mccoyTired, timecode: 3518.8.seconds, music: { |p b e|
	 e.still.( 
		wait: b.sum,
		text: ["you look tired","miss chapel"],
	)
});
P.synthV(role: \mccoy, take: \lead, params: {|p b| [
		lyrics: "You look tired, Miss Chapel +",
		legato: [1, 1, 1, 1, 1, 0.8, ],
		filter: (midinote: _ - 12), 
		pitchTake: 1
	] }, music:{|p b e|
		{
			e.playbuf
			=> p.synthVTracks.at(e.key).(mix:0)
			// /2
		}.play

});
P.tune();
P(\chords, music: { |p b e|
		[
			freq: [[3,5],[2,4],[1,3]].df('f#',3,\whole).q,
			dur: b.parse([2, 2, 2]).q,
			instrument: \stringyy,
			amp: 0.25
		].pp
});
	[" Perhaps you'd care for me to administer (boom) the last few injections.",[ 2,4,2.5,2,1,-7,-6,2,-7,-6,-5 ].dm(\c) ++ [ -4, 5,6,7,11,12,13,11].dm('e-',4) ].addLine;
P.still(\clear, timecode: 0.seconds, music: { |p b e|
	 e.still.( 
		wait: b.sum,
		text: ["perhaps you'd care for me","to administer"],
	).sequenceText2(
			b.parse([11]), [ 
			["the last few","injections"],
			],
	)
});
	// P.tune();
P.synthV(role: \mccoy, take: \lead, params: {|p b| [
		lyrics: "Perhaps + you'd care for me to administer + + + r the last few injections + - +",
		filter: (midinote: _ - 12), 
		paramTension: 0.1,
		pitchTake: 1
	] }, music:{|p b e|
		{
			e.playbuf
			=> p.synthVTracks.at(e.key).(mix: 0)
			// /2
		}.play

});
P(\bassline, music: { |p b e|
		[
			freq: [\r,1,-7, 1, 1.5, 1, -6].df(\g,[3,4],\minor).q,
			dur: b.parse([5, 3, [1,0.5],[0.5,1], 2, 3, 4]).q,
			out: Effect.bus({ |i| i*5 
				=>FreeVerb.ar(_,0.4,1)
				=> SineShaper.ar(_,0.2)
				/ 2
			}, inputChannels:2)
		].pp
});
P.tune(\Perhaps);
	["CHAPEL: Tired? Well, not at all, Doctor. Thank you for asking.","5 1 2 3 4 2 1".dm('b-',\whole) ++ "5 6 7 12 11".dm(\c)].addLine;
P.still(\chapelTired, timecode: 3523.75.seconds, music: { |p b e|
	 e.still.( 
		wait: b.parse([7]).unbubble,
		text: ["tired?","well not at all, Doctor"],
		// fade: 2
	)	
});
P.still(\clear, timecode: 0.seconds, music: { |p b e|
	 e.still.( 
		wait: b.sum,
		text: ["thank you","for asking"],
	)
});
P.tune();
P(\chords, music: { |p b e|
		[
			freq: [[1,3,5].df('b-',\whole), [5,7,11,13].df('b-',4,\mixolydian), [1,-1,-11,-7].df(\g,\mixolydian),[3,5,11].df(\c)].q,
			dur: b.parse([4,3,3,2]).q
		].pp
});
P.synthV(role: \chapel, take: \lead, params: {|p b| [
		lyrics: "Tired? Well, not at all, Doctor + Thank you for asking +",
		legato: [0.6, 0.9, 1, 1, 1, 1, 0.9, 1, 1, 1, 1, 1, ],
		pitchTake: 1
	] }, music:{|p b e|
		{
			e.playbuf
			=> p.synthVTracks.at(e.key).()
		}.play

});
P(\pad,syl:6, music: { |p b e|
		{
			Gendy2.arWidth(freq:[1,-1].df(\c)* Pulse.kr(4).range(1,1.midiratio),width:1.midiratio)
			* 0.02
			=> {|i|i + AllpassC.ar(i,0.1,[1].dm(\b,[3,5]).midicps.reciprocal,decaytime:SinOsc.ar(0.1).range(0.5,2),mul:0.45)}
			=> {|i|i + AllpassC.ar(i,0.1,[1].dm(\c,[3,5]).midicps.reciprocal,decaytime:SinOsc.ar([0.09,0.11,0.12,0.13]).range(0.5,2),mul:0.75)}
			* 
			Env([0.1,1,0],[2,9],curve:[0,-2])//.plot
			.kr(2,gate:1)
			=> HPF.ar(_,250)
		}.play
});
	["(Leaves a puzzled McCoy.)","r"].addLine;
	P.still(\puledMccoy, timecode: 3533.2.seconds, music: { |p b e|
		 e.still.( 
			 fadeIn:2,
			wait: b.sum,
			text: ["",""],
			fade: 3
		)
	});
}
)
