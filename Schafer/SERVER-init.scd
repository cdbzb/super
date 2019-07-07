// SERVER MACHINE INIT
(
	~speakers=Array.series(8, start: 2);

	~setOptions={
		o=Server.local.options;
		o.numOutputBusChannels = 18;
		o.sampleRate=48000;
		o.numInputBusChannels=0;
		o.memSize=2**20;
		o.device="ULN2 [570]";
		//o.outputStreamsEnabled="001111111100000000";
		s.options.maxLogins=2;
	}.value;
	~bassManagement={ |cutoff=70 vol=0.3|
	Out.ar(~speakers[7],BLowPass.ar(Mix.ar(In.ar(~speakers))*vol,cutoff));
	};


	//ServerBoot.add(~setOptions);
	//ServerTree.add({b=~bassManagement.play});
	s.waitForBoot({
		s.meter;
		s.plotTree;
	});
)
s.reboot;
s.options.sampleRate;
ServerTree.objects;
ServerTree.removeAll;
a={PinkNoise.ar(0.05)!8}.play(s,~speakers);
a.free;
c={PinkNoise.ar(0.05)!2}.play;
b.free;
b.set(\vol,0.3); // Sub Volume
s.free(1006);
s.reboot;
