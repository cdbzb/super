(
s.waitForBoot{
	MicroKeys(\b).synth_(\harp).range_( (0..50) );
	//why does adding this function break things??????
	// MicroKeys(\b).add(\quiet, {|e|e.debug("xxx"); try{e.vel= (e.vel/ 10) max: 0.02} ? e}, \addBefore, \synth);
	// MicroKeys(\b).namedList.removeAt(\quiet)
	MIDIItem("trashme_241209_091414")
	// .record(MicroKeys(\b))
	.play(MicroKeys(\b))
	// MIDIItem("trashme_241209_091414").play(MicroKeys(\b))
}

)
MicroKeys(\b).activate

