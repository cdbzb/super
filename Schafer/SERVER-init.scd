// SERVER MACHINE INIT
(
	o=Server.local.options;
	o.numOutputBusChannels = 18;
	o.numInputBusChannels=0;
	o.device="ULN2 [570]";
	o.outputStreamsEnabled="110000000011111111";
	s.options.maxLogins=2;
	s.reboot;
)

( // bass management 
	~speakers=Array.series(8, start: 10);
	~bassManagement={ |cutoff=120|
		var channels=In.ar(~speakers);
		var bass = BLowPass.ar(Mix.ar(channels,120));
		Out.ar(~speakers[7],bass);
		Out.ar(~speakers[0],BHiPass.ar(channels,cutoff));
	}.play
)

//~bassManagement.set([/cutoff,100]);

