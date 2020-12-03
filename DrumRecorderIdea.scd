s.latency=0.04
(
var time=Main.elapsedTime,w=Window.new.front.alwaysOnTop_(true);
var v = w.view;
~sequence = List();
v.keyDownAction={(instrument:\bd_808).play; ~sequence = ~sequence.add(Main.elapsedTime-time);time=Main.elapsedTime;~sequence.postln } 
)
[dur: ~sequence.q,instrument:\bd_808 ].pp
