Server.default=s=Server.local;

a={FreeVerb.ar(Blip.ar(MouseX.kr(600,1200),10*MouseY.kr(0,1))*0.2*MouseY.kr(0,1),mix:0.9,room:0.8 )}.play(s,1);


a={|freq=6500|SinOsc.ar(freq,0,SinOsc.ar(40))*EnvGen.kr(Env.linen(2,120,600))*0.3}.play(s,1);
s.meter;
a.set(\freq,7000);
a.release(10);

Server.default=s=Server.local;
