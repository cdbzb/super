SynthDef(\sawTw,{ |freq=400 amp=1 spread=5 | 
	var env= Env.perc(0.2,6!4.rand).kr(2,gate:1);
	var sig=Splay.ar ( Saw.ar( rrand(spread,(-1*spread))+freq,0.2) )
	.distort*env
	;
	sig=sig+CombN.ar(sig,1,0.3,3);
	sig=sig/1.5+Phaser2.ar(sig,rate:0.2	);
	Out.ar(\out.kr(0),sig*amp)
	//Out.ar(0,sig)
}).add.tag(\keys);
