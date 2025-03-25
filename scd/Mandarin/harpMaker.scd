(
	~harpMaker = { 
		  arg notes = #[[1, 5],[1, 5],[1, 5]].df(\c, 3),
		  noteDurs = #[2, 2, 2],
		  triggers= {Impulse.kr(4)},
		  noiseType = {PinkNoise.ar(0.1)},
		  filterFunc =HPF.ar(_, SinOsc.ar(0.1).linlin(-1, 1, 60, 200)),
		  decay = 0.5
		  ;
			{
				Pluck.ar(
					 noiseType => filterFunc,
					 triggers, 
					 delaytime:(notes.rank > 1).if {notes.flop} {notes} 
					 => _.collect { |i| i.dq(inf).demand(noteDurs) =>_.reciprocal },
					 decaytime: decay,
					 coef:0.8
				)
				=> _.softclip
				=> Phaser2.ar(_, rate: 0.1).wet(0.5)
				  // => CombN.ar(_, 0.33, 1, 5).wet(0.5)
				* 9
		  }
	  };
	 //  ~harpMaker.(
		//   triggers: 
		// // {[1, 2, 3, 1, 2, 1]/3 => _.dq => Duty.ar(_, 0, 1.dq(inf))}
		//   {[1, 3, 5, 3, 2] / 4 => _.dq(inf) => TDuty.ar(_, 0) 
		//   // => Decay.ar(_, 1) - 0.5 => Slew.ar(_, 100, inf) => _.poll
		//   => HPF.ar(_, 250)
	 //  },
		// 		notes: [
		// 		  [1, 5],
		// 		  [1, 4],
		// 		].df(\d, 3),
		// 		  noteDurs: {[3].dq(inf)}
		//   )
		// .play
	  PluckMaker(
		  triggers: 
		// {[1, 2, 3, 1, 2, 1]/3 => _.dq => Duty.ar(_, 0, 1.dq(inf))}
		  {[1, 3, 5, 3, 2] / 4 => _.dq(inf) => TDuty.ar(_, 0) 
		  // => Decay.ar(_, 1) - 0.5 => Slew.ar(_, 100, inf) => _.poll
		  // => HPF.ar(_, 250)
	  },
	  decay: 0.5,
				notes: [
				  [1, 5],
				  [1, 4],
				].df(\d, 3),
				  noteDurs: {[3].dq(inf)}
		  ).play
)
