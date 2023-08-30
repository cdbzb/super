Shakers {
	*ar {|instrument=0,gate=1, onamp=1, offamp=1, number=32 resonantFreq=1 energy=1 decay=1|
		^StkInst.ar(Stk.at("Shakers"),instrument.midicps,gate,onamp,offamp,[11,number,1,resonantFreq*128,4,decay*128,2,energy*64]);
	}
}
