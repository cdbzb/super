~synth=(
	filterTypes: [{RLPFD.ar(in, freq, res, dist, gain)}, {BPF.ar(in, freq, res, gain)},nil ],
	filter: NodeProxy.audio(s,1).play,
	osc: NodeProxy.audio(s,1),
)


~synth.filter.source=~synth.filterTypes.choose;
~synth.osc.source=Saw.ar()

s.boot;

~buf= Buffer.new(s, 8192,  numChannels:1,  bufnum:0);

(
	SynthDef.new(\test, {|freq=400 gate=1 delay=0.60 ffreq=400|
		var sig= Saw.ar(freq );
		var env = Env.perc(0.01,1.5).kr(2,gate,1,0.1);
		sig=sig+PulseDPW.ar(freq/2,0.2);
		ffreq=SinOsc.ar(5.1,0,2500,ffreq+1500);
		sig=MoogFF.ar(sig,ffreq,2);
		sig= LeakDC.ar(sig+CombN.ar(sig,1,delay,9) ).distort;
		Out.ar(1,sig*env);
	},  rates: nil,  prependArgs: nil,  variants: nil,  metadata: nil).add;
)

(
	a.free;
SynthDef(\delay,{|in delay|
	var sig=In.ar(3,  numChannels: 1);
	sig = CombN.ar(sig,  maxdelaytime: 0.2,  delaytime: 0.2,  decaytime: 4,  mul: 1,  add: 0);
	Out.ar(0,sig!2);
}).add;
a=Synth(\delay)
)

(
	Pbind(*[
		instrument:\test,
		degree: Pseq.new([1,3,5,8]+30,inf),
		dur:0.06,
		amp:0.05
	]).play
)

s.options.memsize=2**17;
s.reboot;
