s.reboot;
p=ProxySpace(s).push;
p.clear;

~out.stop;
(
~out.play;
~out = {Mix.ar([~wet*2,~dry])};
~lfo2 = { SinOsc.kr(0.111,0.01,0.9)};
~lfo = { SinOsc.kr(0.2*~lfo2,0.1,0.5)};
~osc = { Saw.ar ( 350+(~lfo*150), mul: ~lfo2*0.1)};
~wet = {FreeVerb.ar(~osc,1)};
~dry = {SinOsc.ar(533, 0, 0.01 )};
~osc = {SinOsc.ar(499, 0, 0.01)};
)
~wet= {FreeVerb.ar(~toVerb, mix:100, room: 0.5)};
~toVerb = {SinOsc.ar(300, mul:0.1)};

