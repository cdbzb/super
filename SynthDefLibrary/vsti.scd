
	SynthDef(\vsti,{|in out=0|
		var sig=VSTPlugin.ar(nil,2);
		Out.ar(out,sig)
	}).add.tag(\vst_plugin);

