//(
//	o=ServerOptions.new(s);
//	o=Server.local.options;
//	o.sampleRate=48000;
//	s.reboot;
//)

(
	~voPauseAmp = { arg pause=1, amp=0.3;
	var buffers = SoundFile.collectIntoBuffers("~/tank/THE FUTURE/VO/*");
		Routine.new({ //arg pause;
			buffers.do({|item index|
				//item.postln;
				{Out.ar([0,1],PlayBuf.ar(1,item)*amp)}.play;
				pause.wait;
			})
		}).play
	}
)

//~voPauseAmp.(8,0.03);

