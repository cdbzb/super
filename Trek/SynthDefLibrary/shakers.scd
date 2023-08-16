
SynthDef(\shakeEnv,{ |instrument=0 inst|
//TODO add up!
	var time = \time.kr(0.05);
	var env = Env([0,1,0,0] ,[0.05,0.00,10]).kr(0,gate:\up.tr(0));
	var env2 = Env([0,1,0,0],[0,time,0]);
	env2= EnvGen.ar(env2,\down.tr(0));
	inst.notNil.if{instrument = inst};
	Shakers.ar(
		energy: env + env2 * \amp.kr(1),
		instrument:instrument
	)
	* Env.cutoff(5).kr(2,gate:\gate.kr(1))
	=> Out.ar(\out.kr(0),_)
}).add.tag(\perc)


/*
Maraca = 0
Cabasa = 1
Sekere = 2
Tambourine = 3
Sleigh Bells = 4
Bamboo Chimes = 5
Sand Paper = 6
Coke Can = 7
Sticks = 8
Crunch = 9
Big Rocks = 10
Little Rocks = 11
Next Mug = 12
Penny + Mug = 13
Nickle + Mug = 14
Dime + Mug = 15
Quarter + Mug = 16
Franc + Mug = 17
Peso + Mug = 18
Guiro = 19
Wrench = 20
Water Drops = 21
Tuned Bamboo Chimes = 22
*/
