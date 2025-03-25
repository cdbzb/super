PluckMaker {
	*new { 
		  arg notes = #[[1, 5],[1, 5],[1, 5]].df(\c, 3),
		  noteDurs = #[2, 2, 2],
		  triggers= {Impulse.kr(4)},
		  noiseType = {PinkNoise.ar(0.1)},
		  noiseFilterFunc =HPF.ar(_, SinOsc.ar(0.1).linlin(-1, 1, 60, 200)),
		  decay = 0.5,
		  amp = 0.1
		  ;
		var func = { 
			{
				Pluck.ar(
					 noiseType => noiseFilterFunc,
					 triggers, 
					 delaytime:(notes.rank > 1).if {notes.flop} {notes} 
					 => _.collect { |i| i.dq(inf).demand(noteDurs) =>_.reciprocal },
					 decaytime: decay,
					 coef:0.8
				)
				=> _.softclip
				=> Phaser2.ar(_, rate: 0.1).wet(0.5)
				  // => CombN.ar(_, 0.33, 1, 5).wet(0.5)
				  * 90
				* amp 
		  }
	  };
	  ^func.(notes, noteDurs, triggers, noiseType, noiseFilterFunc)
	}
}
