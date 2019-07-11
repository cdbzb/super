(
SynthDef(\test, { |in out mix lagg|
    var sig;
	sig = VSTPlugin.ar(In.ar(in, 2), 2, id: \eq, params: [1,mix.lag(lagg)]);
	Out.ar(out, sig);
	}).add;

	SynthDef(\pf,{|in out=0|
		var sig=VSTPlugin.ar(nil,2);
		Out.ar(out,sig)
	}).add
)

( ///function way
	~verb={ |in=3 out=0|
			var eq = VSTPluginController.new(Synth(\test, [\in, in, \out, out]), \eq);
		{
			s.sync;
			eq.open("/Library/Audio/Plug-Ins/VST/Verberate.vst");
		}.fork;
			eq;
	}
)
v=~verb.();
		{Saw.ar(300+SinOsc.ar(0.1,50,-25),0.1)}.play(s,3);
		v.synth.set(\mix,0.5);
		v.synth.set(\lagg,10);
		v.set(2,1);
		v.set(0,0);
		v.gui;


( //// Pianoteq
	{
		SynthDef(\pf,{|in out=0|
			var sig=VSTPlugin.ar(nil,2);
			Out.ar(out,sig)
		}).add;
		s.sync;
		p=VSTPluginController.new(Synth(\pf));
		s.sync;
		p.open("/Library/Audio/Plug-Ins/VST/Pianoteq 5.vst");
		s.sync;
		Pbind(\type,\midi,\midiout,p.midi,\note,Pwhite(0,128,inf),\dur,Pwhite(0.01,0.9,inf),\amp,Pwhite(0.1,0.8,inf)).play;
	}.fork
)
		p.gui;
		p.set(0,1); //pedal
		p.set(0,0.1); //pedal
		p.set(36,05); //quadratic
		p.set(35,19); //duplex
		p.set(35,1); //duplex

(
	~vst=
	{
		SynthDef(\test, { |in out mix lagg|
			var sig;
			sig = VSTPlugin.ar(In.ar(in, 2), 2, id: \eq, params: [1,mix.lag(lagg)]);
			Out.ar(out, sig);
		}).add;

		(
			bus: 3,
			synth: \test,
			controller: nil,
			effect: "Verberate.vst",
			init: { |self| var buss = Bus.audio(s,2);
				self.controller=VSTPluginController(Synth(\test,[\in,buss.index,\out,0]),\eq);
				self.bus=buss;
				},
			load: {|self| self.controller.open("/Library/Audio/Plug-Ins/VST/"++self.effect)},
			test: {Synth.new(\default)},
			set:{|self args| self.controller.set(args)}
		)
	}
)

(
	{
		~verb=~vst.();
		~verb.init;
		s.sync;
		~verb.load;
		{Saw.ar(300+SinOsc.ar(0.01,70,-45),0.1)}.play(s,~verb.bus);
	}.fork
)

~verb.controller.synth.set(\lagg,10);
~verb.controller.synth.set(\mix,0.5);
~verb.controller.set(2,0.9);
~verb.controller.gui;
