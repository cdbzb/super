(
s.waitForBoot{
	MicroKeys(\b).synth_(\harp).range_( (0..50) );
	MicroKeys(\b).add(\quiet, {|e|  e.vel= (e.vel/ 10) max: 0.02 } , \addBefore, \range); //not works!
	MIDIItem("trashme_241209_091414")
	.record(MicroKeys(\b))
	.play(MicroKeys(\b))
}
)

( // harpsichord songlet
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
~patternStarts = MIDIItem("_241212_093847").select({|e| e.midinote == -3.dm(\c)}).filter({|list| list.select{|e x| e.timestamp - list.wrapAt(x - 1).timestamp  > 1.2 }}).[\timestamp];
~patternDurs = ~patternStarts.differentiate;
MIDIItem("_241212_093847")
.play(\a);
MIDIItem("_241212_093848")
// .record(\a)
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
.play(\bass);
MIDIItem("bass_ExtraNotes241212_112145")
// .collect({|e| e.params = e.params ++ (out: 4); e})
.player
//sadly collect needs to be after player!
.collect({|e| e.params = e.params ++ (out: 4); e})
// .collect({|e|  e})
// .record(\bass)
// .play(MicroKeys(\bl).synth_(\sawSynth))
.play(\bass);
MicroKeys.mono(\vocal).synth_(
	{ |gate=1 ampLag=0| //{{{
		var freq=\num.kr(400,\freqLag.kr(0.05)).midicps;
		var width=\width.kr(6);
		//var gate=\gate.kr(0);
		Gendy2.ar(minfreq:freq-width,maxfreq:freq+width)
		=>Mix.ar(_) *0.5
		+Gendy1.ar(minfreq:freq-width,maxfreq:freq+width)
		* 0.1 * \amp.kr(0.5,ampLag)
		=> (PlateReverb.ar(_,10,mix:\mix.kr(1)) ++ (_*0.5)) => Mix.ar(_)
		* Env.asr(\attack.kr(0.5),1,\release.kr(8)).kr(2,gate:gate)
		=>Out.ar(\out.kr(0),_)
	}.asDefName
	, [mix: 0.1, out: Effect.bus({|i| i * 9 },)]
);

MIDIItem("vocalLine_241213_080701")
// .record(\vocal)
.play(\vocal)

)
(//bassline - TODO add tamborine!
MIDIItem("bassIdea_241212_172222")
// .record(\bass)
.play(\bass)
)

(
m = MicroKeys(\pf).synth_(\default);
MIDIItem("pf_241213_075725")
// .record(\pf)
.play(\pf)
)
(
fork{
	4.do{
		3.do{|x|
			[
				MIDIItem("_241212_093848")
				.collect({|e| e.params = e.params ++ ( out: x)}),
				// .record(\a)
				MIDIItem("_241212_093847")
				.collect({|e| e.params = e.params ++ ( out: x+ 1)}),
			].do {|i|
				i
				.start_( ~patternStarts[x])
				.end_(~patternStarts[x + 1])
				.play(\a);
			};
			~patternStarts.differentiate[x+1].wait
		}
	}
}
)
(//song version effort
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
	~patternStarts = MIDIItem("_241212_093847").select({|e| e.midinote == -3.dm(\c)}).filter({|list| list.select{|e x| e.timestamp - list.wrapAt(x - 1).timestamp  > 1.2 }})[\timestamp];
	~patternStarts = [0] ++ ~patternStarts;
	~durs = ~patternStarts.differentiate.drop(1);
	Song(\harpsiSong, []).current;
	~finish = {
		Song.sections.do{|x|
			P(\harpsi, start:x, music: { |p b e|
				[
					MIDIItem("_241212_093847"),
					MIDIItem("_241212_093848")
					.collect({|e| e.params = e.params ++ ( out: 0)})
				].do{|i| i
							.start_(~sectionStart[ x ])
							.end_(~sectionStart[ x+1 ])
							.play(\a)
						}				
					});
				}
	};
	// ~counter = Pseries(0,1).dupEach(2).asStream;
	// a = { var string = "[ \\\"%\\\", [r], [~durs[%]] ].addLine;".format(~counter.next, ~counter.next); Nvim.replace(string ) };
[ "0", [r], [~durs[0]] ].addLine;
[ "1", [r], [~durs[1]] ].addLine;
P(\cymbal, music: { |p b e|
	(instrument:\cymbalsDS, amp:0.5).play
});
[ "2", [r], [~durs[2]] ].addLine;
[ "3", [r], [~durs[3]] ].addLine;
	~sectionStart = [0] ++ Song.secDur[..Song.sections] => _.integrate;
	~finish.()
)
