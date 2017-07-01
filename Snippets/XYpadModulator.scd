// snippet to show Mouse aquisition

s.boot

(
	{
	var modulator , carrier;
	modulator = SinOsc.ar(MouseX.kr(100,1000),0,MouseY.kr(0.1,1000));
	carrier = SinOsc.ar((440  +modulator),0,0.1);
}.play
)



