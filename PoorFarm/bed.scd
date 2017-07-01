{HPF.ar(Crackle.ar(1.9),100,SinOsc.ar(0.02,0,0.2,0.05))}.play;
(
{SinOsc.ar((200+(Crackle.ar(1.9)*800)),0,0.05)}.play;
{SinOsc.ar((250+(Crackle.ar(1.9)*600)),0,0.03)}.play;
{SinOsc.ar((175+(Crackle.ar(1.9)*400)),0,0.08)}.play;
)

{Out.ar(1,SinOsc.ar(25,0,SinOsc.kr(0.1,0,1)))}.play
s.meter

