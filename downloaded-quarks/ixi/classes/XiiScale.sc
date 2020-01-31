


XiiScale {

	var <degrees, <descDegrees, <stepsPerOctave, <tuning, <>name, lastIndex = 0, 
		setStepsNextTuning = false;
	
	*new { | degrees, tuning, descDegrees |
		// can't use arg defaults because nils are passed in by doesNotUnderstand
		// nils in tuning handled after stepsPerOctave determined
		// nil for descDegrees is OK
		^super.new.init(degrees ? \ionian, tuning, descDegrees);
	}
	
	init { | inDegrees, inTuning, inDescDegrees |
		// Degrees may or may not set the stepsPerOctave
		this.degrees_(inDegrees);
		// Tuning will use stepsPerOctave if set; if not
		// will guess based on scale contents
		this.tuning_(inTuning);
		this.descDegrees_(inDescDegrees ? inDegrees);
		stepsPerOctave = stepsPerOctave ? tuning.size;
		^this.checkForMismatch
	}
	
	checkForMismatch {
		(stepsPerOctave != tuning.size).if({
			(
				"Scale steps per octave " ++ stepsPerOctave ++ 
				" does not match tuning size " ++
				tuning.size ++ ": using default tuning"
			).warn;
			tuning = XiiTuning.default(stepsPerOctave);
		});
		^this
	}
	
	degrees_ { | inDegrees |
		var key;
		inDegrees.isKindOf(SequenceableCollection).if({			degrees = inDegrees.asArray;
			(degrees != degrees.asInteger).if({
				"Truncating non-integer scale degrees.".warn;
				degrees = degrees.asInteger;
			});
			name = "scale" ++ UniqueID.next.asString;
			setStepsNextTuning = true;
		}, {
			key = inDegrees ? \ionian;
			#degrees, descDegrees, stepsPerOctave = XiiScaleInfo.at(key);
			name = key.asString
		})
	}
	
	descDegrees_ { | inDescDegrees |
		inDescDegrees.isKindOf(SequenceableCollection).if({
			descDegrees = inDescDegrees.asArray;
		}, {
			^descDegrees = XiiScaleInfo.descDegrees(inDescDegrees)
		});
	}
	
	tuning_ { | inTuning |
		var targetSteps;
		targetSteps = setStepsNextTuning.if({ this.guessSPO }, { stepsPerOctave });
		inTuning.isKindOf(XiiTuning).if({
			tuning = inTuning;
		}, {
			tuning = inTuning.notNil.if({
				XiiTuning.new(inTuning, targetSteps);
			}, {
				XiiTuning.default(targetSteps);
			})
		});
		setStepsNextTuning.if({ setStepsNextTuning = false; stepsPerOctave = tuning.size });
	}
	
	guessSPO {
		// most common flavors of ET
		// pick the smallest one that contains all scale degrees
		var etTypes = #[12, 19, 24, 53, 128];
		^etTypes[etTypes.indexInBetween(degrees.maxItem).ceil];
	}
	
	scale_ { | degrees, tuning, descDegrees |
		degrees.notNil.if({ this.degrees_(degrees) });
		tuning.notNil.if({ this.tuning_(tuning) });
		this.descDegrees_(descDegrees ? degrees);
	}
	
	asArray {
		^this.semitones
	}
	
	asADArray {
		^this.semitones(false) ++ this.semitones(true).reverse.drop(1)
	}
	
	adDegrees {
		^degrees ++ (descDegrees ? degrees).reverse.drop(1)
	}
	
	adRatios {
		^this.asADArray.midiratio
	}
	
	asFloatArray {
		var array, fa;
		array = this.asArray;
		^FloatArray.new(array.size).addAll(array);
	}
	
	size {
		^degrees.size
	}
	
	semitones { |desc = false|
		desc.if({
			^descDegrees !? descDegrees.collect({ |x| tuning.wrapAt(x) });
		},{
			this.checkForMismatch;
			^degrees.collect({ |x| tuning.wrapAt(x) });
		})
	}
	
	cents { |desc = false|
		^this.semitones * 100
	}
	
	ratios {
		^this.semitones.midiratio
	}
	
	descending {
		|index|
		^descDegrees.notNil && (index < lastIndex)
	}
	
	at { |index|
		^this.semitones(this.descending(index)).at(index) <! ( lastIndex = index )
	}
	
	wrapAt { |index|
		^this.semitones(this.descending(index)).wrapAt(index) <! ( lastIndex = index )
	}
	
	degreeToRatio { |degree, octave = 0|
		^this.ratios.at(degree) * (2 ** octave);
	}
	
	degreeToFreq { |degree, rootFreq, octave|
		^this.degreeToRatio(degree, octave) * rootFreq;
	}
	
	*choose { |size, tuning|
		// this is a bit pretzely, but allows steps and tuning to be constrained
		// independently, while still making sure everything matches up
		var randomScale, randomTuning, steps, selectFunc;
		randomTuning = tuning !? tuning.isKindOf(XiiTuning).if({ tuning }, { XiiTuning.new(tuning) });
		selectFunc = size.isNil.if({
			randomTuning.isNil.if({
				{ true }
			}, {
				{ |k| XiiScaleInfo.stepsPerOctave(k) == randomTuning.size }
			})
		}, {
			{ |k| XiiScaleInfo.degrees(k).size == size }
		});
		randomScale = XiiScaleInfo.choose(selectFunc);
		randomTuning = randomScale.isNil.if({
			("No scales matching criteria " ++ [size, tuning].asString ++ " available.").warn;
			\et12
		}, {
			randomTuning ? XiiTuning.choose(XiiScaleInfo.stepsPerOctave(randomScale))
		});
		^super.new.init(randomScale ? \ionian, randomTuning)
	}
	
	*doesNotUnderstand { |selector, args|
		^(XiiScaleInfo.includesKey(selector)).if({
			this.new(selector, args)
		}, {
			super.doesNotUnderstand(selector, args)
		})
	}
	
	doesNotUnderstand { |selector, args|
		var target;
		target = this.semitones;
		^target.respondsTo(selector).if({
			target.perform(selector, args)
		}, {
			super.doesNotUnderstand(selector, args)
		})
	}
	
	*names {
		^XiiScaleInfo.names
	}

}

XiiTuning {

	var <tuning, <>name;
	
	*new { | tuning, stepsPerOctave |
		^super.new.init(tuning ? \et12, stepsPerOctave ? 12);
	}
	
	*default { | stepsPerOctave |
		var defaultTuning;
		defaultTuning = XiiTuningInfo.default(stepsPerOctave);
		^super.new.init(defaultTuning ? this.calcDefault(stepsPerOctave), stepsPerOctave).
			name_(defaultTuning ? this.defaultName(stepsPerOctave))
	}
	
	*et { |stepsPerOctave|
		^super.new.init(this.calcET(stepsPerOctave)).name_(this.etName);
	}
	
	*calcET { | stepsPerOctave |
		^(0..(stepsPerOctave - 1)) * (12/stepsPerOctave)
	}
	
	*calcDefault { | stepsPerOctave |
		^this.calcET(stepsPerOctave)
	}
	
	*choose { |size = 12|
		^super.new.init(XiiTuningInfo.choose(size))
	}
	
	*defaultName { |stepsPerOctave|
		^this.etName(stepsPerOctave)
	}
	
	*etName { |stepsPerOctave|
		^"et" ++ stepsPerOctave.asString
	}
	
	init { | inTuning, inStepsPerOctave |
		^this.tuning_(inTuning, inStepsPerOctave);
	}
		
	tuning_ { | inTuning, inStepsPerOctave = 12 |
		var newTuning;
		inTuning.isKindOf(SequenceableCollection).if({
			tuning = inTuning.asArray;
			name = "tuning" ++ UniqueID.next.asString;
		}, {
			newTuning = XiiTuningInfo.at(inTuning.asSymbol);
			newTuning.notNil.if({
				tuning = newTuning;
				name = inTuning.asString;
			}, {
				("Unknown tuning: " ++ inTuning).warn;
				tuning = this.class.calcDefault(inStepsPerOctave);
				name = this.class.defaultName(inStepsPerOctave);
			})	
		});
	}

	cents_ { |cents|
		^this.tuning_(cents / 100)
	}
	
		
	ratios {
		^tuning.midiratio
	}
	
	ratioAt {
		|index|
		^this.ratios.at(index)
	}
	
	semitones {
		^tuning
	}
	
	asArray {
		^this.semitones
	}
	
	asFloatArray {
		^FloatArray.newClear(tuning.size).addAll(tuning);
	}
	
	size {
		^tuning.size;
	}
	
	*doesNotUnderstand { |selector, args|
		^(XiiTuningInfo.includesKey(selector)).if({
			this.new(selector, args)
		}, {
			super.doesNotUnderstand(selector, args)
		})
	}
	
	doesNotUnderstand { |selector, args|
		^tuning.respondsTo(selector).if({
			tuning.perform(selector, args)
		}, {
			super.doesNotUnderstand(selector, args)
		})
	}
	
	*names {
		^XiiTuningInfo.names
	}
}

XiiScaleInfo {

	classvar dict;
	*initClass {
	
		dict = IdentityDictionary[
			
			// TWELVE TONES PER OCTAVE
			// 5 note scales
			\minorPentatonic -> [ #[0,3,5,7,10], nil, 12 ],
			\majorPentatonic -> [ #[0,2,4,7,9], nil, 12 ],
			\ritusen -> [ #[0,2,5,7,9], nil, 12 ], // another mode of major pentatonic
			\egyptian -> [ #[0,2,5,7,10], nil, 12 ], // another mode of major pentatonic
			
			\kumoi -> [ #[0,2,3,7,9], nil, 12 ],
			\hirajoshi -> [ #[0,2,3,7,8], nil, 12 ],
			\iwato -> [ #[0,1,5,6,10], nil, 12 ], // mode of hirajoshi
			\chinese -> [ #[0,4,6,7,11], nil, 12 ], // mode of hirajoshi
			\indian -> [ #[0,4,5,7,10], nil, 12 ],
			\pelog -> [ #[0,1,3,7,8], nil, 12 ],
			
			\prometheus -> [ #[0,2,4,6,11], nil, 12 ],
			\scriabin -> [ #[0,1,4,7,9], nil, 12 ],
			
			// han chinese pentatonic scales
			\gong -> [ #[0,2,4,7,9], nil, 12 ],
			\shang -> [ #[0,2,5,7,10], nil, 12 ],
			\jiao -> [ #[0,3,5,8,10], nil, 12 ],
			\zhi -> [ #[0,2,5,7,9], nil, 12 ],
			\yu -> [ #[0,3,5,7,10], nil, 12 ],
			
			
			// 6 note scales
			\whole -> [ (0,2..10), nil, 12 ],
			\augmented -> [ #[0,3,4,7,8,11], nil, 12 ],
			\augmented2 -> [ #[0,1,4,5,8,9], nil, 12 ],
			
			// Partch's Otonalities and Utonalities
			\partch_o1 -> [ #[0,8,14,20,25,34], nil, 43 ],
			\partch_o2 -> [ #[0,7,13,18,27,35], nil, 43 ],
			\partch_o3 -> [ #[0,6,12,21,29,36], nil, 43 ],
			\partch_o4 -> [ #[0,5,15,23,30,37], nil, 43 ],
			\partch_o5 -> [ #[0,10,18,25,31,38], nil, 43 ],
			\partch_o6 -> [ #[0,9,16,22,28,33], nil, 43 ],
			\partch_u1 -> [ #[0,9,18,23,29,35], nil, 43 ],
			\partch_u2 -> [ #[0,8,16,25,30,36], nil, 43 ],
			\partch_u3 -> [ #[0,7,14,22,31,37], nil, 43 ],
			\partch_u4 -> [ #[0,6,13,20,28,38], nil, 43 ],
			\partch_u5 -> [ #[0,5,12,18,25,33], nil, 43 ],
			\partch_u6 -> [ #[0,10,15,21,27,34], nil, 43 ],
			
			// hexatonic modes with no tritone
			\hexMajor7 -> [ #[0,2,4,7,9,11], nil, 12 ],
			\hexDorian -> [ #[0,2,3,5,7,10], nil, 12 ],
			\hexPhrygian -> [ #[0,1,3,5,8,10], nil, 12 ],
			\hexSus -> [ #[0,2,5,7,9,10], nil, 12 ],
			\hexMajor6 -> [ #[0,2,4,5,7,9], nil, 12 ],
			\hexAeolian -> [ #[0,3,5,7,8,10], nil, 12 ],
			
			// 7 note scales
			\major -> [ #[0,2,4,5,7,9,11], nil, 12 ],
			\ionian -> [ #[0,2,4,5,7,9,11], nil, 12 ],
			\dorian -> [ #[0,2,3,5,7,9,10], nil, 12 ],
			\phrygian -> [ #[0,1,3,5,7,8,10], nil, 12 ],
			\lydian -> [ #[0,2,4,6,7,9,11], nil, 12 ],
			\mixolydian -> [ #[0,2,4,5,7,9,10], nil, 12 ],
			\aeolian -> [ #[0,2,3,5,7,8,10], nil, 12 ],
			\minor -> [ #[0,2,3,5,7,8,10], nil, 12 ],
			\locrian -> [ #[0,1,3,5,6,8,10], nil, 12 ],
			
			\harmonicMinor -> [ #[0,2,3,5,7,8,11], nil, 12 ],
			\harmonicMajor -> [ #[0,2,4,5,7,8,11], nil, 12 ],
			
			\melodicMinor -> [ #[0,2,3,5,7,9,11], #[0,2,3,5,7,8,10], 12 ],
			\melodicMajor -> [ #[0,2,4,5,7,8,10], nil, 12 ],
			
			\bartok -> [ #[0,2,4,5,7,8,10], nil, 12 ], // jazzers call this the hindu scale
			
			// raga modes
			\todi -> [ #[0,1,3,6,7,8,11], nil, 12 ], // maqam ahar kurd
			\purvi -> [ #[0,1,4,6,7,8,11], nil, 12 ],
			\marva -> [ #[0,1,4,6,7,9,11], nil, 12 ],
			\bhairav -> [ #[0,1,4,5,7,8,11], nil, 12 ],
			\ahirbhairav -> [ #[0,1,4,5,7,9,10], nil, 12 ],
			
			\superLocrian -> [ #[0,1,3,4,6,8,10], nil, 12 ],
			\romanianMinor -> [ #[0,2,3,6,7,9,10], nil, 12 ], // maqam nakriz
			\hungarianMinor -> [ #[0,2,3,6,7,8,11], nil, 12 ],       
			\neapolitanMinor -> [ #[0,1,3,5,7,8,11], nil, 12 ],
			\enigmatic -> [ #[0,1,4,6,8,10,11], nil, 12 ],
			\spanish -> [ #[0,1,4,5,7,8,10], nil, 12 ],
			
			// modes of whole tones with added note ->
			\leadingWhole -> [ #[0,2,4,6,8,10,11], nil, 12 ],
			\lydianMinor -> [ #[0,2,4,6,7,8,10], nil, 12 ],
			\neapolitanMajor -> [ #[0,1,3,5,7,9,11], nil, 12 ],
			\locrianMajor -> [ #[0,2,4,5,6,8,10], nil, 12 ],
			
			// 8 note scales
			\diminished -> [ #[0,1,3,4,6,7,9,10], nil, 12 ],
			\diminished2 -> [ #[0,2,3,5,6,8,9,11], nil, 12 ],
			
			// 12 note scales
			\chromatic -> [ (0..11), nil, 12 ],
			
			// TWENTY-FOUR TONES PER OCTAVE
			
			// maqam ajam
			\ajam -> [ #[0,4,8,10,14,18,22], nil, 24 ],
			\jiharkah -> [ #[0,4,8,10,14,18,21], nil, 24 ],
			\shawqAfza -> [ #[0,4,8,10,14,16,22], nil, 24 ],
			
			// maqam sikah
			\sikah -> [ #[0,3,7,11,14,17,21], #[0,3,7,11,13,17,21], 24 ],
			\huzam -> [ #[0,3,7,9,15,17,21], nil, 24 ],
			\iraq -> [ #[0,3,7,10,13,17,21], nil, 24 ],
			\bastanikar -> [ #[0,3,7,10,13,15,21], nil, 24 ],
			\mustar -> [ #[0,5,7,11,13,17,21], nil, 24 ],
			
			// maqam bayati
			\bayati -> [ #[0,3,6,10,14,16,20], nil, 24 ],
			\karjighar -> [ #[0,3,6,10,12,18,20], nil, 24 ],
			\husseini -> [ #[0,3,6,10,14,17,21], nil, 24 ],
			
			// maqam nahawand
			\nahawand -> [ #[0,4,6,10,14,16,22], #[0,4,6,10,14,16,20], 24 ],
			\farahfaza -> [ #[0,4,6,10,14,16,20], nil, 24 ],
			\murassah -> [ #[0,4,6,10,12,18,20], nil, 24 ],
			\ushaqMashri -> [ #[0,4,6,10,14,17,21], nil, 24 ],
			
			// maqam rast
			\rast -> [ #[0,4,7,10,14,18,21], #[0,4,7,10,14,18,20], 24 ],
			\suznak -> [ #[0,4,7,10,14,16,22], nil, 24 ],
			\nairuz -> [ #[0,4,7,10,14,17,20], nil, 24 ],
			\yakah -> [ #[0,4,7,10,14,18,21], #[0,4,7,10,14,18,20], 24 ],
			\mahur -> [ #[0,4,7,10,14,18,22], nil, 24 ],
			
			// maqam hijaz
			\hijaz -> [ #[0,2,8,10,14,17,20], #[0,2,8,10,14,16,20], 24 ],
			\zanjaran -> [ #[0,2,8,10,14,18,20], nil, 24 ],
			
			// maqam hijazKar
			\zanjaran -> [ #[0,2,8,10,14,16,22], nil, 24 ],
			
			// maqam saba
			\saba -> [ #[0,3,6,8,12,16,20], nil, 24 ],
			\zamzam -> [ #[0,2,6,8,14,16,20], nil, 24 ],
			
			// maqam kurd
			\kurd -> [ #[0,2,6,10,14,16,20], nil, 24 ],
			\kijazKarKurd -> [ #[0,2,8,10,14,16,22], nil, 24 ],
			
			// maqam nawa Athar
			\nawaAthar -> [ #[0,4,6,12,14,16,22], nil, 24 ],
			\nikriz -> [ #[0,4,6,12,14,18,20], nil, 24 ],
			\atharKurd -> [ #[0,2,6,12,14,16,22], nil, 24 ],
		];
	}
	
	*doesNotUnderstand { |selector, args|
		^dict.perform(selector, args)
	}
	
	*getParam {
		|name, index|
		^this.includesKey(name.asSymbol).if({ 
			dict.at(name).at(index)
		}, {
			("Unknown scale: " ++ name.asString).warn;
			nil 
		})
	}
	
	*descDegrees {
		|name|
		^this.getParam(name, 1) ? this.getParam(name, 0)
	}
	
	*degrees {
		|name|
		^this.getParam(name, 0)
	}
	
	*stepsPerOctave {
		|name|
		^this.getParam(name, 2)
	}
	
	*choose {
		|selectFunc|
		^dict.keys.select(selectFunc ? { true }).choose;
	}
	
	*names {
		^dict.keys.asArray.sort.asString
	}
}

XiiTuningInfo {

	classvar dict, defaults;
	
	*initClass {
		defaults = IdentityDictionary[
			43 -> \partch
		];
		
		dict = IdentityDictionary[

			//TWELVE-TONE TUNINGS
			\et12 -> (0..11),

			//pythagorean
			\pythagorean -> [1, 256/243, 9/8, 32/27, 81/64, 4/3, 729/512, 3/2,
				128/81, 27/16, 16/9, 243/128].ratiomidi,
			
			//5-limit tritone
			\just -> [1, 16/15, 9/8, 6/5, 5/4, 4/3, 45/32, 3/2, 8/5, 5/3, 9/5, 15/8].ratiomidi,
			
			//septimal tritone
			\sept1 -> [1, 16/15, 9/8, 6/5, 5/4, 4/3, 7/5, 3/2, 8/5, 5/3, 9/5, 15/8].ratiomidi,
			
			//septimal tritone and minor seventh
			\sept2 -> [1, 16/15, 9/8, 6/5, 5/4, 4/3, 7/5, 3/2, 8/5, 5/3, 7/4, 15/8].ratiomidi,
		
			//meantone, 1/4 syntonic comma
			\mean4 -> #[0, 0.755, 1.93, 3.105, 3.86, 5.035, 5.79, 6.965, 7.72, 8.895, 10.07, 10.82],
		
			//meantone, 1/5 Pythagorean comma
			\mean5 -> #[0, 0.804, 1.944, 3.084, 3.888, 5.028, 5.832, 6.972, 7.776, 8.916, 10.056, 10.86],
		
			//meantone, 1/6 Pythagorean comma
			\mean6 -> #[0, 0.86, 1.96, 3.06, 3.92, 5.02, 5.88, 6.98, 7.84, 8.94, 10.04, 10.9],		
			//Kirnberger III
			\kirnberger -> [1, 256/243, (5.sqrt)/2, 32/27, 5/4, 4/3, 45/32, 5 ** 0.25,
				128/81, (5 ** 0.75)/2, 16/9, 15/8].ratiomidi,
		
			//Werckmeister III
			\werckmeister -> #[0, 0.92, 1.93, 2.94, 3.915, 4.98, 5.9, 6.965, 7.93, 8.895, 9.96, 10.935],	
			//Vallotti
			\vallotti -> #[0, 0.94135, 1.9609, 2.98045, 3.92180, 5.01955, 5.9218, 6.98045,
				7.9609, 8.94135, 10, 10.90225],
				
			//Young
			\young -> #[0, 0.9, 1.96, 2.94, 3.92, 4.98, 5.88, 6.98, 7.92, 8.94, 9.96, 10.9],
				
			//Mayumi Reinhard
			\reinhard -> [1, 14/13, 13/12, 16/13, 13/10, 18/13, 13/9, 20/13, 13/8, 22/13,
				13/7, 208/105].ratiomidi,
				
			//Wendy Carlos Harmonic
			\wcHarm -> [1, 17/16, 9/8, 19/16, 5/4, 21/16, 11/8, 3/2, 13/8, 27/16, 7/4, 15/8].ratiomidi,
			
			//Wendy Carlos Super Just
			\wcSJ -> [1, 17/16, 9/8, 6/5, 5/4, 4/3, 11/8, 3/2, 13/8, 5/3, 7/4, 15/8].ratiomidi,
			
			//MORE THAN TWELVE-TONE ET
			\et19 -> ((0 .. 18) * 12/19),
			\et22 -> ((0 .. 21) * 6/11),
			\et24 -> ((0 .. 23) * 0.5),
			\et31 -> ((0 .. 30) * 12/31),
			\et41 -> ((0 .. 40) * 12/41),
			\et53 -> ((0 .. 52) * 12/53),
		
			//NON-TWELVE-TONE JI	
			//Ben Johnston
			\johnston -> [1, 25/24, 135/128, 16/15, 10/9, 9/8, 75/64, 6/5, 5/4, 81/64, 32/25, 
				4/3, 27/20, 45/32, 36/25, 3/2, 25/16, 8/5, 5/3, 27/16, 225/128, 16/9, 9/5,
				15/8, 48/25].ratiomidi,
				
			//Harry Partch
			\partch -> [1, 81/80, 33/32, 21/20, 16/15, 12/11, 11/10, 10/9, 9/8, 8/7, 7/6,
				32/27, 6/5, 11/9, 5/4, 14/11, 9/7, 21/16, 4/3, 27/20, 11/8, 7/5, 10/7, 16/11,
				40/27, 3/2, 32/21, 14/9, 11/7, 8/5, 18/11, 5/3, 27/16, 12/7, 7/4, 16/9, 9/5, 
				20/11, 11/6, 15/8, 40/21, 64/33, 160/81].ratiomidi,
				
			//Jon Catler
			\catler -> [1, 33/32, 16/15, 9/8, 8/7, 7/6, 6/5, 128/105, 16/13, 5/4, 21/16,
				4/3, 11/8, 45/32, 16/11, 3/2, 8/5, 13/8, 5/3, 27/16, 7/4, 16/9, 24/13, 15/8].ratiomidi,
				
			//John Chalmers
			\chalmers -> [1, 21/20, 16/15, 9/8, 7/6, 6/5, 5/4, 21/16, 4/3, 7/5, 35/24, 3/2,
				63/40, 8/5, 5/3, 7/4, 9/5, 28/15, 63/32].ratiomidi,
				
			//Lou Harrison
			\harrison -> [1, 16/15, 10/9, 8/7, 7/6, 6/5, 5/4, 4/3, 17/12, 3/2, 8/5, 5/3,
				12/7, 7/4, 9/5, 15/8].ratiomidi,
		
			//sruti
			\sruti -> [1, 256/243, 16/15, 10/9, 9/8, 32/27, 6/5, 5/4, 81/64, 4/3, 27/20,
				45/32, 729/512, 3/2, 128/81, 8/5, 5/3, 27/16, 16/9, 9/5, 15/8, 243/128].ratiomidi,
		
			//HARMONIC SERIES -- length arbitary
			\harmonic -> (1 .. 24).ratiomidi,
		
			//NO OCTAVE
			//Bohlen-Pierce
			\bp -> ((0 .. 12) * (3.ratiomidi/13)),
			
			//Wendy Carlos scales -- length arbitrary
			\wcAlpha -> ((0 .. 127) * 0.78),
			\wcBeta -> ((0 .. 127) * 0.638),
			\wcGamma -> ((0 .. 255) * 0.351)
		];
	}	

	*choose { |size|
		^dict.keys.select({ |t| dict[t].size == size }).choose;
	}

	*names {
		^dict.keys.asArray.sort.asString
	}
	
	*default { |stepsPerOctave|
		^defaults[stepsPerOctave]
	}

	*doesNotUnderstand { |selector, args|
		^dict.perform(selector, args)
	}	
}




/*

1) Why has the .asFloatArray method become so complex? Can't you just do: array.asFloatArray?



*/





/* 

Comments:

0) First of all, the way you've implemented asc/desc scales is very clever.
(I put Prand instead of PSeq in the example and then
a.scale_(\ionian, \sept2, \locrian);
and it all seemed to work).

1) I'm not sure what asArray returns anymore. What is this for? I see it has something to do with the tuning. 

2) Now one has to use .asRatios to get the ratios but .degrees to get the degrees.
Perhaps the naming should be more coherent (.ratios and .degrees)? (these are the
two methods that I would use all the time and the less confusing the better.
Later:
I see you've got the .asMIDI method, but I think that a name of a protocol like MIDI 
should not be part of this class' method names. That'd be reactionary. .asDegrees?
Even later:
Ok, I now see that you've got .asArray and .asRatios for these things. Perhaps my confusion
illustrates an API design propblem? Is the solution just to implement either an .degrees method
or an .asDegrees, or both? Or am I just confusing/conflating things here?


3) .at and .wrapAt give me "a BinaryOpFunction". Is that the intention?
a = ScaleT.ionian;
a.at(2);
a.wrapAt(3);


4) If I'm used to having my pitches in an array and using .mirror to go up and down the scale, how do I do this now with ascending and descending scales?

a = ScaleT(\melodicMinor).adRatios
(
{
	a.do({arg rel;
		Synth(\xiiString, [\freq, (440*rel).postln;]);
		0.25.wait;
	})
}.fork
)

Here the descending doesn't work. I'd like to be able to get the whole scale (up and down)
represented as an array.

I could of course try this:

(
{
	(a++ScaleT(\melodicMinor).descDegrees.reverse.midiratio).do({arg rel;
		Synth(\xiiString, [\freq, (440*rel).postln;]);
		0.25.wait;
	})
}.fork
)

But it turns out it didn't work as the descDegrees are not set to the desc scale of melodicMinor.
(shouldn't they be automatically set when a scale with different descending is chosen?


5) Something VERY strange! I've realised that Scale messes up with the way the interpreter works.
If I do this:

a = Scale.new(\ionian)
a.sdfsdfsdfsdf

the interpreter doesn't give me error message like it should do (it just gives me an empty line). Then if I type 

a = SoundFile.new
a.sdlkfjsdfs

the interpreter just prints an empty line in the post window.
This seems to happen only when I do things with the Scale class and not others.


*/






/*

(
s.waitForBoot({
	a = ScaleT.ionian;
	
	p = { |scale|
		Pbind(
			\degree, Pseq([0, 1, 2, 3, 4, 5, 6, 7, 6, 5, 4, 3, 2, 1, 0, \rest], inf),
			\scale, scale,
			\dur, 0.25
		).play;
	};
	
	q = p.value(a);
})
)

// change degrees
a.degrees_(\phrygian);

// supports ascending/descending scales
a.degrees_(\melodicMinor);

a.degrees_(\todi);
a.descDegrees_(\bartok);

// change tuning
a.tuning_(\just);

// change all -- should be done simultaneously when switching
// number of steps per octave
a.scale_(\bayati, \et24);

// ... but if you don't, we warn you and continue with
// default tuning
a.scale_(\mixolydian);

// can also set tuning at creation time
(
q.stop;
a = ScaleT.ionian(\pythagorean);
q = p.value(a);
)

// random scale
(
q.stop;
a = Scale.choose;
[a.name, a.tuning.name].postln;
q = p.value(a);
)

// or constrain it by size and/or tuning
(
q.stop;
a = ScaleT.choose(5, \et12);
[a.name, a.tuning.name].postln;
q = p.value(a);
)

(
q.stop;
a = Scale.choose(7);
[a.name, a.tuning.name].postln;
q = p.value(a);
)

(
q.stop;
a = Scale.choose(nil, \partch);
[a.name, a.tuning.name].postln;
q = p.value(a);
)

(
// or make up your own arbitrary scales and tunings
// degrees, tuning, descDegrees if different
a.scale_(
	#[0, 2, 4, 5, 7, 9, 10],
	[0, 0.8, 2.1, 3, 4.05, 5.2, 6, 6.75, 8.3, 9, 10.08, 11.5],
	#[0, 1, 4, 5, 7, 8, 11]
);
)

a.scale_(\ionian, \sept2, \locrian);

// tuning has its own class
t = Tuning.werckmeister;

a.scale_(\lydian, t);

// getting info
a.name;
a.degrees;
a.semitones;
a.ratios;
a.asFloatArray;

a.tuning.name;
a.tuning.semitones;
a.tuning.ratios;

Scale.names.postln;
Tuning.names.postln;



(
var scale, buffer;
scale = Scale.choose;
["scale chosen : ", scale.name].postln;
buffer = Buffer.alloc(s, scale.size,1, {|b| b.setnMsg(0, scale.asFloatArray) });

play({
	SinOsc.ar(
		(
			DegreeToKey.kr(
				buffer,
				MouseX.kr(0,15),		// mouse indexes into scale
				12,					// 12 notes per octave
				1,					// mul = 1
				60					// offset by 72 notes
			) 
			+ LFNoise1.kr([3,3], 0.04)	// add some low freq stereo detuning
		).midicps,						// convert midi notes to hertz
		0,
		0.8)
})
)





Scale {

	classvar scaleDict;
	var <degrees, <descDegrees, <stepsPerOctave, <tuning, <>name, lastIndex = 0, 
		setStepsNextTuning = false;
	
	*initClass {
	
		scaleDict = IdentityDictionary[
			
			// TWELVE TONES PER OCTAVE
			// 5 note scales
			\minorPentatonic -> [ #[0,3,5,7,10], nil, 12 ],
			\majorPentatonic -> [ #[0,2,4,7,9], nil, 12 ],
			\ritusen -> [ #[0,2,5,7,9], nil, 12 ], // another mode of major pentatonic
			\egyptian -> [ #[0,2,5,7,10], nil, 12 ], // another mode of major pentatonic
			
			\kumoi -> [ #[0,2,3,7,9], nil, 12 ],
			\hirajoshi -> [ #[0,2,3,7,8], nil, 12 ],
			\iwato -> [ #[0,1,5,6,10], nil, 12 ], // mode of hirajoshi
			\chinese -> [ #[0,4,6,7,11], nil, 12 ], // mode of hirajoshi
			\indian -> [ #[0,4,5,7,10], nil, 12 ],
			\pelog -> [ #[0,1,3,7,8], nil, 12 ],
			
			\prometheus -> [ #[0,2,4,6,11], nil, 12 ],
			\scriabin -> [ #[0,1,4,7,9], nil, 12 ],
			
			// han chinese pentatonic scales
			\gong -> [ #[0,2,4,7,9], nil, 12 ],
			\shang -> [ #[0,2,5,7,10], nil, 12 ],
			\jiao -> [ #[0,3,5,8,10], nil, 12 ],
			\zhi -> [ #[0,2,5,7,9], nil, 12 ],
			\yu -> [ #[0,3,5,7,10], nil, 12 ],
			
			
			// 6 note scales
			\whole -> [ (0,2..10), nil, 12 ],
			\augmented -> [ #[0,3,4,7,8,11], nil, 12 ],
			\augmented2 -> [ #[0,1,4,5,8,9], nil, 12 ],
			
			// Partch's Otonalities and Utonalities
			\partch_o1 -> [ #[0,8,14,20,25,34], nil, 43 ],
			\partch_o2 -> [ #[0,7,13,18,27,35], nil, 43 ],
			\partch_o3 -> [ #[0,6,12,21,29,36], nil, 43 ],
			\partch_o4 -> [ #[0,5,15,23,30,37], nil, 43 ],
			\partch_o5 -> [ #[0,10,18,25,31,38], nil, 43 ],
			\partch_o6 -> [ #[0,9,16,22,28,33], nil, 43 ],
			\partch_u1 -> [ #[0,9,18,23,29,35], nil, 43 ],
			\partch_u2 -> [ #[0,8,16,25,30,36], nil, 43 ],
			\partch_u3 -> [ #[0,7,14,22,31,37], nil, 43 ],
			\partch_u4 -> [ #[0,6,13,20,28,38], nil, 43 ],
			\partch_u5 -> [ #[0,5,12,18,25,33], nil, 43 ],
			\partch_u6 -> [ #[0,10,15,21,27,34], nil, 43 ],
			
			// hexatonic modes with no tritone
			\hexMajor7 -> [ #[0,2,4,7,9,11], nil, 12 ],
			\hexDorian -> [ #[0,2,3,5,7,10], nil, 12 ],
			\hexPhrygian -> [ #[0,1,3,5,8,10], nil, 12 ],
			\hexSus -> [ #[0,2,5,7,9,10], nil, 12 ],
			\hexMajor6 -> [ #[0,2,4,5,7,9], nil, 12 ],
			\hexAeolian -> [ #[0,3,5,7,8,10], nil, 12 ],
			
			// 7 note scales
			\major -> [ #[0,2,4,5,7,9,11], nil, 12 ],
			\ionian -> [ #[0,2,4,5,7,9,11], nil, 12 ],
			\dorian -> [ #[0,2,3,5,7,9,10], nil, 12 ],
			\phrygian -> [ #[0,1,3,5,7,8,10], nil, 12 ],
			\lydian -> [ #[0,2,4,6,7,9,11], nil, 12 ],
			\mixolydian -> [ #[0,2,4,5,7,9,10], nil, 12 ],
			\aeolian -> [ #[0,2,3,5,7,8,10], nil, 12 ],
			\minor -> [ #[0,2,3,5,7,8,10], nil, 12 ],
			\locrian -> [ #[0,1,3,5,6,8,10], nil, 12 ],
			
			\harmonicMinor -> [ #[0,2,3,5,7,8,11], nil, 12 ],
			\harmonicMajor -> [ #[0,2,4,5,7,8,11], nil, 12 ],
			
			\melodicMinor -> [ #[0,2,3,5,7,9,11], #[0,2,3,5,7,8,10], 12 ],
			\bartok -> [ #[0,2,4,5,7,8,10], nil, 12 ], // jazzers call this the hindu scale
			
			// raga modes
			\todi -> [ #[0,1,3,6,7,8,11], nil, 12 ], // maqam ahar kurd
			\purvi -> [ #[0,1,4,6,7,8,11], nil, 12 ],
			\marva -> [ #[0,1,4,6,7,9,11], nil, 12 ],
			\bhairav -> [ #[0,1,4,5,7,8,11], nil, 12 ],
			\ahirbhairav -> [ #[0,1,4,5,7,9,10], nil, 12 ],
			
			\superLocrian -> [ #[0,1,3,4,6,8,10], nil, 12 ],
			\romanianMinor -> [ #[0,2,3,6,7,9,10], nil, 12 ], // maqam nakriz
			\hungarianMinor -> [ #[0,2,3,6,7,8,11], nil, 12 ],       
			\neapolitanMinor -> [ #[0,1,3,5,7,8,11], nil, 12 ],
			\enigmatic -> [ #[0,1,4,6,8,10,11], nil, 12 ],
			\spanish -> [ #[0,1,4,5,7,8,10], nil, 12 ],
			
			// modes of whole tones with added note ->
			\leadingWhole -> [ #[0,2,4,6,8,10,11], nil, 12 ],
			\lydianMinor -> [ #[0,2,4,6,7,8,10], nil, 12 ],
			\neapolitanMajor -> [ #[0,1,3,5,7,9,11], nil, 12 ],
			\locrianMajor -> [ #[0,2,4,5,6,8,10], nil, 12 ],
			
			// 8 note scales
			\diminished -> [ #[0,1,3,4,6,7,9,10], nil, 12 ],
			\diminished2 -> [ #[0,2,3,5,6,8,9,11], nil, 12 ],
			
			// 12 note scales
			\chromatic -> [ (0..11), nil, 12 ],
			
			// TWENTY-FOUR TONES PER OCTAVE
			
			// maqam ajam
			\ajam -> [ #[0,4,8,10,14,18,22], nil, 24 ],
			\jiharkah -> [ #[0,4,8,10,14,18,21], nil, 24 ],
			\shawqAfza -> [ #[0,4,8,10,14,16,22], nil, 24 ],
			
			// maqam sikah
			\sikah -> [ #[0,3,7,11,14,17,21], #[0,3,7,11,13,17,21], 24 ],
			\huzam -> [ #[0,3,7,9,15,17,21], nil, 24 ],
			\iraq -> [ #[0,3,7,10,13,17,21], nil, 24 ],
			\bastanikar -> [ #[0,3,7,10,13,15,21], nil, 24 ],
			\mustar -> [ #[0,5,7,11,13,17,21], nil, 24 ],
			
			// maqam bayati
			\bayati -> [ #[0,3,6,10,14,16,20], nil, 24 ],
			\karjighar -> [ #[0,3,6,10,12,18,20], nil, 24 ],
			\husseini -> [ #[0,3,6,10,14,17,21], nil, 24 ],
			
			// maqam nahawand
			\nahawand -> [ #[0,4,6,10,14,16,22], #[0,4,6,10,14,16,20], 24 ],
			\farahfaza -> [ #[0,4,6,10,14,16,20], nil, 24 ],
			\murassah -> [ #[0,4,6,10,12,18,20], nil, 24 ],
			\ushaqMashri -> [ #[0,4,6,10,14,17,21], nil, 24 ],
			
			// maqam rast
			\rast -> [ #[0,4,7,10,14,18,21], #[0,4,7,10,14,18,20], 24 ],
			\suznak -> [ #[0,4,7,10,14,16,22], nil, 24 ],
			\nairuz -> [ #[0,4,7,10,14,17,20], nil, 24 ],
			\yakah -> [ #[0,4,7,10,14,18,21], #[0,4,7,10,14,18,20], 24 ],
			\mahur -> [ #[0,4,7,10,14,18,22], nil, 24 ],
			
			// maqam hijaz
			\hijaz -> [ #[0,2,8,10,14,17,20], #[0,2,8,10,14,16,20], 24 ],
			\zanjaran -> [ #[0,2,8,10,14,18,20], nil, 24 ],
			
			// maqam hijazKar
			\zanjaran -> [ #[0,2,8,10,14,16,22], nil, 24 ],
			
			// maqam saba
			\saba -> [ #[0,3,6,8,12,16,20], nil, 24 ],
			\zamzam -> [ #[0,2,6,8,14,16,20], nil, 24 ],
			
			// maqam kurd
			\kurd -> [ #[0,2,6,10,14,16,20], nil, 24 ],
			\kijazKarKurd -> [ #[0,2,8,10,14,16,22], nil, 24 ],
			
			// maqam nawa Athar
			\nawaAthar -> [ #[0,4,6,12,14,16,22], nil, 24 ],
			\nikriz -> [ #[0,4,6,12,14,18,20], nil, 24 ],
			\atharKurd -> [ #[0,2,6,12,14,16,22], nil, 24 ],
		];
	}
	
	*new { | degrees, tuning, descDegrees |
		// can't use arg defaults because nils are passed in by doesNotUnderstand
		// nils in tuning handled after stepsPerOctave determined
		// nil for descDegrees is OK
		^super.new.init(degrees ? \ionian, tuning, descDegrees);
	}
	
	init { | inDegrees, inTuning, inDescDegrees |
		// Degrees may or may not set the stepsPerOctave
		this.degrees_(inDegrees);
		// Tuning will use stepsPerOctave if set; if not
		// will guess based on scale contents
		this.tuning_(inTuning);
		this.descDegrees_(inDescDegrees ? inDegrees);
		stepsPerOctave = stepsPerOctave ? tuning.size;
		^this.checkForMismatch
	}
	
	checkForMismatch {
		(stepsPerOctave != tuning.size).if({
			(
				"Scale steps per octave " ++ stepsPerOctave ++ 
				" does not match tuning size " ++
				tuning.size ++ ": using default tuning"
			).warn;
			tuning = Tuning.default(stepsPerOctave);
		});
		^this
	}
	
	degrees_ { | inDegrees |
		var key;
		inDegrees.isKindOf(SequenceableCollection).if({			degrees = inDegrees.asArray;
			(degrees != degrees.asInteger).if({
				"Truncating non-integer scale degrees.".warn;
				degrees = degrees.asInteger;
			});
			name = "scale" ++ UniqueID.next.asString;
			setStepsNextTuning = true;
		}, {
			key = inDegrees.asSymbol ? \ionian;
			#degrees, descDegrees, stepsPerOctave = scaleDict[ key ];
			name = key.asString
		})
	}
	
	descDegrees_ { | inDescDegrees |
		inDescDegrees.isKindOf(SequenceableCollection).if({
			descDegrees = inDescDegrees.asArray;
		}, {
			descDegrees = scaleDict.includesKey(inDescDegrees.asSymbol).if({
				scaleDict[ inDescDegrees ][ 1 ] ? scaleDict[ inDescDegrees ][ 0 ];
			}, {
				nil
			})
		});
	}
	
	tuning_ { | inTuning |
		var targetSteps;
		targetSteps = setStepsNextTuning.if({ this.guessSPO }, { stepsPerOctave });
		inTuning.isKindOf(Tuning).if({
			tuning = inTuning;
		}, {
			tuning = inTuning.notNil.if({
				Tuning.new(inTuning, targetSteps);
			}, {
				Tuning.default(targetSteps);
			})
		});
		setStepsNextTuning.if({ setStepsNextTuning = false; stepsPerOctave = tuning.size });
	}
	
	guessSPO {
		// most common flavors of ET
		// pick the smallest one that contains all scale degrees
		var etTypes = #[12, 19, 24, 53, 128];
		^etTypes[etTypes.indexInBetween(degrees.maxItem).ceil];
	}
	
	scale_ { | degrees, tuning, descDegrees |
		degrees.notNil.if({ this.degrees_(degrees) });
		tuning.notNil.if({ this.tuning_(tuning) });
		this.descDegrees_(descDegrees ? degrees);
	}
	
	asArray {
		^this.semitones
	}
	
	asADArray {
		^this.semitones(false) ++ this.semitones(true).reverse.drop(1)
	}
	
	adDegrees {
		^degrees ++ (descDegrees ? degrees).reverse.drop(1)
	}
	
	adRatios {
		^this.asADArray.midiratio
	}
	
	asFloatArray {
		var array, fa;
		array = this.asArray;
		^FloatArray.new(array.size).addAll(array);
	}
	
	size {
		^degrees.size
	}
	
	semitones { |desc = false|
		desc.if({
			^descDegrees !? descDegrees.collect({ |x| tuning.wrapAt(x) });
		},{
			this.checkForMismatch;
			^degrees.collect({ |x| tuning.wrapAt(x) });
		})
	}
	
	cents { |desc = false|
		^this.semitones * 100
	}
	
	ratios {
		^this.semitones.midiratio
	}
	
	descending {
		|index|
		^descDegrees.notNil && (index < lastIndex)
	}
	
	at { |index|
		^this.semitones(this.descending(index)).at(index) <! ( lastIndex = index )
	}
	
	wrapAt { |index|
		^this.semitones(this.descending(index)).wrapAt(index) <! ( lastIndex = index )
	}
	
	degreeToRatio { |degree, octave = 0|
		^this.ratios.at(degree) * (2 ** octave);
	}
	
	degreeToFreq { |degree, rootFreq, octave|
		^this.degreeToRatio(degree, octave) * rootFreq;
	}
	
	*choose { |size, tuning|
		// this is a bit pretzely, but allows steps and tuning to be constrained
		// independently, while still making sure everything matches up
		var randomScale, randomTuning, steps, selectFunc;
		randomTuning = tuning !? tuning.isKindOf(Tuning).if({ tuning }, { Tuning.new(tuning) });
		selectFunc = size.isNil.if({
			randomTuning.isNil.if({
				{ true }
			}, {
				{ |k| scaleDict[ k ][ 2 ] == randomTuning.size }
			})
		}, {
			{ |k| scaleDict[ k ][ 0 ].size == size }
		});
		randomScale = scaleDict.keys.select(selectFunc).choose;
		randomTuning = randomScale.isNil.if({
			("No scales matching criteria " ++ [size, tuning].asString ++ " available.").warn;
			\et12
		}, {
			randomTuning ? Tuning.choose(scaleDict[ randomScale ][ 2 ])
		});
		^super.new.init(randomScale ? \ionian, randomTuning)
	}
	
	*doesNotUnderstand { |selector, args|
		^(scaleDict.includesKey(selector)).if({
			this.new(selector, args)
		}, {
			super.doesNotUnderstand(selector, args)
		})
	}
	
	doesNotUnderstand { |selector, args|
		var target;
		target = this.semitones;
		^target.respondsTo(selector).if({
			target.perform(selector, args)
		}, {
			super.doesNotUnderstand(selector, args)
		})
	}
	
	*names {
		^scaleDict.keys.asArray.sort.asString
	}

}

Tuning {

	classvar tuningDict, defaults;
	var <tuning, <>name;
	
	*initClass {
		defaults = IdentityDictionary[
			43 -> \partch
		];
		
		tuningDict = IdentityDictionary[

			//TWELVE-TONE TUNINGS
			\et12 -> (0..11),

			//pythagorean
			\pythagorean -> [1, 256/243, 9/8, 32/27, 81/64, 4/3, 729/512, 3/2,
				128/81, 27/16, 16/9, 243/128].ratiomidi,
			
			//5-limit tritone
			\just -> [1, 16/15, 9/8, 6/5, 5/4, 4/3, 45/32, 3/2, 8/5, 5/3, 9/5, 15/8].ratiomidi,
			
			//septimal tritone
			\sept1 -> [1, 16/15, 9/8, 6/5, 5/4, 4/3, 7/5, 3/2, 8/5, 5/3, 9/5, 15/8].ratiomidi,
			
			//septimal tritone and minor seventh
			\sept2 -> [1, 16/15, 9/8, 6/5, 5/4, 4/3, 7/5, 3/2, 8/5, 5/3, 7/4, 15/8].ratiomidi,
		
			//meantone, 1/4 syntonic comma
			\mean4 -> #[0, 0.755, 1.93, 3.105, 3.86, 5.035, 5.79, 6.965, 7.72, 8.895, 10.07, 10.82],
		
			//meantone, 1/5 Pythagorean comma
			\mean5 -> #[0, 0.804, 1.944, 3.084, 3.888, 5.028, 5.832, 6.972, 7.776, 8.916, 10.056, 10.86],
		
			//meantone, 1/6 Pythagorean comma
			\mean6 -> #[0, 0.86, 1.96, 3.06, 3.92, 5.02, 5.88, 6.98, 7.84, 8.94, 10.04, 10.9],		
			//Kirnberger III
			\kirnberger -> [1, 256/243, (5.sqrt)/2, 32/27, 5/4, 4/3, 45/32, 5 ** 0.25,
				128/81, (5 ** 0.75)/2, 16/9, 15/8].ratiomidi,
		
			//Werckmeister III
			\werckmeister -> #[0, 0.92, 1.93, 2.94, 3.915, 4.98, 5.9, 6.965, 7.93, 8.895, 9.96, 10.935],	
			//Vallotti
			\vallotti -> #[0, 0.94135, 1.9609, 2.98045, 3.92180, 5.01955, 5.9218, 6.98045,
				7.9609, 8.94135, 10, 10.90225],
				
			//Young
			\young -> #[0, 0.9, 1.96, 2.94, 3.92, 4.98, 5.88, 6.98, 7.92, 8.94, 9.96, 10.9],
				
			//Mayumi Reinhard
			\reinhard -> [1, 14/13, 13/12, 16/13, 13/10, 18/13, 13/9, 20/13, 13/8, 22/13,
				13/7, 208/105].ratiomidi,
				
			//Wendy Carlos Harmonic
			\wcHarm -> [1, 17/16, 9/8, 19/16, 5/4, 21/16, 11/8, 3/2, 13/8, 27/16, 7/4, 15/8].ratiomidi,
			
			//Wendy Carlos Super Just
			\wcSJ -> [1, 17/16, 9/8, 6/5, 5/4, 4/3, 11/8, 3/2, 13/8, 5/3, 7/4, 15/8].ratiomidi,
			
			//MORE THAN TWELVE-TONE ET
			\et19 -> ((0 .. 18) * 12/19),
			\et22 -> ((0 .. 21) * 6/11),
			\et24 -> ((0 .. 23) * 0.5),
			\et31 -> ((0 .. 30) * 12/31),
			\et41 -> ((0 .. 40) * 12/41),
			\et53 -> ((0 .. 52) * 12/53),
		
			//NON-TWELVE-TONE JI	
			//Ben Johnston
			\johnston -> [1, 25/24, 135/128, 16/15, 10/9, 9/8, 75/64, 6/5, 5/4, 81/64, 32/25, 
				4/3, 27/20, 45/32, 36/25, 3/2, 25/16, 8/5, 5/3, 27/16, 225/128, 16/9, 9/5,
				15/8, 48/25].ratiomidi,
				
			//Harry Partch
			\partch -> [1, 81/80, 33/32, 21/20, 16/15, 12/11, 11/10, 10/9, 9/8, 8/7, 7/6,
				32/27, 6/5, 11/9, 5/4, 14/11, 9/7, 21/16, 4/3, 27/20, 11/8, 7/5, 10/7, 16/11,
				40/27, 3/2, 32/21, 14/9, 11/7, 8/5, 18/11, 5/3, 27/16, 12/7, 7/4, 16/9, 9/5, 
				20/11, 11/6, 15/8, 40/21, 64/33, 160/81].ratiomidi,
				
			//Jon Catler
			\catler -> [1, 33/32, 16/15, 9/8, 8/7, 7/6, 6/5, 128/105, 16/13, 5/4, 21/16,
				4/3, 11/8, 45/32, 16/11, 3/2, 8/5, 13/8, 5/3, 27/16, 7/4, 16/9, 24/13, 15/8].ratiomidi,
				
			//John Chalmers
			\chalmers -> [1, 21/20, 16/15, 9/8, 7/6, 6/5, 5/4, 21/16, 4/3, 7/5, 35/24, 3/2,
				63/40, 8/5, 5/3, 7/4, 9/5, 28/15, 63/32].ratiomidi,
				
			//Lou Harrison
			\harrison -> [1, 16/15, 10/9, 8/7, 7/6, 6/5, 5/4, 4/3, 17/12, 3/2, 8/5, 5/3,
				12/7, 7/4, 9/5, 15/8].ratiomidi,
		
			//sruti
			\sruti -> [1, 256/243, 16/15, 10/9, 9/8, 32/27, 6/5, 5/4, 81/64, 4/3, 27/20,
				45/32, 729/512, 3/2, 128/81, 8/5, 5/3, 27/16, 16/9, 9/5, 15/8, 243/128].ratiomidi,
		
			//HARMONIC SERIES -- length arbitary
			\harmonic -> (1 .. 24).ratiomidi,
		
			//NO OCTAVE
			//Bohlen-Pierce
			\bp -> ((0 .. 12) * (3.ratiomidi/13)),
			
			//Wendy Carlos scales -- length arbitrary
			\wcAlpha -> ((0 .. 127) * 0.78),
			\wcBeta -> ((0 .. 127) * 0.638),
			\wcGamma -> ((0 .. 255) * 0.351)
		];
	}	

	*new { | tuning, stepsPerOctave |
		^super.new.init(tuning ? \et12, stepsPerOctave ? 12);
	}
	
	*default { | stepsPerOctave |
		^defaults.includesKey(stepsPerOctave).if({
			super.new.init(defaults[stepsPerOctave])
		}, {
			super.new.init(this.calcDefault(stepsPerOctave)).
				name_(this.defaultName(stepsPerOctave));
		})
	}
	
	*et { |stepsPerOctave|
		^super.new.init(this.calcET(stepsPerOctave)).name_(this.etName);
	}
	
	*calcET { | stepsPerOctave |
		^(0..(stepsPerOctave - 1)) * (12/stepsPerOctave)
	}
	
	*calcDefault { | stepsPerOctave |
		^this.calcET(stepsPerOctave)
	}
	
	*choose { |size = 12|
		var validTunings;
		validTunings = tuningDict.keys.select({ |t| tuningDict[t].size == size });
		^super.new.init(validTunings.choose)
	}
	
	*defaultName { |stepsPerOctave|
		^this.etName(stepsPerOctave)
	}
	
	*etName { |stepsPerOctave|
		^"et" ++ stepsPerOctave.asString
	}
	
	init { | inTuning, inStepsPerOctave |
		^this.tuning_(inTuning, inStepsPerOctave);
	}
		
	tuning_ { | inTuning, inStepsPerOctave = 12 |
		inTuning.isKindOf(SequenceableCollection).if({
			tuning = inTuning.asArray;
			name = "tuning" ++ UniqueID.next.asString;
		}, {
			tuningDict.includesKey(inTuning.asSymbol).if({
				tuning = tuningDict[ inTuning.asSymbol ];
				name = inTuning.asString;
			}, {
				("Unknown tuning: " ++ inTuning).warn;
				tuning = this.class.calcDefault(inStepsPerOctave);
				name = this.class.defaultName(inStepsPerOctave);
			})	
		});
	}

	cents_ { |cents|
		^this.tuning_(cents / 100)
	}
	
		
	ratios {
		^tuning.midiratio
	}
	
	ratioAt {
		|index|
		^this.ratios.at(index)
	}
	
	semitones {
		^tuning
	}
	
	asArray {
		^this.semitones
	}
	
	asFloatArray {
		^FloatArray.newClear(tuning.size).addAll(tuning);
	}
	
	size {
		^tuning.size;
	}
	
	*doesNotUnderstand { |selector, args|
		^(tuningDict.includesKey(selector)).if({
			this.new(selector, args)
		}, {
			super.doesNotUnderstand(selector, args)
		})
	}
	
	doesNotUnderstand { |selector, args|
		^tuning.respondsTo(selector).if({
			tuning.perform(selector, args)
		}, {
			super.doesNotUnderstand(selector, args)
		})
	}
	
	*names {
		^tuningDict.keys.asArray.sort.asString
	}
}


*/





/*
Thor comments:


1) It would be nice if this would be possible:
a = ScaleTest.ionian;
a.scale
If we use a getter on the scale variable.


2) When I try to set a new scale WITH a new tuning, the tuning doesn't seem to change

// I think this should be possible:
a.scale_(\ionian, \wcSJ);
// coming from bayati in \et24

I can see why this is not possible (the inStepsPerOctave being the 2nd arg)
but is that really needed? Will anyone ever use that? Better provide a tuning.
(for example a custom made tuning)
a.scale_(\ionian, TuningTest([0,0.8, 2.1, etc.]));


3) Would it be good to have a FloatArray function?

	asFloatArray {
		^scale.copy.asFloatArray;
	}
	

4) Question: in asArray, why do you do return a copy of the scale? 
	asArray {
		^scale.copy;
	}


5) If someone is going to show all available scales in a menu (s)he should be
able to get all the names from the dictionary. Perhaps like this:

	scaleNames {
		^scaleDict.keys.asArray.sort.asString;
	}

// not sure about the necessity of .asString above, but for GUI purposes it's good.

Where we can do:

Post << ScaleTest().scaleNames


6) similarily for tuning, we could get at the tuning types:

	tuningTypes {
		^tuningDict.keys.asArray.sort.asString;
	}

Post << TuningTest().tuningTypes


7) For some reason I couldn't change a custom scale in real-time whilst playing the pattern:

// or make up your own arbitrary scales and tunings
a = ScaleTest.new(
	#[0, 2, 3, 4, 5, 6, 7, 8, 11],
	[0, 0.8, 2.1, 3, 4.05, 5.2, 6, 6.75, 8.3, 9, 10.08, 11.5],
	12
)




*/

/*
I realized that if the tuning was stored with the scale, I could make it work just like an array of floats for playing purposes. Using the attached class file, try this to see what I mean:

(
a = ScaleTest.ionian;

Pbind(\note, PdegreeToKey(
			Pseq([0, 1, 2, 3, 4, 5, 6, 7].mirror, inf),
			a,
			a.stepsPerOctave
		),
	\dur, 0.25
).play;
)

// change scale
a.scale_(\phrygian);

// change tuning (much nicer!)
a.tuning_(\et12);
a.tuning_(\wcSJ);

(
// change both -- should be done simultaneously when switching
// number of steps per octave
a.update(\bayati, \et24);
)


// ... but if you don't, we warn you and continue in ET
a.scale_(\ionian);
a.scale_(\ionian, \wcSJ);

a.tuning_(\partch);

// can also set tuning at creation time
a = ScaleTest.ionian(\pythagorean);

(
// or make up your own arbitrary scales and tunings
a = ScaleTest.new(
	#[0, 2, 3, 4, 5, 6, 7, 8, 11],
	[0, 0.8, 2.1, 3, 4.05, 5.2, 6, 6.75, 8.3, 9, 10.08, 11.5],
	12
)
)

a = ScaleTest(\ionian).asArray.asFloatArray
*/














/*


ScaleTest {

	classvar scaleDict;
	var <scale, <stepsPerOctave, <tuning;
	
	*initClass {
		scaleDict = IdentityDictionary[
		
			// TWELVE TONES PER OCTAVE
			// 5 note scales
			\minorPentatonic -> [ #[0,3,5,7,10], 12 ],
			\majorPentatonic -> [ #[0,2,4,7,9], 12 ],
			\ritusen -> [ #[0,2,5,7,9], 12 ], // another mode of major pentatonic
			\egyptian -> [ #[0,2,5,7,10], 12 ], // another mode of major pentatonic
		
			\kumoi -> [ #[0,2,3,7,9], 12 ],
			\hirajoshi -> [ #[0,2,3,7,8], 12 ],
			\iwato -> [ #[0,1,5,6,10], 12 ], // mode of hirajoshi
			\chinese -> [ #[0,4,6,7,11], 12 ], // mode of hirajoshi
			\indian -> [ #[0,4,5,7,10], 12 ],
			\pelog -> [ #[0,1,3,7,8], 12 ],
		
			\prometheus -> [ #[0,2,4,6,11], 12 ],
			\scriabin -> [ #[0,1,4,7,9], 12 ],
			
			///////////////
			// han chinese pentatonic scales
			\gong -> [ #[0, 2, 4, 7, 9], 12 ],
			\shang -> [ #[0, 2, 5, 7, 10], 12 ],
			\jiao -> [ #[0,3, 5, 8, 10], 12 ],
			\zhi -> [ #[0,2,5,7,9], 12 ],
			\yu -> [ #[0,3,5,7,10], 12 ],
			//////////////////////
		
			// 6 note scales
			\whole -> (0,2..10),
			\augmented -> [ #[0,3,4,7,8,11], 12 ],
			\augmented2 -> [ #[0,1,4,5,8,9], 12 ],
		
			// hexatonic modes with no tritone
			\hexMajor7 -> [ #[0,2,4,7,9,11], 12 ],
			\hexDorian -> [ #[0,2,3,5,7,10], 12 ],
			\hexPhrygian -> [ #[0,1,3,5,8,10], 12 ],
			\hexSus -> [ #[0,2,5,7,9,10], 12 ],
			\hexMajor6 -> [ #[0,2,4,5,7,9], 12 ],
			\hexAeolian -> [ #[0,3,5,7,8,10], 12 ],
		
			// 7 note scales
			\major -> [ #[0,2,4,5,7,9,11], 12 ],
			\ionian -> [ #[0,2,4,5,7,9,11], 12 ],
			\dorian -> [ #[0,2,3,5,7,9,10], 12 ],
			\phrygian -> [ #[0,1,3,5,7,8,10], 12 ],
			\lydian -> [ #[0,2,4,6,7,9,11], 12 ],
			\mixolydian -> [ #[0,2,4,5,7,9,10], 12 ],
			\aeolian -> [ #[0,2,3,5,7,8,10], 12 ],
			\minor -> [ #[0,2,3,5,7,8,10], 12 ],
			\locrian -> [ #[0,1,3,5,6,8,10], 12 ],
		
			\harmonicMinor -> [ #[0,2,3,5,7,8,11], 12 ],
			\harmonicMajor -> [ #[0,2,4,5,7,8,11], 12 ],
		
			\melodicMinor -> [ #[0,2,3,5,7,9,11], 12 ],
			\bartok -> [ #[0,2,4,5,7,8,10], 12 ], // jazzers call this the hindu scale
		
			// raga modes
			\todi -> [ #[0,1,3,6,7,8,11], 12 ], // maqam ahar kurd
			\purvi -> [ #[0,1,4,6,7,8,11], 12 ],
			\marva -> [ #[0,1,4,6,7,9,11], 12 ],
			\bhairav -> [ #[0,1,4,5,7,8,11], 12 ],
			\ahirbhairav -> [ #[0,1,4,5,7,9,10], 12 ],
		
			\superLocrian -> [ #[0,1,3,4,6,8,10], 12 ],
			\romanianMinor -> [ #[0,2,3,6,7,9,10], 12 ], // maqam nakriz
			\hungarianMinor -> [ #[0,2,3,6,7,8,11], 12 ],       
			\neapolitanMinor -> [ #[0,1,3,5,7,8,11], 12 ],
			\enigmatic -> [ #[0,1,4,6,8,10,11], 12 ],
			\spanish -> [ #[0,1,4,5,7,8,10], 12 ],
		
			// modes of whole tones with added note ->
			\leadingWhole -> [ #[0,2,4,6,8,10,11], 12 ],
			\lydianMinor -> [ #[0,2,4,6,7,8,10], 12 ],
			\neapolitanMajor -> [ #[0,1,3,5,7,9,11], 12 ],
			\locrianMajor -> [ #[0,2,4,5,6,8,10], 12 ],
		
			// 8 note scales
			\diminished -> [ #[0,1,3,4,6,7,9,10], 12 ],
			\diminished2 -> [ #[0,2,3,5,6,8,9,11], 12 ],
		
			// 12 note scales
			\chromatic -> [ (0..11), 12 ],
			
			// TWENTY-FOUR TONES PER OCTAVE
			\bayati -> [ #[0, 3, 6, 10, 14, 16, 20], 24 ],
		];

	}
	
	*new { | scale, tuning |
		// can't use arg defaults because nils are passed in by doesNotUnderstand
		// nils in tuning handled after stepsPerOctave determined
		^super.new.init(scale ? \ionian, tuning);
	}
	
	init { | inScale, inTuning |
		// Scale may or may not set the stepsPerOctave
		this.scale_(inScale);
		// Tuning will use stepsPerOctave if set; if not
		// will guess based on scale contents
		this.tuning_(inTuning);
		stepsPerOctave = stepsPerOctave ? tuning.size;
		^this.checkForMismatch
	}
	
	checkForMismatch {
		(stepsPerOctave != tuning.size).if({
			("Scale steps per octave " ++ stepsPerOctave ++ " does not match tuning size " ++
				tuning.size ++ ": using default tuning").warn;
			tuning = Tuning.default(stepsPerOctave);
		});
		^this
	}
	
	scale_ { | inScale |
		inScale.isKindOf(Collection).if({
			scale = inScale.asArray;
		}, {
			scaleDict.includesKey(inScale).if({
				scale = scaleDict[ inScale ][ 0 ];
				stepsPerOctave = scaleDict[ inScale ][ 1 ];
			}, {
				("Unknown scale: " ++ inScale).warn;
				scale = scaleDict[ \ionian ][ 0 ];
				stepsPerOctave = scaleDict[ \ionian ][ 1 ];
			})	
		});
	}
	
	tuning_ { | inTuning |
		inTuning.isKindOf(Tuning).if({
			tuning = inTuning;
		}, {
			tuning = inTuning.notNil.if({
				Tuning.new(inTuning, stepsPerOctave ? this.guessSPO);
			}, {
				Tuning.default(stepsPerOctave ? this.guessSPO);
			})
		});
	}
	
	guessSPO {
		// most common flavors of ET
		// pick the smallest one that contains all scale degrees
		var etTypes = #[12, 19, 24, 53, 128];
		^etTypes[etTypes.indexInBetween(scale.maxItem).ceil];
	}
	
	update { | scale, tuning |
		this.scale_(scale);
		this.tuning_(tuning);
	}
	
	asArray {
		^scale.copy;
	}
	
	size {
		^scale.size;
	}
	
	asMIDI {
		this.checkForMismatch;
		^scale.collect({ |x| tuning.wrapAt(x) })
	}
	
	asRatios {
		^this.asMIDI.midiratio;
	}
	
	degreeToRatio { |degree, octave = 0|
		^this.asRatios.at(degree) * (2 ** octave);
	}
	
	degreeToFreq { |degree, rootFreq, octave|
		^this.degreeToRatio(degree, octave) * rootFreq;
	}
	
	*choose {
		var randomScale;
		randomScale = scaleDict.keys.choose;
		^super.new.init(randomScale, Tuning.choose(scaleDict[ randomScale ][ 1 ]))
	}
	
	*doesNotUnderstand { |selector, args|
		^(scaleDict.includesKey(selector)).if({
			this.new(selector, args)
		}, {
			super.doesNotUnderstand(selector, args)
		})
	}
	
	doesNotUnderstand { |selector, args|
		^this.asMIDI.perform(selector, args)
	}

}

Tuning {

	classvar tuningDict;
	var <tuning;
	
	*initClass {
		tuningDict = IdentityDictionary[

			//TWELVE-TONE TUNINGS
			\et12 -> (0..11),

			//pythagorean
			\pythagorean -> [1, 256/243, 9/8, 32/27, 81/64, 4/3, 729/512, 3/2,
				128/81, 27/16, 16/9, 243/128].ratiomidi,
			
			//5-limit tritone
			\just -> [1, 16/15, 9/8, 6/5, 5/4, 4/3, 45/32, 3/2, 8/5, 5/3, 9/5, 15/8].ratiomidi,
			
			//septimal tritone
			\sept1 -> [1, 16/15, 9/8, 6/5, 5/4, 4/3, 7/5, 3/2, 8/5, 5/3, 9/5, 15/8].ratiomidi,
			
			//septimal tritone and minor seventh
			\sept2 -> [1, 16/15, 9/8, 6/5, 5/4, 4/3, 7/5, 3/2, 8/5, 5/3, 7/4, 15/8].ratiomidi,
		
			//meantone, 1/4 syntonic comma
			\mean4 -> #[0, 0.755, 1.93, 3.105, 3.86, 5.035, 5.79, 6.965, 7.72, 8.895, 10.07, 10.82],
		
			//meantone, 1/5 Pythagorean comma
			\mean5 -> #[0, 0.804, 1.944, 3.084, 3.888, 5.028, 5.832, 6.972, 7.776, 8.916, 10.056, 10.86],
		
			//meantone, 1/6 Pythagorean comma
			\mean6 -> #[0, 0.86, 1.96, 3.06, 3.92, 5.02, 5.88, 6.98, 7.84, 8.94, 10.04, 10.9],		
			//Kirnberger III
			\kirnberger -> [1, 256/243, (5.sqrt)/2, 32/27, 5/4, 4/3, 45/32, 5 ** 0.25,
				128/81, (5 ** 0.75)/2, 16/9, 15/8].ratiomidi,
		
			//Werckmeister III
			\werckmeister -> #[0, 0.92, 1.93, 2.94, 3.915, 4.98, 5.9, 696.5, 7.93, 8.895, 9.96, 10.935],	
			//Vallotti
			\vallotti -> #[0, 0.94135, 1.9609, 2.98045, 3.92180, 5.01955, 5.9218, 6.98045,
				7.9609, 8.94135, 10, 10.90225],
				
			//Young
			\young -> #[0, 0.9, 1.96, 2.94, 3.92, 4.98, 5.88, 6.98, 7.92, 8.94, 9.96, 10.9],
				
			//Mayumi Reinhard
			\reinhard -> [1, 14/13, 13/12, 16/13, 13/10, 18/13, 13/9, 20/13, 13/8, 22/13,
				13/7, 208/105].ratiomidi,
				
			//Wendy Carlos Harmonic
			\wcHarm -> [1, 17/16, 9/8, 19/16, 5/4, 21/16, 11/8, 3/2, 13/8, 27/16, 7/4, 15/8].ratiomidi,
			
			//Wendy Carlos Super Just
			\wcSJ -> [1, 17/16, 9/8, 6/5, 5/4, 4/3, 11/8, 3/2, 13/8, 5/3, 7/4, 15/8].ratiomidi,
			
			//MORE THAN TWELVE-TONE ET
			\et19 -> ((0 .. 18) * 12/19),
			\et22 -> ((0 .. 21) * 6/11),
			\et24 -> ((0 .. 23) * 0.5),
			\et31 -> ((0 .. 30) * 12/31),
			\et41 -> ((0 .. 40) * 12/41),
			\et53 -> ((0 .. 52) * 12/53),
		
			//NON-TWELVE-TONE JI	
			//Ben Johnston
			\johnston -> [1, 25/24, 135/128, 16/15, 10/9, 9/8, 75/64, 6/5, 5/4, 81/64, 32/25, 
				4/3, 27/20, 45/32, 36/25, 3/2, 25/16, 8/5, 5/3, 27/16, 225/128, 16/9, 9/5,
				15/8, 48/25].ratiomidi,
				
			//Harry Partch
			\partch -> [1, 81/80, 33/32, 21/20, 16/15, 12/11, 11/10, 10/9, 9/8, 8/7, 7/6,
				32/27, 6/5, 11/9, 5/4, 14/11, 9/7, 21/16, 4/3, 27/20, 11/8, 7/5, 10/7, 16/11,
				40/27, 3/2, 32/21, 14/9, 11/7, 8/5, 18/11, 5/3, 27/16, 12/7, 7/4, 16/9, 9/5, 
				20/11, 11/6, 15/8, 40/21, 64/33, 160/81].ratiomidi,
				
			//Jon Catler
			\catler -> [1, 33/32, 16/15, 9/8, 8/7, 7/6, 6/5, 128/105, 16/13, 5/4, 21/16,
				4/3, 11/8, 45/32, 16/11, 3/2, 8/5, 13/8, 5/3, 27/16, 7/4, 16/9, 24/13, 15/8].ratiomidi,
				
			//John Chalmers
			\chalmers -> [1, 21/20, 16/15, 9/8, 7/6, 6/5, 5/4, 21/16, 4/3, 7/5, 35/24, 3/2,
				63/40, 8/5, 5/3, 7/4, 9/5, 28/15, 63/32].ratiomidi,
				
			//Lou Harrison
			\harrison -> [1, 16/15, 10/9, 8/7, 7/6, 6/5, 5/4, 4/3, 17/12, 3/2, 8/5, 5/3,
				12/7, 7/4, 9/5, 15/8].ratiomidi,
		
			//sruti
			\sruti -> [1, 256/243, 16/15, 10/9, 9/8, 32/27, 6/5, 5/4, 81/64, 4/3, 27/20,
				45/32, 729/512, 3/2, 128/81, 8/5, 5/3, 27/16, 16/9, 9/5, 15/8, 243/128].ratiomidi,
		
			//HARMONIC SERIES -- length arbitary
			\harmonic -> (1 .. 24).ratiomidi,
		
			//NO OCTAVE
			//Bohlen-Pierce
			\bp -> ((0 .. 12) * (3.ratiomidi/13)),
			
			//Wendy Carlos scales -- length arbitrary
			\wcAlpha -> ((0 .. 127) * 0.78),
			\wcBeta -> ((0 .. 127) * 0.638),
			\wcGamma -> ((0 .. 255) * 0.351)
		];
	}	

	*new { | tuning, stepsPerOctave |
		^super.new.init(tuning ? \et12, stepsPerOctave ? 12);
	}
	
	*default { | stepsPerOctave |
		^super.new.init(this.calcDefault(stepsPerOctave))
	}
	
	*calcDefault { | stepsPerOctave |
		^(0..(stepsPerOctave - 1)) * (12/stepsPerOctave)
	}
	
	*choose { |size = 12|
		var validTunings;
		validTunings = tuningDict.select({ |t| t.size == size });
		^super.new.init(validTunings.choose)
	}
	
	init { | inTuning, inStepsPerOctave |
		^this.tuning_(inTuning, inStepsPerOctave);
	}
		
	tuning_ { | inTuning, inStepsPerOctave = 12 |
		inTuning.isKindOf(Collection).if({
			tuning = inTuning.asArray;
		}, {
			tuningDict.includesKey(inTuning).if({
				tuning = tuningDict[ inTuning ];
			}, {
				("Unknown tuning: " ++ inTuning).warn;
				tuning = this.class.calcDefault(inStepsPerOctave);
			})	
		});
	}
		
	asArray {
		^tuning.copy;
	}
	
	size {
		^tuning.size;
	}
	
	*doesNotUnderstand { |selector, args|
		^(tuningDict.includesKey(selector)).if({
			this.new(selector, args)
		}, {
			super.doesNotUnderstand(selector, args)
		})
	}
	
	doesNotUnderstand { |selector, args|
		{ ^tuning.perform(selector, args) }.try({ |exception|
			"Error accessing tuning array.".postln;
			^exception.reportError 
		});
	}
	
}

*/









// old versions


/*
ScaleTest {

	classvar scaleDict;
	var scale;
	
	*initClass {
		scaleDict = IdentityDictionary[
			\ionian -> [0, 2, 4, 5, 7, 9, 10],
			\aeolian -> [0, 2, 3, 5, 7, 8, 10],
			\bayati -> [0, 1.5, 3, 5, 7, 8, 10],
			// etc.
		];
	}
	
	*new { | scalename |
		^scalename.notNil.if({ super.new.init(scalename) }, { super.new })
	}
	
	init { | scalename |
		scale = scaleDict[ scalename ];
		^scale.isNil.if({ "no scale with this name".warn; nil }, { this })
	}
	
	scale_ { | scalename |
		scale = this.init(scalename);
	}
	
	asArray {
		^scale;
	}
	
	asFloatArray {
		^scale.asFloatArray;
	}
	
	asRatios {
		var root;
		root = scale[0].midicps;
		^scale.collect({ |x| x.midicps/root })
	}
		
	*doesNotUnderstand { |selector, args|
		^(scaleDict.includesKey(selector)).if({
			this.new(selector)
		}, {
			super.doesNotUnderstand(selector, args)
		})
	}
}



ScaleTest {

	classvar scaleDict;
	var scale;

	*initClass {
		scaleDict = IdentityDictionary[
			\ionian -> [0, 2, 4, 5, 7, 9, 10],
			\aeolian -> [0, 2, 3, 5, 7, 8, 10],
			// etc.
		];
	}

	*new { | scalename |
		^scalename.notNil.if({ super.new.init(scalename) }, { super.new })
	}

	init { | scalename |
		scale = scaleDict[ scalename ];
		^scale.isNil.if({ "no scale with this name".warn; nil }, { scale })
	}
	
	scale_ { | scalename |
		scale = this.init(scalename);
	}

	scale {
		^scale;
	}

	asRatios { | notesInOctave=12 |
		var ratios;
		ratios = notesInOctave.collect({|i| 2.pow(i/notesInOctave)});
		^ratios[scale]
	}

	*doesNotUnderstand { |selector, args|
		^(scaleDict.includesKey(selector)).if({
			this.new(selector)
		}, {
			super.doesNotUnderstand(selector, args)
		})
	}
}

+ Array {
	asRatios { | notesInOctave=12 |
		var ratios;
		ratios = notesInOctave.collect({|i| 2.pow(i/notesInOctave)});
		^ratios[this]
	}
}



TESTING:

// mode 1

a = ScaleTest(\bayati).asArray

a.asRatios
a = ScaleTest(\aeolian).asRatios
ScaleTest(\ionian).asFloatArray


// mode 2

a = ScaleTest.new
a.scale = \ionian
a
a.scale
a.asRatios

*/