4.collect(2**_ => _.asInteger).do{
	|channels|
	channels.postln;
	//SynthDefLibrary.currentPack_(\disk_in_out);
	SynthDef("diskout"++channels.asString, { |bufnum, bus |
		DiskOut.ar(bufnum, In.ar(bus ,channels));
	}).add.tag(\disk);

	// this will play it back
	SynthDef("diskin"++channels.asString, { |out, bufnum = 0|
		Out.ar(out, DiskIn.ar(channels, bufnum))
	}).add.tag(\disk);
} ;
//SynthDefLibrary.currentPack_(\end)


