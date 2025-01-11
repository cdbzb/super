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
	   
(//new mandarin sketch
// MIDIItem("sketch_250110_122615").take(1).play(\better)
m = MIDIItem("sketch_250110_122615");
m.record
m.take(2).start_(106).play(\better) //last pattern only
m.take(3).start_(1).play(\better) //last pattern only
m.take(6).play(\better) 
)
(
var beat = 1;
//digital-ish figure?
[
	freq: [1, 1, 11, 11].df(\c).q(inf),
	lagTime:0,
	dur: 0.15,
	instrument: \hat_808,
	rel:0,
	pulse: 0.8
].pp;
[
	rest: [\r, 1].q(inf),
	instrument: \sn_808,
	dur: 0.3 * beat
].pp;
[
	freq: [1, 1, 11, 11].df(\c).q(inf),
	lagTime:0,
	dur: 0.15 * beat,
	instrument: \sawSynth,
	rel:0,
	pulse: 0.8
].pp;
// MIDIItem("MIDIItem_250110_130456").record([ 'better' ])
MIDIItem("MIDIItem_250110_130456").take(1).play(\better)
)

MIDIItem.all.values.do(_.save)
( //find pattern
m = MIDIItem("MIDIItem_250110_130456").take(1);
m.notes
~lookForMatch = {|midiItem start length | 
	var m = midiItem.select({|e| e.type == \mk}).midiEvents.collect{|i| i.midinote};
	m[start..(start + length)]
	.similarity(m[start+ length+1..(start+length+1+length)]) 
};
	
~lookForMatch.(m, 2, 5);
a = (10..45).collect{|i| i.postln;try{~lookForMatch.(m, 2, i)}};
a.indexOf(a.maxItem);
m.notes[ a.indexOf(a.maxItem) ][\timestamp] //4bar pat
)

m.midiEvents.collect{|e| e.midinote}.similarity(m.start_(20).end_(30).midiEvents.collect{|e| e.midinote})
MIDIItem("_250111_095637").take(1).play(\better)
MicroKeys(\better).monitor
MIDIItem("_250111_095637").take(0).play(\better)
.record
MIDIItem.all.do(_.save)
/*
- Verse 1 (4/4 time, ♩=85)
  霓虹灯照亮我的脸 (♩ ♩ ♩ ♩ | ♩ ♩ ♩ -)  
  Néng hóng dēng zhào liàng wǒ de liǎn  
  手机屏幕又暗又冷 (♩ ♩ ♩ ♩ | ♩ ♩ ♩ -)  
  Shǒu jī píng mù yòu àn yòu lěng  
  万家灯火像星星 (♩ ♩ ♩ ♩ | ♩ ♩ -)  
  Wàn jiā dēng huǒ xiàng xīng xīng  
  但我依然感觉好孤寂 (♩ ♩ ♩ ♩ | ♩ ♩ ♩ -)  
  Dàn wǒ yī rán gǎn jué hǎo gū jì  
- Chorus
  滑动屏幕寻找共鸣 (♩ ♩ ♩ ♩ | ♩ ♩ ♩ -)  
  Huá dòng píng mù xún zhǎo gòng míng  
  数据海洋中迷失自己 (♩ ♩ ♩ ♩ | ♩ ♩ ♩ -)  
  Shù jù hǎi yáng zhōng mí shī zì jǐ  
- Verse 2
  城市脉搏跳动不停 (♩ ♩ ♩ ♩ | ♩ ♩ ♩ -)  
  Chéng shì mài bó tiào dòng bù tíng  
  我的心却慢慢冷清 (♩ ♩ ♩ ♩ | ♩ ♩ ♩ -)  
  Wǒ de xīn què màn màn lěng qīng

- Verse 1: Neon lights illuminate my face The phone screen is dark and cold City lights sparkle like stars Yet I still feel so lonely 
*/

(// quarters version
MIDIItem("quartersVersion_250112_102445").record(\better)
MIDIItem("quartersVersion_250112_102445").take(1).play(\better)
MIDIItem("quartersVersion_250112_102445").save
.take(1).play(\better)
)
