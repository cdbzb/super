Library.put(\functions,\reverb,\mono,{ |in fftSize=4096 irbufnum|
	var sig = PartConv.ar(in,fftSize,irbufnum);
	Out.ar(0,sig);
});

Library.put(\functions,\reverb,\single_stereo,{ |in fftSize=4096 bufarray | // note:these are the same!
	var sig = PartConv.ar(in,fftSize,bufarray);
	Out.ar(0,sig);
});

Library.put(\functions,\reverb,\true_stereo,{
	nil
})
