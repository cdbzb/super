(
{
{
		var a = Dseq([[1,3],[2,4],[ 3,6,9 ]],inf);
		var d = Demand.kr(Dust.kr(0.6),1,a);
		var b = Dseq(d,inf);
		var c = Demand.kr(Dust.kr(10),1,b);
		Impulse.ar(c*100+400)
		+ Impulse.ar(266)
		* 0.1 
	} ! 2 => Mix.ar(_) => Pan2.ar(_,SinOsc.ar(0.03))
	=> Phaser2.ar(_,  depth: 0.5,  rate: 0.1,  fb: 0.3,  cfb: 0.1,  rot: 1.5707963267949,  rq: 1)
}.play
)

(

	var a = Duty.kr(Dseq( [1,2,4,2]/2,inf ),  Dust.kr(0.5),  Dbrown(400,800,3),  doneAction: 0);
	Pulse.ar(a,LFBrownNoise2.kr(0.1).range(0,1,0.5),0.1)
	* 0.1
	=> DWGReverbC1C3.ar(_)
}.play
)


(
fork{
	4.do{
		{
			var freq = Duty.ar(
				0.1,
				0,
				Dseq( [-1,3,15,4,-23,24,2,3].scramble.df(\d),inf ),

			);
			//freq=SinOsc.kr(1).range(100,1000);
			Duty.ar( Dseq([1,2,3,2,5,3,4,2]/freq,inf),0,Dseq([1,2,3,4]/4,inf)) 
			=> Lag.ar(_,0.001)
			=> LeakDC.ar(_)
			* 0.1
			=> Pan2.ar(_,[-1,0,1].choose)

		}.play;
		0.1.rand.wait
	}
}
//.asSynthDef(name:\grrr).add;
//Synth(\grrr)
)
