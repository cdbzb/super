
 + SynthDef  {
	*new { arg name, ugenGraphFunc, rates, prependArgs, variants, metadata;
		^super.newCopyArgs(name.asSymbol).variants_(variants).metadata_(metadata ?? {(path: thisProcess.nowExecutingPath)}).children_(Array.new(64))
			.build(ugenGraphFunc, rates, prependArgs)
	}
        }
