( //setup
	Reaper.open;
	//SETUP
"./moneymoney2.scd".standardizePath.load	;
~recPath = "~/tank/Maura Offshore/RPP/SC/".standardizePath;
~rec2 = {|name|
	( ~recPath +/+ name ).version.record(0,2,Reaper.lastPlayLength)
};
~playSections = {|...args| 
	var sections = args;
	fork{
		sections.do{|sec|
			Song.playSection(sec);
			Song.secDur[sec].wait;
		}
	}
};
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
};
~numberTitles = {|root = \c| { 
	(
		freq: [1, 5].df(root,[6,5]),
		amp: 0.1,
		dur: 10,
		instrument: \defaultPiano,
		out: Effect.bus({|i| DWGReverbC1C3.ar(i) /2 },)
	).play
} };
)
(//opening cue
	//go ahead and break this out!!!
	/*
	"/Users/michael/tank/super/MauraCayman/tropical1.scd".load; //calypsoTheme loop with tremolo
	*/
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
( //67.8 Billion
var title = 203f:12;
Reaper.play(202,206);
Reaper.sched(title - 0.2,{
	(freq:[3,6,12].df(\c,6),instrument: \defaultPiano, dur:3).play
})
)
(// 3:22 grand cayman animation
				\PATH ++ path => _.postln;
	Reaper.play( 322, 332 );
	~recPath +/+ "GrandCaymanAnimation.wav"
	=> _.version
	=> _.record(0,2,Reaper.lastPlayLength)
	;
	{
		var start = 323f:12;
		var end = 328f:20;
		~drawLine.(start, end, pan: 0.3)
	} => Reaper.sched(323f:12, _);
	Reaper.sched( 326 f: 06, { 
			{
				Saw.ar( [3, 5].df(\a), 0.1 )
				* Env.perc(0.005,2).kr(0,gate:1)
				* SinOsc.ar(3)
				// => Pan2.ar( _, [0.1,0.8] )
				=> Splay.ar(_, center:0.9)
			}.play;
} )
)
( //classical tax havens
Reaper.play(352, 356);
// ~rec2.("classical-tax-haven.wav");
Reaper.sched(353 f: 02 - s.latency , {
	\NOW.postln;
	(
		instrument: \wash,
		freq: [-6, 1, 3, 5].df(\c)
	).play
})
)
(//fourth largest
	Reaper.play(357,412);
	~rec2.("fourth-largest.wav");
	Reaper.sched(400 f: 05 - s.latency, {
		(
			freq: [1, 5.1].df(\g),
			out: Effect.bus({|i| DWGReverbC1C3.ar(i,mix:1) },)
		).play
	})
)
( //number titles
	Reaper.play(412);
	// ~rec2.("2-Layering.wav");
	Reaper.sched(412f:4,~numberTitles.())

)
( //number2
Reaper.play(705, 710);
Reaper.sched(705f:21 - s.latency,~numberTitles.('b-'));
~rec2.("2-Layering.wav");
)
( // 705 moneymoney

Reaper.play(705, 746);
~rec2.("moneymoney1.wav");
Reaper.sched(706f:5, ~moneymoney)
)
( //830 Caymans 1
/*
 "~/tank/super/MauraCayman/tropical830.scd".standardizePath.load;
 */
Reaper.play(830, 1000);
~rec2.("tropical830.wav");
Reaper.sched(
	// 832f:11
	833f:16 - s.latency
	,{
	// ~playSections.(0,1,0,1, 2, 3, 4, 2, 3, 4, 5);
	~playSections.(0,1, 2, 3, 4,5, 2, 3, 4, 5, 6, 7);
})
)
( //number3

Reaper.play(2450, 2455);
~rec2.("3-Integration.wav");
Reaper.sched(2450f:17,~numberTitles.(\e));
)
( //number3

Reaper.play(2450, 2455);
~rec2.("3-Integration.wav");
Reaper.sched(2450f:17,~numberTitles.(\e));
)
( // one two three
	Reaper.play(920);
	[920f:19, 923f:22,925f:22].collect{
	https://scsynth.org/t/dev-meetings-schedule/250/111	|i x|
		Reaper.sched(i,
			{ 
				(freq:x + 1 df: \f, amp:0.3).play
			}
		)
	}
)
( // musical cue effort
/*
 "~/tank/super/MauraCayman/tropical1.scd".standardizePath.load;
 */
var durs = [Song.secDur[\VerseLoop],Song.secDur['VersTwoLoop'],"qqqqqqqq".asBeats.warpTo(Song.tempoMap[\VersLoopConnecter]).unbubble];
var moneyStack = 1852f:06;
var cameraBlurry = 1922f:23;
	Song.guitarFXSynthFunc = {
		In.ar(Song.guitarFx,1) / 4 
		=> HPF.ar(_,150)
=> Out.ar(1,_)
	};
	~calypsoLoop = {|tempo = 1|
		{ 
			TempoClock.tempo_(tempo);
			fork{
				// r.record;0.1.wait;
				6.do{
					[\VerseLoop,\VersTwoLoop,\VersLoopConnecter].do { |x i|
						x.postln;
						Song.playSection(x);
						// Song.secDur[x].wait
						durs[i].wait

					};
				};
				3.wait;
				r.stopRecording;
				TempoClock.tempo_(1)
			}
	} };
	// Reaper.play(1836, 1837);
	// "~/tank/Maura\ Offshore/RPP/SC/calypsoMoneyBed.wav".version.record(1, 2, Reaper.lastPlayLength);
	// "~/tank/Maura\ Offshore/RPP/SC/calypsoMoneyBed.wav".record(1, 2, Reaper.lastPlayLength);
	Reaper.sched(1836f:20,~calypsoLoop.(tempo:0.7));
	// Reaper.play(1840);
	Reaper.sched(1851f:20,~calypsoLoop.(tempo:0.7));
	Reaper.sched( moneyStack,
		{
			(instrument: \cymbalsDS).play
		}
	);
	Reaper.play(1920);
	Reaper.sched(1920f:20,~calypsoLoop.(tempo:0.7));
	Reaper.sched( cameraBlurry,
		// ~calypsoLoop.(tempo:1).play;
		// TempoClock.isRunning;
		// TempoClock.clear;
		// TempoClock.play;
		// AppClock.clear;
		// SystemClock.clear;
		// TempoClock.clear();
		// TempoClock.tempo_(1);
		{
			(dur:8, instrument:\wash, freq: [3,5,7,12].df(\f)).play
		}
	)
)
( Song(\hongKong,[]).current;
	["intro",[-7, 1, 1, 3, 4, 4, 6, 7, 7, 2, 2.5, 2.5].dm('c',\mixolydian)].addLine;
	P.tune( { |i| i => Pmul(\freq,0.25,_)  <> [instrument: \sawSynth].pma ;} )
)
(//freeport title
var title = 1532f:18;
Reaper.play(1531,1548);
Reaper.sched(title - s.latency, {
	(freq: [1, 3, 5.5].df(\c,[5,6]),strum: 0.00, instrument: \reedy,amp:0.002, dur:
1630.seconds - title.seconds ).play;
[
	degree: Pwhite(1,24,inf),
	octave: 6,
	dur: Pwhite(0.01,0.1,inf),
	amp: 0.02,
	coef: 0.1,
	instrument: \harp,
	out: Pwhite(0,1,inf)
].pp
});
~recPath +/+ "freeport-title.wav" 
=> _.version 
=> _.record(1, 2, Reaper.lastPlayLength)
)
(//picasso
	// var len = 1218 f: 11 - (1117 f: 20);
	var pablo = 1118f:16;
	var len = 1148 f: 06 - pablo;
	\666.post; len.postln;
	Reaper.play(1117, 1218 f: 11);
	~rec2.("picasso.wav", Reaper.lastPlayLength);
	Reaper.sched( pablo - 0,{
		{
			Gendy1.arWidth(
				freq: 
				[
					[1,3,5,7,12].df(\g),
					[1,3,4,6,12].df(\g),
					[1,3,5,7,12].df(\g),
					[2,3, 5, 7, 13].df(\g)
				].flop.collect{|i| 
					i.dq(3)
				}.demand(
					( len / 6 ) ! 6 
				)
				=> Lag.kr(_,1)
				* EnvGen.cutoff( len, 3 )
			) / 30
			=> Splay.ar(_)
		}.play
	} )
)
(//saltimbanque note

	Reaper.play( 1156, 1202 f: 2);
	~rec2.("picasoo-note.wav");
	Reaper.sched( 1156 f: 16 - s.latency ,{
			( freq: [1,3,4,6,12].df(\g),
			dur: 5,
			out: Effect.bus({|i| FreeVerb.ar(i) },)
		).play
		}
	)
)
(//saltimbanque note 2

	Reaper.play( 1208, 1213f:16);
	~rec2.("picasoo-note2.wav");
	Reaper.sched( 1209f: 04 - s.latency ,{
			( freq:
					[2,3, 5, 7, 13].df(\g),
			dur: 1213 f: 16 - (1209 f: 04),
			out: Effect.bus({|i| FreeVerb.ar(i) },)
		).play
		}
	)
)
