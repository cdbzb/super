+ EnvGen {
	*cutoff { |wait release doneAction = 2|
		^Env([1,1,0],[wait, release]).kr(doneAction)
	}
}
