(
a = MicroKeys({|e| {e.postln;SinOsc.ar(e.num.midicps) * Env.asr().kr(2,gate:\gate.kr(1))}.play});
a.tuning_(\partch);
a.play;
f = a.namedList.array.reverse.inject(I.d, _<>_)
)


b = MIDIItem2();
b.record
b.stop


(
Event.addEventType(\foo, {var syn = f.(~amp * 120, ~midinote);fork{~sustain.wait; syn.release}});
e = b.notes.collect({|i| var j = i.copy; j.type = \foo; j});
e.q.play
)
