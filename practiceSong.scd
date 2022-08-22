(
s.waitForBoot{
	Song(\practice8_19,[]).current.preroll_(1);
	["first",[ 1,5,6,5,4,3,3,2,4,3].dm].addLine;
	Song.setTempoMap( \first,"qe e e e e e q q q q" );
	P.tune(\first, _.fin(8));
P('line',start:\first,lag:-0.1,music: {|p b e|
		MegaBind(
			[
				[4, \_, 4, 3, 2, 1, -5, \_, -7, \_],
				[\r, \r, 4, 3, 2, 1, -5, \_, -4, \_],
				[\r, \r, \_, \_, \_, \_, \_, \_, 4,  3],
			].df()
			,
			b,
			[],
			{|i|  
				8.collect{
					[ SinOsc,Saw, Pulse].choose
					.ar(i.freqSeq.lag2(0.1) * [1,2,4].choose * 0.995.rrand(1.005) 
					+ (SinOsc.ar(5.0.rrand(6),0, Env.triangle(3).kr() * 3))
					, 0.01,0.01)
				}
			* Env.asr(7).kr(0,gate:i.gateSeq)
			=> 
			{|i|
				CombN.ar(i,0.5,SinOsc.ar(0.01, 0.1.rand).range(0.3,0.04),1)
				+ Allpass2.ar(i,1888)
				+i
			}
			=> CombC.ar(_,0.5,LFBrownNoise2.kr(0.1).range(0.04,0.06),1)
			=> Allpass2.ar(_,SinOsc.ar(0.3).range(1000,1200))
			//=> Phaser2.ar(_, rate:0.1 )
		},
			{|i|Splay.ar(i).tanh }
		).play
});
	P('bass',start:\first,music: {|p b e|
		[
			freq:" 4 3 4 2 5 -5 -7 2".df(\c,3).q,
			dur: 1!8 => _.warpTo(e.tempoMap) =>_.q
		].pp
	});

}
)
