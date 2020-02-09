o=Server.local.options;
o.device_("USBStreamer ")
	.memSize_((2**17).asInt)
	.numOutputBusChannels_(4)
	.outputStreamsEnabled_("10000")
	;
s.reboot;
