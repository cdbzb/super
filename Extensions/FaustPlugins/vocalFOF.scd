(
{
	var voicetype=[0,1].choose;
	var range = [[150,500],[440,850]][voicetype];
	var a = VocalFOF.ar(gain:0.2,freq:LFNoise1.ar(1.13).range(*range)+[0,5,8],vowel:LFNoise1.kr(2.1).range(0,4),voicetype:voicetype,vibratofreq:[7,5,1].choose)
	=> Pan2.ar(_,LFBrownNoise2.kr(1));

Zita.ar(a[0],a[1],mix:0.9,mid_rt60:5,eq2_level:10,eq2_freq:900)

//FreeVerb2.ar(a[0],a[1],mix:1)*0.1
	}=>{|i| 5.do{ i.play(s,1.rand) }}
)
