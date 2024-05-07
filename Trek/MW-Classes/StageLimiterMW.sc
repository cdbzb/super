StageLimiter {
	classvar lmSynth, <lmFunc, <activeSynth;
	
	*activate { |numChannels = 2|
		fork
		{
			lmFunc = 
			{ 
				{ 
					if( activeSynth.isNil or: try{ activeSynth.isRunning.not } ) {   
					activeSynth = 
						Synth(\stageLimiter,
							target: RootNode(Server.default), 
							addAction: \addToTail
						).register;
					}
				}.defer(0.01) 
			};
			lmSynth = SynthDef(\stageLimiter, 
			{
				var input = In.ar(0, numChannels);
				input = Select.ar(CheckBadValues.ar(input, 0, 0), [input, DC.ar(0), DC.ar(0), input]);
				input => LeakDC.ar(_, 0.9995)
				=> Limiter.ar(_)
				=> ReplaceOut.ar(0, _) ;
			}).add;
			Server.default.sync;
			lmFunc.value;
			// CmdPeriod.add(lmFunc);
			ServerTree.add(lmFunc);
			"StageLimiter active".postln;
		}
	}
	
	*deactivate {
		activeSynth.free;
		ServerTree.remove(lmFunc);
		"StageLimiter inactive...".postln;
	}
}
