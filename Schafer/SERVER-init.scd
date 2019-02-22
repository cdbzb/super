// SERVER MACHINE INIT
(
	o=Server.local.options;
	o.numOutputBusChannels = 18;
	s.reboot;
)

s.options.maxLogins=2;

( // bass management 
	var firstChannel = Bus.audio(s, numChannels: 8);
	~speakers=Array.series(8, start: 10);
	~channels = Array.series(8, start: firstChannel.index);
	~bassManagement={ |cutoff=120|
		var bass = BLowPass.ar(Mix.ar(In.ar(~channels),120));
		Out.ar(~speakers[7],bass);
		Out.ar(~speakers[0],BHiPass.ar(In.ar(~channels),cutoff));

	}.play
)

