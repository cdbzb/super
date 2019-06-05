	o=Server.local.options;
	o.numOutputBusChannels = 18;
	o.numInputBusChannels=0;
	o.memSize=2**17;
	o.device="ULN2 [570]";
	o.outputStreamsEnabled="001111111100000000";
	s.options.maxLogins=2;
	s.reboot;

