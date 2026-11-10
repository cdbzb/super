// Ndef wrapper around the Proteus UGen (neural amp and pedal models).
//
//   AmpSim(\amp, \gtr, "JoyoExtremeMetal").play;  // makes Ndef(\gtr) if needed
//   Ndef(\gtr, { SoundIn.ar(0 ! 2) });
//   AmpSim.load(\amp, "Fender_Bassman_JC");       // swap model, same synth
//   Ndef(\amp).set(\knob, 0.7, \drive, 0.25, \amp, 0.7, \bypass, 1);
//
// Chain: pre, drive, model, LeakDC, trim, amp, post. drive and amp are ratios.
// trim comes from the catalogue, so models sit near the same level. Turn it
// off with trim: false.
//
// Models live in the synth node, so any new node (a changed source, or a
// rebuild) needs AmpSim.load again.
AmpSim {
	classvar index;

	*new { |name, input, model, numChannels = 2, trim = true|
		var ndef = Ndef(name, {
			var in = input.notNil.if { Ndef(input).ar(numChannels) } { \in.ar(0 ! numChannels) };
			var bypass = \bypass.kr(0), on = 1 - bypass, knob = \knob.kr(0.5);
			var trims = [\trim0.kr(0), \trim1.kr(0), \trim2.kr(0)] * on;
			var sig = Proteus.ar(in * Select.kr(bypass, [\drive.kr(1), 1]), knob, name, bypass);
			this.prFinish(sig, knob, trims, \amp.kr(1))
		});
		model !? { this.load(name, model, trim: trim) };
		^ndef
	}

	// Effect.bus for a model: returns a bus index to use as an event's out.
	//   Pbind(\instrument, \harpS, \out, AmpSim.bus("JoyoExtremeMetal")).play;
	// Frees itself after time seconds of silent input. It watches the input
	// because a model's output never quite reaches silence. Mono input comes
	// out on both channels. Make one per pattern, not one per event.
	// pre and post are functions around the model, in the same synth:
	//   AmpSim.bus("JoyoExtremeMetal", post: { |i| FreeVerb.ar(i, 0.5, 0.9) })
	// knob, drive and amp can be UGens here; set them as controls on an Ndef.
	// Use them rather than nesting Effect.bus: nested effects run in the wrong
	// order, so the inner one hears nothing.
	// The bus is a plain Integer, dead once the synth frees itself (or MyFree
	// runs). To keep it in a score that is played more than once, use AmpSim.fx
	// (FxBus.sc), which starts a fresh synth whenever the old one is gone.
	*bus { |model, out = 0, inputChannels = 2, time = 10, knob, pre, post, drive = 1, amp = 1, trim = true|
		^this.prEffect(model, out, inputChannels, time, knob, pre, post, drive, amp, trim).bus.index
	}

	// The Effect behind *bus and *fx: starts the synth now and loads the model
	// into it once the server has it.
	*prEffect { |model, out = 0, inputChannels = 2, time = 10, knob, pre, post, drive = 1, amp = 1, trim = true|
		var effect, ugens, path = this.modelPath(model), server = Server.default;
		var trims = this.prTrims(model, trim);
		this.prWarnKnob(model, knob);
		knob = knob ? 0.5;
		effect = Effect({ |in|
			var sig;
			DetectSilence.ar(in.asArray.sum, time: time, doneAction: 2);
			ugens = Proteus.ar((pre.notNil.if { pre.value(in) } { in }) * drive, knob, \amp);
			sig = this.prFinish(ugens, knob, trims, amp);
			sig = sig.isArray.if { sig } { sig ! 2 };
			post.notNil.if { post.value(sig) } { sig }
		}, out, inputChannels, time: time);
		fork {
			server.sync;
			ugens.asArray.do { |ugen|
				server.sendMsg('/u_cmd', effect.synth.nodeID, ugen.synthIndex, 'load_model', path, true)
			}
		};
		^effect
	}

	*load { |name, model, verbose = true, trim = true|
		var ndef = Ndef(name), path = this.modelPath(model), server = ndef.server;
		var trims = this.prTrims(model, trim);
		ndef.set(\trim0, trims[0], \trim1, trims[1], \trim2, trims[2]);
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

	/* The catalogue from bin/ampsim-index, one Event per model, sorted by pack.
	   Keys: name, pack, path, kind (\amp, \pedal, \bass), knob (the model reads
	   the knob input), cab (true, false, or nil when the file name doesn't say).
	   trim is the dB at knob 0, 0.5 and 1 that levels the model for a reference
	   tone. Kind and cab are guesses from the names. */
	*index {
		^index ?? {
			index = this.indexPath.load.collect { |row|
				(
					name: row[0], pack: row[1], kind: row[2], knob: row[3], cab: row[4], trim: row[5],
					path: this.modelDir +/+ row[1] +/+ row[0] ++ ".json"
				)
			}
		}
	}

	*indexPath { ^PathName(this.filenameSymbol.asString).pathOnly +/+ "ampsim-models.scd" }

	*models { ^this.find }

	/* Names of the models that match every given filter. text is a
	   case-insensitive substring of the name.
	     AmpSim.find("ts9");
	     AmpSim.find(kind: \bass, knob: true); */
	*find { |text, kind, knob, cab|
		^this.prSelect(text, kind, knob, cab).collect { |entry| entry[\name] }
	}

	/* Posts what find returns, grouped by pack. Marks models with a knob. */
	*list { |text, kind, knob, cab|
		var pack;
		this.prSelect(text, kind, knob, cab).do { |entry|
			(entry[\pack] != pack).if {
				pack = entry[\pack];
				pack.postln
			};
			"  %%".format(entry[\name], entry[\knob].if { " (knob)" } { "" }).postln
		}
	}

	/* The catalogue Event for a model name, or nil. */
	*info { |model|
		var name = model.asString.splitext[0];
		^this.index.detect { |entry| entry[\name] == name }
	}

	/* A bare name is looked up in the catalogue. Anything with a slash is a path. */
	*modelPath { |model|
		var entry;
		model = model.asString;
		model.contains("/").if { ^model.standardizePath };
		entry = this.info(model);
		entry.isNil.if {
			Error("AmpSim: no model \"%\". Search with AmpSim.list(text).".format(model)).throw
		};
		^entry[\path]
	}

	/* What follows the model in every chain. Trim follows the knob, in dB. */
	*prFinish { |sig, knob, trims, amp|
		^LeakDC.ar(sig, 0.999) * LinSelectX.kr(knob * 2, trims).dbamp * amp
	}

	/* A model loaded by path isn't in the catalogue, so it gets no trim. */
	*prTrims { |model, trim|
		var entry = trim.if { this.info(model) };
		^entry.notNil.if { entry[\trim] } { [0, 0, 0] }
	}

	*prWarnKnob { |model, knob|
		var entry = this.info(model);
		(knob.notNil and: { entry.notNil } and: { entry[\knob].not }).if {
			"AmpSim: % has no knob input, so knob does nothing".format(model).warn
		}
	}

	*prSelect { |text, kind, knob, cab|
		^this.index.select { |entry|
			(text.isNil or: { entry[\name].containsi(text.asString) })
			and: { kind.isNil or: { entry[\kind] == kind } }
			and: { knob.isNil or: { entry[\knob] == knob } }
			and: { cab.isNil or: { entry[\cab] == cab } }
		}
	}
}
