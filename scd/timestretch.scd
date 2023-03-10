Item.list
    (
    var sf;
    // path to a sound file here
    p = Platform.resourceDir +/+ "sounds/a11wlk01.wav";
    // the frame size for the analysis - experiment with other sizes (powers of 2)
    f = 8192;
    // the hop size
    h = 0.5;
    // get some info about the file
    sf = SoundFile.new( p );
    sf.openRead;
    sf.close;
    // allocate memory to store FFT data to... SimpleNumber.calcPVRecSize(frameSize, hop) will return
    // the appropriate number of samples needed for the buffer
    y = Buffer.alloc(s, sf.duration.calcPVRecSize(f, h));
    // allocate the soundfile you want to analyze
    z = Buffer.read(s, p);
    )

    // this does the analysis and saves it to 'y'... frees itself when done
    (
    SynthDef("pvrec", { arg recBuf=1, soundBufnum=2;
        var in, chain, bufnum;
        bufnum = LocalBuf.new(8192, 1);
        Line.kr(1, 1, BufDur.kr(soundBufnum), doneAction: 2);
        in = PlayBuf.ar(1, soundBufnum, BufRateScale.kr(soundBufnum), loop: 0);
        // note the window type and overlaps... this is important for resynth parameters
        chain = FFT(bufnum, in, 0.25, 1);
        chain = PV_RecordBuf(chain, recBuf, 0, 1, 0, 0.25, 1);
        // no ouput ... simply save the analysis to recBuf
        }).add;

    a = Synth("pvrec", [\recBuf, y, \soundBufnum, z]);
    )

    // you can save your 'analysis' file to disk! I suggest using float32 for the format
    // These can be read back in using Buffer.read

    y.write(p++".scpv", "wav", "float32");

    // play your analysis back ... see the playback UGens listed above for more examples.
    (
    SynthDef("pvplay", { arg out=0, recBuf=1, rate=1;
        var in, chain, bufnum;
        bufnum = LocalBuf.new(8192);
        chain = PV_PlayBuf(bufnum, recBuf, rate, 0, 1, 1, 0.25, 1);
        Out.ar(out, IFFT(chain, 1).dup);
        }).add;
    );
    b = Synth("pvplay", [\out, 0, \recBuf, y,\rate,0.1]);
    b.free
(
Item(\necessary).pvBuffer.write("test.scpv", "wav","float32")
Synth(\pvplay,[\recBuf, a])
a=Buffer.read(s,"test.scpv")
a=Signal.readNew(
	Item(\necessary).buffer.loadToFloatArray(action:{|array|a=array},)
	a.fft()
	~cosines=Signal.fftCosTable(a.size)
	~imaginary=Signal.newClear(a.size)
	~fft=fft(a,~imaginary,~cosines)
	~fft.class
	a.asSignal
	FloatArray
)

    var size = 512, real, imag, cosTable, complex;

    real = Signal.newClear(size);
            // some harmonics
    real.sineFill2([[8], [13, 0.5], [21, 0.25], [55, 0.125, 0.5pi]]);
            // add a little noise
    real.overDub(Signal.fill(size, { 0.2.bilinrand }));

    imag = Signal.newClear(size);
    cosTable = Signal.fftCosTable(size);

    complex = fft(real, imag, cosTable);
    [real, imag, (complex.magnitude) / 100 ].flop.flat
        .plot("fft", Rect(0, 0, 512 + 8, 500), numChannels: 3);

	Object
	Item(\necessary).writeArchive("/tmp/necessary")
	b=Object.readArchive("/tmp/necessary")
	b.play
)
