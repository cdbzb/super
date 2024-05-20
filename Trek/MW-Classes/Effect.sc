	Effect { //|function out=0| // node proxy version 
		var <>numChannels,<>bus,<>node, <>sidechain, <>synth;
		
		*newOld { |function out=0 inputChannels=1|
			^super.new.init(function , out,inputChannels);
		}
		*new { |function out=0 inputChannels=1 target time=1|
			^super.new.init(function , out,inputChannels, target, time);
		}
		*newSidechain {|function out=0 inputChannels=1| ^super.new.initSidechain(function,out,inputChannels) }

		*new2 {|function out=0 inputChannels=1| ^super.new.init(function,out,inputChannels)}
		*lfo {|function inputChannels=1 dur| ^super.new.initLfo(function,inputChannels,dur)}
		*bus {|function out=0 inputChannels=1 target time=1| ^Effect.new(function , out,inputChannels, target, time).bus.index}
		*kbus {|function inputChannels=1 dur| ^super.new.initLfo(function,inputChannels,dur).bus.index}

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

		init { |function out inputChannels=1 target time=1 |
			var desc = SynthDef(\temp,{ In.ar(0, inputChannels) => function => Out.ar(0,_) });
			numChannels=desc.asSynthDesc.outputData[0].at(\numChannels);
			target = target ? Server.default;
			// bus=Bus.audio(numChannels:numChannels);
			bus=Bus.audio(numChannels: inputChannels);
			// bus.debug("bus: ");
			// defer{bus.scope};
			synth={|gate| 
				In.ar(bus.index, inputChannels)
				=> function
				=>.first DetectSilence.ar(_, time: time, doneAction: 2)
				=> Out.ar(out, _)
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
