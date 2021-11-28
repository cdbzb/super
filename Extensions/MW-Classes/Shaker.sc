//Shaker : StkInst { 
//	*new{|instrument=0 gate=1 onamp=0.1 offamp=0.1 number=32 resonantFreq=1 energy=1 decay=1|
//		^StkInst.multiNewList([
//			'audio',
//			instrument.midicps,
//			onamp,
//			offamp,
//			Stk.at("Shakers"),
//		]	++ [11,number,1,resonantFreq*128,4,decay*128,2,energy*128]
//)}
/*
- Shake Energy = 2
    - System Decay = 4
    - Number Of Objects = 11
    - Resonance Frequency = 1
    - Shake Energy = 128

*/
//}
