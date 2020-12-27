
(
~modulator = Buffer.read(s,Platform.resourceDir +/+ "sounds/a11wlk01.wav");
~carrier = Buffer.alloc(s, 2048);
~carrier.loadCollection((({ 0.3.bilinrand.sin.sum3rand}!1024) ++ ({ 0.05.sum3rand}!1024))); //some custom noise
~carrier.allocReadChannel('/Users/michael/tank/super/samples/La_Mer_clean.aif',channels:0);
Buffer.read
~cepbufc = Buffer.alloc(s, 1024);
~cepbufm = Buffer.alloc(s, 1024);
~envc = Buffer.alloc(s, 2048);
~envm = Buffer.alloc(s, 2048);
)

~carrier.loadCollection((({ 0.3.bilinrand.sin.sum3rand}!1024) ++ ({ 0.05.sum3rand}!1024))); //some custom noise

(
SynthDef(\morphintime, {|out = 0, modBuf = 0, carBuf = 1|
var in, in2, chain, chain2, chain3, cepsch, cepsch2, fftsize;
fftsize = 2048;


// 1. STFT of signal
// 2. smooth spectral envelope
// get cepstrum of modulating signal
in = PlayBuf.ar(1, modBuf, BufRateScale.kr(modBuf), 1, 0, 1);
chain = FFT(LocalBuf(2048), in);
cepsch = Cepstrum(~cepbufm, chain);
// get cepstrum of carrier signal
in2 = PlayBuf.ar(1, carBuf, BufRateScale.kr(carBuf), 1, 0, 1);
//in2 = WhiteNoise.ar(0.1);
chain2 = FFT(LocalBuf(2048), in2);
cepsch2 = Cepstrum(~cepbufc, chain2);

// PV_BrickWall can act as a low-pass filter, or here, as a wol-pass lifter...
// ...in practical terms, produces a smoothed version of the spectrum
// get smooth version of modulator
cepsch = PV_BrickWall(cepsch, -0.92);
ICepstrum(cepsch, ~envm);
// get smoothed version of carrier
cepsch2 = PV_BrickWall(cepsch2, -0.92);
ICepstrum(cepsch2, ~envc);

// 3. divide spectrum of each carrier frame by smooth spectral envelope (to flatten)
chain2 = PV_MagDiv(chain2,~envc);

// 4. multiply flattened spectral carrier frame with smooth spectral envelope of modulator
chain2 = PV_MagMul(chain2, ~envm);

Out.ar( out, Pan2.ar(IFFT(chain2) *0.5) );

}).add;

)

x = Synth.new(\morphintime, [\out,3.rand,\modBuf, ~modulator, \carBuf, ~carrier  ]);



