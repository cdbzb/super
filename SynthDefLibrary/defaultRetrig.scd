
SynthDef(\defaultRetrig,{ | out=0 freq=400 amp=0.1 gate=1 t_trig=1 pan=0 curve=( -8 ),fatness=0.3 | 
			var z;
			var damper = Env.asr(0,1,0.3).kr(2,gate:gate);
			var decay = Env.perc(0.005, freq/440 => _.reciprocal * 4, curve:curve).kr(0,gate:t_trig);
			var envelope = damper * decay;
			z = LPF.ar(
				Mix.new(VarSaw.ar(freq + [0, Rand(-0.4,0.0), Rand(0.0,0.4)], 0,fatness, 0.3)),
				//XLine.kr(Rand(4000,5000), Rand(2500,3200), 1)
				Env([Rand(4000,5000),Rand(2500,3200)],1,\exp).kr(0,gate:t_trig)
			//) * Linen.kr(gate, 0.01, 0.7, 0.3, 0);
			) * envelope;
			OffsetOut.ar(out, Pan2.ar(z, pan, amp));
		}).add.tag(\keys);

SynthDef(\defaultPiano,{ | out=0 freq=400 amp=0.1 gate=1 t_trig=1 pan=0 curve=( -8 ),fatness=0.3,pedal=1 | 
			var z;
			//var damper = Env.asr(0,1,0.3).kr(2,gate:gate);
			var decay = Env.perc(0.005, freq/440 => _.reciprocal * 4, curve:curve).kr(0,gate:t_trig);
			var damper = Env.asr(0.01,  sustainLevel: 1.0,  releaseTime: 0.3,  curve: -4.0).kr(0,gate:pedal); 
			var envelope = damper * decay;
			z = LPF.ar(
				Mix.new(VarSaw.ar(freq + [0, Rand(-0.4,0.0), Rand(0.0,0.4)], 0,fatness, 0.3)),
				Env.perc(0,1).kr(0,gate:t_trig) * Rand(1000) + Rand(2500,3200)
			//) * Linen.kr(gate, 0.01, 0.7, 0.3, 0);
			) * envelope;
			OffsetOut.ar(out, Pan2.ar(z, pan, amp));
		}).add.tag(\keys);

		/*
		a=Synth(\defaultPiano,[\pedal,1])
		a.set(\t_trig,1)
		a.set(\pedal,0)
		*/
