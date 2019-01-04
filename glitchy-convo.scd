(
	~irbuffer=Buffer.read(s,"/Users/michael/tank/IR/Saane/Claustrophobia/Bath_mono.aiff");

	{
		var sig = SinOsc.ar(LFNoise1.ar(0.1,200,200),0,0.1);
		////var irbuffer = Buffer.readChannel(s,"/Users/michael/tank/IR/Saane/Claustrophobia/Bath_mono.aiff,", channels: [0]);
		PartConv.ar(sig,~fftsize, ~irbuffer);
	}.play
)


s.meter;
