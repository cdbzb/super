
(
~carrier = Bus.audio;
~modulator = Bus.audio;

	SynthDef(\soundInMorph2, {
		|out = 0, modulator = 0, carrier = 1, dur = 10 fftsize = 2048| // takes bus indices
		var in, in2, chain, chain2, chain3, cepsch, cepsch2 ;//fftsize = 2048;
		var modulatorEnvelope=LocalBuf(fftsize); var carrierEnvelope=LocalBuf(fftsize);
		var modulatorCepstrum=LocalBuf(fftsize/2); var carrierCepstrum=LocalBuf(fftsize/2);
		//fftsize = 2048;
		in = In.ar(modulator);
		chain = FFT(LocalBuf(fftsize), in);
		cepsch = Cepstrum(modulatorCepstrum, chain);
		in2 = In.ar(carrier);
		chain2 = FFT(LocalBuf(fftsize), in2);
		cepsch2 = Cepstrum(carrierCepstrum, chain2);
		cepsch = PV_BinShift( 
			cepsch,
			shift:MouseX.kr(-20,20),
			stretch:MouseY.kr(-1,2)
		);
		cepsch = PV_BrickWall(cepsch, SinOsc.ar(0.1));
		ICepstrum(cepsch, modulatorEnvelope);
		cepsch2 = PV_BrickWall(cepsch2, SinOsc.ar(0.134));
		ICepstrum(cepsch2, carrierEnvelope);
		chain2 = PV_MagDiv(chain2,carrierEnvelope);
		chain2 = PV_MagMul(chain2, modulatorEnvelope);
		Out.ar( out, Pan2.ar(IFFT(chain2) * \amp.kr(0.5), \pan.kr(0)) );
		Line.kr(0,1,dur,doneAction:2)
	}).add;
)
(
{
	//var rate = [0.9,1,1.1,1.25].choose;
	var rate = 1;
	Synth(\soundInMorph2,[\pan,rrand(-1,1),\out,0,\modulator,~modulator.index,\carrier,~carrier.index,\dur,100,\amp:0.8,\fftsize,8192],addAction:\addToTail);
	Item(\order).play(out:~modulator.index,loop:1,rate:rate);
	Item(\order).play(out:~carrier.index,loop:10,rate:rate);
	//{Saw.ar(200)*0.1}.play(s,~carrier.index);
}.()//.sched([ 0,0.4,2,2.4,6.5 ])
)
Cepstrum
