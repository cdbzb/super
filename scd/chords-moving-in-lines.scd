(

a = {|key quality = \major|
	var b = Bus.audio(s, 2);
	[
		freq: [1, 3, 5].df(key, quality),
		pan: Pseg( [-1, 1, 1], [ 5, 8 ] ),
		amp: Pseg( [0.1, 0.1, 0], [5, 8] ),
		out: b
	].pp;
	{ var sig = In.ar(b, 2) => FreeVerb.ar(_, 0.5, 1);  DetectSilence.ar(sig, doneAction:2); Out.ar([0, 1], sig[0]); Out.ar(4, sig[1]); }.play(addAction: \addAfter).onFree({b.free})
};

[
	freq: [6, 5, 4, 3, 2, 1, 3, 2, 1, -7 ].df(\c, 6).q(inf),
	dur: "e ee x xeeee".beats => _.q(inf),
	instrument: \sawSynthSustain,
	att: 5,
	out: 2,
		pan: Pseg( [-1, 1, 1], [ 5, 8 ], repeats:inf ),
		amp: 0.02
].ppm;

fork{
	loop{
		a.(\c);
		4.wait ;
		a.(\g, \minor);
		4.wait;
		a.(\C);
		4.wait ;
		a.(\g );
		4.wait
	}
}

)

