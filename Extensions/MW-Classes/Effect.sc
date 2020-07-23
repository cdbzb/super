	Effect { //|function out=0| // node proxy version 
		var <>numChannels,<>bus,<>node, <>sidechain;

		*new { |function out=0 inputChannels=1|
			^super.new.init(function , out,inputChannels);
		}

		*newSidechain {|function out=0 inputChannels=1| ^super.new.initSidechain(function,out,inputChannels) }

		init { |function out inputChannels=1 |
			var desc=SynthDef(\temp,{In.ar(1,inputChannels)=>function=>Out.ar(0,_)});
			var numChannels=desc.asSynthDesc.outputData[0].at(\numChannels);
			bus=Bus.audio(numChannels:numChannels);
			node=NodeProxy.audio(numChannels:numChannels).play(out);
			node.reshaping_(\elastic);
			node.source= {In.ar(bus,numChannels)=>function};
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



		release { |releaseTime|
			node.end(releaseTime)
		}

		dur {|time fade=3|
			{node.end(fade)}.sched(time);
			{bus.free}.sched(time + fade);
		}	
		
		doesNotUnderstand { |selector ...args|
			Message(node,selector,args).value;
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
