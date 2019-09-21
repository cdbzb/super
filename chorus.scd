(
	a=NodeProxy.audio(s,2);
)
(
	~out.free;
	~out=Bus.audio(s,2);
	//a.play;
	a.source= Pbind(*[
		instrument:{|freq=300 out=0 gate=1| var sig=SawDPW.ar(freq!2)*0.1; var env=Env.perc(0.4,6).kr(2,gate:gate);Out.ar(out,sig*env)},
		degree: Pseq([1,3,5,1,4,6,5,4],inf),
		dur:0.9,
		legato: 1.5,
		//out:~out;
	]);

	//a[1]=nil;
	a[1]=\filter->{|in out=0| 
		var time=SinOsc.ar([Rand(0.19,0.21),Rand(0.19,0.21)],0.04,0.16).range(0.016,0.020);
		//var time=0.02!2;
		//var sig=  DelayC.ar(in,1,time);
		var sig=  in*0.0+CombC.ar(in*(-1),1,time,0.3);
		var verb=PlateReverb.ar(Mix.ar(sig));
		sig=sig+verb;
		XOut.ar(out, 1.0, sig);
	};
	a[2]=nil;
//a[2]=\filter->{|in out=0| Out.ar(out,in+PlateReverb.ar(in,mix:0.8,room:0.8))};
	//a[2]=\filter->{|in out=0| var sig=PlateReverb.ar(in!1,mix:0.6);ReplaceOut.ar(out,sig)};
)
s.reboot;
a.source;
(
b=NodeProxy.audio;
b.source={ 
		var in=In.ar(~out,2);
		var time=SinOsc.ar([Rand(0.19,0.21),Rand(0.19,0.21)],0.04,0.16).range(0.016,0.020);
		//var sig=  DelayC.ar(in,1,time);
		var sig=  in*0.0+CombC.ar(in*(-1),1,time,0.3);
		//XOut.ar(out, 1.0, sig);
	};
	b.play;

)
a.play;
