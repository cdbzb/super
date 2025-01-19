(
MicroKeys(\pluck);
MicroKeys(\pluck).synth = { |gate=1 out=0 |
	var decaytime = \decaytime.kr(10);
	var in=PinkNoise.ar(1);
	var sig=Pluck.ar(
		in: in,
		gate: gate,
		maxdelaytime: 0.02,
		// delaytime: freq * (\poly.kr() / 127 + CC.bend(mk:MicroKeys(\pluck), rawScale: 16384).bus.kr => _.midiratio)   + [0.5, 0, -0.1]=> _.reciprocal,
		delaytime: MicroKeys.freq.() + [0.5, 0, -0.1] => _.reciprocal ,
		decaytime: decaytime,
		coef:  CC(24, mk: \pluck).bus.kr + [0, 0.1, 0.2],
	)
	=> Splay.ar(_)
	* \amp.kr(0.1) * 10
	* Env.asr().kr(2,gate:gate)
	* EnvGen.cutoff(decaytime - 0.1, 0.1)
	=> LeakDC.ar(_);
	Out.ar(out,sig);
};
// MicroKeys(\pluck).record;
// MIDIItem("241217_102915").take(1).start_(127.5).play(\pluck);
// MicroKeys(\chordOd).synth_(\sawSynth).record;
)
MicroKeys(\pluck).monitor
// MIDIItem("241217_094128").take(7).play(\pluck)
(
var transport = 3;
// MIDIItem("241217_102915").take(8).start_(70).play(\pluck); // Rocking between c and c#
MIDIItem("241217_102915").take(8).start_(70 + transport).play(\pluck); // Rocking between c and c#
MicroKeys(\vocalLine).synth_(\sawSynthSustain).monitor;
MicroKeys(\ld).synth_(\stringyy, [release: 3]).add(\quiet, {|e| e.vel.notNil.if{ e.vel = e.vel * 1.5 + 30 }; e}, \addBefore, \synth);
// .monitor
// .record
MIDIItem("241220_132623")
// .record(\ld) 
.filter({|i| i.collect{|e| e.amp.notNil.if{e.amp_ (e.amp -30); e}{e}}})
.start_( transport)
.play(\ld);
// 城市的燈 (scratch lyric)

)
(

var transport = 3;
MIDIItem("241220_132623")
// .record(\ld) 
.filter({|i| i.collect{|e| e.amp.notNil.if{e.amp_ (e.amp -30); e}{e}}})
.start_( transport)
.play(\ld);
m = MIDIItem("241217_102915").take(8)
.select({|e| e.timestamp>=73 and: e.midinote.notNil})
.select({|e| 
	var pitch = 'c#';
	(e.midinote == -11.dm(pitch)) or: (e.midinote == -1.dm(pitch))
}).recalcSustains
.select({|e| e.midicmd == \noteOn})
.filter({|list| list.select{|i x| x.odd } })
.play(MicroKeys(\default).synth_(\cymbalsDS, [out: 2]).name);
// .play(\pluck);

MIDIItem("241217_102915").take(8).start_(73.09).play(\pluck)
// example effort to make Song from durations (for reference)
// "/Users/michael/tank/super/scd/MIDI-Items/splits-and-layers2.scd"
)
MIDIItem("241217_120932").take(0).recalcSustains.fromNoteTo(14, 50).play(\pluck) //nice descending 7ths figure
MIDIItem("241217_132422").take(1).play(\pluck) //effort to integrate to two
// TempoClock.default = TempoClock.new(queuSize: 2**24)
)
(
MicroKeys(\pluck).record
m = MIDIItem("241218_072744");
MIDIItem("241218_072744").take(1).fromNoteTo(4, 1000)
MIDIItem("241218_072744").take(1).fromNoteTo(4, 1000).recalcSustains.play(\pluck)
m.take(3).play(\pluck)
.play(\pluck) //outtro idea?
)
(
m = MIDIItem("241218_072744");
m.take(3)
// .fromNoteTo(0, 1000)
// .recalcSustains
.quantize(choiceFunc: {|e| e.select({|e| e.midinote == 41})}, beats: (2.5, 2.55..5))
.recalcSustains
.play(\pluck)
// MicroKeys(\pluck).record
)
( //pbind version
	var dur = 0.43;
	[
		[
			degree: [1, 5, 6, 9, 13, 9, 6, 5] - 1 => _.q(inf),
			root: -3,
			mtranspose: Pseries(0, -1).dupEach(8),
			scale: Scale.aeolian,
			dur: dur,
			legato: [7, 1, 5, 1, 1, 1, 1, 1].q(inf)
		].p,
		[
			degree: [14, 13].q(inf),
			root: -3,
			mtranspose: Pseries(0, -1).dupEach(2),
			scale: Scale.aeolian,
			dur: [1, 7].q(inf) * dur
		].p.trace
	] => {|array|
		Ptpar([
			dur , array[0],
			0, array[1]
		])
	} => _.play

)
