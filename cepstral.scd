(
~modulator = Buffer.read(s,Platform.resourceDir +/+ "sounds/a11wlk01.wav");
~carrier = Buffer.alloc(s, 2048);
~carrier.loadCollection((({ 0.3.bilinrand.sin.sum3rand}!1024) ++ ({ 0.05.sum3rand}!1024))); //some custom noise
~carrier.allocReadChannel('/Users/michael/tank/super/samples/La_Mer_clean.aif',channels:0);
~cepbufc = Buffer.alloc(s, 1024);
~cepbufm = Buffer.alloc(s, 1024);
~envc = Buffer.alloc(s, 2048);
~envm = Buffer.alloc(s, 2048);
)


(
SynthDef(\morphintime, {|out = 0, modBuf = 0, carBuf = 1|
var in, in2, chain, chain2, chain3, cepsch, cepsch2, fftsize;
fftsize = 2048;


// 1. STFT of signal
// 2. smooth spectral envelope
// get cepstrum of modulating signal
in = PlayBuf.ar(1, modBuf, BufRateScale.kr(modBuf), \trigger.tr(1), 0, 1);
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
cepsch2 = PV_BrickWall(cepsch2, \smoothCarrier.kr(-0.92));
ICepstrum(cepsch2, ~envc);

// 3. divide spectrum of each carrier frame by smooth spectral envelope (to flatten)
chain2 = PV_MagDiv(chain2,~envc);

// 4. multiply flattened spectral carrier frame with smooth spectral envelope of modulator
chain2 = PV_MagMul(chain2, ~envm);

Out.ar( out, Pan2.ar(IFFT(chain2) *\amp.kr(0.5),\pan.kr(0)) );

}).add;

SynthDef(\localBufferMorph, {|out = 0, modBuf = 0, carBuf = 1|
var in, in2, chain, chain2, chain3, cepsch, cepsch2, fftsize;
var modulatorEnvelope,carrierEnvelope;
modulatorEnvelope=LocalBuf(2048);
carrierEnvelope=LocalBuf(2048);
fftsize = 2048;


// 1. STFT of signal
// 2. smooth spectral envelope
// get cepstrum of modulating signal
in = PlayBuf.ar(1, modBuf, BufRateScale.kr(modBuf), \trigger.tr(1), 0, 1);
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
ICepstrum(cepsch, modulatorEnvelope);
// get smoothed version of carrier
cepsch2 = PV_BrickWall(cepsch2, \smoothCarrier.kr(-0.92));
ICepstrum(cepsch2, carrierEnvelope);

// 3. divide spectrum of each carrier frame by smooth spectral envelope (to flatten)
chain2 = PV_MagDiv(chain2,carrierEnvelope);

// 4. multiply flattened spectral carrier frame with smooth spectral envelope of modulator
chain2 = PV_MagMul(chain2, modulatorEnvelope);

Out.ar( out, Pan2.ar(IFFT(chain2) *\amp.kr(0.5),\pan.kr(0)) );

}).add;

SynthDef(\soundInMorph, {
	|out = 0, modBuf = 0, carBuf = 1|
	var in, in2, chain, chain2, chain3, cepsch, cepsch2, fftsize;
	var modulatorEnvelope=LocalBuf(2048); var carrierEnvelope=LocalBuf(2048);
	var modulatorCepstrum=LocalBuf(1024); var carrierCepstrum=LocalBuf(1024);
	fftsize = 2048;


	// 1. STFT of signal
	// 2. smooth spectral envelope
	// get cepstrum of modulating signal
	//in = PlayBuf.ar(1, modBuf, BufRateScale.kr(modBuf), \trigger.tr(1), 0, 1);
	in = SoundIn.ar(bus: 0,  mul: 1.0,  add: 0.0);
	chain = FFT(LocalBuf(2048), in);
	cepsch = Cepstrum(modulatorCepstrum, chain);
	// get cepstrum of carrier signal
	in2 = PlayBuf.ar(1, carBuf, BufRateScale.kr(carBuf), 1, 0, 1);
	//in2 = WhiteNoise.ar(0.1);
	chain2 = FFT(LocalBuf(2048), in2);
	cepsch2 = Cepstrum(carrierCepstrum, chain2);

	// PV_BrickWall can act as a low-pass filter, or here, as a wol-pass lifter...
	// ...in practical terms, produces a smoothed version of the spectrum
	// get smooth version of modulator
	cepsch = PV_BrickWall(cepsch, -0.92);
	ICepstrum(cepsch, modulatorEnvelope);
	// get smoothed version of carrier
	cepsch2 = PV_BrickWall(cepsch2, \smoothCarrier.kr(-0.92));
	ICepstrum(cepsch2, carrierEnvelope);

	// 3. divide spectrum of each carrier frame by smooth spectral envelope (to flatten)
	chain2 = PV_MagDiv(chain2,carrierEnvelope);

	// 4. multiply flattened spectral carrier frame with smooth spectral envelope of modulator
	chain2 = PV_MagMul(chain2, modulatorEnvelope);

	Out.ar( out, Pan2.ar(IFFT(chain2) *\amp.kr(0.5),\pan.kr(0)) );

}).add;

)

~carrier.allocReadChannel('/Users/michael/tank/super/samples/La_Mer_clean.aif',channels:0);

( 
~bus= Bus.audio(s,1);
	[
		out:~bus.index,
		instrument:\stringyy, 
		dur:Pwhite(0.5,2,inf),
		legato:Prand([1,2,8,0.5],inf),
		degree:Prand([1,3,5,7],inf),
		width:Pwhite(10,50),
		tuning:\sept1,
		amp:0.1,
		octave:Pwhite(3,6),
	].pp;
	{RecordBuf.ar(In.ar(~bus.index,1),~carrier.bufnum);0}.play;
	x = Synth.new(\morphintime, [
		\out,0,
		\modBuf, Item(\order).buffer , 
		\carBuf, ~carrier,
		//default for smooth is *negative* 0.92
		//positive numbers and zero are both interesting
		\smoothCarrier,-0.97 ,
		\pan,[ 1,-1 ].choose,
		\amp,1,
	]);

 { Item(\order).playbuf(48000/s.sampleRate, loop:1,) * 0.2 => EarlyRef.ar(_,[1,1,1],[4,4,4],[5,7,8])=> DWGReverbC1C3.ar(_,1200,mix:0.1,c3:20)}.play
 )
 { Item(\order).playbuf([1,1.03],loop:1,) * 0.1 => EarlyRef.ar(_,[1,1,1],[4,4,4],[5,7,8])=> DWGReverbC1C3.ar(_,1200,mix:0.1,c3:20)}.play
 { Item(\order).playbuf(loop:1,) * 0.1 => EarlyRef.ar(_,[1,1,1],[4,4,4],[5,7,8])=> DWGReverbC1C3.ar(_,1200,mix:0.1,c3:20)}.play
 s.meter
 (degree:1,dur:10,instrument:\sawSynthSustain,amp:0.01,att:4,octave:3,).play
 s.plotTree

 (
	 ~bus=Bus.audio(s,1);
	 {Impulse.ar(2)*0.2}.play(s,~bus.index);
	 {Impulse.ar(2)*0.2}.play;
	 ~buffer=Buffer.alloc(s,44100,1);
 )
 (
	 {RecordBuf.ar(Impulse.ar(5),~buffer.bufnum,loop:0,doneAction:2)}.play;
	 {PlayBuf.ar(1,~buffer.bufnum)}.play(s,1)
 )
 ~buffer.plot
	
