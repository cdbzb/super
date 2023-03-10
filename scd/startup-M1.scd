(
var files="/Users/michael/tank/super/Library/functions/*".pathMatch;
//files=files++"/Users/michael/tank/super/Library/synthdefs/*".pathMatch;
//files=files++"/Users/michael/tank/super/SynthDefLibrary/*".pathMatch;
o=Server.local.options;
o.numOutputBusChannels = 8;
o.sampleRate=48000;
o.numInputBusChannels= 2;
o.memSize=2**20;
//o.device="ULN2 [570]";
//o.outputStreamsEnabled="001111111100000000";
//s.options.maxLogins=2;
s.options.bindAddress_("0.0.0.0");
s.options.maxLogins_(3);
files.do({|file| file.load; file.postln});
Library.postTree;
)
