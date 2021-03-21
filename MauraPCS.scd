(
a="~/tank/Maura-PCS/sfx/*".standardizePath.pathMatch.collect({|i| Buffer.read(s,i)});
a[0].play(mul:0.02)
)
Reaper.go(100)

a[1].path.fileName
a[2].path.fileName
a[2].play
Item.samplesDir_("~/tank/Maura-PCS/sfx")
//put Items' in folder called "directory"
//should be renamed Items.....
Item.list
a=Items(\bills)
Items(\bills).list
"open " ++ Item.samplesDir=> _.unixCmd
a.list
1.47



(
Reaper.play(135);
Reaper.sched(136.01,{(
	//note:6,
	freq:[6].df(\c,octave:2),
	instrument:\sawSynthSustain,
	att:9,
	dur:9).play}
);
Reaper.sched( 137.9,{(note:3,dur:3).play} );
//Reaper.clock.sched(3,{(note:1).play});
Reaper.sched( 140.4,{(note:[1,3,5,7],dur:3,instrument:\stringyy).play} );
//2:15 bills
)
TempoClock.seconds_(9)
