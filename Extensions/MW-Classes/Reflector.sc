
Reflector5 : Object {
	*ar { arg
		input, 
		numReflcs = 5, 
		delayOffset = 0.02,
		scaleDelays = 1,
		spread = 1,
		reflPan = 0,
		lpfRefl = 0.9,
		hpfRefl = 150
		; 

		var primeDelays, delays, delayPans, reflections, pannedReflections;
		var filtered_input;

		primeDelays = [
			173, 179, 181, 191, 193, 197, 199, 211, 223, 227, 229,
			233, 239, 241, 251, 257, 263, 269, 271, 277, 281, 283,
			293, 307, 311, 313, 317, 331, 337, 347, 349, 353, 359,
		].scramble / 44100;

		numReflcs = numReflcs.clip(1,primeDelays.size);

		//form array of delay times
		delays = nil!numReflcs;

		delays[0] = delayOffset;

		(numReflcs - 1).do{arg i; 
			delays[i+1] = delays[i] + primeDelays[i];
		};

		delays = delays * scaleDelays;

		delayPans = Array.fill(numReflcs, {
			( reflPan + ( spread * Rand(-1.0, 1.0) ) ).clip2(1)
		});


		// sum to mono
		if(input.size > 1, {
			filtered_input = input.sum
		}, {
			filtered_input = input
		});	


		filtered_input = HPF.ar( 
			OnePole.ar( filtered_input, lpfRefl ), 
			hpfRefl 
		);


		reflections = Array.fill(numReflcs,
			{|i| 
				DelayN.ar(
					BPF.ar(
						filtered_input * (IRand(0,1) - 0.5 * 2 / (i+1 )), 
						freq: ExpRand(300, 2000), 
						// rq: 1 / (i+1) // every next reflection has  narrower spectrum
						rq: ExpRand(0.1,0.4)
					) ,
					0.2, 
					delays.at(i)
				) 
			}
		);

		pannedReflections = Array.fill(numReflcs,
			{|i| 
				PanAz.ar(5,reflections.at(i), delayPans.at(i)) 
			}
		);

		^pannedReflections.sum 

	}
}
