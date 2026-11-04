// Ndef wrapper around the Proteus UGen (neural amp and pedal models).
//
//   AmpSim(\amp, \gtr, "JoyoExtremeMetal").play;  // makes Ndef(\gtr) if needed
//   Ndef(\gtr, { SoundIn.ar(0 ! 2) });
//   AmpSim.load(\amp, "Fender_Bassman_JC");       // swap model, same synth
//   Ndef(\amp).set(\knob, 0.7, \bypass, 1);
//
// Models live in the synth node, so any new node (a changed source, or a
// rebuild) needs AmpSim.load again.
AmpSim {
	*new { |name, input, model, numChannels = 2|
		var ndef = Ndef(name, {
			var in = input.notNil.if { Ndef(input).ar(numChannels) } { \in.ar(0 ! numChannels) };
			Proteus.ar(in, \knob.kr(0.5), name, \bypass.kr(0))
		});
		model !? { this.load(name, model) };
		^ndef
	}

	// Effect.bus for a model: returns a bus index to use as an event's out.
	//   Pbind(\instrument, \harpS, \out, AmpSim.bus("JoyoExtremeMetal")).play;
	// Frees itself after time seconds of silent input. It watches the input
	// because a model's output never quite reaches silence. Mono input comes
	// out on both channels. Make one per pattern, not one per event.
	*bus { |model, out = 0, inputChannels = 2, time = 10, knob = 0.5|
		var ugens, path = this.modelPath(model), server = Server.default;
		var effect = Effect({ |in|
			DetectSilence.ar(in.asArray.sum, time: time, doneAction: 2);
			ugens = Proteus.ar(in, knob, \amp);
			(inputChannels == 1).if { ugens ! 2 } { ugens }
		}, out, inputChannels, time: time);
		fork {
			server.sync;
			ugens.asArray.do { |ugen|
				server.sendMsg('/u_cmd', effect.synth.nodeID, ugen.synthIndex, 'load_model', path, true)
			}
		};
		^effect.bus.index
	}

	*load { |name, model, verbose = true|
		var ndef = Ndef(name), path = this.modelPath(model), server = ndef.server;
		fork {
			server.sync;
			server.latency.wait; // node proxies start their synths one latency late
			ndef.objects.do { |ctl|
				var def = ctl.synthDef, info = def.metadata[def.name.asSymbol][name.asSymbol];
				info[\index].do { |index|
					server.sendMsg('/u_cmd', ctl.nodeID, index, 'load_model', path, verbose)
				}
			}
		}
	}

	*modelDir { ^PathName(Proteus.filenameSymbol.asString).pathOnly +/+ "example_models" }

	*models {
		^PathName(this.modelDir).files
		.select { |file| file.extension == "json" }
		.collect(_.fileNameWithoutExtension)
	}

	*list { this.models.do(_.postln) }

	// a bare name means a model in modelDir
	*modelPath { |model|
		model = model.asString;
		^model.contains("/").if { model.standardizePath } { this.modelDir +/+ model.splitext[0] ++ ".json" }
	}
}
