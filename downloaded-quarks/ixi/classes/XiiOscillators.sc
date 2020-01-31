
XiiNoise {	

	var <>xiigui; // TESTING: TEMP can delete
	
	*new { arg server, channels, setting = nil;
		^super.new.initXiiNoise(server, channels, setting);
		}
		
	initXiiNoise {arg server, channels, setting;

		var freqSpec, crackleSpec, params, s; 
		
		s = server ? Server.local;
		
		// mono
		SynthDef(\xiiNoise1x1, {arg inbus=0,
							outbus=0,
							amp1, amp2, amp3, amp4, amp5,
							level=0;

		� �var white, brown, pink, gray, crackle; 
		   white = WhiteNoise.ar(amp1);
		   pink = PinkNoise.ar(amp2);
		   brown = BrownNoise.ar(amp3);
		   gray = GrayNoise.ar(amp4);
		   crackle = Crackle.ar(amp5+1, amp5);
		� �Out.ar(outbus, (white+brown+pink+gray+crackle)*level) 
		}).load(s); 	

		// stereo
		SynthDef(\xiiNoise2x2, {arg inbus=0,
							outbus=0,
							amp1, amp2, amp3, amp4, amp5,
							level=0;

		� �var white, brown, pink, gray, crackle; 
		   white = WhiteNoise.ar(amp1);
		   pink = PinkNoise.ar(amp2);
		   brown = BrownNoise.ar(amp3);
		   gray = GrayNoise.ar(amp4);
		   crackle = Crackle.ar(amp5+1, amp5);
		� �Out.ar(outbus, ((white+brown+pink+gray+crackle)*level).dup) 
		}).load(s); 	

		//freqSpec = ControlSpec.new(20, 20000, \exponential, 1, 2000); 
		//crackleSpec = ControlSpec.new(0.001, 1, \exponential, 0.001, 0.01); 
		
		params = [ 
		� �["White", "Pink", "Brown", "Gray", "Crackle", "Level"], 
		� �[\amp1, \amp2, \amp3, \amp4, \amp5, \level], 
		� �[\amp, \amp, \amp, \amp, \amp, \amp], 
		� �if(setting.isNil.not, {setting[5]}, {[0, 0, 0, 0, 0, 1]})
		]; 
		
		xiigui = if(channels == 2, { 	// stereo
			XiiEffectGUI.new("- noise 2x2 -", \xiiNoise2x2, params, channels, this, setting);
			}, {				// mono
			XiiEffectGUI.new("- noise 1x1 -", \xiiNoise1x1, params, channels, this, setting);
		})
	}
}


XiiOscillators {	

	var <>xiigui;
	
	*new { arg server, channels, setting = nil;
		^super.new.initXiiOscillators(server, channels, setting);
		}
		
	initXiiOscillators {arg server, channels, setting;

		var freqSpec, freqSpec2, linearSpec, params, s; 
		
		s = server ? Server.local;
		
		// mono
		SynthDef(\xiiOscillators1x1, {arg inbus=0,
							outbus=0,
							freq1, freq2, freq3, freq4, freq5,
							amp1, amp2, amp3, amp4, amp5,
							freqwidth4, formfreq5, widthfreq5,
							level=1;

		� �var sine, saw, tri, pulse, formant; 
		   sine = SinOsc.ar(freq1, 0, amp1);
		   saw = Saw.ar(freq2, amp2);
		   tri = LFTri.ar(freq3, 0, amp3);
		   pulse = Pulse.ar(freq4, freqwidth4, amp4);
		   formant = Formant.ar(freq5, formfreq5, widthfreq5, amp5);
		� �Out.ar(outbus, (sine+saw+tri+pulse+formant)*level) 
		}).load(s); 	

		// stereo
		SynthDef(\xiiOscillators2x2, {arg inbus=0,
							outbus=0,
							freq1, freq2, freq3, freq4, freq5,
							amp1, amp2, amp3, amp4, amp5,
							freqwidth4, formfreq5, widthfreq5,
							level=1;

		� �var sine, saw, tri, pulse, formant; 
		   sine = SinOsc.ar(freq1, 0, amp1);
		   saw = Saw.ar(freq2, amp2);
		   tri = LFTri.ar(freq3, 0, amp3);
		   pulse = Pulse.ar(freq4, freqwidth4, amp4);
		   formant = Formant.ar(freq5, formfreq5, widthfreq5, amp5);
		� �Out.ar(outbus, ((sine+saw+tri+pulse+formant)*level).dup) 
		}).load(s); 	

		freqSpec = ControlSpec.new(20, 20000, \exponential, 1, 200); 
		freqSpec2 = ControlSpec.new(2, 20000, \exponential, 1, 20); 
		linearSpec = ControlSpec.new(0.001, 0.999, \linear, 0.001, 0.5); 
		
		params = [ 
		� �["SineFreq","SineAmp", "SawFreq","SawAmp", "TriFreq","TriAmp", 
			"PulseFreq","PulseWidth","PulseAmp", "FrmntFreq","FormFreq","FWidthFreq", 		"FrmntAmp", "Level"], 
		� �[\freq1, \amp1, \freq2, \amp2, \freq3, \amp3, \freq4, \freqwidth4, \amp4,
			\freq5, \formfreq5, \widthfreq5, \amp5, \level], // synth arg parameter
		� �[freqSpec, \amp, freqSpec, \amp, freqSpec, \amp, freqSpec, linearSpec, \amp, 
			freqSpec, freqSpec2, freqSpec2, \amp, \amp], 
		� �if(setting.isNil.not, {setting[5]}, {[200, 0, 200, 0, 200, 0, 200, 0.5, 0, 
			200, 100, 20, 0, 1]})
		]; 
		
		xiigui = if(channels == 2, { 	// stereo
			XiiEffectGUI.new("- oscillators 2x2 -", \xiiOscillators2x2, params, channels, this, setting);
			}, {				// mono
			XiiEffectGUI.new("- oscillators 1x1 -", \xiiOscillators1x1, params, channels, this, setting);
		})
	}
}


