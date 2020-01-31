// Examples of Server options
s.reboot

o = Server.local.options;

// Post the number of output channels

o.numOutputBusChannels.postln;
o.device.postln;

// Set them to a new number

o.numOutputBusChannels = 8; // The next time it boots, this will take effect

// specify a device

o.device ="ULN2 [570]";     // use a specific soundcard
o.device ="Dante Via 16 Channel";     // use a specific soundcard
o.device = nil;            // use the system default soundcard

// Create a new instance of ServerOptions

o = ServerOptions.new;

// Set the memory size to twice the default

o.memSize = 4096;

// Create a new Server on the local machine using o for its options

t = Server(\Local2, NetAddr("127.0.0.1", 57111), o);
t.makeWindow;
t.boot;
t.quit;
