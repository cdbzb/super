( 
	//SETUP

~duration = {|from to| to.asFloat.asSeconds - from.asFloat.asSeconds};

~dotted = 	{ | dur, pan=0, amp=0.7|
	{ 
		Dust.ar(50) 
		=>Decay.ar(_,0.0001)
		=>TwoTube.ar(_,loss:0.8,d1length:rrand(20,30))
		=>MoogFF.ar(_,LFBrownNoise1.kr(2).range(4700,6000))
		=>Pan2.ar(_,pan,amp)
	}.play(s,0) .dur(dur)
};
~drawLine = {| start end pan=0 amp=0.7 | Reaper.sched(start, {~dotted.value(~duration.(start, end),pan,amp )})};
~record = { | name, length |
	g = Group.after(1);
	b = Buffer.alloc(s, 65536, 2);
	b.write("~/tank/Maura-PCS/SC".standardizePath +/+ name.asString, "wav", "int24", 0, 0, true);
	// create the diskout node; making sure it comes after the source
	d = Synth.tail(g, "diskout2", [\bufnum, b]);
	fork{ 
		length.wait ;
		d.free; 
	b.close;
	b.free;
	};
};

~circle = { | length, panL, panR | 
	{
		var index = Line.kr(0, 2*pi,length,doneAction:2);
		[index.sin,index.cos]
	}
};

~drawCircle = { |when, length, panL=(-1), panR=1, amp=1|
	Reaper.sched(when,
		{
			{
				var index = Line.kr(0,2*pi,length,doneAction:2);
				Dust.ar(150)=>Decay.ar(_,0.02)=>OnePole.ar(_)
				* WhiteNoise.ar(1)=> 
				MoogFF.ar(_,[index.cos,index.sin]*300+500)
		=> {|i| i[0]=>Pan2.ar(_,panL)+i[1]=>Pan2.ar(_,panR)}
		* amp
			}.play
		}
	)
	
};

		~blueJayWay = { |time=0, fadeIn=0,sustain=1, release=8, amp=0.1|
			Reaper.sched( time,
				{
					{
						SinOsc.ar([1,3,4,6].df(\a)+(LFBrownNoise2.kr(1)!4)/2,0,0.003)
						+ PinkNoise.ar(0.02)
						=> MoogFF.ar(_,LFBrownNoise2.kr(0.5).range(600,2000))
						* Env.linen(fadeIn,sustain,release).kr(2,gate:1)
						* amp * 10
					}.play
				}
			)
		}
)
( //hands moving up and down
Reaper.play(123);
~upDown = {
	{
		var line = Line.kr(0,1 ,5);
		var root = 500;
		var up = 1.df(\a) * line.midiratio;
		var down = 1.df(\f) * ((-1 * line).midiratio);
		[up, down].collect{|i|Gendy1.arWidth(freq:i)}
		* EnvGen.cutoff(20,2)
		/20
	}.play
};
Reaper.sched(124,~upDown);
Reaper.sched(143f:10, { (instrument: \harp,freq: [300,400,560]).play })
)
( //number titles
	~numberOne = {
		(
			freq: [1, 5].df(\c,[6,5]),
			amp: 0.5,
			dur: 10,
			instrument: \defaultPiano,
			out: Effect.bus({|i| DWGReverbC1C3.ar(i) /2 },)
		).play
	};
	Reaper.play(412);
	Reaper.sched(412f:4,~numberOne)

)
( //number2
Reaper.play(705);
Reaper.sched(705f:22,~numberOne);
Reaper.sched(706, ~moneymoney)
)
( // one two three
	Reaper.play(920);
	[920f:19, 923f:22,925f:22].collect{
		|i x|
		Reaper.sched(i,
			{ 
				(freq:x + 1 df: \f, amp:0.3).play
			}
		)
	}
)
