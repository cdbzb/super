XMIDIController {
	*initClass
	{

		fork{
			MIDIClient.init;
			MIDIIn.connectAll;
			StageLimiter.activate;
		}
	}


}
