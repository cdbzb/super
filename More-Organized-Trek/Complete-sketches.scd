"~/tank/super/More-Organized-Trek/Songs/Complete-song.scd".standardizePath.load

	~complete.addGuides.("xxx.xxxxxxx")
	~complete.play;

(//adding a part to Hello using List comprehension...{{{
	all {:x,x<-~complete.parts.keys,var y=~complete.parts[x],(x==\guide3).not,(y.start==3).or(y.start==4),::x.postln;y.p};
	[legato:1.05,degree:([8,7,6,5].q++[6,6,5,4].q)-1,amp:Pseries(0.1,-0.015),octave:[4,5],dur:1,root:2].p.trace.play(~complete.parts.helloSequence.clock);
	//[degree:[8,7,6,5,6].q-1,octave:[3,4],dur:1,root:2].p.play(~complete.parts.helloSequence.clock);
);//}}}

/// transform-complete transition can I make a seperate song out of this?{{{
"~/tank/super/More-Organized-Trek/Songs/Transform-song.scd".standardizePath.load

(
	fork{
		~transform.play;
		~transform.durTillEnd.wait;
		~complete.play;
	}
)//}}}

// TODO replace visual with Still
// Why don't these sto...aaah only TempoClock gets stopped, how to stop them all?
// add HelloClock to registry of clocks that get stopped by ~myFree

