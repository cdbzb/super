5.collect(2**_ => _.asInteger).do{|channels|
	SynthDef("diskout"++channels.asString, { |bufnum, bus |
		DiskOut.ar(bufnum, In.ar(bus ,channels));
	}).add;

	// this will play it back
	SynthDef("diskin"++channels.asString, { |out, bufnum = 0|
		Out.ar(out, DiskIn.ar(channels, bufnum))
	}).add;
}

