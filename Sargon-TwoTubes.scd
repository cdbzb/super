(
a={ |i_out=12 fund = 320 |
	ReplaceOut.ar(i_out ,TwoTube.ar(SoundIn.ar(0), 0.9 ,0.8 , fund,16*fund+5))}.play
)
a.free;

s.meter;