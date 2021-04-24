(
/*
"rpr ~/tank/Maura-PCS/PCS.RPP".unixCmd;
*/
~samplesDir="~/tank/Maura-PCS/sfx".standardizePath;
~samples={|folder| ~samplesDir +/+ folder.asString ++ "/*" => _.pathMatch=>_.collect({|i| Buffer.read(s,i)}) };
~air = ~samples.("air");
~bills = ~samples.(\bills);
Item.samplesDir_("~/tank/Maura-PCS/sfx/");

~sections=();

~sections.fincen={
	Reaper.play(135,150);
	Reaper.sched(136.01,{(
	//note:6,
	freq:[6].df(\c,octave:2),
	instrument:\sawSynthSustain,
	att:9,
	dur:9).play}
);
Reaper.sched( 137.9,{(note:3,dur:3).play} );
//Reaper.clock.sched(3,{(note:1).play});
Reaper.sched( 140.4,{(note:[1,3,5,7],dur:3,instrument:\stringyy).play
} );
//2:15 bills
};

~sections.bills = {
	//Reaper.play(215,301);
	Reaper.play(213,400);
	Reaper.clock.seconds.postln;
	//~bills[0].play;
	{PlayBuf.ar(2,~bills[0],rate:0.85)}.play;

	{
		[
			[freq:[11,1].df(\a).q(inf)].p,
			[freq:[[4,6],[5,7],[3,11]].df(\d).q(inf),dur:[2,2,4].q(inf)].p,
			[\r,4,3,2,1,3,2,1,-6].df(\d,octave:6).q=>[freq:_]=>_.p
		] => Ppar(_) =>_.play; 
	}=>Reaper.sched(215,_)
};
~sections.gas = {
	Reaper.play(1558,1624);
	a=~air[0].play(mul:9);
	Reaper.sched(1616,{a.free});
	Reaper.sched(1612.6,{(note:2,dur:5).play});
	Reaper.sched(1619.33,{(note:[1,3],instrument:\stringyy,dur:6).play})
};

~sections.slides = {
	Reaper.play(1650);
	Reaper.sched(1651.0,{[note:Pwhite(0,10.0),instrument:\claves_808,dur:[1.2].q(10)].pp})
};
)

/*/
End
~sections.hands.value
~sections.slides.value
~sections.gas.value
~sections.bills.value
~sections.fincen.value
Start
*/ 
