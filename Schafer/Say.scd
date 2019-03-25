(
	~speakers=1!8;
	~numberBuffers=Array.newClear(8);
	Routine.new(
	 {
	//var voices=Say.voiceNames.choose;
	var voices=Say.findVoice(lang: \en);
	    8.do { |index|
	        SayBuf.prepare((voice: voices, lang: \en, text:index.asString, bufAction: { |b|
		    ~numberBuffers[index]=b
	        }))
	    };
	    // wait until ready to go:
	    while {~numberBuffers[7]==nil} { 0.1.wait };
	    "loading 8 bufs took % seconds.\n".postf();
	       8.do { |index|
	            var buf =~numberBuffers[index];
			{PlayBuf.ar(1,buf , rate:0.5 )}.play(s,~speakers[index]);
			(buf.numFrames/44000).wait;
			0.1.wait;
	        };
	    // cleanup buffers and files when done:
	    1.wait;
	    ~numberBuffers.do(SayBuf.freeBuf(_));
	}).play;
)

Say.voices.choose;
SayBuf.clearDir;
Say.pendingPIDs;
Say.maxPIDs=64;
s.reboot;

