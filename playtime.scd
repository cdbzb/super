( //first
    x = Signal.fill(512, { rrand(0.0, 1.0) });
    y = Signal.fill(512, { |i| (i * pi / 64).sin });
    [x, y, (x + y) * 0.5, x * y, min(x, y), max(x, y) ].flop.flat .plot(numChannels: 6);
    b=Buffer.loadCollection(s,min(x,y))
)
	
(//then
		a={|gate=1|
			PlayBuf.ar(1,b,SinOsc.ar(
			BrownNoise.ar(0.4!4)*3)
			*[1,1.1,1.2,1.33]*rrand(0.55,1.1),loop:1)
			=>MoogFF.ar(_,BrownNoise.kr(\bspeed.kr(0.1)!4)*4200+860,3)
			//=>CombC.ar(_,1,0.1.dup.rand+0.06  )
		=>AllpassC.ar(_,1,0.1.dup(4).rand+0.05+SinOsc.kr(0.5).range(0,0.5))
		//=>CombN.ar(_,1,decaytime:3)
			* Env.cutoff(3).kr(0,gate:gate)
		}.play
		.dur(12);

		~b ?? {~b=Bus.control};
		
		{{|gate=1|Line.kr(9,0.1,5,doneAction:2)=>Out.kr(~b.index,_); Env.cutoff(1).kr(2,gate:gate)}.play}.sched(3);
		
		{a.map(\bspeed,~b)}.sched(3);


a.take(16)
