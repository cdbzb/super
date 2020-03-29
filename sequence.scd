a=List.new();
a.add(T(1,{1.postln}))
a.add(T(2,{2.postln}))
a.do({|i|(i.at1>1.5).if {TempoClock.sched(i.at1,i.at2)}})
a.play
