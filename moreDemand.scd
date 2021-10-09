(
fork{
	4.do{
		{
			var vol = [0.01,0.3,3].dq(inf) => Demand.kr(Impulse.kr(1),1,_);
			var env = Env.perc(0.01,1,1,level:vol).kr(0,gate:TDuty.kr([1,0.3].dq(inf)));
			var freq= [ [400,500,800,600,300].dq(inf),1,0 ].duty;
			SinOsc.ar(freq*[0.5,0.666,0.75,1,1.25,1.5].choose)*env
			=>Pan2.ar(_,[0,1,-1].choose) /10
			=> _.distort => DWGReverbC1C3.ar(_,400,mix:0.05) => _.distort
		}.play;
		1.0.wait
	}
}
)
