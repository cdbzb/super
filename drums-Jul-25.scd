(
var pat = [[ 2,1 ],[ 2,1 ],[ 2,1 ],[2,1,2]] ;
[
	dur:pat.subdivide.q(inf) /4,
	amp:pat.flat + 8 / 10 => _.q(inf),
	instrument:\hihat,
	//lag:pat - 1 /4000 =>_.q(inf)
	lag: [0,1,0,1,0,1,0,0,0]/3/8 => _.q(inf),
	amp:0.04

].pp ;
[
instrument: [\bd_808,\sn_808,\bd_808,\bd_808,\sn_808].q(inf),
dur: [2,2,1,1,2].q(inf)/4,
out: [0,0,0,0,Effect(TwoTube.ar(_, k:0.01, loss:0.98, d1length:[420,SinOsc.kr(0.1).range(380,390)], d2length:600, mul:0.8, add:0.0),inputChannels:2).bus.index].q(inf)
].pp
)
