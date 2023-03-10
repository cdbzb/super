thisProcess.nowExecutingPath;

SinOsc.ar(300,  phase: 0,  mul: 1,  add: 0)
SinOsc.ar(500);
{
	Mix.ar([
		3.do({|i|
			SinOsc.ar(i*300,0,0.5)})
		])
	}
Saw.ar(freq: 440,  mul: 1,  add: 0)



SinOsc.ar(freq: 440,  phase: 0,  mul: 1,  add: 0)
SinOsc.ar(300	,  phase: 0,  mul: 1,  add: 0)

fork
fork	:
{}; 	

{

}.fork;


{SinOsc.ar}.play;
{ SinOsc.ar(300) }.play;
{

}.fork;
aaaaa
{ SinOsc.ar(freq: 440,  phase: 0,  mul: 1,  add: 0) }.play;
a= {}.play;
a= { SinOsc.ar(300) }.play;
b = { Saw	 }.play;
b = { SinOsc.ar(400,0,0.1) }.play;
a={ SinOsc.ar(400) }.play;

a={ SinOsc.ar(300) }.play;








