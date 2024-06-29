(
//fitting algo: if I have pieces of length [a, b, c, .. g] what collections add up to some specific amount?
 ~hats = {
	l = List[];
	while{l.flat.sum<16}{
		l = l ++
		(
			[1, 2, 4].choose
			=> {|i| 
				[2, 3, 4, 5].choose 
				=> {|j| j.reciprocal.dup(j) }
				=> _.dup(i)
			}
		)
		// =>_.flat
		// => l.add(_);
		// l = l.flat;
		// l.postln

	};
	l.flat.sum - 16 => _.bubble ++ l.last[0] //=> l.last[0].dup(_)
	=> {|a| a[0] * a[1].reciprocal.floor => a[1].dup(_)}
	=> {|z| l.drop(-1) ++ z}
	=> _.flat
	*4
	=> { |i| [out: 4.rand, instrument: \hat_808, dur: i.q ].pp};

}
)

(
var
clock = TempoClock.new,
bd = \bd_808,
sn = \sn_808,
pats = (
	bbk: [ instrument: [bd, bd, sn].q, dur: "q q h".beats.q ].p,
	bbkb: [ instrument: [bd, bd, sn, bd].q, dur: "q q q q".beats.q ].p,
	bk: [ instrument: [bd, sn].q, dur: "h h".beats.q ].p,
)
;
[\bk, \bbk, \bk, \bbkb].collect(pats.at(_)) => _.q(8) 
+= [out: 2, amp: 0.01,instrument: \cymbalsDS, dur: "hhhhhhhh".beats.q(4), lag: 0.01].p
+= ~hats.dup(4).q
+= ~hats.dup(4).q
=> _.play(clock:clock);

fork{
	loop{
		clock.tempo = 3 * 0.98.rrand(1.02);
		// clock.tempo = 3;
		0.3.wait
	}
};
[
	instrument: \stringyy,
	freq: [
		[-1, 1, 5, 13, 17 , 21, 24.5, 26].df(\C, tuning: \sept),
		[-1, 1, 5, 13, 17 , 21, 24.5, 26].df(\A, 4, tuning: \sept),
	].q(8),
	tuning: \sept,
	amp: 0.04,
	dur: 12,
	freqLag: 8,
	mix: 0,
	out: Effect.bus({|i| 
		i
		=> FoaPanB.ar(_, LFNoise1.ar(0.1, 0.11, 0.13, 0.17, 0.19).range(-pi,pi))
		=> Mix.ar(_)
		=> AmbiVerbSC.ar(_, mix: 0.2)
		=> Monitors.decode(_)
	},)
	
].pm.play

)
l.sum


l.sum
l
