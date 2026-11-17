	Effect { //|function out=0| // node proxy version 
		var <>numChannels,<>bus,<>node, <>sidechain, <>synth;
		/* Narrow buses. The input bus is sized by the function's OUTPUT count, so a
		   mono-output effect gets a 1-channel bus: a stereo writer (most voices,
		   a panned \audioItem) puts its channel 1 on bus.index + 1 — the next
		   bus, often another Effect's input — and an inputChannels wider than the
		   output reads past its own bus the same way.
		     wideBuses  true: such a bus is max(inputChannels, outputs, 2) wide, so
		                nothing spills; the function still reads inputChannels
		                (channel 0 of a stereo writer), so the effect itself
		                sounds the same — only the leak into the neighbour stops
		     logNarrow  true: post each narrow Effect once (its source) and count
		                it; Effect.narrowReport lists them, Effect.clearNarrowLog
		                resets — play a piece through to see what wideBuses changes
		   Both default false: unchanged behaviour until a piece has been checked. */
		classvar <>wideBuses = false, <>logNarrow = false, <narrowLog;
		
		*newOld { |function out=0 inputChannels=1|
			^super.new.init(function , out,inputChannels);
		}
		// detectOutput: false skips the output DetectSilence — for a function that
		// watches its own input instead (AmpSim: a model's output blips at load and
		// never quite settles, so the output check freed an idle one after `time`).
		// busChannels: a minimum input-bus width, whatever the output (AmpSim passes
		// max(inputChannels, 2) so a mono model never spills a stereo writer).
		*new { |function out=0 inputChannels=1 target time=1 maxDur release=3 detectOutput=true busChannels|
			^super.new.init(function , out,inputChannels, target, time, maxDur, release, detectOutput, busChannels);
		}
		*newSidechain {|function out=0 inputChannels=1| ^super.new.initSidechain(function,out,inputChannels) }

		*new2 {|function out=0 inputChannels=1| ^super.new.init(function,out,inputChannels)}
		*lfo {|function inputChannels=1 dur| ^super.new.initLfo(function,inputChannels,dur)}
		// A plain Integer, dead once the synth frees itself. Effect.fx (FxBus.sc)
		// is the replayable form.
		*bus {|function out=0 inputChannels=1 target time=1 maxDur release=3| ^this.new(function , out,inputChannels, target, time, maxDur, release).bus.index}
		*kbus {|function inputChannels=1 dur| ^super.new.initLfo(function,inputChannels,dur).bus.index}

		// ---- narrow-bus log (see wideBuses / logNarrow above)
		// The input bus width for an Effect reading `inputChannels` and writing
		// `outputs`: the output count, unless wideBuses widens a narrow one.
		// Logs narrow ones when logNarrow. Pure (no server).
		*busChannels { |function, inputChannels = 1, outputs = 1|
			var narrow = (outputs < 2) or: { inputChannels > outputs };
			narrow.not.if { ^outputs };
			logNarrow.if { this.prLogNarrow(function, inputChannels, outputs) };
			^this.wide.if { [inputChannels, outputs, 2].maxItem } { outputs }
		}
		// whether this class widens a narrow bus; EffectNarrow never does
		*wide { ^wideBuses }
		*prLogNarrow { |function, inputChannels, outputs|
			var key = (function.tryPerform(\def) !? { |d| d.sourceCode } ?? { function.asString })
				.asString.collect { |c| c.isSpace.if($ , c) }.split($ ).reject(_.isEmpty).join(" ");
			var entry;
			narrowLog = narrowLog ?? { Dictionary.new };
			entry = narrowLog[key];
			entry.isNil.if {
				narrowLog[key] = (count: 1, in: inputChannels, out: outputs);
				"Effect narrow bus (in %, out %%): %".format(inputChannels, outputs,
					(inputChannels > outputs).if(", reads past its bus", ""), key.keep(100)).postln;
			} {
				entry[\count] = entry[\count] + 1
			}
		}
		*narrowReport {
			(narrowLog ? ()).isEmpty.if { ^"Effect.narrowReport: nothing logged (set Effect.logNarrow = true and play)".postln };
			narrowLog.asSortedArray.sort { |a, b| a[1][\count] > b[1][\count] }.do { |kv|
				"%x  in % out %  %".format(kv[1][\count], kv[1][\in], kv[1][\out], kv[0].keep(120)).postln
			};
			^narrowLog
		}
		*clearNarrowLog { narrowLog = nil }

		initLfo { |function inputChannels=1 dur |
			bus=Bus.control();
			synth={ function => Out.kr(bus.index , _ )}.play;
			dur.notNil.if{
				fork{dur.wait;synth.free}
			};
			synth.onFree({bus.free});
  			^this;
//			^Pfunc({bus.index.isNil.not.if{bus.asMap}{nil}})
		}

		pfunc {
			^Pfunc({bus.index.isNil.not.if{bus.asMap}{nil}})
		}

		asStream {
			"embedded!".postln
		}

		embedInStream {|inevent|
			var cleanup = EventStreamCleanup.new;
			var event = inevent.copy;
			cleanup.addFunction(event,{|flag| flag.if{this.synth.free}});
			loop {
				event = inevent ?? { ^cleanup.exit(inevent) };
				inevent = event.yield;
		};
event.yield
		}

		init { |function out inputChannels=1 target time=1 maxDur release=3 detectOutput=true busChannels|
			var desc = SynthDef(\temp,{ In.ar(0, inputChannels) => function => Out.ar(0,_) });
			numChannels=desc.asSynthDesc.outputData[0].at(\numChannels);
			target = target ? Server.default;
			// an explicit minimum covers the input: not narrow, nothing to log
			bus=Bus.audio(numChannels: busChannels.notNil.if {
				busChannels.max(inputChannels).max(numChannels)
			} { this.class.busChannels(function, inputChannels, numChannels) });
			synth={|gate|
				var sig = In.ar(bus.index, inputChannels) => function;
				maxDur.notNil.if { sig = sig * EnvGen.kr(Env.linen(0, maxDur, release), doneAction: 2) };
				detectOutput.if { DetectSilence.ar(sig.asArray.first, time: time, doneAction: 2) };
				Out.ar(out, sig)
			}.play(addAction:\addToTail, target: target);
			NodeWatcher.register(synth, assumePlaying: true);
			synth.onFree({ 
				\freeing_Bus.postln;
				bus.free
			})
			// fork{
			// 	while ( {synth.isPlaying},{0.2.wait} );
			// 	\freeing_Bus.postln;
			// 	bus.free
			// };
			^this;
		}


		initSidechain { |function out inputChannels=1 |
			var desc=SynthDef(\temp,{In.ar(1,inputChannels)=>function=>Out.ar(0,_)});
			var numChannels=desc.asSynthDesc.outputData[0].at(\numChannels);
			'sidechain is at input[0]: example:'.postln;
//			'Effect.newSidechain( 'postln;
				'({|input| Vocoder.ar(input[1..4],input[0],20)},'.postln;
				'inputChannels:5)'.postln;
			bus=Bus.audio(numChannels:numChannels);
			sidechain=Bus.audio;
			node=NodeProxy.audio(numChannels:numChannels).play(out);
			node.reshaping_(\elastic);
			node.source= {[In.ar(sidechain),In.ar(bus,numChannels)]=>function};
			^this;
		}



//	asStream {
//		^bus.index
//	}
		release { |releaseTime|
			node.end(releaseTime)
		}

		dur {|time fade=3|
			node.isNil.not.if({node.end(fade)}.sched(time));
			synth.isNil.not.if({synth.release(fade)}.sched(time));
			{bus.free}.sched(time + fade);
		}	
		
		doesNotUnderstand { |selector ...args|
			[synth, node].do{ |receiver|
				receiver.respondsTo{selector}.if{
					Message(receiver,selector).value(*args);
				}
			}
		}
	}

/* EffectNarrow: Effect with the original bus sizing, whatever Effect.wideBuses
   says — the input bus is as wide as the function's OUTPUT, so a stereo writer
   into a mono effect spills its channel 1 into the next bus, as legacy pieces
   (Trek, Yoeminrak, Mandarin, scd/) were written and mixed against. Those call
   it explicitly so their sound is pinned; switch a call back to Effect once the
   passage has been checked by ear. Same arguments as Effect (bus, fx, new). */
EffectNarrow : Effect {
	*wide { ^false }
}

FX { 
	var <>bus;

	*new { |synth fx|
		^super.new.init(synth,fx )
	}

	*newN{ |synth fx|
		^super.new.initN(synth,fx);
	}


	init { |synth fx fxArgs numChannels=1|
		bus=Bus.audio(Server.default);
		synth.set(\out,bus.index);
		^Synth(fx,[\in,bus.index]++fxArgs,addAction:\addToTail)
	}

	initN { |synth fx fxArgs numChannels=1|
		bus=Bus.audio(Server.default);
		synth.set(\out,bus.index);
		^Synths(fx,[\in,bus.index]++fxArgs,addAction:\addToTail)
	}

}



EffectOld  { //deprecated
	var <>bus, <>synth, <>pattern, <>def, <>out, <>dur;
	*new {|inPattern def out dur|
		^super.new.init(inPattern, def, out, dur)
	}

	init {|inPattern inDef outChan inDur|
		bus=Bus.audio(Server.default,2);
		pattern=inPattern=>Pset(\out,bus.index,_);
		def=inDef;
		outChan.isNil.if({out=Bus.audio(Server.default,2)},{out=outChan});
		inDur.isNil.if({dur=30},{dur=inDur});
		^this
	}

	play {
		synth=Synth(def.asSymbol,[\in,bus.index,\out,out]);
		pattern.play;
		{dur.wait;synth.free}.fork;
		^synth;
	}
//////
// OK!!!
//
//get the stream from the pattern (.asStream)
// when it returns nil put in the \off event
//
///////

	//Array or?
	set { |...args|
		synth.set(args)
	}

}
+Function {
	lfo {^Effect.lfo(this).bus.index}
	lfoAsMap {|dur| ^Effect.lfo(this,dur:dur).pfunc}
	asBusNumber {|...args| 
		//NodeWatcher.register(this);
		^Effect(this,*args).bus.index}
}

+Node{
	mapLfo { |key function|
		var effect = Effect.lfo(function);
		this.onFree({ try{ effect.synth.free };try{effect.free} });
		fork{
			this.server.sync;
			this.map(key,effect.bus.index)
		};
		^(synth:this,lfo:effect.synth)
	}
}
