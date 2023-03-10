
(
fork{
	a=Signal.windowedSinc(2048,440,s.sampleRate);
	d = Deferred();
	b =Buffer.loadCollection(server:s, collection:a, numChannels:1, action:d.valueCallback);
	d.wait;
	{ Convolution2.ar(in:ClipNoise.ar(0.1), kernel:b!2, trigger:0, framesize:2048, mul:1.0, add:0.0) }.play;
}
)
(
a = Signal.gaussianBank(2048,[500,1200,4000],1,s.sampleRate);
b = a.collect(Buffer.loadCollection(s,_,1));
b.size
b.do{|i x| {Convolution2.ar(in:ClipNoise.ar(0.1), kernel:i, trigger:0, framesize:2048, mul:1.0, add:0.0) => Pan2.ar(_,SinOsc.kr(0.2,x-1)) }.play};
b
