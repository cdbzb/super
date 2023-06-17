/* hjh 6/12/2021 */

ModControl {
	var control, modulator, modDepth;

	*new { |rate = \control, name, default, warp, modulator, modDepth|
		^super.new.init(rate, name, default, warp, modulator, modDepth)
	}

	*ar { |name, default = 0, warp = \lin, modulator, modDepth|
		^this.new(\audio, name, default, warp, modulator, modDepth)
	}

	*kr { |name, default = 0, warp = \lin, modulator, modDepth|
		^this.new(\control, name, default, warp, modulator, modDepth)
	}

	init { |rate, name, default, warp, aModulator, aModDepth|
		control = NamedControl.perform(
			UGen.methodSelectorForRate(rate), name, default
		);
		if(aModulator.isUGen.not) {
			modulator = NamedControl.perform(
				this.methodSelectorForRate,
				(name ++ "Mod").asSymbol,
				if(aModulator.isNil) {
					(lin: 0, exp: 1, linear: 0, exponential: 1).at(warp) ?? { 0 }
				} { aModulator };
			);
		} { modulator = aModulator };
		if(aModDepth.isUGen.not) {
			modDepth = NamedControl.perform(
				this.methodSelectorForRate,
				(name ++ "ModDepth").asSymbol,
				if(aModDepth.isNil) {
					(lin: 1, exp: 2, linear: 1, exponential: 2).at(warp) ?? { 1 }
				} { aModDepth };
			);
		} { modDepth = aModDepth };
		^control.modulate(warp, modulator, modDepth, name);
	}

	methodSelectorForRate {
		^control.methodSelectorForRate
	}
}


+ UGen {
	// warp must be \lin or \exp for now
	// it appears to be difficult
	// to extract only the math formulas from Spec and Warp
	// without also importing all the clip, round etc. logic
	// I don't have time to deal with excessive tight coupling
	// this morning. Somebody else refactor it and then
	// other warps could be supported
	modulate { |warp, modulator, modDepth, name|
		if(modulator.isUGen.not) {
			modulator = NamedControl.perform(
				this.methodSelectorForRate,
				(name ++ "Mod").asSymbol,
				modulator
			);
		};
		if(modDepth.isUGen.not) {
			modDepth = NamedControl.perform(
				this.methodSelectorForRate,
				(name ++ "ModDepth").asSymbol,
				modDepth
			);
		};
		case
		{ #[lin, linear].includes(warp) } {
			^(modDepth * modulator) + this
		}
		{ #[exp, exponential].includes(warp) } {
			^(modDepth ** modulator) * this
		}
		{ Error("Unsupported warp '%' for modulation".format(warp)).throw };
	}
}

// OutputProxy doesn't know its rate??? really???
+ OutputProxy {
	rate { ^source.rate }

	methodSelectorForRate {
		^UGen.methodSelectorForRate(this.rate)
	}
}
