

(
[
        freq:Pwhite(100,1000,inf),
        dur:Pwhite(0.1,1),
        legato:8,
        out:Effect({ 
		|i| 
		SineShaper.ar(i,MouseX.kr(0,0.1))
		=>FreeVerb.ar(_,0.5,1) 
	//	=> Disintegrator.ar(_,  probability: 0.5,  multiplier: 0.0,  mul: 1.0,  add: 0)
	}).bus.index,
].pp
    )
