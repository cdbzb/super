+ EnvGen {
	*cutoff { |wait release curve doneAction = 2|
		^Env([1,1,0],[wait, release],curve).kr(doneAction)
	}
}
