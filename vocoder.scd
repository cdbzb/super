Vocoder.ar
{LPCAnalyzer.ar(SoundIn.ar,Impulse.ar(440,0,0.2), 256, 50)}.play

{LPCAnalyzer.ar(SoundIn.ar,Impulse.ar(440,0,0.2), 256, 50, windowtype:1)}.play

{LPCAnalyzer.ar(SoundIn.ar,Impulse.ar(440,0,0.2), 128,  MouseX.kr(1,128))}.play

{LPCAnalyzer.ar(SoundIn.ar,Impulse.ar(440,0,0.2), 1024,  MouseX.kr(1,128), windowtype:1)}.play


{LPCAnalyzer.ar(SoundIn.ar,0.1*WhiteNoise.ar, 256, MouseX.kr(1,256))}.play

//keep number of poles lower if pushing harder with bigger windows
{LPCAnalyzer.ar(SoundIn.ar,Impulse.ar(MouseY.kr(100,1000),0,0.2), 1024,  MouseX.kr(1,128),1,0.9999, 1)}.play


(
{
var source,amplitude, freq, hasFreq;

source= SoundIn.ar;

//no need, fitted filter tracks amplitudes, essentially
//amplitude= Amplitude.kr(source);

#freq,hasFreq= Pitch.kr(source);

LPCAnalyzer.ar(source,if(hasFreq,Impulse.ar(freq),0.25*WhiteNoise.ar), 256,MouseX.kr(1,256), windowtype:1)

}.play
)


//singing with myself after three seconds
(
{
var source,amplitude, freq, hasFreq;

source= SoundIn.ar;

amplitude= Amplitude.kr(source);

LPCAnalyzer.ar(source,CombC.ar(source,3.0,3.0,10.0), 256,MouseX.kr(1,256)).dup(2)

}.play
)

(
{
var input,source;

input= Resonz.ar(Saw.ar(SinOsc.kr([0.1,0.11],500,600)),LFNoise1.kr(LFNoise1.kr(4,3.5,7),700,2500),LFNoise2.kr(0.5,0.3,0.4));

source= SoundIn.ar;

LPCAnalyzer.ar(input,source, 64,MouseX.kr(1,64), windowtype:1)

}.play
)


//test variable order
{LPCAnalyzer.ar(SoundIn.ar,Impulse.ar(MouseX.kr(10,1000,'exponential'),0,0.2), 256, 256,1,0.999)}.play

{LPCAnalyzer.ar(SoundIn.ar,Impulse.ar(MouseX.kr(10,1000,'exponential'),0,0.2), 256, 256,1,MouseY.kr(0.9,1.0).sqrt)}.play









//////////////////////////////////////

//residual test assumes windowtype 0)
(
{
var input,source;
var delaytime= 1024.0/SampleRate.ir;

input= SoundIn.ar;

source= Impulse.ar(delaytime.reciprocal);

(DelayN.ar(input,delaytime, delaytime)- LPCAnalyzer.ar(input,source,1024,MouseX.kr(1,256))).poll(10000)

}.play
)