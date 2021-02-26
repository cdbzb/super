
(
~items=(
	directory: "directory",
	files: List(),
	addd: { |self ...args| 
		args.do({|i| 
			self.files.includes(i).not.if{
				self.files.add(i)
			}
		}) 
	},
	items: {|self| self.files.collect(self.directory+/+_ ).collect(Item(_))},

)
)
 includes
Item('directory/test').arm(length:5)
Item('directory/mouth').bus_(1).play
(
a={|out| Effect({|i|
	var chain = FFT(LocalBuf(2048),i);
	chain =PV_RandComb(chain,SinOsc.kr(10.rand).unipolar);
	chain = PV_BinScramble(chain,0.3,0.2);
	IFFT(chain)
	=> LeakDC.ar(_)
	=> DetectSilenceDry.ar(_,doneAction:2)
//	 => HPF.ar(_,5580)
//	=> Out.ar(0,_)
	},out:out);
 } ;
 b=[0,1,1,0].q(inf).asStream;
 fork{
	 5.do{
 Item('directory/test').bus_(a.(b.next).bus.index);
 Item('directory/mouth').bus_(a.(b.next).bus.index);
		 Item('directory/test').play;
		 Item('directory/mouth').play(amp:0.1);
		 7.wait
	 }
 }
)

  PV_Invert

(
a={|out| Effect({|i|
	var chain = FFT(LocalBuf(2048),i);
	chain =PV_RandComb(chain,SinOsc.kr(100.rand.reciprocal,rrand(0,2*pi)).range(0.05,0.9));
//	chain = PV_BinScramble(chain,0.3,0.2);
	chain = PV_LocalMax(chain,0.01);
	
	chain = PV_PhaseShift(chain,SinOsc.kr(3));
	IFFT(chain)
	=> LeakDC.ar(_)
//	=> Pan2.ar(_,rrand(-1,1))
	=> DetectSilenceDry.ar(_,doneAction:2)
//	 => HPF.ar(_,5580)
//	=> Out.ar(0,_)
	},out:out,inputChannels:1);
};
c=a.(1).bus.index;
e=a.(0).bus.index;
d={PinkNoise.ar(0.1)}.play(s,c);
d={PinkNoise.ar(0.1)}.play(s,e);
)

(
Item('directory/moreTalking').bus_(
	Effect({|i|
		var chain = FFT(LocalBuf(2048),i);
		chain = PV_Invert(chain);
//		chain = PV_MagSmear(chain,18);
		chain = PV_MagSmooth(chain,0.999);
		chain = PV_SpectralMap(chain,0.999);
		//chain = PV_MagOnePole(chain);
		IFFT(chain)
		* Env.linen(1,5,2).kr(2)
	},out:[0,1]).bus.index
).play
)
PV_ChainUGen.dumpClassSubtree
(
a=Items(\directory);
a.directory;
a.add(\mouth,\test,\otherOne);
fork{
	9.do{ 
		a.items.do(_.play(rate:rrand(0.5,1,1),out:[0,1,[0,1]].choose));
		5.wait}
}
)
