+ EnvGen {
	*cutoff { |wait release|
		^Env([1,1,0],[wait, release]).kr(2)
	}
}
