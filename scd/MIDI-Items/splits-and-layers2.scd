(
s.waitForBoot{
	MicroKeys(\b).synth_(\harp).range_( (0..50) );
	MicroKeys(\b).add(\quiet, {|e|  e.vel= (e.vel/ 10) max: 0.02 } , \addBefore, \range); //not works!
	MIDIItem("trashme_241209_091414")
	.record(MicroKeys(\b))
	.play(MicroKeys(\b))
}
)

(
	MicroKeys(\a).synth_(
		{ |gate=1 out=0 |
			var freq = \freq.kr(400) * (\poly.kr() / 127).midiratio;
			var in=PinkNoise.ar(1);
			var sig=Pluck.ar(in: in, trig: gate,  maxdelaytime: 0.02,  delaytime: 1/freq,  decaytime: \decaytime.kr(10),  coef: \coef.kr(0.5),  mul: 0.7,  add: 0);
			sig = sig * \amp.kr(0.1) * 10;
			sig = LeakDC.ar(sig)
			* Env.asr(0, 1, 3).kr(2,gate:gate)
			=> Pan2.ar(_, \num.kr(60) / 127 => _.linlin(0, 1, -1, 0));
			Out.ar(out,sig);
			// DetectSilence.ar(sig,doneAction:2);
		}.asDefName
	).add(\brightness, {|e| e.params = e.params ++ (coef:   1 - e.vel * ( (e.num / 10).reciprocal )).postln}, \addBefore, \synth);
// .activate
MIDIItem("_241212_093847")
// .record(\a)
.play(\a);
MIDIItem("_241212_093848")
.collect({|e| e.params = e.params ++ ( out: 1)})
.play(\a );
MicroKeys(\bass).synth_(
	{ arg out=0, freq=440, amp=0.1, pan=0, gate=1;
		var z;
		z = LPF.ar(
			Mix.new(VarSaw.ar(freq /4 * CC.bend(mk: MicroKeys(\bass)).bus.kr.linlin(-1,1,-4,4).midiratio + [0, Rand(-0.4,0.0), Rand(0.0,0.4)], 0, 0.3, 0.3)),
			XLine.kr(Rand(4000,5000), Rand(2500,3200), 1)
		) * Linen.kr(gate, 0.01, 0.7, 0.3, 2);
		OffsetOut.ar(out, Pan2.ar(z, pan, amp));
	}.asDefName
 );
MIDIItem("bass_241212_112145")
// .record(\bass)
.play(\bass)
)

(mk:MicroKeys(\a),type: \mk, 'midicmd': \noteOn, 'timestamp': 2.1079740109999, raw: 50,num: 50,'dur': 0.4399152220001, 'amp': 0.65354330708661, params: ( out: 2)).play
