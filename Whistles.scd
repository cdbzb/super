(
SynthDef(\whistle, {
	|val = 110, lt = 5|
	var sig;
	var sig1;
	var line = val*10;
	var freq = XLine.kr(val,line,4.0).round(val);
	var freq2 = XLine.kr(line,val,2.0).round(val);
	var env = Env([0,1,0,0.2,0,0.2,0],[lt,lt,lt,lt,lt,lt],-1);
	var env2 = Env([0,1,0,1,0,1,0],[lt,lt,lt,lt,lt,lt],-1);
	sig1 = SinOsc.ar(freq)*EnvGen.kr(env,doneAction:2)*0.001;
	sig = SinOsc.ar(freq2)*EnvGen.kr(env2,doneAction:2)*0.02;
	sig = (sig1 + sig)!2;
	Out.ar(0,sig);
}).add
)
(
~run = Routine{
	1.do(
		1.do(
			Synth.new(\whistle,[\val,60, \lt, 0.1]);
		);
		3.wait;
		1.do(
			Synth.new(\bumpl,[\freq, 120, \line, 4.rand+1, \lines, 4.rand+1, \liness, 4.rand+1]);
			Synth.new(\bumph,[\freq, 120, \line, 4.rand+1, \lines, 4.rand+1, \liness, 4.rand+1]);
		);
		3.wait;
	);
	1.do(
		1.do(
			Synth.new(\whistle,[\val,60,\lt,2]);
		);
		3.wait;
		2.do(
			Synth.new(\bumpl,[\freq, 121, \line, 1, \lines, 2, \liness, 3]);
			Synth.new(\bumph,[\freq, 121, \line, 3, \lines, 4, \liness, 5]);
		);
		4.wait;
	);
	1.do(
		1.do(
			Synth.new(\bumpl,[\freq, 115, \line, 4.rand+1, \lines, 4.rand+1, \liness, 4.rand+1]);
			Synth.new(\bumph,[\freq, 115, \line, 4.rand+1, \lines, 4.rand+1, \liness, 4.rand+1]);
		);
		5.wait;
		1.do(
			Synth.new(\bumpl,[\freq, 110, \line, 4.rand+1, \lines, 4.rand+1, \liness, 4.rand+1]);
			Synth.new(\bumph,[\freq, 110, \line, 4.rand+1, \lines, 4.rand+1, \liness, 4.rand+1]);
		);
		3.wait;
	);
	1.do(
		1.do(
			Synth.new(\whistle,[\val,60, \lt, 0.2]);
			1.wait;
			Synth.new(\whistle,[\val,60, \lt, 1.2]);
		);
		3.wait;
		1.do(
			Synth.new(\bumpl,[\freq, 120, \line, 4.rand+1, \lines, 4.rand+1, \liness, 4.rand+1]);
			Synth.new(\bumph,[\freq, 120, \line, 4.rand+1, \lines, 4.rand+1, \liness, 4.rand+1]);
		);
		3.wait;
	)
}.play
)


(
SynthDef(\bumpl, {
	| freq = 140, line = 3, lines = 3, liness = 4|
	var sig;
	var sig1;
	var env = Env([0,1,0,0.2,1,0.2,0],[1.0,2.5,1.1,1.5,0.5,3],-1);
	sig = Pulse.ar([freq-40, freq*line, freq*lines])*EnvGen.kr(env,doneAction:2)*0.005;
	sig = RLPF.ar(sig, 800,1.0);
	Out.ar(0,sig);
}).add
)
(
SynthDef(\bumph, {
	| freq = 140, line = 3, lines = 3, liness = 4|
	var sig;
	var sig1;
	var env = Env([0,1,0,0.2,1,0.2,0],[1.0,2.5,1.1,1.5,0.5,3],-1);
	sig1 = SinOsc.ar([(freq*line),(freq*liness),(freq*lines)])*EnvGen.kr(env,doneAction:2)*0.008;
	//sig1 = RHPF.ar(sig1,1220,1.0);
	Out.ar(1,sig1);
}).add
)

Synth.new(\bump,[\freq, 120, \line, 4.rand+1, \lines, 4.rand+1, \liness, 4.rand+1]);

s.meter

	