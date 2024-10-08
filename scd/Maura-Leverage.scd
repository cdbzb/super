( //SETUP
	"Maura-Leverage-defs.scd".load;
~duration = {|from to| to.asFloat.asSeconds - from.asFloat.asSeconds};

~dotted = 	{ | dur |
	{ 
		Dust.ar(50) 
		=>Decay.ar(_,0.0001)
		=>TwoTube.ar(_,loss:0.8,d1length:rrand(20,30))
		=>MoogFF.ar(_,LFBrownNoise1.kr(2).range(4700,6000))
		=>Pan2.ar(_,0.5,0.7)
	}.play(s,0) .dur(dur)
};
~drawLine = {| start end | Reaper.sched(start, {~dotted.value(~duration.(start, end) )})};
~record = { | name, length |
	g = Group.after(1);
	b = Buffer.alloc(s, 65536, 2);
	b.write("~/tank/Leverage/SC".standardizePath +/+ name.asString, "wav", "int24", 0, 0, true);
	// create the diskout node; making sure it comes after the source
	d = Synth.tail(g, "diskout2", [\bufnum, b]);
	fork{ 
		length.wait ;
		d.free; 
	b.close;
	b.free;
	}
	
};

~myFree = {
	|vsti|
	s.freeMyDefaultGroup;
	fork{
		//s.latency.wait;
		TempoClock.all.do(_.clear);
		SystemClock.do(_.clear);
	};
	// Alga.parGroups[s] = AlgaParGroup(s.defaultGroup);
	~vstRegistry.do{|i| 16.do{|x| i.midi.allNotesOff(x)}};
	Reaper.stop;
	try{ Song.resources.select{|i| i.isKindOf(Node)}.do(_.release)};
	Trek.transitionGroup.release;
	// g=Group.new
}
)
( //animation 1
// Reaper.play(29, 45);
//Title
Reaper.sched(30, { a = Synths(\stringyy,  
	\attack, 3, 
	\freq, [300,400,555,676,880], 
	\amp, 0.2 
)});
Reaper.sched(32.03,{ a.release(4) });
//circle
~drawLine.(32f:3, 34f:3 );
//four paintings
Reaper.sched(34f:14,{ 
	(
		instrument: \harpGendyPan,
		pan: [-0.6,-0.4,00.2,-0.33],
		freq: [500,550,600,675],
		modWidth:0.05,
		strum: 0.01,
	).play
});
~collection = (
	initial: 34f:14,
	grow1: (start: 45, end: 45f:15),
	grow2: (start: 52f:14, end: 53f:15),
	grow3: (start: 58f:18, end: 59f:5)
);
[\grow1, \grow2, \grow3].collect{
	|i x|
	Reaper.sched( ~collection[i][\start], {
		Synth( \stringyy, [freq: [1, 3, 5].df(\c)[x], amp:0.05]);
		Synth(\suddenGrowth, [
			\growthTime, ~collection[i][\end] - ~collection[i][\start],
			\freq, [100,125,140][x],
			amp:0.05
		]) 
	})
};
~black = 101.seconds.asInteger f:08;
Reaper.play(*~region);
~drawLine.(34f:15, 36f:20);
//boxed words
~boxed = (
	loan: (
		initial: 36f:20, 
		grow1: (start: 47f:7, end: 47f:15),
		grow2: (start: 55f:18, end: 56f:02)
	),
	empty: 50f:14,
	emptyUpper: 56f:22,
	art:41f:4 
);
Reaper.sched( 35f:6, {
	(instrument: \sawSynth, att: 3,freq: 350, amp:0.05).play
});
Reaper.sched(36f:20, { 
	(freq: 700 * [1, 1.2], rel:4, amp:0.1, out: Effect.bus({|i| FreeVerb.ar(i,1,1) * [0.1, 0.9] })).play
});
~drawLine.(40f:08, 41f:07);
)

( // pigtail
Reaper.play(1201, 1217);
[
	1203f:22
	, 1205f: 20, 
	1206f: 21,
	// 1206f: 22
].do{|i x|
	Reaper.sched(i , {
		[1, 3.1, 6.2].df(\d)[x] => (instrument: \harp, freq: _) => _.play
	} )
};
1208f:3 => Reaper.sched(_, {
	{
		SinOsc.ar([1300, 500, 650, 750])
		* EnvGen.cutoff(14f:10-(8f:3), 0.1)
		* XLine.kr(1, 0.1, 5)
		/100
	}.play
})
//three disappointments
)
(
//twisty up
Reaper.play( 1308, 1320 );
Reaper.sched( 1309f:9 + 0.2, 
	{
		{
			Env( [1, 5, 2, 7].df(\e), [9f:9, 10f:6, 10f:22, 11f:12].differentiate.drop(1) ).kr(2)

			=> Saw.ar(_)
			/80
		}.play
	}
)
)
