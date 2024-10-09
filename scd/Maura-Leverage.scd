( //SETUP
	"Maura-Leverage-defs.scd".load;
~duration = {|from to| to.asFloat.asSeconds - from.asFloat.asSeconds};

~circle = {
};
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
Reaper.play(*~region);


~upperLine = [ [34f:16,36f:21 ], [45f:18,47f:2 ],[54f:6, 55f:16]];
~rightLine = [ [40f:10, 41f:08], [49f:20, 50f:16], [ 56f:8, 57 ], ];
~lowerLine = [ [43f:2, 44f:20], [ 51f:6, 52f:14 ],[57f:12, 58f:18]];


~upperLine.do{|i| i.postln;~drawLine.(*i)};
~rightLine.do{|i| ~drawLine.(*i)};
~lowerLine.do{|i| ~drawLine.(*i)};


~collection = (
	initial: 34f:14,
	grow1: (start: 45, end: 45f:15),
	grow2: (start: 52f:14, end: 53f:15),
	grow3: (start: 58f:18, end: 59f:5),
);
~len = {|i| ~collection[i].end - ~collection[i].start};

// ~drawLine.(32f:3, 34f:3 ); //circle

Reaper.sched( 32f:4,  
	{
		{
			Dust.ar(50) 
			=>Decay.ar(_,0.0001)
			=> Pan2.ar(_, 
				Env([0 , 1, 0, -1, 0], 0.5, \sin).kr(2).range(-0.3, -0.8)
			)
			=> BPF.ar(_, 
				Env([0 , 1, 0, -1, 0], 0.5, \sin).kr(2).range(500, 2000)
			)
		}.play
	}
);


Reaper.sched(30, { a = Synths(\stringyy,  //Title
	\attack, 3, 
	\freq, [300,400,555,676,880], 
	\amp, 0.2 
)});

Reaper.sched(34f:14,{ //paintings in circle 
	(
		instrument: \harpGendyPan,
		pan: [-0.6,-0.4,00.2,-0.33],
		freq: [500,600,375],
		freq: [-6, 1, 3, 5].df(\e, 6),
		modWidth:0.05,
		strum: 0.01,
		amp: 0.02,
		out: Effect.bus({|i| FreeVerb.ar(i, 0.9, 1) },)
	).play
});

Reaper.sched(32.03,{ a.release(4) });
//circle
//four paintings

[\grow1, \grow2, \grow3].collect{ |i x|
	Reaper.sched( ~collection[i][\start], {
		// fork{ ~len.(i).wait; Synth( \stringyy, [freq: [100, 125, 140][x]*2.5, amp:0.05]); };
		(instrument: \stringyy, freq: [100, 125, 140][x]*2.5, amp:0.05, lag: ~len.(i) - 0.2, sustain: ~black - ~collection[i][\start], release: 3 ).play;
		Synth(\suddenGrowth, [
			\len, ~len.(i) + 0.2,
			\startFreq, [100,125,140][x],
			\endFreq, [100,125,140][x] * 5,
			\amp,0.1
		]) 
	})
};

~black = 101.seconds.asInteger f:08;

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
	(instrument: \sawSynth,freq: 250, att: 3,freq: 350, amp:0.02).play
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
( //dustheads
Reaper.play(1512, 1610);
~fourPointFive = 1542f:16;
~embezzlement = [1544f:12, 1545f:9] ;
~malaysian = [1545f:18, 1546f:13];


~drawLine.(1525f:23, 1526f:21);
~drawLine.(1520f:21, 1522f:06);
~fourPointFive => Reaper.sched(_, {
	( instrument:  \stringyy , freq: [1, -1].df('c#') ).play;
	( instrument: \harpGendyPan,modWidth: 0.02, amp: 0.02, freq: [-1, -15].df(\e) ).play
});
[ ~embezzlement, ~malaysian ].collect{|i x|
	Reaper.sched(i[0], {
		var dyad = {
			Saw.ar([7, 12].df([\a, \b][x], \mixolydian), 0.1)
			* (Impulse.ar(18) => Decay.ar(_,0.1))
			* EnvGen.cutoff(i.differentiate[1], 0)
			/5
		}.play;
	})
}

)
(
//hole
Reaper.play(813, 840);
~holeSound = {
	BrownNoise.ar()
	/4000
	=> Klank.ar(`[[150, 200 ]], _)
	*EnvGen.cutoff(26f:20 - (14f:4), 0.1)
};
Reaper.sched( 814f:4, { ~holeSound.play } )
)
(

//earlyhole
Reaper.play(434, 555);
~holeSound = {
	BrownNoise.ar()
	/4000
	=> Klank.ar(`[[150, 200 ] * 1.5], _)
	// *EnvGen.cutoff(26f:20 - (14f:4), 0.1)
};
Reaper.sched( 437f:15, { ~holeSound.play } )
)
