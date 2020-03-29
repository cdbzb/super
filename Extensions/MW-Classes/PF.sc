PF {
	var <controller;
	var <synth;
	var vsti;
	var synthdef;
	var <node,<bus;
	*new{^super.new.init}
	init{
		node=NodeProxy.audio().play;
		bus=Bus.audio(numChannels:2);
		node.source={In.ar(bus.index,2)};
		//this is not the way to do this!
		synthdef=SynthDef(\vsti,{|out=0|
			var sig=VSTPlugin.ar(nil,2);
			Out.ar(out,sig)
		}).add;
		//synth=Synth(\vsti);
		//controller=VSTPluginController(Synth(\vsti,[\out,self.bus]));
		controller=VSTPluginController(Synth(\vsti,[\out,bus.index],target:RootNode(Server.default)));
		controller.open('/Library/Audio/Plug-Ins/VST/Pianoteq 5.vst',info:true);  //++self.plugin

		///setup midi monitor
		MIDIClient.init;
		MIDIIn.connectAll;
		MIDIFunc.noteOn({ |vel num| var a=controller.midi;a.noteOn(0,num,vel)});
		MIDIFunc.noteOff({ |vel num| var a=controller.midi;a.noteOff(0,num,vel)})
	}
}
