(
MicroKeys(\better).synth_(
{ arg out=0, amp=0.1, pan=0, gate=1;
	var z;
	var freq = MicroKeys.freq.(~mk);
	// var freq = \freq.kr(500);
	z = LPF.ar(
		Mix.new(VarSaw.ar(freq + [0, Rand(-0.4,0.0), Rand(0.0,0.4)], 0, 0.1, 0.3)),
		XLine.kr(Rand(4000,5000), Rand(2500,3200) , 1)* (CC(24, ControlSpec(0.5, 4, \exp, default: 1), mk: ~mk ).bus.kr )
	) * Linen.kr(gate, 0.01, 0.7, 0.3, 2);
	OffsetOut.ar(out, Pan2.ar(z, pan, amp));
});
// MicroKeys(\better).monitor;
MIDIItem("MIDIItem_250109_104454").record([ 'better' ]);
MIDIItem("MIDIItem_250109_104454").take(0).recalcSustains.play([ 'better' ], overdub: true);
MIDIItem("MIDIItem_250109_104454").take(6).play([ 'better' ], overdub: true)

// MIDIItem.all.values.do(_.save)
// MicroKeys(\foo).synth_(\default);
// MIDIItem("250108_091401").save.play(\foo);
)
MIDIItem("MIDIItem_250109_104454").takes.size
a = MicroKeys.all
a


