// load things
(
b = Buffer.read(s, "/Users/michael/tank/super/samples/La_Mer_clean.aif");
z=Item("keep this body");
c = Bus.new('control', 0, 13);
//d = Buffer.read(s, "/Users/home/Documents/Jennifer/421b/data/rainm.wav");
d=z.buffer;
~fftbufc = Buffer.alloc(s, 2048);
~fftbufm = Buffer.alloc(s, 2048);
~cepbufc = Buffer.alloc(s, 1024);
~cepbufm = Buffer.alloc(s, 1024);
~envc = Buffer.alloc(s, 2048);
~envm = Buffer.alloc(s, 2048);
)
(
SynthDef("morphintime", {
|out = 0, bufnum = 0, bufnum2 = 1|
var in, in2, chain, chain2, chain3, cepsch, cepsch2, fftsize;
fftsize = 2048;
bufnum = b.bufnum;
bufnum2 = d.bufnum;
// 1. STFT of signal
// 2. smooth spectral envelope
// get cepstrum of modulating signal
in = PlayBuf.ar(1, bufnum, BufRateScale.kr(bufnum), 1, 0, 1);
//in = Gendy1.arWidth(freq:300,width:1.1);
chain = FFT(~fftbufm, in);
cepsch = Cepstrum(~cepbufm, chain);
// get cepstrum of carrier signal
in2 = PlayBuf.ar(1, bufnum2, BufRateScale.kr(bufnum2), 1, 0, 1);
chain2 = FFT(~fftbufc, in2);
cepsch2 = Cepstrum(~cepbufc, chain2);

// PV_BrickWall can act as a low-pass filter or here, as a wol-pass lifter...
// ...in practical terms, produces a smoothed version of the spectrum
// get smooth version of modulator
cepsch = PV_BrickWall(cepsch, -0.95);
ICepstrum(cepsch, ~envm);
// get smoothed version of carrier
cepsch2 = PV_BrickWall(cepsch2, -0.95);
ICepstrum(cepsch2, ~envc);
// 3. divide spectrum of each carrier frame by
// smooth spectral envelope (to flatten)
chain2 = chain2.pvcalc2(~envc, fftsize, {|mags, phases, mags2, phases2|
[mags / mags2, phases - phases2]
}, frombin: 0, tobin: 125, zeroothers: 0);
// 4. multiply flattened spectral carrier frame with smooth spectral envelope
// of modulator
chain2 = chain2.pvcalc2(~envm, fftsize, {|mags, phases, mags2, phases2|
[mags * mags2, phases + phases2]
}, frombin: 0, tobin: 125, zeroothers: 0);
Out.ar( out, Pan2.ar(IFFT(chain2)) );
}).send(s);
)
x = Synth.new("morphintime");
(note:1).play

