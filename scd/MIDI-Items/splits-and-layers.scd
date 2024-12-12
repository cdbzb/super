(
s.waitForBoot{
	MicroKeys.mono(\aa).synth_(
		{ |gate=1 ampLag=0|
			// var freq=\freq.kr(400,\freqLag.kr(0.05));
			var freq = \num.kr(50, \freqLag.kr(1)).midicps;
			var width=\width.kr(6);
			//var gate=\gate.kr(0);
			Gendy2.ar(minfreq:freq-width,maxfreq:freq+width)
			=>Mix.ar(_) *0.5
			+Gendy1.ar(minfreq:freq-width,maxfreq:freq+width)
			* 0.1 * \amp.kr(0.5,ampLag)
			=> (PlateReverb.ar(_,10,mix:\mix.kr(1)) ++ (_*0.5)) => Mix.ar(_)
			* Env.asr(\attack.kr(0.5),1,\release.kr(4)).kr(2,gate:gate)
			=> PanAz.ar(5, _, Sweep.ar(1, 0.1))
			// =>Out.ar(\out.kr(0),_)
		}.asDefName
	);
	MicroKeys(\aa).range_((50..127));
	MicroKeys(\b).synth_(\harp).range_( (0..50) );
MIDIItem("trashme_241209_091414")

.record([MicroKeys(\aa), MicroKeys(\b)])
// .record([ MicroKeys(\b)])
.play(
	[
	MicroKeys(\aa),
	MicroKeys(\b).add(\quiet, {|e| e.vel= ((e.vel/ 10) max: 0.02) }, \addBefore, \synth),
	MicroKeys(\bar).synth_(\sawSynthSustain).add(\down,{|e| e.num.notNil.if { e.num= e.num- 12 + 0.1.rrand(-0.1)};e.silent=[nil,true].choose}, \addBefore, \synth),
	// MicroKeys(\foo).synth_(\sawSynthSustain).add(\down,{|e| e.num.notNil.if { e.num= e.num- 12 };}, \addBefore, \synth),
	MicroKeys(\d).synth_(\default, [out:Effect.bus({|i| Phaser2.ar(i, 0.9, 0.8)* 3 })]).add(\quiet, {|e| e.vel = e.vel / 4; }, \addBefore, \synth),
]
)

};
)
[MicroKeys(\aa),MicroKeys(\d)].do( MIDIItem("trashme_241209_091414").play(_) )
 MIDIItem("trashme_241209_091414").play(MicroKeys(\aa)) 
MicroKeys(\aa).down
MicroKeys(\aa).doNoteOff(70, 50)
MicroKeys(\aa).doNoteOn(71, 90)
MicroKeys.monosynth
