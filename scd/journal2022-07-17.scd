(
	 fork { 	 
		 loop { 
			 {
				 Saw.ar(200.rrand(500.0),0.1) //try cauchy? or gauss?
				 => RLPF.ar(_,8000.exprand(1))
				 * Env.perc(13.rrand(20),12.rrand(70)).kr(2,gate:1)
				 => Pan2.ar(_,-1.rrand(1))
				 *0.1
			 }.play;3.0.wait;1.0.wait 
		 }
	 } 
 )
