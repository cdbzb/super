(

 // also 4096 works on my machine; 1024 too often and amortisation too pushed, 8192 more high load FFT
~fftsize =4096;

~prep = {|in|
var ir, irbuffer, bufsize;
Routine({
	in.postln;


 irbuffer = Buffer.read(s, in);
 //irbuffer = Buffer.readChannel(s, "/Users/michael/tank/IR/Saane/Roland RE-201 Space Echo/Mode•02/Mode•02.wav",channels:0);
 //irbuffer = Buffer.readChannel(s, "/Users/michael/tank/IR/Saane/Factory\ Hall/PA\ horn\ in\ hall/PA\ horn\ in\ hall.wav",channels:1);

s.sync;

bufsize = PartConv.calcBufSize(~fftsize, irbuffer);

// ~numpartitions= PartConv.calcNumPartitions(~fftsize, irbuffer);

~irspectrum = Buffer.alloc(s, bufsize, 1);
~irspectrum.preparePartConv(irbuffer, ~fftsize);

s.sync;
irbuffer.free; // don't need time domain data anymore, 

})
};


)

~prep.("/Users/michael/tank/IR/Saane/Factory\ Hall/PA\ horn\ in\ hall/PA\ horn\ in\ hall.wav").play;
~prep.("/Users/michael/tank/IR/Saane/Roland RE-201 Space Echo/Mode•02/Mode•02.wav").play;


( // awesome space motor
{
    //var input = PlayBuf.ar(1, ~target, loop:1);
    var input = SinOsc.ar(300+100*SinOsc.ar(0.1),0,0.1);
    var input2 = SinOsc.ar(300+100*SinOsc.ar(0.11),0,0.1);
    PartConv.ar([input,input2], ~fftsize, ~irspectrum.bufnum, 0.5)
}.play
)
s.meter;

// convolve with live input
(
{
    var input = SoundIn.ar(0);
    PartConv.ar(input, ~fftsize, ~irspectrum.bufnum)
}.play
)


// only free buffers once you're finished with examples
// if you free whilst PartConv is still running, the server won't crash, but PartConv output will go to zero abruptly
(
~irspectrum.free;
~target.free;
currentEnvironment.clear;
)
