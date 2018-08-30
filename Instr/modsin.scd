(
	Instr(\modsin,{|freq=400,rate=5,width=0.05,amp=0.1, release=1,gate=1| var env; 
		env=EnvGen.kr(Env.asr(0,1,release),gate,doneAction:2);
		//env=1;
		ModSin(freq,rate, width,amp)*env},[
			[20,15000,\exponential,1],
			[0.1,1000,\exponential,0.1],
			[0.002,0.99,\linear,0.001],
			[0,10,\linear,0.1],

		]);
)

a=Instr(\modsin).add;
b=Synth(a.name,[\gate,1]);
b.set(\gate,0);
b.release;
