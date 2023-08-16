
//~spread={|outs array channels=5| var sig = Silent.ar!channels; array.do{|i x| sig.put(outs[x],i)}; sig}

//{a= PinkNoise.ar(0.1)=>Pan2.ar(_,SinOsc.ar(1))=>~spread.([1,3],_) }.play

OutN {
	//var channels=5;
	//var outputs;
	*ar{ 
		 |outs, array, channels=5|
			var sig = Silent.ar!channels; array.do{|i x| sig.put(outs[x],i)}; ^sig
	}
}
