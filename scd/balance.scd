(
{Balance.ar(
	Saw.ar([200,230,280,599]+SinOsc.kr(1/9),0.08)
	+ (Gendy1.ar(ampdist:0.1,minfreq:40,maxfreq:480)*0.1)
	+ (Item(\balanceTest).playbuf([2,3,4],loop:1)=>HPF.ar(_,1499))
	,
	Item(\balanceTest).playbuf(rate:1,loop:1) 
	,
	hp:30,
	stor:1000
)
=> EchoNone.ar(_,2,(0.1,0.11..0.13),2)
}.play;

fork{
	inf.do {
		15.wait;
		6.rand.do{
			Item(\balanceTest).play(s,4.rand,amp:5);
			2.0.rand.wait
		}
	}
}

)
