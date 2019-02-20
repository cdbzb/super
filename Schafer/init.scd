(
	o=Server.local.options;
	o.numOutputBusChannels = 8;
	s.reboot;
)

( // bass management effort FIRST
	var firstChannel = Bus.audio(s, numChannels: 8);
	~speakers=Array.series(8);
	~channels = Array.series(8, start: firstChannel.index);
	~bassManagement={ |cutoff=120|
		var bass = BLowPass.ar(Mix.ar(In.ar(~channels),120));
		Out.ar(~speakers[7],bass);
		Out.ar(~speakers[0],BHiPass.ar(In.ar(~channels),cutoff));

	}.play
)

a={Out.ar(~channels[3],PinkNoise.ar(0.1))}.play;
a.free;
~channels;
{Out.ar(~channels[4],Saw.ar(80,0.1))}.play;

s.meter;
~channels;
~channels[0].scope;
~speakers;
(
	b=Bus(index: ~channels[0],numChannels: 8);
	b.scope;
	b;
)
Bus
~channels;
~speakers=0
{Out.ar(,PinkNoise.ar(0.1))}.play;
s.meter;
s.reboot;

Bus.freeAll;
Bus(index:1).numChannels;
Bus


