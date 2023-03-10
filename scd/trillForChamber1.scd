
(
[[6,7,8,9],{0.1.rrand(12)}!4] => _.flop //rate and lag

=> _.do	({ |i x| { |rate=4 lag=4|
	{
		SinOsc.ar(freq:LFBrownNoise2.kr(3).range(4,rate), phase:0.0, mul:2.0, add:0.0).floor
		=> Select.ar(_, [\lower.ar(7.df,lag ), \upper.ar(11.df, lag)])
		=> Pulse.ar(_, 0.4)
		* 0.05
	}
}.valueArray(i).play(s,x)
=> {|i| fork{2.wait; i.set(\lower,6.df);3.wait; i.set(\lower,5.5.df)}}
} )
)
