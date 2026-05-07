( 
// ~tempo=2.0;
MicroKeys(\foo).add(\quiet, {|e| e.vel.notNil.if {e.vel= e.vel/8};e}, addAction: \addBefore, target: \synth);
// MIDIItem("_250115_125413").record(\foo);
// MIDIItem("_250115_125413").take(0).play(\foo, clock: TempoClock.new(tempo:1, queueSize:2**14));
// MIDIItem("_250115_125417").take(0).play(\foo, clock: TempoClock.new(tempo:1, queueSize:2**14));
// Song.play;
~tempo=2.0;
~tempo=1.97;
// TempoClock.tempo_(1)
// ~swing = 0.03;
~swing = 0.01;
TempoClock.tempo_(~tempo);
// Song.playOnly(\an);
// Song.play;
[
	freq: 
	[-5, 1, 2, 3, 1 ]
	++[-5, 1, 2, 3, 1 ]
	++[-4, 1, 2, 3, 1 ]
	++[-4, 1, 2, 3, 1 ]
	=>_.flat
	=>_.df(\c, 3) =>_.q(inf),
	dur: "qqqq q q q q".beats / 2  => _.q(inf),
	rests:MuteFirst()
].pp;
[
	freq: [\r, 3, 5, 11, 6, 4, 6, 14, 13].df(\c).q(inf),
	dur: [1, 1, 1, 1, 1, 1, 1, 1, 8] * 2 => _.q(inf),
	instrument: \stringyy,
	amp: 0.3
].pp;
[
	inst: [0, 1, 1, 0, 0, 1, 0, 1, 1, 0, 1, 0, 1].q(inf),
	instrument: Pfunc({|e| [\bd_808, \JWSnare][e.inst]}),
	accent: 
	[1, 1, 0.5, 1, 1, 1]
	++ [1, 1, 0.5, 1, 0.5, 1, 1]
	=>_
	.q(inf),
	amp: Pfunc({|e| [0.1, 0.1][e.inst] * e.accent}),
	dur: 
	[1, 0.75 + ~swing, 0.25-~swing, 0.5, 0.5, 1]

	++ [1, 0.75 + 0.03, 0.25-0.03, 0.25, 0.25,  0.5, 1]
	=>_
	.q(inf),
	// transientFreq: [0, 200, 200, 0, 0, 200].q(inf),
	// resonanceLength: 0.0905, 
	// resonanceFreq: 86,
].pp;

s.bind{
	{
		var levels = [5,1,2,1] /5 => _.dq(inf);
		var durs =  
		1/4 !14 
		* ~tempo.reciprocal
		+ ( [1, -1] /80 => _.dup(8) ) //swing amt
		=> _.flat 
		// => _.warpTo(e.tempoMap.quantizeWindow(0.3))
		=> _.dq(20);
		var triggers = TDuty.kr( durs, 0,1,gapFirst:0 );
		var energy = EnvGen.ar( Env.linen(0, 0.00, 0.015), triggers, doneAction:0   ) 
		* Demand.kr(triggers,0,levels 
			// * 40
			// *8
		);
		Shakers.ar(3, energy:energy   , decay: 1).tanh

		// /5
		* 2
		=> Pan2.ar(_, 0.8)
		// * EnvGen.cutoff(b.parse([4]).unbubble,3)
		=> DWGReverbC1C3.ar(_,mix:0.05)
		/12
		=> Pan2.ar(_,0.75)
		=> Out.ar(1, _)

	}.play;
	[
		instrument: \hat_808, 
		dur: "x x e x x e  x x x x x x e".beats.q(inf),
		pan:0.5
	].pp;
	(instrument: \cymbalsDS, amp:0.005).play
}
)

