a=VocoderPattern.new(pattern: [note:[1,2,4,7],instrument:\sawSynthSustain].p,  key: \order,  effect:nil,  inputEffect:(EchoNone.ar(_,0.5,0.5,decaytime:4)),  fftSize: 2048,  hop: 0.5,  window: nil,  warp:nil,  out:1,  amp: 0.1,  pan: -1,  loop: 1,  rate: 1,  durs: nil,  dry: 0).play
a.warp
a.play

'control flow'.help


Item(\order).refresh
Item(\order).play
Item(\order).getFFT(fftSize: 4096,hop:0.25)
{SinOsc.kr(1).range(-2,1.1)}.play(s,8);
Item(\order).playFFT(fftSize: 4096,window:2,hop:0.25).map(\rate,8);
{SinOsc.kr(1.1).range(-2,1.1)}.play(s,7);
Item(\order).playFFT(fftSize: 4096,window:2,hop:0.25).map(\rate,7);
Item(\order).playFFT(window:2)
s.reboot
(note:1).play
.playFFT

{
	var rateEnvelope=item.stamp(durs);
	{rateEnvelope.kr}.play(server,bus);
	synth.map(\rate,bus);
};
