// class definitions
// proof of concept - hjh 2020-09-11

// basically Thunk, possibly could fold this into Thunk
LazyResult : AbstractFunction {
	var func, value;
	var originalFunc;
	*new { |func| ^super.newCopyArgs(func, nil, func) }

	value { |... args|
		^if(this.isResolved) {
			value
		} {
			value = func.value(*args);
			func = nil;
			value
		}
	}

	isResolved { ^func.isNil }

	reset { func = originalFunc; value = nil }
}

LambdaEnvir {
	var envir;
	var resolvingKeys;

	*new { |env|
		^super.new.init(env);
	}

	init { |env|
		envir = Environment.new;
		env.keysValuesDo { |key, value|
			envir.put(key, LazyResult(value));
		};
	}

	at { |key|
		var entity = envir.at(key);
		if(entity.isResolved) {
			// should be an already-calculated value,
			// but we need to return it below
			entity = entity.value;
		} {
			if(resolvingKeys.isNil) {
				resolvingKeys = IdentitySet.new;
			};
			if(resolvingKeys.includes(key)) {
				Error("LambdaEnvir: Circular reference involving '%'".format(key)).throw;
			};
			resolvingKeys.add(key);
			protect {
				if(currentEnvironment === this) {
					entity = entity.value(this);
				} {
					this.use {
						entity = entity.value(this);
					};
				};
			} {
				resolvingKeys.remove(key);
			};
		};
		^entity
	}

	put { |key, value| envir.put(key, value) }

	use { |func|
		var saveEnvir = currentEnvironment;
		var result;
		protect {
			currentEnvironment = this;
			result = func.value;
		} {
			currentEnvironment = saveEnvir;
		};
		^result
	}

	keysValuesDo { |func|
		envir.keysValuesDo(func)
	}

	reset {
		this.keysValuesDo { |key, value| value.reset }
	}
}


LazyPbind : Pbind {
	embedInStream { |inevent|
		var proto = Event.new;
		var lambdaEnvir;
		var event;

		// these will become LazyResults later
		// this is OK because both streams and functions respond to 'value'
		patternpairs.pairsDo { |key, value|
			proto.put(key, value.asStream)
		};

		loop {
			if(inevent.isNil) { ^nil.yield };
			// passing 'proto' here populates all the LazyResult objects
			lambdaEnvir = LambdaEnvir(proto)
			.parent_(inevent.parent).proto_(inevent.proto);
			event = inevent.copy;
			lambdaEnvir.keysValuesDo { |key|
				var value = lambdaEnvir[key];  // this is what resolves the LazyResult
				if(value.isNil) { ^inevent };
				if(key.isSequenceableCollection) {
					if(key.size > value.size) {
						("the pattern is not providing enough values to assign to the key set:" + key).warn;
						^inevent
					};
					key.do { |key1, i|
						event.put(key1, value[i]);
					};
				} {
					event.put(key, value);
				};
			};
			inevent = event.yield;
		}
	}
}

// oh, and LambdaEnvir needs to add:
+ LambdaEnvir {
	parent { ^envir.parent }
	proto { ^envir.proto }
	parent_ { |parent| envir.parent_(parent) }
	proto_ { |proto| envir.proto_(proto) }
}

+ Object {
	isResolved { ^true }
}
