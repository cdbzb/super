( //SETUP
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
	b.write("~/tank/Maura-PCS/SC".standardizePath +/+ name.asString, "wav", "int24", 0, 0, true);
	// create the diskout node; making sure it comes after the source
	d = Synth.tail(g, "diskout2", [\bufnum, b]);
	fork{ 
		length.wait ;
		d.free; 
	b.close;
	b.free;
	}
	
};

)
( //CUE 3
var region = [1648, 1722];
var length = region.asFloat=>{|i|i[1].asSeconds-i[0].asSeconds};
Reaper.play(*region);
~notes=[
	1653.416,
	//1656.116,
	1706.043,
	1709.875
];
~bells=[5,6,13,12].q.asStream;

// CHECK LATENCY BELOW
~notes.do({|i| Reaper.sched(i-0.2,{(freq:~bells.next.df(\a,octave:5),dur:5).play}) });
Reaper.sched(1649.375,{
	var octave = 4;
	[ 
		instrument: \stringyy,
		freq:
		[
			[1,2,3,4,5,6].df(\a,octave:octave),
			[-6,1,3,4,11].df(\a,octave:octave)
		].q(2),
		legato:1.05,
		dur:(~duration.(1650,1709)) /4,
		amp:0.05
	].p.play
});
// Line
Reaper.sched( 1656.115,{
	(type:\tuneUp,freq:440,amp:0.1,out:Effect(LPF.ar(_,700),out:0).bus.index).play
});
Reaper.sched( 1656.115,{
	(type:\tuneUp,freq:440,amp:0.1,out:Effect(LPF.ar(_,700),out:1).bus.index).play
});

~drawLine.(1651.666,1653.416);
Reaper.sched(1703.25,{ ~dotted.value(~duration.(1703.25,1704.083)) });
Reaper.sched(1705.25,{ ~dotted.value(~duration.(1705.25,1706.0)) });
Reaper.sched(1657.116,{ ~dotted.value(~duration.(1657.115,1657.583)) //[dur:1/12].p.fin(5).trace.play
});

 //~record.("Cue3II.wav",~duration.(*region))
)
( //CUE 2
Reaper.play(810,850);
Reaper.sched(812.333,{
	var octave = 4;
	[ 
		instrument:\stringyy,
		freq:
		[
			[1,2,3,4,5/*,6*/].df('a-',octave:octave),
			[-6,1,3,4/*,11*/].df('a-',octave:octave)
		].q(2),
		legato:1.05,
		//dur:(1714.0.asSeconds-1650.0.asSeconds) /4,
		dur:(1709.875.asSeconds-1650.0.asSeconds) /4,
		amp:0.05
	].p.play
});
//Reaper.play(810,818);
~drawLine.(814.25,815.083);
Reaper.sched( 817.932,{
	(type:\tuneUp,freq:440,amp:0.1,out:Effect(LPF.ar(_,700),out:1).bus.index).play
});
~drawLine.(818.041,818.5);
~drawLine.(827.375,828.166);
~drawLine.(830.958,831.708);
~drawLine.(833.25,833.75);
Reaper.sched( 834.750,{
	{In.ar(2,2)}.play(addAction:\addToHead);
	[1,3,5,6,12].df('a-').do{|i|(type:\reedy,freq:i,amp:0.015,release:3).play};
	~gong.(880,amp:0.015);
	//{In.ar(2,2)}.play(addAction:\addToHead);
	
});

// PITCHED WORDS
~notes=[
	//817.938,
	815.083,
	828.166,
	831.708,
];
~bells=[5,6,13,12].q.asStream;
// CHECK LATENCY BELOW
~notes.do({|i| Reaper.sched(i-0.2,{(freq:~bells.next.df('a-',octave:5),dur:5).play}) });
//~record.("Cue2.wav",~duration.(810,850))
)
( //First CUE
Reaper.play(406,445);
~drawLine.(410.0,412.833);
Reaper.sched(412.5,{
	(instrument:\stringyy,freq:[3,5,6,12,15].df(\g),dur:~duration.(412.5,439.6)).play;
	~gong.(1.df(\g));
	//~gong.(3.df(\g));
});
~drawLine.(414.4,416.166);
Reaper.sched(419.166,{
	//(type:\tuneUp,dur:4,freq:2.df(\g),amp:0.1).play
	(type:\tuneUp,freq:440,amp:0.1,out:Effect(LPF.ar(_,700),out:1).bus.index).play
});
~drawLine.(425.166,425.5);
~drawLine.(426.666,427.166);

~drawLine.(435.25,435.5);
Reaper.sched(433.833,
	{
		{Impulse.ar(6)=>Klank.ar(`[[400,600,800,900]+2000,0.2,0.5!4],_)}.play.dur(5/6)
	}
);

~notes=[
	416.166,
	425.5,
	427.166,
	435.25,

];
~bells=[5,6,13,12].q.asStream;
// CHECK LATENCY BELOW
~notes.do({|i| Reaper.sched(i-0.2,{(freq:~bells.next.df(\g,octave:5),dur:5).play}) });

 //~record.("Cue1.wav",~duration.(406,445))
)
( //Ending
var region = [1849,1930];
var length = region.asFloat=>{|i|i[1].asSeconds-i[0].asSeconds};
Reaper.play(*region);
//~notes=[
//	1653.416,
//	//1656.116,
//	1706.043,
//	1709.875
//];
//~bells=[5,6,13,12].q.asStream;

// CHECK LATENCY BELOW
//~notes.do({|i| Reaper.sched(i-0.2,{(freq:~bells.next.df(\a,octave:5),dur:5).play}) });
Reaper.sched(1849.5,{
	var octave = 4;
	[ 
		instrument: \stringyy,
		freq:
		
			[1,2,3,4,5,6].df(\b,octave:octave)
			//[-6,1,3,4,11].df(\b,octave:octave)
		//].q(2),
		,
		//legato:1.05,
		dur:~duration.(1849.5,1905) ,
		//dur:~duration.(1849.5,1854,5) ,
		amp:0.05
	].p.fin(1).play
});
// Line
Reaper.sched( 1852.6,{ (type:\tuneUp,freq:440,amp:0.07,out:Effect(LPF.ar(_,700),out:0).bus.index).play });

~drawLine.(1851.583,1852.666);

 //~record.("CueEND.wav",~duration.(*region))
)
(
//Money
Reaper.play(325,340);
~record.("money.wav",15);
Reaper.sched(328.45, { (freq:12.df(\g),dur:12).play } )
)
(
Reaper.play(1529.75,1600);
a={
	var chain = 
	Dust.ar(\density.kr(1000))
	//=>TwoTube.ar(_,loss:0.8,d1length:rrand(43,30),d2length:rrand(20,50))
	=> FFT(LocalBuf(2048),_);
	chain = PV_MagSmooth(chain,Line.kr(0.1,0.9,10));
	chain = PV_MagSmear(chain,Line.kr(1,9,10));
	IFFT(chain)
	* Line.kr(1,0,10)
	=> FreeVerb.ar(_,1,1)
}.play(s,1)
)
(
~addBus={|...args| var bus=Bus.audio; var synth=Synth(*args); synth.set(\out,bus.index);[synth,bus]}
~addBus.(\default,[\freq,[300,400,500]])
 { SinOsc.ar(440.rand,\phase.kr(0)) } => _.play(s,1) => _.mapLfo(\phase,{SinOsc.kr(Line.kr(400,200,8))})
 =>_.play



 a=NodeProxy.new(s,\audio,2).play.fadeTime_(1);
 a.fadeTime_(2);
 a.source_({Gendy4.ar(0.1,0.1,durscale:0.0009,minfreq:[ 300,420,500,640 ]*.x 0.8,maxfreq:310)=>Pan2.ar(_,LFBrownNoise2.kr(0.3))})
)
