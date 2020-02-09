.cauchy
Prand
Pcauchy
Pgauss
(
	{|freqscale=1|
		Impulse.ar(0,0,\amp.kr(0.1))
		//=>Slew.ar(_)
		=>Klank.ar(`[[222,Rand(4200,4400),Rand(4000,4500),1290,Rand(7000,9000)],[0.1,1,1,1,1],[0.4,1,1,1,0.4]*0.5],_,freqscale:freqscale)
		=>FreeVerb.ar(_,0.4,0.7)
		=> Out.ar(\out.kr(2),_);
		Env.perc(1).kr(2,gate:1)
	} => SynthDef(\clap,_) => _.add;

	a=Pgauss(2,0.01,inf).asStream;

	38.do{|x|
		a.nextN(10).do({|i|SystemClock.sched(i+(x/4),{(instrument:\clap,out:2,freq:rrand(300,330),dur:0.1).play})});
		a.nextN(10).do({|i|SystemClock.sched(i+(x/2),{(freqscale:2.8,instrument:\clap,out:3,freq:rrand(300,330),dur:0.1).play})});
};

//[out:2,dur:p,lag:0.1,instrument:\clap].pp;

[out:[2,3],amp:0.5,degree:0,dur:[Rest(2)].q++[1,1/2,1/2].q(6),octave:2].pp;
[instrument:\kick1, dur:"x......x.xx..x.x".asDrumPat(8,8),out:3 ].pp;
[instrument:\hihat,dur:Pwrand([1/2,1/4],[3,1]/4,50),amp:Pgauss(0.1,0.01),out:[2,3],lag:Pgauss(0,0.005)].pp;
[instrument:\snare,out:2,lag:0.5].pp
)
