(
	Ppar([
	Pbind(	\instrument, \default, \dur, 0.14, \degree, 
		Pseq( 
			[
				Pser([60,63,66,69,66,63],	16)-50,
				Pser([59,63,67,70],		16)-50,
				Pser([57,63,64,65,69,65,64,63],	16)-50,
			],3)),  
			
	Pbind(	\instrument, \default, \dur, 0.14, \degree, 
		Pseq( 
			[
				Pser([50,51,52,51],	14)-30,
				Pser([59,63,67,70,72],		16)-60,
				Pser([57,63,64,65,69,64,63],	18)-40,

		],3))     
	]).play
)
