IR {
	*new { |in channel=0 fftsize=4096 | // returns bufnum
		var irbuffer, bufsize, spectrum;
		var path=PathName(in);
		var bufnum = Buffer.new.bufnum;
		irbuffer = Buffer.readChannel(Server.default, in, channels:[channel], action: { |buffer|
			bufsize = PartConv.calcBufSize( fftsize, buffer);
			spectrum = Buffer.alloc(Server.default, bufsize, 1, bufnum:bufnum);
			spectrum.preparePartConv(buffer, fftsize);
			spectrum.postln;
			irbuffer.free;
		});
		^bufnum;
	}
}
