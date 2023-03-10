// Server.killAll
// s.boot(startAliveThread:true,recover:false);
// While s.aliveThreadIsRunning.postln
// s.doWhenBooted({SinOsc.ar(436)}.play,5,"Not Running".postln);
// s.meter
// s.waitForBoot("running",5,"not running".postln);
// s.quit
// (
// n = NetAddr("127.0.0.1",57110);
// OSCdef(\test,{|msg,time,addr,recvPort| \unmatching.postln},'/chat',n);
// )
// (
// m = NetAddr("127.0.0.1",57110);
// m.sendMsg("/chat", "alarm");
// )
(
SynthDef(\bubblesa,{
	|freq = 200, noise = 50, lddf=0.2, ldsa=0.2, lddb=0.2, ldfs=0.2, ldgg=0.2, ldgh=0.2|
	var sig;
	var env=Env([0,0.1,0.2,0.3,0.4,0.3,0],[ldgh,lddf,ldgg,ldsa,lddb,ldfs],-4);
	sig = (SinOsc.ar(freq)*EnvGen.kr(env,doneAction:2)*0.02);
	//sig=Pan2.ar(sig, Line.kr(0.8,-1,6));
	Out.ar(1,sig);
}).add
)

(
SynthDef(\bubblesb,{
	|freq = 200, noise = 50, lddf=0.2, ldsa=0.2, lddb=0.2, ldfs=0.2, ldgg=0.2, ldgh=0.2|
	var sig;
	var env=Env([0,0.1,0.2,0.3,0.4,0.3,0],[ldgh,lddf,ldgg,ldsa,lddb,ldfs],-4);
	sig = (SinOsc.ar(freq)*EnvGen.kr(env,doneAction:2)*0.02);
	//sig=Pan2.ar(sig, Line.kr(0.8,-1,6));
	Out.ar(1,sig);
}).add
)
Synth(\bubblesb)
Synth(\bubblesa)

(
~synthfunc={
//~basef=50.rand+30;
~basef=8.rand+32.3;
~mulval1=3.rand+1;
~mulval=8.rand+1;
h=Array.series(6,0.25,0.18);
g=Array.series(6,0.5,0.38);
z=Array.series(4, (~basef*~mulval1),~basef);
y=Array.series(4,((~basef+1)*~mulval),(~basef+1));
~basef.postln;
~mulval.postln;
Synth(\bubblesb,[\freq,z[0],\lddf,h[0],\ldsa,h[1],\lddb,h[2],\ldfs,h[3],\ldgg,h[4],\ldgh,h[5]]);
Synth(\bubblesb,[\freq,z[1],\lddf,h[0],\ldsa,h[1],\lddb,h[2],\ldfs,h[3],\ldgg,h[4],\ldgh,h[5]]);
Synth(\bubblesa,[\freq,y[2],\lddf,h[0],\ldsa,h[1],\lddb,h[2],\ldfs,h[3],\ldgg,h[4],\ldgh,h[5]]);
Synth(\bubblesa,[\freq,y[3],\lddf,h[0],\ldsa,h[0],\lddb,h[0],\ldfs,h[0],\ldgg,h[0],\ldgh,h[0]]);
//Synth(\bubblesa,[\freq,z[4],\lddf,h[5],\ldsa,h[4],\lddb,h[3],\ldfs,h[2],\ldgg,h[1],\ldgh,h[0]]);
//Synth(\bubblesa,[\freq,z[5],\lddf,g[5],\ldsa,g[4],\lddb,g[3],\ldfs,g[2],\ldgg,g[1],\ldgh,g[0]]);
//Synth(\bubblesa,[\freq,z[6],\lddf,h[5],\ldsa,h[4],\lddb,h[3],\ldfs,h[2],\ldgg,h[1],\ldgh,h[0]]);
Synth(\bubblesb,[\freq,z[0],\lddf,h[0],\ldsa,h[1],\lddb,h[2],\ldfs,h[3],\ldgg,h[4],\ldgh,h[5]]);
Synth(\bubblesb,[\freq,z[1],\lddf,h[0],\ldsa,h[1],\lddb,h[2],\ldfs,h[3],\ldgg,h[4],\ldgh,h[5]]);
Synth(\bubblesa,[\freq,y[2],\lddf,h[0],\ldsa,h[1],\lddb,h[2],\ldfs,h[3],\ldgg,h[4],\ldgh,h[5]]);
Synth(\bubblesa,[\freq,y[3],\lddf,g[0],\ldsa,g[0],\lddb,g[0],\ldfs,g[0],\ldgg,g[0],\ldgh,g[0]]);
//Synth(\bubblesa,[\freq,y[4],\lddf,h[5],\ldsa,h[4],\lddb,h[3],\ldfs,h[2],\ldgg,h[1],\ldgh,h[0]]);
//Synth(\bubblesa,[\freq,y[5],\lddf,g[5],\ldsa,g[4],\lddb,g[3],\ldfs,g[2],\ldgg,g[1],\ldgh,g[0]]);
//Synth(\bubblesa,[\freq,y[6],\lddf,h[5],\ldsa,h[4],\lddb,h[3],\ldfs,h[2],\ldgg,h[1],\ldgh,h[0]]);
}
)


(
var r;
r = Routine {
    1.do({
		var time = 3.5;
		1.do(~synthfunc);
		(time).wait;
		1.do(~synthfunc);
		(time).wait;
		1.do(~synthfunc);
		(time).wait;
		1.do(~synthfunc);
		(time).wait;
		1.do(~synthfunc);
		(time).wait;
		1.do(~synthfunc);
		(time).wait;
		1.do(~bellfunc);
		1.do(~windfunc);
		(time).wait;
		1.do(~bellfunc1);
		(time).wait;
		1.do(~synthfunc);
		(time).wait;
		1.do(~synthfunc);
		(time).wait;
		1.do(~bellfunc1);
		(time).wait;
		1.do(~synthfunc);
		(time).wait;
		1.do(~synthfunc);
		(time).wait;
		1.do(~synthfunc);
		(time).wait;
		1.do(~synthfunc);
		1.do(~windfunc);
		(time).wait;
		1.do(~bellfunc);
		(time).wait;
		1.do(~synthfunc);
		(time).wait;

    });
	1.do({
		var time = 3.5;
		1.do(~synthfunc);
		(time).wait;
		1.do(~synthfunc);
		(time).wait;
		1.do(~synthfunc);
		(time).wait;
		1.do(~synthfunc);
		(time).wait;
		1.do(~synthfunc);
		(time).wait;
		1.do(~synthfunc);
		(time).wait;
		1.do(~bellfunc1);
		1.do(~windfunc);
		(time).wait;
		1.do(~bellfunc1);
		(time).wait;
		1.do(~synthfunc);
		(time).wait;
		1.do(~synthfunc);
		(time).wait;
		1.do(~synthfunc);
		(time).wait;
		1.do(~windfunc);
		(time).wait;
		1.do(~synthfunc);
		(time).wait;
		1.do(~synthfunc);
		(time).wait;
		1.do(~synthfunc);
		1.do(~windfunc);
		(time).wait;
		1.do(~bellfunc);
		(time).wait;
		1.do(~synthfunc);
		(time).wait;

    });
    // Wait half second before saying we're done
    0.5.wait;
    "done".postln;
}.play;
)
(
~windfunc ={
var vol = 1.01;
var env = Env.new([0,vol,0,vol,0,vol,0],[0.3,3.0,0.3,3.0,0.3,3.0],-3);
	{ BPF.ar(BrownNoise.ar(0.1.dup)*EnvGen.kr(env,doneAction:2), XLine.kr(40,17000,20.0), 0.05) }.play;
}
)
(
~bellfunc ={
	//var freq = rrand(10,40).round(5);
var vol = 0.12;
var freq = 11;
var line = 200;
var env = Env.new([0,0.7,0.5,0.0],[4.0,1.0,3.0],-3);
		{ (RLPF.ar(Saw.ar([freq*100,freq*100+100],vol)*EnvGen.kr(env, doneAction:2), XLine.kr(line,80,12), 0.001, 0.4))!2 }.play;
//{ RLPF.ar(Saw.ar([freq*6,freq*6+1],0.08), XLine.kr(line,10,8, doneAction:2), 0.5) }.play;
	{ (RLPF.ar(Saw.ar([freq*80 - 80,freq* 90 - 90],vol)*EnvGen.kr(env, doneAction:2), XLine.kr(line,80,12), 0.001,0.1))!2 }.play;
//{ RLPF.ar(Saw.ar([freq*6, freq*6+1],0.08), XLine.kr(line,10,10, doneAction:2), 0.1) }.play;
	{ (RLPF.ar(Saw.ar([freq*30 - 100,freq*300 - 300],vol)*EnvGen.kr(env, doneAction:2), XLine.kr(line,80,12), 0.01,0.4)) !2}.play;
	{ (RLPF.ar(Saw.ar([freq*30 - 98,freq*300 - 298],vol)*EnvGen.kr(env, doneAction:2), XLine.kr(line,80,12), 0.01,0.1))!2 }.play;
	{ (RLPF.ar(Saw.ar([freq*30 - 96,freq * 300 - 296],vol)*EnvGen.kr(env, doneAction:2), XLine.kr(line,80,12), 0.01,0.1))!2 }.play;
//{ RLPF.ar(Saw.ar([freq* 6 +2,freq* 6 +3],0.18), XLine.kr(line,10,10, doneAction:2), 0.8) }.play;
//{ RLPF.ar(Saw.ar([freq*6 - 2,freq*6-1],0.18), XLine.kr(line,10,8, doneAction:2), 0.8) }.play;
//{ RLPF.ar(Saw.ar([freq*6,freq*6+1],0.18), XLine.kr(line,10,12, doneAction:2), 0.8) }.play;
}
)
/*(
~bellfunc1 ={
	//iteration 1;
var vol = 0.09;
var freq = 2;
var line = 200;
var env = Env.new([0,1,0.8,0],[0.5,6.0,4.0],-3);
	{ RLPF.ar(Saw.ar([freq*100,freq*100+100],vol)*EnvGen.kr(env, doneAction:2), XLine.kr(line,40,20, doneAction:2), 0.3,0.05)!2 }.play;
//{ RLPF.ar(Saw.ar([freq*6,freq*6+1],0.08), XLine.kr(line,10,8, doneAction:2), 0.5) }.play;
	{ RLPF.ar(Saw.ar([freq*80 - 80,freq* 90 - 90],vol)*EnvGen.kr(env), XLine.kr(line,40,22, doneAction:2), 0.3,0.05)!2 }.play;
//{ RLPF.ar(Saw.ar([freq*6, freq*6+1],0.08), XLine.kr(line,10,10, doneAction:2), 0.1) }.play;
}
)*/
(
~bellfunc1 ={
	//iteration 2;
var vol = 0.000000001;
var freq = 6.rand+2;
var line = 200;
var env = Env.new([0,0.02,0],[0.5,3.0],-3);
	{ (SinOsc.ar([freq*100,freq*100+100])*EnvGen.kr(env, doneAction: 2)) }.play;
//{ RLPF.ar(Saw.ar([freq*6,freq*6+1],0.08), XLine.kr(line,10,8, doneAction:2), 0.5) }.play;
	{ (SinOsc.ar([freq*80 - 80,freq* 90 - 90])*EnvGen.kr(env, doneAction: 2)) }.play;
//{ RLPF.ar(Saw.ar([freq*6, freq*6+1],0.08), XLine.kr(line,10,10, doneAction:2), 0.1) }.play;
}
)
1.do(~windfunc)
1.do(~bellfunc)
1.do(~bellfunc1)

/*
SinOsc(
var env = Env.new([0,1,0],[0.5,3.0],-3);
	{ (SinOsc.ar(200, 0, 0.5)*EnvGen.kr(env, doneAction: 2)*0.1)!2 }.play;*/











