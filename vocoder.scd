Vocoder.ar

// for sampling rates 88200 and 96000, replace LocalBuf(1024, 1) by LocalBuf(2048, 1) below

d = Buffer.read(s, Platform.resourceDir +/+ "sounds/a11wlk01.wav");

(
{

    var in, fft;

    in = SoundIn.ar(0); // PlayBuf.ar(1, d, BufRateScale.kr(d), 1, 0, 1);
    fft = FFT(LocalBuf(1024, 1), in, wintype:1);
    DelayN.ar(TPV.ar(fft, 1024, 512, 70, MouseX.kr(1,70), MouseY.kr(0.25,3), 4, 0.2), 3, 3)

}.play
)

(
{

    var in, fft;

    in = PlayBuf.ar(1, d, BufRateScale.kr(d),1,0,1);
    fft = FFT(LocalBuf(1024, 1), in, wintype:1);
    TPV.ar(fft, 1024, 512, 50, 50, 1.0, MouseX.kr(0.1,100), MouseY.kr(-20,40).dbamp);

}.play
)


(
{

    var in, fft;

    in = PlayBuf.ar(1, d, BufRateScale.kr(d), 1, 0, 1);
    fft = FFT(LocalBuf(1024, 1), in);
    TPV.ar(fft, 1024, 512, 1,1);

}.plot(0.05, s, nil, -1.5, 1.5);
)


// residual

(
{

    var in, fft, output;
    var input, inputAmp, threshhold, gate;

    in = PlayBuf.ar(1, d, BufRateScale.kr(d), 1, 0, 1);
    //in = SoundIn.ar(0);
    //inputAmp = Amplitude.kr(input);
    //threshhold = 0.001;    // noise gating threshold
    //gate = Lag.kr(inputAmp > threshhold, 0.01);
    //in = input * gate;

    fft = FFT(LocalBuf(1024, 1), in, wintype:1);

    output = TPV.ar(fft, 1024, 512, 50, 50, 1.0, 4, 0.2);

    // delay by 512 samples for output, then phase measurement is from centre of frame, so

    output - DelayN.ar(in, 0.1, (512 + 512) / s.sampleRate) * 0.1

}.play
)



d.free
