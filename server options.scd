(
o=Server.local.options;
o.numOutputBusChannels=14;
o.numInputBusChannels=12;
o.device="ULN2 [570]";
//o.outputIndex=10;
o.outputStreamsEnabled="0000000000111111";
o.inputStreamsEnabled="11111111111111";
s.reboot;
)
{Out.ar([10,11],In.ar(0,2))}.play.tail;

s.meter;