
(
SynthDef(\localBufferMorph, {|out = 0, modBuf = 0, carBuf = 1| // two buffer version
var in, in2, chain, chain2, chain3, cepsch, cepsch2;
var fftsize = 2048;
var modulatorEnvelope=LocalBuf(fftsize), carrierEnvelope=LocalBuf(fftsize);
var modulatorCepstrum=LocalBuf(fftsize/2), carrierCepstrum=LocalBuf(fftsize/2);
in = PlayBuf.ar(1, modBuf, BufRateScale.kr(modBuf), \trigger.tr(1), 0, 1);
chain = FFT(LocalBuf(2048), in);
cepsch = Cepstrum(modulatorCepstrum, chain);
in2 = PlayBuf.ar(1, carBuf, BufRateScale.kr(carBuf), 1, 0, 1);
chain2 = FFT(LocalBuf(2048), in2);
cepsch2 = Cepstrum(carrierCepstrum, chain2);
cepsch = PV_BrickWall(cepsch, -0.92);
ICepstrum(cepsch, modulatorEnvelope);
cepsch2 = PV_BrickWall(cepsch2, \smoothCarrier.kr(-0.92));
ICepstrum(cepsch2, carrierEnvelope);
chain2 = PV_MagDiv(chain2,carrierEnvelope);
chain2 = PV_MagMul(chain2, modulatorEnvelope);
Out.ar( out, Pan2.ar(IFFT(chain2) *\amp.kr(0.5),\pan.kr(0)) );
}).add;

SynthDef(\soundInMorph, {
	|out = 0, modulator = 0, carrier = 1|
	var in, in2, chain, chain2, chain3, cepsch, cepsch2, fftsize = 2048;
	var modulatorEnvelope=LocalBuf(fftsize); var carrierEnvelope=LocalBuf(fftsize);
	var modulatorCepstrum=LocalBuf(fftsize/2); var carrierCepstrum=LocalBuf(fftsize/2);
	fftsize = 2048;
	in = In.ar(modulator);
	chain = FFT(LocalBuf(fftsize), in);
	cepsch = Cepstrum(modulatorCepstrum, chain);
	in2 = In.ar(carrier);
	chain2 = FFT(LocalBuf(fftsize), in2);
	cepsch2 = Cepstrum(carrierCepstrum, chain2);
	cepsch = PV_BrickWall(cepsch, -0.92);
	ICepstrum(cepsch, modulatorEnvelope);
	cepsch2 = PV_BrickWall(cepsch2, \smoothCarrier.kr(-0.92));
	ICepstrum(cepsch2, carrierEnvelope);
	chain2 = PV_MagDiv(chain2,carrierEnvelope);
	chain2 = PV_MagMul(chain2, modulatorEnvelope);
	Out.ar( out, Pan2.ar(IFFT(chain2) *\amp.kr(0.5),\pan.kr(0)) );
}).add;

)


( 
~b=Buffer.readChannel(s,'/Users/michael/tank/super/samples/La_Mer_clean.aif',channels:0);
{PlayBuf.ar(1,~b.bufnum,loop:1,rate:2)*3}.play(s,11);
~bus= Bus.audio(s,1);
	[
		out:11,
		instrument:\sawSynthSustain, 
		dur:Pwhite(0.5,2,inf),
		legato:Prand([1,2,8,0.5],inf),
		degree:Prand([1,3,5,7],inf),
		width:Pwhite(10,50),
		tuning:\sept1,
		amp:0.1,
		octave:Pwhite(3,6),
	].pp;
	//{RecordBuf.ar(In.ar(~bus.index,1),~carrier.bufnum);0}.play;
	x = Synth.new(\soundInMorph, [
		\out,0,
		\modulator, 13, 
		\carrier,11 
		,
		//default for smooth is *negative* 0.92
		//positive numbers and zero are both interesting
		\smoothCarrier,-0.92 ,
		\pan,[ 1,-1 ].choose,
		\amp,1,
	]);
	//Item(\order).play(out:13,loop:1);
	{PlayBuf.ar(1,Item(\order).buffer,loop:1,rate:0.8) => EchoNone.ar(_,1,0.4,3)}.play(s,13)

 //{ Item(\order).playbuf(48000/s.sampleRate, loop:1,) * 0.2 => EarlyRef.ar(_,[1,1,1],[4,4,4],[5,7,8])=> DWGReverbC1C3.ar(_,1200,mix:0.1,c3:20)}.play
 )
 { Item(\order).playbuf([1,1.03],loop:1,) * 0.1 => EarlyRef.ar(_,[1,1,1],[4,4,4],[5,7,8])=> DWGReverbC1C3.ar(_,1200,mix:0.1,c3:20)}.play
 { Item(\order).playbuf(loop:1,) * 0.1 => EarlyRef.ar(_,[1,1,1],[4,4,4],[5,7,8])=> DWGReverbC1C3.ar(_,1200,mix:0.1,c3:20)}.play
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
 PV_ChainUGen.dumpClassSubtree
 (

	 "/Users/michael/tank/super/song-Synthdefs.scd".load;
SynthDef(\busVersion, {
	|out = 0, carrier = 1,modulator=0 fftsize=2048 hop=0.5| //carrier is a bufnum
	var in, in2, chain, carrierChain, chain3, cepsch, cepsch2;
	var modulatorEnvelope=LocalBuf(fftsize); var carrierEnvelope=LocalBuf(fftsize);
	In.ar(bus: modulator )
	=> FFT(LocalBuf(fftsize), _,hop,1)
	=> Cepstrum(LocalBuf(fftsize/2), _)
	=> PV_BrickWall(_, -0.92)
	=> ICepstrum(_, modulatorEnvelope);
	// get cepstrum of carrier signal
	carrierChain = 
		In.ar(carrier)
		=> FFT(LocalBuf(fftsize), _,hop,1);
	cepsch2 = 
		Cepstrum(LocalBuf(fftsize/2), carrierChain)
		=> PV_BrickWall(_, \smoothCarrier.kr(-0.92))
		=> ICepstrum(_, LocalBuf(fftsize));
	// 3. divide spectrum of each carrier frame by smooth spectral envelope (to flatten)
	// 4. multiply flattened spectral carrier frame with smooth spectral envelope of modulator
	carrierChain = PV_MagDiv(carrierChain,cepsch2)
	 => PV_MagMul(_, modulatorEnvelope);
	Out.ar( out, Pan2.ar(IFFT(carrierChain) *\amp.kr(0.5),\pan.kr(0)) );

}).add;
 )
 (
