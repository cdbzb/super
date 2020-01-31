XiiBandpass {	
	var <>xiigui;
	
	*new { arg server, channels, setting = nil;
		^super.new.initXiiBandpass(server, channels, setting);
		}
		
	initXiiBandpass {arg server, channels, setting;

		var freqSpec, rqSpec, params, s; 
		
		s = server ? Server.local;
		
		// mono
		SynthDef(\xiiBPF1x1, {arg inbus=0,
							outbus=0, 
							freq=200,
							rq=0.4, 
							fxlevel = 0.7, 
							level=1.0;
							
		� �var fx, sig; 
		� �sig = InFeedback.ar(inbus,1); 
		� �fx = BPF.ar(sig, freq, rq); 
		� �Out.ar(outbus, (fx * fxlevel) + (sig * level)) 
		}).load(s); 	

		// stereo
		SynthDef(\xiiBPF2x2, {arg inbus=0,
							outbus=0, 
							freq=200,
							rq=0.4, 
							fxlevel = 0.7, 
							level=1.0;
							
		� �var fx, sig; 
		� �sig = InFeedback.ar(inbus, 2); 
		� �fx = BPF.ar(sig, freq, rq); 
		� �Out.ar(outbus, (fx * fxlevel) + (sig * level)) 
		}).load(s); 	

		freqSpec = ControlSpec.new(20, 20000, \exponential, 1, 2000); 
		rqSpec = ControlSpec.new(0.0001, 1, \exponential, 0.0001, 0.5); 
		
		
		params = [ 
		� �["Freq", "RQ", "Fx level", "Dry Level"], 
		� �[ \freq, \rq, \fxlevel, \level], 
		� �[freqSpec, rqSpec, \amp, \amp], 
		� �if(setting.notNil, {setting[5]}, {[2000, 0.5, 1, 0]})
		]; 
		
		xiigui = if(channels == 2, { 	// stereo
			XiiEffectGUI.new("- bandpass 2x2 -", \xiiBPF2x2, params, channels, this, setting); /// 
			}, {				// mono
			XiiEffectGUI.new("- bandpass 1x1 -", \xiiBPF1x1, params, channels, this, setting); /// 
		});
	}
	start { xiigui.start }
	
	stop { xiigui.stop }

	setInBus_ {arg ch; xiigui.setInBus_(ch) }
	
	setOutBus_ {arg ch; xiigui.setOutBus_(ch) }
	
	setLoc_{arg x, y; xiigui.setLoc_(x, y) }

	setSlider_{arg slidernum=0, val=0.5; xiigui.setSlider_(slidernum, val) }
	
}

XiiLowpass {	
	var <>xiigui;
	
	*new { arg server, channels, setting = nil;
		^super.new.initXiiLowpass(server, channels, setting);
		}
		
	initXiiLowpass {arg server, channels, setting;
		var freqSpec, params, s; 
		s = server ? Server.local;
		
		// mono
		SynthDef(\xiiLPF1x1, {arg inbus=0,
							outbus=0, 
							freq=200, 
							fxlevel = 0.7, 
							level=1.0;
							
		� �var fx, sig; 
		� �sig = InFeedback.ar(inbus,1); 
		� �fx = LPF.ar(sig, freq); 
		� �Out.ar(outbus, (fx * fxlevel) + (sig * level)) 
		}).load(s); 	

		// stereo
		SynthDef(\xiiLPF2x2, {arg inbus=0,
							outbus=0, 
							freq=200,
							fxlevel = 0.7, 
							level=1.0;
							
		� �var fx, sig; 
		� �sig = InFeedback.ar(inbus, 2); 
		� �fx = LPF.ar(sig, freq); 
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
			XiiEffectGUI.new("- lowpass 2x2 -", \xiiLPF2x2, params, channels, this, setting); /// 
			}, {				// mono
			XiiEffectGUI.new("- lowpass 2x2 -", \xiiLPF1x1, params, channels, this, setting); /// 
		})
	}

	start { xiigui.start }
	
	stop { xiigui.stop }

	setInBus_ {arg ch; xiigui.setInBus_(ch) }
	
	setOutBus_ {arg ch; xiigui.setOutBus_(ch) }
	
	setLoc_{arg x, y; xiigui.setLoc_(x, y) }

	setSlider_{arg slidernum=0, val=0.5; xiigui.setSlider_(slidernum, val) }

}

XiiHighpass {	
	var <>xiigui;
	
	*new { arg server, channels, setting = nil;
		^super.new.initXiiHighpass(server, channels, setting);
		}
		
	initXiiHighpass {arg server, channels, setting;
		var freqSpec, params, s; 
		s = server ? Server.local;
		
		// mono
		SynthDef(\xiiHPF1x1, {arg inbus=0,
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
		SynthDef(\xiiHPF2x2, {arg inbus=0,
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
			XiiEffectGUI.new("- highpass 2x2 -", \xiiHPF2x2, params, channels, this, setting); /// 
			}, {				// mono
			XiiEffectGUI.new("- highpass 1x1 -", \xiiHPF1x1, params, channels, this, setting); /// 
		})
	}
	start { xiigui.start }
	
	stop { xiigui.stop }

	setInBus_ {arg ch; xiigui.setInBus_(ch) }
	
	setOutBus_ {arg ch; xiigui.setOutBus_(ch) }
	
	setLoc_{arg x, y; xiigui.setLoc_(x, y) }

	setSlider_{arg slidernum=0, val=0.5; xiigui.setSlider_(slidernum, val) }

}


XiiRLowpass {	
	var <>xiigui;
	
	*new { arg server, channels, setting = nil;
		^super.new.initXiiRLowpass(server, channels, setting);
		}
		
	initXiiRLowpass {arg server, channels, setting;

		var freqSpec, rqSpec, params, s; 
		
		s = server ? Server.local;
		
		// mono
		SynthDef(\xiiRLPF1x1, {arg inbus=0,
							outbus=0, 
							freq=200,
							rq=0.4, 
							fxlevel = 0.7, 
							level=1.0;
							
		� �var fx, sig; 
		� �sig = InFeedback.ar(inbus,1); 
		� �fx = RLPF.ar(sig, freq, rq); 
		� �Out.ar(outbus, (fx * fxlevel) + (sig * level)) 
		}).load(s); 	

		// stereo
		SynthDef(\xiiRLPF2x2, {arg inbus=0,
							outbus=0, 
							freq=200,
							rq=0.4, 
							fxlevel = 0.7, 
							level=1.0;
							
		� �var fx, sig; 
		� �sig = InFeedback.ar(inbus, 2); 
		� �fx = RLPF.ar(sig, freq, rq); 
		� �Out.ar(outbus, (fx * fxlevel) + (sig * level)) 
		}).load(s); 	

		freqSpec = ControlSpec.new(20, 20000, \exponential, 1, 2000); 
		rqSpec = ControlSpec.new(0.01, 1, \exponential, 0.01, 0.5); 
		
		params = [ 
		� �["Freq", "RQ", "Fx level", "Dry Level"], 
		� �[ \freq, \rq, \fxlevel, \level], 
		� �[freqSpec, rqSpec, \amp, \amp], 
		� �if(setting.notNil, {setting[5]}, {[2000, 0.5, 1, 0]})
		]; 
		
		xiigui = if(channels == 2, { 	// stereo
			XiiEffectGUI.new("- resonant lowpass 2x2 -", \xiiRLPF2x2, params, channels, this, setting);
			}, {				// mono
			XiiEffectGUI.new("- resonant lowpass 1x1 -", \xiiRLPF1x1, params, channels, this, setting); 
		})
	}
	start { xiigui.start }
	
	stop { xiigui.stop }

	setInBus_ {arg ch; xiigui.setInBus_(ch) }
	
	setOutBus_ {arg ch; xiigui.setOutBus_(ch) }
	
	setLoc_{arg x, y; xiigui.setLoc_(x, y) }

	setSlider_{arg slidernum=0, val=0.5; xiigui.setSlider_(slidernum, val) }

}


XiiRHighpass {	
	var <>xiigui;
	
	*new { arg server, channels, setting = nil;
		^super.new.initXiiRHighpass(server, channels, setting);
		}
		
	initXiiRHighpass {arg server, channels, setting;

		var freqSpec, rqSpec, params, s; 
		
		s = server ? Server.local;
		
		// mono
		SynthDef(\xiiRHPF1x1, {arg inbus=0,
							outbus=0, 
							freq=200,
							rq=0.4, 
							fxlevel = 0.7, 
							level=1.0;
							
		� �var fx, sig; 
		� �sig = InFeedback.ar(inbus,1); 
		� �fx = RHPF.ar(sig, freq, rq); 
		� �Out.ar(outbus, (fx * fxlevel) + (sig * level)) 
		}).load(s); 	

		// stereo
		SynthDef(\xiiRHPF2x2, {arg inbus=0,
							outbus=0, 
							freq=200,
							rq=0.4, 
							fxlevel = 0.7, 
							level=1.0;
							
		� �var fx, sig; 
		� �sig = InFeedback.ar(inbus, 2); 
		� �fx = RHPF.ar(sig, freq, rq); 
		� �Out.ar(outbus, (fx * fxlevel) + (sig * level)) 
		}).load(s); 	

		freqSpec = ControlSpec.new(20, 20000, \exponential, 1, 2000); 
		rqSpec = ControlSpec.new(0.01, 1, \exponential, 0.01, 0.5); 
		
		params = [ 
		� �["Freq", "RQ", "Fx level", "Dry Level"], 
		� �[ \freq, \rq, \fxlevel, \level], 
		� �[freqSpec, rqSpec, \amp, \amp], 
		� �if(setting.notNil, {setting[5]}, {[2000, 0.5, 1, 0]})
		]; 
		
		xiigui = if(channels == 2, { 	// stereo
			XiiEffectGUI.new("- resonant highpass 2x2 -", \xiiRHPF2x2, params, channels, this, setting);
			}, {				// mono
			XiiEffectGUI.new("- resonant highpass 1x1 -", \xiiRHPF1x1, params, channels, this, setting);
		})
	}
	start { xiigui.start }
	
	stop { xiigui.stop }

	setInBus_ {arg ch; xiigui.setInBus_(ch) }
	
	setOutBus_ {arg ch; xiigui.setOutBus_(ch) }
	
	setLoc_{arg x, y; xiigui.setLoc_(x, y) }

	setSlider_{arg slidernum=0, val=0.5; xiigui.setSlider_(slidernum, val) }

}


XiiResonant {	
	var <>xiigui;
	
	*new { arg server, channels, setting = nil;
		^super.new.initXiiResonant(server, channels, setting);
		}
		
	initXiiResonant {arg server, channels, setting;

		var freqSpec, rqSpec, params, s; 
		
		s = server ? Server.local;
		
		// mono
		SynthDef(\xiiResonant1x1, {arg inbus=0,
							outbus=0, 
							freq=200,
							rq=0.4, 
							fxlevel = 0.7, 
							level=1.0;
							
		� �var fx, sig; 
		� �sig = InFeedback.ar(inbus,1); 
		� �fx = Resonz.ar(sig, freq, rq); 
		� �Out.ar(outbus, (fx * fxlevel) + (sig * level)) 
		}).load(s); 	

		// stereo
		SynthDef(\xiiResonant2x2, {arg inbus=0,
							outbus=0, 
							freq=200,
							rq=0.4, 
							fxlevel = 0.7, 
							level=1.0;
							
		� �var fx, sig; 
		� �sig = InFeedback.ar(inbus, 2); 
		� �fx = Resonz.ar(sig, freq, rq); 
		� �Out.ar(outbus, (fx * fxlevel) + (sig * level)) 
		}).load(s); 	

		freqSpec = ControlSpec.new(20, 20000, \exponential, 1, 2000); 
		rqSpec = ControlSpec.new(0.0001, 1, \exponential, 0.0001, 0.5); 
		
		params = [ 
		� �["Freq", "RQ", "Fx level", "Dry Level"], 
		� �[ \freq, \rq, \fxlevel, \level], 
		� �[freqSpec, rqSpec, \amp, \amp], 
		� �if(setting.notNil, {setting[5]}, {[2000, 0.5, 1, 0]})
		]; 
		
		xiigui = if(channels == 2, { 	// stereo
			XiiEffectGUI.new("- resonant 2x2 -", \xiiResonant2x2, params, channels, this, setting);
			}, {				// mono
			XiiEffectGUI.new("- resonant 1x1 -", \xiiResonant1x1, params, channels, this, setting);
		})
	}
	start { xiigui.start }
	
	stop { xiigui.stop }

	setInBus_ {arg ch; xiigui.setInBus_(ch) }
	
	setOutBus_ {arg ch; xiigui.setOutBus_(ch) }
	
	setLoc_{arg x, y; xiigui.setLoc_(x, y) }

	setSlider_{arg slidernum=0, val=0.5; xiigui.setSlider_(slidernum, val) }

}


XiiKlanks {	
	var <>xiigui;
	
	*new { arg server, channels, setting = nil;
		^super.new.initXiiKlanks(server, channels, setting);
		}
		
	initXiiKlanks {arg server, channels, setting;

		var freqSpec, gainSpec, ringSpec, params, s; 
		
		s = server ? Server.local;
		
		// mono
		SynthDef(\xiiKlanks1x1, {arg inbus=0,
							outbus=0, gain=0.01,
							freq1, freq2, freq3, freq4,
							amp1, amp2, amp3, amp4,
							ring1, ring2, ring3, ring4,
							fxlevel = 0.7, 
							level=0;
							
		� �var fx1, fx2, fx3, fx4, sig; 
		� �sig = InFeedback.ar(inbus, 1); 
		� �fx1 = Ringz.ar(sig*gain, freq1, ring1, amp1); 
		� �fx2 = Ringz.ar(sig*gain, freq2, ring2, amp2); 
		� �fx3 = Ringz.ar(sig*gain, freq3, ring3, amp3); 
		� �fx4 = Ringz.ar(sig*gain, freq4, ring4, amp4); 
		� �Out.ar(outbus, ((fx1+fx2+fx3+fx4) *fxlevel) + (sig * level)) 
		}).load(s); 	

		// stereo
		SynthDef(\xiiKlanks2x2, {arg inbus=0,
							outbus=0, gain=0.01,
							freq1, freq2, freq3, freq4,
							amp1, amp2, amp3, amp4,
							ring1, ring2, ring3, ring4,
							fxlevel = 0.7, 
							level=0;
							
		� �var fx1, fx2, fx3, fx4, sig; 
		� �sig = InFeedback.ar(inbus, 2); 
		� �fx1 = Ringz.ar(sig*gain, freq1, ring1, amp1); 
		� �fx2 = Ringz.ar(sig*gain, freq2, ring2, amp2); 
		� �fx3 = Ringz.ar(sig*gain, freq3, ring3, amp3); 
		� �fx4 = Ringz.ar(sig*gain, freq4, ring4, amp4); 
		� �Out.ar(outbus, ((fx1+fx2+fx3+fx4) *fxlevel) + (sig * level)) 
		}).load(s); 	

		freqSpec = ControlSpec.new(20, 20000, \exponential, 1, 2000); 
		gainSpec = ControlSpec.new(0.001, 1, \exponential, 0.001, 0.01); 
		ringSpec = ControlSpec.new(0.01, 4, \linear, 0.01, 1); 
		
		params = [ 
		� �["Gain", "Freq1", "Amp1", "Ring1", "Freq2", "Amp2", "Ring2", "Freq3", "Amp3", "Ring3", 
			"Freq4", "Amp4", "Ring4", "Fx level", "Dry Level"], 
		� �[\gain, \freq1, \amp1, \ring1, \freq2, \amp2, \ring2, \freq3, \amp3, \ring3, 
			\freq4, \amp4, \ring4, \fxlevel, \level], 
		� �[gainSpec, freqSpec, \amp, ringSpec, freqSpec, \amp, ringSpec, 
			freqSpec, \amp, ringSpec, freqSpec, \amp, ringSpec, \amp, \amp], 
		� �if(setting.notNil, {setting[5]}, 
				{[0.004, 400, 1.0, 1.0, 600, 0.8, 0.9, 800, 0.7, 1.0, 1000, 0.8, 0.6, 0.4, 0]})
		]; 
		
		xiigui = if(channels == 2, { 	// stereo
			XiiEffectGUI.new("- klanks 2x2 -", \xiiKlanks2x2, params, channels, this, setting);
			}, {				// mono
			XiiEffectGUI.new("- klanks 1x1 -", \xiiKlanks1x1, params, channels, this, setting);
		})
	}
	start { xiigui.start }
	
	stop { xiigui.stop }

	setInBus_ {arg ch; xiigui.setInBus_(ch) }
	
	setOutBus_ {arg ch; xiigui.setOutBus_(ch) }
	
	setLoc_{arg x, y; xiigui.setLoc_(x, y) }

	setSlider_{arg slidernum=0, val=0.5; xiigui.setSlider_(slidernum, val) }

}




XiiMoogVCFFF {	
	var <>xiigui;
	
	*new { arg server, channels, setting = nil;
		^super.new.initXiiResonant(server, channels, setting);
		}
		
	initXiiResonant {arg server, channels, setting;

		var freqSpec, gainSpec, params, s; 
		
		s = server ? Server.local;
		
		// mono
		SynthDef(\xiiMoogVCFFF1x1, {arg inbus=0,
							outbus=0, 
							freq=200,
							gain=1, 
							fxlevel = 0.7, 
							level=1.0;
							
		� �var fx, sig; 
		� �sig = InFeedback.ar(inbus,1); 
		� �fx = MoogFF.ar(sig, freq, gain); 
		� �Out.ar(outbus, (fx * fxlevel) + (sig * level)) 
		}).load(s); 	

		// stereo
		SynthDef(\xiiMoogVCFFF2x2, {arg inbus=0,
							outbus=0, 
							freq=200,
							gain=1, 
							fxlevel = 0.7, 
							level=1.0;
							
		� �var fx, sig; 
		� �sig = InFeedback.ar(inbus, 2); 
		� �fx = MoogFF.ar(sig, freq, gain); 
		� �Out.ar(outbus, (fx * fxlevel) + (sig * level)) 
		}).load(s); 	

		freqSpec = ControlSpec.new(20, 20000, \exponential, 1, 2000); 
		gainSpec = ControlSpec.new(0.01, 4, \linear, 0.01, 1); 
		
		params = [ 
		� �["Freq", "Gain", "Fx level", "Dry Level"], 
		� �[ \freq, \gain, \fxlevel, \level], 
		� �[freqSpec, gainSpec, \amp, \amp], 
		� �if(setting.notNil, {setting[5]}, {[2000, 1, 1, 0]})
		]; 
		
		xiigui = if(channels == 2, { 	// stereo
			XiiEffectGUI.new("- moog vcf ff 2x2 -", \xiiMoogVCFFF2x2, params, channels, this, setting);
			}, {				// mono
			XiiEffectGUI.new("- moog vcf ff 1x1 -", \xiiMoogVCFFF1x1, params, channels, this, setting);
		})
	}
	start { xiigui.start }
	
	stop { xiigui.stop }

	setInBus_ {arg ch; xiigui.setInBus_(ch) }
	
	setOutBus_ {arg ch; xiigui.setOutBus_(ch) }
	
	setLoc_{arg x, y; xiigui.setLoc_(x, y) }

	setSlider_{arg slidernum=0, val=0.5; xiigui.setSlider_(slidernum, val) }

}


XiiMoogVCF {	
	var <>xiigui;
	
	*new { arg server, channels, setting = nil;
		^super.new.initXiiResonant(server, channels, setting);
		}
		
	initXiiResonant {arg server, channels, setting;

		var freqSpec, gainSpec, params, s; 
		
		s = server ? Server.local;
		
		// mono
		SynthDef(\xiiMoogVCF1x1, {arg inbus=0,
							outbus=0, 
							freq=200,
							gain=1, 
							fxlevel = 0.7, 
							level=1.0;
							
		� �var fx, sig; 
		� �sig = InFeedback.ar(inbus,1); 
		� �fx = MoogVCF.ar(sig, freq, gain); 
		� �Out.ar(outbus, (fx * fxlevel) + (sig * level)) 
		}).load(s); 	

		// stereo
		SynthDef(\xiiMoogVCF2x2, {arg inbus=0,
							outbus=0, 
							freq=200,
							gain=1, 
							fxlevel = 0.7, 
							level=1.0;
							
		� �var fx, sig; 
		� �sig = InFeedback.ar(inbus, 2); 
		� �fx = MoogVCF.ar(sig, freq, gain); 
		� �Out.ar(outbus, (fx * fxlevel) + (sig * level)) 
		}).load(s); 	

		freqSpec = ControlSpec.new(20, 20000, \exponential, 1, 2000); 
		gainSpec = ControlSpec.new(0.01, 0.9, \linear, 0.01, 0.6); 
		
		params = [ 
		� �["Freq", "Gain", "Fx level", "Dry Level"], 
		� �[ \freq, \gain, \fxlevel, \level], 
		� �[freqSpec, gainSpec, \amp, \amp], 
		� �if(setting.notNil, {setting[5]}, {[2000, 0.9, 1, 0]})
		]; 
		
		xiigui = if(channels == 2, { 	// stereo
			XiiEffectGUI.new("- moog vcf 2x2 -", \xiiMoogVCF2x2, params, channels, this, setting);
			}, {				// mono
			XiiEffectGUI.new("- moog vcf 1x1 -", \xiiMoogVCF1x1, params, channels, this, setting);
		})
	}
	start { xiigui.start }
	
	stop { xiigui.stop }

	setInBus_ {arg ch; xiigui.setInBus_(ch) }
	
	setOutBus_ {arg ch; xiigui.setOutBus_(ch) }
	
	setLoc_{arg x, y; xiigui.setLoc_(x, y) }

	setSlider_{arg slidernum=0, val=0.5; xiigui.setSlider_(slidernum, val) }

}

XiiSpreader {	
	var <>xiigui;
	
	*new { arg server, channels, setting = nil;
		^super.new.initXiiBandpass(server, channels, setting);
		}
		
	initXiiBandpass {arg server, channels, setting;

		var thetaSpec, bpoSpec, params, s; 
		
		s = server ? Server.local;
		
		// mono
		SynthDef(\xiiSpreader1x2, {arg inbus=0,
							outbus=0, 
							theta=0, 
							bpo=8,
							fxlevel = 0.7, 
							level=0;
							
		� �var fx, sig; 
		� �sig = InFeedback.ar(inbus,1); 
		� �fx = Spreader.ar(sig, theta, bpo); 
		� �Out.ar(outbus, (fx * fxlevel) + (sig * level)) 
		}).load(s); 	

		thetaSpec = ControlSpec.new(0, pi, \lin, 0.0001, 0); 
		bpoSpec = ControlSpec.new(2, 20, \linear, 1, 8); 
		
		
		params = [ 
		� �["BPO", "theta", "Fx level", "Dry Level"], 
		� �[ \bpo, \theta, \fxlevel, \level], 
		� �[bpoSpec, thetaSpec, \amp, \amp], 
		� �if(setting.notNil, {setting[5]}, {[8, 0, 1, 0]})
		]; 
	
		// spreader is special: unlike other effects, input is mono and output is stereo
		// I therefore added a one2two arg to XiiEffectsGUI and hardcode 1 in channels
		xiigui = XiiEffectGUI.new("- spreader 1x2 -", \xiiSpreader1x2, params, 1, this, setting, true); 
		
	}
	
	start { xiigui.start }
	
	stop { xiigui.stop }

	setInBus_ {arg ch; xiigui.setInBus_(ch) }
	
	setOutBus_ {arg ch; xiigui.setOutBus_(ch) }
	
	setLoc_{arg x, y; xiigui.setLoc_(x, y) }

	setSlider_{arg slidernum=0, val=0.5; xiigui.setSlider_(slidernum, val) }
	
}


XiiRMShelf {	
	var <>xiigui;
	
	*new { arg server, channels, setting = nil;
		^super.new.initXiiBandpass(server, channels, setting);
		}
		
	initXiiBandpass {arg server, channels, setting;

		var freqSpec, params, s; 
		
		s = server ? Server.local;
		
		// mono
		SynthDef(\xiiRMShelf1x1, {arg inbus=0,
							outbus=0, 
							freq=200,
							k=0.4, 
							fxlevel = 0.7, 
							level=1.0;
							
		� �var fx, sig; 
		� �sig = InFeedback.ar(inbus,1); 
		� �fx = RMShelf.ar(sig, freq, k); 
		� �Out.ar(outbus, (fx * fxlevel) + (sig * level)) 
		}).load(s); 	

		// stereo
		SynthDef(\xiiRMShelf2x2, {arg inbus=0,
							outbus=0, 
							freq=200,
							k=0.4, 
							fxlevel = 0.7, 
							level=1.0;
							
		� �var fx, sig; 
		� �sig = InFeedback.ar(inbus, 2); 
		� �fx = RMShelf.ar(sig, freq, k); 
		� �Out.ar(outbus, (fx * fxlevel) + (sig * level)) 
		}).load(s); 	

		freqSpec = ControlSpec.new(20, 20000, \exponential, 1, 2000);
		
		params = [ 
		� �["Freq", "K", "Fx level", "Dry Level"], 
		� �[ \freq, \k, \fxlevel, \level], 
		� �[freqSpec, \unipolar, \amp, \amp], 
		� �if(setting.notNil, {setting[5]}, {[2000, 0.5, 1, 0]})
		]; 
		
		xiigui = if(channels == 2, { 	// stereo
			XiiEffectGUI.new("- rmshelf 2x2 -", \xiiRMShelf2x2, params, channels, this, setting); /// 
			}, {				// mono
			XiiEffectGUI.new("- rmshelf 1x1 -", \xiiRMShelf1x1, params, channels, this, setting); /// 
		});
	}
	start { xiigui.start }
	
	stop { xiigui.stop }

	setInBus_ {arg ch; xiigui.setInBus_(ch) }
	
	setOutBus_ {arg ch; xiigui.setOutBus_(ch) }
	
	setLoc_{arg x, y; xiigui.setLoc_(x, y) }

	setSlider_{arg slidernum=0, val=0.5; xiigui.setSlider_(slidernum, val) }
	
}


XiiRMEQ {	
	var <>xiigui;
	
	*new { arg server, channels, setting = nil;
		^super.new.initXiiBandpass(server, channels, setting);
		}
		
	initXiiBandpass {arg server, channels, setting;

		var freqSpec, rqSpec, params, s; 
		
		s = server ? Server.local;
		
		// mono
		SynthDef(\xiiRMEQ1x1, {arg inbus=0,
							outbus=0, 
							freq=200,
							rq=0.4, 
							k = 0, 
							fxlevel = 0.7, 
							level=1.0;
							
		� �var fx, sig; 
		� �sig = InFeedback.ar(inbus,1); 
		� �fx = RMEQ.ar(sig, freq, rq, k); 
		� �Out.ar(outbus, (fx * fxlevel) + (sig * level)) 
		}).load(s); 	

		// stereo
		SynthDef(\xiiRMEQ2x2, {arg inbus=0,
							outbus=0, 
							freq=200,
							rq=0.4,
							k = 0, 
							fxlevel = 0.7, 
							level=1.0;
							
		� �var fx, sig; 
		� �sig = InFeedback.ar(inbus, 2); 
		� �fx = RMEQ.ar(sig, freq, rq, k); 
		� �Out.ar(outbus, (fx * fxlevel) + (sig * level)) 
		}).load(s); 	

		freqSpec = ControlSpec.new(200, 22000, \exponential, 1, 2000); 
		rqSpec = ControlSpec.new(0.0001, 1, \linear, 0.0001, 0.5); 
		
		
		params = [ 
		� �["Freq", "RQ", "K", "Fx level", "Dry Level"], 
		� �[ \freq, \rq, \k, \fxlevel, \level], 
		� �[freqSpec, rqSpec, \unipolar, \amp, \amp], 
		� �if(setting.notNil, {setting[5]}, {[2000, 0.5, 0, 1, 0]})
		]; 
		
		xiigui = if(channels == 2, { 	// stereo
			XiiEffectGUI.new("- rmeq 2x2 -", \xiiRMEQ2x2, params, channels, this, setting); /// 
			}, {				// mono
			XiiEffectGUI.new("- rmeq 1x1 -", \xiiRMEQ1x1, params, channels, this, setting); /// 
		});
	}
	start { xiigui.start }
	
	stop { xiigui.stop }

	setInBus_ {arg ch; xiigui.setInBus_(ch) }
	
	setOutBus_ {arg ch; xiigui.setOutBus_(ch) }
	
	setLoc_{arg x, y; xiigui.setLoc_(x, y) }

	setSlider_{arg slidernum=0, val=0.5; xiigui.setSlider_(slidernum, val) }
	
}


XiiBPeakEQ {	
	var <>xiigui;
	
	*new { arg server, channels, setting = nil;
		^super.new.initXiiBandpass(server, channels, setting);
		}
		
	initXiiBandpass {arg server, channels, setting;

		var freqSpec, rqSpec, dbSpec, params, s; 
		
		s = server ? Server.local;
		
		// mono
		SynthDef(\xiiBPeakEQ1x1, {arg inbus=0,
							outbus=0, 
							freq=200,
							rq=0.4, 
							db = 12, 
							fxlevel = 0.7, 
							level=1.0;
							
		� �var fx, sig; 
		� �sig = InFeedback.ar(inbus,1); 
		� �fx = BPeakEQ.ar(sig, freq, rq, db); 
		� �Out.ar(outbus, (fx * fxlevel) + (sig * level)) 
		}).load(s); 	

		// stereo
		SynthDef(\xiiBPeakEQ2x2, {arg inbus=0,
							outbus=0, 
							freq=200,
							rq=0.4,
							db = 12, 
							fxlevel = 0.7, 
							level=1.0;
							
		� �var fx, sig; 
		� �sig = InFeedback.ar(inbus, 2); 
		� �fx = BPeakEQ.ar(sig, freq, rq, db); 
		� �Out.ar(outbus, (fx * fxlevel) + (sig * level)) 
		}).load(s); 	

		freqSpec = ControlSpec.new(200, 22000, \exponential, 1, 2000); 
		rqSpec = ControlSpec.new(0.0001, 1, \linear, 0.0001, 0.5); 
		dbSpec = ControlSpec.new(-36, 36, \linear, 1, 12); 
		
		
		params = [ 
		� �["Freq", "RQ", "dB", "Fx level", "Dry Level"], 
		� �[ \freq, \rq, \db, \fxlevel, \level], 
		� �[freqSpec, rqSpec, dbSpec, \amp, \amp], 
		� �if(setting.notNil, {setting[5]}, {[2000, 0.5, 12, 1, 0]})
		]; 
		
		xiigui = if(channels == 2, { 	// stereo
			XiiEffectGUI.new("- bpeakeq 2x2 -", \xiiBPeakEQ2x2, params, channels, this, setting); /// 
			}, {				// mono
			XiiEffectGUI.new("- bpeakeq 1x1 -", \xiiBPeakEQ1x1, params, channels, this, setting); /// 
		});
	}
	start { xiigui.start }
	
	stop { xiigui.stop }

	setInBus_ {arg ch; xiigui.setInBus_(ch) }
	
	setOutBus_ {arg ch; xiigui.setOutBus_(ch) }
	
	setLoc_{arg x, y; xiigui.setLoc_(x, y) }

	setSlider_{arg slidernum=0, val=0.5; xiigui.setSlider_(slidernum, val) }
	
}



XiiBBandStop {	
	var <>xiigui;
	
	*new { arg server, channels, setting = nil;
		^super.new.initXiiBandpass(server, channels, setting);
		}
		
	initXiiBandpass {arg server, channels, setting;

		var freqSpec, rqSpec, bwSpec, params, s; 
		
		s = server ? Server.local;
		
		// mono
		SynthDef(\xiiBBandStop1x1, {arg inbus=0,
							outbus=0, 
							freq=200,
							bw = 12, 
							fxlevel = 0.7, 
							level=1.0;
							
		� �var fx, sig; 
		� �sig = InFeedback.ar(inbus,1); 
		� �fx = BBandStop.ar(sig, freq, bw); 
		� �Out.ar(outbus, (fx * fxlevel) + (sig * level)) 
		}).load(s); 	

		// stereo
		SynthDef(\xiiBBandStop2x2, {arg inbus=0,
							outbus=0, 
							freq=200,
							bw = 12, 
							fxlevel = 0.7, 
							level=1.0;
							
		� �var fx, sig; 
		� �sig = InFeedback.ar(inbus, 2); 
		� �fx = BBandStop.ar(sig, freq, bw); 
		� �Out.ar(outbus, (fx * fxlevel) + (sig * level)) 
		}).load(s); 	

		freqSpec = ControlSpec.new(200, 22000, \exponential, 1, 2000); 
		rqSpec = ControlSpec.new(0.0001, 1, \linear, 0.0001, 0.5); 
		bwSpec = ControlSpec.new(0.0001, 12, \linear, 0.001, 1); 
		
		
		params = [ 
		� �["Freq", "bw (dB)", "Fx level", "Dry Level"], 
		� �[ \freq, \bw, \fxlevel, \level], 
		� �[freqSpec, bwSpec, \amp, \amp], 
		� �if(setting.notNil, {setting[5]}, {[2000, 12, 1, 0]})
		]; 
		
		xiigui = if(channels == 2, { 	// stereo
			XiiEffectGUI.new("- bbandstop 2x2 -", \xiiBBandStop2x2, params, channels, this, setting); /// 
			}, {				// mono
			XiiEffectGUI.new("- bbandstop 1x1 -", \xiiBBandStop1x1, params, channels, this, setting); /// 
		});
	}
	start { xiigui.start }
	
	stop { xiigui.stop }

	setInBus_ {arg ch; xiigui.setInBus_(ch) }
	
	setOutBus_ {arg ch; xiigui.setOutBus_(ch) }
	
	setLoc_{arg x, y; xiigui.setLoc_(x, y) }

	setSlider_{arg slidernum=0, val=0.5; xiigui.setSlider_(slidernum, val) }
	
}




XiiBBandPass {	
	var <>xiigui;
	
	*new { arg server, channels, setting = nil;
		^super.new.initXiiBandpass(server, channels, setting);
		}
		
	initXiiBandpass {arg server, channels, setting;

		var freqSpec, rqSpec, bwSpec, params, s; 
		
		s = server ? Server.local;
		
		// mono
		SynthDef(\xiiBBandPass1x1, {arg inbus=0,
							outbus=0, 
							freq=200,
							bw = 12, 
							fxlevel = 0.7, 
							level=1.0;
							
		� �var fx, sig; 
		� �sig = InFeedback.ar(inbus,1); 
		� �fx = BBandPass.ar(sig, freq, bw); 
		� �Out.ar(outbus, (fx * fxlevel) + (sig * level)) 
		}).load(s); 	

		// stereo
		SynthDef(\xiiBBandPass2x2, {arg inbus=0,
							outbus=0, 
							freq=200,
							bw = 12, 
							fxlevel = 0.7, 
							level=1.0;
							
		� �var fx, sig; 
		� �sig = InFeedback.ar(inbus, 2); 
		� �fx = BBandPass.ar(sig, freq, bw); 
		� �Out.ar(outbus, (fx * fxlevel) + (sig * level)) 
		}).load(s); 	

		freqSpec = ControlSpec.new(200, 22000, \exponential, 1, 2000); 
		rqSpec = ControlSpec.new(0.0001, 1, \linear, 0.0001, 0.5); 
		bwSpec = ControlSpec.new(0.0001, 12, \linear, 0.001, 1); 
		
		
		params = [ 
		� �["Freq", "bw (dB)", "Fx level", "Dry Level"], 
		� �[ \freq, \bw, \fxlevel, \level], 
		� �[freqSpec, bwSpec, \amp, \amp], 
		� �if(setting.notNil, {setting[5]}, {[2000, 12, 1, 0]})
		]; 
		
		xiigui = if(channels == 2, { 	// stereo
			XiiEffectGUI.new("- bbandpass 2x2 -", \xiiBBandPass2x2, params, channels, this, setting); /// 
			}, {				// mono
			XiiEffectGUI.new("- bbandpass 1x1 -", \xiiBBandPass1x1, params, channels, this, setting); /// 
		});
	}
	start { xiigui.start }
	
	stop { xiigui.stop }

	setInBus_ {arg ch; xiigui.setInBus_(ch) }
	
	setOutBus_ {arg ch; xiigui.setOutBus_(ch) }
	
	setLoc_{arg x, y; xiigui.setLoc_(x, y) }

	setSlider_{arg slidernum=0, val=0.5; xiigui.setSlider_(slidernum, val) }
	
}




XiiBLowShelf {	
	var <>xiigui;
	
	*new { arg server, channels, setting = nil;
		^super.new.initXiiBandpass(server, channels, setting);
		}
		
	initXiiBandpass {arg server, channels, setting;

		var freqSpec, rsSpec, dbSpec, params, s; 
		
		s = server ? Server.local;
		
		// mono
		SynthDef(\xiiBLowShelf1x1, {arg inbus=0,
							outbus=0, 
							freq=200,
							rs=0.4, 
							db = 12, 
							fxlevel = 0.7, 
							level=1.0;
							
		� �var fx, sig; 
		� �sig = InFeedback.ar(inbus,1); 
		� �fx = BLowShelf.ar(sig, freq, rs, db); 
		� �Out.ar(outbus, (fx * fxlevel) + (sig * level)) 
		}).load(s); 	

		// stereo
		SynthDef(\xiiBLowShelf2x2, {arg inbus=0,
							outbus=0, 
							freq=200,
							rs=0.4,
							db = 12, 
							fxlevel = 0.7, 
							level=1.0;
							
		� �var fx, sig; 
		� �sig = InFeedback.ar(inbus, 2); 
		� �fx = BLowShelf.ar(sig, freq, rs, db); 
		� �Out.ar(outbus, (fx * fxlevel) + (sig * level)) 
		}).load(s); 	

		freqSpec = ControlSpec.new(200, 22000, \exponential, 1, 2000); 
		rsSpec = ControlSpec.new(0.25, 1, \linear, 0.0001, 0.5); 
		dbSpec = ControlSpec.new(-12, 12, \linear, 1, 12); 
		
		
		params = [ 
		� �["Freq", "RS", "dB", "Fx level", "Dry Level"], 
		� �[ \freq, \rs, \db, \fxlevel, \level], 
		� �[freqSpec, rsSpec, dbSpec, \amp, \amp], 
		� �if(setting.notNil, {setting[5]}, {[2000, 0.5, 12, 1, 0]})
		]; 
		
		xiigui = if(channels == 2, { 	// stereo
			XiiEffectGUI.new("- blowshelf 2x2 -", \xiiBLowShelf2x2, params, channels, this, setting); /// 
			}, {				// mono
			XiiEffectGUI.new("- blowshelf 1x1 -", \xiiBLowShelf1x1, params, channels, this, setting); /// 
		});
	}
	start { xiigui.start }
	
	stop { xiigui.stop }

	setInBus_ {arg ch; xiigui.setInBus_(ch) }
	
	setOutBus_ {arg ch; xiigui.setOutBus_(ch) }
	
	setLoc_{arg x, y; xiigui.setLoc_(x, y) }

	setSlider_{arg slidernum=0, val=0.5; xiigui.setSlider_(slidernum, val) }
	
}



XiiBHiShelf {	
	var <>xiigui;
	
	*new { arg server, channels, setting = nil;
		^super.new.initXiiBandpass(server, channels, setting);
		}
		
	initXiiBandpass {arg server, channels, setting;

		var freqSpec, rsSpec, dbSpec, params, s; 
		
		s = server ? Server.local;
		
		// mono
		SynthDef(\xiiBHiShelf1x1, {arg inbus=0,
							outbus=0, 
							freq=200,
							rs=0.4, 
							db = 12, 
							fxlevel = 0.7, 
							level=1.0;
							
		� �var fx, sig; 
		� �sig = InFeedback.ar(inbus,1); 
		� �fx = BHiShelf.ar(sig, freq, rs, db); 
		� �Out.ar(outbus, (fx * fxlevel) + (sig * level)) 
		}).load(s); 	

		// stereo
		SynthDef(\xiiBHiShelf2x2, {arg inbus=0,
							outbus=0, 
							freq=200,
							rs=0.4,
							db = 12, 
							fxlevel = 0.7, 
							level=1.0;
							
		� �var fx, sig; 
		� �sig = InFeedback.ar(inbus, 2); 
		� �fx = BHiShelf.ar(sig, freq, rs, db); 
		� �Out.ar(outbus, (fx * fxlevel) + (sig * level)) 
		}).load(s); 	

		freqSpec = ControlSpec.new(200, 22000, \exponential, 1, 2000); 
		rsSpec = ControlSpec.new(0.25, 1, \linear, 0.0001, 0.5); 
		dbSpec = ControlSpec.new(-12, 12, \linear, 1, 12); 
		
		
		params = [ 
		� �["Freq", "RS", "dB", "Fx level", "Dry Level"], 
		� �[ \freq, \rs, \db, \fxlevel, \level], 
		� �[freqSpec, rsSpec, dbSpec, \amp, \amp], 
		� �if(setting.notNil, {setting[5]}, {[2000, 0.5, 12, 1, 0]})
		]; 
		
		xiigui = if(channels == 2, { 	// stereo
			XiiEffectGUI.new("- bhishelf 2x2 -", \xiiBHiShelf2x2, params, channels, this, setting); /// 
			}, {				// mono
			XiiEffectGUI.new("- bhishelf 1x1 -", \xiiBHiShelf1x1, params, channels, this, setting); /// 
		});
	}
	start { xiigui.start }
	
	stop { xiigui.stop }

	setInBus_ {arg ch; xiigui.setInBus_(ch) }
	
	setOutBus_ {arg ch; xiigui.setOutBus_(ch) }
	
	setLoc_{arg x, y; xiigui.setLoc_(x, y) }

	setSlider_{arg slidernum=0, val=0.5; xiigui.setSlider_(slidernum, val) }
	
}





//////////// crazy filters


///////////////////// experimental - not working right now

XiiResonzOsc {	
	var <>xiigui;
	
	*new { arg server, channels, setting = nil;
		^super.new.initXiiResonant(server, channels, setting);
		}
		
	initXiiResonant {arg server, channels, setting;

		var freqSpec, rqSpec, rq2Spec, params, s; 
		
		s = server ? Server.local;
		
		// mono
		SynthDef(\xiiResonzOsc1x1, {arg inbus=0,
							outbus=0, 
							ffreq=200,
							ffreq2=200,
							rq=1,
							rq2=2,
							gain=1, 
							fxlevel = 0.7, 
							level=1.0;
							
		� �var fx, sig; 
		� �sig = InFeedback.ar(inbus,1); 
		
		fx = Resonz.ar(sig, ffreq, SinOsc.kr(rq).range(0.2, 0.8));
		fx = Resonz.ar(fx, SinOsc.kr(ffreq2), SinOsc.ar(rq2).range(20,8000));

		� �Out.ar(outbus, (fx * fxlevel) + (sig * level)) 
		}).load(s); 	

		// stereo
		SynthDef(\xiiResonzOsc2x2, {arg inbus=0,
							outbus=0, 
							ffreq=200,
							ffreq2=200,
							rq=1,
							rq2=2,
							gain=1, 
							fxlevel = 0.7, 
							level=1.0;
							
		� �var fx, sig; 
		� �sig = InFeedback.ar(inbus,2); 
		
		fx = Resonz.ar(sig, ffreq, SinOsc.kr(rq).range(0.2, 0.8));
		fx = Resonz.ar(fx, SinOsc.kr(ffreq2), SinOsc.ar(rq2).range(20,8000));
		� �Out.ar(outbus, (fx * fxlevel) + (sig * level)) 
		}).load(s); 	

		freqSpec = ControlSpec.new(20, 20000, \exponential, 1, 2000); 
		rqSpec = ControlSpec.new(20, 20000, \exponential, 1, 2000); 
		rq2Spec = ControlSpec.new(1, 20, \exponential, 1, 1); 
		
		params = [ 
		� �["Freq", "rQ", "FFreq", "rQ2", "Fx level", "Dry Level"], 
		� �[ \freq, \rq, \ffreq, \rq2, \fxlevel, \level], 
		� �[freqSpec, rqSpec, freqSpec, rq2Spec,\amp, \amp], 
		� �if(setting.notNil, {setting[5]}, {[2000, 2000, 2000, 2000, 1, 0]})
		]; 
		
		xiigui = if(channels == 2, { 	// stereo
			XiiEffectGUI.new("- resonzosc 2x2 -", \xiiResonzOsc2x2, params, channels, this, setting);
			}, {				// mono
			XiiEffectGUI.new("- resonzosc 1x1 -", \xiiResonzOsc1x1, params, channels, this, setting);
		})
	}
	start { xiigui.start }
	
	stop { xiigui.stop }

	setInBus_ {arg ch; xiigui.setInBus_(ch) }
	
	setOutBus_ {arg ch; xiigui.setOutBus_(ch) }
	
	setLoc_{arg x, y; xiigui.setLoc_(x, y) }

	setSlider_{arg slidernum=0, val=0.5; xiigui.setSlider_(slidernum, val) }

}

