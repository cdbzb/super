
	SynthDef(\vsti,{|in out=0|
		var sig=VSTPlugin.ar(nil,2);
		Out.ar(out,sig)
	}).add.tag(\vst_plugin);

SynthDef(\vsti2,{|in |
		var sig=VSTPlugin.ar(nil,2);
		Out.ar(\out.kr(0),sig)
	}).add.tag(\vst_plugin)

