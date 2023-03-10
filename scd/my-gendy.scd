(
{
	EnvGen.ar(
		Env.new([0,LFNoise1.kr(200),LFNoise2.kr(200),1,0,1]-0.5*2,0.001* {LFNoise0.kr(10)}!4 => {|i| i/i.sum} * 0.0001,loopNode:0,releaseNode:4,curve:\sin),gate:1
	) * 0.1
}.play
)
s.reboot
[2,4,8]=>{|i|   i/i.sum	} => _.sum
