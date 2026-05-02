(
Song(\choir, []).current;
["one", "r",1!4].addLine;
		P.synthVVST( \choirZh2,start:\one,take:0,tail:5, params:{|p b k| [
			midinote: 
			[[1, -6],[3, 2],[6, 3],[7, 14]].dm( \d)
			, 
			lyrics: "aaah -",
			dur: [3,3],
			singers:6,
			spacing: 0.1,
			// pitchDelta: Env([0, 100 * [5,-3]],5)
		] },
		music: {|p b e|
			{
				e.bus => Splay.ar(_)
				// => Pan2.ar(_, x/4 * 2 - 1)
				// => FreeVerb.ar(_,0.2,1)
			}.play
		});
P(\yoe, music: { |p b e|
	(type:\default, instrument:\stringyy,amp:1,dur:5, freq:[-4, 3, 5, 7, 11, 13, 15, 16].df(\G,4)).play
});


)
