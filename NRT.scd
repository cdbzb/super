p = Platform.resourceDir +/+ "sounds/a11wlk01.wav";
q = "/tmp/pvtest.wav".standardizePath;

// get duration
f = SoundFile.openRead(p);
f.close;
f.duration  // 4.2832879818594

(
var resultbuf, inbuf;
var fftSize = 512;

z = Server(\nrt, NetAddr("127.0.0.1", 57110),
	ServerOptions.new
	.numOutputBusChannels_(2)
	.numInputBusChannels_(2)
	.sampleRate_(44100)
);

inbuf = Buffer(z, 65536, 1);
resultbuf = Buffer(z, f.duration.calcPVRecSize(fftSize, 0.5, z.options.sampleRate), 1);

x = Score([
	[0, inbuf.allocMsg],
	[0, resultbuf.allocMsg],
	[0, inbuf.readMsg(p, leaveOpen: true)],
	[0, [\d_recv, SynthDef(\pv_ana, {
		var sig = VDiskIn.ar(1, inbuf, f.sampleRate / SampleRate.ir);
		var fft = FFT(LocalBuf(fftSize, 1), sig);
		fft = PV_RecordBuf(fft, resultbuf, run: 1);
		Out.ar(0, sig);
	}).asBytes]],
	[0, Synth.basicNew(\pv_ana, z).newMsg],
	[f.duration + (fftSize / z.options.sampleRate),
		resultbuf.writeMsg(q, "wav", "float")
	]
]);

x.recordNRT(
	outputFilePath: if(thisProcess.platform.name == \windows) { "NUL" } { "/dev/null" },
	headerFormat: "wav", sampleRate: z.options.sampleRate,
	options: z.options,
	duration: f.duration + (fftSize / z.options.sampleRate),
	action: { "done".postln }
);

z.remove;
)

(
//s.boot;

// this is the pv_rec result
b = Buffer.read(s, q);
)

(
SynthDef(\pvmouse, { |out = 0, recBuf = 1, fftSize = 512|
	var in, chain, bufnum;
	bufnum = LocalBuf.new(fftSize);
	chain = PV_BufRd(bufnum, recBuf, MouseX.kr(0, 1));
	//chain = PV_BinShift(bufnum, MouseY.kr(1,2,\exponential),1);
	Out.ar(out, IFFT(chain).dup);
}).add;
)

a = Synth(\pvmouse, [recBuf: b]);
a.free;
)
