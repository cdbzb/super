(
fork{
	20.do{
		{
			var freq = "3 4 5 4 3 -7 4 2".df([\e, \c, \g, \b ].choose);
			var durs = 0.2.dup(8) + {-0.1.rrand(0.1)}.dup(8) * 9;
			var wahh = Env([400, 1600, [2000, 500.rrand(600) ].choose], durs.parse([4, 4]), [2, 8]).kr(2,gate:1);
			Saw.ar( freq.dq.demand(durs) )
			=> RLPF.ar(_, wahh)
			=>.split CombC.ar(_, 1, wahh/3000 + 0.1 / 10, 8)
			* [3,0.1]
			=> _.sum
			=> Pan2.ar(_, -1.rrand(1))
			/3
		}.play;
		5.0.rand.wait;
	}
}
)
