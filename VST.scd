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
s.boot;

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
(
	SynthDef(\vsti,{|in out=0|
			var sig=VSTPlugin.ar(nil,2);
			Out.ar(out,sig)
		}).add;

		//TODO generalize this - seperate into proto
		~synful=( // creates a nodeproxy playing on a private bus - .node and .bus respectively 
			bus: Bus.audio(s,2),
			controller: nil,
			node:nil,
			params:(expression:11),
			expression:{|self expression channel | self.controller.sendMidi("B0".asHexIfPossible+channel,11,expression)},
			plugin: "SynfulOrchestra.vst",
			setprog:{|self program bank channel| 

				self.controller.postln;

				self.controller.sendMidi("B0".asHexIfPossible+channel,0,bank);//set bank then
				self.controller.sendMidi("C0".asHexIfPossible+channel,program); //set program
			},
			init: { |self| //create node and controller + load plug 
				self.controller=VSTPluginController(Synth(\vsti,[\out,self.bus]));
				self.node=NodeProxy.audio(s,2).play;
				self.node.source={In.ar(self.bus.index,2)};
				{
					s.sync;
					self.controller.open("/Library/Audio/Plug-Ins/VST/"++self.plugin);
					s.sync;
					8.wait;
					self.controller.readProgram("/Users/michael/tank/super/SynfulTest.FXP");
				}.fork;
			},
			set:{|self args| self.controller.set(args)}
		);
		{
			~synful.init;
		}.fork
)

//0-4 are string secs
~synful.setprog(4,5,0); //patch bank channel
~synful.expression(40,0); //expression channel
~synful.node[1]=\filter->{|in| FreeVerb.ar(in,room:0.8,mix:0.5)*2}; //verb
(type:\midi,\midiout:~synful.controller.midi,note:[-14,-5,2,9],dur:10).play; //play a chord
(type:\midi,\midiout:~synful.controller.midi,note:[-14,-5,2,9]-2,dur:10).play;
(type:\midi,\midiout:~synful.controller.midi,note:[-14,-5,2,9]-3,dur:10).play;

p=Pbind(\type,\midi,\midiout,~synful.controller.midi,\dur,Pwhite(0.1,1.1,inf),\note,Prand([0,2,4,5,7,9,11]*[2,1].flatten,inf),\legato,Prand([1,1,1,4,0.5,0.1],inf)).play;
p.stop;

v={var sig=In.ar(~synful.bus,1);Out.ar(1,sig)}.play;
{SinOsc.ar(440,0,0.1)}.play(s,~synful.bus);
v;
v.free;
s.meter;
~synful.bus.scope;

a[1]=\filter->{|in|FreeVerb.ar(in,room:0.8,mix:0.8)};
a.source={Impulse.ar(1)};
a.stop;
a.free;


1100nnnn 0ppppppp Program change
64+128+1;

Number
