(
Song(\licklet,[]).current;
["countoff","1 1 1 1".dm(\c)].addLine;
["One", "1 2 1 2 3  6  6 5  3 2 1 2 3  4 4 3".dm(\c)].addLine;
Song.setTempoMap(\One,"e e e e ee ee e eee e e e e ee ee e eee");
P(\lick, music: {|p b e|
	var phrase    = [5,   1,   1,   1,   5,   1,   1,   1];
	var endLength = [0.5, 0.5, 0.5, 0.8, 0.5, 0.8, 0.8, 0.8];
	var amp = [1, 1, 2, 1, 1, 2, 1, 1.5, 1, 1, 1, 1, 1, 2, 1, 1.5];
	[
		freq: "1 2 1 2 3  6  6 5  3 2 1 2 3  4 4 3".df(\c).q,
		dur: "e e e e ee ee e eee e e e e ee ee e eee".beats.warpTo(e.tempoMap.quantizeDft(0.2)) =>_.q,
		dur: b.q,
		legato:  phrase.collect{|i x| i-1 => 1.dup(_) ++ endLength[x]}.flat.postln.q,
		instrument: \sawSynthSustain,
		amp: amp.collect({|i| i / 10 * 0.8.rrand(1.2)}).q,
		out:Effect.bus({|i| CombN.ar(i, 0.3,0.3)/3 ++ i },)
	].ppma()
});
P(\traps, music: { |p b e|
	[
		dur: "e*25".beats.warpTo(e.tempoMap.quantizeDft(0.9)).q,
		rests: MuteFirst(),
		instrument: \hihat,
		lag:0.05
].pp
});
P(\claps,lag:0.1, music: { |p b e|
	[
		// dur: "qq e eq e eq e eq e eq e eq".beats.warpTo(e.tempoMap).q,
		dur: 
[1.77, 0.452, 1.498, 0.526, 1.61, 0.504, 1.4, 0.46, 1.508, 0.487].warpTo(e.tempoMap) + "qq e eq e eq e eq e eq e eq".beats.warpTo(e.tempoMap.quantizeDft.quantize) /2 => _.q,
		instrument: \sn_808,
		rest: MuteFirst()
	].pp
});
P(\boom, music: { |p b e|
	[
		instrument: \bd_808,
		rests: MuteFirst(),
		// lag: -0.2,
		dur: "q*11".beats.warpTo( e.tempoMap.quantizeDft(0.2) ).q,
		amp: 0.5

	].pp
});
)

KeyRecorder(\One) //do CmdPeriod to stop recording
a= Buffer.read(s, "/tmp/test.wav" )
(
// a.play;

{
	WhiteNoise.ar(0.1)
	/3
	* Env.perc(0,0.1).kr(0, gate:TDuty.kr(
		[1.77, 0.452, 1.498, 0.526, 1.61, 0.504, 1.4, 0.46, 1.508, 0.487].warpTo(Song.tempoMap[\One]).dq,
		// [1.128, 0.883, 0.93, 1.134, 0.994, 1.09, 0.882, 1.015, 0.488, 0.447, 0.986, 1.175].warpTo(Song.tempoMap[
		// 	\One
		// ]).dq,
		0,
		gapFirst: 1
	))
	=> DelayN.ar(_,0.2,0.2)
	+ ( 
		PlayBuf.ar(2, a.bufnum
		)
			// => DelayN.ar(_, 0.4,0.4)
)}.play
)
{PlayBuf.ar(1, a.bufnum)}.play
a
s.meter
(
fork{
	loop{
		Song.playRange(1,2);
		Song.secDur[\One].wait
	}
}
)
