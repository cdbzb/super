/*
 FxBus: an effect bus you can keep in a score.

 Effect.bus and AmpSim.bus start their synth when the line is EVALUATED and hand
 back a bare bus Integer. That synth frees itself after `time` seconds of silence
 (and MyFree / Cmd-. free it too), and its bus is freed with it, so a list built
 once and played again sends to a dead — or recycled — bus and goes silent.

 Effect.fx and AmpSim.fx take the same arguments but return an FxBus: the recipe,
 not the bus. It prints as its own source, so the event still shows what it is:

   (coef: 0.2, out: AmpSim.fx("Filmosound_with_cab", inputChannels: 1, drive: 0.8))

 and becomes a bus only when a message is actually sent. Every value bound for
 the server goes through asControlInput (Synth args, synth.set, Event msgFuncs),
 the same path a Bus object takes as out:. Here that answers the live Effect's
 bus, starting a fresh Effect first if the last one is gone. So:

   - one Effect per FxBus, shared by every note that names it, not one per note
   - it comes back by itself after MyFree, Cmd-., or the silence timeout
   - it works where a lazy Function cannot reach: nested params: Events, .p/.pm
     arrays, and player.setParams (which bakes the FxBus, not a number, into the
     take)

 Copies share one Effect. setParams and filter deep-copy midiEvents, and
 Object:deepCopy is a primitive that copies nested objects without calling
 their own deepCopy, so a nested FxBus WILL be duplicated. Each copy keeps the
 same immutable id, and the live Effect is kept per id on the class (live), so
 every copy answers the same bus. == and hash compare the recipe source, so
 cache keys (SynthVVST, MicroKeys config hashes) are stable across plays.

 EventList.prepare arms every FxBus it finds before anything is sent
 (armForPlay, see EventList.prArmForPlay), so the synth starts outside the
 timestamped note bundles. asControlInput's own re-arm is the fallback for an
 Effect that died mid-playback.

 out: may itself be an FxBus, to chain effects: the downstream one is resolved
 (asUGenInput) when the upstream Effect's synth is built.

 Extends Effect (*fx) and AmpSim (*fx); both are defined in their own files.
*/
FxBus {
	classvar <live;
	var <source, <make, <id;

	*initClass { live = IdentityDictionary.new }

	// make: a Function answering a started Effect. source: the String this
	// prints and stores as.
	*new { |source, make|
		^super.newCopyArgs(source, make, UniqueID.next)
	}

	// The live Effect for this FxBus and every copy of it (nil before the first
	// arm, or after free).
	effect { ^live[id] }

	/* "Head(first, key: value, ...)", leaving out keys still at their default so
	   the printed form stays as short as what was typed. triples: key, value,
	   default, ... */
	*prSource { |head, first, triples|
		var parts = [first.asCompileString];
		triples.clump(3).do { |t|
			(t[1] != t[2]).if { parts = parts.add(t[0] ++ ": " ++ t[1].asCompileString) }
		};
		^head ++ "(" ++ parts.join(", ") ++ ")"
	}

	isLive {
		var effect = this.effect;
		^effect.notNil
			and: { effect.synth.notNil }
			and: { effect.synth.isPlaying }
			and: { effect.synth.server.serverRunning }
	}

	// Start the Effect unless the current one is still playing.
	arm {
		this.isLive.not.if { live[id] = make.value };
		^this
	}

	armForPlay { ^this.arm }

	index { ^this.arm.effect.bus.index }

	asControlInput { ^this.index }
	asUGenInput { ^this.index }
	asBus { ^this.arm.effect.bus }

	// Stop the Effect now; the next send starts a new one.
	free {
		this.effect !? { |fx| fx.synth !? { |syn| syn.isPlaying.if { syn.free } } };
		live.removeAt(id)
	}

	// Same object where SC lets us choose (a top-level copy). Nested copies go
	// through the deepCopy primitive regardless — the shared id covers those.
	copy { ^this }
	shallowCopy { ^this }
	deepCopy { ^this }

	// Same Effect, whether or not the same object.
	sharesEffectWith { |that| ^that.isKindOf(FxBus) and: { id == that.id } }

	== { |that| ^that.isKindOf(FxBus) and: { source == that.source } }
	hash { ^source.hash }

	printOn { |stream| stream << source }
	storeOn { |stream| stream << source }
}

+ Effect {
	/* Effect.bus's arguments; answers an FxBus instead of a bus Integer. */
	*fx { |function out=0 inputChannels=1 target time=1 maxDur release=3|
		^FxBus(
			FxBus.prSource("Effect.fx", function, [
				\out, out, 0,
				\inputChannels, inputChannels, 1,
				\target, target, nil,
				\time, time, 1,
				\maxDur, maxDur, nil,
				\release, release, 3
			]),
			{ Effect(function, out, inputChannels, target, time, maxDur, release) }
		)
	}
}

+ AmpSim {
	/* AmpSim.bus's arguments; answers an FxBus instead of a bus Integer. */
	*fx { |model, out = 0, inputChannels = 2, time = 10, knob, pre, post, drive = 1, amp = 1, trim = true|
		^FxBus(
			FxBus.prSource("AmpSim.fx", model, [
				\out, out, 0,
				\inputChannels, inputChannels, 2,
				\time, time, 10,
				\knob, knob, nil,
				\pre, pre, nil,
				\post, post, nil,
				\drive, drive, 1,
				\amp, amp, 1,
				\trim, trim, true
			]),
			{ AmpSim.prEffect(model, out, inputChannels, time, knob, pre, post, drive, amp, trim) }
		)
	}
}
