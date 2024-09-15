(
~ccs = Dictionary.new;
~ccMapping = {|symbol num| ~ccs.put(symbol, ( num: num, val: 0.5 ))};
~ccMapping.(\mod, 1);
~ccs[\mod] .put( \spec, ControlSpec.new(minval:60, maxval:2000, warp:\exponential, step:0.0, default:nil, units:nil, grid:nil) );
~ccMapping.(\lag, 24);
~ccs[\lag].put(\spec, ControlSpec.new);
~ccMapping.(\ffreq, 25);
~ccs[\mod] .put( \spec, ControlSpec.new(minval:60, maxval:8000, warp:\exponential, step:0.0, default:nil, units:nil, grid:nil) );
MIDIdef.cc(\KSMod, {|num| ~ccs.at(\mod).val_(~ccs.at(\mod).spec.map(num / 128))}, ~ccs.at(\mod).at(\num));
MIDIdef.cc(\KSLag, {|num| ~ccs.at(\lag).val_(~ccs.at(\lag).spec.map(num / 128))}, ~ccs.at(\lag).at(\num));
MIDIdef.cc(\KSFfreq, {|num| ~ccs.at(\ffreq).val_(~ccs.at(\ffreq).spec.map(num / 128))}, ~ccs.at(\ffreq).at(\num));
)
(
a = {Saw.ar(\freq.kr(300).lag(\lag.kr(0.1).poll)) * 0.1 => MoogFF.ar(_, \ffreq)}.play
MIDIdef.cc('se', {|num| ~ccs.at(\mod).val => { |i| a.set(\freq, i)}})
MIDIdef.cc('24', {|n| n.postln; a.set(\lag, ~ccs.at(\lag).val )}, 24)
MIDIdef.cc('25', {|n| n.postln; a.set(\lag, ~ccs.at(\lag).val )}, 25)
)
~ccs.at(\lag).val
~ccs.at(\mod).val
ControlSpec.new(minval:60, maxval:20000, warp:\exp, step:0.0, default:nil, units:nil, grid:nil).map(0.5)
Spec(\freq).dump
Spec.specs[\db]
\db.asSpec.map(0.0)
.map(0.5)
a = CC(\mod, 1, \freq.asSpec)
b = Synth(\stringyy, [freqLag: 5])
a.map(\freq, {|n| b.set(\freq, n => _.postln)})
a.val
f = {|n| n + 3}
{f.(3)}.()


a.spec.map(a.val)
a.val
a.number

~ccs[\mod].value_(8)
~ccMapping.cs
MIDIdef.cc('KS_1', {|num| })
a = CC(\mod, 1, \freq.asSpec)
a.bus.scope
a.spec.map(a.val)
(

a = CC(\mod, 1, ControlSpec(60, 2000, \exp, default: 400));
b = CC(\ffreq, 24, ControlSpec(60, 8000, \exp, default: 1000));
{
	Saw.ar( a.asBus.().lag3([1, 2, 3]/10), 0.1 ) 
	=> MoogFF.ar(_, b.asBus.())
	=> Splay.ar(_)
	=> {|i| i + CombC.ar(i, 0.5, CC(\delayTime, 25, ControlSpec(0.1, 0.5)).asBus.().lag3(0.2), 2)}
}.play
// a.bus.set(200)
)
a.bus.scope
a.bus.index
Bus(index: a.index).scope
b.bus
b.index
a.name
		MIDIdef.cc("-bgggus", { a.spec.map(a.val) => a.bus.set(_) }, a.number);
a.getBus.scope
a.spec.map(a.val)
b.name
MIDI
Synth( \stringyy, [\freq, 440 + ~ccs.at(\mod)] )
