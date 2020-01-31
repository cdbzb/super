
XiiLimiter {	
	var <>xiigui;
	
	*new { arg server, channels, setting = nil;
		^super.new.initXiiLimiter(server, channels, setting);
		}
		
	initXiiLimiter {arg server, channels, setting;
		var durSpec, params, s; 
		s = server ? Server.local;
		
		// mono
		SynthDef(\xiiLimiter1x1, {arg inbus=0,
							outbus=0, 
							level=1,
							dur = 0.01;
							
		� �var fx, sig; 
		� �sig = InFeedback.ar(inbus,1); 
		� �fx = Limiter.ar(sig, level, dur); 
		� �Out.ar(outbus, fx) 
		}).load(s); 	

		// stereo
		SynthDef(\xiiLimiter2x2, {arg inbus=0,
							outbus=0, 
							level=1,
							dur = 0.01;
							
		� �var fx, sig; 
		� �sig = InFeedback.ar(inbus, 2); 
		� �fx = Limiter.ar(sig, level, dur); 
		� �Out.ar(outbus, fx) 
		}).load(s); 	

		durSpec = ControlSpec.new(0.001, 0.1, \linear, 0.001, 0.01); 
		
		params = [ 
		� �["Level", "Dur"], 
		� �[ \level, \dur], 
		� �[ \amp, durSpec], 
		� �if(setting.notNil, {setting[5]}, {[1, 0.01]})
		]; 
		
		xiigui = if(channels == 2, { 	// stereo
			XiiEffectGUI.new("- limiter 2x2 -", \xiiLimiter2x2, params, channels, this, setting); /// 
			}, {				// mono
			XiiEffectGUI.new("- limiter 1x1 -", \xiiLimiter1x1, params, channels, this, setting); /// 
		})
	}
	start { xiigui.start }
	
	stop { xiigui.stop }

	setInBus_ {arg ch; xiigui.setInBus_(ch) }
	
	setOutBus_ {arg ch; xiigui.setOutBus_(ch) }
	
	setLoc_{arg x, y; xiigui.setLoc_(x, y) }

	setSlider_{arg slidernum=0, val=0.5; xiigui.setSlider_(slidernum, val) }

}



XiiNormalizer {	
	var <>xiigui;
	
	*new { arg server, channels, setting = nil;
		^super.new.initXiiNormalizer(server, channels, setting);
		}
		
	initXiiNormalizer {arg server, channels, setting;
		var durSpec, params, s; 
		s = server ? Server.local;
		
		// mono
		SynthDef(\xiiNormalizer1x1, {arg inbus=0,
							outbus=0, 
							level=1,
							dur = 0.01;
							
		� �var fx, sig; 
		� �sig = InFeedback.ar(inbus,1); 
		� �fx = Normalizer.ar(sig, level, dur); 
		� �Out.ar(outbus, fx) 
		}).load(s); 	

		// stereo
		SynthDef(\xiiNormalizer2x2, {arg inbus=0,
							outbus=0, 
							level=1,
							dur = 0.01;
							
		� �var fx, sig; 
		� �sig = InFeedback.ar(inbus, 2); 
		� �fx = Normalizer.ar(sig, level, dur); 
		� �Out.ar(outbus, fx) 
		}).load(s); 	

		durSpec = ControlSpec.new(0.001, 0.1, \linear, 0.001, 0.01); 
		
		params = [ 
		� �["Level", "Dur"], 
		� �[ \level, \dur], 
		� �[ \amp, durSpec], 
		� �if(setting.notNil, {setting[5]}, {[1, 0.01]})
		]; 
		
		xiigui = if(channels == 2, { 	// stereo
			XiiEffectGUI.new("- normalizer 2x2 -", \xiiNormalizer2x2, params, channels, this, setting); /// 
			}, {				// mono
			XiiEffectGUI.new("- normalizer 1x1 -", \xiiNormalizer1x1, params, channels, this, setting); /// 
		})
	}
	start { xiigui.start }
	
	stop { xiigui.stop }

	setInBus_ {arg ch; xiigui.setInBus_(ch) }
	
	setOutBus_ {arg ch; xiigui.setOutBus_(ch) }
	
	setLoc_{arg x, y; xiigui.setLoc_(x, y) }

	setSlider_{arg slidernum=0, val=0.5; xiigui.setSlider_(slidernum, val) }

}




XiiGate {	
	var <>xiigui;
	
	*new { arg server, channels, setting = nil;
		^super.new.initXiiGate(server, channels, setting);
		}
		
	initXiiGate {arg server, channels, setting;
		var gateSpec, params, s; 
		s = server ? Server.local;
		
		// mono
		SynthDef(\xiiGate1x1, {arg inbus=0,
							outbus=0,
							gate=1;
		� �var fx, sig; 
		� �sig = InFeedback.ar(inbus,1); 
		� �fx = Gate.ar(sig, gate); 
		� �Out.ar(outbus, fx) 
		}).load(s); 	

		// stereo
		SynthDef(\xiiGate2x2, {arg inbus=0,
							outbus=0,
							gate=1;
		� �var fx, sig; 
		� �sig = InFeedback.ar(inbus, 2); 
		� �fx = Gate.ar(sig, gate); 
		� �Out.ar(outbus, fx) 
		}).load(s); 	

		gateSpec = ControlSpec.new(0, 1.0, \linear, 0.0001, 1); 
		
		params = [ 
		� �["Gate"], 
		� �[ \gate], 
		� �[gateSpec], 
		� �if(setting.notNil, {setting[5]}, {[1]})
		]; 
		
		xiigui = if(channels == 2, { 	// stereo
			XiiEffectGUI.new("- gate 2x2 -", \xiiGate2x2, params, channels, this, setting); /// 
			}, {				// mono
			XiiEffectGUI.new("- gate 1x1 -", \xiiGate1x1, params, channels, this, setting); /// 
		})
	}
	start { xiigui.start }
	
	stop { xiigui.stop }

	setInBus_ {arg ch; xiigui.setInBus_(ch) }
	
	setOutBus_ {arg ch; xiigui.setOutBus_(ch) }
	
	setLoc_{arg x, y; xiigui.setLoc_(x, y) }

	setSlider_{arg slidernum=0, val=0.5; xiigui.setSlider_(slidernum, val) }

}




XiiCompressor {	
	var <>xiigui;
	
	*new { arg server, channels, setting = nil;
		^super.new.initXiiCompressor(server, channels, setting);
		}
		
	initXiiCompressor {arg server, channels, setting;
		var linearSpec, clampSpec, relaxSpec, params, s; 
		s = server ? Server.local;
		
		// mono
		SynthDef(\xiiCompressor1x1, {arg inbus=0,
							outbus=0, 
							thresh=1,
							slopeBelow=1,
							slopeAbove=0.5,
							clampTime=0.01,
							relaxTime=0.01;
							
		� �var fx, sig; 
		� �sig = InFeedback.ar(inbus,1); 
		� �fx = Compander.ar(sig, sig, thresh, slopeBelow, slopeAbove, clampTime, relaxTime); 
		� �Out.ar(outbus, fx) 
		}).load(s); 	

		// stereo
		SynthDef(\xiiCompressor2x2, {arg inbus=0,
							outbus=0, 
							thresh=1,
							slopeBelow=1,
							slopeAbove=0.5,
							clampTime=0.01,
							relaxTime=0.012;
							
		� �var fx, sig; 
		� �sig = InFeedback.ar(inbus,2); 
		� �fx = Compander.ar(sig, sig, thresh, slopeBelow, slopeAbove, clampTime, relaxTime); 
		� �Out.ar(outbus, fx) 
		}).load(s); 	

		linearSpec = ControlSpec.new(0.001, 1, \linear, 0.01, 1); 
		clampSpec = ControlSpec.new(0.002, 0.015, \lin, 0.001, 0.01); 
		relaxSpec = ControlSpec.new(0.004, 0.030, \lin, 0.001, 0.012); 
		
		params = [ 
		� �["Thresh", "SlopeBelow", "SlopeAbove", "ClampTime", "RelaxTime"], 
		� �[ \thresh, \slopeBelow, \slopeAbove, \clampTime, \relaxTime], 
		� �[linearSpec, linearSpec, linearSpec, clampSpec, relaxSpec ], 
		� �if(setting.notNil, {setting[5]}, {[1, 1, 0.5, 0.01, 0.012]})
		]; 
		
		xiigui = if(channels == 2, { 	// stereo
			XiiEffectGUI.new("- compressor 2x2 -", \xiiCompressor2x2, params, channels, this, setting); /// 
			}, {				// mono
			XiiEffectGUI.new("- compressor 1x1 -", \xiiCompressor1x1, params, channels, this, setting); /// 
		})
	}
	start { xiigui.start }
	
	stop { xiigui.stop }

	setInBus_ {arg ch; xiigui.setInBus_(ch) }
	
	setOutBus_ {arg ch; xiigui.setOutBus_(ch) }
	
	setLoc_{arg x, y; xiigui.setLoc_(x, y) }

	setSlider_{arg slidernum=0, val=0.5; xiigui.setSlider_(slidernum, val) }

}




XiiSustainer {	
	var <>xiigui;
	
	*new { arg server, channels, setting = nil;
		^super.new.initXiiSustainer(server, channels, setting);
		}
		
	initXiiSustainer {arg server, channels, setting;
		var linearSpec, clampSpec, relaxSpec, params, s; 
		s = server ? Server.local;
		
		// mono
		SynthDef(\xiiSustainer1x1, {arg inbus=0,
							outbus=0, 
							thresh=1,
							slopeBelow=0.1,
							slopeAbove=1,
							clampTime=0.01,
							relaxTime=0.01;
							
		� �var fx, sig; 
		� �sig = InFeedback.ar(inbus,1); 
		� �fx = Compander.ar(sig, sig, thresh, slopeBelow, slopeAbove, clampTime, relaxTime); 
		� �Out.ar(outbus, fx) 
		}).load(s); 	

		// stereo
		SynthDef(\xiiSustainer2x2, {arg inbus=0,
							outbus=0, 
							thresh=1,
							slopeBelow=0.1,
							slopeAbove=1,
							clampTime=0.01,
							relaxTime=0.012;
							
		� �var fx, sig; 
		� �sig = InFeedback.ar(inbus,2); 
		� �fx = Compander.ar(sig, sig, thresh, slopeBelow, slopeAbove, clampTime, relaxTime); 
		� �Out.ar(outbus, fx) 
		}).load(s); 	

		linearSpec = ControlSpec.new(0.001, 1, \linear, 0.01, 1); 
		clampSpec = ControlSpec.new(0.002, 0.015, \lin, 0.001, 0.01); 
		relaxSpec = ControlSpec.new(0.004, 0.030, \lin, 0.001, 0.012); 
		
		params = [ 
		� �["Thresh", "SlopeBelow", "SlopeAbove", "ClampTime", "RelaxTime"], 
		� �[ \thresh, \slopeBelow, \slopeAbove, \clampTime, \relaxTime], 
		� �[linearSpec, linearSpec, linearSpec, clampSpec, relaxSpec ], 
		� �if(setting.notNil, {setting[5]}, {[1, 0.1, 1, 0.01, 0.012]})
		]; 
		
		xiigui = if(channels == 2, { 	// stereo
			XiiEffectGUI.new("- sustainer 2x2 -", \xiiSustainer2x2, params, channels, this, setting); /// 
			}, {				// mono
			XiiEffectGUI.new("- sustainer 1x1 -", \xiiSustainer1x1, params, channels, this, setting); /// 
		})
	}
	start { xiigui.start }
	
	stop { xiigui.stop }

	setInBus_ {arg ch; xiigui.setInBus_(ch) }
	
	setOutBus_ {arg ch; xiigui.setOutBus_(ch) }
	
	setLoc_{arg x, y; xiigui.setLoc_(x, y) }

	setSlider_{arg slidernum=0, val=0.5; xiigui.setSlider_(slidernum, val) }

}




// lowest level (thresh) of noisegate has to be more than 0
XiiNoiseGate {	
	var <>xiigui;
	
	*new { arg server, channels, setting = nil;
		^super.new.initXiiNoiseGate(server, channels, setting);
		}
		
	initXiiNoiseGate {arg server, channels, setting;
		var linearSpec, slopeAboveSpec, clampSpec, relaxSpec, params, s; 
		s = server ? Server.local;
		
		// mono
		SynthDef(\xiiNoiseGate1x1, {arg inbus=0,
							outbus=0, 
							thresh=1,
							slopeBelow=1,
							slopeAbove=10,
							clampTime=0.01,
							relaxTime=0.01;
							
		� �var fx, sig; 
		� �sig = InFeedback.ar(inbus,1); 
		� �fx = Compander.ar(sig, sig, thresh, slopeBelow, slopeAbove, clampTime, relaxTime); 
		� �Out.ar(outbus, fx) 
		}).load(s); 	

		// stereo
		SynthDef(\xiiNoiseGate2x2, {arg inbus=0,
							outbus=0, 
							thresh=1,
							slopeBelow=1,
							slopeAbove=10,
							clampTime=0.01,
							relaxTime=0.012;
							
		� �var fx, sig; 
		� �sig = InFeedback.ar(inbus,2); 
		� �fx = Compander.ar(sig, sig, thresh, slopeBelow, slopeAbove, clampTime, relaxTime); 
		� �Out.ar(outbus, fx) 
		}).load(s); 	

		linearSpec = ControlSpec.new(0.001, 1, \linear, 0.01, 1); 
		slopeAboveSpec = ControlSpec.new(1, 20, \linear, 0.1, 10); 
		clampSpec = ControlSpec.new(0.002, 0.015, \lin, 0.001, 0.01); 
		relaxSpec = ControlSpec.new(0.004, 0.030, \lin, 0.001, 0.012); 
		
		params = [ 
		� �["Thresh", "SlopeBelow", "SlopeAbove", "ClampTime", "RelaxTime"], 
		� �[ \thresh, \slopeBelow, \slopeAbove, \clampTime, \relaxTime], 
		� �[linearSpec, linearSpec, slopeAboveSpec, clampSpec, relaxSpec ], 
		� �if(setting.notNil, {setting[5]}, {[1, 1, 10, 0.01, 0.012]})
		]; 
		
		xiigui = if(channels == 2, { 	// stereo
			XiiEffectGUI.new("- noisegate 2x2 -", \xiiNoiseGate2x2, params, channels, this, setting); /// 
			}, {				// mono
			XiiEffectGUI.new("- noisegate 1x1 -", \xiiNoiseGate1x1, params, channels, this, setting); /// 
		})
	}
	start { xiigui.start }
	
	stop { xiigui.stop }

	setInBus_ {arg ch; xiigui.setInBus_(ch) }
	
	setOutBus_ {arg ch; xiigui.setOutBus_(ch) }
	
	setLoc_{arg x, y; xiigui.setLoc_(x, y) }

	setSlider_{arg slidernum=0, val=0.5; xiigui.setSlider_(slidernum, val) }

}




// not ready yet:


XiiExpander {	
	var <>xiigui;
	
	*new { arg server, channels, setting = nil;
		^super.new.initXiiExpander(server, channels, setting);
		}
		
	initXiiExpander {arg server, channels, setting;
		var freqSpec, params, s; 
		s = server ? Server.local;
		
		// mono
		SynthDef(\xiiExpander1x1, {arg inbus=0,
							outbus=0, 
							freq=200,
							fxlevel = 0.7, 
							level=1.0;
							
		� �var fx, sig; 
		� �sig = InFeedback.ar(inbus,1); 
		� �fx = HPF.ar(sig, freq); 
		� �Out.ar(outbus, (fx * fxlevel) + (sig * level)) 
		}).load(s); 	

		// stereo
		SynthDef(\xiiExpander2x2, {arg inbus=0,
							outbus=0, 
							freq=200,
							fxlevel = 0.7, 
							level=1.0;
							
		� �var fx, sig; 
		� �sig = InFeedback.ar(inbus, 2); 
		� �fx = HPF.ar(sig, freq); 
		� �Out.ar(outbus, (fx * fxlevel) + (sig * level)) 
		}).load(s); 	

		freqSpec = ControlSpec.new(20, 20000, \exponential, 1, 2000); 
		
		params = [ 
		� �["Freq", "Fx level", "Dry Level"], 
		� �[ \freq, \fxlevel, \level], 
		� �[freqSpec, \amp, \amp], 
		� �if(setting.notNil, {setting[5]}, {[2000, 1, 0]})
		]; 
		
		xiigui = if(channels == 2, { 	// stereo
			XiiEffectGUI.new("- expander 2x2 -", \xiiExpander2x2, params, channels, this, setting); /// 
			}, {				// mono
			XiiEffectGUI.new("- expander 1x1 -", \xiiExpander1x1, params, channels, this, setting); /// 
		})
	}
	start { xiigui.start }
	
	stop { xiigui.stop }

	setInBus_ {arg ch; xiigui.setInBus_(ch) }
	
	setOutBus_ {arg ch; xiigui.setOutBus_(ch) }
	
	setLoc_{arg x, y; xiigui.setLoc_(x, y) }

	setSlider_{arg slidernum=0, val=0.5; xiigui.setSlider_(slidernum, val) }

}
