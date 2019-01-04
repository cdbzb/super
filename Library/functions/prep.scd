~fftsize=4096;

Library.put(\functions,\prep,
	{|in channel=0 fftsize=4096 | // in is fullPath, label is symbol
		    // to use call: PartConv.ar(Library.at(\label)) 
	var irbuffer, bufsize, spectrum;
	var path=PathName(in);
	var bufnum = Buffer.new.bufnum;
	irbuffer = Buffer.readChannel(s, in, channels:[channel], action: { |buffer|
		bufsize = PartConv.calcBufSize( fftsize, buffer);
		spectrum = Buffer.alloc(s, bufsize, 1, bufnum:bufnum);
		spectrum.preparePartConv(buffer, fftsize);
		spectrum.postln;
		irbuffer.free;
	});
	bufnum;
});

(
	Library.put(\functions,\prepStereo, { | in| //returns aray of bufs
		var bufs=Array.newClear(2);
		var file = SoundFile.openRead(in);
		('num chans ' ++ file.numChannels).postln;
		file.numChannels.do({ |index|
			('channel '++index).postln;
			//// put channels into stereo buffer and write out!!!!!!!!!
			bufs[index]=Library.at(\functions,\prep).(~file.path , channel: index);
		});
		bufs;
	})
)

Library.at(\functions,\prepStereo).("/Users/michael/tank/IR/Saane/Church_Schellingwoude/Schellingwoude_m-st.wav");


