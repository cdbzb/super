
// Sickbay
(
s.waitForBoot{
	Song(\chapelForgets,[]).current;
	["(Chapel is holding the hypos and trying to remember something very important.)","c",[6]].addLine;
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
	["CHAPEL: You'll find them excellent, Doctor. Well within normal.","3 4 5 7 5 4 4 3".dm(\a,\mixolydian)].addLine;
	P.tune(\excellent);
	["MCCOY: Is something wrong, Miss Chapel?","-7 1 2 3 1 -7 -5".dm(\g,\mixolydian)].addLine;
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
	P.tune(\Regarding);
	["CHAPEL: Yes. That must be it. ","7 11 5 3 1".dm(\f)].addLine;
	P(\bassnote, music: { |p b e|
		[
			freq: [\r,1].df(\f,[4,3]).q,
			dur:b.parse([1,4]).q,
			out: Effect.bus(DWGReverbC1C3.ar(_))
		].pp
	});
	P.tune(\Yes);
	["I am so plea -sed the way they are responding, Doctor.","5 4 3 5 6 5 4 3 2  5 4 3 1 -5".dm('b-') ].addLine;

	P(\bass, music: { |p b e|
		[
			freq:[1,2,3,4,-5,-6].df('b-',[4,3]).q,
			dur:b.parse([1,1,1,3,4,5,4]).q,
			out: Effect.bus(DWGReverbC1C3.ar(_))
		].pp
	});
	P.tune(\am);
	["The formula's working perfectly.","r"].addLine;
	["MCCOY: You look tired, Miss Chapel.","r"].addLine;
	[" Perhaps you'd care for me to administer (boom) the last few injections.",[ 2,4,2.5,2,1,-7,-6,2,-7,-6,-5 ].dm(\c) ++ [ -4, 5,6,7,11,12,13,11].dm('e-',4) ].addLine;
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
	["CHAPEL: Tired? Well, not at all, Doctor. Thank you for asking.","r"].addLine;
	["(Leaves a puzzled McCoy.)","r"].addLine;
}
)
