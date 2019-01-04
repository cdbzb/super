(
	~irbuffer=Buffer.read(s,"/Users/michael/tank/IR/Saane/Claustrophobia/Bath_mono.aiff");
	//for glitches use wrong format for prep

	~fftsize=4096;
	{
		var sig = SinOsc.ar(LFNoise1.ar(0.1,200,200),0,0.1);
		////var irbuffer = Buffer.readChannel(s,"/Users/michael/tank/IR/Saane/Claustrophobia/Bath_mono.aiff,", channels: [0]);
		sig = PartConv.ar(sig,~fftsize, ~irbuffer);
		Out.ar([1],sig);
	}.play;
	{
		var sig = SinOsc.ar(LFNoise1.ar(0.1,200,200),0,0.1);
		////var irbuffer = Buffer.readChannel(s,"/Users/michael/tank/IR/Saane/Claustrophobia/Bath_mono.aiff,", channels: [0]);
		sig = PartConv.ar(sig,~fftsize, ~irbuffer);
		Out.ar([0],sig);
	}.play;
)

)


s.meter;
