(
a=3.collect{|i| Signal.readWave( "/Users/michael/tank/super/samples/8-27-aah/220827_135548.aif",8192,frame:44000*i,freq:440 ).asWavetable};
b=Buffer.allocConsecutive(3,s,8192*2, numChannels:1 );
b.do{ |i x| i.loadCollection(a[x]) };
{VOsc.ar(b[0].bufnum + SinOsc.ar([0.11,0.12,0.13,0.14]).range(0,1.99), freq:[1,3,5,7].df + SinOsc.ar({ 4.5.rrand(7) }!4), mul:0.1)
=> HPF.ar(_) => SineShaper.ar(_,0.03) => _.tanh => Decimator.ar(_,bits:LFNoise0.ar(freq:8, mul:1.0, add:0.0).range(4,16))
}.play
)


(
a=Signal.gaussianBank(2048,[400,900],1,s.sampleRate);
deferred{ Buffer.loadCollection(s,a[2]) => ~func.(_)}
.then{|i| {Convolution2.ar(WhiteNoise.ar(0.1),i)}.play}
)

(

(
a=Signal.gaussianBank(2048,[400,900],1,s.sampleRate);
Buffer.loadCollection(s,a[2])
.deferThen{|i| {Convolution2.ar(WhiteNoise.ar(0.1),i)}.play}
)
)
