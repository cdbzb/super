Instr(\modsin,{|freq=400,rate=5,width=0.05,amp=0.1| 
	ModSin(freq,rate, width,amp)},[
		[20,15000,\exponential,1],
		[0.1,1000,\exponential,0.1],
		[0.002,0.99,\linear,0.001]
	]);
