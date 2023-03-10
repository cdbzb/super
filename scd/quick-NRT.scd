(
SynthDef(\finishedStore, {
	SendReply.ar(Impulse.ar(0), '/finishedStore');
	Line.ar(dur: 0.001, doneAction: 2);
	Silent.ar
}).store
)


(
~plotNRT = { |function, duration = 1, numChannels = 1, action|
	var soundFile, array;
	var synthDef = function.asSynthDef;
	var dateString = Date.getDate.stamp;
	var renderString = "render_" ++ dateString;
	var soundFileName = Platform.recordingsDir +/+ renderString ++ ".aiff";
	var options = ServerOptions().numOutputBusChannels = numChannels;
	var oscFunc = OSCFunc({ |msg|
		// produces score and renders aiff
		Score.recordNRT(
			[
				[0.0, [\s_new, synthDef.name, 1000, 0, 0]],
				[duration, [\c_set, 0, 0]]
			],
			("~/" ++ renderString ++ ".osc").standardizePath,
			soundFileName,
			options: options,
			duration: duration,
			// after rendering is finished we can plot
			action: {
				soundFile = SoundFile.new;
				soundFile.openRead(soundFileName);
				{
					array = FloatArray.newClear(soundFile.numFrames);
					soundFile.readData(array);
					function.notNil.if { action.(array) };
					array.plot;
					soundFile.close;
				}.defer

			}
		);
	}, '/finishedStore').oneShot;
	// triggers synth finishedStore which triggers OSCFunc
	synthDef.store(completionMsg: [\s_new, \finishedStore, -1]);
}
)


// plot 120 seconds
// audio file stored in SC recordings directory

~plotNRT.({ LFDNoise3.ar(150) }, 120, action: { |x| a = x })

a.size
-> 5292032

a[(400000..420000)].plot
(
	var server = Server(\nrt,
		options: ServerOptions.new
		.numOutputBusChannels_(1)
		.numInputBusChannels_(0)
	);
	var bufnum = server.bufferAllocator.alloc(1);
	
	a = Score([
		[0.0, 
			[ 'b_allocRead', bufnum, (Platform.resourceDir +/+ "sounds/a11wlk01.wav").asString, 0, 0 ],
			['/d_recv',
				SynthDef(\NRTsine, { |out, freq = 440|
					var buf = PlayBuf.ar(1, bufnum);
					var env = Env.perc(0.01, 2 - 0.01).ar();
					Out.ar(out, buf * env )
				}).asBytes
			]
			
		],
		[0.0, (x = Synth.basicNew(\NRTsine, server, 1000)).newMsg()],
		[2.0, x.freeMsg]
	]);
	
	a.recordNRT(
		outputFilePath: "/tmp/nrt.wav".standardizePath,
		headerFormat: "wav",
		sampleFormat: "int16",
		options: server.options,
		duration: 2,
		action: { "done".postln }
	);
	server.remove;
)
