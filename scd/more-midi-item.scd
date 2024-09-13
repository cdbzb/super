a = MIDIItem(\testfttx, false, synthFunc: {|amp midinote c s out coef| Synth(\harp, [freq: midinote.midicps, amp: amp/640, out: out, coef: topEnvironment.at(\coef).postln /128]  )}).monitor

MIDIdef.cc(\mod, {|v| ~coef = v.postln}, 1 )

a.record
a.stop
a.save
a.dump
a.notes

Event.addEventType(\a,  {a.synthFunc.valueEnvir(~amp*64) })
Event.addEventType(\b, { a.asPbind <> (type: \a, out: ~out, coef: ~coef) => _.play})
(type: \b, out: 1, coef: 0.1).play
[type: \b, dur: a.asPbind.patternpairs.asEvent.at(\dur).list.parse([3, 4]).q(inf), lag: Pwhite(0,0.02, inf),coef: Pbrown(0.1,0.7,0.1,inf), out: [0,1, 1, Effect.bus({|i| FreeVerb.ar(i,1,1) }), 0, 2, 3, 4, 3, 2].q(inf)].p.trace.play


