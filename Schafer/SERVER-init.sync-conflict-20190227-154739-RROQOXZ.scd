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
	~bassManagement={ |cutoff=70|
	{Out.ar(17,BLowPass.ar(Mix.ar(In.ar([10,11,12,13,14,15,16,17])),cutoff))}.play;
		//var channels=In.ar(~speakers);
		//var bass = BLowPass.ar(Mix.ar(channels,120));
		//Out.ar(~speakers[0],BHiPass.ar(channels,cutoff));
		//Out.ar(17,bass);
	}.play
)

s.plotTree;
s.free(1006);
~bassManagement.set([\cutoff,90]);
~bassManagement.free;

